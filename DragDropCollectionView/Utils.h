//
//  Utils.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


@interface Utils : NSObject

+ (void) eliminateEmptyKeysInDict: (NSMutableDictionary*) dict;
+ (CGRect) getCellCoordinates: (CollectionViewCell*) cell fromCollectionView: (UICollectionView*) collectionView;
+ (UIColor*) getRandomColor;

+ (int) getHighestKeyInDict: (NSMutableDictionary*) dict;
+ (void) scrollToLastElement: (UICollectionView*) collectionView ofDictionary: (NSMutableDictionary*) dict;


+ (CollectionViewCell*) getTargetCell:(DragView*)dragView inCollectionView:(DropCollectionView*) collectionView recognizer:(UIPanGestureRecognizer*)recognizer;

+ (NSArray*) getInsertCells:(DragView *)dragView inCollectionView:(DropCollectionView*) collectionView recognizer:(UIPanGestureRecognizer*)recognizer;

+ (CGPoint) getCenteredTapLocation:(DragView *)dragView inCollectionView:(DropCollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer;

@end
