// --------------------------------------------------------------------------------------------------------------
/*

	MicroThread.h
	
*/
// --------------------------------------------------------------------------------------------------------------

#ifndef MICROTHREAD_H
#define MICROTHREAD_H

// --------------------------------------------------------------------------------------------------------------
#include <Core.h>
#include <Config.h>

// --------------------------------------------------------------------------------------------------------------

struct ThreadState
{
	void* 			m_pStackPointer;
	u32				m_timeSlice;
	bool			m_autoCleanUp;
	void* 			m_pStackPointerTop;
};

// --------------------------------------------------------------------------------------------------------------

class ThreadBase
{
	friend class	ThreadSheduler;
	ThreadState		m_state;
	ThreadBase*		m_pNext;
public:
					ThreadBase	( );
	virtual			~ThreadBase	( );
	virtual int 	Run			( ) = 0;
	void			Yield		( );
	void			Sleep		( int msecs );
	void			Exit		( );
};

// --------------------------------------------------------------------------------------------------------------

class MainThread : public ThreadBase
{
	 int 	Run	( ) { return 0; } ;
};

// --------------------------------------------------------------------------------------------------------------

class ThreadSheduler
{
	ThreadBase*				m_pCurrentThread;
	MainThread* 			m_pMain;

	static ThreadSheduler* 	pInstance;
	
							~ThreadSheduler	( );

	void					Init 			( );							
							
	ThreadState*			GetNext			( );
	ThreadState*			GetCurrent		( );								
	int 					AddThreadImpl	( ThreadBase* pThread, u32 stackSize, u32 timeSlice = 1, bool autoCleanUp = false );
	int 					KillThread		( ThreadBase* pThread );
	void 					Yield			( );			// yeald main thread
							
	static ThreadState*		GetNextThread	( );
	static ThreadState*		GetCurrentThread( );							
	static void				Run 			( ThreadBase* pThread );
	
public:

	static void				Create			( );
	static void				Destroy			( );
	static int 				AddThread		( ThreadBase* pThread, u32 stackSize, u32 timeSlice = 1, bool autoCleanUp = false );
//	static int 				KillThread		( ThreadBase* pThread );
//	static void 			Yield			( );			// yeald main thread

};

// --------------------------------------------------------------------------------------------------------------

inline void	DisableInts	( )
{
    asm volatile
    (	
		"	ori	#0x700,sr				;"
       :  :  : 
    );
}

// --------------------------------------------------------------------------------------------------------------

inline void	EnableInts ( )
{
    asm volatile
    (	
		"	andi	#0xf3ff,sr				;"
       :  :  : 
    );
}

// --------------------------------------------------------------------------------------------------------------

extern "C"
{
	void			InstallContextSwitchHandler		( );
	void			RemoveContextSwitchHandler		( );
	void 			PreemptiveContextSwitchHandler	( );
	void 			NormalContextSwitchHandler		( );
	void			ActivateThread					( ThreadState* pThreadState );	
}

// --------------------------------------------------------------------------------------------------------------

#endif //MICROTHREAD_H