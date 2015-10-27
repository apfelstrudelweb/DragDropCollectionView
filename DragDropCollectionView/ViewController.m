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
#import "ArrasoltaAPI.h"

// Important: always include PublicAPI.h into the current project
#define SHARED_CONFIG_INSTANCE   [ArrasoltaConfig sharedInstance]


@interface ViewController () {
    
    NSMutableDictionary* dataSourceDict;
    NSMutableArray* layoutConstraints;
}

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [SHARED_CONFIG_INSTANCE setPreferredFontName:@"ArialRoundedMTBold"];
    
    [self setSourceElements];
    
    
    [SHARED_CONFIG_INSTANCE setSourceItemConsumable:true];
    
    //[SHARED_CONFIG_INSTANCE setFixedCellSize:CGSizeMake(120, 60.0)];
    
//    [SHARED_CONFIG_INSTANCE setShouldCollectionViewFillEntireHeight:true];
//    [SHARED_CONFIG_INSTANCE setShouldCollectionViewBeCenteredVertically:true];
   
    
    [SHARED_CONFIG_INSTANCE setCellWidthHeightRatio:CELL_WIDTH_HEIGHT_RATIO]; // width:height
    [SHARED_CONFIG_INSTANCE setMinInteritemSpacing:0];
    float minInterimSpacing = 0;//[SHARED_CONFIG_INSTANCE getMinInteritemSpacing];
    float minLineSpacing = minInterimSpacing / CELL_WIDTH_HEIGHT_RATIO;
    [SHARED_CONFIG_INSTANCE setMinLineSpacing:0];
    
    [SHARED_CONFIG_INSTANCE setBackgroundColorSourceView:[UIColor colorWithRed:0.89 green:0.92 blue:0.98 alpha:1.0]];
    [SHARED_CONFIG_INSTANCE setBackgroundColorTargetView:[UIColor colorWithRed:0.89 green:0.92 blue:0.98 alpha:1.0]];
    
    [SHARED_CONFIG_INSTANCE setDropPlaceholderColorUntouched:[UIColor colorWithRed:0.79 green:0.85 blue:0.97 alpha:1.0]];
    [SHARED_CONFIG_INSTANCE setDropPlaceholderColorTouched:[UIColor colorWithRed:0.64 green:0.76 blue:0.96 alpha:1.0]];
    
    [SHARED_CONFIG_INSTANCE setShouldPlaceholderIndexStartFromZero:false]; // starts with index=1
    [SHARED_CONFIG_INSTANCE setShouldDragPlaceholderContainIndex:true];
    [SHARED_CONFIG_INSTANCE setShouldDropPlaceholderContainIndex:true];
    
    //[SHARED_CONFIG_INSTANCE setPlaceholderFontSize:10.0];
    [SHARED_CONFIG_INSTANCE setPlaceholderTextColor:[UIColor colorWithRed:0.51 green:0.62 blue:0.80 alpha:1.0]];
    
    [SHARED_CONFIG_INSTANCE setNumberOfDropItems:30];
    
    [SHARED_CONFIG_INSTANCE setDataSourceDict:dataSourceDict];
    
    [SHARED_CONFIG_INSTANCE setScrollDirection:horizontal];
    //[SHARED_CONFIG_INSTANCE setScrollDirection:vertical];
    [SHARED_CONFIG_INSTANCE setShouldItemsBePlacedFromLeftToRight:true]; // only for horizontal scroll direction
    
    [SHARED_CONFIG_INSTANCE setLongPressDurationBeforeDrag:0.0];
    
    [SHARED_CONFIG_INSTANCE setShouldPanningBeEnabled:true];
    [SHARED_CONFIG_INSTANCE setShouldPanningBeCoupled:true];
    

    self.view = [MainView new];
    
}

- (void) setSourceElements {
    
    dataSourceDict = [NSMutableDictionary new];
    
    NSArray* countries = @[@[@"Andorra", @"andorra.png"],
                           @[@"Austria", @"austria.png"],
                           @[@"Belgium", @"belgium.png"],
//                           @[@"Croatia", @"croatia.png"],
//                           @[@"Denmark", @"denmark.png"],
//                           @[@"Finland", @"finland.png"],
//                           @[@"France", @"france.png"],
//                           @[@"Germany", @"germany.png"],
//                           @[@"Great Britain", @"greatbritain.png"],
//                           @[@"Greece", @"greece.png"],
//                           @[@"Hungary", @"hungary.png"],
//                           @[@"Iceland", @"iceland.png"],
//                           @[@"Ireland", @"ireland.png"],
//                           @[@"Italy", @"italy.png"],
//                           @[@"Liechtenstein", @"liechtenstein.png"],
//                           @[@"Luxembourg", @"luxembourg.png"],
//                           @[@"Malta", @"malta.png"],
//                           @[@"Netherlands", @"netherlands.png"],
                           @[@"Norway", @"norway.png"],
                           @[@"Poland", @"poland.png"],
                           @[@"Portugal", @"portugal.png"],
                           @[@"Spain", @"spain.png"],
                           @[@"Sweden", @"sweden.png"],
                           @[@"Switzerland", @"switzerland.png"],
                           
//                           @[@"Austria", @"austria.png"],
//                           @[@"Belgium", @"belgium.png"],
//                           @[@"Croatia", @"croatia.png"],
//                           @[@"Denmark", @"denmark.png"],
//                           @[@"Finland", @"finland.png"],
//                           @[@"France", @"france.png"],
//                           @[@"Germany", @"germany.png"],
//                           @[@"Great Britain", @"greatbritain.png"],
//                           @[@"Greece", @"greece.png"],
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
                           
                           @[@"Turkey", @"turkey.png"]
                           ];
    
    for (int i=0; i<countries.count; i++) {
        ArrasoltaDragView* view = [ArrasoltaDragView new];
        view.index = i;
        [view setBorderColor:[UIColor redColor]];
        [view setBorderWidth:IS_IPAD ? 2 : 1];
        
        ConcreteCustomView* cv = [ConcreteCustomView new];
        if (i%2==0) {
            cv.backgroundColorOfView = [UIColor colorWithRed:0.64 green:0.76 blue:0.96 alpha:1.0];
        } else {
            cv.backgroundColorOfView = [UIColor colorWithRed:0.43 green:0.62 blue:0.92 alpha:1.0];
        }
        cv.labelText = countries[i][0];
        cv.labelColor = [UIColor colorWithRed:0.11 green:0.27 blue:0.53 alpha:1.0];
        cv.imageName = countries[i][1];
        
        [view setContentView:cv];
        //[view initialize];
        
        dataSourceDict[@(i)] = view;
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
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Memory warning"
                                                    message:@"fgsdfgfgsfdg"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


@end
