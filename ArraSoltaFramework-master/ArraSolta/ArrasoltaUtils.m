//
//  Utils.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaUtils.h"

@interface ArrasoltaUtils() {
    float cellWidth;
}
@end

@implementation ArrasoltaUtils

float cellWidth;
float cellHeight;

/**
 * Removes all empty keys in a dictionary and shifts all populated elements to left, for example [0,1,4,7] becomes [0,1,2,3]
 *
 */
+ (void) eliminateEmptyKeysInDict: (NSMutableDictionary*) dict {
    // get the highest index (=key) of the elements in collection view
    NSArray *sortedKeys = [dict.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    
    if (sortedKeys.count==0) return;
    
    int lastElementIndex = [sortedKeys[0] intValue];
    
    NSMutableArray* valuesArray = [NSMutableArray new];
    int index = 0;
    
    // delete all empty elements and left-shift all populated ones
    for (int i=0; i<lastElementIndex+1; i++) {
        id value = dict[@(i)];
        if (value) {
            [valuesArray insertObject:value atIndex:index];
            index++;
        }
    }
    
    [dict removeAllObjects];
    
    // rewrite dictionary with reordered elements
    for (int i=0; i<valuesArray.count; i++) {
        id value = valuesArray[i];
        dict[@(i)] = value;
    }
}

/**
 * Calculates the size and the position of a single UICollectionViewCell and returns a CGRect
 *
 */
+ (CGRect) getCellCoordinates: (ArrasoltaCollectionViewCell *) cell fromCollectionView: (UICollectionView*) collectionView {
    
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
    NSArray * keys = dict.allKeys;
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
+ (ArrasoltaCollectionViewCell*)getTargetCell:(ArrasoltaMoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint correctedTapLocation = [self getCenteredTapLocation:moveableView inCollectionView:collectionView recognizer:recognizer];
    
    NSIndexPath* dropIndexPath = [collectionView indexPathForItemAtPoint:correctedTapLocation];
    return (ArrasoltaCollectionViewCell*)[collectionView cellForItemAtIndexPath:dropIndexPath];
}

+ (void)bringMoveableViewToFront:(UIPanGestureRecognizer *)recognizer moveableView:(ArrasoltaMoveableView *)moveableView overCollectionView:(UICollectionView*) collectionView {
    UIWindow *frontWindow = [UIApplication sharedApplication].keyWindow;
    
    moveableView.frame = [self getCellFrame:moveableView inCollectionView:collectionView recognizer:recognizer];
    [frontWindow addSubview:moveableView];
}

+ (CGRect)getCellFrame:(ArrasoltaMoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint correctedTapLocation = [self getCenteredTapLocation:moveableView inCollectionView:collectionView recognizer:recognizer];
    
    NSIndexPath* dropIndexPath = [collectionView indexPathForItemAtPoint:correctedTapLocation];
    ArrasoltaCollectionViewCell *cell = (ArrasoltaCollectionViewCell*)[collectionView cellForItemAtIndexPath:dropIndexPath];
    
    CGRect cvFrame = collectionView.frame;
    float cvX = cvFrame.origin.x;
    float cvY = cvFrame.origin.y;
    
    CGRect cellFrame = cell.frame;
    float cellX = cellFrame.origin.x;
    float cellY = cellFrame.origin.y;
    float cellW = cellFrame.size.width;
    float cellH = cellFrame.size.height;
    
    return CGRectMake(cvX+cellX, cvY+cellY, cellW, cellH);
    
}

// returns an array of max. two "CollectionViewCell" objects
+ (NSArray*) getInsertCells:(ArrasoltaMoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer*)recognizer {
    
    CGPoint correctedTapLocation = [self getCenteredTapLocation:moveableView inCollectionView:collectionView recognizer:recognizer];
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
    
    ArrasoltaCollectionViewCell* leftCell = (ArrasoltaCollectionViewCell*)[collectionView cellForItemAtIndexPath:dropIndexPathLeft];
    ArrasoltaCollectionViewCell* rightCell = (ArrasoltaCollectionViewCell*)[collectionView cellForItemAtIndexPath:dropIndexPathRight];
    
    if (leftCell.isPopulated && rightCell.isPopulated) {
        return @[leftCell, rightCell];
    } else {
        return nil;
    }
    
}

+ (CGPoint) getCenteredTapLocation:(ArrasoltaMoveableView *)moveableView inCollectionView:(UICollectionView*) collectionView recognizer:(UIPanGestureRecognizer *)recognizer {
    
    CGPoint tapLocationInDragView = [recognizer locationInView:moveableView];
    CGPoint tapLocationInCollectionView = [recognizer locationInView:collectionView];
    
    // negative offset -> left cell should not be highlighted when touch point is in the middle of two cells
    ArrasoltaCollectionViewCell* dummyCell;
    
    
    // Get vertical scroll offset
    //
    // Important: when collection view is scrolled, all information about previous cells
    // (which are no more visible) are lost!
    // That's why we need to iterate over all cells and find the first one which can
    // provide the width and height of such.
    for (int i=0; i<[collectionView numberOfItemsInSection:0]; i++) {
        dummyCell = (ArrasoltaCollectionViewCell*)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
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

// compares two sizes - if first size is within second size, return true, otherwise false
+ (bool) size:(CGSize)smallerSize isSmallerThanOrEqualToSize:(CGSize)largerSize {
    
    return CGRectContainsRect(
                              CGRectMake(0.0f, 0.0f, largerSize.width, largerSize.height),
                              CGRectMake(0.0f, 0.0f, smallerSize.width, smallerSize.height)
                              );
}

+ (ArrasoltaCollectionViewCell*) getCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath cellDictionaries:(NSArray*) cellDictionaries {

    // Important: order of dictionaries must be maintained:
    // 1. source dictionary
    // 2. target dictionary
    
    NSDictionary* sourceDict = (NSMutableDictionary*) cellDictionaries[0];
    NSDictionary* targetDict = (NSMutableDictionary*) cellDictionaries[1];

    ArrasoltaCollectionViewCell* cell;
    
    if ([collectionView isKindOfClass:[ArrasoltaDragCollectionView class]]) {
        // fill all cells from DragCollectionView
        cell = [((ArrasoltaDragCollectionView*)collectionView) getCell:indexPath];
        ArrasoltaDragView* dragView = sourceDict[@((int)indexPath.item)];
        
        [cell populateWithContentsOfView:dragView withinCollectionView:collectionView];
        
    } else {
        // fill all cells from DropCollectionView
        cell = [((ArrasoltaDropCollectionView*)collectionView) getCell:indexPath];
        ArrasoltaDropView* dropView = targetDict[@((int)indexPath.item)];
        
        [cell populateWithContentsOfView:dropView withinCollectionView:collectionView];
    }
    
    return cell;
}

@end
