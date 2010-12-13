/*
 *  SoundSystem.h
 *  ComponentV3
 *
 *  Created by jrk on 12/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
/*
The SoundSystem is a class which is responsible for sound and music playback in the game.
it offers static methods for fast playback of samples by filename and an entity based
playback queue where by creating entities with a "SoundEffect" component you can dispatch sfx

the entity based sfx are refered by SFX_IDs which you obtain by registering samples to the
sound system. an elaborate caching mechanism makes the entity approach the preferred approach
for in game sounds. static methods should be used for menus
 
 on the iphone setting the music volume to 0 enables other apps to play music while
 the game runs.
 
 IMPORTANT: prior to playing any music you have to call set_music_volume() once!
 */

#pragma once
#include <vector>
#include "EntityManager.h"
#include "Entity.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

namespace mx3 
{
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
		
		static void set_sfx_volume (float vol);
		static void set_music_volume (float vol);
		static void resume_background_music ();
		
	protected:
		EntityManager *_entityManager;
		
		static float music_vol;
		static float sfx_vol;
		
		std::string sounds[MAX_REGISTERED_SOUNDS];
		float sound_delays[MAX_REGISTERED_SOUNDS];
		
		static std::string last_music_played;
		std::vector<Entity*> _entities;
	};

}