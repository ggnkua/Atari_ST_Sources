#include <Config.h>
#include "FrameBuffer.h"
#include "FrameBuffer_Falcon030.h"
#include "Falcon_LowLevel/VidelDirect.h"
#include <osbind.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>

////#define DISABLE

namespace DemoSys
{

// ----------------------------------------------------------------------------------------------------------------

struct F030_VideoModeInfo{
		FrameBufferInterface::FrameBufferMode 	m_modeId;
		unsigned char*							videl_dump;
		unsigned int							buffer_size;
		unsigned short							width,height;
		unsigned short							buffer_bpp;
};

F030_VideoModeInfo f030_modes_info_vga[] = 
{
	{ FrameBufferInterface::kbufsize_320x200_8, 	dump_320x200x8bpp_vga,320*200,320,200,8		},
	{ FrameBufferInterface::kbufsize_320x200_565,	dump_320x200x16bpp_vga,320*200*2,320,200,16		},
	{ FrameBufferInterface::kbufsize_320x240_8, 	dump_320x240x8bpp_vga,320*240,320,240,8		},
	{ FrameBufferInterface::kbufsize_320x240_565,	dump_320x240x16bpp_vga,320*240*2,320,240,16		},
	
	{ FrameBufferInterface::kbufsize_invalid,		0,0,0,0,0						},
};

F030_VideoModeInfo f030_modes_info_pal[] =
{
	{ FrameBufferInterface::kbufsize_320x200_8, 	dump_320x200x8bpp_tv,320*200,320,200,8		},
	{ FrameBufferInterface::kbufsize_320x240_8, 	dump_320x240x8bpp_tv,320*240,320,240,8		},
	{ FrameBufferInterface::kbufsize_invalid,		0,0,0,0,0						},
};

unsigned char*	f030_framebuffers[3];
unsigned char*	f030_framebuffers_not_aligned[3];
unsigned int	f030_buffer_size = 0;
unsigned int	f030_bpp = 0;

u32				f030_oldVbl = 0;
volatile u32	f030_numPal = 0;
volatile u32*	f030_newPal;
u32				f030_newPalCopy[256];
volatile void*	f030_newBuff = NULL;
u32				f030_hscroll = 0;

// ----------------------------------------------------------------------------------------------------------------

void __attribute__ ((interrupt)) vblHandler ()
{	

    asm volatile
    (	
		" ori			#0x700,sr "
       :  
	   :
	   :
    );

	if ( f030_newBuff  )
	{
	 	FalconLV_SetFramebufferPointer((void*)f030_newBuff);	
		f030_newBuff = NULL;
	}
	
	if ( f030_numPal )
	{
		FalconLV_SetPalletteRGBA( (u32*)f030_newPal, f030_numPal );
		f030_newPal = 0;
		f030_numPal = 0;
	}	
	
	*((unsigned char*)0x00FF8264) = f030_hscroll;
}

// ----------------------------------------------------------------------------------------------------------------

bool FrameBufferImplementationFalcon030::initFrameBuffer( FrameBufferInterface::FrameBufferMode mode)
{
	FalconLV_SaveVideo();

	unsigned char*	videl_dump = NULL;
	F030_VideoModeInfo* pModeList = NULL;
	
	u32	monitorType = (*((unsigned short*)0xFFFF82C0) & 0x3 ) ;

	if ( monitorType == 1 || monitorType == 3 )
	{
		pModeList = f030_modes_info_pal;
	}
	else if ( monitorType == 2 )
	{
		pModeList = f030_modes_info_vga;
	}
	else
	{
		return false;
	}
	
	printf("monitor type: %d\r\n", monitorType );
	
	for ( int i = 0; pModeList[i].m_modeId != FrameBufferInterface::kbufsize_invalid; i ++  )
	{
		if ( pModeList[i].m_modeId == mode  )
		{
			videl_dump = pModeList[mode].videl_dump;
			f030_buffer_size = pModeList[mode].buffer_size;
			f030_bpp = pModeList[mode].buffer_bpp;
			break;
		}
	}
	
	if ( videl_dump == NULL ) 
	{
		return false;
	}

	for (int i=0;i < 3; ++i)
	{
		f030_framebuffers_not_aligned[i] = (unsigned char*) Mxalloc(f030_buffer_size+0x100, MX_STRAM);
		f030_framebuffers[i] = (unsigned char*) ((((u32)f030_framebuffers_not_aligned[i])+0x100)&0xffffff00);	// align screen pointer to 256 bytes.
		memset(f030_framebuffers[i],0,f030_buffer_size );
	}
	
	Vsync();
	#ifndef DISABLE
	FalconLV_SetVideoMode((void*)videl_dump);
 	FalconLV_SetFramebufferPointer(f030_framebuffers[1]);
	
	f030_oldVbl = *((u32*)0x70); 
	*((u32*)0x70) = (u32)&vblHandler;
	#endif
	
	return true;
}

// ----------------------------------------------------------------------------------------------------------------

void FrameBufferImplementationFalcon030::shutdownFrameBuffer()
{
	#ifndef DISABLE
	*((u32*)0x70) = f030_oldVbl;
	FalconLV_RestoreVideo();
	#endif
	
	for (int i=0;i < 3; ++i)
	{
		Mfree(f030_framebuffers_not_aligned[i]);
	}
}

// ----------------------------------------------------------------------------------------------------------------

void FrameBufferImplementationFalcon030::changeMode(FrameBufferInterface::FrameBufferMode mode)
{

}

// ----------------------------------------------------------------------------------------------------------------

void FrameBufferImplementationFalcon030::setPalette( u32* pPalette, u32 numEntries, u32 intensity  )
{
	if ( intensity == 255 )
	{
		memcpy ( f030_newPalCopy, pPalette, numEntries << 2 );
	}
	else
	{
		s32 damp = 255 - (s32)intensity;
	
		for ( int i = 0; i < numEntries; i ++ )
		{
			s32	r = (( pPalette[i] >> 24 ) & 0xff ) - damp;
			s32	g = (( pPalette[i] >> 16 ) & 0xff ) - damp;
			s32	b = (( pPalette[i] >> 8 ) & 0xff ) - damp;
		
			r = r < 0 ? 0 : r;
			g = g < 0 ? 0 : g;
			b = b < 0 ? 0 : b;

			r = r > 255 ? 255 : r;
			g = g > 255 ? 255 : g;
			b = b > 255 ? 255 : b;
			
			f030_newPalCopy[i] = ( r << 24 ) + ( g << 16 ) + ( b << 8 );
		}
	}
	
	f030_numPal = numEntries;
	f030_newPal = f030_newPalCopy;
}

// ----------------------------------------------------------------------------------------------------------------

void FrameBufferImplementationFalcon030::setPaletteColor( u32 index, u32 value )
{
	((u32*)0xffff9800)[ index ] = value;
}

// ----------------------------------------------------------------------------------------------------------------

void FrameBufferImplementationFalcon030::setHScrollColor( u32 value )
{
	f030_hscroll = value;
}

// ----------------------------------------------------------------------------------------------------------------

void FrameBufferImplementationFalcon030::getPalette(u32* p_palette,u32 first, u32 last)
{

}

// ----------------------------------------------------------------------------------------------------------------

void* FrameBufferImplementationFalcon030::getBackBuffer()
{
	return (void*)f030_framebuffers[0] ;
}

// ----------------------------------------------------------------------------------------------------------------

void FrameBufferImplementationFalcon030::postProcessBuffers()
{
}

// ----------------------------------------------------------------------------------------------------------------

void FrameBufferImplementationFalcon030::flipBuffers( bool waitVsync )
{
	unsigned char* pTempBuffer;

	f030_newBuff = f030_framebuffers[0];
	
	pTempBuffer = f030_framebuffers[0];
	f030_framebuffers[0] = f030_framebuffers[1];
	f030_framebuffers[1] = f030_framebuffers[2];
	f030_framebuffers[2] = pTempBuffer;
		
// 	FalconLV_SetFramebufferPointer(f030_framebuffers[0]);	
}

// ----------------------------------------------------------------------------------------------------------------

}