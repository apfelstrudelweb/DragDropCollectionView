//
//  ViewController.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"
#define SHARED_CONFIG   [DragDropConfig sharedConfig]

@interface ViewController () {
    NSMutableDictionary* dataSourceDict;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SHARED_CONFIG setCItemSpacing:SPACE_BETWEEN_ITEMS];
    [SHARED_CONFIG setCBackgroundColorSourceView:[UIColor colorWithRed:1.00 green:0.95 blue:0.80 alpha:1.0]];
    [SHARED_CONFIG setCBackgroundColorTargetView:[UIColor whiteColor]];
    
    [SHARED_CONFIG setCDataSourceDict:[self getSourceElements]];
    
    self.view = [MainView new];
    
}

- (NSMutableDictionary*) getSourceElements {
    
    dataSourceDict = [NSMutableDictionary new];
    
    NSArray* titles = @[@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z"];
    
    for (int i=0; i<titles.count; i++) {
        DragView* view = [DragView new];
        [view setLabelTitle:titles[i]];
        if (i%2==0) {
            [view setColor: [UIColor orangeColor]];
        } else {
            [view setColor: [UIColor blueColor]];
        }
        
        CellModel* model = [CellModel new];
        [model populateWithDragView:view];
        
        //[self.targetCellsDict insertObject: model atIndex:insertIndex];
        
        [dataSourceDict setObject:model forKey:[NSNumber numberWithInt:i]];
    }
    
    return dataSourceDict;
}


#pragma mark -interface orientation
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName: @"viewHasBeenRotatedNotification" object:self];
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        // important for scrolling to position where fret has been before rotating the device
        
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
