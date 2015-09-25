//
//  DragView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragView.h"

@implementation DragView


-(void)setLabelTitle:(NSString *)text {

    self.cellLabel = [[UILabel alloc] init];
    [self.cellLabel setTextForDragDropElement:text];
    
    [self.cellLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    [self addSubview:self.cellLabel];
    
    
//    self.imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dummy.png"]];
//    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self addSubview:self.imageView];
    
    [self setupConstraints:self.cellLabel];
}

- (NSString*) getLabelTitel {
    return self.cellLabel.text;
}

- (void) setColor: (UIColor*) color {
    self.backgroundColor = color;
}


- (DragView*) supplyNewDragView: (UICollectionView*) collectionView {
    
    DragView *newDragView = [DragView new];
    newDragView.frame = self.frame;
    newDragView.backgroundColor = self.backgroundColor;
    [newDragView setLabelTitle:[self getLabelTitel]];
    
    [collectionView.superview addSubview:newDragView];
    
//    NSArray* recognizers = [self gestureRecognizers];
//    
//    for (UIGestureRecognizer* recognizer in recognizers) {
//        if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
//            [self removeGestureRecognizer:recognizer];
//            
//        }
//    }
    
    return newDragView;
}

//#pragma mark -UIPanGestureRecognizer
//- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
//    
//    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:recognizer forKey:@"recognizer"];
//    [[NSNotificationCenter defaultCenter] postNotificationName: @"dragCellNotification" object:nil userInfo:userInfo];
//}


#pragma mark -constraint issues

- (void)setupConstraints: (UILabel*) label {
    
    // Width constraint
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];
    
    // Height constraint
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0]];
    
    // Center horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:label
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    [super updateConstraints];
}


@end
