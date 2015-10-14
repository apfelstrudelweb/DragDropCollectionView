//
//  NSMutableDictionary+cat.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (cat)

/**
 * Inserts a new object at index position and right-shifts all other
 * objects at the right-hand side of the inserted object
 *
 */
- (void) insertObject: (id) object atIndex: (int) index;

@end
