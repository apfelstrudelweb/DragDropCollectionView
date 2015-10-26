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
        
        flowLayout = [[CollectionViewFlowLayout alloc] init];
        
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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataNotification:) name:@"arrasoltaReloadDataNotification"
                                                   object:nil];
        
    }
    return self;
}


#pragma mark -NSNotificationCenter
- (void) reloadDataNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"arrasoltaReloadDataNotification"]) {
        
        if ([SHARED_CONFIG_INSTANCE getShouldPanningBeCoupled]) {
            CollectionViewFlowLayout* layout = (CollectionViewFlowLayout*)self.collectionViewLayout;
            layout.itemSize = [SHARED_STATE_INSTANCE getCellSize];
        }

    }
}

- (void) restoreElementNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"arrasoltaRestoreElementNotification"]) {
        [self reloadData];
    }
}

- (void) receiveDeleteCellNotification:(NSNotification *) notification {
    
    if ([notification.name isEqualToString:@"arrasoltaDeleteCellNotification"]) {
        
        id userinfo = notification.userInfo[@"dropView"];

        if (![userinfo isKindOfClass:[DropView class]]) {
            // empty cell
            if (targetCellsDict.count > 0) {
                [SHARED_BUTTON_INSTANCE updateHistoryBeforeAction];
            }
            
            NSIndexPath* indexPath = notification.userInfo[@"indexPath"];
            [targetCellsDict shiftAllElementsToLeftFromIndex:(int)indexPath.item];
            [self reloadData];
        }
    }
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
