//
//  ViewConverter.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DragView.h"
#import "DropView.h"

@interface ViewConverter : NSObject

+ (ViewConverter*) sharedInstance;

- (DropView*) convertToDropView: (DragView*) view widthIndex: (int)index;
- (DragView*) convertToDragView: (DropView*) view;


@end
