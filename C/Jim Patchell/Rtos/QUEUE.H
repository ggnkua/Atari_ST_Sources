#include "task.h"

#ifndef QUEUE__H
#define QUEUE__H

//--------------------------------------------------------------------
// C++ Classes
//--------------------------------------------------------------------

class BQueue:public TSemaphore {
	char **Buff;	//pointer to an array of character pointers
	int Head;		//head pointer for queue of messages
	int Tail;		//tail pointer for queue of messages
	int nObj;		//number of objects in queue
	int Qsize;		//size of queue
	int Size;		//size of messages
	int *BTail;		//pointer to array of tail pointers
	int *BnChars;	//number of chars in message
public:
	BQueue(int size,int qsize,char *name);
	~BQueue();
	int SendMessage(char *m,int c);	//send a message (does post)
	int GetMessage(void);				//get char from current message
	int WaitMessage(void);				//wait for message (pend)
};


class MessageQueue:public TSemaphore {
	int *Buff;		//buffer where data is stored
	int Head;		//head index
	int Tail;		//tail index
	int nChars;		//number of chars in queue
	int Size;		//size of queue
public:
	MessageQueue(int size,int mode,char *name);	//constructor Function
	~MessageQueue();
	virtual int Post(int v=0);
	virtual int Pend(int timeout=-1);
	int Get(void);
	int Put(int c);
	long GetLong(void);
	int PutLong(long c);
	int QueueStatus(void);
	int Space(void);
	void Flush(void);
};

class EventQueue:public TSemaphore {
	char *Buff;		//buffer where data is stored
	int Head;		//head index
	int Tail;		//tail index
	int nChars;		//number of chars in queue
	int Size;		//size of queue
public:
	EventQueue(int size,char *name);	//constructor function
	~EventQueue();
	int PostMessage(int *d,int c);
	virtual int Post(int v=0);
	virtual int Pend(int t=0);
	int Get(void);
	int Put(int c);
	int QueueStatus(void);	//number of char in queue
	int QueueSpace(void);	//how much space left in queue
	void Kill(void);		//Delete Message from Queue
};

class Wait: public TSemaphore{
	//this is like a semaphore (ECB) but no timeout logic
	//for things where waiting forever is OK
	//these have pretty much zero CPU overhead
	int value;			/*	this could be dangerous	*/
public:
	Wait(int count,char *name);
	~Wait();
	virtual int Pend(int timeout=0);
	virtual int Post(int v=0);
};

#endif
