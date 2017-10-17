/********************************************
** header file for TASK
********************************************/

#ifndef TASK__H
#define TASK__H

#include "erorcode.h"
#include "pq.h"

//system defines


#define MAX_TASKS	32		//maximum number of tasks (arbitrary)

/*------------------------------------------------------------------
** Definition of a Task Control Block (TCB)
**----------------------------------------------------------------*/

typedef struct tcb {
	int *stack;			/*	points to current position in stack	*/
	int *stacktop;		/*	points to the end of the stack		*/
	char *datamem;		/*	pointer to relative data memory		*/
	int stacksize;		/*	SIZE of the stack in words			*/
	int tasktype;		/*	absolute or relative data			*/
	int priority;		/*	task priority	*/
	int status;			/*	task status, set by semaphore mostly	*/
	long TimeStamp;		/*	system time stamp, set when swapped	*/
	long TcbSwaps;		/*	number of times tasks swapped in	*/
	int timeout;        /*	timeout counter to trigger event	*/
	char *name;			/*	name of task	*/
	struct tcb *next;
	struct tcb *list;	/*	master linked list of tasks	*/
} TCB;


#define TCB_ABSOLUTE	0	//absolute memory references
#define TCB_RELATIVE	1	//RElative memory references

/*------------------------------------------------------------------
**
** Event Control Block
**
**-----------------------------------------------------------------*/

class TSemaphore {
	int SemaphoreMode;		//mode of semaphore
	static TSemaphore *MasterList;	//head pointer for master semaphore list
	static TSemaphore *TimeoutList;	//head pointer for timeout semaphore list
	char *name;
	TSemaphore *Mnext,*Mprev;	//Link list pointers for master list
	TSemaphore *Tnext,*Tprev;	//Link list pointers for timeout list
protected:
	int EventCount;			//counter for semaphore
	TCB *task_h;		//head pointer for list of waiting tasks
	TCB *task_t;		//tail pointer for list of waiting tasks
public:
	TSemaphore(int InitCount,int Mode,char *name);
	~TSemaphore();
	virtual int Pend(int Timeout=0);	//wait for semaphore availiable
	virtual int Post(int Value=0);	//signal semaphore availiable
	virtual int GetCount(void);		//get event count
	virtual void SetCount(int C);	//set event count
	static void Timeout(void);			//checks timeout of all semaphores
	static TCB *RemoveTask(TCB *task);	//remove waiting task from list of semaphores
	static int SendKill(TCB *task);		//send a kill message to a task
	static long TStamp;			//time stamp variable
	virtual void PrintInfo(void);		//print semaphore info
	static TSemaphore *FindSemaphore(char *name);
	static TSemaphore *FindTask(TCB *task);	//find semaphore that task is waiting for
};

//semaphore contructor modes
#define TSEMAPHORE_MODE_WAIT		0
#define TSEMAPHORE_MODE_TIMEOUT		1

//--------------------------------------------------------------------
/* global variables	*/
//--------------------------------------------------------------------

extern PQ *ActiveTasks;		//priority queue of active tasks
extern TCB *MasterTaskList;			//list of all tasks
extern TCB *CurrentTask;	//Current Task executing
extern TCB *ReadyTask;		//task that is ready to execute
extern int InterruptCount;
extern int Blocking;		//Blocking count, if true swaps blocked

/**************************************************************************
**                                                                       **
** Function Prototypes                                                   **
**                                                                       **
**************************************************************************/

#ifdef __cplusplus
extern "C" {
#endif

extern TCB *CreateTask(void (*task)(void),int stacksize,int priority,char *name);
extern TCB *CreateRelTask(void (*task)(void *),int stacksize,int priority,char *name,char *initdata,int dsize,int rsize,void *param);
extern int TDelete(TCB *task);		//delete task
extern void EnterInterrupt(int level);	//called when interrupt routine entered
extern void ExitInterrupt(void);	//called when interrupt routine exited
extern void Swap(void);				//Context Swap (do not use)
extern void IrqSwap(void);			//Context swap for interrupt (do not use)
extern void Schedule(void);			//re schedule task (do not use)
extern void InitOS(void);			//Initialize Kernel
extern void Start(void);			//Start Multitasking
extern int EnterCritical(void);		//enter critical area
extern void ExitCritical(int);		//exit critical area
extern void TBlock(void);           //Block context swaps
extern void TRelease(void);			//unblock context swap
extern void TYeild(void);			//current tasks yield to next priority task
extern int TDelay(int time);		//delay a task for a period of time

extern void InitDisable(void);		//initialize semaphore to prevent
									//re-entrancy to malloc/free
extern void Disable(void);			//Pend on semaphore if malloc in use
extern void Enable(void);			//Post semaphore when malloc done

#ifdef __cplusplus
}
#endif

#endif
