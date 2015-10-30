//
//  CustomView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 01.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaCustomView.h"
#import "ArrasoltaCurrentState.h"

@implementation ArrasoltaCustomView


#pragma mark -layoutSubviews
- (void)layoutSubviews {
    
    self.viewIsInDragState = [[ArrasoltaCurrentState sharedInstance] isTransactionActive];
    
    self.center = self.superview.center;
}

@end
