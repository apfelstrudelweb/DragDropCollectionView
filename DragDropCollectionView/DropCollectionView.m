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

#define SHARED_CONFIG_INSTANCE   [ConfigAPI sharedInstance]
#define REUSE_IDENTIFIER @"dropCell"

@interface DropCollectionView() {
    
    NSMutableDictionary* targetCellsDict;
    
    float minInteritemSpacing;
    float minLineSpacing;
}
@end

@implementation DropCollectionView

- (id)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>*) view boundToElementsDictionary:(NSMutableDictionary*) dict  {
    
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        self = [[DropCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        self.backgroundColor = [SHARED_CONFIG_INSTANCE getBackgroundColorTargetView];
        
        targetCellsDict = dict;
        
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
        
    }
    return self;
}


#pragma mark -NSNotificationCenter
- (void) receiveDeleteCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"deleteCellNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSIndexPath* indexPath = [userInfo objectForKey:@"indexPath"];
        
        NSInteger numberOfItems = [self numberOfItemsInSection:0];
        NSIndexPath* lastIndexPath = [NSIndexPath indexPathForItem:numberOfItems-1 inSection:0];
        
        // append empty cell in order to maintain a constant number of cells
        [self performBatchUpdates:^{
            
            NSArray *indexPaths = [NSArray arrayWithObject:lastIndexPath];
            [self deleteItemsAtIndexPaths:@[indexPath]];
            [self insertItemsAtIndexPaths:indexPaths];
            
        } completion: ^(BOOL finished) {
            [targetCellsDict  removeObjectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
            [Utils eliminateEmptyKeysInDict:targetCellsDict];
            
            [self reloadData];
            
        }];
    }
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
