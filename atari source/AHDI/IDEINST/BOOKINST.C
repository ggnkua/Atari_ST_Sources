/* stbkinst.c */

/*
 * Install hard disk driver onto C: of STBook
 *
 * Copyright 1991 Atari Corp.
 * All Rights Reserved.
 *
 * Oct-21-1991	ml.	Created this from HINSTALL 5.00
 */

#include "hinstall.h"
#include "defs.h"
#include "part.h"
#include <gemdefs.h>
#include <osbind.h>


/* Storage wasted for idiotic bindings */
int contrl[12];
int intin[128];
int ptsin[128];
int intout[128];
int ptsout[128];


/* Error messages */
static char *nomemory = "[3][Not enough system memory!|Cannot continue.][   OK   ]";
static char *noavdrv = "[1][No available logical drive |for installation of driver.][   OK   ]";
static char *cantinst = "[1][Cannot install driver!][   OK   ]";
static char *rootread = "[3][Cannot read Root Sector|from the disk!|Try backing up the disk|and reformatting it.][   OK   ]";
static char *rootwrit = "[3][Cannot write Root Sector|to the disk!|Try backing up the disk|and reformatting it.][   OK   ]";
static char *bootread = "[3][Cannot read Boot Sector|from the logical drive!|Try backing up the disk|and reformatting it.][   OK   ]";
static char *bootwrit = "[3][Cannot write Boot Sector|to the logical drive!|Try backing up the disk|and reformatting it.][   OK   ]";
static char *wrdvrerr = "[3][Cannot write driver|file to destination!][   OK   ]";
static char *crdvrerr = "[3][Cannot create driver|file at destination!][   OK   ]";
static char *opdvrerr = "[3][Cannot open driver|source file!][   OK   ]";
static char *drvinstd = "[1][Hard disk driver installed!][   OK   ]";

/* Globals */
long ostack;			/* old system stack */
int *pun;			/* pointer to # of physical units exist */
int *vernum;			/* --> AHDI version #; 0 if not available */


/*
 * Top level;
 *
 */
main()
{
    long *cookptr;	/* pointer to AHDI cookie */

    appl_init();

    Pexec(0, DVRSOURCE, "-s", 0);
    ostack = Super(NULL);	/* Superuser mode for low memory access */
    pun = (int *)(*(long *)PUNPTR);
    Super(ostack);		/* back to User mode */

    if (!pun || !(*pun)) {	/* if no unit exists */
	err(noavdrv);		/* return error */
	goto punt;
    }

    cookptr = (long *)((char *)pun + 2 + 16 + 16*4);
    if (*cookptr != AHDI || cookptr != *(long *)(cookptr + 1))
	vernum = 0L;
    else
	vernum = (int *)(cookptr + 2);

    install();
    
punt:
    appl_exit();		/* exit application HDX */
    Pterm(0);			/* terminate process */
}


/*
 * Install hard disk driver.
 *
 */
install()
{
    int i, pdev, ldev;
    int maxsiz;
    char *s, *d, sdev, dvr[15];
    char *lbuf;
    extern char rootstart, rootend;
    extern char bootstart, bootend;

    /* find maximum sector size on system */
    if (!vernum)	    /* new version of AHDI? */
	maxsiz = 512;	    /* if not, sector size is always 512 bytes */
    else
	maxsiz = *(vernum + 1);	/* max sector size kept after version # */

    if (!(lbuf = Malloc((long)maxsiz))) {
	err(nomemory);
	return ERROR;
    }

    ldev = 0;	    /* C: */
    pdev = 0x10;    /* IDE-AT unit 0 */
    sdev = 'C';
  
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

    /* if gemroot() is not successful, return with error */
    if (gemroot(lbuf, 1) != 0) {
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
    *d++ = *s++;
    *d++ = *s++;
    d += 0x1c;
    s += 0x1c;
    for (i = &bootend-&bootstart-0x1e; i--;)
	*d++ = *s++;

    /* make the image executable */
    Protobt(lbuf, -1L, -1, 1);

    /* write the installed boot sector back to disk */
    if (putboot(ldev, lbuf) != 0) {
	err(bootwrit);
	goto argh;
    }
/*
    err(drvinstd);
/**/
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
 * Copy hard disk driver to root of sdev:
 */
char dvrbuf[BUFSIZ];
copydvr(sdev)
char sdev;
{
    int ih, oh, ret;
    long cnt;
    char dvrdest[15];	/* path name of driver */ 

    if ((ih = Fopen(DVRSOURCE, 0)) < 0)
	return err(opdvrerr);
  
    dvrdest[0] = sdev;
    strcpy(&dvrdest[1], DVRNAME);
    if ((oh = Fcreate(dvrdest, 0)) < 0) {
	ret = err(crdvrerr);
	goto copyr;
    }

    while ((cnt = Fread(ih, BUFSIZ, dvrbuf)) > 0) {
	if (Fwrite(oh, cnt, dvrbuf) != cnt) {
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
 * Throw up an alert box
 * with the given text.
 *
 */
err(s)
char *s;
{
    graf_mouse(ARROW, 0L);
    form_alert(1, s);
    graf_mouse(HOURGLASS, 0L);
    return ERROR;
}



