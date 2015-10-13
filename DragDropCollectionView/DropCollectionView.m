//
//  DropCollectionView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DropCollectionView.h"
#import "Utils.h"
#import "ConfigAPI.h"
#import "CurrentState.h"
#import "DropView.h"
#import "UndoButtonHelper.h"
#import "DragDropHelper.h"

#define SHARED_CONFIG_INSTANCE     [ConfigAPI sharedInstance]
#define SHARED_STATE_INSTANCE      [CurrentState sharedInstance]
#define SHARED_BUTTON_INSTANCE     [UndoButtonHelper sharedInstance]
#define SHARED_DRAGDROP_INSTANCE   [DragDropHelper sharedInstance]

#define REUSE_IDENTIFIER @"dropCell"

@interface DropCollectionView() {
    
    NSMutableDictionary* sourceCellsDict;
    NSMutableDictionary* targetCellsDict;
    
    float minInteritemSpacing;
    float minLineSpacing;
}
@end

@implementation DropCollectionView

- (id)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>*) view sourceDictionary:(NSMutableDictionary*) sourceDict targetDictionary:(NSMutableDictionary*) targetDict  {
    
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        self = [[DropCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        self.backgroundColor = [SHARED_CONFIG_INSTANCE getBackgroundColorTargetView];
        
        sourceCellsDict = sourceDict;
        targetCellsDict = targetDict;
        
        minInteritemSpacing = [SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
        minLineSpacing = [SHARED_CONFIG_INSTANCE getMinLineSpacing]; // set member variable AFTER  instantiation - otherwise it will be lost later
        [flowLayout setMinimumInteritemSpacing:minInteritemSpacing];
        [flowLayout setMinimumLineSpacing:minLineSpacing];
        
        self.delegate = view;
        self.dataSource = view;
        self.showsHorizontalScrollIndicator = NO;
        
        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteCellNotification:) name:@"deleteCellNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreElementNotification:) name:@"restoreElementNotification"
                                                   object:nil];
        
    }
    return self;
}


#pragma mark -NSNotificationCenter
- (void) restoreElementNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"restoreElementNotification"]) {
        [self reloadData];
    }
}

- (void) receiveDeleteCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"deleteCellNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSIndexPath* indexPath = [userInfo objectForKey:@"indexPath"];
        
        NSInteger numberOfItems = [self numberOfItemsInSection:0];
        NSIndexPath* lastIndexPath = [NSIndexPath indexPathForItem:numberOfItems-1 inSection:0];
        
        bool cellIsPopulated = [targetCellsDict objectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
        
        // remove the deletable view also from history (undo button)
        DragView *dragView;
        [SHARED_DRAGDROP_INSTANCE updateHistory:indexPath dragView:&dragView];

        // append empty cell in order to maintain a constant number of cells - only when user has configured it
        if ([SHARED_CONFIG_INSTANCE isShouldRemoveAllEmptyCells] || !cellIsPopulated)  {
            [self performBatchUpdates:^{
                
                NSArray *indexPaths = [NSArray arrayWithObject:lastIndexPath];
                [self deleteItemsAtIndexPaths:@[indexPath]];
                [self insertItemsAtIndexPaths:indexPaths];
 
            } completion: ^(BOOL finished) {
                
                // if consumable item, get it back into the source collection view
                if (sourceCellsDict && [SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
                    
                    [self recoverConsumedElement:(int)indexPath.item];
                }
                
                [targetCellsDict removeObjectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
                
                
                [Utils eliminateEmptyKeysInDict:targetCellsDict];
                
                
                [SHARED_STATE_INSTANCE setTransactionActive:true]; // indicate that view is in drag state
    
                // update indexes -> we need them for UndoButtonHelper
                for (NSNumber* key in targetCellsDict) {
                    DropView* view = [targetCellsDict objectForKey:key];
                    view.index = [key intValue];
                }
                
                [self reloadData];
                
            }];
        } else {
            // if consumable item, get it back into the source collection view
            if (sourceCellsDict && [SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
                
                [self recoverConsumedElement:(int)indexPath.item];
            }
            
            [targetCellsDict removeObjectForKey:[NSNumber numberWithInt:(int)indexPath.item]];

            [SHARED_STATE_INSTANCE setTransactionActive:true]; // indicate that view is in drag state
            
            [self reloadData];
        }
    }
}

- (void) recoverConsumedElement: (int) item; {
    
    DropView* dropView = [targetCellsDict objectForKey:[NSNumber numberWithInt:item]];
    
    //Your main thread code goes in here
    NSArray* consumedViews = [SHARED_STATE_INSTANCE getConsumedItems];
    
    UIView* recoveryView;
    
    for (DragView* view in consumedViews) {
        if (view.index == dropView.sourceIndex) {
            [sourceCellsDict setObject:view forKey:[NSNumber numberWithInt:view.index]];
            recoveryView = view;
        }
    }
    
    if (recoveryView) {
        [SHARED_STATE_INSTANCE removeConsumedItem:recoveryView];
    }
    
    // inform source collection view about change - reload needed
    [[NSNotificationCenter defaultCenter] postNotificationName: @"restoreElementNotification" object:nil userInfo:nil];
    
}



- (CollectionViewCell*) getCell: (NSIndexPath*) indexPath {
    CollectionViewCell* cell = [self dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.indexPath = indexPath;
    [cell reset];
    return cell;
}

- (void) resetAllCells {
    
    for (CollectionViewCell *cell in self.visibleCells) {
        [cell shrink];
    }
}

@end
