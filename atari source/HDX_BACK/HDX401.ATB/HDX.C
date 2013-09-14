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
 *	ipart.h		IBM structure definitions
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
 *
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
extern long gbslsiz();
extern long bslsiz;
extern BYTE *bsl;
extern int yesscan;
extern long disksiz;
extern long ratio;

/* Globals */
int rebootp = 0;	/* 1: must reboot (not return to desktop) */
int tformat;			/* TRUE: just formatted disk */
char sbuf[512];		/* error message buffer */
long extsiz;		/* the size of extened partition */
long ostack;				/* old stack pointer */
long bps;			/* bytes per sector */
int npart;			/* number of partition */
int ext;			/* the index of extended partition */
int extend;			/* the index of end extended partition */
int needscan;		/* TRUE: if info in the LOGMAP update */
int athead;			/* the # of data heads on the AT drive */
int atcyl;			/* the # of cylinders on the AT drive */
int atspt;			/* the # of sectors per track on the AT drive */

/*  Logical-to-dev+partition mapping table. */
extern char cachexst;		/* 0: no cache. 1: with cache */

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

    rsrc_load(RESOURCEFILE);
    /* Get all addresses of dialogues from resource file */
    getalladdr();

	needscan = TRUE;

   	if (domulti() != 11)
		reboot();

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
	int skipit = 11;
    
    		wind_update(TRUE);
	        BEE_MOUSE;
		    if (rescan(0,0) != OK) {
				errs("[3][|", CANTFMT, "][ EXIT ]");
				ret = skipit;
				goto fnshfmt;
			}
			tformat = TRUE;
			needscan = FALSE;
			if ((ret = dodiform()) != OK)	{
				if (ret == ERROR)
					errs("[3][|", CANTFMT, "][ EXIT ]");
				else
					ret = skipit;
			} else {
				errs("[0][| |", OKFMT, "][ EXIT ]");
			}
	fnshfmt:
			tformat = FALSE;
	   		wind_update(FALSE);
			return(ret);
}



/*
 * Handle [FORMAT] item.
 *
 */
dodiform()
{
  extern char bootstop;
  extern char bootend;
  int dev, v, w, i, ret;
  int modesel;			/* flag for mode select */
  long cnt, hdsiz;
  char *s, *d, *wgetstr();
  char buf[10], bs[512]; 
  char *seldev =  "IDE  unit 0";
  long nbad;
  extern long gbslsiz(), nument(), dsmarkbad();
  long pattern, temp;
  long longrandom();
  int set, bsiz;
  
  /*
   * Throw up generic formatting/partition warning,
   * then get physical dev they want to clobber.
   */
  yesscan = 0;
  fwarning[FWARNCN].ob_state = NORMAL;
  fwarning[FWARNOK].ob_state = NORMAL;
  if (execform(fwarning) != FWARNOK) return 10;
  dev = 0;
  pattern = longrandom();  /* can't find pattern from wincap, make one */

  /* For REAL !! */  
  dsplymsg(fmtmsg);
  bsl = 0L;
  
  /* Get size of Bad Sector List */
  if ((bslsiz = gbslsiz(dev)) > 0L) {
      /* Allocate memory for existing BSL */
      if ((bsl = (BYTE *)mymalloc((int)bslsiz*512)) <= 0) {
          ret = ERROR;
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
  if ((ret = fmtunt(dev)) != OK)	{
      ret = ERROR;
  } else {
  	hdsiz = athead*atcyl*atspt;
	disksiz = hdsiz;
  }
  delay();
  Super(ostack);
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
  ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz =disksiz;
  for (d = bs, s = &bootstop, cnt = (long)(&bootend - &bootstop); --cnt;)
    *d++ = *s++;
  Protobt(bs, -1L, -1, 1);	/* make root sector executable */
  
  if ((ret = putroot(dev, bs, (SECTOR)0)) != OK) {
      return ERROR;
  }

  return (dodipart(dev, disksiz));
}




/*
 * Handle [PARTITION] item;
 * if `xdev' is -1, throw up dialog boxes;
 * if `xdev' >= 0, just partition the dev,
 * using `pnam' as the partition type, 
 * and `pr_id' to search for the type.
 *
 */
dodipart(xdev, hsize)
int xdev;
long hsize;
{
    int dev, i, ret =OK, fine;
	int choice;
    char *s;
    char bs[512];
    PART *pinfo;
	int tem1, tem2;
	long disksiz;

	npart = 4;
	ext = NO_EXT;	/* set the extended partition flag to not exists */
	dev = xdev;
	if ((pinfo = (PART *)Malloc((long)sizeof(PART)*npart)) <= 0)	{
		if (pinfo > 0)	Mfree(pinfo);
		return ERROR;
	}
	inipart(pinfo, npart);
	npart = 0;
	setpart(pinfo, hsize);

    /* For REAL!! */
    dsplymsg(partmsg);
    bsl = 0L;
    
    /* Get size of BSL */
    if ((bslsiz = gbslsiz(dev)) > 0L) {
    	/* Allocate memory for existing BSL */
    	if ((bsl = (BYTE *)mymalloc((int)bslsiz*512)) <= 0) {
    	    ret = ERROR;
    	    goto partend;
    	}
    	    
    	/* Read in BSL */
    	if ((ret = rdbsl(dev)) != OK) {
    	    ret = ERROR;
    	    goto partend;
    	}
    } else if (bslsiz == 0) {
    	ret = ERROR;
		goto partend;
    } else if (bslsiz == ERROR) {
        ret = ERROR;
        goto partend;
    } else {
        ret = ERROR;
		goto partend;
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
		ret = ERROR;
		goto partend;
	}

	if ((ret = stlayroot(bs, dev, pinfo)) != OK)	{
		goto partend;
	}
	tem1 = npart;			/* save the number of partitions */
	tem2 = ext;				/* save the index of extended partition */
    if (rescan(1,0)) {		/* has to be here because map changed	*/
    	ret = ERROR;		/* after partitions are moved around,	*/
    	goto partend;		/* report medium change error.		*/
    }
	npart = tem1;
	ext = tem2;
    /* Partition the device with parameters given in pinfo */
    ret = stlaybs(dev, &pinfo[0]);
    	
    rebootp = 1;
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
	sbslparm(bs);				/* set bsl parameters */
	Protobt(bs, -1L, -1, 1);		/* make root sector executable */
    if ((ret = putroot(dev, bs, (SECTOR)0)) != OK) {
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
		if (putroot(dev, bs, part[i].p_st) != OK) {
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
	char *buf;
	long size;

    if ((bslsiz = gbslsiz(physdev)) < 0L) {
        return ERROR;
    }
    /* SCAN_BS: pinfo is for scan() and laybs() use */
	if (ext != NO_EXT)	sortpart(pinfo, SCAN_BS);	

    for (i = 0; i < npart; ++i, ++pinfo) {
    	
    	/* don't care if partition does not exist */
		if (!(pinfo->p_flg & P_EXISTS)) {
		    return OK;
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
	 *	= Num entries in FAT / (512 / 2)    <16-bit FAT>	*
	 *	= ((partition's size in sectors / spc) + 2) / 256 + 1	*
	 *					    <+1 to round up>	*
	 *--------------------------------------------------------------*/
	fatsiz = ((((nsect / bs->b_spc) + 2) * 2) / bps) + 1;
	iw((UWORD *)&bs->b_spf[0], (UWORD)fatsiz);

	/* write the serial number to the bs */ 
	Protobt(bs, 0x01000000, -1, -1);

	/*
	 * Write partition's boot sector
	 */
	forcesum((UWORD *)buf, (UWORD)0);	/* force image checksum */
	if ((ret = wrsects(physdev,(UWORD)ratio,buf,(SECTOR)pinfo->p_st))!= OK) {
	    return ERROR;
	}

	/*
	 * Zero the partition
	 */
	if ((ret = zerosect(physdev, (SECTOR)(pinfo->p_st+ratio),
		     ((UWORD)((fatsiz*2 + ndirs*BPDIR/bps) * ratio)))) != OK) {
	    return ERROR;
	}
		     
	/*
	 * Make first 2 entries in FATs more IBM-like.
	 */
	if ((ret = rdsects(physdev,(UWORD)ratio,buf,
						(SECTOR)(pinfo->p_st+ratio)))!= 0){
	    return ERROR;
	}
	*(UWORD *)&buf[0] = 0xf8ff;
	*(UWORD *)&buf[2] = 0xffff;
	if ((ret = wrsects(physdev,(UWORD)ratio,
						buf,(SECTOR)(pinfo->p_st+ratio)))!= 0 ||
	    (ret = wrsects(physdev,(UWORD)ratio,buf,
						(SECTOR)(pinfo->p_st+ratio+fatsiz*ratio)))
	    != 0) {
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
				return ERROR;
			data = (SECTOR)1 + (SECTOR)(fatsiz*2) + (SECTOR)(ndirs*BPDIR/bps);
			bsl2fat(ldev, (SECTOR)ratio, (UWORD)(fatsiz*ratio), 
												data*ratio, MEDIA);
		}
		if (buf > 0) Mfree((long)buf);
	}
	return OK;
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

