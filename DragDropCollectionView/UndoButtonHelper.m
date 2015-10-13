//
//  UndoButtonHelper.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 10.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "UndoButtonHelper.h"
#import "CurrentState.h"
#import "ConfigAPI.h"


#define SHARED_STATE_INSTANCE      [CurrentState sharedInstance]
#define SHARED_CONFIG_INSTANCE     [ConfigAPI sharedInstance]

#define ALPHA_OFF 0.25

@interface UndoButtonHelper() {
    
    NSMutableDictionary* sourceDictionary;
    NSMutableDictionary* targetDictionary;
    
    UIButton* undoButton;
    NSMutableArray* historyArray;
}
@end

@implementation UndoButtonHelper

+ (UndoButtonHelper*)sharedInstance {
    
    static UndoButtonHelper *_sharedInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[UndoButtonHelper alloc] init];
    });
    return _sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        historyArray = [NSMutableArray new];
    }
    return self;
}

- (void) initWithButton: (UIButton*) button {
    
    undoButton = button;
    [undoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    undoButton.alpha = ALPHA_OFF;

}

- (void) setSourceDictionary: (NSMutableDictionary*) dict {
    sourceDictionary = dict;
}

- (void) setTargetDictionary: (NSMutableDictionary*) dict {
    targetDictionary = dict;
}

- (void) addViewToHistory: (DragView*) dragView andDropView: (DropView*) dropView {
    [historyArray addObject:@[dragView, dropView]];
    undoButton.alpha = 1.0;
}

- (void) removeViewFromHistory: (DragView*) dragView andDropView: (DropView*) dropView {
    [historyArray removeObject:@[dragView, dropView]];
    // set explicity for cell deletion
    undoButton.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
}

#pragma mark -UIButton touched
-(void) undoAction:(UIButton*)sender {

    if (!historyArray || historyArray.count==0) return; // nothing to do
    
    DragView* lastDragView = [historyArray lastObject][0];
    DropView* lastDropView = [historyArray lastObject][1];
    
    [SHARED_STATE_INSTANCE removeConsumedItem:lastDragView];
    [historyArray removeLastObject];
    
    undoButton.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;

    
    [targetDictionary removeObjectForKey:[NSNumber numberWithInt:lastDropView.index]];
    
    if ([SHARED_CONFIG_INSTANCE isSourceItemConsumable]) {
        [sourceDictionary setObject:lastDragView forKey:[NSNumber numberWithInt:lastDragView.index]];
    }

    
    // inform source collection view about change - reload needed
    [[NSNotificationCenter defaultCenter] postNotificationName: @"restoreElementNotification" object:nil userInfo:nil];
}

@end
