//
//  DragDropHelper.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 06.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragDropHelper.h"
#import "UndoButtonHelper.h"
#import "Utils.h"
#import "DragCollectionView.h"
#import "DropCollectionView.h"
#import "ConfigAPI.h"
#import "ViewConverter.h"



#define SHARED_STATE_INSTANCE      [CurrentState sharedInstance]
#define SHARED_CONFIG_INSTANCE     [ConfigAPI sharedInstance]
#define SHARED_BUTTON_INSTANCE     [UndoButtonHelper sharedInstance]
#define SHARED_CONVERTER_INSTANCE  [ViewConverter sharedInstance]

@interface DragDropHelper() {
    
    // what we need from outside
    UIView* mainView;
    DragCollectionView* dragCollectionView;
    DropCollectionView* dropCollectionView;
    NSMutableDictionary* sourceCellsDict;
    NSMutableDictionary* targetCellsDict;
    
    
    // what we do process inside
    CollectionViewCell* leftCell;
    CollectionViewCell* rightCell;
    CollectionViewCell* dropCell;
    CollectionViewCell* lastLeftCell;
    
    DragView* targetDragView;
    DragView* newDragView;
    
    
    NSArray* insertCells;
    int insertIndex;
    
    // for thread safety
    MoveableView* currentBusyView;
    NSMutableArray* concurrentBusyViews;
    
    // scroll issues
    NSTimer* timer;
    float centerX;
    float centerY;
    bool isScrollHorizontally;
    bool comesFromSourceCollectionView;

}
@end

@implementation DragDropHelper

+ (DragDropHelper*)sharedInstance {
    
    static DragDropHelper *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DragDropHelper alloc] init];
    });
    return _sharedInstance;
}


- (void)initWithView:(UIView*)view collectionViews:(NSArray*) collectionViews cellDictionaries:(NSArray*) cellDictionaries {
    
    mainView = view;
    
    // countercheck for type safety
    if ([collectionViews[0] isKindOfClass:[DragCollectionView class                             ]]) {
        dragCollectionView = (DragCollectionView*) collectionViews[0];
        dropCollectionView = (DropCollectionView*) collectionViews[1];
    } else {
        dragCollectionView = (DragCollectionView*) collectionViews[1];
        dropCollectionView = (DropCollectionView*) collectionViews[0];
    }
    
    id testObject = ((NSMutableDictionary*) cellDictionaries[0]).allValues.firstObject;
    
    
    if ([testObject isKindOfClass:[DragView class]]) {
        sourceCellsDict = (NSMutableDictionary*) cellDictionaries[0];
        targetCellsDict = (NSMutableDictionary*) cellDictionaries[1];
    } else {
        sourceCellsDict = (NSMutableDictionary*) cellDictionaries[1];
        targetCellsDict = (NSMutableDictionary*) cellDictionaries[0];
    }
    
    [SHARED_STATE_INSTANCE setDragDropHelper:self];
    [SHARED_BUTTON_INSTANCE setSourceDictionary:sourceCellsDict];
    [SHARED_BUTTON_INSTANCE setTargetDictionary:targetCellsDict];
    
    concurrentBusyViews = [NSMutableArray new];
    
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    // We can get a drag or drop view - so generalize at beginning!
    MoveableView* moveableView = (MoveableView*)recognizer.view;
    
    // avoid concurrency
    if (currentBusyView && ![moveableView isEqual:currentBusyView]) {
        
        [concurrentBusyViews addObject:moveableView];
        [moveableView enablePanGestureRecognizer:false];
        // nothing to do
        return;
    }
    
    
    // START DRAGGING
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        currentBusyView = moveableView;
        
        // bring view in front so there are no overlays from
        // other cells
        UICollectionView* collectionView = [moveableView isKindOfClass:[DragView class]] ? dragCollectionView : dropCollectionView;
        [Utils bringMoveableViewToFront:recognizer moveableView:moveableView overCollectionView:collectionView];
        
        if ([moveableView isKindOfClass:[DragView class]]) {
            comesFromSourceCollectionView = true;
        } else {
            comesFromSourceCollectionView = false;
        }
        
        [SHARED_STATE_INSTANCE setTransactionActive:true]; // indicate that view is in drag state
        
    }
    
    // DURING DRAGGING
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        //NSLog(@"moveableView: %f - %f", moveableView.frame.origin.x, moveableView.frame.origin.y);

        [moveableView move:recognizer inView:mainView];
        
        // scroll issue
        [self handleScrolling:recognizer forView:moveableView];
        
        if (leftCell.isPushedToLeft) {
            [leftCell undoPush];
        }
        
        if (rightCell.isPushedToRight) {
            [rightCell undoPush];
        }
        
        // reset all cells (from previous touches)
        [dropCollectionView resetAllCells];
        
        CollectionViewCell* hoverCell = [Utils getTargetCell:moveableView inCollectionView:dropCollectionView recognizer:recognizer];
        
        // nothing more to do - wait until end position
        if (hoverCell) {
            [hoverCell expand];
            insertCells = nil;
            return;
        }
        
        insertCells = [Utils getInsertCells:moveableView inCollectionView:dropCollectionView recognizer:recognizer];
        
        // nothing more to do - wait until end position
        if (!insertCells) {
            lastLeftCell = nil;
            return;
        }
        
        // if insertion intention has been detected, prepare the left and the right cell
        leftCell  = insertCells[0];
        rightCell = insertCells[1];
        insertIndex = (int)rightCell.indexPath.item;
        
        // Prevent that the dragged cell is treated like an embedding cell group
        if (leftCell.indexPath.item == moveableView.index || rightCell.indexPath.item == moveableView.index) {
            return;
        }
        
        [leftCell push:Left];
        [rightCell push:Right];
        
        
        // calls "prepareLayout" form CollectionViewFlowLayout and populates the cache:
        // it seems that "layoutAttributesForElementsInRect" sometimes returns an empty
        // array, thus the app crashes
        [dropCollectionView.collectionViewLayout invalidateLayout];
        
    }
    
    // END DRAGGING AND START DROPPING
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [timer invalidate];
        
        if (insertCells) {
            [self insertCell:moveableView];
        } else {
            [self appendCell:moveableView recognizer:recognizer];
        }
        
        // refresh table views
        [dragCollectionView reloadData];
        [dropCollectionView reloadData];
        
        NSLog(@"targetCellsDict len: %lu", (unsigned long)targetCellsDict.count);
        
        [SHARED_STATE_INSTANCE setTransactionActive:false];
        [[CurrentState sharedInstance] setDragAllowed:false];
        
        
        // enable gesture recognizers of all concurrent drag views again
        for (MoveableView* view in concurrentBusyViews) {
            [view enablePanGestureRecognizer:true];
        }
        [concurrentBusyViews removeAllObjects];
        currentBusyView = nil;
        
        //[dropCollectionView.collectionViewLayout invalidateLayout];
    }
    
    else {
        // TODO: handle cancel process
        NSLog(@"*******CANCEL*********");
        [timer invalidate];
    }
}


/**
 * Append cell without replacing adjacent ones (= into empty spaces or overwritimg existing ones)
 */
- (void)appendCell:(MoveableView *)moveableView recognizer:(UIPanGestureRecognizer*)recognizer {
    
    dropCell = [Utils getTargetCell:moveableView inCollectionView:dropCollectionView recognizer:recognizer];
    [dropCell highlight:false];
    int dropIndex = (int)dropCell.indexPath.item;
    
    // if view is not dropped into a valid cell, handle it
    if (!dropCell) {
        [self flipBackToOrigin:moveableView];
        return;
    }
    
    if ([moveableView isKindOfClass:[DragView class]]) {
        // Move from source grid to target grid
        // 1. remove drag view from source dict
        if ([SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
            [sourceCellsDict removeMoveableView:moveableView];
        }
        
        DropView* dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:(DragView*)moveableView widthIndex:dropIndex];
        
        // first remove underlying element ...
        [self handleUnderlyingElement:dropView atIndex:dropIndex];
        // ... and the populate dictionary!
        [targetCellsDict addMoveableView:dropView atIndex:dropIndex];
        // 5. remove drag view from main view
        [moveableView removeFromSuperview];
    } else {
        // Move inside the target grid
        // 1. bring back underlying element to source view
        [self handleUnderlyingElement:moveableView atIndex:dropIndex];
        // 2. update all indices from drop view
        [(DropView*)moveableView move:targetCellsDict toIndex:dropIndex];
    }
}

/**
 * Insert cell between two adjacent cells - the right-hand cell is shifted one cell towards right
 */
- (void)insertCell:(MoveableView *)moveableView  {
    
    // TODO: fix BUG -> element crashes after it has been moved and inserted (moving it aigain)!
    
    NSIndexPath* insertionIndexPath = rightCell.indexPath;
    int highestInsertionIndex = (int)[dropCollectionView numberOfItemsInSection:0];
    insertIndex = (int)insertionIndexPath.item;
    
    DropView* dropView;
    
    if ([moveableView isKindOfClass:[DragView class]]) {
        
        // 1. view comes from source collection view
        dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:(DragView*)moveableView widthIndex:insertIndex];
        dropView.index = insertIndex;
        dropView.previousDragViewIndex = moveableView.index;
        
        if ([SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
            [sourceCellsDict removeMoveableView:moveableView];
        }

    } else {
        
        // 2. view comes from target collection view
        [targetCellsDict removeMoveableView:(DropView*)moveableView];

        dropView = (DropView*)moveableView;
        dropView.previousDropViewIndex = dropView.index;
        dropView.index = insertIndex;

    }
    
    // when target collection view is full, recover last element (which falls out)
    DropView* droppedView = (DropView*) [targetCellsDict insertObject: dropView atIndex:insertIndex withMaxCapacity:highestInsertionIndex];
    
    if (droppedView && [SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
        int prevDragIndex = droppedView.previousDragViewIndex;
        DragView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:droppedView];
        [sourceCellsDict addMoveableView:dragView atIndex:prevDragIndex];
    }

    [moveableView removeFromSuperview];
}

/**
 *
 * If cell is not dropped into a valid indexpath of collection view,
 * flip it back to source collection view (= to its origin)
 *
 **/
- (void)flipBackToOrigin:(MoveableView *)moveableView {
    [moveableView removeFromSuperview];
    
    [SHARED_STATE_INSTANCE setTransactionActive:false];
    
    if ([moveableView isKindOfClass:[DragView class]]) {
        if ([SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
            [sourceCellsDict addMoveableView:moveableView atIndex:moveableView.index];
        }
    } else {
        DragView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:(DropView*)moveableView];
        // add it to source dict again (recovery)
        [sourceCellsDict addMoveableView:dragView atIndex:((DropView*)moveableView).previousDragViewIndex];
        [targetCellsDict removeMoveableView:moveableView];
    }
}



- (void)handleScrolling:(UIPanGestureRecognizer *)recognizer forView:(MoveableView *)moveableView {
    
    // check if scrolling is necessary - if not, do nothing!
    CGSize collectionViewSize = dropCollectionView.frame.size;
    CGSize contentViewSize = dropCollectionView.contentSize;
    
    if ([Utils size:contentViewSize isSmallerThanOrEqualToSize:collectionViewSize]) {
        return;
    }
    
    
    centerX = recognizer.view.center.x;
    centerY = recognizer.view.center.y;
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)dropCollectionView.collectionViewLayout;
    isScrollHorizontally = layout.scrollDirection == UICollectionViewScrollDirectionHorizontal;
    
    if(![mainView isDescendantOfView:moveableView]) {
        [mainView addSubview:moveableView];
    }
    
    
    [timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scrollCollectionView) userInfo:nil repeats:true];
}



#pragma mark -NSTimer
-(void) scrollCollectionView {
    
    float collectionViewTop = dropCollectionView.frame.origin.y;
    
    // only scroll when collection view has been reached from top
    if (centerY < collectionViewTop) {
        [timer invalidate];
        return;
    }
    
    if (isScrollHorizontally) {
        [self scrollHorizontally];
    } else {
        [self scrollVertically];
    }
    
}

- (void) scrollHorizontally {
    
    // middle of the collection view
    float collectionViewWidth = dropCollectionView.frame.size.width;
    float collectionViewMiddle = dropCollectionView.frame.origin.x + 0.5*dropCollectionView.frame.size.width;
    
    
    float contentWidth = dropCollectionView.contentSize.width;
    float contentOffsetX = dropCollectionView.contentOffset.x;
    float contentOffsetY = dropCollectionView.contentOffset.y;
    
    float relDistanceFromMiddle = fabs(collectionViewMiddle - centerX) / collectionViewWidth;
    
    float threshold = 0.2; // min relative distance from the middle
    
    
    if (relDistanceFromMiddle < threshold) {
        [timer invalidate];
        return;
    }
    
    
    if ((contentOffsetX < 0 && centerX < collectionViewMiddle) || (contentOffsetX > contentWidth - collectionViewWidth && centerX > collectionViewMiddle)) {
        [timer invalidate];
        return;
    }
    
    
    float distX = 20*(expf(relDistanceFromMiddle - threshold) - 1);
    
    if (centerX < collectionViewMiddle) {
        dropCollectionView.contentOffset = CGPointMake(contentOffsetX-distX, contentOffsetY);
    }
    
    else if (centerX > collectionViewMiddle) {
        dropCollectionView.contentOffset = CGPointMake(contentOffsetX+distX, contentOffsetY);
    }
}


- (void) scrollVertically {
    
    // middle of the collection view
    float collectionViewHeight = dropCollectionView.frame.size.height;
    float collectionViewMiddle = dropCollectionView.frame.origin.y + 0.5*dropCollectionView.frame.size.height;
    
    float contentHeight = dropCollectionView.contentSize.height;
    float contentOffsetX = dropCollectionView.contentOffset.x;
    float contentOffsetY = dropCollectionView.contentOffset.y;
    
    float relDistanceFromMiddle = fabs(collectionViewMiddle - centerY) / collectionViewHeight;
    
    float threshold = 0.2; // min relative distance from the middle
    
    
    //    if(comesFromSourceCollectionView && centerY < collectionViewMiddle) {
    //        [timer invalidate];
    //        return;
    //    }
    
    if (relDistanceFromMiddle < threshold) {
        [timer invalidate];
        return;
    }
    
    if ((contentOffsetY < 0 && centerY < collectionViewMiddle) || (contentOffsetY > contentHeight - collectionViewHeight && centerY > collectionViewMiddle)) {
        [timer invalidate];
        return;
    }
    
    float distY = 20*(expf(relDistanceFromMiddle - threshold) - 1);
    
    
    if (centerY < collectionViewMiddle) {
        dropCollectionView.contentOffset = CGPointMake(contentOffsetX, contentOffsetY-distY);
    }
    
    else if (centerY > collectionViewMiddle) {
        comesFromSourceCollectionView = false;
        dropCollectionView.contentOffset = CGPointMake(contentOffsetX, contentOffsetY+distY);
    }
}



// check if cell is populated:
// if so, bring back to source grid and remove from view
- (void)handleUnderlyingElement:(MoveableView*) moveableView atIndex:(int) index {
    
    DropView* underlyingView = targetCellsDict[@(index)];
    
    // if drop view view is dropped back into the same cell, do nothing!
    if ([(DropView*)moveableView isEqual:underlyingView]) return;
    
    if (underlyingView) {
        // remove as underlying view from dict
        [targetCellsDict removeMoveableView:underlyingView];
        if ([SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
            // convert to drag view again
            DragView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:underlyingView];
            // add it to source dict again (recovery)
            [sourceCellsDict addMoveableView:dragView atIndex:underlyingView.previousDragViewIndex];
        }
        [underlyingView removeFromSuperview];
    }
}

//- (void)handleInitialDragView:(DragView *)dragView {
//    // Remove temporary DragView (it's only a snapshot) and replace it by a real one
//    CGRect frame = newDragView.frame;
//    [newDragView removeFromSuperview];
//
//    newDragView = [dragView provideNew];
//    newDragView.frame = frame;
//    [mainView addSubview:newDragView];
//    // we need to update the dictionary - otherwise we get empty custom views!
//    [sourceCellsDict setObject:newDragView forKey:[NSNumber numberWithInt:dragView.index]];
//}

@end
