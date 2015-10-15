//
//  MoveableView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MoveableView.h"
#import "CustomView.h"
#import <objc/runtime.h>

@interface MoveableView() {
    
    UIView* customView;
}
@end

@implementation MoveableView

- (void) setContentView: (UIView*) view {
    customView = view;
}

- (UIView*) getContentView {
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
    CGPoint translation = [recognizer translationInView:view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    
    [recognizer setTranslation:CGPointMake(0, 0) inView:view];
}

//- (DragView*) provideNew {
//    DragView *newView = [DragView new];
//    newView.frame = self.frame;
//    newView.index = self.index;
//    newView.borderColor = self.borderColor;
//    newView.borderWidth = self.borderWidth;
//    
//    CustomView* contentView = (CustomView*)[self getContentView];
//    
//    //NSString *className = NSStringFromClass([contentView class]);
//    id theClass = NSClassFromString(contentView.concreteClassName);
//    
//    UIView* newContentView = [theClass new];
//    
//    
//    unsigned int outCount, i;
//    objc_property_t *propertiesSource = class_copyPropertyList([contentView class], &outCount);
//    
//    // get all members by introspection
//    for (i = 0; i < outCount; i++) {
//        objc_property_t propertySource = propertiesSource[i];
//        NSString *propertyName = [NSString stringWithUTF8String:property_getName(propertySource)];
//        id propertyValue = [contentView valueForKey:(NSString *)propertyName];
//        
//        [newContentView setValue:propertyValue forKey:(NSString *)propertyName];
//    }
//    
//    [newView setContentView:newContentView];
//    
//    return newView;
//}


@end
