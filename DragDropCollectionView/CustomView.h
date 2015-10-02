//
//  CustomView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 01.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomView : UIView

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSDictionary *viewsDictionary;

- (void) setLabelText: (NSString*) text;
- (void) setImageName: (NSString*) name;

- (void) setLabelColor: (UIColor*) color;
- (void) setBackgroundColorOfView: (UIColor*) color;


- (NSString*) getLabelText;
- (NSString*) getImageName;

- (UIColor*) getLabelColor;
- (UIColor*) getBackgroundColorOfView;

- (void) setupConstraints;

@end
