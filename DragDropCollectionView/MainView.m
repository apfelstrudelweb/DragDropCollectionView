//
//  MainView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"


@interface MainView() {
    
    float minLineSpacing;
    
    CollectionViewCell* lastHoverCell;
    CollectionViewCell* lastLeftCell;
    //    CollectionViewCell* lastRightCell;
    
    CollectionViewCell* leftCell;
    CollectionViewCell* rightCell;
    
    //
    //    NSIndexPath *finalInsertIndexPath;
    //    CollectionViewCell* leftCell, *rightCell;
    DragView* targetDragView;
    DragView* newDragView;
}

@end


@implementation MainView



- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        minLineSpacing = [SHARED_CONFIG_INSTANCE getMinLineSpacing];
        
        self.sourceCellsDict = [SHARED_CONFIG_INSTANCE getDataSourceDict];
        self.targetCellsDict = [NSMutableDictionary new];
        
        self.numberOfDragItems = (int)self.sourceCellsDict.count;
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
        
        
        [super setupConstraints];
        //[super calculateCellSize];
        self.cellSize = [self.dragCollectionView getBestFillingCellSize:self.dragCollectionViewSize];
        
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
    
    // IMPORTANT: all cells are populated by "UIView objects" stored in dictionaries
    if ([collectionView isKindOfClass:[DragCollectionView class]]) {
        // fill all cells from DragCollectionView
        cell = [((DragCollectionView*)collectionView) getCell:indexPath];
        DragView* dragView = [self.sourceCellsDict objectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
        // simply put the view like a layer over the main view and exactly congruently to the correspondent cell - the view must be draggable!
        if (dragView) {
            // we need to put the dragView on the main view in order to make it draggable
            // within the whole view
            CGRect dragRect = [Utils getCellCoordinates:cell fromCollectionView:collectionView];
            [dragView setFrame:dragRect];
            [self addSubview:dragView];
        }
    } else {
        // fill all cells from DropCollectionView
        cell = [((DropCollectionView*)collectionView) getCell:indexPath];
        
        //[self.targetCellsDict log];
        
        DropView* dropView = [self.targetCellsDict objectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
        if (dropView) {
            // contrary to the drag view, we need to put the drop view into a cell -> scroll issues
            [cell populateWithContentsOfView:dropView];
        }
    }
    
    return cell;
}



#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellSize;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if ([collectionView isKindOfClass:[DragCollectionView class]]) {
        // don't change the insets of the source collection view
        return UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        // let small space above - so when cell is to be inserted, the left and right cell has enough place to expand to the top as well
        return UIEdgeInsetsMake(0.5*minLineSpacing, 0, 0, 0);
    }
}


- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    
    DragView* dragView = (DragView*)recognizer.view;
    [self bringSubviewToFront:dragView];
    
    
    // START DRAGGING
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        // provide a temporary DragView as snapshot for the dragging process
        // which will be removed again when dragging is finished
        newDragView = (DragView*)[dragView snapshotViewAfterScreenUpdates:NO];
        newDragView.frame = dragView.frame;
        targetDragView = [dragView provideNew];
        [self addSubview:newDragView];
        
        lastHoverCell = nil;
        [SHARED_STATE_INSTANCE setTransactionActive:true]; // indicate that view is in drag state
    }
    
    
    
    // DURING DRAGGING
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        // during dragging, we use a snapshot of the content view
        //[dragView setContentView:newContentView];
        [dragView initialize];
        // move drag view AFTER cloning of itself - otherwise we get a vertical offset
        [dragView move:recognizer inView:self];
        
        if (leftCell.isPopulated && rightCell.isPopulated) {
            [leftCell undoPush];
            [rightCell undoPush];
        }
        
        // reset all cells (from previous touches)
        [self.dropCollectionView resetAllCells];
        
        
        CollectionViewCell* hoverCell = [Utils getTargetCell:dragView inCollectionView:self.dropCollectionView recognizer:recognizer];
        
        if (hoverCell) {
            [hoverCell expand];
            return;
        }
        
        NSArray* insertCells = [Utils getInsertCells:dragView inCollectionView:self.dropCollectionView recognizer:recognizer];
        
        if (!insertCells) {
            lastLeftCell = nil;
            
            return;
        }
        
        //NSLog(@"insertCells: %@", insertCells);
        
        leftCell  = insertCells[0];
        rightCell = insertCells[1];
        
        [leftCell push:Left];
        [rightCell push:Right];
        
    }
    
    // END DRAGGING AND START DROPPING
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        // Remove temporary DragView (it's only a snapshot) and replace it by a real one
        CGRect frame = newDragView.frame;
        [newDragView removeFromSuperview];
        newDragView = [dragView provideNew];
        newDragView.frame = frame;
        [self addSubview:newDragView];
        // we need to update the dictionary - otherwise we get empty custom views!
        [self.sourceCellsDict setObject:newDragView forKey:[NSNumber numberWithInt:dragView.index]];
        
        
        
        CollectionViewCell* dropCell = [Utils getTargetCell:dragView inCollectionView:self.dropCollectionView recognizer:recognizer];
        // if view is not dropped into a valid cell, remove it
        if (!dropCell) {
            [dragView removeFromSuperview];
            [self.dropCollectionView reloadData];
            [SHARED_STATE_INSTANCE setTransactionActive:false];
            return;
        }
        NSIndexPath* dropIndexPath = dropCell.indexPath;
        // drop view into the cell, making a copy of the dragged element and remove the dragged one
        DropView* dropView = [[DropView alloc] initWithView:targetDragView inCollectionViewCell:dropCell];
        // when dragged view is dropped, remove it as it is replaced by this drop view
        [dragView removeFromSuperview];
        // [dropView setIndex:(int)dropIndexPath.item];
        // populate dictionary -> we need it for "cellForItemAtIndexPath"
        
        //DropView* copyOfDropView = [dropView provideNew];
        
        [self.targetCellsDict setObject:dropView forKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
        // reload in order to show the new drop view - > "cellForItemAtIndexPath"
        [self.dropCollectionView reloadData];
        [SHARED_STATE_INSTANCE setTransactionActive:false];
    }
}



//- (void)_handlePan:(UIPanGestureRecognizer *)recognizer {
//
//
//    CollectionViewCell* cell;
//    finalInsertIndexPath = nil;
//
//    DragView* dragView = (DragView*)recognizer.view;
//
//    [self bringSubviewToFront:dragView];
//
//    // TODO: when View is in end position, don't add subviews!!
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
//        // Important: deliver new view when the old view has been dropped into the target cell
//        //[dragView supplyNewDragView:self.dragCollectionView];
//        DragView *newDragView = [dragView clone];
//
//        [self.dragCollectionView.superview addSubview:newDragView];
//
//
//        prevIndexPath = nil;
//    }
//
//
//    CGPoint translation = [recognizer translationInView:self];
//    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
//                                         recognizer.view.center.y + translation.y);
//    [recognizer setTranslation:CGPointMake(0, 0) inView:self];
//
//    CGPoint tapLocationInCollectionView = [recognizer locationInView:self.dropCollectionView];
//    CGPoint tapLocationInDragView = [recognizer locationInView:dragView];
//
//    // negative offset -> left cell should not be highlighted when touch point is in the middle of two cells
//    CollectionViewCell* dummyCell;
//
//
//    // Get vertical scroll offset
//    //
//    // Important: when collection view is scrolled, all information about previous cells
//    // (which are no more visible) are lost!
//    // That's why we need to iterate over all cells and find the first one which can
//    // provide the width and height of such.
//    for (int i=0; i<[self.dropCollectionView numberOfItemsInSection:0]; i++) {
//        dummyCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
//        if (dummyCell) {
//            break;
//        }
//    }
//
//    float cellWidth = dummyCell.bounds.size.width;
//    float cellHeight = dummyCell.bounds.size.height; // is redundant, perhaps we'll need it in future
//    float scrollY = self.dropCollectionView.contentOffset.y / self.dropCollectionView.frame.size.height;
//
//
//    // now get the center of the dragged view -> we need two tap locations:
//    // - first tap location related to the collection view and
//    // - second tap location related to the dragged view
//    float centerX = tapLocationInCollectionView.x - tapLocationInDragView.x + 0.5*cellWidth;
//    float centerY = tapLocationInCollectionView.y - tapLocationInDragView.y + 0.5*cellHeight+scrollY;
//
//    CGPoint correctedTapLocation = CGPointMake(centerX, centerY);
//
//    NSIndexPath *dropIndexPath = [self.dropCollectionView indexPathForItemAtPoint:correctedTapLocation];
//    cell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:dropIndexPath];
//
//    DragView* view = [self.targetCellsDict objectForKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
//
//    if (!view) {
//        [cell highlightEmptyOne];
//        [cell expandEmptyOne];
//    } else {
//        // when a cell is populated, fade out the color in order to indicate that this cell may be overwritten by putting a new object above
//        [cell highlightPopulatedOne];
//    }
//
//
//    // when a cell is left without dropping an object onto it, perform a reset
//    if (![dropIndexPath isEqual:prevIndexPath]) {
//        if (prevIndexPath != nil) {
//            // watch out after scrolling -> check if model in array exists
//            DragView* prevView = [self.targetCellsDict objectForKey:[NSNumber numberWithInt:(int)prevIndexPath.item]];
//            CollectionViewCell* prevCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:prevIndexPath];
//
//            if (!prevView) {
//                // when cell is left, shrink again
//                [prevCell shrinkEmptyOne];
//                [prevCell unhighlightEmptyOne];
//
//            } else {
//                // when populated cell is left again, release the color lightening
//                [prevCell unhighlightPopulatedOne];
//            }
//        }
//        prevIndexPath = dropIndexPath;
//
//        NSIndexPath *insertIndexPath;
//
//        if (leftCell.isPopulated && rightCell.isPopulated) {
//            [leftCell pushBack];
//            [rightCell pushBack];
//        }
//
//        // if specific cell isn't touched, figure out if we are between two cells
//        if (!dropIndexPath) {
//
//            float leftX = correctedTapLocation.x - 0.5*cellWidth - 0.5*itemSpacing;
//
//            CGPoint leftTapLocation = CGPointMake(leftX, correctedTapLocation.y);
//
//            insertIndexPath = [self.dropCollectionView indexPathForItemAtPoint:leftTapLocation];
//
//            if (insertIndexPath) {
//                //NSLog(@"finalInsertIndexPath: %ld", (long)insertIndexPath.item);
//                finalInsertIndexPath = insertIndexPath;
//
//                int item1 = (int)insertIndexPath.item;
//                int item2 = item1 + 1;
//
//                leftCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:insertIndexPath];
//                rightCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:item2 inSection:0]];
//
//                if (leftCell.isPopulated && rightCell.isPopulated) {
//                    [leftCell pushToLeft];
//                    [rightCell pushToRight];
//                }
//            }
//        }
//    }
//
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
//        // drop view into the cell, making a copy of the dragged element and remove the dragged one
//        DropView* dropView = [[DropView alloc] initWithView:dragView inCollectionViewCell:cell];
//        [self.targetCellsDict setObject:dropView forKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
//        // reload in order to show the new drop view from the targetCellsDict
//        //[self.dropCollectionView reloadData];
//    }
//
////    if (recognizer.state == UIGestureRecognizerStateEnded) {
////
////        //
////        //        if (!cell) {
////        //            // if not dropped into a cell, remove it
////        //            [dragView removeFromSuperview];
////        //            return;
////        //        }
////
////        NSIndexPath* indexPathToInsert;
////
////        for (NSInteger row = 0; row < [self.dropCollectionView numberOfItemsInSection:0]; row++) {
////            CollectionViewCell* _cell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
////
////            if (_cell.isPushedToLeft) {
////                indexPathToInsert = [NSIndexPath indexPathForRow:row+1 inSection:0];
////                break;
////            }
////        }
////
////        // insert cell
////        if (indexPathToInsert) {
////
////            __block CollectionViewCell* newCell;
////
////            self.numberOfDropItems++;
////            [self.dropCollectionView performBatchUpdates:^{
////
////                NSArray *indexPaths = [NSArray arrayWithObject:indexPathToInsert];
////                [self.dropCollectionView insertItemsAtIndexPaths:indexPaths];
////
////            } completion: ^(BOOL finished) {
////
////                newCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:indexPathToInsert];
////
////
//////                //[cell unhighlightPopulatedOne];
//////                [newCell setColor:[dragView getColor]];
//////                [newCell setLabelTitle:[dragView getLabelTitle]];
//////                [newCell setLabelColor:[dragView getLabelColor]];
//////                [newCell setCellSubview:[dragView getSubview]];
//////                [newCell initialize]; // don't omit otherwise overwritten cells will have multiple labels!
////                [newCell populateWithContentsOfView:dragView];
////
////
//////                CellModel* model = [CellModel new];
//////                [model setColor:dragView.backgroundColor];
//////                [model setLabelTitle:[dragView getLabelTitle]];
//////                //[model setImageView:dragView.imageView];
////
////
////                // Now update dictionary, shifting all elements right of the insert index to right
////                int insertIndex = (int)indexPathToInsert.item;
////                [self.targetCellsDict insertObject: dragView atIndex:insertIndex];
////                int maxItems = (int)[self.dropCollectionView numberOfItemsInSection:0];
////                int maxKey = [Utils getHighestKeyInDict:self.targetCellsDict];
////
////                // avoid overflow of dictionary
////                if (maxKey > maxItems-1) {
////                    [self.targetCellsDict removeObjectForKey:[NSNumber numberWithInt:maxItems]];
////                }
////
////                 [dragView removeFromSuperview];
////
////            }];
////
////            //NSLog(@"targetCellsDict: %@", targetCellsDict);
////
////            // now remove last cell in order to maintain a constant number of cells
////            self.numberOfDropItems--;
////            [self.dropCollectionView performBatchUpdates:^{
////
////                NSIndexPath *indexPath =[NSIndexPath indexPathForRow:self.numberOfDropItems inSection:0];
////                [self.dropCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
////            } completion: ^(BOOL finished) {
////                finalInsertIndexPath = nil;
////                [leftCell pushBack];
////                [rightCell pushBack];
////
////                leftCell = nil;
////                rightCell = nil;
////            }];
////            return;
////        }
////
////        // populate cell
////        [cell initialize]; // don't omit otherwise overwritten cells will have multiple labels!
////        // when new object is put on it, release the color lightening
////        [cell unhighlightPopulatedOne];
////
////        [cell populateWithContentsOfView:dragView];
////
////        DropView* dropView = [[DropView alloc] initWithView:dragView];
////
////        [self.targetCellsDict setObject:dropView forKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
////
////        [dragView removeFromSuperview];
////
////    }
//    
//}

@end
