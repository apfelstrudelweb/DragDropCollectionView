//
//  CustomView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 01.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CustomView.h"

#define FONT @"Helvetica-Bold"
#define FONTSIZE 7.0

@interface CustomView( ) {
    
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
    
    bool hasObserver;
    
    NSString* imageName;

}
@end

@implementation CustomView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [UILabel new];
        self.imageView = [UIImageView new];
        
        //[self setContentMode:UIViewContentModeScaleAspectFit];
        [self setClipsToBounds:YES];
        
        [self.label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self.imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:self.label];
        [self addSubview:self.imageView];
  
   
    }
    return self;
}



- (void) setLabelText: (NSString*) text {
    [self.label setTextForDragDropElement:text];
    
    self.label.text = text;
    self.label.textAlignment = NSTextAlignmentCenter;
    
    UIFont* font = IS_IPAD ? [UIFont fontWithName:FONT size:2*FONTSIZE] : [UIFont fontWithName:FONT size:FONTSIZE];
    
    self.label.font = font;
    
    
}

- (void) setImageName: (NSString*) name {
    UIImage *image = [UIImage imageNamed:name];
    UIImage* _image = [UIImage imageWithCGImage:image.CGImage]; // trick for @2x.png
    [self.imageView setImage:_image];
    imageName = name;
}

- (void) setLabelColor: (UIColor*) color {
    [self.label setTextColor:color];
}

- (void) setBackgroundColorOfView: (UIColor*) color {
    [self setBackgroundColor:color];
}


- (NSString*) getLabelText {
    return self.label.text;
}

- (NSString*) getImageName {
    return imageName;
}

- (UIColor*) getLabelColor {
    return self.label.textColor;
}

- (UIColor*) getBackgroundColorOfView {
    return self.backgroundColor;
}



#pragma mark -constraint issues
- (void)layoutSubviews {
    [super layoutSubviews];
    
    bool viewIsInDragState = [SHARED_STATE_INSTANCE isTransactionActive];
 
    // Performance issue: don't update constraints continuously during dragging the view,
    // only when view has bee dropped or before dragging!
    if (!viewIsInDragState) {
        [self setupConstraints];
    }
}

- (void)setupConstraints {
    
    self.viewsDictionary = @{   @"label"       : self.label,
                                @"image"       : self.imageView };
    
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    float areaHeight = self.frame.size.height;
    float margin = areaHeight/20.0;
    
    
    NSString* visualFormatText = [NSString stringWithFormat:@"V:|-%f-[label]-%f-[image]", margin, margin];
    
    
    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.viewsDictionary];
    
    for (int i = 0; i<visualFormatConstraints.count; i++) {
        [self addConstraint:visualFormatConstraints[i]];
    }
    
    
    layoutConstraints = [NSMutableArray new];
    
    float labelHeight = areaHeight / 4.0 ;//[self heightForText];
    
    float remainingHeight = areaHeight - labelHeight - 2*margin;
    
    float fact = 1.0;//IS_RETINA ? 1.0 : 1.0;
    
    float imageWidth  = fact*self.imageView.image.size.width;
    float imageHeight = fact*self.imageView.image.size.height;
    float ratio = (float) imageWidth / imageHeight;
    
    if (remainingHeight < imageHeight) {
        imageHeight = remainingHeight;
        imageWidth = ratio * imageHeight;
    }
    
   
    
    
    
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.label
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.label
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:labelHeight]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.label
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:imageWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:imageHeight]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.imageView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}


@end
