//
//  CollectionViewCell.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CollectionViewCell.h"

@interface CollectionViewCell() {
    NSMutableArray* layoutViewConstraints;
    NSMutableArray* layoutLabelConstraints;
}

@end

@implementation CollectionViewCell

- (void) initialize {
    
    // remove previous label
    for (UIView *view in self.contentView.subviews) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                [subview removeFromSuperview];
                break;
            }
        }
    }
    self.colorView.backgroundColor = COLOR_PLACEHOLDER_UNTOUCHED;
    
    [self setupViewConstraints:self.colorView isExpanded:false];
    
    self.isPopulated = false;
    self.isExpanded = false;
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.colorView = [UIView new];
        [self.colorView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.contentView addSubview:self.colorView];
        [self setupViewConstraints:self.colorView isExpanded:false];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
        
        self.longPressGesture.minimumPressDuration = 0.5; //seconds
        self.longPressGesture.delegate = self;
        [self addGestureRecognizer:self.longPressGesture];
        
        self.userInteractionEnabled = YES;
        
//        [[self contentView] setFrame:[self bounds]];
//        [[self contentView] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
    }
    return self;
}

//- (bool) isPopulated {
//    bool hasLabel = false;
//    
//    for (UIView *view in self.contentView.subviews) {
//        for (UIView *subview in view.subviews) {
//            if ([subview isKindOfClass:[UILabel class]]) {
//                hasLabel = true;
//                break;
//            }
//        }
//    }
//    return hasLabel;
//}

- (void) didLongPress:(UISwipeGestureRecognizer *)sender  {
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.indexPath forKey:@"indexPath"];

    if (sender.state == UIGestureRecognizerStateEnded) {
        [[NSNotificationCenter defaultCenter] postNotificationName: @"shiftCellNotification" object:nil userInfo:userInfo];
    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        [self initialize];
        [[NSNotificationCenter defaultCenter] postNotificationName: @"deleteCellNotification" object:nil userInfo:userInfo];
    }
}


-(void)setLabelTitle:(NSString *)text {
    
    self.cellLabel = [[UILabel alloc] init];
    [self.cellLabel setTextForDragDropElement:text];
    
    [self.cellLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.colorView addSubview:self.cellLabel];
    [self setupLabelConstraints:self.cellLabel];
}

- (void) setColor: (UIColor*) color {
    self.colorView.backgroundColor = color;
    [self expandEmptyOne];
    self.isPopulated = true;
}

- (UIColor*) getColor {
    return self.backgroundColor;
}

- (void) shrinkEmptyOne {
    [self setupViewConstraints:self.colorView isExpanded:false];
}

- (void) expandEmptyOne {
    // expand only once!
    if (!self.isExpanded) {
        [self setupViewConstraints:self.colorView isExpanded:true];
    }
}

- (void) highlightEmptyOne {
    if (!self.isExpanded) {
        self.colorView.backgroundColor  = COLOR_PLACEHOLDER_TOUCHED;
    }
}

- (void) unhighlightEmptyOne {
    self.colorView.backgroundColor = COLOR_PLACEHOLDER_UNTOUCHED;
}

- (void) highlightPopulatedOne {
    self.colorView.alpha = 0.3;
}

- (void) unhighlightPopulatedOne {
    self.colorView.alpha = 1.0;
}

- (void) pushToLeft {
    
    if (self.isPushedToLeft || !self.isPopulated) return;
    self.isPushedToLeft = true;
    
    [self setupViewConstraints:true doReset:false];
}

- (void) pushToRight {
    
    if (self.isPushedToRight || !self.isPopulated) return;
    self.isPushedToRight = true;
    
    [self setupViewConstraints:false doReset:false];
}

- (void) pushBack {
    
    self.isPushedToLeft = false;
    self.isPushedToRight = false;
    [self setupViewConstraints:false doReset:true];
}



#pragma mark -constraint issues

- (void)setupViewConstraints: (bool) toLeft doReset: (bool) reset {
    
    [self removeConstraints:layoutViewConstraints];
    layoutViewConstraints = [NSMutableArray new];
    
    NSLayoutAttribute layoutAttributeHorizAlign = toLeft ? NSLayoutAttributeLeft : NSLayoutAttributeRight;
    
    // Width constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.colorView
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:reset ? 1.0 : 0.5
                                                                   constant:0]];
    
    // Height constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.colorView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:reset ? 1.0 : 1.2
                                                                   constant:0]];
    
    // Center horizontally
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.colorView
                                                                  attribute:layoutAttributeHorizAlign
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:layoutAttributeHorizAlign
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    // Center vertically
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:self.colorView
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
    
    float fact = expand ? 1.0 : 0.7;
    self.isExpanded = expand;
    
    // Width constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:fact
                                                                   constant:0]];
    
    // Height constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:fact
                                                                   constant:0]];
    
    // Center horizontally
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    // Center vertically
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.contentView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutViewConstraints];
}

- (void)setupLabelConstraints: (UILabel*) label {
    
    [self removeConstraints:layoutLabelConstraints];
    layoutLabelConstraints = [NSMutableArray new];
    
    // Width constraint
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    // Height constraint
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    // Center horizontally
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    
    // Center vertically
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.contentView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutLabelConstraints];
}

@end
