//
//  MoveableView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MoveableView.h"
#import "DragDropHelper.h"

//#import <objc/runtime.h>

#define SHARED_STATE_INSTANCE      [CurrentState sharedInstance]

@interface MoveableView() {
    
    CustomView* customView;
    DragDropHelper* dragDropHelper;
}
@end

@implementation MoveableView

- (void)didMoveToSuperview {
    
    //if (!self.superview) return;
    
    dragDropHelper = (DragDropHelper*)[SHARED_STATE_INSTANCE getDragDropHelper];
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    [recognizer setMaximumNumberOfTouches:1];
    [recognizer setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:recognizer];
    
    [self initialize];
}


#pragma mark UIPanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    [dragDropHelper handlePan:recognizer];
}

- (void) setContentView: (CustomView*) view {
    customView = view;
}

- (CustomView*) getContentView {
    return customView;
}


- (void) initialize {
    
    self.backgroundColor = self.borderColor;
    
    if (customView) {
        //[customView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:customView];

        customView.frame = CGRectInset(self.bounds, 0.5*self.borderWidth, 0.5*self.borderWidth);
        // resize subviews
        customView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        customView.translatesAutoresizingMaskIntoConstraints = YES;
    }
}

#pragma mark -UIPanGestureRecognizer
- (void) move:(UIPanGestureRecognizer *)recognizer inView:(UIView*) view {
    // perform translation of the drag view
    recognizer.view.center = [recognizer locationInView:view];
    [recognizer setTranslation:CGPointMake(0, 0) inView:view];
    //NSLog(@"translation x-y: %f - %f", translation.x, translation.y);
}


@end
