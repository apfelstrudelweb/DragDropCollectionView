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
#define SHARED_BUTTON_INSTANCE   [UndoButtonHelper sharedInstance]

@interface MainView() {
    
    float minLineSpacing;
}

@end


@implementation MainView



- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}


- (instancetype)initWithFrame:(CGRect)frame {
    
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
        
        self.undoButton = [UIButton new];
        UIImage* btnImage = [UIImage imageWithCGImage:[UIImage imageNamed:@"undo.png"].CGImage]; // trick for @2x.png
        [self.undoButton setImage:btnImage forState:UIControlStateNormal];
        [self.undoButton setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.undoButton];
        [SHARED_BUTTON_INSTANCE initWithButton:self.undoButton];
        
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
        
        if (true) {
            self.cellSize = CGSizeMake(100, 50);
        } else {
            self.cellSize = [self.dragCollectionView getBestFillingCellSize:self.dragCollectionViewSize];
        }
        
        
        // Important - we need it for drag & drop functionality!
        [[DragDropHelper sharedInstance] initWithView:self collectionViews:@[self.dragCollectionView, self.dropCollectionView] cellDictionaries:@[self.sourceCellsDict, self.targetCellsDict]];
        
        
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
        DragView* dragView = (self.sourceCellsDict)[@((int)indexPath.item)];

        [cell populateWithContentsOfView:dragView withinCollectionView:collectionView];
        
    } else {
        // fill all cells from DropCollectionView
        cell = [((DropCollectionView*)collectionView) getCell:indexPath];
        DropView* dropView = (self.targetCellsDict)[@((int)indexPath.item)];

        [cell populateWithContentsOfView:dropView withinCollectionView:collectionView];
    }
    return cell;
}


#pragma mark <UICollectionViewDelegate>
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    return self.cellSize;
//    return CGSizeMake(100, 50);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if ([collectionView isKindOfClass:[DragCollectionView class]]) {
        // don't change the insets of the source collection view
        return UIEdgeInsetsMake(0, 0, 0, 0);
    } else {
        // let small space above - so when cell is to be inserted, the left and right cell has enough place to expand to the top as well
        return UIEdgeInsetsMake(minLineSpacing, 0, 0, 0);
    }
}

#pragma mark <UIScrollViewDelegate>
// synchronize scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint currentOffset = scrollView.contentOffset;
    
    if ([scrollView isKindOfClass:[DragCollectionView class]]) {
        self.dropCollectionView.contentOffset = currentOffset;
    } else {
        //self.dragCollectionView.contentOffset = currentOffset;
    }
}


@end
