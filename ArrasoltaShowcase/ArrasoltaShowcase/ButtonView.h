//
//  ButtonView.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 23.10.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ButtonView : UIView

@property (strong, nonatomic) UIButton *undoButton;
@property (strong, nonatomic) UIButton *redoButton;
@property (strong, nonatomic) UIButton *resetButton;
@property (strong, nonatomic) UILabel *infoLabel;

@property (strong, nonatomic) NSDictionary *viewsDictionary;

@end
