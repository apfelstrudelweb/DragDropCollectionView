//
//  DropCollectionView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrasoltaCollectionViewCell.h"
#import "ArrasoltaCollectionView.h"

@interface ArrasoltaDropCollectionView : ArrasoltaCollectionView

- (instancetype)initWithFrame:(CGRect)frame withinView: (UIView*) view sourceDictionary:(NSMutableDictionary*) sourceDict targetDictionary:(NSMutableDictionary*) targetDict;

- (ArrasoltaCollectionViewCell*) getCell: (NSIndexPath*) indexPath;

- (void) resetAllCells;

@end
