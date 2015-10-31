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
        [SHARED_CONFIG_INSTANCE setCellWidthHeightRatio:1.2]; // width = 2.0*height
    } else {
        [SHARED_CONFIG_INSTANCE setFixedCellSize:CGSizeMake(80, 40.0)];
    }
    
    [SHARED_CONFIG_INSTANCE setShouldCollectionViewFillEntireHeight:false];
    [SHARED_CONFIG_INSTANCE setShouldCollectionViewBeCenteredVertically:true];
    
    
    [SHARED_CONFIG_INSTANCE setMinInteritemSpacing:6];
    [SHARED_CONFIG_INSTANCE setMinLineSpacing:4];
    
    [SHARED_CONFIG_INSTANCE setBackgroundColorSourceView:COMPONENT_COLOR];
    [SHARED_CONFIG_INSTANCE setBackgroundColorTargetView:COMPONENT_COLOR];
    
    [SHARED_CONFIG_INSTANCE setTargetPlaceholderColorUntouched:[UIColor clearColor]];
    [SHARED_CONFIG_INSTANCE setTargetPlaceholderColorTouched:[UIColor colorWithRed:0.51 green:0.67 blue:0.96 alpha:1.0]];
    
    [SHARED_CONFIG_INSTANCE setShouldPlaceholderIndexStartFromZero:false]; // starts with index=1
    [SHARED_CONFIG_INSTANCE setShouldSourcePlaceholderDisplayIndex:true];
    [SHARED_CONFIG_INSTANCE setShouldTargetPlaceholderDisplayIndex:true];
    
    [SHARED_CONFIG_INSTANCE setPlaceholderFontSize:IS_IPAD ? 20 : 10];
    [SHARED_CONFIG_INSTANCE setPlaceholderTextColor:[UIColor colorWithRed:0.77 green:0.84 blue:0.96 alpha:1.0]];
    
    // MUST be set if source items are NOT consumable
    [SHARED_CONFIG_INSTANCE setNumberOfTargetItems:60];
    
    // dictionary populated in "setSourceElements"
    [SHARED_CONFIG_INSTANCE setSourceItemsDictionary:dataSourceDictionary];
    
    [SHARED_CONFIG_INSTANCE setScrollDirection:horizontal];
    //[SHARED_CONFIG_INSTANCE setScrollDirection:vertical];
    [SHARED_CONFIG_INSTANCE setShouldCellOrderBeHorizontal:true]; // only for horizontal scroll direction
    
    [SHARED_CONFIG_INSTANCE setLongPressDurationBeforeDragging:0.0];
    
    // zooming by panning
    [SHARED_CONFIG_INSTANCE setShouldPanningBeEnabled:true];
    // flag whether both collection views should be zoomed simultaneously
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
    
    UIColor* colorC = [UIColor colorWithRed:0.96 green:0.22 blue:0.22 alpha:1.0];
    UIColor* colorD = [UIColor colorWithRed:0.95 green:0.73 blue:0.09 alpha:1.0];
    UIColor* colorE = [UIColor colorWithRed:0.55 green:0.88 blue:0.40 alpha:1.0];
    UIColor* colorF = [UIColor colorWithRed:0.11 green:0.75 blue:0.11 alpha:1.0];
    UIColor* colorG = [UIColor colorWithRed:0.25 green:0.41 blue:0.96 alpha:1.0];
    UIColor* colorA = [UIColor colorWithRed:0.69 green:0.33 blue:0.93 alpha:1.0];
    UIColor* colorB = [UIColor colorWithRed:0.97 green:0.31 blue:0.84 alpha:1.0];
    
    // As showcase, use 24 common open-position guitar chords
    
    // Example: the song "Oh Susanna" has the following chord sequence:
    // Verse:   G-D-G-D-G-D-G-D-G
    // Chorus:  C-G-D-G-D-G
    NSArray* chordsArray = @[@[@"C", colorC],
                             @[@"C7", colorC],
                             @[@"Cmaj7", colorC],
                             @[@"D", colorD],
                             @[@"D7", colorD],
                             @[@"Dm", colorD],
                             @[@"Dm7", colorD],
                             @[@"Dmaj7", colorD],
                             @[@"E", colorE],
                             @[@"E7", colorE],
                             @[@"Em", colorE],
                             @[@"Em7", colorE],
                             @[@"F", colorF],
                             @[@"Fmaj7", colorF],
                             @[@"G", colorG],
                             @[@"G7", colorG],
                             @[@"A", colorA],
                             @[@"A7", colorA],
                             @[@"Am", colorA],
                             @[@"Am7", colorA],
                             @[@"Amaj7", colorA],
                             @[@"Bb", colorB],
                             @[@"B7", colorB],
                             @[@"Bm", colorB]
                             ];
    
    for (int i=0; i<chordsArray.count; i++) {
        // first populate the draggable view from framework (which serves as
        // a container for the custom view - see below)
        ArrasoltaDraggableView* view = [ArrasoltaDraggableView new];
        view.index = i; // index must be set - otherwise, the undo functionality won't work
        [view setBorderColor:[UIColor clearColor]];
        [view setBorderWidth:IS_IPAD ? 4 : 2];
        
        // now populate the own UIView which serves as draggable/droppable view
        CustomView* customView = [CustomView new];
        customView.backgroundColorOfView = chordsArray[i][1];
        customView.labelText = chordsArray[i][0];
        customView.labelColor = [UIColor blackColor];
        
        [view setContentView:customView];
        
        // the dictionary must contain Numbers as Key and
        // ArraSoltaDragView objects as value
        dataSourceDictionary[@(i)] = view;
    }
}



@end
