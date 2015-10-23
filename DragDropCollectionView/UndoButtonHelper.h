//
//  UndoButtonHelper.h
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 10.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DragView.h"
#import "DropView.h"
#import "History.h"

@interface UndoButtonHelper : NSObject

+ (UndoButtonHelper*) sharedInstance;

- (void) initWithButton: (UIButton*) button;
- (void) initWithInfoLabel: (UILabel*) label;

- (void) updateHistory: (History*) hist;

- (void) setSourceDictionary: (NSMutableDictionary*) dict;
- (void) setTargetDictionary: (NSMutableDictionary*) dict;



@end
