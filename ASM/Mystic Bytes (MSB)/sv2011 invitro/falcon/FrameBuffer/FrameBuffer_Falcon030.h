
//==========================================================================================
//		FrameBuffer base class
//==========================================================================================
#ifndef _DSYS_FRAMEBUFFER_F030_
#define _DSYS_FRAMEBUFFER_F030_

//#include <Core.h>
#include "FrameBuffer.h"

namespace DemoSys
{

// =========================================================================================
//	Frame buffer interface abstraction class

class FrameBufferImplementationFalcon030
{

public:
	static bool					initFrameBuffer(FrameBufferInterface::FrameBufferMode mode);// Init FrameBuffer abstraction
	static void					shutdownFrameBuffer();										// kills FrameBuffer 
	
	static void					changeMode(FrameBufferInterface::FrameBufferMode mode);		// 	static void getBackBuffer();											
	static void					setPalette(u32* p_palette, u32 numEntries, u32 intensity );									// get palette
	static void					setPaletteColor( u32 index, u32 value);
	static void					getPalette(u32* p_palette,u32 first = -1,u32 last = -1);	// user supplied dest address, always 256
	static void 				setHScrollColor( u32 value );
	
	static void*				getBackBuffer();											// Get buffer pointer
	static void					flipBuffers( bool waitVsync = false );						// Swaps the surface
	static void					postProcessBuffers();										// buffer postprocessing

};

}

#endif //_DSYS_FRAMEBUFFER_F030_
