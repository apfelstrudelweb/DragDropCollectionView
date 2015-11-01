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
    
    // don't declare these members in the public interface,
    // otherwise we get conflicts with introspection in conjunction
    // with layout constraints during the dragging process of this view!
    UILabel *label;
}
@end

@implementation CustomView


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        label = [UILabel new];
        
        [self addSubview:label];

        // Mandatory - this framework needs it!
        self.concreteClassName = NSStringFromClass([self class]);
        
    }
    return self;
}


#pragma mark -layoutSubviews
// IMPORTANT: this method must be implemented
- (void)layoutSubviews {
    
    // Performance issue: don't update frame continuously during dragging the view,
    // only when view has been dropped or before dragging!
    if (!self.viewIsInDragState) {
        label.frame = self.bounds;
        // now we want to have rounded corners ... with black thin border
        self.layer.cornerRadius = 0.5*label.frame.size.height;
        self.layer.borderWidth = IS_IPAD ? 2.0 : 1.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
    }
}


#pragma  mark -getter/setter
/**
 * Label - Note - C, D, E ...
 **/
- (void) setLabelText: (NSString*) text {
    
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    
    CGFloat fontSize = 8.0;
    
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
 * Background color of this custom view
 **/
- (void) setBackgroundColorOfView: (UIColor*) color {
    self.backgroundColor = color;
}

- (UIColor*) getBackgroundColorOfView {
    return self.backgroundColor;
}

@end
