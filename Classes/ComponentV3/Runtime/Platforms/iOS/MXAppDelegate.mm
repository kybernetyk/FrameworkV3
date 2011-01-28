
#include "SystemConfig.h"
#import "MXAppDelegate.h"
#import "EAGLView.h"
#include <sys/time.h>
#include "Entity.h"
#include "EntityManager.h"
#import "FacebookSubmitController.h"
#import "MainViewController.h"
#include "RenderDevice.h"
#import <QuartzCore/QuartzCore.h>
#include "Timer.h"
#include "ComponentV3.h"
#import "NotificationSystem.h"
#import "SimpleAudioEngine.h"
#import "Reachability.h"

#ifdef USE_GAMECENTER
#import "GameCenterManager.h"
#endif

#import "Appirater.h"

BOOL g_MayReleaseMemory = YES;
BOOL g_is_online = NO;

@implementation MXAppDelegate
@synthesize window;


#pragma mark -
#pragma mark facebook 
//- (void) shareLevelOnFarmville
//{
//
//	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
//	if ([defs boolForKey: @"facebook_disable"])
//	{
//		NSLog(@"Facebook disabled by user!");
//		return;
//	}
//	
//	
//	NSString *token = [defs objectForKey: @"fbtoken"];
//	if (token)
//	{
//		NSLog(@"found token. init share!");
//		[self initFBShare];
//		return;
//	}
//	
//	NSLog(@"no token. let's ask user!");
//	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Share On Facebook" 
//														message: @"Do you want to share your progress on Facebook?" 
//													   delegate: self 
//											  cancelButtonTitle: @"No. Don't ask me again." 
//											  otherButtonTitles: @"Yes!", @"Not now.", nil];
//	
//	[alertView show];
//	[alertView autorelease]; 
//	
//}
//
//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//	NSLog(@"omg der buttonen indexen: %i, %@", buttonIndex,	[alertView buttonTitleAtIndex: buttonIndex]);
//	if (buttonIndex == 1)
//	{
//		NSLog(@"user wants to share!");
//		[self initFBShare];
//		return;
//	}
//	if (buttonIndex == 2)
//	{
//		NSLog(@"user wants not to share now ...");
//		return;
//	}
//	
//	NSLog(@"user hates facebook!");
//	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
//	[defs setBool: YES forKey: @"facebook_disable"];
//	[defs synchronize];
//}


- (void) initFBShare: (id) datasource
{
	if (!facebookController)
	{
		facebookController = [[FacebookSubmitController alloc] initWithNibName: @"FacebookSubmitController" bundle: nil];
		[facebookController setDelegate: self];
		[facebookController setDataSource: datasource];
		
	}
	
//	[facebookController setLevel: g_GameState.level];
//	[facebookController setScore: g_GameState.score];
	
	//	[self presentModalViewController: fbsc animated: YES];
	[facebookController shareOverFarmville];
}

- (void) facebookSubmitControllerDidFinish: (id) controller
{
	NSLog(@"facebook controller finished");

}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
	return [facebookController handleOpenURL: url];
	
	return YES;
}

- (void) setNewGLView: (NSNotification *) notification
{
	return;
	
	NSLog(@"setting gl view to: %@", [notification object]);

	EAGLView *newgl = (EAGLView *)[notification object];
	[self stopAnimation];
	
	[glView autorelease];
	glView = [newgl retain];
//	glView = [mainViewController glView];
	//glView = newgl;
	
	NSLog(@"superview: %@", [glView superview]);

	mx3::RenderDevice::sharedInstance()->init ();
	[self startAnimation];
	
	
}

#pragma mark -
#pragma mark Reachability
- (void) reachabilityChanged: (NSNotification* )note
{
	Reachability* curReach = [note object];
	NetworkStatus stat = [curReach currentReachabilityStatus];
	
	NSLog(@"mxmenu reachability changed to %i",stat);
	
	if (stat == NotReachable)
	{	
		g_is_online = NO;	
	}
	else
	{
		g_is_online = YES;
	}
}

#pragma mark -
#pragma mark application delegate
- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
	CV3Log ("Component V3 Engine. Version %s starting up ...\n", CV3_VERSION);

	Class acClass = NSClassFromString(@"AppController");
	
	if (!acClass)
	{
		NSLog(@"You must have an AppController Class!");
		abort();
	}

	NSString *nibName = MAINVIEWNIBNAME;
	NSLog(@"Using %@ as nib ...", nibName);
	
	mainViewController = [[MainViewController alloc] initWithNibName: nibName bundle: nil];
	
	if (!mainViewController)
	{
		NSLog(@"couldn't create the main view controller!");
		abort();
	}
	NSLog(@"window: %@",window);
	[window addSubview: [mainViewController view]];
	
	//glView = [[mainViewController glView] retain];
	glView = [mainViewController glView];
	
	mx3::RenderDevice::sharedInstance()->init ();
#ifdef __ALLOW_RENDER_TO_TEXTURE__
	mx3::RenderDevice::sharedInstance()->setupBackingTexture();
	mx3::RenderDevice::sharedInstance()->setRenderTargetBackingTexture();
	mx3::RenderDevice::sharedInstance()->setRenderTargetScreen();
#endif
	
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	[nc addObserver: self 
		   selector: @selector(setNewGLView:) 
			   name: kNewGLViewLoaded 
			 object: nil];

	[nc addObserver: self 
		   selector: @selector(reachabilityChanged:) 
			   name: kReachabilityChangedNotification 
			 object: nil];
	
	[Appirater appLaunched: YES];
	
	theGame = new game::Game();
	theGame->init();
	
	[self startAnimation];
	
	theGame->appDidFinishLaunching ();
	
	reachability = [[Reachability reachabilityWithHostName: @"apple.com"] retain];
	[reachability startNotifer];

//	NSLog(@"adview: %@", [mainViewController adView]);
//	[window bringSubviewToFront: [mainViewController adView]];
}

- (void)applicationWillTerminate:(UIApplication *)application 
{
	theGame->appWillTerminate();
	theGame->terminate();
}



- (void)applicationWillResignActive:(UIApplication *)application 
{
	//game::g_pGame->setPaused(true);
	theGame->appWillResignActive();
	//[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
	//game::g_pGame->setPaused(false);
	theGame->appDidBecomeActive ();
	
	//[[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application 
{
	NSLog(@" O M G MEMORY WARNING\n");
	//	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application 
{
	[self stopAnimation];
	theGame->appDidEnterBackground();
}

-(void) applicationWillEnterForeground:(UIApplication*)application 
{
	[Appirater appEnteredForeground: YES];
	[self startAnimation];
	theGame->appWillEnterForeground();
}


- (void)applicationSignificantTimeChange:(UIApplication *)application 
{
	//[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
	game::next_game_tick = mx3::GetTickCount();
	game::timer.update();
	game::timer.update();
	
}


#pragma mark -
#pragma mark game
- (void) startAnimation
{
	if (displayLink)
		return;
	
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
	displayLink = [CADisplayLink displayLinkWithTarget: self selector:@selector(renderScene)];

	int interval = 60 / DESIRED_FPS;
	[displayLink setFrameInterval: interval];
	[displayLink addToRunLoop: [NSRunLoop currentRunLoop] forMode: NSDefaultRunLoopMode];
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
	//mac init
#endif
	
}

- (void) stopAnimation
{
	[displayLink invalidate];
	displayLink = nil;
}


- (void)renderScene
{
	theGame->update();
	
	[glView startDrawing];
	theGame->render();
	[glView endDrawing];
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[glView release];
	[[mainViewController view] removeFromSuperview];
	[mainViewController release];
	[window release];

	[super dealloc];
}


@end
