/* this structure is needed for the setjmp() and longjmp() functions */

#ifndef SETJMP_H
#define SETJMP_H

typedef	unsigned long	jmp_buf[13];	/* a7, a6, (a7), d2-d7/a2-a5 */

extern int  setjmp();
extern void longjmp();

#endif
