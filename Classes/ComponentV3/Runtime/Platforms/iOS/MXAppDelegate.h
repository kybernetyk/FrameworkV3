#pragma once
#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "FacebookSubmitController.h"
#import "Reachability.h"
#include "Game.h"

extern BOOL g_MayReleaseMemory;
extern BOOL g_is_online;


@interface MXAppDelegate : NSObject <UIApplicationDelegate> 
{
    UIWindow *window;
	NSTimer*			mTimer;   // Rendering Timer
	CADisplayLink *displayLink;

	EAGLView *glView;
	
	game::Game *theGame;
	
	MainViewController *mainViewController;
	FacebookSubmitController *facebookController;
	Reachability *reachability;
}
@property (nonatomic, retain) IBOutlet UIWindow *window;

- (void) startAnimation;
- (void) stopAnimation;
- (void) renderScene;
- (void) initFBShare: (id) datasource;
@end

