//
//  NSMutableArray+cat.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 22.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (arrasolta)

@property (NS_NONATOMIC_IOSONLY, getter=getNumberOfActiveElements, readonly) int numberOfActiveElements;

- (void) initWithZeroObjects: (int) capacity;

@end
