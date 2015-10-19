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
    DragView* currentDragView;
    NSMutableArray* concurrentDragViews;
    
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
    
    concurrentDragViews = [NSMutableArray new];
    
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    // We can get a drag or drop view - so generalize at beginning!
    MoveableView* moveableView = (MoveableView*)recognizer.view;
    
    
    // START DRAGGING
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        // bring view in front so there are no overlays from
        // other cells
        UICollectionView* collectionView = [moveableView isKindOfClass:[DragView class]] ? dragCollectionView : dropCollectionView;
        [Utils bringMoveableViewToFront:recognizer moveableView:moveableView overCollectionView:collectionView];
        
        if ([moveableView isKindOfClass:[DragView class]]) {
            comesFromSourceCollectionView = true;
        } else {
            comesFromSourceCollectionView = false;
        }
        
    }
    
    // DURING DRAGGING
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        [moveableView move:recognizer inView:mainView];
        
        // scroll issue
        centerX = recognizer.view.center.x;
        centerY = recognizer.view.center.y;

        

        
        UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)dropCollectionView.collectionViewLayout;
        isScrollHorizontally = layout.scrollDirection == UICollectionViewScrollDirectionHorizontal;
        
        bool flag = false;
        
        for (UIView* view in mainView.subviews) {
            if ([view isKindOfClass:[MoveableView class]]) {
                flag = true;
                break;
            }
        }
        
        if (!flag) {
            [mainView addSubview:moveableView];
            NSLog(@"addSubview");
//            [[NSNotificationCenter defaultCenter]
//             postNotificationName:@"TestNotification"
//             object:self];
        }
        

        [timer invalidate];
        timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(scrollCollectionView) userInfo:nil repeats:true];
        
    }
    
    // END DRAGGING AND START DROPPING
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [timer invalidate];

        if ([moveableView isKindOfClass:[DragView class]]) {
            // Move from source grid to target grid
            // TEST ONLY - use calculated drop index
            int index = 22;
            
            // 1. remove drag view from source dict
            if ([SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
                [sourceCellsDict removeMoveableView:moveableView];
            }
            // 2. convert to drop view
            DropView* dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:(DragView*)moveableView widthIndex:index];
            // 3. bring back underlying element to source view
            [self handleUnderlyingElement:dropView atIndex:index];
            // 4. add drop view to target dict
            [targetCellsDict addMoveableView:dropView atIndex:index];
            // 5. remove drag view from main view
            [moveableView removeFromSuperview];
        } else {
            // Move inside the target grid
            // TEST ONLY - use calculated drop index
            int index = 17;//arc4random_uniform(8);
            // 1. bring back underlying element to source view
            [self handleUnderlyingElement:moveableView atIndex:index];
            // 2. update all indices from drop view
            [(DropView*)moveableView move:targetCellsDict toIndex:index];
        }
        
        // refresh table views
        [dragCollectionView reloadData];
        [dropCollectionView reloadData];
        
        NSLog(@"targetCellsDict len: %lu", (unsigned long)targetCellsDict.count);
        
        [SHARED_STATE_INSTANCE setDragAllowed:false];
    }
    
    else {
        // TODO: handle cancel process
        NSLog(@"*******CANCEL*********");
        [timer invalidate];
    }
}


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

@end
