//
//  DragCollectionView.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


#import "ArrasoltaDroppableView.h"
#import "ArrasoltaCollectionView.h"
#import "ArrasoltaSourceCollectionViewCell.h"

@interface ArrasoltaSourceCollectionView : ArrasoltaCollectionView

- (instancetype)initWithFrame:(CGRect)frame withinView: (UIView*) view;

- (ArrasoltaSourceCollectionViewCell*) getCell: (NSIndexPath*) indexPath;


@end
