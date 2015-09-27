//
//  PersistencyManager.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 27.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "PersistencyManager.h"

@interface PersistencyManager () {
    
    float itemSpacing;
    UIColor* backgroundColorSourceView;
    UIColor* backgroundColorTargetView;

    NSMutableDictionary* dataSourceDict;
}

@end

@implementation PersistencyManager

- (void) setItemSpacing: (float) value {
    itemSpacing = value;
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

- (float) getItemSpacing {
    return itemSpacing;
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

@end
