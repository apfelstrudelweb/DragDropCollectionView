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

    NSMutableDictionary* dataSourceDict;
    
    // Current State
    bool transactionActive;
}

@end

@implementation PersistencyManager

-(id) init {
    
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

// Current State
- (void) setTransactionActive: (bool) value {
    transactionActive = value;
}

- (bool) isTransactionActive {
    return transactionActive;
}

@end
