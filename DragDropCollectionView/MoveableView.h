//
//  MoveableView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoveableView : UIView

@property int index;
@property (strong, nonatomic) UIColor* borderColor;
@property (nonatomic) float borderWidth;

- (void) move:(UIPanGestureRecognizer *)recognizer inView:(UIView*) view;

- (void) setContentView: (UIView*) view;
- (UIView*) getContentView;

- (void) initialize;

- (void) setupConstraints: (UIView*) element;

@end
