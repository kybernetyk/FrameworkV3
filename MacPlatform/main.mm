//
//  main.m
//  SDLTest
//
//  Created by jrk on 7/1/11.
//  Copyright 2011 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SDL/SDL.h>

#include "Game.h"
#include "RenderDevice.h"

int SDL_main(int argc, char *argv[])
{
//    return NSApplicationMain(argc,  (const char **) argv);
	
	printf("lol\n");
	
	// Init SDL video subsystem
	if ( SDL_Init (SDL_INIT_VIDEO) < 0 ) 
	{
        fprintf(stderr, "Couldn't initialize SDL: %s\n",
				SDL_GetError());
		exit(1);
	}
	
	
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_SetVideoMode(320, 480, 0, SDL_OPENGL);
	
	SDL_WM_SetCaption ("MaCV3",0);

	mx3::RenderDevice::sharedInstance()->init();
	
	game::Game the_game;
	the_game.init();
	
	SDL_Event event; /* Event structure */
	bool bRunning = true;
	while (bRunning)
	{
		NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];

		while(SDL_PollEvent(&event))
		{
			switch(event.type)
			{
				case SDL_QUIT:
					bRunning = false;
					break;
				case SDL_KEYDOWN:
					if ( ( (KMOD_LMETA & event.key.keysym.mod) || (KMOD_RMETA & event.key.keysym.mod)) && event.key.keysym.sym == SDLK_q) 
					{ 
						bRunning = false;
					} 
					break;
				default:
					break;
			}
		}

		the_game.update();
		the_game.render();

		SDL_GL_SwapBuffers();
		glClearColor(0.0,0.0,0.7,0.0);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);	 // Clear The Screen And The Depth Buffer
		glLoadIdentity();	
	
		[pool drain];
		usleep(16666);
	}
	
	
	return 0;
}
