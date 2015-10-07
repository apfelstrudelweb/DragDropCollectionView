//
//  CustomView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 01.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CurrentState.h"

@interface CustomView : UIView

// these members will be called later by introspection and must not be bound to layout constraints!
@property (strong, nonatomic) NSString* labelText;
@property (strong, nonatomic) NSString* imageName;
@property (strong, nonatomic) UIColor*  labelColor;
@property (strong, nonatomic) UIColor*  backgroundColorOfView;

@end
