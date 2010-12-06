//
//  MinyxStoreViewController.m
//  Fruitmunch
//
//  Created by jrk on 6/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MinyxStoreViewController.h"
#import "MKStoreManager.h"

@implementation MinyxStoreViewController
@synthesize delegate;
@synthesize activity;
@synthesize tableView;
@synthesize products;

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
	
	
	[self setProducts: [[MKStoreManager sharedManager] purchasableObjects]];
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
	[MKStoreManager setDelegate: nil];
	[self setActivity: nil];
	[self setProducts: nil];
    [super dealloc];
}


#pragma mark -
#pragma mark actions 
- (IBAction) dismissStore: (id) sender
{
	[MKStoreManager setDelegate: nil];
	[delegate minyxStoreDismissed: self];
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
		[cell setAccessoryType: UITableViewCellAccessoryDetailDisclosureButton];
	}

	
	SKProduct *product = [[self products] objectAtIndex: [indexPath row]];

	NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
	[numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
	[numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
	[numberFormatter setLocale:product.priceLocale];
	NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];

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
	[activity startAnimating];
	
	SKProduct *product = [[self products] objectAtIndex: [indexPath row]];
	
	NSString *feature = [product productIdentifier];
	[MKStoreManager setDelegate: self];
	[[MKStoreManager sharedManager] buyFeature: feature];
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark -
#pragma mark MKStoreManager

- (void)productPurchased:(NSString *)productId
{
	[activity stopAnimating];
	[self setProducts: [[MKStoreManager sharedManager] purchasableObjects]];
	[tableView reloadData];
}

- (void)transactionCanceled
{
	[activity stopAnimating];
	[self setProducts: [[MKStoreManager sharedManager] purchasableObjects]];
	[tableView reloadData];
}


@end
