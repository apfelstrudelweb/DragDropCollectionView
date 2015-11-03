//
//  ArrasoltaViewConverter.h
//
//  Converter which performs a conversion from Source to Target View
//  and vice versa:
//
//  Created by Ulrich Vormbrock on 16.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


#import "ArrasoltaDraggableView.h"
#import "ArrasoltaDroppableView.h"

@interface ArrasoltaViewConverter : NSObject

+ (ArrasoltaViewConverter*) sharedInstance;

- (ArrasoltaDroppableView*) convertToDropView: (ArrasoltaDraggableView*) view widthIndex: (int)index;
- (ArrasoltaDraggableView*) convertToDragView: (ArrasoltaDroppableView*) view;


@end
