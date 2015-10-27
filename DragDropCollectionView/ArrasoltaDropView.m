//
//  DropView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaDropView.h"
#import "ArrasoltaCustomView.h"
#import "NSMutableDictionary+arrasolta.h"

//#pragma GCC diagnostic ignored "-Wundeclared-selector"


@interface ArrasoltaDropView() {
  
}
@end

@implementation ArrasoltaDropView


- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithView:(ArrasoltaDropView*)view inCollectionViewCell:(ArrasoltaCollectionViewCell*) cell {
    
    self = [super initWithFrame:cell.frame];
    if (self) {
        
        // if there is already an underlying DropView, remove it
        for (UIView* view in cell.subviews) {
            if ([view isKindOfClass:[ArrasoltaDropView class]]) {
                [view removeFromSuperview];
            }
        }
        
        self.borderColor = view.borderColor;
        self.borderWidth = view.borderWidth;
        
        
        ArrasoltaCustomView* contentView = [view getContentView];
        
        contentView.center = cell.contentView.center;

        [self setContentView:contentView];
        [super initialize];

    }
    return self;
}

// move from one cell to another
- (void) move:(NSMutableDictionary *)targetCellsDict toIndex:(int)index {
    
    [targetCellsDict removeMoveableView:self];
    self.previousDropViewIndex = self.index;
    self.index = index;
    
    [targetCellsDict addMoveableView:self atIndex:index];
}

@end
