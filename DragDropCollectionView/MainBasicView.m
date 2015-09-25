//
//  MainBasicView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainBasicView.h"

@interface MainBasicView( ) {
    // subview proportions
    float totalHeight;
    float totalWidth;
    int percentHeader1, percentHeader2, percentDragArea, percentDropArea, percentStepper;
    
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
}
@end

@implementation MainBasicView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteCellNotification:) name:@"deleteCellNotification"
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveShiftCellNotification:) name:@"shiftCellNotification"
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewHasBeenRotated:) name:@"viewHasBeenRotatedNotification"
                                                   object:nil];
        
    }
    return self;
}


#pragma mark -NSNotificationCenter
- (void) receiveDeleteCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"deleteCellNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSIndexPath* indexPath = [userInfo objectForKey:@"indexPath"];
        
        // append empty cell in order to maintain a constant number of cells
        self.numberOfDropItems++;
        [self.dropCollectionView performBatchUpdates:^{
            
            NSIndexPath* indexPathToAppend = [NSIndexPath indexPathForRow:self.numberOfDropItems-1 inSection:0];
            
            NSArray *indexPaths = [NSArray arrayWithObject:indexPathToAppend];
            [self.dropCollectionView insertItemsAtIndexPaths:indexPaths];
            
        } completion: ^(BOOL finished) {
            [self.targetCellsDict  removeObjectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
            
            [self.targetCellsDict log];
            
        }];
        
    }
}


- (void) receiveShiftCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"shiftCellNotification"]) {
        
        
        NSDictionary *userInfo = notification.userInfo;
        NSIndexPath* indexPath = [userInfo objectForKey:@"indexPath"];
        
        self.numberOfDropItems--;
        [self.dropCollectionView performBatchUpdates:^{
            //NSLog(@"item = %d", (int)indexPath.item);
            [self.dropCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            
        } completion: ^(BOOL finished) {
            // shift elements to left and remove empty ones
            [Utils eliminateEmptyKeysInDict:self.targetCellsDict];
            // important: reload data, otherwise empty cells could remain visible!
            [self.dropCollectionView reloadData];
            
            [Utils scrollToLastElement: self.dropCollectionView ofDictionary:self.targetCellsDict];
        }];
    }
}

- (void) viewHasBeenRotated:(NSNotification *) notification {
    
    //numberOfItemsInLine = NUMBER_ITEMS_IN_LINE;
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[DragView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    [self setupConstraints];
    [self calculateCellSize];
    
    [self.dragCollectionView reloadData];
    [self.dropCollectionView reloadData];
    
    [Utils scrollToLastElement: self.dropCollectionView ofDictionary:self.targetCellsDict];
}


- (void) calculateCellSize {
    
    float collectionViewWidth;
    float collectionViewHeight;
    
    float occupiedHeight = 0.0;
    
    int N;
    
    
    collectionViewWidth  = totalWidth;
    collectionViewHeight = totalHeight*percentDragArea*0.01;
    N = (int)[self.dragCollectionView numberOfItemsInSection:0];
    
    
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
        self.cellWidthHeight = floorf((collectionViewWidth - (cols-1)*self.itemSpacing)/cols);
        
        occupiedHeight = rows*self.cellWidthHeight + (rows-1)*self.itemSpacing;
        
        if (occupiedHeight > collectionViewHeight) {
            // if total height exceeds contentview, add an item to first row
            int cols = [matrixArray[0] intValue] + 1;
            self.cellWidthHeight = floorf((collectionViewWidth - (cols-1)*self.itemSpacing)/cols);
            self.numberOfColumns = cols;
            
            // case when matrix contains only one row with few elements
            if (self.cellWidthHeight > collectionViewHeight) {
                self.cellWidthHeight = collectionViewHeight;
            }
            
            break;
        }
        
        newVal = [matrixArray[0] intValue] - 1;
        [matrixArray replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:newVal]];
        
        newVal = [matrixArray[1] intValue] + 1;
        [matrixArray replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:newVal]];
        
        // case when matrix contains only two elements
        if (matrixArray.count<3) {
            return;
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
    
}



#pragma mark -constraint issues
- (void)setupConstraints {
    
    self.viewsDictionary = @{   @"headline1"    : self.headline1,
                                @"source"       : self.dragCollectionView,
                                @"stepper"      : self.stepper,
                                @"headline2"    : self.headline2,
                                @"target"       : self.dropCollectionView };
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    totalHeight = 0.9*screenRect.size.height;
    totalWidth  = 0.9*screenRect.size.width;
    percentHeader1 = PERCENT_HEADER_1;
    percentHeader2 = PERCENT_HEADER_2;
    percentDragArea = PERCENT_DRAG_AREA;
    percentDropArea = PERCENT_DROP_AREA;
    percentStepper = PERCENT_STEPPER;
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    
    NSString* visualFormatText = [NSString stringWithFormat:@"V:|-%d-[headline1]-%d-[source]-%f-[stepper]-%d-[headline2]-%d-[target]",MARGIN, 0, 0.5*MARGIN, 0, 0];
    
    
    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.viewsDictionary];
    
    for (int i = 0; i<visualFormatConstraints.count; i++) {
        [self addConstraint:visualFormatConstraints[i]];
    }
    
    
    layoutConstraints = [NSMutableArray new];
    
    
    float heightHeader1  = (float) totalHeight*percentHeader1*0.01;
    float heightHeader2  = (float) totalHeight*percentHeader2*0.01;
    float heightDragArea = (float) totalHeight*percentDragArea*0.01;
    float heightDropArea = (float) totalHeight*percentDropArea*0.01;
    float heightStepper  = (float) totalHeight*percentStepper*0.01;
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline1
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline1
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightHeader1]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline1
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline2
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline2
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightHeader2]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline2
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.dragCollectionView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.dragCollectionView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightDragArea]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.dragCollectionView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.dropCollectionView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.dropCollectionView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightDropArea]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.dropCollectionView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stepper
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stepper
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightStepper]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stepper
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

@end
