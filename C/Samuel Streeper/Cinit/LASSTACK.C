/* sstack.c */

#define STACKSIZE (6*1024)
long _stksize = STACKSIZE;
char _stack[STACKSIZE+2];
