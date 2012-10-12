//
//  V8HorizontalPickerView.h
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "V8HorizontalPickerViewProtocol.h"

// position of indicator view, if shown
typedef enum {
	V8HorizontalPickerIndicatorBottom = 0,
	V8HorizontalPickerIndicatorTop	
} V8HorizontalPickerIndicatorPosition;



@interface V8HorizontalPickerView : UIView <UIScrollViewDelegate>
{
    AVAudioPlayer *volumeOverridePlayer;
}

// delegate and datasources to feed scroll view. this view only maintains a weak reference to these
@property (nonatomic, assign) id <V8HorizontalPickerViewDataSource> dataSource;
@property (nonatomic, assign) id <V8HorizontalPickerViewDelegate> delegate;

@property (nonatomic, readonly) NSInteger numberOfElements;
@property (nonatomic, readonly) NSInteger currentSelectedIndex;

// what font to use for the element labels?
@property (nonatomic, retain) UIFont *elementFont;

// color of labels used in picker
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *selectedTextColor; // color of current selected element

// the point, defaults to center of view, where the selected element sits
@property (nonatomic, assign) CGPoint selectionPoint;
@property (nonatomic, retain) UIView *selectionIndicatorView;

@property (nonatomic, assign) V8HorizontalPickerIndicatorPosition indicatorPosition;

// views to display on edges of picker (eg: gradients, etc)
@property (nonatomic, retain) UIView *leftEdgeView;
@property (nonatomic, retain) UIView *rightEdgeView;

// views for left and right of scrolling area
@property (nonatomic, retain) UIView *leftScrollEdgeView;
@property (nonatomic, retain) UIView *rightScrollEdgeView;

// Audio click player
@property (retain, nonatomic) AVAudioPlayer *volumeOverridePlayer;
@property (nonatomic) BOOL playSound;
@property (nonatomic) float audioVolume;
- (void)setPlayAudioWithPath:(NSURL *)audioFilePath withVolume:(float)volume;

// padding for left/right scroll edge views
@property (nonatomic, assign) CGFloat scrollEdgeViewPadding;


- (void)reloadData;
- (void)scrollToElement:(NSInteger)index animated:(BOOL)animate;

@end


// sub-class of UILabel that knows how to change it's state
@interface V8HorizontalPickerLabel : UILabel <V8HorizontalPickerElementState> { }

@property (nonatomic, assign) BOOL selectedElement;
@property (nonatomic, retain) UIColor *selectedStateColor;
@property (nonatomic, retain) UIColor *normalStateColor;
@property (nonatomic, assign) AVAudioPlayer *audioPlayer;
@property (nonatomic, assign) BOOL playSound;

@end