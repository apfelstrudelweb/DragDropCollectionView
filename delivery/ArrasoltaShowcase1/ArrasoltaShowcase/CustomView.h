//
//  ConcreteCustomView.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 07.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface CustomView : ArrasoltaCustomView

// these members will be called later by introspection and must not be bound to layout constraints!
@property (strong, nonatomic) NSString* labelText;
@property (strong, nonatomic) NSString* imageName;
@property (strong, nonatomic) UIColor*  labelColor;
@property (strong, nonatomic) UIColor*  backgroundColorOfView;

@end
