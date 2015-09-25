//
//  NSMutableDictionary+cat.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "NSMutableDictionary+cat.h"

@implementation NSMutableDictionary (cat)

- (void) insertObject: (id) object atIndex: (int) index {
    
    NSMutableDictionary* newDict = [NSMutableDictionary new];
    
    // 1. get all keys in ascending order
    NSMutableArray *allKeys = [[self allKeys] mutableCopy];
    
    [allKeys sortUsingComparator:
     ^NSComparisonResult(NSNumber* n1, NSNumber* n2){
         
         if ([n1 intValue] > [n2 intValue]) {
             return NSOrderedDescending;
         }
         else if ([n1 intValue] < [n2 intValue]) {
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
        
        if ([key intValue] < index) {
            id object = [self objectForKey:key];
            // watch out for empty cells left to the insertion index
            if (object) {
                [newDict setObject:object forKey:key];
            }
        }
        

    }
    //[newDict log];

    // 3. right-shift all other elements starting from insertion index
    for (int i=0; i<allKeys.count; i++) {
        
        NSNumber* key = allKeys[i];
        
        if([key intValue] >= index) {
            NSNumber* newKey = [NSNumber numberWithInt:[key intValue]+1];
            
            id object = [self objectForKey:key];
            [newDict setObject:object forKey:newKey];
        }
    }
    //[newDict log];
    
    // 4. copy new element at insertion index
    [newDict setObject:object forKey:[NSNumber numberWithInt:index]];
    
    //[newDict log];
    
    // 5. overwrite initial dictionary
    [self removeAllObjects];
    
    [newDict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        //NSLog(@"%@ = %@", key, object);
        [self setObject:object forKey:key];
    }];
    
 
}

// for debug purposes -> displays index as key and label title as value on console
- (void) log {
    
    NSMutableArray *allKeys = [[self allKeys] mutableCopy];
    
    [allKeys sortUsingComparator:
     ^NSComparisonResult(NSNumber* n1, NSNumber* n2){
         
         if ([n1 intValue] > [n2 intValue]) {
             return NSOrderedDescending;
         }
         else if ([n1 intValue] < [n2 intValue]) {
             return NSOrderedAscending;
         }
         else{
             return NSOrderedSame;
         }
     }
     ];
    
    
    printf("%s", "\r-------------------------\r");
    
    for (NSNumber *key in allKeys) {
        
        CellModel* model = [self objectForKey: key];
        NSString* labelTitle = [model labelTitle];
        
        NSString *fmt = [NSString stringWithFormat:@"\rkey = %2d -- label = %@", [key intValue], labelTitle];
        
        printf("%s", [fmt cStringUsingEncoding:[NSString defaultCStringEncoding]]);
    }
    
}

@end
