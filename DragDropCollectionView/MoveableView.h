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

- (void) setContentView: (UIView*) view;
- (UIView*) getContentView;

- (void) initialize;

//- (MoveableView*) provideNew;

- (void)setupConstraints: (UIView*) element;

@end
