// --------------------------------------------------------------------------------------------------------------
/*
	StillImage.h
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _StillImage_H
#define _StillImage_H

#include <Types.h>
#include <Fx/FxBase.h>

// --------------------------------------------------------------------------------------------------------------

class StillImage : public FxBase
{
	u8* 			m_pBackground;
	u8* 			m_pBackgroundPal;
	
	u32				m_copyBackground;
	u32				m_repetition;
	u32				m_intensity;
	
	const char*		m_pBackgroundName;
	const char*		m_pBackgroundPalName;	
		
public:
					StillImage	( );
	virtual 		~StillImage	( ) ;
	
	virtual void 	Init			( ) ;
	virtual	void	Start			( ) ;	
	virtual void 	Render			( ) ;
	virtual bool 	Update			( UpdateInfo* pUpdateInfo  ) ;
	virtual bool	Serialise 		( Node& node ) ;		
};

// --------------------------------------------------------------------------------------------------------------

#endif // _StillImage_H