//
//  DragDropConfig.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigAPI : NSObject

+ (ConfigAPI*) sharedInstance;

- (void) setCellWidthHeightRatio: (float) value;
- (void) setMinInteritemSpacing: (float) value;
- (void) setMinLineSpacing: (float) value;
- (void) setBackgroundColorSourceView: (UIColor*) color;
- (void) setBackgroundColorTargetView: (UIColor*) color;
- (void) setDataSourceDict: (NSMutableDictionary*) dict;

- (float) getCellWidthHeightRatio;
- (float) getMinInteritemSpacing;
- (float) getMinLineSpacing;
- (UIColor*) getBackgroundColorSourceView;
- (UIColor*) getBackgroundColorTargetView;
- (NSMutableDictionary*) getDataSourceDict;

@end