//
//  ViewConverter.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 16.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaViewConverter.h"
#import <objc/runtime.h>

@implementation ArrasoltaViewConverter

+ (ArrasoltaViewConverter*) sharedInstance
{
    
    static ArrasoltaViewConverter *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ArrasoltaViewConverter alloc] init];
    });
    
    return _sharedInstance;
}

- (ArrasoltaDroppableView*) convertToDropView: (ArrasoltaDraggableView*) view widthIndex: (int)index {
    
    ArrasoltaDroppableView *dropView = [ArrasoltaDroppableView new];
    dropView.index = index;
    dropView.frame = view.frame;
    dropView.previousDragViewIndex = view.index;
    dropView.previousDropViewIndex = -1; // TODO: find a better approach
    dropView.borderColor = view.borderColor;
    dropView.borderWidth = view.borderWidth;
    
    ArrasoltaCustomView *newContentView = [self cloneContentView:[view getContentView]];
    
    [dropView setContentView:newContentView];
    
    return dropView;

}

- (ArrasoltaDraggableView*) convertToDragView: (ArrasoltaDroppableView*) view {
    
    ArrasoltaDraggableView *dragView = [ArrasoltaDraggableView new];
    dragView.frame = view.frame;
    dragView.index = view.previousDragViewIndex;
//    dropView.previousDragViewIndex = view.index;
//    dropView.previousDropViewIndex = -1; // TODO: find a better approach
    dragView.borderColor = view.borderColor;
    dragView.borderWidth = view.borderWidth;
    

    ArrasoltaCustomView *newContentView = [self cloneContentView:[view getContentView]];
    
    [dragView setContentView:newContentView];
    
    return dragView;
}

// Helper method: clones the custom content view by introspection
- (ArrasoltaCustomView *)cloneContentView:(ArrasoltaCustomView *)contentView {
    
    id theClass = NSClassFromString(contentView.concreteClassName);
    ArrasoltaCustomView* newContentView = [theClass new];

    unsigned int outCount, i;
    objc_property_t *propertiesSource = class_copyPropertyList([contentView class], &outCount);
    
    // get all members by introspection
    for (i = 0; i < outCount; i++) {
        objc_property_t propertySource = propertiesSource[i];
        NSString *propertyName = @(property_getName(propertySource));
        id propertyValue = [contentView valueForKey:(NSString *)propertyName];
        
        [newContentView setValue:propertyValue forKey:(NSString *)propertyName];
        
        //propertySource = nil;
    }
    
    free(propertiesSource);
    
    return newContentView;
}

@end
