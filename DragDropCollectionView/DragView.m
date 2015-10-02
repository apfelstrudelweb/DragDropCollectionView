//
//  DragView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragView.h"
#import "CustomView.h"
#pragma GCC diagnostic ignored "-Wundeclared-selector"

@interface DragView() {

    
}
@end



@implementation DragView


- (void)didMoveToSuperview {
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.superview action:@selector(handlePan:)];
    
    [recognizer setMaximumNumberOfTouches:1];
    [recognizer setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:recognizer];

}

- (void) setBorderColor: (UIColor*) color {
    //[super setBackgroundColor:color];
    [super setBorderColor:color];
}

- (DragView*) provideNew {
    
    DragView *newView = [DragView new];
    newView.frame = self.frame;
    newView.index = self.index;
    newView.borderColor = self.borderColor;
    
    CustomView* contentView = (CustomView*)[self getContentView];

    CustomView* newContentView = [[CustomView alloc] initWithFrame:contentView.frame]; //(CustomView*)[contentView snapshotViewAfterScreenUpdates:NO];
    //[newContentView setBackgroundColor:[UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0]];

    [newContentView setLabelText:[contentView getLabelText]];
    [newContentView setImageName:[contentView getImageName]];
    [newContentView setLabelColor:[contentView getLabelColor]];
    [newContentView setBackgroundColorOfView:[contentView getBackgroundColorOfView]];
    

    [newView setContentView:newContentView];
    
    
    
    
    [newView initialize];
    
    
    return newView;
}



#pragma mark -UIPanGestureRecognizer
- (void) move:(UIPanGestureRecognizer *)recognizer inView:(UIView*) view {
    // perform translation of the drag view
    CGPoint translation = [recognizer translationInView:view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:view];
}




@end
