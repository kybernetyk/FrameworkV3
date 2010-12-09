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
- (IBAction) dismissStore: (id) sender
{
	[MKStoreManager setDelegate: nil];
	//[delegate minyxStoreDismissed: self];

	post_notification (kHideInAppStore, self);
	
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kHideInAppStore object: self];
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

- (void) restorePurchases: (id) sender
{
	[MKStoreManager setDelegate: self];
	[activity startAnimating];
	[[MKStoreManager sharedManager] restorePreviousTransactions];
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
