//
//  DragView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragView.h"
#import "CustomView.h"
#import <objc/runtime.h>
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
    
    [super initialize];
    
}

- (void) setBorderColor: (UIColor*) color {
    //[super setBackgroundColor:color];
    [super setBorderColor:color];
}

- (void) setBorderWidth: (float) value {
    [super setBorderWidth:value];
}

- (DragView*) provideNew {
    
    DragView *newView = [DragView new];
    newView.frame = self.frame;
    newView.index = self.index;
    newView.borderColor = self.borderColor;
    newView.borderWidth = self.borderWidth;
    
    CustomView* contentView = (CustomView*)[self getContentView];
    
    Class subclass = [contentView class];
    CustomView* newContentView = [subclass new];
    
    unsigned int outCount, i;
    objc_property_t *propertiesSource = class_copyPropertyList([contentView class], &outCount);
    
    // get all members by introspection
    for (i = 0; i < outCount; i++) {
        objc_property_t propertySource = propertiesSource[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(propertySource)];
        id propertyValue = [contentView valueForKey:(NSString *)propertyName];
        [newContentView setValue:propertyValue forKey:(NSString *)propertyName];
        
    }
    
    [newView setContentView:newContentView];
    
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
