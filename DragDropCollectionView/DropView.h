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
#import "DragCollectionView.h"

@interface DropView : MoveableView

@property int previousDragViewIndex; // previous index in source collection view
@property int previousDropViewIndex; // previous index in target collection view (when item has moved from one cell to another)

- (instancetype)initWithView:(DropView*)view inCollectionViewCell:(CollectionViewCell*) cell;

- (void) move:(NSMutableDictionary *)targetCellsDict toIndex:(int)index;

@end
