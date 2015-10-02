//
//  DragDropConfig.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ConfigAPI.h"
#import "PersistencyManager.h"

@interface ConfigAPI () {
    PersistencyManager *persistencyManager;
}

@end

@implementation ConfigAPI

+ (ConfigAPI*)sharedInstance
{

    static ConfigAPI *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ConfigAPI alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc] init];
    }
    return self;
}

- (void) setCellWidthHeightRatio: (float) value {
    [persistencyManager setCellWidthHeightRatio:value];
}
- (void) setMinInteritemSpacing: (float) value {
    [persistencyManager setMinInteritemSpacing:value];
}
- (void) setMinLineSpacing: (float) value {
    [persistencyManager setMinLineSpacing:value];
}
- (void) setBackgroundColorSourceView: (UIColor*) color {
    [persistencyManager setBackgroundColorSourceView:color];
}
- (void) setBackgroundColorTargetView: (UIColor*) color {
    [persistencyManager setBackgroundColorTargetView:color];
}
- (void) setDataSourceDict: (NSMutableDictionary*) dict {
    [persistencyManager setDataSourceDict:dict];
}

- (float) getCellWidthHeightRatio {
    return [persistencyManager getCellWidthHeightRatio];
}
- (float) getMinInteritemSpacing {
    return [persistencyManager getMinInteritemSpacing];
}
- (float) getMinLineSpacing {
    return [persistencyManager getMinLineSpacing];
}
- (UIColor*) getBackgroundColorSourceView {
    return [persistencyManager getBackgroundColorSourceView];
}
- (UIColor*) getBackgroundColorTargetView {
    return [persistencyManager getBackgroundColorTargetView];
}
- (NSMutableDictionary*) getDataSourceDict {
    return [persistencyManager getDataSourceDict];
}
@end
