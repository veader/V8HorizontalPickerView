//
//  TestViewController.h
//  fStats
//
//  Created by Shawn Veader on 9/18/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "V8HorizontalPickerView.h"

@class V8HorizontalPickerView;

@interface TestViewController : UIViewController <V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource> {
	V8HorizontalPickerView *pickerView;
	NSMutableArray *titleArray;
	UIButton *nextButton;
	UIButton *reloadButton;
	UILabel *infoLabel;
	int indexCount;
}

@property (nonatomic, retain) V8HorizontalPickerView *pickerView;
@property (nonatomic, retain) UIButton *nextButton;
@property (nonatomic, retain) UIButton *reloadButton;
@property (nonatomic, retain) UILabel *infoLabel;

@end
