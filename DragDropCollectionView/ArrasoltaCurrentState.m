//
//  CurrentState.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 02.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaCurrentState.h"

@interface ArrasoltaCurrentState () {
    bool transactionActive;
    bool stopPanning;
    
    NSMutableArray* consumedItemsArray;
    
    NSObject* dragDropHelper;
    
    float bottomSourceCollectionView;
    float topTargetCollectionView;
    
    CGSize cellSize;
    CGSize initialCellSize;
}
@end

@implementation ArrasoltaCurrentState

+ (ArrasoltaCurrentState*)sharedInstance
{
    
    static ArrasoltaCurrentState *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ArrasoltaCurrentState alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        consumedItemsArray = [NSMutableArray new];
    }
    return self;
}


// Getter/Setter which indicate if a Drag View is in the drag state (transaction)
- (void) setTransactionActive: (bool) value {
    transactionActive = value;
}

- (bool) isTransactionActive {
    return transactionActive;
}

- (void) setStopPanning: (bool) value {
    stopPanning = value;
}

- (bool) isStopPanning {
    return stopPanning;
}

- (void) addConsumedItem: (UIView*) view {
    [consumedItemsArray addObject:view];
}
- (void) removeConsumedItem: (UIView*) view {
    [consumedItemsArray removeObject:view];
}
- (NSArray*) getConsumedItems {
    return consumedItemsArray;
}


- (NSObject*) getDragDropHelper {
    return dragDropHelper;
}
- (void) setDragDropHelper: (NSObject*) object {
    dragDropHelper = object;
}

- (float) getBottomSourceCollectionView {
    return bottomSourceCollectionView;
}

- (void) setBottomSourceCollectionView: (float) value {
    bottomSourceCollectionView = value;
}

- (float) getTopTargetCollectionView {
    return topTargetCollectionView;
}

- (void) setTopTargetCollectionView: (float) value {
    topTargetCollectionView = value;
}


- (void) setCellSize:(CGSize)size {
    cellSize = size;
    
    if (CGSizeEqualToSize(initialCellSize, CGSizeZero)) {
        initialCellSize = cellSize;
    }
}

- (CGSize) getCellSize {
    
    return cellSize;
}

- (CGSize) getInitialCellSize {
    return initialCellSize;
}

- (void) setInitialCellSize:(CGSize)size {
    initialCellSize = size;
}



@end