//
//  PersistencyManager.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 27.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "PersistencyManager.h"
#define INVALID -1

@interface PersistencyManager () {
    
    float cellWidthHeightRatio;
    
    float minInteritemSpacing;
    float minLineSpacing;
    
    UIColor* backgroundColorSourceView;
    UIColor* backgroundColorTargetView;
    
    UIColor* dropPlaceholderColorUntouched;
    UIColor* dropPlaceholderColorTouched;
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
}

@end

@implementation PersistencyManager

-(instancetype) init {
    
    cellWidthHeightRatio = INVALID;
    minInteritemSpacing = INVALID;
    minLineSpacing = INVALID;
    
    return self;
}

// Config API
- (void) setCellWidthHeightRatio: (float) value {
    cellWidthHeightRatio = value;
}
- (void) setMinInteritemSpacing: (float) value {
    minInteritemSpacing = value;
}
- (void) setMinLineSpacing: (float) value {
    minLineSpacing = value;
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
- (void) setShouldDropPlaceholderContainIndex: (bool) value {
    shouldDropPlaceholderContainIndex = value;
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

@end
