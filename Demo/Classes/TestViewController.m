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
@synthesize secondPickerView, secondInfoLabel;

#pragma mark - iVars
NSMutableArray *titleArray;
NSMutableArray *numberArray;
int indexCount;

#pragma mark - Init/Dealloc
- (id)init {
	self = [super init];
	if (self) {
		titleArray = [[NSMutableArray arrayWithObjects:@"All", @"Today", @"Thursday", @"Wednesday", @"Tuesday", @"Monday", nil] retain];
		numberArray = [[NSMutableArray arrayWithObjects:@"One", @"Two", @"Three", @"Four", @"Five", @"Six", @"Seven", @"Eight", @"Nine", @"Ten", nil] retain];
		indexCount = 0;
	}
	return self;
}

- (void)dealloc {
	[pickerView   release];
	[titleArray   release];
	[nextButton   release];
	[reloadButton release];
	[infoLabel    release];
	[secondPickerView release];
	[secondInfoLabel  release];
	[numberArray      release];
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

	self.view.backgroundColor = [UIColor blackColor];
	CGFloat margin = 40.0f;
	CGFloat width = (self.view.bounds.size.width - (margin * 2.0f));
	CGFloat pickerHeight = 40.0f;
	CGFloat x = margin;
	CGFloat y = 50.0f;
	CGFloat spacing = 25.0f;
	CGRect tmpFrame = CGRectMake(x, y, width, pickerHeight);

//	CGFloat width = 200.0f;
//	CGFloat x = (self.view.frame.size.width - width) / 2.0f;
//	CGRect tmpFrame = CGRectMake(x, 150.0f, width, 40.0f);

	pickerView = [[V8HorizontalPickerView alloc] initWithFrame:tmpFrame];
	pickerView.backgroundColor   = [UIColor darkGrayColor];
	pickerView.selectedTextColor = [UIColor whiteColor];
	pickerView.textColor   = [UIColor grayColor];
	pickerView.delegate    = self;
	pickerView.dataSource  = self;
	pickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];
	pickerView.selectionPoint = CGPointMake(60, 0);

	// add carat or other view to indicate selected element
	UIImageView *indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
	pickerView.selectionIndicatorView = indicator;
//	pickerView.indicatorPosition = V8HorizontalPickerIndicatorTop; // specify indicator's location
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

	[self.view addSubview:pickerView];

	// second picker view -----------
	y += pickerHeight + spacing;
	tmpFrame = CGRectMake(x, y, width, pickerHeight);
	secondPickerView = [[V8HorizontalPickerView alloc] initWithFrame:tmpFrame];
	secondPickerView.backgroundColor   = [UIColor darkGrayColor];
	secondPickerView.selectedTextColor = [UIColor whiteColor];
	secondPickerView.textColor   = [UIColor grayColor];
	secondPickerView.delegate    = self;
	secondPickerView.dataSource  = self;
	secondPickerView.elementFont = [UIFont boldSystemFontOfSize:14.0f];

	// add carat or other view to indicate selected element
	indicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"indicator"]];
	secondPickerView.selectionIndicatorView = indicator;
	[indicator release];

	[self.view addSubview:secondPickerView];

	self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	y += pickerHeight + spacing;
	tmpFrame = CGRectMake(x, y, width, 50.0f);
	nextButton.frame = tmpFrame;
	[nextButton addTarget:self action:@selector(nextButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[nextButton	setTitle:@"Center Element 0" forState:UIControlStateNormal];
	nextButton.titleLabel.textColor = [UIColor blackColor];
	[self.view addSubview:nextButton];

	self.reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	y += tmpFrame.size.height + spacing;
	tmpFrame = CGRectMake(x, y, width, 50.0f);
	reloadButton.frame = tmpFrame;
	[reloadButton addTarget:self action:@selector(reloadButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
	[reloadButton setTitle:@"Reload Data" forState:UIControlStateNormal];
	[self.view addSubview:reloadButton];

	y += tmpFrame.size.height + spacing;
	tmpFrame = CGRectMake(x, y, width, 50.0f);
	infoLabel = [[UILabel alloc] initWithFrame:tmpFrame];
	infoLabel.backgroundColor = [UIColor blackColor];
	infoLabel.textColor = [UIColor whiteColor];
	infoLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:infoLabel];

	y += tmpFrame.size.height + spacing;
	tmpFrame = CGRectMake(x, y, width, 50.0f);
	secondInfoLabel = [[UILabel alloc] initWithFrame:tmpFrame];
	secondInfoLabel.backgroundColor = [UIColor blackColor];
	secondInfoLabel.textColor = [UIColor whiteColor];
	secondInfoLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:secondInfoLabel];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	self.pickerView = nil;
	self.nextButton = nil;
	self.infoLabel  = nil;
	self.secondPickerView = nil;
	self.secondInfoLabel  = nil;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[pickerView scrollToElement:0 animated:NO];
	[secondPickerView scrollToElement:0 animated:NO];
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

#warning TODO: make this work with second picker and label...
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
	if (picker == self.secondPickerView) {
		return [numberArray count];
	} else {
		return [titleArray count];
	}
}

#pragma mark - HorizontalPickerView Delegate Methods
- (NSString *)horizontalPickerView:(V8HorizontalPickerView *)picker titleForElementAtIndex:(NSInteger)index {
	if (picker == self.secondPickerView) {
		return [numberArray objectAtIndex:index];
	} else {
		return [titleArray objectAtIndex:index];
	}
}

- (NSInteger) horizontalPickerView:(V8HorizontalPickerView *)picker widthForElementAtIndex:(NSInteger)index {
	CGSize constrainedSize = CGSizeMake(MAXFLOAT, MAXFLOAT);
	NSString *text;
	if (picker == self.secondPickerView) {
		text = [numberArray objectAtIndex:index];
	} else {
		text = [titleArray objectAtIndex:index];
	}
	CGSize textSize = [text sizeWithFont:[UIFont boldSystemFontOfSize:14.0f]
					   constrainedToSize:constrainedSize
						   lineBreakMode:UILineBreakModeWordWrap];
	return textSize.width + 40.0f; // 20px padding on each side
}

- (void)horizontalPickerView:(V8HorizontalPickerView *)picker didSelectElementAtIndex:(NSInteger)index {
	if (picker == self.secondPickerView) {
		self.secondInfoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
	} else {
		self.infoLabel.text = [NSString stringWithFormat:@"Selected index %d", index];
	}
}

@end
