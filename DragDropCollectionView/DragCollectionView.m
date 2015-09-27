//
//  DragCollectionView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragCollectionView.h"

#define REUSE_IDENTIFIER @"dragCell"

@interface DragCollectionView() {
    
}
@end

@implementation DragCollectionView

- (id)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>*) view  {
    
    //self = [super initWithFrame:frame];
    if (self) {
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        
        self = [[DragCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        self.backgroundColor = [SHARED_INSTANCE getBackgroundColorSourceView];
        
        self.itemSpacing = [SHARED_INSTANCE getItemSpacing]; // set member variable AFTER  instantiation - otherwise it will be lost later
        [flowLayout setMinimumInteritemSpacing:self.itemSpacing];
        [flowLayout setMinimumLineSpacing:self.itemSpacing];
        
        self.delegate = view;
        self.dataSource = view;
        self.showsHorizontalScrollIndicator = NO;
        
        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
    }
    return self;
}

- (CollectionViewCell*) getCell: (NSIndexPath*) indexPath {
    return [self dequeueReusableCellWithReuseIdentifier:REUSE_IDENTIFIER forIndexPath:indexPath];
}

/**
 * Assuming that a single cell has the same width and height, this method calculates
 * the ideal width/height so that the collection view (in which the cells are embedded)
 * is best filled, taking into account the total number of cells. The main goal consists
 * in preventing a vertical overlapping towards the bottom of the collection view.
 *
 */
- (float) getBestFillingCellSize: (CGSize) containerSize {
    
    float cellWidthHeight = 0.0;
    
    float collectionViewWidth;
    float collectionViewHeight;
    
    float occupiedHeight = 0.0;
    
    int N;
    
    int numberOfColumns;
    
    
    collectionViewWidth  = containerSize.width;
    collectionViewHeight = containerSize.height; //totalHeight*percentDragArea*0.01;
    N = (int)[self numberOfItemsInSection:0];
    
    
    NSMutableArray *matrixArray = [NSMutableArray new];
    [matrixArray insertObject:[NSNumber numberWithInt:N] atIndex:0];
    for (int i=1; i<N; i++) {
        [matrixArray insertObject:[NSNumber numberWithInt:0] atIndex:i];
    }
    
    int newVal;
    
    for (int i=0; i<N; i++) {
        
        int rows = [matrixArray getNumberOfActiveElements];
        int cols = [matrixArray[0] intValue];
        
        // 1. row
        cellWidthHeight = floorf((collectionViewWidth - (cols-1)*self.itemSpacing)/cols);
        
        occupiedHeight = rows*cellWidthHeight + (rows-1)*self.itemSpacing;
        
        if (occupiedHeight > collectionViewHeight) {
            // if total height exceeds contentview, add an item to first row
            int cols = [matrixArray[0] intValue] + 1;
            cellWidthHeight = floorf((collectionViewWidth - (cols-1)*self.itemSpacing)/cols);
            numberOfColumns = cols;
            
            // case when matrix contains only one row with few elements
            if (cellWidthHeight > collectionViewHeight) {
                cellWidthHeight = collectionViewHeight;
            }
            break;
        }
        
        newVal = [matrixArray[0] intValue] - 1;
        [matrixArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:newVal]];
        
        newVal = [matrixArray[1] intValue] + 1;
        [matrixArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:newVal]];
        
        // case when matrix contains only two elements
        if (matrixArray.count<3) {
            return cellWidthHeight;
        }
        
        if ([matrixArray[2] intValue] > 0) {
            newVal = [matrixArray[2] intValue] + 1;
            [matrixArray replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:newVal]];
        }
        
        
        for (int j=1; j<N-1; j++) {
            int diff = [matrixArray[j] intValue] - [matrixArray[j-1] intValue];
            
            if (diff > 0) {
                newVal = [matrixArray[j] intValue] - diff;
                [matrixArray replaceObjectAtIndex:j withObject:[NSNumber numberWithInt:newVal]];
                
                int sum = 0;
                for (int k=0;k<j+1;k++) {
                    sum += [matrixArray[k] intValue];
                }
                newVal = N - sum;
                [matrixArray replaceObjectAtIndex:j+1 withObject:[NSNumber numberWithInt:newVal]];
            }
        }
        
        //NSLog(@"matrixArray:%@", matrixArray);
        
        if ([matrixArray[0] intValue] == 1) {
            break;
        }
    }
    return cellWidthHeight;
}



@end
