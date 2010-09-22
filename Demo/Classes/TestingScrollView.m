//
//  TestingScrollView.m
//  HorzPickerTestApp
//
//  Created by Shawn Veader on 9/21/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "TestingScrollView.h"


@implementation TestingScrollView

@synthesize selectionLineOrigin;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	CGContextRef c = UIGraphicsGetCurrentContext();
	UIEdgeInsets insets = self.contentInset;

	// draw a center line
	CGFloat yellow[4] = {1.0f, 0.6f, 0.6f, 1.0f};
	CGContextSetStrokeColor(c, yellow);
	CGContextBeginPath(c);
	CGContextMoveToPoint(c, self.center.x - insets.left, 0.0f);
	CGContextAddLineToPoint(c, self.center.x - insets.left, self.frame.size.height);
	CGContextStrokePath(c);

	// draw selection line
	CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
	CGContextSetStrokeColor(c, red);
	CGContextBeginPath(c);
	CGContextMoveToPoint(c, self.selectionLineOrigin.x - insets.left, 0.0f);
	CGContextAddLineToPoint(c, self.selectionLineOrigin.x - insets.left, self.frame.size.height);
	CGContextStrokePath(c);
}

- (void)dealloc {
    [super dealloc];
}

- (void)setSelectionLineOrigin:(CGPoint)point {
	if (!CGPointEqualToPoint(point, selectionLineOrigin)) {
		selectionLineOrigin = point;
		[self setNeedsLayout];
	}
}

@end
