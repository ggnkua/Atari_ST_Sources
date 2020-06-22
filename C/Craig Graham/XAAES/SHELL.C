/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "k_defs.h"
#include "xa_globl.h"
#include "shellwrt.h"
#include "xa_defs.h"

unsigned long XA_shell_write(short clnt_pid, AESPB *pb)
{
	XA_CLIENT *client=Pid2Client(clnt_pid),*child;
	short child_id;
	
	child_id=shell_write(pb->intin[0],pb->intin[1],pb->intin[2],(char*)pb->addrin[0],(char*)pb->addrin[1]);
	pb->intout[0]=child_id;
	
	child=Pid2Client(child_id);
	child->parent=clnt_pid;
	
	if ((pb->intin[0]==1)&&(pb->intin[1]==1))
	{
		client->waiting_for=XAWAIT_CHILD;
		return XAC_BLOCK;
	}
	
	return XAC_DONE;
}

unsigned long XA_shell_read(short clnt_pid, AESPB *pb)
{
	char *parent_name=(char*)pb->addrin[0];
	char *tail=(char*)pb->addrin[1];
	short f;
	
	sprintf(parent_name, "%s",clients[clients[clnt_pid].parent].cmd_name);
	
	for(f=0; f<clients[clnt_pid].cmd_tail[0]+1; f++)
		tail[f]=clients[clnt_pid].cmd_tail[f];
	tail[f]=0;
	
	pb->intout[0]=1;
	
	return XAC_DONE;
}

unsigned long XA_shell_find(short clnt_pid, AESPB *pb)
{
	char *kp=getenv("PATH");
	char *fn=pb->addrin[0];
	char path[128],cwd[200];
	long handle;
	short f=0,l,n;
	
/* check the clients home path */
	sprintf(path,"%s\\%s",clients[clnt_pid].home_path,fn);
	handle=Fopen(path,0);
	if (handle>0)
	{
		Fclose(handle);
		sprintf(fn,"%s",path);
		pb->intout[0]=1;
		
		return XAC_DONE;
	}
	
/* check our PATH enviroment variable */
	l=strlen(cwd);
	sprintf(cwd,"%s",kp);
	
	while(f<l)
	{				/* We understand ':', ';' and ',' as path seperators */
		for(n=f; (cwd[n])&&(cwd[n]!=':')&&(cwd[n]!=';')&&(cwd[n]!=','); n++)
			if (cwd[n]=='/') cwd[n]='\\';
		
		cwd[n]='\0';
		
		sprintf(path,"%s\\%s",cwd+f,fn);
		handle=Fopen(path,0);
		if (handle>0)
		{
			Fclose(handle);
			sprintf(fn,"%s",path);
			pb->intout[0]=1;

			return XAC_DONE;
		}
		f=n+1;
	}

/* Last ditch - try the file spec on it's own */
	handle=Fopen(fn,0);
	if (handle>0)
	{
		Fclose(handle);
		pb->intout[0]=1;
		
		return XAC_DONE;
	}

/* Didn't find the file :( */
	pb->intout[0]=0;
	return XAC_DONE;
}

unsigned long XA_shell_envrn(short clnt_pid, AESPB *pb)
{
	char **p=pb->addrin[0];
	char *name=(char*)pb->addrin[1];
	*p=getenv(name);
	
	pb->intout[0]=1;
	
	return XAC_DONE;
}
