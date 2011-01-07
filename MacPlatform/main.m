//
//  main.m
//  SDLTest
//
//  Created by jrk on 7/1/11.
//  Copyright 2011 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SDL/SDL.h>

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

	SDL_Event event; /* Event structure */
	bool bRunning = true;
	while (bRunning)
	{
		while(SDL_PollEvent(&event))
		{
			switch(event.type)
			{
				case SDL_QUIT:
					bRunning = false;
					break;
				default:
					break;
			}
		}


		SDL_GL_SwapBuffers();
		glClearColor(0.0,0.0,0.7,0.0);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);	 // Clear The Screen And The Depth Buffer
		glLoadIdentity();	
	
		usleep(30000);
	}
	
	
	return 0;
}
