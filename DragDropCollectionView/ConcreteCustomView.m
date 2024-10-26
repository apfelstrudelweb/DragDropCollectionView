//
//  ConcreteCustomView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 07.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ConcreteCustomView.h"
#import "UILabel+size.h"


#define FONTSIZE    6.0

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

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    
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
        
        // Mandatory for later introspection
        self.concreteClassName = NSStringFromClass([self class]);
        
    }
    return self;
}


#pragma  mark -getter/setter
- (void) setLabelText: (NSString*) text {
    
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    
    NSString* fontName = [SHARED_CONFIG_INSTANCE getPreferredFontName];
    
    UIFont* font = IS_IPAD ? [UIFont fontWithName:fontName size:2*FONTSIZE] : [UIFont fontWithName:fontName size:FONTSIZE];
    
    label.font = font;

}

- (void) setImageName: (NSString*) name {

    UIImage* image = [UIImage imageWithCGImage:[UIImage imageNamed:name].CGImage]; // trick for @2x.png
    // we need to set the accessibility identifier for the getter,
    // as an UIImage doesn't have any method for retrieving its name
    image.accessibilityIdentifier = name;
    imageView.image = image;
}

- (NSString*) getImageName {
    return imageView.image.accessibilityIdentifier;
}

- (void) setLabelColor: (UIColor*) color {
    label.textColor = color;
}

- (void) setBackgroundColorOfView: (UIColor*) color {
    self.backgroundColor = color;
}


- (NSString*) getLabelText {
    return label.text;
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
       // imageviewHeight = imageWidth / ratio;
    }
    
    // for zooming purposes ...
//    float f = 1.0;
//    float zoomFact = f * viewWidth / imageView.image.size.width;
//    imageWidth *= 0.9*zoomFact;
//    imageHeight *= 0.9*zoomFact;
    
//    UIFont* font = label.font;
//    NSString* fontName = font.fontName;
//    CGFloat fontSize = IS_IPAD ? 12 : 6;
//    UIFont* newFont = [UIFont fontWithName:fontName size:fontSize*zoomFact];
//    [label setFont:newFont];
    
    
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
