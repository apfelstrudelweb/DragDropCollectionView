//
//  UILabel+cat.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "UILabel+format.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@implementation UILabel (format)


- (void) setHeadlineText: (NSString*) text {
    
    self.text = text;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = FONT_COLOR;
    
    UIFont* font = IS_IPAD ? [UIFont fontWithName:[SHARED_CONFIG_INSTANCE getPreferredFontName] size:50] : [UIFont fontWithName:[SHARED_CONFIG_INSTANCE getPreferredFontName] size:24];
    
    self.font = font;
}

- (void) setButtonText: (NSString*) text {
    
    self.text = text;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = FONT_COLOR;
    
    UIFont* font = IS_IPAD ? [UIFont fontWithName:[SHARED_CONFIG_INSTANCE getPreferredFontName] size:30] : [UIFont fontWithName:[SHARED_CONFIG_INSTANCE getPreferredFontName] size:14];
    
    self.font = font;
}

- (void) setCounterText: (NSString*) text {
    self.text = text;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = COMPONENT_COLOR;
    
    UIFont* font = IS_IPAD ? [UIFont fontWithName:[SHARED_CONFIG_INSTANCE getPreferredFontName] size:50] : [UIFont fontWithName:[SHARED_CONFIG_INSTANCE getPreferredFontName] size:24];
    
    self.font = font;
}


@end
