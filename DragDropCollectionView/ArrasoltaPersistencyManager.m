//
//  PersistencyManager.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 27.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaPersistencyManager.h"
#define INVALID -1
#define ARRASOLTA_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface ArrasoltaPersistencyManager () {
    
    CGSize fixedCellSize;
    float cellWidthHeightRatio;
    
    float minInteritemSpacing;
    float minLineSpacing;
    
    bool shouldCollectionViewBeCenteredVertically;
    bool shouldCollectionViewFillEntireHeight;
    
    UIColor* backgroundColorSourceView;
    UIColor* backgroundColorTargetView;
    
    UIColor* dropPlaceholderColorUntouched;
    UIColor* dropPlaceholderColorTouched;
    
    NSString* preferredFontName;
    float placeholderFontSize;
    UIColor* placeholderTextColor;
    bool shouldPlaceholderIndexStartFromZero;
    bool shouldDragPlaceholderContainIndex; //// indexpath.item
    bool shouldDropPlaceholderContainIndex; // indexpath.item
    
    int numberOfDropPlaceholders;

    NSMutableDictionary* dataSourceDict;
    
    bool isSourceItemConsumable;
    bool shouldRemoveAllEmptyCells;
    
    NSObject* dragDropHelper;
    UIButton* undoButton;
    NSInteger scrollDirection;
    bool hasAutomaticCellSize;
    float longPressDurationBeforeDrag;
    bool shouldItemsBePlacedFromLeftToRight;
    bool shouldPanningBeEnabled;
    bool shouldPanningBeCoupled;
}

@end

@implementation ArrasoltaPersistencyManager

-(instancetype) init {
    
    cellWidthHeightRatio = INVALID;
    minInteritemSpacing = INVALID;
    minLineSpacing = INVALID;
    
    return self;
}

// Config API
- (void) setFixedCellSize:(CGSize)size {
    fixedCellSize = size;
}
- (void) setCellWidthHeightRatio: (float) value {
    cellWidthHeightRatio = value;
}
- (void) setMinInteritemSpacing: (float) value {
    minInteritemSpacing = value;
}
- (void) setMinLineSpacing: (float) value {
    minLineSpacing = value;
}
- (void) setShouldCollectionViewBeCenteredVertically: (bool) value {
    shouldCollectionViewBeCenteredVertically = value;
}
- (void) setShouldCollectionViewFillEntireHeight: (bool) value {
    shouldCollectionViewFillEntireHeight = value;
}
- (void) setBackgroundColorSourceView: (UIColor*) color {
    backgroundColorSourceView = color;
}
- (void) setBackgroundColorTargetView: (UIColor*) color {
    backgroundColorTargetView = color;
}
- (void) setDataSourceDict: (NSMutableDictionary*) dict {
    dataSourceDict = dict;
}
- (void) setDropPlaceholderColorUntouched: (UIColor*) color {
    dropPlaceholderColorUntouched = color;
}
- (void) setDropPlaceholderColorTouched: (UIColor*) color {
    dropPlaceholderColorTouched = color;
}
- (void) setPlaceholderTextColor: (UIColor*) color {
    placeholderTextColor = color;
}
- (void) setPreferredFontName: (NSString*) value {
    preferredFontName = value;
}
- (void) setPlaceholderFontSize: (float) value {
    placeholderFontSize = value;
}
- (void) setShouldDropPlaceholderContainIndex: (bool) value {
    shouldDropPlaceholderContainIndex = value;
}
- (void) setShouldPlaceholderIndexStartFromZero: (bool) value {
    shouldPlaceholderIndexStartFromZero = value;
}
- (void) setShouldDragPlaceholderContainIndex: (bool) value {
    shouldDragPlaceholderContainIndex = value;
}
- (void) setNumberOfDropItems: (int) value {
    numberOfDropPlaceholders = value;
}
- (void) setIsSourceItemConsumable: (bool) value {
    isSourceItemConsumable = value;
}
- (void) setShouldRemoveAllEmptyCells: (bool) value {
    shouldRemoveAllEmptyCells = value;
}
- (void) setUndoButton: (UIButton*) button {
    undoButton = button;
}
- (void) setScrollDirection: (NSInteger) value {
    scrollDirection = value;
}
- (void) setHasAutomaticCellSize: (bool) value {
    hasAutomaticCellSize = value;
}
- (void) setLongPressDurationBeforeDrag: (float) value {
    longPressDurationBeforeDrag = value;
}
- (void) setShouldItemsBePlacedFromLeftToRight: (bool) value {
    shouldItemsBePlacedFromLeftToRight = value;
}
-(void) setShouldPanningBeEnabled: (bool) value {
    shouldPanningBeEnabled = value;
}
-(void) setShouldPanningBeCoupled: (bool) value {
    shouldPanningBeCoupled = value;
}



- (CGSize) getFixedCellSize {
    return fixedCellSize;
}
- (float) getCellWidthHeightRatio {
    if (cellWidthHeightRatio == INVALID) {
        return 1.0;
    }
    return cellWidthHeightRatio;
}
- (float) getMinInteritemSpacing {
    if (minInteritemSpacing == INVALID && minLineSpacing == INVALID) {
        return 0.0;
    } else if (minInteritemSpacing == INVALID && minLineSpacing != INVALID) {
        return minLineSpacing;
    }
    return minInteritemSpacing;
}
- (float) getMinLineSpacing {
    if (minInteritemSpacing == INVALID && minLineSpacing == INVALID) {
        return 0.0;
    } else if (minInteritemSpacing != INVALID && minLineSpacing == INVALID) {
        return minInteritemSpacing;
    }
    return minLineSpacing;
}
- (bool) getShouldCollectionViewBeCenteredVertically{
    return shouldCollectionViewBeCenteredVertically;
}
- (bool) getShouldCollectionViewFillEntireHeight{
    return shouldCollectionViewFillEntireHeight;
}
- (UIColor*) getBackgroundColorSourceView {
    return backgroundColorSourceView;
}
- (UIColor*) getBackgroundColorTargetView {
    return backgroundColorTargetView;
}
- (NSMutableDictionary*) getDataSourceDict {
    return dataSourceDict;
}
- (UIColor*) getDropPlaceholderColorUntouched {
    if (dropPlaceholderColorUntouched) {
        return dropPlaceholderColorUntouched;
    } else {
        return [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    }
}
- (UIColor*) getDropPlaceholderColorTouched {
    if (dropPlaceholderColorTouched) {
        return dropPlaceholderColorTouched;
    } else {
        return [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0];
    }
}
- (NSString*) getPreferredFontName {
    if (preferredFontName) {
        return preferredFontName;
    } else {
        return @"Helvetica-Bold";
    }
}
- (float) getPlaceholderFontSize {
    if (placeholderFontSize) {
        return placeholderFontSize;
    } else {
        return ARRASOLTA_IS_IPAD ? 24 : 12;
    }
}
- (UIColor*) getPlaceholderTextColor {
    if (placeholderTextColor) {
        return placeholderTextColor;
    } else {
        return [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    }
}
- (bool) getShouldPlaceholderIndexStartFromZero {
    return shouldPlaceholderIndexStartFromZero;
}
- (bool) getShouldDragPlaceholderContainIndex {
    return shouldDragPlaceholderContainIndex;
}
- (bool) getShouldDropPlaceholderContainIndex {
    return shouldDropPlaceholderContainIndex;
}
- (int) getNumberOfDropItems {
    if (isSourceItemConsumable) {
        return (int)dataSourceDict.count;
     } else {
           return numberOfDropPlaceholders;
    }
}
- (bool) getIsSourceItemConsumable {
    return isSourceItemConsumable;
}
- (bool) getShouldRemoveAllEmptyCells {
    return shouldRemoveAllEmptyCells;
}
- (UIButton*) getUndoButton {
    return undoButton;
}
- (NSInteger) getScrollDirection {
    return scrollDirection;
}
- (bool) getHasAutomaticCellSize {
    return hasAutomaticCellSize;
}
- (float) getLongPressDurationBeforeDrag {
    return longPressDurationBeforeDrag;
}
- (bool) getShouldItemsBePlacedFromLeftToRight {
    return shouldItemsBePlacedFromLeftToRight;
}
-(bool) getShouldPanningBeEnabled {
    return shouldPanningBeEnabled;
}
-(bool) getShouldPanningBeCoupled {
    return shouldPanningBeCoupled;
}

@end
