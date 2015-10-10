//
//  DropView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DropView.h"
#import "CustomView.h"
#pragma GCC diagnostic ignored "-Wundeclared-selector"

@interface DropView() {
    UIView* mainView;
}
@end

@implementation DropView



- (void) setMainView: (UIView*) view {
    mainView = view;
}



- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithView:(DragView*)view inCollectionViewCell:(CollectionViewCell*) cell {
    
    self = [super initWithFrame:cell.frame];
    if (self) {
        
        // if there is already an underlying DropView, remove it
        for (UIView* view in cell.subviews) {
            if ([view isKindOfClass:[DropView class]]) {
                [view removeFromSuperview];
            }
        }
        
        self.borderColor = view.borderColor;
        self.borderWidth = view.borderWidth;
        
        
        UIView* contentView = [view getContentView];
        
        /**
         * Important: we make a copy of the contentView - the same occurs when we drag an
         * element twice. In the target custom view, we want to achieve exactly the same look
         * and the same behavior when a new cell is to be inserted and the adjacent cells
         * are rotated. With the copy we guarantee that the perspectives of the contentView
         * are the same!
         * See also "DragView.provideNew()"
         *
         **/
//        CustomView* newContentView = (CustomView*)[contentView snapshotViewAfterScreenUpdates:NO];

        [self setContentView:contentView];
        [super initialize];

    }
    return self;
}


@end
