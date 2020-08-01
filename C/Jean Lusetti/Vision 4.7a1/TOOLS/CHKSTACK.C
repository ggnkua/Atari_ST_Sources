/*************************/
/* Stack Checking Module */
/*************************/
#include  "logging.h"
#include "chkstack.h"


static STACK_DATA StackData ;

extern long sGetSP(void) ; /* in CHKSTACK.S */


void CheckStackPointer(void)
{
  long sp = sGetSP() ;

  if ( StackData.firstSP == 0 )
    StackData.firstSP = sp ;

  StackData.SP         = sp ;
  StackData.StackUsage = StackData.firstSP - sp ;
  if ( StackData.StackUsage > StackData.maxStackUsage )
    StackData.maxStackUsage = StackData.StackUsage ;
}

STACK_DATA* GetStackStats(void)
{
  return &StackData ;
}

void LogStackStats(void)
{
  LoggingDo(LL_INFO, "***** Stack Statistics:*****") ;
  LoggingDo(LL_INFO, "Current Stack Pointer: $%p", (void*) StackData.SP) ;
  LoggingDo(LL_INFO, "Current Stack Usage:   %ld bytes", StackData.StackUsage) ;
  LoggingDo(LL_INFO, "Maximum Stack Usage:   %ld bytes", StackData.maxStackUsage) ;
}