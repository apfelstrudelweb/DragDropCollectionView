//
//  CollectionView.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 25.10.15.
//  Copyright © 2015 Ulrich Vormbrock. All rights reserved.
//

#import "CollectionView.h"
#import "CurrentState.h"

#define SHARED_STATE_INSTANCE    [CurrentState sharedInstance]

@interface CollectionView() {
    int pinchCount;

}
@end

@implementation CollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    
    self = [super initWithFrame:frame collectionViewLayout:layout];
    
    if (self) {
        // for zooming
        
        self.pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
        
        self.pinchRecognizer.delegate = self;
        [self addGestureRecognizer:self.pinchRecognizer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadDataNotification:) name:@"arrasoltaReloadDataNotification"
                                                   object:nil];
    }
    return self;
}

#pragma mark -NSNotificationCenter
- (void) reloadDataNotification:(NSNotification *) notification {
    if ([notification.name isEqualToString:@"arrasoltaReloadDataNotification"]) {
        [self reloadData];
    }
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    float scale = recognizer.scale;
    
    float speed = 4*fabsf(1-scale);
    
    
    if (++pinchCount % 5 != 0) return; // performance issue!
    
    bool pinchOut = recognizer.scale > 1.0;
    
    
    UICollectionViewFlowLayout* layout = (UICollectionViewFlowLayout*)self.collectionViewLayout;
    
    if (layout) {
        CGSize size = [SHARED_STATE_INSTANCE getCellSize];
        CGSize newSize;
        
        float contentWidth = self.contentSize.width;
        float contentHeight = self.contentSize.height;
        
        float ratio = size.width / size.height;
        
        // maintain proportions
        float dX = (1.0 + speed) * ratio;
        float dY = (1.0 + speed);
        
        if (pinchOut) {
            
            if (2.5*size.width > contentWidth || 2.5*size.height > contentHeight) {
                return;
            }
            newSize = CGSizeMake(size.width + dX, size.height + dY);
        } else {
            CGSize initialCellSize = [SHARED_STATE_INSTANCE getInitialCellSize];
            
            if (size.width > initialCellSize.width && size.height > initialCellSize.height) {
                newSize = CGSizeMake(size.width - dX, size.height - dY);
            } else {
                // make sure we don't violate constraints ...
                return;
            }
        }

        
        layout.scrollDirection = self.scrollDirection;
        
        [layout invalidateLayout];
        
        layout.itemSize = newSize;
        [self setCollectionViewLayout:layout];
        
        [SHARED_STATE_INSTANCE setCellSize:newSize];

        // inform all collection views so they can freload both
        [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaReloadDataNotification" object:nil userInfo:nil];
        
    }
}

@end
