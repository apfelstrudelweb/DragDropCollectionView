//
//  ConcreteCustomView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 07.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ConcreteCustomView.h"


#import "UILabel+size.h"

#define FONT        @"Helvetica-Bold"
#define FONTSIZE    7.0

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface ConcreteCustomView( ) {
    
    NSDictionary *viewsDictionary;
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
    
    // don't declare these members in the public interface,
    // otherwise we get conflicts with introspection in conjunction
    // with layout constraints during dragging this view!
    UILabel *label;
    UIImageView *imageView;
}
@end

@implementation ConcreteCustomView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        label = [UILabel new];
        imageView = [UIImageView new];
        
        // avoids overlapping
        [self setClipsToBounds:YES];
        
        [label setTranslatesAutoresizingMaskIntoConstraints:NO];
        [imageView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self addSubview:label];
        [self addSubview:imageView];
        
    }
    return self;
}


#pragma  mark -getter/setter
- (void) setLabelText: (NSString*) text {
    [label setTextForDragDropElement:text];
    
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    
    UIFont* font = IS_IPAD ? [UIFont fontWithName:FONT size:2*FONTSIZE] : [UIFont fontWithName:FONT size:FONTSIZE];
    
    label.font = font;
    
}

- (void) setImageName: (NSString*) name {
    _imageName = name;
    // setup image view
    UIImage *image = [UIImage imageNamed:_imageName];
    UIImage* _image = [UIImage imageWithCGImage:image.CGImage]; // trick for @2x.png
    [imageView setImage:_image];
}

- (void) setLabelColor: (UIColor*) color {
    [label setTextColor:color];
}

- (void) setBackgroundColorOfView: (UIColor*) color {
    [self setBackgroundColor:color];
}


- (NSString*) getLabelText {
    return label.text;
}

- (NSString*) getImageName {
    return self.imageName;
}

- (UIColor*) getLabelColor {
    return label.textColor;
}

- (UIColor*) getBackgroundColorOfView {
    return self.backgroundColor;
}


// IMPORTANT: this method must be implemented
#pragma mark -layoutSubviews
- (void)layoutSubviews {
    
    // Performance issue: don't update constraints continuously during dragging the view,
    // only when view has been dropped or before dragging!
    if (!self.viewIsInDragState) {
        [self setupConstraints];
    }
}


#pragma mark -constraint issues
- (void)setupConstraints {
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    float viewHeight = self.frame.size.height;
    float viewWidth  = self.frame.size.width;
    
    // calculate a percentual padding in function of the total height of this view
    float fact = 0.05; // 5%
    float padding = fact*viewHeight;
    
    // define the order of the subviews - here we place them vertically:
    // on the top we place the label, beneath we place the image view
    viewsDictionary = @{        @"label"       : label,
                                @"image"       : imageView };
    
    NSString* visualFormatText = [NSString stringWithFormat:@"V:|-%f-[label]-%f-[image]", padding, padding];
    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary];
    
    for (int i = 0; i<visualFormatConstraints.count; i++) {
        [self addConstraint:visualFormatConstraints[i]];
    }
    
    
    layoutConstraints = [NSMutableArray new];
    
    // height of label - here: 25% of the total height of this view
    float labelHeight = 0.25*viewHeight;
    // available height for the image view - remember: we have 2 paddings:
    // one between the top and the label and the other between the label and the image view
    float imageviewHeight = viewHeight - labelHeight - 2*padding;
    float imageviewWidth  = viewWidth; // assume that we offer the entire width of this view
    
    float imageWidth  = imageView.image.size.width;
    float imageHeight = imageView.image.size.height;
    float ratio = (float) imageWidth / imageHeight;
    
    // watch out: the image size should not exceed the available size of the image view
    if (imageviewHeight < imageHeight) {
        imageHeight = imageviewHeight;
        imageWidth = ratio * imageHeight;
    } else if (imageviewWidth < imageWidth) {
        imageWidth = imageviewWidth;
        imageviewHeight = imageWidth / ratio;
    }
    
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:1.0
                                                               constant:0]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:labelHeight]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:label
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:imageWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:imageHeight]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView
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
