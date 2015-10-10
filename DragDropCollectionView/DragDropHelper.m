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

#define SHARED_STATE_INSTANCE      [CurrentState sharedInstance]
#define SHARED_CONFIG_INSTANCE     [ConfigAPI sharedInstance]
#define SHARED_BUTTON_INSTANCE     [UndoButtonHelper sharedInstance]

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
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    DragView* dragView = (DragView*)recognizer.view;
    [mainView bringSubviewToFront:dragView];
    
    // START DRAGGING
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        //lastHoverCell = nil;
        
        // provide a temporary DragView as snapshot for the dragging process
        // which will be removed again when dragging is finished
        newDragView = (DragView*)[dragView snapshotViewAfterScreenUpdates:NO];
        newDragView.frame = dragView.frame;
        targetDragView = [dragView provideNew];
        
        if (![SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
            [mainView addSubview:newDragView];
        }
        
        [SHARED_STATE_INSTANCE setTransactionActive:true]; // indicate that view is in drag state
    }
    
    // DURING DRAGGING
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        // during dragging, we use a snapshot of the content view
        //[dragView setContentView:newContentView];
        //[dragView initialize];
        // move drag view AFTER cloning of itself - otherwise we get a vertical offset
        [dragView move:recognizer inView:mainView];
        
        if (leftCell.isPopulated && rightCell.isPopulated) {
            [leftCell undoPush];
            [rightCell undoPush];
        }
        
        // reset all cells (from previous touches)
        [dropCollectionView resetAllCells];
        
        CollectionViewCell* hoverCell = [Utils getTargetCell:dragView inCollectionView:dropCollectionView recognizer:recognizer];
        
        // nothing more to do - wait until end position
        if (hoverCell) {
            [hoverCell expand];
            return;
        }
        
        insertCells = [Utils getInsertCells:dragView inCollectionView:dropCollectionView recognizer:recognizer];
        
        // nothing more to do - wait until end position
        if (!insertCells) {
            lastLeftCell = nil;
            return;
        }
        
        // if insertion intention has been detected, prepare the left and the right cell
        leftCell  = insertCells[0];
        rightCell = insertCells[1];
        
        [leftCell push:Left];
        [rightCell push:Right];
    }
    
    // END DRAGGING AND START DROPPING
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (![SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
            [self handleInitialDragView:dragView];
        } else {
            // remove consumable item from dictionary
            [sourceCellsDict removeObjectForKey:[NSNumber numberWithInt:dragView.index]];
            
            // and add it to an array in order to get it back if needed
            [SHARED_STATE_INSTANCE addConsumedItem:dragView];
        }
        
        // insert cell
        if (insertCells) {
            [self insertCell:dragView];
        } else {
            [self appendCell:recognizer dragView:dragView];
        }
        
        
        // reload in order to show the new drop view - > "cellForItemAtIndexPath"
        [dropCollectionView reloadData];
        [SHARED_STATE_INSTANCE setTransactionActive:false];
    }
}


- (void)insertCell:(DragView *)dragView {
    
    [leftCell shrink];
    [rightCell shrink];
    
    NSIndexPath* insertionIndexPath = rightCell.indexPath;
    
    NSInteger numberOfItems = [dropCollectionView numberOfItemsInSection:0];
    NSIndexPath* lastIndexPath = [NSIndexPath indexPathForItem:numberOfItems-1 inSection:0];
    
    __block CollectionViewCell* newCell;
    
    [dropCollectionView performBatchUpdates:^{
        
        NSArray *indexPaths = [NSArray arrayWithObject:insertionIndexPath];
        [dropCollectionView deleteItemsAtIndexPaths:@[lastIndexPath]];
        [dropCollectionView insertItemsAtIndexPaths:indexPaths];
        
    } completion: ^(BOOL finished) {
        
        newCell = (CollectionViewCell*)[dropCollectionView cellForItemAtIndexPath:insertionIndexPath];
        
        dropCell = newCell;
        
        DropView* dropView = [[DropView alloc] initWithView:targetDragView inCollectionViewCell:dropCell];
        dropView.index = insertIndex;
        dropView.sourceIndex = dragView.index;
        
        // Now update dictionary, shifting all elements right of the insert index to right
        insertIndex = (int)insertionIndexPath.item;
        [targetCellsDict insertObject: dropView atIndex:insertIndex];
        int maxItems = (int)[dropCollectionView numberOfItemsInSection:0];
        int maxKey = [Utils getHighestKeyInDict:targetCellsDict];
        
        // avoid overflow of dictionary
        if (maxKey > maxItems-1) {
            [targetCellsDict removeObjectForKey:[NSNumber numberWithInt:maxItems]];
        }
        
        // update indexes -> we need them for UndoButtonHelper
        for (NSNumber* key in targetCellsDict) {
            DropView* view = [targetCellsDict objectForKey:key];
            view.index = [key intValue];
        }
        
        [SHARED_BUTTON_INSTANCE addViewToHistory:dragView andDropView:dropView];
        
        // when dragged view is dropped, remove it as it is replaced by this drop view
        [dragView removeFromSuperview];
        
        // reload in order to show the new drop view - > "cellForItemAtIndexPath"
        [dropCollectionView reloadData];
        
    }];
}

- (void)appendCell:(UIPanGestureRecognizer *)recognizer dragView:(DragView *)dragView {
    dropCell = [Utils getTargetCell:dragView inCollectionView:dropCollectionView recognizer:recognizer];
    
    // if view is not dropped into a valid cell, remove it
    if (!dropCell) {
        [dragView removeFromSuperview];
        [dropCollectionView reloadData];
        [SHARED_STATE_INSTANCE setTransactionActive:false];
        
        if ([SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
            [self handleInitialDragView:dragView];
        }
        
        return;
    }
    NSIndexPath* dropIndexPath = dropCell.indexPath;
    
    
    // in case of consumable items, recover the underlying item
    if (dropCell.isPopulated && [SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
        
        [dropCell highlight:false];
        
        NSArray* consumedItems = [SHARED_STATE_INSTANCE getConsumedItems];
        
        DropView* prevView = [targetCellsDict objectForKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
        int prevIndex = prevView.sourceIndex;
        
        DragView* recoveryView;
        
        for (DragView* view in consumedItems) {
            if (view.index == prevIndex) {
                recoveryView = view;
            }
        }
        
        //if (!recoveryView) return;
        
        [SHARED_STATE_INSTANCE removeConsumedItem:recoveryView];
        [sourceCellsDict setObject:recoveryView forKey:[NSNumber numberWithInt:recoveryView.index]];
        [targetCellsDict removeObjectForKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
        
        // inform source collection view about change - reload needed
        [[NSNotificationCenter defaultCenter] postNotificationName: @"restoreElementNotification" object:nil userInfo:nil];
    }
    
    // drop view into the cell, making a copy of the dragged element and remove the dragged one
    DropView* dropView = [[DropView alloc] initWithView:targetDragView inCollectionViewCell:dropCell];
    dropView.index = (int)dropIndexPath.item;
    dropView.sourceIndex = dragView.index;
    [dropView setMainView:mainView];
    
    [SHARED_BUTTON_INSTANCE addViewToHistory:dragView andDropView:dropView];
    
    // when dragged view is dropped, remove it as it is replaced by this drop view
    [dragView removeFromSuperview];
    // populate dictionary -> we need it for "cellForItemAtIndexPath"
    [targetCellsDict setObject:dropView forKey:[NSNumber numberWithInt:dropView.index]];
    
}

- (void)handleInitialDragView:(DragView *)dragView {
    // Remove temporary DragView (it's only a snapshot) and replace it by a real one
    CGRect frame = newDragView.frame;
    [newDragView removeFromSuperview];
    
    newDragView = [dragView provideNew];
    newDragView.frame = frame;
    [mainView addSubview:newDragView];
    // we need to update the dictionary - otherwise we get empty custom views!
    [sourceCellsDict setObject:newDragView forKey:[NSNumber numberWithInt:dragView.index]];
}


@end
