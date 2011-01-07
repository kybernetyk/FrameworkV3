/*
 *  TexturedQuad.h
 *  SpaceHike
 *
 *  Created by jrk on 6/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
#pragma once
#include <string>
#include "Util.h"
#include "TextureManager.h"
#import "ParticleEmitter.h"
extern "C"
{
	#include "bm_font.h"
};


namespace mx3 
{

		
//	class Texture2D;

	class IRenderable
	{
	public:
		
		static unsigned int LAST_GUID;
		
		IRenderable()
		{
			_guid = ++LAST_GUID;
			init();
		}
		
		std::string _filename;
		
		virtual void init()
		{
			anchorPoint = vector2D_make(0.5, 0.5);
			x = y = z = 0.0;
			scale_x = scale_y = 1.0;
			rotation = 0.0;
			alpha = 1.0;
			w = h = 0;
		}
		
		virtual ~IRenderable()
		{
		}
		
		virtual void renderContent() 
		{
			
		}
		
		float x;
		float y;
		float z;
		float w;
		float h;
		float alpha;
		float scale_x;
		float scale_y;
		float rotation;
		vector2D anchorPoint;

		unsigned int _guid;
	};

	class OGLFont : public IRenderable
	{
	public:
		OGLFont (std::string fnt_filename);
		~OGLFont ();
		void init();
		std::string _tex_filename;
		void transform ();
		void renderContent();
		
		bool loadFromFNTFile (std::string fnt_filename);

		char *text;
		bm_font font;
	//	Texture2D *texture;
	};
	
	class PE_Proxy : public IRenderable
	{
	public:
		#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
		ParticleEmitter *pe;
		#endif

		PE_Proxy ()
		{
			init();
		}

		PE_Proxy(std::string filename)
		{
			init();
			loadFromFile(filename);
			
			//CV3Log("###### Loading new PE: %s\n", filename.c_str());
		}
		
		void update (float delta)
		{
			#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			Vector2f pos;
			pos.x = x;
			pos.y = y;
			
			[pe setSourcePosition: pos];
			[pe updateWithDelta: delta];
			#endif
		}
		
		bool isActive ()
		{
			#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			return [pe active];
			#endif
		}
		
		bool shoudHandle ()
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			if (![pe active] && [pe particleCount] == 0)
				return false;
#endif
			return true;;
		}
		
		void stop ()
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000			
			[pe stopParticleEmitter];
#endif
		}
		
		void start ()
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			[pe startParticleEmitter];
#endif
		}
		
		void reset ()
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			[pe reset];
#endif
		}
		
		void renderContent ()
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			[pe renderParticles];
#endif
		}
		
		float getDuration ()
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			return [pe duration];
#endif
		}
		
		float setDuration (float dur)
		{
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			[pe setDuration: dur];
#endif
		}

		bool loadFromFile (std::string filename)
		{
			NSString *nsfilename = [NSString stringWithCString: filename.c_str() 
													  encoding: NSASCIIStringEncoding];
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000			
			pe = [[ParticleEmitter alloc] initParticleEmitterWithFile: nsfilename];
			if (pe)
				return true;
			
			return false;
#else
			return true;
#endif
		}
		
		bool do_not_delete;
		void init()
		{
			IRenderable::init();
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000			
			pe = nil;
#endif
			do_not_delete = false;
		}
		
		~PE_Proxy ()
		{
			CV3Log("############## O M G PE PROXY ############\n");
#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 30000
			if (pe)
			{
				//g_TextureManager.releaseTexture(texture);
				//texture = NULL;
				[pe release];
				pe = nil;
			}
#endif
		}
		
	};

	class TexturedQuad : public IRenderable
	{
	public:
		TexturedQuad();
		//TexturedQuad(Texture2D *existing_texture);
		TexturedQuad(std::string filename);
		~TexturedQuad ();

		void init()
		{
			IRenderable::init();
			
			//texture = NULL;
		}
		
		bool loadFromFile (std::string filename);
			
		void transform ();
		void renderContent();
		
		
//		Texture2D *texture;
	};

	class TexturedBufferQuad : public IRenderable
	{
	public:
		TexturedBufferQuad();
		TexturedBufferQuad(std::string filename);
		~TexturedBufferQuad ();
		
		void init()
		{
			IRenderable::init();
			
			texture = NULL;
			alpha_mask = NULL;
		}
		
		bool loadFromFile (std::string filename);
		
		void transform ();
		void renderContent();
		
		void create_alpha_mask ();
		void apply_alpha_mask ();
		
		BufferTexture2D *texture;
		
		unsigned char *alpha_mask;
		
		void alpha_draw_circle_fill (int xc, int yc, int r, unsigned char val);
		
	protected:
		void line(unsigned char *buf,int buf_w, unsigned char val, int x1, int y1, int x2, int y2);
		void circle_fill(unsigned char *buff, int buff_w, unsigned char val, int xc, int yc, int r);
		void circle(unsigned char *buf, int buf_w, int xc, int yc, int r);
		
	};
	
	class TexturedAtlasQuad : public IRenderable
	{
	public:
		TexturedAtlasQuad();
		//TexturedAtlasQuad(Texture2D *existing_texture);
		TexturedAtlasQuad(std::string filename);
		~TexturedAtlasQuad ();
		
		void init()
		{
			IRenderable::init();
			
			//texture = NULL;
			src.x = src.y = src.w = src.h = 0.0;
			tex_w = tex_h = 0;
		}
		
		bool loadFromFile (std::string filename);
		
		void transform ();
		
		int tex_w;
		int tex_h;
		
		rect src;
		void renderContent ();

		//Texture2D *texture;
	};


}