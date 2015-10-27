//
//  DragCollectionView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrasoltaDropView.h"
#import "ArrasoltaDragCollectionView.h"
#import "ArrasoltaCollectionViewCell.h"
#import "ArrasoltaCollectionView.h"


@interface ArrasoltaDragCollectionView : ArrasoltaCollectionView

- (instancetype)initWithFrame:(CGRect)frame withinView: (UIView*) view;

- (ArrasoltaCollectionViewCell*) getCell: (NSIndexPath*) indexPath;


@end
