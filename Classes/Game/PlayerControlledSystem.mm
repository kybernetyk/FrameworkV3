/*
 *  PlayerControlledSystem.cpp
 *  ComponentV3
 *
 *  Created by jrk on 8/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "Util.h"
#include "PlayerControlledSystem.h"
#include "InputDevice.h"
#include "ParticleSystem.h"

namespace game 
{
	

	PlayerControlledSystem::PlayerControlledSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
	}
	
	//TODO: rename right blob and left blob to: left blob -> center blob, right blob -> rotating blob
	void PlayerControlledSystem::update (float delta)
	{
		bool move_left = false;
		bool move_right = false;
		bool rotate = false;
		
		
		move_left = InputDevice::sharedInstance()->getLeftActive();
		move_right = InputDevice::sharedInstance()->getRightActive();
		rotate = InputDevice::sharedInstance()->getUpActive();
		
		
		
		_entities.clear();
		_entityManager->getEntitiesPossessingComponents (_entities, GameBoardElement::COMPONENT_ID, ARGLIST_END);

	
	}

}