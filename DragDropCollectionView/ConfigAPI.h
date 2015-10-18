//
//  DragDropConfig.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "PersistencyManager.h"

@interface ConfigAPI : NSObject


+ (ConfigAPI*) sharedInstance;

- (void) setCellWidthHeightRatio: (float) value;
- (void) setMinInteritemSpacing: (float) value;
- (void) setMinLineSpacing: (float) value;
- (void) setBackgroundColorSourceView: (UIColor*) color;
- (void) setBackgroundColorTargetView: (UIColor*) color;
- (void) setDataSourceDict: (NSMutableDictionary*) dict;
- (void) setDropPlaceholderColorUntouched: (UIColor*) color;
- (void) setDropPlaceholderColorTouched: (UIColor*) color;
- (void) setNumberOfDropItems: (int) value;
- (void) setSourceItemConsumable: (bool) value;
- (void) shouldRemoveAllEmptyCells: (bool) value;
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
- (bool) isSourceItemConsumable;
- (bool) isShouldRemoveAllEmptyCells;
- (NSInteger) getScrollDirection;
- (bool) getHasAutomaticCellSize;


@end
