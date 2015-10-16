//
//  ViewController.m
//  DragDropCollectionView
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"
// custom views
#import "MainView.h"
#import "ConcreteCustomView.h"

// framework
#import "PublicAPI.h"

// Important: always include PublicAPI.h into the current project
#define SHARED_CONFIG_INSTANCE   [ConfigAPI sharedInstance]


@interface ViewController () {
    
    NSMutableDictionary* dataSourceDict;
    NSMutableArray* layoutConstraints;
}

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setSourceElements];
    
    [SHARED_CONFIG_INSTANCE setSourceItemConsumable:true];
    [SHARED_CONFIG_INSTANCE shouldRemoveAllEmptyCells:true];
    
    [SHARED_CONFIG_INSTANCE setCellWidthHeightRatio:CELL_WIDTH_HEIGHT_RATIO]; // width:height
    [SHARED_CONFIG_INSTANCE setMinInteritemSpacing:SPACE_BETWEEN_ITEMS];
    float minInterimSpacing = [SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
    float minLineSpacing = minInterimSpacing / CELL_WIDTH_HEIGHT_RATIO;
    [SHARED_CONFIG_INSTANCE setMinLineSpacing:minLineSpacing];
    [SHARED_CONFIG_INSTANCE setBackgroundColorSourceView:[UIColor clearColor]];
    [SHARED_CONFIG_INSTANCE setBackgroundColorTargetView:[UIColor clearColor]];
    
    [SHARED_CONFIG_INSTANCE setDropPlaceholderColorUntouched:[UIColor colorWithRed:0.79 green:0.85 blue:0.97 alpha:1.0]];
//    [SHARED_CONFIG_INSTANCE setDropPlaceholderColorTouched:[UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.0]];
    
    [SHARED_CONFIG_INSTANCE setNumberOfDropItems:60];
    
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
//                           @[@"Hungary", @"hungary.png"],
//                           @[@"Iceland", @"iceland.png"],
//                           @[@"Ireland", @"ireland.png"],
//                           @[@"Italy", @"italy.png"],
//                           @[@"Liechtenstein", @"liechtenstein.png"],
//                           @[@"Luxembourg", @"luxembourg.png"],
//                           @[@"Malta", @"malta.png"],
//                           @[@"Netherlands", @"netherlands.png"],
//                           @[@"Norway", @"norway.png"],
//                           @[@"Poland", @"poland.png"],
//                           @[@"Portugal", @"portugal.png"],
//                           @[@"Spain", @"spain.png"],
//                           @[@"Sweden", @"sweden.png"],
//                           @[@"Switzerland", @"switzerland.png"],
//                           @[@"Turkey", @"turkey.png"]
                           ];
    
    for (int i=0; i<countries.count; i++) {
        DragView* view = [DragView new];
        view.index = i;
        [view setBorderColor:[UIColor redColor]];
        [view setBorderWidth:2.0];
        
        ConcreteCustomView* cv = [ConcreteCustomView new];
        if (i%2==0) {
            [cv setBackgroundColorOfView:[UIColor colorWithRed:0.64 green:0.76 blue:0.96 alpha:1.0]];
        } else {
            [cv setBackgroundColorOfView:[UIColor colorWithRed:0.43 green:0.62 blue:0.92 alpha:1.0]];
        }
        [cv setLabelText:countries[i][0]];
        [cv setLabelColor:[UIColor colorWithRed:0.11 green:0.27 blue:0.53 alpha:1.0]];
        [cv setImageName:countries[i][1]];
        
        [view setContentView:cv];
        //[view initialize];
        
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
        
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
