// --------------------------------------------------------------------------------------------------------------
/*
	
	MicroThread.cpp
	
*/
// --------------------------------------------------------------------------------------------------------------

#include "MicroThread.h"
#include <stdlib.h>
#include <stdio.h>

// --------------------------------------------------------------------------------------------------------------

ThreadSheduler* ThreadSheduler::pInstance = NULL;

// --------------------------------------------------------------------------------------------------------------

ThreadBase::ThreadBase	( )
{

}

// --------------------------------------------------------------------------------------------------------------

ThreadBase::~ThreadBase	( )
{

}

// --------------------------------------------------------------------------------------------------------------

void ThreadBase::Yield ( )
{
}

// --------------------------------------------------------------------------------------------------------------

void ThreadBase::Sleep ( int msecs )
{
}

// --------------------------------------------------------------------------------------------------------------

void ThreadBase::Exit ( )
{
}

// --------------------------------------------------------------------------------------------------------------

void ThreadSheduler::Create	( )
{
	pInstance = new ThreadSheduler();
	pInstance->Init();
}

// --------------------------------------------------------------------------------------------------------------
	
void ThreadSheduler::Destroy ( )
{
	RemoveContextSwitchHandler();

	DisableInts();
	//delete pInstance;
	EnableInts();	
}

// --------------------------------------------------------------------------------------------------------------

void ThreadSheduler::Init ( )
{

	MainThread* pMain = new MainThread();
	pMain->m_state.m_pStackPointer = NULL;
	pMain->m_state.m_timeSlice = 1;
	pMain->m_state.m_autoCleanUp = false;
	pMain->m_pNext = pMain;

	m_pCurrentThread = pMain;
	m_pMain = pMain;
	
    InstallContextSwitchHandler( );
	
	printf("ThreadSheduler: started...\r\n");
}

// --------------------------------------------------------------------------------------------------------------

ThreadSheduler::~ThreadSheduler	( )
{
	RemoveContextSwitchHandler();
	
	//delete m_pMain;

	printf("ThreadSheduler: destroyed...\r\n");	
}

// --------------------------------------------------------------------------------------------------------------

void ThreadSheduler::Run ( ThreadBase* pThread)
{
	int ret = pThread->Run();
	// kill thread
	while(1);
}

// --------------------------------------------------------------------------------------------------------------

int ThreadSheduler::AddThreadImpl ( ThreadBase* pThread, u32 stackSize, u32 timeSlice, bool autoCleanUp )
{
	
	pThread->m_state.m_pStackPointerTop = malloc ( stackSize );
	pThread->m_state.m_timeSlice = timeSlice;
	pThread->m_state.m_autoCleanUp = autoCleanUp;
	pThread->m_state.m_pStackPointer = (void*) ((char*) pThread->m_state.m_pStackPointerTop + stackSize );
	
    asm volatile
    (	
		"	move.l	%1,a0				\n"				// stack pointer
		"	move.l	%3,-(a0)			\n"				// push Run func argument
		"	move.l	#0,-(a0)			\n"				// push fake return address
		"	move.w	#0x114,-(a0)		\n"				// push fake frame format and vector offset
		"	move.l	%2,-(a0)			\n"				// push function address
		"	move.w	sr,-(a0)			\n"				// push status register
		"	fsave	-(a0)				\n"				// fake fpu state
		"	fmovem.l 	fpcr/fpsr/fpiar,-(a0)	\n"				// fake fpu state
		"	fmovem	fp0-fp7,-(a0)		\n"				// push floating point regs
		"	movem.l	d0-d7/a0-a6,-(a0)	\n"				// push regular regs
		"	move.l	a0,%0				\n"				// return stack address
		
       :  	"=r" ( pThread->m_state.m_pStackPointer )
	   : 	"g"( pThread->m_state.m_pStackPointer ),
			"g"( ThreadSheduler::Run ),
			"g"( pThread )
	   :  	"a0"
    );

	DisableInts();
	
	pThread->m_pNext = m_pCurrentThread->m_pNext;
	m_pCurrentThread->m_pNext = pThread;
		
	EnableInts();	
}

// --------------------------------------------------------------------------------------------------------------

int ThreadSheduler::AddThread ( ThreadBase* pThread, u32 stackSize, u32 timeSlice, bool autoCleanUp )
{
	pInstance->AddThreadImpl( pThread, stackSize, timeSlice, autoCleanUp );
}

// --------------------------------------------------------------------------------------------------------------

int ThreadSheduler::KillThread ( ThreadBase* pThread )
{

}

// --------------------------------------------------------------------------------------------------------------

void ThreadSheduler::Yield ( )
{
	NormalContextSwitchHandler ( );
}

// --------------------------------------------------------------------------------------------------------------

ThreadState* ThreadSheduler::GetNext ( )
{
	m_pCurrentThread = m_pCurrentThread->m_pNext;
	
	return GetCurrent();	
}

// --------------------------------------------------------------------------------------------------------------

ThreadState* ThreadSheduler::GetCurrent ( )
{
	return &(m_pCurrentThread->m_state);
}
	
// --------------------------------------------------------------------------------------------------------------

ThreadState* ThreadSheduler::GetNextThread ( )
{
	return pInstance->GetNext();
}

// --------------------------------------------------------------------------------------------------------------

ThreadState* ThreadSheduler::GetCurrentThread ( )
{
	return pInstance->GetCurrent();
}
	
// --------------------------------------------------------------------------------------------------------------
