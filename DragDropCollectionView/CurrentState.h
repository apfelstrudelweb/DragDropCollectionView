//
//  CurrentState.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 02.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CurrentState : NSObject

+ (CurrentState*) sharedInstance;

- (void) setTransactionActive: (bool) value;
- (bool) isTransactionActive;

- (void) addConsumedItem: (UIView*) view;
- (void) removeConsumedItem: (UIView*) view;
- (NSArray*) getConsumedItems;

@end
