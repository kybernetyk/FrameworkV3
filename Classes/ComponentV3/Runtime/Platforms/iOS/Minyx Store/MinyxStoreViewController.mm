//
//  MinyxStoreViewController.m
//  Fruitmunch
//
//  Created by jrk on 6/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MinyxStoreViewController.h"
#import "MKStoreManager.h"
#import "MinyxStoreDetailViewController.h"
#import "NotificationSystem.h"
#import "MXAlertPrompt.h"
#import "NSString+Search.h"
#import "SBJSON.h"
#import "SoundSystem.h"

@implementation MinyxStoreViewController
@synthesize activity;
@synthesize tableView;
@synthesize products;
@synthesize productInformationDataSource;
@synthesize productIdToShow;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
//	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
//																		  target: self
//																		  action: @selector(dismissStore:)];

	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle: @"Done"
															 style: UIBarButtonItemStyleBordered 
															target: self 
															action: @selector(dismissStore:)];
	
	
	[[self navigationItem] setRightBarButtonItem: done];
	[done autorelease];

	
	[self setProducts: [[MKStoreManager sharedManager] purchasableObjects]];
	
	if ([self productIdToShow])
	{
		for (SKProduct *product in [self products])
		{
			if ([[product productIdentifier] isEqualToString: [self productIdToShow]])
			{
				[self showDetailViewForProduct: product animated: NO];
				return;
			}
		}
	}

//	if ([[self products] count] == 1)
//	{
//		SKProduct *product = [[self products] objectAtIndex: 0];
//		
//		[self showDetailViewForProduct: product animated: NO];
//	}
}

- (void) viewWillAppear:(BOOL)animated
{
	[self setProducts: [[MKStoreManager sharedManager] purchasableObjects]];
	[tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
	[MKStoreManager setDelegate: nil];
	[activity stopAnimating];
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

- (void)viewDidUnload 
{
    [super viewDidUnload];
	[MKStoreManager setDelegate: nil];
	[self setActivity: nil];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc 
{
	[self setProductInformationDataSource: nil];
	[MKStoreManager setDelegate: nil];
	[self setActivity: nil];
	[self setProducts: nil];
    [super dealloc];
}


#pragma mark -
#pragma mark actions 
extern BOOL g_MayReleaseMemory;
- (IBAction) dismissStore: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[MKStoreManager setDelegate: nil];
	//[delegate minyxStoreDismissed: self];

	[[self parentViewController] dismissModalViewControllerAnimated: YES];
	
	g_MayReleaseMemory = YES;
	
	//post_notification (kHideInAppStore, self);
	
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kHideInAppStore object: self];
}

- (void) restorePurchases: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[MKStoreManager setDelegate: self];
	[activity startAnimating];
	[[MKStoreManager sharedManager] restorePreviousTransactions];
}

#pragma mark -
#pragma mark promo code stuff
- (IBAction) enterPromoCode: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[activity startAnimating];
	MXAlertPrompt *prompt = [MXAlertPrompt alloc];
	prompt = [prompt initWithTitle:@"Enter Promo Code" message:@"Enter the promo code you received:" delegate:self cancelButtonTitle:@"Cancel" okButtonTitle:@"Ok."];
	[prompt show];
	[prompt release];
	
}


- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	if (buttonIndex != [alertView cancelButtonIndex])
	{
		NSString *entered = [(MXAlertPrompt *)alertView enteredText];
		//label.text = [NSString stringWithFormat:@"You typed: %@", entered];
		//NSLog(@"text entered: %@", entered);
		
		NSString *device_id = [[UIDevice currentDevice] uniqueIdentifier]; 
		NSString *bundle_id = [[NSBundle mainBundle] bundleIdentifier];
		NSString *urlstring = [NSString stringWithFormat: @"http://www.minyxgames.com/promo.py/unlock?appid=%@&code=%@&deviceid=%@",bundle_id,entered,device_id];
		NSURL *url = [NSURL URLWithString: urlstring];

		NSURLRequest *req = [NSURLRequest requestWithURL: url];

		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest: req 
																	delegate: self];
		
		if (!connection)
		{	
			[connection release];
			connection = nil;

			[activity stopAnimating];
			UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Connection To Server Failed"
														 message: @"Couldn't connect to promo server. Re-try later." 
														delegate: nil 
											   cancelButtonTitle: @"Ok."
											   otherButtonTitles: nil];
			[av show];
			[av release];
		}
		else
		{
			receivedData = [[NSMutableData data] retain];
		}
	}
	else
	{
		[activity stopAnimating];
	}
}

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
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
	
	NSString *msg = [NSString stringWithFormat: @"%@",  [error localizedDescription]];
	
	[activity stopAnimating];
	UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Connection To Promo Server Failed"
												 message: msg
												delegate: nil 
									   cancelButtonTitle: @"Ok."
									   otherButtonTitles: nil];
	[av show];
	[av release];
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	[activity stopAnimating];
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    //NSLog(@"Succeeded! Received %d bytes of data",[receivedData length]);
	
	NSString *str = [[[NSString alloc] initWithData: receivedData encoding: NSUTF8StringEncoding] autorelease];
	
	NSLog(@"string: %@",str);
	//str = [str lowercaseString];
	
	SBJSON *json = [[[SBJSON alloc] init] autorelease];
	
	NSArray *response_elements = [json objectWithString: str];
	NSLog(@"codes: %@", response_elements);
	
	if ([response_elements count] <= 0)
	{
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Invalid Promo Code"
													 message: @"The code you entered is invalid."
													delegate: nil 
										   cancelButtonTitle: @"Ok."
										   otherButtonTitles: nil];
		[av show];
		[av release];
		
		
		[connection release];
		[receivedData release];
		receivedData = nil;
		
		return;
	}
	
	NSMutableArray *features_to_unlock = [NSMutableArray arrayWithCapacity: 4];
	
	for (NSDictionary *element in response_elements)
	{
		NSString *response_kind = [element objectForKey: @"response"];
		if (!response_kind)
			continue;
		
		if ([response_kind containsString: @"error" ignoringCase: YES])
		{
			
			NSString *msg = [element objectForKey: @"message"];
			if (!msg)
				msg = @"The code you entered is invalid.";
			
			UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Invalid Promo Code"
														 message: msg
														delegate: nil 
											   cancelButtonTitle: @"Ok."
											   otherButtonTitles: nil];
			[av show];
			[av release];
			
			
			[connection release];
			[receivedData release];
			receivedData = nil;
			
			return;
		}
		
		if ([response_kind containsString: @"unlock" ignoringCase: YES])
		{
			NSString *unlock_code = [element objectForKey: @"unlock"];
			if (!unlock_code)
				continue;
			
			[features_to_unlock addObject: unlock_code];
		}
		
		if ([response_kind containsString: @"message" ignoringCase: YES])
		{
			NSString *msg_title = [element objectForKey: @"title"];
			if (!msg_title)
				continue;
			
			NSString *msg = [element objectForKey: @"message"];
			if (!msg)
				continue;
			
			UIAlertView *av = [[UIAlertView alloc] initWithTitle: msg_title
														 message: msg
														delegate: nil 
											   cancelButtonTitle: @"Ok."
											   otherButtonTitles: nil];
			[av show];
			[av release];
		}			
		
	}
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSMutableArray *feature_names = [NSMutableArray arrayWithCapacity: 4];
	int c = 0;
	int unlock_count = 0;
	for (NSString *feature in features_to_unlock)
	{
		c++;
		
		feature = [feature stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSLog(@"object %i: %@",c, feature);
		
		for (SKProduct *prod in [self products])
		{
			if ([[prod productIdentifier] containsString: feature ignoringCase: YES])
			{
				[feature_names addObject: [prod localizedTitle]];
				[defs setBool: YES forKey: [prod productIdentifier]];
				unlock_count ++;
			}
		}
	}
	[defs synchronize];

	if ([feature_names count] > 0)
	{
		NSMutableString *msg = [NSMutableString stringWithString: @"You unlocked: "];
		c = 0;
		for (NSString *feature in feature_names)
		{
			c++;
			[msg appendFormat: @"\"%@\"", feature];
			if (c < [feature_names count])
				[msg appendString: @", "];
		}
		
		UIAlertView *av = [[UIAlertView alloc] initWithTitle: @"Unlock successful"
													 message: msg
													delegate: nil 
										   cancelButtonTitle: @"Ok."
										   otherButtonTitles: nil];
		[av show];
		[av release];
		[tableView reloadData];
	}

    
	[connection release];
    [receivedData release];
}

#pragma mark -
#pragma mark table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	return [[self products] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	return @"   ";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    static NSString *CellIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	//	NSTimeInterval start = [[NSDate date] timeIntervalSince1970];
	if (!cell) 
	{
		cell = [[[UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle 
									  reuseIdentifier: CellIdentifier] autorelease];
		
		/*UISwitch *mySwitch = [[[UISwitch alloc] initWithFrame:CGRectZero] autorelease];
		[cell addSubview: mySwitch];
		[cell setAccessoryView: mySwitch];*/
		[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
	}

	
	SKProduct *product = [[self products] objectAtIndex: [indexPath row]];

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *formattedPrice = [NSString stringWithString: [numberFormatter stringFromNumber:product.price]];
	[numberFormatter release];
	
	if ([MKStoreManager isFeaturePurchased: [product productIdentifier]])
		formattedPrice = @"[You own this]";
	
	NSString *cell_title = [NSString stringWithFormat: @"%@ - %@", [product localizedTitle], formattedPrice];
	NSString *cell_detail = [product localizedDescription];
	
	
	[[cell textLabel] setText: cell_title];
	[[cell detailTextLabel] setText: cell_detail];
	
	return cell;
}	


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	//[activity startAnimating];

/*	SKProduct *product = [[self products] objectAtIndex: [indexPath row]];
	NSString *feature = [product productIdentifier];
	[MKStoreManager setDelegate: self];
	[[MKStoreManager sharedManager] buyFeature: feature];*/

	SKProduct *product = [[self products] objectAtIndex: [indexPath row]];
	
	[self showDetailViewForProduct: product animated: YES];
	
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void) showDetailViewForProduct: (SKProduct *) product animated: (BOOL) animated
{
	MinyxStoreDetailViewController *dvc = [[MinyxStoreDetailViewController alloc] initWithNibName:@"MinyxStoreDetailViewController" bundle: nil];
	[dvc setProduct: product];
	[dvc setDataSource: [self productInformationDataSource]];
	
	[[self navigationController] pushViewController: dvc animated: animated];
	[dvc release];
	
}



- (void)productPurchased:(NSString *)productId
{
//	[MKStoreManager setDelegate: nil];
	[activity stopAnimating];
	[self setProducts: [[MKStoreManager sharedManager] purchasableObjects]];
	[tableView reloadData];
}

- (void)transactionCanceled
{
	//[MKStoreManager setDelegate: nil];
	[activity stopAnimating];
	
//	[tableView reloadData];
}

- (void) restoreFinished
{
	//[MKStoreManager setDelegate: nil];
	[activity stopAnimating];
	[self setProducts: [[MKStoreManager sharedManager] purchasableObjects]];
	[tableView reloadData];
}

@end
