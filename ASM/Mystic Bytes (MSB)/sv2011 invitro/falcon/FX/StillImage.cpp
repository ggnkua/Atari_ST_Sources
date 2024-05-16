// --------------------------------------------------------------------------------------------------------------
/*
	StillImage.cpp
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

#include "StillImage.h"

REGISTER_FACTORY_CLASS(StillImage,"StillImage");

// --------------------------------------------------------------------------------------------------------------

extern "C" void FalconLV_ChunkyToPlanes( unsigned char* pSrc, unsigned char* pDst, u32 numPixels );

// --------------------------------------------------------------------------------------------------------------

StillImage::StillImage ( ) :
	m_copyBackground ( 0 ),
	m_repetition ( 0 ),
	m_intensity ( 0 )
{
}

// --------------------------------------------------------------------------------------------------------------

bool StillImage::Serialise ( Node& node ) 
{
	node.r( "BgPic", m_pBackgroundName );
	node.r( "BgPal", m_pBackgroundPalName );
	
	return true;
}
// --------------------------------------------------------------------------------------------------------------

StillImage::~StillImage	( ) 
{
	free ( m_pBackground );
	free ( m_pBackgroundPal );
	printf("~StillImage\r\n");
}

// --------------------------------------------------------------------------------------------------------------

void StillImage::Init ( ) 
{
	printf("StillImage Intialising..\r\n");
	m_pBackground = (u8*) LoadFile( m_pBackgroundName);
	m_pBackgroundPal = (u8*) LoadFile( m_pBackgroundPalName );
	FalconLV_ChunkyToPlanes( m_pBackground, m_pBackground,(u32) 320*200 );	

	printf("StillImage Done..\r\n");
}

// --------------------------------------------------------------------------------------------------------------

void StillImage::Render ( )
{

	if ( m_copyBackground < 3 )
	{
		memcpy ( DemoSys::FrameBufferInterface::getBackBuffer(), m_pBackground, 320*200 );
		m_copyBackground++;
	}	
}

// --------------------------------------------------------------------------------------------------------------

bool StillImage::Update ( UpdateInfo* pUpdateInfo   )
{		
	m_intensity-= ( pUpdateInfo->m_dt >> 3);
	
	if ( pUpdateInfo->m_signal == cmdBarTick )
	{
		m_intensity = m_repetition * 48;
		if ( m_intensity > 512 ) 
		{
			m_intensity = 512;
		}
		m_repetition ++;
	}
	
	DemoSys::FrameBufferInterface::setPalette( (u32*)m_pBackgroundPal, 256 );

	return false;
}

// --------------------------------------------------------------------------------------------------------------

void StillImage::Start ( )
{
	//DemoSys::FrameBufferInterface::setPalette( (u32*)m_pBackgroundPal, 256 );
}

// --------------------------------------------------------------------------------------------------------------
