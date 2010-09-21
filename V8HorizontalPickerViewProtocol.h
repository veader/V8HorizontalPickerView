//
//  V8HorizontalPickerViewProtocol.h
//
//  Created by Shawn Veader on 9/17/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

@class V8HorizontalPickerView;

// ------------------------------------------------------------------
// HorizontalPickerView DataSource Protocol
@protocol V8HorizontalPickerViewDataSource <NSObject>
@required
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker;
@end


// ------------------------------------------------------------------
// HorizontalPickerView Delegate Protocol
@protocol V8HorizontalPickerViewDelegate <NSObject>

@optional
- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index;

// one of these two methods must be defined
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index;
- (UIView *)  horizontalPickerView:(V8HorizontalPickerView *)picker viewForElementAtIndex:(NSInteger)index;

@required
- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index;

@end