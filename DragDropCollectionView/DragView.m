//
//  DragView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragView.h"
#import "CustomView.h"


@interface DragView() {
    
}
@end



@implementation DragView


- (void) setBorderColor: (UIColor*) color {
    //[super setBackgroundColor:color];
    super.borderColor = color;
}

- (void) setBorderWidth: (float) value {
    super.borderWidth = value;
}




@end
