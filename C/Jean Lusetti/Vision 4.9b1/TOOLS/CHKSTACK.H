#ifndef __CHKSTACK_H
#define __CHKSTACK_H

typedef struct _STACK_DATA
{
  long firstSP ;       /* First stack pointer used for calculations */
  long SP ;            /* Current Stack Pointer                     */
  long StackUsage ;    /* Current stack usage                       */
  long maxStackUsage ; /* Maximum stack usage so far                */
}
STACK_DATA, *PSTACK_DATA ;


void        CheckStackPointer(void) ;
STACK_DATA* GetStackStatistics(void) ;
void        LogStackStats(void) ;

#endif
