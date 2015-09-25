//
//  CellModel.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CellModel : NSObject

@property (nonatomic, strong) DragView* view;

@property (nonatomic, strong) NSString* labelTitle;
@property (nonatomic, strong) UIColor* color;
@property (nonatomic, strong) UIImageView* imageView;

- (void) populateWithDragView: (DragView*) view;

@end
