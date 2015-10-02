//
//  DragCollectionView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragCollectionView : UICollectionView


- (id)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>*) view;

- (CollectionViewCell*) getCell: (NSIndexPath*) indexPath;

- (CGSize) getBestFillingCellSize: (CGSize) containerSize;

@end