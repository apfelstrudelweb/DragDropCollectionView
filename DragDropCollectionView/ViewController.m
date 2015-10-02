//
//  ViewController.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"
#import "CustomView.h"


@interface ViewController () {
    NSMutableDictionary* dataSourceDict;
    
    NSMutableArray* layoutConstraints;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSourceElements];
    
    [SHARED_CONFIG_INSTANCE setCellWidthHeightRatio:CELL_WIDTH_HEIGHT_RATIO]; // width:height = 3:2
    [SHARED_CONFIG_INSTANCE setMinInteritemSpacing:SPACE_BETWEEN_ITEMS];
    float minInterimSpacing = [SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
    float minLineSpacing = minInterimSpacing / CELL_WIDTH_HEIGHT_RATIO;
    [SHARED_CONFIG_INSTANCE setMinLineSpacing:minLineSpacing];
    [SHARED_CONFIG_INSTANCE setBackgroundColorSourceView:[UIColor whiteColor]];
    [SHARED_CONFIG_INSTANCE setBackgroundColorTargetView:[UIColor whiteColor]];
    
    [SHARED_CONFIG_INSTANCE setDataSourceDict:dataSourceDict];
    
    self.view = [MainView new];
    
}

- (void) setSourceElements {
    
    dataSourceDict = [NSMutableDictionary new];
    
    NSArray* countries = @[@[@"Andorra", @"andorra.png"],
                           @[@"Austria", @"austria.png"],
                           @[@"Belgium", @"belgium.png"],
                           @[@"Croatia", @"croatia.png"],
                           @[@"Denmark", @"denmark.png"],
                           @[@"Finland", @"finland.png"],
                           @[@"France", @"france.png"],
                           @[@"Germany", @"germany.png"],
                           @[@"Great Britain", @"greatbritain.png"],
                           @[@"Greece", @"greece.png"],
                           @[@"Hungary", @"hungary.png"],
                           @[@"Iceland", @"iceland.png"],
                           @[@"Ireland", @"ireland.png"],
                           @[@"Italy", @"italy.png"],
                           @[@"Liechtenstein", @"liechtenstein.png"],
                           @[@"Luxembourg", @"luxembourg.png"],
                           @[@"Malta", @"malta.png"],
                           @[@"Netherlands", @"netherlands.png"],
                           @[@"Norway", @"norway.png"],
                           @[@"Poland", @"poland.png"],
                           @[@"Portugal", @"portugal.png"],
                           @[@"Spain", @"spain.png"],
                           @[@"Sweden", @"sweden.png"],
                           @[@"Switzerland", @"switzerland.png"],
                           @[@"Turkey", @"turkey.png"]
                           ];
    
    for (int i=0; i<countries.count; i++) {
        DragView* view = [DragView new];
        view.index = i;
        [view setBorderColor:[UIColor colorWithRed:0.80 green:0.80 blue:0.80 alpha:1.0]];
        
        CustomView* cv = [CustomView new];
        if (i%2==0) {
            [cv setBackgroundColorOfView:[UIColor colorWithRed:0.64 green:0.76 blue:0.96 alpha:1.0]];
        } else {
            [cv setBackgroundColorOfView:[UIColor colorWithRed:0.43 green:0.62 blue:0.92 alpha:1.0]];
        }
        [cv setLabelText:countries[i][0]];
        [cv setLabelColor:[UIColor colorWithRed:0.11 green:0.27 blue:0.53 alpha:1.0]];
        [cv setImageName:countries[i][1]];
        //[cv setupConstraints];
        [view setContentView:cv];
        [view initialize];
        
        [dataSourceDict setObject:view forKey:[NSNumber numberWithInt:i]];
    }
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
