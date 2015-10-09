//
//  MainView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"
#import "UILabel+size.h"

#define SHARED_CONFIG_INSTANCE   [ConfigAPI sharedInstance]

@interface MainView() {
    
    float minLineSpacing;
    
    DragDropHelper* dragDropHelper;
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
        
        self.headline1 = [[UILabel alloc] initWithFrame:frame];
        [self.headline1 setTextForHeadline:@"Drag and Drop Prototype"];
        [self.headline1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline1];
        
        self.headline2 = [[UILabel alloc] initWithFrame:frame];
        [self.headline2 setTextForHeadline:@"Drag elements from top to bottom"];
        [self.headline2 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline2];
        
        // Prepare source collection view
        self.sourceCellsDict = [SHARED_CONFIG_INSTANCE getDataSourceDict];
        self.numberOfDragItems = (int)self.sourceCellsDict.count;

        self.dragCollectionView = [[DragCollectionView alloc] initWithFrame:frame withinView:self];
        [self.dragCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.dragCollectionView];
        
        // Prepare target collection view
        self.targetCellsDict = [NSMutableDictionary new];
        self.numberOfDropItems = [SHARED_CONFIG_INSTANCE getNumberOfDropItems];
        
        self.dropCollectionView = [[DropCollectionView alloc] initWithFrame:frame withinView:self sourceDictionary:self.sourceCellsDict targetDictionary:self.targetCellsDict];
        
        [self.dropCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.dropCollectionView];

        [super setupConstraints];
        
        // calculate the ideal cell size in order to use most of the available
        // space within the collection view - we need to call the method otherwise
        // we get problems after an interface rotation!
        self.cellSize = [self.dragCollectionView getBestFillingCellSize:self.dragCollectionViewSize];
        
        // Important - we need it for the UIPanGestureRecognizer
        dragDropHelper = [[DragDropHelper alloc] initWithView:self collectionViews:@[self.dragCollectionView, self.dropCollectionView] cellDictionaries:@[self.sourceCellsDict, self.targetCellsDict]];
        
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
            [cell populateWithContentsOfView:dragView withinCollectionView:collectionView];
        }
    } else {
        // fill all cells from DropCollectionView
        cell = [((DropCollectionView*)collectionView) getCell:indexPath];
        DropView* dropView = [self.targetCellsDict objectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
        if (dropView) {
            // contrary to the drag view, we need to put the drop view into a cell -> scroll issues
            [cell populateWithContentsOfView:dropView withinCollectionView:collectionView];
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

#pragma mark UIPanGestureRecognizer
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    [dragDropHelper handlePan:recognizer];
}


@end
