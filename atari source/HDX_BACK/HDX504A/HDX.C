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
 *	part.h		ST structure definitions
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
 * 8-Nov-1988  jye. change and add some codes so that can be used for extended
 *					and big partition.
 * 13-Jun-1989 jye. Change and add some codes so that HDX can be deal with
 *				    acsi and scsi drives.
 * 22-Jan-1990 jye. Change the HDX so that we don't have to put a informations
 *					of a drive into the Wincap file.
 * 13-Mar-1990 jye. change the HDX to a genetic one so that the user don't
 *					need know what kind of drive.
 * 20-Jul-1990 jye. change the interface about the unit select. In the new 
 *					interface, user tells the type of drive is acsi or scsi,
 *					then selects unit.
 * 01-Aug-1990 jye. Change hard disk size request from mdsence to readcap.
 * 25-Jul-1991 jye. Change the Hdx so that can be used for IDE-AT drive.
 * 11-Nov-1991 jye. change the hdx so that can got the hard disk size from
 *					page 0, or 3, or 4, or from the wincap. For the SCSI drive,
 *					getting the disk size from wincap or readcap.
 * 7-Jul-1992  jye. Change the hdx so that can be used for the sparrow scsi.
 * Feb-3-1993  jye. Fixed a bug which is when format a hard disk with no wincap
 *					file, then the HDX will bomb out. Now, you can still format
 *					the hard disk without the wincap, because the wincap file
 *					is used when HDX can't get the hard disk's informations.
 * Apr-9-1993  jye.	To fixed a problem for the Conner CP2088 drive, which HDX
 *					can't Markbad it in Format, because this kind of drive has
 *					the different values of head, cylinder, and spt between the
 *					physical and logical parameters, so I added a inqury() call
 *					right after the 'fmtunt()' in 'dodiform()' to up date the
 *					table, because 'fmtunt()' changes the physical parameters 
 *					to the logical parameters.
 * Jul-16-93   jye. Fixed a bug that can't format the drive if the bsl was 
 *					trashed.
 * Jul-19-93   jye. Fixed and do the partition even it was format in the old way
 * Jul-22-93   jye. Fixed a bug that if couldn't scan some drive, the format or
 *					partition operation would stop.
 */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "bsl.h"
#include "hdx.h"
#include "addr.h"
#include "myerror.h"

#define MFM 17

extern char sbuf[];
extern int rebootp;
extern long gbslsiz();
extern long get3bytes();
extern long get4bytes();
extern long bslsiz;
extern BYTE *bsl;
extern int uplim;			/* the number of partitions */
extern long sptrk;
extern long spcyl;
extern int yesscan;
extern long disksiz;
extern long ratio;
extern int typedev;
extern int typedrv;
extern int prevnpart;
extern int atexst;		/* set for AT drive exist */

/* Globals */
int rebootp = 0;	/* 1: must reboot (not return to desktop) */
int tformat;			/* TRUE: just formatted disk */
int running;		/* 1: continue evnt_multi() loop */
char sbuf[512];		/* error message buffer */
long extsiz;		/* the size of extened partition */
long ostack;		/* old stack pointer */
int toibm;			/* the flag of partition to ibm format */
int ibm2st;			/* the flag for IBM partition to ST */
long bps;			/* bytes per sector */
int npart;			/* number of partition */
int ext;			/* the index of extended partition */
int extend;			/* the index of end extended partition */
int showmany;		/* the flag that show the too much device alert box */
char ttscsi;		/* SCSI hard disk drive */
char spscsixst;		/* set for sparrow scsi drive exist */
int noacsi;			/* set for no ACSI dirve in the system */
int needscan;		/* TRUE: if info in the LOGMAP update */
int noinfo=1;			/* 1: no informations in the wincap */
int athead;			/* the # of data heads on the AT drive */
int atcyl;			/* the # of cylinders on the AT drive */
int atspt;			/* the # of sectors per track on the AT drive */
int ok2draw;		/* go ahead to draw the change part of dialog box */
int ndevs;			/* the # of devices */
char *drvid[] ={	/* for the id of the drives */
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"123456789012345678901234567",
	"Identification unavaliable",
	"Not responding",
	"ACSI 0",		/* index is 19 */
	"ACSI 1",
	"ACSI 2",
	"ACSI 3",
	"ACSI 4",
	"ACSI 5",
	"ACSI 6",
	"ACSI 7",
	"SCSI 0",		/* index is 27 */
	"SCSI 1",
	"SCSI 2",
	"SCSI 3",
	"SCSI 4",
	"SCSI 5",
	"SCSI 6",
	"SCSI 7",
	"IDE 0",			/* index is 35 */
	" "
};

DEVSET devid[17];

/*  Logical-to-dev+partition mapping table. */
extern int nlogdevs;		/* #logical devs found */
extern LOGMAP logmap[];		/* logical dev map */
extern int livedevs[];		/* live physical dev flag */
extern int idevs[];			/* the devise have a id */
extern char cachexst;		/* 0: no cache. 1: with cache */

/* Partition related variables */
long mxpsiz = MAXPSIZ;

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
int pnf;		/* 1: partition or format; 0: zero or markbad */
int hidden;		/* current state of cursor */
int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];	/* storage wasted for idiotic bindings */
int work_in[11];	/* Input to GSX parameter array */
int work_out[57];	/* Output from GSX parameter array */
int pxyarray[10];	/* input point array */
int blitxst;		/* the flag for check the BLiTTER */

/*
 * Top level;
 * we get control from the desktop.
 */
main()
{
	pnf = 0;		/* set the flag to it isn't partition yet */
    appl_init();
    phys_handle=graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
    wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
    open_vwork();
    wi_handle=wind_create(0x0040&0x0080, xdesk, ydesk, wdesk, hdesk);

    hidden = FALSE;
    butdown = TRUE;

	/* doing a checking see if the cache in the system */
	cachexst = (char) chkcache();

	/* check the existence of the BLiTTER */
	blitxst = chkblit();

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
	/*
    if (wgetent("Parameters", "@@") == OK) {
	if (wgetnum("ms", &mxpsiz) != OK)
	    mxpsiz = MAXPSIZ;
    } else {
    	goto punt;
    }
	*/

	needscan = TRUE;

redomul:
    ARROW_MOUSE;

    /* display menu bar */
    menu_bar(menuobj, 1);

    running = TRUE;
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
		if (form_alert(2, autoboot) == 1)	{
			reboot();
		} else {
			goto redomul;
		}
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
			switch (msgbuff[4]) {
			    case DIFORM:
		        	if ((needscan) && (rescan(0,1) == ERROR))	{
						break;	/* don't report medium changed */
					}
			        tformat = TRUE;
					needscan = FALSE;
			        dodiform();
			        tformat = FALSE;
			        break;
			    case DIPART:
		        	if ((needscan)&&(rescan(0,2) == ERROR))	{
						break;	/* don't report medium changed */
					}
					needscan = FALSE;
			        dodipart(-1, NULL, NULL);
			    	break;
			    case DIZERO:
					if (pnf)	{
						err(needboot);
					} else {
		        		if ((needscan)&&(rescan(0,0) == ERROR))	{
							break;	/* don't report medium changed */
						}
						needscan = FALSE;
			        	dodizero();
					}
			        break;
			    case DIMARK:
					if (pnf)	{
						err(needboot);
					} else {
		        		if ((needscan)&&(rescan(0,0) == ERROR))	{
							break;	/* don't report medium changed */
						}
						needscan = FALSE;
			        	dodimark();
					}
			        break;
				/*
			    case DISHIP:
		        	if ((needscan)&&(rescan(0,1) == ERROR))	{
						break; don't report medium changed
					}
					needscan = FALSE;
			        dodiship();
			        break;
				*/
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
			    strcpy(abtdial[ABVERSN].ob_spec, "Version 5.04a");
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
    PFMT12, PFMT13, PFMT14, PFMT15
};


/*
 * Handle [FORMAT] item.
 *
 */
dodiform()
{
  extern char bootstop;
  extern char bootend;
  int dev, v, w, i, br;
  int modesel;			/* flag for mode select */
  long cnt, hdsiz;
  char *s, *d, *wgetstr();
  char buf[10], bs[512], sendata[32];
  char pnam[128];
  char *seldev = "ACSI unit 0", *id = "XXXXX";
  char *seldv =  "IDE  unit 0";
  HINFO hinfo;
  char devnames[NAMSIZ];	/* device type name buffer */
  long nbad;
  extern long gbslsiz(), nument(), dsmarkbad();
  long pattern, temp, cyl;
  long longrandom();
  char pr_id[10];	/* partition scheme id */
  int mask = 0x0001;
  int set, scsidrv, bsiz, other = 0;
  int page=4, spt, ret;
  int head=0, domark=YESMK;
  
  /*
   * Throw up generic formatting/partition warning,
   * then get physical dev they want to clobber.
   */
  yesscan = 0;
  noinfo = 1;
  for (i = 0; i < NAMSIZ; i++)
  	devnames[i] = "\0";
  fwarning[FWARNCN].ob_state = NORMAL;
  fwarning[FWARNOK].ob_state = NORMAL;
  if (execform(fwarning) != FWARNOK) return BAILOUT;

  if ((dev = gphysdev()) < 0) {
      return BAILOUT;
  }
  strcpy(id, "mn");
  br = 0;

  /* display doing SCSI massage */

  inqfmt:
  /* Get all available disk types from wincap 'mn' entries */  
  if (wallents(devnames, id) != OK)		{
  	goto stfm;
  }
  if (!*devnames) 	{/* no informations */
  	goto stfm;
  }
  noinfo = 0;
  /* Shove format name text into buttons */
  for (i = 0, s = devnames; i < 14 && *s; ++i) {
      dsknames[pfmt[i]].ob_type = G_BUTTON;	/* button */
      dsknames[pfmt[i]].ob_spec = (long)s;
      dsknames[pfmt[i]].ob_state = NORMAL;
      dsknames[pfmt[i]].ob_flags = SELECTABLE | RBUTTON;
      while (*s++)
	;
  }
  other = i;							/* the other button */
  dsknames[pfmt[i]].ob_type = G_BUTTON;	/* button */
  dsknames[pfmt[i]].ob_spec = "OTHER";
  dsknames[pfmt[i]].ob_state = NORMAL;
  dsknames[pfmt[i]].ob_flags = SELECTABLE | RBUTTON;
  i++;

  /* rest of buttons are invisible and untouchable */
  for (; i < 16; ++i) {
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
  for (i = 0; i < 18; ++i)
    if (dsknames[pfmt[i]].ob_state & SELECTED)
      break;
  if (i >= 18) {		/* nothing picked */
      return BAILOUT;
  } else if (other == i)	{  /* the OTHER button was selected */
  	  noinfo = 1;
	  goto stfm;
  }
  
	if ((!br) && (dev < 8))		{
	  	if (wgetent(dsknames[pfmt[i]].ob_spec, "mn") == ERROR)	{
  			strcpy(id, "mn");
			noinfo = 1;
			goto stfm;
			/*
			nofmt[NOSCHFMT].ob_spec = dsknames[pfmt[i]].ob_spec;
			nofmt[NOSCHFMT].ob_state = NORMAL;
			execform(nofmt, 0);
			return ERROR;
			*/
		}
		if ((s = wgetstr("br")) != NULL)	{
			strcpy(id, s);
			br = 1;			/* processing the branch */
			goto inqfmt;	/* start over */
		}
	}

stfm:
	modesel = 1;
  if(gfparm(dev, &noinfo, &modesel, &hinfo, dsknames[pfmt[i]].ob_spec,id)!= 0) {
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

  if (dev > 15)	{ /* IDE-AT drive */
  	br = dev - 16;
  } else {			/* it is a scsi or acsi drive */
  	br = (dev > 7) ? (dev-8) : (dev);	/* minus 8 for the scsi drive number */
  }

  /* asking the user do the marking bad or not */
  mkornot[YESMK].ob_state = NORMAL;
  mkornot[NOTMK].ob_state = NORMAL;
  domark = execform(mkornot);

  /*
   * One last chance to bail out.
   */
  *seldev = 'A';
  if (dev > 15)	{ /* it is a IDE-AT drive */
  	seldev = seldv;
  } else if (dev > 7)	{ /* it is a SCSI drive */
  		*seldev = 'S';
  }
  *(seldev + 10) = br + '0';
  (fmtfnl[FUNIT].ob_spec)->te_ptext = seldev;
  fmtfnl[FMTYES].ob_state = NORMAL;
  fmtfnl[FMTNO].ob_state = NORMAL;
  if (execform(fmtfnl) != FMTYES) return BAILOUT;

  /* For REAL !! */  
  dsplymsg(fmtmsg);

  bsl = 0L;
  
  if ((dev > 15) && (!(athead*atcyl*atspt)))	{
  	formaterr(dev);
    ret = ERROR;
    goto formend;
  }
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
  /* Jul-16-93 jye. changed this codes so that it can format the trashed
  					bad sector list
  } else {	bslsiz == MDMERR; medium changed error
      ret = ERROR;
      goto formend;
  }
  */
  } else { /* if the bslsiz = other values, set it to 1 and countinue */
  	  bslsiz = 1;
      /* Allocate memory for existing BSL */
      if ((bsl = (BYTE *)mymalloc((int)bslsiz*512)) <= 0) {
          ret = err(nomemory);
          goto formend;
      }
      /* Read in BSL */
	  	if (creabsl(dev, NEW, 0L) != OK) {
	  	    ret = ERROR;
	  	    goto formend;
		}
  }
  
  /*
   * In supervisor mode
   * set disk format parameters
   * and format the disk.
   */
  ostack = Super(NULL);
  delay();
  if (dev > 15)		{ /* do the IDE-AT format */
 	if ((ret = fmtunt(dev)) != OK)	{
	  delay();
  	  Super(ostack);
      ret = errcode(dev);
      if (tsterr(ret) != OK)
          formaterr(dev);
      ret = ERROR;
	} else {
		/* Apr-7-93 jye: This is a farmware bug, so have to recall identify()*/
		/* 			to update the head, cylinder, and spt 					 */
		if (identify(16, bs) == OK)	{
			delay();
			gparmfc(&atcyl, &athead, &atspt, bs); 
		} else {
			ret = ERROR;
			goto formend;
		}
		if (dev == 16)	{/* it is a master IDE-AT */
			hdsiz = athead*atcyl*atspt; 
		} 
  		disksiz = hdsiz;
		delay();
  		Super(ostack);
	}
	goto formend;
  } 
  set = typedev & (mask << dev);
  scsidrv = typedrv & (mask << dev);
  bsiz = ((set) || (scsidrv)) ? (16) : (22);
  if (!noinfo)	{			/* there are info in the wincap */
	if ((set) || (scsidrv))	{
  		v = mdsense(dev, 4, 0, 32, sendata);
  		delay();				    /* kludge delay */
	  	sqms(dev, sendata);
	} else {
  		if (modesel) {
      		v = ms(dev, &hinfo);	/* Yes, do noprmal mode set */
		}
	}
  	/* Find formatted capacity of drive */
  	hdsiz = (long)hinfo.hi_cc * (long)hinfo.hi_dhc * (long)hinfo.hi_spt;
  }	else if (dev < 8)	{		/* No, do special mode set */
	for (i = 0; i < 32; i++)
		sendata[i] = 0;
	if ((set) || (scsidrv))	{
  		if (mdsense(dev, 0, 0, bsiz, sendata) == OK)		{
			if (hdsiz = get3bytes(sendata+5))	{
  				delay();				    /* kludge delay */
				sqms(dev, sendata);
				v = OK;
				goto kkk;
			}
		}
  redopg:
		for (i = 0; i < 32; i++)
			sendata[i] = 0;
  		v = mdsense(dev, page, 0, 32, sendata);
  		for (i = 0; i < 32; i++) /* the lenght of sendata */
  			if (sendata[i])
				break;
  		if ((i == 32) && (page == 4))	{ /* no informations returned */
			page = 3;
			goto redopg;
  		} else if (i == 32)	{
			ret = 111;
  			delay();				    /* kludge delay */
  			Super(ostack);
			goto formend;
		}
		if (page == 4)	{
			if (!(hdsiz = get3bytes(sendata+5)))	{
				page = 3;
				/*
				cyl = get3bytes(sendata+14);
				head = *(sendata+17);
				if ((!cyl) || (!head))	{
					ret = 111;
  					delay();		
  					Super(ostack);
					goto formend;
				}
				*/
				sqms(dev, sendata);
				goto redopg;
			}
			sqms(dev, sendata);
			goto kkk;
		} 
		if (!(hdsiz = get3bytes(sendata+5)))	{
			/*
			spt = getword(sendata+22);
			hdsiz = cyl*head*spt;
			*/
			if (!hdsiz)		{
				ret = 111;
  				delay();				    /* kludge delay */
  				Super(ostack);
				goto formend;
			}
		}
		goto kkk;
	} else {	/* it is the acsi drivers */
  		hdsiz = (long)hinfo.hi_cc * (long)hinfo.hi_dhc * (long)hinfo.hi_spt;
  		delay();				    /* kludge delay */
      	v = ms(dev, &hinfo);	/* Yes, do noprmal mode set */
	}
  }	else {
		if ((v = readcap(dev, 0, (long)0, buf)) == OK)	{
			if ((hdsiz = get4bytes(buf)))	{
				hdsiz += 1;
				ret = OK;
				goto kkk;
			} 
		} 
  		delay();				    /* kludge delay */
		for (i = 0; i < 32; i++)
			sendata[i] = 0;
  		if ((v=mdsense(dev, 0, 0, bsiz, sendata)) == OK)		{
			if (hdsiz = get3bytes(sendata+5))	{
				ret = OK;
				goto kkk;
			}
		}
		for (i = 0; i < 32; i++)
			sendata[i] = 0;
  		delay();				    /* kludge delay */
  		if ((v=mdsense(dev, 4, 0, 32, sendata)) == OK)		{
			if (hdsiz = get3bytes(sendata+5))	{
				ret = OK;
				goto kkk;
			}
		}
		for (i = 0; i < 32; i++)
			sendata[i] = 0;
  		delay();				    /* kludge delay */
  		if ((v=mdsense(dev, 3, 0, 32, sendata)) == OK)		{
			if (hdsiz = get3bytes(sendata+5))	{
				ret = OK;
				goto kkk;
			}
		}
		ret = 111;
  		delay();				    /* kludge delay */
  		Super(ostack);
		goto formend;
  }
kkk:
  disksiz = hdsiz;
  delay();				    /* kludge delay */
  if (v == OK)	{
  	v = format(dev, (UWORD)hinfo.hi_in);  /*format*/
  }
lll:
  delay();				    /* kludge delay */
  Super(ostack);
  
  if (v != 0)  {
      ret = errcode(dev);
      if (tsterr(ret) != OK)
          formaterr(dev);
      ret = ERROR;
      goto formend;
  }
  
  ret = OK;
  rebootp = 1;
formend:
  erasemsg();	/* Erase formatting box */
  if (ret == 111)		/* HDX may not support this drive */
  		ret = err(needinfo);
  if (ret < 0) {
      if (bsl > 0) free(bsl);
      return ERROR;
  }
  
  /*------------------------------------------*
   * Markbad the device destructively.	      *
   * Bad Sectors found are added to the BSL.  *
   * Write BSL to device.		      *
   *------------------------------------------*/
  if (domark == YESMK)	{ /* need to do the markbad */
  	if ((nbad = dsmarkbad(dev, hdsiz, 1, pattern)) < 0) {
  	    free(bsl);
  	    return ERROR;
  	}
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
  if (modesel)	{
  	sfmtparm(bs, &hinfo);
  } else {
  	sdisksiz(bs, disksiz);
  }
  for (d = bs, s = &bootstop, cnt = (long)(&bootend - &bootstop); --cnt;)
    *d++ = *s++;
  Protobt(bs, -1L, -1, 1);	/* make root sector executable */
  
  if ((ret = putroot(dev, bs, (SECTOR)0)) != OK) {
      if (tsterr(ret) != OK)
	  	err(rootwrit);
      return ERROR;
  }

  /*
   * Make a copy of the default partition name.
   * Figure out the partition scheme id.
   */
  if (!noinfo)	{
  	s = wgetstr("pt");
  	strcpy(pnam, s);
  }
  /* ??
  figprid(disksiz, pr_id);
  */
  dodipart(dev, pnam, disksiz);
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
dodipart(xdev, pnam, hsize)
int xdev;
char *pnam;
long hsize;
{
    int dev, i, ret =OK, fine;
	int choice;
    char *seldev = "ACSI unit 0";
  	char *seldv =  "IDE  unit 0";
    char *s;
    char bs[512];
    PART *pinfo;
	int tem1, tem2;
	long disksiz;
	int mask = 0x0001;

    if (xdev < 0) {
	/*
	 * Throw up warning saying that partition is dangerous;
	 * then get physical dev they want to clobber.
	 */
	pwarning[PWARNCN].ob_state = NORMAL;
	pwarning[PWARNOK].ob_state = NORMAL;
	if (execform(pwarning) != PWARNOK) return BAILOUT;
	tformat = FALSE;
	if ((dev = gphysdev()) < 0) {
	    return BAILOUT;
	}
	/*
	 * Let the user edit/pick partitions.
	 */
	fine = 0;
	while (!fine) {
	    if (sfigpart(bs, dev, (PART *)&pinfo) != OK)	{
			if (pinfo > 0)	Mfree(pinfo);
	        return BAILOUT;
		}
	    if ((ret = chkpart(dev, pinfo)) != OK) {
			if (ret < 0)	{	/* size too big */
	    	    err(nexsmem);
	    	} else {	/* some other errors  */
				if (pinfo > 0)	Mfree(pinfo);
				return BAILOUT;
			}
	    } else {
	        fine = 1;
		}
	}

  	fine = dev;			/* default for the acsi unit */
	*seldev = 'A';
  	if (dev > 15)	{ /* it is a IDE-AT drive */
		fine = dev - 16;
		seldev = seldv;
	} else if (dev > 7) 	{	/* minus 8 for the scsi drive number */
		fine = dev - 8;
		*seldev = 'S';
	}
	*(seldev + 10) = fine + '0';

	/* Last chance to bail out */
	(partfnl[PUNIT].ob_spec)->te_ptext = seldev;
	partfnl[PARTYES].ob_state = NORMAL;
	partfnl[PARTNO].ob_state = NORMAL;
	if (execform(partfnl) != PARTYES)	{
		if (pinfo > 0)	Mfree(pinfo);
	    return BAILOUT;
	}

    } else {
		/* ??
		if ((!noinfo) && (!ttscsi) && (wgetent(pnam, pr_id) != OK)) {
		    nopart[NOSCHPOK].ob_state = NORMAL;
		    (nopart[NOSCHPR].ob_spec)->te_ptext = pnam;
		    execform(nopart);
		    return ERROR;
		}
		*/
		npart = 4;
		ext = NO_EXT;	/* set the extended partition flag to not exists */
		dev = xdev;
		if ((pinfo = (PART *)Malloc((long)sizeof(PART)*npart)) <= 0)	{
			err(nomemory);
			if (pinfo > 0)	Mfree(pinfo);
			return ERROR;
		}
		inipart(pinfo, npart);
		npart = 0;
		setpart(pinfo, pnam, hsize);
		/* ??
		if (ttscsi)		{	 SCSI bus drive 
			setpart(pinfo, hsize);
		} else {			 regular drvie 
			for (i = 0; i < 4; ++i)
			    fillpart(i, &pinfo[i]);
		}
		*/
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
    } else if (bslsiz == ERROR) {
        ret = err(rootread);
        goto partend;
    } else {
		/*	Jul-19-93 jye. changed to partition it even it was oldfmt 
    	ret = err(oldfmt);
		goto partend;
		*/
		bslsiz = 1;
    	/* Allocate memory for existing BSL */
    	if ((bsl = (BYTE *)mymalloc((int)bslsiz*512)) <= 0) {
    	    ret = err(nomemory);
    	    goto partend;
    	}
        /* Create a new BSL if current one is unusable */
	  	if (creabsl(dev, NEW, 0L) != OK) {
	  	    ret = ERROR;
	  	    goto partend;
		}
	}

    
    /* Lay out partition headers */
    if (spheader(dev, &pinfo[0]) != OK) {
        ret = ERROR;
        goto partend;
    }
    
    if (wrbsl(dev) != OK) {		/* write BSL */
        ret = ERROR;
        goto partend;
    }

	/* check and change the structure's id after 'spheader()' */
	changeid(pinfo);

	/* Shove partition parms into root sector */
	if ((ret = getroot(dev, bs, (SECTOR)0)) != 0)	{
		if (tsterr(ret) != OK)
			err(rootread);
		ret = ERROR;
		goto partend;
	}

	if ((ret = stlayroot(bs, dev, pinfo)) != OK)	{
		goto partend;
	}
	tem1 = npart;			/* save the number of partitions */
	tem2 = ext;				/* save the index of extended partition */
	/* Jul-22-93 jye:	Fixed a bug that if 'rescan' return non zero, that
						HDX will stop to do the rest of format or partition.
						So, here we shouldn't care what error may occor in
						the 'rescan', and we should countinue the rest of 
						operation. So I change this codes to following. 

    	if (rescan(1,2)) {		 has to be here because map changed
    		ret = ERROR;		 after partitions are moved around,
    		goto partend;		 report medium change error.
    	}
	*/
    rescan(1,2);	 /*	has to be here because map changed after partitions 
						are moved around, report medium change error.*/
	npart = tem1;
	ext = tem2;
    /* Partition the device with parameters given in pinfo */
    if (stlaybs(dev, &pinfo[0]) != OK)
        ret = ERROR;
    else
        ret = OK;
    	
    rebootp = 1;
	/*  add on Jul 2, 90 for removable drive
	if ((typedev & (mask << dev)))			 it is a removable drive 
		if (npart <= prevnpart)				 if less or equal than prevous 
			rebootp = 0; 					 partition, don't reboot 
	change and add over on Jul 2, 90 for the removable drive on Oct 1, 90
	if ((typedev & (mask << dev)))	{		 it is a removable drive 
		for (i = 0; i < 10; i++) 	{
			if (!mediach(dev))			
				break;
			if (i == 10)
				rebootp = 1;
			else
				rebootp = 0;
		}
	}
	*/
	pnf = 1;		/* set the flag to just doing the partition */
partend:
    if (bsl > 0) free(bsl);
	inipart(pinfo, npart);
	if (pinfo > 0)	Mfree(pinfo);
    erasemsg();
    return (ret);
}


/*
 * get root sector informations and write them into that sector 
 */

stlayroot(bs, dev, part)
char *bs;
int dev;
PART *part;
{
	int i;
	UWORD sum = 0x1234;
	long cnt, disksiz, prvst;
	char *d, *s;
	extern char bootstop;
	extern char bootend;

	/* do the prime partition */
	spart(bs, part, 0, &prvst);	/* set ST partition parameters */
	/*
  	sfmtparm(bs, &hinfo);
  	for (d = bs, s = &bootstop, cnt = (long)(&bootend - &bootstop); --cnt;)
  	  *d++ = *s++;
	*/
	sbslparm(bs);				/* set bsl parameters */
	Protobt(bs, -1L, -1, 1);		/* make root sector executable */
    if ((ret = putroot(dev, bs, (SECTOR)0)) != OK) {
    	if (tsterr(ret) != OK)
    	    err(rootwrit);
    	return(ERROR);
    }
	if (ext == NO_EXT)	return OK;		/* no extended partition */
	/* do the extended partitions */
	extsiz = part[ext].p_siz;
	for (i = 4; i < npart; i++)	{
		if (!(part[i].p_flg & P_EXISTS))	{ 	/* skip if not exists */
			return OK;
		}
		spart(bs, part, i, &prvst);	/* set IBM partition parameters */
		if ((ret = putroot(dev, bs, part[i].p_st)) != OK) {
    		if (tsterr(ret) != OK)
    		    err(rootwrit);
    		return(ERROR);
    	}
	}
	return OK;
}




/*
 * Put information into the root structure
 */

spart(image, pinfo, pnm, prvst)

char *image;			/* root sector buffer */
register PART *pinfo;	/* partition information */
int pnm;				/* partition number */
long *prvst;			/* The previous partition start sector */

{
	PART *rpart;
	long numcyl;
	int i, j;

	if (pnm) 	{
		fillbuf(image, 512L, 0L);
	}
	rpart = &((RSECT *)(image + 0x200 - sizeof(RSECT)))->hd_p[0];
	if (pnm < 4)	{
		for (i = 0; i < NPARTS; i++, rpart++)	{
			if (pinfo->p_flg & P_EXISTS)	{
				rpart->p_flg = P_EXISTS;
				for (j = 0; j < 3; j++)
					rpart->p_id[j] = pinfo->p_id[j];
				rpart->p_st = pinfo->p_st;
				rpart->p_siz = pinfo->p_siz;
			} else {
				rpart->p_flg = 0;
				for (j = 0; j < 3; j++)
					rpart->p_id[j] = 0;
				rpart->p_st = 0L;
				rpart->p_siz = 0L;
			}
			pinfo++;
		}

	} else {	/* pnm => 4 */
		rpart->p_flg = pinfo[pnm].p_flg;
		for (j = 0; j < 3; j++)
			rpart->p_id[j] = pinfo[pnm].p_id[j];
		rpart->p_st = ROOTSECT;
		rpart->p_siz = pinfo[pnm].p_siz - ROOTSECT;
		rpart++;
		if (((pnm + 1) != npart) && (pinfo[pnm+1].p_flg & P_EXISTS)) { 
			/* need extened partition */
			rpart->p_flg = P_EXISTS;
			rpart->p_id[0] = 'X';
			rpart->p_id[1] = 'G';
			rpart->p_id[2] = 'M';
			rpart->p_siz = pinfo[pnm+1].p_siz;
			rpart->p_st = (pnm == 4) ? (pinfo[4].p_siz) :
	    							(pinfo[pnm].p_siz + *prvst);
			*prvst = rpart->p_st;
		}

	}
}



/*
 * Setup partitions on the disk;
 * write boot sectors and zero FATs and root directories.
 *
 */
stlaybs(physdev, pinfo)
int physdev;
register PART *pinfo;
{
	int i, ldev, ret;
	int kindfat;
    SECTOR data, nsect;
    char *devno="X";
    long ndirs;
    UWORD fatsiz;
    BOOT *bs;
	long serialno;
	extern long longrandom();
	extern long cell();
	char *buf, *buf1;
	long size, remsect;
	long datsect;
	long datclst; 
	long fatclst;
	long entsect;

    if ((bslsiz = gbslsiz(physdev)) < 0L) {
        if (bslsiz == ERROR)
            err(rootread);
        return ERROR;
    }
    /* SCAN_BS: pinfo is for scan() and laybs() use */
	if (ext != NO_EXT)	sortpart(pinfo, SCAN_BS);	

    for (i = 0; i < npart; ++i, ++pinfo) {
    	
    	/* don't care if partition does not exist */
		if (!(pinfo->p_flg & P_EXISTS)) {
		    return OK;
		}


	/*
	 * Compute boot sector parameters.
	 */
		if (pinfo->p_siz > disksiz) {		/* partition >? disk size */
		    *devno = i + '0';
		    (part2big[BGPART].ob_spec)->te_ptext = devno;
		    part2big[BGPARTOK].ob_state = NORMAL;
		    execform(part2big);
		    return ERROR;
		}

	/* estimat the bps */
	/* MAXSECT = 16MB - 8 */
	bps = cell((pinfo->p_siz-7)*BPS, (long)MAXSECT);

	/* the real bps */
	bps = BPS * n2power((UWORD)cell(bps, (long)BPS));
	ratio = bps / BPS;
	nsect = pinfo->p_siz / ratio;

	size = (long)BPS * ratio;
	if ((buf = (char *)Malloc(size)) <= 0)	{
		err(nomemory);
		if (buf > 0) Mfree((long)buf);
		return ERROR;
	}

	/*
	 * Install entries in boot sector image;
	 * force sector checksum to zero (non-executable);
	 * write boot sector to media.
	 *
 	 *	512 bytes/sector
	 *	2 or 4 sectors/cluster (partition > 16Mb has 4 spc)
	 *	1 reserved sector (for boot)
	 *	2 FATs
	 *	... dir slots
	 *	... # sectors
	 *	F8 means media is a hard disk
	 *	... FAT size
	 *
	 */
	 
	/* Make a clean boot sector */
	fillbuf(buf, bps, 0L);
	bs = (BOOT *)buf;
        

    /* bytes per sector */
	iw((UWORD *)&bs->b_bps[0], (UWORD)bps);
	
	/* sectors per cluster */
	bs->b_spc = SPC;
	    
	/* number of reserved sectors */
	iw((UWORD *)&bs->b_res[0], (UWORD)1);
	
	/* number of FATs */
	bs->b_nfats = 2;
	

	/*
	 * Compute root directory size
	 * 256 entries, plus fudge on devs > 10Mb
	 */
	if (pinfo->p_siz < 0x5000L) ndirs = NUMEN;
	else ndirs = nsect / 80;	/* 1 dir entry per 80 sectors */
	/* round to nearest sector */
	ndirs = (ndirs + ((UWORD)bps/BPDIR - 1)) & ~((UWORD)bps/BPDIR - 1);	
	iw((UWORD *)&bs->b_ndirs[0], (UWORD)ndirs);
	
	/* number of sectors on media (partition) */
	iw((UWORD *)&bs->b_nsects[0], (UWORD)nsect);

	/* media descriptor */
	bs->b_media = 0xf8;

	/*--------------------------------------------------------------*
	 * Compute FAT size						*
	 *								*
	 * Num entries to map the entire partition			*
	 *	= partition's size in clusters				*
	 *	= partition's size in sectors / spc			*
	 *								*
	 * Num entries in FAT						*
	 *	= Num entries to map partition + reserved entries	*
	 *	= (partition's size in sectors / spc) + 2		*
	 *								*
	 * Num sectors FAT occupies					*
	 *	= Num entries in FAT / Num entries of FAT per sector	*
	 *	= Num entries in FAT / (bps / 2)    <16-bit FAT>	*
	 *	= ((partition's size in sectors / spc) + 2) / (bps/2) + 1	*
	 *					    <+1 to round up>	*
	 *--------------------------------------------------------------*/
	fatsiz = ((((nsect / bs->b_spc) + 2) * 2) / bps) + 1;/*bps ?? 512 or 1024*/
	iw((UWORD *)&bs->b_spf[0], (UWORD)fatsiz);

	/* write the serial number to the bs */ 
	Protobt(bs, 0x01000000, -1, -1);

	/*
	 * Write partition's boot sector
	 */
	forcesum((UWORD *)buf, (UWORD)0);	/* force image checksum */
	if ((ret = wrsects(physdev,(UWORD)ratio,buf,(SECTOR)pinfo->p_st))!= OK) {
	    if (tsterr(ret) != OK)
	        err(bootwrit);
	    return ERROR;
	}

	/*
	 * Zero the fat tables directory entry 
	 */
	if ((ret = zerosect(physdev, (SECTOR)(pinfo->p_st+ratio),
		     ((UWORD)((fatsiz*2 + ndirs*BPDIR/bps) * ratio)))) != OK) {
	    if (tsterr(ret) != OK)
	        err(hdrwrite);
	    return ERROR;
	}
	/* Apr-23-93 jye: To fixed the same bug in the Gemdos.
	 * Num entries in FAT						*
	 *	= Num entries to map partition + reserved entries	*
	 *	= (partition's size in sectors / spc) + 2		*
	 *								*
	 * Num sectors FAT occupies					*
	 *	= Num entries in FAT / Num entries of FAT per sector	*
	 *	= Num entries in FAT / (bps / 2)    <16-bit FAT>	*
	 * 
	 * Num entries in the last sector of FAT
	 * = (nsect/spc + 2) % (bps/2)
	 * 
	 * The pointer(or counter in byte)after the last entries in the FAT
	 * = ((nsect/spc + 2) % (bps/2))*ratio*2 (16bit fat is 2 bytes)
	 */
	/* # of sectors in datas:  
	 *			 	datsect   = nsect - boot - 2*fatsiz - size of dir 
	 * 						  = nsect-boot-2*fatsiz-(ndirs*32)/bps
	 * # of clusters in datas: 
	 *				datclst	  = # of sectors in datas / SPC 
	 * # of clusters(entries) in Fat: 
	 *				fatclst   = fatsiz * (bps/2)
	 * # of sectors need in fat talbe for datclst:
	 *				entsect   = datclst / (bps/2)
	 * # of sectors need to remodify to 0xffff:
	 *				remsect   = fatsiz - entsect
	 */

	datsect = nsect - 1 - 2*fatsiz - (ndirs*32)/bps;
	datclst = datsect / SPC;
	fatclst = fatsiz * (bps/2);
	entsect = datclst / (bps/2);
	remsect = (fatsiz - entsect)*size;


	/* # of sectors need to remodify to 0xffff */
	if ((buf1 = (char *)Malloc(remsect)) <= 0)	{
		err(nomemory);
		if (buf > 0) Mfree((long)buf);
		if (buf1 > 0) Mfree((long)buf1);
		return ERROR;
	}

	/* 
	 * Apr-23-93 jye: To fixed the write over to next partitiona in the Gemdos  
	 *				  , here just set those entries in Fat table, which don't
	 *				  correspond to the availble date sectors in the partition.
	 *				  The pointers should be:
	 *				  	p_st+(boot+datclst/(bps/2))*ratio and 
	 *					p_st+(boot+fatsiz+datclst/(bps/2))*ratio 
	 */
	if ((ret = rdsects(physdev, (UWORD)(remsect/BPS), buf1, 
	 				(SECTOR)pinfo->p_st+(1+datclst/(bps/2))*ratio)) != OK) {
	    if (tsterr(ret) != OK)
	        err(bootwrit);
	    return ERROR;
	}
	/* fill the last sectors of FAT start at last entry with the 0xffff */
	/* +2 is for two reserved entries in the fat table */
	fillfat(buf1, ((datclst%(bps/2))+2)*2, remsect, 0xffff);
	if ((ret = wrsects(physdev,(UWORD)(remsect/BPS),buf1,
	 				(SECTOR)pinfo->p_st+(1+datclst/(bps/2))*ratio) != OK) ||
		(ret = wrsects(physdev,(UWORD)(remsect/BPS),buf1,
	 		(SECTOR)pinfo->p_st+(1+fatsiz+datclst/(bps/2))*ratio) != OK)) {
	    if (tsterr(ret) != OK)
	        err(bootwrit);
	    return ERROR;
	}
	/* Apr-23-93 jye: Add above codes to fix the Gemdos over write next
	 * 				  partition.
	 */

		     
	/*
	 * Make first 2 entries in FATs more IBM-like.
	 */
	if ((ret = rdsects(physdev,(UWORD)ratio,buf,
						(SECTOR)(pinfo->p_st+ratio)))!= 0){
	    if (tsterr(ret) != OK)
	        err(fatread);
	    return ERROR;
	}
	*(UWORD *)&buf[0] = 0xf8ff;
	*(UWORD *)&buf[2] = 0xffff;
	if ((ret = wrsects(physdev,(UWORD)ratio,
						buf,(SECTOR)(pinfo->p_st+ratio)))!= 0 ||
	    (ret = wrsects(physdev,(UWORD)ratio,buf,
						(SECTOR)(pinfo->p_st+ratio+fatsiz*ratio)))
	    != 0) {
	    if (tsterr(ret) != OK)
	        err(fatwrite);
	    return ERROR;
	}

	/*
	 * Mark bad sectors recorded in the BSL into the FATs.
	 * Calculating parameters:
	 *	ldev - from physdev and i.
	 *	fat0 - always equals 1.
	 *	fatsiz - calculated above.
	 *	data - starts after the boot sector, 2 FATs and rootdir.
	 */

		if (bslsiz > 0) {
			if ((ldev = phys2log(physdev, i)) == ERROR)
				return parterr(physdev);
			data = (SECTOR)1 + (SECTOR)(fatsiz*2) + (SECTOR)(ndirs*BPDIR/bps);
			bsl2fat(ldev, (SECTOR)ratio, (UWORD)(fatsiz*ratio), 
												data*ratio, MEDIA);
		}
		if (buf > 0) Mfree((long)buf);
		if (buf1 > 0) Mfree((long)buf1);
	}
	return OK;
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
	if (showmany)	err(manyldev);

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
	if (showmany)	err(manyldev);

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
 * Translate unit number to tree index.
 *
 */
static int physxlat[] = {
    UNIT0, UNIT1, UNIT2, UNIT3
};

static int physid[] = {
    DRVID0, DRVID1, DRVID2, DRVID3
};

#define ROLL1 1			/* move the bar one step */
#define ROLL4 4			/* move the bar four steps */


/*
 * Get physical device#,
 * return devno or -1.
 *
 */
gphysdev()

{
    int xrun = 1, tpdev=0;
	int index=0, i, ret;

	linkdev();			/* link all live devices into a list */
	if (tformat)	{	/* when format, enable all devices in dialog box */
		if ((spscsixst)	|| (atexst)) { /* sparrow or notebook */
			ndevs = 9;
			tpdev = 8;
		} else if (ttscsi) {
			ndevs = 16;
		} else { /* if ((!ttscsi) && (!noacsi))	 Mega ST */
			ndevs = 8;
		}
	}
	/* set form for first display */
	physdial[PHYSOK].ob_state = NORMAL;
	physdial[PHYSCN].ob_state = NORMAL;
	physdial[SLBOX].ob_y = 0;
	if (ndevs <= 4)	{
		physdial[SLBOX].ob_height = physdial[SLTRK].ob_height;
	} else {
		physdial[SLBOX].ob_height = physdial[SLTRK].ob_height / (ndevs/4.0);
	}
	for (i=0; i < 4; i++)	{
		physdial[physxlat[i]].ob_state = NORMAL;
		physdial[physid[i]].ob_state = NORMAL;
	}
	ok2draw = 0;
	drawdev(index);	/* draw the devices into the dialog box */
	ARROW_MOUSE;
	dsplymsg(physdial);
	++ok2draw;
    while (xrun) 	{
		switch (ret=form_do(physdial, -1)) 	{
			case PHYSOK:xrun = 0;
						break;
			case PHYSCN:xrun = 0;			/* return */
						break;
			case SLTRK: if (ndevs > 5)	{
							scrupdn(ROLL4, &index);
						}
						break;
			case SLUP:  if (index != 0)	{
							scrupdn(ROLL1, &index);
						}
						break;
			case SLDN:  if ((index < 12) && (index+4 < ndevs))	{
							scrupdn(ROLL1, &index);
						}
						break;
			case SLBOX: if (ndevs > 5)	{
							slidebox(physdial, &index);
						}
						break;
			case DRVID0:physdial[UNIT0].ob_state = SELECTED;
				   	objc_draw(physdial,UNIT0, MAX_DEPTH, 0, 0, wdesk, hdesk);
						break;;
			case DRVID1:physdial[UNIT1].ob_state = SELECTED;
				   	objc_draw(physdial,UNIT1, MAX_DEPTH, 0, 0, wdesk, hdesk);
						break;;
			case DRVID2:physdial[UNIT2].ob_state = SELECTED;
				   	objc_draw(physdial,UNIT2, MAX_DEPTH, 0, 0, wdesk, hdesk);
						break;;
			case DRVID3:physdial[UNIT3].ob_state = SELECTED;
				   	objc_draw(physdial,UNIT3, MAX_DEPTH, 0, 0, wdesk, hdesk);
						break;;
			case UNIT0:physdial[DRVID0].ob_state = SELECTED;
				   	objc_draw(physdial,DRVID0, MAX_DEPTH, 0, 0, wdesk, hdesk);
						break;;
			case UNIT1:physdial[DRVID1].ob_state = SELECTED;
				   	objc_draw(physdial,DRVID1, MAX_DEPTH, 0, 0, wdesk, hdesk);
						break;;
			case UNIT2:physdial[DRVID2].ob_state = SELECTED;
				   	objc_draw(physdial,DRVID2, MAX_DEPTH, 0, 0, wdesk, hdesk);
						break;;
			case UNIT3:physdial[DRVID3].ob_state = SELECTED;
				   	objc_draw(physdial,DRVID3, MAX_DEPTH, 0, 0, wdesk, hdesk);
						break;;
  		}
  	}

  /*
   * Draw shrinking box and cleanup the screen;
   * return thing that caused our exit.
   */
    erasemsg();

	if (ret == PHYSCN)	{
		return ERROR;
	}
	/* search for the selected unit */
	for (i=0; i < 4; i++)	{
		if (physdial[physxlat[i]].ob_state & SELECTED)	{
			if (tformat)	{
				return(index+tpdev+i);
			} else {
				return(devid[index+i].dev);
			}
		}
	}
	return ERROR;
}

/* draw the select devices dialog box for the format operation */

fdrawdev(index)
int index;
{

	int i, st=0;

	if ((spscsixst)	|| (atexst))	{
		st = 8;
	}
	
	for (i=0; i < 4; i++)	{
		/*
		(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[36][0];
		(physdial[physid[i]].ob_spec)->te_ptext = &drvid[36][0];
		*/
		if (i+index+st < 8)	{
		  	(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[19+i+index][0];
		} else if (i+index+st < 16)	{
		(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[27+i+index+st-8][0];
		} else {
			(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[35][0];
		}
		physdial[physxlat[i]].ob_state = NORMAL;
		physdial[physid[i]].ob_state = NORMAL;
		if (i+index+st == 16)	{	/* it is sparrow */
			(physdial[physid[i]].ob_spec)->te_ptext = &drvid[i+index+st][0];
		} else if (livedevs[i+index+st])	{
			if (idevs[i+index+st])	{
				(physdial[physid[i]].ob_spec)->te_ptext = &drvid[i+index+st][0];
			} else {
				(physdial[physid[i]].ob_spec)->te_ptext = &drvid[17][0];
			}
		} else {
			if (idevs[i+index+st])	{
				(physdial[physid[i]].ob_spec)->te_ptext = &drvid[i+index+st][0];
			} else {
				(physdial[physid[i]].ob_spec)->te_ptext = &drvid[18][0];
			}
			/*
			physdial[physid[i]].ob_state = NORMAL;
			*/
		}
		if (ok2draw)	{
			/*
			objc_draw(physdial,physlat[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
			*/
			objc_draw(physdial,physxlat[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
			objc_draw(physdial,physid[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
		}
	}
}
    
/* draw the select devices dialog box for the partition operation */

drawdev(index)
int index;
{

	int i, j;

	if (tformat)	{
		fdrawdev(index);
		return OK;
	}

	for (i=0; i < 4; i++)	{
		(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[36][0];
		(physdial[physid[i]].ob_spec)->te_ptext = &drvid[36][0];
		if (devid[i+index].flg)	{
		   	physdial[physxlat[i]].ob_state = NORMAL;
		   	physdial[physid[i]].ob_state = NORMAL;
			/*
			if (devid[i+index].flg == 2)	{
		    	physdial[physxlat[i]].ob_state = NORMAL;
			} else {
		    	physdial[physxlat[i]].ob_state = NORMAL | OUTLINED;
			}
			*/
			j = devid[i+index].dev;
			if (j < 8)	{
				/*
				drvid[19][10] = devid[i+index].dev + '0';
				*/
				(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[19+j][0];
			} else if (j < 16)	{
				/*
				drvid[20][10] = devid[i+index].dev - 8 + '0';
				*/
				(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[27+j-8][0];
			} else {
				(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[35][0];
			}
			/*
			physdial[physid[i]].ob_state = NORMAL;
			*/
			(physdial[physid[i]].ob_spec)->te_ptext = devid[i+index].id;
		} else {
			physdial[physxlat[i]].ob_state = DISABLED;
			physdial[physid[i]].ob_state = DISABLED;
			/*
			(physdial[physid[i]].ob_spec)->te_ptext = &drvid[18][0];
			*/
		}
		if (ok2draw)	{
			objc_draw(physdial,physxlat[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
			objc_draw(physdial,physid[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
			/*
			objc_draw(physdial,physlat[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
			*/
		}
	}
}

scrupdn(roll, index)
int roll;
int *index;

{
 	int gr_mkmx, gr_mkmy;
	int gr_mkmstate, gr_mkkstate;
	int barht, barx, bary;
	int eptx, epty, eptht;

	barht = physdial[SLTRK].ob_height;
	eptht = physdial[SLBOX].ob_height;
	graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
	objc_offset(physdial, SLBOX, &eptx, &epty);
	objc_offset(physdial, SLTRK, &barx, &bary);
	/* check which part of bar was clicked */
	if (gr_mkmy > (epty+eptht))	{	/* low part of bar was clicked */
		if (roll == ROLL4)	{
			/*
			if (eptht > (bary+barht-epty-eptht))	{
			if (((spscsixst)||(atexst)) && (*index+5 >= ndevs))	{
				*index = ndevs - 4;
				physdial[SLBOX].ob_y = barht - eptht;
			} else if (*index+5 >= ndevs)	{
			*/
			if ((*index+5 >= ndevs) || (eptht > (bary+barht-epty-eptht)))	{
				physdial[SLBOX].ob_y = barht - eptht;
				*index = ndevs - 4;	/* the last 4 to display */
			} else if (*index+4 < ndevs)	{
				/*
				physdial[SLBOX].ob_y += barht / 4;
				*/
				physdial[SLBOX].ob_y += eptht;
				*index += 4;
			}
		} else {	/* ROLL1 */
			if ((*index+5 >= ndevs)||((barht/ndevs)>(bary+barht-epty-eptht))){
				physdial[SLBOX].ob_y = barht - eptht;
				*index = ndevs - 4;	/* the last 4 to display */
			} else {
				physdial[SLBOX].ob_y += barht / ndevs;
				*index += 1;
			}
		}
	} else if (gr_mkmy < epty)	{	/* upper part of bar was clicked */
		if (roll == ROLL4)	{
			if ((eptht > (epty - bary)) || (*index <= 4))	{
				physdial[SLBOX].ob_y = 0;
				*index = 0;
			} else {
				/*
				physdial[SLBOX].ob_y -= barht / 4;
				*/
				physdial[SLBOX].ob_y -= eptht;
				*index -= 4;
			}
		} else {
			if (*index <= 1)	{
				physdial[SLBOX].ob_y = 0;
				*index = 0;
			} else {
				physdial[SLBOX].ob_y -= barht / ndevs;
				*index -= 1;
			}
		}
	} else {
	  return OK;
	}
	objc_draw(physdial,SLTRK, MAX_DEPTH, 0, 0, wdesk, hdesk);
	drawdev(*index);
}


slidebox(tree, index)

OBJECT *tree;
int *index;

{
	int gr_wreturn, eptatmax;
	int ind, tmp;

	ind = ndevs - 4;
	eptatmax = tree[SLTRK].ob_height - tree[SLBOX].ob_height;
	gr_wreturn = graf_slidebox(tree, SLTRK, SLBOX, 1);
	tmp = (ind * gr_wreturn) / 1000;
	if (tmp == *index)	{	/* slide box is in the same place */
		return OK;	
	} else {
		*index = tmp;
	}
	if (*index+4 > ndevs)	{
		*index = ndevs-4;
	} 
	tree[SLBOX].ob_y = (eptatmax * (*index)) / ind;
	objc_draw(tree, SLTRK, MAX_DEPTH, 0, 0, wdesk, hdesk);
	drawdev(*index);
}



/* put the live device into a list */

linkdev()
{

	int i, j=0;

	for (i=0; i<16; i++)	{
		devid[i].flg = 0;
		devid[i].id = &drvid[18][0];
		if (livedevs[i])	{
			devid[j].flg = P_EXISTS;
			devid[j].dev = i;
			if (idevs[i])	{
				devid[j++].id = &drvid[i][0];
			} else {
				devid[j++].id = &drvid[17][0];
			}
		} else if (idevs[i])	{
			devid[j].flg = 2;
			devid[j].dev = i;
			devid[j++].id = &drvid[i][0];
		}
	}
	if ((spscsixst) || (atexst))	{
		devid[j].flg = P_EXISTS;
		devid[j].dev = i;
		devid[j++].id = &drvid[i][0];
	}

	ndevs = j;	/* number of live devices */

}

ggphysdev()
{
    int i, j, endup, start, index=0;
	int ret, unit=8;

	/* Set up the dialog box for SCSI or ACSI or IDE-AT driver selection */
redogphy:
	typedial[SCSIYES].ob_state = NORMAL;
	typedial[ACSIYES].ob_state = NORMAL;
	typedial[IDEYES].ob_state = NORMAL;
	if (!tformat)	{
		/* check which type of unit was selected */
		if ((!ttscsi)&&(!spscsixst)&&(noacsi))	{ /* don't need select */
			index = 16;
			unit = 2;
		} else if ((!ttscsi)&&(!spscsixst)&&(!atexst))	{/* don't need select */
			;
		} else if ((!atexst) && (noacsi))	{ /* don't need select */
			index = 8;
		} else {
			if ((!ttscsi)&&(!spscsixst))	{
				typedial[SCSIYES].ob_state = DISABLED;
			} else if (!atexst)	{
				typedial[IDEYES].ob_state = DISABLED;
			} else if (noacsi)	{
				typedial[ACSIYES].ob_state = DISABLED;
			}
			if ((ret = execform(typedial)) == SCSIYES)	{
				index = 8;
			} else if (ret == IDEYES)	{
				index = 16;
				unit = 2;
			}
		} 
	} else { 	/* do format */
		if ((ret = execform(typedial)) == SCSIYES)	{
			index = 8;
		} else if (ret == IDEYES)	{
			index = 16;
			unit = 2;
		}
	}
    /*
     * Clean up and exec object;
     * shadow devs we KNOW are there.
     */
    physdial[PHYSOK].ob_state = NORMAL;
    physdial[PHYSCN].ob_state = NORMAL;
    
	/*
    if (tformat == TRUE) {
    	start = 1;		start initializing at unit 0 
		physdial[physxlat[0]].ob_state = NORMAL;
    } else {
    	start = 0;		start initializing at unit 1
    }
	*/
    
	endup = index + unit;
	if (index == 16)	{
		physdial[physxlat[0]].ob_state = NORMAL;
		if ((spscsixst) || (atexst))	{
			(physdial[physid[0]].ob_spec)->te_ptext = &drvid[16][0];
		} else {
			(physdial[physid[0]].ob_spec)->te_ptext = &drvid[18][0];
		}
    	for (i = 1; i < 8; i++)	{
			(physdial[physid[i]].ob_spec)->te_ptext = &drvid[18][0];
			physdial[physid[i]].ob_state = DISABLED;
			physdial[physxlat[i]].ob_state = DISABLED;
		}
	} else {
    	for (i = 0; i < 8; i++)	{
			(physdial[physid[i]].ob_spec)->te_ptext = &drvid[18][0];
			if ((spscsixst)&&(tformat)&&(!index))	{
				physdial[physid[i]].ob_state = DISABLED;
				physdial[physxlat[i]].ob_state = DISABLED;
			} else if (tformat)	{	/* when format, all devices are on */
				physdial[physxlat[i]].ob_state = NORMAL;
				physdial[physid[i]].ob_state = NORMAL;
			} else {
				physdial[physid[i]].ob_state = DISABLED;
				physdial[physxlat[i]].ob_state = DISABLED;
			}
		}
	}
	/*
	if (ttscsi)			 the hard drive is a SCSI drive 
		physdial[physxlat[8]].ob_state = NORMAL;
	*/
    for (i = index, j = 0; i < endup; ++i, j++)		{
		if (livedevs[i])	{
		    physdial[physxlat[j]].ob_state = NORMAL | SHADOWED;
			physdial[physid[j]].ob_state = NORMAL;
			if ((i < 16) && (idevs[i]))	{
		    	(physdial[physid[j]].ob_spec)->te_ptext = &drvid[i][0];
			} else if ((i < 16) && (!index))	{
		    	(physdial[physid[j]].ob_spec)->te_ptext = &drvid[17][0];
			}
		}
	}


    if (execform(physdial) != PHYSOK)
		return ERROR;
     
    /* search for the selected unit */
    for (i = 0; i < unit; ++i)
		if (physdial[physxlat[i]].ob_state & SELECTED)	{
	    	return(index+i);
			/*
			if (livedevs[index+i])
	    		return(index+i);
			else	{	
				form_alart(1, nodev);
				goto redogphy;
			}
			*/
		}


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
OBJECT *tree;
{
    form_center(tree,&lx, &ly, &formw, &formh);

	/*
    sx = lx + formw / 2;
    sy = ly + formh / 2;
	*/
    
    form_dial(1, 0, 0, 0, 0, lx, ly, formw, formh);
    objc_draw(tree, 0, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


/*
 *  Erase a dialogue box from the screen.
 *	Input:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
erasemsg()
{
    form_dial(3, 0, 0, 0, 0, lx, ly, formw, formh);
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

changeid(part)
PART *part;
{
	int i;
	long psiz;

	for(i = 0; i < npart; i++)	{
		if (i == ext)	continue;
		if (!(part[i].p_flg & P_EXISTS)) return OK;
		if (i > 3)	{
			psiz = part[i].p_siz - ROOTSECT;
		} else {
			psiz = part[i].p_siz;
		}
		if (psiz < MB16)	{
			part[i].p_id[0] = 'G';
			part[i].p_id[1] = 'E';
			part[i].p_id[2] = 'M';
		} else {
			part[i].p_id[0] = 'B';
			part[i].p_id[1] = 'G';
			part[i].p_id[2] = 'M';
		}
	}
}

