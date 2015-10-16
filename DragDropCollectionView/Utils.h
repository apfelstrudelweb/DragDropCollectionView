//
//  Utils.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


#import "NSMutableArray+cat.h"
#import "NSMutableDictionary+cat.h"
#import "CollectionViewCell.h"
#import "MoveableView.h"


@interface Utils : NSObject

+ (void) eliminateEmptyKeysInDict: (NSMutableDictionary*) dict;
+ (CGRect) getCellCoordinates: (CollectionViewCell*) cell fromCollectionView: (UICollectionView*) collectionView;
+ (UIColor*) getRandomColor;

+ (int) getHighestKeyInDict: (NSMutableDictionary*) dict;
+ (void) scrollToLastElement: (UICollectionView*) collectionView ofDictionary: (NSMutableDictionary*) dict;


+ (CollectionViewCell*) getTargetCell:(MoveableView*)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer*)recognizer;

+ (void)bringMoveableViewToFront:(UIPanGestureRecognizer *)recognizer moveableView:(MoveableView *)moveableView overCollectionView:(UICollectionView*) collectionView;

+ (CGRect)getCellFrame:(MoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer;

+ (NSArray*) getInsertCells:(MoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer*)recognizer;

+ (CGPoint) getCenteredTapLocation:(MoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer;

@end
