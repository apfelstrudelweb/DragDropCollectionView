//
//  NSMutableDictionary+cat.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "NSMutableDictionary+cat.h"


@implementation NSMutableDictionary (cat)

/**
 * Inserts a new object at index position and right-shifts all other 
 * objects at the right-hand side of the inserted object. When the 
 * maximal capacity (=number of items in collection view) is reached,
 * the laste element is removed in order to keep the number of
 * elements constant.
 *
 */
- (MoveableView*) insertObject: (MoveableView*) object atIndex: (int) index withMaxCapacity: (int) capacity {

    int lastIndex = capacity - 1;

    NSMutableDictionary* newDict = [NSMutableDictionary new];
    
    MoveableView* droppedView;
    
    // 1. get all keys in ascending order
    NSMutableArray *allKeys = [self.allKeys mutableCopy];
    
    [allKeys sortUsingComparator:
     ^NSComparisonResult(NSNumber* n1, NSNumber* n2){
         
         if (n1.intValue > n2.intValue) {
             return NSOrderedDescending;
         }
         else if (n1.intValue < n2.intValue) {
             return NSOrderedAscending;
         }
         else{
             return NSOrderedSame;
         }
     }
     ];
    
    // 2. copy all elements left to insertion index
    for (int i=0; i<allKeys.count; i++) {
        
        NSNumber* key = allKeys[i];
        
        if (key.intValue < index) {
            id object = self[key];
            // watch out for empty cells left to the insertion index
            if (object) {
                newDict[key] = object;
            }
        }
        

    }

    // 3. right-shift all other elements starting from insertion index
    for (int i=0; i<allKeys.count; i++) {
        
        NSNumber* key = allKeys[i];
        NSNumber* newKey = @(key.intValue+1);
        
        if (key.intValue >= index && key.intValue < lastIndex) {

            MoveableView* object = self[key];
            object.index = key.intValue+1;
            newDict[newKey] = object;
        } else if (key.intValue == lastIndex) {
            droppedView = self[key];
        }
    }
    
    // 4. copy new element at insertion index
    newDict[@(index)] = object;
    
    
    // 5. overwrite initial dictionary
    [self removeAllObjects];
    
    [newDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {

        self[key] = object;
    }];
    
    return droppedView;
}

- (void) shiftAllElementsToLeftFromIndex: (int) index {
    
    NSMutableDictionary* newDict = [NSMutableDictionary new];
    
    // 1. get all keys in ascending order
    NSMutableArray *allKeys = [self.allKeys mutableCopy];
    
    [allKeys sortUsingComparator:
     ^NSComparisonResult(NSNumber* n1, NSNumber* n2){
         
         if (n1.intValue > n2.intValue) {
             return NSOrderedDescending;
         }
         else if (n1.intValue < n2.intValue) {
             return NSOrderedAscending;
         }
         else{
             return NSOrderedSame;
         }
     }
     ];
    
    // 2. copy all elements left to deletion index
    for (int i=0; i<allKeys.count; i++) {
        
        NSNumber* key = allKeys[i];
        
        if (key.intValue < index) {
            id object = self[key];
            // watch out for empty cells left to the insertion index
            if (object) {
                newDict[key] = object;
            }
        }
    }
    
    // 3. left-shift all other elements starting from deletion index
    for (int i=0; i<allKeys.count; i++) {
        
        NSNumber* key = allKeys[i];
        NSNumber* newKey = @(key.intValue-1);
        
        if (key.intValue >= index) {
            
            MoveableView* object = self[key];
            object.index = key.intValue-1;
            newDict[newKey] = object;
        }
    }
    
    // 4. overwrite initial dictionary
    [self removeAllObjects];
    
    [newDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        
        self[key] = object;
    }];
}

- (void) removeMoveableView: (MoveableView*) view {
    int index = view.index;
    [self removeObjectForKey:@(index)];
}

- (void) addMoveableView: (MoveableView*) view atIndex: (int) index {
    
    [self setObject:view forKey:@(index)];

}


@end
