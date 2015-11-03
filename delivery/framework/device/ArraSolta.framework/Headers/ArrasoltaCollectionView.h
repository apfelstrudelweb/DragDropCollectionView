//
//  ArrasoltaCollectionView.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 25.10.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArrasoltaCollectionView : UICollectionView<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPinchGestureRecognizer* pinchRecognizer;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;


- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout;

- (CGSize) getBestFillingCellSize: (CGSize) containerSize;

@end
