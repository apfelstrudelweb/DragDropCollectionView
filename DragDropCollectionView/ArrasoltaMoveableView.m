//
//  MoveableView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaMoveableView.h"
#import "ArrasoltaDragDropHelper.h"
#import "ArrasoltaAPI.h"



@interface ArrasoltaMoveableView() {
    
    ArrasoltaCustomView* customView;
    ArrasoltaDragDropHelper* dragDropHelper;
    
    UILongPressGestureRecognizer *longPressRecognizer;
    UIPanGestureRecognizer* panRecognizer;
    CGRect newBounds;
    
    bool isInitialized;
}
@end

@implementation ArrasoltaMoveableView


- (void)didMoveToSuperview {
    
    if (!self.superview) return;
    
    if (!dragDropHelper) {
        dragDropHelper = (ArrasoltaDragDropHelper*)[SHARED_STATE_INSTANCE getDragDropHelper];
    }
    
    if (!longPressRecognizer && [SHARED_CONFIG_INSTANCE getLongPressDurationBeforeDragging] > 0.0) {
        longPressRecognizer = [[UILongPressGestureRecognizer alloc]
                               initWithTarget:self action:@selector(handleLongPress:)];
        longPressRecognizer.minimumPressDuration = [SHARED_CONFIG_INSTANCE getLongPressDurationBeforeDragging];
        longPressRecognizer.delegate = self;
        [self addGestureRecognizer:longPressRecognizer];
    }
    
    if ([SHARED_CONFIG_INSTANCE getLongPressDurationBeforeDragging] == 0.0) {
        [[ArrasoltaCurrentState sharedInstance] setDragAllowed:true];
    }
    
    
    if (!panRecognizer) {
        panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        
        panRecognizer.maximumNumberOfTouches = 1;
        panRecognizer.minimumNumberOfTouches = 1;
        panRecognizer.delegate = self;
        [self addGestureRecognizer:panRecognizer];
    }
    
    [self initialize];
}


#pragma mark UIPanGestureRecognizer
-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    
    // make decreasing possible only once !
    if ([[ArrasoltaCurrentState sharedInstance] isDragAllowed]) return;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        
        newBounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y, floorf(0.9*self.bounds.size.width), floorf(0.9*self.bounds.size.height));
        
        self.bounds = newBounds;
        
        [[ArrasoltaCurrentState sharedInstance] setDragAllowed:true];
    }
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    if (![[ArrasoltaCurrentState sharedInstance] isDragAllowed]) return;
    
    [dragDropHelper handlePan:recognizer];
}

- (void) enablePanGestureRecognizer: (bool) flag {
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        
        if([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            recognizer.enabled = flag;
        }
        
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}


- (void) setContentView: (ArrasoltaCustomView*) view {
    customView = view;
}

- (ArrasoltaCustomView*) getContentView {
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
