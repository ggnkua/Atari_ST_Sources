#ifndef _THREADS_H_
#define _THREADS_H_

/* FIX_PC */
typedef void __stdargs ThreadableFunction(void *parm);		/* HR (*)() */

short __stdargs ThreadNew(ThreadableFunction *thread_function, unsigned long stacksize, void *parm, char *name);

#endif