//
//  NSMutableDictionary+cat.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MoveableView.h"


@interface NSMutableDictionary (cat)

/**
 * Inserts a new object at index position and right-shifts all other
 * objects at the right-hand side of the inserted object
 *
 */
- (MoveableView*) insertObject: (id) object atIndex: (int) index withMaxCapacity: (int) lastIndex;
- (void) shiftAllElementsToLeftFromIndex: (int) index;

- (void) removeMoveableView: (MoveableView*) view;
- (void) addMoveableView: (MoveableView*) view atIndex: (int) index;

@end
