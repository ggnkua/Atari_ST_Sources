#include <Config.h>
#include "FrameBuffer.h"
#include "FrameBuffer_WinSDL.h"
#include <assert.h>

namespace DemoSys
{

ScreenModeDefinition FrameBufferImplementationWinSDL::ms_screenModeDefs[] =
{
	{320,200,8, 
		960,900,3},			// kbufsize_320x200_8 = 0,
	{320,200,16,		
		964+64,600+200,3,
		200,32},	
	{320,200,32,		
		1024,768+100,3},	

	{384,200,8,			
		1024,768,2},	
	{384,200,16,		
		1024,768,2},	
	{384,200,32,		
		1024,768,2},	

	{640,400,8,			
		1024,768,1},	
	{640,400,16,		
		1024,768,1},	
	{640,400,32,		
		1024,768,1},	

	{768,400,8,			
		1024,768,1},	
	{768,400,16,		
		1024,768,1},	
	{768,400,32,		
		1024,768,1},	

};

SDL_Surface	*FrameBufferImplementationWinSDL::ms_backBuffer = NULL;
SDL_Surface	*FrameBufferImplementationWinSDL::ms_frontBuffer = NULL;

u32	FrameBufferImplementationWinSDL::ms_oldTick = 0;
FrameBufferInterface::FrameBufferMode FrameBufferImplementationWinSDL::ms_mode;

void FrameBufferImplementationWinSDL::initFrameBuffer( FrameBufferInterface::FrameBufferMode mode)
{
	ms_frontBuffer = SDL_SetVideoMode(ms_screenModeDefs[mode].real_width, ms_screenModeDefs[mode].real_height, ms_screenModeDefs[mode].depth, SDL_DOUBLEBUF /*| SDL_FULLSCREEN*/ );
	assert(ms_frontBuffer != NULL);
	SDL_WM_SetCaption( "DemoSys", NULL );
	ms_backBuffer = SDL_CreateRGBSurface(0,ms_screenModeDefs[mode].width, ms_screenModeDefs[mode].height, ms_screenModeDefs[mode].depth,0,0,0,0 );
	assert(ms_backBuffer != NULL);

	ms_mode = mode;
	ms_oldTick = SDL_GetTicks();
}

void FrameBufferImplementationWinSDL::shutdownFrameBuffer()
{

}

void FrameBufferImplementationWinSDL::changeMode(FrameBufferInterface::FrameBufferMode mode)
{

}

void FrameBufferImplementationWinSDL::setPalette(u32* p_palette)
{

}

void FrameBufferImplementationWinSDL::getPalette(u32* p_palette,u32 first, u32 last)
{

}

void* FrameBufferImplementationWinSDL::getBackBuffer()
{
	return ms_backBuffer->pixels;
}

template <class T> void blitScale(SDL_Surface* src, SDL_Surface* dst,u32 scale)
{
	register u32 outerSizeWidth = dst->w;
	register u32 outerSizeHeigth = dst->h;

	register u32 innerSizeWidth = src->w<<8;
	register u32 innerSizeHeigth = src->h<<8;

	register u32 x = 0;
	register u32 y = 0;

	assert (dst->format->BitsPerPixel == src->format->BitsPerPixel);

	T*	dest_ptr = (T*)dst->pixels + ( (outerSizeWidth/2 - (src->w*(256/scale)) /2))+32*outerSizeWidth; //+ (outerSizeHeigth/2 - (src->h*(256/scale))/2)*outerSizeWidth ) ;
	T*	src_ptr = (T*)src->pixels;

	register u32 delta = scale;		// 1/scale

	for (u32 h = 0; h < outerSizeHeigth; h++ )
	{
		x = 0;

		for (u32 w = 0; w < outerSizeWidth; w++ )
		{
			if ( x <= innerSizeWidth)
				*dest_ptr = src_ptr [ (x >> 8) + (y >> 8) * src->w ];
			dest_ptr++;
			x += delta;
		}
		y += delta;

		if ( y >= innerSizeHeigth )
			break;
	}

}

void FrameBufferImplementationWinSDL::postProcessBuffers()
{
	blitScale<u16>(ms_backBuffer,ms_frontBuffer,256/(u32)ms_screenModeDefs[ms_mode].pixel_ratio );
}

void FrameBufferImplementationWinSDL::flipBuffers()
{
	SDL_Flip( ms_frontBuffer ); 

	// cap framerate
	int t = SDL_GetTicks();
	s32 delay = (1000/FRAMES_PER_SECOND) - (t - ms_oldTick);

	if ( delay > 0 )
	{
		SDL_Delay( delay );
	}
	ms_oldTick = t;
}

}