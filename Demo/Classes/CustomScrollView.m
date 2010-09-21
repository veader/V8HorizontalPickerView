//
//  CustomScrollView.m
//  fStats
//
//  Created by Shawn Veader on 9/19/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "CustomScrollView.h"


@implementation CustomScrollView


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef c = UIGraphicsGetCurrentContext();

	// draw our center line
    CGFloat red[4] = {1.0f, 0.0f, 0.0f, 1.0f};
    CGContextSetStrokeColor(c, red);
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, self.center.x, 0.0f);
    CGContextAddLineToPoint(c, self.center.x, self.frame.size.height);
    CGContextStrokePath(c);

	// outline each view
//    CGFloat white[4] = {1.0f, 1.0f, 1.0f, 1.0f};
//    CGContextSetStrokeColor(c, white);
//	for (UIView *view in [self subviews]) {
//		CGRect tmpFrame = view.frame;
//		CGContextStrokeRect(c, tmpFrame);
//	}
}
/*

- (void)dealloc {
    [super dealloc];
}


@end
