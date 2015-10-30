//
//  MainView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"


@interface MainView() {
    
    // for subview components
    float totalHeight, totalWidth;
    int percentHeader, percentButton, percentDragArea, percentDropArea;
    
    // layout constraints
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
}

@end


@implementation MainView



- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.labelHeadline = [[UILabel alloc] initWithFrame:frame];
        [self.labelHeadline setHeadlineText:@"ArraSolta Showcase"];
        [self.labelHeadline setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.labelHeadline];
        
        
        self.undoButtonView = [ButtonView new];
        [self.undoButtonView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.undoButtonView];
        
        
        // Prepare source collection view
        self.sourceItemsDictionary = [SHARED_CONFIG_INSTANCE getSourceItemsDictionary];
        self.numberOfSourceItems = (int)self.sourceItemsDictionary.count;
        
        self.sourceCollectionView = [[ArrasoltaDragCollectionView alloc] initWithFrame:frame withinView:self];
        [self.sourceCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.sourceCollectionView];
        
        // Prepare target collection view
        self.targetItemsDictionary = [NSMutableDictionary new];
        self.numberOfTargetItems = [SHARED_CONFIG_INSTANCE getNumberOfTargetItems];
        
        self.targetCollectionView = [[ArrasoltaDropCollectionView alloc] initWithFrame:frame withinView:self sourceDictionary:self.sourceItemsDictionary targetDictionary:self.targetItemsDictionary];
        
        [self.targetCollectionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.targetCollectionView];
        
        [self setupConstraints];
        
        // Important - we need it for drag & drop functionality!
        [[ArrasoltaDragDropHelper sharedInstance] initWithView:self collectionViews:@[self.sourceCollectionView, self.targetCollectionView] cellDictionaries:@[self.sourceItemsDictionary, self.targetItemsDictionary]];
        
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
        return self.numberOfSourceItems;
    } else {
        return self.numberOfTargetItems;
    }
}

-(ArrasoltaCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // Important: order of dictionaries must be maintained:
    // 1. source dictionary
    // 2. target dictionary
    
    return [ArrasoltaUtils getCell:collectionView forIndexPath:indexPath cellDictionaries:@[self.sourceItemsDictionary, self.targetItemsDictionary]];
    
}


#pragma mark <UIScrollViewDelegate>
// synchronize scrolling
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGPoint currentOffset = scrollView.contentOffset;
    
    if ([scrollView isKindOfClass:[ArrasoltaDragCollectionView class]]) {
        self.targetCollectionView.contentOffset = currentOffset;
    } else {
        //self.dragCollectionView.contentOffset = currentOffset;
    }
}

#pragma mark -NSNotification
- (void) orientationChanged:(NSNotification *) notification {
    
    [self setupConstraints];
    
    [self.sourceCollectionView reloadData];
    [self.targetCollectionView reloadData];
    
    [ArrasoltaUtils scrollToLastElement: self.targetCollectionView ofDictionary:self.targetItemsDictionary];
}

#pragma mark -constraint issues
- (void)setupConstraints {
    
    self.subviewsDictionaryForAutoLayout = @{   @"headline"     : self.labelHeadline,
                                                @"source"       : self.sourceCollectionView,
                                                @"button"       : self.undoButtonView,
                                                @"target"       : self.targetCollectionView };
    
    CGRect screenRect = [UIScreen mainScreen].bounds;
    
    totalHeight = 0.9*screenRect.size.height;
    totalWidth  = 0.9*screenRect.size.width;
    percentHeader = PERCENT_HEADER;
    percentButton  = PERCENT_UNDO_BTN;
    percentDragArea = PERCENT_DRAG_AREA;
    percentDropArea = PERCENT_DROP_AREA;
    
    self.sourceCollectionViewSize = CGSizeMake(totalWidth, totalHeight*percentDragArea*0.01);
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    
    NSString* visualFormatText = [NSString stringWithFormat:@"V:|-%d-[headline]-%d-[source]-%d-[button]-%d-[target]", 0, 0, 0, 0];
    
    
    
    visualFormatConstraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormatText
                                                                      options:0
                                                                      metrics:nil
                                                                        views:self.subviewsDictionaryForAutoLayout];
    
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
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.labelHeadline
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.labelHeadline
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightHeader]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.labelHeadline
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButtonView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightButton]];
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButtonView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.9
                                                               constant:0.0]];
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.undoButtonView
                                                              attribute:NSLayoutAttributeRight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self.sourceCollectionView
                                                              attribute:NSLayoutAttributeRight
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.sourceCollectionView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.sourceCollectionView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightDragArea]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.sourceCollectionView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0
                                                               constant:0.0]];
    
    // Width constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.targetCollectionView
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeWidth
                                                             multiplier:0.0
                                                               constant:totalWidth]];
    
    // Height constraint
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.targetCollectionView
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:self
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:0.0
                                                               constant:heightDropArea]];
    
    // Center horizontally
    [layoutConstraints addObject:[NSLayoutConstraint constraintWithItem:self.targetCollectionView
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
