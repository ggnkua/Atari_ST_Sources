#include <string.h>
#include "queue.h"

//**************************************************************************
//
// This file contains the definitions for the various message queues that
// are needed by the teletrac spindle controller board.
// All of these queues are derived from TSemaphore in task.h
//
//
//**************************************************************************

//--------------------------------------------------------------------------
// Class Definitions
// Class BQueue
// A queue of buffers
//
// This class creates a queue of buffers.  It is used by devices that
// need to send out atomic blocks of data.
//--------------------------------------------------------------------------

BQueue::BQueue(int size,int qsize,char *name):TSemaphore(0,TSEMAPHORE_MODE_WAIT,name)
{
	int i;
	Head = 0;
	nObj = 0;
	Tail = 0;
	Buff = new char * [qsize];		//allocate pointer array to buffers
	BTail = new int[qsize];			//allocate array of Tail pointers
	BnChars = new int[qsize];		//allocate array of Char Count
	Qsize = qsize;
	Size = size;
	for(i=0;i<Qsize;++i)
		Buff[i] = new char[Size];	//allocate buffers
}

BQueue::~BQueue()
{
	int i;

	for(i=0;i<Qsize;++i)
		delete[] Buff[i];
	delete[] BnChars;
	delete[] BTail;
	delete[] Buff;
}

int BQueue::SendMessage(char *m,int c)
{
	//------------------------------------------------------------
	// this function puts the message pointed to by m into first
	// availiable buffer.  Then the semaphore is posted
	// individual buffers are not circular, so no head pointers
	// are required for individual buffers
	// returns 0 on success, negative value on fail
	//------------------------------------------------------------
	TCB *t;

	int retval = -1;
	int sr = EnterCritical();	//disable interrupts for time being
	if(nObj < Qsize)
	{
		++Head;                 //PREincrement Head Pointer
		if(Head == Qsize)
			Head = 0;			//wrap Head Pointer
		++nObj;                 //increment number of messages in buffer
		memcpy(Buff[Head],m,c);	//copy data into buffer
		BnChars[Head] = c;		//set number of characters
		BTail[Head] = 0;		//set tail pointer to begining of message
		retval = 0;
		if(task_h)				//is there really a task waiting?
		{
			t = task_h;		//get first task in
			task_h = t->next;       //remove from list
			t->next = (TCB *)0;
			t->status = EVENT_NOERROR;			//return this value
			ActiveTasks->Insert(t);	//put task back onto active list
			ExitCritical(sr);
			Schedule();
		}
		else
		{
			ExitCritical(sr);
		}
	}
	else
		ExitCritical(sr);		//enable interrupts
	return retval;
}

int BQueue::GetMessage(void)
{
	//------------------------------------------------------------
	// Gets a character from the current buffer
	// returns -1 when message is empty (does not cause pend)
	//------------------------------------------------------------
	unsigned char *b = (unsigned char *)Buff[Tail];
	int retval = -1;		//assume end of buffer
	if(BnChars[Tail] > 0)
	{
		retval = b[BTail[Tail]++];
		//-------------------------------------------
		//The buffers are not circular buffers
		// no wrap is needed
		//-------------------------------------------
		BnChars[Tail]--;
	}
	return retval;		//return value
}

int BQueue::WaitMessage(void)
{
	//------------------------------------------------------------
	// Wait for a message to be sent
	// if head == tail, pend on message
	//------------------------------------------------------------
	int retval = EVENT_NOERROR;				//assume success
	int sr = EnterCritical();	//disable interrupts
	if(nObj)					//is a message waiting?
	{
		nObj--;
		Tail++;					//preincrement tail pointer
		if(Tail == Qsize)		//do we need to wrap
			Tail = 0;			//wrap tail pointer
		ExitCritical(sr);		//enable interrupts
	}
	else
	{
		//-----------------------------------------------------------
		// there are no messages waiting, so pend on message posted
		// and switch to another task
		//-----------------------------------------------------------
		/*	no	*/
		if(!task_h)		//make linked list of waiting tasks
			task_h = CurrentTask;
		else
			task_t->next = CurrentTask;
		task_t = CurrentTask;
		CurrentTask->status = EVENT_NOERROR;
		CurrentTask->TimeStamp = TSemaphore::TStamp;
		if(ActiveTasks->Delete((void **)&ReadyTask))	//get highest priority task
		{
			ReadyTask->TcbSwaps++;
			asm(" trap #0");				//do context swap
			//---------------------------------------------------
			// This is where we end up when task is restarted
			// Set up Tail pointer and return
			//---------------------------------------------------
			nObj--;
			Tail++;
			if(Tail == Qsize)
				Tail = 0;
		}
		else
		{
			retval = -1;	//indicate some sort of error
		}
		ExitCritical(sr);
		retval = CurrentTask->status;	//return this value
	}
	return retval;
}


//--------------------------------------------------------------------------
// Class Definitions
// Class Wait
// Not much different from TSemaphore.  It just doesn't support timeouts
//--------------------------------------------------------------------------

Wait::Wait(int count,char *name):TSemaphore(count,TSEMAPHORE_MODE_WAIT,name)
{
	value = 0;
}

Wait::~Wait()
{
}

int Wait::Pend(int timeout)
{
	int retval = TSemaphore::Pend(timeout);
	if(retval > 0) retval = value;
	return retval;
}

int Wait::Post(int v)
{
	TCB *t;
	int sr;

	value = v;
	return TSemaphore::Post(v);
}

//--------------------------------------------------------------------------
// Class Definitions
// Message QUEUE class
//
// Basically an "int" pipe to connect data between tasks
//--------------------------------------------------------------------------

MessageQueue::MessageQueue(int size,int mode,char *name):TSemaphore(0,mode,name)	//constructor Function
{
	Buff = new int[size];
	Head = 0;
	Tail = 0;
	nChars = 0;
	Size = size;
}

MessageQueue::~MessageQueue()
{
	if(Buff)
		delete[] Buff;	//destroy Buffer
}

int MessageQueue::Post(int v)
{
	return TSemaphore::Post(v);
}

int MessageQueue::Pend(int timeout)
{
	return TSemaphore::Pend(timeout);
}

int MessageQueue::Get(void)
{
	int retval;
	int sr;

	if(nChars)
	{
		sr = EnterCritical();
		retval = Buff[Tail++];
		if(Tail >= Size)
			Tail = 0;		//wrap tail pointer
		--nChars;
		ExitCritical(sr);
	}
	else
		retval = -1;
	return retval;
}

int MessageQueue::Put(int c)
{
	int retval = c;
	int sr;

	sr = EnterCritical();
	if(nChars < Size)
	{
		Buff[Head++] = c;
		if(Head >= Size)
			Head = 0;		//wrap head pointer
		++nChars;			//increment number of characters
	}
	else
		retval = -1;		//could not put character into buffer
	ExitCritical(sr);
	return retval;
}

long MessageQueue::GetLong(void)
{
	//-------------------------------------
	// A way of sending a long through the
	// data pipe
	//-------------------------------------
	union {
		long retval;
		int i[2];
	} convert;

	int sr;

	sr = EnterCritical();
	if(nChars > 1)	//are there at least 2 words?
	{
		convert.i[0] = Buff[Tail++];
		if(Tail >= Size) Tail = 0;
		convert.i[1] = Buff[Tail++];
		if(Tail >= Size) Tail = 0;
		nChars -= 2;
	}
	ExitCritical(sr);
	return convert.retval;
}

int MessageQueue::PutLong(long c)
{
	//--------------------------------
	// a way to send a long through
	// the data pipe
	//--------------------------------
	union {
		long v;
		int i[2];
	}convert;
	int retval=0,sr;

	convert.v = c;
	sr = EnterCritical();
	if(nChars < (Size-1)) 	//is there space for two ints?
	{
		Buff[Head++] = convert.i[0];
		if(Head >= Size) Head = 0;
		Buff[Head++] = convert.i[1];
		if(Head >= Size) Head = 0;
		nChars += 2;
	}
	else
		retval = -1;
	ExitCritical(sr);
	return retval;
}

int MessageQueue::QueueStatus(void)
{
	return nChars;
}

int MessageQueue::Space(void)
{
	return Size-nChars;
}

void MessageQueue::Flush(void)
{
	Head = 0;		//get rid of all of the data
	nChars = 0;
	Tail = 0;
}

//-------------------------------------------------------------------------
// Event Queue
//
// This is different from the Message Queue in that this is used when a
// Timeout in not desired.  This will help cut down on the overhead
// involved in using a semaphore.  Only one task can wait on an Event Queue,
// but many tasks can post to one.
//-------------------------------------------------------------------------

EventQueue::EventQueue(int size,char *name):TSemaphore(0,TSEMAPHORE_MODE_WAIT,name)	//constructor function
{
	Buff = new char[size];
	Head = 0;
	Tail = 0;
	nChars = 0;
	Size = size;
}

EventQueue::~EventQueue()
{
	if(Buff)
		delete[] Buff;
}

int EventQueue::Post(int v)
{
	//this member function both writes data into the queue and performs
    return TSemaphore::Post(v);
}


int EventQueue::PostMessage(int *d,int c)
{
	//this member function both writes data into the queue and performs a post
	TCB *t;
	int sr;

	sr = EnterCritical();
	if(EventCount < 32766)	//is it going to overflow??
	{
		//-----------------------
		//write data into queue
		//-----------------------
		while(c)
		{
			if(nChars < Size)
			{
				Buff[Head++] = (char)*d++;
				if(Head >= Size)
					Head = 0;		//wrap head pointer
				++nChars;			//increment number of characters
			}
			else
			{
				ExitCritical(sr);
				return EVENT_BUFFFULL;
			}
			--c;
		}
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
				t->status = EVENT_NOERROR;			//return this value
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

int EventQueue::Pend(int v)
{
	return TSemaphore::Pend(v);
}

int EventQueue::Get(void)
{
	int retval;
	int sr;

	if(nChars)
	{
		sr = EnterCritical();
		retval = Buff[Tail++];
		if(Tail >= Size)
			Tail = 0;		//wrap tail pointer
		--nChars;
		ExitCritical(sr);
	}
	else
		retval = -1;
	return retval;
}

int EventQueue::Put(int c)
{
	int retval = c;
	int sr;

	sr = EnterCritical();
	if(nChars < Size)
	{
		Buff[Head++] = (char)c;
		if(Head >= Size)
			Head = 0;		//wrap head pointer
		++nChars;			//increment number of characters
	}
	else
		retval = -1;		//could not put character into buffer
	ExitCritical(sr);
	return retval;
}

int EventQueue::QueueStatus(void)	//number of char in queue
{
	return nChars;
}

int EventQueue::QueueSpace(void)	//how much space left in queue
{
	return Size - nChars;
}

void EventQueue::Kill(void)
{
	int sr;

	sr = EnterCritical();
	nChars = 0;
	Tail = Head;
	ExitCritical(sr);
}

