//
//  ViewController.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    
    // Dictionary populated by the user -> see method "populateDataSourceDictionary"
    NSMutableDictionary* dataSourceDictionary;
    
    bool hasAutomaticCellSize;
    
    NSMutableArray* layoutConstraints;
}

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hasAutomaticCellSize = true; // recommended
    
    // if custom draggable view should have the same font as the rest of
    // this application, set the following line BEFORE populating the dictionary!
    [SHARED_CONFIG_INSTANCE setPreferredFontName:@"ArialRoundedMTBold"];
    
    // populate the dictionary with custom views
    [self populateDataSourceDictionary];
    
    // when an element has been dragged and dropped,
    // remove it from source collection view
    [SHARED_CONFIG_INSTANCE setSourceItemsConsumable:true];
    
    if (hasAutomaticCellSize) {
        [SHARED_CONFIG_INSTANCE setCellWidthHeightRatio:2.0]; // width = 2.0*height
    } else {
        [SHARED_CONFIG_INSTANCE setFixedCellSize:CGSizeMake(80, 40.0)];
    }
    
    [SHARED_CONFIG_INSTANCE setShouldCollectionViewFillEntireHeight:true];
    [SHARED_CONFIG_INSTANCE setShouldCollectionViewBeCenteredVertically:false];
    
    
    [SHARED_CONFIG_INSTANCE setMinInteritemSpacing:10];
    [SHARED_CONFIG_INSTANCE setMinLineSpacing:6];
    
    [SHARED_CONFIG_INSTANCE setBackgroundColorSourceView:[UIColor colorWithRed:0.89 green:0.92 blue:0.98 alpha:1.0]];
    [SHARED_CONFIG_INSTANCE setBackgroundColorTargetView:[UIColor colorWithRed:0.89 green:0.92 blue:0.98 alpha:1.0]];
    
    [SHARED_CONFIG_INSTANCE setSourcePlaceholderColor:[UIColor colorWithRed:0.79 green:0.85 blue:0.97 alpha:1.0]];
    [SHARED_CONFIG_INSTANCE setTargetPlaceholderColorUntouched:[UIColor colorWithRed:0.79 green:0.85 blue:0.97 alpha:1.0]];
    [SHARED_CONFIG_INSTANCE setTargetPlaceholderColorTouched:[UIColor colorWithRed:0.64 green:0.76 blue:0.96 alpha:1.0]];
    
    [SHARED_CONFIG_INSTANCE setShouldPlaceholderIndexStartFromZero:false]; // starts with index=1
    [SHARED_CONFIG_INSTANCE setShouldSourcePlaceholderDisplayIndex:true];
    [SHARED_CONFIG_INSTANCE setShouldTargetPlaceholderDisplayIndex:true];
    
    [SHARED_CONFIG_INSTANCE setPlaceholderFontSize:IS_IPAD ? 20 : 10];
    [SHARED_CONFIG_INSTANCE setPlaceholderTextColor:[UIColor colorWithRed:0.51 green:0.62 blue:0.80 alpha:1.0]];
    
    // MUST be set if source items are NOT consumable
    [SHARED_CONFIG_INSTANCE setNumberOfTargetItems:30];
    
    // dictionary populated in "setSourceElements"
    [SHARED_CONFIG_INSTANCE setSourceItemsDictionary:dataSourceDictionary];
    
    [SHARED_CONFIG_INSTANCE setScrollDirection:horizontal];
    //[SHARED_CONFIG_INSTANCE setScrollDirection:vertical];
    [SHARED_CONFIG_INSTANCE setShouldCellOrderBeHorizontal:true]; // only for horizontal scroll direction
    
    [SHARED_CONFIG_INSTANCE setLongPressDurationBeforeDragging:0.0];
    
    // zooming by panning
    [SHARED_CONFIG_INSTANCE setShouldPanningBeEnabled:true];
    // flag if both collection views should be zoomed simultaneously
    [SHARED_CONFIG_INSTANCE setShouldPanningBeCoupled:true];
    
    
    self.view = [MainView new];
    
}

/**
 *
 *  We need to populate the NSMutableDictionary for the source collection view
 *
 **/
- (void) populateDataSourceDictionary {
    
    dataSourceDictionary = [NSMutableDictionary new];
    
    // PNGs from Images/Flags
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
        // first populate the draggable view from framework (which serves as
        // a container for the custom view - see below)
        ArrasoltaDraggableView* view = [ArrasoltaDraggableView new];
        view.index = i; // index must be set - otherwise, the undo functionality won't work
        [view setBorderColor:[UIColor redColor]];
        [view setBorderWidth:IS_IPAD ? 2 : 1];
        
        // now populate the own UIView which serves as draggable/droppable view
        CustomView* customView = [CustomView new];
        // make alternating background colors
        if (i%2==0) {
            customView.backgroundColorOfView = [UIColor colorWithRed:0.64 green:0.76 blue:0.96 alpha:1.0];
        } else {
            customView.backgroundColorOfView = [UIColor colorWithRed:0.43 green:0.62 blue:0.92 alpha:1.0];
        }
        customView.labelText = countries[i][0];
        customView.labelColor = [UIColor colorWithRed:0.11 green:0.27 blue:0.53 alpha:1.0];
        customView.imageName = countries[i][1];
        
        [view setContentView:customView];
        
        // the dictionary must contain Numbers as Key and
        // ArraSoltaDragView objects as value
        dataSourceDictionary[@(i)] = view;
    }
}



@end
