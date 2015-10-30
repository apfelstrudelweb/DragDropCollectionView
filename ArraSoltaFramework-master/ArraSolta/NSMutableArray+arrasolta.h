//
//  NSMutableArray+arrasolta.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 22.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSMutableArray (arrasolta)

@property (NS_NONATOMIC_IOSONLY, getter=getNumberOfActiveElements, readonly) int numberOfActiveElements;

- (void) initWithZeroObjects: (int) capacity;

@end
