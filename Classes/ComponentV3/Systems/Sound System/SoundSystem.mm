/*
 *  SoundSystem.cpp
 *  ComponentV3
 *
 *  Created by jrk on 12/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "SoundSystem.h"
#import "EntityManager.h"
#import "Component.h"
#import "Entity.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SimpleAudioEngine.h"
namespace mx3 
{
	
		
	/*SystemSoundID loadSound (const char *fn)
	{
		NSString *filename = [NSString stringWithCString: fn];
		
		// Create the URL for the source audio file. The URLForResource:withExtension: method is
		//    new in iOS 4.0.
		NSURL *soundURL   = [[NSBundle mainBundle] URLForResource: filename
													withExtension: nil];
		
		// Store the URL as a CFURLRef instance
		CFURLRef soundFileURLRef = (CFURLRef) [soundURL retain];
		SystemSoundID sid;
		
		// Create a system sound object representing the sound file.
		AudioServicesCreateSystemSoundID (
										  soundFileURLRef,
										  &sid
										  );		
		
		
		//NSNumber *theID = [NSNumber numberWithInt: sid];
		
		//[soundRefs setObject: theID forKey: filename];
		
		return sid;
		
		//AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);		
		//AudioServicesPlaySystemSound (sid);		
		
	}
	*/

	SoundSystem::SoundSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
		for (int i = 0; i < MAX_REGISTERED_SOUNDS; i++)
			sound_delays[i] = 0.0;
		
		music_playing = 0;
	}

	void SoundSystem::registerSound (std::string filename, int sfx_id)
	{
		if (sfx_id >= MAX_REGISTERED_SOUNDS)
		{	
			abort();
			
		}
		
		sounds[sfx_id] = filename;
	}
	
	void SoundSystem::preloadSounds ()
	{
		for (int i = 0; i < MAX_REGISTERED_SOUNDS; i++)
		{
			NSString *s = [NSString stringWithCString: sounds[i].c_str() 
											 encoding: NSASCIIStringEncoding];
			if (!s || [s length] == 0)
				continue;
			
			NSLog(@"sound preload: %@", s);
			
			[[SimpleAudioEngine sharedEngine] preloadEffect: s];
		}
	}
	
	void SoundSystem::playMusic (int music_id)
	{
		if (music_playing == music_id)
			return;

		
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
		
		if (music_id == 0)
			return;
			
		NSString *filename = nil;
		
		
		if (music_id == MUSIC_GAME)
			filename = @"music.mp3";
		
		if (!filename)
			return;
		
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic: filename loop: YES];
	}


	void SoundSystem::update (float delta)
	{

		_entities.clear();
		_entityManager->getEntitiesPossessingComponent (_entities,SoundEffect::COMPONENT_ID);
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		Entity *current_entity = NULL;

		for (int i = 0; i < MAX_REGISTERED_SOUNDS; i++)
			sound_delays[i] -= delta;
		
		SoundEffect *current_sound = NULL;
		
		while (it != _entities.end())
		{
			current_entity = *it;
			++it;
			
			current_sound = _entityManager->getComponent <SoundEffect> (current_entity);
			
			if (current_sound)
			{
				int sid = current_sound->sfx_id;
				if (sound_delays[sid] <= 0.0)
				{	
					//printf("PLAYIN SID %i ...\n", sid);
					[[SimpleAudioEngine sharedEngine] playEffect: [NSString stringWithCString: sounds[sid].c_str() encoding: NSASCIIStringEncoding]];
					
					sound_delays[sid] = 0.1;
				}
			}
			_entityManager->addComponent<MarkOfDeath>(current_entity);
		}
	}

	mx3::Entity *SoundSystem::make_new_sound (int soundfx)
	{
		if (soundfx >= MAX_REGISTERED_SOUNDS)
		{	
			abort();
			return NULL;
		}
		
		EntityManager *em = Entity::entityManager;
		Entity *sound = em->createNewEntity();
		SoundEffect *sfx = em->addComponent <SoundEffect> (sound);
		sfx->sfx_id = soundfx;
		
		return sound;
	}
}