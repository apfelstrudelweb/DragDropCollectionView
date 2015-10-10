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
    
    NSMutableArray* consumedItemsArray;
    
    NSObject* dragDropHelper;
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

- (id)init
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

@end