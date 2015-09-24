//
//  DragDropConfig.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DragDropConfig : NSObject

+ (id)sharedConfig;

@property (nonatomic) float itemSpacing;
@property (nonatomic, strong) UIColor* backgroundColorSourceView;
@property (nonatomic, strong) UIColor* backgroundColorTargetView;

@property (nonatomic, strong) NSMutableDictionary* dataSourceDict;

@end
