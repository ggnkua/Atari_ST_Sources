// --------------------------------------------------------------------------------------------------------------
/*
	OffsetScroll.h
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _OFFSETSCROLL_H
#define _OFFSETSCROLL_H

#include <Types.h>
#include <Fx/FxBase.h>
#include <Archive.h>
#include <vector>
#include <string>

// --------------------------------------------------------------------------------------------------------------

class OffsetScroll : public FxBase
{

	u16* 			m_pOffsets;	
	u8* 			m_pScrollBitmap;
	u8* 			m_pBackground;
	u8* 			m_pBackgroundPal;
	u8				m_pBackgroundPalGrey[1024];
	s32				m_motionOffset;
	u32				m_intensity;
	
	s32				m_speed;
	s32				m_fadeSpeed;
	s32				m_initialOffset;
	
	u32				m_oldhbl;
	bool			m_rewind;
	u32				m_copyBackground;
	
	const char*		m_pBackgroundName;
	const char*		m_pBackgroundPalName;	
	const char*		m_pTextureName;
	const char*		m_pDataName;
	
	u32				m_currTexture;
	u8*				m_textureData[16];
	const char* 	m_textureNames[16];
		
public:
					OffsetScroll	( );						
	virtual 		~OffsetScroll	( ) ;
	virtual void 	Init			( ) ;
	virtual	void	Start			( ) ;	
	virtual void 	Render			( ) ;
	virtual bool 	Update			( UpdateInfo* pUpdateInfo ) ;
	virtual bool	Serialise 		( Node& node ) ;	
};

// --------------------------------------------------------------------------------------------------------------

#endif // _OFFSETSCROLL_H