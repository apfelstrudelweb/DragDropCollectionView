//
//  DragDropHelper.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 06.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentState.h"
#import "DragView.h"

@interface DragDropHelper : NSObject

+ (DragDropHelper*) sharedInstance;

- (void)initWithView:(UIView*)view collectionViews:(NSArray*) collectionViews cellDictionaries:(NSArray*) cellDictionaries;

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

@end
