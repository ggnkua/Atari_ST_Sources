/**************************
 * ole.c                  *
 **************************
 **************************
 * [1998-06-02, tm]       *
 * - first C version      *
 **************************/

#include "manager.h"
#include "ole.h"
#include "doc.h"
#include "link.h"
#include "notify.h"
#include "language.h"


void find_name(int anID, char *p)
{
	if (p)
	{
		if (search)
		{
			int type, apid, moreapps = appl_search(0,p,&type,&apid);
			
			while (moreapps)
			{
				if (apid == anID) return;

				moreapps = appl_search(1,p,&type,&apid);
			}
			
			p[0] = 0;
		}
		else if (magix)
		{
			p[0] = '?';
			p[1] = 0;
			p[2] = anID;
			p[3] = 0;
			
			appl_find(p);
		}
	}
}



void ole_init(int *pipe)
{
	App *pa = NULL, *pad = apps;
	int answ[8];

	#ifdef DEBUG
	printf("OLGA: OLE_INIT App %i  ",pipe[1]);
	if (pipe[3] & OL_SERVER) printf("Server ");
	if (pipe[3] & OL_CLIENT) printf("Client ");
	if (pipe[3] & OL_PIPES) printf("Pipes ");
	printf(STRING_LEVEL,pipe[4],pipe[5],pipe[6]);
	printf("%c%c\n",((pipe[7] >> 8) & 0x00ff),(pipe[7] & 0x00ff));
	#endif
	
	if (!(pipe[3] & OL_PEER))
	{
		answ[7] = 0;
		goto _nooep;
	}
	
	while (pad)
	{
		if (pad->apID == pipe[1])
		{
			pa = pad;
			break;
		}
	
		pad = pad->Next;
	}
	
	if (!pa)
	{
		pa = (App *)malloc(sizeof(App));
		
		if (pa)
		{
			int i;
			
			pa->apID        = pipe[1];
			pa->cmdCount    = -1;
			pa->enumOLE     = NULL;
			pa->ipaProtocol = 0;
			pa->Prev        = NULL;
			pa->Next        = NULL;

			for(i=0; i<=CMDMAX; i++) pa->startCmd[i] = NULL;
			
			if (!apps) apps = pa;
			else
			{
				pad = apps;
				while (pad->Next) pad = pad->Next;

				pad->Next = pa;
				pa->Prev = pad;
			}
			
			appCount++;
		}
	}
	
	if (pa)
	{
		pa->Flags     = pipe[3];
		pa->Protocol  = pipe[4];
		pa->XAccType  = pipe[7];
		
		find_name(pa->apID,pa->apName);

		answ[7] = 1;
	}
	else
	{
		answ[7] = 0;
	}

	_nooep:
	answ[0] = OLGA_INIT;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = OLGAFLAGS;
	answ[4] = OLGAPROTOCOL;
	answ[5] = 0;
	answ[6] = 0;

	appl_write(pipe[1],16,answ);
}



void ole_exit(int *pipe)
{
	App *pad;

	#ifdef DEBUG
	printf("OLGA: OLE_EXIT App %i\n",pipe[1]);
	#endif

	denotify(pipe[1],0,0);
	unLink(FALSE,FALSE,pipe);
	close_doc(FALSE,pipe);
	server_terminated(pipe[1],0);
	client_terminated(pipe[1]);

	_exit:
	pad = apps;

	while (pad)
	{
		if (pad->apID == pipe[1])
		{
			int i;
			
			for (i=0; i<=CMDMAX; i++) globalFree(pad->startCmd[i]);
			
			if ((!pad->Prev) && (!pad->Next)) apps = NULL;
			else
			{
				if (!pad->Prev) apps = pad->Next;
				else
					pad->Prev->Next = pad->Next;
				
				if (pad->Next) pad->Next->Prev = pad->Prev;
			}

			free(pad);
			appCount--;
			
			goto _exit;
		}

		pad = pad->Next;
	}
	
	if (!appCount)
	{
		if ((multitask) && (_app) && (apName))
		{
			char *p = getenv("OLGAMANAGER");
			
			if (p)
			{
				if (!stricmp(p,apName))
				{
					#ifdef DEBUG
					printf(DEBUG_DEACTIVATED);
					#endif
					
					appl_exit();
					exit(0);
				}
			}
		}
	}
}



void server_terminated(int srvID, int retCode)
{
	int     answ[8];
	Server *ps;
	
	answ[0] = OLGA_SERVERTERMINATED;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = srvID;
	answ[6] = retCode;
	answ[7] = 0;
	
	_again:
	ps = server;
	
	while (ps)
	{
		if (ps->srvID == srvID)
		{
			answ[4] = ps->ext4;
			answ[5] = ps->ext5;
			
			appl_write(ps->clID,16,answ);
			
			goto _free;
		}
		else if (ps->clID == srvID)
		{
			_free:
			
			if ((!ps->Prev) && (!ps->Next)) server = NULL;
			else
			{
				if (!ps->Prev) server = ps->Next;
				else
					ps->Prev->Next = ps->Next;
				
				if (ps->Next) ps->Next->Prev = ps->Prev;
			}

			free(ps);
			goto _again;
		}
		
		ps = ps->Next;
	}
}



void client_terminated(int clID)
{
	int     answ[8];
	Client *pc;

	answ[0] = OLGA_CLIENTTERMINATED;
	answ[1] = ap_id;
	answ[2] = 0;
	answ[3] = clID;
	answ[5] = 0;
	answ[6] = 0;
	
	_again:
	pc = clients;
	
	while (pc)
	{
		if (pc->clID == clID)
		{
			Client *pcd = clients;
			
			answ[4] = 0;
			
			while (pcd)
			{
				if (pcd != pc)
				{
					if (pcd->srvID == pc->srvID) answ[4]++;
				}
			
				pcd = pcd->Next;
			}
			
			answ[7] = pc->runFlag;
			
			appl_write(pc->srvID,16,answ);
			
			goto _free;
		}
		else if (pc->srvID == clID)
		{
			_free:
			
			if ((!pc->Prev) && (!pc->Next)) clients = NULL;
			else
			{
				if (!pc->Prev) clients = pc->Next;
				else
					pc->Prev->Next = pc->Next;
				
				if (pc->Next) pc->Next->Prev = pc->Prev;
			}
			
			free(pc);
			goto _again;
		}
		
		pc = pc->Next;
	}
}



void ch_exit(int *pipe)
{
	#ifdef DEBUG
	printf("OLGA: CH_EXIT App %i  Child %i Code %i\n",pipe[1],pipe[3],pipe[4]);
	#endif

	server_terminated(pipe[3],pipe[4]);
}
