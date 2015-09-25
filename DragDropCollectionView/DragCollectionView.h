//
//  DragCollectionView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragCollectionView : UICollectionView

@property (nonatomic) float itemSpacing;

- (id)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>*) view;

- (CollectionViewCell*) getCell: (NSIndexPath*) indexPath;

- (float) getBestFillingCellSize: (CGSize) containerSize;

@end
