//
//  Utils.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "Utils.h"

@interface Utils() {
    float cellWidth;
}
@end

@implementation Utils

float cellWidth;
float cellHeight;

/**
 * Removes all empty keys in a dictionary and shifts all populated elements to left, for example [0,1,4,7] becomes [0,1,2,3]
 *
 */
+ (void) eliminateEmptyKeysInDict: (NSMutableDictionary*) dict {
    // get the highest index (=key) of the elements in collection view
    NSArray *sortedKeys = [[dict allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    
    if (sortedKeys.count==0) return;
    
    int lastElementIndex = [sortedKeys[0] intValue];
    
    NSMutableArray* valuesArray = [NSMutableArray new];
    int index = 0;
    
    // delete all empty elements and left-shift all populated ones
    for (int i=0; i<lastElementIndex+1; i++) {
        id value = [dict objectForKey:[NSNumber numberWithInt:i]];
        if (value) {
            [valuesArray insertObject:value atIndex:index];
            index++;
        }
    }
    
    [dict removeAllObjects];
    
    // rewrite dictionary with reordered elements
    for (int i=0; i<valuesArray.count; i++) {
        id value = [valuesArray objectAtIndex:i];
        [dict setObject:value forKey:[NSNumber numberWithInt:i]];
    }
}

/**
 * Calculates the size and the position of a single UICollectionViewCell and returns a CGRect
 *
 */
+ (CGRect) getCellCoordinates: (CollectionViewCell *) cell fromCollectionView: (UICollectionView*) collectionView {
    
    CGPoint origin = collectionView.frame.origin;
    float x = origin.x;
    float y = origin.y;
    
    CGPoint cellOrigin = cell.frame.origin;
    float cellX = cellOrigin.x;
    float cellY = cellOrigin.y;
    float w = cell.frame.size.width;
    float h = cell.frame.size.height;
    
    return CGRectMake(x+cellX, y+cellY, w, h);
}

/**
 * Returns a random color
 *
 */
+ (UIColor*) getRandomColor {
    NSInteger aRedValue = arc4random()%255;
    NSInteger aGreenValue = arc4random()%255;
    NSInteger aBlueValue = arc4random()%255;
    
    return [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
}

/**
 * Returns the highest key (int) of a dictionary
 *
 */
+ (int) getHighestKeyInDict: (NSMutableDictionary*) dict {
    NSArray * keys = [dict allKeys];
    return [[keys valueForKeyPath:@"@max.intValue"] intValue];
}

/**
 * collection view: scrolls to the last element of a dictionary
 *
 */
+ (void) scrollToLastElement: (UICollectionView*) collectionView ofDictionary: (NSMutableDictionary*) dict {
    // now scroll to the last item in collection view
    int maxItem = [self getHighestKeyInDict:dict];
    NSIndexPath* scrollToIndexPath = [NSIndexPath indexPathForItem:maxItem inSection:0];
    
    [collectionView layoutIfNeeded];
    
    [collectionView scrollToItemAtIndexPath:scrollToIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
}

#pragma mark -UIPanGestureRecognizer
/**
 * Returns the correspondent cell of a target collection view when a drag view is dropped into
 * it (after dragging it from the source collection view)
 *
 */
+ (CollectionViewCell*)getTargetCell:(DragView *)dragView inCollectionView:(DropCollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer {

    CGPoint correctedTapLocation = [self getCenteredTapLocation:dragView inCollectionView:collectionView recognizer:recognizer];
    
    NSIndexPath* dropIndexPath = [collectionView indexPathForItemAtPoint:correctedTapLocation];
    return (CollectionViewCell*)[collectionView cellForItemAtIndexPath:dropIndexPath];
}

// returns an array of max. two "CollectionViewCell" objects
+ (NSArray*) getInsertCells:(DragView *)dragView inCollectionView:(DropCollectionView*) collectionView recognizer:(UIPanGestureRecognizer*)recognizer {
    
    CGPoint correctedTapLocation = [self getCenteredTapLocation:dragView inCollectionView:collectionView recognizer:recognizer];
    float dragCenterX = correctedTapLocation.x;
    float dragCenterY = correctedTapLocation.y;
    
    float leftX = dragCenterX - cellWidth;
    float leftY = dragCenterY;
    
    CGPoint shiftedTapLocation = CGPointMake(leftX, leftY);
    NSIndexPath* dropIndexPathLeft = [collectionView indexPathForItemAtPoint:shiftedTapLocation];
    
    int leftIndex = (int) dropIndexPathLeft.item;
    int lastInsertionIndex = (int)[collectionView numberOfItemsInSection:0] - 1;
    
    if (!dropIndexPathLeft || leftIndex == lastInsertionIndex) {
        //NSLog(@"dropIndexPathLeft: %@", dropIndexPathLeft);
        return nil;
    }
    
    NSIndexPath* dropIndexPathRight = [NSIndexPath indexPathForItem:leftIndex+1 inSection:dropIndexPathLeft.section];
    
    CollectionViewCell* leftCell = (CollectionViewCell*)[collectionView cellForItemAtIndexPath:dropIndexPathLeft];
    CollectionViewCell* rightCell = (CollectionViewCell*)[collectionView cellForItemAtIndexPath:dropIndexPathRight];
    
    if (leftCell.isPopulated && rightCell.isPopulated) {
        return @[leftCell, rightCell];
    } else {
        return nil;
    }
    
}

+ (CGPoint) getCenteredTapLocation:(DragView *)dragView inCollectionView:(DropCollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint tapLocationInDragView = [recognizer locationInView:dragView];
    CGPoint tapLocationInCollectionView = [recognizer locationInView:collectionView];
    
    // negative offset -> left cell should not be highlighted when touch point is in the middle of two cells
    CollectionViewCell* dummyCell;
    
    
    // Get vertical scroll offset
    //
    // Important: when collection view is scrolled, all information about previous cells
    // (which are no more visible) are lost!
    // That's why we need to iterate over all cells and find the first one which can
    // provide the width and height of such.
    for (int i=0; i<[collectionView numberOfItemsInSection:0]; i++) {
        dummyCell = (CollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (dummyCell) {
            break;
        }
    }
    
    cellWidth  = dummyCell.bounds.size.width;
    cellHeight = dummyCell.bounds.size.height;
    
    float scrollY = collectionView.contentOffset.y / collectionView.frame.size.height;
    
    
    // now get the center of the dragged view -> we need two tap locations:
    // - first tap location related to the collection view and
    // - second tap location related to the dragged view
    float centerX = tapLocationInCollectionView.x - tapLocationInDragView.x + 0.5*cellWidth;
    float centerY = tapLocationInCollectionView.y - tapLocationInDragView.y + 0.5*cellHeight+scrollY;
    
    CGPoint centeredTapLocation = CGPointMake(centerX, centerY);
    return centeredTapLocation;
}

@end
