//
//  ViewController.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 15.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    
    // Dictionary populated by user -> see method "populateDataSourceDictionary"
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
    [SHARED_CONFIG_INSTANCE setSourceItemsConsumable:false];
    
    if (hasAutomaticCellSize) {
        [SHARED_CONFIG_INSTANCE setCellWidthHeightRatio:1.0]; // width = 2.0*height
    } else {
        [SHARED_CONFIG_INSTANCE setFixedCellSize:CGSizeMake(80, 40.0)];
    }
    
    [SHARED_CONFIG_INSTANCE setShouldCollectionViewFillEntireHeight:false];
    [SHARED_CONFIG_INSTANCE setShouldCollectionViewBeCenteredVertically:true];
    
    
    [SHARED_CONFIG_INSTANCE setMinInteritemSpacing:10];
    [SHARED_CONFIG_INSTANCE setMinLineSpacing:6];
    
    [SHARED_CONFIG_INSTANCE setBackgroundColorSourceView:[UIColor colorWithRed:0.31 green:0.44 blue:0.67 alpha:1.0]];
    [SHARED_CONFIG_INSTANCE setBackgroundColorTargetView:[UIColor colorWithRed:0.31 green:0.44 blue:0.67 alpha:1.0]];
    
    [SHARED_CONFIG_INSTANCE setTargetPlaceholderColorUntouched:[UIColor lightGrayColor]];
    [SHARED_CONFIG_INSTANCE setTargetPlaceholderColorTouched:[UIColor grayColor]];
    
    [SHARED_CONFIG_INSTANCE setShouldPlaceholderIndexStartFromZero:false]; // starts with index=1
    [SHARED_CONFIG_INSTANCE setShouldSourcePlaceholderDisplayIndex:true];
    [SHARED_CONFIG_INSTANCE setShouldTargetPlaceholderDisplayIndex:true];
    
    [SHARED_CONFIG_INSTANCE setPlaceholderFontSize:IS_IPAD ? 20 : 10];
    [SHARED_CONFIG_INSTANCE setPlaceholderTextColor:[UIColor whiteColor]];
    
    // MUST be set if source items are NOT consumable
    [SHARED_CONFIG_INSTANCE setNumberOfTargetItems:50];
    
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
    NSArray* chords = @[@[@"C", [UIColor colorWithRed:0.95 green:0.29 blue:0.29 alpha:1.0]],
                           @[@"C#", [UIColor colorWithRed:1.00 green:0.60 blue:0.00 alpha:1.0]],
                           @[@"D", [UIColor colorWithRed:0.90 green:0.57 blue:0.22 alpha:1.0]],
                           @[@"D#", [UIColor colorWithRed:1.00 green:0.85 blue:0.40 alpha:1.0]],
                           @[@"E", [UIColor colorWithRed:0.39 green:0.96 blue:0.39 alpha:1.0]],
                           @[@"F", [UIColor colorWithRed:0.42 green:0.66 blue:0.31 alpha:1.0]],
                           @[@"F#", [UIColor colorWithRed:0.00 green:1.00 blue:0.64 alpha:1.0]],
                           @[@"G", [UIColor colorWithRed:0.00 green:1.00 blue:0.85 alpha:1.0]],
                           @[@"G#", [UIColor colorWithRed:0.24 green:0.47 blue:0.85 alpha:1.0]],
                           @[@"A", [UIColor colorWithRed:0.45 green:0.45 blue:0.95 alpha:1.0]],
                           @[@"A#", [UIColor colorWithRed:0.74 green:0.40 blue:0.97 alpha:1.0]],
                           @[@"H", [UIColor colorWithRed:0.96 green:0.48 blue:0.96 alpha:1.0]]
                           ];
    
    for (int i=0; i<chords.count; i++) {
        // first populate the draggable view from framework (which serves as
        // a container for the custom view - see below)
        ArrasoltaDraggableView* view = [ArrasoltaDraggableView new];
        view.index = i; // index must be set - otherwise, the undo functionality won't work
        [view setBorderColor:[UIColor blackColor]];
        [view setBorderWidth:IS_IPAD ? 6 : 3];
        
        // now populate the own UIView which serves as draggable/droppable view
        CustomView* customView = [CustomView new];
        customView.backgroundColorOfView = chords[i][1];
        customView.labelText = chords[i][0];
        customView.labelColor = [UIColor colorWithRed:0.27 green:0.27 blue:0.27 alpha:1.0];
        
        [view setContentView:customView];
        
        // the dictionary must contain Numbers as Key and
        // ArraSoltaDragView objects as value
        dataSourceDictionary[@(i)] = view;
    }
}



@end
