// --------------------------------------------------------------------------------------------------------------
/*
	HwScroll.h
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _HwScroll_H
#define _HwScroll_H

#include <Types.h>
#include <Fx/FxBase.h>

// --------------------------------------------------------------------------------------------------------------

struct Strip
{
	s32 m_pos;
	s32 m_height;
	inline bool	Serialise ( Node& node );
};

inline bool Strip::Serialise ( Node& node )
{
	node.r( "Pos", m_pos );
	node.r( "Height", m_height );

	printf("Strip: %d, %d\r\n", m_pos, m_height );
}

// --------------------------------------------------------------------------------------------------------------

class HwScroll : public FxBase
{
	u8* 			m_pBackground;
	u8* 			m_pBackgroundPal;

	u32				m_copyBackground;
	u32				m_repetition;
	u32				m_intensity;
	
	s32				m_offset;
	
	const char*		m_pBackgroundName;
	const char*		m_pBackgroundPalName;	
	const char*		m_pBackgroundName2;
	const char*		m_pBackgroundPalName2;	
	
	s32				m_currentStrip;
	Strip			m_strips[8];
		
public:
					HwScroll		( );
	virtual 		~HwScroll		( ) ;
	virtual void 	Init			( ) ;
	virtual	void	Start			( ) ;	
	virtual void 	Render			( ) ;
	virtual bool 	Update			( UpdateInfo* pUpdateInfo  ) ;
	virtual bool	Serialise 		( Node& node ) ;	
};

// --------------------------------------------------------------------------------------------------------------

#endif // _HwScroll_H