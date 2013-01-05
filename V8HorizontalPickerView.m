//
//  V8HorizontalPickerView.m
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "V8HorizontalPickerView.h"


#pragma mark - Internal Method Interface
@interface V8HorizontalPickerView () {
	UIScrollView *_scrollView;

	// collection of widths of each element.
	NSMutableArray *elementWidths;

	NSInteger elementPadding;

	// state keepers
	BOOL dataHasBeenLoaded;
	BOOL scrollSizeHasBeenSet;
	BOOL scrollingBasedOnUserInteraction;

	// keep track of which elements are visible for tiling
	int firstVisibleElement;
	int lastVisibleElement;
}

- (void)collectData;

- (void)getNumberOfElementsFromDataSource;
- (void)getElementWidthsFromDelegate;
- (void)setTotalWidthOfScrollContent;
- (void)updateScrollContentInset;

- (void)addScrollView;
- (void)drawPositionIndicator;
- (V8HorizontalPickerLabel *)labelForForElementAtIndex:(NSInteger)index withTitle:(NSString *)title;
- (CGRect)frameForElementAtIndex:(NSInteger)index;

- (CGRect)frameForLeftScrollEdgeView;
- (CGRect)frameForRightScrollEdgeView;
- (CGFloat)leftScrollEdgeWidth;
- (CGFloat)rightScrollEdgeWidth;

- (CGPoint)currentCenter;
- (void)scrollToElementNearestToCenter;
- (NSInteger)nearestElementToCenter;
- (NSInteger)nearestElementToPoint:(CGPoint)point;
- (NSInteger)elementContainingPoint:(CGPoint)point;

- (NSInteger)offsetForElementAtIndex:(NSInteger)index;
- (NSInteger)centerOfElementAtIndex:(NSInteger)index;

- (void)scrollViewTapped:(UITapGestureRecognizer *)recognizer;

- (NSInteger)tagForElementAtIndex:(NSInteger)index;
- (NSInteger)indexForElement:(UIView *)element;
@end


#pragma mark - Implementation
@implementation V8HorizontalPickerView : UIView

@synthesize dataSource, delegate;
@synthesize numberOfElements, currentSelectedIndex; // readonly
@synthesize elementFont, textColor, selectedTextColor;
@synthesize selectionPoint, selectionIndicatorView, indicatorPosition;
@synthesize leftEdgeView, rightEdgeView;
@synthesize leftScrollEdgeView, rightScrollEdgeView, scrollEdgeViewPadding;

#pragma mark - Init/Dealloc
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		elementWidths = [[NSMutableArray array] retain];

		[self addScrollView];

		self.textColor   = [UIColor blackColor];
		self.elementFont = [UIFont systemFontOfSize:12.0f];

		currentSelectedIndex = -1; // nothing is selected yet

		numberOfElements     = 0;
		elementPadding       = 0;
		dataHasBeenLoaded    = NO;
		scrollSizeHasBeenSet = NO;
		scrollingBasedOnUserInteraction = NO;

		// default to the center
		selectionPoint = CGPointMake(frame.size.width / 2, 0.0f);
		indicatorPosition = V8HorizontalPickerIndicatorBottom;

		firstVisibleElement = -1;
		lastVisibleElement  = -1;

		scrollEdgeViewPadding = 0.0f;

		self.autoresizesSubviews = YES;
	}
	return self;
}

- (void)dealloc {
	_scrollView.delegate = nil;

	[_scrollView    release];
	[elementWidths  release];
	[elementFont    release];
	[leftEdgeView   release];
	[rightEdgeView  release];

	[leftScrollEdgeView  release];
	[rightScrollEdgeView release];

	[textColor          release];
	[selectedTextColor  release];

	if (selectionIndicatorView) {
		[selectionIndicatorView release];
	}

	[super dealloc];
}


#pragma mark - LayoutSubViews
- (void)layoutSubviews {
	[super layoutSubviews];
	BOOL adjustWhenFinished = NO;

	if (!dataHasBeenLoaded) {
		[self collectData];
	}
	if (!scrollSizeHasBeenSet) {
		adjustWhenFinished = YES;
		[self updateScrollContentInset];
		[self setTotalWidthOfScrollContent];
	}

	SEL titleForElementSelector = @selector(horizontalPickerView:titleForElementAtIndex:);
	SEL viewForElementSelector  = @selector(horizontalPickerView:viewForElementAtIndex:);
	SEL setSelectedSelector     = @selector(setSelectedElement:);

	CGRect visibleBounds   = [self bounds];
	CGRect scaledViewFrame = CGRectZero;

	// remove any subviews that are no longer visible
	for (UIView *view in [_scrollView subviews]) {
		scaledViewFrame = [_scrollView convertRect:[view frame] toView:self];

		// if the view doesn't intersect, it's not visible, so we can recycle it
		if (!CGRectIntersectsRect(scaledViewFrame, visibleBounds)) {
			[view removeFromSuperview];
		} else { // if it is still visible, update it's selected state
			if ([view respondsToSelector:setSelectedSelector]) {
				// view's tag is it's index
				BOOL isSelected = (currentSelectedIndex == [self indexForElement:view]);
				if (isSelected) {
					// if this view is set to be selected, make sure it is over the selection point
					int currentIndex = [self nearestElementToCenter];
					isSelected = (currentIndex == currentSelectedIndex);
				}
				// casting to V8HorizontalPickerLabel so we can call this without all the NSInvocation jazz
				[(V8HorizontalPickerLabel *)view setSelectedElement:isSelected];
			}
		}
	}

	// find needed elements by looking at left and right edges of frame
	CGPoint offset = _scrollView.contentOffset;
	int firstNeededElement = [self nearestElementToPoint:CGPointMake(offset.x, 0.0f)];
	int lastNeededElement  = [self nearestElementToPoint:CGPointMake(offset.x + visibleBounds.size.width, 0.0f)];

	// add any views that have become visible
	UIView *view = nil;
	CGRect tmpViewFrame = CGRectZero;
	CGPoint itemViewCenter = CGPointZero;
	for (int i = firstNeededElement; i <= lastNeededElement; i++) {
		view = nil; // paranoia
		view = [_scrollView viewWithTag:[self tagForElementAtIndex:i]];
		if (!view) {
			if (i < numberOfElements) { // make sure we are not requesting data out of range
				if (self.delegate && [self.delegate respondsToSelector:titleForElementSelector]) {
					NSString *title = [self.delegate horizontalPickerView:self titleForElementAtIndex:i];
					view = [self labelForForElementAtIndex:i withTitle:title];
				} else if (self.delegate && [self.delegate respondsToSelector:viewForElementSelector]) {
					view = [self.delegate horizontalPickerView:self viewForElementAtIndex:i];
					// move view's center to the center of item's ideal frame
					tmpViewFrame = [self frameForElementAtIndex:i];
					itemViewCenter = CGPointMake((tmpViewFrame.size.width / 2.0f) + tmpViewFrame.origin.x, (tmpViewFrame.size.height / 2.0f));
					view.center = itemViewCenter;
				}

				if (view) {
					// use the index as the tag so we can find it later
					view.tag = [self tagForElementAtIndex:i];
					[_scrollView addSubview:view];
				}
			}
		}
	}

	// add the left or right edge views if visible
	CGRect viewFrame = CGRectZero;
	if (leftScrollEdgeView) {
		viewFrame = [self frameForLeftScrollEdgeView];
		scaledViewFrame = [_scrollView convertRect:viewFrame toView:self];
		if (CGRectIntersectsRect(scaledViewFrame, visibleBounds) && ![leftScrollEdgeView isDescendantOfView:_scrollView]) {
			leftScrollEdgeView.frame = viewFrame;
			[_scrollView addSubview:leftScrollEdgeView];
		}
	}
	if (rightScrollEdgeView) {
		viewFrame = [self frameForRightScrollEdgeView];
		scaledViewFrame = [_scrollView convertRect:viewFrame toView:self];
		if (CGRectIntersectsRect(scaledViewFrame, visibleBounds) && ![rightScrollEdgeView isDescendantOfView:_scrollView]) {
			rightScrollEdgeView.frame = viewFrame;
			[_scrollView addSubview:rightScrollEdgeView];
		}
	}

	// save off what's visible now
	firstVisibleElement = firstNeededElement;
	lastVisibleElement  = lastNeededElement;

	// determine if scroll view needs to shift in response to resizing?
	if (currentSelectedIndex > -1 && [self centerOfElementAtIndex:currentSelectedIndex] != [self currentCenter].x) {
		if (adjustWhenFinished) {
			[self scrollToElement:currentSelectedIndex animated:NO];
		} else if (numberOfElements <= currentSelectedIndex) {
			// if currentSelectedIndex no longer exists, select what is currently centered
			currentSelectedIndex = [self nearestElementToCenter];
			[self scrollToElement:currentSelectedIndex animated:NO];
		}
	}
}


#pragma mark - Getters and Setters
- (void)setDelegate:(id)newDelegate {
	if (delegate != newDelegate) {
		delegate = newDelegate;
		[self collectData];
	}
}

- (void)setDataSource:(id)newDataSource {
	if (dataSource != newDataSource) {
		dataSource = newDataSource;
		[self collectData];
	}
}

- (void)setSelectionPoint:(CGPoint)point {
	if (!CGPointEqualToPoint(point, selectionPoint)) {
		selectionPoint = point;
		[self updateScrollContentInset];
	}
}

// allow the setting of this views background color to change the scroll view
- (void)setBackgroundColor:(UIColor *)newColor {
	[super setBackgroundColor:newColor];
	_scrollView.backgroundColor = newColor;
	// TODO: set all subviews as well?
}

- (void)setIndicatorPosition:(V8HorizontalPickerIndicatorPosition)position {
	if (indicatorPosition != position) {
		indicatorPosition = position;
		[self drawPositionIndicator];
	}
}

- (void)setSelectionIndicatorView:(UIView *)indicatorView {
	if (selectionIndicatorView != indicatorView) {
		if (selectionIndicatorView) {
			[selectionIndicatorView removeFromSuperview];
			[selectionIndicatorView release];
		}
		selectionIndicatorView = [indicatorView retain];

		[self drawPositionIndicator];
	}
}

- (void)setLeftEdgeView:(UIView *)leftView {
	if (leftEdgeView != leftView) {
		if (leftEdgeView) {
			[leftEdgeView removeFromSuperview];
			[leftEdgeView release];
		}
		leftEdgeView = [leftView retain];

		CGRect tmpFrame = leftEdgeView.frame;
		tmpFrame.origin.x = 0.0f;
		tmpFrame.origin.y = 0.0f;
		leftEdgeView.frame = tmpFrame;
		[self addSubview:leftEdgeView];
	}
}

- (void)setRightEdgeView:(UIView *)rightView {
	if (rightEdgeView != rightView) {
		if (rightEdgeView) {
			[rightEdgeView removeFromSuperview];
			[rightEdgeView release];
		}
		rightEdgeView = [rightView retain];

		CGRect tmpFrame = rightEdgeView.frame;
		tmpFrame.origin.x = self.frame.size.width - tmpFrame.size.width;
		tmpFrame.origin.y = 0.0f;
		rightEdgeView.frame = tmpFrame;
		[self addSubview:rightEdgeView];
	}
}

- (void)setLeftScrollEdgeView:(UIView *)leftView {
	if (leftScrollEdgeView != leftView) {
		if (leftScrollEdgeView) {
			[leftScrollEdgeView removeFromSuperview];
			[leftScrollEdgeView release];
		}
		leftScrollEdgeView = [leftView retain];

		scrollSizeHasBeenSet = NO;
		[self setNeedsLayout];
	}
}

- (void)setRightScrollEdgeView:(UIView *)rightView {
	if (rightScrollEdgeView != rightView) {
		if (rightScrollEdgeView) {
			[rightScrollEdgeView removeFromSuperview];
			[rightScrollEdgeView release];
		}
		rightScrollEdgeView = [rightView retain];

		scrollSizeHasBeenSet = NO;
		[self setNeedsLayout];
	}
}

- (void)setFrame:(CGRect)newFrame {
	if (!CGRectEqualToRect(self.frame, newFrame)) {
		// causes recalulation of offsets, etc based on new size
		scrollSizeHasBeenSet = NO;
	}
	[super setFrame:newFrame];
}

#pragma mark - Data Fetching Methods
- (void)reloadData {
	// remove all scrollview subviews and "recycle" them
	for (UIView *view in [_scrollView subviews]) {
		[view removeFromSuperview];
	}

	firstVisibleElement = NSIntegerMax;
	lastVisibleElement  = NSIntegerMin;

	[self collectData];
}

- (void)collectData {
	scrollSizeHasBeenSet = NO;
	dataHasBeenLoaded    = NO;

	[self getNumberOfElementsFromDataSource];
	[self getElementWidthsFromDelegate];
	[self setTotalWidthOfScrollContent];
	[self updateScrollContentInset];

	dataHasBeenLoaded = YES;
	[self setNeedsLayout];
}


#pragma mark - Scroll To Element Method
- (void)scrollToElement:(NSInteger)index animated:(BOOL)animate {
	currentSelectedIndex = index;
	int x = [self centerOfElementAtIndex:index] - selectionPoint.x;
	[_scrollView setContentOffset:CGPointMake(x, 0) animated:animate];

	// notify delegate of the selected index
	SEL delegateCall = @selector(horizontalPickerView:didSelectElementAtIndex:);
	if (self.delegate && [self.delegate respondsToSelector:delegateCall]) {
		[self.delegate horizontalPickerView:self didSelectElementAtIndex:index];
	}

#if (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_3)
	[self setNeedsLayout];
#endif
}


#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	if (scrollingBasedOnUserInteraction) {
		// NOTE: sizing and/or changing orientation of control might cause scrolling
		//		 not initiated by user. do not update current selection in these
		//		 cases so that the view state is properly preserved.

		// set the current item under the center to "highlighted" or current
		currentSelectedIndex = [self nearestElementToCenter];
	}

#if (__IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_4_3)
	[self setNeedsLayout];
#endif
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	scrollingBasedOnUserInteraction = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	// only do this if we aren't decelerating
	if (!decelerate) {
		[self scrollToElementNearestToCenter];
	}
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView { }

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self scrollToElementNearestToCenter];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	scrollingBasedOnUserInteraction = NO;
}


#pragma mark - View Creation Methods (Internal Methods)
- (void)addScrollView {
	if (_scrollView == nil) {
		_scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
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
		_scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
		_scrollView.autoresizesSubviews = YES;

		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTapped:)];
		[_scrollView addGestureRecognizer:tapRecognizer];
		[tapRecognizer release];

		[self addSubview:_scrollView];
	}
}

- (void)drawPositionIndicator {
	CGRect indicatorFrame = selectionIndicatorView.frame;
	CGFloat x = self.selectionPoint.x - (indicatorFrame.size.width / 2);
	CGFloat y;

	switch (self.indicatorPosition) {
		case V8HorizontalPickerIndicatorTop: {
			y = 0.0f;
			break;
		}
		case V8HorizontalPickerIndicatorBottom: {
			y = self.frame.size.height - indicatorFrame.size.height;
			break;
		}
		default:
			break;
	}

	// properly place indicator image in view relative to selection point
	CGRect tmpFrame = CGRectMake(x, y, indicatorFrame.size.width, indicatorFrame.size.height);
	selectionIndicatorView.frame = tmpFrame;
	[self addSubview:selectionIndicatorView];
}

// create a UILabel for this element.
- (V8HorizontalPickerLabel *)labelForForElementAtIndex:(NSInteger)index withTitle:(NSString *)title {
	CGRect labelFrame     = [self frameForElementAtIndex:index];
	V8HorizontalPickerLabel *elementLabel = [[V8HorizontalPickerLabel alloc] initWithFrame:labelFrame];

	elementLabel.textAlignment   = UITextAlignmentCenter;
	elementLabel.backgroundColor = self.backgroundColor;
	elementLabel.text            = title;
	elementLabel.font            = self.elementFont;

	elementLabel.normalStateColor   = self.textColor;
	elementLabel.selectedStateColor = self.selectedTextColor;

	// show selected status if this element is the selected one and is currently over selectionPoint
	int currentIndex = [self nearestElementToCenter];
	elementLabel.selectedElement = (currentSelectedIndex == index) && (currentIndex == currentSelectedIndex);

	return [elementLabel autorelease];
}


#pragma mark - DataSource Calling Method (Internal Method)
- (void)getNumberOfElementsFromDataSource {
	SEL dataSourceCall = @selector(numberOfElementsInHorizontalPickerView:);
	if (self.dataSource && [self.dataSource respondsToSelector:dataSourceCall]) {
		numberOfElements = [self.dataSource numberOfElementsInHorizontalPickerView:self];
	} else {
		numberOfElements = 0;
	}
}


#pragma mark - Delegate Calling Method (Internal Method)
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


#pragma mark - View Calculation and Manipulation Methods (Internal Methods)
// what is the total width of the content area?
- (void)setTotalWidthOfScrollContent {
	NSInteger totalWidth = 0;

	totalWidth += [self leftScrollEdgeWidth];
	totalWidth += [self rightScrollEdgeWidth];

	// sum the width of all elements
	for (NSNumber *width in elementWidths) {
		totalWidth += [width intValue];
		totalWidth += elementPadding;
	}
	// TODO: is this necessary?
	totalWidth -= elementPadding; // we add "one too many" in for loop

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

		CGFloat halfFirstWidth = 0.0f;
		CGFloat halfLastWidth  = 0.0f;
		if ( [elementWidths count] > 0 ) {
			halfFirstWidth = [[elementWidths objectAtIndex:0] floatValue] / 2.0; 
			halfLastWidth  = [[elementWidths lastObject] floatValue]      / 2.0;
		}

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
		firstInset -= [self leftScrollEdgeWidth];
		CGFloat lastInset  = (scrollerWidth - selectionPoint.x) - halfLastWidth;
		lastInset -= [self rightScrollEdgeWidth];

		_scrollView.contentInset = UIEdgeInsetsMake(0, firstInset, 0, lastInset);
	}
}

// what is the left-most edge of the element at the given index?
- (NSInteger)offsetForElementAtIndex:(NSInteger)index {
	NSInteger offset = 0;
	if (index >= [elementWidths count]) {
		return 0;
	}

	offset += [self leftScrollEdgeWidth];

	for (int i = 0; i < index && i < [elementWidths count]; i++) {
		offset += [[elementWidths objectAtIndex:i] intValue];
		offset += elementPadding;
	}
	return offset;
}

// return the tag for an element at a given index
- (NSInteger)tagForElementAtIndex:(NSInteger)index {
	return (index + 1) * 10;
}

// return the index given an element's tag
- (NSInteger)indexForElement:(UIView *)element {
	return (element.tag / 10) - 1;
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
	CGFloat width = 0.0f;
	if ([elementWidths count] > index) {
		width = [[elementWidths objectAtIndex:index] intValue];
	}
	return CGRectMake([self offsetForElementAtIndex:index], 0.0f, width, self.frame.size.height);
}

// what is the frame for the left scroll edge view?
- (CGRect)frameForLeftScrollEdgeView {
	if (leftScrollEdgeView) {
		CGFloat scrollHeight = _scrollView.contentSize.height;
		CGFloat viewHeight   = leftScrollEdgeView.frame.size.height;
		return CGRectMake(0.0f, ((scrollHeight / 2.0f) - (viewHeight / 2.0f)),
						  leftScrollEdgeView.frame.size.width, viewHeight);
	} else {
		return CGRectZero;
	}
}

// what is the width of the left edge of the scroll area?
- (CGFloat)leftScrollEdgeWidth {
	if (leftScrollEdgeView) {
		CGFloat width = leftScrollEdgeView.frame.size.width;
		width += scrollEdgeViewPadding;
		return width;
	}
	return 0.0f;
}

// what is the frame for the right scroll edge view?
- (CGRect)frameForRightScrollEdgeView {
	if (rightScrollEdgeView) {
		CGFloat scrollWidth  = _scrollView.contentSize.width;
		CGFloat scrollHeight = _scrollView.contentSize.height;
		CGFloat viewWidth  = rightScrollEdgeView.frame.size.width;
		CGFloat viewHeight = rightScrollEdgeView.frame.size.height;
		return CGRectMake(scrollWidth - viewWidth, ((scrollHeight / 2.0f) - (viewHeight / 2.0f)),
						  viewWidth, viewHeight);
	} else {
		return CGRectZero;
	}
}

// what is the width of the right edge of the scroll area?
- (CGFloat)rightScrollEdgeWidth {
	if (rightScrollEdgeView) {
		CGFloat width = rightScrollEdgeView.frame.size.width;
		width += scrollEdgeViewPadding;
		return width;
	}
	return 0.0f;
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

// similar to nearestElementToPoint: however, this method does not look past beginning/end
- (NSInteger)elementContainingPoint:(CGPoint)point {
	for (int i = 0; i < numberOfElements; i++) {
		CGRect frame = [self frameForElementAtIndex:i];
		if (CGRectContainsPoint(frame, point)) {
			return i;
		}
	}
	return -1;
}

// move scroll view to position nearest element under the center
- (void)scrollToElementNearestToCenter {
	[self scrollToElement:[self nearestElementToCenter] animated:YES];
}


#pragma mark - Tap Gesture Recognizer Handler Method
// use the gesture recognizer to slide to element under tap
- (void)scrollViewTapped:(UITapGestureRecognizer *)recognizer {
	if (recognizer.state == UIGestureRecognizerStateRecognized) {
		CGPoint tapLocation    = [recognizer locationInView:_scrollView];
		NSInteger elementIndex = [self elementContainingPoint:tapLocation];
		if (elementIndex != -1) { // point not in element
			[self scrollToElement:elementIndex animated:YES];
		}
	}
}

@end



// ------------------------------------------------------------------------
#pragma mark - Picker Label Implementation
@implementation V8HorizontalPickerLabel : UILabel

@synthesize selectedElement, selectedStateColor, normalStateColor;

- (void)setSelectedElement:(BOOL)selected {
	if (selectedElement != selected) {
		if (selected) {
			self.textColor = self.selectedStateColor;
		} else {
			self.textColor = self.normalStateColor;
		}
		selectedElement = selected;
		[self setNeedsLayout];
	}
}

- (void)setNormalStateColor:(UIColor *)color {
	if (normalStateColor != color) {
		[normalStateColor release];
		normalStateColor = [color retain];
		self.textColor = normalStateColor;
		[self setNeedsLayout];
	}
}

@end