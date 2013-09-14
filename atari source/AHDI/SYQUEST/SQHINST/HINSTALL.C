/* hinstall.c */

/*
 * Install hard disk driver on hard disk
 *
 * Copyright 1988 Atari Corp.
 * All Rights Reserved.
 *
 * Jul-18-1989	ml.	Have to mask off bits that don't correspond
 *			to unit number when using the pun structure.
 */

#include "hinstall.h"
#include "defs.h"
#include "part.h"
#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>


/*  AES (windows and messages) related variables */
int gl_hchar;		/* height of system font (pixels) */
int gl_wchar;		/* width of system font (pixels) */
int gl_wbox;		/* width of box able to hold system font */
int gl_hbox;		/* height of box able to hold system font */

int phys_handle;	/* physical workstation handle */
int handle;		/* virtual workstation handle */
int wi_handle;		/* window handle */
int top_window;		/* handle of topped window */

int xdesk, ydesk, hdesk, wdesk;	/* window X, Y, width, height */
int xold, yold, hold, wold;
int xwork, ywork, hwork, wwork;	/* desktop and work areas */

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

/* User interface variables */
/* Dialogue boxes */
extern OBJECT *menubar;		/* menu bar */
extern OBJECT *about;		/* release date of this version */
extern OBJECT *logdev;		/* logical device numbers */
extern OBJECT *instfnl;		/* final warning for installing driver */
extern OBJECT *unstfnl;		/* final warning for removing driver */

/* Error messages */
extern char *nomemory;		/* not enough memory */
extern char *noavdrv;		/* no available drive for installation */
extern char *cantinst;		/* cannot install driver */
extern char *rootread;		/* root sector read error */
extern char *rootwrit;		/* root sector write error */
extern char *bootread;		/* boot sector read error */
extern char *bootwrit;		/* boot sector write error */
extern char *wrdvrerr;		/* error when writing driver */
extern char *crdvrerr;		/* error when creating driver destination */
extern char *opdvrerr;		/* error when opening driver source */
extern char *nodriver;		/* no existing driver on disk */

/* Globals */
static char *rscorrupt = "[3][Fatal Error!|Corrupt Resource File][EXIT]";
char sbuf[512];			/* error message buffer */
int running;			/* 1: continue evnt_multi() loop */
int physdev[MAXLOGDEVS];	/* physical unit # for the logical drives */

long ostack;			/* old system stack */
int *pun;			/* pointer to # of physical units exist */
int *vernum;			/* --> AHDI version #; 0 if not available */


/*
 * Top level;
 * we get control from the desktop.
 *
 */
main()
{
    long *cookptr;	/* pointer to AHDI cookie */

    running = TRUE;
    appl_init();
    phys_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
    wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
    open_vwork();
    wi_handle = wind_create(WI_KIND, xdesk, ydesk, wdesk, hdesk);
  
    hidden = FALSE;
    butdown = TRUE;
  
    if (!rsrc_load(RESOURCEFILE)) {
	errs("[2][", RESOURCEFILE, "][ OK ]");
	goto punt;
    }
  
    graf_mouse(ARROW, 0L);
  
    /* display menu bar */
    if (getalladdr() == ERROR) {
	errs("[2][", RESOURCEFILE, "][ OK ]");
	goto punt;
    }
  
    ostack = Super(NULL);	/* Superuser mode for low memory access */
    pun = (int *)(*(long *)PUNPTR);
    Super(ostack);		/* back to User mode */

    if (!(*pun)) {		/* if no unit exists */
	err(noavdrv);		/* return error */
	goto punt;
    }

    cookptr = (long *)((char *)pun + 2 + 16 + 16*4);
    if (*cookptr != AHDI || cookptr != *(long *)(cookptr + 1))
	vernum = 0L;
    else
	vernum = (int *)(cookptr + 2);

    menu_bar(menubar, 1);	/* put up menu bar */
  
    while (running)
	domulti();
    
    menu_bar(menubar, 0);	/* erase menu bar */
  
punt:
    wind_delete(wi_handle);	/* close window on screen */
    v_clsvwk(handle);		/* close virtual workstation */
    appl_exit();		/* exit application HDX */
    Pterm(0);			/* terminate process */
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
  
    if (event & MU_MESAG)
        switch (msgbuff[0]) {
	    case WM_REDRAW:
		do_redraw(msgbuff[4],msgbuff[5],msgbuff[6],msgbuff[7]);
		break;
	
	    case WM_NEWTOP:
	    case WM_TOPPED:
		wind_set(wi_handle, WF_TOP, 0, 0, 0, 0);
		break;
	
	    case WM_CLOSED:
		running = FALSE;
		break;
	
	    case MN_SELECTED:
		graf_mouse(HOURGLASS, 0L);
		switch(msgbuff[3]) {
		    case MNDESK:
			if(msgbuff[4] == DEABOUT) {
			    strcpy((about[ABVERSN].ob_spec)->te_ptext, "3.00");
			    about[ABOK].ob_state = NORMAL;
			    execform(about);
			    }
			break;		/* "cannot happen" */

		    case MNFILE:
			switch (msgbuff[4]) {
			    case FIQUIT:	/* [QUIT] item */
				running = 0;
				break;

			    case FIINST:	/* [INSTALL] item */
				install();
				break;
		
			    case FIUNINST:	/* [UNINSTALL] item */
				uninstall();
				break;
			}
			break;
		}
		menu_tnormal(menubar, msgbuff[3], 1); /* back to normal */
        	graf_mouse(ARROW, 0L);	/* restore mouse */
		break;
	}
}


/*
 * Install hard disk driver.
 *
 */
install()
{
    int i, pdev, ldev, gem;
    int maxsiz;
    char *s, *d, sdev, dvr[15];
    char *lbuf;
    extern char rootstart, rootend;
    extern char bootstart, bootend;

    if ((ldev = glogdev()) < 0) 
	return BAILOUT;
  
    /* final warning */
    sdev = ldev + 'C';
    (instfnl[INSTDRV].ob_spec)->te_ptext = &sdev;
    instfnl[INSTOK].ob_state = NORMAL;
    instfnl[INSTCN].ob_state = NORMAL;
    if (execform(instfnl) != INSTOK) return BAILOUT;

    /* find maximum sector size on system */
    if (!vernum)	    /* new version of AHDI? */
	maxsiz = 512;	    /* if not, sector size is always 512 bytes */
    else
	maxsiz = *(vernum + 1);	/* max sector size kept after version # */

    if (!(lbuf = Malloc((long)maxsiz))) {
	err(nomemory);
	return ERROR;
    }

    /* find which physical unit the chosen logical drive belongs to */
    pdev = physdev[ldev];
    pdev &= 0x0f;		/* mask off extra bits */
      
    /* Remove old driver if there is one */
    dvr[0] = sdev;
    strcpy(&dvr[1], OLDDVR);
    if (!(Fsfirst(dvr, 0x04)))	/* 0x04 = system files */
	Fdelete(dvr);
          
  
    /* copy driver to specified unit */
    if (copydvr(sdev) != OK)
	return ERROR;

    /* read in the root sector */
    if (getroot(pdev, lbuf) != 0) {
	err(rootread);
	goto argh;
    }
  
    /* copy boot code into root sector */
    for (d = lbuf, s = &rootstart, i = &rootend - &rootstart; i--;)
	*d++ = *s++;

    /* determine if root sector is of GEMDOS or MSDOS format */
    if (*((int *)(lbuf + 0x200 - 2)) != 0x55aa) {
	ret = gemroot(lbuf, 1);	 /* it has a GEMDOS root sector */
	gem = TRUE;
    } else {
	ret = msroot(lbuf, 1);	 /* it has a MSDOS root sector */
	gem = FALSE;
    }
	  
    /* if gemroot() or msroot() is not successful, return with error */
    if (ret) {
	err(cantinst);
	goto argh;
    }

    /* write installed root sector back to disk */  
    if (putroot(pdev, lbuf) != 0) {
	err(rootwrit);
	goto argh;
    }

    /* read boot sector from partition */
    if (getboot(ldev, lbuf) != 0) {
	err(bootread);
	goto argh;
    }

    /* 
     * copy boot code to boot sector, avoiding the BPB information 
     * copy bytes 0..1 for BRA.S to code;
     * leave bytes 2..$1d unaltered (information for BPB);
     * copy bytes $1e..$1fe for code.
     */
    s = &bootstart;
    d = lbuf;
    *d++ = 0xeb;
    *d++ = 0x34;
    *d++ = 0x90;
    *d++ = 0;
    *d++ = *s++;
    *d++ = *s++;
    d += 0x18;
    s += 0x18;
    for (i = &bootend-&bootstart-0x1a; i--;)
	*d++ = *s++;

    /* make the image executable */
    if (gem)
	Protobt(lbuf, -1L, -1, 1);	/* GEMDOS boot sector */
    else
	msprotobt((UWORD *)lbuf, 1);	/* MSDOS boot sector */

    /* write the installed boot sector back to disk */
    if (putboot(ldev, lbuf) != 0) {
	err(bootwrit);
	goto argh;
    }

    return;

argh:
    dvr[0] = sdev;
    strcpy(&dvr[1], DVRNAME);
    Fdelete(dvr);
}


/*
 * gemroot(buf, flg)
 * char buf[]
 * int flg	(0: clear boot bit;  non-0: set boot bit)
 */
gemroot(buf, flg)
char buf[];
int flg;
{
    GEMPART *gpart, *gpart1;
    int pno;

    /* point to beginning of partition map */
    gpart = gpart1 = &((RSECT *)(buf + 0x200 - sizeof(RSECT)))->hd_p[0];

    /* clear all boot bits */
    for (pno = 0; pno < NPARTS; pno++, gpart1++) {
	gpart1->p_flg &= ~P_BOOTBIT;
    }

    if (!flg) {
	Protobt(buf, -1L, -1, 1);
	return OK;
    }

    /* find the first valid partition and set its boot bit */
    for (pno = 0; pno < NPARTS; pno++, gpart++) {
	if (gpart->p_flg & P_EXISTS &&
	    gpart->p_siz) { 		/* if partition exists */
	    if ((gpart->p_id[0] == 'G' &&	/* and it's a GEM partition */
	    	 gpart->p_id[1] == 'E' &&
	    	 gpart->p_id[2] == 'M') ||
		(gpart->p_id[0] == 'B' &&
		 gpart->p_id[1] == 'G' &&
		 gpart->p_id[2] == 'M')) {
	    	gpart->p_flg |= P_BOOTBIT;	/* set the boot bit */
	    	Protobt(buf, -1L, -1, 1);	/* make image executable */
	    	return OK;			/* return successful */
	    }
	}
    }
    return ERROR;	/* if cannot find valid partition, return error */
}


/*
 * msroot(buf, flg)
 * char buf[]
 * int flg	(0: clear boot bit;  non-0: set boot bit)
 */
msroot(buf, flg)
char buf[];
int flg;
{
    MSPART *mpart, *mpart1;
    int pno;

    /* point to beginning of partition map */
    mpart = mpart1 = &((MSMBR *)(buf + 0x200 - sizeof(MSMBR)))->ms_p[0];

    /* clear all boot bits */
    for (pno = 0; pno < NPARTS; pno++, mpart1++) {
	mpart1->b_ind = 0;
    }
  
    if (!flg) {
	msprotobt((UWORD *)buf, 0);
	return OK;
    }

    /* find the first valid partition and set its boot bit */
    for (pno = 0; pno < NPARTS; pno++, mpart++) {
	if ((mpart->s_ind == 0x01	/* if it's a Prim-DOS partition */
	    || mpart->s_ind == 0x04)
	    && mpart->n_sect) {		/* and it's size is > 0 */
	    mpart->b_ind = P_BOOTBIT;	/* set the boot bit */
	    msprotobt((UWORD *)buf, 0);	/* make image executable */
	    return OK;			/* return successful */
	}
    }
    return ERROR;	/* if cannot find valid partition, return error */
}


/*
 * msprotobt(image, rb)
 * 
 * - make an MSDOS sector image executable on an ST
 *   (i.e. check sum sector to 0x1234)
 */
msprotobt(image, rb)
UWORD *image;
int rb;		/* 0: for root sector;  non-0: for boot sector */
{
    register int i;
    register UWORD sum;
    UWORD *buf;

    if (!rb)			/* if image is a root sector */
	/* point to the 2 bytes right before the partition map */
	buf = &((MSMBR *)((char *)image + 0x200 - sizeof(MSMBR)))->chksum;
    else			/* if image is a boot sector */
	buf = image + 3;	/* checksum word at 6th and 7th bytes */

    /* initialize checksum word to 0 */
    *buf = 0;

    /* check sum entire image */
    for (i = 0, sum = 0; i < 256; ++i)
	sum += *image++;

    *buf = 0x1234 - sum;	/* add in the amount needed */
}


/*
 *  Remove bootable driver from hard disk.
 */
uninstall()
{
    int i, pno;
    int dev, ldev;
    char sdev;
    char sect[512];
    long ostack;
    char dvr[15];	/* entire path name of driver has at most 17 char */ 

    if ((ldev = glogdev()) < 0) 
	return BAILOUT;
  
    /*
     * Make sure they're sure...
     */
    sdev = ldev + 'C';
    (unstfnl[UNSTDRV].ob_spec)->te_ptext = &sdev;
    unstfnl[UNSTOK].ob_state = NORMAL;
    unstfnl[UNSTCN].ob_state = NORMAL;
    if (execform(unstfnl) != UNSTOK) return BAILOUT;

    /* find which physical unit the chosen logical drive belongs to */
    dev = physdev[ldev];
    dev &= 0x0f;		/* mask off extra bits */
      
    /* remove driver from disk */
    dvr[0] = sdev;
    strcpy(&dvr[1], DVRNAME);
    if (Fdelete(dvr)) {
	strcpy(&dvr[1], OLDDVR);
	if (Fdelete(dvr)) {
	    err(nodriver);
	    goto back;
	}
    }
  
    /* unset boot bit of partition */
    if (getroot(dev, sect) != 0) {
	err(rootread);
	goto back;
    }

    /* determine if root sector is of GEMDOS or MSDOS format */
    if (*((int *)(sect + 0x200 - 2)) != 0x55aa) {
	ret = gemroot(sect, 0);	 /* it has a GEMDOS root sector */
    } else {
	ret = msroot(sect, 0);	 /* it has a MSDOS root sector */
    }
  
    if (putroot(dev, sect) != 0) {
	err(rootwrit);
	goto back;
    }

    /* set bootdev to A: for future warm resets */
    ostack = Super(0L);
    *(int *)BOOTDEV = 0;
    Super(ostack);
back:
    ;
}



/*
 * Copy hard disk driver to root of ldev:
 */
copydvr(sdev)
char sdev;
{
    int ih, oh, ret;
    long cnt;
    char buf[BUFSIZ];
    char dvrdest[15];	/* path name of driver */ 

    if ((ih = Fopen(DVRSOURCE, 0)) < 0)
	return err(opdvrerr);
  
    dvrdest[0] = sdev;
    strcpy(&dvrdest[1], DVRNAME);
    if ((oh = Fcreate(dvrdest, 0)) < 0) {
	ret = err(crdvrerr);
	goto copyr;
    }

    while ((cnt = Fread(ih, BUFSIZ, buf)) > 0) {
	if (Fwrite(oh, cnt, buf) != cnt) {
	    ret = err(wrdvrerr);
	    goto copyr;
	}
    }
    ret = OK;		/* got here with no error */

copyr:
    Fclose(ih);
    Fclose(oh);
    if (ret) Fdelete(dvrdest);
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
	    temp[0] = xwork;
	    temp[1] = ywork;
	    temp[2] = xwork + wwork - 1;
	    temp[3] = ywork + hwork - 1;
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
 * "Execute" form,
 * return thingy that caused the exit.
 *
 */
execform(tree)
     OBJECT tree[];
{
    int thingy;
    WORD formw, formh;
    WORD lx, ly, sx, sy; 
  
    formw = tree[0].ob_width;
    formh = tree[0].ob_height;
  
    sx = wdesk / 2;
    sy = hdesk / 2;
    lx = (wdesk - formw) / 2;
    ly = (hdesk - formh) / 2;
  
    tree[0].ob_x = lx;				/* set form's location */
    tree[0].ob_y = ly;
  
    graf_mouse(ARROW, 0L);
    form_dial(0, sx, sy, 0, 0, lx, ly, formw, formh);
    form_dial(1, sx, sy, 0, 0, lx, ly, formw, formh);
    objc_draw(tree, 0, MAX_DEPTH, 0, 0, wdesk, hdesk);
    thingy = form_do(tree, 0);
    form_dial(2, sx, sy, 0, 0, lx, ly, formw, formh);
    form_dial(3, sx, sy, 0, 0, lx-3, ly-3, formw+4, formh+4);
    graf_mouse(HOURGLASS, 0L);
    return thingy;
}


/*
 * Complain about corrupt resource file
 * and setup to return to the desktop.
 *
 */
corrupt()
{
    err(rscorrupt);	/* complain */
    running = FALSE;	/* stop multi calls */
    return ERROR;	/* bubble up complaint */
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
    char *puntbl;	/* ptr to physical unit table */
    int cpun;		/* current physical unit number */
    int clun;		/* current logical unit number */
    int i;		/* index */

    /* assume no drives exist */
    for (i = 0; i < MAXLOGDEVS; i++) {
	logdev[logxlat[i]].ob_state = DISABLED;
    }

    /* find out mapping of physical units to logical drives */
    /* and selectively enable drive buttons */
    puntbl = (char *)(pun + 2);	/* puntbl -> pun(C:) */
    cpun = -1;			/* start with a bad physical unit # */

    /* logical drive is selectable only if it belongs to a valid */
    /* physical unit and it is the first partition of the unit */
    for (i = 0;
	 (i < MAXLOGDEVS) && ((int)(*puntbl) != -1); 
	 i++, puntbl++) {
	if (cpun != (int)(*puntbl)) {
	    cpun = (int)(*puntbl);
	    logdev[logxlat[i]].ob_state = NORMAL;
	}
	physdev[i] = cpun;	/* remember which pun it belongs to */
    }

    logdev[LOGOK].ob_state = NORMAL;
    logdev[LOGCN].ob_state = NORMAL;

    if (execform(logdev) != LOGOK) return -1;

    for (i = 0; i < MAXLOGDEVS; ++i)
	if (logdev[logxlat[i]].ob_state & SELECTED)
	    return i;

    return -1;
}



