/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <mintbind.h>
#include <string.h>
#include <stdlib.h>
#include "ctype.h"			/* We use the version without macros!! */

#include "xa_types.h"
#include "xa_globl.h"

/* HR: appl_init, appl_exit and appl_yield are now in HANDLER.C (The client code.) */

/*
 *	AES4.0 compatible appl_search
 *
 *  HR: dynamic client pool
 *      N.aes extensions
 */
AES_function XA_appl_search	/* LOCK lock, XA_CLIENT *client, AESPB *pb */
{
	XA_CLIENT *next = nil;
	bool lang = false;
	char *fname = (char *)pb->addrin[0];
	short *o = pb->intout, cpid = pb->intin[0];

	CONTROL(1,3,1)

	o[0] = 1, o[1] = 0;

DIAG((D.appl, -1, "appl_search for %s(%d) cpid=%d\n", client->name, client->pid, cpid));
	if (cpid < 0)
	{
		cpid = -cpid;
		if (cpid < 1 or cpid > MAX_PID)
			cpid = 1;
		next = Pid2Client(cpid);
		lang = true;
	}
	else
	if (cpid == APP_DESK)		/* N.aes  short name of desktop program */
		next = Pid2Client(C.DSKpid);
	else
	{
		if unlocked(clients)
			Sema_Up(CLIENTS_SEMA);
		if (cpid == APP_FIRST)
			next = S.client_list;		/* HR: simply the first */
		else
		if (cpid == APP_NEXT)
		{
			next = client->temp;	/* HR */
			if (next)
				next = next->next;		/* :-) */
		}

		/* skip inactive clients */
		while (next and !next->client_end)
			next = next->next;
		if unlocked(clients)
			Sema_Dn(CLIENTS_SEMA);
	}

	if (!next or (next and !next->client_end))
		o[0] = 0;	/* No more clients or no active clients */
	else
	{
		cpid = next->pid;
/* HR: replies according to the compendium */		
		if (cpid == C.AESpid)
			o[1] = APP_SYSTEM;
		else if (cpid == C.DSKpid)	/* HR: :-) */
			o[1] = APP_APPLICATION | APP_SHELL;
		else if (next->type == XA_CT_ACC)
			o[1] = APP_ACCESSORY;
		else
			o[1] = APP_APPLICATION;

		o[2] = cpid;

		if (lang)
			strcpy(fname, next->name);
		else
		{
			strncpy(fname, next->proc_name, 8); /* HR */
			fname[8] = '\0';
DIAG((D.appl, -1, "appl_search for %s(%d): '%s'\n", client->name, client->pid, fname));
		}
		
		client->temp = next;	/* HR */
	}

	return XAC_DONE;
}

/*
 *	XaAES's current appl_write() only works for standard 16 byte messages
 */
#if 1
AES_function XA_appl_write 	/* LOCK lock, XA_CLIENT *client, AESPB *pb */
{
	short dest_id = pb->intin[0];
	MSG_BUF *m = (MSG_BUF *)pb->addrin[0];

	CONTROL(2,1,1)

	DIAG((D.appl,client->pid,"appl_write: %d --> %d, len=%d msg = "
						 "%04x,%04x,%04x,%04x,%04x,%04x,%04x,%04x\n",
						client->pid, dest_id, pb->intin[1],
						m->m[0],m->m[1],m->m[2],m->m[3],m->m[4],m->m[5],m->m[6],m->m[7] ));

	send_a_message(lock, dest_id, m);
	pb->intout[0] = 1;		/* HR */

	return XAC_DONE;
}
#else
#include "obsolete/applwrit.h"
#endif

/*
 *	Data table for appl_getinfo
 */
static
short info_tab[17][4] =
{
		{0, 0, 0, 0},					/* 0 large font */
		{0, 0, 0, 0},					/* 1 small font */
		{								/* 2 colours */
			1,				/* Getrez() */
			16,				/* no of colours */
			1,				/* colour icons */
			1				/* extended rsrc file format */
		},
		{0, 0, 0, 0},					/* 3 language (english) */
		{								/* 4 processes */
			1,				/* preemptive */
			1,				/* convert mint id <--> aes id */
			1,				/* appl_search */
			1				/* rsrc_rcfix */
		},
		{								/* 5 PC_GEM (none!) */
			0,				/* objc_xfind */
			0,
			0,				/* menu_click */
			0				/* shel_rdef/wdef */
		},
		{								/* 6 extended inquiry */
			0,				/* -1 not a valid app id for appl_read */
			0,				/* -1 not a valid length parameter to shel_get */
			1,				/* -1 is a valid mode parameter to menu_bar */
			0				/* MENU_INSTL is not a valid mode parameter to menu_bar */
		},
		{								/* 7 MagiC specific */
			0,				/* bit: 0 WDIALOG, 1 SCRLBOX, 2 FONTSEL, 3 FSELX  */
			0,
			0,
			0
		},
		{								/* 8 mouse support */
			0,				/* modes 258 - 260 not applicable */
			1,				/* mouse form maintained per application */
			0,
			0
		},
		{								/* 9 menu support */
			1,				/* HR: sub menus */
			1,				/* HR: popup menus */
			0,				/* HR: scrollable menus */
			1				/* MN_SELECTED provides object tree information */
		},
		{								/*10 AES shell support */
			0x3f07,			/* supported extended bits + highest mode */
			0,				/* 0 launch mode */
			0,				/* 1 launch mode */
			1				/* ARGV style via wiscr to shel_write supported */
		},

/* HR: These values are'nt bits, so I dont think this is correct
	   WF_TOP + WF_NEWDESK + WF_OWNER + WF_BEVENT + WF_BOTTOM + WF_ICONIFY + WF_UNICONIFY */
		{								/*11 window functions ?*/
			0x01f3,			/* see above */
			0,
			3,				/* window behaviours (iconifier|bottomer) */
			1				/* wind_update(): check and set available (mode + 0x100) */
		},

/* WM_UNTOPPED + WM_ONTOP + CH_EXIT (HR) + WM_BOTTOMED + WM_ICONIFY + WM_UNICONIFY */
		{								/*12 messages */
			0x01e6,			/* see above */
			0,
			1,				/* WM_ICONIFY gives coordinates */
			0
		},
		{								/*13 objects */
			1,				/* 3D objects */
			1,				/* objc_sysvar */
			0,				/* GDOS fonts */
			0x000c			/* extended objects (0x8 G_SHORTCUT, 0x4 WHITEBAK objects)  */
		},
		{								/*14 form support (form_xdo, form_xdial) */
			0,				/* MagiC flydials */
			0,				/*   "   keyboard tables */
			0,				/* return last cursor position */
			0
		},
		{								/*15 <-- 64 */
			0,
			0,
			1,				/* appl_search with long names */
			0
		},
		{0, 0, 0, 0}					/* 65 := 16 */
};										


/*
 * appl_getinfo() handler
 */
AES_function XA_appl_getinfo		/* LOCK lock, XA_CLIENT *client, AESPB *pb */
{
	unsigned short gi_type = pb->intin[0];

	CONTROL(1,5,0)

DIAG((D.appl,client->pid,"get_info %d for %d\n", gi_type, client->pid));		/* HR: Extremely curious to who's asking what. */
	if (gi_type > 14)
	{
		if (gi_type == 64 or gi_type == 65)		/* HR N.Aes extensions */
			gi_type -= 64 - 15;
		else
		{
			pb->intout[0] = 0 ;		/* "error" - unimplemented info type */
			return XAC_DONE ;
		}
	}

	info_tab[0][0] = screen.standard_font_height;
 	info_tab[0][1] = screen.standard_font_id;
	info_tab[1][0] = screen.small_font_height;
	info_tab[1][1] = screen.small_font_id;

	info_tab[2][0] = Getrez();			/* HR */

	pb->intout[0] = 1;
	pb->intout[1] = info_tab[gi_type][0];
	pb->intout[2] = info_tab[gi_type][1];
	pb->intout[3] = info_tab[gi_type][2];
	pb->intout[4] = info_tab[gi_type][3];
	
	return XAC_DONE;
}

/*
 * appl_find()
 *
 * HR: the -1 -2 support wasnt good at all
 */
AES_function XA_appl_find	/* (LOCK lock, XA_CLIENT *client, AESPB *pb) */
{
	struct nn { short m, id;};
	struct nn *ex = (struct nn *)pb->addrin;
	char *name = (char *)pb->addrin[0], *t;
	short f = ex->id, n;

	CONTROL(0,1,1)

DIAG((D.appl, -1, "appl_find for %s(%d)\n", client->name, client->pid));

	if (ex->m == -1 or ex->m == -2)		/* mint id <--> aes_id */
	{
#if 0
		if (client and client->client_end)	/* is it a active aes client */
			pb->intout[0] = f;
		else
			pb->intout[0] = -1;
#else
		pb->intout[0] = f;
#endif
		DIAG((D.appl, -1, "   m-1/-2 --> %d\n", pb->intout[0]));
	}
	else
	if (ex->m == 0)
	{
		pb->intout[0] = client->pid;		/* Return the pid of current process */
		DIAG((D.appl, -1, "   m0 --> %d\n", pb->intout[0]));
/* Tell application we understand appl_getinfo() */
/* (Invented by Martin Osieka for his AES extension WINX; */
/*	used by MagiC 4, too.) */
	}
	else
	if (strcmp(name, "?AGI") == 0)
	{
		pb->intout[0] = 0 ;		/* OK */
		DIAG((D.appl, -1, "   ?AGI\n"));
	}
	else
	{
		DIAG((D.appl, -1, "   '%s'\n", pb->addrin[0]));
		pb->intout[0] = -1;
		client = S.client_list;		/* HR: use proper loop */
		while (client)
		{
			if (client->client_end)
			{
				t = client->proc_name;
				for (n = 0; (n < 8) and (toupper(name[n]) == toupper(t[n])); n++)
					;
				if(n == 8)
				{
					pb->intout[0] = client->pid;
					DIAG((D.appl, -1, "   --> %d\n", pb->intout[0]));
					break;
				}
			}
			client = client->next;
		}
	}

	return XAC_DONE;			/* HR */
}

/*
 *	Extended XaAES calls
 */

/*
 * Get the file handle of the client reply pipe
 */
AES_function XA_appl_pipe		/* LOCK lock, XA_CLIENT *client, AESPB *pb */
{
	CONTROL(0,1,0)

	pb->intout[0] = client ? client->client_end : 0;
	return XAC_DONE;
}
