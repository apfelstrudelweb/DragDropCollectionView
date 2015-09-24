//
//  DragDropConfig.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragDropConfig.h"

@implementation DragDropConfig

@synthesize itemSpacing = _itemSpacing;
@synthesize backgroundColorSourceView = _backgroundColorSourceView;
@synthesize backgroundColorTargetView = _backgroundColorTargetView;
@synthesize dataSourceDict = _dataSourceDict;

#pragma mark Singleton Methods

+ (id)sharedConfig {
    static DragDropConfig *sharedConfig = nil;
    @synchronized(self) {
        if (sharedConfig == nil)
            sharedConfig = [[self alloc] init];
    }
    return sharedConfig;
}

- (id)init {
    if (self = [super init]) {

    }
    return self;
}


- (float) itemSpacing {
    return _itemSpacing;
}

- (UIColor*) backgroundColorSourceView {
    return _backgroundColorSourceView;
}

- (UIColor*) backgroundColorTargetView {
    return _backgroundColorTargetView;
}

- (NSMutableDictionary*) dataSourceDict {
    return _dataSourceDict;
}

@end
