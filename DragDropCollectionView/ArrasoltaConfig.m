//
//  DragDropConfig.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaConfig.h"


@interface ArrasoltaConfig () {
    ArrasoltaPersistencyManager *persistencyManager;
}

@end

@implementation ArrasoltaConfig

+ (ArrasoltaConfig*)sharedInstance
{
    
    static ArrasoltaConfig *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ArrasoltaConfig alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        persistencyManager = [[ArrasoltaPersistencyManager alloc] init];
    }
    return self;
}

// Setter
- (void) setFixedCellSize:(CGSize)size {
    [persistencyManager setFixedCellSize:size];
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
- (void) setShouldCollectionViewBeCenteredVertically: (bool) value {
    [persistencyManager setShouldCollectionViewBeCenteredVertically:value];
}
- (void) setShouldCollectionViewFillEntireHeight: (bool) value {
    [persistencyManager setShouldCollectionViewFillEntireHeight:value];
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
- (void) setPreferredFontName: (NSString*) value {
    [persistencyManager  setPreferredFontName:value];
}
- (void) setPlaceholderFontSize: (float) value {
    [persistencyManager setPlaceholderFontSize:value];
}
- (void) setPlaceholderTextColor: (UIColor*) color {
    [persistencyManager setPlaceholderTextColor:color];
}
- (void) setShouldPlaceholderIndexStartFromZero: (bool) value {
    [persistencyManager setShouldPlaceholderIndexStartFromZero:value];
}
- (void) setShouldDragPlaceholderContainIndex: (bool) value {
    [persistencyManager setShouldDragPlaceholderContainIndex:value];
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
//- (void) shouldRemoveAllEmptyCells: (bool) value {
//    [persistencyManager setShouldRemoveAllEmptyCells:value];
//}
- (void) setScrollDirection: (NSInteger) value {
    [persistencyManager setScrollDirection:value];
}
- (void) setHasAutomaticCellSize: (bool) value {
    [persistencyManager setHasAutomaticCellSize:value];
}
- (void) setLongPressDurationBeforeDrag: (float) value {
    [persistencyManager setLongPressDurationBeforeDrag:value];
}
- (void) setShouldItemsBePlacedFromLeftToRight: (bool) value {
    [persistencyManager setShouldItemsBePlacedFromLeftToRight:value];
}
-(void) setShouldPanningBeEnabled: (bool) value {
    [persistencyManager setShouldPanningBeEnabled:value];
}
- (void) setShouldPanningBeCoupled: (bool) value {
    [persistencyManager setShouldPanningBeCoupled:value];
}


// Getter
- (CGSize) getFixedCellSize {
    return [persistencyManager getFixedCellSize];
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
- (bool) getShouldCollectionViewBeCenteredVertically{
    return [persistencyManager getShouldCollectionViewBeCenteredVertically];
}
- (bool) getShouldCollectionViewFillEntireHeight{
    return [persistencyManager getShouldCollectionViewFillEntireHeight];
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
- (NSString*) getPreferredFontName {
    return [persistencyManager getPreferredFontName];
}
- (float) getPlaceholderFontSize {
    return [persistencyManager getPlaceholderFontSize];
}
- (UIColor*) getPlaceholderTextColor {
    return [persistencyManager getPlaceholderTextColor];
}
- (bool) getShouldPlaceholderIndexStartFromZero {
    return [persistencyManager getShouldPlaceholderIndexStartFromZero];
}
- (bool) getShouldDragPlaceholderContainIndex {
    return [persistencyManager getShouldDragPlaceholderContainIndex];
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
//- (bool) isShouldRemoveAllEmptyCells {
//    return [persistencyManager getShouldRemoveAllEmptyCells];
//}
- (NSInteger) getScrollDirection {
    return [persistencyManager getScrollDirection];
}
- (bool) getHasAutomaticCellSize {
    return [persistencyManager getHasAutomaticCellSize];
}
- (float) getLongPressDurationBeforeDrag {
    return [persistencyManager getLongPressDurationBeforeDrag];
}
- (bool) getShouldItemsBePlacedFromLeftToRight {
    return [persistencyManager getShouldItemsBePlacedFromLeftToRight];
}
- (bool) getShouldPanningBeEnabled {
    return [persistencyManager getShouldPanningBeEnabled];
}
- (bool) getShouldPanningBeCoupled {
    return [persistencyManager getShouldPanningBeCoupled];
}

@end
