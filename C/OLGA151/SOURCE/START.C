/****************************
 * start.c                  *
 ****************************
 ****************************
 * [1998-06-02, tm]         *
 * - first C version        *
 ****************************/

#include "start.h"
#include "manager.h"


#define VA_START 0x4711



void server_started(int srvID, int clID, int ext4, int ext5, int running)
{
	Server *ps = server;
	Client *pc = clients;
	int found = FALSE;
	
	while (ps)
	{
		if (ps->clID == clID)
		{
			if (ps->srvID == srvID)
			{
				if ((ps->ext4 == ext4) && (ps->ext5 == ext5))
				{
					found = TRUE;
					break;
				}
			}
		}
		
		ps = ps->Next;
	}
	
	if (!found)
	{
		ps = (Server *)malloc(sizeof(Server));
		
		if (ps)
		{
			ps->clID  = clID;
			ps->srvID = srvID;
			ps->ext4  = ext4;
			ps->ext5  = ext5;
			ps->Prev  = NULL;
			ps->Next  = NULL;
			
			if (!server) server = ps;
			else
			{
				Server *psd = server;
				
				while (psd->Next) psd = psd->Next;
				psd->Next = ps;
				ps->Prev = psd;
			}
		}
	}
	
	found = FALSE;
	
	while (pc)
	{
		if (pc->srvID == srvID)
		{
			if (pc->clID == clID)
			{
				found = TRUE;
				break;
			}
		}
		
		pc = pc->Next;
	}
	
	if (!found)
	{
		pc = (Client *)malloc(sizeof(Client));
		
		if (pc)
		{
			pc->srvID   = srvID;
			pc->clID    = clID;
			pc->runFlag = running;
			pc->Prev    = NULL;
			pc->Next    = NULL;
			
			if (!clients) clients = pc;
			else
			{
				Client *pcd = clients;
				
				while (pcd->Next) pcd = pcd->Next;
				pcd->Next = pc;
				pc->Prev = pcd;
			}
		}
	}
}



void olga_start(int *pipe)
{
	long cmdLen = 1L;
	int stID, answ[8];
	char sname[10], *p, *fname = (char *)malloc(512L), *pcmd = *(char **)&pipe[6];
	App *pa = apps;
	
	#ifdef DEBUG
	printf("OLGA: OLGA_START App %i  ",pipe[1]);
	switch(pipe[3])
	{
	case OLS_TYPE:
		printf("OLS_TYPE %c%c",(pipe[5] >> 8) & 0x00ff,pipe[5] & 0x00ff);
		break;
	case OLS_EXTENSION:
		printf("OLS_EXTENSION %c%c%c%c",(pipe[4] >> 8) & 0x00ff,pipe[4] & 0x00ff,(pipe[5] >> 8) & 0x00ff,pipe[5] & 0x00ff);
		break;
	case OLS_NAME:
		printf("OLS_NAME %s",*(char **)&pipe[4]);
		break;
	}
	if (pcmd) printf("  Cmd %s\n",pcmd);
	else
		printf("\n");
	#endif

	answ[6] = 0;

	while (pa)
	{
		if (pa->apID == pipe[1]) break;

		pa = pa->Next;
	}
	
	if ((!pa) || (!fname)) goto _started;
	
	fname[0] = 0;
	
	switch(pipe[3])
	{
	case OLS_TYPE:
		{
			Type *pt = types;
			
			while (pt)
			{
				if (pt->typ == pipe[5])
				{
					strcpy(fname,pt->path);
					expand_path(fname);

					break;
				}
				
				pt = pt->next;
			}
		}
		break;
	
	case OLS_EXTENSION:
		{
			Extension *pe = extensions;
			
			while (pe)
			{
				if (pe->ext5 == pipe[5])
				{
					if (pe->ext4 == pipe[4])
					{
						strcpy(fname,pe->path);
						expand_path(fname);
						
						break;
					}
				}
				
				pe = pe->next;
			}
		}
		break;

	case OLS_NAME:
		strcpy(fname,*(char **)&pipe[4]);
		break;
	}
	
	if (!strlen(fname)) goto _started;
	
	pa->cmdCount++;
	if (pa->cmdCount > CMDMAX) pa->cmdCount = 0;
	
	globalFree(pa->startCmd[pa->cmdCount]);
	
	if (pcmd) cmdLen += strlen(pcmd);

	p = strrchr(fname,'\\');
	if (!p) p = fname;
	else
		p++;
	
	strncpy(sname,p,8L);
	sname[8] = 0;

	p = strchr(sname,'.');
	if (p) *p = 0;

	while (strlen(sname)<8) strcat(sname," ");
	strupr(sname);
	
	stID = appl_find(sname);
	
	if (stID >= 0)
	{
		pa->startCmd[pa->cmdCount] = globalAlloc(cmdLen);
		if (!pa->startCmd[pa->cmdCount]) goto _started;
		
		if (pcmd) strcpy(pa->startCmd[pa->cmdCount],pcmd);
		else
			pa->startCmd[pa->cmdCount][0] = 0;

		answ[0] = VA_START;
		answ[1] = ap_id;
		answ[2] = 0;
		answ[3] = (int)(((long)pa->startCmd[pa->cmdCount] >> 16) & 0x0000ffffL);
		answ[4] = (int)((long)pa->startCmd[pa->cmdCount] & 0x0000ffffL);
		answ[5] = 0;
		answ[6] = 0;
		answ[7] = 0;

		appl_write(stID,16,answ);

		answ[6] = 1;
		
		if ((pipe[3] == OLS_TYPE) || (pipe[3] == OLS_EXTENSION))
			server_started(stID,pipe[1],pipe[4],pipe[5],1);
		else
			server_started(stID,pipe[1],0,0,1);
	}
	else if ((multitos) || (magix))
	{
		int   tmp_drive;
		char *tmp_cwd;
		
		cmdLen++;

		pa->startCmd[pa->cmdCount] = globalAlloc(cmdLen);
		if (!pa->startCmd[pa->cmdCount]) goto _started;
		
		pa->startCmd[pa->cmdCount][0] = cmdLen-2;
		
		if (pcmd) strcpy(&(pa->startCmd[pa->cmdCount][1]),pcmd);
		else
			pa->startCmd[pa->cmdCount][1] = 0;
		
		tmp_drive = Dgetdrv();
		
		tmp_cwd = (char *)malloc(512L);
		if (tmp_cwd) Dgetpath(tmp_cwd,tmp_drive+1);
		
		if (strlen(fname) > 1)
		{
			if (fname[1] == ':') Dsetdrv(toupper(fname[0])-65);
		}

		p = strrchr(fname,'\\');
		if (p)
		{
			char c = *(++p);
			
			*p = 0;
			Dsetpath(fname);
			*p = c;
		}

		if (magix)
			stID = shel_write(1,1,100,fname,pa->startCmd[pa->cmdCount]);
		else
			stID = shel_write(0,1,1,fname,pa->startCmd[pa->cmdCount]);
		
		if (!stID)
		{
			Dsetdrv(tmp_drive);
			if (tmp_cwd) Dsetpath(tmp_cwd);
		}
		else
		{
			answ[6] = 1;
			
			if ((pipe[3] == OLS_TYPE) || (pipe[3] == OLS_EXTENSION))
				server_started(stID,pipe[1],pipe[4],pipe[5],0);
			else
				server_started(stID,pipe[1],0,0,0);
		}
		
		if (tmp_cwd) free(tmp_cwd);
	}

	_started:

	answ[0] = OLGA_ACK;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = pipe[3];
	answ[4] = pipe[4];
	answ[5] = pipe[5];
	answ[7] = OLGA_START;

	appl_write(pipe[1],16,answ);

	if ((pipe[6]) || (pipe[7]))
	{
		answ[3] = 0;
		answ[4] = pipe[6];
		answ[5] = pipe[7];

		appl_write(pipe[1],16,answ);
	}
	
	if (fname) free(fname);
}



void av_started(int *pipe)
{
	char *p = *(char **)&pipe[3];
	App *pa = apps;
	int i;

	if (p)
	{
		while (pa)
		{
			if (pa->cmdCount >= 0)
			{
				for(i=0; i <= pa->cmdCount; i++)
				{
					if (p == pa->startCmd[i])
					{
						globalFree(pa->startCmd[i]);
						pa->startCmd[i] = NULL;
						
						return;
					}
				}
			}

			pa = pa->Next;
		}
	}
}
