//
//  DragCollectionView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragCollectionView.h"

#define REUSE_IDENTIFIER @"cell1"

@implementation DragCollectionView



- (id)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>*) view  {
    
    //self = [super initWithFrame:frame];
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        [flowLayout setMinimumInteritemSpacing:[SHARED_CONFIG itemSpacing]];
        [flowLayout setMinimumLineSpacing:[SHARED_CONFIG itemSpacing]];
        
        
        self = [[DragCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        self.backgroundColor = [SHARED_CONFIG backgroundColorSourceView];
        
        self.delegate = view;
        self.dataSource = view;
        self.showsHorizontalScrollIndicator = NO;
        
        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
    }
    return self;
}

- (CollectionViewCell*) getCell: (NSIndexPath*) indexPath {
    return [self dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
}


@end
