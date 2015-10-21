//
//  DragDropConfig.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ConfigAPI.h"


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

- (instancetype)init
{
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc] init];
    }
    return self;
}

// Setter
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
- (void) setDropPlaceholderColorUntouched: (UIColor*) color {
    [persistencyManager setDropPlaceholderColorUntouched:color];
}
- (void) setDropPlaceholderColorTouched: (UIColor*) color {
    [persistencyManager setDropPlaceholderColorTouched:color];
}
- (void) setShouldDropPlaceholderContainIndex: (bool) value {
    [persistencyManager setShouldDropPlaceholderContainIndex:value];
}
- (void) setNumberOfDropItems: (int) value {
    [persistencyManager setNumberOfDropItems:value];
}
- (void) setSourceItemConsumable: (bool) value {
    [persistencyManager setIsSourceItemConsumable:value];
}
- (void) shouldRemoveAllEmptyCells: (bool) value {
    [persistencyManager setShouldRemoveAllEmptyCells:value];
}
- (void) setScrollDirection: (NSInteger) value {
    [persistencyManager setScrollDirection:value];
}
- (void) setHasAutomaticCellSize: (bool) value {
    [persistencyManager setHasAutomaticCellSize:value];
}
- (void) setLongPressDurationBeforeDrag: (float) value {
    [persistencyManager setLongPressDurationBeforeDrag:value];
}


// Getter
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
- (UIColor*) getDropPlaceholderColorUntouched {
    return [persistencyManager getDropPlaceholderColorUntouched];
}
- (UIColor*) getDropPlaceholderColorTouched {
    return [persistencyManager getDropPlaceholderColorTouched];
}
- (bool) getShouldDropPlaceholderContainIndex {
    return [persistencyManager getShouldDropPlaceholderContainIndex];
}
- (int) getNumberOfDropItems {
    return [persistencyManager getNumberOfDropItems];
}
- (bool) isSourceItemConsumable {
    return [persistencyManager getIsSourceItemConsumable];
}
- (bool) isShouldRemoveAllEmptyCells {
    return [persistencyManager getShouldRemoveAllEmptyCells];
}
- (NSInteger) getScrollDirection {
    return [persistencyManager getScrollDirection];
}
- (bool) getHasAutomaticCellSize {
    return [persistencyManager getHasAutomaticCellSize];
}
- (float) getLongPressDurationBeforeDrag {
    return [persistencyManager getLongPressDurationBeforeDrag];
}

@end
