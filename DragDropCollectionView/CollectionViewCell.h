//
//  CollectionViewCell.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MoveableView.h"


@interface CollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSIndexPath* indexPath;

@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isPopulated;
@property (nonatomic) BOOL isPushedToLeft;
@property (nonatomic) BOOL isPushedToRight;

@property UILongPressGestureRecognizer* longPressGesture;


- (void) reset;
- (void) populateWithContentsOfView: (UIView*) view withinCollectionView:(UICollectionView*) collectionView;
- (void) expand;
- (void) shrink;

- (void) push: (NSInteger) direction;
- (void) undoPush;

// define push directions - accessible also from MainView.m
typedef NS_ENUM (NSInteger, PushDirection) {
    Left,
    Right
};

@end
