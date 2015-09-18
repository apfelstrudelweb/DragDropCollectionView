//
//  MainView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


@interface MainView : UIView  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (strong, nonatomic) UILabel *headline1;
@property (strong, nonatomic) UILabel *headline2;

@property (strong, nonatomic) UICollectionView *collectionView1;
@property (strong, nonatomic) UICollectionView *collectionView2;

@property (strong, nonatomic) NSDictionary *viewsDictionary;


@end
