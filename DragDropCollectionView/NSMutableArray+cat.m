//
//  NSMutableArray+cat.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 22.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "NSMutableArray+cat.h"

@implementation NSMutableArray (cat)

//- (void) populateWithNumber: (int) num atIndex: (int) index {
//    
//    NSLog(@"count=%lu", (unsigned long)self.count);
//    
//    NSNumber* number = [NSNumber numberWithInt:num];
//    
//    if (self.count < index+1) {
//         [self insertObject:number atIndex:index];
//    } else {
//         [self replaceObjectAtIndex:index withObject:number];
//    }
//}

- (int) getNumberOfActiveElements {
    int num = 0;
    
    for (int i=0; i<self.count; i++) {
        if ([self[i] intValue] > 0) {
            num++;
        }
    }
    return num;
}

@end
