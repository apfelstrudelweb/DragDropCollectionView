//
//  UILabel+cat.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (size)

- (void) setTextForDragDropElement: (NSString*) text;
- (void) setTextForHeadline: (NSString*) text;
- (void) setPlaceholderText: (NSString*) text;

@end
