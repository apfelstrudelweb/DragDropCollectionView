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
    
    CGRect newBounds;
}
@end

@implementation MoveableView

- (void)didMoveToSuperview {
    
    //if (!self.superview) return;
    
    dragDropHelper = (DragDropHelper*)[SHARED_STATE_INSTANCE getDragDropHelper];
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    recognizer.maximumNumberOfTouches = 1;
    recognizer.minimumNumberOfTouches = 1;
    recognizer.delegate = self;
    [self addGestureRecognizer:recognizer];
    
    
    // attach long press gesture to each cell
    UILongPressGestureRecognizer *lpgr
    = [[UILongPressGestureRecognizer alloc]
       initWithTarget:self action:@selector(handleLongPress:)];
    lpgr.minimumPressDuration = 0.5;
    lpgr.delegate = self;
    [self addGestureRecognizer:lpgr];
    
    [self initialize];
}


#pragma mark UIPanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

    if (![SHARED_STATE_INSTANCE isDragAllowed]) return;

    self.bounds = newBounds;
    customView.frame = CGRectInset(self.bounds, 0.5*self.borderWidth, 0.5*self.borderWidth);

    [dragDropHelper handlePan:recognizer];
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        NSLog(@"handleLongPress start");
        
        [[CurrentState sharedInstance] setDragAllowed:true];
        
        CGRect bounds = self.bounds;
        newBounds = CGRectMake(bounds.origin.x, bounds.origin.y, floorf(1.05*bounds.size.width), floorf(1.05*bounds.size.height));
        
        self.bounds = newBounds;
        
    } else {
        NSLog(@"handleLongPress end");
        
    }
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
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
