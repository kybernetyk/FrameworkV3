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
#define MAX_RESOURCES 512
		
	class TexturedQuad;
	class TexturedAtlasQuad;
	class OGLFont;
	class TexturedBufferQuad;
	class IRenderable;
	class PE_Proxy;

	typedef int ResourceHandle;
	
	class RenderableManager
	{
	public:
		RenderableManager();
		/*TexturedQuad *accquireTexturedQuad (std::string filename);
		TexturedAtlasQuad *accquireTexturedAtlasQuad (std::string filename);
		TexturedBufferQuad *accquireBufferedTexturedQuad (std::string filename);*/
		
		template <typename T> ResourceHandle acquireResource (std::string filename)
		{
			if (_referenceCounts[filename] > 0)
			{
				_referenceCounts[filename] ++;
				ResourceHandle ret =  _handlesByFilename [filename];
				if (ret == 0)
				{
					CV3Log ("handle may not be 0!\n");
					abort();
					return 0;
				}
				return ret;
			}
			
			ResourceHandle current_handle = getNextAvailableHandle();
			
			T *res = new T(filename);
			_resourcesByHandle[current_handle] = res;
			_referenceCounts[filename] = 1;
			_handlesByFilename[filename] = current_handle;
			_filenamesByHandle[current_handle] = filename;
			return current_handle;
			
		}
		
		template <typename T> T *getResource (ResourceHandle *handle)
		{
			if (_resourcesByHandle[*handle])
				return (T *)_resourcesByHandle[*handle];

			CV3Log ("handle %i not found and not loaded before ...\n", *handle);
			abort();
			return NULL;
		}
		
		
		void release (ResourceHandle *handle)
		{
			std::string fn = _filenamesByHandle [*handle];
			if (fn.length() <= 0)
			{
				CV3Log ("handle %i not found and not loaded before ...\n", *handle);
				
				abort();
				return;
			}
			
			
			_referenceCounts[fn] --;
			
			if (_referenceCounts[fn] <= 0)
			{
				_referenceCounts[fn] = 0;
				_filenamesByHandle[*handle] = "";
				_handlesByFilename[fn] = 0;
				
				
				IRenderable *p = _resourcesByHandle[*handle];
				if (!p)
				{
					CV3Log ("trying to delete NULL resource! handle: %i\n", *handle);
					abort ();
					return;
				}
				delete p;
				_resourcesByHandle[*handle] = NULL;
			}
			*handle = 0;
			
		}

		
		
		PE_Proxy *accquireParticleEmmiter (std::string filename);
		

	protected:
		ResourceHandle getNextAvailableHandle ();
		
		std::tr1::unordered_map <std::string, int> _referenceCounts;
		std::tr1::unordered_map <std::string, ResourceHandle> _handlesByFilename;
		std::tr1::unordered_map <ResourceHandle, std::string> _filenamesByHandle;

		
		
		IRenderable *_resourcesByHandle[MAX_RESOURCES];
	};

}

extern mx3::RenderableManager g_RenderableManager;
