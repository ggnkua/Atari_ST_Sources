/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <OSBIND.H>
#include <MINTBIND.H>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <memory.h>
#include <basepage.h>
#include "messages.h"
#include "k_defs.h"
#include "xa_defs.h"
#include "xa_types.h"
#include "XA_GLOBL.H"

void accstart(void);

short shell_write(short mode, short wisgr, short wiscr, char *parm, char *tail)
{
	short real_mode=mode&0xff,x_mode=mode&0xff00;
	short child=0,t,alloced_cmd=FALSE;
	char *run_path,*run_name,*save_tail,*save_cmd,*cmd,*ext;
	XSHELW *x_shell=(XSHELW*)parm;
	XA_CLIENT *new_client;
	
	if (!x_mode)
	{
	
		if (parm)
		{
			cmd=(char*)malloc(strlen(parm)+1);
			if (!cmd)
				return 0;
			strcpy(cmd,parm);
			alloced_cmd=TRUE;
		}else{
			cmd=parm;
		}
	
	}else{
	
		if (x_shell->newcmd)
		{
			cmd=(char*)malloc(strlen(x_shell->newcmd)+1);
			if (!cmd)
				return 0;
			strcpy(cmd,x_shell->newcmd);
			alloced_cmd=TRUE;
		}else{
			cmd=x_shell->newcmd;
		}
	}
	
	DIAGS(("shell_write():\n mode=%x\n cmd=%s\n tail=%s\n",mode,cmd,tail));

	if (real_mode<4)
	{
		save_cmd=(char*)malloc(strlen(cmd)+1);		/* Preserve the details */

		if (!save_cmd)
		{
			free(cmd);
			return 0;
		}

		strcpy(save_cmd,cmd);
		save_tail=(char*)malloc(strlen(tail+1)+1);
		strncpy(save_tail,tail, tail[0]+1);
		save_tail[tail[0]+1]='\0';
			
		for(t=(short)strlen(cmd); (t>-1)&&(cmd[t]!='\\'); t--);	/* Seperate path & name*/
		if (cmd[t]=='\\')
		{
			cmd[t]='\0';
			run_path=cmd;
			run_name=cmd+t+1;
			if (run_path[1]==':')
			{
				Dsetdrv((run_path[0] & ~32) - 'A');
				run_path+=2;
			}
			Dsetpath(run_path);	/* Ensure that client is run from it's correct directory */
								/* - this allows it to find it's resources,etc */
		}else{
			run_name=cmd;
			run_path=NULL;
		}
		
		ext=run_name+strlen(run_name)-4;
	}
	
	switch(real_mode)
	{
		case 0:			
			if (((stricmp(ext,".app"))&&(stricmp(ext,".prg")))==0) {
				wisgr = 1;
			}else if (((stricmp(ext,".acc"))&&(stricmp(ext,".acx")))==0) {
				wisgr = 3;
			} else {
				wisgr = 0;
			}

			switch(wisgr)
			{
				case 1:
					child=(short)Pvfork();	/* Fork off a new process*/
					if (!child)
					{						/* In child here */
						if (x_mode&SW_PSETLIMIT)		/* Limit child's memory? */
							Psetlimit(2,x_shell->psetlimit);

						if (x_mode&SW_UID)				/* XaAES extension - set user id */
							Psetuid(x_shell->uid);

						if (x_mode&SW_GID)				/* XaAES extension - set group id */
							Psetgid(x_shell->gid);
	
						Pexec(200,run_name,tail,NULL);	/* Run the new client */
				
						Pterm0();			/* If we reach here, we've failled to execute, so exit */
					}
			
					if (x_mode&SW_PRENICE)				/* Was the child spawned as 'nice'? */
						Prenice(child, (short)x_shell->prenice);

					new_client=Pid2Client(child);
					new_client->client_type=XA_CT_APP;
			
					break;
					
				case 3:	/* Launch ACC */
					{
						BASEPAGE* b=(BASEPAGE*)Pexec(3, run_name, tail, NULL);
		
						Mshrink(b,256 + b->p_tlen + b->p_dlen + b->p_blen);

						b->p_dbase = b->p_tbase;
						b->p_tbase = (char*)accstart;
		
						child = Pexec(104, run_name, b, NULL);

						new_client=Pid2Client(child);
						new_client->client_type=XA_CT_ACC;
						
					}
					break;
			}
			Dsetdrv(XaAES_home_drv);
			Dsetpath(XaAES_home);

			new_client->cmd_name=save_cmd;
			new_client->cmd_tail=save_tail;
			new_client->parent=AESpid;

			return child;
			break;
		case 1:
			switch (wisgr)		/* TOS Launch? Use TOSWIN... */
			{
				case 0:
					{
						int fd;
						char new_cmd[300];
					
						sprintf(new_cmd,"%s %s\\%s %s",run_path, run_path,run_name,tail+1);
						fd = (int)Fopen("U:\\PIPE\\TOSRUN", 2);
						t = (short)strlen(new_cmd) + 1;

						Fwrite(fd, t, new_cmd);
					
						Fclose(fd);
					
						child=0;
						break;
					}
				default:				/* GEM Launch */

					child=(short)Pvfork();	/* Fork off a new process*/
					if (!child)
					{						/* In child here */
#if GENERATE_DIAGS
						Fforce(1,debug_file);			/* Redirect console output */
#endif
						if (x_mode&SW_PSETLIMIT)		/* Limit child's memory? */
							Psetlimit(2,x_shell->psetlimit);
				
						if (x_mode&SW_UID)				/* XaAES extension - set user id */
							Psetuid(x_shell->uid);
						
						if (x_mode&SW_GID)				/* XaAES extension - set group id */
							Psetgid(x_shell->gid);
			
						Pexec(200,run_name,tail,NULL);	/* Run the new client */
		
						Pterm0();			/* If we reach here, we've failled to execute, so exit */
					}
	
					if (x_mode&SW_PRENICE)				/* Was the child spawned as 'nice'? */
						Prenice(child, (short)x_shell->prenice);

					new_client=Pid2Client(child);
					new_client->client_type=XA_CT_APP;
						
					new_client->cmd_name=save_cmd;
					new_client->cmd_tail=save_tail;
					new_client->parent=AESpid;
				
					break;
			}

			Dsetdrv(XaAES_home_drv);
			Dsetpath(XaAES_home);
						
			return child;

			break;
		case 3:
			DIAGS(("launch acc[%s]\n",run_name));
			{
				BASEPAGE* b;
				long p_rtn;
				char full_cmd[300];
					
				sprintf(full_cmd,"%s\\%s",run_path,run_name);
				p_rtn=Pexec(3, full_cmd, tail, NULL);
				
				if (p_rtn<0)
				{
					DIAGS(("launch failled:error=%ld\n",p_rtn));
					break;
				}
				
				b=(BASEPAGE*)p_rtn;
				
				Mshrink((void*)b,256 + b->p_tlen + b->p_dlen + b->p_blen);

				b->p_dbase = b->p_tbase;
				b->p_tbase = (char*)accstart;
		
				child = (short)Pexec(104, run_name, b, NULL);
				
				DIAGS(("child=%d\n",child));
			
				new_client=Pid2Client(child);
				new_client->client_type=XA_CT_ACC;
			}
			break;
		
		case 4:		/* Shutdown system */
			if (wisgr==2)
				shutdown=TRUE;
			break;
		
		case 5:		/* Res change */
			break;
			
		case 6:		/* undefined */
			break;
		
		case 7:		/* broadcast message */
			{
				XA_CLIENT *client;
				short *msg=(short*)parm;
				
				for(client=FirstClient(); client!=NULL; client=NextClient(client))
				{
					if (client->clnt_pipe_rd)
					{
						send_app_message(Client2Pid(client), msg[0], msg[1], msg[3], msg[4], msg[5], msg[6], msg[7]);
					}
				}
			}
			break;
		
		case 8:
		case 9:
		default:
			break;

		
	}

	Dsetdrv(XaAES_home_drv);
	Dsetpath(XaAES_home);
	
	if (alloced_cmd)
		free(cmd);
	
	return 0;
}

