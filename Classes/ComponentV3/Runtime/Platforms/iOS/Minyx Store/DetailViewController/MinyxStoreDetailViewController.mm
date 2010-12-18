//
//  DetailViewController.m
//  Fruitmunch
//
//  Created by jrk on 7/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MinyxStoreDetailViewController.h"
#import "MKStoreManager.h"
#import "NotificationSystem.h"
#import <QuartzCore/QuartzCore.h>
#import "SoundSystem.h"

@implementation MinyxStoreDetailViewController
@synthesize dataSource;
@synthesize product;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/
- (void) setBorderAndCornersForView: (UIView *) aView
{
	[[aView layer] setCornerRadius: 8.0];
	[[aView layer] setMasksToBounds: YES];
	
	//0x9f9087
	
	
	
	UIColor *col = [UIColor colorWithRed: (159.0/255.0) green: (144.0/255.0) blue: (135.0/255.0) alpha:1.0];
	
	[[aView layer] setBorderColor: [col CGColor]];
	[[aView layer] setBorderWidth: 1.0];
	
}

- (void) setCornersForView: (UIView *) aView
{
	[[aView layer] setCornerRadius: 8.0];
	[[aView layer] setMasksToBounds: YES];
	
}


extern BOOL g_MayReleaseMemory;
- (void) dismissStore: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[MKStoreManager setDelegate: nil];
	[[self parentViewController] dismissModalViewControllerAnimated: YES];
	g_MayReleaseMemory = YES;
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kHideInAppStore object: self];
	//post_notification (kHideInAppStore, self);
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	
	[self setBorderAndCornersForView: imageView];
	//[self setBorderAndCornersForView: detailText];
	//[self setBorderAndCornersForView: buyButton];
	
//	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
//																		  target: self
//																		  action: @selector(dismissStore:)];

	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle: @"Done"
															 style: UIBarButtonItemStyleBordered 
															target: self 
															action: @selector(dismissStore:)];
	
	
	[[self navigationItem] setRightBarButtonItem: done];
	[done autorelease];

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];	
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *formattedPrice = [NSString stringWithString: [numberFormatter stringFromNumber:product.price]];
	[numberFormatter release];
	
	if ([MKStoreManager isFeaturePurchased: [product productIdentifier]])
		formattedPrice = @"[You own this]";

	[priceLabel setText: formattedPrice];
	
	NSString *desc = [product localizedDescription];
	[detailText setText: desc];
	
	[titleLabel setText: [product localizedTitle]];
	[self setTitle: [product localizedTitle]];
	
	[imageView setImage: 
	 [UIImage imageNamed: 
	  [dataSource imageNameForProductID: 
	   [product productIdentifier]
	   ]  
	  ]
	 ];
	
	
	large_detail_frame = [detailImageView_imageView frame];
	small_detail_frame = large_detail_frame;
	small_detail_frame.size.width /= 4.0;
	small_detail_frame.size.height /= 4.0;
	small_detail_frame.origin.x = [[self view] bounds].size.width / 2 - small_detail_frame.size.width / 2;
	small_detail_frame.origin.y = [[self view] bounds].size.height / 2 - small_detail_frame.size.height / 2;
	
	[detailImageView_imageView setFrame: small_detail_frame];
	
	[self setCornersForView: detailImageView_captionLabel];
	
	if ([[self dataSource] detailImageNameForProductID: [product productIdentifier]])
		[showDetialButton setHidden: NO];
	else
		[showDetialButton setHidden: YES];
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	[MKStoreManager setDelegate: nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[MKStoreManager setDelegate: nil];
	[self setProduct: nil];
	[self setDataSource: nil];
    [super dealloc];
}

#pragma mark -
#pragma mark actions
- (void) buyTheShit: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[activity startAnimating];
	NSString *feature = [product productIdentifier];
	[MKStoreManager setDelegate: self];
	[[MKStoreManager sharedManager] buyFeature: feature];
	
}

- (void) showDetailImage: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	NSString *imgName = [[self dataSource] detailImageNameForProductID: [product productIdentifier]];
	NSString *caption = [[self dataSource] detailImageCaptionForProductID: [product productIdentifier]];
	
	if (caption)
		[detailImageView_captionLabel setText: caption];
	
	[detailImageView_captionLabel setHidden: YES];
	
	[detailImageView_imageView setImage: [UIImage imageNamed: imgName]];
	[detailImageView_imageView setFrame: small_detail_frame];
	[detailImageView_closeButton setHidden: YES];
	[[self view] addSubview: detailImageView];
	

	
	//[UIView beginAnimations: @"zoooomin" context: NULL];
	//[UIView setAnimationDuration: 1.0];
	//[UIView setAnimationDidStopSelector: @selector(detailShowDone:)];
	
//	+ (void)animateWithDuration:(NSTimeInterval)duration delay:(NSTimeInterval)delay options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion;

	[UIView animateWithDuration: 0.4
						  delay: 0.0
						options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseInOut
					 animations: ^(){
						[detailImageView_imageView setFrame: large_detail_frame]; 
					 }
					 completion: ^(BOOL finished){
						 [detailImageView_closeButton setHidden: NO];
						 if (caption)
							 [detailImageView_captionLabel setHidden: NO];
					 }
	 ];
	
	
}


- (IBAction) dismissDetailImage: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	
	[detailImageView_closeButton setHidden: YES];
	[detailImageView_captionLabel setHidden: YES];
	[UIView animateWithDuration: 0.4
						  delay: 0.0
						options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseIn
					 animations: ^(){
						 [detailImageView_imageView setFrame: small_detail_frame];
					 }
					 completion: ^(BOOL finished){
						 [detailImageView removeFromSuperview];	
					 }
	 ];
	
	
}


#pragma mark -
#pragma mark MKStoreManager

- (void)productPurchased:(NSString *)productId
{
	[MKStoreManager setDelegate: nil];
	[activity stopAnimating];
	
	[priceLabel setText: @"[You own this]"];
}

- (void)transactionCanceled
{
	[MKStoreManager setDelegate: nil];
	[activity stopAnimating];
}



@end
