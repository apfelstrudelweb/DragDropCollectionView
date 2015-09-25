//
//  MainBasicView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "MainBasicView.h"

@interface MainBasicView( ) {
    // subview proportions
    float totalHeight;
    float totalWidth;
    int percentHeader1, percentHeader2, percentDragArea, percentDropArea;
    
    NSMutableArray* layoutConstraints;
    NSArray *visualFormatConstraints;
}
@end

@implementation MainBasicView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
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
- (void) receiveDeleteCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"deleteCellNotification"]) {
        NSDictionary *userInfo = notification.userInfo;
        NSIndexPath* indexPath = [userInfo objectForKey:@"indexPath"];
        
        // append empty cell in order to maintain a constant number of cells
        self.numberOfDropItems++;
        [self.dropCollectionView performBatchUpdates:^{
            
            NSIndexPath* indexPathToAppend = [NSIndexPath indexPathForRow:self.numberOfDropItems-1 inSection:0];
            
            NSArray *indexPaths = [NSArray arrayWithObject:indexPathToAppend];
            [self.dropCollectionView insertItemsAtIndexPaths:indexPaths];
            
        } completion: ^(BOOL finished) {
            [self.targetCellsDict  removeObjectForKey:[NSNumber numberWithInt:(int)indexPath.item]];
            
            //[self.targetCellsDict log];
            
        }];
        
    }
}


- (void) receiveShiftCellNotification:(NSNotification *) notification {
    if ([[notification name] isEqualToString:@"shiftCellNotification"]) {
        
        NSDictionary *userInfo = notification.userInfo;
        NSIndexPath* indexPath = [userInfo objectForKey:@"indexPath"];
        
        self.numberOfDropItems--;
        [self.dropCollectionView performBatchUpdates:^{
            //NSLog(@"item = %d", (int)indexPath.item);
            [self.dropCollectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:indexPath]];
            
        } completion: ^(BOOL finished) {
            // shift elements to left and remove empty ones
            [Utils eliminateEmptyKeysInDict:self.targetCellsDict];
            // important: reload data, otherwise empty cells could remain visible!
            [self.dropCollectionView reloadData];
            
            [Utils scrollToLastElement: self.dropCollectionView ofDictionary:self.targetCellsDict];
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
    self.cellWidthHeight = [self.dragCollectionView getBestFillingCellSize:self.dragCollectionViewSize];
    
    [self.dragCollectionView reloadData];
    [self.dropCollectionView reloadData];
    
    [Utils scrollToLastElement: self.dropCollectionView ofDictionary:self.targetCellsDict];
}





#pragma mark -constraint issues
- (void)setupConstraints {
    
    self.viewsDictionary = @{   @"headline1"    : self.headline1,
                                @"source"       : self.dragCollectionView,
                                @"headline2"    : self.headline2,
                                @"target"       : self.dropCollectionView };
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    totalHeight = 0.9*screenRect.size.height;
    totalWidth  = 0.9*screenRect.size.width;
    percentHeader1 = PERCENT_HEADER_1;
    percentHeader2 = PERCENT_HEADER_2;
    percentDragArea = PERCENT_DRAG_AREA;
    percentDropArea = PERCENT_DROP_AREA;
    
    self.dragCollectionViewSize = CGSizeMake(totalWidth, totalHeight*percentDragArea*0.01);
    
    // clear constraints in case of device rotation
    [self removeConstraints:visualFormatConstraints];
    [self removeConstraints:layoutConstraints];
    
    
    NSString* visualFormatText = [NSString stringWithFormat:@"V:|-%d-[headline1]-%d-[source]-%d-[headline2]-%d-[target]",MARGIN, 0, 0, 0];
    
    
    
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

@end
