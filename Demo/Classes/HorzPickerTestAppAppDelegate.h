//
//  HorzPickerTestAppAppDelegate.h
//  HorzPickerTestApp
//
//  Created by Shawn Veader on 9/20/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorzPickerTestAppAppDelegate : NSObject <UIApplicationDelegate> { }

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) TestViewController *testView;

@end

