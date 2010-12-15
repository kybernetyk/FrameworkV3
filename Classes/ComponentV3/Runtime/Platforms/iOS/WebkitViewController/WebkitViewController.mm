//
//  PromotionViewController.m
//  PromotionTest
//
//  Created by Brandon Trebitowski on 11/25/10.
//  Copyright 2010 brandontreb.com. All rights reserved.
//

#import "WebkitViewController.h"
#import "SoundSystem.h"
#import "NSString+Search.h"
#import "NotificationSystem.h"

@implementation WebkitViewController

@synthesize webView;
@synthesize spinner;
@synthesize promotionAddress;
extern BOOL g_MayReleaseMemory;

- (void) viewWillAppear:(BOOL)animated {	
	
	// Create a URL from the address
	NSURL *url = [NSURL URLWithString:promotionAddress];
	
	// Creates the URL request to load in the webview
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
//	[self.webView setHidden: YES];
	// Load the request in our webview
	[self.webView loadRequest:request];
	
	NSLog(@"will appear");
	
}

#pragma mark -
#pragma mark webView delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType 
{
	NSLog(@"scheme: %@", [[request URL] scheme]);
	NSLog(@"host: %@", [[request URL] host]);
	
	if ([[[request URL] scheme] isEqualToString: @"minyxstore"])
	{
		g_MayReleaseMemory = YES;
		NSLog(@"posting notification!");
		//[self doneButtonTouched: self];
		
			
		post_notification(kShowInAppStore, [[request URL] host]);
			
		return NO;
	}
	
	//if ([[[request URL] scheme] isEqualToString: @"itms"])
	if (navigationType == UIWebViewNavigationTypeLinkClicked)
	{
		[[UIApplication sharedApplication] openURL: [request URL]];
		return NO;
	}
	
	
	[spinner startAnimating];
	return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.webView setHidden: NO];
	[spinner stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" 
//													message:@"Unable to load, please try again later." 
//												   delegate:nil 
//										  cancelButtonTitle:@"OK" 
//										  otherButtonTitles:nil];
//	[alert show];
//	[alert release];
//	[self.parentViewController dismissModalViewControllerAnimated:YES];

}



- (IBAction) doneButtonTouched:(id) sender 
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	g_MayReleaseMemory = YES;
	[self.parentViewController dismissModalViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
#ifdef ORIENTATION_LANDSCAPE
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
#endif
	
#ifdef ORIENTATION_PORTRAIT
	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
#endif
	
	return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	[self.webView setHidden: YES];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    self.spinner = nil;
	self.webView = nil;
}


- (void)dealloc 
{
	[self setWebView: nil];
	[self setSpinner: nil];
	[self setPromotionAddress: nil];
    [super dealloc];
}


@end
