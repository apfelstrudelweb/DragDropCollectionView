//
//  DragView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveableView.h"

@interface DragView : MoveableView

- (DragView*) provideNew;
- (void) move:(UIPanGestureRecognizer *)recognizer inView:(UIView*) view;

- (void) setBorderColor: (UIColor*) color;

@end
