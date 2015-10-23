//
//  MainBasicView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

// from framework
#import "PublicAPI.h"
#import "ButtonView.h"


@interface MainBasicView : UIView

@property (strong, nonatomic) UILabel *headline1;
@property (strong, nonatomic) UILabel *headline2;
@property (strong, nonatomic) ButtonView *btnView;

@property (strong, nonatomic) DragCollectionView *dragCollectionView;
@property (strong, nonatomic) DropCollectionView *dropCollectionView;

@property (strong, nonatomic) NSDictionary *viewsDictionary;

@property (nonatomic) CGSize dragCollectionViewSize;
@property (nonatomic) CGSize cellSize;

@property (nonatomic) int numberOfColumns;

@property (nonatomic) int numberOfDragItems;
@property (nonatomic) int numberOfDropItems;


@property (strong, nonatomic) NSMutableDictionary* sourceCellsDict;
@property (strong, nonatomic) NSMutableDictionary* targetCellsDict;


- (void)setupConstraints;


@end
