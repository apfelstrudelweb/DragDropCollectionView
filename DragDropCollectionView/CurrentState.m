//
//  CurrentState.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 02.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CurrentState.h"

@interface CurrentState () {
    bool transactionActive;
    //bool dragAllowed;
    
    NSMutableArray* consumedItemsArray;
    
    NSObject* dragDropHelper;
    
    float bottomSourceCollectionView;
    float topTargetCollectionView;
    
    CGSize cellSize;
    CGSize initialCellSize;
}
@end

@implementation CurrentState

+ (CurrentState*)sharedInstance
{
    
    static CurrentState *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[CurrentState alloc] init];
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

//- (void) setDragAllowed: (bool) value {
//    dragAllowed = value;
//}
//
//- (bool) isDragAllowed{
//    return dragAllowed;
//}


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
    
//    if (CGSizeEqualToSize(cellSize, CGSizeZero)) {
//        cellSize = CGSizeMake(0, 0);
//    }
    
    return cellSize;
}

- (CGSize) getInitialCellSize {
    return initialCellSize;
}

- (void) setInitialCellSize:(CGSize)size {
    initialCellSize = size;
}



@end