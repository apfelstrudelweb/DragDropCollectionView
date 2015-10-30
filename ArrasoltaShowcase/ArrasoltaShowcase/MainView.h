//
//  MainView.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//
#import "ButtonView.h"


@interface MainView : UIView

@property (strong, nonatomic) UILabel *headline;
@property (strong, nonatomic) ButtonView *btnView;

@property (strong, nonatomic) ArrasoltaDragCollectionView *dragCollectionView;
@property (strong, nonatomic) ArrasoltaDropCollectionView *dropCollectionView;

@property (strong, nonatomic) NSDictionary *viewsDictionary;

@property (nonatomic) CGSize dragCollectionViewSize;
@property (nonatomic) CGSize cellSize;

@property (nonatomic) int numberOfColumns;

@property (nonatomic) int numberOfDragItems;
@property (nonatomic) int numberOfDropItems;


@property (strong, nonatomic) NSMutableDictionary* sourceDict;
@property (strong, nonatomic) NSMutableDictionary* targetDict;

@property bool isTranslation;

@end
