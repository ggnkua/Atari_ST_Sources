
//==========================================================================================
//		FrameBuffer base class
//==========================================================================================
#ifndef _DSYS_FRAMEBUFFER_WINSDL_
#define _DSYS_FRAMEBUFFER_WINSDL_

#include "FrameBuffer.h"
#include <sdl.h>

namespace DemoSys
{

// =========================================================================================
//	Frame buffer interface abstraction class

struct ScreenModeDefinition
{
	u16	width;			// render buffer dimensions
	u16	height;
	u16 depth;

	u16 real_width;		// window size
	u16 real_height;
	u16 pixel_ratio;

	u16 gui_reserved_height;
	u16 border_reserved;

};

class FrameBufferImplementationWinSDL
{
	static ScreenModeDefinition ms_screenModeDefs[];
	static SDL_Surface			*ms_backBuffer;
	static SDL_Surface			*ms_frontBuffer;
	static u32					ms_oldTick;
	static FrameBufferInterface::FrameBufferMode ms_mode;
public:
	static void					initFrameBuffer(FrameBufferInterface::FrameBufferMode mode);// Init FrameBuffer abstraction
	static void					shutdownFrameBuffer();										// kills FrameBuffer 
	
	static void					changeMode(FrameBufferInterface::FrameBufferMode mode);		// 	static void getBackBuffer();											
	static void					setPalette(u32* p_palette);									// get palette
	static void					getPalette(u32* p_palette,u32 first = -1,u32 last = -1);	// user supplied dest address, always 256

	static void*				getBackBuffer();											// Get buffer pointer
	static void					flipBuffers();												// Swaps the surface
	static void					postProcessBuffers();										// buffer postprocessing


	// -----------------------------------------
	// this is only gui stuff
	static inline SDL_Surface*	getSurface()		{	return ms_frontBuffer;									};
	static inline int			getWindowWidth()	{	return ms_screenModeDefs[ms_mode].real_width;			};
	static inline int			getWindowHeight()	{	return ms_screenModeDefs[ms_mode].real_height;			};
	static inline int			getGuiReserved()	{	return ms_screenModeDefs[ms_mode].gui_reserved_height;	};
	static inline int			getGuiAreaX()		{	return 0;												};
	static inline int			getGuiAreaY()		{	return ms_screenModeDefs[ms_mode].real_height-
															ms_screenModeDefs[ms_mode].gui_reserved_height + 
															(ms_screenModeDefs[ms_mode].border_reserved<<1);		};
	// -----------------------------------------

};

}

#endif //_DSYS_FRAMEBUFFER_WINSDL_
