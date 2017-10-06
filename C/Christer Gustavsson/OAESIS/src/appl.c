/****************************************************************************

 Module
  appl.c
  
 Description
  Application handling routines in oAESis.
  
 Author(s)
 	cg (Christer Gustavsson <d2cg@dtek.chalmers.se>)
 	kkp (Klaus Pedersen) <kkp@gamma.dou.dk>)

 Revision history
 
  960101 cg
   Added standard header.
   Basic version of appl_getinfo implemented.

  960102 cg
   AES_WINDOW mode of appl_getinfo implemented.

  960115 cg
   Appl_get_vid() implemented.
      
  960228 kkp
   Changed the behaviour of TOPAPPL

 Copyright notice
  The copyright to the program code herein belongs to the authors. It may
  be freely duplicated and distributed without fee, but not charged for.
 
 ****************************************************************************/

/****************************************************************************
 * Used interfaces                                                          *
 ****************************************************************************/

#include <alloc.h>
#include <fcntl.h>
#include <mintbind.h>
#include <signal.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <support.h>

#include "appl.h"
#include "debug.h"
#include "evnthndl.h"
#include "gemdefs.h"
#include "mintdefs.h"
#include "menu.h"
#include "mesagdef.h"
#include "misc.h"
#include "rdwrs.h"
#include "types.h"
#include "vdi.h"
#include "wind.h"

/****************************************************************************
 * Macros                                                                   *
 ****************************************************************************/

#define MAX_NUM_APPS 32

#define AES_MESSAGES 12
#define AES_OBJECTS  13
#define AES_FORM     14

/****************************************************************************
 * Module global variables                                                  *
 ****************************************************************************/

static WORD	next_ap = 0;

static AP_INFO apps[MAX_NUM_APPS];

static AP_LIST *ap_resvd = NULL;

/****************************************************************************
 * Local functions (use static!)                                            *
 ****************************************************************************/

/* 
 * Find MiNT-PID & return AP_LIST entry for that 
 */
static AP_LIST *search_mpid(WORD pid)
{
	AP_LIST	*al;

	al = globals.ap_pri;
	
	while(al) 
	{
		if( al->ai->pid == pid) 
			break;
		al = al->next;
	}
	return al;	
}


static WORD do_appl_read(WORD apid,WORD msgpipe,WORD length,void *m) {
	
	if((apid == APR_NOWAIT) && (Finstat(msgpipe) < length)) {
		return 0;
	};
	
	if(Fread(msgpipe,length,m) < 0) {
		return 0;
	};
		
	return 1;
}

void CDECL handle_signal(LONG signal) {
	LONG ret;
	
	switch(signal) {
	case SIGCHLD:
/*
		ret = Pwait();

		DB_printf("Child died. Pid %d. Exit code %d (0x%x)",(WORD)(ret >> 16),(WORD)ret,(WORD)ret);
*/
		break;
	default:
		;
/*
		DB_printf("Unknown signal %ld",signal);
*/
	}
}

/****************************************************************************
 * Public functions                                                         *
 ****************************************************************************/

/****************************************************************************
 * Appl_init_module                                                         *
 *  Initiate the application module.                                        *
 ****************************************************************************/
void                   /*                                                   */
Appl_init_module(void) /*                                                   */
/****************************************************************************/
{
	WORD i;
	
	for(i = 0; i < MAX_NUM_APPS; i++) {
		apps[i].id = -1;
		apps[i].eventpipe = -1;
		apps[i].msgpipe = -1;
		apps[i].rshdr = NULL;
		apps[i].deskbg = NULL;
		apps[i].menu = NULL;
		apps[i].deskmenu = -1;
	};
}

/****************************************************************************
 * Appl_exit_module                                                         *
 *  Shutdown the application module.                                        *
 ****************************************************************************/
void                   /*                                                   */
Appl_exit_module(void) /*                                                   */
/****************************************************************************/
{
	AP_LIST	*al = globals.ap_pri;
		
	while(al) {
		Pkill(al->ai->pid,SIGKILL);
		Mfree(al);
		al = al->next;
	};
}

/****************************************************************************
 * Appl_get_top                                                             *
 *  Get currently topped application.                                       *
 ****************************************************************************/
WORD               /* Id of topped application.                             */
Appl_get_top(void) /*                                                       */
/****************************************************************************/
{
	if(globals.ap_pri) {
		return globals.ap_pri->ai->id;
	}
	else {
		return -1;
	};
}

/****************************************************************************
 * Appl_search_apid                                                         *
 *  Find AES-id & return AP_LIST entry for that.                            *
 ****************************************************************************/
AP_LIST *         /* Entry or NULL.                                         */
Appl_search_apid( /*                                                        */
WORD apid)        /* Application id of the searched application.            */
/****************************************************************************/
{
	AP_LIST	*al;

	al = globals.ap_pri;
	
	while(al) {
		if( al->ai->id == apid) 
			break;
		al = al->next;
	};
	
	return al;	
}

/****************************************************************************
 * Appl_get_deskbg                                                          *
 *  Get the resource tree of the top desktop.                               *
 ****************************************************************************/
OBJECT *               /* Resource tree, or NULL.                           */
Appl_get_deskbg(void)  /*                                                   */
/****************************************************************************/
{
	OBJECT  *retval = NULL;
	AP_INFO *ai;
		
	ai = Appl_internal_info(DESK_OWNER);
		
	if(ai) {
		retval = ai->deskbg;
	};
		
	return retval;
}

/****************************************************************************
 * Appl_set_deskbg                                                          *
 *  Set the resource tree of the desktop of an application                  *
 ****************************************************************************/
WORD              /* 0 if ok or -1.                                         */
Appl_set_deskbg(  /*                                                        */
WORD apid,        /* Id of application.                                     */
WORD vid,         /* VDI workstation id.                                    */
OBJECT *tree)     /* Resource tree.                                         */
/****************************************************************************/
{
	OBJECT *deskbg,*olddeskbg = apps[apid].deskbg;
	
	if(apps[apid].id != -1) {
		apps[apid].deskbg = tree;

		Rdwrs_operation(ASTARTREAD);
		deskbg = Appl_get_deskbg();
		Rdwrs_operation(AENDREAD);
	
		if(((deskbg == tree) && (deskbg != olddeskbg)) || !tree) {
			Wind_update_deskbg(vid);
		};
	
		return 0;
	};

	return -1;
}

/****************************************************************************
 * Appl_get_menu                                                            *
 *  Get the resource tree of the menu of an application                     *
 ****************************************************************************/
OBJECT *          /* Resource tree, or NULL.                                */
Appl_get_menu(    /*                                                        */
WORD apid)        /* Id of application.                                     */
/****************************************************************************/
{
	if(apid == TOP_APPL) {
		if(globals.ap_pri) {
			return globals.ap_pri->ai->menu;
		};
		
		return NULL;
	}
	else if(apid == TOP_MENU_OWNER) {
		OBJECT  *retval = NULL;
		AP_INFO *ai;
		
		ai = Appl_internal_info(TOP_MENU_OWNER);
		
		if(ai) {
			retval = ai->menu;
		};
		
		return retval;
	};
	
	return apps[apid].menu;
}

/****************************************************************************
 * Appl_set_menu                                                            *
 *  Set the resource tree of the menu of an application                     *
 ****************************************************************************/
WORD              /* 0 if ok or -1.                                         */
Appl_set_menu(    /*                                                        */
WORD apid,        /* Id of application.                                     */
OBJECT *tree)     /* Resource tree.                                         */
/****************************************************************************/
{
	if(apps[apid].id != -1) {
		apps[apid].menu = tree;
		return 0;
	};
	
	return -1;
}

/****************************************************************************
 * Appl_set_newmsg                                                          *
 *  Set indication of which messages the application understands.           *
 ****************************************************************************/
WORD              /* 0 if ok or -1.                                         */
Appl_set_newmsg(  /*                                                        */
WORD apid,        /* Id of application.                                     */
WORD newmsg)      /* Messages understood.                                   */
/****************************************************************************/
{
	if(apps[apid].id != -1) {
		apps[apid].newmsg = newmsg;
		return 0;
	};
	
	return -1;
}

/****************************************************************************
 * Appl_top                                                                 *
 *  Top application.                                                        *
 ****************************************************************************/
WORD              /* Previously topped application.                         */
Appl_top(         /*                                                        */
WORD apid,        /* Id of application.                                     */
WORD vid)         /* VDI workstation id.                                    */
/****************************************************************************/
{
	AP_LIST **al;
	OBJECT  *deskbg;
	WORD    deskbgcount = 0;
	WORD    lasttop;
	
	Rdwrs_operation(ASTARTWRITE);
	
	lasttop = globals.ap_pri->ai->id;
	al = &globals.ap_pri;
	
	while(*al) {
		if((*al)->ai->id == apid) {
			AP_LIST *tmp = *al;
			
			*al = (*al)->next;
			
			tmp->next = globals.ap_pri;
			globals.ap_pri = tmp;
			
			deskbg = tmp->ai->deskbg;
			
			break;
		};

		if((*al)->ai->deskbg) {
			deskbgcount++;
		}
		
		al = &(*al)->next;
	};
	
	Rdwrs_quick(AENDWRITE);
	
	if(deskbg && deskbgcount) {
		Rdwrs_operation(WSTARTREAD);
		Wind_update_deskbg(vid);
		Rdwrs_operation(WENDREAD);
	};
	
	return lasttop;
}

/****************************************************************************
 * Appl_put_event                                                           *
 *  Put event message in event pipe                                         *
 ****************************************************************************/
WORD              /*  0 if ok or -1                                         */
Appl_put_event(   /*                                                        */
WORD apid,        /* Id of application that is to receive a message.        */
EVNTREC *m)       /* Message to be sent                                     */
/****************************************************************************/
{
	AP_INFO *ai;
	WORD    retval = 0;

	Rdwrs_operation(ASTARTREAD);

	ai = Appl_internal_info(apid);			

	if(ai) {
		LONG fd = Fopen(ai->eventname,O_WRONLY);

		if(fd >= 0) {
			Fwrite((WORD)fd,sizeof(EVNTREC),m);
			Fclose((WORD)fd);
		}			
		else {
			DB_printf("%s: Line %d:\r\n"
				"Couldn't open event pipe %s. apid=%d error code=%ld\r\n",
				__FILE__,__LINE__,ai->eventname,ai->id,fd);

			retval = -1;
		};
	}
	else
	{
		DB_printf(
			"%s: Line %d: Couldn't find description of top application\r\n",
			__FILE__,__LINE__);

		retval = -1;
	};

	Rdwrs_operation(AENDREAD);

	return retval;
}

/****************************************************************************
 * Appl_internal_info                                                       *
 *  Get internal information about application.                             *
 ****************************************************************************/
AP_INFO *           /* Application description or NULL.                     */
Appl_internal_info( /*                                                      */
WORD apid)          /* Id of application.                                   */
/****************************************************************************/
{
	switch(apid) {
	case TOP_APPL:
		if(globals.ap_pri) {
			return globals.ap_pri->ai;
		}
		else {
			return NULL;
		};

	case DESK_OWNER:
		{
			AP_LIST *al = globals.ap_pri;
			
			while(al) {
				if(al->ai->deskbg) {
					return al->ai;
				};
				
				al = al->next;
			};
		};			
		return NULL;

	case TOP_MENU_OWNER:
		{
			AP_LIST *al = globals.ap_pri;
			
			while(al) {
				if(al->ai->menu) {
					return al->ai;
				};
				
				al = al->next;
			};
		};		
		return NULL;
	
	default:
		if(apps[apid].id == apid) {
			return &apps[apid];
		};
		return NULL;
	};
}

/****************************************************************************
 * Appl_info_alloc                                                          *
 *  Reserve structure of internal application information.                  *
 ****************************************************************************/
AP_INFO *           /* Application description or NULL.                     */
Appl_info_alloc(    /*                                                      */
WORD pid,           /* MiNT process id.                                     */
WORD type)          /* Type of application (appl, acc, desktop etc)         */
/****************************************************************************/
{
	AP_LIST	*al;

	BYTE	s[50];
	
	al = (AP_LIST *)Mxalloc(sizeof(AP_LIST),GLOBALMEM);

	if(!al) {
		DB_printf("%s: Line %d: Appl_info_alloc:\r\n"
										"out of memory!\r\n",__FILE__,__LINE__);
		return NULL;
	};

	while(apps[next_ap].id != -1) {
		next_ap = ((next_ap + 1) % MAX_NUM_APPS);
	};
	
	al->ai = &apps[next_ap];
		
	al->ai->id = next_ap;
	al->ai->pid = pid;
	al->ai->deskbg = NULL;
	al->ai->menu = NULL;
	al->ai->type = type;
	al->ai->newmsg = 0;
	
	sprintf(s,"u:\\pipe\\applmsg.%03x",al->ai->pid);		
	al->ai->msgname = (BYTE *)Mxalloc(strlen(s) + 1,GLOBALMEM);
	strcpy(al->ai->msgname,s);

	sprintf(s,"u:\\pipe\\applevnt.%03x",al->ai->pid);		
	al->ai->eventname = (BYTE *)Mxalloc(strlen(s) + 1,GLOBALMEM);
	strcpy(al->ai->eventname,s);
		
	al->ai->rshdr = 0L;
	
	/* open up a vdi workstation to use in the application */

	if(pid == Pgetpid()) {
		WORD	work_in[] = {1,7,1,1,1,1,1,1,1,1,2};
		WORD	work_out[57];
	
		al->ai->msgpipe = (WORD)Fcreate(al->ai->msgname,0);
		al->ai->eventpipe = (WORD)Fcreate(al->ai->eventname,0);
	
		al->ai->vid = globals.vid;
		Vdi_v_opnvwk(work_in,&al->ai->vid,work_out);

		al->next = globals.ap_pri;
		globals.ap_pri = al;
	}
	else {
		al->next = ap_resvd;
		ap_resvd = al;
	};
	
	return al->ai;
}

void	apinfofree(WORD id) {
	AP_LIST	**al;
	
	al = &globals.ap_pri;
	
	while(*al) {
		if((*al)->ai->id == id) {
			AP_LIST	*altemp = *al;
			
			*al = (*al)->next;
	
			Vdi_v_clsvwk(altemp->ai->vid);
			altemp->ai->vid = -1;
	
			Fclose(altemp->ai->msgpipe);
			altemp->ai->msgpipe = -1;
			Fclose(altemp->ai->eventpipe);
			altemp->ai->eventpipe = -1;
			
			if(altemp->ai->rshdr) {
				Mfree(altemp->ai->rshdr);	/*free resource memory*/
			};

			Mfree(altemp->ai->msgname);
			Mfree(altemp->ai->eventname);
			altemp->ai->id = -1;
			Mfree(altemp);

			break;
		};
		al = &(*al)->next;
	};
}

/* 0x000a appl_init */

/****************************************************************************
 * Appl_do_init                                                             *
 *  Implementation of appl_init().                                          *
 ****************************************************************************/
WORD                   /* Application id, or -1.                            */
Appl_do_init(          /*                                                   */
GLOBAL_ARRAY *global)  /* Global array.                                     */
/****************************************************************************/
{
	AP_INFO	*ai;
	AP_LIST	*al;
	WORD    pid = Pgetpid();
	WORD    apid;

	Psignal(SIGCHLD,(LONG)handle_signal);
	Psignal(SIGQUIT,(LONG)handle_signal);
	Psignal(SIGBUS,(LONG)handle_signal);
	Psignal(SIGSEGV,(LONG)handle_signal);

	Rdwrs_operation(ASTARTWRITE);

	al = search_mpid(pid);

	if(!al) {			/* A process is only allowed to have one apid */
		/* Has an info structure already been reserved? */
		
		AP_LIST **awalk = &ap_resvd;
		
		while(*awalk) {
			if((*awalk)->ai->pid == pid) {
				break;
			};
			
			awalk = &(*awalk)->next;
		};
		
		if(*awalk) {
			WORD	work_in[] = {1,7,1,1,1,1,1,1,1,1,2};
			WORD	work_out[57];
	
			al = *awalk;
			*awalk = al->next;
	
			al->ai->msgpipe = (WORD)Fcreate(al->ai->msgname,0);
			al->ai->eventpipe = (WORD)Fcreate(al->ai->eventname,0);
	
			al->ai->vid = globals.vid;
			Vdi_v_opnvwk(work_in,&al->ai->vid,work_out);

			al->next = globals.ap_pri;
			globals.ap_pri = al;
			
			ai = al->ai;
		}
		else {
			ai = Appl_info_alloc(Pgetpid(),APP_APPLICATION);
		};
	}
	else {
		ai = al->ai;
	};

	if(ai) {
		apid = ai->id;	

		global->version = 0x0410;
		global->numapps = -1;
		global->apid = ai->id;
		global->appglobal = 0L;
		global->rscfile = 0L;
		global->rshdr = 0L;
		global->resvd1 = 0;
		global->resvd2 = 0;
		global->int_info = ai;
		global->maxchar = 0;
		global->minchar = 0;
	}
	else {
		apid = -1;
	};
	
	Rdwrs_operation(AENDWRITE);
	
	if(apid >= 0) {
		BYTE fname[128],cmdlin[128],menuentry[21],*tmp;
		
		Misc_get_loadinfo(128,cmdlin,fname);

		strcpy(menuentry,"  ");
		
		tmp = strrchr(fname,'\\');
		
		if(tmp) {
			tmp++;
		}
		else {
			tmp = fname;
		};
		
		strncat(menuentry,tmp,20);
	 
	 	if(ai->type & APP_APPLICATION) {
			Menu_do_register(ai->id, menuentry);
		};
	};
	
	return apid;
}

void	Appl_init(AES_PB *apb) {
	apb->int_out[0] = Appl_do_init(apb->global);
}

/* 0x000b appl_read */

void	Appl_read(AES_PB *apb) {
	apb->int_out[0] = do_appl_read(apb->int_in[0],
																apb->global->int_info->msgpipe,
																apb->int_in[1],
																(void *)apb->addr_in[0]);
}

/* 0x000c appl_write */

/****************************************************************************
 * Appl_do_write                                                            *
 *  Implementation of appl_write().                                         *
 ****************************************************************************/
WORD           /* 0 if ok, or 1.                                            */
Appl_do_write( /*                                                           */
WORD apid,     /* Id of application to receive message.                     */
WORD length,   /* Length of message structure.                              */
void *m)       /* Pointer to message structure.                             */
/****************************************************************************/
{
	AP_INFO	*ai;
	
	Rdwrs_operation(ASTARTREAD);
	
	ai = Appl_internal_info(apid);
	
	if(ai) {
		LONG	pnr = Fopen(ai->msgname,1);
		
		if(pnr >= 0) {
			if(Fwrite((WORD)pnr,length,m) < 0) {
				Rdwrs_quick(AENDREAD);
				return 0;
			};
			
			Fclose((WORD)pnr);
		}
		else {
			Rdwrs_quick(AENDREAD);
			
			return 0;
		};
	}
	else {
		Rdwrs_quick(AENDREAD);
		return 0;
	};

	Rdwrs_quick(AENDREAD);	

	return 1;
}

void	Appl_write(AES_PB *apb) {
	apb->int_out[0] =	
		Appl_do_write(apb->int_in[0],apb->int_in[1],(void *)apb->addr_in[0]);
}



/****************************************************************************
 * Appl_do_find                                                             *
 *  Implementation of appl_find().                                          *
 ****************************************************************************/
WORD              /* Application id, or -1.                                 */
Appl_do_find(     /*                                                        */
BYTE *fname)      /* File name of application to seek.                      */
/****************************************************************************/
{
	AP_LIST *al;
	LONG    w;
	_DTA    *olddta,newdta;
	BYTE    pname[ 30];

	w = (LONG)fname & 0xffff0000l;
	if(w == 0xffff0000l) {
	/* convert MiNT to AES pid */
		al = search_mpid((WORD)((LONG)fname));
		
		if(al) {
			return al->ai->id;
		};
		
		return -1;
	}
	
	if ( w == 0xfffe0000l)
	{
	/* convert from AES to MINT pid */
		al = Appl_search_apid((WORD)((LONG)fname));
		if(al)
			return al->ai->pid;
		return -1;
	}

/* Now find the pid of process with the passed name */
	olddta = Fgetdta();

	Fsetdta( &newdta);
	w = -1;
	sprintf(pname, "u:\\proc\\%s.*", fname);

	if(Fsfirst(pname, 0) == 0) {
		w = atoi(&newdta.dta_name[9]);
	};

	Fsetdta(olddta);

/* map the MINT-pid to aes */
	if(w != -1) {
		al = search_mpid((WORD)w);

		if(al) {
			return al->ai->id;
		};
	};
	
	return -1;
}

/****************************************************************************
 * Appl_find                                                                *
 *  0x000d appl_find().                                                     *
 ****************************************************************************/
void              /*                                                        */
Appl_find(        /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	if ( apb->addr_in[0] == 0)	/* return our own pid */
		apb->int_out[0] = apb->global->apid;
	else
		apb->int_out[0] = Appl_do_find((BYTE *)apb->addr_in[0]);
}

/****************************************************************************
 * Appl_do_search                                                           *
 *  Implementation of appl_search().                                        *
 ****************************************************************************/
WORD              /* 0 if no more applications exist, or 1.                 */
Appl_do_search(   /*                                                        */
WORD apid,        /* pid of caller..                                        */
WORD mode,        /* Search mode.                                           */
BYTE *sname,      /* Pretty name of found application.                      */
WORD *type,       /* Type of found application.                             */
WORD *ap_id)      /* Application id fo found application.                   */
/****************************************************************************/
{
	AP_LIST *this,*p;

	this = Appl_search_apid(apid);
	
	if(!this) {
		return 0;
	};
	
	switch(mode) {
	case APP_FIRST:
		this->ai->ap_search_next = globals.ap_pri;
	 /* there will always have atleast ourself to return */

	case APP_NEXT:
		p = this->ai->ap_search_next;

		if(!p) {
			return 0;
		};

		strncpy(sname,p->ai->name, 18); /* the 'pretty name' */

		*type =  p->ai->type;           /* sys/app/acc */

		*ap_id = p->ai->id;
		
	/* get the next... */	
		this->ai->ap_search_next = p->next;
		
		return (p->next) ? 1: 0;

	case 2:        /* search system shell (??) */
		DB_printf("Appl_do_search(2,...) not implemented yet.\r\n");
		break;

	default:
		DB_printf("%s: Line %d: Appl_do_search\r\n"
							"Unknown mode %d",__FILE__,__LINE__,mode);
	}
	
	return 0;
}

/****************************************************************************
 * Appl_search                                                              *
 *  0x0012 appl_search().                                                   *
 ****************************************************************************/
void              /*                                                        */
Appl_search(      /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	Rdwrs_operation(ASTARTREAD);
	
	apb->int_out[ 0] = Appl_do_search(apb->global->apid, apb->int_in[0], 
	     (BYTE *)apb->addr_in[0],
	     &apb->int_out[1],
	     &apb->int_out[2]);

	Rdwrs_operation(AENDREAD);
}

/* 0x0013 appl_exit */

/****************************************************************************
 * Appl_do_exit                                                             *
 *  Implementation of appl_exit().                                          *
 ****************************************************************************/
WORD           /* 0 if error, or 1.                                         */
Appl_do_exit(  /*                                                           */
WORD apid,     /* Application id.                                           */
WORD vid)      /* VDI workstation id.                                       */
/****************************************************************************/
{
	/*clean up*/

	Menu_bar_remove(apid);

	Menu_unregister(apid);
	
	Appl_set_deskbg(apid,vid,NULL);

	Wind_do_new(vid,apid);

	Rdwrs_operation(ASTARTWRITE);

	apinfofree(apid);
		
	Rdwrs_operation(AENDWRITE);
	
	Rdwrs_operation(MSTARTWRITE);
	Rdwrs_operation(ASTARTREAD);
	Menu_update_appl();

	Rdwrs_operation(AENDREAD);
	Rdwrs_operation(MENDWRITE);

	return 1;
}

void	Appl_exit(AES_PB *apb) {
	apb->int_out[0] = Appl_do_exit(apb->global->apid,apb->global->int_info->vid);
}

/****************************************************************************
 * Appl_getinfo                                                             *
 *  0x0082 appl_getinfo().                                                  *
 ****************************************************************************/
void              /*                                                        */
Appl_getinfo(     /*                                                        */
AES_PB *apb)      /* AES parameter block.                                   */
/****************************************************************************/
{
	apb->int_out[0] = 1; /* default: return OK ( ret != 0) */

	switch(apb->int_in[0]) {
 	case AES_LARGEFONT: /* 0 */
 		apb->int_out[ 1] = globals.fnt_regul_sz;
 		apb->int_out[ 2] = globals.fnt_regul_id;
 		apb->int_out[ 3] = 0;
 		break;
 	case AES_SMALLFONT: /* 1 */
 		apb->int_out[ 1] = globals.fnt_small_sz;
 		apb->int_out[ 2] = globals.fnt_small_id;
 		apb->int_out[ 3] = 0; /* system font */
 		break;
 	case AES_SYSTEM:    /* 2 */
 		apb->int_out[ 1] = 0;  /* rez nr. */
 		apb->int_out[ 2] = 16; /* n_colors */
 		apb->int_out[ 3] = 1;  /* new .RCS (?) */
 		break;
 	case AES_LANGUAGE:  /* 3 */
 		apb->int_out[ 1] = 0;  /* english */	
 		break;
 /* We don't get these unless vAES>=4.1 - hopefully... */
 	case AES_PROCESS:   /* 4 */
 		apb->int_out[ 1] = 1;  /* real multitask */
 		apb->int_out[ 2] = 1;  /* appl_find can mintid->aespid */
 		apb->int_out[ 3] = 0;  /* no appl_search */
 		apb->int_out[ 4] = 0;  /* no rsrc_rsfix */
 		break;
 	case AES_PCGEM:     /* 5 */
 		apb->int_out[ 1] = 0;  /* objc_xfind */
 		apb->int_out[ 2] = 0;  /* 0 */
 		apb->int_out[ 3] = 0;  /* menu_click */
 		apb->int_out[ 4] = 0;  /* shel_r/wdef */
 		break;
 	case AES_INQUIRE:   /* 6 */
 		apb->int_out[ 1] = 1;  /* appl_read(-1) */
 		apb->int_out[ 2] = 0;  /* shel_get(-1) */
 		apb->int_out[ 3] = 1;  /* menu_bar(-1) */
 		apb->int_out[ 4] = 0;  /* menu_bar(MENU_INSTL) */
 		break;
 	case AES_MOUSE:     /* 8 */
 		apb->int_out[1] = 1;  /* graf_mouse modes 258-260 supported */
 		apb->int_out[2] = 0;  /* mouse form maintained by OS */

 	case AES_MENU:      /* 9 */
 		apb->int_out[ 1] = 0;  /* MultiTOS style submenus */
 		apb->int_out[ 2] = 0;  /* MultiTOS style popup menus */
 		apb->int_out[ 3] = 0;  /* MultiTOS style scrollable menus */
 		apb->int_out[ 4] = 0;  /* words 5/6/7 in MN_SELECTED message give extra info */
 		break;
 
	case AES_SHELL:   /* 10 */
		apb->int_out[1] = SWM_AESMSG;
		apb->int_out[2] = 0;
		apb->int_out[3] = 0;
		apb->int_out[4] = 0;
 		break;

 	case AES_WINDOW:    /* 11 */
 		apb->int_out[1] = 0x1a1;
 		                       /* 0x001: WF_TOP returns window below current one
 		                          0x002: wind_get(WF_NEWDESK) supported
 		                          0x004: WF_COLOR get/set supported
 		                          0x008: WF_DCOLOR get/set supported
 		                          0x010: WF_OWNER supported in wind_get
 		                          0x020: WF_BEVENT get/set supported
 		                          0x040: WF_BOTTOM supported
 		                          0x080: WF_ICONIFY supported
 		                          0x100: WF_UNICONIFY supported      */
 		apb->int_out[2] = 0;  /* resv */
 		apb->int_out[3] = 0x1;  /* 0x1: iconifier
 		                           0x2: explicit "bottomer" gadget
 		                           0x4: shift+click to send window to bottom
 		                           0x8: "hot" close box            */
 		apb->int_out[ 4] = 1;  /* wind_update check and set allowed  */
 		break;
 	case AES_MESSAGES:  /* 12 */
 		apb->int_out[ 1] = 0;  /* bit 0: WM_NEWTOP message meaningful
 		                          bit 1: WM_UNTOPPED message sent
 		                          bit 2: WM_ONTOP message sent
 		                          bit 3: AP_TERM message sent
 	                              bit 4: MultiTOS shutdown and resolution change
 		                                 messages supported
 		                          bit 5: AES sends CH_EXIT
 		                          bit 6: WM_BOTTOM message sent
 		                          bit 7: WM_ICONIFY message sent
 		                          bit 8: WM_UNICONIFY message sent
 		                          bit 9: WM_ALLICONIFY message sent */
 		apb->int_out[ 2] = 0;  /* 0 */
 		apb->int_out[ 3] = 0;  /* 0 */
 		break;
 	case AES_OBJECTS:   /* 13 object information */
 		apb->int_out[ 1] = 0;  /* 3D objects supported via objc_flags */
 		apb->int_out[ 2] = 2;  /* 1=objc_sysvar, 2=extended sysvar */
 		apb->int_out[ 3] = 0;  /* SPEEDO and GDOS fonts allowed in TEDINFO */
 		apb->int_out[ 4] = 0;  /* 0 */
 		break;
 	case AES_FORM:      /* 14 form library information */
 		apb->int_out[ 1] = 0;  /* flying dialogs */
 		apb->int_out[ 2] = 0;  /* Mag!X style keyboard tables */
 		apb->int_out[ 3] = 0;  /* last cursor position returned */
 		apb->int_out[ 4] = 0;  /* 0 */
 		break;

	default:
		DB_printf("%s: Line %d: Appl_getinfo:\r\n"
						"Unknown type %d\r\n",__FILE__,__LINE__,apb->int_in[0]);
		apb->int_out[0] = 0;
	};
}
