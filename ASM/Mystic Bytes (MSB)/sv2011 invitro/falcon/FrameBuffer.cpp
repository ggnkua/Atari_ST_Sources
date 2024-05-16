//==========================================================================================
//		FrameBuffer base class
//==========================================================================================
#include <Config.h>
#include "FrameBuffer.h"

//==========================================================================================

namespace DemoSys
{

bool FrameBufferInterface::initFrameBuffer(FrameBufferMode mode)
{
	return FrameBufferImplementation::initFrameBuffer(mode);
}

void FrameBufferInterface::shutdownFrameBuffer()
{
	FrameBufferImplementation::shutdownFrameBuffer();
}

void FrameBufferInterface::changeMode(FrameBufferMode mode)
{
	FrameBufferImplementation::changeMode(mode);
}

void FrameBufferInterface::setPalette(u32* p_palette, u32 numEntries, u32 intensity )
{
	FrameBufferImplementation::setPalette(p_palette,numEntries,intensity);
}

void FrameBufferInterface::getPalette(u32* p_palette,u32 first, u32 last)
{
	FrameBufferImplementation::getPalette(p_palette,first,last);
}

void* FrameBufferInterface::getBackBuffer()
{
	return FrameBufferImplementation::getBackBuffer();
}

void FrameBufferInterface::postProcessBuffers()
{
	FrameBufferImplementation::postProcessBuffers();
}

void FrameBufferInterface::setHScrollColor( u32 value )
{
	FrameBufferImplementation::setHScrollColor( value );
}

void FrameBufferInterface::flipBuffers( bool waitVsync )
{
	FrameBufferImplementation::flipBuffers( waitVsync );
}

void	FrameBufferInterface::setPaletteColor( u32 index, u32 value )
{
	FrameBufferImplementation::setPaletteColor( index, value );
}

}