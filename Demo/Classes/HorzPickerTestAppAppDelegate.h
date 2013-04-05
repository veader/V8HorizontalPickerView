//
//  HorzPickerTestAppAppDelegate.h
//  HorzPickerTestApp
//
//  Created by Shawn Veader on 9/20/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HorzPickerTestAppAppDelegate : NSObject <UIApplicationDelegate> { }

@property (nonatomic, strong) IBOutlet UIWindow *window;
@property (nonatomic, strong) IBOutlet TestViewController *testView;

@end

