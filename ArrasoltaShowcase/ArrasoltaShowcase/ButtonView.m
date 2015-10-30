//
//  ButtonView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 23.10.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

@interface ButtonView() {
    // for layout constraints
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
}
@end

@implementation ButtonView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
   
        self.undoButton = [UIButton new];
        UIImage* undoBtnImage = [UIImage imageWithCGImage:[UIImage imageNamed:@"undo.png"].CGImage]; // trick for @2x.png
        [self.undoButton setImage:undoBtnImage forState:UIControlStateNormal];
        [self.undoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.undoButton];
        
        self.redoButton = [UIButton new];
        UIImage* redoBtnImage = [UIImage imageWithCGImage:[UIImage imageNamed:@"redo.png"].CGImage]; // trick for @2x.png
        [self.redoButton setImage:redoBtnImage forState:UIControlStateNormal];
        [self.redoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.redoButton];
        
        self.resetButton = [UIButton new];
        self.resetButton.backgroundColor = [UIColor lightGrayColor];
        [self.resetButton setTitle:@"Reset" forState:UIControlStateNormal];
        [self.resetButton setContentEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        [self.resetButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.resetButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.resetButton.titleLabel setButtonText:@""]; // formatting issue only
        self.resetButton.layer.cornerRadius = 5;
        self.resetButton.clipsToBounds = YES;
        [self addSubview:self.resetButton];
        
        self.counterLabel = [UILabel new];
        [self.counterLabel setHeadlineText:@"0"];
        [self.counterLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.counterLabel];
        
        // Bind all button elements to framework
        [SHARED_BUTTON_INSTANCE initWithResetButton:self.resetButton];
        [SHARED_BUTTON_INSTANCE initWithUndoButton:self.undoButton];
        [SHARED_BUTTON_INSTANCE initWithRedoButton:self.redoButton];
        [SHARED_BUTTON_INSTANCE initWithInfoLabel:self.counterLabel];
        
        [self setupConstraints];
  
    }
    return self;
}


#pragma mark -constraint issues
- (void)setupConstraints {
    
    self.subviewsDictionaryForAutoLayout = @{   @"reset"    : self.resetButton,
                                @"undo"     : self.undoButton,
                                @"redo"     : self.redoButton,
                                @"label"     : self.counterLabel
                                };
    
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    int dist = IS_IPAD ? 50 : 25; // set the distance between the elements 
    
    
    NSString* visualFormatText = [NSString stringWithFormat:@"H:[reset]-%d-[undo]-%d-[redo]-%d-[label]-%d-|",dist, dist, dist, dist];
    
    
    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subviewsDictionaryForAutoLayout];
    
    for (int i = 0; i<visualFormatConstraints.count; i++) {
        [self addConstraint:visualFormatConstraints[i]];
    }
    
    
    layoutConstraints = [NSMutableArray new];
    
    float fact = IS_IPAD ? 0.6 : 0.3;
    
    float undoButtonWidth  = fact*self.undoButton.imageView.image.size.width;
    float undoButtonHeight  = fact*self.undoButton.imageView.image.size.height;



    // RESET Button
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.resetButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.2
                                                               constant:0.0]];

    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.resetButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    // UNDO Button
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:undoButtonWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:undoButtonHeight]];
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // REDO Button
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.redoButton
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:undoButtonWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.redoButton
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:undoButtonHeight]];
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.redoButton
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0
                                                               constant:0.0]];

    // INFO Label
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.counterLabel
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.15
                                                               constant:0.0]];
    
    
    // Center vertically
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.counterLabel
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
