//
//  CollectionViewCell.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CollectionViewCell.h"

#define ANIMATION_DURATION 0.25
#define MIN_PRESS_DURATION 0.5

@interface CollectionViewCell() {
    NSMutableArray* layoutViewConstraints;
    

    bool isTransformedLeft;
    bool isTransformedRight;
    
    UIView* placeholderView; // basic subview of a cell - initially represented by a gray square
    MoveableView* moveableView;
}

@end


@implementation CollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        placeholderView = [UIView new];
        [placeholderView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.contentView addSubview:placeholderView];
        [self setupViewConstraints:placeholderView isExpanded:false];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
        
        self.longPressGesture.minimumPressDuration = MIN_PRESS_DURATION;
        self.longPressGesture.delegate = self;
        [self addGestureRecognizer:self.longPressGesture];
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}


- (void) reset {
    
//    [self.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        [obj removeFromSuperview];
//    }];
    
    // remove previous drop view -> important for scrolling
    for (UIView *view in self.contentView.subviews) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[MoveableView class]]) {
                [subview removeFromSuperview];
                break;
            }
        }
    }
    
    placeholderView.backgroundColor = COLOR_PLACEHOLDER_UNTOUCHED;
    
    [self setupViewConstraints:placeholderView isExpanded:false];
    
    self.isPopulated = false;
    self.isExpanded = false;

}

- (void) populateWithContentsOfView: (MoveableView*) view withinCollectionView: (UICollectionView*) collectionView {
    
    if ([view isKindOfClass:[DragView class]]) {
        // add an UIView above the main view
        CGRect dragRect = [Utils getCellCoordinates:self fromCollectionView:collectionView];
        [view setFrame:dragRect];
        [collectionView.superview addSubview:view];
    } else {
        [self reset];
        [self expand];
        self.isPopulated = true;
        // add an UIView above the placeholder views (gray square) in an UICollectionViewCell
        moveableView = view;
        [placeholderView addSubview:view];
        [view setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addFurtherViewConstraints:view];
    }
}


- (void) didLongPress:(UISwipeGestureRecognizer *)sender  {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.indexPath forKey:@"indexPath"];
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"shiftCellNotification" object:nil userInfo:userInfo];
    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        [self reset];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"deleteCellNotification" object:nil userInfo:userInfo];
    }
}

// expands the cell when drag view is above it
- (void) expand {
    if (!self.isPopulated) {
        [self setupViewConstraints:placeholderView isExpanded:true];
    } else {
        // highlight populated cell
        [self highlight:true];
    }
}

// shrinks the cell when drag view leaves it again
- (void) shrink {
    if (!self.isPopulated) {
        [self setupViewConstraints:placeholderView isExpanded:false];
    } else {
        // unhighlight populated cell
        [self highlight:false];
    }
}

// highlights/unhighlights the drop view (which is above this cell)
- (void) highlight: (bool) flag {
    for (UIView* view in placeholderView.subviews) {
        if ([view isKindOfClass:[DropView class]]) {
            view.alpha = flag ? 0.5 : 1.0;
        }
    }
}

- (void) push: (NSInteger) direction {
    
    if (!self.isPopulated) return;
    
    if (direction == Left) {
        if (self.isPushedToLeft) return;
        self.isPushedToLeft = true;
    } else {
        if (self.isPushedToRight) return;
        self.isPushedToRight = true;
    }
    
    [self setupViewConstraints:direction doReset:false];
    [self addFurtherViewConstraints:moveableView];
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         [self layoutIfNeeded];
                     }];
}

- (void) undoPush {
    self.isPushedToLeft = false;
    self.isPushedToRight = false;
    [self setupViewConstraints:Left doReset:true];
    //[self setupViewConstraints:Right doReset:true];
    [self addFurtherViewConstraints:moveableView];
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         [self layoutIfNeeded];
                     }];
}



#pragma mark -constraint issues
- (void)setupViewConstraints: (NSInteger) direction doReset: (bool) reset {
    
    [self removeConstraints:layoutViewConstraints];
    layoutViewConstraints = [NSMutableArray new];
    

    NSLayoutAttribute layoutAttributeHorizAlign = (direction==Left) ? NSLayoutAttributeLeft : NSLayoutAttributeRight;
    
    // Width constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:placeholderView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:reset ? 1.0 : 0.5
                                                                   constant:0]];
    
    // Height constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:placeholderView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:reset ? 1.0 : 1.2
                                                                   constant:0]];
    
    // Center horizontally
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:placeholderView
                                                                  attribute:layoutAttributeHorizAlign
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:layoutAttributeHorizAlign
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    // Center vertically
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:placeholderView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutViewConstraints];
    

    
}

- (void)setupViewConstraints: (UIView*) view isExpanded: (bool) expand {
    
    [self removeConstraints:layoutViewConstraints];
    layoutViewConstraints = [NSMutableArray new];
    
    UIView* referenceView;
    float fact = expand ? 1.0 : 0.7;
    
    referenceView = self.contentView;
    
    self.isExpanded = expand;
    
    // Width constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:fact
                                                                   constant:0]];
    
    // Height constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:fact
                                                                   constant:0]];
    
    // Center horizontally
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    // Center vertically
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutViewConstraints];
}

- (void)addFurtherViewConstraints: (UIView*) view {

    // Width constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:placeholderView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0
                                                                   constant:0]];
    
    // Height constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:placeholderView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1.0
                                                                   constant:0]];
    
    // Center horizontally
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:placeholderView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    // Center vertically
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:placeholderView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutViewConstraints];
}


@end
