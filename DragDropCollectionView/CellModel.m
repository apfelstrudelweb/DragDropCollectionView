//
//  CellModel.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CellModel.h"

@implementation CellModel

- (void) populateWithDragView: (DragView*) view {
    
    self.view = view;
    
    [self setColor:view.backgroundColor];
    [self setLabelTitle:[view getLabelTitel]];
}

@end
