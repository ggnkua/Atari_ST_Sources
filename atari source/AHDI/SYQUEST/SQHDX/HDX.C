/* hdx.c */

/*
 * Atari Hard Disk Installation Utility
 * Copyright 1988 Atari Corp.
 *
 * Associated files
 *	hdx.rsc		resource file
 *	wincap		hard disk database (text file)
 *
 *	hdx.h		object tree definitions
 *	defs.h		constant definitions
 *	part.h		structure definitions
 *
 *	hdx.c		top level, user interface (this file)
 *	epart.c		edit partition sizes
 *	fmt.c		disk formatting
 *	part.c		partition reading/writing
 *	sect.c		sector reading, writing, zeroing
 *	string.c	string functions (matching, concat, ...)
 *	assist.c	markbad(), zero()
 *	wincap.c	hard disk parameter / partition size database
 *	st.c		random ST functions (delay, reboot, ...)
 *
 *----
 * 11-May-1988	ml.	Cleaned up the memory management in the program
 *			(ie. for all files).  Memory chunks which are for
 *			sure will be < 32k is allocated using malloc(),
 *			whereas chunks >= 32k is allocated using Malloc().
 *			When using malloc(), you will get the 'Stack Over-
 *			flow message if you are in Supervisor mode and 
 *			you have your own supervisor stack.  To get around
 *			this, have to use mymalloc() (in mymalloc.s).
 * 15-Mar-1988	ml.	Changed interface to Markbad.
 * 11-Jan-1988	ml.	Modified dialogue boxes.
 * 07-Dec-1987	ml.	Started to add in concept of Bad Sector List.
 * ??-Oct-1987  ml.	Partition and Disk type menu now has 15 entries 
 *			instead of 16.
 * 30-Sep-1987	ml.	Inherited 'this' from Landon Dyer.
 * 24-Mar-1986 lmd	Released to software test.
 * 15-Mar-1986 lmd	Hacked up from earlier version by Jim Tittsler.
 *
 */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "defs.h"
#include "part.h"
#include "bsl.h"
#include "hdx.h"
#include "addr.h"
#include "error.h"


/* Globals */
int rebootp = 0;	/* 1: must reboot (not return to desktop) */
int format;		/* TRUE: just formatted disk */
int running;		/* 1: continue evnt_multi() loop */
char sbuf[512];		/* error message buffer */

long ostack;				/* old stack pointer */

extern long bslsiz;
extern BYTE *bsl;

/*  Logical-to-dev+partition mapping table. */
extern int nlogdevs;		/* #logical devs found */
extern LOGMAP logmap[];		/* logical dev map */
extern int livedevs[];		/* live physical dev flag */

/* Partition related variables */
long maxpsiz = MAXPSIZ;	/* maximum partition size */

/* AES (windows and messages) related variables */
int gl_hchar;		/* height of system font (pixels) */
int gl_wchar;		/* width of system font (pixels) */
int gl_wbox;		/* width of box able to hold system font */
int gl_hbox;		/* height of box able to hold system font */

int phys_handle;	/* physical workstation handle */
int handle;		/* virtual workstation handle */
int wi_handle;		/* window handle */

int formw, formh, sx, sy, lx, ly;	/* dialogue box dimensions */
int xdesk, ydesk, hdesk, wdesk;		/* window X, Y, width, height */
int xwork, ywork, hwork, wwork;		/* desktop and work areas */

int msgbuff[8];		/* event message buffer */
int keycode;		/* keycode returned by event-keyboard */
int mx, my;		/* mouse x and y pos. */
int butdown;		/* button state tested for, UP/DOWN */
int ret;		/* dummy return variable */

int hidden;		/* current state of cursor */

int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];	/* storage wasted for idiotic bindings */

int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */



/*
 * Top level;
 * we get control from the desktop.
 */
main()
{
    running = TRUE;
    appl_init();
    phys_handle=graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
    wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
    open_vwork();
    wi_handle=wind_create(WI_KIND, xdesk, ydesk, wdesk, hdesk);

    hidden = FALSE;
    butdown = TRUE;

    if (!rsrc_load(RESOURCEFILE)) {
	errs("[2][|", RESOURCEFILE, "][ EXIT ]");
	goto punt;
    }
    
    /* Get all addresses of dialogues from resource file */
    if (getalladdr() != OK) {
	errs("[2][|", RESOURCEFILE, "][ EXIT ]");
	goto punt;
    }

    /*
     * Get maximum partition size from
     * wincap "@@" entry.
     */
    if (wgetent("Parameters", "@@") == OK) {
	if (wgetnum("ms", &maxpsiz) != OK)
	    maxpsiz = MAXPSIZ;
    } else {
    	goto punt;
    }

    ARROW_MOUSE;

    /* display menu bar */
    menu_bar(menuobj, 1);

    while (running) {
    	domulti();
    }

    /*
     * If nothing has been done to the hard disks
     * then just get out, back to the desktop.
     * Otherwise reboot the system.
     */
    menu_bar(menuobj, 0);		/* erase menu bar */

punt:
    /*
     * If we have to reboot,
     * tell the user and then do it.
     *
     */
    if (rebootp) {
	err(autoboot);
	reboot();
    }

    wind_delete(wi_handle);
    v_clsvwk(handle);
    appl_exit();
}


/*
 * Get a single event, process it, and return.
 *
 */
domulti(){
    int event;
    
    event = evnt_multi(MU_MESAG,
			1,1,butdown,
			0,0,0,0,0,
			0,0,0,0,0,
			msgbuff,0,0,&mx,&my,&ret,&ret,&keycode,&ret);

    if (event & MU_MESAG) {
    	wind_update(TRUE);
	switch (msgbuff[0]) {
	    case WM_REDRAW:
		do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
		break;

	    case MN_SELECTED:
	        BEE_MOUSE;
		switch(msgbuff[3]) {
		    case MNDISK:
		        rescan(0);	/* don't report medium changed */
			switch (msgbuff[4]) {
			    case DIFORM:
			        format = TRUE;
			        dodiform();
			        format = FALSE;
			        break;
			    case DIPART:
			        dodipart(-1, NULL, NULL);
			    	break;
			    case DIZERO:
			        dodizero();
			        break;
			    case DIMARK:
			        dodimark();
			        break;
			    case DISHIP:
			        dodiship();
			        break;
			    default:	    break;
			}
			break;

		    case MNFILE:
			switch (msgbuff[4]) {
			    case FIQUIT:
				running = 0;
				break;

			    default:
				break;
			}
			break;
			
		    case MNDESK:
			if(msgbuff[4] == DEABOUT) {
			    strcpy(abtdial[ABVERSN].ob_spec, "Version 3.0a");
			    abtdial[ABOK].ob_state = NORMAL;
			    execform(abtdial);
			}
			break;		/* "cannot happen" */
		}

		menu_tnormal(menuobj, msgbuff[3], 1);	/* back to normal */
	        ARROW_MOUSE;
		break;
		
	    case WM_NEWTOP:
	    case WM_TOPPED:
		wind_set(wi_handle, WF_TOP, 0, 0, 0, 0);
		break;

	    case WM_CLOSED:
		running = FALSE;
		break;

	    default:
		break;
	}
	wind_update(FALSE);
    }
}


/*
 * Default partition name (no "pt" entry).
 */
#define	DEF_PARTNAME	"4-6-10"


/*
 * Map from button in format dial.
 */
int pfmt[] = {
    PFMT0, PFMT1, PFMT2, PFMT3,
    PFMT4, PFMT5, PFMT6, PFMT7,
    PFMT8, PFMT9, PFMT10, PFMT11,
    PFMT12, PFMT13, PFMT14
};


/*
 * Handle [FORMAT] item.
 *
 */
dodiform()
{
  extern long get3bytes();
  extern char bootstop;
  extern char bootend;
  int dev, v, i;
  int modesel;			/* flag for mode select */
  long cnt, hdsiz;
  char *s, *d, *wgetstr();
  char bs[512], sendata[16];
  char pnam[128];
  char *seldev = "X";
  HINFO hinfo;
  char devnames[NAMSIZ];	/* device type name buffer */
  long nbad;
  extern long gbslsiz(), nument(), dsmarkbad();
  long pattern, temp;
  long longrandom();
  char pr_id[2];	/* partition scheme id */
  
  /*
   * Throw up generic formatting/partition warning,
   * then get physical dev they want to clobber.
   */
  fwarning[FWARNCN].ob_state = NORMAL;
  fwarning[FWARNOK].ob_state = NORMAL;
  if (execform(fwarning) != FWARNOK) return BAILOUT;

  if ((dev = gphysdev()) < 0) {
      return BAILOUT;
  }
  
  /* Get all available disk types from wincap 'mn' entries */  
  wallents(devnames, "mn");
  
  /* Shove format name text into buttons */
  for (i = 0, s = devnames; i < 15 && *s; ++i) {
      dsknames[pfmt[i]].ob_type = G_BUTTON;	/* invisible box */
      dsknames[pfmt[i]].ob_spec = (long)s;
      dsknames[pfmt[i]].ob_state = NORMAL;
      dsknames[pfmt[i]].ob_flags = SELECTABLE | RBUTTON;
      while (*s++)
	;
  }
  
  /* rest of buttons are invisible and untouchable */
  for (; i < 15; ++i) {
      dsknames[pfmt[i]].ob_type = G_IBOX;	/* invisible box */
      dsknames[pfmt[i]].ob_spec = 0;		/* no thickness */
      dsknames[pfmt[i]].ob_state = DISABLED;	/* nobody home */
      dsknames[pfmt[i]].ob_flags = NONE;		/* disabled */
  }
  
  /* clean up rest of the form and throw it up */
  dsknames[PFOK].ob_state = NORMAL;
  dsknames[PFCN].ob_state = NORMAL;
  if (execform(dsknames) != PFOK)
    return BAILOUT;
  
  /* search for format they picked */
  for (i = 0; i < 15; ++i)
    if (dsknames[pfmt[i]].ob_state & SELECTED)
      break;
  if (i >= 15) {		/* nothing picked */
      return BAILOUT;
  }
  
  modesel = 1;
  if (gfparm(&modesel, &hinfo, dsknames[pfmt[i]].ob_spec) != 0) {
      return ERROR;
  }
  
  /* get data pattern to test the disk */
  if (wgetnum("dp", &pattern) != OK) {
      pattern = longrandom();  /* can't find pattern from wincap, make one */
  } else {
      temp = pattern;
      pattern <<= 16;	/* shift pattern to hi word */
      pattern |= temp;
  }
  
  /*
   * One last chance to bail out.
   */
  *seldev = dev + '0';
  (fmtfnl[FUNIT].ob_spec)->te_ptext = seldev;
  fmtfnl[FMTYES].ob_state = NORMAL;
  fmtfnl[FMTNO].ob_state = NORMAL;
  if (execform(fmtfnl) != FMTYES) return BAILOUT;

  /* For REAL !! */  
  dsplymsg(fmtmsg);

  bsl = 0L;
  
  /* Get size of Bad Sector List */
  if ((bslsiz = gbslsiz(dev)) > 0L) {
      /* Allocate memory for existing BSL */
      if ((bsl = (BYTE *)mymalloc((int)bslsiz*512)) <= 0) {
          ret = err(nomemory);
          goto formend;
      }
      
      /* Read in BSL */
      if ((ret = rdbsl(dev)) != OK) {
          /* Create a new BSL if current one is unusable */
	  if (creabsl(dev, NEW, 0L) != OK) {
	      ret = ERROR;
	      goto formend;
	  }
      } else {
      	  /* Remove USER BSL */
      	  if (creabsl(dev, EXPAND, nument(VENDOR)) != OK) {
      	      ret = ERROR;
      	      goto formend;
      	  }
      }
  } else if (bslsiz == 0L || bslsiz == ERROR) {	/* no bsl or read error */
      if (creabsl(dev, NEW, 0L) != OK) {
          ret = ERROR;
          goto formend;
      }
  } else {	/* bslsiz == MDMERR; medium changed error */
      ret = ERROR;
      goto formend;
  }
  
  /*
   * In supervisor mode
   * set disk format parameters
   * and format the disk.
   */
  ostack = Super(NULL);
  ret = md_sense(dev, sendata);
  v = OK;				    /* assume everything is OK */
  if (modesel)
      v = ms(dev, &hinfo);		    /* mode set */
  /*
  delay();				    /* kludge delay */
  if (v == OK)
    v = doformat(dev, (UWORD)hinfo.hi_in);  /* format /**/
  delay();				    /* kludge delay */
  Super(ostack);
  
  if (v != 0) {
      ret = errcode(dev);
      if (tsterr(ret) != OK)
          formaterr(dev);
      ret = ERROR;
      goto formend;
  }
  
  /* Find formatted capacity of drive */
  if (modesel) {
      hdsiz = (long)hinfo.hi_cc * (long)hinfo.hi_dhc * (long)hinfo.hi_spt;
  } else {
      /* Do a mode sense to find out size of disk */
      ostack = Super(NULL);
      ret = md_sense(dev, sendata);
      delay();
      Super(ostack);
      if (ret != 0) {
          ret = formaterr(dev);
          goto formend;
      }
      hdsiz = get3bytes(sendata+5);
  }
  
  ret = OK;
  rebootp = 1;
formend:
  erasemsg();	/* Erase formatting box */
  if (ret < 0) {
      if (bsl > 0) free(bsl);
      return ERROR;
  }
  
  /*------------------------------------------*
   * Markbad the device destructively.	      *
   * Bad Sectors found are added to the BSL.  *
   * Write BSL to device.		      *
   *------------------------------------------*/
  if ((nbad = dsmarkbad(dev, hdsiz, 1, pattern)) < 0) {
      free(bsl);
      return ERROR;
  }
      
  if (wrbsl(dev) != OK) {
      free(bsl);
      return ERROR;
  }
  free(bsl);

    
  /*
   * Install boot-stopper in sector image;
   * write root sector to device.
   * 6-13-88  Setting of soft format parameters in root sector sets
   *		the hard disk size only.
   */
  fillbuf(bs, 512L, 0L);	/* create new root sector */
  sbslparm(bs);			/* set BSL parameters */
  sfmtparm(bs, hdsiz);
  for (d = bs, s = &bootstop, cnt = &bootend - &bootstop; --cnt;)
    *d++ = *s++;
  Protobt(bs, -1L, -1, 1);	/* make root sector executable */
  
  if ((ret = putroot(dev, bs)) != OK) {
      if (tsterr(ret) != OK)
	  err(rootwrit);
      return ERROR;
  }

  /*
   * Make a copy of the default partition name.
   * Figure out the partition scheme id.
   */
  if ((s = wgetstr("pt")) == NULL)
    s = DEF_PARTNAME;
  strcpy(pnam, s);
  figprid(((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz, pr_id);
  dodipart(dev, pnam, pr_id);
  return OK;
}



/*
 * Handle [PARTITION] item;
 * if `xdev' is -1, throw up dialog boxes;
 * if `xdev' >= 0, just partition the dev,
 * using `pnam' as the partition type, 
 * and `pr_id' to search for the type.
 *
 */
dodipart(xdev, pnam, pr_id)
int xdev;
char *pnam;
char *pr_id;
{
    int dev, i, ret =OK, fine;
    char *seldev = "X";
    char *s;
    char bs[512];
    PART pinfo[4];
    extern long gbslsiz();

    if (xdev < 0) {
	/*
	 * Throw up warning saying that partition is dangerous;
	 * then get physical dev they want to clobber.
	 */
	pwarning[PWARNCN].ob_state = NORMAL;
	pwarning[PWARNOK].ob_state = NORMAL;
	if (execform(pwarning) != PWARNOK) return BAILOUT;
	format = FALSE;
	if ((dev = gphysdev()) < 0) {
	    return BAILOUT;
	}

	/*
	 * Let the user edit/pick partitions.
	 */
	fine = 0;
	while (!fine) {
	    if (figpart(dev, pinfo) != OK)
	        return BAILOUT;
	    if ((ret = chkpart(dev, pinfo)) != OK) {
	    	if (ret < 0)
	    	    err(nexsmem);
	    	else return BAILOUT;
	    } else {
	        fine = 1;
	    }
	}

	/* Last chance to bail out */
	*seldev = dev + '0';
	(partfnl[PUNIT].ob_spec)->te_ptext = seldev;
	partfnl[PARTYES].ob_state = NORMAL;
	partfnl[PARTNO].ob_state = NORMAL;
	if (execform(partfnl) != PARTYES)
	    return BAILOUT;

    } else {
	if (wgetent(pnam, pr_id) != OK) {
	    nopart[NOSCHPOK].ob_state = NORMAL;
	    (nopart[NOSCHPR].ob_spec)->te_ptext = pnam;
	    execform(nopart);
	    return ERROR;
	}

	dev = xdev;
	for (i = 0; i < 4; ++i)
	    fillpart(i, &pinfo[i]);
    }

    /* For REAL!! */
    dsplymsg(partmsg);
    
    bsl = 0L;
    
    /* Get size of BSL */
    if ((bslsiz = gbslsiz(dev)) > 0L) {
    	/* Allocate memory for existing BSL */
    	if ((bsl = (BYTE *)mymalloc((int)bslsiz*512)) <= 0) {
    	    ret = err(nomemory);
    	    goto partend;
    	}
    	    
    	/* Read in BSL */
    	if ((ret = rdbsl(dev)) != OK) {
    	    if (ret == INVALID)
    	        err(cruptbsl);
    	    ret = ERROR;
    	    goto partend;
    	}
    } else if (bslsiz == 0) {
    	ret = err(oldfmt);
	goto partend;
    } else if (bslsiz == ERROR) {
        ret = err(rootread);
        goto partend;
    }
    
    /* Lay out partition headers */
    if (pheader(dev, &pinfo[0]) != OK) {
        ret = ERROR;
        goto partend;
    }
    
    if (wrbsl(dev) != OK) {		/* write BSL */
        ret = ERROR;
        goto partend;
    }
    
    /*
     * Shove partition parms into root sector.
     */
    if ((ret = getroot(dev, bs)) != 0) {
    	if (tsterr(ret) != OK)
	    err(rootread);
	ret = ERROR;
	goto partend;
    }

    spart(bs, &pinfo[0]);		/* set partition parameters */
    sbslparm(bs);			/* set bsl parameters */
    Protobt(bs, -1L, -1, 1);		/* make root sector executable */
    if ((ret = putroot(dev, bs)) != OK) {
    	if (tsterr(ret) != OK)
    	    err(rootwrit);
    	ret = ERROR;
    	goto partend;
    }

    if (rescan(1)) {		/* has to be here because map changed	*/
    	ret = ERROR;		/* after partitions are moved around,	*/
    	goto partend;		/* report medium change error.		*/
    }
    
    /* Partition the device with parameters given in pinfo */
    if (dopart(dev, &pinfo[0]) != OK)
        ret = ERROR;
    else
        ret = OK;
    	
    rebootp = 1;
partend:
    if (bsl > 0) free(bsl);
    erasemsg();
    return (ret);
}



/*
 * Handle [ZERO] item.
 *
 */
dodizero()
{
    int ldev, ret;
    char *seldev = "X";
    int i; 

    zwarning[ZWOK].ob_state = NORMAL;
    zwarning[ZWCN].ob_state = NORMAL;
    if (execform(zwarning) != ZWOK)
	return BAILOUT;

    if ((ldev = glogdev()) < 0) return BAILOUT;

    /* Find out if logical device has assumed parameters */
    if (chkparm(ldev) != OK) {
    	wronparm[WRONOK].ob_state = NORMAL;
	execform(wronparm);
	return ERROR;
    }
        
    *seldev = ldev;
    (zerofnl[ZDRV].ob_spec)->te_ptext = seldev;
    strcat((zerofnl[ZDRV].ob_spec)->te_ptext, ":");
    zerofnl[ZYES].ob_state = NORMAL;
    zerofnl[ZNO].ob_state = NORMAL;
    if (execform(zerofnl) != ZYES)  return BAILOUT;

    dsplymsg(zeromsg);
    if (zero(ldev) == OK) {
	if (!rebootp) {
	    for (i = 0; i < 10; i++) {
		if (!mediach(ldev-'A')) break;
	    }
	    if (i == 10) {
    		rebootp = 1;
		err(mdach);
            }
	}
    }
    erasemsg();
}


/*
 * Handle [MARKBAD] item.
 *
 */
dodimark()
{
    int ldev, ret;
    int i;

    mwarning[MWARNOK].ob_state = NORMAL;
    mwarning[MWARNCN].ob_state = NORMAL;
    if (execform(mwarning) == MWARNCN)
        return BAILOUT;
    if ((ldev = glogdev()) < 0)
        return BAILOUT;
        
    /* Find out if logical device has assumed parameters */
    if (chkparm(ldev) != OK) {
    	wronparm[WRONOK].ob_state = NORMAL;
	execform(wronparm);
	return ERROR;
    }
         
    dsplymsg(lmrkmsg);
    if (markbad(ldev) != OK) {
        erasemsg();
    } else {
    	if (!rebootp) {
	    for (i = 0; i < 10; i++) {
		if (!mediach(ldev-'A')) break;
	    }
	    if (i == 10) {
    		rebootp = 1;
		err(mdach);
            }
        }
    }
}


/*
 * Map from button in ship dial.
 */
int sdev[] = {
    SDEV0, SDEV1, SDEV2, SDEV3,
    SDEV4, SDEV5, SDEV6, SDEV7
};

/*
 * Ship selected devices.
 */
dodiship()
{
  int i, seldev[8], selected=0;
  
    
  /* Throw up generic shipping warning. */
  shipdial[SWARNCN].ob_state = NORMAL;
  shipdial[SWARNOK].ob_state = NORMAL;
  if (execform(shipdial) != SWARNOK) return BAILOUT;
  
  /* Device(s) selected? */
  shipdev[SDEVOK].ob_state = NORMAL;
  shipdev[SDEVCN].ob_state = NORMAL;
  for(i = 0; i < MAXPHYSDEVS; i++) {		/* indicate what's alive */
      if (livedevs[i] == 0)
  	shipdev[sdev[i]].ob_state = NORMAL;
      else
        shipdev[sdev[i]].ob_state = NORMAL | SHADOWED;
  }
  
  if (execform(shipdev) != SDEVOK)
      return BAILOUT;
      
  for(i = 0; i < MAXPHYSDEVS; i++) {	/* search for selected unit */
      if (shipdev[sdev[i]].ob_state & SELECTED) {
          seldev[i] = 1;
          selected++;
      } else {
      	  seldev[i] = 0;
      }
  }
  
  if (!selected) return BAILOUT;	/* nothing is selected */
  
  /* Throw up final shipping warning. */
  shipfnl[SFNLCN].ob_state = NORMAL;
  shipfnl[SFNLOK].ob_state = NORMAL;
  if (execform(shipfnl) != SFNLOK) return BAILOUT;
  
  /* For REAL!!! */
  /* Ship selected devices */
  for (i = 0; i < MAXPHYSDEV; i++) {
      if (seldev[i])
          ship(i);
  }
  
  /* Put out final message about turning off hard disks */
  scommand[TRNOFFOK].ob_state = NORMAL;
  execform(scommand);
}



/*
 * Translate unit number to tree index.
 *
 */
static int physxlat[] = {
    UNIT0, UNIT1, UNIT2, UNIT3,
    UNIT4, UNIT5, UNIT6, UNIT7
};


/*
 * Get physical device#,
 * return devno or -1.
 *
 */
gphysdev()
{
    int i, start;

    /*
     * Clean up and exec object;
     * shadow devs we KNOW are there.
     */
    physdial[PHYSOK].ob_state = NORMAL;
    physdial[PHYSCN].ob_state = NORMAL;
    
    if (format == TRUE) {
    	start = 1;		/* start initializing at unit 0 */
	physdial[physxlat[0]].ob_state = NORMAL;
    } else {
    	start = 0;		/* start initializing at unit 1 */
    }
    
    for (i = start; i < MAXPHYSDEVS; ++i)
	physdial[physxlat[i]].ob_state = DISABLED;
    for (i = 0; i < MAXPHYSDEVS; ++i)
	if (livedevs[i])
	    physdial[physxlat[i]].ob_state = NORMAL | SHADOWED;

    if (execform(physdial) != PHYSOK)
	return ERROR;
     
    /* search for selected unit */
    for (i = 0; i < MAXPHYSDEVS; ++i)
	if (physdial[physxlat[i]].ob_state & SELECTED)
	    return i;

    return ERROR;			/* if no object selected */
}


/*
 * Translate from logical device number
 * to object number in logical device
 * dialouge box.
 */
int logxlat[] = {
	CCOLON, DCOLON, ECOLON, FCOLON,
	GCOLON, HCOLON, ICOLON, JCOLON,
	KCOLON, LCOLON, MCOLON, NCOLON,
	OCOLON, PCOLON
};


/*
 * Get logical device,
 * return 'C'...'P'
 * or -1.
 *
 */
glogdev()
{
    int i, flg;

    /*
     * Setup tree; selectively enable drive buttons
     * and so on.
     */
    logdial[LOGOK].ob_state = NORMAL;
    logdial[LOGCN].ob_state = NORMAL;
    for (i = 0; i < MAXLOGDEVS; ++i) {
	if (logmap[i].lm_physdev < 0)
	    flg = DISABLED;
	    else flg = NORMAL;
	logdial[logxlat[i]].ob_state = flg;
    }

    if (execform(logdial) != LOGOK) return -1;

    for (i = 0; i < MAXLOGDEVS; ++i)
	if (logdial[logxlat[i]].ob_state & SELECTED)
	    return i + 'C';

    return -1;
}


/*
 * Open virtual workstation.
 *
 */
open_vwork()
{
    int i;

    for (i = 0; i < 10;)
	work_in[i++] = 1;
    work_in[10] = 2;
    handle = phys_handle;
    v_opnvwk(work_in, &handle, work_out);
}


/*
 * Find and redraw all clipping rectangles
 *
 */
do_redraw(xc, yc, wc, hc)
int xc, yc, wc, hc;
{
    GRECT t1, t2;
    int temp[4];

    hide_mouse();
    t2.g_x=xc;
    t2.g_y=yc;
    t2.g_w=wc;
    t2.g_h=hc;
    vsf_interior(handle, 1);
    vsf_color(handle, 0);
    wind_get(wi_handle, WF_FIRSTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
    while (t1.g_w && t1.g_h) {
	if (rc_intersect(&t2, &t1)) {
	    set_clip(t1.g_x, t1.g_y, t1.g_w, t1.g_h);
	    temp[0] = xwork;
	    temp[1] = ywork;
	    temp[2] = xwork + wwork - 1;
	    temp[3] = ywork + hwork - 1;
	    v_bar(handle, temp);
	}
	wind_get(wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
    }

    show_mouse();
}


/*
 * Hide the mouse.
 *
 */
hide_mouse()
{
    if (!hidden) {
	graf_mouse(M_OFF, 0L);
	hidden = TRUE;
    }
}


/*
 * Show the mouse.
 *
 */
show_mouse() 
{
    if (hidden) {
	graf_mouse(M_ON, 0L);
	hidden = FALSE;
    }
}


/*
 * Set clipping rectangle.
 *
 */
set_clip(x, y, w, h)
int x, y, w, h;
{
    int clip[4];

    clip[0] = x;
    clip[1] = y;
    clip[2] = x + w;
    clip[3] = y + h;
    vs_clip(handle, 1, clip);
}


/*
 * "Execute" form,
 * return thingy that caused the exit.
 *
 */
execform(tree)
OBJECT tree[];
{
    int thingy;

    ARROW_MOUSE;
    dsplymsg(tree);
    thingy = form_do(tree, 0);
    erasemsg();
    BEE_MOUSE;
    return thingy;
}


/*
 *  Display a dialogue box on the screen.
 *	Input:
 *		tree - object tree for dialogue box to be displayed.
 *	Output:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
dsplymsg(tree)
OBJECT tree[];
{
    formw = tree[0].ob_width;
    formh = tree[0].ob_height;
    
    sx = wdesk / 2;
    sy = hdesk / 2;
    lx = (wdesk - formw) / 2;
    ly = (hdesk - formh) / 2;
    
    tree[0].ob_x = lx;
    tree[0].ob_y = ly;
    
    form_dial(0, sx, sy, 0, 0, lx, ly, formw, formh);
    form_dial(1, sx, sy, 0, 0, lx, ly, formw, formh);
    objc_draw(tree, 0, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


/*
 *  Erase a dialogue box from the screen.
 *	Input:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
erasemsg()
{
    form_dial(2, sx, sy, 0, 0, lx, ly, formw, formh);
    form_dial(3, sx, sy, 0, 0, lx-3, ly-3, formw+4, formh+4);
}



/*
 *  Make a long (4-byte) random.
 */ 
long
longrandom()
{
    long pattern;
    
    pattern = Random();
    pattern <<= 16;
    pattern ^= Random();
    
    return (pattern);
}

