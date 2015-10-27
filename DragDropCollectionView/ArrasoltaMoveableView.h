//
//  MoveableView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrasoltaCustomView.h"

@interface ArrasoltaMoveableView : UIView<UIGestureRecognizerDelegate>

@property int index; // index of current collectionView

@property (strong, nonatomic) UIColor* borderColor;
@property (nonatomic) float borderWidth;

- (void) move:(UIPanGestureRecognizer *)recognizer inView:(UIView*) view;

- (void) enablePanGestureRecognizer: (bool) flag;

@property (NS_NONATOMIC_IOSONLY, getter=getContentView, strong) ArrasoltaCustomView *contentView;


- (void) initialize;

@end
