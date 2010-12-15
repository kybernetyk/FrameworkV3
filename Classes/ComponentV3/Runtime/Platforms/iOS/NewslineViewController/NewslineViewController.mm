//
//  NewslineViewController.m
//  Fruitmunch
//
//  Created by jrk on 10/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "NewslineViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "NSString+Search.h"
#import "SBJSON.h"
#import "PromotionViewController.h"
#include "NotificationSystem.h"

@implementation NewslineViewController
@synthesize newsItems;
@synthesize link;


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
	
	
	
//	UIColor *col = [UIColor colorWithRed: (159.0/255.0) green: (144.0/255.0) blue: (135.0/255.0) alpha:1.0];
//	
//	[[aView layer] setBorderColor: [col CGColor]];
//	[[aView layer] setBorderWidth: 1.0];
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[self setBorderAndCornersForView: [self view]];
	visibleFrame = [[self view] frame];
	
	hiddenFrame = visibleFrame;
	
	hiddenFrame.origin.y += hiddenFrame.size.height;
	
	[[self view] setFrame: hiddenFrame];
	
	[moreButton setHidden: YES];
	[[self view] setFrame: hiddenFrame];

	
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc addObserver: self 
		   selector: @selector(restart:) 
			   name: UIApplicationDidBecomeActiveNotification 
			 object: nil];
	


}

- (void) restart: (NSNotification *) notification
{
	NSLog(@"RESTURD!");
	[self start];
}

- (void) animateIn 
{
	[UIView beginAnimations: @"alalalal" context: NULL];
	[UIView setAnimationDuration: 1.0];
	[[self view] setFrame: visibleFrame];
	[UIView commitAnimations];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[[NSNotificationCenter defaultCenter] removeObserver: self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[self setNewsItems: nil];
	[receivedData release];
	receivedData = nil;
	
    [super dealloc];
}

- (void) start
{
		
	
	
//	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
//	NSInteger n = [defs integerForKey: @"num_of_news_shown"];
//	n ++;
//	[defs setInteger: n forKey: @"num_of_news_shown"];
//	[defs synchronize];
//	if (n < 4)
//		return;
	
	NSString *bundle_id = [[NSBundle mainBundle] bundleIdentifier];
	NSString *urlstring = [NSString stringWithFormat: @"http://www.minyxgames.com/app_news.py/news?appid=%@",bundle_id];
	NSURL *url = [NSURL URLWithString: urlstring];
	
	NSURLRequest *req = [NSURLRequest requestWithURL: url];
	
	NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: req 
																  delegate: self];
	
	if (!connection)
	{	
		[connection release];
		connection = nil;
		
		if ([[self newsItems] count] > 0)
		{
			srand(time(0));
			int r = rand()%[[self newsItems] count];
			
			
			NSString *news = [[self newsItems] objectAtIndex: r];
			[textLabel setText: news];
			
			[self animateIn];
		}
		
	}
	else
	{
		receivedData = [[NSMutableData data] retain];
	}
	
}

#pragma mark -
#pragma mark connection
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
	
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
	
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
	NSLog(@"received response!");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
	[receivedData appendData:data];
	
	NSLog(@"received data");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // release the connection, and the data object
    [connection release];
    // receivedData is declared as a method instance elsewhere
    [receivedData release];
	receivedData = nil;
	
	if ([[self newsItems] count] > 0)
	{
		srand(time(0));
		int r = rand()%[[self newsItems] count];
		
		
		NSString *news = [[self newsItems] objectAtIndex: r];
		[textLabel setText: news];
		
		[self animateIn];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	NSString *str = [[[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding] autorelease];
	
	SBJSON *json = [[[SBJSON alloc] init] autorelease];

	NSArray *news_feed = [json objectWithString: str];
	if ([news_feed count] <= 0)
	{
		[connection release];
		[receivedData release];
		receivedData = nil;
		if ([[self newsItems] count] > 0)
		{
			srand(time(0));
			int r = rand()%[[self newsItems] count];
			
			
			NSString *news = [[self newsItems] objectAtIndex: r];
			[textLabel setText: news];
			
			[self animateIn];
		}
		
		return;
	}
	
	//only get first
	NSDictionary *news_item = [news_feed objectAtIndex: 0];

	NSString *text = [news_item objectForKey: @"text"];
	NSString *link = [news_item objectForKey: @"link"];
	
	[textLabel setText: text];
	
	if (link)
	{
		[self setLink: link];
		[moreButton setHidden: NO];
	}

	[self animateIn];
	
    // release the connection, and the data object
    [connection release];
    [receivedData release];
	receivedData = nil;
}


- (IBAction) visitLink: (id) sender
{
	if (![self link])
		return;

	NSLog(@"visiting: %@",[self link]);
	
	if ([[self link] containsString: @"itunes"])
	{
		NSURL *url = [NSURL URLWithString: [self link]];
		[[UIApplication sharedApplication] openURL: url];
	}
	else
	{
		post_notification(kShowWebkitView, [self link]);
	}
	
	
}
@end
