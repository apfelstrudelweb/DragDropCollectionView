//
//  DragCollectionView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragCollectionView.h"
#import "Utils.h"
#import "ConfigAPI.h"
#import "CollectionViewFlowLayout.h"
#import "CurrentState.h"


#define REUSE_IDENTIFIER @"dragCell"
#define SHARED_CONFIG_INSTANCE   [ConfigAPI sharedInstance]
#define SHARED_STATE_INSTANCE    [CurrentState sharedInstance]


@interface DragCollectionView() {

    //UICollectionViewScrollDirection scrollDirection;
    
    float minInteritemSpacing;
    float minLineSpacing;

}
@end

@implementation DragCollectionView


- (instancetype)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>*) view  {
    

    if (self) {
        
        
        UICollectionViewFlowLayout* flowLayout = [[CollectionViewFlowLayout alloc] init];
        
        self = [[DragCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        
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

        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
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


- (CollectionViewCell*) getCell: (NSIndexPath*) indexPath {
    return [self dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
