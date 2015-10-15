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
    self.backgroundColor = [UIColor greenColor];
}

//- (id)initWithFrame:(CGRect)frame {
//    
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.center = self.superview.center;
//        self.backgroundColor = [UIColor greenColor];
//        
//         self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//        self.translatesAutoresizingMaskIntoConstraints = YES;
//        
//    }
//    return self;
//}


@end
