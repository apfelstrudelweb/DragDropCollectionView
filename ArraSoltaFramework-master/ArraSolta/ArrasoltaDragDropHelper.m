//
//  DragDropHelper.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 06.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaDragDropHelper.h"
#import "ArrasoltaViewConverter.h"
#import "ArrasoltaAPI.h"

#define SHARED_CONVERTER_INSTANCE  [ArrasoltaViewConverter sharedInstance]


@interface ArrasoltaDragDropHelper() {
    
    // what we need from outside
    UIView* mainView;
    ArrasoltaSourceCollectionView* dragCollectionView;
    ArrasoltaTargetCollectionView* dropCollectionView;
    NSMutableDictionary* sourceCellsDict;
    NSMutableDictionary* targetCellsDict;
    
    
    // what we do process inside
    ArrasoltaCollectionViewCell* leftCell;
    ArrasoltaCollectionViewCell* rightCell;
    ArrasoltaCollectionViewCell* dropCell;
    ArrasoltaCollectionViewCell* lastLeftCell;
    
    ArrasoltaDraggableView* targetDragView;
    ArrasoltaDraggableView* newDragView;
    
    
    NSArray* insertCells;
    int insertIndex;
    
    // for thread safety
    ArrasoltaMoveableView* currentBusyView;
    NSMutableArray* concurrentBusyViews;
    
    // scroll issues
    NSTimer* timer;
    float centerX;
    float centerY;
    bool isScrollHorizontally;
    bool comesFromSourceCollectionView;
    
}
@end

@implementation ArrasoltaDragDropHelper

+ (ArrasoltaDragDropHelper*)sharedInstance {
    
    static ArrasoltaDragDropHelper *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ArrasoltaDragDropHelper alloc] init];
    });
    return _sharedInstance;
}


- (void)initWithView:(UIView*)view collectionViews:(NSArray*) collectionViews cellDictionaries:(NSArray*) cellDictionaries {
    
    mainView = view;
    
    // countercheck for type safety
    if ([collectionViews[0] isKindOfClass:[ArrasoltaSourceCollectionView class                             ]]) {
        dragCollectionView = (ArrasoltaSourceCollectionView*) collectionViews[0];
        dropCollectionView = (ArrasoltaTargetCollectionView*) collectionViews[1];
    } else {
        dragCollectionView = (ArrasoltaSourceCollectionView*) collectionViews[1];
        dropCollectionView = (ArrasoltaTargetCollectionView*) collectionViews[0];
    }
    
    id testObject = ((NSMutableDictionary*) cellDictionaries[0]).allValues.firstObject;
    
    
    if ([testObject isKindOfClass:[ArrasoltaDraggableView class]]) {
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
    ArrasoltaMoveableView* moveableView = (ArrasoltaMoveableView*)recognizer.view;
    
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
        UICollectionView* collectionView = [moveableView isKindOfClass:[ArrasoltaDraggableView class]] ? dragCollectionView : dropCollectionView;
        [ArrasoltaUtils bringMoveableViewToFront:recognizer moveableView:moveableView overCollectionView:collectionView];
        
        if ([moveableView isKindOfClass:[ArrasoltaDraggableView class]]) {
            comesFromSourceCollectionView = true;
        } else {
            comesFromSourceCollectionView = false;
        }
        
        [SHARED_STATE_INSTANCE setTransactionActive:true]; // indicate that view is in drag state
        
    }
    
    // DURING DRAGGING
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
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
        
        ArrasoltaCollectionViewCell* hoverCell = [ArrasoltaUtils getTargetCell:moveableView inCollectionView:dropCollectionView recognizer:recognizer];
        
        // nothing more to do - wait until end position
        if (hoverCell) {
            [hoverCell expand];
            insertCells = nil;
            return;
        }
        
        insertCells = [ArrasoltaUtils getInsertCells:moveableView inCollectionView:dropCollectionView recognizer:recognizer];
        
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
        if ([moveableView isKindOfClass:[ArrasoltaDroppableView class]] && (leftCell.indexPath.item == moveableView.index || rightCell.indexPath.item == moveableView.index)) {
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
            // update history
            [SHARED_BUTTON_INSTANCE updateHistoryBeforeAction];
            [self insertCell:moveableView];
            // now scroll to the inserted cell
            NSIndexPath* scrollToIndexPath = [NSIndexPath indexPathForItem:insertIndex inSection:0];
            
            UICollectionViewScrollPosition scrollPos = [SHARED_CONFIG_INSTANCE getScrollDirection] == horizontal ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionCenteredVertically;
            
            [dropCollectionView scrollToItemAtIndexPath:scrollToIndexPath atScrollPosition:scrollPos animated:YES];
            [SHARED_BUTTON_INSTANCE updateHistoryAfterAction];
        } else {
            [self appendCell:moveableView recognizer:recognizer];
        }
        
        

        // refresh table views
        [dragCollectionView reloadData];
        [dropCollectionView reloadData];
 
        
        [SHARED_STATE_INSTANCE setTransactionActive:false];
        [[ArrasoltaCurrentState sharedInstance] setDragAllowed:false];
        
        
        // enable gesture recognizers of all concurrent drag views again
        for (ArrasoltaMoveableView* view in concurrentBusyViews) {
            [view enablePanGestureRecognizer:true];
        }
        [concurrentBusyViews removeAllObjects];
        currentBusyView = nil;
        
        // TODO: check if we need it!
        //[dropCollectionView.collectionViewLayout invalidateLayout];
    }
    
    else {
        // TODO: handle cancel process
        //NSLog(@"*******CANCEL*********");
        [timer invalidate];
    }
}


/**
 * Append cell without replacing adjacent ones (= into empty spaces or overwritimg existing ones)
 */
- (void) appendCell:(ArrasoltaMoveableView *)moveableView recognizer:(UIPanGestureRecognizer*)recognizer {
    
    dropCell = [ArrasoltaUtils getTargetCell:moveableView inCollectionView:dropCollectionView recognizer:recognizer];
    [dropCell highlight:false];
    int dropIndex = (int)dropCell.indexPath.item;
    
    if (dropIndex < 0) {
        return;
    }
    
    // if view is not dropped into a valid cell, handle it ...
    if (!dropCell) {
 
        if ([moveableView isKindOfClass:[ArrasoltaDroppableView class]]) {
            // track drop view if moved back to the source grid
            // update history
            [SHARED_BUTTON_INSTANCE updateHistoryBeforeAction];
            [self flipBackToOrigin:moveableView];
            [SHARED_BUTTON_INSTANCE updateHistoryAfterAction];
        } else {
            // ... but don't track drag view which stays in source grid
            [self flipBackToOrigin:moveableView];
        }
        
        return;
    }
    
    // update history
    [SHARED_BUTTON_INSTANCE updateHistoryBeforeAction];
    
    if ([moveableView isKindOfClass:[ArrasoltaDraggableView class]]) {
        // Move from source grid to target grid
        // 1. remove drag view from source dict
        if ([SHARED_CONFIG_INSTANCE areSourceItemsConsumable]) {
            [sourceCellsDict removeMoveableView:moveableView];
        }
        
        ArrasoltaDroppableView* dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:(ArrasoltaDraggableView*)moveableView widthIndex:dropIndex];
        
        // first remove underlying element ...
        [self bringUnderlyingElementBackToOrigin:dropView atIndex:dropIndex];
        // ... and then populate dictionary!
        [targetCellsDict addMoveableView:dropView atIndex:dropIndex];
        // remove drag view from main view
        [moveableView removeFromSuperview];
        
    } else {
        // Move inside the target grid
        ArrasoltaDroppableView* dropView = (ArrasoltaDroppableView*)moveableView;
        // 1. bring back underlying element to source view
        [self bringUnderlyingElementBackToOrigin:moveableView atIndex:dropIndex];
        // 2. update all indices from drop view
        [dropView move:targetCellsDict toIndex:dropIndex];
    }
    [SHARED_BUTTON_INSTANCE updateHistoryAfterAction];
}

/**
 * Insert cell between two adjacent cells - the right-hand cell is shifted one cell towards right
 */
- (void)insertCell:(ArrasoltaMoveableView *)moveableView  {
    
    NSIndexPath* insertionIndexPath = rightCell.indexPath;
    int highestInsertionIndex = (int)[dropCollectionView numberOfItemsInSection:0];
    insertIndex = (int)insertionIndexPath.item;
    
    if (insertIndex < 0) {
        return;
    }
    
    ArrasoltaDroppableView* dropView;
    
    if ([moveableView isKindOfClass:[ArrasoltaDraggableView class]]) {
        
        // 1. view comes from source collection view
        dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:(ArrasoltaDraggableView*)moveableView widthIndex:insertIndex];
        dropView.index = insertIndex;
        dropView.previousDragViewIndex = moveableView.index;
        
        if ([SHARED_CONFIG_INSTANCE areSourceItemsConsumable]) {
            [sourceCellsDict removeMoveableView:moveableView];
        }
        
    } else {
        
        // 2. view comes from target collection view
        [targetCellsDict removeMoveableView:(ArrasoltaDroppableView*)moveableView];
        
        dropView = (ArrasoltaDroppableView*)moveableView;
        dropView.previousDropViewIndex = dropView.index;
        dropView.index = insertIndex;
        
    }
    
    // when target collection view is full, recover last element (which falls out)
    ArrasoltaDroppableView* droppedView = (ArrasoltaDroppableView*) [targetCellsDict insertObject: dropView atIndex:insertIndex withMaxCapacity:highestInsertionIndex];
    
    if (droppedView && [SHARED_CONFIG_INSTANCE areSourceItemsConsumable]) {
        int prevDragIndex = droppedView.previousDragViewIndex;
        ArrasoltaDraggableView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:droppedView];
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
- (void)flipBackToOrigin:(ArrasoltaMoveableView *)moveableView {
    [moveableView removeFromSuperview];
    
    [SHARED_STATE_INSTANCE setTransactionActive:false];
    
    if ([moveableView isKindOfClass:[ArrasoltaDraggableView class]]) {
        if ([SHARED_CONFIG_INSTANCE areSourceItemsConsumable]) {
            [sourceCellsDict addMoveableView:moveableView atIndex:moveableView.index];
        }
    } else {
        ArrasoltaDraggableView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:(ArrasoltaDroppableView*)moveableView];
        // add it to source dict again (recovery)
        [sourceCellsDict addMoveableView:dragView atIndex:((ArrasoltaDroppableView*)moveableView).previousDragViewIndex];
        [targetCellsDict removeMoveableView:moveableView];
    }
}



- (void)handleScrolling:(UIPanGestureRecognizer *)recognizer forView:(ArrasoltaMoveableView *)moveableView {
    
    // check if scrolling is necessary - if not, do nothing!
    CGSize collectionViewSize = dropCollectionView.frame.size;
    CGSize contentViewSize = dropCollectionView.contentSize;
    
    if ([ArrasoltaUtils size:contentViewSize isSmallerThanOrEqualToSize:collectionViewSize]) {
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
    
    //if (dropCollectionView.hasFittingCellSize) return;
    
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
- (bool)bringUnderlyingElementBackToOrigin:(ArrasoltaMoveableView*) moveableView atIndex:(int) index {
    
    ArrasoltaDroppableView* underlyingView = targetCellsDict[@(index)];
    
    // if drop view is dropped back into the same cell, do nothing!
    if ([(ArrasoltaDroppableView*)moveableView isEqual:underlyingView]) return NO;
    
    if (underlyingView) {
        // remove as underlying view from dict
        [targetCellsDict removeMoveableView:underlyingView];
        if ([SHARED_CONFIG_INSTANCE areSourceItemsConsumable]) {
            // convert to drag view again
            ArrasoltaDraggableView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:underlyingView];
            // add it to source dict again (recovery)
            [sourceCellsDict addMoveableView:dragView atIndex:underlyingView.previousDragViewIndex];
        }
        
        //        // update history
        //        History* hist = [History new];
        //        hist.deletionIndex = index;
        //        hist.previousIndex = underlyingView.previousDragViewIndex;
        //        [SHARED_BUTTON_INSTANCE updateHistory:hist incrementCounter:false];
        
        [underlyingView removeFromSuperview];
        return YES;
    }
    return NO;
}


@end
