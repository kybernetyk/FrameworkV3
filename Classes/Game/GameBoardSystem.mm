/*
 *  GameBoardSystem.cpp
 *  Donnerfaust
 *
 *  Created by jrk on 17/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "GameBoardSystem.h"
#include "GameComponents.h"

namespace game 
{
	GameBoardSystem::GameBoardSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
	}
	
	
	
	void GameBoardSystem::update (float delta)
	{
		_delta = delta;
		/* create collision map */	
		_entities.clear();
		_entityManager->getEntitiesPossessingComponents(_entities,  GameBoardElement::COMPONENT_ID, ARGLIST_END );
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		
		
		_current_entity = NULL;
		_current_gbe = NULL;
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);
			_current_position = _entityManager->getComponent<Position>(_current_entity);

		}

	}
	
}
