//
//  MainView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UICollectionViewCell+cat.h"
#import "CollectionViewCell.h"
#import "DragView.h"
#import "CellModel.h"
#import "LayoutManager.h"

#define SHARED_MANAGER     [LayoutManager sharedManager]

@interface MainView : UIView  <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property UICollectionView *collectionView1;
@property UICollectionView *collectionView2;


@end
