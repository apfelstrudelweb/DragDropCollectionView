//
//  LayoutManager.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <CoreGraphics/CGBase.h>

@interface LayoutManager : NSObject

@property (nonatomic) CGFloat originalCellWidth;
@property (nonatomic) CGFloat originalCellHeight;

+ (id)sharedManager;

- (CGFloat) getOriginalCellWidth;

@end
