//
//  MoveableView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomView.h"

@interface MoveableView : UIView

@property int index; // index of current collectionView

@property (strong, nonatomic) UIColor* borderColor;
@property (nonatomic) float borderWidth;

- (void) move:(UIPanGestureRecognizer *)recognizer inView:(UIView*) view;

- (void) setContentView: (CustomView*) view;

- (CustomView*) getContentView;


- (void) initialize;

@end
