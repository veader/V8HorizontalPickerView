    //
//  TestViewController.m
//  fStats
//
//  Created by Shawn Veader on 9/18/10.
//  Copyright 2010 V8 Labs, LLC. All rights reserved.
//

#import "TestViewController.h"


@implementation TestViewController

@synthesize pickerView;
@synthesize nextButton, reloadButton;
@synthesize infoLabel;

#pragma mark - iVars
NSMutableArray *titleArray;
int indexCount;

#pragma mark - Init/Dealloc
- (id)init {
	self = [super init];
	if (self) {
	}
	return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	self = [super initWithCoder:aDecoder];
	if (self) {
		//
	}
	return self;
}

- (void)dealloc {
	[pickerView   release];
	[titleArray   release];
	[nextButton   release];
	[reloadButton release];
	[infoLabel    release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}

#pragma mark - View Management Methods
- (void)viewDidLoad {
	[super viewDidLoad];

	titleArray = [[NSMutableArray arrayWithObjects:@"All", @"Today", @"Thursday", @"Wednesday", @"Tuesday", @"Monday", nil] retain];
	indexCount = 0;

	self.pickerView.backgroundColor   = [UIColor darkGrayColor];
	self.pickerView.selectedTextColor = [UIColor whiteColor];
	self.pickerView.textColor   = [UIColor grayColor];
	self.pickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	self.pickerView.selectionPoint = CGPointMake(60, 0);

	// add carat or other view to indicate selected element
	UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
	self.pickerView.selectionIndicatorView = indicator;
//	self.pickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location
	[indicator release];

	// add gradient images to left and right of view if desired
//	UIImageView *leftFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left_fade"]];
//	pickerView.leftEdgeView = leftFade;
//	[leftFade release];
//
//	UIImageView *rightFade = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right_fade"]];
//	pickerView.rightEdgeView = rightFade;
//	[rightFade release];

	// add image to left of scroll area
//	UIImageView *leftImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loopback"]];
//	pickerView.leftScrollEdgeView = leftImage;
//	[leftImage release];
//	pickerView.scrollEdgeViewPadding = 20.0f;
//
//	UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airplane"]];
//	pickerView.rightScrollEdgeView = rightImage;
//	[rightImage release];

}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
//	self.pickerView = nil;
//	self.nextButton = nil;
//	self.infoLabel  = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[pickerView scrollToElement:0 animated:NO];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	CGFloat margin = 40.0f;
	CGFloat width = (self.view.bounds.size.width - (margin * 2.0f));
	CGFloat x = margin;
	CGFloat y = 0.0f;
	CGFloat height = 40.0f;
	CGFloat spacing = 25.0f;
	CGRect tmpFrame;
	if (fromInterfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
		fromInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		y = 150.0f;
		spacing = 25.0f;
		tmpFrame = CGRectMake(x, y, width, height);
	} else {
		y = 50.0f;
		spacing = 10.0f;
		tmpFrame = CGRectMake(x, y, width, height);
	}
	pickerView.frame = tmpFrame;
	
	y = y + tmpFrame.size.height + spacing;
	tmpFrame = nextButton.frame;
	tmpFrame.origin.y = y;
	nextButton.frame = tmpFrame;
	
	y = y + tmpFrame.size.height + spacing;
	tmpFrame = reloadButton.frame;
	tmpFrame.origin.y = y;
	reloadButton.frame = tmpFrame;
	
	y = y + tmpFrame.size.height + spacing;
	tmpFrame = infoLabel.frame;
	tmpFrame.origin.y = y;
	infoLabel.frame = tmpFrame;

}

#pragma mark - Button Tap Handlers
- (void)nextButtonTapped:(id)sender {
	[pickerView scrollToElement:indexCount animated:NO];
	indexCount += 1;
	if ([titleArray count] <= indexCount) {
		indexCount = 0;
	}
	[nextButton	setTitle:[NSString stringWithFormat:@"Center Element %d", indexCount]
				forState:UIControlStateNormal];
}

- (void)reloadButtonTapped:(id)sender {
	// change our title array so we can see a change
	if ([titleArray count] > 1) {
		[titleArray removeLastObject];
	}

	[pickerView reloadData];
}

#pragma mark - HorizontalPickerView DataSource Methods
- (NSInteger)numberOfElementsInHorizontalPickerView:(V8HorizontalPickerView *)picker {
	return [titleArray count];
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
	return [titleArray objectAtIndex:index];
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
	CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
	NSString *text = [titleArray objectAtIndex:index];
	CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
					   constrainedToSize:constrainedSize
						   lineBreakMode:UILineBreakModeWordWrap];
	return textSize.width + 40.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
	self.infoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
}

@end
