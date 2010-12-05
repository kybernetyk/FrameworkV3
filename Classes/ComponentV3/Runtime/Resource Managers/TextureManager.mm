/*
 *  TextureManager.cpp
 *  ComponentV3
 *
 *  Created by jrk on 16/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "TextureManager.h"
namespace mx3 
{
	Texture2D *TextureManager::accquireTexture (std::string filename)
	{
		if (_referenceCounts[filename] > 0)
		{
			_referenceCounts[filename] ++;
			return _textures[filename];
		}

		Texture2D *ret = new Texture2D(filename);
		if (!ret)
			return NULL;

		_textures[filename] = ret;
		_referenceCounts[filename] = 1;
		return ret;
	}
	
	Texture2D *TextureManager::getTexture (std::string &filename)
	{
		if (_referenceCounts[filename] > 0)
			return _textures[filename];

		return accquireTexture (filename);
	}

	void TextureManager::releaseTexture (std::string &filename)
	{
//		if (!pTexture)
//			return;
//Texture2D *pTexture = _textures[filename];
//		if (!pTexture)
//			return;
		
		//std::string filename = pTexture->_filename;
		_referenceCounts[filename] --;
		if (_referenceCounts[filename] <= 0)
		{
			Texture2D *p = _textures[filename];
			_textures[filename] = NULL;
			delete p;
			_referenceCounts[filename] = 0;
		}
	}

	void TextureManager::purgeCache ()
	{
		std::tr1::unordered_map <std::string, Texture2D *>::iterator it = _textures.begin();
		
		while (it != _textures.end()) 
		{
			Texture2D *p = it->second;
			delete p;
			++it;
		}
		
		_textures.clear();
		_referenceCounts.clear();
	}
}

mx3::TextureManager g_TextureManager;
