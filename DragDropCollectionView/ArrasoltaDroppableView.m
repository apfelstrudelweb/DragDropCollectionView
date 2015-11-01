//
//  DropView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaDroppableView.h"
#import "NSMutableDictionary+arrasolta.h"


@implementation ArrasoltaDroppableView


- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithView:(ArrasoltaDroppableView*)view inCollectionViewCell:(ArrasoltaTargetCollectionViewCell*) cell {
    
    self = [super initWithFrame:cell.frame];
    if (self) {
        
        // if there is already an underlying DropView, remove it
        for (UIView* view in cell.subviews) {
            if ([view isKindOfClass:[ArrasoltaDroppableView class]]) {
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
