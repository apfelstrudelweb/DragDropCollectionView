//
//  DropView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrasoltaMoveableView.h"
#import "ArrasoltaCollectionViewCell.h"
#import "ArrasoltaDragCollectionView.h"

@interface ArrasoltaDropView : ArrasoltaMoveableView

@property int previousDragViewIndex; // previous index in source collection view
@property int previousDropViewIndex; // previous index in target collection view (when item has moved from one cell to another)

- (instancetype)initWithView:(ArrasoltaDropView*)view inCollectionViewCell:(ArrasoltaCollectionViewCell*) cell;

- (void) move:(NSMutableDictionary *)targetCellsDict toIndex:(int)index;

@end
