//
//  DragView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragView.h"
#import "CustomView.h"
#import "DragDropHelper.h"
#import <objc/runtime.h>
//#pragma GCC diagnostic ignored "-Wundeclared-selector"

#define SHARED_STATE_INSTANCE      [CurrentState sharedInstance]

@interface DragView() {
    
    DragDropHelper* dragDropHelper;
    
}
@end



@implementation DragView


- (void)didMoveToSuperview {
    
    if (!self.superview) return;
    
    dragDropHelper = (DragDropHelper*)[SHARED_STATE_INSTANCE getDragDropHelper];
    
    UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    
    [recognizer setMaximumNumberOfTouches:1];
    [recognizer setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:recognizer];
    
    [super initialize];
}


#pragma mark UIPanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    [dragDropHelper handlePan:recognizer];
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
    
    //NSString *className = NSStringFromClass([contentView class]);
    id theClass = NSClassFromString(contentView.concreteClassName);
    
    UIView* newContentView = [theClass new];
    
    
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


- (void) enablePanGestureRecognizer: (bool) flag {
    for (UIGestureRecognizer *recognizer in self.gestureRecognizers) {
        
        if([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            recognizer.enabled = flag;
        }
    }
}


@end
