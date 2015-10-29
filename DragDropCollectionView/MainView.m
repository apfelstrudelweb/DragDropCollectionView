//
//  MainView.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainView.h"
#import "UILabel+size.h"

// remove
//#import "ConcreteCustomView.h"


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
        [self.headline1 setTextForHeadline:@"ArraSolta Showcase"];
        [self.headline1 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline1];
        
        self.headline2 = [[UILabel alloc] initWithFrame:frame];
        [self.headline2 setTextForSubHeadline:@"Drag elements from top to bottom"];
        [self.headline2 setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addSubview:self.headline2];
        
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
        
        [super setupConstraints];
        
        // Important - we need it for drag & drop functionality!
        [[ArrasoltaDragDropHelper sharedInstance] initWithView:self collectionViews:@[self.dragCollectionView, self.dropCollectionView] cellDictionaries:@[self.sourceDict, self.targetDict]];
   
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


@end
