//
//  DropCollectionView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaTargetCollectionView.h"
#import "ArrasoltaAPI.h"
#import "ArrasoltaCollectionViewFlowLayout.h"
#import "ArrasoltaTargetCollectionView.h"


#define REUSE_IDENTIFIER @"arrasoltaDropCell"


@interface ArrasoltaTargetCollectionView() {
    
    NSMutableDictionary* sourceCellsDict;
    NSMutableDictionary* targetCellsDict;
    
    float minInteritemSpacing;
    float minLineSpacing;
}
@end

@implementation ArrasoltaTargetCollectionView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint point = self.frame.origin;
    
    float topY = point.y;
    
    [[ArrasoltaCurrentState sharedInstance] setTopTargetCollectionView:topY];

}

- (instancetype)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>*) view sourceDictionary:(NSMutableDictionary*) sourceDict targetDictionary:(NSMutableDictionary*) targetDict  {
    
    if (self) {
        
        UICollectionViewFlowLayout* flowLayout;
        
        flowLayout = [[ArrasoltaCollectionViewFlowLayout alloc] init];
        
        self = [[ArrasoltaTargetCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
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
        
        [self registerClass:[ArrasoltaTargetCollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
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
        
        [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        
        ArrasoltaCollectionViewFlowLayout* layout = ( ArrasoltaCollectionViewFlowLayout*)self.collectionViewLayout;
        CGSize itemSize = layout.itemSize;
        if (itemSize.height > 0.8 * self.contentSize.height || itemSize.width > 0.8 * self.contentSize.width) {
            [SHARED_STATE_INSTANCE setStopPanning:true];
        }
        
        if ([SHARED_CONFIG_INSTANCE getShouldPanningBeCoupled]) {
            ArrasoltaCollectionViewFlowLayout* layout = (ArrasoltaCollectionViewFlowLayout*)self.collectionViewLayout;
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
        
        if ([userinfo isKindOfClass:[ArrasoltaDraggableView class]]) {
            return;
        }

        if (![userinfo isKindOfClass:[ArrasoltaDroppableView class]]) {
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



- (ArrasoltaTargetCollectionViewCell*) getCell: (NSIndexPath*) indexPath {
    ArrasoltaTargetCollectionViewCell* cell = [self dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.indexPath = indexPath;
    [cell reset];
    [cell setNumberForDropView];
    return cell;
}

- (void) resetAllCells {
    
    for (ArrasoltaTargetCollectionViewCell *cell in self.visibleCells) {
        [cell shrink];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
