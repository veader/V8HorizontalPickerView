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

- (id)init {
	if ((self = [super init])) {
		titleArray = [[NSMutableArray arrayWithObjects:@"All", @"Today", @"Thursday",
							@"Wednesday", @"Tuesday", @"Monday", nil] retain];
        // titleArray = [[NSMutableArray array] retain]; // for testing
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
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.view.backgroundColor = [UIColor blackColor];
	CGFloat width = 200.0f;
	CGFloat x = (self.view.frame.size.width - width) / 2.0f;
	CGRect tmpFrame = CGRectMake(x, 150.0f, width, 40.0f);
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
//	pickerView.scrollEdgeViewOutsidePadding = 10.0f;
//
//	UIImageView *rightImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"airplane"]];
//	pickerView.rightScrollEdgeView = rightImage;
//	[rightImage release];

	[self.view addSubview:pickerView];
	
	self.nextButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	tmpFrame = CGRectMake(x, 225.0f, width, 50.0f);
	nextButton.frame = tmpFrame;
	[nextButton addTarget:self
				   action:@selector(nextButtonClicked:)
		 forControlEvents:UIControlEventTouchUpInside];
	[nextButton	setTitle:@"Center Element 0" forState:UIControlStateNormal];
	nextButton.titleLabel.textColor = [UIColor blackColor];
	[self.view addSubview:nextButton];
	
	self.reloadButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	tmpFrame = CGRectMake(x, 300, width, 50.0f);
	reloadButton.frame = tmpFrame;
	[reloadButton addTarget:self
					 action:@selector(reloadButtonClicked:)
		   forControlEvents:UIControlEventTouchUpInside];
	[reloadButton setTitle:@"Reload Data" forState:UIControlStateNormal];
	[self.view addSubview:reloadButton];
	
	tmpFrame = CGRectMake(x, 375, width, 50.0f);
	infoLabel = [[UILabel alloc] initWithFrame:tmpFrame];
	infoLabel.backgroundColor = [UIColor blackColor];
	infoLabel.textColor = [UIColor whiteColor];
	infoLabel.textAlignment = UITextAlignmentCenter;
	[self.view addSubview:infoLabel];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	[pickerView scrollToElement:0 animated:NO];
}

- (void)nextButtonClicked:(id)sender {
	[pickerView scrollToElement:indexCount animated:NO];
	indexCount += 1;
	if ([titleArray count] <= indexCount) {
		indexCount = 0;
	}
	[nextButton	setTitle:[NSString stringWithFormat:@"Center Element %d", indexCount]
				forState:UIControlStateNormal];
}

- (void)reloadButtonClicked:(id)sender {
	// change our title array so we can see a change
	if ([titleArray count] > 1) {
		[titleArray removeLastObject];
	}

	[pickerView reloadData];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
	self.pickerView = nil;
	self.nextButton = nil;
	self.infoLabel  = nil;
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
