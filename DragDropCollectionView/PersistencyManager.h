//
//  PersistencyManager.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 27.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersistencyManager : NSObject

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


- (float) getCellWidthHeightRatio;
- (float) getMinInteritemSpacing;
- (float) getMinLineSpacing;
- (UIColor*) getBackgroundColorSourceView;
- (UIColor*) getBackgroundColorTargetView;
- (NSMutableDictionary*) getDataSourceDict;
- (UIColor*) getDropPlaceholderColorUntouched;
- (UIColor*) getDropPlaceholderColorTouched;
- (int) getNumberOfDropItems;

@end
