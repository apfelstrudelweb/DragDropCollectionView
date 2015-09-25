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

@property (nonatomic) float cItemSpacing;
@property (nonatomic, strong) UIColor* cBackgroundColorSourceView;
@property (nonatomic, strong) UIColor* cBackgroundColorTargetView;

@property (nonatomic, strong) NSMutableDictionary* cDataSourceDict;

@end
