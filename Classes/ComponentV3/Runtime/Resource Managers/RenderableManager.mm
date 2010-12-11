/*
 *  RenderableManager.cpp
 *  ComponentV3
 *
 *  Created by jrk on 16/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "RenderableManager.h"
#include "TexturedQuad.h"
namespace mx3 
{
	RenderableManager::RenderableManager ()
	{
		memset(_resourcesByHandle, 0x00, MAX_RESOURCES * sizeof(IRenderable *));
	}
	
	
	ResourceHandle RenderableManager::getFreeHandle() 
	{
		for (ResourceHandle i = 1; i < MAX_RESOURCES; i++)
			if (_resourcesByHandle[i] == 0)
				return i;
		
		CV3Log ("** RenderableManager error:\n\t[!] NO RESOURCE SLOTS FREE! MAX_RESOURCES: %i\n", MAX_RESOURCES);
		abort();
		return -1; //oh oh we fucked up
	}
	
	
	
//	ResourceHandle RenderableManager::acquireTexturedQuad (std::string filename)
//	{
//		ResourceHandle current_handle = getNextAvailableHandle();
//
//		TexturedQuad *t = new TexturedQuad(filename);
//		_renderables[filename] = t;
//		_resourcesByHandle[current_handle] = t;
//		
//		_filenames[current_handle] = filename;
//		_referenceCounts[filename] = 1;
//		return current_handle;
//	}
//	
//	TexturedQuad *RenderableManager::getTexturedQuad (ResourceHandle *handle)
//	{
//		if (_resourcesByHandle[*handle])
//			return _resourcesByHandle[*handle];
//		
//		CV3Log ("handle %i not found and not loaded before ...\n", *handle);
//		abort();
//		return NULL;
//	}
//
//	ResourceHandle RenderableManager::acquireTexturedAtlasQuad (std::string filename)
//	{
//		ResourceHandle current_handle = getNextAvailableHandle();
//		
//		TexturedAtlasQuad *t = new TexturedAtlasQuad(filename);
//		_renderables[filename] = t;
//		_resourcesByHandle[current_handle] = t;
//		
//		_filenames[current_handle] = filename;
//		_referenceCounts[current_handle] = 1;
//		return current_handle;
//	}
//	
//	
//	TexturedAtlasQuad *RenderableManager::getTexturedAtlasQuad (ResourceHandle *handle)
//	{
//		if (_referenceCounts[*handle] > 0)
//		{
//			_referenceCounts[*handle] ++;
//			return (TexturedAtlasQuad*)_resourcesByHandle[*handle];
//		}
//		
//		std::string fn = _filenames[*handle];
//		if (fn.length() <= 0)
//		{
//			CV3Log ("handle %i not found and not loaded before ...\n", *handle);
//			
//			abort();
//			return NULL;
//		}
//		
//		ResourceHandle h = acquireTexturedAtlasQuad (fn);
//		return (TexturedAtlasQuad*)_resourcesByHandle[h];
//	}
//
//	ResourceHandle RenderableManager::acquireBufferedQuad (std::string filename)
//	{
//		ResourceHandle current_handle = getNextAvailableHandle();
//		
//		TexturedBufferQuad *t = new TexturedBufferQuad(filename);
//		_renderables[filename] = t;
//		_resourcesByHandle[current_handle] = t;
//		
//		_filenames[current_handle] = filename;
//		_referenceCounts[current_handle] = 1;
//		return current_handle;
//	}
//	
//	TexturedBufferQuad *RenderableManager::getBufferedQuad (ResourceHandle *handle)
//	{
//		if (_referenceCounts[*handle] > 0)
//		{
//			_referenceCounts[*handle] ++;
//			return (TexturedBufferQuad*)_resourcesByHandle[*handle];
//		}
//		
//		std::string fn = _filenames[*handle];
//		if (fn.length() <= 0)
//		{
//			CV3Log ("handle %i not found and not loaded before ...\n", *handle);
//			
//			abort();
//			return NULL;
//		}
//		
//		ResourceHandle h = acquireBufferedQuad (fn);
//		return (TexturedBufferQuad*)_resourcesByHandle[h];
//	}
//	
//	
//	ResourceHandle RenderableManager::acquireOGLFont (std::string filename)
//	{
//		ResourceHandle current_handle = getNextAvailableHandle();
//		
//		OGLFont *t = new OGLFont(filename);
//		_renderables[filename] = t;
//		_resourcesByHandle[current_handle] = t;
//		
//		_filenames[current_handle] = filename;
//		_referenceCounts[current_handle] = 1;
//		return current_handle;
//	}
//	
//	OGLFont *RenderableManager::getOGLFont (ResourceHandle *handle)
//	{
//		if (_referenceCounts[*handle] > 0)
//		{
//			_referenceCounts[*handle] ++;
//			return (OGLFont*)_resourcesByHandle[*handle];
//		}
//		
//		std::string fn = _filenames[*handle];
//		if (fn.length() <= 0)
//		{
//			CV3Log ("handle %i not found and not loaded before ...\n", *handle);
//			
//			abort();
//			return NULL;
//		}
//		
//		ResourceHandle h = acquireOGLFont (fn);
//		return (OGLFont*)_resourcesByHandle[h];
//	}
//	
//	void RenderableManager::release (ResourceHandle *handle)
//	{
//		
//		
//		std::string fn = _filenames[*handle];
//		if (fn.length() <= 0)
//		{
//			CV3Log ("handle %i not found and not loaded before ...\n", *handle);
//			
//			abort();
//			return;
//		}
//		
//		
//		_referenceCounts[*handle] --;
//		
//		if (_referenceCounts[*handle] <= 0)
//		{
//			std::string fn = _filenames[*handle];
//			_renderables[fn] = NULL;
//			_referenceCounts[*handle] = 0;
//			_filenames[*handle] = "";
//			
//			IRenderable *p = _resourcesByHandle[*handle];
//			if (!p)
//			{
//				CV3Log ("trying to delete NULL resource! handle: %i\n", *handle);
//				abort ();
//				return;
//			}
//			delete p;
//			_resourcesByHandle[*handle] = NULL;
//		}
//		*handle = 0;
//	}
//		
	PE_Proxy *RenderableManager::accquireParticleEmmiter (std::string filename)
	{
		PE_Proxy *ret = new PE_Proxy(filename);
		
		ret->stop();
		ret->reset();

		return ret;
	}
}

mx3::RenderableManager g_RenderableManager;
