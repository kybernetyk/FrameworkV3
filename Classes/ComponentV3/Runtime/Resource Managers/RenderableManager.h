/*
 *  RenderableManager.h
 *  ComponentV3
 *
 *  Created by jrk on 16/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once

#include <tr1/unordered_map>
namespace mx3 
{
	
		
	class TexturedQuad;
	class TexturedAtlasQuad;
	class OGLFont;
	class TexturedBufferQuad;
	class IRenderable;
	class PE_Proxy;


	class RenderableManager
	{
	public:
		TexturedQuad *accquireTexturedQuad (std::string filename);
		TexturedAtlasQuad *accquireTexturedAtlasQuad (std::string filename);
		TexturedBufferQuad *accquireBufferedTexturedQuad (std::string filename);

		PE_Proxy *accquireParticleEmmiter (std::string filename);

		OGLFont *accquireOGLFont (std::string filename);
		
		void release (IRenderable *pRenderable);
		
	protected:
		std::tr1::unordered_map <std::string, int> _referenceCounts;
		std::tr1::unordered_map <std::string, IRenderable *> _renderables;
	};

}

extern mx3::RenderableManager g_RenderableManager;
