/*
 * GEMScript protocol for WinDom applications
 * Copyright (c) 2000-2001 Arnaud BERCEGEAY
 *
 * Contact :
 * Arnaud BERCEGEAY <bercegeay@atari.org>
 * http://perso.wanadoo.fr/arnaud.bercegeay/
 *
 * More about WinDom:
 * http://windom.free.fr
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <stdarg.h>

#ifdef __PUREC__	/* MODIF_DOM */
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#define FA_NORMAL 0
#else
#include <atari.h>
#include <osbind.h>
#include <mgem.h>
#endif

#include <windom.h>

char __Ident_gslib[] = "$PatchLevel: GemScript library 001 $";

#define GSLIB_EVENT  0x134F

/* set to 0 to disabled the debug feature */
#define GS_DEBUG 1

/* send debug strings to stdio window */
#define DEBUG_TO_STDIO 0

#if GS_DEBUG
static long Fh_debug = 0L;
static void gs_debug(const char*, ...);
static void	gs_debug_list(void);
#ifdef __PUREC__
static void gs_debug_cmd (char *strptr);
#else
static void gs_debug_cmd ();
#endif
#define SEPARATOR_STR "*************************************************"
#endif   

/*
 * GEMScript messages list:
 *
 *         Message        evnt[0] [1]   [2] [3] [4] [5] [6] [7]
 *
 *   --- GS_REQUEST --->  0x1350  ap_id  0  GS_INFO  0   0  gs_id
 *   <--- GS_REPLY ----   0x1351  ap_id  0  idem     0  (a) idem
 *
 * (a) set to 0 says "ok". If != 0, request rejected (nok).
 *
 *   --- GS_COMMAND --->  0x1352  ap_id  0  ptr_cmd  0   0  gs_id
 *   <---- GS_ACK -----   0x1353  ap_id  0  idem      (b)   idem
 *    ---- GS_ACK ---->   0x1353  ap_id  0  NULL     idem   0
 *
 * (b) is a pointer to a result string, or NULL
 * if (b) is not NULL, there will be an GS_ACK answer to the GS_ACK.
 *
 *   ---- GS_QUIT ---->   0x1354  ap_id  0  NULL  0   0   0  gs_id
 *
 */

/*
 * Message number for GEMSCRIPT messages
 */

#define GS_REQUEST  0x1350
#define GS_REPLY    0x1351
#define GS_COMMAND  0x1352
#define GS_ACK      0x1353
#define GS_QUIT     0x1354

/*
 * Structures Mxallocated in global memory
 */

typedef struct gs_info
{
	long len;
	short version;
	short msg;
	long ext;
} GS_INFO ;

typedef struct gs_comm
{
	GS_INFO          info;
	int              ap_id;
	int              gs_id;
	int              state;
	int              flags;
	int              nshares;
	int              return_value;
	char           * ptr_result;
	char             command[512];
	struct gs_comm * next;
} GS_COMM ;

/* GS_COMM::flags values */
#define GSCF_CLOSED           0x0001
#define GSCF_SLAVE            0x0002
#define GSCF_SHARED           0x0004

/* GS_COMM::state values */
#define GSCS_ERROR            0
#define GSCS_WAITFORREPLY     1
#define GSCS_OPENED           2
#define GSCS_WAITFORACK       3
#define GSCS_WAITFORACK2      4

/*
 *  Static variables
 */

static GS_COMM * ListeGSComm = NULL;  /* List of GS opened dialog */
static int (*CommandReceiver)( GS_COMM *, int, char **) = NULL; /* call it when receive GS_COMMAND */

/*
 *  prototype of local functions
 */

static GS_COMM * NewGSComm     (void);
static GS_COMM * FindGSComm    (int ap_id, int gs_id);
#ifdef __PUREC__
static GS_COMM * FindGSComm2   (char * str);
#else
static GS_COMM * FindGSComm2   ();
#endif
static int       ExistGSComm   (GS_COMM * gsc);
static void      AjouterGSComm (GS_COMM * gsc, int gs_id_libre);


/******************************************************************
  RECEIVER for GS_REQUEST messages
 ******************************************************************/

static void GSRequest ( void )
{
	GS_COMM *gsc;
	
#if GS_DEBUG
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] Received GS_REQUEST message\n");
	gs_debug("[GEMSCRIPT]  ap_id=%d info=%p gs_id=%d\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],evnt.buff[7]);
#endif

	if (CommandReceiver)
	{
		/* on pourra traiter les commandes: on accepte le dialogue */
		if (FindGSComm(evnt.buff[1],evnt.buff[7]))
		{
			/* le dialogue avec cette ap_id et ce gs_id est d‚j… */
			/* ouvert: on r‚pond par une erreur */
#if GS_DEBUG
			gs_debug("[GEMSCRIPT]  Communication with these ap_id and gs_id already open\n");
			gs_debug(NULL);
			gs_debug("[GEMSCRIPT] Send: GS_REPLY message\n");
			gs_debug("[GEMSCRIPT]  ap_id=%d info=%p gs_id=%d ret=1\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],evnt.buff[7]);
#endif
			ApplWrite(evnt.buff[1],GS_REPLY,evnt.buff[3],evnt.buff[4],0,1,evnt.buff[7]);
		}
		else
		{
			/* le dialogue avec cette ap_id et ce gs_id n'existe */
			/* pas encore: il faut l'initialiser */
			gsc = NewGSComm();
			if (gsc == NULL) {
				/* Impossible d'allouer de la m‚moire pour ajouter */
				/* cette communication … la liste => echec */
#if GS_DEBUG
				gs_debug("[GEMSCRIPT]  NewGSComm() failed, GSRequest refuse the communication\n");
				gs_debug(NULL);
				gs_debug("[GEMSCRIPT] Send: GS_REPLY message\n");
				gs_debug("[GEMSCRIPT]  ap_id=%d info=%p gs_id=%d ret=1\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],evnt.buff[7]);
#endif
				ApplWrite(evnt.buff[1],GS_REPLY,evnt.buff[3],evnt.buff[4],0,1,evnt.buff[7]);
			}
			else
			{
				/* allocation m‚moire OK: succŠs */
				gsc->ap_id = evnt.buff[1];
				gsc->gs_id = evnt.buff[7];
				gsc->flags = GSCF_SLAVE;
				gsc->state = GSCS_OPENED;
				AjouterGSComm(gsc,0);
#if GS_DEBUG
				gs_debug("[GEMSCRIPT]  NewGSComm() ok, GSRequest accept the communication\n");
				gs_debug(NULL);
				gs_debug("[GEMSCRIPT] Send: GS_REPLY message\n");
				gs_debug("[GEMSCRIPT]  ap_id=%d info=%p gs_id=%d ret=0\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],evnt.buff[7]);
#endif
				ApplWrite(evnt.buff[1],GS_REPLY,evnt.buff[3],evnt.buff[4],0,0,evnt.buff[7]);		
			}
		}
	}
	else
	{
		/* pas de fonction CommandReceiver: On n'est pas en mesure */
		/* par la suite de dialoguer. On refuse la communication */
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  No CommandReceiver function. It's stupid to accept communication, so...\n");
		gs_debug(NULL);
		gs_debug("[GEMSCRIPT] Send: GS_REPLY message\n");
		gs_debug("[GEMSCRIPT]  ap_id=%d info=%p gs_id=%d ret=1\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],evnt.buff[7]);
#endif
		ApplWrite(evnt.buff[1],GS_REPLY,evnt.buff[3],evnt.buff[4],0,1,evnt.buff[7]);
	}
	
#if GS_DEBUG
	gs_debug_list();
#endif

}


/******************************************************************
  RECEIVER for GS_REPLY messages
 ******************************************************************/

static void GSReply ( void )
{
	GS_COMM * g;
	
#if GS_DEBUG
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] Received: GS_REPLY message\n");
	gs_debug("[GEMSCRIPT]  ap_id=%d info=%p gs_id=%d ret=%d\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],evnt.buff[7],evnt.buff[6]);
#endif

	/* Reception d'un message GS_REPLY */
	/* ce message doit faire suite … l'envoi d'un message GS_REQUEST */
	
	g = FindGSComm(evnt.buff[1],evnt.buff[7]);
	if (g == NULL)
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  FindGSComm(ap_id,gs_id) failed\n");
#endif
		return;
	}
	if (g->state != GSCS_WAITFORREPLY)
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  state != GSCS_WAITFORREPLY : unexpected GS_REPLY message\n");
#endif
		return;
	}
	if (evnt.buff[6])
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  GS_REPLY message NOK :(\n");
#endif
		g->state = GSCS_ERROR ;
	}
	else
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  GS_REPLY message OK :)\n");
#endif
		g->state = GSCS_OPENED ;
	}
}


/******************************************************************
  RECEIVER for GS_COMMAND messages
 ******************************************************************/

static void GSCommand ( void )
{
	GS_COMM * gsc;
	char * ptrcmd;
	clock_t   chrono;
	char * argv[32];  /* max 32 arguments in command */
	int argc;
	
#if GS_DEBUG
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] Received GS_COMMAND message\n");
	gs_debug("[GEMSCRIPT]  ap_id=%d PtrCommand=%p gs_id=%d\n", evnt.buff[1], evnt.buff[3], evnt.buff[4], evnt.buff[7]);
	#ifdef __PUREC__
	gs_debug_cmd( *(char **)&evnt.buff[3]);
	#else
	gs_debug_cmd( evnt.buff[3], evnt.buff[4]);
	#endif
#endif

	if (CommandReceiver)
	{
		gsc = FindGSComm(evnt.buff[1],evnt.buff[7]);
		if (gsc)
		{
			gsc->ptr_result = NULL;
			ptrcmd = (char*)(long)( (((long)(evnt.buff[3]))<<16) | ((long)(evnt.buff[4]) & 0x0000FFFFL) );
			if (ptrcmd)
			{
				argc = 0;
				while (*ptrcmd)
				{
					argv[argc++] = ptrcmd;
					while (*ptrcmd)
						ptrcmd++;
					ptrcmd++;
				}
				argv[argc] = NULL;
				gsc->return_value = (*CommandReceiver)(gsc,argc,argv);
			}
			ptrcmd = (char*)(long)( (((long)(evnt.buff[3]))<<16) | ((long)(evnt.buff[4]) & 0x0000FFFFL) );
#if GS_DEBUG
			gs_debug(NULL);
			gs_debug("[GEMSCRIPT] Send: GS_ACK message\n");
			gs_debug("[GEMSCRIPT]  ap_id=%d PtrCommand=%p PtrResult=%p ret=%d\n",gsc->ap_id,ptrcmd,gsc->ptr_result,gsc->return_value);
#endif
			ApplWrite(gsc->ap_id,GS_ACK,ptrcmd,gsc->ptr_result,gsc->return_value);
			if (gsc->ptr_result)
			{
				/* on attend un message ACK en r‚ponse … ce ACK */
				gsc->state = GSCS_WAITFORACK2;

				/* on boucle jusqu'… ce que gsc->state passe … GSCS_OPENED */
				/* ou que le timeout soit ‚coul‚ */
			
				chrono = clock();

				while (  (clock() - chrono < 800)  /* 4 secondes */
					       &&(gsc->state == GSCS_WAITFORACK2))
				{
					long timer=evnt.timer;
					evnt.timer = 200L;
					EvntWindom( MU_MESAG | MU_TIMER);
					evnt.timer = timer;
				}
	
				if (gsc->state != GSCS_OPENED)
				{
#if GS_DEBUG
					gs_debug("[GEMSCRIPT]  GSCommand(%p): No ack received in reply to the ack...\n",gsc);
#endif
				}
				gsc->state = GSCS_OPENED;
			}
			else
			{
				/* on se rendort jusqu'au prochain appel */
				gsc->state = GSCS_OPENED;
			}
		}
		else
		{
			/* communication GS inexistante => erreur */
#if GS_DEBUG
			gs_debug("[GEMSCRIPT]  FindGSComm failed.\n");
			gs_debug(NULL);
			gs_debug("[GEMSCRIPT] Send: GS_ACK message\n");
			gs_debug("[GEMSCRIPT]  ap_id=%d PtrCommand=%p PtrResult=%p ret=%d\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],0,0,2);
#endif
			ApplWrite(evnt.buff[1],GS_ACK,evnt.buff[3],evnt.buff[4],0,0,2);
		}
	}
	else
	{
		/* pas de fonction CommandReceiver: erreur */
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  No CommandReceiver function. GS_COMMAND failed.\n");
		gs_debug(NULL);
		gs_debug("[GEMSCRIPT] Send: GS_ACK message\n");
		gs_debug("[GEMSCRIPT]  ap_id=%d PtrCommand=%p PtrResult=%p ret=%d\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],0,0,2);
#endif
		ApplWrite(evnt.buff[1],GS_ACK,evnt.buff[3],evnt.buff[4],0,0,2);
	}
}


/******************************************************************
  RECEIVER for GS_ACK messages
 ******************************************************************/

static void GSAck ( void )
{
	GS_COMM * g;

#if GS_DEBUG
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] Received: GS_ACK message\n");
	gs_debug("[GEMSCRIPT]  ap_id=%d PtrCommand=%p PtrResult=%p ret=%d\n",evnt.buff[1],evnt.buff[3],evnt.buff[4],evnt.buff[5],evnt.buff[6],evnt.buff[7]);
	#ifdef __PUREC__
	gs_debug_cmd( *(char **)&evnt.buff[5]);
	#else
	gs_debug_cmd(evnt.buff[5],evnt.buff[6]);
	#endif
#endif

	/* ce message doit faire suite … un GS_COMMAND */
	if (evnt.buff[3] | evnt.buff[4])
	#ifndef __PUREC__
		g = FindGSComm2(evnt.buff[3],evnt.buff[4]); /* recv ACK after command */
	#else
		g = FindGSComm2( *(char**)&evnt.buff[3]); /* recv ACK after command */		
	#endif
	else
	#ifndef __PUREC__
		g = FindGSComm2(evnt.buff[5],evnt.buff[6]); /* recv ACK after ACK */
	#else
		g = FindGSComm2( *(char **)&evnt.buff[5]); /* recv ACK after ACK */		
	#endif
	if (g == NULL)
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  FindGSComm2(PtrCommand) failed\n");
#endif
		return;
	}
	if ((g->state != GSCS_WAITFORACK) && (g->state != GSCS_WAITFORACK2))
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  state!=GSCS_WAITFORACK* : unexpected GS_ACK message\n");
#endif
		return;
	}
	if (g->state == GSCS_WAITFORACK)
	{
		/* C'est le r‚sultat de la commande pr‚c‚dente */
		/* il faut stocker ce resultat (evnt.buff[5,6]) qqpart */
		/* ainsi que evnt.buff[7] */
		
		g->return_value = evnt.buff[7] ;
		
		if (evnt.buff[5] || evnt.buff[6])
		{
			g->ptr_result = (char*)(long)((((long)(evnt.buff[5]))<<16) | ((long)(evnt.buff[6]) & 0x0000FFFFL));
#if GS_DEBUG
			gs_debug("[GEMSCRIPT] [DEBUG] g->command=%p g->ptr_result=%p\n",g->command,g->ptr_result);
#endif
			strcpy(g->command,g->ptr_result);
			g->ptr_result = g->command;
#if GS_DEBUG
			gs_debug(NULL);
			gs_debug("[GEMSCRIPT] Send: GS_ACK message\n");
			gs_debug("[GEMSCRIPT]  ap_id=%d PtrResult=%p\n",g->ap_id,evnt.buff[5],evnt.buff[6]);
#endif
			ApplWrite(g->ap_id,GS_ACK,0,0,evnt.buff[5],evnt.buff[6],0);
		}
		else
			g->ptr_result = NULL ;
	}
	g->state = GSCS_OPENED;
}


/******************************************************************
  RECEIVER for GS_QUIT messages
 ******************************************************************/

static void GSQuit ( void )
{
	GS_COMM * g, * gg;

#if GS_DEBUG
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] Received GS_QUIT message\n");
	gs_debug("[GEMSCRIPT]  ap_id=%d gs_id=%d\n",evnt.buff[1],evnt.buff[7]);
#endif

	g = FindGSComm(evnt.buff[1],evnt.buff[7]);
	if (g == NULL)
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  FindGSComm(ap_id,gs_id) failed\n");
#endif
		return;
	}
	
#if GS_DEBUG
	gs_debug("[GEMSCRIPT]  Close GS communication %p\n",g);
#endif

	if (g->flags & GSCF_SHARED)
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  GS_COMM is shared; just set the CLOSED flag\n");
#endif
		g->flags |= GSCF_CLOSED;
		ApplWrite(app.id,GSLIB_EVENT,0,g);
	}
	else if ( ! (g->flags & GSCF_SLAVE) )
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  GS_COMM wasn\'t opened by the other client: just set the CLOSED flag\n");
#endif
		g->flags |= GSCF_CLOSED;
		ApplWrite(app.id,GSLIB_EVENT,0,g);
	}
	else
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  remove the GS_COMM from the list\n");
#endif
	
		if (g == ListeGSComm)
		{
			ListeGSComm = g->next;
		}
		else
		{
			gg = ListeGSComm;
			while ((gg->next) && (gg->next != g))
				gg = gg->next;
			if (gg->next)
				gg->next = g->next;
		}
		Mfree(g);
	}

#if GS_DEBUG
	gs_debug_list();
#endif
}
	
/* ********* */

static int initialized = 0;

/******************************************************************
  Init GS functions (Attach GS events to receiver)
 ******************************************************************/

int GSInit( void *func, long mode )
{
	if (! initialized)
	{
		EvntAttach(NULL,GS_REQUEST,GSRequest);
		EvntAttach(NULL,GS_REPLY,GSReply);
		EvntAttach(NULL,GS_COMMAND,GSCommand);
		EvntAttach(NULL,GS_ACK,GSAck);
		EvntAttach(NULL,GS_QUIT,GSQuit);
		CommandReceiver = func;
		initialized = 1;
#if GS_DEBUG
		if (mode)
		{
			Fh_debug = (long)Fcreate("w_gs.log",FA_NORMAL);
			if (Fh_debug <= 0L)
				Fh_debug = (long)Fcreate("C:\\TMP\\W_GS.LOG",0);
			if (Fh_debug <= 0L)
				Fh_debug = 0L;
			gs_debug(NULL);
			gs_debug("[GEMSCRIPT] GSInit; app.id=%d\n",app.id);
		}
#endif
	}
	return 0;
}


/******************************************************************
  Close all opened GS dialog and DeInit GS functions
 ******************************************************************/

int GSExit( void )
{
	GS_COMM * g;

#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR);
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] GSExit()\n");
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif

	if (initialized)
	{
		/* Envoi de GS_QUIT … tout le monde */
		while (ListeGSComm)
		{
			g = ListeGSComm;
			ListeGSComm = g->next;
#if GS_DEBUG
			gs_debug(NULL);
			gs_debug("[GEMSCRIPT] Send: GS_QUIT message\n");
			gs_debug("[GEMSCRIPT]  ap_id=%d gs_id=%d\n",g->ap_id,g->gs_id);
#endif
			ApplWrite(g->ap_id,GS_QUIT,0,0,0,0,g->gs_id);
			Mfree(g);
		}

		/* Suppression des ‚venements GS_xxx */
		EvntDelete(NULL,GS_REQUEST);
		EvntDelete(NULL,GS_REPLY);
		EvntDelete(NULL,GS_COMMAND);
		EvntDelete(NULL,GS_ACK);
		EvntDelete(NULL,GS_QUIT);
		CommandReceiver = NULL;
		initialized = 0;
#if GS_DEBUG
		if (Fh_debug)
		{
			gs_debug("\n\n[GEMSCRIPT] " SEPARATOR_STR "\n");
			gs_debug("[GEMSCRIPT] GSExit succeed... bye :)\n");
			gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
			Fclose(Fh_debug);
		}
#endif
	}
	return 0;
}


/******************************************************************
  Open a GS pipe
 ******************************************************************/

GS_COMM * GSOpen(int ap_id)
{
	GS_COMM * gsc, *g;
	clock_t   chrono;
	
#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] GSOpen(%d)\n",ap_id);
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif

	gsc = NewGSComm();
	if (gsc == NULL) {
#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR "\n");
	gs_debug("[GEMSCRIPT]  NewGSComm() failed, GSOpen return NULL\n");
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif
		return 0L;
	}
	
	gsc->ap_id = ap_id;
	AjouterGSComm(gsc,1);
	
#if GS_DEBUG
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] Send: GS_REQUEST message\n");
	gs_debug("[GEMSCRIPT]  ap_id=%d info=%p gs_id=%d\n",ap_id,&(gsc->info),gsc->gs_id);
#endif

	gsc->state = GSCS_WAITFORREPLY;
	ApplWrite(ap_id,GS_REQUEST,&(gsc->info),0,0,gsc->gs_id);
	
	/* on boucle jusqu'… ce que gsc->state passe … GSCS_OPENED */
	/* ou que le timeout soit ‚coul‚ */
	
	chrono = clock();

	while (  (clock() - chrono < 800)  /* 4 secondes */
	       &&(gsc->state == GSCS_WAITFORREPLY))
	{
		long timer=evnt.timer;
		evnt.timer = 200L;
		EvntWindom( MU_MESAG | MU_TIMER);
		evnt.timer = timer;
	}
	
	if (gsc->state != GSCS_OPENED)
	{
		/* toujours pas initialis‚ */
#if GS_DEBUG
		gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR "\n");
		if (gsc->state == GSCS_ERROR)
			gs_debug("[GEMSCRIPT]  GS_REPLY NOK, GSOpen return NULL\n");
		else
			gs_debug("[GEMSCRIPT]  no GS_REPLY received, GSOpen return NULL\n");
		gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif
		/* on libŠre le GSComm allou‚ */
		if (gsc == ListeGSComm)
		{
			ListeGSComm = gsc->next;
		}
		else
		{
			g = ListeGSComm;
			while ((g->next) && (g->next != gsc))
				g = g->next;
			if (g->next)
				g->next = gsc->next;
			else
				return NULL;  /* erreur : gsc n'est pas dans la liste */
		}
		
		Mfree(gsc);
		return NULL;
	}
	
#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR "\n");
	gs_debug("[GEMSCRIPT]  GSOpen succeed, return %p\n",gsc);
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif

#if GS_DEBUG
	gs_debug_list();
#endif

	return gsc;
}


/******************************************************************
  Close a GS pipe
 ******************************************************************/

int GSClose( GS_COMM * gsc )
{
	GS_COMM * g;
	
#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] GSClose(%p)\n",gsc);
#endif

	if (gsc == ListeGSComm)
	{
		ListeGSComm = gsc->next;
	}
	else
	{
		g = ListeGSComm;
		while ((g) && (g->next) && (g->next != gsc))
			g = g->next;
		if (g && g->next)
			g->next = gsc->next;
		else {
#if GS_DEBUG
			gs_debug("[GEMSCRIPT]  dialog isn\'t in the list, GSClose failed\n");
			gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif
			return -1;  /* erreur : gsc n'est pas dans la liste */
		}
	}

	if (gsc->flags & GSCF_CLOSED)
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  GS_COMM already closed; just remove it from the list\n");
		gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif		
	}
	else
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
		gs_debug(NULL);
		gs_debug("[GEMSCRIPT] Send: GS_QUIT message\n");
		gs_debug("[GEMSCRIPT]  ap_id=%d gs_id=%d\n",gsc->ap_id,gsc->gs_id);
#endif
		ApplWrite(gsc->ap_id,GS_QUIT,0,0,0,0,gsc->gs_id);
	}
	
	Mfree(gsc);

#if GS_DEBUG
	gs_debug_list();
#endif

	return 0;
}


/******************************************************************
  Send a command thru a GS pipe
 ******************************************************************/

int GSSendCommand(GS_COMM * gsc, char * command, int nb_arg, ...)
{
	va_list   args;
	clock_t   chrono;
	char     *s, *d ;

#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] GSSendCommand(%p,...)\n",gsc);
#endif

	if (ExistGSComm(gsc))
	{
		if (gsc->flags & GSCF_CLOSED)
		{
#if GS_DEBUG
			gs_debug("[GEMSCRIPT]  GS_COMM closed !\n");
			gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
#endif
			return -1;
		}

#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  Command: %s(",command);
#endif
		/* construction de la ligne de commande */
		d = gsc->command;
		s = command;
		while (*s)
			*d++ = *s++;
		*d++ = 0;
		
		/* ajout des parametres */
		va_start( args, nb_arg);
		while (nb_arg > 0)
		{
			s = va_arg( args, char*);
			if ((s) && (*s))
			{
#if GS_DEBUG
				gs_debug("\"%s\"",s);
#endif
				while (*s)
					*d++ = *s++;
			}
			else
			{
#if GS_DEBUG
				gs_debug("NULL");
#endif
				*d++ = '\1';  /* argument vide */
			}
			*d++ = 0;
			nb_arg--;
#if GS_DEBUG
			if (nb_arg) gs_debug(",");
#endif
		}
		va_end( args);
#if GS_DEBUG
		gs_debug(")\n");
		gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif
		
		/* termine par un deuxiŠme octet nul */
		*d++ = 0;
		
#if GS_DEBUG
		gs_debug(NULL);
		gs_debug("[GEMSCRIPT] Send: GS_COMMAND message\n");
		gs_debug("[GEMSCRIPT]  ap_id=%d PtrCommand=%p gs_id=%d\n",gsc->ap_id,gsc->command,gsc->gs_id);
		gs_debug_cmd(gsc->command);
#endif

		ApplWrite(gsc->ap_id,GS_COMMAND,gsc->command,0,0,gsc->gs_id);
		gsc->state = GSCS_WAITFORACK;
		
		/* maintenant, on attend le ACK */
		chrono = clock();
	
		while (  (clock() - chrono < 800)  /* 4 secondes */
		       &&(gsc->state == GSCS_WAITFORACK))
		{
			long timer=evnt.timer;
			evnt.timer = 200L;
			EvntWindom( MU_MESAG | MU_TIMER);
			evnt.timer = timer;
		}
		
		if (gsc->state == GSCS_WAITFORACK)
		{
			/* toujours pas de ack */
#if GS_DEBUG
			gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
			gs_debug(NULL);
			gs_debug("[GEMSCRIPT]  GSSendCommand fail: no GS_ACK received\n");
			gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif
			gsc->state = GSCS_OPENED;
			return -2;
		}
		return gsc->return_value;
	}
	gs_debug("[GEMSCRIPT]  unknown GS_COMM handle: GSSendCommand failed :(\n");
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
	return -1;
}


/******************************************************************
  Get the string returned in reply to a command
 ******************************************************************/

char * GSGetCommandResult (GS_COMM * gsc)
{
#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] GSGetCommandResult(%p)\n",gsc);
#endif

	if (ExistGSComm(gsc))
	{
#if GS_DEBUG
		gs_debug("[GEMSCRIPT]  return %p",gsc->ptr_result);
		if (gsc->ptr_result==NULL) 
			gs_debug ("\n");
		else if (*(gsc->ptr_result))
			gs_debug (" \"%s\"\n",gsc->ptr_result);
		else
			gs_debug (" \"\"\n");  /* needed to avoid a sox bug ? */
		gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif
		return (gsc->ptr_result);
	}
	gs_debug("[GEMSCRIPT]  unknown GS_COMM handle: GSGetCommandResult failed\n");
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
	return NULL;
}


/******************************************************************
  Set the string to send in reply to a command
 ******************************************************************/

int GSSetCommandResult (GS_COMM * gsc, char *ptr_result)
{
#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] GSSetCommandResult(gsc,ptr) gsc=%p, ptr=%p",gsc,ptr_result);
#endif

	if (ExistGSComm(gsc))
	{
		if (ptr_result==NULL)
		{
			gsc->ptr_result = NULL;
#if GS_DEBUG
			gs_debug("\n");
#endif
		}
		else
		{
			gsc->ptr_result = gsc->command;
			strcpy(gsc->command,ptr_result);
#if GS_DEBUG
			if (*ptr_result) gs_debug("=\"%s\"\n",ptr_result);
			else             gs_debug("=\"\"\n");
#endif
		}
#if GS_DEBUG
		gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
#endif
		return 0;
	}
	gs_debug("[GEMSCRIPT]  unknown GS_COMM handle: GSGetCommandResult failed\n");
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
	return -1;
}

/******************************************************************
  Get the application ID of the correspondant
 ******************************************************************/

int GSGetAppId(GS_COMM * gsc)
{
	if (ExistGSComm(gsc))
	{
		return gsc->ap_id;
	}
	
	return -1;
}

/******************************************************************
  Set the GS_COMM shared flag
 ******************************************************************/

int GSShare(GS_COMM * gsc)
{
#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] GSShare(gsc) gsc=%p\n",gsc);
#endif
	if (ExistGSComm(gsc) && (gsc->flags & GSCF_SLAVE))
	{
		gsc->flags |= GSCF_SHARED;
		gsc->nshares++;
	}
#if GS_DEBUG
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
	gs_debug_list();
#endif
	return 0;
}

int GSUnShare(GS_COMM * gsc)
{
#if GS_DEBUG
	gs_debug("\n[GEMSCRIPT] " SEPARATOR_STR );
	gs_debug(NULL);
	gs_debug("[GEMSCRIPT] GSUnShare(gsc) gsc=%p\n",gsc);
#endif
	if (ExistGSComm(gsc) && (gsc->flags & GSCF_SHARED))
	{
		gsc->nshares--;
		if (gsc->nshares <= 0) {
			gsc->flags &= ~GSCF_SHARED;
			gsc->nshares = 0;
			if (gsc->flags & GSCF_CLOSED) 
			{
				GS_COMM *g;
				
				/* remove gsc from the list */
				if (gsc == ListeGSComm)
					ListeGSComm = gsc->next;
				else {
					g = ListeGSComm;  /* g != NULL because gsc exist ! */
					while ((g->next) && (g->next != gsc))
						g = g->next;
					g->next = gsc->next;
				}
#if GS_DEBUG
				gs_debug("[GEMSCRIPT]  remove %p from the GS_COMM list\n",gsc);
#endif
				Mfree(gsc);
			}
		}
	}
#if GS_DEBUG
	gs_debug("[GEMSCRIPT] " SEPARATOR_STR "\n");
	gs_debug_list();
#endif
	return 0;
}

/******************************************************************
  Some other local functions
 ******************************************************************/

static int ExistGSComm ( GS_COMM * gsc )
{
	GS_COMM * g;
	
	g = ListeGSComm ;
	while (g)
	{
		if (g == gsc)
			return 1;
		g = g->next;
	}
	return 0;
}

static GS_COMM * NewGSComm( void)
{
	GS_COMM * gsc;
	
	gsc = (GS_COMM *) Mxalloc (sizeof(GS_COMM), 3+32);
	if (gsc)
	{
		gsc->info.len = sizeof(GS_INFO);
		gsc->info.version = 0x0100;
		gsc->info.msg = 1;
		gsc->info.ext = 0;
		gsc->ap_id = -1;
		gsc->gs_id = -1;
		gsc->flags =  0;
		gsc->nshares = 0;
		gsc->ptr_result = NULL;
		gsc->next = NULL;
	}
	
	return gsc;
}

static void AjouterGSComm(GS_COMM * gsc, int gs_id_libre)
{
	if (gs_id_libre)
	{
		/* init … 1 */
		gsc->gs_id = 1;
	}
	
	if (ListeGSComm == NULL)
	{
		ListeGSComm = gsc;
		gsc->next = NULL;
	}
	else if ((ListeGSComm->ap_id == gsc->ap_id) && (ListeGSComm->gs_id > gsc->gs_id))
	{
		gsc->next = ListeGSComm ;
		ListeGSComm = gsc;
	}
	else
	{
		GS_COMM * g = ListeGSComm ;
		
		if (g->ap_id != gsc->ap_id)
		{
			while ((g->next) && (g->next->ap_id != gsc->ap_id))
				g = g->next;
			if (g->next == NULL)
			{
				gsc->next = g->next;
				g->next = gsc;
			}
			else
			{	
				while ((g->next) && (g->next->ap_id==gsc->ap_id) && (g->next->gs_id<=gsc->gs_id))
				{
					if (gs_id_libre)
						gsc->gs_id++;
					g = g->next;
				}
				gsc->next = g->next;
				g->next = gsc;
			}
		}
		else
		{
			/* ici, plist (==g) a la mˆme ap_id, et un un gs_id de 1 */
			/* on commence donc par voir si gs_id=2 est dispo */
			if (gs_id_libre)
				gsc->gs_id = 2;
			while ((g->next) && (g->next->ap_id==gsc->ap_id) && (g->next->gs_id<=gsc->gs_id))
			{
				if (gs_id_libre)
					gsc->gs_id++;
				g = g->next;
			}
			gsc->next = g->next;
			g->next = gsc;
		}
	}
}

static GS_COMM * FindGSComm(int ap_id, int gs_id)
{
	GS_COMM * g;
	
	g = ListeGSComm ;
	while (g)
	{
		if ((g->ap_id == ap_id) && (g->gs_id == gs_id) && !(g->flags & GSCF_CLOSED))
			return g;
		g = g->next;
	}
	
	return NULL;
}

static GS_COMM * FindGSComm2( char * strptr )
{
	GS_COMM * g;
	
	g = ListeGSComm ;
	while (g)
	{
		if ((g->command == strptr))
			return g;
		g = g->next;
	}
	
	return NULL;
}

#if GS_DEBUG
static void gs_debug( const char * msg, ...)
{
	va_list args;
	char tmpbuff[1024];
	time_t now;
	char *c;
	
#ifndef DEBUG_TO_STDIO
	if (Fh_debug==0L)
		return;
#endif
		
	if (msg)
	{
		va_start(args, msg);
		vsprintf(tmpbuff,msg, args);
		va_end(args);
	}
	else
	{
		time (&now);
		sprintf(tmpbuff,"\n[GEMSCRIPT] [%s]", ctime(&now));
		c = &tmpbuff[20];
		/* remplace les '\n' de fin par des espaces */
		while (*c) {
			if (*c < 32) *c=' ';
			c++;
		}
		strcpy(c,"\n");
	}

	if (Fh_debug)
		Fwrite(Fh_debug,strlen(tmpbuff),tmpbuff);
		
#if DEBUG_TO_STDIO
	w_puts(tmpbuff);
#endif

}

static void	gs_debug_list()
{
	GS_COMM * g = ListeGSComm;
	
	gs_debug("\n[GEMSCRIPT] +----------+-------+-------+-------+-------+-------+\n");
	gs_debug(  "[GEMSCRIPT] | GS_COMM  | ap_id | gs_id | state | flags |nshares|\n");
	gs_debug(  "[GEMSCRIPT] +----------+-------+-------+-------+-------+-------+\n");
	while (g)
	{
		gs_debug("[GEMSCRIPT] | %08lx | %4d  | %4d  | %4d  | 0x%03x | %4d  |\n",g,g->ap_id,g->gs_id,g->state,g->flags,g->nshares);
		g = g->next;
	}
	gs_debug("[GEMSCRIPT] +----------+-------+-------+-------+-------+-------+\n");
}

static void  gs_debug_cmd (char *strptr)
{
	char tmp[256];
	char *s, *d;
	int len=0;
	
	gs_debug("[GEMSCRIPT]  (%p) = ",strptr);
	
	if (strptr == NULL)
	{
		gs_debug("<NULL>\n");
		return;
	}
	
	s = strptr;
	
	while (*s && len<256)
	{
		d = tmp;
		*d++ = '\"';
		while (*s && len<256)
		{
			if (*s>0 && *s<8) {
				*d++ = '\\';
				*d++ = '0' + *s;
				len += 2;
			} else if ((*s=='\\') || (*s=='\"')) {
				*d++ = '\\';
				*d++ = *s;
				len += 2;
			} else  {
				*d++ = *s;
				len++;
			}
			s++;
		}
		if (len < 256) {
			*d++ = '\"';
			*d++ = ' ';
		}
		*d   = 0;
		gs_debug(tmp);
		s++;
	}
	gs_debug("<end>\n");
}
#endif
