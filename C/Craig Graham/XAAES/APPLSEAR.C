/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <MINTBIND.H>
#include <OSBIND.H>
#include <memory.h>
#include <strings.h>
#include "XA_DEFS.H"
#include "XA_TYPES.H"
#include "XA_GLOBL.H"
#include "K_DEFS.H"
#include "EVNT_MUL.H"

/*
	AES4.0 compatible appl_search
*/
unsigned long XA_appl_search(short clnt_pid, AESPB *pb)
{
	short start_pid,cpid;
	char *fname=(char*)pb->addrin[0];
	
	switch(pb->intin[0])
	{
		case 0:		/* APP_FIRST */
			start_pid=clnt_pid + 1;
			break;
		case 1:		/* APP_NEXT */
			start_pid=((short)clients[clnt_pid].temp) + 1;
			break;
	}
	
	if (start_pid>MAX_PID)
		start_pid=0;
	
							/* find next active client */
	for(cpid=start_pid; !clients[cpid].clnt_pipe_rd; cpid++)
	{
		if (cpid>MAX_PID)
			cpid=0;
	}
	
	if (cpid==clnt_pid)		/* Have we looked at all the clients? */
	{
		pb->intout[0]=0;
	}else{					/* nope - fill in details of found client */
		pb->intout[0]=1;
		
		if (cpid==AESpid)
			pb->intout[1]=1;
		else
			pb->intout[1]=2;
	
		pb->intout[2]=cpid;

		strncpy(fname,clients[cpid].proc_name,8);
		fname[8]='\0';
		
		clients[clnt_pid].temp=(void*)cpid;
	}
	
	return XAC_DONE;
	
}
	