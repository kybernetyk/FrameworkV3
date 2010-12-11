/*
 *  SoundSystem.h
 *  ComponentV3
 *
 *  Created by jrk on 12/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once
#include <vector>
#include "EntityManager.h"
#include "Entity.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

namespace mx3 
{

	#define SFX_EMPTY 0
	#define SFX_TICK 1
	#define SFX_BLAM 2
	#define SFX_KAWAII 3
	#define SFX_KAWAII2 4
	#define SFX_LEVELUP 5

	#define MUSIC_GAME 1

	class SoundSystem
	{
	public:
		SoundSystem (EntityManager *entityManager);
		void registerSound (std::string filename, int sfx_id);
//		void preloadSounds ();
		
		void update (float delta);	
		
		static mx3::Entity *make_new_sound (int soundfx);
		static void play_sound (std::string filename);
		static void play_background_music (std::string filename);
		static void preload_sound (std::string filename);
		
	protected:
		EntityManager *_entityManager;
		
		std::string sounds[MAX_REGISTERED_SOUNDS];
		float sound_delays[MAX_REGISTERED_SOUNDS];
		
		int music_playing;
		std::vector<Entity*> _entities;
	};

}