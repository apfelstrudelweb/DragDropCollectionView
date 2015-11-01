//
//  Utils.h
//
//  Utilities for Collection View  and Dictionary handling
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


#import "NSMutableDictionary+arrasolta.h"
#import "ArrasoltaSourceCollectionView.h"
#import "ArrasoltaTargetCollectionView.h"
#import "ArrasoltaDraggableView.h"


@interface ArrasoltaUtils : NSObject

+ (void) eliminateEmptyKeysInDict: (NSMutableDictionary*) dict;
+ (CGRect) getCellCoordinates: (ArrasoltaTargetCollectionViewCell*) cell fromCollectionView: (UICollectionView*) collectionView;
+ (UIColor*) getRandomColor;

+ (int) getHighestKeyInDict: (NSMutableDictionary*) dict;
+ (void) scrollToLastElement: (UICollectionView*) collectionView ofDictionary: (NSMutableDictionary*) dict;


+ (ArrasoltaTargetCollectionViewCell*) getTargetCell:(ArrasoltaMoveableView*)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer*)recognizer;

+ (void) bringMoveableViewToFront:(UIPanGestureRecognizer *)recognizer moveableView:(ArrasoltaMoveableView *)moveableView overCollectionView:(UICollectionView*) collectionView;

+ (CGRect) getCellFrame:(ArrasoltaMoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer;

+ (NSArray*) getInsertCells:(ArrasoltaMoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer*)recognizer;

+ (CGPoint) getCenteredTapLocation:(ArrasoltaMoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer;

+ (bool) size:(CGSize)smallerSize isSmallerThanOrEqualToSize:(CGSize)largerSize;

+ (ArrasoltaCollectionViewCell*) getCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath cellDictionaries:(NSArray*) cellDictionaries;

@end
