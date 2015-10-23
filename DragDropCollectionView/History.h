//
//  History.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 22.10.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface History : NSObject

@property (nonatomic) BOOL elementComesFromTop;
@property (nonatomic) BOOL elementHasBeenInserted;
@property (nonatomic) BOOL elementHasBeenDeleted;
@property (nonatomic) BOOL elementHasBeenReplaced;
@property (nonatomic) BOOL elementHasBeenDroppedOut;
@property (nonatomic) BOOL emptyCellHasBeenDeleted;

@property (nonatomic) int index;
@property (nonatomic) int previousIndex;
@property (nonatomic) int deletionIndex;

@end
