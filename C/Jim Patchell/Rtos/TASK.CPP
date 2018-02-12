/*************************************************************************
**                                                                      **
**                                                                      **
** This is a rudimentary multitasking kernel that is integrated with    **
** the I/O module cio.cpp.  Provides the simplest services of           **
** creating tasks, both for absolute and relative data regions,         **
** creating and deleting events, interrupt processing.                  **
** This kernel is roughly based on uC/OS by Jean Labrosse, but by       **
** integrating it with I/O, expands it much more.                       **
**                                                                      **
** Other files that have to do with the Multitasking kernel are:        **
** CIO.CPP  	.... provides I/O management							**
** TRAP.S		.... provides access to CIO.CPP via software interrupt	**
** SWAP.S		.... handles context swaping and critical sections		**
** PQ.CPP		.... priority queue class for prioritizing tasks        **
** copyright (c) 1995 by Jim Patchell                                   **
**                                                                      **
*************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "pq.h"
#include "task.h"
#include "cio.h"

PQ *ActiveTasks;		//priority queue of active tasks
TCB *CurrentTask=0;		//current executing task
TCB *ReadyTask = 0;		//task that is ready to run
TCB *FreeTaskList = NULL;
TCB *MasterTaskList = 0;	//master list of all current tasks

int InterruptCount=0;	//level of interrupt depth
int Blocking=0;			//level of task swap blocking

TSemaphore *TSemaphore::MasterList = (TSemaphore *)0;
TSemaphore *TSemaphore::TimeoutList = (TSemaphore *)0;
long TSemaphore::TStamp = 0l;

extern "C" void _Start(void);

//----------------------------------------------------------------------
//
// This function is used to compare two items in the priority queue
// to see which one has the highest priority
//
// The function is passes two pointers that point to the pointers
// that point to the actual objects
//
//----------------------------------------------------------------------
//
static int PriorityCompare(void **s1, void **s2)
{
	int r;

	//check priority levels
	if( (r = ((TCB *)*s1)->priority - ((TCB *)*s2)->priority) != 0)
		return r;
	//if priority levels are the same, then check time stamps
	return int(((TCB *)*s2)->TimeStamp - ((TCB *)*s1)->TimeStamp);
}

static int TaskCompare(void **s1,void **s2)
{
	int retval = 1;

	if(*s1 == *s2) retval = 0;
	return retval;
}

//-----------------------------------------------------------------------
//
// Create a task
//
// void (*task)(void);		//this is the "main" routine for the task
// int stacksize;			//number of WORDs that are in the stack for the task
// int priority;			//0 is lowest priority, 32767 is highest priority
// char *name;				//this is used for debugging
//
// This function allocates space for the Stack in "stacksize" words
//
//-----------------------------------------------------------------------

extern "C" TCB *CreateTask(void (*task)(void),int stacksize,int priority,char *name)
{

	TCB *t;
	int *stack;
	long *stk;
	int sr;

	sr = EnterCritical();
	if((t = FreeTaskList))	//is there a free task?
	{
		FreeTaskList = t->next;	//remove from free list
		if(t->datamem)		//did this used to be a relative task?
			free(t->datamem);
		if(t->stacksize < stacksize)
		{
			free(t->stacktop);	//get rid of memory
			stack = (int *)malloc(2 * stacksize);
		}
		else
		{
			stack = t->stacktop;
			stacksize = t->stacksize;	//larger stack is ok, but record it
		}
	}
	else
	{
		t = (TCB *)malloc((int)sizeof( TCB));
		stack = (int *)malloc(2 * stacksize);
	}
	if(t)
	{
		t->TcbSwaps = 0;
		t->datamem = (char *)0;
		t->stacksize = stacksize;
		t->tasktype = TCB_ABSOLUTE;
		t->priority = priority;
		t->TimeStamp = TSemaphore::TStamp++;
		t->name = name;
		t->stacktop = stack;
		t->next = (TCB *)0;
		t->list = MasterTaskList;
		MasterTaskList = t;
		stk = (long *)((int *)stack + stacksize);
		*--stk = (long)task;
		*--((int *)stk) = 0x2000;	/*	supervisor mode,interrupts enabled	*/
		*--stk = 0l;		/*	a6 = 0	*/
		*--stk = 0l;		/*	a5 = 0	*/
		*--stk = 0l;		/*	a4 = 0	*/
		*--stk = 0l;		/*	a3 = 0	*/
		*--stk = 0l;		/*	a2 = 0	*/
		*--stk = 0l;		/*	a1 = 0	*/
		*--stk = 0l;		/*	a0 = 0	*/
		*--stk = 0l;		/*	d7 = 0	*/
		*--stk = 0l;		/*	d6 = 0	*/
		*--stk = 0l;		/*	d5 = 0	*/
		*--stk = 0l;		/*	d4 = 0	*/
		*--stk = 0l;		/*	d3 = 0	*/
		*--stk = 0l;		/*	d2 = 0	*/
		*--stk = 0l;		/*	d1 = 0	*/
		*--stk = 0l;		/*	d0 = 0	*/
		t->stack = (int *)stk;
	}
	ExitCritical(sr);
	return t;
}

//-----------------------------------------------------------------------
//
// Create a task that has position independent global data
//
// void (*task)(void);		//this is the "main" routine for the task
// int stacksize;			//number of WORDs that are in the stack for the task
// int priority;			//0 is lowest priority, 32767 is highest priority
// char *name;				//this is used for debugging
// long *data;				//this points to the intialization data for task
// long dsize;				//size of intialization data block in bytes
// long rsize;				//size of global ram in bytes
// void *param				//pointer sized parameter to pass to task
//
// This function allocates space for the Stack in "stacksize" words
// this function also creates a pointer to the data area and loads it into
// the stack location for address register 5 (a5).
//
// when you compile the code, use a #pragma to rename the 'ram' and 'data'
// regions to something else.  In the spec file you will need to find out the
// sizes of the the other data areas and use those sizes appropriately.
// The order of linking the data and ram area should be data area first.
// This function uses malloc to allocate a memory block that is
// 'dsize' + 'rsize' long.  The whole block is zeroed, and then the
// initialization data is downloaded.
//
// the file that contains the task to be created should be compiled with
// the following command line switch:
//	-rA5=_data
// This will cause the compiler to address global data relative to address
// register 5.
// When a task switch occures, this register is pushed onto the stack
// meaning that you can have as many independent instances of this task
// as you want.
//
//-----------------------------------------------------------------------

extern "C" TCB *CreateRelTask(void (*task)(void *),int stacksize,int priority,char *name,char *initdata,int dsize,int rsize,void *param)
{

	TCB *t;
	int *stack;
	long *stk;
	char *data;
	int sr;

	sr = EnterCritical();
	if((t = FreeTaskList))	//is there a free task?
	{
		FreeTaskList = t->next;	//remove from free list
		if(t->datamem)		//did this used to be a relative task?
			free(t->datamem);
		if(t->stacksize < stacksize)
		{
			free(t->stacktop);	//get rid of memory
			stack = (int *)malloc(2 * stacksize);
		}
		else
		{
			stack = t->stacktop;
			stacksize = t->stacksize;	//larger stack is ok, but record it
		}
	}
	else
	{
		t = (TCB *)malloc((int)sizeof( TCB));
		stack = (int *)malloc(2 * stacksize);
	}
	if(t)
	{
		data = (char *)malloc(dsize + rsize);	/*	create data area	*/
		memset(data,0,dsize + rsize);	/*	zero memory		*/
		memcpy(data,initdata,dsize);	/*	copy in initialization data	*/
		t->datamem = data;
		t->TcbSwaps = 0;
		t->tasktype = TCB_RELATIVE;
		t->stacksize = stacksize;
		t->priority = priority;
		t->TimeStamp = TSemaphore::TStamp++;
		t->name = name;
		t->stacktop = stack;
		t->next = (TCB *)0;
		t->list = MasterTaskList;
		MasterTaskList = t;
		stk = (long *)((int *)stack + stacksize);
		*--stk = (long)param;	/*	push parameter onto stack	*/
		*--stk = (long)task;	/*	simulates subroutine call, never used	*/
		*--stk = (long)task;    /*	address of routine to be run	*/
		*--((int *)stk) = 0x2000;	/*	supervisor mode,interrupts enabled	*/
		*--stk = 0l;		/*	a6 = 0	*/
		*--stk = (long)data;/*	a5 = data	*/
		*--stk = 0l;		/*	a4 = 0	*/
		*--stk = 0l;		/*	a3 = 0	*/
		*--stk = 0l;		/*	a2 = 0	*/
		*--stk = 0l;		/*	a1 = 0	*/
		*--stk = 0l;		/*	a0 = 0	*/
		*--stk = 0l;		/*	d7 = 0	*/
		*--stk = 0l;		/*	d6 = 0	*/
		*--stk = 0l;		/*	d5 = 0	*/
		*--stk = 0l;		/*	d4 = 0	*/
		*--stk = 0l;		/*	d3 = 0	*/
		*--stk = 0l;		/*	d2 = 0	*/
		*--stk = 0l;		/*	d1 = 0	*/
		*--stk = 0l;		/*	d0 = 0	*/
		t->stack = (int *)stk;
	}
	ExitCritical(sr);
	return t;
}


//***********************************************************************
//
// Delete Task
//
// This is REAL tricky
// memory cannot be free'd, technically, until the task is done using
// the stack, but it won't be done using the stack until it swaps
//
//----------------------------------------------------------------------
// Another tricky thing:  it is posible to delete a task that is pending
// on a semaphore.  It is nessesary to check all of the semaphores and
// remove any tasks waiting for a post, or else things will not be nice.
// 05-26-98
//
//----------------------------------------------------------------------
// This function still has some problems.  Need to come up with a way
// for a notification to be posted when the task is finally deleted,
// since it may not sometime happen right away.
//
//***********************************************************************


int TDelete(TCB *task)
{
	int retval=0;
	int sr;
	TCB *deletedtask=0;

	TBlock();
	TCB *t,**prev;
	int loop;
	if(task == NULL) task = CurrentTask;	//null value= delete current task
	for(prev = &MasterTaskList,t = MasterTaskList,loop=1;t && loop;)
	{
		if(t == task)	//is this the task?
		{
			*prev = t->list;
			loop = 0;
		}
		else
		{
			prev = &(t->list);
			t = t->list;
		}
	}
	TRelease();
	if(task == CurrentTask)	//delete current task?
	{
		//if we end up here, the task can not posibly be pending
		//it cannot posibly be in the priority QUEUE
		//if we end up here, this call will NEVER return, tasks will
		//have to be resheduled
		EnterCritical();		//this task is going away, don't need to save SR
		CurrentTask->next = FreeTaskList;
		FreeTaskList = CurrentTask;
		ActiveTasks->Delete((void **)&ReadyTask);
		asm(" trap #0");
	}
	else	//delete a task that is not active
	{
		//we have to do one of several posible things.
		//1. check the priority QUEUE and see if the task lives in there
		//2. check the list of semaphores and see if the task is pending
		//This code has not ben verified
		sr = EnterCritical();
		ActiveTasks->Remove((void **)&deletedtask,TaskCompare,(void *)task);	//see if task can be removed
		if(deletedtask)	//we found the task
		{
			deletedtask->next = FreeTaskList;
			FreeTaskList = deletedtask;
		}
		else
		{
			if(TSemaphore::SendKill(task))
				retval = -1;

		}
		ExitCritical(sr);
	}
	return retval;		//no errors
}

/*-----------------------------------------------------------------------
**
** EnterInterrupt
**
**	This function keeps track of the nesting level of interrupts
**
**  This function requires no blocking BECAUSE the 68000 can do
**  This operation in one instruction so it is not interruptable
**
**---------------------------------------------------------------------*/

extern "C" void EnterInterrupt(void)
{
	++InterruptCount;
}

/************************************************************************
**                                                                     **
** ExitInterrupt                                                       **
**                                                                     **
** This function keeps track of the nesting level of interrupts        **
** If nesting level is == 0, then do a context swap to the highest     **
** priority task                                                       **
**                                                                     **
** WARNING!                                                            **
** 	Don't mess with this function, you will be sorry                   **
**  Adding any local variables or passed parameters                    **
**  Messes with the stack.  IrqSwap alters the stack and               **
**  if it is different from what it expects, it will mess              **
**  up the stack.                                                      **
**                                                                     **
** Hey, you don't even need to add any local variables, just add a     **
** Little bit more code and it will mess things up.  Always check      **
** the listing file to see how much might get pushed onto the stack	   **
**                                                                     **
** Just as a point of reference                                        **
**  JSR to IrqSwap uses up 4 bytes on stack                            **
**  JSR to ExitInt uses up 4 bytes on stack                            **
**  IntLevel       uses up 2 bytes on stack                            **
**                        10 bytes total                               **
**                                                                     **
** ExitInterrupt will alocate at least 4 bytes on the stack probably   **
** for sr, depending on how it does this.                              **
** Currently ExitInterrupt uses 4 bytes on the stack to save various   **
** registers that it doesn't really have to                            **
**                                                                     **
** Currently IrqSwap() needs to remove 14 bytes from stack			   **
**				                                                       **
************************************************************************/

extern "C" void ExitInterrupt(int IntLevel)
{
	int sr;

	--InterruptCount;
	sr = EnterCritical();
	if(!IntLevel && !Blocking)	//don't swap if nested
	{
		CurrentTask->TimeStamp = TSemaphore::TStamp;
		ActiveTasks->Replace((void **)&ReadyTask,CurrentTask);
		if(ReadyTask != CurrentTask)
		{
			ReadyTask->TcbSwaps++;
			IrqSwap();	//interrupts will be re-enabled right after this
		}
	}
	ExitCritical(sr);
}

/***********************************************************************
** TimerTicker                                                        **
**                                                                    **
**	This function is called by the real time interrupt handler        **
**	This function Increments the clock, scans through the Event       **
**  Control Blocks looking for timed out events.                      **
**                                                                    **
***********************************************************************/

extern "C" void TimerTicker(void)
{
	TSemaphore::Timeout();
}

/**********************************************************************
**                                                                   **
** Start                                                             **
**                                                                   **
** This function dequeues the highest priority task and then starts  **
** it.  This function gets the whole ball of wax moving              **
**                                                                   **
**********************************************************************/

void Start(void)
{
	TCB *nexttask;

	EnterCritical();
	ActiveTasks->Delete((void **)&ReadyTask);   //get a task
	ReadyTask->TcbSwaps++;						//our first swap
	_Start();                                   //initial context swap
}

/*********************************************************************
**                                                                  **
** Schedule                                                         **
**                                                                  **
** This function reschedules a task at the task level.  It puts the **
** current task back into the active task list and dequeues the     **
** highest priority task.                                           **
**                                                                  **
** It updates the time stamp at the same time                       **
**                                                                  **
*********************************************************************/

extern "C" void Schedule(void)
{
	int sr;

	++TSemaphore::TStamp;
	sr = EnterCritical();
	if(!InterruptCount && !Blocking)	//ok to swap?
	{
		CurrentTask->TimeStamp = TSemaphore::TStamp;
		ActiveTasks->Replace((void **)&ReadyTask,CurrentTask);
		if(ReadyTask != CurrentTask)
		{
			ReadyTask->TcbSwaps++;
			asm(" trap #0");
		}
	}
	ExitCritical(sr);
}

/***********************************************************************
**                                                                    **
** InitOS                                                             **
**                                                                    **
** This function must be called before starting the multitasking      **
**                                                                    **
***********************************************************************/
void InitOS(void)
{
	InitDisable();
	ActiveTasks = new PQ(MAX_TASKS,PriorityCompare);	//initialize priority queue
}

/***********************************************************************
**                                                                    **
** Multitasking Control Routines                                      **
**                                                                    **
************************************************************************
**                                                                    **
** TBlock                                                             **
**                                                                    **
**	This routine keeps track of blocking level                        **
**                                                                    **
**	If Blocking is non zero, multitasking swapping is blocked         **
**                                                                    **
**                                                                    **
***********************************************************************/

extern "C" void TBlock(void)
{
	++Blocking;
}

/***********************************************************************
**                                                                    **
** TRelease                                                           **
**                                                                    **
** This routine keeps track of blocking level                         **
**                                                                    **
** If Blocking is non zero, mulitasking swapping is blocked           **
**                                                                    **
***********************************************************************/

extern "C" void TRelease(void)
{
	--Blocking;
}

/***********************************************************************
**
** TYeild
**
** Give up control of cpu to next highest priority task
**
***********************************************************************/

extern "C" void TYeild(void)
{
	int sr;

	sr = EnterCritical();
	if(ActiveTasks->Delete((void **)&ReadyTask))
	{
		ActiveTasks->Insert(CurrentTask);
		asm(" trap #0");		//do context swap
	}
	ExitCritical(sr);
}

/***********************************************************************
**
** TDelay
**
** Give up control of cpu for 'time' system clock ticks
**
***********************************************************************/

extern "C" int TDelay(int time)
{
	int error;
	static unsigned delaycount=0;
	char *s = new char[256];

    sprintf(s,"TDelay%u",delaycount++);
	TSemaphore *d = new TSemaphore(0,1,s);
	if((error = d->Pend(time)) == EVENT_TIMEOUT)
		error = 0;
	delete d;
	delete[]s;
    return error;
}

/***************************************************************************
**                                                                        **
** TSemaphore Base Class Function Definitions                             **
**                                                                        **
** Class Public Memeber Functions:                                        **
**                                                                        **
**	TSemaphore(int InitCount,int mode,char *name);	//constructor         **
**	~TSemaphore();									//destructor          **
**	virtual int Pend(int Timeout);                                        **
**	virtual int Post(int Value);                                          **
**	virtual int GetCount(void);                                           **
**	virtual void SetCount(int Count);                                     **
**                                                                        **
** Semaphore is named to make debugging just a little easier, maybe.      **
**                                                                        **
***************************************************************************/

TSemaphore::TSemaphore(int InitCount,int Mode,char *n)
{
	int sr;

	EventCount = InitCount;
	SemaphoreMode = Mode;
	name = new char[strlen(n)+1];	//allocate space for semaphore name
	strcpy(name,n);					//copy name in
	task_h = 0;						//no tasks waiting
	task_t = 0;						//no tasks waiting
	//------------------------------------
	// put new semaphore into master list
	//------------------------------------
	sr = EnterCritical();	//do not disturbe this process
	if(MasterList)	//is list already started?
	{
		Mnext = MasterList;		//make current head, next in line
		Mprev = 0;				//there is no previous entry
		MasterList->Mprev = this;	//this will be prev for next entry
		MasterList = this;		//this is now the new head of list
	}
	else			//No, start list
	{
		MasterList = this;
		Mnext = 0;	//nothing follows
		Mprev = 0;	//nothing preceeds
	}
	//-------------------------------------------------------
	// if Mode==1, then put this semaphore into timeout list
	//-------------------------------------------------------
	if(SemaphoreMode == 1)
	{
		if(TimeoutList)	//is list already started?
		{
			Tnext = TimeoutList;	//make current head next in line
			Tprev = 0;			//these is no previous entry
			TimeoutList->Tprev = this;	//this will be prev for next entry
			TimeoutList = this;			//this is now the new head of list
		}
		else			//no start list
		{
			TimeoutList = this;
			Tnext = 0;
			Tprev = 0;
		}
	}
	ExitCritical(sr);	//restore interrupts
}

TSemaphore::~TSemaphore()
{
	int sr;

	delete[] name;		//free up space used by semaphore name
	//---------------------------------------------
	// remove this instance from the master lists
	//---------------------------------------------
	sr = EnterCritical();	//don't want to mess this up
	if(this == MasterList)	//is it really the head pointer?
		MasterList = Mnext;	//new head of list
	if(Mprev)
		Mprev->Mnext = Mnext;
	if(Mnext)
		Mnext->Mprev = Mprev;
	//-----------------------------------------------------
	// if timeout mode, remove instance from timeout list
	//-----------------------------------------------------
	if(SemaphoreMode)
	{
		if(this == TimeoutList)
			TimeoutList = Tnext;
		if(Tprev)
			Tprev->Tnext = Tnext;
		if(Tnext)
			Tnext->Tprev = Tprev;
	}
	ExitCritical(sr);
}

int TSemaphore::Pend(int Timeout)	//wait for semaphore availiable
{
	int sr;
	int retval;
	sr = EnterCritical();
	if(EventCount-- > 0)	/*	is resource availiable?	*/
	{
		/*	yes	*/
		ExitCritical(sr);
		retval = EVENT_NOERROR;	//everything is peachy
	}
	else
	{
		/*	no	*/
		if(!task_h)		//make linked list of waiting tasks
			task_h = CurrentTask;
		else
			task_t->next = CurrentTask;
		task_t = CurrentTask;
		CurrentTask->status = EVENT_NOERROR;
		if(SemaphoreMode)
			CurrentTask->timeout = Timeout;

		//swap out current task

		CurrentTask->TimeStamp = TSemaphore::TStamp;	//set the time stamp
		if(ActiveTasks->Delete((void **)&ReadyTask))	//get highest priority task
		{
			ReadyTask->TcbSwaps++;
			asm(" trap #0");                            //do context swap
		}
		else
		{
			CurrentTask->status = EVENT_NOTASKS;
		}
		//-----------------------
		// Pend is over, check status
		//-----------------------

		ExitCritical(sr);
		retval = CurrentTask->status;	//return this value
	}
	return retval;
}

int TSemaphore::Post(int Value)	//signal semaphore availiable
{
	TCB *t;
	int sr;

	sr = EnterCritical();
	if(EventCount < 32766)	//is it going to overflow??
	{
		if(EventCount++ >= 0)	//increment semaphore
		{
			ExitCritical(sr);
		}
		else
		{
			if(task_h)				//is there really a task waiting?
			{
				t = task_h;		//get first task in
				task_h = t->next;       //remove from list
				t->next = (TCB *)0;
				t->status = Value;			//return this value
				ActiveTasks->Insert(t);	//put task back onto active list
				ExitCritical(sr);
				Schedule();
			}
			else
			{
				ExitCritical(sr);
			}
		}
		return EVENT_NOERROR;
	}
	else
	{
		ExitCritical(sr);
		return(EVENT_OVERFLOW);
	}
}

int TSemaphore::GetCount(void)		//get event count
{
	return EventCount;
}

void TSemaphore::SetCount(int C)	//set event count
{
	EventCount = C;
}

void TSemaphore::Timeout(void)			//checks timeout of all semaphores
{
	//**************************************************************
	//
	// This function replaces TimerTicker
	//
	//**************************************************************

	int sr;
	++TSemaphore::TStamp;
	//we need to process the list of tasks waiting
	//for queues
	TSemaphore *e;
	TCB *t,**prev;

	sr = EnterCritical();
	for(e = TimeoutList;e;e=e->Tnext)	//go through whole list
	{
		for(prev = &(e->task_h),t = e->task_h;t;)
		{
			if(t->timeout > 0)	//if less than zero, infinate timeout
			{
				if( --(t->timeout) <= 0)	//decrement timeout counter
				{
					t->status = EVENT_TIMEOUT;	//event caused by semaphore
					*prev = t->next;
					t->next = 0;
					ActiveTasks->Insert(t);
				}
			}
			prev = &(t->next);
			t = t->next;
		}
	}
	ExitCritical(sr);
}

TCB *TSemaphore::RemoveTask(TCB *task)
{
	/***************************************************************\
	**                                                             **
	** This function searches through the master list of semaphores**
	** looking for the specified task.  If the task is found, it is**
	** removed from the waiting list of the semaphore.             **
	** returns NULL if task is not found                           **
	**                                                             **
	****************************************************************/
	int sr;
	TSemaphore *e;
	TCB *t,**prev;

	sr = EnterCritical();		//don't want to be bothered when doin this
	for(e = MasterList;e;e = e->Mnext)	//go through all of the semaphores
	{
		for(prev = &(e->task_h),t = e->task_h;t;prev=&(t->next),t = t->next)
		{
			if(t == task)	//is this the task we are looking for?
			{
				*prev = t->next;	//remove task from list
				t->next = 0;
				goto exit;
			}
		}
	}
	t = 0;	//did not find task, return NULL
exit:
	ExitCritical(sr);
	return t;
}

void TSemaphore::PrintInfo(void)
{
	//-------------------------------------------
	// print semaphore info for debug purposes
	//-------------------------------------------
	char *s = new char[256];
	int c;
	int i;
	TCB *t;
	extern int ConsolHandle;	//global handle for debug consol

	c = sprintf(s,"SEMAPHORE:%s\r\n",name);
	Write(ConsolHandle,s,c);
	c = sprintf(s,"\tEventCount:%d\r\n",EventCount);
	Write(ConsolHandle,s,c);
	for(i=1,t = task_h;t;++i,t = t->next)
	{
		c=sprintf(s,"TASK%d:%s\r\n",i,t->name);
		Write(ConsolHandle,s,c);
	}
	Write(ConsolHandle,"--------------------------------\r\n",34);
	delete[] s;
}

TSemaphore *TSemaphore::FindSemaphore(char *n)
{
	TSemaphore *e;
	int sr = EnterCritical();
	for(e = MasterList;e;e=e->Mnext)
	{
		if(strcmp(n,e->name) == 0)
			goto exit;
	}
exit:
	ExitCritical(sr);
	return e;
}

int TSemaphore::SendKill(TCB *task)
{
	/*******************************************************************\
	** Send a Message to a task waiting at a semaphore to kill itself  **
	**                                                                 **
	** returns 0 on success                                            **
	** returns non zero on fail                                        **
	**                                                                 **
	** scans entire list of semaphores, when task is located, will post**
	** a message to that task to kill itself                           **
	**                                                                 **
	********************************************************************/
	TSemaphore *e;
	TCB *t,**prev;
	int sr = EnterCritical();
	int retval = 1;

	for(e = MasterList;e;e = e->Mnext)	//go through all of the semaphores
	{
		for(prev = &(e->task_h),t = e->task_h;t;prev=&(t->next),t = t->next)
		{
			if(t == task)	//is this the task we are looking for?
			{
				*prev = t->next;	//remove task from list
				t->next = 0;
				t->status = EVENT_TERMINATE;	//return this value
				ActiveTasks->Insert(t);	//put task back onto active list
				retval = 0;
				goto exit;
			}
		}
	}
exit:
	ExitCritical(sr);
	return retval;
}

TSemaphore *TSemaphore::FindTask(TCB *task)
{
	/******************************************************************
	**
	** find the semaphore that "task" is waiting for
	**
	******************************************************************/
	TSemaphore *e;
	TCB *t;
	int sr = EnterCritical();

	for(e = MasterList;e;e = e->Mnext)	//go through all of the semaphores
	{
		for(t = e->task_h;t;t = t->next)
		{
			if(t == task)
				goto exit;
		}
	}
exit:
	ExitCritical(sr);
	return e;
}
