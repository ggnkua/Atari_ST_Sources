/*****************************************
 *  Object Linking for GEM Applications  *
 *        written by Thomas Much         *
 *****************************************
 *       O L G A - M a n a g e r         *
 *      This software is freeware.       *
 *       Use it at your own risk.        *
 *****************************************
 *     Thomas Much, Gerwigstraže 46,     *
 * D-76131 Karlsruhe, Fax +49 721 622821 *
 *   Thomas.Much@stud.uni-karlsruhe.de   *
 *****************************************
 *       first version:    07.03.1995    *
 *       first C version:  25.05.1998    *
 *       latest update:    16.06.1998    *
 *****************************************/

/* DEBUG: Ausgabe in Datei? */

#include "manager.h"
#include "language.h"
#include "initman.h"
#include "exitman.h"
#include "ole.h"
#include "doc.h"
#include "link.h"
#include "start.h"
#include "id4.h"
#include "notify.h"
#include "idle.h"
#include "getset.h"
#include "getext.h"
#include "getserv.h"


#define CH_EXIT90      90
#define AV_SENDKEY     0x4710
#define AV_PATH_UPDATE 0x4730
#define AV_STARTED     0x4738


int        ap_id,
           menu_id,
           allocmode,
           crashtest  = 1,
           mbar       = 0,
           search     = 0,
           termflag   = 0,
           memprot    = 0,
           magix      = 0,
           multitask  = 0,
           multitos   = 0,
           linkCount  = 0,
           appCount   = 0,
           docCount   = 0;
char      *apName     = NULL;
App       *apps       = NULL;
Link      *links      = NULL;
Document  *docs       = NULL;
Type      *types      = NULL;
Extension *extensions = NULL;
Alias     *aliases    = NULL;
Object    *objects    = NULL;
Note      *notes      = NULL;
Server    *server     = NULL;
Client    *clients    = NULL;




void *globalAlloc(long size)
{
	if (memprot) return(Mxalloc(size,allocmode));
	else
		return(malloc(size));
}



void globalFree(void *p)
{
	if (p)
	{
		if (memprot) Mfree(p);
		else
			free(p);
	}
}



void expand_path(char *p)
{
	if (p)
	{
		if (strlen(p))
		{
			if (p[0] == '$')
			{
				Alias *pal = aliases;
				
				while (pal)
				{
					if (!strcmp(pal->alias,&p[1]))
					{
						strcpy(p,pal->path);
						expand_path(p);
						
						return;
					}
					
					pal = pal->next;
				}
				
				p[0] = 0;
			}
		}
	}
}



void mu_timer(void)
{
	if ((search) && (crashtest))
	{
		char fname[9];
		int type,apid,moreapps;
		App *pad = apps;

		while (pad)
		{
			pad->alive = 0;
			pad = pad->Next;
		}
		
		moreapps = appl_search(0,fname,&type,&apid);
		
		while (moreapps)
		{
			pad = apps;
			
			while (pad)
			{
				if (pad->apID == apid)
				{
					if (!strcmp(pad->apName,fname)) pad->alive = 1;
					break;
				}
				
				pad = pad->Next;
			}

			moreapps = appl_search(1,fname,&type,&apid);
		}
		
		_kick:
		pad = apps;
		
		while (pad)
		{
			if (!pad->alive)
			{
				int pipe[8];
				
				pipe[0] = OLE_EXIT;
				pipe[1] = pad->apID;
				pipe[2] = 0;
				pipe[3] = 0;
				pipe[4] = 0;
				pipe[5] = 0;
				pipe[6] = 0;
				pipe[7] = 0;
				
				ole_exit(pipe);
				
				goto _kick;
			}

			pad = pad->Next;
		}
	}
}



void mu_keybd(int kstat, int key)
{
	if (mbar)
	{
		int answ[8], mbowner = menu_bar(NULL,-1);
		
		#ifdef DEBUG
		printf("OLGA: AV_SENDKEY Stat %i Key %i -> App #%i\n",kstat,key,mbowner);
		#endif
		
		answ[0] = AV_SENDKEY;
		answ[1] = ap_id;
		answ[2] = 0;
		answ[3] = kstat;
		answ[4] = key;
		answ[5] = 0;
		answ[6] = 0;
		answ[7] = 0;
		
		appl_write(mbowner,16,answ);
	}
}



int av_path_update(int *pipe)
{
	App *pad = apps;
	
	while (pad)
	{
		if (pad->apID == pipe[1])
		{
			if (!(pad->Flags & OL_SERVER))
			{
				pipe[0] = OLGA_UPDATE;
				return(1);
			}
		}
		
		pad = pad->Next;
	}

	return(0);
}



void event_loop(void)
{
	int event,
	    dummy,
	    kstat,
	    key,
	    pipe[8];

	do
	{
		event = evnt_multi(MU_MESAG | MU_TIMER | MU_KEYBD,0,0,0,0,0,0,0,0,0,0,0,0,0,pipe,OLGATIMER,0,&dummy,&dummy,&dummy,&kstat,&key,&dummy);

		_again:
		if (event & MU_MESAG)
		{
			switch(pipe[0])
			{
			case AC_OPEN:
				{
					char s[256],si[18];

					strcpy(s,"[0][OLGA v");
					strcat(s,OLGAVERSIONSTR);
					strcat(s,"  Rev ");
					strcat(s,OLGAREVISION);
					strcat(s," (");
					strcat(s,OLGADATE);
					strcat(s,") |");
					strcat(s,MESSAGE_COPYRIGHT);
					strcat(s,itoa(appCount,si,10));
					strcat(s,MESSAGE_APPS);
					strcat(s,itoa(docCount,si,10));
					strcat(s,MESSAGE_DOCS);
					strcat(s,itoa(linkCount,si,10));
					strcat(s,MESSAGE_LINKS);
					
					form_alert(1,s);
				}
				break;
			
			case AP_TERM:
				termflag = 1;
				break;
			
			case AV_PATH_UPDATE:
				if (av_path_update(pipe)) goto _again;
				break;
			
			case OLE_INIT:
				ole_init(pipe);
				break;
			
			case OLE_EXIT:
				ole_exit(pipe);
				break;
			
			case OLGA_UPDATE:
				olga_update(pipe);
				break;
			
			case OLGA_RENAME:
				olga_rename(pipe);
				break;

			case OLGA_LINKRENAMED:
				olga_linkrenamed(pipe);
				break;
			
			case OLGA_OPENDOC:
				olga_opendoc(pipe);
				break;

			case OLGA_CLOSEDOC:
				olga_closedoc(pipe);
				break;
			
			case OLGA_LINK:
				olga_link(pipe);
				break;
				
			case OLGA_UNLINK:
				olga_unlink(pipe);
				break;
				
			case OLGA_BREAKLINK:
				olga_breaklink(pipe);
				break;
				
			case OLGA_START:
				olga_start(pipe);
				break;
				
			case OLGA_GETOBJECTS:
				olga_getobjects(pipe);
				break;

			case OLGA_IDLE:
				olga_idle(pipe);
				break;

			case OLGA_ACTIVATE:
				olga_activate(pipe);
				break;
				
			case OLGA_EMBED:
				olga_embed(pipe);
				break;
			
			case OLGA_REQUESTNOTIFICATION:
				olga_requestnotification(pipe);
				break;
			
			case OLGA_RELEASENOTIFICATION:
				olga_releasenotification(pipe);
				break;
				
			case OLGA_NOTIFIED:
				olga_notified(pipe);
				break;
				
			case OLGA_GETEXTENSION:
				olga_getextension(pipe);
				break;
				
			case OLGA_GETSERVERPATH:
				olga_getserverpath(pipe);
				break;
				
			case OLGA_GETSETTINGS:
				olga_getsettings(pipe);
				break;
				
			case OLGA_ACK:
				olga_ack(pipe);
				break;

			case CH_EXIT90:
				ch_exit(pipe);
				break;
			
			case AV_STARTED:
				av_started(pipe);
				break;
			}
		}
		
		if (event & MU_KEYBD) mu_keybd(kstat,key);
		
		if (event & MU_TIMER) mu_timer();

	} while (!termflag);
}



void main(void)
{
	init_manager();
	event_loop();
	exit_manager();
	exit(0);
}
