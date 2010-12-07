//
//  DetailViewController.m
//  Fruitmunch
//
//  Created by jrk on 7/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "MinyxStoreDetailViewController.h"
#import "MKStoreManager.h"

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


- (void) dismissStore: (id) sender
{
	[MKStoreManager setDelegate: nil];

	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc postNotificationName: @"DismissMinyxStore" object: self];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];

	
	UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
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
	[activity startAnimating];
	NSString *feature = [product productIdentifier];
	[MKStoreManager setDelegate: self];
	[[MKStoreManager sharedManager] buyFeature: feature];
	
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
