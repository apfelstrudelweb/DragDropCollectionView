//
//  PublicAPI.h
//
//  Include this API into all files of your projects,
//  as for example into your View Controller and into
//  all views which need ArraSolta functionalities.
//
//  Created by Ulrich Vormbrock on 08.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "ArrasoltaUndoButtonHelper.h"
#import "ArrasoltaConfig.h"
#import "ArrasoltaDragCollectionView.h"
#import "ArrasoltaDropCollectionView.h"
#import "ArrasoltaUtils.h"
#import "ArrasoltaDragDropHelper.h"
#import "ArrasoltaCustomView.h"

// Macros - it's recommended that you use these macros
#define SHARED_STATE_INSTANCE      [ArrasoltaCurrentState sharedInstance]
#define SHARED_CONFIG_INSTANCE     [ArrasoltaConfig sharedInstance]
#define SHARED_BUTTON_INSTANCE     [ArrasoltaUndoButtonHelper sharedInstance]

@interface ArrasoltaAPI : NSObject

@end