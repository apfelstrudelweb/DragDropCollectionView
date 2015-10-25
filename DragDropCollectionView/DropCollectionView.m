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
#import "CollectionViewFlowLayout.h"


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

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint point = self.frame.origin;
    
    float topY = point.y;
    
    [[CurrentState sharedInstance] setTopTargetCollectionView:topY];

}

- (instancetype)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>*) view sourceDictionary:(NSMutableDictionary*) sourceDict targetDictionary:(NSMutableDictionary*) targetDict  {
    
    if (self) {
        
        UICollectionViewFlowLayout* flowLayout;
        
        if ([SHARED_CONFIG_INSTANCE getShouldItemsBePlacedFromLeftToRight]) {
            flowLayout = [[CollectionViewFlowLayout alloc] init];
        } else {
            flowLayout = [[UICollectionViewFlowLayout alloc] init];
        }
        
        self = [[DropCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        self.backgroundColor = [SHARED_CONFIG_INSTANCE getBackgroundColorTargetView];
        
        sourceCellsDict = sourceDict;
        targetCellsDict = targetDict;
        
        minInteritemSpacing = [SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
        minLineSpacing = [SHARED_CONFIG_INSTANCE getMinLineSpacing]; // set member variable AFTER  instantiation - otherwise it will be lost later
        flowLayout.minimumInteritemSpacing = minInteritemSpacing;
        flowLayout.minimumLineSpacing = minLineSpacing;
        
        if ([SHARED_CONFIG_INSTANCE getScrollDirection] == horizontal) {
            super.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        } else {
            super.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        
        flowLayout.scrollDirection = super.scrollDirection;
        
        self.delegate = view;
        self.dataSource = view;
        self.showsHorizontalScrollIndicator = NO;
        
        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteCellNotification:) name:@"arrasoltaDeleteCellNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreElementNotification:) name:@"arrasoltaRestoreElementNotification"
                                                   object:nil];
        
    }
    return self;
}


#pragma mark -NSNotificationCenter

- (void) restoreElementNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"arrasoltaRestoreElementNotification"]) {
        [self reloadData];
    }
}

- (void) receiveDeleteCellNotification:(NSNotification *) notification {
    
    if ([notification.name isEqualToString:@"arrasoltaDeleteCellNotification"]) {
        
        id userinfo = notification.userInfo[@"dropView"];
        
        if ([userinfo isKindOfClass:[DropView class]]) {
            // populated cell
            DropView* dropView = notification.userInfo[@"dropView"];
            
            // update history
            History* hist = [History new];
            hist.elementHasBeenDeleted = YES;
            hist.deletionIndex = dropView.index;
            hist.previousIndex = dropView.previousDragViewIndex;
            [SHARED_BUTTON_INSTANCE updateHistory:hist incrementCounter:true];
        } else {
            // empty cell
            NSIndexPath* indexPath = notification.userInfo[@"indexPath"];
            [targetCellsDict shiftAllElementsToLeftFromIndex:(int)indexPath.item];
            [self reloadData];
            
            // update history
            History* hist = [History new];
            hist.emptyCellHasBeenDeleted = YES;
            hist.index = (int)indexPath.item;
            [SHARED_BUTTON_INSTANCE updateHistory:hist incrementCounter:true];
        }
    }
}

- (void) recoverConsumedElement: (int) item; {
    
//    DropView* dropView = [targetCellsDict objectForKey:[NSNumber numberWithInt:item]];
//    
//    //Your main thread code goes in here
//    NSArray* consumedViews = [SHARED_STATE_INSTANCE getConsumedItems];
//    
//    UIView* recoveryView;
//    
//    for (DragView* view in consumedViews) {
//        if (view.index == dropView.sourceIndex) {
//            [sourceCellsDict setObject:view forKey:[NSNumber numberWithInt:view.index]];
//            recoveryView = view;
//        }
//    }
//    
//    if (recoveryView) {
//        [SHARED_STATE_INSTANCE removeConsumedItem:recoveryView];
//    }
//    
//    // inform source collection view about change - reload needed
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaRestoreElementNotification" object:nil userInfo:nil];
    
}



- (CollectionViewCell*) getCell: (NSIndexPath*) indexPath {
    CollectionViewCell* cell = [self dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.isTargetCell = true;
    [cell reset];
    return cell;
}

- (void) resetAllCells {
    
    for (CollectionViewCell *cell in self.visibleCells) {
        [cell shrink];
    }
}

@end
