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

- (void) reset;
- (void) setLabel:(NSString *)value;
- (void) setColor: (UIColor*) color;

- (NSString*) getLabelTitel;

@end
