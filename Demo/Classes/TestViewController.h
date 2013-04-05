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

@interface TestViewController : UIViewController <V8HorizontalPickerViewDelegate, V8HorizontalPickerViewDataSource> { }

@property (nonatomic, strong) IBOutlet V8HorizontalPickerView *pickerView;
@property (nonatomic, strong) IBOutlet UIButton *nextButton;
@property (nonatomic, strong) IBOutlet UIButton *reloadButton;
@property (nonatomic, strong) IBOutlet UILabel *infoLabel;

@property (nonatomic, strong) NSMutableArray *titleArray;

@end
