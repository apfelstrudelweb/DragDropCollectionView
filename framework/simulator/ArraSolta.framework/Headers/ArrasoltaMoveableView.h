//
//  MoveableView.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaCustomView.h"

@interface ArrasoltaMoveableView : UIView<UIGestureRecognizerDelegate>

@property (NS_NONATOMIC_IOSONLY, getter=getContentView, strong) ArrasoltaCustomView *contentView;

@property int index; // index of current collectionView

@property (strong, nonatomic) UIColor* borderColor;
@property (nonatomic) float borderWidth;

- (void) move:(UIPanGestureRecognizer *)recognizer inView:(UIView*) view;

- (void) enablePanGestureRecognizer: (bool) flag;


- (void) initialize;

@end
