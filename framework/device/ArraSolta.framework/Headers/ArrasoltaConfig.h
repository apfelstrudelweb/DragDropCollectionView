//
//  DragDropConfig.h
//
//  Singleton which stores all configurations made in the View Controller.
//  The configurations are maintained within the entire session.
//
//  Created by Ulrich Vormbrock on 24.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//


#import "ArrasoltaPersistencyManager.h"

@interface ArrasoltaConfig : NSObject


+ (ArrasoltaConfig*) sharedInstance;

@property (NS_NONATOMIC_IOSONLY, getter=getFixedCellSize) CGSize fixedCellSize;
@property (NS_NONATOMIC_IOSONLY, getter=getCellWidthHeightRatio) float cellWidthHeightRatio;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldCollectionViewBeCenteredVertically) bool shouldCollectionViewBeCenteredVertically;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldCollectionViewFillEntireHeight) bool shouldCollectionViewFillEntireHeight;
@property (NS_NONATOMIC_IOSONLY, getter=getMinInteritemSpacing) float minInteritemSpacing;
@property (NS_NONATOMIC_IOSONLY, getter=getMinLineSpacing) float minLineSpacing;
@property (NS_NONATOMIC_IOSONLY, getter=getBackgroundColorSourceView, copy) UIColor *backgroundColorSourceView;
@property (NS_NONATOMIC_IOSONLY, getter=getBackgroundColorTargetView, copy) UIColor *backgroundColorTargetView;
@property (NS_NONATOMIC_IOSONLY, getter=getSourceItemsDictionary, copy) NSMutableDictionary *sourceItemsDictionary;
@property (NS_NONATOMIC_IOSONLY, getter=getSourcePlaceholderColor, copy) UIColor *sourcePlaceholderColor;
@property (NS_NONATOMIC_IOSONLY, getter=getTargetPlaceholderColorUntouched, copy) UIColor *targetPlaceholderColorUntouched;
@property (NS_NONATOMIC_IOSONLY, getter=getTargetPlaceholderColorTouched, copy) UIColor *targetPlaceholderColorTouched;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldPlaceholderIndexStartFromZero) bool shouldPlaceholderIndexStartFromZero;
@property (NS_NONATOMIC_IOSONLY, getter=getPlaceholderTextColor, copy) UIColor *placeholderTextColor;
@property (NS_NONATOMIC_IOSONLY, getter=getPreferredFontName, copy) NSString *preferredFontName;
@property (NS_NONATOMIC_IOSONLY, getter=getPlaceholderFontSize) float placeholderFontSize;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldSourcePlaceholderDisplayIndex) bool shouldSourcePlaceholderDisplayIndex;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldTargetPlaceholderDisplayIndex) bool shouldTargetPlaceholderDisplayIndex;
@property (NS_NONATOMIC_IOSONLY, getter=getNumberOfTargetItems) int numberOfTargetItems;
@property (NS_NONATOMIC_IOSONLY, getter=areSourceItemsConsumable) bool sourceItemsConsumable;
@property (NS_NONATOMIC_IOSONLY, getter=getScrollDirection) NSInteger scrollDirection;
@property (NS_NONATOMIC_IOSONLY, getter=getLongPressDurationBeforeDragging) float longPressDurationBeforeDragging;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldCellOrderBeHorizontal) bool shouldCellOrderBeHorizontal;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldPanningBeEnabled) bool shouldPanningBeEnabled;
@property (NS_NONATOMIC_IOSONLY, getter=getShouldPanningBeCoupled) bool shouldPanningBeCoupled;

@end
