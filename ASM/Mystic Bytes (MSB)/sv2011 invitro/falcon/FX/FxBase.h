// --------------------------------------------------------------------------------------------------------------
/*
	FxBase.h
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef _FXBASE_H
#define _FXBASE_H

#include <string.h>
#include <Archive.h>

// --------------------------------------------------------------------------------------------------------------

enum Command
{
	cmdIdle,
	cmdBarTick,
	cmdNext,
	cmdEnd,
	cmdEvent1,
	cmdEvent2
};
// --------------------------------------------------------------------------------------------------------------

struct TimeLine
{
	TimeLine()	: m_ms ( 0 ), m_sustain( false ) {}

	s32		m_ms;			// milisecond
	bool	m_sustain;		// keep sending event
	Command	m_signal;
	inline bool	Serialise ( Node& node );	
};

static const char* eventNames[] = {
	"Idle",
	"BarTick",
	"Next",
	"End",
	"Event1",
	"Event2",
	"Event3",
	NULL
};

inline bool TimeLine::Serialise ( Node& node )
{
	s32	sec = 0;
	s32 milis = 0;
	s32 minutes = 0;

	node.r( "Minutes", minutes );
	node.r( "Second", sec );
	node.r( "MiliSec", milis );
	
	m_ms = milis + sec * 1000 + minutes * 60000;
	
	const char* pEnum;
	node.r( "Cmd", pEnum );
	node.r( "Sustain", m_sustain );
	
	for ( int i=0; eventNames[i] != 0; i++ )
	{
		if ( strcmp( pEnum, eventNames[i] ) == 0 )
		{
			m_signal = (Command)i;
			break;
		}
	}	
	printf("event: %d, %d, %d\r\n", m_ms, m_signal, (u32)m_sustain);
}

// --------------------------------------------------------------------------------------------------------------
struct UpdateInfo
{
	UpdateInfo() : 
		m_currentMilis ( 0 ) {}

	s32	m_dt;
	s32	m_currentMilis;
	s32	m_bar;
	s32	m_signal;
};

// --------------------------------------------------------------------------------------------------------------

class FxBase
{
public:
	virtual 		~FxBase	( ) {};
	virtual void 	Init	( ) = 0;
	virtual	void	Start	( ) = 0;
	virtual void 	Render	( ) = 0;
	virtual bool 	Update	( UpdateInfo* pUpdateInfo ) = 0;
	virtual bool	Serialise ( Node& node ) {};
};

// --------------------------------------------------------------------------------------------------------------

#endif // _FXBASE_H