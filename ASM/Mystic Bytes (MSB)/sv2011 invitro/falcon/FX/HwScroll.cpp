// --------------------------------------------------------------------------------------------------------------
/*
	HwScroll.cpp
*/
// --------------------------------------------------------------------------------------------------------------

#include <Config.h>
#include <Core.h>
#include <Factory.h>
#include <Archive.inl>
#include <FrameBuffer.h>
#include <File.h>
#include <stdio.h>
#include <string.h>

#include "HwScroll.h"

REGISTER_FACTORY_CLASS(HwScroll,"HwScroll");

// --------------------------------------------------------------------------------------------------------------

extern "C" void FalconLV_ChunkyToPlanes( unsigned char* pSrc, unsigned char* pDst, u32 numPixels );

// --------------------------------------------------------------------------------------------------------------

HwScroll::HwScroll ( ) :
	m_copyBackground ( 0 ),
	m_repetition ( 0 ),
	m_intensity ( 512 ),
	m_offset ( (563-200)*64 ),
	m_currentStrip ( -1 )
{
}

// --------------------------------------------------------------------------------------------------------------

bool HwScroll::Serialise ( Node& node ) 
{
	node.r( "BgPic", m_pBackgroundName );
	node.r( "BgPal", m_pBackgroundPalName );
	
	node.rlist( "Strip", m_strips );
	return true;
}

// --------------------------------------------------------------------------------------------------------------

HwScroll::~HwScroll	( ) 
{
	free ( m_pBackground );
	free ( m_pBackgroundPal );
	printf("~HwScroll\r\n");
}

// --------------------------------------------------------------------------------------------------------------

void HwScroll::Init ( ) 
{
	printf("HwScroll Intialising..\r\n");
	m_pBackground = (u8*) LoadFile( m_pBackgroundName);
	m_pBackgroundPal = (u8*) LoadFile( m_pBackgroundPalName );
	FalconLV_ChunkyToPlanes( m_pBackground, m_pBackground,(u32) 320*563*2 );	

	
	printf("HwScroll Done..\r\n");
}

// --------------------------------------------------------------------------------------------------------------

void HwScroll::Render ( )
{
	memcpy ( DemoSys::FrameBufferInterface::getBackBuffer(), m_pBackground + ( m_offset >> 6 ) * 320, 320*200 );

	if ( m_currentStrip != -1 )
	{
		s32 y = ( m_offset >> 6 ) ;
		
		if ( y < m_strips[m_currentStrip].m_pos && y + 200 > m_strips[m_currentStrip].m_pos + m_strips[m_currentStrip].m_height )
		{
			s32 height = m_strips[m_currentStrip].m_height;
					
			memcpy ( (u8*)DemoSys::FrameBufferInterface::getBackBuffer() +  ( m_strips[m_currentStrip].m_pos - y  ) * 320, m_pBackground + 320*563 + m_strips[m_currentStrip].m_pos * 320, 320*m_strips[m_currentStrip].m_height );
		}
	}
}

// --------------------------------------------------------------------------------------------------------------

bool HwScroll::Update ( UpdateInfo* pUpdateInfo   )
{		
	m_intensity-= ( pUpdateInfo->m_dt >> 3);
	
	m_offset-= ( pUpdateInfo->m_dt ) ;
	
	if ( m_offset < 0 )
	{
		m_offset = 0;
	}
	
	if ( pUpdateInfo->m_signal == cmdEvent1 )
	{
		m_currentStrip++;
		pUpdateInfo->m_signal = cmdBarTick;
	}
	
	if ( pUpdateInfo->m_signal == cmdBarTick )
	{
		m_intensity = 512;
	}
		
	DemoSys::FrameBufferInterface::setPalette( (u32*)m_pBackgroundPal, 256, m_intensity  );

	m_intensity-=16;
	if ( m_intensity < 255 )
	{
		m_intensity = 255;
	}	
	
	return false;
}

// --------------------------------------------------------------------------------------------------------------

void HwScroll::Start ( )
{
	//DemoSys::FrameBufferInterface::setPalette( (u32*)m_pBackgroundPal, 256 );
}

// --------------------------------------------------------------------------------------------------------------
