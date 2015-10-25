//
//  CollectionView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.10.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CollectionView.h"
#import "CurrentState.h"
#import "ConfigAPI.h"

#define SHARED_STATE_INSTANCE    [CurrentState sharedInstance]
#define SHARED_CONFIG_INSTANCE   [ConfigAPI sharedInstance]

@interface CollectionView() {
    
    float minInteritemSpacing;
    float minLineSpacing;
    
    int pinchCount;
    
    bool deviceOrientationChanged;
    
}
@end

@implementation CollectionView

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    CGPoint point = self.frame.origin;
    
    
    float bottomY = point.y + size.height;
    
    [SHARED_STATE_INSTANCE setBottomSourceCollectionView:bottomY];
    
    CGSize fixedSize = [SHARED_CONFIG_INSTANCE getFixedCellSize];
    
    
    
    // watch out for unfinite loop!
    if (deviceOrientationChanged) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            CGSize cellSize;
            
            if (!CGSizeEqualToSize(fixedSize, CGSizeZero)) {
                cellSize = fixedSize;
            } else {
                cellSize = [self getBestFillingCellSize:size];
            }
            
            UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
            
            
            flowLayout.itemSize = cellSize;
            
            [flowLayout invalidateLayout];
            
            //[self reloadData];
            [SHARED_STATE_INSTANCE setCellSize:cellSize];
            
        });
        deviceOrientationChanged = false;
    }
    
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    if (self) {
        
        minInteritemSpacing = [SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
        minLineSpacing = [SHARED_CONFIG_INSTANCE getMinLineSpacing];
        
        // for zooming
        if ([SHARED_CONFIG_INSTANCE getShouldPanningBeEnabled]) {
            self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
            
            self.pinchRecognizer.delegate = self;
            [self addGestureRecognizer:self.pinchRecognizer];
        }
        
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(orientationChanged:)
         name:UIDeviceOrientationDidChangeNotification
         object:[UIDevice currentDevice]];
    }
    return self;
}

#pragma mark -NSNotificationCenter
- (void) orientationChanged:(NSNotification *)note {
    deviceOrientationChanged = true;
}



- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    float scale = recognizer.scale;
    float speed = 4*fabsf(1-scale);
    
    
    if (++pinchCount % 5 != 0) return; // performance issue!
    
    bool pinchOut = recognizer.scale > 1.0;
    
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    
    if (layout) {
        CGSize size = [SHARED_STATE_INSTANCE getCellSize];
        CGSize newSize;
        
        float contentWidth = self.contentSize.width;
        float contentHeight = self.contentSize.height;
        
        float ratio = size.width / size.height;
        
        // maintain proportions
        float dX = (1.0 + speed) * ratio;
        float dY = (1.0 + speed);
        
        if (pinchOut) {
            
            if (2.5*size.width > contentWidth || 2.5*size.height > contentHeight) {
                return;
            }
            newSize = CGSizeMake(size.width + dX, size.height + dY);
        } else {
            CGSize minimalCellSize = [SHARED_STATE_INSTANCE getInitialCellSize];
            
            CGSize fixedSize = [SHARED_CONFIG_INSTANCE getFixedCellSize];
            
            if (!CGSizeEqualToSize(fixedSize, CGSizeZero)) {
                minimalCellSize = [self getBestFillingCellSize:self.frame.size];
            }
            
            if (size.width > (minimalCellSize.width) && size.height > minimalCellSize.height) {
                newSize = CGSizeMake(size.width - dX, size.height - dY);
            } else {
                // make sure we don't violate constraints ...
                newSize = CGSizeMake(minimalCellSize.width, minimalCellSize.height);
            }
        }
        
        
        layout.scrollDirection = self.scrollDirection;
        
        [layout invalidateLayout];
        
        layout.itemSize = newSize;
        [self setCollectionViewLayout:layout];
        
        [SHARED_STATE_INSTANCE setCellSize:newSize];
        
        
        // inform all collection views so they can reload both
        [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaReloadDataNotification" object:nil userInfo:nil];
        
    }
}

/**
 * Assuming that a single cell has a fix width-height ratio, this method calculates
 * the ideal width/height so that the collection view (in which the cells are embedded)
 * is best filled, taking into account the total number of cells. The main goal consists
 * in preventing scrolling.
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
    collectionViewHeight = containerSize.height;
    int N = (int)[self numberOfItemsInSection:0];
    
    // 1. horizontal scroll: row is filled from top to bottom before next column appears
    int numberOfRows = 1;
    int counter = 0;
    int numberOfCellsPerRow = N;
    
    
    for (int i=N; i>0; i--) {
        
        
        float lastCellWidth = (collectionViewWidth-(i-1)*minInteritemSpacing) / i;
        float lastCellHeight = lastCellWidth / cellSizeRatio;
        
        if (lastCellWidth < 0) {
            continue; //overflow due to minInteritemSpacing
        }
        
        
        if (counter == 0) {
            numberOfCellsPerRow = i;
        } else {
            numberOfCellsPerRow--;
        }
        
        numberOfRows = ceilf((float)N / (float)numberOfCellsPerRow);
        //numberOfRows = floorf((float)N / (float)numberOfCellsPerRow);
        
        
        occupiedHeight = (numberOfRows==1) ? lastCellHeight : numberOfRows*lastCellHeight + (numberOfRows-1)*minLineSpacing;
        
        if (occupiedHeight > collectionViewHeight) {
            break;
        }
        
        cellWidth = lastCellWidth;
        cellHeight = lastCellHeight;
        
        counter++;
        
    }
    
    return CGSizeMake(cellWidth, cellHeight);
}


@end
