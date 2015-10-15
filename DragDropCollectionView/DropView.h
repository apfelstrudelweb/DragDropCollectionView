//
//  DropView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MoveableView.h"
#import "CollectionViewCell.h"
#import "DragView.h"
#import "DragCollectionView.h"

@interface DropView : MoveableView

@property int sourceIndex;

- (DropView*) provideNew;

- (id)initWithView:(DragView*)view inCollectionViewCell:(CollectionViewCell*) cell;

- (void) setMainView: (UIView*) view;

@end
