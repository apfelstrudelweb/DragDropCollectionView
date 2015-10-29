//
//  UndoButtonHelper.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 10.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaUndoButtonHelper.h"
#import "NSMutableDictionary+arrasolta.h"
#import "NSMutableArray+arrasolta.h"
#import "ArrasoltaAPI.h"


#define ALPHA_OFF 0.25

@interface ArrasoltaUndoButtonHelper() {
    
    NSMutableDictionary* originalSourceDictionary;
    
    NSMutableDictionary* sourceDictionary;
    NSMutableDictionary* targetDictionary;
    
    // GUI elements
    UIButton* undoButton;
    UIButton* redoButton;
    UIButton* resetButton;
    UILabel* infoLabel;
    
    int capacity;
    NSMutableArray* historyBeforeActionArray;
    NSMutableArray* historyAfterActionArray;
    
    NSArray* initialArray;
    NSMutableArray* redoArray;
    
    int counter;
}
@end

@implementation ArrasoltaUndoButtonHelper

+ (ArrasoltaUndoButtonHelper*)sharedInstance {
    
    static ArrasoltaUndoButtonHelper *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ArrasoltaUndoButtonHelper alloc] init];
    });
    return _sharedInstance;
}


#pragma mark -initialization
- (instancetype)init {
    self = [super init];
    if (self) {
        historyBeforeActionArray = [NSMutableArray new];
        historyAfterActionArray = [NSMutableArray new];
        redoArray = [NSMutableArray new];
    }
    return self;
}

- (void) initWithUndoButton: (UIButton*) button {
    
    undoButton = button;
    [undoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    undoButton.alpha = ALPHA_OFF;
}

- (void) initWithRedoButton: (UIButton*) button {
    
    redoButton = button;
    [redoButton addTarget:self action:@selector(redoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    redoButton.alpha = ALPHA_OFF;
}

- (void) initWithResetButton: (UIButton*) button {
    
    resetButton = button;
    [resetButton addTarget:self action:@selector(resetAction:) forControlEvents:UIControlEventTouchUpInside];
    
    resetButton.enabled = NO;
    resetButton.alpha = ALPHA_OFF;
}

- (void) initWithInfoLabel: (UILabel*) label {
    infoLabel = label;
    infoLabel.text = [NSString stringWithFormat:@"%d", counter];
    infoLabel.alpha = ALPHA_OFF;
}

- (void) setSourceDictionary: (NSMutableDictionary*) dict {
    sourceDictionary = dict;
    originalSourceDictionary = [sourceDictionary mutableCopy];
    capacity = (int)dict.count;
}

- (void) setTargetDictionary: (NSMutableDictionary*) dict {
    targetDictionary = dict;
}


#pragma mark -history update and read
/**
 *
 *  We populate an array with snapshots of both the source, both the target collection view
 *
 **/
- (void) updateHistoryBeforeAction {
    
    NSMutableArray* snapshotSourceArray = [[NSMutableArray alloc] initWithCapacity:capacity];
    [snapshotSourceArray initWithZeroObjects:capacity];
    
    [sourceDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber* number, ArrasoltaDragView* view, BOOL *stop) {
        int sourceIndex = [number intValue];
        [snapshotSourceArray replaceObjectAtIndex:sourceIndex withObject:view];
    }];
    
    bool cellsAreConsumabe = [SHARED_CONFIG_INSTANCE areSourceItemsConsumable];
    int dropCapacity = cellsAreConsumabe ? capacity : [SHARED_CONFIG_INSTANCE getNumberOfTargetItems];
    
    
    NSMutableArray* snapshotTargetArray = [[NSMutableArray alloc] initWithCapacity:dropCapacity];
    [snapshotTargetArray initWithZeroObjects:dropCapacity];
    
    [targetDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber* number, ArrasoltaDropView* view, BOOL *stop) {
        int targetIndex = [number intValue];
        [snapshotTargetArray replaceObjectAtIndex:targetIndex withObject:view];
    }];
    
    
    [historyBeforeActionArray addObject:@[snapshotSourceArray, snapshotTargetArray]];
    
    if (counter == 0) {
        initialArray = @[snapshotSourceArray, snapshotTargetArray];
    }
    
    counter++;
    
    undoButton.alpha = 1.0;
    infoLabel.alpha = 1.0;
    infoLabel.text = [NSString stringWithFormat:@"%d", counter];
    resetButton.enabled = YES;
    resetButton.alpha = 1.0;
    
}

- (void) updateHistoryAfterAction {
    
    NSMutableArray* snapshotSourceArray = [[NSMutableArray alloc] initWithCapacity:capacity];
    [snapshotSourceArray initWithZeroObjects:capacity];
    
    [sourceDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber* number, ArrasoltaDragView* view, BOOL *stop) {
        int sourceIndex = [number intValue];
        [snapshotSourceArray replaceObjectAtIndex:sourceIndex withObject:view];
    }];
    
    bool cellsAreConsumabe = [SHARED_CONFIG_INSTANCE areSourceItemsConsumable];
    int dropCapacity = cellsAreConsumabe ? capacity : [SHARED_CONFIG_INSTANCE getNumberOfTargetItems];
    
    NSMutableArray* snapshotTargetArray = [[NSMutableArray alloc] initWithCapacity:dropCapacity];
    [snapshotTargetArray initWithZeroObjects:dropCapacity];
    
    [targetDictionary enumerateKeysAndObjectsUsingBlock:^(NSNumber* number, ArrasoltaDropView* view, BOOL *stop) {
        int targetIndex = [number intValue];
        [snapshotTargetArray replaceObjectAtIndex:targetIndex withObject:view];
    }];
    
    [historyAfterActionArray addObject:@[snapshotSourceArray, snapshotTargetArray]];

}

/**
 *
 *  We recover the previous snapshots of both the source, both the target collection view
 *
 **/
-(void) undoAction:(UIButton*)sender {
    
    if (!historyBeforeActionArray || historyBeforeActionArray.count==0) return; // nothing to do
    
    NSMutableArray* snapshotSourceArray = [historyBeforeActionArray lastObject][0];
    [sourceDictionary removeAllObjects];
    
    for (int i=0; i<snapshotSourceArray.count; i++) {
        id obj  = snapshotSourceArray[i];
        
        if(![obj isEqual:[NSNull null]]) {
            ArrasoltaDragView* dragView = obj;
            [sourceDictionary setObject:dragView forKey:@(i)];
        }
    }
    
    NSMutableArray* snapshotTargetArray = [historyBeforeActionArray lastObject][1];
    [targetDictionary removeAllObjects];
    
    for (int i=0; i<snapshotTargetArray.count; i++) {
        id obj  = snapshotTargetArray[i];
        
        if(![obj isEqual:[NSNull null]]) {
            ArrasoltaDropView* dropView = obj;
            [targetDictionary setObject:dropView forKey:@(i)];
        }
    }
    
    counter--;
    
    if (historyAfterActionArray.count > 0) {
        [redoArray addObject:[historyAfterActionArray lastObject]];
        [historyAfterActionArray removeLastObject];
    }
    
    if (historyBeforeActionArray.count > 0) {
        [historyBeforeActionArray removeLastObject];
    }
    

    undoButton.alpha = historyBeforeActionArray.count==0 ? ALPHA_OFF : 1.0;
    redoButton.alpha = 1.0;
    redoButton.enabled = YES;
    
    infoLabel.alpha = historyBeforeActionArray.count==0 ? ALPHA_OFF : 1.0;
    infoLabel.text = [NSString stringWithFormat:@"%d", counter];
    
    
    // inform source collection view about change - reload needed
    [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaRestoreElementNotification" object:nil userInfo:nil];
}


-(void) redoAction:(UIButton*)sender {
    
    if (redoArray.count == 0) return;
    
    
    NSMutableArray* snapshotSourceArray = [redoArray lastObject][0];
    [sourceDictionary removeAllObjects];
    
    for (int i=0; i<snapshotSourceArray.count; i++) {
        id obj  = snapshotSourceArray[i];
        
        if(![obj isEqual:[NSNull null]]) {
            ArrasoltaDragView* dragView = obj;
            [sourceDictionary setObject:dragView forKey:@(i)];
        }
    }
    
    NSMutableArray* snapshotTargetArray = [redoArray lastObject][1];
    [targetDictionary removeAllObjects];
    
    for (int i=0; i<snapshotTargetArray.count; i++) {
        id obj  = snapshotTargetArray[i];
        
        if(![obj isEqual:[NSNull null]]) {
            ArrasoltaDropView* dropView = obj;
            [targetDictionary setObject:dropView forKey:@(i)];
        }
    }
    
    counter++;
    
    if (historyAfterActionArray.count > 0) {
         [historyBeforeActionArray addObject:[historyAfterActionArray lastObject]];
    } else {
        
        // reset to initial state
        [historyBeforeActionArray addObject:initialArray];
    }
   
    [historyAfterActionArray addObject:[redoArray lastObject]];
    [redoArray removeLastObject];
    
    redoButton.alpha = redoArray.count==0 ? ALPHA_OFF : 1.0;
    undoButton.alpha = 1.0;
    undoButton.enabled = YES;
    
    infoLabel.alpha = redoArray.count==0 ? ALPHA_OFF : 1.0;
    infoLabel.text = [NSString stringWithFormat:@"%d", counter];
    
    // inform source collection view about change - reload needed
    [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaRestoreElementNotification" object:nil userInfo:nil];
}

- (void) decrementCounter {
    counter--;
}


#pragma mark -UIButton touched
-(void) resetAction:(UIButton*)sender {
    
    [historyBeforeActionArray removeAllObjects];
    [historyAfterActionArray removeAllObjects];
    [redoArray removeAllObjects];
    counter = 0;
    
    undoButton.alpha = ALPHA_OFF;
    infoLabel.alpha = ALPHA_OFF;
    infoLabel.text = [NSString stringWithFormat:@"%d", counter];
    resetButton.enabled = NO;
    resetButton.alpha = ALPHA_OFF;
    //redoButton.enabled = NO;
    redoButton.alpha = ALPHA_OFF;
    
    [targetDictionary removeAllObjects];
    [originalSourceDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        sourceDictionary[key] = object;
    }];
    
    // inform source collection view about change - reload needed
    [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaRestoreElementNotification" object:nil userInfo:nil];
}

@end
