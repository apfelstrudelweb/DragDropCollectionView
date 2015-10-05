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
    
    NSArray* insertCells;
    CollectionViewCell* leftCell;
    CollectionViewCell* rightCell;
    int insertIndex;
    CollectionViewCell* dropCell;
    
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


- (void)handleInitialDragView:(DragView *)dragView {
    // Remove temporary DragView (it's only a snapshot) and replace it by a real one
    CGRect frame = newDragView.frame;
    [newDragView removeFromSuperview];
    newDragView = [dragView provideNew];
    newDragView.frame = frame;
    [self addSubview:newDragView];
    // we need to update the dictionary - otherwise we get empty custom views!
    [self.sourceCellsDict setObject:newDragView forKey:[NSNumber numberWithInt:dragView.index]];
}

- (void)insertCell:(DragView *)dragView {
    NSIndexPath* insertionIndexPath = rightCell.indexPath;
    
    __block CollectionViewCell* newCell;
    
    self.numberOfDropItems++;
    [self.dropCollectionView performBatchUpdates:^{
        
        NSArray *indexPaths = [NSArray arrayWithObject:insertionIndexPath];
        [self.dropCollectionView insertItemsAtIndexPaths:indexPaths];
        
    } completion: ^(BOOL finished) {
        
        newCell = (CollectionViewCell*)[self.dropCollectionView cellForItemAtIndexPath:insertionIndexPath];
        
        dropCell = newCell;
        
        DropView* dropView = [[DropView alloc] initWithView:targetDragView inCollectionViewCell:dropCell];
        
        // Now update dictionary, shifting all elements right of the insert index to right
        insertIndex = (int)insertionIndexPath.item;
        [self.targetCellsDict insertObject: dropView atIndex:insertIndex];
        int maxItems = (int)[self.dropCollectionView numberOfItemsInSection:0];
        int maxKey = [Utils getHighestKeyInDict:self.targetCellsDict];
        
        // avoid overflow of dictionary
        if (maxKey > maxItems-1) {
            [self.targetCellsDict removeObjectForKey:[NSNumber numberWithInt:maxItems]];
        }
        
        // when dragged view is dropped, remove it as it is replaced by this drop view
        [dragView removeFromSuperview];
        
        [leftCell undoPush];
        [rightCell undoPush];
        
        // reload in order to show the new drop view - > "cellForItemAtIndexPath"
        [self.dropCollectionView reloadData];
        
    }];
    
    
    // now remove last cell in order to maintain a constant number of cells
    self.numberOfDropItems--;
    [self.dropCollectionView performBatchUpdates:^{
        
        NSIndexPath *indexPath =[NSIndexPath indexPathForRow:self.numberOfDropItems inSection:0];
        [self.dropCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
    } completion: ^(BOOL finished) {
        
        leftCell = nil;
        rightCell = nil;
    }];
}

- (void)appendCell:(UIPanGestureRecognizer *)recognizer dragView:(DragView *)dragView {
    dropCell = [Utils getTargetCell:dragView inCollectionView:self.dropCollectionView recognizer:recognizer];
    
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
        
        insertCells = [Utils getInsertCells:dragView inCollectionView:self.dropCollectionView recognizer:recognizer];
        
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
        
        [self handleInitialDragView:dragView];
        
        // insert cell
        if (insertCells) {
            [self insertCell:dragView];
            
        } else {
            [self appendCell:recognizer dragView:dragView];

        }
        
        
        // reload in order to show the new drop view - > "cellForItemAtIndexPath"
        [self.dropCollectionView reloadData];
        [SHARED_STATE_INSTANCE setTransactionActive:false];
    }
}


@end
