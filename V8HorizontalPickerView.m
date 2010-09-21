//
//  V8HorizontalPickerView.m
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "V8HorizontalPickerView.h"

#pragma mark -
#pragma mark Internal Method Interface
@interface V8HorizontalPickerView (InternalMethods)
- (void)getNumberOfElementsFromDataSource;
- (void)getElementWidthsFromDelegate;
- (void)setTotalWidthOfScrollContent;

- (UIView *)labelForForElementAtIndex:(NSInteger)index withTitle:(NSString *)title;
- (CGRect)frameForElementAtIndex:(NSInteger)index;

- (void)scrollToElementNearestToCenter;
- (NSInteger)nearestElementToCenter;
- (CGPoint)currentCenter;
- (BOOL)scrolledPastEnds;

- (NSInteger)offsetForElementAtIndex:(NSInteger)index;
- (NSInteger)centerOfElementAtIndex:(NSInteger)index;
@end


#pragma mark -
#pragma mark Implementation
@implementation V8HorizontalPickerView : UIView

@synthesize dataSource, delegate;
@synthesize numberOfElements; // readonly
@synthesize elementFont, textColor, selectedTextColor, theBackgroundColor;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
		elementWidths = [[NSMutableArray array] retain];
		reusableViews = [[NSMutableSet alloc] init];

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
		[self addSubview:_scrollView];
		
		self.textColor = [UIColor blackColor];

		numberOfElements     = 0;
		elementPadding       = 0;
		currentSelectedIndex = 0;
		endsPadding = frame.size.width / 2;
		dataHasBeenLoaded    = NO;
		scrollSizeHasBeenSet = NO;
	}
    return self;
}

- (void)dealloc {
	[_scrollView release];
	[elementWidths release];
	[elementFont release];
	[reusableViews release];

	[textColor release];
	[selectedTextColor release];
	[theBackgroundColor release];

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
		[delegate release];
		delegate = [newDelegate retain];
		[self reloadData];
	}
}

- (void)setDataSource:(id)newDataSource {
	if (dataSource != newDataSource) {
		[dataSource release];
		dataSource = [newDataSource retain];
		[self reloadData];
	}
}

// allow the setting of this views background color to change the scroll view
- (void)setBackgroundColor:(UIColor *)newColor {
	[super setBackgroundColor:newColor];
	_scrollView.backgroundColor = newColor;
	self.theBackgroundColor = newColor;
	// TODO: set all subviews as well?
}

#pragma mark -
#pragma mark Reload Data Method
- (void)reloadData {
	scrollSizeHasBeenSet = NO;
	dataHasBeenLoaded    = NO;

	[self getNumberOfElementsFromDataSource];
	[self getElementWidthsFromDelegate];
	[self setTotalWidthOfScrollContent];

	dataHasBeenLoaded = YES;
}

#pragma mark -
#pragma mark Scroll To Element Method
- (void)scrollToElement:(NSInteger)index animated:(BOOL)animate {
	int x = [self centerOfElementAtIndex:index] - _scrollView.center.x;
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
    UIView *view = [reusableViews anyObject];
    if (view) {
        [[view retain] autorelease];
        [reusableViews removeObject:view];
    }
    return view;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	// set the current item under the center to "highlighted" or current
	currentSelectedIndex = [self nearestElementToCenter];

	// TODO: is there a way to stop them from scrolling past a point?
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
	// only do this if we aren't decelerating
	if (!decelerate) {
		[self scrollToElementNearestToCenter];
	}
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
	// only do this if we're past the beginning or end
	if ([self scrolledPastEnds]) {
		[self scrollToElementNearestToCenter];
	}
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	[self scrollToElementNearestToCenter];
}


#pragma mark -
#pragma mark View Creation (Internal Method)
// create UILabel for this element.
- (UIView *)labelForForElementAtIndex:(NSInteger)index withTitle:(NSString *)title {
	CGRect labelFrame     = [self frameForElementAtIndex:index];
	UILabel *elementLabel = [[UILabel alloc] initWithFrame:labelFrame];

	elementLabel.textAlignment   = UITextAlignmentCenter;
	elementLabel.backgroundColor = self.theBackgroundColor;
	elementLabel.text            = title;

	if (currentSelectedIndex == index && self.selectedTextColor) {
		elementLabel.textColor = self.selectedTextColor;
	} else {
		elementLabel.textColor = self.textColor;
	}
	if (self.elementFont) {
		elementLabel.font = self.elementFont;
	} else {
		elementLabel.font = [UIFont systemFontOfSize:12.0f];
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
	NSInteger totalWidth = endsPadding;
	for (int i = 0; i < numberOfElements; i++) {
		totalWidth += [[elementWidths objectAtIndex:i] intValue];
		totalWidth += elementPadding;
	}
	totalWidth += endsPadding;

	if (_scrollView) {
		// create our scroll view as wide as all the elements to be included
		_scrollView.contentSize = CGSizeMake(totalWidth, self.bounds.size.height);
		scrollSizeHasBeenSet = YES;
	}
}

// what is the left-most edge of the element at the given index?
- (NSInteger)offsetForElementAtIndex:(NSInteger)index {
	NSInteger offset = endsPadding;

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
	return CGRectMake([self offsetForElementAtIndex:index],
					  0.0f,
					  [[elementWidths objectAtIndex:index] intValue],
					  self.frame.size.height);
}

// what is the center, relative to the content offset?
- (CGPoint)currentCenter {
	return CGPointMake(_scrollView.contentOffset.x + _scrollView.center.x, 
					   _scrollView.center.y);
}

// what is the element nearest to the center of the view?
- (NSInteger)nearestElementToCenter {
	CGPoint center = [self currentCenter];

	for (int i = 0; i < numberOfElements; i++) {
		CGRect frame = [self frameForElementAtIndex:i];
		if (CGRectContainsPoint(frame, center)) {
			return i;
		} else if (center.x < frame.origin.x) {
			// if the center is before this element, go back to last one,
			//     unless we're at the beginning
			if (i > 0) {
				return i - 1;
			} else {
				return 0;
			}
			break;
		} else if (center.x > frame.origin.y) {
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

- (BOOL)scrolledPastEnds {
	CGPoint center = [self currentCenter];
	CGRect firstFrame = [self frameForElementAtIndex:0];
	CGRect lastFrame  = [self frameForElementAtIndex:numberOfElements - 1];
	if (center.x < firstFrame.origin.x || center.x > lastFrame.origin.x) {
		return YES;
	}
	return NO;
}

@end
