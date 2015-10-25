//
//  CollectionView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.10.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionView : UICollectionView<UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIPinchGestureRecognizer* pinchRecognizer;
@property (nonatomic) UICollectionViewScrollDirection scrollDirection;

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout;

@end
