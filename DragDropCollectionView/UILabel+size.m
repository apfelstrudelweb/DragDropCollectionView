//
//  UILabel+cat.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "UILabel+size.h"
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@implementation UILabel (size)

- (void) setTextForDragDropElement: (NSString*) text {
    
    self.text = text;
    self.textAlignment = NSTextAlignmentCenter;
    self.textColor = [UIColor whiteColor];
    
    UIFont* font = IS_IPAD ? [UIFont fontWithName:@"Helvetica-Bold" size:28] : [UIFont fontWithName:@"Helvetica" size:14];
    
    self.font = font;
}

- (void) setTextForHeadline: (NSString*) text {
    
    self.text = text;
    self.textAlignment = NSTextAlignmentLeft;
    self.textColor = FONT_COLOR;
    
    UIFont* font = IS_IPAD ? [UIFont fontWithName:@"Helvetica-Bold" size:28] : [UIFont fontWithName:@"Helvetica-Bold" size:16];
    
    self.font = font;
}

@end
