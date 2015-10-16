//
//  ViewConverter.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ViewConverter.h"
#import <objc/runtime.h>

@implementation ViewConverter

+ (ViewConverter*) sharedInstance
{
    
    static ViewConverter *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ViewConverter alloc] init];
    });
    return _sharedInstance;
}

- (DropView*) convertToDropView: (DragView*) view widthIndex: (int)index {
    
    DropView *dropView = [DropView new];
    dropView.index = index;
    dropView.frame = view.frame;
    dropView.previousDragViewIndex = view.index;
    dropView.previousDropViewIndex = -1; // TODO: find a better approach
    dropView.borderColor = view.borderColor;
    dropView.borderWidth = view.borderWidth;
    
    CustomView *newContentView = [self cloneContentView:[view getContentView]];
    
    [dropView setContentView:newContentView];
    
    return dropView;

}

- (DragView*) convertToDragView: (DropView*) view {
    
    DragView *dragView = [DragView new];
    dragView.frame = view.frame;
    dragView.index = view.previousDragViewIndex;
//    dropView.previousDragViewIndex = view.index;
//    dropView.previousDropViewIndex = -1; // TODO: find a better approach
    dragView.borderColor = view.borderColor;
    dragView.borderWidth = view.borderWidth;
    

    CustomView *newContentView = [self cloneContentView:[view getContentView]];
    
    [dragView setContentView:newContentView];
    
    return dragView;
}

// Helper method: clones the custom content view by introspection
- (CustomView *)cloneContentView:(CustomView *)contentView {
    
    id theClass = NSClassFromString(contentView.concreteClassName);
    CustomView* newContentView = [theClass new];

    unsigned int outCount, i;
    objc_property_t *propertiesSource = class_copyPropertyList([contentView class], &outCount);
    
    // get all members by introspection
    for (i = 0; i < outCount; i++) {
        objc_property_t propertySource = propertiesSource[i];
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(propertySource)];
        id propertyValue = [contentView valueForKey:(NSString *)propertyName];
        
        [newContentView setValue:propertyValue forKey:(NSString *)propertyName];
    }
    return newContentView;
}

@end
