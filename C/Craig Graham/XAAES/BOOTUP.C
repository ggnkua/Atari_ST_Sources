/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <VDI.H>
#include <OSBIND.H>
#include <MINTBIND.H>
#include <UNISTD.H>
#include <FILESYS.H>
#include <SIGNAL.H>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ostruct.h>
#include "xa_defs.h"
#include "k_defs.h"
#include "xa_types.h"
#include "frm_alrt.h"
#include "handler.h"
#include "cookies.h"
#include "kernal.h"
#include "mouse_cl.h"
#include "c_window.h"
#include "std_widg.h"
#include "XA_GLOBL.H"
#include "system.h"
#include "signals.h"
#include "shellwrt.h"
#include "resource.h"
#include "objects.h"
#include "about.h"
#include "DESKTOP.H"
#include "F_XBIOS.H"

/* aes.h confilcts with k_defs.h, so we can't use it here... :-( */
#if defined(LATTICE)		/* ----- Lattice C ----- */
extern short _AESglobal[15];
#define global _AESglobal
int __regargs _AESif(unsigned int);
#define appl_init() _AESif(0)
extern int graf_handle(short *,short *,short *,short *);
#define appl_exit()	_AESif(36)
#elif defined(__PUREC__)	/* ----- Pure C 1.1 ----- */
typedef struct
{
	int		contrl[15];
	int		global[15];
	int		intin[132];
	int		intout[140];
	void	*addrin[16];
	void	*addrout[16];
} GEMPARBLK;
extern  GEMPARBLK _GemParBlk;
#define global _GemParBlk.global
extern int appl_init(void);
extern int graf_handle(int *,int *,int *,int *);
extern int appl_exit(void);
#else						/* ----- others ----- */
extern short global[] ;
extern int appl_init(void) ;
extern int graf_handle(int *,int *,int *,int *);
extern int appl_exit(void);
#endif

/*
	Boot up code
*/

const char select_ink[]={27,'b',0};
const char select_paper[]={27,'c',0};

void _XCEXIT(void)
{
	exit(0);
}

void BootMessage(void)
{
	printf("XaAES ");
	printf(XA_VERSION);
	printf("\nMultiTasking AES for MiNT\n");
	printf("(w)1995,96, Craig Graham, Johan Klockars, Martin Koehling, Thomas Binder\n");
	printf("Date: %s\n",__DATE__);
	printf("Compile time switches enabled:\n");

#if GENERATE_DIAGS
	printf(" - Diagnostics\n");
#endif

#if FORCE_WINDOWS
	printf(" - Force windows\n");
#endif

#if SOLID_BOXES
	printf(" - Solid boxes\n");
#endif

#if MONO_WIDGETS
	printf(" - Mono widgets\n");
#else
	printf(" - Colour widgets\n");
#endif
		
#if DISPLAY_LOGO_IN_TITLE_BAR
	printf(" - Logo in title bar\n");
#endif

#if POINT_TO_TYPE
	printf(" - Point-to-type\n");
#endif

#if ALT_CTRL_APP_OPS
	printf(" - CTRL+ALT key-combo's\n");
#endif

#if USE_CALL_DIRECT
	printf(" - Use direct-call\n");
#endif

#if AVOID_MINT_PIPES_BUG
	printf(" - Avoid MiNT pipe delete bug\n");
#endif

#if EMULATE_AES4_1
	printf(" - Emulate AES4.1\n");
#else
	printf(" - Emulate AES1.4\n");
#endif

#if DODGY_MEMORY_PROTECTION
	printf(" - Dodgy OS_SPECIAL memory access\n");
#endif

#if JOHAN_RECTANGLES
	printf(" - Johan's new rectangle lists\n");
#endif

	printf("\n");
}

short P_handle=0,V_handle=0;		/* Workstation handles used by the AES */
XA_SCREEN display;					/* The display descriptor */
const XA_COLOUR_SCHEME default_colours={LWHITE,BLACK,LBLACK,WHITE,BLACK,CYAN};
const XA_COLOUR_SCHEME bw_default_colours={WHITE,BLACK,BLACK,BLACK,BLACK,BLACK};
int AES_in_pipe;					/* The AES instruction input pipe handle */
unsigned long client_handle_mask=0L;	/* Mask of all active client pipes for Fselect */

int MOUSE_in_pipe;					/* The MOUSE data packet input pipe handle */

long KBD_device;					/* The MiNT keyboard device's file handle */

short AESpid;						/* The AES's MiNT process ID */

XA_WINDOW *root_window;				/* The desktop window */

#if GENERATE_DIAGS
char debug_path[100];				/* Path to dump debug info to */
short debug_file;					/* File handle to dump debug stuff to */
#endif

char XaAES_home[200];				/* XaAES's home location */
short XaAES_home_drv;

char scrap_path[128];				/* Path to the scrap directory */
char acc_path[128];					/* Path to desk accessory directory */

void *system_resources;				/* Pointer to the XaAES resources */
const char dummy_cmd_tail[]="\0"; 	/* Dummy constants used for distinguishing */
const char dummy_cmd_name[]=""; 	/* malloced from non-malloced strings... */

/* mode codes for falcon video mode switch */
const short falcon_modes[]=	{0+0x8+0x10,1+0x8+0x10,2+0x8+0x10,3+0x8+0x10};

short iconify_x,iconify_y,iconify_w,iconify_h;	/* Positioning information for iconifying windows */

short mouse_pid;

/*
	Read & parse the 'xaaes.cnf' file.
*/
void parse_cnf(void)
{
	FILE *cnf;
	char lb[210],parms[200],*p;
	short tl,t;
	
	lb[202]='\0';
	
	cnf=fopen("xaaes.cnf","r");
	if (!cnf)
	{
		cnf=fopen("u:\\c\\mint\\xaaes.cnf","r");
		if (!cnf)
		{
			cnf=fopen("u:\\c\\multitos\\xaaes.cnf","r");
			if (!cnf)
			{
				cnf=fopen("u:\\c\\xaaes.cnf","r");
				if (!cnf)
				{
					DIAGS(("WARNING: Couldn't open xaaes.cnf\n"));
					return;
				}
			}
		}
	}

	while(!feof(cnf))
	{
		fgets(lb,199,cnf);
		
		if (lb[0]!='#')							/* '#' is a comment line */
		{
			tl=strlen(lb);
			
			for(t=0; (t<tl)&&(lb[t]!=' '); t++) 
				if ((lb[t]>96)&&(lb[t]<123))	/* Capitalise the command */
					lb[t]-=32;

			for(t++; t<tl; t++)
			{
				if (lb[t]<14)					/* Strip out unwanted carriage returns, etc */
					lb[t]='\0';
			}
			
			if (!strncmp(lb,"RUN ",4))			/* Run command launches a program */
			{
				for(p=lb+4; (*p!=' ')&&(*p!='\0'); p++);
				if (*p)
				{
					*p='\0';
					p++;
				}
				sprintf(parms+1,"%s",p);
				parms[0]=(char)strlen(parms+1);
				
				shell_write(0,0,0,lb+4,parms);
			}
			
			if (!strncmp(lb,"CLIPBOARD ",10))	/* Set the location of the default clipboard */
			{
				sprintf(scrap_path,"%s",lb+10);
			}

			if (!strncmp(lb,"ACCPATH ",8))	/* Set the location of the default clipboard */
			{
				sprintf(acc_path,"%s",lb+8);
			}
			
#if GENERATE_DIAGS
			if (!strncmp(lb,"DEBUG ",6))		/* Redirect console output */
			{
				sprintf(debug_path,"%s",lb+6);
			}
#endif
		}
	}
}

void load_accs(void)
{
	char search_path[200];
	char acc[200];
	short fnd;
	_DTA *my_dta=Fgetdta();
	
	sprintf(search_path,"%s*.ACC",acc_path);

	fnd=Fsfirst(search_path,0xff);
	while(!fnd)
	{
		sprintf(acc,"%s%s",acc_path,my_dta->dta_name);
		shell_write(3,0,0,acc,"");
		fnd=Fsnext();
	}
}

static short auto_program ;

/*
	Cleanup on exit
	- this is pretty iffy at the moment, but it will get you back to a command line.
	  (you cann't re-start XaAES again though :( )
*/
static void Cleanup(void)
{
	XA_CLIENT *client;
	long ex_con;
	
	DIAGS(("Cleaning up ready to exit....\n"));
	Psignal(SIGCHLD, 0L);
	
/* Kill off clients */
	for(client=FirstClient(); client!=NULL; client=NextClient(client))
	{
		if (client->clnt_pipe_rd)
		{
			DIAGS(("Killing:%d:%s:%s\n",Client2Pid(client),client->cmd_name,client->name));
			Pkill(Client2Pid(client),SIGTERM);
		}
	}

	Syield();
	
	for(client=FirstClient(); client!=NULL; client=NextClient(client))
	{
		if (client->clnt_pipe_rd)
		{
			ex_con=Pwaitpid(Client2Pid(client),1,NULL);		/* if client ignored SIGTERM, send SIGKILL */
			if (!ex_con)
			{
				Pkill(Client2Pid(client),SIGKILL);
			}
		}
	}

/* Kill off the mouse server */
	DIAGS(("Killing mouse server\n"));
	Pkill(mouse_pid,SIGTERM);	/* "Please die". This gives the server */
										/* a chance to clean up before exiting; SIGKILL */
										/* can't be caught! */

	/* Wait for mouse server to terminate; this is *essential*! */
	/* It helps prevent two problems: */
	/* - The XaAES kernal might close the physical screen workstation before */
	/*   the mouse server is finished restoring the interrupt vectors. */
	/* - If XaAES.TOS was started from the DESKTOP, GEM AES restores */
	/*   the mouse button and mouse movement vectors afterwards; if this */
	/*   happens *before* the mouse server is finished, this causes */
	/*   problems... (e.g.: button clicks are no longer accepted) */
	Pwaitpid(mouse_pid, 0, NULL);

/* Close screen workstation */
	v_clsvwk(V_handle);
	if ( auto_program )
		v_clswk(P_handle);	/* Auto version must close the physical workstation */

/* Close the AES command pipe (server end) */
	Fclose(AES_in_pipe);
	
/* Unhook from the trap vector */
	unhook_from_vector() ;
	
/* Remove semaphores: */
	Psemaphore(1,APPL_INIT_SEMAPHORE,0);
	Psemaphore(1,TRAP_HANDLER_SEMAPHORE,0);
	Psemaphore(1,WIN_LIST_SEMAPHORE,0);
	Psemaphore(1,ROOT_SEMAPHORE,0);
	Psemaphore(1,CLIENTS_SEMAPHORE,0);
	Psemaphore(1,UPDATE_LOCK,0);
	Psemaphore(1,MOUSE_LOCK,0);
	if ( !auto_program )	/* If we weren't an auto program, call appl_exit() to the standard AES */
		appl_exit() ;
}


/*
	Startup & Initialisation....
	- Spawn off any extra programs we need (mouse server, etc).
	- Open physical & virtual workstations.
	- Install our trap handler.
	- Run the xaaes.cnf startup script.
*/

const XA_WIDGET_LOCATION sys_menu_loc={LT,2,2};

short main(short argc, char *argv[])
{
	short work_in[12];
	short work_out[58];
	char a1[10];
	short f,junk;
	long dummy;
	XA_WIDGET_TREE *menu;
#if DODGY_MEMORY_PROTECTION
	short proc_handle;
	long protection;
#endif

	work_in[0]=1;
	for(f=1;f<10; work_in[f++]=1);
	work_in[10]=2;

/* Check that MiNT is actually installed */
	if(!GetCookie((long)'MiNT',&dummy))
	{
		BootMessage();
		/* Use puts here, as everything is not yet initialised */
		puts("Sorry, XaAES requires MiNT to run.");
		exit(1);
	}

/* Let's get our MiNT process id being's as MiNT is loaded... */
	AESpid=Pgetpid();
	clients[AESpid].cmd_name="XaAES";

/* Change the protection mode to OS_SPECIAL to allow operation with
 * memory protection (doesn't work yet, what's wrong?)
 */
/* Craig's Note: I think this causes a massive memory leak in the MiNT kernal, so
   I've disabled it */
 #if DODGY_MEMORY_PROTECTION
	{
#ifndef F_PROT_S
#define F_PROT_S		0x20
#endif
#ifndef F_OS_SPECIAL
#define F_OS_SPECIAL	0x8000
#endif
		/*	Opening "u:\proc\.-1" opens the current process... */
		if ((dummy = Fopen("u:\\proc\\.-1", O_RDONLY)) >= 0)
		{
			proc_handle = (short)dummy;
			Fcntl(proc_handle, &protection, PGETFLAGS);
			protection &= ~0xf0;
			protection |= F_OS_SPECIAL | F_PROT_S;
			Fcntl(proc_handle, &protection, PSETFLAGS);
			Fclose(proc_handle);
		}
	}
#endif

/* Where were we started? */
	XaAES_home_drv=Dgetdrv();
	Dgetcwd(XaAES_home,XaAES_home_drv+1,sizeof(XaAES_home)-1);

/* Are we an auto/mint.cnf launched program? */
	/* Note: global[0] (AES version number) is initially zero. */
	appl_init();
	auto_program=(global[0]==0);	/* global[0] still zero? */
	
	
	if (auto_program)
	{
		printf("auto program\n");

		if ( (Kbshift(-1)&3) && Getrez()==0 ) 			/* any shift key and low rez */
		{
			Setscreen((void*)-1L,(void*)-1L,1); 		/* switch to medium rez */
		}else{
			printf("argc=%d\n",argc);
			for(f=0; f<argc; f++)
				printf("argv[%d]=%s\n",f,argv[f]);
				
			/* Set video mode from command line parameter ?*/
			if (argc==3)
			{
				printf("got 3 args\n");
				if (!strcmp("-video",argv[1])) 			/* Video mode switch */
				{
					printf("Requested video mode %s\n",argv[2]);
					
					if(GetCookie((long)'_VDO',&dummy))	
					{
						if (dummy>=0x00030000L)			/* Check for falcon video */
						{
							short modecode=falcon_modes[atoi(argv[2])];
							CGVsetScreen(modecode);
						}
					}
					
				}
			}
		}
		v_opnwk(work_in,&P_handle,work_out);			/* If we are an auto program we must open a physical workstation to the screen */

	}else{
		P_handle=graf_handle(&junk,&junk,&junk,&junk);	/* The GEM AES has already been started,  */
														/*  so get the physical workstation handle from it */
	}

/* Setup the kernal OS call jump table */
	setup_k_function_table();

/* Create a whole wodge of semphores for everything from remembering your mothers birthday
   to avoiding an IRA bomb up your arse at work......(yes folks, I work in London and
   don't like getting blown up). */
	Psemaphore(0,APPL_INIT_SEMAPHORE,0);
	Psemaphore(0,TRAP_HANDLER_SEMAPHORE,0);
	Psemaphore(0,WIN_LIST_SEMAPHORE,0);
	Psemaphore(0,ROOT_SEMAPHORE,0);
	Psemaphore(0,CLIENTS_SEMAPHORE,0);
	Psemaphore(0,UPDATE_LOCK,0);
	Psemaphore(0,MOUSE_LOCK,0);

/* Print a text boot message */
	BootMessage();

/* Patch the AES trap vector to use our OS. */
	hook_into_vector();

/* Create the XaAES.cmd introduction pipe */
	AES_in_pipe=Fopen("u:\\pipe\\XaAES.cmd",O_CREAT|O_RDWR);

/* Open the u:/dev/console device to get keyboard input */
	KBD_device=Fopen("u:\\dev\\console",O_RDONLY);
	if (KBD_device<0)
	{
		printf("XaAES ERROR: Can't open /dev/console ?\n");
		Cleanup() ;
		return 1;
	}

/* Initialise the client descriptors */
	for(f=0; f<MAX_PID; f++)
	{
		clients[f].clnt_pipe_rd=clients[f].clnt_pipe_wr=0;
		clients[f].std_resource=NULL;
		clients[f].parent=AESpid;
		clients[f].cmd_tail=(char*)dummy_cmd_tail;
		clients[f].cmd_name=(char*)dummy_cmd_name;
		clients[f].zen=NULL;
		clients[f].desktop=NULL;
	}

/* Open us a virtual workstation for XaAES to play with */
	V_handle=P_handle;
	v_opnvwk(work_in,&V_handle,work_out);
	vswr_mode(V_handle,MD_TRANS);	/* We run in TRANSPARENT mode for all AES ops (unless requested otherwise) */
	vst_alignment(V_handle,0,5,&f,&f);

/*	 Setup the display parameters */
	display.x=display.y=0;
	display.w=work_out[0];
	display.h=work_out[1];
	display.colours=work_out[13];
	display.display_type=D_LOCAL;
	display.P_handle=P_handle;
	display.V_handle=V_handle;

	display.dial_colours=
		(display.colours<16) ?	bw_default_colours : default_colours;
	
	vq_extnd(V_handle,1,work_out);	/* Get extended information */
	display.planes=work_out[4];		/* number of planes in the display */

/* If we are using anything apart from the system font for windows, better check 
   for GDOS and load the fonts. */
	if (STANDARD_AES_FONTID!=1)		
	{
		if (vq_gdos())		/* Yeah, I know, this is assuming the old-style vq_gdos() binding */
			vst_load_fonts(V_handle,0);
	}

/* Set standard AES font */
	display.standard_font_id = display.small_font_id =
		vst_font(V_handle,STANDARD_AES_FONTID);

/* Select Small font */
	display.small_font_point = vst_point(V_handle,
		SMALL_FONT_POINT, &f, &display.small_font_height, &f, &f);
		
/* Select standard font */
 	display.standard_font_point = vst_point(V_handle,
 		(display.h<=280) ? 9 : STANDARD_FONT_POINT,
		&f, &display.standard_font_height,
		&f, &f);

/* Get font information for use by the resource loader */
	vqt_attributes(V_handle, work_out) ;
	display.c_max_w=work_out[8];	/* character cell width */
	display.c_max_h=work_out[9];	/* character cell height */

/* Fix up the window widget bitmaps and any others we might be using
   (calls vr_trnfm() for all the bitmaps) */
	fix_bitmaps();

/* Set the default clipboard */
	strcpy(scrap_path,"c:\\clipbrd\\");
/* Set the default accessory path */
	strcpy(acc_path,"c:\\");

/* Spawn the mouse server */
	MOUSE_in_pipe=(int)Fopen("u:\\pipe\\mouse.XA", O_CREAT|O_RDWR);	/* kernals end of pipe mouse packet pipe */
#if 0
	sprintf(a1,"%d",V_handle);
#else
	sprintf(a1,"%d",P_handle);
#endif
	mouse_pid=Pvfork();
	if (!mouse_pid)
	{				/* In child here */
		execl("mousesrv.tos","mousesrv",a1,NULL);
	}

#if SHOW_LOGO_AT_STARTUP
/* Display the XaAES logo */
	if (!Pvfork())
	{				/* In child here */
		execl("logo.prg","XaAES_LOGO",NULL);
	}
#endif

/* Parse the standard startup file xaaes.cnf
   This can run programs & re-direct the debugging output to another file/device */
#if GENERATE_DIAGS
	strcpy(debug_path,"debug.list");	/* By default debugging output goes to the file "./debug.list"*/
#endif
	parse_cnf();

#if GENERATE_DIAGS
/* Open a diagnostics file? All console output can be considered diagnostics, so
   I just redirect the console to the required file/device */
	debug_file=(int)Fopen(debug_path,O_CREAT|O_WRONLY);
	Fforce(1,debug_file);

	DIAGS(("\n\n\nDebug to %s\n",debug_path));
#endif

	DIAGS(("Display Device: P_handle=%d, V_handle=%d\n",P_handle,V_handle));
	DIAGS((" size=[%d,%d], colours=%d, bitplanes=%d\n",display.w,display.h,display.colours,display.planes));

/* Load the system resource file (we can probably embed this later) */
	system_resources=LoadResources("system.rsc",DU_RSX_CONV, DU_RSY_CONV);
	if (system_resources)
	{
		DIAGS(("system_resources=%lx\n",system_resources));
	}else{
		puts("ERROR: Cann't find/load system resource file 'system.rsc'\n");
		Cleanup();
		return -1;
	}
	
/* Create the root (desktop) window 
	- we don't want messages from it, so make it a NO_MESSAGES window */
	root_window=create_window(AESpid, NO_MESSAGES, 0, 0, display.w, display.h);
	root_window->handle=0;
	root_window->is_open=TRUE;				/* Flag window as open	*/

/* Tack a menu onto the root widget */
	clients[AESpid].std_menu=ResourceTree(system_resources,SYSTEM_MENU);
	fix_menu(clients[AESpid].std_menu);
	set_menu_widget(root_window, sys_menu_loc, clients[AESpid].std_menu);
	menu=(XA_WIDGET_TREE*)(root_window->widgets[XAW_MENU].stuff);
	menu->owner=AESpid;

/* Set a default desktop */
	set_desktop(ResourceTree(system_resources,DEF_DESKTOP));
	(desktop+DESKTOP_LOGO)->ob_x=(root_window->ww-(desktop+DESKTOP_LOGO)->ob_width)/2;
	(desktop+DESKTOP_LOGO)->ob_y=(root_window->wh-(desktop+DESKTOP_LOGO)->ob_height)/2;
	clients[AESpid].desktop=desktop;

/* Display the root window */
	v_hide_c(V_handle);
	display_non_topped_window(root_window,NULL);

/* Initial iconified window coords */
	iconify_w=ICONIFIED_W; iconify_h=ICONIFIED_H;
	iconify_x=0;
	iconify_y=display.y+display.h-iconify_h-1;

/* Turn on the mouse cursor */
	v_show_c(V_handle,0);

/* Set our process priority - a high negative value here improves performance a lot, 
   so I set it to -20 in XA_DEFS.H. This doesn't hurt the rest of the systems performance,
   as there are no busy wait loops in the server, and it spends most of it's time blocked
   waiting for commands. */

	Pnice(AES_PRIORITY);

/* Catch SIGCHLD to spot dead children */
	Psignal(SIGCHLD, (long)HandleSIGCHLD);

/* Load Accessories */
	load_accs();
	
/* Catch SIGINT and SIGQUIT so we can shutdown with CTRL+ALT+C */
	Psignal(SIGINT, (long)HandleSIGINT);
	Psignal(SIGQUIT, (long)HandleSIGINT);

/* Call the main command interpreter kernal */
	kernal();

/* Closedown & exit */
	Cleanup() ;

	return 0;
}
