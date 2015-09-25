//
//  CollectionViewCell.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSIndexPath* indexPath;

//@property (nonatomic, strong) DragView* dragView;

@property (nonatomic, strong) UILabel* cellLabel;
@property (nonatomic, strong) UIView* colorView;
@property (nonatomic) BOOL isExpanded;
@property (nonatomic) BOOL isPopulated;
@property (nonatomic) BOOL isPushedToLeft;
@property (nonatomic) BOOL isPushedToRight;

@property UILongPressGestureRecognizer* longPressGesture;

- (void) populateWithCellModel: (CellModel*) model inCollectionView: (UICollectionView*) collectionView;

- (void) initialize;
- (void) setLabelTitle:(NSString *)value;
- (void) setColor: (UIColor*) color;
- (UIColor*) getColor;

- (void) shrinkEmptyOne;
- (void) expandEmptyOne;

- (void) highlightEmptyOne;
- (void) unhighlightEmptyOne;

- (void) highlightPopulatedOne;
- (void) unhighlightPopulatedOne;

- (void) pushToLeft;
- (void) pushToRight;
- (void) pushBack;


@end
