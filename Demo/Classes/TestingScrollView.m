//
//  TestingScrollView.m
//  HorzPickerTestApp
//
//  Created by Shawn Veader on 9/21/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "TestingScrollView.h"


@implementation TestingScrollView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    // Drawing center line
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
	CGContextSetStrokeColor(c, red);
	CGContextBeginPath(c);
	CGFloat centerX = self.center.x;
	UIEdgeInsets insets = self.contentInset;
	CGContextMoveToPoint(c, centerX - insets.left, 0.0f);
	CGContextAddLineToPoint(c, centerX - insets.left, self.frame.size.height);
	CGContextStrokePath(c);
}

- (void)dealloc {
    [super dealloc];
}


@end
