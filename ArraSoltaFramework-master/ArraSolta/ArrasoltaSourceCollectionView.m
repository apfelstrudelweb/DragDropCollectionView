//
//  DragCollectionView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaSourceCollectionView.h"
#import "ArrasoltaAPI.h"
#import "ArrasoltaCollectionViewFlowLayout.h"

#import "ArrasoltaSourceCollectionViewCell.h"

#define REUSE_IDENTIFIER @"arrasoltaDragCell"



@interface ArrasoltaSourceCollectionView() {

    //UICollectionViewScrollDirection scrollDirection;
    
    float minInteritemSpacing;
    float minLineSpacing;

}
@end

@implementation ArrasoltaSourceCollectionView


- (instancetype)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>*) view  {
    

    if (self) {
        
        
        UICollectionViewFlowLayout* flowLayout = [[ArrasoltaCollectionViewFlowLayout alloc] init];
        //UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        self = [[ArrasoltaSourceCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        
        minInteritemSpacing = [SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
        minLineSpacing = [SHARED_CONFIG_INSTANCE getMinLineSpacing];// set member variable AFTER  instantiation - otherwise it will be lost later
        flowLayout.minimumInteritemSpacing = minInteritemSpacing;
        flowLayout.minimumLineSpacing = minLineSpacing;

        if ([SHARED_CONFIG_INSTANCE getScrollDirection] == horizontal) {
            super.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        } else {
            super.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        
        flowLayout.scrollDirection = super.scrollDirection;

        
        self.backgroundColor = [SHARED_CONFIG_INSTANCE getBackgroundColorSourceView];

        self.delegate = view;
        self.dataSource = view;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;

        [self registerClass:[ArrasoltaSourceCollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreElementNotification:) name:@"arrasoltaRestoreElementNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataNotification:) name:@"arrasoltaReloadDataNotification"
                                                   object:nil];
        
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];

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


- (ArrasoltaSourceCollectionViewCell*) getCell: (NSIndexPath*) indexPath {
    ArrasoltaSourceCollectionViewCell* cell = [self dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
    cell.indexPath = indexPath;
    //cell.isTargetCell = true;
    [cell reset];
    [cell setNumberForDragView];
    return cell;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
