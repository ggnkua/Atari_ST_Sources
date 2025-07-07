#ifndef STACK_H
#define STACK_H

#ifndef _STCK_SIZE
#define _STCK_SIZE 4096L
#endif

long _STKSIZ = 256L;          /* reduce pre-defined stack to minimum */

char _stack[_STCK_SIZE];      /* define own stack */
char *_topstack = _stack + _STCK_SIZE;
long _oldstack;

void new_stack()
{
     asm("unlk      a6");               /* restore original stack */
     asm("move.l    (sp)+,d0");         /* get return address from stack */
     asm("move.l    sp,__oldstack");    /* store old stack pointer value */
     asm("move.l    __topstack,sp");    /* set stack pointer to user stack */
     asm("move.l    d0,-(sp)");         /* place return address onto stack */
     asm("rts");                        /* return to caller */
}

void old_stack()
{
     asm("unlk      a6");               /* restore original stack */
     asm("move.l    (sp)+,d0");         /* get return address from stack */
     asm("move.l    __oldstack,sp");    /* set stack pointer to old stack */
     asm("move.l    d0,-(sp)");         /* place return address onto stack */
     asm("rts");                        /* return to caller */
}

#endif STACK_H
