//
//  MainBasicView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainBasicView : UIView

@property (strong, nonatomic) UILabel *headline1;
@property (strong, nonatomic) UILabel *headline2;

@property (strong, nonatomic) UIStepper* stepper;

@property (strong, nonatomic) DragCollectionView *dragCollectionView;
@property (strong, nonatomic) DropCollectionView *dropCollectionView;

@property (strong, nonatomic) NSDictionary *viewsDictionary;

@property (nonatomic) float cellWidthHeight;
@property (nonatomic) float itemSpacing;
@property (nonatomic) int numberOfColumns;

@property (nonatomic) int numberOfDragItems;
@property (nonatomic) int numberOfDropItems;


@property (strong, nonatomic) NSMutableDictionary* targetCellsDict;



- (void)setupConstraints;
- (void) calculateCellSize;

@end
