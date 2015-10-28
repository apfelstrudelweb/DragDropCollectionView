//
//  CollectionViewFlowLayout.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 17.10.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaCollectionViewFlowLayout.h"
#import "ArrasoltaConfig.h"

#define SHARED_CONFIG_INSTANCE     [ArrasoltaConfig sharedInstance]


@interface ArrasoltaCollectionViewFlowLayout() {
    // cache for all collection view cell's layouts
    NSMutableArray * cache;
    // flag indicating that attributes can be read from cache (performance issue)
    bool attributesHaveBeenUpdated;
    
    // number of all cells in the collection view
    int numberOfTotalCells;
    // length of the longest row
    float maxRowWidth;
}
@end

@implementation ArrasoltaCollectionViewFlowLayout

/**
 *
 *  Is called whenever the collection view’s layout is invalidated,
 *  for example after device rotation
 *
 **/
- (void)prepareLayout {
    
    attributesHaveBeenUpdated = false;
    
    if (!cache) {
        cache = [NSMutableArray new];
    }
    
    if (cache.count == 0) {
        
        numberOfTotalCells = (int)[self.collectionView numberOfItemsInSection:0]; //(int) attributesArray.count; //
        
        // now populate the cache with ALL cells of collection view (not only the visibe ones)
        for (int i=0; i<numberOfTotalCells; i++) {
            UICollectionViewLayoutAttributes * attributes = [super layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
            [cache addObject:attributes];
        }
    }
    
    maxRowWidth = self.collectionView.frame.size.width;
    
}


/**
 *
 *  Is called whenever cells appear/disappear after scrolling
 *  and after "prepareLayout"
 *
 **/
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    
    
    NSMutableArray * attributesArray = [[super layoutAttributesForElementsInRect: rect] mutableCopy]; // reflects only the attributes of visible cells within the scroll area!
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical || !cache) {
        return attributesArray; // nothing to do ... the order of the elements is ok
    }
    
    if (attributesHaveBeenUpdated) {
        // nothing to do, just take the elements from cache!
        return cache;
    }
    
    if (attributesArray.count == 0) {
        return cache;
    }
    
    
    // height of collection view
    float availableHeight = self.collectionViewContentSize.height;
    // width of collection view
    float availableWidth = self.collectionViewContentSize.width;
    // height of a single collection view cell (here: equal sizes!)
    float cellHeight = ((UICollectionViewLayoutAttributes*)attributesArray[0]).frame.size.height;
    // height of a single collection view cell (here: equal sizes!)
    float cellWidth = ((UICollectionViewLayoutAttributes*)attributesArray[0]).frame.size.width;
    // minimal spacing between two rows -> to be multiplied later with (numberOfRows - 1)
    float minLineSpacing = self.minimumLineSpacing;
    // minimal spacing between two columns
    float minInteritemSpacing = self.minimumInteritemSpacing;
    
    // now calculate the maximal number of rows in function of cellHeight,
    // minLineSpacing and availableHeight -> formula comes from:
    // availableHeight = numberOfRows*cellHeight + (numberOfRows-1)*minLineSpacing
    int numberOfRows = floor((availableHeight + minLineSpacing) / (cellHeight + minLineSpacing));
    
    
    /**
     *
     * Now we need to calculate the new positioning of the cells in function of
     * the maximal number of possible rows (=numberOfRows). We start with the
     * first row and try to achieve the best reapartition of cells in each row,
     * so that rows 1...N-1 are filled with the same number of cells (=n). The last
     * row should be filled with the remaining elements -> number = between 1 and n.
     *
     **/
    // get the number of cells until the penultimate row
    int numberOfCellsPerMainRow = ceil((float)numberOfTotalCells / (float)numberOfRows);
    
    
    // number of total cells from row 1...N-1
    int numberOfMainRowCells = numberOfCellsPerMainRow*(numberOfRows-1);
    // number of cells in last row
    int numberOfLastRowCells = numberOfTotalCells - numberOfMainRowCells;
    
    // special case : if no remaining element for last row, decrease the number of cells
    // in previous rows -> remember: we want to fill each available row!
    if (numberOfLastRowCells == 0) {
        numberOfCellsPerMainRow--;
        numberOfMainRowCells = numberOfCellsPerMainRow*(numberOfRows-1);
        numberOfLastRowCells += numberOfRows;
    }
    
    if (numberOfLastRowCells > numberOfCellsPerMainRow) {
        numberOfCellsPerMainRow++;
        //numberOfMainRowCells = numberOfCellsPerMainRow*(numberOfRows-1);
        
        if (numberOfCellsPerMainRow * numberOfRows > numberOfTotalCells) {
            numberOfRows--;
        }
    }
    
    // make sure all available columns are filled before starting a new row
    while (((numberOfCellsPerMainRow+1) * cellWidth + numberOfCellsPerMainRow * minInteritemSpacing) <= availableWidth) {
        //numberOfRows--;
        numberOfCellsPerMainRow++;
    }

    

    
    int numberOfEffectiveRows;
    
    if ([SHARED_CONFIG_INSTANCE getShouldItemsBePlacedFromLeftToRight]) {
        numberOfEffectiveRows = floor((float)(numberOfTotalCells-1)/(float)numberOfCellsPerMainRow) + 1;
    } else {
        numberOfEffectiveRows = numberOfRows;
    }
    
    float occupiedWidth = numberOfCellsPerMainRow*cellWidth + (numberOfCellsPerMainRow-1) * minInteritemSpacing;
    float occupiedHeight = numberOfEffectiveRows*cellHeight + (numberOfEffectiveRows-1) * minLineSpacing;
    
    float offsetX = 0;
    float offsetY = 0;
    float offsetSpacingY = 0;
    
    bool shouldCollectionViewBeCenteredHorizontally = false;
    
    if (occupiedHeight < availableHeight) {
        
        if ([SHARED_CONFIG_INSTANCE getShouldCollectionViewFillEntireHeight]) {
            if (numberOfEffectiveRows > 1) {
                offsetSpacingY = (availableHeight - occupiedHeight) / (numberOfEffectiveRows-1);
            }
        } else if ([SHARED_CONFIG_INSTANCE getShouldCollectionViewBeCenteredVertically]) {
            offsetY = 0.5*(availableHeight - occupiedHeight);
        }
        if (shouldCollectionViewBeCenteredHorizontally) {
            offsetX = 0.5*(availableWidth - occupiedWidth);
        }
    }
    

    // get the width of the largest row (we need it for increasing the scroll area)
    maxRowWidth = numberOfCellsPerMainRow * cellWidth + (numberOfCellsPerMainRow - 1) * minInteritemSpacing;
    
    for (int i=0; i<numberOfTotalCells; i++) {
        
        // now overwrite the geometrical properties of each cell
        UICollectionViewLayoutAttributes* attr = cache[i];// get from cache ...
        
        int row = 0;
        int col = 0;
        
        if ([SHARED_CONFIG_INSTANCE getShouldItemsBePlacedFromLeftToRight]) {
            row = floor((float)i/(float)numberOfCellsPerMainRow);
            col = i % numberOfCellsPerMainRow;
        } else {
            row = i % numberOfRows;
            col = floor((float)i/(float)numberOfRows);
        }
        
        
        // overwrite layout in the cache ("call by reference")
        attr.frame = CGRectMake(col*(cellWidth+minInteritemSpacing) + offsetX, row*(cellHeight+minLineSpacing+offsetSpacingY) + offsetY, cellWidth, cellHeight);
    }
    
    attributesHaveBeenUpdated = true; // the next time, read from cache!
    
    return cache;
}

/**
 *
 * Override the collection view content view for scroll issues
 *
 **/
- (CGSize)collectionViewContentSize {
    
    if (self.scrollDirection == UICollectionViewScrollDirectionVertical) {
        return [super collectionViewContentSize];
    } else {
        return CGSizeMake(maxRowWidth, self.collectionView.frame.size.height);
    }
}

/**
 *
 * Asks the layout object if the new bounds require a layout update
 * return YES, otherwise we get empty cells after scrolling!
 *
 **/
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

@end
