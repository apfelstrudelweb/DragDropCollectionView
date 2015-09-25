//
//  Utils.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 18.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "Utils.h"


@implementation Utils

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
    
    [collectionView scrollToItemAtIndexPath:scrollToIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

@end
