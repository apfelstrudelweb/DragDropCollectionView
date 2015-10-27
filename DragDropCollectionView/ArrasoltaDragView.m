//
//  DragView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaDragView.h"
#import "ArrasoltaCustomView.h"


@interface ArrasoltaDragView() {
    
}
@end



@implementation ArrasoltaDragView


- (void) setBorderColor: (UIColor*) color {
    //[super setBackgroundColor:color];
    super.borderColor = color;
}

- (void) setBorderWidth: (float) value {
    super.borderWidth = value;
}




@end
