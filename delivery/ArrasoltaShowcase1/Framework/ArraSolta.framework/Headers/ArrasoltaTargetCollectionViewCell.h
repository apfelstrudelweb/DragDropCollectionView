//
//  ArrasoltaTargetCollectionViewCell.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaCollectionViewCell.h"


@interface ArrasoltaTargetCollectionViewCell : ArrasoltaCollectionViewCell

// define push directions - accessible also from MainView.m
typedef NS_ENUM (NSInteger, PushDirection) {
    Left,
    Right };



@property (nonatomic) BOOL isPopulated;
@property (nonatomic) BOOL isPushedToLeft;
@property (nonatomic) BOOL isPushedToRight;


- (void) reset;
- (void) setNumberForDropView;

- (void) expand;
- (void) shrink;
- (void) highlight: (bool) flag;

- (void) push: (NSInteger) direction;
- (void) undoPush;


@end
