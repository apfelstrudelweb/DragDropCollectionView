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
    
    int numberOfDragItems;
    
}

@end


@implementation MainView

- (id)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

        self.headline1 = [[UILabel alloc] initWithFrame:frame];
        [self.headline1 setTextForHeadline:@"Drag and Drop Prototype"];
        [self.headline1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline1];
        
        self.headline2 = [[UILabel alloc] initWithFrame:frame];
        [self.headline2 setTextForHeadline:@"Drag elements from top to bottom"];
        [self.headline2 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline2];
        
        
        targetCellsDict = [NSMutableDictionary new];
        sourceCellsDict = [NSMutableDictionary new];
        
        itemSpacing = SPACE_BETWEEN_ITEMS;
        
        UICollectionViewFlowLayout *flowLayout1 = [[UICollectionViewFlowLayout alloc] init];
        
        [flowLayout1 setMinimumInteritemSpacing:itemSpacing];
        [flowLayout1 setMinimumLineSpacing:itemSpacing];
        
        
        self.collectionView1 = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout1];
        
        self.collectionView1.delegate = self;
        self.collectionView1.dataSource = self;
        self.collectionView1.showsHorizontalScrollIndicator = NO;
        self.collectionView1.backgroundColor = [UIColor whiteColor];
        
        [self.collectionView1 registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell1"];
        self.collectionView1.tag = 1;
        
        [self addSubview:self.collectionView1];
        
        [self.collectionView1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        
        
        UICollectionViewFlowLayout *flowLayout2 = [[UICollectionViewFlowLayout alloc] init];
        
        [flowLayout2 setMinimumInteritemSpacing:itemSpacing];
        [flowLayout2 setMinimumLineSpacing:itemSpacing];
        
        //[flowLayout2 setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        self.collectionView2 = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:flowLayout2];
        
        self.collectionView2.delegate = self;
        self.collectionView2.dataSource = self;
        self.collectionView2.showsVerticalScrollIndicator = YES;
        self.collectionView2.backgroundColor = [UIColor whiteColor];
        
        [self.collectionView2 registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"cell2"];
        self.collectionView2.tag = 2;
        
        [self addSubview:self.collectionView2];
        
        [self.collectionView2 setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self createStepper];

        
        self.collectionView1.backgroundColor = [UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0];
//        self.collectionView2.backgroundColor = [UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0];
        
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
        
        [targetCellsDict  removeObjectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
    }
}

- (void) receiveShiftCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"shiftCellNotification"]) {
        
        // shift elements to left and remove empty ones
        [Utils eliminateEmptyKeysInDict:targetCellsDict];
        
        // refresh collection view so that changes can take effect
        [self.collectionView2 reloadData];
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
    
    
}

#pragma mark <UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {

    int number = collectionView.tag==1 ? numberOfDragItems: NUMBER_TARGET_ITEMS;
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
        }
    }
    
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return CGSizeMake(cellWidthHeight, cellWidthHeight);
}



#pragma mark -UIPanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
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
    
    CGPoint tapLocation = [recognizer locationInView:self.collectionView2];
    NSIndexPath *dropIndexPath = [self.collectionView2 indexPathForItemAtPoint:tapLocation];
    CollectionViewCell* cell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:dropIndexPath];
    
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
    }
    
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (!cell) {
            // if not dropped into a cell, remove it
            [dragView removeFromSuperview];
            return;
        }
        
        [cell initialize]; // don't omit otherwise overwritten cells will have multiple labels!
        // when new object is put on it, release the color lightening
        [cell unhighlightPopulatedOne];
        
        [cell setColor: dragView.backgroundColor];
        [cell setLabelTitle:[dragView getLabelTitel]];
        
        [dragView removeFromSuperview];
        
        CellModel* model = [CellModel new];
        [model setColor:dragView.backgroundColor];
        [model setLabelTitle:[dragView getLabelTitel]];
        
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
    self.stepper.value = NUMBER_SOURCE_ITEMS;
    self.stepper.minimumValue = 2;
    self.stepper.maximumValue = 50;
    self.stepper.stepValue = 1;
    self.stepper.userInteractionEnabled = YES;
    self.stepper.tintColor = FONT_COLOR;
    
    numberOfDragItems = self.stepper.value;
    
    
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

}



@end
