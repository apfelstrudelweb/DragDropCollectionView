//
//  UndoButtonHelper.h
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 10.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArrasoltaUndoButtonHelper : NSObject

+ (ArrasoltaUndoButtonHelper*) sharedInstance;

- (void) initWithUndoButton: (UIButton*) button;
- (void) initWithRedoButton: (UIButton*) button;
- (void) initWithResetButton: (UIButton*) button;
- (void) initWithInfoLabel: (UILabel*) label;

- (void) updateHistoryBeforeAction;
- (void) updateHistoryAfterAction;

- (void) setSourceDictionary: (NSMutableDictionary*) dict;
- (void) setTargetDictionary: (NSMutableDictionary*) dict;

- (void) decrementCounter;



@end
