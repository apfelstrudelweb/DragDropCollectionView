//
//  MainView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"


@interface MainView() {
    
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
    
    float itemSpacing;
    int numberOfItemsInLine;
    
    NSMutableDictionary* sourceCellsDict;
    NSMutableDictionary* targetCellsDict;
    
    NSIndexPath* prevIndexPath;
    
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
        numberOfItemsInLine = NUMBER_ITEMS_IN_LINE;
        
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
        //[self setupConstraints1:self.collectionView1];
        
        
        
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
        //[self setupConstraints2:self.collectionView2];
        
//        self.collectionView1.backgroundColor = [UIColor yellowColor];
//        self.collectionView2.backgroundColor = [UIColor greenColor];
        
        self.viewsDictionary = @{   @"headline1"    : self.headline1,
                                    @"source"       : self.collectionView1,
                                    @"headline2"    : self.headline2,
                                    @"target"       : self.collectionView2 };
        
        [self setupConstraints];
        
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
    
    numberOfItemsInLine = NUMBER_ITEMS_IN_LINE;
    
    for (UIView *subview in self.subviews) {
        if ([subview isKindOfClass:[DragView class]]) {
            [subview removeFromSuperview];
        }
    }
    
    [self.collectionView1 reloadData];
    [self.collectionView2 reloadData];
    
    [self setupConstraints];
}

#pragma mark <UICollectionViewDataSource>
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    int number = collectionView.tag==1 ? NUMBER_SOURCE_ITEMS: NUMBER_TARGET_ITEMS;
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
    
    float collectionViewWidth;
    
    if (collectionView.tag == 1) {
        collectionViewWidth = self.collectionView1.frame.size.width;
    } else {
        collectionViewWidth = self.collectionView2.frame.size.width;
    }
    
    //int numberOfRowsInSource = NUMBER_SOURCE_ITEMS / numberOfItemsInLine;
    
    // we want [NUMBER_ITEMS_IN_LINE] cells in a numberOfRowsline
    float cellWidth = floorf((collectionViewWidth - (numberOfItemsInLine-1)*itemSpacing)/numberOfItemsInLine);
    float cellHeight = cellWidth;

    return CGSizeMake(cellWidth, cellHeight);
    
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
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    int topMargin = IS_LANDSCAPE ? MARGIN : 2*MARGIN;
    
    NSString* visualFormatText = [NSString stringWithFormat:@"V:|-%d-[headline1]-%d-[source]-%d-[headline2]-%d-[target]", topMargin, MARGIN, MARGIN, MARGIN];
    

    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                                           options:0
                                                                                           metrics:nil
                                                                                             views:self.viewsDictionary];
    
    for (int i = 0; i<visualFormatConstraints.count; i++) {
        [self addConstraint:visualFormatConstraints[i]];
    }
    
    
    layoutConstraints = [NSMutableArray new];
    
    float h1 = IS_LANDSCAPE ? 0.4 : 0.35;
    
    
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView1
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0.9
                                                                constant:0]];

    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView1
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:h1
                                                                constant:0.0]];
    
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
                                                              multiplier:0.9
                                                                constant:0]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView2
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeHeight
                                                              multiplier:0.5
                                                                constant:0]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.collectionView2
                                                               attribute:NSLayoutAttributeCenterX
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeCenterX
                                                              multiplier:1.0
                                                                constant:0.0]];
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline1
                                                               attribute:NSLayoutAttributeWidth
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeWidth
                                                              multiplier:0.9
                                                                constant:0]];
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
                                                              multiplier:0.9
                                                                constant:0]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline2
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
