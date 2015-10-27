//
//  ViewConverter.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArrasoltaDragView.h"
#import "ArrasoltaDropView.h"

@interface ArrasoltaViewConverter : NSObject

+ (ArrasoltaViewConverter*) sharedInstance;

- (ArrasoltaDropView*) convertToDropView: (ArrasoltaDragView*) view widthIndex: (int)index;
- (ArrasoltaDragView*) convertToDragView: (ArrasoltaDropView*) view;


@end
