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
#import "ViewConverter.h"
#import "NSMutableDictionary+cat.h"


#define SHARED_STATE_INSTANCE      [CurrentState sharedInstance]
#define SHARED_CONFIG_INSTANCE     [ConfigAPI sharedInstance]
#define SHARED_CONVERTER_INSTANCE  [ViewConverter sharedInstance]

#define ALPHA_OFF 0.25

@interface UndoButtonHelper() {
    
    NSMutableDictionary* sourceDictionary;
    NSMutableDictionary* targetDictionary;
    
    UIButton* undoButton;
    UILabel* infoLabel;
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

- (instancetype)init {
    self = [super init];
    if (self) {
        historyArray = [NSMutableArray new];
    }
    return self;
}

// simply add new history object to stack
- (void) updateHistory: (History*) hist {
    undoButton.alpha = 1.0;
    infoLabel.alpha = 1.0;
    [historyArray addObject:hist];
    infoLabel.text = [NSString stringWithFormat:@"%d", (int)historyArray.count];
}

- (void) initWithButton: (UIButton*) button {
    
    undoButton = button;
    [undoButton addTarget:self action:@selector(undoAction:) forControlEvents:UIControlEventTouchUpInside];
    
    undoButton.alpha = ALPHA_OFF;
    
}

- (void) initWithInfoLabel: (UILabel*) label {
    infoLabel = label;
    infoLabel.text = 0;
    infoLabel.alpha = ALPHA_OFF;
}

- (void) setSourceDictionary: (NSMutableDictionary*) dict {
    sourceDictionary = dict;
}

- (void) setTargetDictionary: (NSMutableDictionary*) dict {
    targetDictionary = dict;
}



#pragma mark -UIButton touched
-(void) undoAction:(UIButton*)sender {
    
    if (!historyArray || historyArray.count==0) return; // nothing to do
    
    History* lastHist = [historyArray lastObject];
    
    if (lastHist.emptyCellHasBeenDeleted) {
        // insert empty cell again and shift all elements starting frokm index one place to right
        [targetDictionary shiftAllElementsToRightFromIndex:lastHist.index];
        
    } else if (lastHist.elementHasBeenDroppedOut) {
        // when collection view is full, last element has dropped back to source collection view

        
        // 1. remove inserted element
        DropView* dropView = [targetDictionary objectForKey:@(lastHist.index)];
        DragView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:dropView];
        
        // update dictionaries
        [targetDictionary removeObjectForKey:@(lastHist.index)];
        [sourceDictionary setObject:dragView forKey:@(dropView.previousDragViewIndex)];
        
        // 2. shift elements between insertion index and last index to left
        [targetDictionary shiftAllElementsToLeftFromIndex:lastHist.index];
        
        // 3. recover dropped element and bring it back to the last place of target collection view
        dragView = [sourceDictionary objectForKey:@(lastHist.previousIndex)];
        dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:dragView widthIndex:lastHist.deletionIndex];
        
        // update dictionaries
        [sourceDictionary removeObjectForKey:@(lastHist.previousIndex)];
        [targetDictionary setObject:dropView forKey:@(lastHist.deletionIndex)];

        // skip next step as it has been handeled at once here
        [historyArray removeLastObject];
        
    } else if (lastHist.elementHasBeenReplaced) {
        
        // we need 2 transactions at once:
        
        // 1. reverse "targetCellsDict addMoveableView"
        // -> get occupant view back to original position
        DropView* dropView = [targetDictionary objectForKey:@(lastHist.index)];
        
        if (lastHist.elementComesFromTop) {
            DragView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:dropView];
            
            // update dictionaries
            [targetDictionary removeObjectForKey:@(lastHist.index)];
            [sourceDictionary setObject:dragView forKey:@(dropView.previousDragViewIndex)];
        } else {
            //[dropView move:targetDictionary toIndex:dropView.previousDropViewIndex];
            [dropView move:targetDictionary toIndex:lastHist.previousIndex];
        }
        
        
        // 2. reverse "bringUnderlyingElementBackToOrigin"
        // -> get replaced source view back to target view
        [historyArray removeLastObject];
        History* lastHist2 = [historyArray lastObject];
        int dropIndex = lastHist.index; //lastHist2.previousIndex;
        
        DragView* dragView = [sourceDictionary objectForKey:@(lastHist2.previousIndex)];
        dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:dragView widthIndex:dropIndex];
        
        // update dictionaries
        [sourceDictionary removeObjectForKey:@(lastHist2.previousIndex)];
        [targetDictionary setObject:dropView forKey:@(dropIndex)];
        
    } else if (lastHist.elementHasBeenDeleted) {
        
        int dropIndex = lastHist.deletionIndex;
        
        DragView* dragView = [sourceDictionary objectForKey:@(lastHist.previousIndex)];
        DropView* dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:dragView widthIndex:dropIndex];
        
        // update dictionaries
        [sourceDictionary removeObjectForKey:@(lastHist.previousIndex)];
        [targetDictionary setObject:dropView forKey:@(dropIndex)];
        
        
    } else {
        
        DropView* dropView = [targetDictionary objectForKey:@(lastHist.index)];
        
        if (lastHist.elementComesFromTop) {
            DragView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:dropView];
            
            // update dictionaries
            [targetDictionary removeObjectForKey:@(lastHist.index)];
            [sourceDictionary setObject:dragView forKey:@(dragView.index)];
            
            if (lastHist.elementHasBeenInserted) {
                // handle the right-hand elements which have been shifted
                [targetDictionary shiftAllElementsToLeftFromIndex:lastHist.index];
            }
            
        } else {
            
            if (lastHist.elementHasBeenInserted) {
                // make sure we don't use the previous index from the GUI
                dropView.previousDropViewIndex = lastHist.previousIndex;
                // flip back the inserted element
                [targetDictionary flipBackElementAtIndex:lastHist.index];
            } else {
                [dropView move:targetDictionary toIndex:lastHist.previousIndex];
                
            }
        }
    }
    
    [historyArray removeLastObject];
    
    undoButton.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
    infoLabel.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
    infoLabel.text = [NSString stringWithFormat:@"%d", (int)historyArray.count];
    
    // inform source collection view about change - reload needed
    [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaRestoreElementNotification" object:nil userInfo:nil];
}


@end
