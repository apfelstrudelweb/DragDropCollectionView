//
//  MainView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"


@interface MainView() {
    
    // subview proportions
    float totalHeight;
    float totalWidth;
    int percentHeader1, percentHeader2, percentDragArea, percentDropArea, percentStepper;
    
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
    
    float itemSpacing;
    float cellWidthHeight;
    
    NSMutableDictionary* sourceCellsDict;
    NSMutableDictionary* targetCellsDict;
    
    NSIndexPath* prevIndexPath;
    
    NSIndexPath *finalInsertIndexPath;
    CollectionViewCell* leftCell, *rightCell;
    
    int numberOfDragItems;
    int numberOfDropItems;
    
    int numberOfColumns;
    
}

@end


@implementation MainView



- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        itemSpacing = [SHARED_CONFIG itemSpacing];
        sourceCellsDict = [SHARED_CONFIG dataSourceDict]; //[NSMutableDictionary new];
        targetCellsDict = [NSMutableDictionary new];
        
        numberOfDragItems = sourceCellsDict.count;
        numberOfDropItems = NUMBER_TARGET_ITEMS;
        
        self.headline1 = [[UILabel alloc] initWithFrame:frame];
        [self.headline1 setTextForHeadline:@"Drag and Drop Prototype"];
        [self.headline1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline1];
        
        self.headline2 = [[UILabel alloc] initWithFrame:frame];
        [self.headline2 setTextForHeadline:@"Drag elements from top to bottom"];
        [self.headline2 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline2];
        

        UICollectionViewFlowLayout *flowLayout1 = [[UICollectionViewFlowLayout alloc] init];
        
        [flowLayout1 setMinimumInteritemSpacing:itemSpacing];
        [flowLayout1 setMinimumLineSpacing:itemSpacing];
        
        
        self.collectionView1 = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout1];
        self.collectionView1.backgroundColor = [SHARED_CONFIG backgroundColorSourceView];
        
        self.collectionView1.delegate = self;
        self.collectionView1.dataSource = self;
        self.collectionView1.showsHorizontalScrollIndicator = NO;
        
        [self.collectionView1 registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell1"];
        self.collectionView1.tag = 1;
        
        [self addSubview:self.collectionView1];
        
        [self.collectionView1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        
        
        UICollectionViewFlowLayout *flowLayout2 = [[UICollectionViewFlowLayout alloc] init];
        
        [flowLayout2 setMinimumInteritemSpacing:itemSpacing];
        [flowLayout2 setMinimumLineSpacing:itemSpacing];
        
        //[flowLayout2 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        self.collectionView2 = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout2];
        self.collectionView2.backgroundColor = [SHARED_CONFIG backgroundColorTargetView];
        
        self.collectionView2.delegate = self;
        self.collectionView2.dataSource = self;
        self.collectionView2.showsVerticalScrollIndicator = YES;
        
        [self.collectionView2 registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell2"];
        self.collectionView2.tag = 2;
        
        [self addSubview:self.collectionView2];
        
        [self.collectionView2 setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self createStepper];
        
        
        self.viewsDictionary = @{   @"headline1"    : self.headline1,
                                    @"source"       : self.collectionView1,
                                    @"stepper"      : self.stepper,
                                    @"headline2"    : self.headline2,
                                    @"target"       : self.collectionView2 };
        
        
        [self setupConstraints];
        [self calculateCellSize];
        
        
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
// notification from InfoView: user has clicked into a red info cell "X"
- (void) receiveDeleteCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"deleteCellNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSIndexPath* indexPath = [userInfo objectForKey:@"indexPath"];
  
        // append empty cell in order to maintain a constant number of cells
        numberOfDropItems++;
        [self.collectionView2 performBatchUpdates:^{
            
            NSIndexPath* indexPathToAppend = [NSIndexPath indexPathForRow:numberOfDropItems-1 inSection:0];
            
            NSArray *indexPaths = [NSArray arrayWithObject:indexPathToAppend];
            [self.collectionView2 insertItemsAtIndexPaths:indexPaths];
            
        } completion: ^(BOOL finished) {
            [targetCellsDict  removeObjectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
            
        }];

    }
}


- (void) receiveShiftCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"shiftCellNotification"]) {
        
        
        NSDictionary *userInfo = notification.userInfo;
        NSIndexPath* indexPath = [userInfo objectForKey:@"indexPath"];
        
        numberOfDropItems--;
        [self.collectionView2 performBatchUpdates:^{
            //NSLog(@"item = %d", (int)indexPath.item);
            [self.collectionView2 deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            
        } completion: ^(BOOL finished) {
            // shift elements to left and remove empty ones
            [Utils eliminateEmptyKeysInDict:targetCellsDict];
            // important: reload data, otherwise empty cells could remain visible!
            [self.collectionView2 reloadData];
            
            [self scrollToLastElement];
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
    
    [self.collectionView1 reloadData];
    [self.collectionView2 reloadData];
    
    [self scrollToLastElement];
    
}

#pragma mark <UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    int number = collectionView.tag==1 ? numberOfDragItems: numberOfDropItems;
    return number;
}

-(CollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CollectionViewCell *cell;
    UIColor *color;
    
    NSString *cellData = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    
    if (collectionView.tag == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
        
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
        
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell2" forIndexPath:indexPath];
        cell.indexPath = indexPath;
        [cell initialize]; // make it gray and small (it's still a placeholder)
        
        // after scrolling, try to reuse the cell from the dictionary which tracks all populated cells
        CellModel* model = [targetCellsDict objectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
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
    
    return CGSizeMake(cellWidthHeight, cellWidthHeight);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    // put the first row a bit below - so when cell is to be inserted, the left and right cell has enough place to expand to the top as well
    if (collectionView.tag == 2) {
        return UIEdgeInsetsMake(0.5*itemSpacing, 0, 0, 0);
    }
    // don't change the insets of the source collection view
    return UIEdgeInsetsMake(0, 0, 0, 0);
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
    
    CGPoint tapLocationInCollectionView = [recognizer locationInView:self.collectionView2];
    CGPoint tapLocationInDragView = [recognizer locationInView:dragView];
    
    // negative offset -> left cell should not be highlighted when touch point is in the middle of two cells
    CollectionViewCell* dummyCell;
    
    
    // Get vertical scroll offset
    //
    // Important: when collection view is scrolled, all information about previous cells
    // (which are no more visible) are lost!
    // That's why we need to iterate over all cells and find the first one which can
    // provide the width and height of such.
    for (int i=0; i<[self.collectionView2 numberOfItemsInSection:0]; i++) {
        dummyCell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        if (dummyCell) {
            break;
        }
    }
    
    float cellWidth = dummyCell.bounds.size.width;
    float cellHeight = dummyCell.bounds.size.height; // is redundant, perhaps we'll need it in future
    float scrollY = self.collectionView2.contentOffset.y / self.collectionView2.frame.size.height;
    
    
    // now get the center of the dragged view -> we need two tap locations:
    // - first tap location related to the collection view and
    // - second tap location related to the dragged view
    float centerX = tapLocationInCollectionView.x - tapLocationInDragView.x + 0.5*cellWidth;
    float centerY = tapLocationInCollectionView.y - tapLocationInDragView.y + 0.5*cellHeight+scrollY;
    
    CGPoint correctedTapLocation = CGPointMake(centerX, centerY);
    
    NSIndexPath *dropIndexPath = [self.collectionView2 indexPathForItemAtPoint:correctedTapLocation];
    cell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:dropIndexPath];
    
    
    CellModel* model = [targetCellsDict objectForKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
    
    
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
            CellModel* prevModel = [targetCellsDict objectForKey:[NSNumber numberWithInt:(int)prevIndexPath.item]];
            CollectionViewCell* prevCell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:prevIndexPath];
            
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
            
            float leftX = correctedTapLocation.x - 0.5*cellWidth - 0.5*itemSpacing;
            
            CGPoint leftTapLocation = CGPointMake(leftX, correctedTapLocation.y);
            
            insertIndexPath = [self.collectionView2 indexPathForItemAtPoint:leftTapLocation];
            
            if (insertIndexPath) {
                //NSLog(@"finalInsertIndexPath: %ld", (long)insertIndexPath.item);
                finalInsertIndexPath = insertIndexPath;
                
                int item1 = (int)insertIndexPath.item;
                int item2 = item1 + 1;
                
                leftCell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:insertIndexPath];
                rightCell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:[NSIndexPath indexPathForRow:item2 inSection:0]];
                
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
        
        for (NSInteger row = 0; row < [self.collectionView2 numberOfItemsInSection:0]; row++) {
            CollectionViewCell* _cell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            
            if (_cell.isPushedToLeft) {
                indexPathToInsert = [NSIndexPath indexPathForRow:row+1 inSection:0];
                break;
            }
        }
        
        // insert cell
        if (indexPathToInsert) {
            
            __block CollectionViewCell* newCell;
            
            numberOfDropItems++;
            [self.collectionView2 performBatchUpdates:^{
                
                NSArray *indexPaths = [NSArray arrayWithObject:indexPathToInsert];
                [self.collectionView2 insertItemsAtIndexPaths:indexPaths];
                
            } completion: ^(BOOL finished) {
                
                newCell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:indexPathToInsert];
                
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
                
                NSDictionary* prevDict = [targetCellsDict mutableCopy];
                
                [targetCellsDict setObject:model forKey:[NSNumber numberWithInt:insertIndex]];
                
                [prevDict enumerateKeysAndObjectsUsingBlock:^(id key, id model, BOOL *stop) {
                    //NSLog(@"model - > %@ = %@", key, ((CellModel*)model).labelTitle);
                    int _key = [key intValue];
                    
                    if (_key > insertIndex - 1) {
                        //NSLog(@"xxxxxxxxx %@ = %@", key, model);
                        [targetCellsDict setObject:model forKey:[NSNumber numberWithInt:_key+1]];
                    }
                }];
                
            }];
            
            //NSLog(@"targetCellsDict: %@", targetCellsDict);
            
            // now remove last cell in order to maintain a constant number of cells
            numberOfDropItems--;
            [self.collectionView2 performBatchUpdates:^{
                
                NSIndexPath *indexPath =[NSIndexPath indexPathForRow:numberOfDropItems inSection:0];
                [self.collectionView2 deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
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
        
        [targetCellsDict setObject:model forKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
    }
    
}


#pragma mark -constraint issues
- (void)setupConstraints {
    
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
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView1
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView1
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightDragArea]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView1
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView2
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView2
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightDropArea]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView2
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
    
    //    // Center vertically
    //    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.stepper
    //                                                              attribute:NSLayoutAttributeCenterY
    //                                                              relatedBy:NSLayoutRelationEqual
    //                                                                 toItem:self
    //                                                              attribute:NSLayoutAttributeCenterY
    //                                                             multiplier:1.0
    //                                                               constant:0.0]];
    
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

#pragma mark -utility methods
- (void)scrollToLastElement {
    // now scroll to the last item in collection view
    int maxItem = [Utils getHighestKeyInDict:targetCellsDict];
    NSIndexPath* scrollToIndexPath = [NSIndexPath indexPathForItem:maxItem inSection:0];
    
    [self.collectionView2 scrollToItemAtIndexPath:scrollToIndexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
}

- (void) calculateCellSize {
    
    float collectionViewWidth;
    float collectionViewHeight;
    
    float occupiedHeight = 0.0;
    
    int N;
    
    
    collectionViewWidth  = totalWidth;
    collectionViewHeight = totalHeight*percentDragArea*0.01;
    N = (int)[self.collectionView1 numberOfItemsInSection:0];
    
    
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
        cellWidthHeight = floorf((collectionViewWidth - (cols-1)*itemSpacing)/cols);
        
        occupiedHeight = rows*cellWidthHeight + (rows-1)*itemSpacing;
        
        if (occupiedHeight > collectionViewHeight) {
            // if total height exceeds contentview, add an item to first row
            int cols = [matrixArray[0] intValue] + 1;
            cellWidthHeight = floorf((collectionViewWidth - (cols-1)*itemSpacing)/cols);
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

- (void) createStepper {
    
    self.stepper = [[UIStepper alloc] initWithFrame:CGRectZero];
    [self.stepper addTarget:self action:@selector(stepperChanged:) forControlEvents:UIControlEventValueChanged];
    [self.stepper setBackgroundColor:[UIColor clearColor]];
    [self.stepper setTranslatesAutoresizingMaskIntoConstraints:NO];
    self.stepper.value = numberOfDragItems;
    self.stepper.minimumValue = 2;
    self.stepper.maximumValue = 50;
    self.stepper.stepValue = 1;
    self.stepper.userInteractionEnabled = YES;
    self.stepper.tintColor = FONT_COLOR;
    
    [self addSubview:self.stepper];
    
}

- (void)stepperChanged:(UIStepper*)stepper {
    
    numberOfDragItems = self.stepper.value;
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[DragView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    
    [self.collectionView1 reloadData];
    [self.collectionView2 reloadData];
    [self calculateCellSize];
    
    // now scroll to the last item in collection view
    [self scrollToLastElement];
    
}



@end
