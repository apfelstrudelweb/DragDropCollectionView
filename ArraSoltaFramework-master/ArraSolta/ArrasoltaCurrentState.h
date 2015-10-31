//
//  CurrentState.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 02.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArrasoltaCurrentState : NSObject

+ (ArrasoltaCurrentState*) sharedInstance;

@property (NS_NONATOMIC_IOSONLY, getter=isTransactionActive) bool transactionActive;
@property (NS_NONATOMIC_IOSONLY, getter=isStopPanning) bool stopPanning;
@property (NS_NONATOMIC_IOSONLY, getter=isDragAllowed) bool dragAllowed;

@property (NS_NONATOMIC_IOSONLY, getter=getConsumedItems, readonly, copy) NSArray *consumedItems;
@property (NS_NONATOMIC_IOSONLY, getter=getDragDropHelper, strong) NSObject *dragDropHelper;

@property (NS_NONATOMIC_IOSONLY, getter=getBottomSourceCollectionView) float bottomSourceCollectionView;
@property (NS_NONATOMIC_IOSONLY, getter=getTopTargetCollectionView) float topTargetCollectionView;

// dynamic cell size
@property (NS_NONATOMIC_IOSONLY, getter=getCellSize) CGSize cellSize;
@property (NS_NONATOMIC_IOSONLY, getter=getInitialCellSize) CGSize initialCellSize;


- (void) addConsumedItem: (UIView*) view;
- (void) removeConsumedItem: (UIView*) view;

@end
