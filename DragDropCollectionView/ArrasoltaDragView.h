//
//  DragView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrasoltaMoveableView.h"

@interface ArrasoltaDragView : ArrasoltaMoveableView


- (void) setBorderColor: (UIColor*) color;
- (void) setBorderWidth: (float) value;


@end
