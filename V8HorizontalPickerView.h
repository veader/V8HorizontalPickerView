//
//  V8HorizontalPickerView.h
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol V8HorizontalPickerViewDataSource;
@protocol V8HorizontalPickerViewDelegate;

@interface V8HorizontalPickerView : UIView <UIScrollViewDelegate> {
	UIScrollView *_scrollView;

	id dataSource;
	id delegate;

	NSMutableArray *elementWidths;
	NSMutableSet *reusableViews;

	UIFont *elementFont;

	UIColor *textColor;
	UIColor *selectedTextColor;
	UIColor *theBackgroundColor;
	
	NSInteger numberOfElements;
	NSInteger elementPadding;
	NSInteger endsPadding;
	NSInteger currentSelectedIndex;

	BOOL dataHasBeenLoaded;
	BOOL scrollSizeHasBeenSet;
}

@property (nonatomic, retain) id dataSource;
@property (nonatomic, retain) id delegate;
@property (nonatomic, readonly) NSInteger numberOfElements;
@property (nonatomic, retain) UIFont *elementFont;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *selectedTextColor;
@property (nonatomic, retain) UIColor *theBackgroundColor;

- (UIView *)dequeueReusableView;
- (void)scrollToElement:(NSInteger)index;
- (void)reloadData;

@end

@interface V8HorizontalPickerView (InternalMethods)
- (void)getNumberOfElementsFromDataSource;
- (void)getElementWidthsFromDelegate;
- (void)setTotalWidthOfScrollContent;

- (UIView *)labelForForElementAtIndex:(NSInteger)index withTitle:(NSString *)title;
- (CGRect)frameForElementAtIndex:(NSInteger)index;

- (void)scrollToElementNearestToCenter;
- (NSInteger)nearestElementToCenter;
- (CGPoint)currentCenter;

- (NSInteger)offsetForElementAtIndex:(NSInteger)index;
- (NSInteger)centerOfElementAtIndex:(NSInteger)index;
@end

// ------------------------------------------------------------------
// HorizontalPickerView DataSource Protocol
@protocol V8HorizontalPickerViewDataSource
@required
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker;
@end


// ------------------------------------------------------------------
// HorizontalPickerView Delegate Protocol
@protocol V8HorizontalPickerViewDelegate

@optional
- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index;

// one of these two methods must be defined
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index;
- (UIView *)  horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index;

@required
- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index;

@end