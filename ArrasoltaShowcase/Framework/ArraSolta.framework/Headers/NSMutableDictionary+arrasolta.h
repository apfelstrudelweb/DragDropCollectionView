//
//  NSMutableDictionary+cat.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArrasoltaMoveableView.h"


@interface NSMutableDictionary (arrasolta)

/**
 * Inserts a new object at index position and right-shifts all other
 * objects at the right-hand side of the inserted object
 *
 */
- (ArrasoltaMoveableView*) insertObject: (id) object atIndex: (int) index withMaxCapacity: (int) lastIndex;
- (void) shiftAllElementsToLeftFromIndex: (int) index;
- (void) shiftAllElementsToRightFromIndex: (int) index;
- (void) flipBackElementAtIndex: (int) index;

- (void) removeMoveableView: (ArrasoltaMoveableView*) view;
- (void) addMoveableView: (ArrasoltaMoveableView*) view atIndex: (int) index;

@end
