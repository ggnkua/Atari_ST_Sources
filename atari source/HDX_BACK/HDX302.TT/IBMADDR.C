/* ibmaddr.c */
/* 9/13/88 jye. Get addresses of relate to IBM partition dialogues */

#include "obdefs.h"
#include "defs.h"
#include "ibm.h"
#include "hdx.h"
#include "addr.h"
#include "ipart.h"

getibmaddr()

{
/* get addresses of selection dialogues from resource file */

	if (rsrc_gaddr(0, MACHTYPE, &machtype) == 0 
		|| rsrc_gaddr(0, MAXLOGMS, &maxlogms) == 0
		|| rsrc_gaddr(5, NEEDBOOT, &needboot) == 0
		|| rsrc_gaddr(0, SCRPNL, &scrpnl) == 0
		|| rsrc_gaddr(0, EXPPNL, &exppnl) == 0
		|| rsrc_gaddr(0, IBMPNL, &ibmpnl) == 0)		{
			return ERROR;
	}
	return OK;
}
