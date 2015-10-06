//
//  MoveableView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 29.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MoveableView.h"

@interface MoveableView() {
    
    UIView* customView;
    
    NSMutableArray* layoutConstraints;
}
@end

@implementation MoveableView

- (void) setContentView: (UIView*) view {
    customView = view;
}

- (UIView*) getContentView {
    return customView;
}


- (void) initialize {
    
    [self resetConstraints];
    
    self.backgroundColor = self.borderColor;
    
    if (customView) {
        [customView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:customView];
        [self setupConstraints:customView];
        //[self bringSubviewToFront:customView];
    }
}



#pragma mark -constraint issues

- (void)resetConstraints {
    [self removeConstraints:layoutConstraints];
    layoutConstraints = [NSMutableArray new];
}

- (void)setupConstraints: (UIView*) element {
    
    if ([element isKindOfClass:[UIImageView class]]) {
        UIImageView* imageView = (UIImageView*)element;
        UIImage *image = imageView.image;
        CGSize size = image.size;
        float w = size.width;
        float h = size.height;
        
        
        // Width constraint
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:element
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0
                                                                   constant:w]];
        
        // Height constraint
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:element
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0
                                                                   constant:h]];
    } else {
        // Width constraint
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:element
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:0.9
                                                                   constant:0]];
        
        // Height constraint
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:element
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:0.9
                                                                   constant:0]];
    }
        
        // Center horizontally
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:element
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0]];
        
        // Center vertically
        [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:element
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    

    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
    [super updateConstraints];
}


@end
