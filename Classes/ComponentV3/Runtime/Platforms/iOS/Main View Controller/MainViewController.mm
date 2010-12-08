//
//  MainViewController.m
//  ComponentV3
//
//  Created by jrk on 15/11/10.
//  Copyright 2010 flux forge. All rights reserved.
//
#import "ComponentV3.h"
#import "MainViewController.h"
#import "EAGLView.h"
#include "TextureManager.h"
#import "NotificationSystem.h"

#ifdef USE_INAPPSTORE
#import "MKStoreManager.h"
#import "MinyxStoreViewController.h"
#endif

#ifdef USE_GAMECENTER
#import <GameKit/GameKit.h>

@implementation GKLeaderboardViewController (meinpenis)


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

@end
#endif

#ifdef USE_PROMOTION
#import "PromotionViewController.h"
#endif

@implementation MainViewController
@synthesize glView;
@synthesize appController;
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
	NSLog(@"view did load ... %@", self);
    [super viewDidLoad];
	[appController setup];
	
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	
#ifdef USE_GAMECENTER
	[dc addObserver: self selector: @selector(showLeaderBoards:) name: kShowLeaderBoard object: nil];
	
	gcManager = [[GameCenterManager alloc] init];
	[gcManager setDelegate: self];
	
	[gcManager authenticateLocalUser];
#endif
	
#ifdef USE_INAPPSTORE
	NSSet *products = [appController inAppProductIDs];
	
//	[[MKStoreManager sharedManager] setProductIDs: products];
	
	[MKStoreManager sharedManagerWithProductIDs: products];
	
	[dc addObserver: self 
		   selector: @selector(showInAppStore:)
			   name: kShowInAppStore 
			 object: nil];
	
	[dc addObserver: self
		   selector: @selector(dismissStore:)
			   name: kHideInAppStore
			 object: nil];
#endif
	
#ifdef USE_PROMOTION
	[dc addObserver: self 
		   selector: @selector(showPromotionView:)
			   name: kShowPromotions
			 object: nil];
#endif	
	
	[dc postNotificationName: kNewGLViewLoaded object: glView];
	
}



// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
//	return YES;
    // Return YES for supported orientations
#ifdef ORIENTATION_LANDSCAPE
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight ||
			interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
#endif
	
#ifdef ORIENTATION_PORTRAIT
	return (interfaceOrientation == UIInterfaceOrientationPortrait ||
			interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown);
#endif
	
	//else
	return YES;
	
}


- (void)didReceiveMemoryWarning 
{
	if (g_MayReleaseMemory)
	{   
		// Releases the view if it doesn't have a superview.
		[super didReceiveMemoryWarning];	
	}
    
	//tex manager doesnt matter
    g_TextureManager.purgeCache();
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	
	[[NSNotificationCenter defaultCenter] removeObserver: self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self setGlView: nil];
	NSLog(@"appc: %i", [appController retainCount]);
	[self setAppController: nil];
	
#ifdef USE_GAMECENTER
	[gcManager release];
	gcManager = nil;
#endif
	
	NSLog(@"lol view did unload!");
}


- (void)dealloc 
{
#ifdef USE_GAMECENTER
	[gcManager release];
	gcManager = nil;
#endif
	
	[self setGlView: nil];
	[self setAppController: nil];

	[[NSNotificationCenter defaultCenter] removeObserver: self];
    [super dealloc];
}

extern bool spawn_one;

- (IBAction) spawnOne: (id) sender
{
	spawn_one = true;	
}

extern bool spawn_player;

- (IBAction) spawnPlayer: (id) sender
{
	spawn_player = true;
}


#pragma mark -
#pragma mark leaderboard
#ifdef USE_GAMECENTER

#pragma mark -
#pragma mark gamecenter delegate
- (void) processGameCenterAuth: (NSError*) error
{
	NSLog(@"processGameCenterAuth. err: %@", [error localizedDescription]);
}

- (void) scoreReported: (NSError*) error
{
	NSLog(@"scoreReported. err: %@", [error localizedDescription]);	
}


- (void) showLeaderBoards: (NSNotification *) notification
{
	g_MayReleaseMemory = NO;
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *scope = [defs objectForKey: @"leaderboardScope"];
	GKLeaderboardTimeScope lbscope = [scope integerValue];
	NSString *catName = [defs objectForKey: @"leaderboardCategoryName"];
	
	GKLeaderboardViewController *leaderboardController = [[GKLeaderboardViewController alloc] init];
	[leaderboardController setTimeScope: lbscope];
	[leaderboardController setCategory: catName];
	[leaderboardController setLeaderboardDelegate: self];
	
	[self presentModalViewController: leaderboardController animated: YES];
	
	[leaderboardController release];
	
}

- (void)leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSNumber *scope = [NSNumber numberWithInt: [viewController timeScope]];
	if (scope)
	{	
		[defs setObject: scope forKey: @"leaderboardScope"];
	}
	if ([viewController category])
	{
		[defs setObject: [viewController category] forKey: @"leaderboardCategoryName"];
	}
//	NSLog(@"cat: %@", [viewController category]);
	[defs synchronize];
	
	[self dismissModalViewControllerAnimated: YES];
	g_MayReleaseMemory = YES;
}	
#endif

#ifdef USE_INAPPSTORE

- (void) showInAppStore: (NSNotification *) notification
{
	
	NSString *prodid = [notification object];
	//NSLog(@"prodid: %@", prodid);
	
//	NSLog(@"purchasable: %@", [[MKStoreManager sharedManager] purchasableObjects])
	MinyxStoreViewController *msvc = [[MinyxStoreViewController alloc] initWithNibName:
									  @"MinyxStoreViewController" 
																				bundle: nil];
	[msvc setProductInformationDataSource: appController];
	[msvc setProductIdToShow: prodid];
	
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: msvc];
	[[nav navigationBar] setBarStyle: UIBarStyleBlack];
	[[msvc navigationItem] setTitle: @"Minyx Store"];
	[self presentModalViewController: nav animated: YES];
	
	[msvc autorelease];
	[nav autorelease];
}

- (void) dismissStore: (NSNotification *) notification
{
	[self dismissModalViewControllerAnimated: YES];
}
#endif

#ifdef USE_PROMOTION
- (void) showPromotionView: (NSNotification *) notification
{
	PromotionViewController *controller = [[PromotionViewController alloc]
										   initWithNibName:@"PromotionViewController"
										   bundle:[NSBundle mainBundle]];
	controller.promotionAddress = PROMOTION_URL;
	[self presentModalViewController:controller animated:YES];
	[controller release];
}
#endif

@end
