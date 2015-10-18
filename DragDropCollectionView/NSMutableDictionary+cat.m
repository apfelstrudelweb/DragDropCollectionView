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
 * objects at the right-hand side of the inserted object
 *
 */
- (void) insertObject: (id) object atIndex: (int) index {
    
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
    
    //NSLog(@"allKeys: %@", allKeys);
    
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
    //[newDict log];

    // 3. right-shift all other elements starting from insertion index
    for (int i=0; i<allKeys.count; i++) {
        
        NSNumber* key = allKeys[i];
        
        if(key.intValue >= index) {
            NSNumber* newKey = @(key.intValue+1);
            
            id object = self[key];
            newDict[newKey] = object;
        }
    }
    //[newDict log];
    
    // 4. copy new element at insertion index
    newDict[@(index)] = object;
    
    //[newDict log];
    
    // 5. overwrite initial dictionary
    [self removeAllObjects];
    
    [newDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        //NSLog(@"%@ = %@", key, object);
        self[key] = object;
    }];
}

- (void) removeMoveableView: (MoveableView*) view {
    int index = view.index;
    [self removeObjectForKey:@(index)];
}

- (void) addMoveableView: (MoveableView*) view atIndex: (int) index {
    
//    // in the case that a cell already contains a view, handle it!
//    MoveableView* underlyingView = [self objectForKey:[NSNumber numberWithInt:index]];
//    
//    if (underlyingView) {
//        [self setObject:underlyingView forKey:[NSNumber numberWithInt:-index]];
//    }
    
    self[@(index)] = view;
}


@end
