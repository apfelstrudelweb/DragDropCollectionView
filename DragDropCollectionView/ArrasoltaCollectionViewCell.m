//
//  CollectionViewCell.m
//  ArraSolta framework
//
//  Created by Ulrich Vormbrock on 16.09.15.
//  Copyright (c) 2015 Ulrich Vormbrock. All rights reserved.
//

#import "ArrasoltaCollectionViewCell.h"
#import "ArrasoltaAPI.h"
#import "ArrasoltaDragView.h"
#import "ArrasoltaDropView.h"


#define ANIMATION_DURATION 0.5


@interface ArrasoltaCollectionViewCell() {
    
    NSMutableArray* layoutViewConstraints;
    NSMutableArray* layoutLabelConstraints;
    
    bool isTransformedLeft;
    bool isTransformedRight;
    
    UIView* placeholderView; // basic subview of a cell - initially represented by a gray square
    UILabel* numberLabel;
    ArrasoltaMoveableView* moveableView;
    
    CGRect originalFrame;
    
    UILongPressGestureRecognizer* longPressGesture;
    UIPanGestureRecognizer* panRecognizer;
    float initialX;
    float initialY;
    
    int placeholderIndex;
    
}

@end


@implementation ArrasoltaCollectionViewCell


- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        placeholderView = [UIView new];
        [placeholderView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.contentView addSubview:placeholderView];
        [self setupViewConstraints:placeholderView isExpanded:false];
        
        self.userInteractionEnabled = YES;
        
        
        numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [numberLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
        [placeholderView addSubview:numberLabel];
        [self setupLabelConstraints];
        
   
        if (!panRecognizer) {
            panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
            
            panRecognizer.maximumNumberOfTouches = 1;
            panRecognizer.minimumNumberOfTouches = 1;
            panRecognizer.delegate = self;
            [self addGestureRecognizer:panRecognizer];
        }
        
        self.userInteractionEnabled = YES;
        
    }
    return self;
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    
    if (!self.indexPath) return; // when a source element has been dragged to top
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        initialX = [recognizer locationInView:self.window].x;
        initialY = [recognizer locationInView:self.window].y;
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        float finalY = [recognizer locationInView:self.window].y;
        
        
        if (finalY >= [SHARED_STATE_INSTANCE getTopTargetCollectionView]) {
            // if we drop into the same grid, do nothing
            return;
        }
        
        if((finalY < [SHARED_STATE_INSTANCE getBottomSourceCollectionView]) || (finalY < initialY)) {
            
            NSDictionary *userInfo;
            
            //int index = self.indexPath.item;
            
            if (moveableView) {
                userInfo = [NSDictionary dictionaryWithObject:(ArrasoltaDropView*)moveableView forKey:@"dropView"];
                
            } else {
                // delete an empty cell
                userInfo = [NSDictionary dictionaryWithObject:self.indexPath forKey:@"indexPath"];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName: @"arrasoltaDeleteCellNotification" object:nil userInfo:userInfo];
            
        }
    }
}


- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return YES;
    }
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        return YES;
    }
    return NO;
}


// MUST be called (for the iPad)
- (void)layoutSubviews {
    //[super layoutSubviews];
    // omit super!
    if (![SHARED_STATE_INSTANCE isTransactionActive]) {
        
        float w = self.frame.size.width;
        float h = self.frame.size.height;

        self.contentView.frame = CGRectMake(0, 0, w, h);
        
        self.isPushedToLeft  = false;
        self.isPushedToRight = false;
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    self.contentView.frame = bounds;
}

- (void) setNumberForDragView {
    
    if ([SHARED_CONFIG_INSTANCE getShouldSourcePlaceholderDisplayIndex]) {
        
        numberLabel.text = [NSString stringWithFormat:@"%d", placeholderIndex];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        
        numberLabel.textColor = [SHARED_CONFIG_INSTANCE getPlaceholderTextColor];
        float fontSize = [SHARED_CONFIG_INSTANCE getPlaceholderFontSize];
        NSString* fontName = [SHARED_CONFIG_INSTANCE getPreferredFontName];
        
        UIFont* font = [UIFont fontWithName:fontName size:fontSize];
        numberLabel.font = font;
        
    }
}

- (void) setNumberForDropView {
    
    if ([SHARED_CONFIG_INSTANCE getShouldTargetPlaceholderDisplayIndex]) {
        numberLabel.text = [NSString stringWithFormat:@"%d", placeholderIndex];
        numberLabel.textAlignment = NSTextAlignmentCenter;
        
        numberLabel.textColor = [SHARED_CONFIG_INSTANCE getPlaceholderTextColor];
        float fontSize = [SHARED_CONFIG_INSTANCE getPlaceholderFontSize];
        NSString* fontName = [SHARED_CONFIG_INSTANCE getPreferredFontName];

        UIFont* font = [UIFont fontWithName:fontName size:fontSize];
        numberLabel.font = font;
    }
}


- (void) reset {
    
    placeholderView.backgroundColor = [SHARED_CONFIG_INSTANCE getTargetPlaceholderColorUntouched];
    placeholderView.alpha = 1.0;
    
    placeholderIndex = (int)self.indexPath.item;
    if (![SHARED_CONFIG_INSTANCE getShouldPlaceholderIndexStartFromZero]) {
        placeholderIndex++;
    }
    
    [self setupViewConstraints:placeholderView isExpanded:false];
    [self highlight:false];
    
    self.isPopulated = false;
    self.isExpanded = false;
    
    moveableView = nil;
    
    [self setNeedsDisplay];
    
}

// IMPORTANT: this method MUST be implemented,
// otherwise we get trouble with cell contents after scrolling!
- (void) prepareForReuse {
    for (UIView* view in self.contentView.subviews) {
        if ([view isKindOfClass:[ArrasoltaMoveableView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}


- (void) populateWithContentsOfView: (ArrasoltaMoveableView*) view withinCollectionView: (UICollectionView*) collectionView {
    
    [self reset];
    
    if (!view) {
        return;
    }
    
    
    view.frame = self.contentView.bounds;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentView addSubview:view];
    
    moveableView = view;
    
    if ([view isKindOfClass:[ArrasoltaDropView class]]) {
        self.isPopulated = true;
    }
}



// expands the cell when drag view is above it
- (void) expand {
    
    [self setupViewConstraints:placeholderView isExpanded:true];
    
    if (self.isPopulated) {
        [self highlight:true];
    } else {
        placeholderView.backgroundColor = [SHARED_CONFIG_INSTANCE getTargetPlaceholderColorTouched];
    }
}

// shrinks the cell when drag view leaves it again
- (void) shrink {
    
    [self setupViewConstraints:placeholderView isExpanded:false];
    
    if (self.isPopulated) {
        [self highlight:false];
    } else {
        placeholderView.backgroundColor = [SHARED_CONFIG_INSTANCE getTargetPlaceholderColorUntouched];
    }
}

// highlights/unhighlights the drop view (which is above this cell)
- (void) highlight: (bool) flag {
    self.contentView.alpha = flag ? 0.5 : 1.0;
    
}

- (void) push: (NSInteger) direction {
    
    if (!self.isPopulated) return;
    
    if (direction == Left) {
        if (self.isPushedToLeft) return;
        self.isPushedToLeft = true;
    } else {
        if (self.isPushedToRight) return;
        self.isPushedToRight = true;
    }
    
    float w = self.frame.size.width;
    float h = self.frame.size.height;
    
    float deltaY = [SHARED_CONFIG_INSTANCE getMinLineSpacing];
    
    placeholderView.alpha = 0.0;
    originalFrame = moveableView.frame;
    
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         float offX = (direction == Left) ? 0 : 0.5*w;
                         float offY = -deltaY;
                         self.contentView.frame = CGRectMake(offX, offY, 0.5*w, h+2*deltaY);
                     }];
}

- (void) undoPush {
    
    self.isPushedToLeft  = false;
    self.isPushedToRight = false;
    
    [UIView animateWithDuration:ANIMATION_DURATION
                     animations:^{
                         //moveableView.frame = originalFrame;
                         self.contentView.frame = originalFrame;
                     }];
}


- (void)setupViewConstraints: (UIView*) view isExpanded: (bool) expand {
    
    [self removeConstraints:layoutViewConstraints];
    layoutViewConstraints = [NSMutableArray new];
    
    UIView* referenceView;
    float fact = expand ? 1.1 : 0.8;
    
    referenceView = self.contentView;
    
    self.isExpanded = expand;
    
    // Width constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:fact
                                                                   constant:0]];
    
    // Height constraint
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:fact
                                                                   constant:0]];
    
    // Center horizontally
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    
    // Center vertically
    [layoutViewConstraints addObject:[NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeCenterY
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:referenceView
                                                                  attribute:NSLayoutAttributeCenterY
                                                                 multiplier:1.0
                                                                   constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutViewConstraints];
}

- (void) setupLabelConstraints {
    
    [self removeConstraints:layoutLabelConstraints];
    layoutLabelConstraints = [NSMutableArray new];
    
    
    // Width constraint
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:numberLabel
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:placeholderView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    // Height constraint
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:numberLabel
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:placeholderView
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    // Center horizontally
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:numberLabel
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:placeholderView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    
    // Center vertically
    [layoutLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:numberLabel
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:placeholderView
                                                                   attribute:NSLayoutAttributeCenterY
                                                                  multiplier:1.0
                                                                    constant:0.0]];
    // add all constraints at once
    [self addConstraints:layoutLabelConstraints];
}


@end