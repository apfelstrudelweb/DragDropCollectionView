//
//  MainView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


@interface MainView : MainBasicView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>


@property bool isTranslation;

@end
