//-----------------------------------------------------------------------
//
// These routines are used to protect non-rentrant functions
//
// Uses a Semaphore
//
// copyright (c) 2000 by Jim Patchell
//
// these are used by malloc and free in the cross code library
// to prevent re-entrancy problems.
//
//-----------------------------------------------------------------------

#include "task.h"
#include "queue.h"

static Wait *MemoryEvent = (Wait *)0;
static Flag = 0;

extern "C" {
void InitDisable(void)
{
	MemoryEvent = new Wait(1,"MallocBlocker");	//can be used once before pending
	Flag = 1;		//ok to start using Disable and Enable
}

void Disable(void)
{
	if(!Flag) return;	//very dangerous
	MemoryEvent->Pend();
}

void Enable(void)
{
	if(!Flag) return;	//very dangerous
	MemoryEvent->Post();
}
}
