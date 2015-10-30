//
//  ConcreteCustomView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 07.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CustomView.h"


@interface CustomView( ) {
    
    NSDictionary *subviewsDictionaryForAutoLayout;
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
    
    // don't declare these members in the public interface,
    // otherwise we get conflicts with introspection in conjunction
    // with layout constraints during the dragging process of this view!
    UILabel *label;
    UIImageView *imageView;
}
@end

@implementation CustomView

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


#pragma mark -layoutSubviews
// IMPORTANT: this method must be implemented
- (void)layoutSubviews {
    
    // Performance issue: don't update constraints continuously during dragging the view,
    // only when view has been dropped or before dragging!
    if (!self.viewIsInDragState) {
        [self setupConstraints];
    }
}


#pragma  mark -getter/setter
/**
 * Label - country
 **/
- (void) setLabelText: (NSString*) text {
    
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    
    CGFloat fontSize = 6.0;
    
    // font name can be extracted from config settings or be defined here
    NSString* fontName = [SHARED_CONFIG_INSTANCE getPreferredFontName];
    UIFont* font = IS_IPAD ? [UIFont fontWithName:fontName size:2*fontSize] : [UIFont fontWithName:fontName size:fontSize];
    label.font = font;
}

- (NSString*) getLabelText {
    return label.text;
}

- (void) setLabelColor: (UIColor*) color {
    label.textColor = color;
}

- (UIColor*) getLabelColor {
    return label.textColor;
}


/**
 * Image - name of the PNG file - flag of country
 **/
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

/**
 * Background color of this custom view
 **/
- (void) setBackgroundColorOfView: (UIColor*) color {
    self.backgroundColor = color;
}

- (UIColor*) getBackgroundColorOfView {
    return self.backgroundColor;
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
    subviewsDictionaryForAutoLayout = @{        @"label"       : label,
                                                @"image"       : imageView };
    
    NSString* visualFormatText = [NSString stringWithFormat:@"V:|-%f-[label]-%f-[image]", padding, padding];
    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                      options:0
                                                                      metrics:nil
                                                                        views:subviewsDictionaryForAutoLayout];
    
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
