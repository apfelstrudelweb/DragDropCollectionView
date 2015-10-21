//
//  CustomView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 01.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CustomView.h"
#import "CurrentState.h"

@implementation CustomView


#pragma mark -layoutSubviews
- (void)layoutSubviews {
    
    self.viewIsInDragState = [[CurrentState sharedInstance] isTransactionActive];
    
    self.center = self.superview.center;
}

@end
