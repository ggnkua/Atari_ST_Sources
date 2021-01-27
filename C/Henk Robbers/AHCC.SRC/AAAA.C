/* Copyright (c) 1990 - present by H. Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	AAAA.C
 *	=====
 */

#include <string.h>
#include <ahcm.h>

#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#include "aaaa.h"

#if GEMSHELL || TEXTFILE || BINARY
#include "common/kit.h"
#endif

#if TEXTFILE
#include "text/cursor.h"
#include "text/text.h"
#include "text/text_cfg.h"
#include "text/editor.h"
#endif

#include "shell/shell.h"
#include "common/files.h"
#include "common/options.h"
#include "common/journal.h"
#include "common/wdial.h"
#include "common/treeview.h"

#if DIGGER
#include "digger/ttd_kit.h"
#include "digger/ttd_cfg.h"
#include "digger/dig.h"
#include "digger/digobj.h"
#endif

#if BINARY
#include "bined/ed.h"
#endif

#if WKS
extern
M_S cmen;
FOPEN	open_sheet;
VpV load_sheetconfig, save_sheetconfig;
#endif

#if MFRAC
#include "mandel/mandelbr.h"
#endif

STBASE *txtfreebase=nil;			/* STore Manager Cell's and area's */
STMDEF winbase;

short
	aaaa_id=0,
	aes_flags=0,
	aes_font=1,
	aes_font_height=13;

char *global_message = nil;


short points,hpoints;	/* points for font & half font */

extern
bool _nova,_t2w,MagX,MiNT;		/* ex SCR_INST */

bool init_open_jrnl = true;

short wchar,hchar;		/* tbv oude &| toplevel s/w */
short menu_prj_l;

global
IT deskw;
OBJECT  *Menu;
M_S	mainmenu={false,false,0,0,0,0,0,0,0,nil,nil};
bool showchange=false;

/*  COMMONS  */

static
STBASE  *winfreebase=nil;
OBJECT  *Title=nil;

/* Trying to locate memory corruption */
VpI CH;


#if 0
static long dl;
static void * ddl;
#define UP *l++ = dl;
long *l;
void moves_up(void)	/* never call this, but must create a ref!!!!!!!!!! */
{
	UP
	UP
	UP
	UP
	UP
	UP
	UP
	UP

	UP
	UP
	UP
	UP
	UP
	UP
	UP
	UP

	UP
	UP
	UP
	UP
	UP
	UP
	UP
	UP

	UP
	UP
	UP
	UP
	UP
	UP
	UP
	UP
}
#endif

void f_txt(short hs,short x,short y,char *text)
{
	x&=0xfff8;
	v_gtext(abs(hs),x,y,text);
}

global
char *frstr(short ob)
{
	char *s;
	rsrc_gaddr(R_STRING,ob,&s);
	return s;
}

#ifdef STRINGS
global
char *obstr(short ob)
{
	static OBJECT *o=nil;
	if (o eq nil)
		rsrc_gaddr(0,STRINGS,&o);
	return o[ob].spec.free_string;
}
#endif

/*  This function is NOT for determining THE half font height,
 *	but only to divide the large font, if there is one.
 *	Consequently it can be used to ask if the latter is the fact.
 */

global
short half_h(void)
{
	return hchar > wchar ? hchar/2 : hchar;	 /* if font square, no small */
}

typedef short ALCUR(short, const char *);
global
ALCUR * alert_cur = form_alert;

global
short alert_msg(char *t, ... )
{
	char m[256], *mp=m;
	va_list a;
	va_start(a,t);
	if (*t ne '[')		/* This for security reasons only */
	{
		mp+=sprintf(mp,"[1][ ");
		mp+=vsprintf(mp,t,a);
		sprintf(mp," ][ Ok ]");
	}
	else
		vsprintf(mp,t,a);
	va_end(a);
	return (*alert_cur)(1,m);
}


bool m_alerted=false;

global
void mem_alert(char *op1, char *op2)
{
	if (!m_alerted)
	{
#ifdef JOURNAL
		alert_jrnl("%s %s\n\t%s",frstr(RANOUT),op1 ? op1 : "",op2 ? op2 : "");
#else
		alert_text("%s %s\n\t%s",frstr(RANOUT),op1 ? op1 : "",op2 ? op2 : "");
		m_alerted = true;
#endif
	}
}

global
void * mmalloc(long l, char *op1, char *op2, short key)
{
	char *al;

	al=xmalloc(l,key);
	if (al <= nil)
		mem_alert(op1,op2);
	else
		m_alerted=false,
		*al=0;				/* nicely deliver a null string */
	return al;
}

static
void do_dial(OBJECT *ob,short f)		/* alleen voor dialogues zonder form_save */
{
	form_dial(f,0,0,0,0,ob->x-3,ob->y-3,ob->w+6 pdial,ob->h+6 pdial);
}

#ifdef HELP
global
void start_help(char *word)		/* triggered by HELP key */
{							/* help context is future enhancement */
	char helpname[DIR_MAX*2+1];
	char *message;
	static union
	{
		short b[8];
		struct
		{
			short ty, sender, l;
			char *path;
			char *line;
			short dum;
		} s;
	} buf;

	short ac = appl_find(frstr(GUIDENAME));

	if (ac >= 0)
	{
		message = global_message ? global_message : helpname;

		strmaxcpy(message, frstr(HELPNAME), DIR_MAX);

		if (word and *word)
			if (strlen(word) < DIR_MAX)
			{
				strcat(message, " ");
				strcat(message, word);
			}

		buf.s.line = nil;
		buf.s.path = message;
		buf.s.dum  = 0;
		buf.s.ty   = 0x4711;
		buf.s.sender = aaaa_id;
		buf.s.l = 0;
		ac = appl_write(ac,sizeof(buf.s),buf.b);
		if (!ac)
			alertm(frstr(HELPFAIL));
	}
	else
		alertm("%s -=%s=-", frstr(NOGUIDE), frstr(GUIDENAME));
}
#endif

global
void wwa_align(OBJECT *ob,IT *w)
{	ob->y=w->wa.y+1;
	if (ob->y+ob->h > scr.h)
		ob->y=scr.h-ob->h-1;
}

static
void en_windows(short dis)
{
	if (Menu)
	{
	static short was = -1;
	if (dis ne was)
		{
	#ifdef MNCYCL
			menu_ienable(Menu,MNCYCL,dis);
	#endif
	#ifdef MNTILE
			menu_ienable(Menu,MNTILE,dis);
	#endif
	#ifdef MNOVLAP
			menu_ienable(Menu,MNOVLAP,dis);
	#endif
			was = dis;
		}
	}
}

global
XA_report punit
{
	printf("**** %s: ", txt);
	if (!unit)
	{
		printf("nil\n");
	othw
		XA_unit *prior = unit->prior, *next = unit->next;
		printf(" -= %d =- u%ld :: s%ld, p:%ld :: %ld, n:%ld :: %ld, block %ld :: s%ld\n",
			unit->key,
			unit, unit->size,
			prior, prior?prior->size:-1,
			next, next?next->size:-1,
			blk, blk->size);
		bios(2,2);
	}
}

global
short eruit(short r)
{
	marrow();

	if (r ne 2)
	{
	#ifdef GEMSHELL
		end_shell();
		clear_help_stack();
	#endif

	#if TMENU
		if (cfg.a)
		{
			/* CH(9); */
			save_txtconfig();
		}
	#elif BMENU
		if (cfg.a)
			save_binconfig();
	#elif WKS
			save_sheetconfig();
	#elif DIGGER
		if (cfg.a)
			save_disconfig();
	#endif

		if (!delete_windows(r))
			return false;			/* if automatic save_files had been cancelled */

	#ifdef KIT
		end_kit();
	#elif TTD_KIT
		end_ttdkit();
	#endif

	#ifdef BOLDTAGS
		XA_free_all(nil, BOLDTAGS, -1);
	#endif

	#ifdef MFRAC
		end_mandel();
	#endif

	#if DIGGER
		end_disass();
	#endif

	#if TREEWIN
		dp_end();
	#endif

		if (Menu)
			menu_bar(Menu,false);
		wind_update(END_UPDATE);

		nkc_exit();

		stmclear(&winbase);				/* for internal security */
		rsrc_free();

	#if TEXTFILE || BINARY
		xfree(deskw.loctab);
	#endif
		stmfreeall();
	}

	XA_free_all(&XA_global_base, -1, -1);
	v_clsvwk(v_hl);
	appl_exit();

#if AA_LEAK
	XA_leaked(nil, -1, -1, punit, 1);
	XA_leaked(&XA_file_base, -1, -1, punit, 2);
#endif

	if (r)
		exit(r);

	return true;
}

#if defined MNTITEL || defined OKT
static
void do_Title(void)
{
#ifdef GEMSHELL
	do_Scopyright();
#elif  DIGGER
	do_Ocopyright();
#else
	if (Title)
	{
		do_dial(Title,FMD_START);
		objc_draw(Title,0,2,wwa.x,wwa.y,wwa.w,wwa.h);
		aform_do(Title,0,nil,0,0);
#ifdef OKT
		keusaf(Title[OKT]);
#endif
		do_dial(Title,FMD_FINISH);
	}
#endif
}
#endif


global
char prg_name[] = PRGNAME;

#if DROPWIN
char drop_name[14];
static
WINIT drop_winit
{
	sprintf(drop_name,"-%s-", prg_name);
	w->in.x = w->unit.w+(w->wh*half_h()); /* next_upper_left? */
	w->in.y = w->unit.h+(w->wh*half_h());
	w->in.w = strlen(drop_name)*w->unit.w+w->v.w;
	w->in.h =                   w->unit.h+w->v.h;
	snapwindow(w,&w->in);
}
static
DRAW  drop_draw
{
	short dum;
	vst_height(w->hl,w->points,&dum,&dum,&dum,&dum);
	hidem;
	if (get_cookie('NVDI',nil))		/* only then it looks good */
	{
		gspbox(w->hl,w->wa);
		vst_effects(w->hl,0x04);
		v_gtext(w->hl,w->wa.x-half_h(),w->wa.y,drop_name);
	}
	else
		v_gtext(w->hl,w->wa.x,w->wa.y,drop_name);
	showm;
	vst_height(w->hl,points,&dum,&dum,&dum,&dum);
	vst_effects(w->hl,0);
}
static
MOVED drop_move
{
	snapwindow(w,to);
	w->rem=*to;
	wind_set(w->wh,WF_CURRXYWH,w->rem);
	wind_get(w->wh,WF_WORKXYWH,&w->wa.x,&w->wa.y,&w->wa.w,&w->wa.h);
}

static
FCLOSE drop_delete
{
	wind_close(w->wh);
	wind_delete(w->wh);
	return true;
}
#endif

global
CFG_LOCAL def_loc =		/* for desk window */
{
	' ', ' ', 4, 4, 1, 4, MAXL, true, true, true, true, false, true, false,
	{false,0,1,2},		/* scroll info's */
	{true, 1,2,3}
};

static
void set_desk(IT *w)
{
	zero(deskw);

#ifdef AMENU
	menu_init(&mainmenu,AMENU,v_hl,scr_grect);
	Menu=mainmenu.m;
	w->menu=&mainmenu;
#else
	Menu = nil;
#endif

	winfreebase=stminit(&winbase,nil,CYCLIC,sizeof(IT),16, "Desk");
/*	16 = chunksize; if you open 65 windows 5 chunks will be allocated,
			so dont bother.
*/

	wind_get (0,WF_CURRXYWH,&win.x,&win.y,&win.w,&win.h);	/* cur */
	wind_calc(WC_WORK,NAME|MOVER, win.x, win.y, win.w, win.h,
	                       &wwa.x,&wwa.y,&wwa.w,&wwa.h);	/* wa */

	wwa.w = scr_grect.w;

	wwv.x=win.x-wwa.x;
	wwv.y=win.y-wwa.y;
	wwv.w=win.w-wwa.w;
	wwv.h=win.h-wwa.h;
	w->wh=-1;
	w->ty=-1;
	w->view.sz.w = MAXL;
	strcpy(w->title.t, " Desktop ");
	w->full=true;
	w->fullw=74;
	w->points=points;		/* voorlopig absolute mode */
	w->unit.w=wchar;				/* default unit sizes */
	w->unit.h=hchar;
	w->hl=v_hl;
	w->norm.sz.h=wwa.h/w->unit.h;
	w->norm.sz.w=wwa.w/w->unit.w;

/*	Default settings; mostly for options that can be set
	when no window is open.
*/

#if TEXTFILE
	w->loc = txt_local();
#elif BINARY
	w->loc = bin_local();
#elif DIGGER
	dis_local(w);
	w->loc = def_loc;
#endif

#if DROPWIN and defined PRGNAME
	if (MagX or MiNT)
	{
		WH unit = deskw.unit;
		IT *w;

		unit.w *= 2;
		unit.h *= 2;

		w = create_IT
		   (
			true, "drop", 0 , "", nil,
			NAME|MOVER, DROP, nil, nil, nil, nil, 0, drop_winit, nil, nil,
			drop_draw, nil, nil, nil, nil, nil, nil, nil,
			drop_delete,nil, nil, nil, nil, nil, nil,
			drop_move, nil, nil, nil, nil, nil, nil, nil,
			nil, nil, nil, nil, nil, nil, nil, nil, nil, 0L,
			unit, deskw.points*2,
			nil
		   );
		if (w)
		{
			w->op=wind_open(w->wh, w->rem.x, w->rem.y, w->rem.w, w->rem.h);
			if (w->op)
			{
				wind_set(w->wh,WF_NAME,w->title.t);
				wind_set(w->wh,WF_TOP);
				drop_move(w,&w->in);
				do_redraw(w,w->wa); /* Not yet in eventloop */
			}
		}
	}
#endif
}

static
void init_subsystems(short argc, char *argv[])
{
	VpV spmm;
	short ax,ay;
	vsf_interior (v_hl,FIS_SOLID);
	vsf_style    (v_hl,0);
	vsf_color    (v_hl,0);
	vst_color    (v_hl,1);
	vsf_perimeter(v_hl,0);
	vst_alignment(v_hl,0, 5, &ax, &ay);	/* 5 = top line */

	nkc_init();

	if (MagX or MiNT)
		Pdomain(1);		/* allow long filenames */

	if ( rsrc_load(RSRC_RSC) eq 0)
	{
		form_alert(1, "[3][Geen resource!!][ Ach ]");
		eruit(2);
	}
#ifdef TITEL
	rsrc_gaddr(0,TITEL,&Title);		/* In dialogue, not journal */
	Title->x=8;
	Title->y=24;
#endif

	/*	desktop */
	set_desk(&deskw);

#ifdef MTDEBUG
	#if ! DEBUG
	{
		short i = strlen(Menu[MTDEBUG].spec.free_string) + 1;
		Menu[MTDEBUG].flags |= HIDETREE;		/* 02'12 HR */
		Menu[2].w -= i*wchar;
	}
	#endif
#endif


#ifdef MNASSEMF
	#if !BIP_ASM
		Menu[MNASSEMF].state |= DISABLED;
	#endif
#endif

#if defined PRGNAME && defined MTDESK
	{
		static char mname[128];
		mname[0] = ' ';
		strcpy(mname + 1, prg_name);
		Menu[MTDESK].spec.free_string = mname;
	}
#endif

#ifdef MNC
	if (!MagX and !MiNT)  /* Single TOS */		/* 05'12 HR V4.12 */
	{
		strupr(Menu[MNC].spec.free_string);
		strupr(Menu[MNH].spec.free_string);
		strupr(Menu[MNS].spec.free_string);
		strupr(Menu[MNP].spec.free_string);
	}
#endif

	if (Menu)
		menu_bar(Menu,true);

#ifdef MMENU
	menu_init(&mmen,MMENU,v_hl,scr_grect);
#endif
#ifdef TMENU
	menu_init(&tmen,TMENU,v_hl,scr_grect);
	#ifdef MTREPAIRNOT
		tmen.m[MTREPAIRNOT].state |= DISABLED;
		*tmen.m[MTREPAIRNOT].spec.free_string = 0;
	#endif
#endif
# ifdef DMENU
	menu_init(&dmen,DMENU,v_hl,scr_grect);
# endif
# ifdef FMENU
	menu_init(&fmen,FMENU,v_hl,scr_grect);
# endif
#ifdef JOURNAL
	menu_init(&jmen,JOURNAL,v_hl,scr_grect);
#endif
#ifdef OMENU
	menu_init(&dmen,OMENU,v_hl,scr_grect);
#endif
#ifdef BMENU
	menu_init(&bmen,BMENU,v_hl,scr_grect);
#endif
#ifdef CMENU
	menu_init(&cmen,CMENU,v_hl,scr_grect);
#endif

#if BIP_CC
	{ VpV tok_init;
		  tok_init();
	}
#endif

#ifdef FILES
	init_dir(1);		/* 1 = GEM */
#endif

#ifdef MTSEARCH		/* text viewer/editor */
	invoke_cursor(tmen.m);
	init_txtcfg(&pkit);
#elif MBSEARCH		/* binary editor */
	invoke_kit();
	init_bincfg(&pkit);
#elif TTD_KIT			/* disassembler */
	invoke_ttdkit();
	init_ttdcfg(&pkit);
#endif

#ifdef MTM
	initoptions();
#endif

#ifdef MFRAC
	init_mandel(argc);			/* if args dont open intro mandelbrot */
#endif

#ifdef GEMSHELL
	init_shell();
#endif

#if TMENU
	load_txtconfig();
#elif BMENU
	load_binconfig();
#elif WKS
	load_sheetconfig();
#elif DIGGER
	load_disconfig();				/* before: init_files can open a object file */
#endif

#ifdef BOLDTAGS
	read_tags();
#endif

/*  if init_files opens a object, the journal
    is also opened (voor objects)
*/
#if FILES
	init_files(argc,argv);
#endif

#ifdef GEMSHELL
/* If a shell then also a journal and open it for copyright msg.
   BUT after init_files: if the latter opens any window,
   open_jrnl is suppressed if not allready opened by a object
*/
	#if FSVIEW
		fs_init();
	#endif
	{
		extern char *argmake;
		void init_make(char *);
		VpV init_dictionary;
		menu_prj_l = strlen(Menu[MTPRJ].spec.free_string);
#ifdef JOURNAL
		if (!get_it(-1,JRNL))
			init_jrnl(&shell_msg, dial_find, 0);		/* (0; 1=full size) */
#endif
#if BIP_CC && __COLDFIRE__
		init_dictionary();
#endif
		init_make(argmake);
	}

#elif DIGGER
	if (!get_it(-1,JRNL))
	{
		init_jrnl(&ttd_msg, nil, 0);			/* 1 in testfase */
		send_msg("\n");
	}
#elif defined ADDO
	if (!get_it(-1,JRNL))
	{
		init_jrnl(nil, nil, 0);
	}
#elif WKS && JOURNAL
	if (!get_it(-1,JRNL))
	{
		init_jrnl(nil, nil, 0);
	}
#elif JOURNAL								/* absolutely default */
	if (!get_it(-1,JRNL))
	{
		init_jrnl(nil, dial_find, 0);
	}
#endif

/*	CH(1); */
}

#if 0 /* def __LINEA__ */
void font_info(FONT_HDR *sys,char *opm)
{
	short sf,fprop,a[5];

	send_msg("%s info:\n",opm);
	if (sys)
	{
		a[0]=sys->bot_dist;
		a[1]=sys->des_dist;
		a[2]=sys->hlf_dist;
		a[3]=sys->asc_dist;
		a[4]=sys->top_dist;

		fprop = sys->flags.mono_spaced ne 0;
		sf = sys->flags.system;
		send_msg("name='%s',ds[%d,%d,%d,%d,%d] sys:%d,prop:%d\n",
				sys->facename,a[0],a[1],a[2],a[3],a[4],fprop,sf);
	}
}
#endif

#if DRAGDROP
#include <signal.h>

#ifndef SIGPIPE
#define SIGPIPE 13
#endif


static
char noexts[34],
     buf[DD_NAMEMAX+2];
static
void *oldpipesig;
static
char args    [] = "ARGS",
     pipename[] = DD_FNAME;

/*
 * close a drag & drop operation
 */

static
void ddclose(short fd)
{
	Psignal(SIGPIPE, oldpipesig);
	Fclose(fd);
}

#define DBGDROP 0

#if DBGDROP
#define	DPD(x) v_gtext(v_hl,640,1,x);
#else
#define	DPD(x)
#endif

static
void do_drop(short mp[])
{
	short i,fd;
	char nak = DD_NAK,
	     nok = DD_OK,
	     ext[6];
	long size; bool gotit = false;


DPD("stage 00  ")
	memset(noexts, 0, sizeof(noexts));
	pipename[17] = mp[7] & 0xff;
	pipename[18] = mp[7] >> 8;
	fd = Fopen(pipename, 2);
	if (fd > 0)
	{
DPD("stage 0   ")
		noexts[0] = DD_OK;
		strcpy(noexts+1, args);
		oldpipesig = Psignal(SIGPIPE, SIG_IGN);
		i = Fwrite(fd, DD_EXTSIZE+1, noexts);
		if (i eq DD_EXTSIZE+1)
		{
			short hdrlen; char naam[DD_NAMEMAX+2];
DPD("stage 1   ")
			i = Fread(fd, 2L, &hdrlen);
			if (i eq 2)
			{
DPD("stage 2   ")
				i = Fread(fd, 4, ext);	/* read ext */
				if (i eq 4)
				{
DPD("stage 3   ")
					ext[4]=0;
					if (strcmp(ext,args) eq 0)
					{
DPD("stage 4   ")
						i = Fread(fd, 4L, &size);
						if (i eq 4)
						{

DPD("stage 5   ")
							hdrlen-=8;
							if (hdrlen > DD_NAMEMAX)
								i = DD_NAMEMAX;
							else
								i = hdrlen;

							if (Fread(fd, i, naam) eq i)
							{
DPD("stage 5   ")
								hdrlen -= i;
								naam[i]=0;
							/* skip any extra header (future use) */
								while (hdrlen > DD_NAMEMAX)
								{
									Fread(fd, DD_NAMEMAX, buf);
									hdrlen -= DD_NAMEMAX;
								}
								if (hdrlen > 0)
									Fread(fd, hdrlen, buf);
								Fwrite(fd, 1, &nok);
								/* Now read the actual data */
								if (size > DD_NAMEMAX)
									size = DD_NAMEMAX;
								i = Fread(fd, size, buf);
								buf[i]=0;
								gotit = true;
							}
						}
					}
				}
			}
		}
		if (gotit)
		{
			char *s = buf, *t = buf;
			ddclose(fd);
#ifdef MNMULT
/* mp+3 window handle that's dropped on
   mp+4 mouse x position at time of drop
   mp+5 mouse Y position at time of drop
   mp+6 keyboard shift status at time of drop
        if dropped on kit's window it's a directory
	    that must be put in the text field on wich it is dropped
*/			{
				IT *w = get_it(-1,KIT);
				if (w)
				{
					if ( w->wh > 0 and w->op and w->wh eq mp[3])
					{
						if (*s eq '\'')
						{
							t++;
							s++;
							while (*s and *s ne '\'') s++;
						}
						else
							while (*s and *s ne ' ') s++;
						if (*s)
							*s = 0;
						kit_drop(w,0,t,mp[4],mp[5]);
						return;
					}
				}
			}
#endif
			while (*t)
			{
				if (*t eq '\'')
				{
					t++, s++;
					while (*s and *s ne '\'') s++;
					if (*s)
						*s++ =0;
					if (*s eq ' ')
						*s++ = 0;
				othw
					while (*s and *s ne ' ') s++;
					if (*s)
						*s++ = 0;
				}
#if DIGGER
				{
					long fl;
					if ( (fl=Fopen(t,0)) > 0)
						open_object(t, fl ,nil);
				}
#elif TEXTFILE
				open_text_file(t);		/* looks in cached file list before open */
#elif MFRAC
				{
					long fl;
					if ( (fl=Fopen(t,0)) > 0)
						open_mandel(t,fl,nil);
				}
#elif BINARY
				{
					long fl;
					if ( (fl=Fopen(t,0)) > 0)
						open_binary(t,fl, nil);
				}
#endif
				t = s;
			}
		othw
			Fwrite(fd, 1, &nak);
			ddclose(fd);
		}
	}
}
#endif

#ifdef WKS
extern
TEDINFO *ed_str,*co_str;
#endif

global
void w_top(short mn, IT *w, IT *wt)
{
	if (wt)
	{
		cur_off(wt);
	}
	cur_off(w);
	to_top();
	wind_set(mn,WF_TOP);

#ifdef WMENU
	get_work(w);		/* for menu_bar etc */
#endif

#if WINDIAL
	if (no_dial(w))
	{
		set_dialinfs(w);
	othw
		set_dialinfs(wt);
		wdial_on(w);
	}
#endif

#ifdef WMENU
	if (wt)
		if (wt->menu)
			wt->menu->valid = false;

	if (w->menu)
	{
		w->menu->valid = true;
		via (w->set_menu)(w);	/* vinkjes&enable */
	}
#endif

#ifdef WKS				/* 11'07 HR */
	strcpy(ed_str->text, w->wks.edstr);
	strcpy(co_str->text, w->wks.costr);
#endif
}

static
void do_mesag(IT *w,IT *wt,short mp[])
{
	short mn=mp[3],
		  mt=mp[4];

/*	alertm("MESAG; mp(0)=%d,mn=%d",mp[0],mn);	*/

/* Care must be taken that all functions can be performed on
    non top windows */

	switch( mp[0] )
	{
		case WM_REDRAW:
			do_redraw(w,*(RECT *)&mp[4]);
		break;
		case WM_CLOSED:
			via (w->closed)(w);
		break;
		case WM_TOPPED:
			via (w->topped)(w,wt);
			else					/* default action */
				w_top(mn,w,wt);
		break;
		case WM_FULLED:
			via (w->fulled)(w);
		break;
		case WM_VSLID:
			via (w->slide)(w,w->hslp,mt,w eq wt);
		break;
		case WM_HSLID:
			via (w->slide)(w,mt,w->vslp,w eq wt);
		break;
		case WM_ARROWED:
			if (w->arrowd)
				if (aes_global.version >= 0x300 and aes_global.version < 0x400)
				{
					static short old=0;

/*	We dont do it if mp[2] changes to > 0.
Why this all is necessary is not found in any documentation, but it works.
If mp[2] never changes to >0 there is no problem and it works normal.

It seems that if you hold the button down on an arrow, mp[2] becomes >0,
but that in some TOSes the wait time is so short that you get 2 events
on what seems to be only 1 click; one event with 0 and one with x20 in mp[2].
*/
					if (!(mp[2] > 0 and old eq 0))
						(*w->arrowd)(w,mt,w eq wt);
					old = mp[2];
				}
				else
					(*w->arrowd)(w,mt,w eq wt);
		break;
		case WM_SIZED:
			via (w->sized)(w,(RECT *)&mp[4]); /* incl slidersize */
		break;
		case WM_MOVED:
			via (w->moved)(w,(RECT *)&mp[4]);
		break;
	}  /* end switch (mp) */
}

global
/* bool do_menu(IT *w,OBJECT *m,short mn,short choice,short kstate) */
MENU_DO do_menu			/* Now only for main menu */
{

#ifdef MT1
	if (m)
	{
		if (      title eq MT1
			 and  choice eq MNQUIT
			 and  eruit(false) )			/* false: not force for check_save() */
				return false;				/* OK: quit */
/* NB!! then also MT1 */
	#ifdef MTDESK
		else if ( title eq MTDESK
			 and  choice eq MNTITEL) 	do_Title();
	#endif
	#ifdef MTM
		else if ( title eq MTM	   ) 	do_Mode (w,choice);
	#endif

	#ifdef MT1
		else if ( title eq MT1	   )	do_Open (  choice);
	#endif

	#ifdef MTLUA
		else if ( mn eq MTLUA  )	do_Lua	(  choice);
	#endif

	#ifdef GEMSHELL
		else if (!do_shell(title, choice))
	#elif defined WMENU
		else
	#endif

		/* This calls the rest of the main menu if its there.
		   If what normally is held in window menu's is moved to the main
		   menu, that is called here too.
		*/
			if (w)
				via (w->do_menu)(w,m,title,choice,kstate);
		menu_tnormal(m,title,true);
	}
#endif
	return true;
}

static
bool is_mkey(IT *w, short k)
{
	if (w)
		if (w->plain)
			return true;
	if (k&(NKF_CTRL|NKF_ALT))
		return true;
	k&=0xff;
	if (    k eq NK_UNDO or k eq NK_HELP or k eq NK_INS or k eq NK_DEL or k eq NK_ESC
	    or (k >= NK_F1 and k <= NK_F10)
	   )
		return true;
	return false;
}

IT *my_top;

global
void main(short argc, char *argv[])
{
	short evmask,event;
	short aes_keycode,aes_keystate;
	short kcode,mx,my,button,kstate,bclicks,mn,mt,mp[8];
	static bool w_on=false;

	XA_set_base(nil, XA_TCHUNK, 13, 0, nil, nil);

	aaaa_id = appl_init();
#ifdef UP
	ddl = moves_up;	/*	creates the ref, but does not do anything */
#endif
	mbumble;
	move_mode=CLICK;

	{
		short dum,effects[3],d[5];
		v_hl = instt_scr();			/* also sets global phys_handle and virt_handle */
		vqt_fontinfo(v_hl,&dum,&dum,d,&dum,effects);
		points=d[4];	/* celltop to baseline */

	/* --------------------------- TEST, leuk!! ----------------- */
	/*	points=26;												  */
	/* ---------------------------------------------------------- */

		vst_height(v_hl,points,&dum,&points,&wchar,&hchar);
		hpoints=points/2;
		aes_flags = get_aes_info(aes_global.version,&aes_font,&aes_font_height,&dum,&dum);
	}

	/* If the system supports AP_TERM, tell the system that we do as well. */
	if (aes_flags&GAI_APTERM)
		shel_write(9,1,0,nil,nil);

	if (MagX or MiNT)
		global_message = XA_alloc(&XA_global_base, DIR_MAX*2+1, nil, -1, -1);

	init_subsystems(argc,argv);
#ifdef UP
send_msg("With code move up\n");
#endif
	marrow();
	do						/* THE and the ONLY one  event loop */
	{
		static short lastwin = -1;

		RECT tw;
#ifdef WMENU
		RECT mw={0,0,0,0};
		short mwd=0;
#endif
		IT *wt; /* my top window */
		short lwh;

		my_top = nil;

		en_windows(w_handles(nil,nil) ne 0);
		evmask=MU_MESAG|MU_KEYBD;	/* minimum (keybd for menu_keys) */

		wind_get(0,WF_TOP,&lwh);	/* what's REALLY the top window */

		/* find MY window info & secure position of window within chain;
	 		Remember that WM_NEWTOP does not occur,
			and WM_UNTOPPED does not exist in atari GEM	*/
		wt = get_it(lwh,-1);

		if (wt)
		{
			to_top();				/* synchronization. */
			my_top = wt;			/* for debugging anywhere */
#if FILES
			if (is_file(wt))
			{
				S_path dum;
				DIRcpy(&dum, wt->title.t);
				idir = dir_plus_name(&dum, "*.*");
			}
#endif
			if (wt->antevnt)
				evmask=(*wt->antevnt)(wt,w_on,evmask);
			tw=wt->wa;
#ifdef WMENU
			if (wt->do_menu)
			{
				menu_place(wt->menu,wt->men); /* --> get_work */
				evmask=menu_evm(wt->menu,evmask,MU_M2);
				mwd =wt->menu->evm_dir;
				mw = wt->menu->r;
				if (!wt->menu->valid and !wt->menu->pn)
					via (wt->set_menu)(wt);
	#ifdef MTEDITOR
				dis_paste_etc(wt->menu->m,!is_buf(wt));
	#endif
			}
#endif
		}
		else
			marrow();

		lastwin = lwh;			/* Allways !!!! */

		event =
			evnt_multi(
				evmask,
				0x102,3,0,		/* see NKCC.DOC par 7 */
				w_on, tw.x,tw.y,tw.w,tw.h,
#ifdef WMENU
				mwd,mw.x,mw.y,mw.w,mw.h,
#else
				0,0,0,0,0,
#endif
				mp,
				500,0,		/* 1/2 sec */
				&mx,&my,
				&button,&aes_keystate,
				&aes_keycode,&bclicks
		 );

		kcode = aes_keycode;
		kstate = aes_keystate<<8;

		if (!event)
			continue;

		wind_update(BEG_UPDATE);

		if ( event & MU_M1 )
		{
			w_on = !w_on;			/* eruit <--> erin */
			if (w_on)
			{
				via(wt->muisvorm)(wt);				/* nu erin */
			othw
				marrow();
				if (wt and no_dial(wt))
					cur_on(wt);			/* keep visible & steady */
			}
		}

#ifdef WMENU
		if (wt and (event&MU_BUTTON))
		{
			if ((mn=menu_button(wt->menu,&mt)) > 0)
			{
				event&=~MU_BUTTON;
				if (!(*wt->do_menu)(wt,wt->menu->m,mn,mt,kstate))
					break;					/* while event:  QUIT */
			}
		}
#endif

#ifdef CAN_CLICK
		if (   wt and (event&MU_BUTTON)
#if 1	/* spurious zero click button events on MILAN TOS */
			and bclicks
#endif
		   )
			via (wt->button) (wt,button,kstate,bclicks,mx,my);

		if (event & MU_KEYBD)
		{
			short k,c;
			M_KEY key;

	/* hack for some tosses &| emulators concerning page up/down key's. They're so tempting. :-) */
			if (aes_keycode eq 0x4900)		/* Milan PS2 keyboard */
				aes_keycode = 0x4838;
			elif (aes_keycode eq 0x5100)
				aes_keycode = 0x5032;
			elif (aes_keycode eq 0x7300)	/* Aranym on Emutos */
				aes_keycode = 0x4b00;
			elif (aes_keycode eq 0x7400)	/* Aranym on Emutos */
				aes_keycode = 0x4d00;

			if   (   aes_keycode eq 0x4838	/* PC emulator (TOS2WIN) */ /* 10'13 v5, Gerhard Stoll: was elif */
			      or aes_keycode eq 0x5032)
				    aes_keystate|=K_RSHIFT|K_LSHIFT;

			kcode = normkey(aes_keystate,aes_keycode);
			k = kcode&0xff;
			c = kcode&NKF_CTRL;

			mn=0;
			mt=0;

			if (is_mkey(wt,kcode))
			{
				key=m_key(kcode);
	#ifdef MFRAC
				if (wt and wt->overscan)	/* cant use the menu's */
					mn = 0;
				else
	#endif
				{
	#ifdef WMENU
					if (wt and wt->do_menu and (mn=menu_keys(wt->menu,key,&mt)) ne 0)
						if (mt > 0 and !(*wt->do_menu)(wt,wt->menu->m,mn,mt,kstate))
							break;					/* while event:  QUIT */
	#endif
					if (!mn and (mn=menu_keys(&mainmenu,key,&mt)) ne 0 )
						if (mt > 0 and !do_menu(wt,Menu,mn,mt,kstate))
							break;					/* while event:  QUIT */
				}
			}

			if (!mn and wt)		/* key_codes needing open window */
			{
				/* scancode before !! conversion by NKCC */
				wt->aeskcode=aes_keycode;
				wt->aeskstate=aes_keystate;

				/* standards */
				if   ( c and (k eq 'U' or k eq 'u') and wt->closed )
					wt->closed(wt);
				elif ( c and (k eq '=' or k eq '+' or k eq '-') and wt->fulled )
					wt->fulled(wt);
				elif ( c and (k eq 'W' or k eq 'w') )
					cyclewindows(wt);
	#if defined MFRAC && defined MMFULL
				elif (wt->overscan and k eq 'o')
					(*wt->do_menu)(wt,wt->menu->m,MMSHOW,MMFULL,0);
	#endif
				else
					via (wt->keybd)(wt,kcode);
			}
		}		/* endif MU_KEYBD */
#endif

		if ( event & MU_MESAG )
		{
			mt=mp[4];
			mn=mp[3];
			if (mp[0] eq AP_TERM)
			{
				if (eruit(false))
					break;
			}
			elif (mp[0] eq MN_SELECTED)	/* Can only be main menu!! */
			{
				if (!do_menu(wt,Menu,mn,mt,kstate))
					break;					/* while event:  QUIT */
			}
#if DRAGDROP
			elif (mp[0] eq AP_DRAGDROP)
				do_drop(mp);
#endif
			else
			{
				IT *mw = get_it(mn,-1);
				do_mesag(mw,wt,mp);
			}
		}

#ifdef WMENU
		else
		/* not when also MU_MESAG;
		   for entries in top menu that overlay
		   the window menu bar */

		if ( (event & MU_M2) )
			if (menu_mouse(wt->menu,mx,my))
			{
				wind_update(END_UPDATE);
				continue;
			}
			else
			if (m_inside(mx,my,wt->ma))		/* Well where did we go to? */
			{
				via(wt->muisvorm)(wt);
			othw
				M_S *ms = wt->menu;
				if (ms)
					menu_clear(ms);			/* 06'16 v5.5 If a menu is pulled, push(remove) it! */
				marrow();
			}
#endif

		if ( event & MU_TIMER )
			if (wt)
				via (wt->timer)(wt);

		wind_update(END_UPDATE);
	}
	od		/* event loop */

	exit(0);
}

IT * get_second(IT *w, WSELECT *sel)
{
	IT *w2 = nil;
	STMC *ws, *top = stmcur(winbase);
	if (top)
		while ((ws=stmfind(&winbase,PRIOR,CYCLIC)) ne top)
		{
			w2=ws->wit;
			if (w2)
				if (sel(w2))
					if (w2 ne w)
						break;
			w2 = nil;
		}
	return w2;
}