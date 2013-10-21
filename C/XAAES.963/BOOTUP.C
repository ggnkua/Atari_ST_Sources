/*
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
/*
 * Boot up code
 */

#define DEBUG_BOOT 0
#define SCL_HOOKS  0		/* HR 130302: Probe the files xa_user1.scl and xa_user2.scl */

#include <mintbind.h>
#include <fcntl.h>
#include <sys\ioctl.h>
#include <signal.h>
#include <string.h>
#include <ctype.h>			/* We use the version without macros!! */

#include "falcon.h"

#include "xa_types.h"
#include "xa_globl.h"
#include "xa_nkcc.h"		/* Harald Siegmunds NKCC with XaAES reductions. */
#include "xa_graf.h"

#include "config.h"
#include "handler.h"
#include "c_window.h"
#include WIDGHNAME
#include "signals.h"
#include "rectlist.h"
#include "objects.h"
#include "widgets.h"
#include "menuwidg.h"
#include "desktop.h"
#include "xa_form.h"
#include "scrlobjc.h"
#include "xa_shel.h"
#include "xa_fsel.h"
#include "xa_rsrc.h"
#include "xa_clnt.h"
#include "taskman.h"
#include "ipff.h"

#if DEBUG_BOOT
#define BTRACE(n) fdisplay(loghandle, false, "-= %d =-\n",n)
#else
#define BTRACE(n)
#endif

char *about_lines[] =
{
  /*          1         2         3         4         5         6
     123456789012345678901234567890123456789012345678901234567890 */
	"Original code by Craig at Data Uncertain.",
	"Additional work by:",
	"Johan K, Martin K, Mario B, T Eero,",
	"Steve S, Evan K, Thomas B, James C.",
	"Using Harald Siegmunds NKCC.",
	"Thanks to all on the MiNT mailing list,",
	"       Joakim H for his 3D test program.",
	"",
	"XaAES is free software. You may use it,",
	"modify it, rip out and renovate it's dark",
	"inner secrets .... as long as you tell",
	"me. You can NOT sell it for profit.",
	nil
};

static
char 
#if GENERATE_DIAGS
     *scls_name = "xa_debug.scl",
     *old_name  = "xaaesdbg.cnf",
#else
     *scls_name = "xa_setup.scl",
     *old_name  = "xaaes.cnf",
#endif
     *scle_name = "xa_exec.scl",
     *scl1_name = "xa_user1.scl",
     *scl2_name = "xa_user2.scl",
     *sclp_name = "xa_scl.prg";

static
char Aes_display_name[32];
global
Path Aes_home_path;

global
long loghandle;

global
int err = 0;

/* HR: the word global should really be kept reserved for (future?)
       use as the opposite of auto, local or static. */
/* XaAES doesnt want to invoke all AES function prototypes. */

#if defined(LATTICE)				/* ----- Lattice C ----- */
	extern GLOBAL _AESglobal;
	#define globl _AESglobal
	int __regargs _AESif(unsigned int);
	#define appl_init() _AESif(0x0a000100)
	int graf_handle(G_i *,G_i *,G_i *,G_i *);
	#define appl_exit()	_AESif(0x13000100)

#elif defined(__PUREC__)			/* ----- Pure C 1.1 ----- */

	#define globl _GemParBlk.glob
	int appl_init(void);
	int graf_handle(int *, int *, int *, int *);
	int appl_exit(void);

#else						/* ----- others ----- */

	#if 0			/* Old GEMLIB */
		#define globl _global
	#else			/* New GEMLIB */
		#define globl aes_global
	#endif
	extern GLOBAL globl;
	int appl_init(void) ;
	int graf_handle(int *, int *, int *, int *);
	int appl_exit(void);
#endif

/* Global config data */
global
far CFG cfg;

global
far XA_SCREEN screen;				/* The screen descriptor */

global
far COMMON C;						/* All areas that are common. */

static
char version[] = ASCII_VERSION;

static
void *widget_resources;			/* HR: Pointer to the widget resource (icons) */

static
int envs = 0;					/* HR: current no of env strings. */

static
XA_COLOUR_SCHEME
	default_colours = {LWHITE, BLACK, LBLACK, WHITE, BLACK, CYAN},
 	bw_default_colours = {WHITE, BLACK, BLACK, WHITE, BLACK, WHITE};		/* HR: more white */

static
MOOSE_VECS_COM vecs_com =		/* HR: Gets the VDI vector routine addresses from the moose. */
{
	MOOSE_VECS_PREFIX,nil,nil,nil,nil
};

static
vdi_vec *svmotv = nil,
		*svbutv = nil,
		*svwhlv = nil,			/* HR 111002: wheel support */
		*svtimv = nil;

char moose_name[] = "u:" sbslash "dev" sbslash "moose";

int
hex_version(void)
{	return HEX_VERSION; }

static
long protection_flags = 0;

static
void bootmessage(unsigned long mint)
{
	if (mint)
	{
		fdisplay(loghandle, true, "It's FreeMiNT v%ld.%ld.%ld%c%c  (%lx)\n",
				 mint>>24,
				(mint>>16)&255,
				(mint>> 8)&255,
				(mint&255) ? ' .' : '  ',
				(mint&255) ? (G_i)mint&255 : (G_i)'  ',
				mint
				);
		fdisplay(loghandle, true, " and ");
	}
/*	fdisplay(loghandle, true, "XaAES %s\n", version);
*/	fdisplay(loghandle, true, "%s\n", Aes_display_name);
	fdisplay(loghandle, true, "MultiTasking AES for MiNT\n");
	fdisplay(loghandle, true, "(w)1995,96,97,98,99 Craig Graham, Johan Klockars, Martin Koehling, Thomas Binder\n");
	fdisplay(loghandle, true, "     and other assorted dodgy characters from around the world...\n");
	fdisplay(loghandle, true, "   Using Harald Siegmunds NKCC\n");
	fdisplay(loghandle, true, "   1999-2002 Henk Robbers @ Amsterdam\n");
	fdisplay(loghandle, true, "Date: %s, time: %s\n", __DATE__,__TIME__);
	fdisplay(loghandle, true, "Supports mouse wheels\n");
	fdisplay(loghandle, true, "Compile time switches enabled:\n");

	IFDIAG(fdisplay(loghandle, true, " - Diagnostics\n");)
		
#if DISPLAY_LOGO_IN_TITLE_BAR
	fdisplay(loghandle, true, " - Logo in title bar\n");
#endif

#if POINT_TO_TYPE
	fdisplay(loghandle, true, " - Point-to-type capability\n");
#endif

#if ALT_CTRL_APP_OPS
	fdisplay(loghandle, true, " - CTRL+ALT key-combo's\n");
#endif

#if USE_CALL_DIRECT
	fdisplay(loghandle, true, " - Use direct-call\n");
#endif

#if MEMORY_PROTECTION
	fdisplay(loghandle, true, " - OS_SPECIAL memory access\n");
	fdisplay(loghandle, true, " -     protection_flags: 0x%lx\n",protection_flags);
#endif

#if VECTOR_VALIDATION
	if (C.mvalidate)
		fdisplay(loghandle, true, " - Client vector validation\n");
#endif

	fdisplay(loghandle, true, " - Realtime (live) window scrolling, moving and sizing\n");

#if PRESERVE_DIALOG_BGD
	fdisplay(loghandle, true, " - Preserve dialog backgrounds\n");
#endif

#if ! FILESELECTOR
	fdisplay(loghandle, true, " - Built without file selector\n");
#endif
#if ! TEAR_OFF
	fdisplay(loghandle, true, " - Menu's can *not* be teared off\n");
#endif

	if (cfg.superprogdef)
		fdisplay(loghandle, true, "progdefs are executed in supervisor mode\n");
	if (cfg.fsel_cookie)
		fdisplay(loghandle, true, " - FSEL cookie found\n");
	if (lcfg.falcon == 0x0030000L)
		fdisplay(loghandle, true, " - Falcon video handled\n");
	if (cfg.auto_program)
	{
		if (lcfg.havemode)
			fdisplay(loghandle, true, " - video mode %d(x%x)\n",lcfg.modecode,lcfg.modecode);
		fdisplay(loghandle, true, "auto program\n");
	}
}

static
void load_accs(void)
{
	char search_path[200];
	char acc[200];
	int fnd;
	_DTA *my_dta = Fgetdta();

	sdisplay(search_path,"%s*.ACC", cfg.acc_path);

	if (*(cfg.acc_path + 1) == ':')
	{
		Dsetdrv(tolower(*cfg.acc_path) - 'a');
		Dsetpath(cfg.acc_path + 2);
	}
	else
		Dsetpath(cfg.acc_path);

	fnd = Fsfirst(search_path, 0xff);
	while(!fnd)
	{
		sdisplay(acc, "%s%s", cfg.acc_path, my_dta->dta_name);
		DIAGS(("Launch accessory: '%s'\n", acc));
		launch(NOLOCKING, 3, 0, 0, acc, "", C.Aes);
		fnd = Fsnext();
	}
	Dsetdrv(C.home_drv);
	Dsetpath(C.home);
}

/*
 * Cleanup on exit
 */
static
void cleanup(void)
{
	XA_CLIENT *client;
	XA_WINDOW *w;
	
	DIAGS(("Cleaning up ready to exit....\n"));

	if (svmotv)
	{
		vdi_vec *m,*b,*h,*t;
		vex_motv(C.P_handle, svmotv, &m);
		vex_butv(C.P_handle, svbutv, &b);
		if (svwhlv)
			vex_whlv(C.P_handle, svwhlv, &h);
	}

	Psignal(SIGCHLD, 0L);
	
	DIAGS(("Cleaning up clients\n"));
	client = S.client_list;		/* HR */
	while(client)
	{
		XA_CLIENT *next = client->next;
		DIAGS((" - %d,%d\n", client->pid, client->client_end));
		if (is_client(client))
		{
			DIAGS(("Cleaning %s\n", c_owner(client)));
			remove_refs(client, true);						/* HR 100701 */
			XA_client_exit(NOLOCKS, client, nil);		/* HR 230501  */
		}
		client = next;
	}

	DIAGS(("Removing clients\n"));

	client = S.client_list;		/* HR */
	while(client)
	{
		XA_CLIENT *next = client->next;

		DIAGS((" - %d,%d  %d\n", client->pid, client->client_end, client->killed));
		if (client->pid == C.AESpid)
		{
			clear_clip();
			redraw_desktop(NOLOCKING, root_window);		/* HR 270801 */
		}
		else if (client->killed)
		{
			int pid = client->pid;
			DIAGS(("Removing %s\n", c_owner(client)));
			close_client(NOLOCKING, client);
			Pkill(pid, SIGKILL);
		}
		client = next;
	}

#if 0
	DIAGS(("Killing clients\n"));

	client = S.client_list;	/* HR */
	while(client)
	{
		XA_CLIENT *next = client->next;
		DIAGS((" - %d,%d\n", client->pid, client->client_end));
		if (is_client(client))
		{
			long ex_con = Pwaitpid(client->pid, 1, NULL);		/* If client ignored SIGTERM, send SIGKILL */
			if (ex_con == 0)
			{
				DIAGS(("Killing %s\n", c_owner(client)));
				Pkill(client->pid, SIGKILL);
			}
		}
		client = next;
	}
#endif


	DIAGS(("Freeing open windows\n"));

	w = window_list;
	while (w)
	{
		XA_WINDOW *nx = w->next;
		close_window(NOLOCKING, w);
		delete_window(NOLOCKING, w);
		w = nx;
	}
	DIAGS(("Freeing closed windows\n"));
	w = S.closed_windows.first;
	while (w)
	{
		XA_WINDOW *nx = w->next;
		delete_window(NOLOCKING, w);
		w = nx;
	}

	DIAGS(("Freeing Aes environment\n"));
	if (C.env)
		free(C.env);

	DIAGS(("Freeing Aes resources\n"));
	/* To demonstrate the working on multiple resources. */
	FreeResources(C.Aes, nil);		/* first:  widgets */
	FreeResources(C.Aes, nil);		/* then:   big resource */

	DIAGS(("Freeing Options\n"));
	{
		OPT_LIST *nop, *op = S.app_options;
		while (op)
		{
			nop = op->next;
			free(op);
			op = nop;
		}
	}

	DIAGS(("Freeing Symbols\n"));
	
	free_sym();

#if GENERATE_DIAGS

	DIAGS(("Reporting memory leaks\n"));
	{
		XA_report punit;
		XA_leaked(nil, -1, -1, punit);

	}

#endif

	DIAGS(("Freeing what's left\n"));
	_FreeAll();		/* Free (default) global base */

	unhook_from_vector();

	if (C.MOUSE_dev > 0)
		Fclose(C.MOUSE_dev);

	nkc_exit();

	if (C.KBD_dev > 0)
		Fclose(C.KBD_dev);			/* HR: MOUSE_dev --> C.KBD_dev */

	if (C.AES_in_pipe > 0)
		Fclose(C.AES_in_pipe);

	if (C.Salert_pipe > 0)
		Fclose(C.Salert_pipe);

	/* Remove semaphores: */
DIAGS(("Deleting semaphores\n"));
	Psemaphore(1, APPL_INIT_SEMA, 0);
/*	Psemaphore(1, TRAP_HANDLER_SEMA, 0);
*/	IFWL(Psemaphore(1, WIN_LIST_SEMA, 0);)
	Psemaphore(1, ROOT_SEMA, 0);
	Psemaphore(1, CLIENTS_SEMA, 0);
	Psemaphore(1, UPDATE_LOCK, 0);
	Psemaphore(1, MOUSE_LOCK, 0);
	Psemaphore(1, FSELECT_SEMA, 0);

	Psemaphore(1, ENV_SEMA, 0);			/* HR */
	Psemaphore(1, PENDING_SEMA, 0);

DIAGS(("Bye!\n"));
DIAGS(("\n"));
DIAGS(("\n"));
DIAGS(("\n"));
DIAGS(("\n"));
DIAGS(("\n"));

	/* Close the debug output file */

	IFDIAG (if (D.debug_file > 0)
	        {
		       Fclose(D.debug_file);
		    })

	t_color(BLACK);
	wr_mode(MD_REPLACE);

	/* Shut down the VDI */

	v_clrwk(C.vh);					/* HR 080202 */

	if (cfg.auto_program)
	{
#if 0
		int i;

		for (i=512; i>=C.vh; i--)
		{
			char p[20];
			sdisplay(p, "-= vh %d =- ", i);
			v_gtext(C.vh, 0, 64, p);
			v_clsvwk(i);
		}
#else
		v_clsvwk(C.vh);
#endif
/* HR 130302: v_clswk bombs with NOVA VDI 2.67 & Memory Protection.
              so I moved this to the end of the cleanup, AFTER closing the debugfile. */

		v_clswk(C.P_handle);		/* Auto version must close the physical workstation */

		display("\033e\033H");			/* HR 100302: Cursor enable, cursor home */
	}
	else
	{
		v_clsvwk(C.vh);
		appl_exit();
	}
}

/*
 * (Re)initialise the mouse device /dev/moose
 */
static
bool init_moose(void)
{
	MOOSE_INIT_COM i_com;
	MOOSE_DCLICK_COM dc_com;

	if (!C.MOUSE_dev)
	{
		C.MOUSE_dev = Fopen(moose_name, O_RDWR);
		if (C.MOUSE_dev < 0)
		{
			err = fdisplay(loghandle, true, "Can't open %s\n", moose_name);
			return false;
		}
	}

	i_com.init_prefix = MOOSE_INIT_PREFIX;			/* Load the command prefix into the command */
	i_com.dum = nil;			/* HR: 19 october 2000; switched over to VMOOSE, the vdi vector using moose. */

	if (Fwrite(C.MOUSE_dev, 6L, &i_com) == 0)
		err = fdisplay(loghandle, true, "Moose init failed\n");
	else
	{
		long dev = 1L<<C.MOUSE_dev;
		vecs_com.vecs_prefix = MOOSE_VECS_PREFIX;
		/* HR: obtain the addresses of the vdi change routines (in the moose) */
		Fselect(1, &dev, 0, 0);
		if (dev&(1L<<C.MOUSE_dev))
			Fread(C.MOUSE_dev, sizeof(MOOSE_VECS_COM), &vecs_com);

		dc_com.dclick_prefix = MOOSE_DCLICK_PREFIX;
		dc_com.dclick_time = lcfg.double_click_time;

		if (Fwrite(C.MOUSE_dev, 4L, &dc_com) == 0)
			err = fdisplay(loghandle, true, "Moose set dclick time failed\n");
	}

	if (vecs_com.motv)			/* HR */
	{
		vex_motv(C.P_handle, vecs_com.motv, &svmotv);
		vex_butv(C.P_handle, vecs_com.butv, &svbutv);
		if (vecs_com.whlv)
		{
			vex_whlv(C.P_handle, vecs_com.whlv, &svwhlv);
			fdisplay(loghandle, true, "Wheel support present\n");
		}
		else
			fdisplay(loghandle, true, "No wheel support!!\n");
	}

	return true;
}

global
XA_WINDOW *root_window;

global
void reopen_moose(void)
{									
	MOOSE_DCLICK_COM dc_com;
	C.MOUSE_dev = Fopen(moose_name, O_RDWR);
	dc_com.dclick_prefix = MOOSE_DCLICK_PREFIX;
	dc_com.dclick_time = 50;
	/*	dc_com.dclick_time = lcfg.double_click_time;*/
	if (Fwrite(C.MOUSE_dev, 4L, &dc_com) == 0)
	{
		DIAG((D_mouse, nil,"moose set dclick time failed\n"));
	}
}

IFDIAG(long strtclk;)

/*
 *	Startup & Initialisation...
 *	- Spawn off any extra programs we need (mouse server, etc).
 *	- Open physical & virtual workstations.
 *	- Install our trap handler.
 *	- Run the xaaes.cnf startup script.
 */

global
G_i main(G_i argc, char *argv[],char *env[])
{
	LOCK lock = NOLOCKS;
	G_i work_in[12];
	G_i work_out[58];
	int f;
	char *resource_name, *full;

	XA_set_base(nil, 32768, -1, 0);

	loghandle = Fcreate("xa_setup.log", 0);		/* HR 220402: open the log. */

	lcfg.booting = true;
	memset(&default_options, 0, sizeof(default_options));
	memset(&cfg,0,sizeof(cfg));
	memset(&S,0,sizeof(S));
	memset(&C,0,sizeof(C));
	strcpy(C.cmd_name, "u:" sbslash "pipe" sbslash "XaAES.cmd");

	
#if GENERATE_DIAGS
	#if DEBUG_BOOT
		memset(&D,0,sizeof(D));
		D.debug_level = 4;
		D.debug_file = (int)Fcreate("xaaes.log", 0);
		Fforce(1, D.debug_file);
	#endif
	sdisplay(Aes_display_name, "  XaAES(dbg) %s", version);
BTRACE(1);
#else
	sdisplay(Aes_display_name, "  XaAES %s", version);
#endif

	cfg.font_id = STANDARD_AES_FONTID;			/* Font id to use */
	cfg.standard_font_point = STANDARD_FONT_POINT;	/* Size for normal text */
	cfg.medium_font_point = MEDIUM_FONT_POINT;		/* The same, but for low resolution screens */
	cfg.small_font_point = SMALL_FONT_POINT;		/* Size for small text */
	cfg.ted_filler = '_';
	cfg.menu_locking = true;
	cfg.backname = FAINT;
	cfg.widg_w = ICON_W;
	cfg.widg_h = ICON_H;

#if ! FILESELECTOR
	cfg.no_xa_fsel = true;
	DIAGS(("XaAES is compiled without builtin fileselector\n"));
#endif

	IFDIAG(strtclk = clock();)

	{
		char **p = env;
BTRACE(2);
		while (*p and p - env < STRINGS)
			C.strings[envs++] = *p++;
BTRACE(3);
		C.env = C.strings[0];
BTRACE(4);
	}

	/* Check that MiNT is actually installed */
	if (Ssystem(-1, 0, 0) != 0)
	{
BTRACE(5);
		bootmessage(0);
		fdisplay(loghandle, true, "Sorry, XaAES requires MiNT >= 1.15.0 to run.");

		IFDIAG (if (!D.debug_file) {display(">");bios(2,2);})
		Fclose(loghandle);
		exit(1);
	}

	/* Let's get our MiNT process id being as MiNT is loaded... */
BTRACE(6);
	C.AESpid = Pgetpid();

BTRACE(7);
	Pnice(-1);
	Pdomain(1);			/* HR The kernel runs in the MiNT domain. */

BTRACE(8);
	argv[0] = get_procname(C.AESpid);		/* HR: 211200 */

BTRACE(9);
/* Ulrichs advice */
	sdisplay(cfg.scrap_path, "u:" sbslash "proc" sbslash "%s.%d", argv[0], C.AESpid);
	sdisplay(cfg.acc_path,   "u:" sbslash "proc" sbslash "AESSYS.%d",      C.AESpid);
	fdisplay(loghandle, true, "rename: '%s' to '%s'\n", cfg.scrap_path, cfg.acc_path);

BTRACE(10);
	Frename(0, cfg.scrap_path, cfg.acc_path);

									     /* 'F S E L' */
BTRACE(11);
	cfg.fsel_cookie = Ssystem(S_GETCOOKIE, 0x4653454cL, 0) != 0xffffffff;

	/* HR: dynamic window handle allocation. */
	clear_wind_handles();

BTRACE(12);
	/* Initialise the object tree display routines */
	init_objects();

	C.Aes = NewClient(C.AESpid);		/* So we can speak to and about ourself. */

BTRACE(13);
	if (C.Aes == nil)
	{
		err = fdisplay(loghandle, true, "XaAES ERROR: Can't allocate memory ?\n");
		cleanup() ;
		return -1;
	}
	strcpy(C.Aes->cmd_name,"XaAES");
	C.Aes->parent = Pgetppid();
	strcpy(C.Aes->name, Aes_display_name);
	strcpy(C.Aes->proc_name,"AESSYS  ");

BTRACE(14);
	/* Change the protection mode to OS_SPECIAL to allow operation with
	 * memory protection (doesn't work yet, what's wrong?)
	 */
	/* Craig's Note: I think this causes a massive memory leak in the MiNT kernal, so
	 * I've disabled it
	 */
#if MEMORY_PROTECTION
	{
		G_i proc_handle;
		long protection;
	#ifndef F_PROT_S
		#define F_PROT_S	0x20
	#endif
	#ifndef F_OS_SPECIAL
		#define F_OS_SPECIAL	0x8000
	#endif
		/*	Opening "u:\proc\.-1" opens the current process... */
		
BTRACE(15);
		if ((proc_handle = Fopen("u:" sbslash "proc" sbslash ".-1", O_RDONLY)) >= 0)
		{
        	/* get process memory flags */
BTRACE(16);
			Fcntl(proc_handle, (long)&protection, PGETFLAGS);
 			protection_flags = protection;
   		/* delete protection mode bits */
			protection &= 0xffffff0fUL;
 			/* super access, OS special */
			protection |= F_OS_SPECIAL | F_PROT_S;
			/* set process memory flags */
BTRACE(17);
			Fcntl(proc_handle, (long)&protection, PSETFLAGS);
BTRACE(18);
			Fclose(proc_handle);
BTRACE(19);
		}
	}
#endif

	/* Where were we started? */
	
	C.home_drv = Dgetdrv();
	DIAGS(("Home drive: %d\n", C.home_drv));

	Dgetpath(C.home, 0);
	DIAGS(("Home directory: '%s'\n", C.home));

	Dgetcwd(C.home, C.home_drv + 1, sizeof(C.home) - 1);

	DIAGS(("current working directory: '%s'\n", C.home));
	DIAGS(("argv[0]: '%s'\n", argv[0]));

	sdisplay(Aes_home_path, "%c:%s", C.home_drv + 'A', C.home);

	C.Aes->xdrive = C.home_drv;
	strcpy(C.Aes->xpath, C.home);

	/* Are we an auto/mint.cnf launched program? */

	/* Note: globl[0] (AES version number) is initially zero. */
	/* HR: Yeah? make sure :-)  150501: use structs!!! */
	globl.version = 0;		
BTRACE(20);
	appl_init();
BTRACE(21);
	cfg.auto_program = (globl.version == 0);	/* globl[0] still zero? */

	for (f = 0; f < 10; f++)				/* HR start at 0 */
		work_in[f] = 1;
	work_in[10] = 2;
	
	if (cfg.auto_program)
	{
#if 0
		if ((Kbshift(-1) & 3) and (Getrez() == 0))	/* Any shift key and low rez */
			Setscreen((void*)-1L, (void*)-1L, 1, 0);	/* Switch to medium rez */
		else
#endif
		{
			/* Set video mode from command line parameter? */			
			if (argc > 2)
			{
				lcfg.havemode = true;
				ipff_in(argv[2]);
				sk();
				switch (tolower(*argv[2]))
				{
				case 'o':  lcfg.modecode = (skc(), oct());  break;
				case 'x':  lcfg.modecode = (skc(), hex());  break;
				case 'b':  lcfg.modecode = (skc(), bin());  break;
				default :  lcfg.modecode =         idec();  break;
				}

				if (stricmp("-fvideo", argv[1]) == 0) 		/* Falcon Video mode switch */
				{
										/* '_VDO' */
					Ssystem(S_GETCOOKIE, 0x5f56444fL, (long)&lcfg.falcon);

					if (lcfg.falcon == 0x00030000L)
					{
#if __PUREC__
						work_out[45] = lcfg.modecode;
#else
						/* FIX_ME: Those who know how to reach ptsout for other
						   compilers libraries, please come forward. :-)
						*/
#endif
						work_in[0] = 5;    /* Ronald Andersson: This should be the mehod for falcon. */
						DIAGS(("Falcon: mode %d(%x)\n", lcfg.modecode, lcfg.modecode));
					othw
						DIAGS(("-fvideo: No, or incorrect _VDO cookie: %lx\n", lcfg.falcon));
					}

				othw
					if (stricmp("-video", argv[1]) == 0) 	/* Video mode switch */
					{
						work_in[0] = lcfg.modecode;
						DIAGS(("Standard: mode %d(%x)\n", lcfg.modecode, lcfg.modecode));
					}
					else
					{
#if 0
						lcfg.modecode = Getrez();
						work_in[0] = lcfg.modecode + 2;
						DIAGS(("Standard: Getrez() = %d(%x)\n", lcfg.modecode, lcfg.modecode));
#else
						DIAGS(("Invalid agument: '%s'\n", argv[1]));
#endif
					}
				}
			othw
				DIAGS(("Default screenmode.\n"));
			}

			IFDIAG (if (!D.debug_file) {display(">");bios(2,2);})	/* Before screen is cleared :-) */
			v_opnwk(work_in, &C.P_handle, work_out);

			fdisplay(loghandle, true, "\033HPhysical work station opened: %d\n",C.P_handle);
		}
	} else
	{
		G_i junk;
		C.P_handle = graf_handle(&junk, &junk, &junk, &junk);	/* The GEM AES has already been started,  */
									/*  so get the physical workstation handle from it */
	}

	/* Setup the kernel OS call jump table */
	
BTRACE(22);
	setup_k_function_table();


BTRACE(23);

	/* Create a whole wodge of semphores */

	DIAGS(("Creating Semaphores\n"));

	Psemaphore(0, APPL_INIT_SEMA, 0);
/*	Psemaphore(0, TRAP_HANDLER_SEMA, 0); */
	IFWL(Psemaphore(0, WIN_LIST_SEMA, 0);)
	Psemaphore(0, ROOT_SEMA, 0);
	Psemaphore(0, CLIENTS_SEMA, 0);
	Psemaphore(0, UPDATE_LOCK, 0);
	Psemaphore(0, MOUSE_LOCK, 0);
	Psemaphore(0, FSELECT_SEMA, 0);

	Psemaphore(0, ENV_SEMA, 0);			/* HR */
	Psemaphore(0, PENDING_SEMA, 0);

	/* Print a text boot message */

BTRACE(24);
	lcfg.mint = Ssystem(S_OSVERSION,0,0);

BTRACE(124);
#if MEMORY_PROTECTION
	if (lcfg.mint >= 0x10f0b00)				/* HR 100701  mint >= 1.15.11 */
		C.mvalidate = true;
#endif

BTRACE(224);
	bootmessage(lcfg.mint);
BTRACE(25);


	/* Patch the AES trap vector to use our OS. */
	hook_into_vector();
BTRACE(26);

	/* Open the MiNT Salert() pipe to be polite about system errors */
	C.Salert_pipe = Fopen("u:" sbslash "pipe" sbslash "alert", O_CREAT|O_RDWR);

	/* Open the u:/dev/console device to get keyboard input */

	C.KBD_dev = Fopen("u:" sbslash "dev" sbslash "console", O_DENYRW|O_RDONLY);	/* HR 101202: O_DENYRW */
	if (C.KBD_dev < 0)
	{
		err = fdisplay(loghandle, true, "XaAES ERROR: Can't open /dev/console ?\n");
		cleanup() ;
		return -1;
	}

	{
		IFDIAG(void *haha =)
		nkc_init();
		DIAGS(("nkc_init: tables are at %lx\n", haha));
	}

	/* Open us a virtual workstation for XaAES to play with */

BTRACE(27);
	C.vh = C.P_handle;
	v_opnvwk(work_in, &C.vh, work_out);
	vsf_perimeter(C.vh, 0);		/* HR 051002: from set_colours; never set to 1 ever */

BTRACE(28);
	graf_mouse(ARROW, nil);
	v_hide_c(C.vh);
	wr_mode(MD_TRANS);				/* We run in TRANSPARENT mode for all AES ops (unless otherwise requested) */
	vst_alignment(C.vh, 0, 5, &f, &f);		/* YESss !!! */

	DIAGS(("Virtual work station opened: %d\n",C.vh));

	/* Setup the screen parameters */

BTRACE(29);
	screen.r.x = screen.r.y = 0;
	screen.r.w = work_out[0] + 1;	/* HR + 1 */
	screen.r.h = work_out[1] + 1;	/* HR + 1 */
	clear_clip();
BTRACE(30);
	screen.colours = work_out[13];
	screen.display_type = D_LOCAL;

	screen.dial_colours =
		MONO ? bw_default_colours : default_colours;

BTRACE(31);
	vq_extnd(C.vh, 1, work_out);			/* Get extended information */
	screen.planes = work_out[4];				/* number of planes in the screen */

	DIAGS(("Video info: width(%d/%d), planes :%d, colours %d\n",
				screen.r.w, screen.r.h, screen.planes, screen.colours));

	/* Set the default clipboard */

	strcpy(cfg.scrap_path, "c:" sbslash "clipbrd" sbslash "");


	/* Set the default accessory path */
	
	strcpy(cfg.acc_path, "c:" sbslash "");

	/* FIX_PC  .lst */
	IFDIAG (strcpy(D.debug_path, "xaaes.log");)			/* By default debugging output goes to the file "./debug.lst"*/

	strcpy(C.Aes->home_path, Aes_home_path);

	IFDIAG (if (!D.debug_file) {display(">");bios(2,2);})

	/* Create the XaAES.cmd introduction pipe */

	C.AES_in_pipe = Fopen(C.cmd_name, O_CREAT|O_RDWR);
	fdisplay(loghandle, true, "Open '%s' to %ld\n", C.cmd_name, C.AES_in_pipe);
	if (C.AES_in_pipe < 0)
	{
		err = fdisplay(loghandle, true, "XaAES ERROR: Can't open '%s' :: %ld\n", C.cmd_name, C.AES_in_pipe);
		cleanup() ;
		return -1;
	}

	/* Parse the standard startup file.
	 * This can redirect the debugging output to another file/device
	 */

	full = xa_find(scls_name);
	if (full)
		SCL(NOLOCKING, 0, scls_name, full, nil);
	else		/* transition time */
	{
		SCL(NOLOCKING, 2, old_name, nil, nil);
		lcfg.oldcnf = true;
	}
	
#if SCL_HOOKS
	full = xa_find(scl1_name);
	if (full)
		SCL(NOLOCKING, 0, scl1_name, full, nil);
#endif

BTRACE(32);
	C.Aes->options = default_options;
BTRACE(33);

	/* Open /dev/moose (HR 040201: after xa_setup.scl for mouse configuration) */
	
	if (!init_moose())
	{
BTRACE(34);
		cleanup();
		return -1;
	}

	/* If we are using anything apart from the system font for windows,
	 * better check for GDOS and load the fonts.
	 */

	if (cfg.font_id != 1)
	{
BTRACE(35);
		if (vq_gdos())					/* Yeah, I know, this is assuming the old-style vq_gdos() binding */
		{
BTRACE(36);
			vst_load_fonts(C.vh, 0);
BTRACE(37);
		}
		else
		{
BTRACE(38);
			cfg.font_id = 1;
		}
	}


	/* Set standard AES font */

BTRACE(39);
	screen.standard_font_id = screen.small_font_id =
		vst_font(C.vh, cfg.font_id);


	/* HR 110202: Use the ability of vst_point to return the character cell measures. */
	/* Select Small font */

BTRACE(40);
	screen.small_font_point = vst_point(C.vh,
		cfg.small_font_point,
		&f,
		&screen.small_font_height,
		&screen.c_min_w,
		&screen.c_min_h);


	/* Select standard font */

BTRACE(41);
	screen.standard_font_point = vst_point(C.vh,
 		(screen.r.h <= 280) ? cfg.medium_font_point : cfg.standard_font_point,
		&f,
		&screen.standard_font_height,
		&screen.c_max_w,
		&screen.c_max_h);

	/* Open a diagnostics file? All console output can be considered diagnostics,
	 * so I just redirect the console to the required file/device
	 */

	DIAGS(("Display Device: Phys_handle=%d, Virt_handle=%d\n", C.P_handle, C.vh));
	DIAGS((" size=[%d,%d], colours=%d, bitplanes=%d\n", screen.r.w, screen.r.h, screen.colours, screen.planes));

	/* Load the system resource files */
	resource_name = xa_find(lcfg.rsc_name);
	if (resource_name)
	{
		C.Aes_rsc = LoadResources(C.Aes, resource_name, nil, DU_RSX_CONV, DU_RSY_CONV);
		IFDIAG(
			if (C.Aes_rsc)
				fdisplay(loghandle, true, "system resource = %lx\n", C.Aes_rsc);)
	}	
	if (!resource_name or !C.Aes_rsc)
	{
		err = fdisplay(loghandle, true, "ERROR: Can't find/load system resource file '%s'\n",lcfg.rsc_name);
		cleanup();
		return -1;
	}
	widget_resources = nil;
	resource_name = xa_find(lcfg.widg_name);
	if (resource_name)
	{
		widget_resources = LoadResources(C.Aes, resource_name, nil, DU_RSX_CONV, DU_RSY_CONV);
		IFDIAG(
			if (widget_resources)
				fdisplay(loghandle, true, "widget_resources= %lx\n", widget_resources);)
	}
	if (!resource_name or !widget_resources)
	{
		err = fdisplay(loghandle, true, "ERROR: Can't find/load widget resource file '%s'\n",lcfg.widg_name);
		cleanup();
		return -1;
	}

	{				/* HR 251201: get widget object parameters. */
		RECT c;
		OBJECT *tree = ResourceTree(widget_resources, 0);
		object_area(&c, tree, 1, 0, 0);
		cfg.widg_w = c.w;
		cfg.widg_h = c.h;
		cfg.widg_dw = (tree[1].r.w - c.w)/2;
		cfg.widg_dh = (tree[1].r.h - c.h)/2;
		fdisplay(loghandle, true, "cfg.widg: %d/%d   %d/%d\n", cfg.widg_w, cfg.widg_h, cfg.widg_dw, cfg.widg_dh);
	}
#if FILESELECTOR
	/* HR: Do some itialisation */
BTRACE(42);
	init_fsel();
BTRACE(43);
#endif

	/* Create the root (desktop) window
	 * - We don't want messages from it, so make it a NO_MESSAGES window
	 */
	
	DIAGS(("creating root window\n"));

	root_window =
		create_window(
					NOLOCKING,
					nil,					/* No messages */
					C.Aes,
					false,
					XaMENU,					/* HR: menu standard widget */
					created_for_AES,
					-1,						/* HR: -1, no frame, overscan window */
					false,false,
					 screen.r,				/*  current size */
					 &screen.r,			/*  maximum size (NB default would be rootwindow->wa) */
					 nil );					/* need no remembrance */

	/* Tack a menu onto the root_window widget */
	C.Aes->std_menu.tree = ResourceTree(C.Aes_rsc, SYSTEM_MENU);	/* HR widget.tree */
	C.Aes->std_menu.owner = C.Aes;
/*
	set_ob_spec(C.Aes->std_menu.tree, SYS_DESK, (long)Aes_display_name);
	(C.Aes->std_menu.tree + SYS_DESK)->r.w = strlen(Aes_display_name) * screen.c_max_w;
*/
BTRACE(44);
	fix_menu(C.Aes->std_menu.tree,true);										/* HR */
BTRACE(45);
	set_menu_widget(root_window, &C.Aes->std_menu);		/* HR */

BTRACE(46);
	{
		char *vs = get_ob_spec(C.Aes->std_menu.tree + SYS_DESK)->string;
		strcpy(vs + strlen(vs) - 3, version + 3);
	}

	DIAGS(("menu widget set\n"));

	/* Fix up the file selector menu */
BTRACE(47);
	fix_menu(ResourceTree(C.Aes_rsc, FSEL_MENU),false);

	/* Fix up the window widget bitmaps and any others we might be using
   	 * (Calls vr_trnfm() for all the bitmaps)
   	 * HR: No, it doesnt! ;-)
   	 */
	 
	DIAGS(("fixing up widgets\n"));
	fix_default_widgets(widget_resources);

	/* Set a default desktop */

	DIAGS(("setting default desktop\n"));
	
	{
		OBJECT *ob = get_xa_desktop();
		ob->r = root_window->r;
		(ob + DESKTOP_LOGO)->r.x = (root_window->wa.w - (ob + DESKTOP_LOGO)->r.w) / 2;
		(ob + DESKTOP_LOGO)->r.y = (root_window->wa.h - (ob + DESKTOP_LOGO)->r.h) / 2;
		C.Aes->desktop.tree = ob;
		C.Aes->desktop.owner = C.Aes;
		
		set_desktop_widget(root_window, &C.Aes->desktop);
		set_desktop(&C.Aes->desktop);
	}

	DIAGS(("setting up task manager\n"));
	
/* HR moved the title to set_slist_object() */
	/* Setup the task manager */
	set_scroll(C.Aes, ResourceTree(C.Aes_rsc, TASK_MANAGER), TM_LIST);
BTRACE(48);

	/* Setup the file selector */
	set_scroll(C.Aes, ResourceTree(C.Aes_rsc, FILE_SELECT), FS_LIST);
BTRACE(49);

	/* Setup the System Alert log */
	set_scroll(C.Aes, ResourceTree(C.Aes_rsc, SYS_ERROR), SYSALERT_LIST);
BTRACE(50);

	/* Setup the About text list */
	set_scroll(C.Aes, ResourceTree(C.Aes_rsc, ABOUT_XAAES), ABOUT_LIST);
BTRACE(51);

	/* Display the root window */
	
	DIAGS(("About to display root window\n"));

	open_window(NOLOCKING, root_window, screen.r);
	
	/* Initial iconified window coords */

BTRACE(52);
	C.iconify = iconify_grid(0);		/* HR */

	/* Set our process priority
	 * - a high negative value here improves performance a lot, 
	 * so I set it to -20 in XA_DEFS.H. This doesn't hurt the rest
	 * of the systems performance, as there are no busy wait loops
	 * in the server, and it spends most of its time blocked
	 * waiting for commands.
	 */


	/* Catch SIGCHLD to spot dead children */
	
BTRACE(53);
	Psignal(SIGCHLD, (long)HandleSIGCHLD);

	/* Catch SIGINT and SIGQUIT so we can shutdown with CTRL+ALT+C */

#if 1
	Psignal(SIGINT, (long)HandleSIGINT);
	Psignal(SIGQUIT, (long)HandleSIGQUIT);
#endif

	v_show_c(C.vh, 0);		/* 0 = reset */		

	if (cfg.opentaskman)
		open_taskmanager(NOLOCKING, false);

	/* Load Accessories */

	DIAGS(("loading accs\n"));
	load_accs();

	/* Execute startup
	 * This can run programs
	 */

#if SCL_HOOKS
	full = xa_find(scl2_name);
	if (full)
		SCL(NOLOCKING, 1, scl2_name, full, nil);
#endif

	if (!lcfg.oldcnf)
#if ! SEPARATE_SCL
		SCL(NOLOCKING, 1, scle_name, nil, nil);
#else
	/* HR 130402: xa_scl */
	{
		char par[256];
		char *p, *n = xa_find(scle_name);
		if (n)
		{
			par[0] = sdisplay(par + 1, "%s", n); /* Grrrrrrr!!!!! */
			p = xa_find(sclp_name);
			if (p)
				launch(NOLOCKING, 0, 0, 0, p, par, C.Aes);
		}
	}
#endif

	/* HR: I just like to have the unlocks at the same level as the locks. */

	/* Unlock the semaphores...we're ready to go */

/*	Sema_Dn(trap);
	IFWL(Sema_Dn(winlist);)
*/	Sema_Dn(desk);
	Sema_Dn(update);
	Sema_Dn(mouse);
	Sema_Dn(fsel);

	Sema_Dn(envstr);			/* HR */
	Sema_Dn(pending);


	Sema_Dn(clients);
	Sema_Dn(appl);

	DIAGS(("Semaphores Unlocked!!!\n"));
	
	fdisplay(loghandle, false, "*** End of successfull setup ***\n");
	Fclose(loghandle);			/* HR 220402: close the log. */

	lcfg.booting = false;

	IFDIAG(strtclk = clock();)

	/* Call the main command interpreter kernel */
	
	DIAGS(("------------- Going to the kernel -------------\n"));

	XaAES();


	/* Closedown & exit */
	
	cleanup();

	return 0;
}

static
XA_WINDOW *about_window = nil;	/* HR */

static
WindowDisplay about_destructor	/* HR */
{
	about_window = nil;
	return TRUE;
}

static
ObjectHandler handle_about /* (LOCK lock, XA_TREE *wt) */		/* The ''form_do'' part */
{
	if ( (wt->current&0xff) == ABOUT_OK)
	{
		deselect(wt->tree, ABOUT_OK);
		display_toolbar(lock, about_window, ABOUT_OK);
		close_window(lock, about_window);
		delete_window(lock, about_window);
	}
}

global
void open_about(LOCK lock)
{
	XA_WINDOW *dialog_window;
	XA_TREE *wt;
	SCROLL_INFO *list;
	OBJECT *form = ResourceTree(C.Aes_rsc, ABOUT_XAAES);
	static RECT remember = {0,0,0,0};

	if (!about_window)
	{
		/* HR */
	/* Work out sizing */
		if (!remember.w)
		{
			center_form(form, ICON_H);
			remember =
			calc_window(lock, C.Aes, WC_BORDER, CLOSE|NAME, MG,
							 C.Aes->options.thinframe,
							 C.Aes->options.thinwork, form->r);		/* HR */
		}

	/* Create the window */
		dialog_window = create_window(lock, nil,
							C.Aes,
							false,
							CLOSE|NAME|
							MOVE|
							TOOLBAR,
							created_for_AES,
							MG,
							C.Aes->options.thinframe,C.Aes->options.thinwork,
							remember, nil, &remember);

	/* Set the window title */
		get_widget(dialog_window, XAW_TITLE)->stuff = "  About  ";
	/* Set version date */
		(form + ABOUT_DATE)->ob_spec.string = __DATE__;

		wt = set_toolbar_widget(lock, dialog_window, form, -1);
		wt->exit_form = XA_form_exit;		/* HR 250602 */
		wt->exit_handler = handle_about;
	
	/* HR: set a scroll list widget */
		list = set_slist_object(lock, wt, form, ABOUT_LIST, nil, nil, nil, nil, nil, nil, 42);

	/* fill the list if already list */
		if (!list->start)
		{
			char **t = about_lines;
			while (*t)
			{
				add_scroll_entry(form, ABOUT_LIST, nil, *t, 0);
				t++;
			}
		}
		
		list->slider(list);

	/* Set the window destructor */
		dialog_window->destructor = about_destructor;
		open_window(lock, dialog_window, remember);
		about_window = dialog_window;
	}
	else if (about_window != window_list)
	{
		C.focus = pull_wind_to_top(lock, about_window);			/* HR */
		after_top(lock, true);
		display_window(lock, 3, about_window, NULL);
	}
}

global
void strnupr(char *s, int n)
{
	int f;
	for (f = 0; f < n; f++)
		s[f] = toupper(s[f]);
}

XA_report punit
{
	display("**** %s: ", txt);
	if (!unit)
	{
		display("nil\n");
	othw
		XA_unit *prior = unit->prior, *next = unit->next;
		display(" -%d- %ld :: %ld, p:%ld :: %ld, n:%ld :: %ld, block %ld :: %ld\n",
			unit->key,
			unit, unit->size,
			prior, prior?prior->size:-1,
			next, next?next->size:-1,
			blk, blk->size);
	}
}


#include "xalloc.h"

#if 0
/* HR: once used to debug a window_list corruption.
       also a example of how to use this trace facility. */
global
long xa_trace(char *t)
{
	long l = 0;
	return l;
}
#endif

/* HR 130402: xa_scl */
void handle_XaAES_msgs(LOCK lock, MSG_BUF *msg)
{
	{
		MSG_BUF m = *msg;
		int mt = m.s.msg;
		DIAGS(("Message to AES %d\n", mt));
		m.s.msg = 0;

		switch (mt)
		{
			case XA_M_EXEC:
			{
				char *txt = m.s.p2;
				if (txt)
				{
					DIAGS(("Exec scl '%s'\n", txt));
					SCL(lock, 1, nil, nil, txt);
					m.s.msg = XA_M_OK;
				}
			}
			break;

			case XA_M_GETSYM:
			{
				char *txt = m.s.p2;
				if (txt)
				{
					SYMBOL *t, *f = m.s.p1;
					DIAGS(("Get sym '%s'\n", txt));
					
					if (f)
					{
						t = find_sym(txt, nil);
						if (t)
						{
							DIAGS((" --> '%s'\n", t->s));
							*f = *t;
							m.s.msg = XA_M_OK;
						}
					}
				}
			}
			break;

			case XA_M_DESK:
				DIAGS(("Desk %d, '%s'\n", m.s.m3, m.s.p2 ? m.s.p2 : "~~~"));
				if (m.s.p2 and m.s.m3)
				{
					strcpy(C.desk, m.s.p2);
					C.DSKpid = m.s.m3;
					m.s.msg = XA_M_OK;
				}
			break;
		}	
		send_a_message(lock, m.m[1], &m);
	}
}

global
void *xmalloc(size_t size, int key)
{
	void *a;
	DIAG((D_x, nil,"XA_alloc %ld k:%d\n", size, key));
	a = XA_alloc(nil, size, key, 0);
	DIAG((D_x, nil,"     --> %ld\n", a));
	return a;	
}

global
void *xcalloc(size_t items, size_t size, int key)
{
	void *a;
	DIAG((D_x, nil,"XA_calloc %ld*%ld, k:%d\n", items, size, key));
	a = XA_calloc(nil, items, size, key, 0);
	DIAG((D_x, nil,"     --> %ld\n", a));
	return a;
}

global
void *malloc(size_t size)
{
	return XA_alloc(nil, size, 0, 0);
}

global
void *calloc(size_t items, size_t size)
{
	return XA_calloc(nil, items, size, 0, 0);
}

global
void free(void *addr)
{
	IFDIAG(XA_unit *un; (long)un = (long)addr - unitprefix;)
	DIAG((D_x, nil,"XA_free %ld k:%d\n", addr, un->key));
	XA_free(nil,addr);
}

global
void _FreeAll(void)
{
	DIAG((D_x, nil,"XA_free_all\n"));
	XA_free_all(nil, -1, -1);
}
