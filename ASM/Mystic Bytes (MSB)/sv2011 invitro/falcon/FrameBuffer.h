//==========================================================================================
//		FrameBuffer base class
//==========================================================================================
#ifndef _DSYS_FRAMEBUFFER_BASE_
#define _DSYS_FRAMEBUFFER_BASE_

#include <Types.h>

namespace DemoSys
{

// =========================================================================================
//	Frame buffer interface

class FrameBufferInterface{
public:
	enum FrameBufferMode{	
		kbufsize_320x200_8 = 0,
		kbufsize_320x200_565,		
		kbufsize_320x200_8888,

		kbufsize_320x240_8 ,
		kbufsize_320x240_565,	
		
		kbufsize_384x200_8,
		kbufsize_384x200_565,
		kbufsize_384x200_8888,

		kbufsize_640x400_8,
		kbufsize_640x400_565,
		kbufsize_640x400_8888,

		kbufsize_768x400_8,
		kbufsize_768x400_565,
		kbufsize_768x400_8888,	
		
		kbufsize_invalid
	};

	static bool 	initFrameBuffer(FrameBufferMode mode);						// Init FrameBuffer
	static void 	shutdownFrameBuffer();										// kills FrameBuffer 

	static void 	changeMode(FrameBufferMode mode);							// 	static void getBackBuffer();											
	static void 	setPalette(u32* p_palette, u32 numEntries, u32 intensity = 255 );					// get palette
	static void		setPaletteColor( u32 index, u32 value );
	static void 	getPalette(u32* p_palette,u32 first = -1,u32 last = -1);	// user supplied dest address, always 256
	static void 	setHScrollColor( u32 value );

	static void* 	getBackBuffer();											// Get buffer pointer
	static void 	flipBuffers( bool waitVsync = false );						// Swaps the surface
	static void 	postProcessBuffers();
	static u32		GetNumBuffers();											// Return the number of buffers
	static void*	GetBuffer( u32 );											// Returns the buffer 
};

}

#endif //_DSYS_FRAMEBUFFER_BASE_
