/* fhdx.c */

/*
 * Atari Hard Disk Installation Utility (Factory Version)
 * Copyright 1988, 1989 Atari Corp.
 *
 * Associated files
 *	fhdx.rsc	resource file
 *	wincap		hard disk database (text file)
 *
 *	fhdx.h		object tree definitions
 *	define.h	constant definitions
 *	part.h		structure definitions
 *
 *	fhdx.c		top level, user interface (this file)
 *	fmt.c		disk formatting
 *	part.c		partition reading/writing
 *	sect.c		sector reading, writing, zeroing
 *	string.c	string functions (matching, concat, ...)
 *	wincap.c	hard disk parameter / partition size database
 *	st.c		random ST functions (delay, reboot, ...)
 *
 *----
 * 19-Jan-1988 ml.	Modified the user version to 'this'.
 * 14-Sep-1989 ml.	Modified to use Lrwabs() instead of hread()
 *			and hwrite().  Will handle both SCSI and
 *			ACSI drives.
 * 20-Jun-1990 ml. 3.8t	Modified to handle NEC drives for AJC.
 *			This is a temporary version only.
 * 10-Jul-1990 ml. 3.8t1   Code revised in fmt.c to handle page code 3 
 *			   of the Mode Select command.
 * 25-Feb-1990 ml. 4.00	Modified to IDE drives in addition to ACSI and 
 *			SCSI.
 */

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include "fhdx.h"
#include "define.h"
#include "part.h"
#include "bsl.h"
#include "deflst.h"
#include "addr.h"
#include "lrwabs.h"


/* Globals */
int rebootp = 0;	/* 1: must reboot (not return to desktop) */
int running;		/* 1: continue evnt_multi() loop */
int maxbadsects;	/* maximum number bad sectors allowed */
int scsixst;		/* 1: SCSI bus exists */
int acsixst;		/* 1: ACSI bus exists */
int idexst;		/* 1: AT bus exists */
char spscsixst;		/* 1: Sparrow SCSI exists */
char cachexst;		/* 1: '030 cache exists */
char blitxst;		/* 1: BLiTTER exists */
char useblit;		/* 1: use BLiTTER */
char sbuf[512];		/* error message buffer */
char bs[512];		/* root sector image */

/* Default values */
int cdev = DEFUNIT;		/* current physical unit */
char cdmdl[16]=DEFDMDL;		/* current disk model */
char cdid[3]=DEFID;		/* id for current disk model */
char cdtype[5]=DEFDTYPE;	/* current disk type (ACSI or SCSI) */
long pattern = DEFPATTERN;	/* test pattern of current disk model */

int pdev;		/* physical unit # of curr physical unit */
int pcode;		/* page code for mode select */
HINFO hinfo;		/* physical parameters of curr disk model */

/* Translate unit number to tree index. */
int acsiphys[] = {
    UNIT0, UNIT1
};
int scsiphys[] = {
    UNIT8, UNIT9
};
int idephys[] = {
    UNIT16, UNIT17
};


static char *rscorrupt = "[3][Fatal Error!|Corrupt Resource File][EXIT]";
long ostack;		/* old stack value */
SECTOR *badbuf;		/* buffer storing bad sectors */

extern long gbslsiz(), nument();
extern char *bsl;
extern long bslsiz;

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
    long dummy;
    int ret, i;
    char *s, *wgetstr();
    extern int chksp();
    extern int chkscsi();
    extern int chkacsi();
    extern int chkide();
    extern int stbook();
    
    running = TRUE;
    appl_init();
    phys_handle=graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
    wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
    open_vwork();
    wi_handle=wind_create(WI_KIND, xdesk, ydesk, wdesk, hdesk);

    hidden = FALSE;
    butdown = TRUE;

    if (!rsrc_load(RESOURCEFILE)) {
	graf_mouse(ARROW, 0L);
	errs("[3][Fatal Error!|Resource file ",
	     RESOURCEFILE,
	     "|not found.][EXIT]");
	goto punt;
    }

    if (getalladdr() == ERROR) {
	corrupt();
	goto punt;
    }

    /* get screen resolution, if LOW, request user to change it to MEDIUM */
    if (!Getrez()) {
	err(midrez);
	goto punt;
    }

    /* Get default unit#, disk type, id and model from wincap 
	if there is any */
    if (wgetent("Parameters", "@@") == OK) {
    	wgetnum("ms", &maxpsiz);		/* get max partition size */
    	if ((s = wgetstr("ty")) != NULL)	/* get disk type */
    	    strcpy(cdtype, s);
    	if (wgetnum("un", &dummy) == OK)	/* get unit # */
	    cdev = (WORD)dummy;
    	if ((s = wgetstr("id")) != NULL)	/* get disk id */
    	    strcpy(cdid, s);
	if ((s = wgetstr("ml")) != NULL)	/* get disk model */
	    strcpy(cdmdl, s);
    }
    
    /* Get parameters of current disk type and model */
    pcode = 0x80;	/* default to Adaptec controller */
    if (gfparm(&pcode, &hinfo, cdmdl, cdid) != OK)
	return ERROR;
	
    /* Get test pattern for selected disk model */
    if (wgetnum("dp", &dummy) == OK)	/* if find one in wincap */
	pattern = dummy;		/*	use that one.	 */
    
    /* Close the wincap file after accessing it */
    wclose();
        	
    /* Calculate maximum number of bad sectors allowed */
    maxbadsects 
    	= (int)hinfo.hi_dhc * hinfo.hi_cc * (int)hinfo.hi_spt / MEGABYTE;

    /* Allocate memory for recording bad sectors */    	
    if ((badbuf = (SECTOR *)mymalloc(maxbadsects << 2)) <= 0L) {
    	ret = err(nomemory);
    	goto punt;
    }

    cachexst = spscsixst = 0;
    scsixst = acsixst = 0;

    /* Check if cache exists */
    cachexst = (char)chkcache();
    
    /* Check if SCSI exists */
    if ((spscsixst = (char)chksp()) || (scsixst = chkscsi())) {
    	physdial[SCSIUNIT].ob_state = NORMAL;
    	for (i = 0; i < MAXPHYSDEV; i++)
    	    physdial[scsiphys[i]].ob_state = NORMAL;
    } else {
    	physdial[SCSIUNIT].ob_state = DISABLED;
    	for (i = 0; i < MAXPHYSDEV; i++)
    	    physdial[scsiphys[i]].ob_state = DISABLED;
    }

    /* Check if AT bus exists */
    if ((idexst = chkide())) {
	if ((blitxst = chkblit()))	    /* check if BLiTTER exists */
/*
	    if (stbook())
		useblit = 0;
	    else
		useblit = 1;
/**/
	    useblit = 0;

    	physdial[IDEUNIT].ob_state = NORMAL;
    	for (i = 0; i < MAXPHYSDEV; i++)
    	    physdial[idephys[i]].ob_state = NORMAL;
    } else {
    	physdial[IDEUNIT].ob_state = DISABLED;
    	for (i = 0; i < MAXPHYSDEV; i++)
    	    physdial[idephys[i]].ob_state = DISABLED;
    }


    /* Check if ACSI bus exists */
    if ((acsixst = chkacsi())) {
    	physdial[ACSIUNIT].ob_state = NORMAL;
    	for (i = 0; i < MAXPHYSDEV; i++)
    	    physdial[acsiphys[i]].ob_state = NORMAL;
    } else {
    	physdial[ACSIUNIT].ob_state = DISABLED;
    	for (i = 0; i < MAXPHYSDEV; i++)
    	    physdial[acsiphys[i]].ob_state = DISABLED;
    }


    if (!idexst && !spscsixst && !scsixst)	/* if no AT or SCSI bus */
    	strcpy(cdtype, "ACSI");			/* may be there is ACSI */
    
    /* default disk type matches what's available? */
    if (!strcmp(cdtype, "SCSI") && (spscsixst || scsixst)) {
	pdev = cdev + 8;		/* phys dev for SCSI */
	physdial[scsiphys[cdev]].ob_state = SELECTED;
    } else if (!strcmp(cdtype, "IDE") && idexst) {
	pdev = cdev + 16;		/* phys dev for AT */
	physdial[idephys[cdev]].ob_state = SELECTED;
    } else if (!strcmp(cdtype, "ACSI") && acsixst) {
	pdev = cdev;			/* phys dev for ACSI */
    	physdial[acsiphys[cdev]].ob_state = SELECTED;
    }
    	
    /* display menu bar */
    menu_bar(menuobj, 1);
    
    /* display current unit and type on menu bar */
    unittype[0].ob_x = wdesk - unittype[0].ob_width;
    unittype[0].ob_y = ydesk - gl_hbox;
    dsply_utbox();
    
    graf_mouse(ARROW, 0L);
    while (running)
    	domulti();

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

    if (badbuf > 0L) free(badbuf);
    wind_delete(wi_handle);
    v_clsvwk(handle);
    appl_exit();
}


/*
 * Get a single event, process it, and return.
 *
 */
domulti()
{
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
	        graf_mouse(HOURGLASS, 0L);
		switch(msgbuff[3]) {
		    case MNDISK:
		    	/*
		        rescan();
		        /**/
			switch (msgbuff[4]) {
			    case SELUNIT:
				dodisunit();
				break;
			    case SELDSK:
				dodisdsk();
				break;
			    case CTRLRTST:
			        dodictrlr();
			        break;
			    case DCHTST:
			        dodidaich();
			        break;
			    case FMTDSK:
			    	dodiform(); 
			    	break;
			    case BRNINTST:
			    	dodibrn();
			    	break;
			    case DEFLST:
			    	dodidef();
			    	break;
			    case SHIPIT:
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
			if(msgbuff[4] == ABOUFHDX) {
			    abtdial[ABOK].ob_state = NORMAL;
			    strcpy(abtdial[VERNUM].ob_spec, "Version 5.00a");
			    execform(abtdial, 0);
			    break;
			}
			break;		/* "cannot happen" */
		}

		menu_tnormal(menuobj, msgbuff[3], 1);	/* back to normal */
	    	graf_mouse(ARROW, 0L);
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
 * Handle [SELECT UNIT] item.
 *
 *	Let user select which unit (0 or 1) to operate on.  The default is
 * DEFUNIT.  The selected unit number will be used until another selection
 * is made.
 */
dodisunit()
{
    int i;

    physdial[PHYSOK].ob_state = NORMAL;
    physdial[PHYSCN].ob_state = NORMAL;

    if (execform(physdial, 0) != PHYSOK)
	return BAILOUT;
    
    /* search for selected unit */
    for (i = 0; i < MAXPHYSDEV; ++i) {
	if (physdial[acsiphys[i]].ob_state & SELECTED) {
	    cdev = pdev = i;		/* for ACSI drives */
	    strcpy(cdtype, "ACSI");
	    dsply_utbox();	    
	    i = MAXPHYSDEV;
	} else if (physdial[scsiphys[i]].ob_state & SELECTED) {
	    cdev = i;
	    pdev = cdev + 8;		/* for SCSI drives */
	    strcpy(cdtype, "SCSI");
	    dsply_utbox();	    
	    i = MAXPHYSDEV;
	} else if (physdial[idephys[i]].ob_state & SELECTED) {
	    cdev = i;
	    pdev = cdev + 16;		/* for IDE drives */
	    strcpy(cdtype, "IDE");
	    dsply_utbox();	    
	    i = MAXPHYSDEV;
	}
    }
}


/*
 * Handle [SELECT DISK MODEL] item.
 *
 *	Let user select the type of disk to operate on.  The selected 
 * disk type will be used until another selection is made.
 */
dodisdsk()
{
    char pnam[16];	/* disk model name */
    char ndid[3];	/* new disk id */
    
    /* inquire disk model */
    strcpy(ndid, "mn");
    if ((ret = dskmdl(pnam, ndid)) != OK)
        return BAILOUT;
        
    
    /* Get parameters of current disk type and model */
    pcode = 0x80;	/* default to Adaptec controller */
    if (gfparm(&pcode, &hinfo, pnam, ndid) != 0)
	return ERROR;
        
    /* Calculate maximum number of bad sectors allowed */
    maxbadsects 
    	= (int)hinfo.hi_dhc * hinfo.hi_cc * (int)hinfo.hi_spt / MEGABYTE;
    	
    /* Allocate memory for recording bad sectors */
    if (badbuf > 0L) free(badbuf);
    if ((badbuf = (SECTOR *)mymalloc(maxbadsects << 2)) <= 0L) {
    	ret = err(nomemory);
    	goto sdskend;
    }

    strcpy(cdid, ndid);		/* update current disk id */
    strcpy(cdmdl, pnam);	/* update current disk model */
    dsply_utbox();		/* update it on screen */
sdskend:
    ;
}


/*
 * Handle [CONTROLLER TEST] item.
 *
 *	To test the controller, do a quick format on 2 cylinders
 * and 2 heads on the disk.
 */
dodictrlr()
{
    int v, dummy;
    HINFO finfo;	/* disk info for controller test */
    
    graf_mouse(HOURGLASS, 0L);
    v = OK;		/* assume everything is just fine */
    
    if (pcode == 0x80) {	/* on an Adaptec controller? */
        /* if so, do format as controller test */
	if (gfparm(&dummy, &finfo, "TESTER", "ct") != 0)
	    return ERROR;
	    
	ostack = Super(NULL);
	if ((v = ms(pdev, &finfo)) == OK) {	    /* mode set */
	    delay();				    /* kludge delay */
	    v = format(pdev, (WORD)finfo.hi_in);    /* format */
	}
    } else {
	ostack = Super(NULL);
    	if (pdev <= 15)				    /* ACSI or SCSI unit */
	    v = untrdy(pdev);			    /* do test unit ready */
	else					    /* AT unit */
    	    v = recal(pdev);			    /* do recalibrate */
    }
    delay();					    /* kludge delay */
    Super(ostack);
    
    if (v != OK) {
    	ctrlfail[CTRLFOK].ob_state = NORMAL;
    	ctrlfail[CTRLFOK].ob_x = (wdesk - ctrlfail[CTRLFOK].ob_width) >> 1;
    	ctrlfail[CTRFTITL].ob_x = (wdesk - ctrlfail[CTRFTITL].ob_width) >> 1;
        execform(ctrlfail, 0);
    } else {
    	ctrlpass[CTRLPOK].ob_state = NORMAL;
    	ctrlpass[CTRLPOK].ob_x = (wdesk - ctrlpass[CTRLPOK].ob_width) >> 1;
    	ctrlpass[CTRPTITL].ob_x = (wdesk - ctrlpass[CTRPTITL].ob_width) >> 1;
        execform(ctrlpass, 0);
    }
}


/*
 * Handle [DAISY CHAIN TEST] item
 */
dodidaich()
{
    int ndev;		/* device chained to */
    long dp;		/* data pattern to test with */
    long sect2rw;	/* number of sectors read from or write to pdev */
    char *buf, *save;	/* buffers for test pattern and saving info on disk */
    OBJECT *result;	/* resulting dialogue to be put up */
    int but;		/* button on result dialogue */
    int title;		/* title line on result dialogue */
    long num;

    graf_mouse(HOURGLASS, 0L);  
    ndev = pdev + 1;	    /* daisy chain unit = pdev + 1 */
    
    /* Find parameters for daisy chain test in wincap */
    if (wgetent("TESTER", "dc") == ERROR) {
    	return err(nodcent);
    }
    if (wgetnum("rw", &num) == OK)	/* number of sectors to test */
        sect2rw = num;
    else sect2rw = 128;			/* default: 64k */
    if (sect2rw > 128) sect2rw = 128;	/* 128 is maximum */
    
    if (wgetnum("dp", &num) == OK)	/* data pattern to test with */
        dp = num;
    else dp = 0xc623d5ab;
    
    /* Close the wincap file after accessing it */
    wclose();
        	
    if ((buf = (char *)Malloc(sect2rw << 9)) <= 0L
    	|| (save = (char *)Malloc(sect2rw << 9)) <= 0L) {
    	if (buf > 0L) Mfree((long)buf);
        return err(nomemory);
    }
    
    /* fill buffer with test pattern */
    fillbuf(buf, (sect2rw << 9), dp);

    /* Read and save data of model unit */
    if (Lrwabs(PHYSREAD, save, (int)sect2rw, 0L, ndev+2) != 0) {
        result = dchrfail;				/* if failed, exit */
    	but = DCHRERR;
    	title = DCHRTITL;
    	goto dchend;
    }
    
    /* Write data (test pattern) to model unit */
    if (Lrwabs(PHYSWRT, buf, (int)sect2rw, 0L, ndev+2) != 0) {
    	result = dchwfail;				/* if failed, exit */
    	but = DCHWERR;
    	title = DCHWTITL;
    	goto dchend;
    }
    
    /* Read data back from model unit */
    if (Lrwabs(PHYSREAD, buf, (int)sect2rw, 0L, ndev+2) != 0) {
        result = dchrfail;				/* if failed, exit */
    	but = DCHRERR;
    	title = DCHRTITL;
    	goto dchend;
    }
    
    /* Test if data read back == test pattern written */
    if (!blktst(buf, dp, (sect2rw << 9))) {
        result = dchdfail;			/* if wrong, exit */
        but = DCHDERR;
        title = DCHDTITL;
        goto dchend;
    }
    
    /* Write original data back to model unit */
    if (Lrwabs(PHYSWRT, save, (int)sect2rw, 0L, ndev+2) != 0) {
    	result = dchwfail;			/* if failed, exit */
    	but = DCHWERR;
    	title = DCHWTITL;
    	goto dchend;
    }
    
    /* Everything is ok */
    result = dchpass;
    but = DCHPOK;
    title = DCHPTITL;
dchend:
    Mfree((long)buf);
    Mfree((long)save);
    result[but].ob_state = NORMAL;	/* display result */
    execform(result, 0);
}



/*
 * Handle [FORMAT] item.
 *
 */
dodiform()
{
    extern char bootstop;
    extern char bootend;
    int v, i, ret;
    long cnt, entries, hdsiz;
    long *a, *b;
    char *s, *d, *wgetstr();
    
    
    /* Get size of Bad Sector List */
    bslsiz = gbslsiz(pdev);
        
    bsl = 0L;
    if (bslsiz > 0) {
	/* Allocate memory for existing BSL */
	if ((bsl = (BYTE *)mymalloc((int)bslsiz << 9)) <= 0) {
	    ret = err(nomemory);
	    goto fmtend;
	}
      
	/* Read in BSL */
	if (rdbsl(pdev) != OK) {
	    /* Create a new BSL if current one is unusable */
	    if (creabsl(pdev, NEW, 0L) != OK) {
		ret = ERROR;
		goto fmtend;
	    }
	} else {
	    entries = nument(VENDOR);
	    if (creabsl(pdev, EXPAND, entries) != OK) {
		ret = ERROR;
		goto fmtend;
	    }
	}
    } else {
	if (creabsl(pdev, NEW, 0L) != OK) {
	    ret = ERROR;
	    goto fmtend;
	}
    }
  
    /*
     * In supervisor mode
     * set disk format parameters
     * and format the disk.
     */
    v = OK;			/* assume everything is ok */
    hdsiz = 0L;			/* initialise size to zero */
    
    /* For REAL !! */  
    graf_mouse(HOURGLASS, 0L);
    dsplymsg(fmtmsg);
    ostack = Super(NULL);	/* go to super mode */
    if (pcode != -1) {		/* if need to do mode select */
	if (pcode == 0x80) {  	/* on an Adaptec controller? */
	    v = ms(pdev, &hinfo);	/* if yes, do Adaptec mode select */
	} else {			/* if no, do SCSI mode select */
	    v = scsims(pdev, &hinfo, pcode, &hdsiz);
	}
    }
    
    delay();					    /* kludge delay */
    if (v == OK) {
	if (pdev <= 15)				    /* ACSI or SCSI unit */
	    v = format(pdev, (WORD)hinfo.hi_in);    /* format */
	else					    /* IDE unit */
	    v = fmtunt(pdev);
    }
    delay();					/* kludge delay */
    Super(ostack);				/* back to user mode */
    rebootp = 1;
    erasemsg();		/* wipe out format message on screen */
    
    if (v != 0) {
	ret = err(cantform);
	goto fmtend;
    }

    /* Do a little test just to make sure root sector is OK */
rdagain:
    if ((ret = getroot(pdev, sbuf)) == ERROR) {
	if (form_alert(1, 
		"[1][Read from root sector timed out!][ Retry | Quit ]")
		== 1) {
	    goto rdagain;
	}
    } else if (ret > 0) {
    	err("[1][Check condition status returned on read!][   OK   ]");
    	errcode(pdev);
    }
    
    /* Write BSL back to disk */  
    if ((ret = wrbsl(pdev)) != OK) {
    	/*
	goto fmtend;
	/**/
    }

    /*
     * Install format parameters and boot-stopper in sector image;
     * write root sector to device.
     */
    fillbuf(bs, 512L, 0L);		/* make a clean root sector */
    sfmtparm(bs, &hinfo);		/* set soft format parms */
    					/* record disk type */
    strcpy((RSECT *)(bs + 0x200 - sizeof(RSECT))->hd_type, cdmdl);
    					/* record disk size */
    if (!hdsiz) {
	hdsiz = (long)hinfo.hi_cc * (long)hinfo.hi_dhc * (long)hinfo.hi_spt;
    }
    (RSECT *)(bs + 0x200 - sizeof(RSECT))->hd_siz = hdsiz;
    sbslparm(bs);			/* set BSL parameters */
    for (d = bs, s = &bootstop, cnt = &bootend - &bootstop; --cnt;)
	*d++ = *s++;
  
    Protobt(bs, -1L, -1, 1);		/* make root sector executable */
    if ((ret = putroot(pdev, bs)) == ERROR) {
	ret = err(rootwrit);
	errcode(pdev);
	goto fmtend;
    }

    /* Do a little test just to make sure root sector is OK */
    if ((ret = getroot(pdev, sbuf)) == ERROR) {
	ret = err(rootread);
	errcode(pdev);
    	goto fmtend;
    }  
    
    /* Compare root sector read in has the same data as those written in */
    a = (long *)bs;
    b = (long *)sbuf;
    for (i = 0; i < 512; i+=4, a++, b++) {
        if (*a != *b) {
            ret = err(rootbad);
            goto fmtend;
        }
    }
    
    /* 
     * Partition the device (using the default partition)
     */
    /*
    free(bsl);
    /**/
    if ((ret = dodipart()) < 0) {
    	if (ret == USRFULL)
            ret = err(deffull);
        goto fmtend;
    }
    ret = OK;
fmtend:
    if (bsl > 0L) free(bsl);
    return ret;
}



/*
 * Just partition pdev using the default partition scheme of cdmdl
 *
 */
dodipart()
{
    int  spc, i, ret =OK;
    PART pinfo[4];
    long hdsiz;

    graf_mouse(HOURGLASS, 0L);
    dsplymsg(partmsg);
    
    if (getroot(pdev, bs) != OK) {
	ret = err(rootread);
	errcode(pdev);
	goto partend;
    }

    /* find hard disk size */
    hdsiz = ((RSECT *)(bs + 0x200 - sizeof(RSECT)))->hd_siz;
    
    /* allow 1 bad sector per Mb */
    maxbadsects = hdsiz / MEGABYTE;

    if (wgetent(cdmdl, "pr") != OK) {	/* if can't find entry */
    	erasemsg();
    	strcpy(nopart[NOSCHPR].ob_spec, cdmdl);
	nopart[NOSCHPOK].ob_state = NORMAL;
	execform(nopart, 0);
	return ERROR;
    }

    for (i = 0; i < NPARTS; ++i)
	fillpart(i, &pinfo[i]);
	    
    /* Close the wincap file after accessing it */
    wclose();
        	
    /* Get size of BSL */
    /*
    bslsiz = gbslsiz(pdev);
    
    bsl = 0L;
    if (bslsiz > 0) {
    	if ((bsl = (BYTE *)mymalloc((int)(bslsiz << 9))) <= 0) {
    	    ret = err(nomemory);
    	    goto partend;
    	}
    	    
    	if ((ret = rdbsl(pdev)) != OK) {
    	    if (ret == INVALID)
    	        err(cruptbsl);
    	    ret = ERROR;
    	    goto partend;
    	}
    } else if (bslsiz < 0) {
        ret = err(rootread);
        errcode(pdev);
        goto partend;
    } else {
        ret = err(notfmtd);
        goto partend;
    }
    /**/
    
    /* Lay out partition headers */
    spc = hinfo.hi_dhc * hinfo.hi_spt;
    if (pheader(pdev, pinfo, spc) != OK) {
        ret = ERROR;
        goto partend;
    }

    if (nument(VENDOR) > maxbadsects) {
        ret = USRFULL;
        goto partend;
    }    
    
    if ((ret = wrbsl(pdev)) != OK) {		/* write BSL */
    	goto partend;
    }
    
    /*
     * Shove partition parms into root sector.
     */
    spart(bs, pinfo);
    sbslparm(bs);			/* set BSL parameters */
    Protobt(bs, -1L, -1, 1);		/* make root sector executable */
    if (putroot(pdev, bs) != OK) {
    	ret = err(rootwrit);
    	errcode(pdev);
    	goto partend;
    }

    rebootp = 1;
    
    /* Partition the device with parameters given in pinfo */
    rescan();
    /* dopart() displays its own error msg */
    if (dopart(pdev, hinfo.hi_spt, pinfo, hdsiz) < 0)
        ret = ERROR;
    else
	ret = OK;
partend:
    /*
    if (bsl > 0L) free(bsl);
    /**/
    rescan();
    erasemsg();
    return (ret);
}


/*
 *  Physical Markbad for Disk Testing.
 */
dodibrn()
{
    int  done=0, ret;
    int  but, title;		/* button and title of result dialogue */
    OBJECT *result;

    graf_mouse(HOURGLASS, 0L);

    /* Get size of Bad Sector List */
    bslsiz = gbslsiz(pdev);
        
    bsl = 0L;
    if (bslsiz > 0) {
	/* Allocate memory for existing BSL */
	if ((bsl = (BYTE *)mymalloc((int)bslsiz << 9)) <= 0L) {
	    ret = err(nomemory);
	    goto brnend;
	}
      
	/* Read in BSL */
	if (rdbsl(pdev) != OK) {
	    /* Create a new BSL if current one is unreadable */
	    if (creabsl(pdev, NEW, 0L) != OK) {
	        ret = ERROR;
	        goto brnend;
	    }
	} else {
            /* Remove USER BSL */
      	    if (creabsl(pdev, EXPAND, nument(VENDOR)) != OK) {
      	        ret = ERROR;
      	        goto brnend;
      	    }
	}
    } else if (bslsiz == 0) {
	ret = err(notfmtd);
	goto brnend;
    } else {	/* bslsiz < 0 */
        ret = err(rootread);
        errcode(pdev);
        goto brnend;
    }

    /* save the root sector */
    if (getroot(pdev, bs) != OK) {
    	ret = err(rootread);	/* cannot read root sector */
    	errcode(pdev);
    	goto bfail;
    }  
    
    ret = dsmarkbad(&hinfo, pdev, pattern);
    if (wrbsl(pdev) != OK) {
    	ret = ERROR;
    	goto bfail;
    }
    
    sbslparm(bs);			/* set BSL parameters */        
    if (putroot(pdev, bs) == ERROR) {	/* put root sector back to disk */
    	ret = err(rootwrit);
    	errcode(pdev);
    	goto bfail;
    }
    
    if (ret >= 0 && ret <= maxbadsects) {
    	/*
	if (bsl > 0L) free(bsl);
	/**/
	if(dodipart() < 0)
	    goto bfail;

	/* set up result box for passing disks */
	result = dskpass;
	but = BRNPASS;
	title = BRNPTITL;
	goto dsply;
    }
    
bfail:
    /* set up result box for failing disks */
    result = dskfail;
    but = BRNFAIL;
    title = BRNFTITL;
dsply:
    result[but].ob_state = NORMAL;
    execform(result, 0);

    /*
    if (bsl > 0L) free(bsl);
    /**/
    if ((bslsiz = gbslsiz(pdev)) > 0)
	dsplybsl(pdev, (UWORD)hinfo.hi_dhc, (UWORD)hinfo.hi_spt);

brnend:
    if (bsl > 0L) free(bsl);
    return ret;
}


/*
 *  Key-in bad sector list in terms of physical block address.
 *  (i.e. head number, cylinder number and byte offset from index)
 *  Sector numbers are calculated and added to the BSL.
 */
dodidef()
{
    int done=0, ret=0;
    int pbps;
    extern int npndefs;		/* number of defects entered */
    
    /* Get size of Bad Sector List */
    bslsiz = gbslsiz(pdev);	/* always device 0 */
        
    bsl = 0L;
    if (bslsiz > 0) {
	/* Allocate memory for existing BSL */
	if ((bsl = (BYTE *)mymalloc((int)bslsiz << 9)) <= 0) {
	    ret = err(nomemory);
	    goto defend;
	}
	
	/* Read in BSL */
	if (rdbsl(pdev) != OK) {
	    /* Create a new BSL if current one is unusable */
	    if (creabsl(pdev, NEW, 0L) != OK) {
		ret = ERROR;
		goto defend;
	    }
	    goto defstrt;
	} else {
	    if (!(nument(VENDOR)))
	        goto defstrt;
	}
	
    	/* Ask if they want to keep existing one */
    	keepdefs[KEEPYES].ob_state = NORMAL;
    	keepdefs[KEEPNO].ob_state = NORMAL;
    	if (execform(keepdefs, 0) == KEEPNO) {
	    if (creabsl(pdev, NEW, 0L) != OK) {
		ret = ERROR;
		goto defend;
	    }
	}
    } else if (bslsiz == 0) {
	ret = err(notfmtd);
	goto defend;
    } else {	/* bslsiz < 0 */
        ret = err(rootread);
        errcode(pdev);
        goto defend;
    }
defstrt:
    if (figtst() != NPUTSTRT) {
        ret = BAILOUT;
        goto defend;
    }

    /* Figure out maximum bytes per track of media */
    if (hinfo.hi_spt == 0x11) {	/* 17 spt: disk is MFM format */
        fmt = MFM;
    	pbps = BPSMFM;
    } else {	       			/* disk is RLL format */
        fmt = RLL;
    	pbps = BPSRLL;
    }
        
    /* Find maximum size of head, cylinder and byte offset */
    maxpaddr.head = (unsigned int)hinfo.hi_dhc;
    maxpaddr.cylndr = (unsigned)hinfo.hi_cc;
    if (tst == MFM)
        maxpaddr.btoffst = BPTMFM;
    else
        maxpaddr.btoffst = BPTRLL;

    /* Let user input defects */
    if (nputdeflst() != OK) {
    	ret = ERROR;
        goto defend;
    }
    
    /* Give user chances to examine and modify the defects entered */
    while (TRUE) {
	askxam[XAMXAM].ob_state = NORMAL;
	askxam[XAMSAVE].ob_state = NORMAL;
	askxam[XAMQUIT].ob_state = NORMAL;
	if ((ret = execform(askxam, 0)) == XAMXAM) {	/* Examine defects */
	    if (!npndefs) {
		err(defemp);	/* defect list is empty */
	    } else {
	    	graf_mouse(ARROW, 0L);
		xamdeflst();
	    }
	} else {
	    break;
	}
    }
    
    if (ret == XAMQUIT) {
        ret = OK;
        goto defend;
    }
        
    /* Check if any defect is actually entered */
    if (npndefs) {
        /* Calculate sector numbers from input defects and add them to BSL */
        if((npndefs = calcsect(&hinfo, pbps)) < 0) {
            ret = ERROR;
            goto defend;
        }
        
        /* Add sector numbers to BSL */
        if ((ret = addbsl(pdev, VENDOR, npndefs)) < 0) {
            ret = ERROR;
            goto defend;
        }
    }

    /* Read root sector */    
    if (getroot(pdev, bs) != OK) {
	ret = err(rootread);
	errcode(pdev);
    	goto defend;
    }  
    sbslparm(bs);		/* set BSL parameters */
    /* Put root sector back to disk, and repartition disk. */
    if (putroot(pdev, bs) == ERROR) {
        ret = err(rootwrit);
        errcode(pdev);
        goto defend;
    }
        
    if ((ret = wrbsl(pdev)) != OK) {
    	goto defend;
    }
    
    /*	
    free(bsl);
    /**/
    if ((ret = dodipart()) < 0) {
    	if (ret == USRFULL)
            ret = err(deffull);
        goto defend;
    }
    ret = OK;
defend:
    if (bsl > 0L) free(bsl);
    return ret;
}


/*
 *  Ship the disk.
 */
dodiship()
{
    if (pdev <= 15) {		/* only ship when unit is ACSI or SCSI */
	graf_mouse(HOURGLASS, 0L);
	ship(pdev);
	err(scommand);
    }
}



/*
 * Display current unit and current disk type on menu bar.
 */
dsply_utbox()
{
    strcpy(unittype[CURRTYPE].ob_spec, cdtype);
    itoa(cdev, unittype[CURRUNIT].ob_spec->te_ptext);
    strcpy(unittype[CURRMDL].ob_spec->te_ptext, cdmdl);
    objc_draw(unittype, 0, MAX_DEPTH, xdesk, unittype[0].ob_y, wdesk, 
    		hdesk+gl_hbox);
}
    		
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
 *  Request the disk type from user.
 */
dskmdl(name, ent_id)
char name[];
char ent_id[];
{
    char devnames[NAMSIZ];	/* device type name buffer */
    char *s;
    int  i, br, ret;
    
    br = 0;			/* not processing a branch */
inqfmt:
    /* Get all available disk types from wincap 'ent_id' entries */  
    if (wallents(devnames, ent_id) != OK) {
        ret = ERROR;
        goto dskend;
    }
  
    /* Shove format name text into buttons */
    for (i = 0, s = devnames; i < 15 && *s; ++i) {
	dsknames[pfmt[i]].ob_type = G_BUTTON;	/* buttons */
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
	dsknames[pfmt[i]].ob_flags = NONE;	/* disabled */
    }
  
    /* clean up rest of the form and throw it up */
    dsknames[PFOK].ob_state = NORMAL;
    dsknames[PFCN].ob_state = NORMAL;
    if (execform(dsknames, 0) != PFOK) {
	ret = BAILOUT;
	goto dskend;
    }
  
    /* search for format they picked */
    for (i = 0; i < 15; ++i)
	if (dsknames[pfmt[i]].ob_state & SELECTED)
	    break;
	    
    if (i >= 15) {
    	ret = BAILOUT;			/* nothing picked */
    	goto dskend;
    }
    
    if (!br) {
	if (wgetent(dsknames[pfmt[i]].ob_spec, "mn") == ERROR) {
    	    strcpy(nofmt[NOSCHFMT].ob_spec, dsknames[pfmt[i]].ob_spec);
    	    nofmt[NOSCHFOK].ob_state = NORMAL;
    	    execform(nofmt, 0);
	    ret = ERROR;
	    goto dskend;
	}
    
	if ((s = wgetstr("br")) != NULL) {
	    strcpy(ent_id, s);	/* id for branch */
	    br = 1;		/* processing the branch */
	    goto inqfmt;	/* start over */
	}
    }
    strcpy(name, dsknames[pfmt[i]].ob_spec);
    ret = OK;
    
dskend:
    /* Close the wincap file after accessing it */
    wclose();
        	
    return ret;
}
  

/*
 * Open virtual workstation.
 *
 */
open_vwork()
{
    int i;

    for (i = 0; i < 9;)
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

    wind_update(TRUE);
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
	    temp[0] = xdesk;
	    temp[1] = ydesk;
	    temp[2] = xdesk + wdesk - 1;
	    temp[3] = ydesk + hdesk - 1;
	    v_bar(handle, temp);
	}
	wind_get(wi_handle, WF_NEXTXYWH, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
    }

    show_mouse();
    wind_update(FALSE);
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
 * Complain about corrupt resource file
 * and setup to return to the desktop.
 *
 */
corrupt()
{
    err(rscorrupt);				/* complain */
    running = FALSE;				/* stop multi calls */
    return ERROR;				/* bubble up complaint */
}


/*
 * "Execute" form,
 * return thingy that caused the exit.
 *
 */
execform(tree, st_ob)
OBJECT tree[];
int st_ob;
{
    int thingy;

    graf_mouse(ARROW, 0L);
    dsplymsg(tree);
    thingy = form_do(tree, st_ob);
    erasemsg();
    graf_mouse(HOURGLASS, 0L);
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
    if ((lx = (wdesk - formw) / 2) < 0)
        lx = xdesk;
    if ((ly = (hdesk - formh) / 2) < 0)
        ly = ydesk;
    
    tree[0].ob_x = lx;
    tree[0].ob_y = ly;
    
    form_dial(0, sx, sy, 0, 0, lx, ly, formw, formh);
    objc_draw(tree, 0, MAX_DEPTH, xdesk, ydesk, wdesk, hdesk);
}


/*
 *  Erase a dialogue box from the screen.
 *	Input:
 *		formw, formh, sx, sy, lx, ly - dimensions of box.
 */
erasemsg()
{
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

