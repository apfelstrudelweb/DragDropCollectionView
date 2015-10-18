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
    
    id testObject = [[(NSMutableDictionary*) cellDictionaries[0] allValues] firstObject];
    
    
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
        
    }
    
    // DURING DRAGGING
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
           [moveableView move:recognizer inView:mainView];
        
    }
    
    // END DRAGGING AND START DROPPING
    else if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if ([moveableView isKindOfClass:[DragView class]]) {
            // Move from source grid to target grid
            // TEST ONLY - use calculated drop index
            int index = 1;
            
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
            int index = arc4random_uniform(8);
            // 1. bring back underlying element to source view
            [self handleUnderlyingElement:moveableView atIndex:index];
            // 2. update all indices from drop view
            [(DropView*)moveableView move:targetCellsDict toIndex:index];
        }
        
        // refresh table views
        [dragCollectionView reloadData];
        [dropCollectionView reloadData];
        
        NSLog(@"targetCellsDict len: %lu", (unsigned long)targetCellsDict.count);
    }
    
    else {
        // TODO: handle cancel process
        NSLog(@"*******CANCEL*********");
    }
}



// check if cell is populated:
// if so, bring back to source grid and remove from view
- (void)handleUnderlyingElement:(MoveableView*) moveableView atIndex:(int) index {
    
    DropView* underlyingView = [targetCellsDict objectForKey:[NSNumber numberWithInt:index]];
    
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
