//
//  ArrasoltaSourceCollectionViewCell.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 01.11.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaSourceCollectionViewCell.h"
#import "ArrasoltaAPI.h"

@interface ArrasoltaSourceCollectionViewCell() {
    
    int placeholderIndex;
    
}

@end

@implementation ArrasoltaSourceCollectionViewCell


- (void) populateWithContentsOfView: (ArrasoltaMoveableView*) view withinCollectionView: (UICollectionView*) collectionView {

    [self reset];
    
    if (!view) {
        return;
    }
    
    view.frame = self.contentView.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:view];
    
}

- (void) reset {
    
    self.placeholderView.backgroundColor = [SHARED_CONFIG_INSTANCE getSourcePlaceholderColor];
    
    self.placeholderView.alpha = 1.0;
    
    placeholderIndex = (int)self.indexPath.item;
    if (![SHARED_CONFIG_INSTANCE getShouldPlaceholderIndexStartFromZero]) {
        placeholderIndex++;
    }
    
    [self setupViewConstraints:self.placeholderView isExpanded:false];
    
    [self setNeedsDisplay];
    
}


- (void) setNumberForDragView {
    
    if ([SHARED_CONFIG_INSTANCE getShouldSourcePlaceholderDisplayIndex]) {
        
        self.numberLabel.text = [NSString stringWithFormat:@"%d", placeholderIndex];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        
        self.numberLabel.textColor = [SHARED_CONFIG_INSTANCE getPlaceholderTextColor];
        float fontSize = [SHARED_CONFIG_INSTANCE getPlaceholderFontSize];
        NSString* fontName = [SHARED_CONFIG_INSTANCE getPreferredFontName];
        
        UIFont* font = [UIFont fontWithName:fontName size:fontSize];
        self.numberLabel.font = font;
        
    }
}

@end
