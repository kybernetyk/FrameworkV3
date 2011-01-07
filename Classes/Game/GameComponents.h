/*
 *  GameComponens.h
 *  ComponentV3
 *
 *  Created by jrk on 16/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once
#pragma error "fick dich"

#include "Component.h"

using namespace mx3;
namespace game
{
#pragma mark -
#pragma mark game 

	
	struct GameBoardElement : public mx3::Component
	{
		static ComponentID COMPONENT_ID;
		
		
		GameBoardElement ()
		{
			_id = COMPONENT_ID;
		}
		
		DEBUGINFO ("Game Board Element.")
	};
	
	
}
