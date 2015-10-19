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
    
    CGRect oldBounds;
    CGRect newBounds;
    
    UIPanGestureRecognizer* panRecognizer;
    UILongPressGestureRecognizer *longPressRecognizer;
    
    bool isInitialized;
}
@end

@implementation MoveableView

//- (void)willMoveToWindow {
//    NSLog(@"willMoveToWindow");
//}


- (void)didMoveToSuperview {
    
    if (!self.superview) return;
    
    if (!dragDropHelper) {
         dragDropHelper = (DragDropHelper*)[SHARED_STATE_INSTANCE getDragDropHelper];
    }

    if (!panRecognizer) {
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
        panRecognizer.maximumNumberOfTouches = 1;
        panRecognizer.minimumNumberOfTouches = 1;
        panRecognizer.delegate = self;
        [self addGestureRecognizer:panRecognizer];
    }

    if (!longPressRecognizer) {
        longPressRecognizer = [[UILongPressGestureRecognizer alloc]
           initWithTarget:self action:@selector(handleLongPress:)];
        longPressRecognizer.minimumPressDuration = 0.5;
        longPressRecognizer.delegate = self;
        [self addGestureRecognizer:longPressRecognizer];
    }

    
    [self initialize];
}


#pragma mark UIPanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

    if (![SHARED_STATE_INSTANCE isDragAllowed]) return; // allowed only after longpress

    self.bounds = newBounds;
    customView.frame = CGRectInset(self.bounds, 0.5*self.borderWidth, 0.5*self.borderWidth);

    [dragDropHelper handlePan:recognizer];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {

        [[CurrentState sharedInstance] setDragAllowed:true];
        
        CGRect bounds = self.bounds;
        oldBounds = self.bounds;
        newBounds = CGRectMake(bounds.origin.x, bounds.origin.y, floorf(1.05*bounds.size.width), floorf(1.05*bounds.size.height));
        
        self.bounds = newBounds;
        
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // TODO: block panning
        //[[CurrentState sharedInstance] setDragAllowed:false];
        self.bounds = oldBounds;
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (void) setContentView: (CustomView*) view {
    customView = view;
}

- (CustomView*) getContentView {
    return customView;
}


- (void) initialize {
    
    if (!isInitialized) {
        self.backgroundColor = self.borderColor;
        
        if (customView) {
            //[customView setTranslatesAutoresizingMaskIntoConstraints:NO];
            [self addSubview:customView];
            
            customView.frame = CGRectInset(self.bounds, 0.5*self.borderWidth, 0.5*self.borderWidth);
            // resize subviews
            customView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
            customView.translatesAutoresizingMaskIntoConstraints = YES;
        }
        
        isInitialized = true;
    }
    

}

#pragma mark -UIPanGestureRecognizer
- (void) move:(UIPanGestureRecognizer *)recognizer inView:(UIView*) view {
    // perform translation of the drag view
    recognizer.view.center = [recognizer locationInView:view];
    [recognizer setTranslation:CGPointMake(0, 0) inView:view];
    //NSLog(@"translation x-y: %f - %f", recognizer.view.center.x, recognizer.view.center.y);
}


@end
