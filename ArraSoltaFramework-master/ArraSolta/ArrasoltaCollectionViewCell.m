//
//  ArrasoltaCollectionViewCell.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 01.11.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaCollectionViewCell.h"
#import "ArrasoltaAPI.h"

#pragma clang diagnostic ignored "-Wincomplete-implementation"

@interface ArrasoltaCollectionViewCell() {
    
    UILongPressGestureRecognizer* longPressGesture;
    UIPanGestureRecognizer* panRecognizer;
    
    NSMutableArray* layoutViewConstraints;
    NSMutableArray* layoutLabelConstraints;
    
    float initialX;
    float initialY;
    
}

@end

@implementation ArrasoltaCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.placeholderView = [UIView new];
        [self.placeholderView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.contentView addSubview:self.placeholderView];
        [self setupViewConstraints:self.placeholderView isExpanded:false];
        
        self.userInteractionEnabled = YES;
        
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [self.numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.placeholderView addSubview:self.numberLabel];
        [self setupLabelConstraints];
        
        
        if (!panRecognizer) {
            panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            
            panRecognizer.maximumNumberOfTouches = 1;
            panRecognizer.minimumNumberOfTouches = 1;
            panRecognizer.delegate = self;
            [self addGestureRecognizer:panRecognizer];
        }
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

// IMPORTANT: this method MUST be implemented,
// otherwise we get trouble with cell contents after scrolling!
- (void) prepareForReuse {
    for (UIView* view in self.contentView.subviews) {
        if ([view isKindOfClass:[ArrasoltaMoveableView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}


- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    if (!self.indexPath) return; // when a source element has been dragged to top
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        initialX = [recognizer locationInView:self.window].x;
        initialY = [recognizer locationInView:self.window].y;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        float finalY = [recognizer locationInView:self.window].y;
        
        
        if (finalY >= [SHARED_STATE_INSTANCE getTopTargetCollectionView]) {
            // if we drop into the same grid, do nothing
            return;
        }
        
        if((finalY < [SHARED_STATE_INSTANCE getBottomSourceCollectionView]) || (finalY < initialY)) {
            
            NSDictionary *userInfo;
            
            //int index = self.indexPath.item;
            
            if (self.moveableView) {
                userInfo = [NSDictionary dictionaryWithObject:(ArrasoltaDroppableView*)self.moveableView forKey:@"dropView"];
                
            } else {
                // delete an empty cell
                userInfo = [NSDictionary dictionaryWithObject:self.indexPath forKey:@"indexPath"];
            }
            
            // delete only target cells
            if ([self isKindOfClass:[ArrasoltaTargetCollectionViewCell class]]) {
                [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaDeleteCellNotification" object:nil userInfo:userInfo];
            }
        }
    }
}


- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}

- (void) setupViewConstraints: (UIView*) view isExpanded: (bool) expand {
    
    [self removeConstraints:layoutViewConstraints];
    layoutViewConstraints = [NSMutableArray new];
    
    UIView* referenceView;
    float fact = expand ? 1.1 : 0.8;
    
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

- (void) setupLabelConstraints {
    
    [self removeConstraints:layoutLabelConstraints];
    layoutLabelConstraints = [NSMutableArray new];
    
    
    // Width constraint
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:_numberLabel
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_placeholderView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    // Height constraint
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:_numberLabel
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_placeholderView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    // Center horizontally
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:_numberLabel
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_placeholderView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    
    // Center vertically
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:_numberLabel
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:_placeholderView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutLabelConstraints];
}


@end
