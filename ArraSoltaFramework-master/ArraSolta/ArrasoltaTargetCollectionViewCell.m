//
//  CollectionViewCell.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaTargetCollectionViewCell.h"
#import "ArrasoltaAPI.h"

#define ANIMATION_DURATION 0.5


@interface ArrasoltaTargetCollectionViewCell() {
    
    bool isTransformedLeft;
    bool isTransformedRight;

    CGRect originalFrame;
    
    int placeholderIndex;
}

@end


@implementation ArrasoltaTargetCollectionViewCell


// MUST be called (for the iPad)
- (void)layoutSubviews {
    //[super layoutSubviews];
    // omit super!
    if (![SHARED_STATE_INSTANCE isTransactionActive]) {
        
        float w = self.frame.size.width;
        float h = self.frame.size.height;
        
        self.contentView.frame = CGRectMake(0, 0, w, h);
        
        self.isPushedToLeft  = false;
        self.isPushedToRight = false;
    }
}


- (void) setNumberForDropView {
    
    if ([SHARED_CONFIG_INSTANCE getShouldTargetPlaceholderDisplayIndex]) {
        self.numberLabel.text = [NSString stringWithFormat:@"%d", placeholderIndex];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        
        self.numberLabel.textColor = [SHARED_CONFIG_INSTANCE getPlaceholderTextColor];
        float fontSize = [SHARED_CONFIG_INSTANCE getPlaceholderFontSize];
        NSString* fontName = [SHARED_CONFIG_INSTANCE getPreferredFontName];

        UIFont* font = [UIFont fontWithName:fontName size:fontSize];
        self.numberLabel.font = font;
    }
}


- (void) reset {
    
    self.placeholderView.backgroundColor = [SHARED_CONFIG_INSTANCE getTargetPlaceholderColorUntouched];
    
    self.placeholderView.alpha = 1.0;
    
    placeholderIndex = (int)self.indexPath.item;
    if (![SHARED_CONFIG_INSTANCE getShouldPlaceholderIndexStartFromZero]) {
        placeholderIndex++;
    }
    
    [self setupViewConstraints:self.placeholderView isExpanded:false];
    [self highlight:false];
    
    self.isPopulated = false;
    self.isExpanded = false;
    
    self.moveableView = nil;
    
    [self setNeedsDisplay];
    
}


- (void) populateWithContentsOfView: (ArrasoltaMoveableView*) view withinCollectionView: (UICollectionView*) collectionView {
    
    [self reset];
    
    if (!view) {
        return;
    }
    
    view.frame = self.contentView.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:view];
    
    self.moveableView = view;
    self.isPopulated = true;
}



// expands the cell when drag view is above it
- (void) expand {
    
    [self setupViewConstraints:self.placeholderView isExpanded:true];
    
    if (self.isPopulated) {
        [self highlight:true];
    } else {
        self.placeholderView.backgroundColor = [SHARED_CONFIG_INSTANCE getTargetPlaceholderColorTouched];
    }
}

// shrinks the cell when drag view leaves it again
- (void) shrink {
    
    [self setupViewConstraints:self.placeholderView isExpanded:false];
    
    if (self.isPopulated) {
        [self highlight:false];
    } else {
        self.placeholderView.backgroundColor = [SHARED_CONFIG_INSTANCE getTargetPlaceholderColorUntouched];
    }
}

// highlights/unhighlights the drop view (which is above this cell)
- (void) highlight: (bool) flag {
    self.contentView.alpha = flag ? 0.5 : 1.0;
    
}

- (void) push: (NSInteger) direction {
    
    if (!self.isPopulated) return;
    
    if (direction == Left) {
        if (self.isPushedToLeft) return;
        self.isPushedToLeft = true;
    } else {
        if (self.isPushedToRight) return;
        self.isPushedToRight = true;
    }
    
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    
    float deltaY = [SHARED_CONFIG_INSTANCE getMinLineSpacing];
    
    self.placeholderView.alpha = 0.0;
    originalFrame = self.moveableView.frame;
    
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         float offX = (direction == Left) ? 0 : 0.5*w;
                         float offY = -deltaY;
                         self.contentView.frame = CGRectMake(offX, offY, 0.5*w, h+2*deltaY);
                     }];
}

- (void) undoPush {
    
    self.isPushedToLeft  = false;
    self.isPushedToRight = false;
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         //moveableView.frame = originalFrame;
                         self.contentView.frame = originalFrame;
                     }];
}

@end
