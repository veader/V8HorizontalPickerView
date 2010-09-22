//
//  V8HorizontalPickerView.m
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "V8HorizontalPickerView.h"

#ifdef V8TESTINGUI
#import "TestingScrollView.h"
#endif

#pragma mark -
#pragma mark Internal Method Interface
@interface V8HorizontalPickerView (InternalMethods)
- (void)getNumberOfElementsFromDataSource;
- (void)getElementWidthsFromDelegate;
- (void)setTotalWidthOfScrollContent;
- (void)updateScrollContentInset;

- (void)addScrollView;
- (UIView *)labelForForElementAtIndex:(NSInteger)index withTitle:(NSString *)title;
- (CGRect)frameForElementAtIndex:(NSInteger)index;

- (CGPoint)currentCenter;
- (void)scrollToElementNearestToCenter;
- (NSInteger)nearestElementToCenter;
- (NSInteger)nearestElementToPoint:(CGPoint)point;

- (NSInteger)offsetForElementAtIndex:(NSInteger)index;
- (NSInteger)centerOfElementAtIndex:(NSInteger)index;

- (void)scrollViewTapped:(UITapGestureRecognizer *)recognizer;
@end


#pragma mark -
#pragma mark Implementation
@implementation V8HorizontalPickerView : UIView

@synthesize dataSource, delegate;
@synthesize numberOfElements; // readonly
@synthesize elementFont, textColor, selectedTextColor;
@synthesize selectionPoint, selectionIndicatorView;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		elementWidths = [[NSMutableArray array] retain];
		_reusableViews = [[NSMutableSet alloc] init];

		[self addScrollView];
		
		self.textColor   = [UIColor blackColor];
		self.elementFont = [UIFont systemFontOfSize:12.0f];

		numberOfElements     = 0;
		elementPadding       = 0;
		currentSelectedIndex = 0;
		dataHasBeenLoaded    = NO;
		scrollSizeHasBeenSet = NO;

		// default to the center
		selectionPoint = CGPointMake(frame.size.width / 2, 0.0f);
	}
    return self;
}

- (void)dealloc {
	[_scrollView   release];
	[elementWidths release];
	[elementFont   release];
	[_reusableViews release];

	[textColor          release];
	[selectedTextColor  release];

	if (selectionIndicatorView) {
		[selectionIndicatorView release];
	}

    [super dealloc];
}

#pragma mark -
#pragma mark LayoutSubViews
- (void)layoutSubviews {
	[super layoutSubviews];

	if (!dataHasBeenLoaded) {
		[self reloadData];
	}
	if (!scrollSizeHasBeenSet) {
		[self setTotalWidthOfScrollContent];
	}

	SEL titleForElementSelector  = @selector(horizontalPickerView:titleForElementAtIndex:);
	SEL viewForElementSelector   = @selector(horizontalPickerView:viewForElementAtIndex:);

	for (UIView *view in [_scrollView subviews]) {
		[view removeFromSuperview];
	}

	// TODO: remove this in favor of loading the views as we go
	for (int i = 0; i < numberOfElements; i++) {
		UIView *view = nil;
		if (self.delegate && [self.delegate respondsToSelector:titleForElementSelector]) {
			NSString *title = [self.delegate horizontalPickerView:self titleForElementAtIndex:i];
			view = [self labelForForElementAtIndex:i withTitle:title];
		} else if (self.delegate && [self.delegate respondsToSelector:viewForElementSelector]) {
			view = [self.delegate horizontalPickerView:self viewForElementAtIndex:i];
			// TODO: possibly adjust frame
		} else {
			// TODO: go boom! ???
		}
		
		if (view) {
			[_scrollView addSubview:view];
		}
	}
}

#pragma mark -
#pragma mark Getters and Setters
- (void)setDelegate:(id)newDelegate {
	if (delegate != newDelegate) {
		delegate = newDelegate;
		[self reloadData];
	}
}

- (void)setDataSource:(id)newDataSource {
	if (dataSource != newDataSource) {
		dataSource = newDataSource;
		[self reloadData];
	}
}

- (void)setSelectionPoint:(CGPoint)point {
	if (!CGPointEqualToPoint(point, selectionPoint)) {
		selectionPoint = point;
		[self updateScrollContentInset];
#ifdef V8TESTINGUI
		((TestingScrollView *)_scrollView).selectionLineOrigin = selectionPoint;
#endif
	}
}

// allow the setting of this views background color to change the scroll view
- (void)setBackgroundColor:(UIColor *)newColor {
	[super setBackgroundColor:newColor];
	_scrollView.backgroundColor = newColor;
	// TODO: set all subviews as well?
}

- (void)setSelectionIndicatorView:(UIView *)indicatorView {
	if (selectionIndicatorView != indicatorView) {
		[selectionIndicatorView release];
		selectionIndicatorView = [indicatorView retain];

		// properly place indicator image in view relative to selection point
		CGFloat x = self.selectionPoint.x - (selectionIndicatorView.frame.size.width / 2);
		CGFloat y = self.frame.size.height - selectionIndicatorView.frame.size.height;
		CGRect tmpFrame = CGRectMake(x, y,
									 selectionIndicatorView.frame.size.width,
									 selectionIndicatorView.frame.size.height);
		selectionIndicatorView.frame = tmpFrame;
		[self addSubview:selectionIndicatorView];
	}
}

#pragma mark -
#pragma mark Reload Data Method
- (void)reloadData {
	scrollSizeHasBeenSet = NO;
	dataHasBeenLoaded    = NO;

	[self getNumberOfElementsFromDataSource];
	[self getElementWidthsFromDelegate];
	[self setTotalWidthOfScrollContent];
	[self updateScrollContentInset];

	dataHasBeenLoaded = YES;
}

#pragma mark -
#pragma mark Scroll To Element Method
- (void)scrollToElement:(NSInteger)index animated:(BOOL)animate {
	int x = [self centerOfElementAtIndex:index] - selectionPoint.x;
	[_scrollView setContentOffset:CGPointMake(x, 0) animated:animate];
	currentSelectedIndex = index;

	// notify delegate of the selected index
	SEL delegateCall = @selector(horizontalPickerView:didSelectElementAtIndex:);
	if (self.delegate && [self.delegate respondsToSelector:delegateCall]) {
		[self.delegate horizontalPickerView:self didSelectElementAtIndex:index];
	}
}


#pragma mark -
#pragma mark Reusable View
// TODO: use this
- (UIView *)dequeueReusableView {
    UIView *view = [_reusableViews anyObject];
    if (view) {
        [[view retain] autorelease];
        [_reusableViews removeObject:view];
    }
    return view;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// set the current item under the center to "highlighted" or current
	currentSelectedIndex = [self nearestElementToCenter];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	// only do this if we aren't decelerating
	if (!decelerate) {
		[self scrollToElementNearestToCenter];
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
//	[self scrollToElementNearestToCenter];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self scrollToElementNearestToCenter];
}

#pragma mark -
#pragma mark View Creation Methods (Internal Methods)
- (void)addScrollView {
	if (_scrollView == nil) {
#ifdef V8TESTINGUI
		_scrollView = [[TestingScrollView alloc] initWithFrame:self.bounds];
		((TestingScrollView *)_scrollView).selectionLineOrigin = selectionPoint;
#else
		_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
#endif
		_scrollView.delegate = self;
		_scrollView.scrollEnabled = YES;
		_scrollView.scrollsToTop  = NO;
		_scrollView.showsVerticalScrollIndicator   = NO;
		_scrollView.showsHorizontalScrollIndicator = NO;
		_scrollView.bouncesZoom  = NO;
		_scrollView.alwaysBounceHorizontal = YES;
		_scrollView.alwaysBounceVertical   = NO;
		_scrollView.minimumZoomScale = 1.0; // setting min/max the same disables zooming
		_scrollView.maximumZoomScale = 1.0;
		_scrollView.contentInset = UIEdgeInsetsZero;
		_scrollView.decelerationRate = 0.1; //UIScrollViewDecelerationRateNormal;
		
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
		[_scrollView addGestureRecognizer:tapRecognizer];
		[tapRecognizer release];
		
		[self addSubview:_scrollView];
	}
}

// create a UILabel for this element.
- (UIView *)labelForForElementAtIndex:(NSInteger)index withTitle:(NSString *)title {
	CGRect labelFrame     = [self frameForElementAtIndex:index];
	UILabel *elementLabel = [[UILabel alloc] initWithFrame:labelFrame];

	elementLabel.textAlignment   = UITextAlignmentCenter;
	elementLabel.backgroundColor = self.backgroundColor;
	elementLabel.text            = title;
	elementLabel.font            = self.elementFont;

	if (currentSelectedIndex == index && self.selectedTextColor) {
		elementLabel.textColor = self.selectedTextColor;
	} else {
		elementLabel.textColor = self.textColor;
	}

	return [elementLabel autorelease];
}

#pragma mark -
#pragma mark DataSource Calling Method (Internal Method)
- (void)getNumberOfElementsFromDataSource {
	SEL dataSourceCall = @selector(numberOfElementsInHorizontalPickerView:);
	if (self.dataSource && [self.dataSource respondsToSelector:dataSourceCall]) {
		numberOfElements = [self.dataSource numberOfElementsInHorizontalPickerView:self];
	}
}

#pragma mark -
#pragma mark Delegate Calling Method (Internal Method)
- (void)getElementWidthsFromDelegate {
	SEL delegateCall = @selector(horizontalPickerView:widthForElementAtIndex:);
	[elementWidths removeAllObjects];
	for (int i = 0; i < numberOfElements; i++) {
		if (self.delegate && [self.delegate respondsToSelector:delegateCall]) {
			NSInteger width = [self.delegate horizontalPickerView:self widthForElementAtIndex:i];
			[elementWidths addObject:[NSNumber numberWithInteger:width]];
		}
	}
}

#pragma mark -
#pragma mark View Calculation and Manipulation Methods (Internal Methods)
// what is the total width of the content area?
- (void)setTotalWidthOfScrollContent {
	NSInteger totalWidth = 0;
	for (int i = 0; i < numberOfElements; i++) {
		totalWidth += [[elementWidths objectAtIndex:i] intValue];
		totalWidth += elementPadding;
	}

	if (_scrollView) {
		// create our scroll view as wide as all the elements to be included
		_scrollView.contentSize = CGSizeMake(totalWidth, self.bounds.size.height);
		scrollSizeHasBeenSet = YES;
	}
}

// reset the content inset of the scroll view based on centering first and last elements.
- (void)updateScrollContentInset {
	// update content inset if we have element widths
	if ([elementWidths count] != 0) {
		CGFloat scrollerWidth = _scrollView.frame.size.width;

		CGFloat halfFirstWidth = [[elementWidths objectAtIndex:0] floatValue] / 2.0; 
		CGFloat halfLastWidth  = [[elementWidths lastObject] floatValue]      / 2.0;
		
		// calculating the inset so that the bouncing on the ends happens more smooothly
		// - first inset is the distance from the left edge to the left edge of the
		//     first element when that element is centered under the selection point.
		//     - represented below as the # area
		// - last inset is the distance from the right edge to the right edge of
		//     the last element when that element is centered under the selection point.
		//     - represented below as the * area
		//
		//        Selection
		//  +---------|---------------+
		//  |####| Element |**********| << UIScrollView
		//  +-------------------------+
		CGFloat firstInset = selectionPoint.x - halfFirstWidth;
		CGFloat lastInset  = (scrollerWidth - selectionPoint.x) - halfLastWidth;

		_scrollView.contentInset = UIEdgeInsetsMake(0, firstInset, 0, lastInset);
	}
}

// what is the left-most edge of the element at the given index?
- (NSInteger)offsetForElementAtIndex:(NSInteger)index {
	NSInteger offset = 0;
	if (index >= [elementWidths count]) {
		return 0;
	}

	for (int i = 0; i < index; i++) {
		offset += [[elementWidths objectAtIndex:i] intValue];
		offset += elementPadding;
	}
	return offset;
}

// what is the center of the element at the given index?
- (NSInteger)centerOfElementAtIndex:(NSInteger)index {
	if (index >= [elementWidths count]) {
		return 0;
	}
	
	NSInteger elementOffset = [self offsetForElementAtIndex:index];
	NSInteger elementWidth  = [[elementWidths objectAtIndex:index] intValue] / 2;
	return elementOffset + elementWidth;
}

// what is the frame for the element at the given index?
- (CGRect)frameForElementAtIndex:(NSInteger)index {
#ifdef V8TESTINGUI
	CGFloat heightPadding = 5.0f;
#else
	CGFloat heightPadding = 0.0f;
#endif
	return CGRectMake([self offsetForElementAtIndex:index],
					  heightPadding,
					  [[elementWidths objectAtIndex:index] intValue],
					  self.frame.size.height - (heightPadding * 2));
}

// what is the "center", relative to the content offset and adjusted to selection point?
- (CGPoint)currentCenter {
	CGFloat x = _scrollView.contentOffset.x + selectionPoint.x;
	return CGPointMake(x, 0.0f);
}

// what is the element nearest to the center of the view?
- (NSInteger)nearestElementToCenter {
	return [self nearestElementToPoint:[self currentCenter]];
}

// what is the element nearest to the given point?
- (NSInteger)nearestElementToPoint:(CGPoint)point {
	for (int i = 0; i < numberOfElements; i++) {
		CGRect frame = [self frameForElementAtIndex:i];
		if (CGRectContainsPoint(frame, point)) {
			return i;
		} else if (point.x < frame.origin.x) {
			// if the center is before this element, go back to last one,
			//     unless we're at the beginning
			if (i > 0) {
				return i - 1;
			} else {
				return 0;
			}
			break;
		} else if (point.x > frame.origin.y) {
			// if the center is past the last element, scroll to it
			if (i == numberOfElements - 1) {
				return i;
			}
		}
	}
	return 0;
}

// move scroll view to position nearest element under the center
- (void)scrollToElementNearestToCenter {
	[self scrollToElement:[self nearestElementToCenter] animated:YES];
}

// use the gesture recognizer to slide to element under tap
- (void)scrollViewTapped:(UITapGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateRecognized ) {
		CGPoint tapLocation    = [recognizer locationInView:_scrollView];
		NSInteger elementIndex = [self nearestElementToPoint:tapLocation];
		[self scrollToElement:elementIndex animated:YES];
	}
}
@end
