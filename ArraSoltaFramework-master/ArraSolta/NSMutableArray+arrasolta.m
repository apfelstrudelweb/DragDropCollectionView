//
//  NSMutableArray+cat.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 22.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "NSMutableArray+arrasolta.h"

@implementation NSMutableArray (arrasolta)


- (int) getNumberOfActiveElements {
    int num = 0;
    
    for (int i=0; i<self.count; i++) {
        if ([self[i] intValue] > 0) {
            num++;
        }
    }
    return num;
}

- (void) initWithZeroObjects: (int) capacity {
    
    for (int i=0; i<capacity+1; i++) {
         [self addObject:[NSNull null]];
    }
}


@end
