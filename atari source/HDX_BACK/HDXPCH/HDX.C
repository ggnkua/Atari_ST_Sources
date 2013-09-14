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
 */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "bsl.h"
#include "hdxpch.h"
#include "ipart.h"
#include "addr.h"
#include "myerror.h"

#define MFM 17

extern char sbuf[];
extern int rebootp;
extern int yesscan;
extern long disksiz;
extern long ratio;
extern int typedev;
extern int typedrv;
extern int prevnpart;
extern int atexst;		/* set for AT drive exist */
extern int floptical;	/* set if it's a floptical drive */
extern int tformat;		/* 1: called by Format */

/* Globals */
BYTE *bsl;			/* bad sector list */
long bslsiz;			/* num sectors BSL occupies */
SECTOR badbuf[WARNBADSECTS];	/* bad sectors buffer */
int rebootp = 0;	/* 1: must reboot (not return to desktop) */
int tformat;			/* TRUE: just formatted disk */
int running;		/* 1: continue evnt_multi() loop */
char sbuf[512];		/* error message buffer */
long extsiz;		/* the size of extened partition */
long ostack;		/* old stack pointer */
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
			    case DIPART:
		        	if ((needscan)&&(rescan(0,2) == ERROR))	{
						break;	/* don't report medium changed */
					}
					needscan = FALSE;
			        dodipart(-1, NULL, NULL);
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
			    strcpy(abtdial[ABVERSN].ob_spec, "HDX Patch Version 1.00");
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
    int dev, i, ret =OK;
    char *s;
    char bs[512];
    PART *pinfo;
	long disksiz;
	int mask = 0x0001;


    if (xdev < 0) {
	tformat = FALSE;
	if ((dev = gphysdev()) < 0) {
	    return BAILOUT;
	}
	/*
	 * Let the user edit/pick partitions.
	 */
	 if (sfigpart(bs, dev, (PART *)&pinfo) != OK)	{
		if (pinfo > 0)	Mfree(pinfo);
	       return BAILOUT;
	 }

    }

    /* For REAL!! */
    dsplymsg(partmsg);
    
    
    /* Lay out partition headers */
    if (spheader(dev, &pinfo[0]) != OK) {
        ret = ERROR;
        goto partend;
    }
    
    /* Partition the device with parameters given in pinfo */
    if (stlaybs(dev, &pinfo[0]) != OK)
        ret = ERROR;
    else
        ret = OK;
    	
	pnf = 1;		/* set the flag to just doing the partition */
partend:
	inipart(pinfo, npart);
	if (pinfo > 0)	Mfree(pinfo);
    erasemsg();
    return (ret);
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
	int i, ret;
    SECTOR nsect;
    char *devno="X";
    long ndirs;
    UWORD fatsiz;
    BOOT *bs;
	extern long cell();
	char *buf1;
	long size, remsect;
	long datsect;
	long datclst; 
	long fatclst;
	long entsect;

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

	/*
	 * Compute root directory size
	 * 256 entries, plus fudge on devs > 10Mb
	 */
	if (pinfo->p_siz < 0x5000L) ndirs = NUMEN;
	else ndirs = nsect / 80;	/* 1 dir entry per 80 sectors */
	/* round to nearest sector */
	ndirs = (ndirs + ((UWORD)bps/BPDIR - 1)) & ~((UWORD)bps/BPDIR - 1);	

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
	fatsiz = ((((nsect / SPC) + 2) * 2) / bps) + 1;/*bps ?? 512 or 1024*/

	/* Apr-23-93 jye: To fixed the same bug in the Gemdos.
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

		     
		if (buf1 > 0) Mfree((long)buf1);
	}
	return OK;
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
		}
		if (ok2draw)	{
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
			j = devid[i+index].dev;
			if (j < 8)	{
				(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[19+j][0];
			} else if (j < 16)	{
				(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[27+j-8][0];
			} else {
				(physdial[physxlat[i]].ob_spec)->te_ptext = &drvid[35][0];
			}
			(physdial[physid[i]].ob_spec)->te_ptext = devid[i+index].id;
		} else {
			physdial[physxlat[i]].ob_state = DISABLED;
			physdial[physid[i]].ob_state = DISABLED;
		}
		if (ok2draw)	{
			objc_draw(physdial,physxlat[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
			objc_draw(physdial,physid[i], MAX_DEPTH, 0, 0, wdesk, hdesk);
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
			if ((*index+5 >= ndevs) || (eptht > (bary+barht-epty-eptht)))	{
				physdial[SLBOX].ob_y = barht - eptht;
				*index = ndevs - 4;	/* the last 4 to display */
			} else if (*index+4 < ndevs)	{
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
 * Fill the buffer with 0xffff start from giving pointer
 * to the end of buffer.
 */

fillfat(buf, start, size, pattern)
char *buf;
long start;
long size;
int pattern;
{
    long i;	/* index */
    
    for (i = start; i < size; i += 2)
	*(int *)&buf[i] = pattern;
}




/*
 *  Get size of the Bad Sector List (in sectors)
 *	Input:
 *		pdev - physical unit BSL belongs to.
 *	Return:
 *		number of sectors BSL occupies.
 */
long 
gbslsiz(pdev) 
int pdev;	/* physical device number */
{
    char bs[512];	/* boot sector image */
    UWORD  ret;
    
   	if ((ret = getroot(pdev, bs, (SECTOR)0)) != 0) {
   		if (tsterr(ret) == OK)
		    return MDMERR;
		else return ERROR;
   	}
   	if (((RSECT *)(bs + 0x200 - sizeof(RSECT)))->bsl_st != STBSL)
   	    return 0L;
   	return(((RSECT *)(bs + 0x200 - sizeof(RSECT)))->bsl_cnt);
}





