//
//  MainView.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//
#import "ButtonView.h"


@interface MainView : UIView

/**
 *  Simple GUI elements
 **/
@property (strong, nonatomic) UILabel    *labelHeadline;
@property (strong, nonatomic) ButtonView *undoButtonView;

/**
 *  Collection Views
 **/
@property (strong, nonatomic) ArrasoltaDragCollectionView *sourceCollectionView;
@property (strong, nonatomic) ArrasoltaDropCollectionView *targetCollectionView;
@property (nonatomic) CGSize sourceCollectionViewSize;
@property (nonatomic) CGSize singleCellSize;

/**
 *  Dictionaries (populating the collection views)
 **/
@property (strong, nonatomic) NSMutableDictionary *sourceItemsDictionary;
@property (strong, nonatomic) NSMutableDictionary *targetItemsDictionary;
// number of items as result of number of elements in dictionaries
@property (nonatomic) int numberOfSourceItems;
@property (nonatomic) int numberOfTargetItems;

/**
 *  Dictionary of subviews (for auto layout issues)
 **/
@property (strong, nonatomic) NSDictionary *subviewsDictionaryForAutoLayout;


@end
