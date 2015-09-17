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

- (void) reset {
    for (UIView *view in self.contentView.subviews) {
        for (UIView *subview in view.subviews) {
            if ([subview isKindOfClass:[UILabel class]]) {
                [subview removeFromSuperview];
            }
        }
    }
    self.colorView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
    
    [self setupViewConstraints:self.colorView isExpanded:false];
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
        
    }
    return self;
}

- (void) didLongPress:(UISwipeGestureRecognizer *)sender  {
    [self reset];
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:self.indexPath forKey:@"indexPath"];
    [[NSNotificationCenter defaultCenter] postNotificationName: @"deleteCellNotification" object:nil userInfo:userInfo];
}

-(void)setLabelTitle:(NSString *)value {
    
    self.cellLabel = [[UILabel alloc] init];
    self.cellLabel.text = value;
    self.cellLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.cellLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self.colorView addSubview:self.cellLabel];
    [self setupLabelConstraints:self.cellLabel];
}

- (void) setColor: (UIColor*) color {
    self.colorView.backgroundColor = color;
    //[self setupViewConstraints:self.colorView isExpanded:true];
    [self expandColorView];
    self.isPopulated = true;
}

- (UIColor*) getColor {
    return self.backgroundColor;
}

- (void) shrinkColorView {
    [self setupViewConstraints:self.colorView isExpanded:false];
}

- (void) expandColorView {
    // expand only once!
    if (!self.isExpanded) {
        [self setupViewConstraints:self.colorView isExpanded:true];
    }
}

- (void) highlight {
    if (!self.isExpanded) {
        self.colorView.backgroundColor  = [UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0];
    }
}

- (void) unhighlight {
    self.colorView.backgroundColor = [UIColor colorWithRed:0.95 green:0.95 blue:0.95 alpha:1.0];
}



#pragma mark -constraint issues

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
