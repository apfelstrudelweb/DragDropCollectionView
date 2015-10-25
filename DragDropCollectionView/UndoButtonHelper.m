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
    
    NSMutableDictionary* originalSourceDictionary;
    
    NSMutableDictionary* sourceDictionary;
    NSMutableDictionary* targetDictionary;
    
    // GUI elements
    UIButton* undoButton;
    UIButton* redoButton;
    UIButton* resetButton;
    UILabel* infoLabel;
    
    
    NSMutableArray* historyArray;
    NSMutableArray* undoArray;
    
    int counter;
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
        undoArray = [NSMutableArray new];
    }
    return self;
}

// simply add new history object to stack
- (void) updateHistory: (History*) hist incrementCounter: (bool) flag {
    
    if (hist.emptyCellHasBeenDeleted && targetDictionary.count == 0) {
        return;
    }
    
    undoButton.alpha = 1.0;
    infoLabel.alpha = 1.0;
    [historyArray addObject:hist];
    if (flag) {
        counter++;
    }
    infoLabel.text = [NSString stringWithFormat:@"%d", counter];
    resetButton.enabled = YES;
    resetButton.alpha = 1.0;
    
    // avoid conflicts with undo and updated history
    [undoArray removeAllObjects];
    redoButton.alpha = ALPHA_OFF;
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
}

- (void) setTargetDictionary: (NSMutableDictionary*) dict {
    targetDictionary = dict;
}



#pragma mark -UIButton touched
-(void) resetAction:(UIButton*)sender {
    
    [historyArray removeAllObjects];
    [undoArray removeAllObjects];
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

-(void) redoAction:(UIButton*)sender {
    
    History* undoHist = [undoArray lastObject];
    if (!undoHist) return;
    
    bool elementHasBeenReplaced = false;
    History* prevUndoHist;
    
    if (undoArray.count > 1) {
        prevUndoHist = [undoArray objectAtIndex:undoArray.count-2];
        elementHasBeenReplaced = prevUndoHist.elementHasBeenReplaced;
    }


    if (undoHist.elementHasBeenInserted) {
        
        int index = undoHist.index;
        DropView* dropView = [targetDictionary objectForKey:@(index)];

        int backFromSourceIndex = undoHist.previousIndex; // dragView
        
        if (undoHist.elementComesFromTop) {
            
            [targetDictionary shiftAllElementsToRightFromIndex:index];
            
            DragView* dragView = [sourceDictionary objectForKey:@(backFromSourceIndex)];
            dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:dragView widthIndex:index];
            
            // update dictionaries
            [sourceDictionary removeObjectForKey:@(backFromSourceIndex)];
            [targetDictionary setObject:dropView forKey:@(index)];
        } else {
            
            [targetDictionary shiftAllElementsToRightFromIndex:index];
            
            if (undoHist.index < undoHist.previousIndex) {
                dropView = [targetDictionary objectForKey:@(backFromSourceIndex+1)]; // +1 because it has been shifted with all other elements
            } else {
                dropView = [targetDictionary objectForKey:@(backFromSourceIndex)];
            }
            
            [dropView move:targetDictionary toIndex:index];
 
        }

        
    } else if (elementHasBeenReplaced) {

        int index = prevUndoHist.index;
        int backToSourceIndex = undoHist.previousIndex;  // dropView
        int backFromSourceIndex = prevUndoHist.previousIndex; // dragView
        
        // 1. bring back drop view to source
        DropView* dropView = [targetDictionary objectForKey:@(index)];
        DragView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:dropView];
        
        [targetDictionary removeObjectForKey:@(index)];
        [sourceDictionary setObject:dragView forKey:@(backToSourceIndex)];
        
        // 2. bring back drag view to target
        dragView = [sourceDictionary objectForKey:@(backFromSourceIndex)];
        dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:dragView widthIndex:index];
        
        // update dictionaries
        [sourceDictionary removeObjectForKey:@(backFromSourceIndex)];
        [targetDictionary setObject:dropView forKey:@(index)];
        
        [undoArray removeLastObject];
        [undoArray removeLastObject];
        [historyArray addObject:undoHist];
        [historyArray addObject:prevUndoHist];
        counter++;
        
        // inform source collection view about change - reload needed
        [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaRestoreElementNotification" object:nil userInfo:nil];
        
        return;
        
    } else if (undoHist.elementHasBeenDeleted) {
        
        DropView* dropView = [targetDictionary objectForKey:@(undoHist.deletionIndex)];
        DragView* dragView = [SHARED_CONVERTER_INSTANCE convertToDragView:dropView];
        
        [targetDictionary removeObjectForKey:@(undoHist.deletionIndex)];
        [sourceDictionary setObject:dragView forKey:@(undoHist.previousIndex)];
        
    } else if (undoHist.elementComesFromTop) {
        DragView* dragView = [sourceDictionary objectForKey:@(undoHist.previousIndex)];
        DropView* dropView = [SHARED_CONVERTER_INSTANCE convertToDropView:dragView widthIndex:undoHist.index];
        
        // update dictionaries
        [sourceDictionary removeObjectForKey:@(undoHist.previousIndex)];
        [targetDictionary setObject:dropView forKey:@(undoHist.index)];
        
    } else {
        
        DropView* dropView = [targetDictionary objectForKey:@(undoHist.previousIndex)];
        [dropView move:targetDictionary toIndex:undoHist.index];
    }
    
    [undoArray removeLastObject];
    [historyArray addObject:undoHist];
    counter++;
    
    undoButton.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
    redoButton.alpha = undoArray.count ==0 ? ALPHA_OFF : 1.0;
    infoLabel.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
    infoLabel.text = [NSString stringWithFormat:@"%d", counter];
    resetButton.enabled = historyArray.count==0 ? NO : YES;
    resetButton.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
    
    // inform source collection view about change - reload needed
    [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaRestoreElementNotification" object:nil userInfo:nil];
}

-(void) undoAction:(UIButton*)sender {
    
    if (!historyArray || historyArray.count==0) return; // nothing to do
    
    History* lastHist = [historyArray lastObject];
    
    counter--;
    
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
        [undoArray addObject:[historyArray lastObject]];
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
            [sourceDictionary setObject:dragView forKey:@(lastHist.previousIndex)];
            //[sourceDictionary setObject:dragView forKey:@(dropView.previousDragViewIndex)];
        } else {
            //[dropView move:targetDictionary toIndex:dropView.previousDropViewIndex];
            [dropView move:targetDictionary toIndex:lastHist.previousIndex];
        }
        
        
        // 2. reverse "bringUnderlyingElementBackToOrigin"
        // -> get replaced source view back to target view
        [undoArray addObject:[historyArray lastObject]];
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
            [sourceDictionary setObject:dragView forKey:@(lastHist.previousIndex)];
            //[sourceDictionary setObject:dragView forKey:@(dragView.index)];
            
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
    
    [undoArray addObject:[historyArray lastObject]];
    
    [historyArray removeLastObject];
    
    undoButton.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
    redoButton.alpha = 1.0;
    redoButton.enabled = YES;
    
    infoLabel.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
    infoLabel.text = [NSString stringWithFormat:@"%d", counter];

//    resetButton.enabled = historyArray.count==0 ? NO : YES;
//    resetButton.alpha = historyArray.count==0 ? ALPHA_OFF : 1.0;
    
//    // make sure we finally get the initial population of source collection view back
//    if (historyArray.count == 0) {
//        [originalSourceDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
//            sourceDictionary[key] = object;
//        }];
//    }
    
    // inform source collection view about change - reload needed
    [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaRestoreElementNotification" object:nil userInfo:nil];
}


@end
