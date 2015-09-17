//
//  UICollectionViewCell+cat.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "UICollectionViewCell+cat.h"
#import "LayoutManager.h"

#define SHARED_MANAGER     [LayoutManager sharedManager]

#define OFFSET 5.0

@implementation UICollectionViewCell (cat)


- (void) shrink {
    
    CGRect origFrame = self.frame;
    float x = origFrame.origin.x;
    float y = origFrame.origin.y;
    float w = origFrame.size.width;
    float h = origFrame.size.height;

    CGRect newFrame = CGRectMake(x+OFFSET, y+OFFSET, w-2*OFFSET, h-2*OFFSET);
    self.frame = newFrame;
}

- (void) expand {
    
    float origW = [SHARED_MANAGER getOriginalCellWidth];
    float origH = origW;
    
    CGRect origFrame = self.frame;
    float x = origFrame.origin.x;
    float y = origFrame.origin.y;
    float w = origFrame.size.width;
    float h = origFrame.size.height;
    
    float diffX = origW - w;
    float diffY = origH - h;
    
    CGRect newFrame = CGRectMake(x-diffX, y-diffY, origW, origH);
    self.frame = newFrame;
}


@end
