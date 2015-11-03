//
//  ArrasoltaDragDropHelper.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 06.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaCurrentState.h"

#define SHARED_STATE_INSTANCE      [ArrasoltaCurrentState sharedInstance]

@interface ArrasoltaDragDropHelper : NSObject

+ (ArrasoltaDragDropHelper*) sharedInstance;

- (void)initWithView:(UIView*)view collectionViews:(NSArray*) collectionViews cellDictionaries:(NSArray*) cellDictionaries;

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

@end
