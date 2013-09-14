/*
 *  Dsmark.c
 *	Routines for performing a destructive markbad.
 */

/*
 * 23-Nov-87	ml.	just started.
 * 20-Jan-88	ml.	modified for factory version.
 * 14-Sep-89	ml.	Modified to use Rwabs() instead of hread() 
 *			and hwrite().  Will handle both SCSI and
 *			ACSI drives.
 */

#include <obdefs.h>
#include <gemdefs.h>
#include <osbind.h>
#include "fhdx.h"
#include "define.h"
#include "part.h"
#include "bsl.h"
#include "addr.h"
#include "lrwabs.h"

extern SECTOR *badbuf;

extern long addbsl();
extern long nument();
extern int wdesk, hdesk;
extern int maxbadsects;

/* Globals */
char *inbuf;    	/* data write to disk */
char *readbuf;  	/* data read from disk */
int  quitted;		/* 1: Disk testing quit by user */
int  totbad;		/* total num of bad sectors found */
unsigned long pattern;	/* data pattern to test disk with */
long spc;		/* sectors per cylinder */
int  pdev;		/* phys dev num */
int  bad0;		/* TRUE: cylinder 0 is bad */




/*
 *  Destructive Markbad for entire device.
 *	Mechanism:
 *		- write data to entire device, read it back, and compare
 *		  if there is any difference. (done in markdev())
 *		- all new bad sectors are added to the bad sector list.
 *		  (done in markdev())
 *		- repeat above for the number of passes passed in.
 *	Input:
 *		hinfo - information about the device to be marked bad.
 *			e.g. num cylinders, sectors per track, etc....
 *		device - physical device number.
 *		dp - data pattern to test the disk with.
 *	Output:
 *		bsl - bad sector list with added entries if any. (in bsl.h)
 *	Return:
 *		totbad - total number of bad sectors found.
 *		ERROR - if any of the first 3 sectors is bad, or not enough
 *			memory for buffer.
 */
dsmarkbad(hinfo, device, dp)
HINFO *hinfo;		/* hard disk info */
int device;		/* phys dev num */
unsigned long dp;	/* data pattern to test disk */
{
    long bpc;		/* num bytes per cylinder on disk */
    int ret;		/* return code from markdev() */
    unsigned int pass;	/* num passes thru the disk */
    long  temp;		/* for shifting data pattern */
    char numbuf[10];	/* ascii for pass */
    char passbuf[10];

    /* Number of sectors per cylinder */
    spc = (long)hinfo->hi_dhc * (long)hinfo->hi_spt;
    bpc = spc*512L;	/* Number of bytes per cylinder */
    pattern = dp;	/* pattern to test disk with */
    pdev = device;	/* device to mark */
    
    /* Allocate big chunk of memory enough for both buffers,
       and split it in two */
    if ((inbuf = (char *)Malloc(bpc << 1)) <= 0) {
    	err(nomemory);
    	return NOMEM;
    }
    readbuf = inbuf + bpc;

    /* Throw up message box to inform user about 
       the processing of the burn-in test.  */
    brninmsg[NUMPASS].ob_spec = "0";
    brninmsg[CYLNUM].ob_spec = "0";
    totbad = (int)nument(VENDOR);
    itoa(totbad, numbuf);
    brninmsg[NUMBAD].ob_spec = numbuf;
    dsplymsg(brninmsg);
         
    pass = 1;		/* about to start pass 1 */     
    temp = 0;
    quitted = 0;	/* procedure not quitted yet */
    
    /* Loop forever until some specified key is hit */
    while (1) {
	fillbuf(inbuf, bpc, pattern);
    	itoa(pass, passbuf);
    	brninmsg[NUMPASS].ob_spec = passbuf;
    	objc_draw(brninmsg, PASSBOX, MAX_DEPTH, 0, 0, wdesk, hdesk);
    	if ((ret = markdev(hinfo->hi_cc))
    		< 0) {
    	    goto wrapup;
	} else {
	    if (quitted) {
	    	ret = totbad;
	        goto wrapup;
	    }
	}
	pass++;
	
	/* Shift data pattern */
	temp = pattern >> 28;
	pattern = (pattern << 4) | temp;
    }
wrapup:
    erasemsg();
    Mfree((long)inbuf);
    return (ret);
}


/*
 *  Fill up a character buffer with the given pattern.
 *	Input:
 *		buf - buffer to be filled.
 *		size - size of buffer in bytes.
 *		dp - a 4-byte data to fill the buffer.
 *	Output:
 *		buf - buffer filled with the given pattern.
 */
fillbuf(buf, size, dp)
char *buf;
long size;
long dp;
{
    long i;	/* index */
    
    for (i = 0L; i < size; i += 4L)
	*(long *)&buf[i] = dp;
}


/*
 *  Markdev - Find bad sectors on a hard disk and record them in the Bad
 *	      Sector List.
 *	Mechanism:
 *		- write some given data to the entire device cylinder by
 *		  cylinder.
 *		- read from the device cylinder by cylinder but in reverse
 *		  order.
 *		- as data are read from the device, compare the written data
 *		  with the data read.  
 *		- if there is any write, read or data error in a sector, that
 *		  sector will be considered bad.  (data error means data read
 *		  is different from data written.)
 *		- add the bad sectors to the bad sector list.
 *	Input:
 *		cyl - number of cylinders on the device. 
 *	Output:
 *		bsl - an updated bad sector list (ie. with newly found bad
 *		      sectors added to it).
 *	Return:
 *		ERROR - Any sector in cylinder 0 is bad.
 *		      - Number of bad sectors 
 *				> Maximum number of bad sectors allowed.
 *	Comments:
 *		To test both the media and the mechanics of the disk:
 *	- on even cycles we'll do a sequential test.
 *	  (i.e. markbad cylinder 0 --> last cylinder sequentially.)
 *	- on odd cycles we'll do a random test.
 *	  (i.e. seek to random cylinder and markbad that one.)
 *
 */
markdev(cyl)
int cyl;	/* num cylinders on device */
{
    unsigned int halfcyl, sechalf;	/* counter */
    int ret;				/* return code from markcyl() */

    sechalf = halfcyl = cyl >> 1;    
    if (cyl % 2)
        halfcyl++;

    /* Markbad first half of device */
    if ((ret = markhalf(halfcyl, 0)) < 0)
        return ret;
    if (quitted)
        return OK;
        
    /* Markbad second half of device */
    if ((ret = markhalf(halfcyl, sechalf)) < 0)
        return ret;
    return OK;
}



/*
 *  Markbad half of a device.
 */
markhalf(numcyl, stcyl)
unsigned int numcyl;	/* number of cylinders in half a device */
unsigned int stcyl;	/* starting cylinder number for that half device */
{
    unsigned int cylcnt, cyl1, cyl2;
    char numbuf[10];
    int ret;
    
    cyl1 = stcyl;
    cylcnt = numcyl >> 1;
    cyl2 = stcyl + cylcnt;
    if (numcyl % 2)
        cylcnt++;
        
    while (cylcnt) {
	itoa(cyl1, numbuf);
	brninmsg[CYLNUM].ob_spec = numbuf;
	objc_draw(brninmsg, CYLBOX, MAX_DEPTH, 0, 0, wdesk, hdesk);
	if ((ret = markcyl(cyl1)) < 0) {
	    return ret;
	}
	else if (quitted) {
	    /* Test cylinder 0 again */
	    if ((ret = markcyl(0)) < 0)
	        return ret;
	    return OK;
	}
	cyl1++;
	
	itoa(cyl2, numbuf);
	brninmsg[CYLNUM].ob_spec = numbuf;
	objc_draw(brninmsg, CYLBOX, MAX_DEPTH, 0, 0, wdesk, hdesk);
	if ((ret = markcyl(cyl2)) < 0) {
	    return ret;
	}
	else if (quitted) {
	    /* Test cylinder 0 again */
	    if ((ret = markcyl(0)) < 0)
	        return ret;
	    return OK;
	}
	cyl2++;
	cylcnt--;
    }
    return OK;
}


/*
 *  Mark bad one cylinder.
 *	Input:
 *		cylnum - cylinder to be tested.
 *	Output:
 *		bsl - an updated bad sector list (ie. with newly found bad
 *		      sectors added to it).
 *	Return:
 *		ERROR - Any sector in cylinder 0 is bad.
 *		      - Number of bad sectors 
 *				> Maximum number of bad sectors allowed.
 *	Comments:
 *	    This procedure could be interrupted by the following keycodes:
 *		Ctrl-S - Suspend running of procedure.
 *		Ctrl-Q - Quit from procedure.
 *		Ctrl-R - Restore running of procedure.
 */
markcyl(cylnum)
unsigned int cylnum;	/* cylinder number */
{
    long olderr, crerr();
    SECTOR start, stcnt;	/* where to start writing or reading */
    unsigned int sectcnt;	/* counters */
    unsigned int nbad;		/* num bad sectors so far */
    int ret;			/* return code */
    int clean;			/* indicate if cylinder has any bad sector */
    BYTE key;			/* keyboard input */
    char chkeybd();
    
    olderr = Setexc(0x101, crerr);  /* Handle critical error ourselves */
    
    	
    /*------------------------------------------------------------*/
    /*  Write lots of sectors (one cylinder worth) at a time.     */
    /*  If write error, loop through sectors within that cylinder */
    /*  to find out exactly which sector(s) is bad, and add it to */
    /*  the bad sector list if it's not already there.		  */
    /*------------------------------------------------------------*/
    
    bad0 = FALSE;	/* cylinder 0 is not bad */
    ret = OK;		/* everything is OK now... */
        
    /* Check for keyboard input */
    if ((key = chkeybd()) != NOKEY && key != CTRLR) {
	if (key == CTRLS) {
	    while (1) {
	        if ((key = chkeybd()) == CTRLR || key == CTRLQ)
	    	    break;
	    }
	}
	if (key == CTRLQ) {
	    quitted = 1;
	    ret = OK;
	    goto badnews;
	}
    }
	
    start = (SECTOR)cylnum * spc;
    
    nbad = 0;	/* no bad sectors found yet */
    if (Lrwabs(PHYSWRT, inbuf, (unsigned int)spc, start, pdev+2) != 0) {
        sectcnt = (unsigned int)spc;
        stcnt = start;
        while (sectcnt) {
    	    if (Lrwabs(PHYSWRT, inbuf, 1, stcnt, pdev+2) != 0) {
     	    	*(badbuf+nbad) = stcnt;	/* store bad sector num */
     	    	nbad++;
  	        if (stcnt < spc) {
  	            bad0 = TRUE;
  	       	    ret = err(cyl0bad);
  	    	    goto addwr;
  	    	}
    	    }
    	    stcnt++;
    	    sectcnt--;
    	}
    }

addwr:
    if (nbad) {	/* there are bad sectors found not added to BSL yet */
	if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
	    goto badnews; 
	}
	if (ret > 0) {
	    totbad += ret;	/* increment num bad sectors existing */
	    prnbad();
	}
	if (totbad > maxbadsects || bad0 == TRUE) {
	    ret = ERROR;
	    goto badnews;
	}
    }
    
    /*-----------------------------------------------------------*/
    /* Read lots of sectors (one cylinder worth) at a time.      */
    /* If read error, loop through sectors within that cylinder  */
    /* to find out exactly which sector(s) is bad, and add it to */
    /* the bad sector list if it's not already there.		 */
    /*								 */
    /* Data read is compared to data written.  If there is any   */
    /* discrepancy within a sector, mark that sector as bad in   */
    /* the bad sector list.					 */
    /*-----------------------------------------------------------*/

    /* Check for keyboard input */
    if ((key = chkeybd()) != NOKEY && key != CTRLR) {
	if (key == CTRLS) {
	    while (1) {
	        if ((key = chkeybd()) == CTRLR || key == CTRLQ)
	    	    break;
	    }
	}
	if (key == CTRLQ) {
	    quitted = 1;
	    ret = OK;
	    goto badnews;
	}
    }
	
    nbad = 0;	/* no bad sectors for this cylinder yet */
    fillbuf(readbuf, spc<<9, 0L);
    if (Lrwabs(PHYSREAD, readbuf, (unsigned int)spc, start, pdev+2) != 0) {
	sectcnt = (unsigned int)spc;
    	stcnt = start;
    	while (sectcnt) {
	    fillbuf(readbuf, 512L, 0L);
    	    if (Lrwabs(PHYSREAD, readbuf, 1, stcnt, pdev+2) != 0) {
     	    	*(badbuf+nbad) = stcnt;	/* store bad sector num */
     	    	nbad++;
    	        if (stcnt < spc) {
    	            bad0 = TRUE;
    	            ret = err(cyl0bad);
  	    	    goto addrd;
  	    	}
    	    } else {
    	        if (!blktst(readbuf, pattern, 512L)) {
    	    	    *(badbuf+nbad) = stcnt;    /* store bad sector num */
    	    	    nbad++;
    	            if (stcnt < spc) {
    	            	bad0 = TRUE;
  	    		ret = err(cyl0bad);
  	    	    	goto addrd;
  	    	    }
    	    	}
    	    }
    	    stcnt++;
    	    sectcnt--;
    	}
    	clean = 0;
    } else {
        clean = 1;
    }
    	
addrd:
    if (nbad) { /* there are bad sectors found not added to BSL yet */
        if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
    	    goto badnews;
    	}
    	if (ret > 0) {
    	    totbad += ret;	/* incr num bad sectors added to BSL */
    	    prnbad();
    	}
	if (totbad > maxbadsects || bad0 == TRUE) {
	    ret = ERROR;
	}
    } else if (clean) {
    	/* Check for keyboard input */
    	if ((key = chkeybd()) != NOKEY && key != CTRLR) {
	    if (key == CTRLS) {
		while (1) {
	    	    if ((key = chkeybd()) == CTRLR || key == CTRLQ)
	    		break;
		}
	    }
	    if (key == CTRLQ) {
		quitted = 1;
		ret = OK;
		goto badnews;
	    }
	}
	
	/* compare data read with data written, record bad sectors if any */
    	if ((ret = cmpdata(start)) > 0) {
    	    totbad += ret;	/* incr num bad sectors added to BSL */
    	    prnbad();
	    if (totbad > maxbadsects || bad0 == TRUE) {
		ret = ERROR;
		goto badnews;
	    }
    	} else {
    	    goto badnews;
    	}
    }
badnews:
    Setexc(0x101, olderr);
    if (ret < 0)	    /* if an error occurs, */
        return(ret);	    /*    return the error */
    else return OK;    /* else return number of bad sectors found. */
}



/*
 *  Compare data read with data written of a cylinder, and mark sectors
 *  with data error in the bad sector list.
 *	Input:
 *		start - starting physical sector number of the cylinder.
 *	Output:
 *		bsl - an updated bad sector list with the newly found bad
 *		      sectors marked in it.
 */
cmpdata(start)
SECTOR start;	/* phys sect num of where cylinder starts */
{
    unsigned int cnt;		/* index into databuf, counter */
    int nbad;			/* num bad sectors found so far */
    int mbad;			/* total num bad sectors found in cylinder */
    int ret;			/* return code from addbsl() */
    char *buf;
    
    mbad = nbad = 0;	/* no bad sectors found yet */
    
    /* Test whole cylinder first, if OK, ship it.  
       Return 0L if no bad sectors found. */
    if (blktst(readbuf, pattern, spc<<9))
        return 0;
        
    buf = readbuf;
    for (cnt = 0; cnt < spc; cnt++) {
    	if (!blktst(buf, pattern, 512L)) {
	    *(badbuf+nbad) = start + cnt;	/* store bad sector num */
	    nbad++;
	    if ((start+cnt) < spc) {
	    	bad0 = TRUE;
	    	err(cyl0bad);
	    	goto addcd;
	    }
	}
	buf += 512L;
    }
addcd:
    if (nbad) {	/* bad sectors found but not added to BSL yet */
        if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
            return ret;
        }
        mbad += ret;	/* incr num bad sectors added to BSL */
    }
    return(mbad);
}



 
/*
 *  Update number of bad sectors found during Destructive Markbad in
 *  the dialogue box.
 */
prnbad()
{
    char numbuf[10];
    
    itoa(totbad, numbuf);
    brninmsg[NUMBAD].ob_spec = numbuf;
    objc_draw(brninmsg, NBADBOX, MAX_DEPTH, 0, 0, wdesk, hdesk);
}


/*
 *  Check if any key is input from the keyboard.
 *	Key code looking for:
 *		Ctrl-S - Suspend running of procedure.
 *		Ctrl-Q - Quit from procedure.
 *		Ctrl-R - Restore running of procedure.
 *		Any other or no key - no effect.
 *	Return:
 *		NOKEY - if no key is input, or key input is not
 *			what we are looking for.
 *		CTRL? - where ? could be S, Q or R.
 */
char
chkeybd()
{
    char key;		/* key being input */
 
    if (Bconstat(2)) {		/* 2: CONSOLE */
    	if((key = Bconin(2)) != CTRLS
    	   && key != CTRLQ
    	   && key != CTRLR)
    	key = NOKEY;
    } else {
    	key = NOKEY;
    }
    return key;
}
