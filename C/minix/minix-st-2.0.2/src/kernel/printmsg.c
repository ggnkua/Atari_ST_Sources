
#include "kernel.h"
#include <signal.h>
#include <unistd.h>
#include <sys/sigcontext.h>
#include <sys/ptrace.h>
#include <minix/boot.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"
#if (CHIP == INTEL)
#include "protect.h"
#endif

void printmsg(type, mptr)
int type;
message *mptr;
{
  switch (type) {
    case SYS_FORK:
    	printf("SYS_FORK: rpp=%d, rpc=%d, pid=%d, ch_clicks=%x\n",
    		mptr->PROC1, mptr->PROC2, mptr->PID, (phys_clicks)mptr->m1_p1);
    	break;
    case SYS_EXEC:
    	printf("SYS_EXEC: pid=%d, pc=%lx, sp=%lx, trc=%x",
    		mptr->PROC1, mptr->IP_PTR, mptr->STACK_PTR, mptr->PROC2);
    	if (mptr->NAME_PTR) printf(", %s\n", mptr->NAME_PTR);
    	printf("\n");
	break;
    case SYS_XIT:
    	printf("SYS_XIT: par=%d, pslot=%d\n", mptr->PROC1, mptr->PROC2);
    	break;
    case SYS_FRESH:
    	printf("SYS_FRESH: pslot=%d, m1_i2=%x\n", mptr->PROC1, mptr->m1_i2);
    	break;
    case SYS_KILL:
    	printf("SYS_KILL: PR=%d, SIG=%d\n", mptr->PR, mptr->SIGNUM);
    	break;
    case SYS_ENDSIG:
    	printf("SYS_ENDSIG: pslot=%d\n", mptr->PROC1);
	break;
    default:
    	break;
  }
  return;
}
