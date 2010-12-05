/*
 *  TextureManager.h
 *  ComponentV3
 *
 *  Created by jrk on 16/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
#pragma once

#include <tr1/unordered_map>
#include "Texture2D.h"
namespace mx3 
{
	class TextureManager
	{
	public:
		Texture2D *accquireTexture (std::string filename);	//increased retaincount by 1

		Texture2D *getTexture (std::string &filename);	//doesn't change retaincount
		
		void releaseTexture (std::string &filename);	//decreases retcount by 1. releases tex on retcount 0
		
		void purgeCache ();
		
	protected:
		std::tr1::unordered_map <std::string, int> _referenceCounts;
		std::tr1::unordered_map <std::string, Texture2D *> _textures;
	};

}

extern mx3::TextureManager g_TextureManager;
