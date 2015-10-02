//
//  DropCollectionView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DropCollectionView.h"

#define REUSE_IDENTIFIER @"dropCell"

@interface DropCollectionView() {
    float minInteritemSpacing;
    float minLineSpacing;
}
@end

@implementation DropCollectionView

- (id)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>*) view  {
    
    //self = [super initWithFrame:frame];
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];

        self = [[DropCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        self.backgroundColor = [SHARED_CONFIG_INSTANCE getBackgroundColorTargetView];
        
        minInteritemSpacing = [SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
        minLineSpacing = [SHARED_CONFIG_INSTANCE getMinLineSpacing]; // set member variable AFTER  instantiation - otherwise it will be lost later
        [flowLayout setMinimumInteritemSpacing:minInteritemSpacing];
        [flowLayout setMinimumLineSpacing:minLineSpacing];
        
        self.delegate = view;
        self.dataSource = view;
        self.showsHorizontalScrollIndicator = NO;
        
        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
    }
    return self;
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
