//
//  NSMutableDictionary+arrasolta.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


#import "ArrasoltaMoveableView.h"


@interface NSMutableDictionary (arrasolta)


- (ArrasoltaMoveableView*) insertObject: (id) object atIndex: (int) index withMaxCapacity: (int) lastIndex;

- (void) shiftAllElementsToLeftFromIndex: (int) index;
- (void) shiftAllElementsToRightFromIndex: (int) index;
- (void) flipBackElementAtIndex: (int) index;

- (void) removeMoveableView: (ArrasoltaMoveableView*) view;
- (void) addMoveableView: (ArrasoltaMoveableView*) view atIndex: (int) index;

@end
