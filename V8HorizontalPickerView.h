//
//  V8HorizontalPickerView.h
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "V8HorizontalPickerViewProtocol.h"

@interface V8HorizontalPickerView : UIView <UIScrollViewDelegate> {
	UIScrollView *_scrollView;

	// delegate and datasources to feed scroll view. this view only maintains
	//     a weak reference to these.
	id <V8HorizontalPickerViewDataSource> dataSource;
	id <V8HorizontalPickerViewDelegate> delegate;

	// collection of widths of each element.
	NSMutableArray *elementWidths;

	// reusable views for "tiling" views
	NSMutableSet *_reusableViews;

	// what font to use for the element labels?
	UIFont *elementFont;

	// color of labels used in picker
	UIColor *textColor;
	UIColor *selectedTextColor; // color of current selected element
	
	NSInteger numberOfElements;
	NSInteger elementPadding;
	NSInteger currentSelectedIndex;

	// the point, defaults to center of view, where the selected element sits
	CGPoint selectionPoint;
	UIView *selectionIndicatorView;

	BOOL dataHasBeenLoaded;
	BOOL scrollSizeHasBeenSet;
}

@property (nonatomic, assign) id <V8HorizontalPickerViewDataSource> dataSource;
@property (nonatomic, assign) id <V8HorizontalPickerViewDelegate> delegate;
@property (nonatomic, readonly) NSInteger numberOfElements;
@property (nonatomic, retain) UIFont *elementFont;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *selectedTextColor;
@property (nonatomic, assign) CGPoint selectionPoint;
@property (nonatomic, retain) UIView *selectionIndicatorView;

- (void)reloadData;
- (UIView *)dequeueReusableView;
- (void)scrollToElement:(NSInteger)index animated:(BOOL)animate;

@end

