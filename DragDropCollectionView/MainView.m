//
//  MainView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"


@interface MainView() {


    NSMutableDictionary* sourceCellsDict;
   
    
    NSIndexPath* prevIndexPath;
    
    NSIndexPath *finalInsertIndexPath;
    CollectionViewCell* leftCell, *rightCell;

}

@end


@implementation MainView



- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.itemSpacing = [SHARED_CONFIG itemSpacing];
        sourceCellsDict = [SHARED_CONFIG dataSourceDict];
        self.targetCellsDict = [NSMutableDictionary new];
        
        self.numberOfDragItems = sourceCellsDict.count;
        self.numberOfDropItems = NUMBER_TARGET_ITEMS;
        
        self.headline1 = [[UILabel alloc] initWithFrame:frame];
        [self.headline1 setTextForHeadline:@"Drag and Drop Prototype"];
        [self.headline1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline1];
        
        self.headline2 = [[UILabel alloc] initWithFrame:frame];
        [self.headline2 setTextForHeadline:@"Drag elements from top to bottom"];
        [self.headline2 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline2];

        self.dragCollectionView = [[DragCollectionView alloc] initWithFrame:frame withinView:self];
        [self.dragCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.dragCollectionView];
        
        self.dropCollectionView = [[DropCollectionView alloc] initWithFrame:frame withinView:self];
        [self.dropCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.dropCollectionView];
        

        
        [self createStepper];
        

        [super setupConstraints];
        [super calculateCellSize];
        
    }
    return self;
}



#pragma mark <UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isKindOfClass:[DragCollectionView class]]) {
        return self.numberOfDragItems;
    } else {
        return self.numberOfDropItems;
    }
}

-(CollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell;
    UIColor *color;
    
    NSString *cellData = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    
    if ([collectionView isKindOfClass:[DragCollectionView class]]) {
        cell = [((DragCollectionView*)collectionView) getCell:indexPath];
        
        // after device rotation, try to reuse the cell from the dictionary which tracks all views in cells
        DragView* dragView = [sourceCellsDict objectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
        CGRect dragRect = [Utils getCellCoordinates:cell fromCollectionView:collectionView];
        
        if (dragView) {
            // overwrite coordinates after interface rotation
            [dragView setFrame:dragRect];
            
            
            UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            [recognizer setMaximumNumberOfTouches:1];
            [recognizer setMinimumNumberOfTouches:1];
            [dragView addGestureRecognizer:recognizer];
            
            [self addSubview:dragView];
        } else {
            // for test and visualization purposes, create each cell with a different and random color
            color = [Utils getRandomColor];
            
            // put an UIView over the cell and populate it - let the cell itself empty (it's only a placeholder)
            
            dragView = [[DragView alloc] initWithFrame:dragRect];
            [dragView setBackgroundColor:color];
            [dragView setLabelTitle:cellData];
            
            
            UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            [recognizer setMaximumNumberOfTouches:1];
            [recognizer setMinimumNumberOfTouches:1];
            [dragView addGestureRecognizer:recognizer];
            
            [self addSubview:dragView];
            
            [sourceCellsDict setObject:dragView forKey:[NSNumber numberWithInt:(int)indexPath.item]];
        }
        
    } else {
        
        cell = [((DropCollectionView*)collectionView) getCell:indexPath];
        cell.indexPath = indexPath;
        [cell initialize]; // make it gray and small (it's still a placeholder)
        
        // after scrolling, try to reuse the cell from the dictionary which tracks all populated cells
        CellModel* model = [self.targetCellsDict objectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
        if (model) {
            [cell setColor:model.color];
            [cell setLabelTitle:model.labelTitle];
            //[cell addSubview:model.imageView];
        }
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(self.cellWidthHeight, self.cellWidthHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if ([collectionView isKindOfClass:[DragCollectionView class]]) {
        // don't change the insets of the source collection view
        return UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        // put the first row a bit below - so when cell is to be inserted, the left and right cell has enough place to expand to the top as well
        return UIEdgeInsetsMake(0.5*self.itemSpacing, 0, 0, 0);
    }

}


#pragma mark -UIPanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    CollectionViewCell* cell;
    
    finalInsertIndexPath = nil;
    
    DragView* dragView = (DragView*)recognizer.view;
    
    [self bringSubviewToFront:dragView];
    
    // TODO: when View is in end position, don't add subviews!!
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Important: deliver new view when the old view has been dropped into the target cell
        DragView *newDragView = [DragView new];
        newDragView.frame = dragView.frame;
        newDragView.backgroundColor = dragView.backgroundColor;
        [newDragView setLabelTitle:[dragView getLabelTitel]];
        
        UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [recognizer setMaximumNumberOfTouches:1];
        [recognizer setMinimumNumberOfTouches:1];
        [newDragView addGestureRecognizer:recognizer];
        
        [self addSubview:newDragView];
        
        prevIndexPath = nil;
    }
    
    
    CGPoint translation = [recognizer translationInView:self];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
    
    CGPoint tapLocationInCollectionView = [recognizer locationInView:self.dropCollectionView];
    CGPoint tapLocationInDragView = [recognizer locationInView:dragView];
    
    // negative offset -> left cell should not be highlighted when touch point is in the middle of two cells
    CollectionViewCell* dummyCell;
    
    
    // Get vertical scroll offset
    //
    // Important: when collection view is scrolled, all information about previous cells
    // (which are no more visible) are lost!
    // That's why we need to iterate over all cells and find the first one which can
    // provide the width and height of such.
    for (int i=0; i<[self.dropCollectionView numberOfItemsInSection:0]; i++) {
        dummyCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (dummyCell) {
            break;
        }
    }
    
    float cellWidth = dummyCell.bounds.size.width;
    float cellHeight = dummyCell.bounds.size.height; // is redundant, perhaps we'll need it in future
    float scrollY = self.dropCollectionView.contentOffset.y / self.dropCollectionView.frame.size.height;
    
    
    // now get the center of the dragged view -> we need two tap locations:
    // - first tap location related to the collection view and
    // - second tap location related to the dragged view
    float centerX = tapLocationInCollectionView.x - tapLocationInDragView.x + 0.5*cellWidth;
    float centerY = tapLocationInCollectionView.y - tapLocationInDragView.y + 0.5*cellHeight+scrollY;
    
    CGPoint correctedTapLocation = CGPointMake(centerX, centerY);
    
    NSIndexPath *dropIndexPath = [self.dropCollectionView indexPathForItemAtPoint:correctedTapLocation];
    cell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:dropIndexPath];
    
    
    CellModel* model = [self.targetCellsDict objectForKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
    
    
    if (!model) {
        [cell highlightEmptyOne];
        [cell expandEmptyOne];
    } else {
        // when a cell is populated, fade out the color in order to indicate that this cell may be overwritten by putting a new object above
        [cell highlightPopulatedOne];
    }
    
    
    // when a cell is left without dropping an object onto it, perform a reset
    if (![dropIndexPath isEqual:prevIndexPath]) {
        if (prevIndexPath != nil) {
            // watch out after scrolling -> check if model in array exists
            CellModel* prevModel = [self.targetCellsDict objectForKey:[NSNumber numberWithInt:(int)prevIndexPath.item]];
            CollectionViewCell* prevCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:prevIndexPath];
            
            if (!prevModel) {
                // when cell is left, shrink again
                [prevCell shrinkEmptyOne];
                [prevCell unhighlightEmptyOne];
                
            } else {
                // when populated cell is left again, release the color lightening
                [prevCell unhighlightPopulatedOne];
            }
        }
        prevIndexPath = dropIndexPath;
        
        NSIndexPath *insertIndexPath;
        
        if (leftCell.isPopulated && rightCell.isPopulated) {
            [leftCell pushBack];
            [rightCell pushBack];
        }
        
        // if specific cell isn't touched, figure out if we are between two cells
        if (!dropIndexPath) {
            
            float leftX = correctedTapLocation.x - 0.5*cellWidth - 0.5*self.itemSpacing;
            
            CGPoint leftTapLocation = CGPointMake(leftX, correctedTapLocation.y);
            
            insertIndexPath = [self.dropCollectionView indexPathForItemAtPoint:leftTapLocation];
            
            if (insertIndexPath) {
                //NSLog(@"finalInsertIndexPath: %ld", (long)insertIndexPath.item);
                finalInsertIndexPath = insertIndexPath;
                
                int item1 = (int)insertIndexPath.item;
                int item2 = item1 + 1;
                
                leftCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:insertIndexPath];
                rightCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:item2 inSection:0]];
                
                if (leftCell.isPopulated && rightCell.isPopulated) {
                    [leftCell pushToLeft];
                    [rightCell pushToRight];
                }
            }
        }
    }
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        //        if (!cell) {
        //            // if not dropped into a cell, remove it
        //            [dragView removeFromSuperview];
        //            return;
        //        }
        
        NSIndexPath* indexPathToInsert;
        
        for (NSInteger row = 0; row < [self.dropCollectionView numberOfItemsInSection:0]; row++) {
            CollectionViewCell* _cell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            
            if (_cell.isPushedToLeft) {
                indexPathToInsert = [NSIndexPath indexPathForRow:row+1 inSection:0];
                break;
            }
        }
        
        // insert cell
        if (indexPathToInsert) {
            
            __block CollectionViewCell* newCell;
            
            self.numberOfDropItems++;
            [self.dropCollectionView performBatchUpdates:^{
                
                NSArray *indexPaths = [NSArray arrayWithObject:indexPathToInsert];
                [self.dropCollectionView insertItemsAtIndexPaths:indexPaths];
                
            } completion: ^(BOOL finished) {
                
                newCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:indexPathToInsert];
                
                [newCell initialize]; // don't omit otherwise overwritten cells will have multiple labels!
                //[cell unhighlightPopulatedOne];
                [newCell setColor: dragView.backgroundColor];
                [newCell setLabelTitle:[dragView getLabelTitel]];
                //[cell addSubview:dragView.imageView];
 
                [dragView removeFromSuperview];
                
                CellModel* model = [CellModel new];
                [model setColor:dragView.backgroundColor];
                [model setLabelTitle:[dragView getLabelTitel]];
                //[model setImageView:dragView.imageView];
                
                
                // Now update dictionary, shifting all elements right of the insert index to right
                int insertIndex = (int)indexPathToInsert.item;
                [self.targetCellsDict insertObject: model atIndex:insertIndex];

                //[targetCellsDict log];
 
            }];
            
            //NSLog(@"targetCellsDict: %@", targetCellsDict);
            
            // now remove last cell in order to maintain a constant number of cells
            self.numberOfDropItems--;
            [self.dropCollectionView performBatchUpdates:^{
                
                NSIndexPath *indexPath =[NSIndexPath indexPathForRow:self.numberOfDropItems inSection:0];
                [self.dropCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            } completion: ^(BOOL finished) {
                finalInsertIndexPath = nil;
                [leftCell pushBack];
                [rightCell pushBack];
                
                leftCell = nil;
                rightCell = nil;
            }];
            return;
        }
        
        // populate cell
        [cell initialize]; // don't omit otherwise overwritten cells will have multiple labels!
        // when new object is put on it, release the color lightening
        [cell unhighlightPopulatedOne];
        
        [cell setColor: dragView.backgroundColor];
        [cell setLabelTitle:[dragView getLabelTitel]];
        //[cell addSubview:dragView.imageView];
        
        [dragView removeFromSuperview];
        
        CellModel* model = [CellModel new];
        [model setColor:dragView.backgroundColor];
        [model setLabelTitle:[dragView getLabelTitel]];
        //[model setImageView:dragView.imageView];
        
        [self.targetCellsDict setObject:model forKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
    }
    
}




#pragma mark -utility methods
- (void) createStepper {
    
    self.stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
    [self.stepper addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];
    [self.stepper setBackgroundColor:[UIColor clearColor]];
    [self.stepper setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.stepper.value = self.numberOfDragItems;
    self.stepper.minimumValue = 2;
    self.stepper.maximumValue = 50;
    self.stepper.stepValue = 1;
    self.stepper.userInteractionEnabled = YES;
    self.stepper.tintColor = FONT_COLOR;
    
    [self addSubview:self.stepper];
    
}

- (void)stepperChanged:(UIStepper*)stepper {
    
    self.numberOfDragItems = self.stepper.value;
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[DragView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    
    [self.dragCollectionView reloadData];
    [self.dropCollectionView reloadData];
    [super calculateCellSize];
    
    // now scroll to the last item in collection view
    [Utils scrollToLastElement: self.dropCollectionView ofDictionary:self.targetCellsDict];
    
}



@end
