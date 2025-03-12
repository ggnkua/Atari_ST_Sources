// --------------------------------------------------------------------------------------------------------------
/*
	OffsetScroll.cpp
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

#include "OffsetScroll.h"

REGISTER_FACTORY_CLASS(OffsetScroll,"OffsetScroll");

// --------------------------------------------------------------------------------------------------------------

extern "C" void FalconLV_ChunkyToPlanes( unsigned char* pSrc, unsigned char* pDst, u32 numPixels );

// --------------------------------------------------------------------------------------------------------------

inline void DrawMapping( void* pBuffer, unsigned char* pTexture, unsigned short* pData )
{
	
#define GenPixel() \
	"	move.w	(a2)+,d0			;" \
	"	move.b	(a1,d0.l),d1		;" \
	"	roxr.b	#1,d1				;" \
	"	addx.w	d2,d2				;"
	
    asm volatile
    (	
		"	move.l	%0,a0				;"
		"	move.l	%1,a1				;"
		"	move.l	%2,a2				;"
		"	moveq	#0,d1				;"
		"	moveq	#0,d4				;"
		"	moveq	#0,d2				;"
		"	moveq	#0,d3				;"
		"	moveq	#0,d0				;"
		"	add.l	#14,a0				;"
		
		"	move.w	(a2)+,d4			;"
		"2:	move.w	(a2)+,d5			;"
		"	lsr.w	#4,d5				;"
		"	subq.w	#1,d5				;"
		"	lea		(a0,d4.l),a3		;"
		"1:								;"
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()
			GenPixel()		
		"	move.w	d2,(a3)				;"
		"	add.l	#16,a3				;"
		"	dbf		d5,1b				;"
		"	move.w	(a2)+,d4			;"
		"	bne		2b					;"
		
       :  
	   : "o"(pBuffer),"o"(pTexture),"o"(pData) 
	   : "d0" , "d1", "d2", "d3","d4","d5", "a0","a1","a2","a3"
    );
}


// --------------------------------------------------------------------------------------------------------------

OffsetScroll::OffsetScroll	( ) :
	m_copyBackground ( 0 ),
	m_intensity ( 400 ),
	m_currTexture ( 0 ),
	m_rewind ( false )
{
	for ( int i = 0; i < 16 ; i++ )
	{
		m_textureData[i] = 0 ;
		m_textureNames[i] = 0;
	}
}

// --------------------------------------------------------------------------------------------------------------

bool OffsetScroll::Serialise ( Node& node ) 
{
	node.r( "BgPic", m_pBackgroundName );
	node.r( "BgPal", m_pBackgroundPalName );
	node.r( "Data", m_pDataName );
	node.r( "SSpeed", m_speed );
	node.r( "FSpeed", m_fadeSpeed );
	node.r( "Offset", m_initialOffset );
	node.rlist( "Text", m_textureNames );
	
	return true;
}

// --------------------------------------------------------------------------------------------------------------

OffsetScroll::~OffsetScroll	( ) 
{
	free ( m_pBackground );
	free ( m_pBackgroundPal );
	free ( m_pScrollBitmap );
	free ( m_pOffsets );
	
	printf("~OffsetScroll\r\n");	
}

// --------------------------------------------------------------------------------------------------------------

void OffsetScroll::Init ( ) 
{
	printf("OffsetScroll Intialising..\r\n");
	m_pBackground = (u8*) LoadFile( m_pBackgroundName);
	m_pBackgroundPal = (u8*) LoadFile( m_pBackgroundPalName );
	FalconLV_ChunkyToPlanes( m_pBackground, m_pBackground,(u32) 320*200 );	
	m_pOffsets = (u16*) LoadFile( m_pDataName );
	printf("OffsetScroll Done..\r\n");
	
	for ( int i = 0; m_textureNames[i] != NULL; i++ )
	{
		printf( "Loading: %s\r\n", m_textureNames[i] );
		m_textureData[i] = (u8*) LoadFile( m_textureNames[i] )  ;
	}
	
	m_motionOffset = m_initialOffset;


	for ( int i = 0; i < 255; i ++ )
	{
		s32	avg = ( (s32)m_pBackgroundPal[i*4] + (s32)m_pBackgroundPal[i*4+1] + (s32)m_pBackgroundPal[i*4+1] ) / 3;
	
		m_pBackgroundPalGrey[i*4] = avg;
		m_pBackgroundPalGrey[i*4+1] = avg;
		m_pBackgroundPalGrey[i*4+2] = avg;	
	}
}

// --------------------------------------------------------------------------------------------------------------

void OffsetScroll::Render ( )
{	
	if ( m_rewind )
	{
		DemoSys::FrameBufferInterface::setPalette( (u32*)m_pBackgroundPalGrey, 256,255  );
	}else
	{
		DemoSys::FrameBufferInterface::setPalette( (u32*)m_pBackgroundPal, 256,m_intensity  );	
	}

	if ( m_copyBackground < 3 )
	{
		memcpy ( DemoSys::FrameBufferInterface::getBackBuffer(), m_pBackground, 320*200 );
	}
	m_copyBackground++;
		
    unsigned char* pBuffer = ( unsigned char*)DemoSys::FrameBufferInterface::getBackBuffer();
	DrawMapping ( pBuffer, m_textureData[m_currTexture] + ( m_motionOffset >> 4 ) , m_pOffsets  );

}

// --------------------------------------------------------------------------------------------------------------


bool OffsetScroll::Update ( UpdateInfo* pUpdateInfo  )
{
	s32	speed = m_speed;
	
	if ( pUpdateInfo->m_signal == cmdBarTick )
	{
		m_intensity = 400;
	} 
	else if ( pUpdateInfo->m_signal == cmdEvent1 )
	{
		m_currTexture++;
		m_motionOffset = m_initialOffset;
		m_intensity = 400;
		m_rewind = false;
	}
	else if ( pUpdateInfo->m_signal == cmdEvent2 || m_rewind )
	{
		static s32 shake = 0;
		DemoSys::FrameBufferInterface::setHScrollColor(  shake );
		shake^=0xf;
			
		if ( pUpdateInfo->m_signal == cmdEvent2  )
		{
			if ( m_rewind == true && !m_rewind == false )
			{
				DemoSys::FrameBufferInterface::setHScrollColor(  0 );
			}
		
			m_rewind = !m_rewind;
		}
		
		if ( m_rewind )
		{
		
		}
		
		speed= -speed*8;
	}

    m_motionOffset += ( ( pUpdateInfo->m_dt * speed  ) >> 8 );	
	m_intensity-= ( pUpdateInfo->m_dt / m_fadeSpeed );
	
	if ( m_intensity < 255 )
	{
		m_intensity = 255;
	}
	
	return false;
}

// --------------------------------------------------------------------------------------------------------------

void OffsetScroll::Start ( )
{
//	DemoSys::FrameBufferInterface::setPalette( (u32*)m_pBackgroundPal, 256,m_intensity  );	
}

// --------------------------------------------------------------------------------------------------------------
