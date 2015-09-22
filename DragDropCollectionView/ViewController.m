//
//  ViewController.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view = [MainView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
