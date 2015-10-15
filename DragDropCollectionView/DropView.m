//
//  DropView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DropView.h"
#import "CustomView.h"
#import "DragDropHelper.h"
#import <objc/runtime.h>

#pragma GCC diagnostic ignored "-Wundeclared-selector"

#define SHARED_STATE_INSTANCE      [CurrentState sharedInstance]

@interface DropView() {
    UIView* mainView;
    DragDropHelper* dragDropHelper;
}
@end

@implementation DropView


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

- (void) setMainView: (UIView*) view {
    mainView = view;
}



- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithView:(DropView*)view inCollectionViewCell:(CollectionViewCell*) cell {
    
    self = [super initWithFrame:cell.frame];
    if (self) {
        
        // if there is already an underlying DropView, remove it
        for (UIView* view in cell.subviews) {
            if ([view isKindOfClass:[DropView class]]) {
                [view removeFromSuperview];
            }
        }
        
        self.borderColor = view.borderColor;
        self.borderWidth = view.borderWidth;
        
        
        UIView* contentView = [view getContentView];
        
        contentView.center = cell.contentView.center;

        [self setContentView:contentView];
        [super initialize];
        
//        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        self.translatesAutoresizingMaskIntoConstraints = YES;

    }
    return self;
}

- (DropView*) provideNew {
    DropView *newView = [DropView new];
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


@end
