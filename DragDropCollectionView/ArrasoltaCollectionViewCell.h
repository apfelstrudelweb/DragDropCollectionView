//
//  CollectionViewCell.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


#import "ArrasoltaMoveableView.h"


@interface ArrasoltaCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSIndexPath* indexPath;

@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isPopulated;
@property (nonatomic) BOOL isPushedToLeft;
@property (nonatomic) BOOL isPushedToRight;

@property (nonatomic) BOOL isTargetCell;

// define push directions - accessible also from MainView.m
typedef NS_ENUM (NSInteger, PushDirection) {
    Left,
    Right };


- (void) reset;
- (void) setNumberForDragView;
- (void) setNumberForDropView;
- (void) populateWithContentsOfView: (ArrasoltaMoveableView*) view withinCollectionView:(UICollectionView*) collectionView;
- (void) expand;
- (void) shrink;
- (void) highlight: (bool) flag;

- (void) push: (NSInteger) direction;
- (void) undoPush;




@end
