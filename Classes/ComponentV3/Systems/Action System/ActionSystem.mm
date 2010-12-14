/*
 *  ActionSystem.cpp
 *  Donnerfaust
 *
 *  Created by jrk on 18/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "ActionSystem.h"

#include <math.h>
mx3::ActionSystem *g_pActionSystem;

namespace mx3 
{
	ActionSystem::ActionSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
		g_pActionSystem = this;
	}


	void ActionSystem::addActionToEntity (Entity *entity, Action *action)
	{
		ActionContainer *container = _entityManager->getComponent<ActionContainer>(entity);
		if (!container)
			container = _entityManager->addComponent<ActionContainer>(entity);
		bool did_insert = false;
		for (int i = 0; i < NUM_OF_ACTIONS_PER_CONTAINER; i++)
		{
			if (!container->actions[i])
			{
				container->actions[i] = action;
				did_insert = true;
				break;
			}
		}
		
		if (!did_insert)
			abort();
		
	}
	
	void ActionSystem::cancelAction (Entity *entity,Action *action)
	{
		ActionContainer *container = _entityManager->getComponent<ActionContainer>(entity);
		if (!container)
			return;
		
		for (int i = 0; i < NUM_OF_ACTIONS_PER_CONTAINER; i++)
		{
			if (container->actions[i] == action)
			{
				Action *child = action->on_complete_action;
				
				while (child)
				{
					Action *t = child;	
					
					child = child->on_complete_action;
					
					delete t;
				}
				container->actions[i] = NULL;
			}
		}
	}
	
	void ActionSystem::step_action (Action *action)
	{
		action->_timestamp += __delta;
		_current_delta = __delta;
		if ( (action->duration - action->_timestamp) <= 0.0)
		{
			action->finished = true;
			_current_delta -= (action->_timestamp - action->duration);
		}
		
	}
	
	
	void ActionSystem::handle_default_action (Action *action)
	{
		//printf(".");
	}
	
	void ActionSystem::handle_move_to_action (MoveToAction *action)
	{
#ifdef __ABORT_GUARDS__
		if (!_current_position)
			abort();
#endif
		if (action->duration == 0.0)
		{
			_current_position->x = action->x;
			_current_position->y = action->y;
			return;
		}
		
		if (action->_ups_x >= INFINITY)
		{
			float dx = action->x - _current_position->x;
			action->_ups_x = dx / action->duration;
		}
		
		if (action->_ups_y >= INFINITY)
		{
			float dy = action->y - _current_position->y;
			action->_ups_y = dy / action->duration;

		}
		
		_current_position->x += action->_ups_x * _current_delta;
		_current_position->y += action->_ups_y * _current_delta;
		
//		if (action->finished)
//		{
//			_current_position->x = action->x;
//			_current_position->y = action->y;
//			
//		}
	}
	
	void ActionSystem::handle_move_by_action (MoveByAction *action)
	{
#ifdef __ABORT_GUARDS__
		if (!_current_position)
			abort();
				
#endif
		if (action->duration == 0.0)
		{
			_current_position->x += action->x;
			_current_position->y += action->y;
			return;
		}
		
		if (action->_dx >= INFINITY)
			action->_dx = _current_position->x + action->x;
		if (action->_dy >= INFINITY)
			action->_dy = _current_position->y + action->y;
		
		_current_position->x += (action->x/action->duration)*_current_delta;
		_current_position->y += (action->y/action->duration)*_current_delta;
		
		
	}

	void ActionSystem:: handle_scale_by_action (ScaleByAction * action)
	{
#ifdef __ABORT_GUARDS__
		if (!_current_position)
			abort();
		
#endif
		if (action->duration == 0.0)
		{
			_current_position->scale_x *= action->scale_x;
			_current_position->scale_y *= action->scale_y;
			return;
		}
		
		if (action->_stepx >= INFINITY)
		{
			action->_stepx = ((_current_position->scale_x * action->scale_x) - _current_position->scale_x) / action->duration;
		}
		
		if (action->_stepy >= INFINITY)
		{
			action->_stepy = ((_current_position->scale_y * action->scale_y) - _current_position->scale_y) / action->duration;
		}
		
		_current_position->scale_x += action->_stepx * _current_delta;
		_current_position->scale_y += action->_stepy * _current_delta;
	}
	
	void ActionSystem::handle_fade_to_action (FadeToAction *action)
	{
#ifdef __ABORT_GUARDS__
		if (!_current_renderable)
			abort();
		
#endif
		if (action->duration == 0.0)
		{
			_current_renderable->alpha = action->alpha;
			return;
		}
		
		if (action->_step >= INFINITY)
		{
			action->_step = (action->alpha - _current_renderable->alpha) / action->duration;
		}
		

		_current_renderable->alpha += action->_step * _current_delta;
	}
	
	void ActionSystem::handle_add_component_action (AddComponentAction *action)
	{
		
#ifdef __ABORT_GUARDS__						
		if (!action->component_to_add)
		{
			CV3Log ("no component pointer set!\n");
			_entityManager->dumpEntity(_current_entity);
			_entityManager->dumpComponent(_current_entity,_current_container);
			abort();
		}
		if (action->component_to_add->_id == ActionContainer::COMPONENT_ID)
		{
			CV3Log ("you may not add action containers components with the AddComponentAction!\n");
			_entityManager->dumpEntity(_current_entity);
			_entityManager->dumpComponent(_current_entity,_current_container);
			abort();
		}
#endif

		if (action->finished)
		{
			_entityManager->addComponent(_current_entity, action->component_to_add);
		}
		
	}
	
	void ActionSystem::handle_create_entity_action (CreateEntityAction *action)
	{
		
		if (action->finished)
		{
			std::vector<Component*>::const_iterator it = action->components_to_add.begin();	
			
			Entity *newEntity = _entityManager->createNewEntity();
			Component *c = NULL;
			while (it != action->components_to_add.end())
			{
				c = *it;
				++it;
				_entityManager->addComponent(newEntity, c);
			}
			
		}
		
	}
	
	
	void ActionSystem::handle_change_integer_to_action (ChangeIntegerToAction *action)
	{
		if (action->finished)
		{
			if (action->pIntToChange)
			{
				*action->pIntToChange = action->new_value;
			}
		
		}		
	}
	void ActionSystem::handle_change_integer_by_action (ChangeIntegerByAction *action)
	{
		if (action->finished)
		{
			if (action->pIntToChange)
			{
				*action->pIntToChange += action->amount;
			}
			
		}		
	}
	
	void ActionSystem::handle_change_float_to_action (ChangeFloatToAction *action)
	{
		if (action->finished)
		{
			if (action->pFloatToChange)
			{
				*action->pFloatToChange = action->new_value;
			}
			
		}
	}
	void ActionSystem::handle_change_float_by_action (ChangeFloatByAction *action)
	{
		if (action->finished)
		{
			if (action->pFloatToChange)
			{
				*action->pFloatToChange += action->amount;
			}
			
		}
	}
	
	
	bool ActionSystem::handle_game_action (Action *action)
	{
		
		return false;
	}
	
	void ActionSystem::handle_action_container ()
	{
		Action **actions = _current_container->actions;
		
		Action *current_action = NULL;
		for (int i = 0; i < NUM_OF_ACTIONS_PER_CONTAINER; i++)
		{
			current_action = actions[i];
			if (!current_action)
				continue;
			step_action(current_action);

			if (!handle_game_action(current_action))
			{
				switch (current_action->action_type) 
				{
					case ACTIONTYPE_MOVE_TO:
						handle_move_to_action((MoveToAction*)current_action);
						break;
					case ACTIONTYPE_MOVE_BY:
						handle_move_by_action((MoveByAction*)current_action);
						break;
					case ACTIONTYPE_SCALE_BY:
						handle_scale_by_action((ScaleByAction*)current_action);
						break;
					case ACTIONTYPE_FADE_TO:
						handle_fade_to_action((FadeToAction*)current_action);
						break;
						
					case ACTIONTYPE_ADD_COMPONENT:
						handle_add_component_action((AddComponentAction*)current_action);
						break;
					case ACTIONTYPE_CREATE_ENTITY:
						handle_create_entity_action((CreateEntityAction*)current_action);
						break;
						
					case ACTIONTYPE_CHANGE_INTEGER_TO:
						handle_change_integer_to_action((ChangeIntegerToAction*)current_action);
						break;
					case ACTIONTYPE_CHANGE_FLOAT_TO:
						handle_change_float_to_action((ChangeFloatToAction*)current_action);
						break;
					case ACTIONTYPE_CHANGE_INTEGER_BY:
						handle_change_integer_by_action((ChangeIntegerByAction*)current_action);
						break;
					case ACTIONTYPE_CHANGE_FLOAT_BY:
						handle_change_float_by_action((ChangeFloatByAction*)current_action);
						break;
						
						
					case ACTIONTYPE_NONE:
					default:
						//handle_default_action(current_action);
						break;
				}
				
			}

			//let's see what to do after the action is finished
			if (current_action->finished)
			{
				Action *on_complete_action = current_action->on_complete_action;
				
				//run another action
				if (on_complete_action)
				{
					delete current_action;
					current_action = NULL;
					_current_container->actions[i] = on_complete_action;
				}
				else //do nothing
				{
					delete current_action;
					current_action = NULL;
					_current_container->actions[i] = NULL;
				}
					
			}
			
		}
	}
	
	
	
	void ActionSystem::update (float delta)
	{
		__delta = delta;
		_entities.clear();
		_entityManager->getEntitiesPossessingComponent (_entities, ActionContainer::COMPONENT_ID);
		
		std::vector <Entity *>::const_iterator it = _entities.begin();
		
	//	Entity *current_entity = NULL;
	//	ActionContainer *current_container = NULL;
		
		
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			
			_current_container = _entityManager->getComponent <ActionContainer> (_current_entity);
			_current_position = _entityManager->getComponent <Position> (_current_entity);
			_current_renderable = _entityManager->getComponent <Renderable> (_current_entity);
#ifdef __ABORT_GUARDS__
			if (!_current_container)
				abort();
#endif
			
			handle_action_container();
		}
		
		//1. get entities with action containers
		//2. run actions in the container on the entity
		//3. if a action expires, check if it has a next_action. if so, make it the active action and kill the expired action

	}
}