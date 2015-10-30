//
//  DragDropHelper.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 06.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ArrasoltaCurrentState.h"
#import "ArrasoltaDragView.h"

@interface ArrasoltaDragDropHelper : NSObject

+ (ArrasoltaDragDropHelper*) sharedInstance;

- (void)initWithView:(UIView*)view collectionViews:(NSArray*) collectionViews cellDictionaries:(NSArray*) cellDictionaries;

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

@end
