//
//  DragDropHelper.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 06.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DragDropHelper : NSObject

- (id)initWithView:(UIView*)view collectionViews:(NSArray*) collectionViews cellDictionaries:(NSArray*) cellDictionaries;

- (void)handlePan:(UIPanGestureRecognizer *)recognizer;

@end
