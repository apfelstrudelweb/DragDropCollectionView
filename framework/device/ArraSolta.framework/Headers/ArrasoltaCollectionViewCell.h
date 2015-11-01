//
//  ArrasoltaCollectionViewCell.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 01.11.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaMoveableView.h"


@interface ArrasoltaCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSIndexPath* indexPath;
@property (nonatomic) BOOL isExpanded;

@property (nonatomic, strong) UIView* placeholderView; 
@property (nonatomic, strong) UILabel* numberLabel;
@property (nonatomic, strong) ArrasoltaMoveableView* moveableView;

- (void) populateWithContentsOfView: (ArrasoltaMoveableView*) view withinCollectionView:(UICollectionView*) collectionView;

- (void) setupViewConstraints: (UIView*) view isExpanded: (bool) expand;
- (void) setupLabelConstraints;

@end
