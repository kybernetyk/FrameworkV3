//
//  MainViewController.h
//  ComponentV3
//
//  Created by jrk on 15/11/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <UIKit/UIKit.h>
#ifdef USE_GAMECENTER
#import "GameCenterManager.h"
#endif

@class EAGLView;

@interface MainViewController : UIViewController 
{
	EAGLView *glView;
	id appController;
	
#ifdef USE_GAMECENTER
	GameCenterManager *gcManager;
#endif
}

- (IBAction) spawnOne: (id) sender;

- (IBAction) spawnPlayer: (id) sender;

@property (nonatomic, retain) IBOutlet EAGLView *glView;
@property (nonatomic, retain) IBOutlet id appController;
@end
