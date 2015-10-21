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


@property (NS_NONATOMIC_IOSONLY, getter=getCellWidthHeightRatio) float cellWidthHeightRatio;
@property (NS_NONATOMIC_IOSONLY, getter=getMinInteritemSpacing) float minInteritemSpacing;
@property (NS_NONATOMIC_IOSONLY, getter=getMinLineSpacing) float minLineSpacing;
@property (NS_NONATOMIC_IOSONLY, getter=getBackgroundColorSourceView, copy) UIColor *backgroundColorSourceView;
@property (NS_NONATOMIC_IOSONLY, getter=getBackgroundColorTargetView, copy) UIColor *backgroundColorTargetView;
@property (NS_NONATOMIC_IOSONLY, getter=getDataSourceDict, copy) NSMutableDictionary *dataSourceDict;
@property (NS_NONATOMIC_IOSONLY, getter=getDropPlaceholderColorUntouched, copy) UIColor *dropPlaceholderColorUntouched;
@property (NS_NONATOMIC_IOSONLY, getter=getDropPlaceholderColorTouched, copy) UIColor *dropPlaceholderColorTouched;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldDropPlaceholderContainIndex) bool shouldDropPlaceholderContainIndex;
@property (NS_NONATOMIC_IOSONLY, getter=getNumberOfDropItems) int numberOfDropItems;
@property (NS_NONATOMIC_IOSONLY, getter=getIsSourceItemConsumable) bool isSourceItemConsumable;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldRemoveAllEmptyCells) bool shouldRemoveAllEmptyCells;
@property (NS_NONATOMIC_IOSONLY, getter=getUndoButton, strong) UIButton *undoButton;
@property (NS_NONATOMIC_IOSONLY, getter=getScrollDirection) NSInteger scrollDirection;
@property (NS_NONATOMIC_IOSONLY, getter=getHasAutomaticCellSize) bool hasAutomaticCellSize;
@property (NS_NONATOMIC_IOSONLY, getter=getLongPressDurationBeforeDrag) float longPressDurationBeforeDrag;


@end
