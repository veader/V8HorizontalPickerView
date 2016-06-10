    //
//  TestViewController.m
//  fStats
//
//  Created by Shawn Veader on 9/18/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "TestViewController.h"


@implementation TestViewController

#pragma mark - iVars
int indexCount;

#pragma mark - Init/Dealloc
- (id)init {
	self = [super init];
	if (self) {
		self.titleArray = [NSMutableArray arrayWithObjects:@"All", @"Today", @"Thursday", @"Wednesday", @"Tuesday", @"Monday", nil];
		indexCount = 0;
	}
	return self;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View Management Methods
- (void)viewDidLoad {
	[super viewDidLoad];

	self.pickerView.selectedTextColor = [UIColor whiteColor];
	self.pickerView.textColor   = [UIColor grayColor];
//	self.pickerView.delegate    = self;
//	self.pickerView.dataSource  = self;
	self.pickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	self.pickerView.selectionPoint = CGPointMake(60, 0);

	// add carat or other view to indicate selected element
	UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
	self.pickerView.selectionIndicatorView = indicator;
//	pickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location

	// add gradient images to left and right of view if desired
//	UIImageView *leftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_fade"]];
//	pickerView.leftEdgeView = leftFade;
//
//	UIImageView *rightFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_fade"]];
//	pickerView.rightEdgeView = rightFade;

	// add image to left of scroll area
//	UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loopback"]];
//	pickerView.leftScrollEdgeView = leftImage;
//	pickerView.scrollEdgeViewPadding = 20.0f;
//
//	UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airplane"]];
//	pickerView.rightScrollEdgeView = rightImage;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[self.pickerView scrollToElement:0 animated:NO];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
//	(interfaceOrientation == UIInterfaceOrientationPortrait ||
//	 interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//	 interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//	CGFloat margin = 40.0f;
//	CGFloat width = (self.view.frame.size.width - (margin * 2.0f));
//	CGFloat height = 40.0f;
//	CGRect tmpFrame;
//	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//		toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//		tmpFrame = CGRectMake(margin, 50.0f, width + 100.0f, height);
//	} else {
//		tmpFrame = CGRectMake(margin, 150.0f, width, height);
//	}
//	pickerView.frame = tmpFrame;
//}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//	CGFloat margin = 40.0f;
//	CGFloat width = (self.view.bounds.size.width - (margin * 2.0f));
//	CGFloat x = margin;
//	CGFloat y = 0.0f;
//	CGFloat height = 40.0f;
//	CGFloat spacing = 25.0f;
//	CGRect tmpFrame;
//	if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
//		fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
//		y = 150.0f;
//		spacing = 25.0f;
//		tmpFrame = CGRectMake(x, y, width, height);
//	} else {
//		y = 50.0f;
//		spacing = 10.0f;
//		tmpFrame = CGRectMake(x, y, width, height);
//	}
//	self.pickerView.frame = tmpFrame;
//	
//	y = y + tmpFrame.size.height + spacing;
//	tmpFrame = self.nextButton.frame;
//	tmpFrame.origin.y = y;
//	self.nextButton.frame = tmpFrame;
//	
//	y = y + tmpFrame.size.height + spacing;
//	tmpFrame = self.reloadButton.frame;
//	tmpFrame.origin.y = y;
//	self.reloadButton.frame = tmpFrame;
//	
//	y = y + tmpFrame.size.height + spacing;
//	tmpFrame = self.infoLabel.frame;
//	tmpFrame.origin.y = y;
//	self.infoLabel.frame = tmpFrame;
//
//}

#pragma mark - Button Tap Handlers
- (IBAction)nextButtonTapped:(id)sender {
	[self.pickerView scrollToElement:indexCount animated:NO];
	indexCount += 1;
	if ([self.titleArray count] <= indexCount) {
		indexCount = 0;
	}
	[self.nextButton setTitle:[NSString stringWithFormat:@"Center Element %d", indexCount]
					 forState:UIControlStateNormal];
}

- (IBAction)reloadButtonTapped:(id)sender {
	// change our title array so we can see a change
	if ([self.titleArray count] > 1) {
		[self.titleArray removeLastObject];
	}

	[self.pickerView reloadData];
}

#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
	return [self.titleArray count];
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
	return [self.titleArray objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
	CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
	NSString *text = [self.titleArray objectAtIndex:index];
	CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
					   constrainedToSize:constrainedSize
						   lineBreakMode:NSLineBreakByWordWrapping];
	return textSize.width + 40.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
	self.infoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
}

@end
