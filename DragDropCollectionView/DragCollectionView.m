//
//  DragCollectionView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "DragCollectionView.h"
#import "Utils.h"
#import "ConfigAPI.h"
#import "CollectionViewFlowLayout.h"
#import "CurrentState.h"

#define REUSE_IDENTIFIER @"dragCell"
#define SHARED_CONFIG_INSTANCE   [ConfigAPI sharedInstance]
#define SHARED_STATE_INSTANCE    [CurrentState sharedInstance]


@interface DragCollectionView() {

    //UICollectionViewScrollDirection scrollDirection;
    
    float minInteritemSpacing;
    float minLineSpacing;
    
    int pinchCount;
}
@end

@implementation DragCollectionView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.contentSize;
    CGPoint point = self.frame.origin;
    
    float bottomY = point.y + size.height;
    
    [[CurrentState sharedInstance] setBottomSourceCollectionView:bottomY];
}



- (instancetype)initWithFrame:(CGRect)frame withinView: (UIView<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>*) view  {
    

    if (self) {
        
        UICollectionViewFlowLayout* flowLayout;
        
        if ([SHARED_CONFIG_INSTANCE getShouldItemsBePlacedFromLeftToRight]) {
            flowLayout = [[CollectionViewFlowLayout alloc] init];
        } else {
            flowLayout = [[UICollectionViewFlowLayout alloc] init];
        }
        
        self = [[DragCollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout];
        
        minInteritemSpacing = [SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
        minLineSpacing = [SHARED_CONFIG_INSTANCE getMinLineSpacing];// set member variable AFTER  instantiation - otherwise it will be lost later
        flowLayout.minimumInteritemSpacing = minInteritemSpacing;
        flowLayout.minimumLineSpacing = minLineSpacing;

        if ([SHARED_CONFIG_INSTANCE getScrollDirection] == horizontal) {
            super.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        } else {
            super.scrollDirection = UICollectionViewScrollDirectionVertical;
        }
        
        flowLayout.scrollDirection = super.scrollDirection;

        
        self.backgroundColor = [SHARED_CONFIG_INSTANCE getBackgroundColorSourceView];

        self.delegate = view;
        self.dataSource = view;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;

        [self registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:REUSE_IDENTIFIER];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreElementNotification:) name:@"arrasoltaRestoreElementNotification"
                                                   object:nil];
        
    
    }
    return self;
}

#pragma mark -NSNotificationCenter
- (void) restoreElementNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"arrasoltaRestoreElementNotification"]) {
        [self reloadData];
    }
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
- (CGSize) getBestFillingCellSize: (CGSize) containerSize {
    
    float cellWidth = 0.0;
    float cellHeight = 0.0;
    float cellSizeRatio = [SHARED_CONFIG_INSTANCE getCellWidthHeightRatio];
    
    float collectionViewWidth;
    float collectionViewHeight;
    
    float occupiedHeight = 0.0;
    
    collectionViewWidth  = containerSize.width;
    collectionViewHeight = containerSize.height; //totalHeight*percentDragArea*0.01;
    int N = (int)[self numberOfItemsInSection:0];
    
    
    NSMutableArray *matrixArray = [NSMutableArray new];
    [matrixArray insertObject:@(N) atIndex:0];
    for (int i=1; i<N; i++) {
        [matrixArray insertObject:@0 atIndex:i];
    }
    
    int newVal;
    
    for (int i=0; i<N; i++) {
        
        int rows = [matrixArray getNumberOfActiveElements];
        int cols = [matrixArray[0] intValue];
        
        // 1. row
        cellWidth = floorf((collectionViewWidth - (cols-1)*minInteritemSpacing)/cols);
        cellHeight = cellWidth / cellSizeRatio;
        
        occupiedHeight = rows*cellHeight + (rows-1)*minLineSpacing;
        
        if (occupiedHeight > collectionViewHeight) {
            // if total height exceeds contentview, add an item to first row
            int cols = [matrixArray[0] intValue] + 1;
            cellWidth = floorf((collectionViewWidth - (cols-1)*minInteritemSpacing)/cols);
            cellHeight = cellWidth / cellSizeRatio;
            
            // case when matrix contains only one row with few elements
            if (cellHeight > collectionViewHeight) {
                cellHeight = collectionViewHeight;
                cellWidth = cellHeight * cellSizeRatio;
            }
            break;
        }
        
        newVal = [matrixArray[0] intValue] - 1;
        matrixArray[0] = @(newVal);
        
        newVal = [matrixArray[1] intValue] + 1;
        matrixArray[1] = @(newVal);
        
        // case when matrix contains only two elements
        if (matrixArray.count<3) {
            return CGSizeMake(cellWidth, cellHeight);
        }
        
        if ([matrixArray[2] intValue] > 0) {
            newVal = [matrixArray[2] intValue] + 1;
            matrixArray[2] = @(newVal);
        }
        
        
        for (int j=1; j<N-1; j++) {
            int diff = [matrixArray[j] intValue] - [matrixArray[j-1] intValue];
            
            if (diff > 0) {
                newVal = [matrixArray[j] intValue] - diff;
                matrixArray[j] = @(newVal);
                
                int sum = 0;
                for (int k=0;k<j+1;k++) {
                    sum += [matrixArray[k] intValue];
                }
                newVal = N - sum;
                matrixArray[j+1] = @(newVal);
            }
        }
        
        if ([matrixArray[0] intValue] == 1) {
            break;
        }
    }
    
    return CGSizeMake(cellWidth, cellHeight);
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
