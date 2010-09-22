//
//  TestingScrollView.h
//  HorzPickerTestApp
//
//  Created by Shawn Veader on 9/21/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TestingScrollView : UIScrollView {
	CGPoint selectionLineOrigin;
}

@property (nonatomic, assign) CGPoint selectionLineOrigin;

@end
