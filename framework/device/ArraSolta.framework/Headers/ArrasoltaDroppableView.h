//
//  DropView.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaMoveableView.h"
#import "ArrasoltaTargetCollectionViewCell.h"

@interface ArrasoltaDroppableView : ArrasoltaMoveableView

@property int previousDragViewIndex; // previous index in source collection view
@property int previousDropViewIndex; // previous index in target collection view (when item has moved from one cell to another)

- (instancetype)initWithView:(ArrasoltaDroppableView*)view inCollectionViewCell:(ArrasoltaTargetCollectionViewCell*) cell;

- (void) move:(NSMutableDictionary *)targetCellsDict toIndex:(int)index;

@end
