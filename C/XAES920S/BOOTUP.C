/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

#include <osbind.h>
#include <falcon.h>
#include <mintbind.h>
#include <fcntl.h>
#include <ioctl.h>
#include <signal.h>
#include <stdlib.h>
#include <string.h>
#include "ctype.h"			/* We use the version without macros!! */

#include "xa_types.h"
#include "xa_globl.h"
#include "xa_nkcc.h"		/* Harald Siehmunds NKCC with XaAES reductions. */

#include "handler.h"
#include "c_window.h"
#include RSCHNAME
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
#include "new_clnt.h"
#include "ipff.h"

/*
 * Boot up code
 */

/* HR: the word global should really be kept reserved for (future?)
       use as the opposite of auto, local or static. */
/* aes.h conflicts with xa_aes.h, so we can't use it here... :-( */

#if defined(LATTICE)				/* ----- Lattice C ----- */
	extern GLOBAL _AESglobal;
	#define globl _AESglobal
	int __regargs _AESif(unsigned int);
	#define appl_init() _AESif(0x0a000100)
	int graf_handle(short *,short *,short *,short *);
	#define appl_exit()	_AESif(0x13000100)

#elif defined(__PUREC__)			/* ----- Pure C 1.1 ----- */

	typedef struct
	{
		int		contrl[15];
		GLOBAL	globl;
		int		intin[132];
		int		intout[140];
		void	*addrin[16];
		void	*addrout[16];
	} GEMPARBLK;
	extern  GEMPARBLK _GemParBlk;
	#define globl _GemParBlk.globl
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

/* config data local to bootup. */
static struct lconfig
{
	Path widg_name,
	     rsc_name;
	unsigned
		  long mint,
		  falcon;		  /* cookies & cookie values */
	short modecode,
	      double_click_time,		/* Double click timing */
		  direct_call;        /* Flag for enabling of direct call */
	bool  havemode;
}
lcfg = {WIDGNAME,RSCNAME,0,0,0,DOUBLE_CLICK_TIME,false};

static
char version[] = ASCII_VERSION;

static
void *widget_resources;			/* HR: Pointer to the widget resource (icons) */

static
short envs = 0;					/* HR: current no of env strings. */

static
const XA_COLOUR_SCHEME
	default_colours = {LWHITE, BLACK, LBLACK, WHITE, BLACK, CYAN},
 	bw_default_colours = {WHITE, BLACK, BLACK, WHITE, BLACK, WHITE};		/* HR: more white */

static
MOOSE_VECS_COM vecs_com =		/* HR: Gets the VDI vector routine addresses from the moose. */
{
	MOOSE_VECS_PREFIX,nil,nil,nil
};

static
vdi_vec *svmotv = nil,
		*svbutv = nil,
		*svtimv = nil;

/* HR: find a xaaes file. When the cd command to XaAES load directory is
       missing in mint.cnf (which is likely for inexperienced mint users. ;-) 
       XaAES wont fail completely.
*/
static
char *dirs[] =
{
	"",					/* plain name only */
	C.home,				/* path (no drive!!) Dont forget to fill. */
	"c:" sbslash "mint" sbslash,
	"c:" sbslash "mint" sbslash "xaaes" sbslash,
	"c:" sbslash "multitos" sbslash,
	"c:" sbslash "multitos" sbslash "xaaes" sbslash,
	"c:" sbslash "gemsys" sbslash,
	"c:" sbslash "gemsys" sbslash "xaaes" sbslash,
	"c:" sbslash,
	"c:" sbslash "xaaes" sbslash,
	nil
},
	**aes_path;

/* HR */
static char moose_name[] = "u:" sbslash "dev" sbslash "moose",
            mouse_name[] = "u:" sbslash "dev" sbslash "mouse";

short
hex_version(void)
{	return HEX_VERSION; }

static
long protection_flags = 0;

static
void bootmessage(unsigned long mint)
{
	if (mint)
	{
		display("It's FreeMiNT v%ld.%ld.%ld%c%c  (%lx)\n",
				 mint>>24,
				(mint>>16)&255,
				(mint>> 8)&255,
				(mint&255) ? ' .' : '  ',
				(mint&255) ? (short)mint&255 : (short)'  ',
				mint
				);
		display(" and ");
	}
	display("XaAES %s\n", version);
	display("MultiTasking AES for MiNT\n");
	display("(w)1995,96,97,98,99 Craig Graham, Johan Klockars, Martin Koehling, Thomas Binder\n");
	display("     and other assorted dodgy characters from around the world...\n");
	display("   Using Harald Siegmunds NKCC\n");
	display("   1999-2001 Henk Robbers @ Amsterdam\n");
	display("Date: %s, time: %s\n", __DATE__,__TIME__);
	display("Compile time switches enabled:\n");

	IFDIAG(display(" - Diagnostics\n");)
		
#if DISPLAY_LOGO_IN_TITLE_BAR
	display(" - Logo in title bar\n");
#endif

#if POINT_TO_TYPE
	display(" - Point-to-type capability\n");
#endif

#if ALT_CTRL_APP_OPS
	display(" - CTRL+ALT key-combo's\n");
#endif

#if USE_CALL_DIRECT
	display(" - Use direct-call\n");
#endif

#if MEMORY_PROTECTION
	display(" - OS_SPECIAL memory access\n");
	display(" -     protection_flags: 0x%lx\n",protection_flags);
#endif

#if VECTOR_VALIDATION
	if (C.mvalidate)
		display(" - Client vector validation\n");
#endif

	display(" - Realtime (live) window scrolling\n");

#if PRESERVE_DIALOG_BGD
	display(" - Preserve dialog backgrounds\n");
#endif

#if ! FILESELECTOR
	display(" - Built without file selector\n");
#endif
#if ! TEAR_OFF
	display(" - Menu's can *not* be teared off\n");
#endif

	display(" - Static Pid Array\n");

	if (cfg.superprogdef)
		display("progdefs are executed in supervisor mode\n");
	if (cfg.fsel_cookie)
		display(" - FSEL cookie found\n");
	if (lcfg.falcon == 0x0030000L)
		display(" - Falcon video handled\n");
	if (cfg.auto_program)
	{
		if (lcfg.havemode)
			display(" - video mode %d(x%x)\n",lcfg.modecode,lcfg.modecode);
		display("auto program\n");
	}
}

/* HR: last resort if shell_find fails. */
static
char *xa_find(char *fn)
{
	long fl;
	static char p[200];

	DIAG((D.shel,-1,"xa_find for %s '%s'\n", C.Aes->name, fn ? fn : "~"));

	aes_path = dirs;
	while (*aes_path)
	{
		char *pad = *aes_path;
		sdisplay(p,"%s%s", pad, fn);
		fl = Fopen(p,0);
		if (fl > 0)
		{
			Fclose(fl);
			if (isalpha(*pad) and *(pad + 1) == ':')
				strcpy(C.home, pad);		/* whole new path */
			return p;
		}
		aes_path++;
	};

DIAG((D.shel,-1," - nil\n"));
	return nil;
}

/*
 * Read & parse the 'xaaes.cnf' file.
 */
#if GENERATE_DIAGS
static
void debugp(debug_item *d)
{
	d->point = 1;
	if (sk() == '/')
	{
		skc();
		d->pid = idec();
	}
	else
		d->pid = 0;
}
#endif

static
char *config = nil;
static
bool have_run = false;

static
void before_run(void)
{
	long ct = 0;

	if (!have_run)
	{
		have_run = true;
	
		/* Count the number of bytes needed for the new environment,
		   that is: without any ARGV string. */
		ct = count_env(C.strings, nil);

		/* Allocate the new environment */
		C.env = xmalloc(ct, 1);

		/* Copy all the strings to the new environment, without any ARGV string. */
		if (C.env)
			copy_env(C.env, C.strings, nil, nil);

		IFDIAG (display("Copy of envireonment\n");
		        display_env(C.strings,1);)
	}
}

static
void parse_cnf(void)
{
	extern bool naes12;
	char *cnf; short fh, t;
	char *translation_table, *lb, parms[200], *p, *name = CNFNAME;
	long tl, err = 0; int lnr = 0;

	p = shell_find(NOLOCKING, C.Aes, name);
	if (!p)
		p = xa_find(name);
	if (p)
		cnf = Fload(p,&fh,&tl);
	if (cnf eq nil)
		return;
	config = cnf;
	ipff_init(IPPF_L-1,127,0,nil,cnf,&translation_table);	/* initialize */

	/* translate everything to lower case */
	for (t = 'A'; t <= 'Z'; t++)
		translation_table[t] = t - 'A' + 'a';

/*	HR:
	 It is not obligatory to do line based parsing;
	ipff_line zeroizes \r & \n,
	\r & \n are otherwise treated as white space,
	alternative:
		replace lb by cnf,
		dont use ipff_line and loop around anyway you like.
		pe: while(is_keyword(rstr))	or something like that.
		Comment must be enclosed then I suppose. :-)
*/

	while((lb = ipff_line(&tl)) ne nil)
	{
		char rstr[IPPF_L];

		lnr++;

		if (tl eq 0)
			continue;

		if (lb[0] != '#')	/* '#' is a comment line */
		{
			if (sk() eq '#')	/* skip white space, return nonwhite character */
				continue;

			ipff_trail(lb);	/* remove trailing spaces */

			IFDIAG (display("%s\n", ipff_getp());)

			str(rstr);		/* get a word */
			sk();			/* skip white space */

			if (*rstr == 0)
				err = display("line %d: a line must start with a alphanumeric keyword\n", lnr);
			elif( strcmp(rstr,"priority") eq 0)
			{
				short prio = idec();
				if (prio >= -20 and prio <= 20)
					Psetpriority(0, C.AESpid, prio);
			}
#if NAES12
			elif (strcmp(rstr,"naes12") eq 0)
				naes12 = true;
#endif
#if NAES3D
			elif (strcmp(rstr,"naes3d") eq 0)		/* HR 040801 */
				cfg.naes = true;
#endif
			elif (strcmp(rstr,"widgets") eq 0)
				fstr(lcfg.widg_name,0);
			elif (strcmp(rstr,"resource") eq 0)
				fstr(lcfg.rsc_name,0);
			elif (strcmp(rstr,"run") eq 0)
			{
				short run;
				char p[210];

				before_run();
				fstr(p,0);
				sk();
				parms[0] = sdisplay(parms+1,"%s",ipff_getp());
				launch(NOLOCKING, 0, 0, 0, p, parms, C.Aes);
			}
			elif (strcmp(rstr,"shell") eq 0 or strcmp(rstr,"desk") eq 0)
			{
				char p[210];

				before_run();
				fstr(p,0);
				sk();
				parms[0] = sdisplay(parms+1,"%s",ipff_getp());
				C.DSKpid = launch(NOLOCKING, 0, 0, 0, p, parms, C.Aes);
			}
			elif (strcmp(rstr,"launcher") eq 0)
				fstr(cfg.launch_path,0);
			elif (strcmp(rstr,"clipboard") eq 0)
				fstr(cfg.scrap_path,0);
			elif (strcmp(rstr,"accpath") eq 0)
				fstr(cfg.acc_path,0);
			elif (strcmp(rstr,"dc_time") eq 0)
				lcfg.double_click_time = idec();
			elif (   strcmp(rstr,"windowner") eq 0
			      or strcmp(rstr,"winowner" ) eq 0 
			     )
			{
				str(rstr);
				if (strcmp(rstr,"true") == 0 or strcmp(rstr,"short") == 0)
					cfg.windowner = 1;
				elif (strcmp(rstr,"long") == 0)
					cfg.windowner = 2;
				/* defailt is zero anyway. */
			}
#if GENERATE_DIAGS
			elif (strcmp(rstr,"debug_lines") eq 0)
				D.debug_lines = idec();
			elif (strcmp(rstr,"debug") eq 0)
			{
				if (isdigit(sk()))
					D.all.point = idec();
				else
				{
					char *p = ipff_getp();
					str(rstr);
					if (strcmp(rstr,"off") eq 0)
						D.all.point = 0;
					elif (strcmp(rstr,"on") eq 0)
						D.all.point = 1;		/* This means only the DIAGS macro's (the old ones) */
					elif (strcmp(rstr,"all") eq 0)
					{
						debugp(&D.all);
						D.all.point = 3;
					}
					elif (!D.debug_file)
					{
						ipff_putp(p);
						fstr(D.debug_path,0);
						if (strnicmp(D.debug_path, "screen", 6) != 0)
						{
							display("\n\n\nDebug to %s\n", D.debug_path);
					
						#if 1		/* HR: Want to see session date / time */
							D.debug_file = (int)Fcreate(D.debug_path, 0);
						#else
							D.debug_file = (int)Fopen(D.debug_path, O_CREAT|O_WRONLY);
						#endif
							Fforce(1, D.debug_file);
						}
					}
				}
			}
			/* If specified together with debug all, the meaning is reversed. */
			elif (   strcmp(rstr,"debugpoint") eq 0
			      or strcmp(rstr,"except"    ) eq 0  /* only for readability together with 'all' */
			     )
			{
				if (!D.all.point) D.all.point = 2;
				do{
					str(rstr);
					if (strlen(rstr) eq 1 and isalpha(*rstr))
						debugp(((debug_item *)&D.a+(tolower(*rstr)-'a')));
					elif (strncmp(rstr,"appl", 4) eq 0 ) debugp(&D.appl );
					elif (strcmp(rstr,"evnt"    ) eq 0 ) debugp(&D.evnt );
					elif (strncmp(rstr,"mult", 4) eq 0 ) debugp(&D.multi);
					elif (strncmp(rstr,"form", 4) eq 0 ) debugp(&D.form );
					elif (strncmp(rstr,"fsel", 4) eq 0 ) debugp(&D.fsel );
					elif (strncmp(rstr,"graf", 4) eq 0 ) debugp(&D.graf );
					elif (strncmp(rstr,"menu", 4) eq 0 ) debugp(&D.menu );
					elif (strcmp(rstr,"objc"    ) eq 0 ) debugp(&D.objc );
					elif (strcmp(rstr,"rsrc"    ) eq 0 ) debugp(&D.rsrc );
					elif (strcmp(rstr,"scrp"    ) eq 0 ) debugp(&D.scrp );
					elif (strncmp(rstr,"shel", 4) eq 0 ) debugp(&D.shel );
					elif (strncmp(rstr,"wind", 4) eq 0 ) debugp(&D.wind );
					elif (strncmp(rstr,"widg", 4) eq 0 ) debugp(&D.widg );
					elif (strncmp(rstr,"mous", 4) eq 0 ) debugp(&D.mouse);
					elif (strncmp(rstr,"keyb", 4) eq 0 ) debugp(&D.keybd);
					elif (strncmp(rstr,"sema", 4) eq 0 ) debugp(&D.sema );
					elif (strncmp(rstr,"rect", 4) eq 0 ) debugp(&D.rect );
					elif (strncmp(rstr,"pipe", 4) eq 0 ) debugp(&D.pipe );
					elif (strncmp(rstr,"trap", 4) eq 0 ) debugp(&D.trap );
					elif (strncmp(rstr,"kern", 4) eq 0 ) debugp(&D.kern );
					if (sk() eq ',') skc();
					else break;
				}od
			}
#else
			elif (   strcmp(rstr,"debug") eq 0
			      or strcmp(rstr,"debugpoint") eq 0
			      or strcmp(rstr,"except"    ) eq 0
			      or strcmp(rstr,"debug_lines") eq 0
			      )
				;		/* Do nothing with this line */
#endif
#if USE_CALL_DIRECT
			elif (strcmp(rstr,"direct") eq 0)
			{
				str(rstr);
				if (strcmp(rstr,"on") eq 0)
				{
					short c;
					cfg.direct_call = 1;
					if (isdigit(c=sk()))
						cfg.direct_call = c - '0';
				}
				else
					cfg.direct_call = 0;
			}
#endif
			elif (strncmp(rstr,"half_scr",8) == 0)
				cfg.half_screen_max = dec();
			elif (strcmp(rstr,"font_id") eq 0)
				cfg.font_id = idec();
			elif (strcmp(rstr,"standard_point") eq 0)
				cfg.standard_font_point = idec();
			elif (strcmp(rstr,"medium_point") eq 0)
				cfg.medium_font_point = idec();
			elif (strcmp(rstr,"small_point") eq 0)
				cfg.small_font_point = idec();
			elif (strcmp(rstr,"menu") eq 0)
#if POPUP_IN_WINDOW
			do
#endif
			{
				str(rstr);
				if (strcmp(rstr,"pull") eq 0)
					cfg.menu_behave = PULL;
				elif (strcmp(rstr,"push") eq 0)
					cfg.menu_behave = PUSH;
				elif (strcmp(rstr,"leave") eq 0)
					cfg.menu_behave = LEAVE;
#if POPUP_IN_WINDOW
				elif (strcmp(rstr, "windowed") eq 0)
					cfg.menu_windowed = true;
				if (sk() ne ',')
					break;
				else
					skc();
#endif
			}
#if POPUP_IN_WINDOW
			od
#endif
			elif (strcmp(rstr,"cancel") eq 0)
			{
				t = 0;
				do{
					str(rstr);
					if (strlen(rstr) >= NUM_CB)
						rstr[CB_L - 1] = 0;
					strcpy(cfg.cancel_buttons[t++],rstr);
					if (sk() eq ',' and t < NUM_CB - 1) skc();	/* last entry kept clear as a stopper */
					else break;
				}od
			}
			elif (strcmp(rstr,"toppage") eq 0)
			{
				str(rstr);
				if (strcmp(rstr,"bold") eq 0)
					cfg.topname = BOLD, cfg.backname = 0;
				elif (strcmp(rstr,"faint") eq 0)
					cfg.topname = 0,    cfg.backname = FAINT;
			}
			elif (strcmp(rstr,"superprogdef") eq 0)
				cfg.superprogdef = true;
			elif (   strcmp(rstr,"string") eq 0
			      or strncmp(rstr,"int",3) eq 0		/* integer, integral */
			      or strcmp(rstr,"export") eq 0
			      or strcmp(rstr,"setenv") eq 0
			      )
			{
				if (have_run)
					err = display("environment variable after any run or desk is discarded\n");
				else
				{
					char ide[IPPF_L];
					char *start = ipff_getp();
					str(ide);
					if (*ide)
					{
						char p[512];
						strupr(ide);
						strcpy(p,ide);
						strcat(p,"=");
						if (sk() == '=')
							skc();
						if (*rstr eq 'i')
							sdisplay(p + strlen(p), "%ld", dec());
						else
							fstr(p + strlen(p),0);
						strcpy(start,p);
						C.strings[envs++] = start;
					}
				}
			}
			elif (strcmp(rstr,"mintmouse") eq 0)
				cfg.mintmouse = true;
#if POINT_TO_TYPE
			elif (strcmp(rstr,"focus") eq 0)
			{
				str(rstr);
				cfg.point_to_type = strcmp(rstr,"point") eq 0;
			}
#endif
#if FILESELECTOR and defined(FSEL_MENU)
			elif (strcmp(rstr,"filters") eq 0)
			{
				short i = 0;
				while (i < 23)
				{
					short s = lstr(rstr,',|/\\');	/* get delimited string */
					rstr[15] = 0;
					strcpy(cfg.Filters[i++],rstr);
					if (s ne ',' and s ne '/' and s ne '|' and s ne '\\')
						break;
					skc();					/* skip delimiter */
				}
				while (i < 23)
					cfg.Filters[i++][0] = 0;
			}
#endif
			else
				err = display("line %d: unimplemented keyword '%s'\n", lnr, rstr);
		}
	}

	before_run();		/* HR: 051200 If no run/exec/desk at all, the env wasnt copied. */
	C.strings[envs] = nil;

	if (err 
		IFDIAG (and !D.debug_file)
		)
	{
		display("hit any key\n");
		bios(2,2);
	}

/*	free(cnf);			postponed to after copy env. :-) */
}

static
void load_accs(void)
{
	char search_path[200];
	char acc[200];
	short fnd;
	_DTA *my_dta = Fgetdta();
	
	sdisplay(search_path,"%s*.ACC", cfg.acc_path);

	fnd = Fsfirst(search_path, 0xff);
	while(!fnd)
	{
		sdisplay(acc, "%s%s", cfg.acc_path, my_dta->dta_name);
		launch(NOLOCKING, 3, 0, 0, acc, "", C.Aes);
		fnd = Fsnext();
	}
}

/*
 * Cleanup on exit
 */
static
void cleanup(void)
{
	XA_CLIENT *client;
	XA_WINDOW *w;
	long ex_con;
	
	DIAG((D.appl,-1,"Cleaning up ready to exit....\n"));

	if (svmotv)
	{
		vdi_vec *m,*b,*t;
		vex_motv(C.P_handle, svmotv, &m);
		vex_butv(C.P_handle, svbutv, &b);
/*		vex_timv(C.P_handle, svtimv, &t, 50);
*/	}

	Psignal(SIGCHLD, 0L);
	
	DIAG((D.appl,-1,"Cleaning up clients\n"));
	client = S.client_list;		/* HR */
	while(client)
	{
		XA_CLIENT *next = client->next;
		DIAGS((" - %d,%d\n", client->pid, client->client_end));
		if (is_client(client))
		{
			DIAG((D.appl,-1,"Cleaning %s(%d)\n", client->name, client->pid));
			remove_refs(client, true);						/* HR 100701 */
			XA_client_exit(NOLOCKS, client, nil);		/* HR 230501  */
		}
		client = next;
	}

	Syield();

	DIAG((D.appl,-1,"Removing clients\n"));

	client = S.client_list;		/* HR */
	while(client)
	{
		XA_CLIENT *next = client->next;
		DIAGS((" - %d,%d  %d\n", client->pid, client->client_end, client->killed));
		if (client->pid == C.AESpid)
		{
			clear_clip();
			root_window->redraw(0, root_window);
		}
		else if (client->killed)
		{
			DIAG((D.appl,-1,"Removing %s(%d)\n", client->name, client->pid));
			Syield();
			close_client(NOLOCKS, client);
			Pkill(client->pid, SIGKILL);
		}
		client = next;
	}

#if 0
	DIAG((D.appl,-1,"Killing clients\n"));

	client = S.client_list;	/* HR */
	while(client)
	{
		XA_CLIENT *next = client->next;
		DIAGS((" - %d,%d\n", client->pid, client->client_end));
		if (is_client(client))
		{
			ex_con = Pwaitpid(client->pid, 1, NULL);		/* If client ignored SIGTERM, send SIGKILL */
			if (ex_con == 0)
			{
				DIAG((D.appl,-1,"Killing %s(%d)\n", client->name, client->pid));
				Syield();
				Pkill(client->pid, SIGKILL);
			}
		}
		client = next;
	}
#endif

	Syield();

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

	/* HR: */
#if HALFSCREEN
	if (cfg.half_screen_buffer)
		Mfree(cfg.half_screen_buffer);
#endif

	DIAGS(("Freeing Aes environment\n"));
	if (C.env)
		free(C.env);
	DIAGS(("Freeing config\n"));
	if (config)
		free(config);

	DIAGS(("Freeing Aes resources\n"));
	/* To demonstrate the working on multiple resources. */
	FreeResources(C.Aes);		/* first:  widgets */
	FreeResources(C.Aes);		/* then:   big resource */

#if GENERATE_DIAGS

	DIAGS(("Reporting memory leaks\n"));
	{
		XA_report punit;
		XA_leaked(nil, -1, -1, punit);

	}

#endif

	DIAGS(("Freeing what's left\n"));
	_FreeAll();		/* Free (default) global base */

	unhook_from_vector() ;

	if (C.MOUSE_dev > 0)
		Fclose(C.MOUSE_dev);

	nkc_exit();
	if (C.KBD_dev > 0)
		Fclose(C.KBD_dev);			/* HR: MOUSE_dev --> C.KBD_dev */

	if (C.AES_in_pipe > 0)
		Fclose(C.AES_in_pipe);

	if (C.Salert_pipe > 0)
		Fclose(C.Salert_pipe);

	/* Close the debug output file */

	IFDIAG (if (D.debug_file > 0)
		       Fclose(D.debug_file);)

	/* Close screen workstation */

DIAGS(("Closing video workstation\n"));
	v_clsvwk(C.vh);
	if (cfg.auto_program)
		v_clswk(C.P_handle);				/* Auto version must close the physical workstation */

	/* Remove semaphores: */
DIAGS(("Deleting semaphores\n"));
	Psemaphore(1, APPL_INIT_SEMA, 0);
/*	Psemaphore(1, TRAP_HANDLER_SEMA, 0);
*/	Psemaphore(1, WIN_LIST_SEMA, 0);
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

	if (!cfg.auto_program)					/* If we weren't an auto program, call appl_exit() to the standard AES */
		appl_exit() ;
}

/*
 * (Re)initialise the mouse device /dev/moose
 */
static
short init_moose(void)
{
	MOOSE_INIT_COM i_com;
	MOOSE_DCLICK_COM dc_com;

	cfg.mouse_name = cfg.mintmouse ? mouse_name : moose_name;

	if (!C.MOUSE_dev)
	{
		C.MOUSE_dev = Fopen(cfg.mouse_name, O_RDWR);
		if (C.MOUSE_dev < 0)
		{
			display("Can't open %s\n", cfg.mouse_name);
			return false;
		}
	}

	if ( ! cfg.mintmouse)
	{
		i_com.init_prefix = MOOSE_INIT_PREFIX;			/* Load the command prefix into the command */
		i_com.dum = nil;			/* HR: 19 october 2000; switched over to VMOOSE, the vdi vector using moose. */
	
		if (Fwrite(C.MOUSE_dev, 6L, &i_com) == 0)
			display("Moose init failed\n");
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
				display("Moose set dclick time failed\n");
		}
	
		if (vecs_com.motv)			/* HR */
		{
			vex_motv(C.P_handle, vecs_com.motv, &svmotv);
			vex_butv(C.P_handle, vecs_com.butv, &svbutv);
		}
	}
	return true;
}

global
void reopen_moose(void)
{									
	MOOSE_DCLICK_COM dc_com;
	C.MOUSE_dev = Fopen(cfg.mouse_name, O_RDWR);
	dc_com.dclick_prefix = MOOSE_DCLICK_PREFIX;
	dc_com.dclick_time = 50;
	/*	dc_com.dclick_time = lcfg.double_click_time;*/
	if (Fwrite(C.MOUSE_dev, 4L, &dc_com) == 0)
	{
		DIAG((D.mouse,-1,"moose set dclick time failed\n"));
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
short main(short argc, char *argv[],char *env[])
{
	short work_in[12];
	short work_out[58];
	short f;
	char *resource_name;

	memset(&cfg,0,sizeof(cfg));
	memset(&S,0,sizeof(S));
	memset(&C,0,sizeof(C));
	C.cmd_name = "u:" sbslash "pipe" sbslash "XaAES.cmd";

	cfg.font_id = STANDARD_AES_FONTID;			/* Font id to use */
	cfg.standard_font_point = STANDARD_FONT_POINT;	/* Size for normal text */
	cfg.medium_font_point = MEDIUM_FONT_POINT;		/* The same, but for low resolution screens */
	cfg.small_font_point = SMALL_FONT_POINT;		/* Size for small text */
	cfg.backname = FAINT;
	cfg.ted_filler = '_';
	cfg.half_screen_max = 64000;

	IFDIAG (memset(&D,0,sizeof(D));)

#if ! FILESELECTOR
	cfg.no_xa_fsel = true;
#endif

	IFDIAG(strtclk = clock();)

	{
		char **p = env;
		while (*p and p - env < STRINGS)
			C.strings[envs++] = *p++;
	}

#if DRAW_TEST
	C.AESpid = 1;
#else
	/* Check that MiNT is actually installed */
	/* Tried to use mintlibs Getcookie, but failed */
	if (Ssystem(-1, 0, 0) != 0)
	{
		bootmessage(0);
		display("Sorry, XaAES requires MiNT >= 1.15.0 to run.");
		IFDIAG (display(">");bios(2,2);)
		exit(1);
	}

	/* Let's get our MiNT process id being as MiNT is loaded... */
	C.AESpid = Pgetpid();

	Pnice(-1);
	Pdomain(1);			/* HR The kernel runs in the MiNT domain. */

	argv[0] = get_procname(C.AESpid);		/* HR: 211200 */

/* Ulrichs advice */
	sdisplay(cfg.scrap_path, "u:" sbslash "proc" sbslash "%s.%d", argv[0], C.AESpid);
	sdisplay(cfg.acc_path,   "u:" sbslash "proc" sbslash "AESSYS.%d",      C.AESpid);
	display("rename: '%s' to '%s'\n", cfg.scrap_path, cfg.acc_path);

	Frename(0, cfg.scrap_path, cfg.acc_path);

									 /* 'FSEL' */
	cfg.fsel_cookie = Ssystem(S_GETCOOKIE, 0x4653454cL, 0) != 0xffffffff;
#endif

	/* HR: dynamic window handle allocation. */
	clear_wind_handles();

	/* Initialise the object tree display routines */
	init_objects();		/* HR: before parse_cnf() */

	C.Aes = NewClient(C.AESpid);		/* So we can speak to and about ourself. */

	C.Aes->cmd_name = "XaAES";
	C.Aes->parent = Pgetppid();
	strcpy(C.Aes->name, "  XaAES System");
/*	strcpy(C.Aes->proc_name,"AES");     Left out, because a null name must be harmless!
*/

#if !DRAW_TEST
	/* Change the protection mode to OS_SPECIAL to allow operation with
	 * memory protection (doesn't work yet, what's wrong?)
	 */
	/* Craig's Note: I think this causes a massive memory leak in the MiNT kernal, so
	 * I've disabled it
	 */
#if MEMORY_PROTECTION
	{
		short proc_handle;
		long protection;
	#ifndef F_PROT_S
		#define F_PROT_S	0x20
	#endif
	#ifndef F_OS_SPECIAL
		#define F_OS_SPECIAL	0x8000
	#endif
		/*	Opening "u:\proc\.-1" opens the current process... */
		
		if ((proc_handle = Fopen("u:" sbslash "proc" sbslash ".-1", O_RDONLY)) >= 0)
		{
        	/* get process memory flags */
			Fcntl(proc_handle, &protection, PGETFLAGS);
 			protection_flags = protection;
   		/* delete protection mode bits */
			protection &= 0xffffff0fUL;
 			/* super access, OS special */
			protection |= F_OS_SPECIAL | F_PROT_S;
			/* set process memory flags */
			Fcntl(proc_handle, &protection, PSETFLAGS);
			Fclose(proc_handle);
		}
	}
#endif

#endif

	/* Where were we started? */
	
	C.home_drv = Dgetdrv();
	Dgetcwd(C.home, C.home_drv + 1, sizeof(C.home) - 1);

	/* Are we an auto/mint.cnf launched program? */

	/* Note: globl[0] (AES version number) is initially zero. */
	
	globl.version = 0;		/* HR: Make sure :-)  150501: use structs!!! */
	appl_init();
	cfg.auto_program = (globl.version == 0);	/* globl[0] still zero? */

	for (f = 0; f < 10; f++)				/* HR start at 0 */
		work_in[f] = 1;
	work_in[10] = 2;
	
	if (cfg.auto_program)
	{
		if ((Kbshift(-1) & 3) and (Getrez() == 0))	/* Any shift key and low rez */
			Setscreen((void*)-1L, (void*)-1L, 1, 0);	/* Switch to medium rez */
		else
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
					Ssystem(S_GETCOOKIE, 0x5f56444fL, &lcfg.falcon);

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
					}

				} else
					if (stricmp("-video", argv[1]) == 0) 	/* Video mode switch */
						work_in[0] = lcfg.modecode;
					else
						work_in[0] = Getrez() + 2;
			}

			IFDIAG (display(">");bios(2,2);)	/* Before screen is cleared :-) */
			v_opnwk(work_in, &C.P_handle, work_out);

			display("\033HPhysical work station opened: %d\n",C.P_handle);
		}
	} else
	{
		short junk;
		C.P_handle = graf_handle(&junk, &junk, &junk, &junk);	/* The GEM AES has already been started,  */
									/*  so get the physical workstation handle from it */
	}

	/* Setup the kernel OS call jump table */
	
	setup_k_function_table();


	/* Create a whole wodge of semphores for everything from remembering your mother's birthday
	 * to avoiding an IRA bomb up your arse at work...
	 * (Yes folks, I work in London and don't like getting blown up).
	 */

#if !DRAW_TEST
	Psemaphore(0, APPL_INIT_SEMA, 0);
/*	Psemaphore(0, TRAP_HANDLER_SEMA, 0); */
	Psemaphore(0, WIN_LIST_SEMA, 0);
	Psemaphore(0, ROOT_SEMA, 0);
	Psemaphore(0, CLIENTS_SEMA, 0);
	Psemaphore(0, UPDATE_LOCK, 0);
	Psemaphore(0, MOUSE_LOCK, 0);
	Psemaphore(0, FSELECT_SEMA, 0);

	Psemaphore(0, ENV_SEMA, 0);			/* HR */
	Psemaphore(0, PENDING_SEMA, 0);


	/* Print a text boot message */

	lcfg.mint = Ssystem(S_OSVERSION,0,0);

#if MEMORY_PROTECTION
	if (lcfg.mint >= 0x10f0b00)				/* HR 100701  mint >= 1.15.11 */
		C.mvalidate = true;
#endif

	bootmessage(lcfg.mint);


	/* Patch the AES trap vector to use our OS. */
	hook_into_vector();

	/* Open the MiNT Salert() pipe to be polite about system errors */
	C.Salert_pipe = Fopen("u:" sbslash "pipe" sbslash "alert", O_CREAT|O_RDWR);

	/* Create the XaAES.cmd introduction pipe */
	
	C.AES_in_pipe = Fopen(C.cmd_name, O_CREAT|O_RDWR);
	display("Open '%s' to %ld\n", C.cmd_name, C.AES_in_pipe);
	if (C.AES_in_pipe < 0)
	{
		display("XaAES ERROR: Can't open %s ?\n", C.AES_in_pipe);
		cleanup() ;
		return -1;
	}

	/* Open the u:/dev/console device to get keyboard input */

	C.KBD_dev = Fopen("u:" sbslash "dev" sbslash "console", O_RDONLY);
	if (C.KBD_dev < 0)
	{
		display("XaAES ERROR: Can't open /dev/console ?\n");
		cleanup() ;
		return -1;
	}

	{
		IFDIAG(void *haha =)
		nkc_init();
		DIAGS(("nkc_init tables are at %lx\n", haha));
	}

#endif
	/* Open us a virtual workstation for XaAES to play with */

	C.vh = C.P_handle;
	v_opnvwk(work_in, &C.vh, work_out);

	v_hide_c(C.vh);
	wr_mode(MD_TRANS);				/* We run in TRANSPARENT mode for all AES ops (unless otherwise requested) */
	vst_alignment(C.vh, 0, 5, &f, &f);		/* YESss !!! */

	/* Setup the screen parameters */

	screen.r.x = screen.r.y = 0;
	screen.r.w = work_out[0] + 1;	/* HR + 1 */
	screen.r.h = work_out[1] + 1;	/* HR + 1 */
	clear_clip();
	screen.colours = work_out[13];
	screen.display_type = D_LOCAL;

	screen.dial_colours =
		MONO ? bw_default_colours : default_colours;

	vq_extnd(C.vh, 1, work_out);			/* Get extended information */
	screen.planes = work_out[4];				/* number of planes in the screen */

#if HALFSCREEN
	/* HR 290601: forgot to divide by char_bit; now I use calc_back :-) */
	cfg.half_screen_size = calc_back(&screen.r, screen.planes);
	cfg.half_screen_size /= screen.planes < 8 ? 4 : 2;
	if (cfg.half_screen_size > cfg.half_screen_max)
		cfg.half_screen_size = cfg.half_screen_max;
#endif

	/* Set the default clipboard */

	strcpy(cfg.scrap_path, "c:" sbslash "clipbrd" sbslash "");


	/* Set the default accessory path */
	
	strcpy(cfg.acc_path, "c:" sbslash "");

	/* Parse the standard startup file xaaes.cnf
	 * This can run programs & redirect the debugging output to another file/device
	 */
	 
	/* FIX_PC  .lst */
	IFDIAG (strcpy(D.debug_path, "debug.lst");)			/* By default debugging output goes to the file "./debug.lst"*/

	sdisplay(C.Aes->home_path, "%c:%s", C.home_drv + 'A', C.home);

	IFDIAG (display(">");bios(2,2);)
	parse_cnf();

#if !DRAW_TEST
	/* Open /dev/moose (HR 040201: after parse_cnf for mintmouse) */
	
	if (!init_moose())
	{
		cleanup();
		return -1;
	}
#endif

	/* If we are using anything apart from the system font for windows,
	 * better check for GDOS and load the fonts.
	 */

	if (cfg.font_id != 1)
	{
		if (vq_gdos())					/* Yeah, I know, this is assuming the old-style vq_gdos() binding */
			vst_load_fonts(C.vh, 0);
		else
			cfg.font_id = 1;
	}


	/* Set standard AES font */

	screen.standard_font_id = screen.small_font_id =
		vst_font(C.vh, cfg.font_id);


	/* Select Small font */

	screen.small_font_point = vst_point(C.vh,
		cfg.small_font_point, &f, &screen.small_font_height, &f, &f);


	/* Select standard font */
	
 	screen.standard_font_point = vst_point(C.vh,
 		(screen.r.h <= 280) ? cfg.medium_font_point : cfg.standard_font_point,
		&f, &screen.standard_font_height, &f, &f);


	/* Get font information for use by the resource loader */
	
	vqt_attributes(C.vh, work_out) ;
	screen.c_max_w = work_out[8];				/* Character cell width */
	screen.c_min_w = work_out[8] / 2;			/* Character cell width */
	screen.c_max_h = work_out[9];				/* Character cell height */
	screen.c_min_h = work_out[9] / 2;			/* Character cell height */

	/* Open a diagnostics file? All console output can be considered diagnostics,
	 * so I just redirect the console to the required file/device
	 */
 	 
	IFDIAG (if (!D.all.point)
		        display("Debug output initially turned off\n");)

	DIAGS(("Display Device: Phys_handle=%d, Virt_handle=%d\n", C.P_handle, C.vh));
	DIAGS((" size=[%d,%d], colours=%d, bitplanes=%d\n", screen.r.w, screen.r.h, screen.colours, screen.planes));

	/* Load the system resource files */
	resource_name = shell_find(NOLOCKING, C.Aes, lcfg.rsc_name);
	if (resource_name == nil)
		resource_name = xa_find(lcfg.rsc_name);		/* HR */
	if (resource_name)
	{
		C.Aes_rsc = LoadResources(C.Aes, resource_name, nil, DU_RSX_CONV, DU_RSY_CONV);
		if (C.Aes_rsc)
			display("system resource = %lx\n", C.Aes_rsc);
	}	
	if (!resource_name or !C.Aes_rsc)
	{
		display("ERROR: Can't find/load system resource file '%s'\n",lcfg.rsc_name);
		cleanup();
		return -1;
	}

	resource_name = shell_find(NOLOCKING, C.Aes, lcfg.widg_name);
	if (resource_name == nil)
		resource_name = xa_find(lcfg.widg_name);		/* HR */
	if (resource_name)
	{
		widget_resources = LoadResources(C.Aes, resource_name, nil, DU_RSX_CONV, DU_RSY_CONV);
		if (widget_resources)
			display("widget_resources=%lx\n", widget_resources);
	}
	if (!resource_name or !widget_resources)
	{
		display("ERROR: Can't find/load widget resource file '%s'\n",lcfg.widg_name);
		cleanup();
		return -1;
	}

#if FILESELECTOR
	/* HR: Do some itialisation */
	init_fsel();
#endif

	/* Create the root (desktop) window
	 * - We don't want messages from it, so make it a NO_MESSAGES window
	 */
	
	DIAGS(("creating root window\n"));

	root_window = create_window(
							NOLOCKING,
							nil,
							C.AESpid,
							false,
							XaMENU|					/* HR: menu standard widget */
							NO_MESSAGES,
							-1,						/* HR: -1, no frame, overscan window */
							 screen.r,				/*  current size */
							 &screen.r,			/*  maximum size (NB default would be root_window->wa) */
							 nil );					/* need no remembrance */
/*	root_window->handle = 0;  HR */

	/* Tack a menu onto the root widget */

	C.Aes->std_menu.tree = ResourceTree(C.Aes_rsc, SYSTEM_MENU);	/* HR widget.tree */
	C.Aes->std_menu.pid = C.AESpid;

	fix_menu(C.Aes->std_menu.tree,true);										/* HR */
	set_menu_widget(root_window, &C.Aes->std_menu);		/* HR */

	{
		char *vs = get_ob_spec(C.Aes->std_menu.tree + SYS_DESK)->string;
		strcpy(vs + strlen(vs) - 3, version + 3);
	}
	
	DIAGS(("menu widget set\n"));


	/* Fix up the file selector menu */
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
		C.Aes->desktop = ob;
		set_desktop(ob);
	}

	DIAGS(("setting up task manager\n"));
	
#if !DRAW_TEST
/* HR moved the title to set_slist_widget() */
	/* Setup the task manager */
	set_scroll(C.Aes, ResourceTree(C.Aes_rsc, TASK_MANAGER), TM_LIST);

	/* Setup the file selector */
	set_scroll(C.Aes, ResourceTree(C.Aes_rsc, FILE_SELECT), FS_LIST);

	/* Setup the System Alert log */
	set_scroll(C.Aes, ResourceTree(C.Aes_rsc, SYS_ERROR), SYSALERT_LIST);

#endif
	/* Display the root window */
	
	DIAGS(("About to display root window\n"));

	C.focus = root_window;			/* HR */

	open_window(NOLOCKING, C.AESpid, root_window->handle, screen.r);
	
	/* Initial iconified window coords */

	C.iconify = iconify_grid(0);		/* HR */

	/* Set our process priority
	 * - a high negative value here improves performance a lot, 
	 * so I set it to -20 in XA_DEFS.H. This doesn't hurt the rest
	 * of the systems performance, as there are no busy wait loops
	 * in the server, and it spends most of its time blocked
	 * waiting for commands.
	 */


#if !DRAW_TEST
	/* Catch SIGCHLD to spot dead children */
	
	Psignal(SIGCHLD, (long)HandleSIGCHLD);

	/* Catch SIGINT and SIGQUIT so we can shutdown with CTRL+ALT+C */
	
	Psignal(SIGINT, (long)HandleSIGINT);
	Psignal(SIGQUIT, (long)HandleSIGQUIT);

	/* Load Accessories */
	
	DIAGS(("loading accs\n"));
	load_accs();

	/* HR: I just like to have the unlocks at the same level as the locks. */

	/* Unlock the semaphores...we're ready to go */

/*	Sema_Dn(TRAP_HANDLER_SEMA);
*/	Sema_Dn(WIN_LIST_SEMA);
	Sema_Dn(ROOT_SEMA);
	Sema_Dn(UPDATE_LOCK);
	Sema_Dn(MOUSE_LOCK);
	Sema_Dn(FSELECT_SEMA);

	Sema_Dn(ENV_SEMA);			/* HR */
	Sema_Dn(PENDING_SEMA);


	Sema_Dn(CLIENTS_SEMA);
	Sema_Dn(APPL_INIT_SEMA);

	DIAGS(("Semaphores Unlocked!!!\n"));

	/* Turn on the mouse cursor */
	
	v_show_c(C.vh, 0);		/* 0 = reset */

	/* Call the main command interpreter kernel */
	
	DIAG((D.appl,-1,"Going to the kernel\n"));



	XaAES();


	/* Closedown & exit */
	
	cleanup();

#else				/* draw_test */
	{
	void cancel_fsel(char *path, char *file);
	RECT r = {32,32,256,256};
	short kind = NAME
				|INFO
				|CLOSER
				|FULLER
				|SMALLER
				|SIZER
				|VSLIDE
				|UPARROW
				|HSLIDE
				|LFARROW
				;
		XA_WINDOW *w;
		v_clrwk(C.vh);
		NewClient(2);
		w = create_window(NOLOCKING, nil,2,false,kind,MG,screen.r, &screen.r, nil);
		open_window(NOLOCKING,2,w->handle,r);
		display_window(NOLOCKING,w);		/* fake all locks */
	/*	do_form_alert(NOLOCKING, 1,"[ 1 ] [ Test | de | form_alert ] [ OK | apply | Cancel ]",2);
	*/	open_fileselector(NOLOCKING,2,"D:\AAAA\*.*","Test fsel",NULL,cancel_fsel);
		bios(2,2);
	}
#endif
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

global
void open_about(LOCK lock)
{
	XA_WINDOW *dialog_window;
	OBJECT *form = ResourceTree(C.Aes_rsc, ABOUT_XAAES);
	static RECT remember = {0,0,0,0};

	if (!about_window)
	{
		/* HR */
	/* Work out sizing */
		if (!remember.w)
			center_form(form, ICON_H),
			calc_window(C.AESpid, WC_BORDER, CLOSE|NAME, &form->r, &remember);		/* HR */

	/* Create the window */
		dialog_window = create_window(lock, nil,
							C.AESpid,
							false,
							CLOSE|NAME|
							MOVE|
							NO_MESSAGES|
							NO_WORK,
							MG, remember, nil, &remember);

	/* Set the window title */
		dialog_window->widgets[XAW_TITLE].stuff = "  About  ";

	/* Set version date */
		(form + ABOUT_DATE)->ob_spec.string = __DATE__;

		set_toolbar_widget(lock, dialog_window, form, -1);

		((XA_TREE *)dialog_window->widgets[XAW_TOOLBAR].stuff)->pid = C.AESpid;

		dialog_window->widgets[XAW_TOOLBAR].behaviour[XACB_DCLICK] = NULL;
		dialog_window->widgets[XAW_TOOLBAR].behaviour[XACB_CLICK] = NULL;
		dialog_window->widgets[XAW_TOOLBAR].behaviour[XACB_DRAG] = NULL;

	/* Set the window destructor */
		dialog_window->destructor = about_destructor;
		open_window(lock, C.AESpid, dialog_window->handle, remember);
		about_window = dialog_window;
	}
	else if (about_window != window_list)
	{
		C.focus = pull_wind_to_top(lock, about_window);			/* HR */
		after_top(lock, true);
		display_non_topped_window(lock, 3, about_window, NULL);
	}
}

global
void strnupr(char *s, short n)
{
	short f;
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

global
void *xmalloc(size_t size, short key)
{
	void *a;
	DIAG((D.x,-1,"XA_alloc %ld k:%d\n", size, key));
	a = XA_alloc(nil, size, key, 0);
	DIAG((D.x,-1,"     --> %ld\n", a));
	return a;	
}

global
void *xcalloc(size_t items, size_t size, short key)
{
	void *a;
	DIAG((D.x,-1,"XA_calloc %ld*%ld, k:%d\n", items, size, key));
	a = XA_calloc(nil, items, size, key, 0);
	DIAG((D.x,-1,"     --> %ld\n", a));
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
	DIAG((D.x,-1,"XA_free %ld k:%d\n", addr, un->key));
	XA_free(nil,addr);
}

global
void _FreeAll(void)
{
	DIAG((D.x,-1,"XA_free_all\n"));
	XA_free_all(nil, -1, -1);
}

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
