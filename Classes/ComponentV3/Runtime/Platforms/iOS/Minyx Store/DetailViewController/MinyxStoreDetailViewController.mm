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
#import "CocosDenshion.h"
#import "CDAudioManager.h"
#import "SimpleAudioEngine.h"

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
	if (reinit_sfx)
	{
		CDAudioManager *am = [CDAudioManager sharedManager];
		[CDAudioManager configure: _lolmode];
		
		mx3::SoundSystem::resume_background_music();
		reinit_sfx = NO;
	}
	
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

	CDAudioManager *am = [CDAudioManager sharedManager];
	_lolmode = [am mode];
	reinit_sfx = NO;
	
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
	[self setCornersForView: webView];

	BOOL h = NO;
	
	large_yt_frame = [webView frame];
	small_yt_frame = large_yt_frame;
	small_yt_frame.size.width /= 4.0;
	small_yt_frame.size.height /= 4.0;
	small_yt_frame.origin.x = [[self view] bounds].size.width / 2 - small_yt_frame.size.width / 2;
	small_yt_frame.origin.y = [[self view] bounds].size.height / 2 - small_yt_frame.size.height / 2;
	
	[webView setFrame: small_yt_frame];
	
	
	if (!h && [[self dataSource] youtubeURLForProductID: [product productIdentifier]])
	{
		[showYTButton setHidden: NO];
		h = YES;
	}
	else
	{
		[showYTButton setHidden: YES];
	}
	
	if (!h && [[self dataSource] detailImageNameForProductID: [product productIdentifier]])
	{	
		[showDetialButton setHidden: NO];
		h = YES;
	}
	else
	{	
		[showDetialButton setHidden: YES];
	}
	

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

- (void) showYTVideo: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[youtubeView_closeButton setHidden: YES];
	[youtubeView_close2Button setHidden: YES];
	[youtubeView_activity stopAnimating];
	//[webView setHidden: YES];
	
	//[[UIApplication sharedApplication] openURL: [NSURL URLWithString: [dataSource youtubeURLForProductID: [product productIdentifier]]]];
	[[self view] addSubview: youtubeView];
	[webView setDelegate: self];
	
	
	[UIView animateWithDuration: 0.4
						  delay: 0.0
						options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseInOut
					 animations: ^(){
						 [webView setFrame: large_yt_frame]; 
					 }
					 completion: ^(BOOL finished){
						 //[youtubeView_closeButton setHidden: NO];
						 [youtubeView_close2Button setHidden: NO];
						 [youtubeView_activity startAnimating];

						 NSString* embedHTML = @"<html><head><meta name=\"viewport\" content=\"width=%i,user-scalable=no\" /><style type=\"text/css\">body { background-color: transparent; color: white; }</style></head><body style=\"margin:0\"><embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" width=\"%i\" height=\"%i\"></embed></body></html>";
						 
						 NSString* html = [NSString stringWithFormat: embedHTML,
										   (int)large_yt_frame.size.width, 
										   [[self dataSource] youtubeURLForProductID: [product productIdentifier]], 
										   (int)large_yt_frame.size.width, 
										   (int)large_yt_frame.size.height];  
						 
						 NSLog(@"html: %@", html);
						 
						 
						 [webView loadHTMLString: html baseURL:nil];  

						 
					 }
	 ];
	
}

- (IBAction) dismissYTVideo: (id) sender
{
	[webView setDelegate: nil];
	[webView loadHTMLString: @"" baseURL: nil];
	
	[youtubeView_closeButton setHidden: YES];
	[youtubeView_close2Button setHidden: YES];
	//[am init: _lolmode];
//	[am setMode: _lolmode];
//	[[SimpleAudioEngine sharedEngine] setEnabled: YES];
	
	//[SimpleAudioEngine end];
	//[SimpleAudioEngine sharedEngine];
	if (reinit_sfx)
	{
		CDAudioManager *am = [CDAudioManager sharedManager];
		[CDAudioManager configure: _lolmode];
		
		mx3::SoundSystem::resume_background_music();

		reinit_sfx = NO;
	}
	
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);

	
	[UIView animateWithDuration: 0.4
						  delay: 0.0
						options: UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseIn
					 animations: ^(){
						 [webView setFrame: small_yt_frame];
					 }
					 completion: ^(BOOL finished){
						 [youtubeView removeFromSuperview];	
					 }
	 ];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView 
{
	//NSLog(@"req url: %@", [[[webView request] URL] absoluteString]);

	
	[webView setHidden: NO];
	[youtubeView_activity stopAnimating];
	[youtubeView_closeButton setHidden: NO];
	
	reinit_sfx = YES;
	[[[CDAudioManager sharedManager] soundEngine] stopAllSounds];
	[[SimpleAudioEngine sharedEngine] setEnabled: NO];
	[SimpleAudioEngine end];
	[CDAudioManager end];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error 
{
	[webView setHidden: NO];
	[youtubeView_activity stopAnimating];
	[youtubeView_closeButton setHidden: NO];
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
