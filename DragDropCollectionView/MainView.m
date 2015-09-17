//
//  MainView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"
#define NUMBER_ITEMS_IN_LINE 4

#define NUMBER_SOURCE_ITEMS 10
#define NUMBER_TARGET_ITEMS 20


@interface MainView() {
    
    NSMutableArray* layoutConstraints1;
    NSMutableArray* layoutConstraints2;
    
    float itemSpacing;
    
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
        
        itemSpacing = 5.0;
        
        targetCellsDict = [NSMutableDictionary new];
        
        //self.backgroundColor = [UIColor greenColor];
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
        [self setupConstraints1:self.collectionView1];
        
        
        
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
        [self setupConstraints2:self.collectionView2];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveDeleteCellNotification:) name:@"deleteCellNotification"
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
        
        [self.collectionView2 reloadData];
    }
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
    
    //NSLog(@"%ld", (long)collectionView.tag);
    NSString *cellData = [NSString stringWithFormat:@"%ld", (long)indexPath.item];
    
    if (collectionView.tag == 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell1" forIndexPath:indexPath];
        
        [cell reset];
        [cell setLabelTitle:cellData];
        
        NSInteger aRedValue = arc4random()%255;
        NSInteger aGreenValue = arc4random()%255;
        NSInteger aBlueValue = arc4random()%255;
        
        color = [UIColor colorWithRed:aRedValue/255.0f green:aGreenValue/255.0f blue:aBlueValue/255.0f alpha:1.0f];
        
        
        CGPoint origin = collectionView.frame.origin;
        float x = origin.x;
        float y = origin.y;
        
        CGPoint cellOrigin = cell.frame.origin;
        float cellX = cellOrigin.x;
        float cellY = cellOrigin.y;
        float w = cell.frame.size.width;
        float h = cell.frame.size.height;
        
        
        //origCellSize = CGSizeMake(w, h);
        
        
        CGRect dragRect = CGRectMake(x+cellX, y+cellY, w, h);
        
        DragView* dragView = [[DragView alloc] initWithFrame:dragRect];
        [dragView setBackgroundColor:color];
        cell.colorView.backgroundColor = color;
        [dragView setLabel:cellData];

        
        UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [recognizer setMaximumNumberOfTouches:1];
        [recognizer setMinimumNumberOfTouches:1];
        
        [dragView addGestureRecognizer:recognizer];
        
        [self addSubview:dragView];
        
    } else {

        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell2" forIndexPath:indexPath];
        cell.indexPath = indexPath;
        [cell reset];
        
        // after scrolling, try to reuse the cell
        CellModel* model = [targetCellsDict objectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
        if (model) {
            [cell setColor:model.color];
            [cell setLabelTitle:model.labelTitle];
        } 
        
    }

    
    return cell;
}



- (void)handlePan:(UIPanGestureRecognizer *)recognizer {

    DragView* dragView = (DragView*)recognizer.view;
    
    [self bringSubviewToFront:dragView];
    
    // TODO: when View is in end position, don't add subviews!!
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // Important: deliver new view when the old view has been dropped into the target cell
        DragView *newDragView = [DragView new];//(DragView *)copyOfView;
        newDragView.frame = dragView.frame;
        newDragView.backgroundColor = dragView.backgroundColor;
        [newDragView setLabel:[dragView getLabelTitel]];
        
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
        [cell highlight];
        [cell expandColorView];
    } else {
        cell.colorView.alpha = 0.4;
    }
   
    
    //if (![cell isEqual:prevCell]) {
    if (![dropIndexPath isEqual:prevIndexPath]) {
        if (prevIndexPath!=nil) {
            // watch out after scrolling -> check if model in array exists
            CellModel* prevModel = [targetCellsDict objectForKey:[NSNumber numberWithInt:(int)prevIndexPath.item]];
            CollectionViewCell* prevCell = (CollectionViewCell*)[self.collectionView2 cellForItemAtIndexPath:prevIndexPath];
            prevCell.colorView.alpha = 1.0;
            if (!prevModel) {
                
                [prevCell shrinkColorView];
                [prevCell unhighlight];
                
            }
        }
        prevIndexPath = dropIndexPath;
    }

    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        if (!cell) {
            [dragView removeFromSuperview];
            return;
        }
        
        [cell reset];
        cell.colorView.alpha = 1.0;
        
        [cell setColor: dragView.backgroundColor];
        [cell setLabelTitle:[dragView getLabelTitel]];
        
        [dragView removeFromSuperview];
        
        UIPanGestureRecognizer* recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
        [recognizer setMaximumNumberOfTouches:1];
        [recognizer setMinimumNumberOfTouches:1];
        
        [cell addGestureRecognizer:recognizer];

        CellModel* model = [CellModel new];
        [model setColor:dragView.backgroundColor];
        [model setLabelTitle:[dragView getLabelTitel]];
        
        [targetCellsDict setObject:model forKey:[NSNumber numberWithInt:(int)dropIndexPath.item]];
        //NSLog(@"dropIndexPath: %ld", (long)dropIndexPath.item);
        
        
        //[activeCellsArray addObject:cell];

    }
    
}

- (void)handlePan2:(UIPanGestureRecognizer *)recognizer {
    
    //    CGPoint tapLocation = [recognizer locationInView:self.collectionView2];
    //    NSIndexPath *dropIndexPath = [self.collectionView2 indexPathForItemAtPoint:tapLocation];
    //    UICollectionViewCell* cell = [self.collectionView2 cellForItemAtIndexPath:dropIndexPath];
    //
    //    if (recognizer.state == UIGestureRecognizerStateBegan) {
    //        if (dropIndexPath) {
    //
    //            cell.layer.backgroundColor = [UIColor grayColor].CGColor;
    //
    //            int index = (int)dropIndexPath.item;
    //
    //            droppedCellArray = [self getShiftedArray:[droppedCellArray mutableCopy] inIndex:index];
    //
    //            [self.collectionView2 reloadData];
    //            //[self.collectionView2 deleteItemsAtIndexPaths:@[[self.collectionView2 indexPathForCell:cell]]];
    //        }
    //    }
    
}



#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGRect rect;
    
    if (collectionView.tag == 1) {
        rect = self.collectionView1.frame;
    } else {
        rect = self.collectionView2.frame;
    }
    
    float w = rect.size.width;
    
    // we want x recs in a line
    float w1 = (w - (NUMBER_ITEMS_IN_LINE-1)*itemSpacing)/NUMBER_ITEMS_IN_LINE;
    float h1 = w1;
    
    [SHARED_MANAGER setOriginalCellWidth:w1];
    [SHARED_MANAGER setOriginalCellHeight:h1];
    
    return CGSizeMake(w1, h1);
    
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath  {

}


#pragma mark -constraint issues

- (void)setupConstraints1: (UICollectionView*) collectionView {
    
    [self removeConstraints:layoutConstraints1];
    layoutConstraints1 = [NSMutableArray new];
    
    // Width constraint
    [layoutConstraints1 addObject:[NSLayoutConstraint constraintWithItem:collectionView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.9
                                                      constant:0]];
    
    // Height constraint
    [layoutConstraints1 addObject:[NSLayoutConstraint constraintWithItem:collectionView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.4
                                                      constant:0]];
    
    // Center horizontally
    [layoutConstraints1 addObject:[NSLayoutConstraint constraintWithItem:collectionView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [layoutConstraints1 addObject:[NSLayoutConstraint constraintWithItem:collectionView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:0.5
                                                      constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutConstraints1];
}

- (void)setupConstraints2: (UICollectionView*) collectionView {
    
    [self removeConstraints:layoutConstraints2];
    layoutConstraints2 = [NSMutableArray new];
    
    // Width constraint
    [layoutConstraints2 addObject:[NSLayoutConstraint constraintWithItem:collectionView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.9
                                                      constant:0]];
    
    // Height constraint
    [layoutConstraints2 addObject:[NSLayoutConstraint constraintWithItem:collectionView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.4
                                                      constant:0]];
    
    // Center horizontally
    [layoutConstraints2 addObject:[NSLayoutConstraint constraintWithItem:collectionView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [layoutConstraints2 addObject:[NSLayoutConstraint constraintWithItem:collectionView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.5
                                                      constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutConstraints2];
}


@end
