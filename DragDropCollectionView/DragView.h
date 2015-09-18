//
//  DragView.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragView : UIView

@property (nonatomic, strong) UILabel* cellLabel;

- (void) setLabelTitle:(NSString *)value;
- (NSString*) getLabelTitel;

- (void) setColor: (UIColor*) color;

@end
