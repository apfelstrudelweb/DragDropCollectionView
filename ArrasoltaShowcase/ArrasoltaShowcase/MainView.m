//
//  MainView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"


@interface MainView() {
    
    float minLineSpacing;
    
    // subview proportions
    float totalHeight;
    float totalWidth;
    int percentHeader, percentButton, percentDragArea, percentDropArea;
    
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
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
        
        self.headline = [[UILabel alloc] initWithFrame:frame];
        [self.headline setHeadlineText:@"ArraSolta Showcase"];
        [self.headline setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline];
        

        self.btnView = [ButtonView new];
        [self.btnView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.btnView];
        
        
        // Prepare source collection view
        self.sourceDict = [SHARED_CONFIG_INSTANCE getSourceItemsDictionary];
        self.numberOfDragItems = (int)self.sourceDict.count;
        
        self.dragCollectionView = [[ArrasoltaDragCollectionView alloc] initWithFrame:frame withinView:self];
        [self.dragCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.dragCollectionView];
        
        // Prepare target collection view
        self.targetDict = [NSMutableDictionary new];
        self.numberOfDropItems = [SHARED_CONFIG_INSTANCE getNumberOfTargetItems];
        
        self.dropCollectionView = [[ArrasoltaDropCollectionView alloc] initWithFrame:frame withinView:self sourceDictionary:self.sourceDict targetDictionary:self.targetDict];
        
        [self.dropCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.dropCollectionView];
        
        [self setupConstraints];
        
        // Important - we need it for drag & drop functionality!
        [[ArrasoltaDragDropHelper sharedInstance] initWithView:self collectionViews:@[self.dragCollectionView, self.dropCollectionView] cellDictionaries:@[self.sourceDict, self.targetDict]];
        
        // observe device rotations
        [[NSNotificationCenter defaultCenter]
         addObserver:self selector:@selector(orientationChanged:)
         name:UIDeviceOrientationDidChangeNotification
         object:[UIDevice currentDevice]];
   
    }
    return self;
}


#pragma mark <UICollectionViewDataSource>
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isKindOfClass:[ArrasoltaDragCollectionView class]]) {
        return self.numberOfDragItems;
    } else {
        return self.numberOfDropItems;
    }
}

-(ArrasoltaCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Important: order of dictionaries must be maintained:
    // 1. source dictionary
    // 2. target dictionary
    
    return [ArrasoltaUtils getCell:collectionView forIndexPath:indexPath cellDictionaries:@[self.sourceDict, self.targetDict]];

}


#pragma mark <UICollectionViewDelegate>
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    if ([collectionView isKindOfClass:[ArrasoltaDragCollectionView class]]) {
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
    
    if ([scrollView isKindOfClass:[ArrasoltaDragCollectionView class]]) {
        self.dropCollectionView.contentOffset = currentOffset;
    } else {
        //self.dragCollectionView.contentOffset = currentOffset;
    }
}

#pragma mark -NSNotification
- (void) orientationChanged:(NSNotification *) notification {
    
    [self setupConstraints];
    
    // Only use when variable cell size!
    //    self.cellSize = [self.dragCollectionView getBestFillingCellSize:self.dragCollectionViewSize];
    
    [self.dragCollectionView reloadData];
    [self.dropCollectionView reloadData];
    
    [ArrasoltaUtils scrollToLastElement: self.dropCollectionView ofDictionary:self.targetDict];
}

#pragma mark -constraint issues
- (void)setupConstraints {
    
    self.viewsDictionary = @{   @"headline"     : self.headline,
                                @"source"       : self.dragCollectionView,
                                @"button"       : self.btnView,
                                @"target"       : self.dropCollectionView };
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    totalHeight = 0.9*screenRect.size.height;
    totalWidth  = 0.9*screenRect.size.width;
    percentHeader = PERCENT_HEADER;
    percentButton  = PERCENT_UNDO_BTN;
    percentDragArea = PERCENT_DRAG_AREA;
    percentDropArea = PERCENT_DROP_AREA;
    
    self.dragCollectionViewSize = CGSizeMake(totalWidth, totalHeight*percentDragArea*0.01);
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    
    NSString* visualFormatText = [NSString stringWithFormat:@"V:|-%d-[headline]-%d-[source]-%d-[button]-%d-[target]",MARGIN, 0, 0, 0];
    
    
    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.viewsDictionary];
    
    for (int i = 0; i<visualFormatConstraints.count; i++) {
        [self addConstraint:visualFormatConstraints[i]];
    }
    
    
    layoutConstraints = [NSMutableArray new];
    
    float largestSide = (totalHeight > totalWidth) ? totalHeight : totalWidth;
    
    float heightHeader  = (float) totalHeight*percentHeader*0.01;
    float heightButton   = (float) largestSide*percentButton*0.01;
    float heightDragArea = (float) totalHeight*percentDragArea*0.01;
    float heightDropArea = (float) totalHeight*percentDropArea*0.01;
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightHeader]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.headline
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.btnView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightButton]];
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.btnView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.9
                                                               constant:0.0]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.btnView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.dragCollectionView
                                                              attribute:NSLayoutAttributeRight
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
    
    
    // add all constraints at once
    [self addConstraints:layoutConstraints];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
