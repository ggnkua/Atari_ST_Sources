/* multi-window terminal emulation Version 0.2, May 29th 1986
 *
 * (C) Copyright 1986 Hans-Martin Mosner, University of Dortmund, Germany
 * You may freely use and distribute this program as source
 * and/or binary provided you make no profit with it.
 */

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include <stdio.h>
#include <bios.h>
#include <xbios.h>
#include "wind.h"
#include "uw.h"
#include "windefs.h"

#define FIRSTOBJ DABOUT
#define LASTOBJ PRTSTOP


/* global constants
 */

extern	int		gl_apid;
extern	struct	wi_str	w[];

int	contrl[12];
int	intin[128];
int	ptsin[128];
int	intout[128];
int	ptsout[128];
int	work_in[11];
int	work_out[57];
int	pxyarray[20];
int	msgbuff[8];

int	phys_handle, handle;

/*
 * Variables used by various routines (miscellaneous).
 */

long	dummy;				/* dummy return variable */
int	scr_x, scr_y, scr_w, scr_h;	/* size of screen */
int	key;				/* the key pressed */
int	tmp;				/* temporary for anything... */
char	alert[300];			/* used for alerts */
int	xsiz, ysiz;			/* temporarys for size of window */

/*
 * Character stuff (fonts, keymaps).
 */
FNT	*fnttbl[10];			/* List of pointers to fonts avail */
int	fontsavail;			/* Number of fonts available */
FNT	*tempfont;			/* font pointer */
char	*oldshifted;			/* Pointer to old shifted key map. */
char	*oldnormal;			/* Pointer to old normal key map. */
char	*oldcapslock;			/* Pointer to old caps lock key map. */
int	menu_key_map[0x80];		/* menu objects indexed by key map
					   (alt key) read from object file */
int fontmenuobj[] =			/* array of font menu object numbers */
  { FNTBIG,
    FNTSYS,
    FNTOWN,
    FNTALT,
    FNTTINY,
    FNTUNKNW,
    /* Add new font menu items here! */
    0
  };
extern	FNT	*loadfont();

/*
 * State (loosely defined).
 */
int	tick;				/* used for flashing cursor */
int	outport;			/* ports used with uw */
int	inwind, outwind;		/* windows for input/output */
int	uw_runs;			/* is uw running ? */
FNT	*curfont;			/* font in use */
int	mouse;				/* is mouse visible ? */
int	menonoff;			/* Menu toggle. */
int	m1inout;			/* mouse event  enter = 0  exit = 1 */
int	sel_inp_mode;			/* input select with right button */
extern int highlighted_wdes;		/* window with text highligted */
#define LOCKLEN 30			/* Max length of lock password */
char	lockword[LOCKLEN];		/* lock password */
char	lockbld[LOCKLEN];		/* lock password build area*/
extern int kermwdes;			/* port number for kermit window */

/*
 * Options (somewhat loosely defined).
 */
int	fast;				/* flag for fast open/close */
int	overstrike;			/* flag for character drawing */
int	sliders;			/* flag for sliders on new windows */
int	titles;				/* flag for titles on new windows */
int	audibell;			/* Audible bell. */
int	visibell;			/* Visible bell. */
int	toponbel;			/* Top window on bell. */

FUNCSTRING fstrings[NFSTRINGS];		/* storage for function key bodys */

char	pastebuff[4096] = "";		/* 50 full lines of text */

char	confpath[80] = ".\\*.*";	/* initial config file path */
char	confname[40] = "win.cnf";	/* initial config file name */
int	confbutt;			/* button from fsel_input */

/*
 * Screen forms, objects, and other similar goodies...
 */
MFDB	screen_mf;

OBJECT	*obj_tmp, *menubar;
TEDINFO	*ted_tmp;
TEDINFO	*ted_fnum;

extern struct iorec old_iorec;	/* copy of old rs_232 io record from winio.c */

MFORM	rmbmform[1];
MFORM	lckmform[1];

#define	CHECKWIN	if (!outwind) break

/*
 * The program code...
 */

extern	char	*getmem();
#ifdef	MWC
#include <linea.h>
#endif

/*
 * If LOCATE is defined, it is assumed to be the path to check after
 * "." for standard files (fonts, config files, etc.).
 */
#ifndef	LOCATE
#define	locate(n)	n
#else
char	locpath[64] = LOCATE;

char	*
locate (name)
char	*name;
{
	int	fd;
	static	char	new[80];

	close(fd = open(name, 0));
	if (fd >= 0)
		return (name);

	sprintf(new, "%s\\%s", locpath, name);
	close(fd = open(new, 0));
	return (fd >= 0? new: name);
}
#endif

startup()
{
int i,j;
char *tmpfnt;
static char my_shft_map[128];
static char my_norm_map[128];

#ifndef	MWC
register GEMFONT **a5;		/* this is really register A5 */
#endif

  /* start up everything: appl_init, menu, and the like
   */
  appl_init();
  rsrc_load(locate("wind.rsc"));
  rsrc_gaddr(R_TREE, MENUBAR, &menubar);

  /*
   * Fill menu_key_map by scaning object strings for ALTINDICATOR.
   */
  for (i = FIRSTOBJ; i <= LASTOBJ; i++)
    if (menubar[i].ob_type == G_STRING)
    {
      char * found;
      char * index();

      found = index((char *)menubar[i].ob_spec, ALTINDICATOR);
      if (found != NULL)
      {
        menu_key_map[*(++found) & 0x7f] = i;
#ifdef DEBUG
        printf("menu_key_map[%c] = %d\n", *found, i);
#endif
      }
    }

/*  objc_change(menubar, VISIBELL, 0, 0, 0, 0, 0, CHECKED, 0); *already done*/
  menu_bar(menubar, menonoff = 1);
  m1inout = 1;
  audibell = 1;
  visibell = 1;
  sliders = 1;
  titles = 1;

  /* set mouse symbol to arrow
   */
  graf_mouse(ARROW, NULL);
  mouse = 1;

  /* get screen handle and sizes;
   * open virtual workstation
   */
  phys_handle = graf_handle(&dummy, &dummy, &dummy, &dummy);
  wind_get(0, WF_WORKXYWH, &scr_x, &scr_y, &scr_w, &scr_h);
  for (i=0; i<10; work_in[i++]=1);
  work_in[10] = 2;
  handle = phys_handle;
  v_opnvwk(work_in, &handle, work_out);

  /* set up screen mfdb
   */

  screen_mf.ptr = NULL;
  screen_mf.wpix = 640;
  screen_mf.hpix = 400;
  screen_mf.wwords = 40;
  screen_mf.format = 0;
  screen_mf.planes = 1;

  /*
   * now set up the system fonts
   */
  fontsavail = 0;
  if ((curfont = getmem((long)sizeof(FNT))) != NULL)
  {
#ifdef	MWC
    linea0();
    tmpfnt = la_init.li_a1[2]->font_data;	/* 8 x 16 system font */
#else
    asm("dc.w $a000");		/* get font addresses from line A */
    asm("move.l a1,a5");		/* put it into A5 */
    tmpfnt = a5[2]->ft_data;
#endif
    for (i=0; i<128; i++)
      for (j=0; j<16; j++)
        curfont->f_data[i*16+j] = tmpfnt[i+j*256];
    curfont->inc_x = 8;
    curfont->inc_y = 16;

    set_menu_string("8 x 16 sys font", fontmenuobj[fontsavail]);

    curfont->def_win_x = 80;	/* Set default window size */
    curfont->def_win_y = 24;

    gen_hash(curfont, &curfont->f_hash);

    fnttbl[fontsavail] = curfont;
    fontsavail++;
  }
  /* set up 6 x 6 system font */
  if ((curfont = getmem((long)sizeof(FNT))) != NULL)
  {
#ifdef	MWC
    linea0();
    tmpfnt = la_init.li_a1[0]->font_data;
#else
    asm("dc.w $a000");		/* get font addresses from line A */
    asm("move.l a1,a5");		/* put it into A5 */
    tmpfnt = a5[0]->ft_data;
#endif
    for (i=0; i<128; i++){ /* for each character (first 128) */
      int bitpos, index, offset;

      bitpos = i*6;
      index = bitpos >> 3;
      offset = bitpos & ~(~0<<3);
      for (j=0; j<6; j++) /* for each pixel row in character */
        curfont->f_data[i*16+j+1] = ((tmpfnt[index+j*192] << offset) +
	  (tmpfnt[index+j*192+1] >> (8-offset) & ~(~0<<offset)))>>2 & 63;
      curfont->f_data[i*16+0] = 0; /* extra empty row */
    }
    curfont->inc_x = 6;
    curfont->inc_y = 7;

    /*
     * The 6x6 system font can be made better.  (dot the i etc.)
     * This is a bad hack, but it makes it easier to read.
     */
    curfont->f_data[105*16+1] = 8;
    curfont->f_data[105*16+2] = 0;
    curfont->f_data[105*16+5] = 8;
    curfont->f_data[106*16+5] = 20;
    curfont->f_data[106*16+6] = 8;
    curfont->f_data[106*16+2] = 0;

    curfont->def_win_x = 80;	/* Set default window size */
    curfont->def_win_y = 40;

    set_menu_string("6 x 7 sys font", fontmenuobj[fontsavail]);
    gen_hash(curfont, &curfont->f_hash);

    fnttbl[fontsavail] = curfont;
    fontsavail++;
  }

  /*
   * Load font file(s) if any.
   */

  if (curfont = loadfont("windstd.fnt")) /* yes, I want the assignment (=). */
  {
    objc_change(menubar, fontmenuobj[fontsavail-1], 0, 0, 0, 0, 0, CHECKED, 0);
    curfont->def_win_x = 80;	/* Set default window size */
    curfont->def_win_y = 24;
  }
  else {
    objc_change(menubar, FNTSYS, 0, 0, 0, 0, 0, CHECKED, 0);
    curfont = fnttbl[fontsavail - 1];
  }

  if (tempfont = loadfont("windalt.fnt"))
  {
    tempfont->def_win_x = 80;	/* Set default window size */
    tempfont->def_win_y = 32;
  }

  if (tempfont = loadfont("windtny.fnt"))
  {
    tempfont->def_win_x = 80;	/* Set default window size */
    tempfont->def_win_y = 48;
  }
  if (tempfont = loadfont("windoth.fnt"))
  {
    tempfont->def_win_x = 80;	/* Set default window size */
    tempfont->def_win_y = 24;
  }
  
  /*
   * Disable unused font entrys.
   */
  for (i = fontsavail; fontmenuobj[i] != 0; i++)
  {
    set_menu_string("unavailable font", fontmenuobj[i]);
    objc_change(menubar, fontmenuobj[i], 0, 0, 0, 0, 0, DISABLED, 0);
  }
    

  /* set up the serial line (XON/XOFF flow control)
   */

  Rsconf(-1, 1, -1, -1, -1, -1);

  /* Initalize function keys to default values.
   */
  for (i=0; i<NFSTRINGS; i++)
  {
    sprintf(fstrings[i], "^A%d^M", i);
  }
  fstrings[NFSTRINGS-1][0] = '\0'; /* last function zero length for coding */

  /* Set up the key tables to use the help key for break.
   */
  oldshifted = ((struct keytbl *) Keytbl(-1L, -1L, -1L))->kt_shifted;
  oldnormal = ((struct keytbl *) Keytbl(-1L, -1L, -1L))->kt_normal;
  oldcapslock = ((struct keytbl *) Keytbl(-1L, -1L, -1L))->kt_capslock;

  for (i=0; i<128; i++) { /* copy bios tables */
    my_shft_map[i] = oldshifted[i];
    my_norm_map[i] = oldnormal[i];
  }

  my_shft_map[KC_HELP] = 0x6f; /* except help key */
  for (i=KC_F1; i<=KC_F10; i++) { /* and function keys */
    my_norm_map[i] = 0x6f;
  }
#ifdef COMMENT
  /*
   * These keys must be decoded manualy so that the field editing
   * of gem will not be impacted.
   */
  my_norm_map[KC_CDOWN] = 0x0a; /* and cursor motion keys (for adm31) */
  my_norm_map[KC_CLEFT] = 0x08;
  my_norm_map[KC_CRIGHT] = 0x0c;
  my_norm_map[KC_CUP] = 0x0b;
#endif
/* (void) Keytbl(my_norm_map, my_shft_map, my_norm_map); */
  (void) Keytbl(my_norm_map, my_shft_map, -1L);
  
  form_dial(FMD_START, 0, 0, 0, 0, scr_x, scr_y, scr_w, scr_h);
  form_dial(FMD_FINISH, 0, 0, 0, 0, scr_x, scr_y, scr_w, scr_h);
  
  /*
   * Read initial configuration file if any
   */
  read_config("", locate(confname));
}

finish()
{
int i;
struct iorec *ioptr;

  /* close all windows and clean up
   */

  if (uw_runs) xmitcmd(CB_FN_MAINT|CB_MF_EXIT);
  for (i=0; i<MAX_WIND; i++)
    w_close(i);
  (void) Keytbl(oldnormal, oldshifted, oldcapslock); /* restore key maps */

  if (old_iorec.io_bufsiz != 0) {
    ioptr = Iorec(0);	/* restore rs_232 io record */
    *ioptr = old_iorec;
  }

  menu_bar(menubar, 0);
  v_clsvwk(handle);
  appl_exit();
  exit();
}

memory()
{
long m = Malloc(-1L);

  sprintf(alert, "[0][Free memory: %ld bytes][Ok]", m);
  form_alert(1, alert);
}

main()
{
  long _stksiz = 4096l;		/* Tell Mark Williams C we need 4k stack */
  int	event;
  int	menuitem = 0;		/* Alt sequence mapped to menu item */
  int	cx, cy, cw, ch;
  int	mx, my, mb, mk;		/* mouse coordinates from event_multi */
  int	ww, wh;			/* window width & height for move */
  int	buttonstate = 2;	/* button state to wait for next. */
  int	clicks;			/* number of clicks seen by evnt_multi. */
  register int	cnt;
  int	funcindex = 0;
  int	regionflag = 0;		/* indicates region selection in progress */
  int	locked = 0;		/* keyboard and mouse locked with password ?*/
  startup();

  xsiz = curfont->def_win_x;
  ysiz = curfont->def_win_y;

init:
  w_open(1, "Terminal", xsiz, ysiz);
  outport = 1;
  inwind = outwind = find_wind(1);
  printer_mark(outwind);

  for (;;)
  {
    if (!mouse)
    {
      graf_mouse(M_ON, NULL);
      ++mouse;
    }
    if (menuitem)
    {
      event = MU_MESAG;
      msgbuff[0] = MN_SELECTED;
      msgbuff[4] = menuitem;
      menuitem = 0;
    }
    else
    {
      event = evnt_multi(MU_MESAG | MU_KEYBD | MU_TIMER | MU_BUTTON | MU_M1,
	2, 2, buttonstate,
	m1inout, scr_x, scr_y, scr_w, scr_h,
	0, 0, 0, 0, 0,
	msgbuff, 15, 0,
	&mx, &my, &mb, &mk,
	&key, &clicks);
    }

    if (event & MU_KEYBD)
    if (locked) {
      static char lockkey[LOCKLEN];
      static int lockindex;
      int keyval = key & 0xff;
      
      if (keyval == '\r') {
        lockkey[lockindex] = '\0';
        if (strcmp (lockkey, lockword) == 0) {
          graf_mouse(ARROW, &dummy);
          menu_bar(menubar, menonoff);
	  locked = 0;
	}
	lockindex = 0;
      }
      else 
        if (lockindex < LOCKLEN - 1)
          lockkey[lockindex++] = keyval;
    }
    else
    {
      int i, j;
      int outcount;
      int keyindex = key >> 8;
      int keyval = key & 0xff;
      int funcindex = NFSTRINGS;
      char outputstring[MAXFUNCLEN];

#ifdef DEBUG
      printf("keyindex = %x, keyval = %x\n", keyindex, keyval);
#endif

      /*
       * Decode key for function keys or other special keys
       * This section could be made faster at the expense of less clear
       * code.  It seems to be fast enough for now. (How fast can you type?)
       * It should probrably be table driven.
       */
      if (keyindex >= KC_F1 || (keyval == 0 
        && keyindex != 0x39 /* ctl-space */ && keyindex != 3 /* ctl-@ */))
      {	/* decode these keys manualy */
        if (keyindex >= KC_F1 && keyindex <= KC_F10) /* Unshifted F keys */
        {
	  if (keyval == 0x6f)	/* plain function key */
	    funcindex = keyindex - KC_F1;

	  else if (keyval == 0x0f)/* control function key */
	    funcindex = keyindex - KC_F1 + 10;

	  else if (keyval == 0)	/* alt function key */
	    funcindex = keyindex - KC_F1 + 30;
        }

        else if (keyindex >= KC_F1+25 && keyindex <= KC_F10+25) /* shift F */
          funcindex = keyindex - KC_F1 - 25 + 20;

	else if (key == (KC_CDOWN << 8))
	  keyval = 0x0a;

	else if (key == (KC_CLEFT << 8))
	  keyval = 0x08;

	else if (key == (KC_CRIGHT << 8))
	  keyval = 0x0c;

	else if (key == (KC_CUP << 8))
	  keyval = 0x0b;

        else if (key == 0x626f) /* break key (shift help) */
        {
          long	clk_time;
	
	  clk_time = clock();
	  Rsconf(-1, -1, -1, -1, 9, -1); /* set break condition */
	  while (clock() - clk_time < BREAK_TICKS); /* delay while break is sent */
	  Rsconf(-1, -1, -1, -1, 1, -1); /* clear break condition */
	  funcindex = NFSTRINGS - 1; /* last function key is zero length */
	}
	else if (keyval == 0)
	{	/* check if alt key used to select menu entry */
	  if (keyindex >= 0x78 && keyindex <= 0x7e)
	  {	/* alt number used to select window number */
	    int newwind = keyindex - 0x77;

	    if (find_port(newwind) > 0)
	      w_top(newwind);
	  }
	  else
	  {	/* alt key short-hand--fake menu message next time around */
	    menuitem = menu_key_map[oldnormal[keyindex] & 0x7f];
#ifdef DEBUG
	    printf("menu keyindex = %x, char = %c, menuitem = %d\n",
	      keyindex, oldnormal[keyindex], menuitem);
#endif
	  }
	  funcindex = NFSTRINGS - 1; /* last function key is zero length */
	}
      }
      if (funcindex < NFSTRINGS) /* if function key */
      {		/* copy function string to outputstring decoding ^ */
	j=0;
	outcount = 0;
        for (i=0; fstrings[funcindex][i] != '\0'; i++)
	{
	  outputstring[j] = fstrings[funcindex][i];
	  if (outputstring[j] == '^')
	  {
	    i++;
	    if (fstrings[funcindex][i] == '?')
	      outputstring[j] = '\177';
	    else if (fstrings[funcindex][i] != '^')
	      outputstring[j] = fstrings[funcindex][i] & 0x1f;
	  }
	  j++;
	}
	outcount = j;
      }
      else	/* normal key press */
      {
        outputstring[0] = keyval & 0x7f;
	outcount = 1;
      }
      /*
       * Now output outcount characters which are stored in outputstring.
       */
      proto_out(outport, outputstring, outcount);
    }

    if (event & MU_TIMER)
    {
      if (tick++ > 20)
      {
	w_flash(outwind, 2);
	tick = 0;
	if (kermwdes) kermtimchk();
      }
      /* act on any input from serial port */
      if (proto_in () < 0) goto init	/* uw mode ended? */;
    }

    if (event & MU_MESAG)
    {
      switch (msgbuff[0])
      {
      case MN_SELECTED:
	switch (msgbuff[4])
	{
	case REMSHELL:
	case SHELLOTH:
	case SHELL32:
	case SHELL24:
	case SHELL12:
	case SHELL8:
	  if (msgbuff[4] == REMSHELL)
	  {	/* default window size */
            xsiz = curfont->def_win_x;
	    ysiz = curfont->def_win_y;
	  }
	  else if (msgbuff[4] == SHELLOTH)
	  {
	    if (!size_dial()) break;
	  }
	  else
	  {	/* size specified in menu string */
	    char *ent_str;

	    ent_str = (char *) menubar[msgbuff[4]].ob_spec;
	    sscanf(ent_str, "%*s%d%*s%d", &ysiz, &xsiz);
	  }
	  if (uw_runs)
	  {
	    tmp = w_open(0, "Terminal", xsiz, ysiz);
	    if (tmp)
	    {
	      outport = tmp;
	      outwind = find_wind(tmp);
	      xmitcmd(CB_FN_NEWW|tmp);
	    }
	  } else
	  {
	    form_alert(1, "[1][UW is not running][Ok]");
	  }
	  break;

	case LOCCOPY:
	  for (cnt=1; cnt<MAX_WIND; cnt++)
	  {
	    if (!find_wind(cnt))
	    {
	      break;		/* a free port */
	    }
	  }
	  if (cnt < MAX_WIND)
	  {
	    static int c[8];
	    struct wi_str *wp1 = &w[outwind];
	    struct wi_str *wp2;
	    outport = w_open(cnt, "Local Copy", wp1->x_chrs, wp1->y_chrs);
	    outwind = find_wind(outport);
	    wp2 = &w[outwind];
	    c[0] = wp1->m_off;
	    c[1] = wp1->top_y;
	    c[2] = c[0] + wp1->wi_mf.wpix;
	    c[3] = c[1] + wp1->wi_mf.hpix;
	    c[4] = wp2->m_off;
	    c[5] = wp2->top_y;
	    c[6] = c[4] + wp2->wi_mf.wpix;
	    c[7] = c[5] + wp2->wi_mf.hpix;
	    vro_cpyfm(handle, FM_COPY, c, &wp1->wi_mf, &wp2->wi_mf);
	    wp2->w_local = TRUE;
	  }
	  break;

	case WINRESIZ:
	  if (!size_dial()) break;
	  w_resize(outwind, xsiz, ysiz);
	  break;

	case FQUIT:
	  finish();

	case FQUITUW:
	  if (uw_runs)
	  {
	  int i;
	    xmitcmd(CB_FN_MAINT|CB_MF_EXIT);
	    uw_runs = 0;
	    for (i=1; i<8; i++)
	    {
	      w_close(find_wind(i));
	    }
	    menu_tnormal(menubar, msgbuff[3], 1);
	    goto init;
	  }
	  break;

	case LOADCONF:
	  fsel_input(confpath, confname, &confbutt);
	  if (confbutt) 
	    read_config(confpath, confname);
	  break;

	case SAVECONF:
	  fsel_input(confpath, confname, &confbutt);
	  if (confbutt) 
	    write_config(confpath, confname);
	  break;

	case CAPTURE:
	  if (outwind)
	  {
	    WI_STR *wp = &w[outwind];

	    fsel_input(wp->wi_fpath, wp->wi_fname, &confbutt);
	    if (confbutt)
	      setcapture(wp);
	  }
	  break;

	case COMMAND:
	  do_exec();
	  break;

	case SETPATH:
	  do_path();
	  break;

	case KERMIT:
	  kerminit(outwind);
	  break;

	case FLOCKKEY:
	  s_dial(LOCKINFO, 1);
	  cnt = 0;
	  while ((key = evnt_keybd() & 0xff) != '\r') {
	    if (key == '\033') {	/* ESC means use old password */
	      locked = 1;
	      strcpy(lockbld, lockword);
	      break;
	    }
	    if (cnt < LOCKLEN - 1)
	      lockbld[cnt++] = key;
	  }
	  while (! locked) {
	    lockbld[cnt] = '\0';
	    locked = 1;
	    cnt = 0;
	    while ((key = (evnt_keybd() & 0xff)) != '\r')
	      if (cnt < LOCKLEN - 1)
	        if (key != lockbld[cnt++]) {
		  locked = 0;
		  lockbld[cnt - 1] = key;
		}
	    if (lockbld[cnt] != '\0')
	      locked = 0;
	  }
	  if (lockbld[0] == '\0')
	    locked = 0;
	  if (locked) {
	    strcpy(lockword, lockbld);
	    menu_bar(menubar, 0);
	    graf_mouse(USER_DEF, lckmform);
	  }
	  s_dial(LOCKINFO, 2);
	  break;

	case DABOUT:
	  if (s_dial(ABOUT, 3) == MOREINF1)
	  {
	    if (s_dial(INFO1, 3) == CONT1)
	    {	/* give short help screens */
	      if (s_dial(INFO2, 3) == CONT2)
	      {
	        if (s_dial(INFO3, 3) == CONT3)
	        {
	          if (s_dial(INFO4, 3) == CONT4)
	          {
		    s_dial(INFO5, 3);
	          }
	        }
	      }
	    }
	  }
	  break;

	case WRENAME:
	  CHECKWIN;
	  rsrc_gaddr(R_TREE, NEWNAME, &obj_tmp);
	  ted_tmp = (TEDINFO *) obj_tmp[FLD1].ob_spec;
	  strcpy(ted_tmp->te_ptext, w[outwind].name);
	  form_center(obj_tmp, &cx, &cy, &cw, &ch);
	  form_dial(FMD_START, 0, 0, 20, 10, cx, cy, cw, ch);
	  if (!fast) form_dial(FMD_GROW, 0, 0, 20, 10, cx, cy, cw, ch);
	  objc_draw(obj_tmp, 0, 5, cx, cy, cw, ch);
	  tmp = form_do(obj_tmp, FLD1);
	  if (!fast) form_dial(FMD_SHRINK, 0, 0, 20, 10, cx, cy, cw, ch);
	  form_dial(FMD_FINISH, 0, 0, 20, 10, cx, cy, cw, ch);
	  objc_change(obj_tmp, tmp, 0, cx, cy, cw, ch, NONE, 0);
	  if (tmp == OKRENAME) w_rename(outwind, (char *) ted_tmp->te_ptext);
	  break;

	case FUNCTKEY:
	  rsrc_gaddr(R_TREE, FUNCTEDT, &obj_tmp);
	  ted_fnum = (TEDINFO *) obj_tmp[FUNCNAME].ob_spec;
	  sprintf(ted_fnum->te_ptext, "%2d", funcindex+1);
	  ted_tmp = (TEDINFO *) obj_tmp[FUNCBODY].ob_spec;
	  strcpy((char *) ted_tmp->te_ptext, fstrings[funcindex]);
	  form_center(obj_tmp, &cx, &cy, &cw, &ch);
	  form_dial(FMD_START, 0, 0, 20, 10, cx, cy, cw, ch);
	  if (!fast) form_dial(FMD_GROW, 0, 0, 20, 10, cx, cy, cw, ch);
	  objc_draw(obj_tmp, 0, 5, cx, cy, cw, ch);
	  tmp = 0;
	  while (tmp != FUNCEXIT)
	  {
	    int i;
	    
	    tmp = form_do(obj_tmp, FUNCNAME);
	    switch (tmp)
	    {
	    case FUNCSHOW:
	      funcindex = atoi(ted_fnum->te_ptext) - 1;
	      if (funcindex < 0)
	        funcindex = NFSTRINGS - 3;
	      else if (funcindex > NFSTRINGS - 3)
	        funcindex = 0;
	      strcpy((char *) ted_tmp->te_ptext, fstrings[funcindex]);
	      objc_draw(obj_tmp, FUNCBODY, 5, cx, cy, cw, ch);
	      sprintf(ted_fnum->te_ptext, "%2d", funcindex+1);
	      objc_draw(obj_tmp, FUNCNAME, 5, cx, cy, cw, ch);
	      break;
	    case FUNCPREV:
	      funcindex --;
	      if (funcindex < 0)
	        funcindex = NFSTRINGS - 3;
	      sprintf(ted_fnum->te_ptext, "%2d", funcindex+1);
	      objc_draw(obj_tmp, FUNCNAME, 5, cx, cy, cw, ch);
	      strcpy((char *) ted_tmp->te_ptext, fstrings[funcindex]);
	      objc_draw(obj_tmp, FUNCBODY, 5, cx, cy, cw, ch);
	      break;
	    case FUNCNEXT:
	      funcindex ++;
	      if (funcindex > NFSTRINGS - 3)
	        funcindex = 0;
	      sprintf(ted_fnum->te_ptext, "%2d", funcindex+1);
	      objc_draw(obj_tmp, FUNCNAME, 5, cx, cy, cw, ch);
	      strcpy((char *) ted_tmp->te_ptext, fstrings[funcindex]);
	      objc_draw(obj_tmp, FUNCBODY, 5, cx, cy, cw, ch);
	      break;
	    case FUNCENT:
	      funcindex = atoi(ted_fnum->te_ptext) - 1;
	      strcpy(fstrings[funcindex], ted_tmp->te_ptext);
	      fstrings[funcindex][i] = ted_tmp->te_ptext[i];
	      strcpy((char *) ted_tmp->te_ptext, fstrings[funcindex]);
	      objc_draw(obj_tmp, FUNCBODY, 5, cx, cy, cw, ch);
	      break;
	    }
	    objc_change(obj_tmp, tmp, 0, cx, cy, cw, ch, NONE, 1);
	  }
	  if (!fast) form_dial(FMD_SHRINK, 0, 0, 20, 10, cx, cy, cw, ch);
	  form_dial(FMD_FINISH, 0, 0, 20, 10, cx, cy, cw, ch);
	  objc_change(obj_tmp, tmp, 0, cx, cy, cw, ch, NONE, 0);
	  break;

	case MFREE:
	  memory();
	  break;

	case MFAST:
	  menu_icheck(menubar, MFAST, fast);
	  fast = !fast;
	  break;

	case OVERSTRI:
	  overstrike = !overstrike;
	  menu_icheck(menubar, OVERSTRI, overstrike);
	  break;

	case FNTSYS:
	case FNTOWN:
	case FNTALT:
	case FNTBIG:
	case FNTTINY:
	case FNTUNKNW:
	/* Add new font menu items here! */
	  for (cnt = 0; fontmenuobj[cnt] != 0; cnt++)
	  {
	    if (fontmenuobj[cnt] != msgbuff[4])
	    {
	      if (cnt < fontsavail)
	        objc_change(menubar, fontmenuobj[cnt], 0, 0, 0, 0, 0,
		  NONE, 0);
	      else
	        objc_change(menubar, fontmenuobj[cnt], 0, 0, 0, 0, 0,
		  DISABLED, 0);
	    }
	    else
	      curfont = fnttbl[cnt];
	  }
	  objc_change(menubar, msgbuff[4], 0, 0, 0, 0, 0, CHECKED, 0);
	  break;

	case PRTBOTOM:
	  if (outwind)
	  {
	    w[outwind].ptr_status = LOG_BOTOM;
	    printer_mark(outwind);
	    w_rename(outwind, NULL);
	  }
	  break;

	case PRTTOP:
	  if (outwind)
	  {
	    w[outwind].ptr_status = LOG_TOP;
	    printer_mark(outwind);
	    w_rename(outwind, NULL);
	  }
	  break;

	case PRTWIND:
	  if (outwind)
	  {
	    printer_mark(outwind);
	    dump_window(outwind);
	  }
	  break;

	case PRTSTOP:
	  if (outwind)
	  {
	    w[outwind].ptr_status = LOG_NONE;
	    printer_mark(outwind);
	    w_rename(outwind, NULL);
	  }
	  break;

	case INPUTWIN:
	case PASTE:
	  sel_inp_mode = msgbuff[4];
	  graf_mouse(USER_DEF, rmbmform);
	  break;

	case RESETAUX:
	  if (rs232_reset())
	    Cauxout(0x11);	/* send XOFF	*/
	  break;

	case ASSRD:		/* Assert RTS/DTR. */
		Offgibit(~0x18);
		break;

	case RESRD:		/* Reset RTS/DTR. */
		Ongibit(0x18);
		break;

	case AUDIBELL:
	  audibell = !audibell;
	  objc_change(menubar, AUDIBELL, 0, 0, 0, 0, 0,
	    audibell? CHECKED: 0, 0);
	  break;

	case VISIBELL:
	  visibell = !visibell;
	  objc_change(menubar, VISIBELL, 0, 0, 0, 0, 0,
	    visibell? CHECKED: 0, 0);
	  break;

	case TOPONBEL:
	  toponbel = !toponbel;
	  objc_change(menubar, TOPONBEL, 0, 0, 0, 0, 0,
	    toponbel? CHECKED: 0, 0);
	  break;
	  
	case SHRNKWIN:	/* Shrink window to iconic size */
	  if (outwind)
	  {
	    outwind = w_shrink(outwind);
	    outport = find_port(outwind);
	  }
	  break;

	case BOTTOMTO:	/* send bottom window to top */
	  w_bottom();
	  break;

	case WINSTYLE:	/* enable/disable sliders and arrows for new windows */
	  sliders = !sliders;
	  menu_icheck(menubar, WINSTYLE, sliders);
	  break;

	case HIDEWIN:	/* send top window to bottom */
	  if (outwind = w_hide())
	  {
	    outport = find_port(outwind);
	    printer_mark(outwind);
	  }
	  break;

	case MOVEWIN:
	  if (outwind)
	  {
	    graf_mouse(POINT_HAND, &dummy);
	    evnt_button(1, 1, 1, &mx, &my, &dummy, &dummy);
	    wind_get(outwind, WF_CURRXYWH, &dummy, &dummy, &ww, &wh);
	    if (graf_dragbox(ww, wh, mx, my,
	      scr_x, scr_y, scr_w + ww, scr_h + wh, &mx, &my))
	        w_move(outwind, mx, my, ww, wh);
	    graf_mouse(sel_inp_mode? USER_DEF: ARROW, rmbmform);
	  }
	  break;

	case OSIZEWIN:
	  if (outwind)
	  {
	    outwind = w_full(outwind);
	    outport = find_port(outwind);
	  }
	  break;

	case CLOSEWIN:
	  if (outwind = proto_close(outwind))
	  {
	    printer_mark(outwind);
	    outport = find_port(outwind);
	  }
	  if (!uw_runs && !find_wind(1))
	  {
	    menu_tnormal(menubar, msgbuff[3], 1);
	    goto init;
	  }
	  break;

	case WINTITLE:	/* enable/disable window headers */
	  titles = !titles;
	  menu_icheck(menubar, WINTITLE, titles);
	  break;

	case SETCONF:	/* set rs232 port configuration */
	  getrsconf();
	  if (s_dial(RSCONF, 3) == RCOK)
	    setrsconf();
	  break;

	case WINCLEAR:	/* clear current window */
	  if (outwind)
	  {
	    w[outwind].ptr_status = LOG_NONE;
	    w_output(outwind, "\032");
	  }
	  break;
	}
	menu_tnormal(menubar, msgbuff[3], 1);
	break;

      case WM_NEWTOP:
      case WM_TOPPED:
	if (!locked)
	  w_top(msgbuff[3]);
	break;

      case WM_SIZED:
      case WM_MOVED:
	if (!locked)
	  w_move(msgbuff[3], msgbuff[4], msgbuff[5], msgbuff[6], msgbuff[7]);
	break;

      case WM_CLOSED:
        if (locked) break;
	if (cnt = proto_close(msgbuff[3]))
	{
	  if (msgbuff[3] == outwind)	/* was keyboard input window closed? */
	    outwind = cnt;
	  printer_mark(outwind);
	  outport = find_port(outwind);
	}
	if (!uw_runs && !find_wind(1))
	{
	  goto init;
	}
	break;

      case WM_REDRAW:
        if (highlighted_wdes == msgbuff[3])
	{	/* this window has highlighted text, redraw all of window*/
	  register struct wi_str *wp = &w[msgbuff[3]];
	  w_redraw(msgbuff[3], FM_COPY, wp->x, wp->y, wp->w, wp->h);
	}
	else
	  /* redraw only damaged part */
	  w_redraw(msgbuff[3], FM_COPY, msgbuff[4], msgbuff[5], msgbuff[6], msgbuff[7]);
	break;

      case WM_FULLED:
	if (locked) break;
	outwind = w_full(msgbuff[3]);
	outport = find_port(outwind);
	break;

      case WM_ARROWED:
	if (!locked)
	  w_arrow(msgbuff[3], msgbuff[4]);
	break;

      case WM_HSLID:
      case WM_VSLID:
	if (!locked)
	  w_slide(msgbuff[3], msgbuff[0] == WM_HSLID, msgbuff[4]);
	break;
      }
    }
    if ((event & MU_BUTTON) && ! locked)
    {
      if (sel_inp_mode && buttonstate) /* select input mode and button down */
      {
        int found;

	graf_mouse(ARROW, &dummy);
	if ((found = wind_find(mx, my)) != 0) {
	  outwind = found;
	  outport = find_port(outwind);
	  if (sel_inp_mode == PASTE)
	      proto_out(outport, pastebuff, strlen(pastebuff));
	}
	evnt_button(1, 2, 0, &dummy, &dummy, &dummy, &dummy);
	buttonstate = 0;
	sel_inp_mode = FALSE;
      }
      else if (my < scr_y)	/* is mouse on menu bar? */
      {	/* yes, disable menu bar if button down */
        if (buttonstate)
	{
          objc_change(menubar, DESK, 0, 0, 0, 0, 0,
            menonoff? DISABLED: NORMAL, menonoff);
          menu_bar(menubar, menonoff = !menonoff);
	  if (menonoff)
	    graf_mouse(ARROW, &dummy);
	  else
	    graf_mouse(USER_DEF, rmbmform);
	  evnt_button(1, 2, 0, &dummy, &dummy, &dummy, &dummy);
	  buttonstate = 0;
	}
      }
      else	/* button click in work area */
      {	/* handle text selection or output or mouse packet */
        int found, found1, x1, y1, x2, y2, w_x, w_y, w_w, w_h;

	if ((found = wind_find(mx, my)) != 0)
	{
	  wind_get(found, WF_WORKXYWH, &w_x, &w_y, &w_w, &w_h);
	  if (mx >= w_x && mx < w_x + w_w && my >= w_y && my <w_y + w_h)
	  { /* in window, fill paste buffer */
	    if (clicks > 1 && buttonstate)
	    {
	      y1 = (my - w_y - Y0) / w[found].font->inc_y;
	      copy_text(found, 0, y1, w[found].x_chrs - 1, y1, pastebuff);
	      evnt_button(3, 2, 0, &dummy, &dummy, &dummy, &dummy);
	      regionflag = 0;
	    }
	    else if (buttonstate)	/* if button down */
	    {
	      x1 = (mx - w_x - X0) / w[found].font->inc_x;
	      y1 = (my - w_y - Y0) / w[found].font->inc_y;
	      regionflag = 1;
	      found1 = found;
	    }
	    else if (regionflag && found == found1)
	    {	/* button up */
	      x2 = (mx - w_x - X0) / w[found].font->inc_x;
	      y2 = (my - w_y - Y0) / w[found].font->inc_y;
	      if (y2 == y1 && x2 == x1)
	      {	 /* simple click on char; select word */
	        copy_word(found, x1, y1, pastebuff);
	      }
	      else if (y2 > y1 || (y2 == y1 && x2 > x1))
	        copy_text(found, x1, y1, x2-1, y2, pastebuff);
	      else
		copy_text(found, x2+1, y2, x1, y1, pastebuff);
	    }
	  }
	  else
	  { /* in border */
	    /* send paste buffer and select keyboard window*/
	    if (buttonstate)	/* if button down */
	    {
	      char * pptr = pastebuff;
	      outwind = found;
	      outport = find_port(outwind);
	      if (clicks > 1)
	          proto_out(outport, pptr, strlen(pptr));
	    }
	    regionflag = 0;
	  }
	}
	else
	{	/* not in window or border */
		/* clear paste buffer and erase any current marks */
	  pastebuff[0] = '\0';
	  regionflag = 0;
	  copy_text(1, 1, 1, 0, 0, pastebuff);
	}
      }
      buttonstate = buttonstate? 0: 2;	/* toggle buttonstate */
    }
    if (event & MU_M1)	/* mouse moved into or out of work area */
    {
      if (!sel_inp_mode && !menonoff && !locked)
	graf_mouse(m1inout? USER_DEF: ARROW, rmbmform);
      m1inout = ! m1inout;
    }
  }
}
/*
 * printer_mark(wnd) places check marks in the apropriate places in the
 * printer menu.
 */
printer_mark (wnd)
{
    objc_change(menubar, PRTBOTOM, 0, 0, 0, 0, 0,
      (w[wnd].ptr_status & LOG_BOTOM)? CHECKED: NONE, 0);

    objc_change(menubar, PRTTOP, 0, 0, 0, 0, 0,
      (w[wnd].ptr_status & LOG_TOP)? CHECKED: NONE, 0);
}

/*
 * s_dial performs a simple dialog with buttons and text only.
 * The index of the terminating button is returned.
 * If action == 1, the dialog is displayed.  If action == 2, it is
 * removed.  If action == 3, both operations are done and form_do is
 * called.
 */
int s_dial(tree, action)
int tree, action;
{
  int tmp = 0;
  int cx, cy, cw, ch;
  OBJECT *obj_tmp;

  rsrc_gaddr(R_TREE, tree, &obj_tmp);
  form_center(obj_tmp, &cx, &cy, &cw, &ch);
  if (action & 1) {
    form_dial(FMD_START, 0, 0, 20, 10, cx, cy, cw, ch);
    if (!fast) form_dial(FMD_GROW, 0, 0, 20, 10, cx, cy, cw, ch);
    objc_draw(obj_tmp, 0, 5, cx, cy, cw, ch);
  }
  if (action == 3) {
    tmp = form_do(obj_tmp, 0);
  }
  if (action & 2) {
    if (!fast) form_dial(FMD_SHRINK, 0, 0, 20, 10, cx, cy, cw, ch);
    form_dial(FMD_FINISH, 0, 0, 20, 10, cx, cy, cw, ch);
    objc_change(obj_tmp, tmp, 0, cx, cy, cw, ch, NONE, 0);
  }
    return (tmp);
}

/*
 * set_menu_string sets the menu string for the specified menu object to
 * newstr.
 */
set_menu_string(newstr, object)
register char * newstr;
int object;
{
  register char * oldstr;

  oldstr = (char *) menubar[object].ob_spec + 2;
  while (*oldstr && *newstr)
    *oldstr++ = *newstr++;
  if (*oldstr)
  	*oldstr = ' ';
}

size_dial()
{
  /*
   * Enter rows and columns dialog
   */
  int cx, cy, cw, ch;
  char *rowstr, *colstr;
  rsrc_gaddr(R_TREE, WINDSIZE, &obj_tmp);
  ted_tmp = (TEDINFO *) obj_tmp[WINDROWS].ob_spec;
  rowstr = ((char *)ted_tmp->te_ptext);
  if (atoi(rowstr) < 2)
    strcpy (rowstr, "24");
  ted_tmp = (TEDINFO *) obj_tmp[WINDCOLS].ob_spec;
  colstr = ((char *)ted_tmp->te_ptext);
  if (atoi(colstr) < 2)
    strcpy (colstr, "80");
  form_center(obj_tmp, &cx, &cy, &cw, &ch);
  form_dial(FMD_START, 0, 0, 20, 10, cx, cy, cw, ch);
  if (!fast)
    form_dial(FMD_GROW, 0, 0, 20, 10, cx, cy, cw, ch);
  objc_draw(obj_tmp, 0, 5, cx, cy, cw, ch);
  tmp = form_do(obj_tmp, WINDROWS);
  if (!fast)
    form_dial(FMD_SHRINK, 0, 0, 20, 10, cx, cy, cw, ch);
  form_dial(FMD_FINISH, 0, 0, 20, 10, cx, cy, cw, ch);
  objc_change(obj_tmp, tmp, 0, cx, cy, cw, ch, NONE, 0);
  if (tmp == WINDCANC)
    return(FALSE);
  xsiz = atoi(colstr);
  ysiz = atoi(rowstr);
  if (xsiz < 2)
    xsiz = 2;
  if (xsiz > 300)
    xsiz = 300;
  if (ysiz < 2)
    ysiz = 2;
  if (ysiz > 300)
    ysiz = 300;
  return (TRUE);
}
