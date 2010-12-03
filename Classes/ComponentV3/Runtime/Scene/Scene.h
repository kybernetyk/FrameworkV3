/*
 *  Scene.h
 *  Fruitmunch
 *
 *  Created by jrk on 3/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once

namespace mx3 
{
	class Scene
	{
	public:
		virtual void preload () = 0;
		virtual void init () = 0;
		virtual void end () = 0;
		
		virtual void update (float delta) = 0;
		virtual void render () = 0;
		
		virtual void frameDone () = 0;
		
		virtual  ~Scene();
	};
}
		
