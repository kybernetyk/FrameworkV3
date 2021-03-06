/*
 *  TexturedQuad.cpp
 *  SpaceHike
 *
 *  Created by jrk on 6/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "TexturedQuad.h"
#include "ogl.h"
#include "RenderDevice.h"
#include "Texture2D.h"
#import "SOIL.h"
#include <math.h>

extern "C"
{	
	#include "bm_font.h"
};

namespace mx3 
{
	
		
	unsigned int IRenderable::LAST_GUID = 0;
	#pragma mark -
	#pragma mark textured quad
	TexturedQuad::TexturedQuad ()
	{
		init();
	}

//	TexturedQuad::TexturedQuad(Texture2D *existing_texture)
//	{
//		IRenderable::IRenderable();
//		init();
//
//		//texture = existing_texture;
//		_filename = existing_texture->_filename;
//		w = existing_texture->w;
//		h = existing_texture->h;
//	}


	TexturedQuad::TexturedQuad(std::string filename)
	{
		init();
		_filename = filename;
		loadFromFile(filename);
	}

	TexturedQuad::~TexturedQuad ()
	{
		g_TextureManager.releaseTexture (_filename);
//		if (texture)
//		{
//			g_TextureManager.releaseTexture(texture);
//			texture = NULL;
//		}
	}

	bool TexturedQuad::loadFromFile (std::string filename)
	{
		Texture2D *texture = g_TextureManager.accquireTexture (filename);
		if (!texture)
			abort();
		
		//texture->setAliasTexParams();
		_filename = filename;
		w = texture->w;
		h = texture->h;
		
//		printf("w: %f, h: %f\n",w,h);
		return true;
	}


	void TexturedQuad::transform ()
	{
		glTranslatef(x, y, z);
		
		if (rotation != 0.0f )
			glRotatef( -rotation, 0.0f, 0.0f, 1.0f );
		
		if (scale_x != 1.0 || scale_y != 1.0)
			glScalef( scale_x, scale_y, 1.0f );
		
		glTranslatef(- (anchorPoint.x * w), - (anchorPoint.y * h), 0);
	}

	void TexturedQuad::renderContent ()
	{
		Texture2D *texture = g_TextureManager.getTexture(_filename);
		if (texture)
		{	
			//glLoadIdentity();
			glPushMatrix();
			transform();
			
			
			GLfloat		coordinates[] = { 0.0f,	1.0,
				1.0,	1.0,
				0.0f,	0.0f,
				1.0,	0.0f };
			GLfloat		vertices[] = 
			{	
				0,			0,			0,
				w,	0,			0,
				0,			h,	0,
				w,			h,	0
			};
			
			GLfloat colors[] = 
			{
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
			};
			glColorPointer(4, GL_FLOAT, 0, colors);

			texture->makeActive();
			//glColor4f(1.0, 1.0,1.0, alpha);
			
			glVertexPointer(3, GL_FLOAT, 0, vertices);
			glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			glPopMatrix();
		}
		
	}

#pragma mark -
#pragma mark BUFFERED QUAD
	TexturedBufferQuad::TexturedBufferQuad ()
	{
		init();
	}
	
	
	
	TexturedBufferQuad::TexturedBufferQuad(std::string filename)
	{
		IRenderable::IRenderable();
		init();
		_filename = filename;
		loadFromFile(filename);
	}
	
	TexturedBufferQuad::~TexturedBufferQuad ()
	{
		if (texture)
		{
			//g_TextureManager.releaseTexture(texture);
			delete texture;
			texture = NULL;
		}
		if (alpha_mask)
		{
			delete [] alpha_mask;
			alpha_mask = NULL;
		}
	}
	
	bool TexturedBufferQuad::loadFromFile (std::string filename)
	{
		texture = new BufferTexture2D(filename);
		if (!texture)
			abort();
		
		//texture->setAliasTexParams();
		_filename = filename;
		w = texture->w;
		h = texture->h;
		create_alpha_mask();
		
		return true;
	}
	
	void TexturedBufferQuad::create_alpha_mask ()
	{
		if (alpha_mask)
			abort();
		
		size_t size = w * h;
		alpha_mask = new unsigned char[size];
		memset(alpha_mask,0x00, size);
		
		unsigned char *buf = texture->buffer;
		
		for (int i = 0, j = 0; i < w*h; i++, j+=4)
		{
			//buf[j+3] = (255&alpha_mask[i]);
			alpha_mask[i] = buf[j+3];
		}
		
	}
#define ROUND(x) (((x)>0) ? long((x)+.5) : long((x)-.5))
#define SQR(x)   ((x)*(x))
#if !defined(MIN)
#define MIN(A,B)	((A) < (B) ? (A) : (B))
#endif
	
#if !defined(MAX)
#define MAX(A,B)	((A) > (B) ? (A) : (B))
#endif
	
	void TexturedBufferQuad::line(unsigned char *buf,int buf_w, unsigned char val, int x1, int y1, int x2, int y2)
	{
//		x1 = MIN(x1,w);
//		x2 = MIN(x2,w);
		
		if (x1 < 0)
			x1 = 0;
		if (x1 >= w)
			x1 = w-1;
		if (y1 < 0)
			y1 = 0;
		if (y1 >= h)
			y1 = h-1;
		if (x2 < 0)
			x2 = 0;
		if (x2 >= w)
			x2 = w-1;
		if (y2 < 0)
			y2 = 0;
		if (y2 >= h)
			y2 = h-1;
		
		
		const int dx = abs(x1 - x2);
		const int dy = abs(y1 - y2);
		int const1, const2, p, x, y, step;
		if (dx >= dy)
		{
			const1 = 2 * dy;
			const2 = 2 * (dy - dx);
			p = 2 * dy - dx;
			x = MIN(x1,x2);
			y = (x1 < x2) ? (y1) : (y2);
			step = (y1 > y2) ? (1) : (-1);
			//putpixel(x, y, getcolor());
			buf [x + (y * buf_w)] = val;
			while (x < MAX(x1,x2))
			{
				if (p < 0)
					p += const1;
				else
				{
					y += step;
					p += const2;
				}
				//putpixel(++x, y, getcolor());
				buf [(++x) + (y * buf_w)] = val;
			}
		}
		else
		{
			const1 = 2 * dx;
			const2 = 2 * (dx - dy);
			p = 2 * dx - dy;
			y = MIN(y1,y2);
			x = (y1 < y2) ? (x1) : (x2);
			step = (x1 > x2) ? (1) : (-1);
			//			putpixel(x, y, getcolor());
			buf [x + (y * buf_w)] = val;
			while (y < MAX(y1,y2))
			{
				if (p < 0)
					p += const1;
				else
				{
					x += step;
					p += const2;
				}
				//putpixel(x, ++y, getcolor());
				
				buf [(x) + (++y * buf_w)] = val;
			}
		}
	}
	
	void TexturedBufferQuad::circle_fill(unsigned char *buff, int buff_w, unsigned char val, int xc, int yc, int r)
	{
		int x1, x2;
		for (int y=yc-r; y<=yc+r; ++y)
		{
			x1 = ROUND(xc + sqrt(SQR(r) - SQR(y - yc)));
			x2 = ROUND(xc - sqrt(SQR(r) - SQR(y - yc)));
			line(buff, buff_w, val, x1, y, x2, y);
		}
	}
	
	void TexturedBufferQuad::circle(unsigned char *buf, int buf_w, int xc, int yc, int r)
	{
		int x =0;
		int y = r;
		int p = 3 - 2 * r;
		
		while (x <= y)
		{
			buf [(xc + x) + (yc + y) * buf_w] = 0x00;
			buf [(xc - x) + (yc + y) * buf_w] = 0x00;				
			buf [(xc + x) + (yc - y) * buf_w] = 0x00;
			buf [(xc - x) + (yc - y) * buf_w] = 0x00;
			
			buf [(xc + y) + (yc + x) * buf_w] = 0x00;
			buf [(xc - y) + (yc + x) * buf_w] = 0x00;
			buf [(xc + y) + (yc - x) * buf_w] = 0x00;
			buf [(xc - y) + (yc - x) * buf_w] = 0x00;
			
			if (p < 0)
			{
				p += 4 * x++ + 6;
			}
			else 
			{
				p += 4 * (x++ - y--) + 10;
			}
		}
	}
	
	
	
	void TexturedBufferQuad::alpha_draw_circle_fill (int xc, int yc, int r, unsigned char val)
	{
		circle_fill (alpha_mask, w, val, xc, yc, r);
	}
	
	void TexturedBufferQuad::apply_alpha_mask ()
	{
		if (!alpha_mask)
			abort();
		
		unsigned char *buf = texture->buffer;
		
		for (int i = 0, j = 0; i < w*h; i++, j+=4)
		{
			buf[j+3] = (alpha_mask[i]);
		}
		
		texture->updateTextureWithBufferData();
	}

	void TexturedBufferQuad::transform ()
	{
		glTranslatef(x, y, z);
		
		if (rotation != 0.0f )
			glRotatef( -rotation, 0.0f, 0.0f, 1.0f );
		
		if (scale_x != 1.0 || scale_y != 1.0)
			glScalef( scale_x, scale_y, 1.0f );
		
		glTranslatef(- (anchorPoint.x * w), - (anchorPoint.y * h), 0);
	}
	
	void TexturedBufferQuad::renderContent ()
	{
		if (texture)
		{	
			//glLoadIdentity();
			glPushMatrix();
			transform();
			
			
			GLfloat		coordinates[] = { 0.0f,	1.0,
				1.0,	1.0,
				0.0f,	0.0f,
				1.0,	0.0f };
			GLfloat		vertices[] = 
			{	
				0,			0,			0,
				w,	0,			0,
				0,			h,	0,
				w,			h,	0
			};
			
			//		glEnableClientState( GL_VERTEX_ARRAY);
			//		glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			
			//		glEnable( GL_TEXTURE_2D);
			//			texture->makeActive();
			GLfloat colors[] = 
			{
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
			};
			glColorPointer(4, GL_FLOAT, 0, colors);
			
			texture->makeActive();
		//	glColor4f(1.0, 1.0,1.0, alpha);
			glVertexPointer(3, GL_FLOAT, 0, vertices);
			glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
			glPopMatrix();
		}
		
	}
	
	

	#pragma mark -
	#pragma mark atlas quad
	TexturedAtlasQuad::TexturedAtlasQuad ()
	{
		init();
	}

//	TexturedAtlasQuad::TexturedAtlasQuad(Texture2D *existing_texture)
//	{
//		IRenderable::IRenderable();
//		init();
//		
//		//texture = existing_texture;
//		_filename = existing_texture->_filename;
//		
//		tex_w = existing_texture->w;
//		tex_h = existing_texture->h;
//
//	}


	TexturedAtlasQuad::TexturedAtlasQuad(std::string filename)
	{
		init();
		_filename = filename;
		loadFromFile(filename);
		
	//	tex_w = texture->w;
	//	tex_h = texture->h;

	}

	TexturedAtlasQuad::~TexturedAtlasQuad ()
	{
		g_TextureManager.releaseTexture (_filename);
//		
//		if (texture)
//		{
//			g_TextureManager.releaseTexture(texture);
//			texture = NULL;
//		}
	}

	bool TexturedAtlasQuad::loadFromFile (std::string filename)
	{
		Texture2D *texture = g_TextureManager.accquireTexture (filename);
		if (!texture)
			abort();
		
		//texture->setAliasTexParams();
		_filename = filename;
		tex_w = texture->w;
		tex_h = texture->h;

		
		return true;
	}

	void TexturedAtlasQuad::transform ()
	{
		glTranslatef(x, y, z);
		
		if (rotation != 0.0f )
			glRotatef( -rotation, 0.0f, 0.0f, 1.0f );
		
		if (scale_x != 1.0 || scale_y != 1.0)
			glScalef( scale_x, scale_y, 1.0f );
		
		glTranslatef(- (anchorPoint.x * w), - (anchorPoint.y * h), 0);
	}


	void TexturedAtlasQuad::renderContent ()
	{
		
		Texture2D *texture = g_TextureManager.getTexture(_filename);
		if (texture)
		{	
			//glLoadIdentity();
			glPushMatrix();
			w = src.w;
			h = src.h;
			
			transform();
			rect atlasInfo;
			atlasInfo.x = src.x / texture->w;
			atlasInfo.y = src.y / texture->h;
			
			atlasInfo.w = src.w / texture->w;
			atlasInfo.h = src.h / texture->h;
			
			
			
			GLfloat		coordinates[] = { atlasInfo.x,	atlasInfo.y + atlasInfo.h,
				atlasInfo.x + atlasInfo.w,	atlasInfo.y + atlasInfo.h,
				atlasInfo.x,	atlasInfo.y,
				atlasInfo.x + atlasInfo.w,	atlasInfo.y };
			
			
			GLfloat		vertices[] = 
			{	
				0,			0,			0,
				w,	0,			0,
				0,			h,	0,
				w,			h,	0
			};
			
	//		glEnableClientState( GL_VERTEX_ARRAY);
	//		glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			GLfloat colors[] = 
			{
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
			};
			glColorPointer(4, GL_FLOAT, 0, colors);
			
	//		glEnable( GL_TEXTURE_2D);
			texture->makeActive();
			//glColor4f(1.0, 1.0,1.0, alpha);
			glVertexPointer(3, GL_FLOAT, 0, vertices);
			glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
			glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
			
	//		glDisable( GL_TEXTURE_2D);
	//		glDisableClientState(GL_VERTEX_ARRAY );
	//		glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			glPopMatrix();
		}
		
	}

	extern std::string pathForFile2 (const char *filename);

	OGLFont::OGLFont (std::string fnt_filename)
	{
		init();
		
		loadFromFNTFile (fnt_filename);
	}
	
	OGLFont::~OGLFont ()
	{
		//			if (texture)
		//			{
		//				g_TextureManager.releaseTexture(texture);
		//				texture = NULL;
		//			}
		g_TextureManager.releaseTexture (_tex_filename);
	}
	void OGLFont::init()
	{
		IRenderable::init();
		text = NULL;
		//texture = NULL;
	}
	
	bool OGLFont::loadFromFNTFile (std::string fnt_filename)
	{
		const char *fn = pathForFile2 (fnt_filename.c_str()).c_str();;
		
		if (!bm_loadfont(fn, &font))
		{
			abort();
		}
		
		
		Texture2D *texture = g_TextureManager.accquireTexture (font.tex_filename);
		if (!texture)
			abort();
		_tex_filename = font.tex_filename;
		//texture->setAliasTexParams();
		_filename = fnt_filename;
		return true;
	}

	void OGLFont::transform ()
	{
		int w = bm_width(&font, text);
		float h = font.line_h*.75; //bm_height(&font, text);
		glTranslatef(x, y, z);
		
		if (rotation != 0.0f )
			glRotatef( -rotation, 0.0f, 0.0f, 1.0f );

		if (scale_x != 1.0 || scale_y != 1.0)
			glScalef( scale_x, scale_y, 1.0f );
		
		glTranslatef(- (anchorPoint.x * w),h - (anchorPoint.y * h), 0);
	}


	void OGLFont::renderContent()
	{
		
		Texture2D *texture = g_TextureManager.getTexture(_tex_filename);
		if (texture)
		{	
			//glLoadIdentity();
			glPushMatrix();
			transform();

			int l = strlen(text);
			
			
	//		glEnableClientState( GL_VERTEX_ARRAY);
	//		glEnableClientState( GL_TEXTURE_COORD_ARRAY );
			
	//		glEnable( GL_TEXTURE_2D);
			texture->makeActive();
		//	glColor4f(1.0, 1.0,1.0, alpha);
			GLfloat colors[] = 
			{
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
				1.0,1.0,1.0,alpha,
			};
			glColorPointer(4, GL_FLOAT, 0, colors);
			
			//IF RENDER ERRORS OCCUR
			//EXCHANGE FLOAT FOR DOUBLE!
			float tx,ty,tw,th;
			
			
			bm_char *pchar = NULL;
			for (int i = 0; i < l; i++)
			{
				pchar = &font.chars[ text[i] ];
				
				tx = (float)pchar->x / (float)texture->w;
				ty = (float)pchar->y / (float)texture->h;
				tw = (float)pchar->w / (float)texture->w;
				th = (float)pchar->h / (float)texture->h;
				GLfloat		vertices[] = 
				{	
					0,			0,			0,
					pchar->w,	0,			0,
					0,			pchar->h,	0,
					pchar->w,	pchar->h,	0
				};
				
				GLfloat		coordinates[] = { tx,	ty + th,
					tx + tw,	ty + th,
					tx,	ty,
					tx + tw,	ty };

				glTranslatef(0, -pchar->h, 0.0);
				glTranslatef(pchar->x_offset, -pchar->y_offset, 0.0);			

				glVertexPointer(3, GL_FLOAT, 0, vertices);
				glTexCoordPointer(2, GL_FLOAT, 0, coordinates);
				glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

				glTranslatef(-pchar->x_offset, pchar->y_offset, 0.0);			
				glTranslatef(0, pchar->h, 0.0);

				
				glTranslatef(pchar->x_advance-pchar->x_offset, 0, 0.0);			
			}
			
	//		glDisable( GL_TEXTURE_2D);
	//		glDisableClientState(GL_VERTEX_ARRAY );
	//		glDisableClientState( GL_TEXTURE_COORD_ARRAY );
			
			
			glPopMatrix();
		}
	}


}