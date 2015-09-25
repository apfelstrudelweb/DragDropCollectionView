//
//  DragDropConfig.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragDropConfig.h"

@implementation DragDropConfig

@synthesize cItemSpacing = _cItemSpacing;
@synthesize cBackgroundColorSourceView = _cBackgroundColorSourceView;
@synthesize cBackgroundColorTargetView = _cBackgroundColorTargetView;
@synthesize cDataSourceDict = _cDataSourceDict;

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
    return _cItemSpacing;
}

- (UIColor*) backgroundColorSourceView {
    return _cBackgroundColorSourceView;
}

- (UIColor*) backgroundColorTargetView {
    return _cBackgroundColorTargetView;
}

- (NSMutableDictionary*) dataSourceDict {
    return _cDataSourceDict;
}

@end
