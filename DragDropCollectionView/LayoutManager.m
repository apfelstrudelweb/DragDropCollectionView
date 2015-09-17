//
//  LayoutManager.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "LayoutManager.h"

@implementation LayoutManager

@synthesize originalCellWidth = _originalCellWidth;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static LayoutManager *sharedManager = nil;
    @synchronized(self) {
        if (sharedManager == nil)
            sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

- (id)init {
    if (self = [super init]) {
      
    }
    return self;
}

- (CGFloat) getOriginalCellWidth {
    return _originalCellWidth;
}

@end
