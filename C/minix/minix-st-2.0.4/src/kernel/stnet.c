/*
 * dummy network task
 */

#include "kernel.h"
#include <minix/com.h>
#include <minix/callnr.h>

#define	TRACE(x)	/* x */

#if (ENABLE_STNET == 1)
PUBLIC void dp8390_task()
{
  message m, reply;
  int dorep, r;
  char *msg;

  while (TRUE)
  {
	if ((r= receive(ANY, &m)) != OK)
		panic("dp8390: receive failed", r);

	dorep = 1;

	switch (m.m_type)
	{
	case DL_WRITE:	msg = "DL_WRITE";		break;
	case DL_WRITEV:	msg = "DL_WRITEV";		break;
	case DL_READ:	msg = "DL_READ";		break;
	case DL_READV:	msg = "DL_READV";		break;
	case DL_INIT:	msg = "DL_INIT"; dorep = 2;	break;
	case DL_GETSTAT: msg = "DL_GETSTAT";		break;
	case DL_STOP:	msg = "DL_STOP"; dorep = 0;	break;
	case HARD_INT:	msg = "HARD_INT"; dorep = 0;	break;
	default:
		panic("dp8390: illegal message", m.m_type);
	}

	TRACE(printf("dummy dp8390 received %s\n", msg));
	
	if (dorep == 1) {
		reply.m_type = TASK_REPLY;
		reply.REP_PROC_NR = m.DL_PROC;
		reply.REP_STATUS = ENXIO;
		send(m.m_source, &reply);
	}
	if (dorep == 2) {
		reply.m_type= DL_INIT_REPLY;
		reply.m3_i1= ENXIO;
		send(m.m_source, &reply);
	}	
  }
}
#endif /* ENABLE_NETWORKING */
