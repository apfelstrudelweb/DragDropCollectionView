//
//  PersistencyManager.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 27.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface PersistencyManager : NSObject

// define scroll direction for collection view flow layout
typedef NS_ENUM (NSInteger, ScrollDirection) {
    vertical,
    horizontal
};

// Config API
- (void) setCellWidthHeightRatio: (float) value;
- (void) setMinInteritemSpacing: (float) value;
- (void) setMinLineSpacing: (float) value;
- (void) setBackgroundColorSourceView: (UIColor*) color;
- (void) setBackgroundColorTargetView: (UIColor*) color;
- (void) setDataSourceDict: (NSMutableDictionary*) dict;
- (void) setDropPlaceholderColorUntouched: (UIColor*) color;
- (void) setDropPlaceholderColorTouched: (UIColor*) color;
- (void) setNumberOfDropItems: (int) value;
- (void) setIsSourceItemConsumable: (bool) value;
- (void) setShouldRemoveAllEmptyCells: (bool) value;
- (void) setUndoButton: (UIButton*) button;
- (void) setScrollDirection: (NSInteger) value;
- (void) setHasAutomaticCellSize: (bool) value;


- (float) getCellWidthHeightRatio;
- (float) getMinInteritemSpacing;
- (float) getMinLineSpacing;
- (UIColor*) getBackgroundColorSourceView;
- (UIColor*) getBackgroundColorTargetView;
- (NSMutableDictionary*) getDataSourceDict;
- (UIColor*) getDropPlaceholderColorUntouched;
- (UIColor*) getDropPlaceholderColorTouched;
- (int) getNumberOfDropItems;
- (bool) getIsSourceItemConsumable;
- (bool) getShouldRemoveAllEmptyCells;
- (UIButton*) getUndoButton;
- (NSInteger) getScrollDirection;
- (bool) getHasAutomaticCellSize;

@end
