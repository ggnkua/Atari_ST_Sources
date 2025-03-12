// --------------------------------------------------------------------------------------------------------------
/*
	LogoFlash.h
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _LOGOFLASH_H
#define _LOGOFLASH_H

#include <Types.h>
#include <Fx/FxBase.h>

// --------------------------------------------------------------------------------------------------------------

class LogoFlash : public FxBase
{
	u8* 			m_pBackground;
	u8* 			m_pBackgroundPal;
	
	u32				m_copyBackground;
	u32				m_repetition;
	u32				m_intensity;
	
	const char*		m_pBackgroundName;
	const char*		m_pBackgroundPalName;	
		
public:
					LogoFlash	( );
	virtual 		~LogoFlash	( ) ;
	virtual void 	Init			( ) ;
	virtual	void	Start			( ) ;	
	virtual void 	Render			( ) ;
	virtual bool 	Update			( UpdateInfo* pUpdateInfo  ) ;
	virtual bool	Serialise 		( Node& node ) ;	
};

// --------------------------------------------------------------------------------------------------------------

#endif // _LOGOFLASH_H