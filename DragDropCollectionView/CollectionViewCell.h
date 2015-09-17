//
//  CollectionViewCell.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewCell+cat.h"

@interface CollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSIndexPath* indexPath;

@property (nonatomic, strong) UILabel* cellLabel;
@property (nonatomic, strong) UIView* colorView;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isPopulated;

@property UILongPressGestureRecognizer* longPressGesture;

- (void) reset;
- (void) setLabelTitle:(NSString *)value;
- (void) setColor: (UIColor*) color;
- (UIColor*) getColor;

- (void) shrinkColorView;
- (void) expandColorView;

- (void) highlight;
- (void) unhighlight;

@end
