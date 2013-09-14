/*
 *  Dsmark.c
 *	Routines for performing a destructive markbad.
 */
 
/* 23-Nov-87	ml.	just started.	
 * 11-Nov-88    jye. change and add codes so that can be used for MS-DOS.
 * 08-Aug-89	jye. change the max size of buffer for memory check.
 */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "bsl.h"
#include "hdx.h"
#include "addr.h"

extern SECTOR badbuf[];		/* bad sectors buffer */

extern int wdesk, hdesk;
extern long nument();
long sysize;				/* system memory size */

/*
 *  Destructive Markbad for entire device.
 *	Mechanism:
 *		- write data to entire device, read it back, and compare
 *		  if there is any difference. (done in markdev())
 *		- all new bad sectors are added to the bad sector list.
 *		  (done in markdev())
 *		- repeat above for the number of passes passed in.
 *	Input:
 *		pdev - physical device number.
 *		hdsiz - size of hard disk in sectors.
 *		pass - number of passes to be performed.
 *		pattern - data pattern to test the disk with.
 *	Output:
 *		bsl - bad sector list with added entries if any. (in bsl.h)
 *	Return:
 *		totbad - total number of bad sectors found.
 *		ERROR - if any of the first 3 sectors is bad, or not enough
 *			memory for buffer.
 */

long
dsmarkbad(pdev, hdsiz, pass, pattern)
int pdev;	/* phys dev num */
long hdsiz;	/* hard disk size */
int pass;	/* num cycles */
long pattern;	/* data pattern to test disk */
{
    char *inbuf;  	/* buffer to hold data to be written to the disk */
    char numbuf[10];
    long totbad;  	/* total num of bad sectors found */
    long ret;	  	/* return code from markdev() */
    long markdev();

    
    /* Allocate memory for biggest data buffer necessary */
    if ((sysize = Malloc(-1L)) <= 0)	{
    	return err(nomemory);
	}
	if ((sysize/512L) > MAXBUFSECT)	 /*the max # of sector for hread() is 254*/ 
		sysize = MAXBUFSECT * 512;	 /*convert to bytes */

    if ((inbuf = (char *)Malloc(sysize)) <= 0)
    	return err(nomemory);

    /* Throw up message box to inform user about 
       the processing of destructive markbad.  */
    totbad = nument(VENDOR);  /* Number of existing VENDOR bad sectors */
    ltoa(totbad, numbuf);
    (dmrkmsg[OLDBAD].ob_spec)->te_ptext = numbuf;
    strcpy((dmrkmsg[NEWBAD].ob_spec)->te_ptext, "0");  /* 0 new bad sector */
    dmrkmsg[DMRKBAR].ob_width = 0;		    /* haven't started yet */
    dsplymsg(dmrkmsg);
         
    totbad = 0;	/* no NEW bad sectors yet */    	
    /* Loop for given number of passes */
    while (pass) {
    	if ((ret = markdev(pdev, hdsiz, inbuf, pattern)) < 0) {
    	    ret == ERROR;
	} else {
	    totbad += ret;
	}
    	pass--;
    }
wrapup:
    erasemsg();
    Mfree((long)inbuf);
    if (ret < 0)
        return (ret);
    return(totbad);
}


/*
 *  Fill up a character buffer with the given pattern.
 *	Input:
 *		buf - buffer to be filled.
 *		size - size of buffer in bytes.
 *		pattern - a 1-byte data to fill the buffer.
 *	Output:
 *		buf - buffer filled with the given pattern.
 */
fillbuf(buf, size, pattern)
char *buf;
long size;
long pattern;
{
    long i;	/* index */
    
    for (i = 0; i < size; i += 4)
	*(long *)&buf[i] = pattern;
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
 *		pdev - physical device number.
 *		hdsiz - size of hard disk in sectors.
 *		databuf - buffer with the testing data.
 *		pattern - data pattern to test with.
 *	Output:
 *		bsl - an updated bad sector list (ie. with newly found bad
 *		      sectors added to it).
 *	Return:
 *		totbad - total number of bad sectors found.
 *		ERROR - Any of first 3 sectors on disk is bad.
 */
long
markdev(pdev, hdsiz, databuf, pattern)
int pdev;	/* phys dev number */
long hdsiz;	/* size of hard disk in sectors */
char *databuf;	/* testing data */ 
long pattern;	/* data pattern */
{
    long sectcnt, cnt;		/* number of sectors to read */
    long sect2mark;		/* number of sectors to mark */
    SECTOR start, where;	/* where to start writing or reading */
    long totbad;		/* total bad sectors found */
    int nbad;			/* num bad sectors so far */
    int ret=0;			/* return code from routines */
    int clean;			/* indicate if chunk has any bad sector */
    char numbuf[10];		/* buf to hold string converted from a number */

    
    /*------------------------------------------------------------*/
    /*  Write lots of sectors (MAXSECTS worth) at a time.	  */
    /*  If write error, loop through sectors within that cylinder */
    /*  to find out exactly which sector(s) is bad, and add it to */
    /*  the bad sector list if it's not already there.		  */
    /*------------------------------------------------------------*/

    sect2mark = hdsiz;		/* mark entire disk */
    totbad = 0L;		/* no bad sectors yet */
    nbad = 0;			/* no bad sectors found yet */
    
    start = 0L;
	/* conver the bytes to the sectors */
	sysize /= 512;
    while (sect2mark != 0) {
		/*
		sbchk = 1;
		*/
    	if (sect2mark > sysize)
    	    sectcnt = sysize;
    	else
    	    sectcnt = sect2mark;
    	    
    	/* fill buffer with given pattern */
    	fillbuf(databuf, (sectcnt << 9), pattern);
    	    
remwrs:
    	if ((ret = wrsects(pdev, (int)sectcnt, databuf, start)) != 0) {
			/*
			if ((ret == 0xffff)&&(sbchk))	{
				active(pdev);
				sbchk = 0;
				goto remwrs;
			}
			*/
    	    if (tsterr(ret) == OK) {
    	    	ret = ERROR;
    	        goto badnews;
    	    }
    	    cnt = sectcnt;
    	    where = start;
    	    while (cnt) {
    	    	if ((ret = wrsects(pdev, 1, databuf, where)) != 0) {
		    if (tsterr(ret) == OK) {
			ret = ERROR;
			goto badnews;
		    }
  	    	    if (where < 3) {
  	    	    	ret = err(rsrvbad);
  	    	    	goto badnews;
  	    	    }
    	    	    
     	    	    badbuf[nbad++] = where;	/* store bad sector num */
    	    	    
    	    	    /* buffer is filled up, have to add bad sectors
    	    	       found so far to the BSL before continuing.   */
    	    	    if (nbad == WARNBADSECTS) {
    	    	    	if ((ret=addbsl(pdev, VENDOR, nbad)) < 0) {
    	    	    	    ret = ERROR;
    	    	    	    goto badnews;
    	    	    	}
    	    	    	totbad += ret;	/* increment num bad sectors existing */
						prnbad(totbad);
    	    	    	nbad = 0;	/* start counting again */
    	    	    }
    	    	}
    	    	where++;
    	    	cnt--;
    	    }
    	}

	if (nbad) {	/* there are bad sectors found not added to BSL yet */
	    if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
		ret = ERROR;
		goto badnews; 
	    }
	    totbad += ret;	/* increment num bad sectors existing */
	    prnbad(totbad);
	}
    
    	/*-----------------------------------------------------------*/
    	/* Read lots of sectors (one cylinder worth) at a time.      */
    	/* If read error, loop through sectors within that cylinder  */
    	/* to find out exactly which sector(s) is bad, and add it to */
    	/* the bad sector list if it's not already there.	     */
    	/*							     */
    	/* Data read is compared to data written.  If there is any   */
    	/* discrepancy within a sector, mark that sector as bad in   */
    	/* the bad sector list.					     */
    	/*-----------------------------------------------------------*/

        nbad = 0;	/* no bad sectors for this cylinder yet */
remrds:
    	if ((ret = rdsects(pdev, (int)sectcnt, databuf, start)) != 0) {
			/*
			if ((ret == 0xffff)&&(sbchk))	{
				active(pdev);
				sbchk = 0;
				goto remrds;
			}
			*/
    	    if (tsterr(ret) == OK) {
    	        ret = ERROR;
    	        goto badnews;
    	    }
    	    cnt = sectcnt;
    	    where = start;
    	    while (cnt) {
    	    	if ((ret = rdsects(pdev, 1, databuf, where)) != 0) {
    	    	    if (tsterr(ret) == OK) {
    	        	ret = ERROR;
    	        	goto badnews;
    	    	    }
    	    	    if (where < 3) {
  	    	    	ret = err(rsrvbad);
  	    	    	goto badnews;
  	    	    }
     	    	    badbuf[nbad++] = where;	/* store bad sector num */
    	    	} else {
    	    	    if (!blktst(databuf, pattern, 512L)) {
    	    	        if (where < 3) {
  	    	    	    ret = err(rsrvbad);
  	    	    	    goto badnews;
  	    	        }
    	    	        badbuf[nbad++] = where;    /* store bad sector num */
    	    	    }
    	    	}
		/* buffer is filled up, have to add bad sectors
    	    	   found so far to the BSL before continuing.   */
    	    	if (nbad == WARNBADSECTS) {
    	    	    if ((ret=addbsl(pdev, VENDOR, nbad)) < 0) {
    	    	        ret = ERROR;
    	    	        goto badnews;
    	    	    }
    	    	    totbad += ret;	/* incr num bad sectors existing */
    	    	    prnbad(totbad);
    	    	    nbad = 0;	/* start counting again */
    	    	}
    	    	where++;
    	    	cnt--;
    	    }
    	    clean = 0;
    	} else {
    	    clean = 1;
    	}
    	
    	if (nbad) { /* there are bad sectors found not added to BSL yet */
    	    if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
    	    	ret = ERROR;
    	    	goto badnews;
    	    }
    	    totbad += ret;	/* incr num bad sectors added to BSL */
    	    prnbad(totbad);
    	} else if (clean) {
	    /* compare data read with data written, record bad sectors if any */
    	    if ((ret = cmpdata(pdev, start, databuf, (int)sectcnt, pattern))
    	    	 < 0) {
    	        ret = ERROR;
    	        goto badnews;
    	    } else {
    	        totbad += ret;	/* incr num bad sectors added to BSL */
    	        prnbad(totbad);
    	    }
    	}
    	start += sectcnt;
    	sect2mark -= sectcnt;
    	
    	/* update bar on screen */
    	dmrkmsg[DMRKBAR].ob_width
    		= (dmrkmsg[DMRKBOX].ob_width * (hdsiz - sect2mark)) / hdsiz;
	objc_draw(dmrkmsg, DMRKBAR, MAX_DEPTH, 0, 0, wdesk, hdesk);
    }
badnews:
    if (ret < 0)	    /* if an error occurs,			*/
        return(ret);	    /*    return the error			*/
    else return(totbad);    /* else return number of bad sectors found. */
}

 
/*
 *  Update number of bad sectors found during Destructive Markbad in
 *  the dialogue box.
 *	Input:
 *		totbad - number of bad sectors found so far.
 */
prnbad(totbad)
long totbad;
{
    char numbuf[10];
    
    ltoa(totbad, numbuf);
    (dmrkmsg[NEWBAD].ob_spec)->te_ptext = numbuf;
    objc_draw(dmrkmsg, NEWBAD, MAX_DEPTH, 0, 0, wdesk, hdesk);
}

/*
 *  Compare data read with data written of a cylinder, and mark sectors
 *  with data error in the bad sector list.
 *	Input:
 *		pdev - physical unit BSL belongs to.
 *		start - starting physical sector number of the cylinder.
 *		databuf - data read from the cylinder.
 *		numsect - number of sectors to be compared.
 *		pattern - long pattern written on the cylinder.
 *	Output:
 *		bsl - an updated bad sector list with the newly found bad
 *		      sectors marked in it.
 */
cmpdata(pdev, start, readbuf, numsect, pattern)
int pdev;	/* physical device number */
SECTOR start;	/* phys sect num of where cylinder starts */
BYTE *readbuf;	/* data read */
int numsect;	/* num sectors to be compared */
long pattern;	/* correct data pattern */
{
    int i, cnt;			/* indices into databuf, counter */
    int nbad;			/* num bad sectors found so far */
    int totbad;			/* total num bad sectors found in cylinder */
    int ret;			/* return code from addbsl() */
    
    totbad = nbad = 0;	/* no bad sectors found yet */
    
    /* Test whole chunk first, if OK, ship it.  
       Return 0 for no bad sectors found. */
    if (blktst(readbuf, pattern, (long)numsect*512))
        return 0;
        
    for (cnt = 0; cnt < numsect; cnt++) {
    	if (!blktst(readbuf, pattern, 512L)) {
	    badbuf[nbad++] = start + cnt;	/* store bad sector num */
	}
	readbuf += 512L;
        if (nbad == WARNBADSECTS) {
            if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
            	return ret;
            }
            totbad += ret;	/* incr num bad sectors added to BSL */
            nbad = 0;		/* reinit counter for bad sectors to 0 */
        }
    }
    if (nbad) {	/* bad sectors found but not added to BSL yet */
        if ((ret = addbsl(pdev, VENDOR, nbad)) < 0) {
            return ret;
        }
        totbad += ret;	/* incr num bad sectors added to BSL */
    }
    return(totbad);
}
