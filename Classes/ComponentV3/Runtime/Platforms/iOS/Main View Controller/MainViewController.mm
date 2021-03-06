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
#include "SoundSystem.h"
#import "WebkitViewController.h"
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
@synthesize adView;
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
	
/*	[dc addObserver: self
		   selector: @selector(dismissStore:)
			   name: kHideInAppStore
			 object: nil];*/
#endif
	
#ifdef USE_PROMOTION
	[dc addObserver: self 
		   selector: @selector(showPromotionView:)
			   name: kShowPromotionView
			 object: nil];
#endif	

	[dc addObserver: self 
		   selector: @selector(showWebkitView:)
			   name: kShowWebkitView
			 object: nil];
	

	
#ifdef USE_NEWSFEED
	newsController = [[NewslineViewController alloc] initWithNibName: @"NewslineViewController" 
															  bundle: nil];
	
	[newslineView addSubview: [newsController view]];
	[newsController setNewsItems: [appController newsItemsForOffline]];
	//[newsController start];		//newscontroller listens to application did become active notification
#endif
	
	//post_notification (kNewGLViewLoaded, [self glView]);
#ifdef USE_ADS
	[[self view] addSubview: [self adView]];
	
	//NSLog(@"keywindow: %@", [[UIApplication sharedApplication] keyWindow]);
//	[[[UIApplication sharedApplication] keyWindow] addSubview: [self adView]];
//	[[[UIApplication sharedApplication] keyWindow] bringSubviewToFront: [self adView]];
	
	if (!adController)
	{
#ifdef ORIENTATION_LANDSCAPE
		adController = [[MXAdController alloc] initWithNibName: @"MXAdController_landscape" bundle: nil];
#else
		adController = [[MXAdController alloc] initWithNibName: @"MXAdController_portrait" bundle: nil];
#endif
		[adController setSuperViewController: self];
		[[self adView] addSubview: [adController view]];
	}


#endif	
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
	
	//this shit is horribly defunct
	//if (g_MayReleaseMemory)
	{   
	//	[glView release];
		// Releases the view if it doesn't have a superview.
	//	[super didReceiveMemoryWarning];	
	//	g_TextureManager.purgeCache();
	}
	

//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Mem warning!" 
//														message: @"You have been warned!" 
//													   delegate: nil
//											  cancelButtonTitle: @"No." 
//											  otherButtonTitles: @"NO DADDY NO", nil];
//	
//	[alertView show];
//	[alertView release]; 
	
	
	//tex manager doesnt matter
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
	
#ifdef USE_NEWSFEED
	[newsController release];
	newsController = nil;
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
	[g_pGameCenterManger submitCachedScores];
	
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
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
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
- (void) reloadScoresComplete: (GKLeaderboard*) leaderBoard error: (NSError*) error
{
	NSLog(@"scores are: %@", [g_pGameCenterManger top100_scores]);
	NSLog(@"last pos: %i\n", [g_pGameCenterManger last_position]);
}
#endif

#ifdef USE_INAPPSTORE

- (void) showInAppStore: (NSNotification *) notification
{
	
	g_MayReleaseMemory = NO;
	NSString *prodid = [notification object];
	NSLog(@"prodid: %@", prodid);
	
//	NSLog(@"purchasable: %@", [[MKStoreManager sharedManager] purchasableObjects])
	MinyxStoreViewController *msvc = [[MinyxStoreViewController alloc] initWithNibName:
									  @"MinyxStoreViewController" 
																				bundle: nil];
	[msvc setProductInformationDataSource: appController];
	[msvc setProductIdToShow: prodid];
	
	UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController: msvc];
	[[nav navigationBar] setBarStyle: UIBarStyleBlack];
	[[msvc navigationItem] setTitle: @"Minyx Store"];

	if ([self modalViewController])
		[[self modalViewController] presentModalViewController: nav animated: YES];
	else
		[self presentModalViewController: nav animated: YES];
	
	[msvc autorelease];
	[nav autorelease];
}
#endif

#ifdef USE_PROMOTION
- (void) showPromotionView: (NSNotification *) notification
{
	g_MayReleaseMemory = NO;
	PromotionViewController *controller = [[PromotionViewController alloc]
										   initWithNibName:@"PromotionViewController"
										   bundle:[NSBundle mainBundle]];
	
	if ([notification object])
		controller.promotionAddress = [notification object];
	else
		controller.promotionAddress = PROMOTION_URL;
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}
#endif


- (void) showWebkitView: (NSNotification *) notification
{
	g_MayReleaseMemory = NO;
	WebkitViewController *controller = [[WebkitViewController alloc]
										   initWithNibName:@"WebkitViewController"
										   bundle:[NSBundle mainBundle]];
	
	if ([notification object])
	{	
		controller.promotionAddress = [notification object];
	}
	else
	{
		[controller release];
		g_MayReleaseMemory = YES;
		return;
	}
	
	[self presentModalViewController:controller animated:YES];
	[controller release];
}



@end
