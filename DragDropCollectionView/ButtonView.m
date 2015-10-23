//
//  ButtonView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 23.10.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ButtonView.h"
#import "UndoButtonHelper.h"
#import "UILabel+size.h"

#define SHARED_BUTTON_INSTANCE   [UndoButtonHelper sharedInstance]

@interface ButtonView() {
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
}
@end

@implementation ButtonView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
   
        self.undoButton = [UIButton new];
        UIImage* btnImage = [UIImage imageWithCGImage:[UIImage imageNamed:@"undo.png"].CGImage]; // trick for @2x.png
        [self.undoButton setImage:btnImage forState:UIControlStateNormal];
        [self.undoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.undoButton];
        
        self.infoLabel = [UILabel new];
        [self.infoLabel setTextForSubHeadline:@"0"];
        [self.infoLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.infoLabel];
        
        [SHARED_BUTTON_INSTANCE initWithButton:self.undoButton];
        [SHARED_BUTTON_INSTANCE initWithInfoLabel:self.infoLabel];
        
        [self setupConstraints];
  
    }
    return self;
}


#pragma mark -constraint issues
- (void)setupConstraints {
    
    self.viewsDictionary = @{   @"button"    : self.undoButton,
                                @"label"     : self.infoLabel
                                };
    
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    
    NSString* visualFormatText = [NSString stringWithFormat:@"H:[button]-%d-[label]-%d-|",MARGIN, MARGIN];
    
    
    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.viewsDictionary];
    
    for (int i = 0; i<visualFormatConstraints.count; i++) {
        [self addConstraint:visualFormatConstraints[i]];
    }
    
    
    layoutConstraints = [NSMutableArray new];
    
    float w = IS_IPAD ? 70 : 35;
    float h = IS_IPAD ? 50 : 25;

    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:w]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:h]];
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];

    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoLabel
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:20.0]];
    
//    // Height constraint
//    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoLabel
//                                                              attribute:NSLayoutAttributeHeight
//                                                              relatedBy:NSLayoutRelationLessThanOrEqual
//                                                                 toItem:self
//                                                              attribute:NSLayoutAttributeHeight
//                                                             multiplier:0.0
//                                                               constant:40.0]];
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.infoLabel
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

@end
