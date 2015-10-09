//
//  CustomView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 01.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomView : UIView

@property (nonatomic) bool viewIsInDragState;
@property (nonatomic) NSString* concreteClassName;

@end
