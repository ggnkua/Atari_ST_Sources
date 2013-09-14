/* markbad.c */

/* 18-Apr-88  ml.	implement delete of trashed subdirectory with	   */
/*			recovering of files.				   */
/* 16-Mar-88  ml.	split assist.c into this and zero.c.		   */
/* 15-Mar-88  ml.	allow user to determine destiny of trashed files.  */
/* 16-Oct-87  ml.	fixed some bugs.				   */
/* 26-Oct-87  ml.	rewrote markbad, readrange, fixbadcls (everything).*/
/* 28-Oct-87  ml.	modified markbad to mark fats and root dir also.   */
/* 11-Dec-87  ml.	added BSL concept to markbad() and zero().	   */

#include "obdefs.h"
#include "gemdefs.h"
#include "osbind.h"
#include "defs.h"
#include "part.h"
#include "bsl.h"
#include "getstart.h"
#include "hdx.h"
#include "addr.h"

extern long gbslsiz();
extern long nument();
extern long cntbad();
extern int *fatck();
extern GSINFO *getstart();
extern long bslsiz;
extern BYTE *bsl;
extern SECTOR badbuf[];		/* bad sectors buffer */
extern long ratio;

UWORD ndirs;	/* total number of root directory entries */
UWORD sectdir;	/* number of sectors root directory entries take up */
UWORD clusiz;	/* number of bytes per cluster */
SECTOR strootdir;	/* starting sector number of root directory */
int endofdir;		/* TRUE: reaches end of directory */

int emptyorph=0;	/* an empty orphan list */
GSINFO	*finfo;		/* file information from getstart() */

extern int gl_wchar;	/* width of system font (pixels) */
char pname[260];	/* full path name of a file */
char dpname[260];	/* full path name of a file to be displayed */
char sectbuf[10];
char clusbuf[10];
long sysize;		/* system available memory */


/*
 * Mark bad sectors on the logical dev
 *
 */

markbad(ldev)
int ldev;
{
    SECTOR fat0, fat1, data, sect2read, dummy = 0L;
    long nsects;
    UWORD fatsiz, w1, w2;
    UWORD pbad, bps;
    char bs[512], foundbuf[10], markdbuf[10];
    BOOT *boot;
    int pdev, ret, nbad;

    
    pdev = ldev;
    log2phys(&pdev, &dummy);
    
    /* Allocate memory for BSL and try to read it */ 
    bsl = 0L;
    if ((bslsiz = gbslsiz(pdev)) > 0L) {
    	if ((bsl = (BYTE *)mymalloc((int)bslsiz << 9)) <= 0)
    	    return err(nomemory);
    	    
        if ((dummy = rdbsl(pdev)) != OK) {
            free(bsl);
            if (dummy == INVALID)
                err(cruptbsl);
            return ERROR;
        }
    } else if (bslsiz < 0L){
	if (bslsiz == ERROR)
	    err(rootread);
	return ERROR;
    }

    /*
     * Read boot sector and extract volume information.
     */
    if ((ret = rdsects(ldev, 1, bs, (SECTOR)0)) != 0) {
    	free(bsl);
    	if (tsterr(ret) != OK)
    	    err(bootread);
    	return ERROR;
    }

    boot = (BOOT *)bs;
     
    gw((UWORD *)&boot->b_ndirs[0], &ndirs);
    gw((UWORD *)&boot->b_spf[0], &fatsiz);
    gw((UWORD *)&boot->b_res[0], &w1);
    gw((UWORD *)&boot->b_nsects[0], &w2);
    gw((UWORD *)&boot->b_bps[0], &bps);
	ratio = bps / BPS;
	fatsiz = fatsiz * ratio;
    clusiz = (UWORD)boot->b_spc * bps;
    fat0 = (SECTOR)w1 * ratio;
    fat1 = fat0 + (SECTOR)fatsiz;
    strootdir = fat1 + fatsiz;
    sectdir = (ndirs * BPDIR) / BPS;
    data = (SECTOR)(strootdir + sectdir);
    nsects = (SECTOR)w2 * ratio;
    sect2read = nsects - data;

    /* Marking bad */
    if ((nbad = readfix(ldev, data, fat0, fatsiz, sect2read, &pbad)) < 0) {
    	if (bsl > 0) free(bsl);
        return ERROR;
    }

    /* Bad sectors found, BSL modified.  Write it back. */
    if (nbad) {
    	if (bslsiz)
            if (wrbsl(pdev) != OK) {
    	        free(bsl);
                return ERROR;
            }
    }
    if (bsl > 0) free(bsl);        
    
    /* Display result of markbad */
    itoa(nbad, foundbuf);
    itoa(pbad, markdbuf);
    (lmrkdone[BADFOUND].ob_spec)->te_ptext = foundbuf;
    (lmrkdone[BADMARKD].ob_spec)->te_ptext = markdbuf;
    lmrkdone[LMDONE].ob_state = NORMAL;
    erasemsg();
    execform(lmrkdone);
    return OK;
}


  
/* 
 * Critical Error Handler:
 *	Always return -1L
 *
 */
long
crerr()
{
    return -1L;
}



/*
 * Read range of sectors,
 * record bad ones in the vector,
 * add bad sectors found to the BSL,
 * mark bad sectors in the FATs,
 * return number of bad ones.
 *
 */
readfix(ldev, data, fat0, fatsiz, sect2read, pbad)
int ldev;		/* logical device to read from */
SECTOR data;		/* LSN of first sector of data clusters */
SECTOR fat0;		/* LSN of first sector of FAT 0 */
UWORD fatsiz;		/* size of FAT in sectors */
SECTOR sect2read;	/* number of sectors to read */
UWORD  *pbad;		/* ptr to # previously recorded bad sector */
{
    int nbad=0, full=0, ret;
    int pdev;		/* physical device number */
    SECTOR pstart;	/* physical starting block# of partition */
    SECTOR pdata;	/* physical starting block# of data clusters */
    SECTOR temp;	/* physical starting block# of data clusters */
    SECTOR *pbadbuf;
    SECTOR *knownbad();
    SECTOR cnt, cnt1;
    UWORD newbad;
    extern SECTOR logstart();
    char *rbuf = 0L;		/* read buffer */
    long dummy = 0L;

    pdev = ldev;
    log2phys(&pdev, &dummy);
    pstart = logstart(ldev);

        
	/* if there's a bsl, find # of previously found bad sector */
	*pbad = 0;
	pbadbuf = 0L;
    pdata = pstart + data;
	temp = pdata;
	if (bslsiz)	{
		if ((pbadbuf = knownbad(pdata, sect2read, pbad)) < 0L)
			goto readend;
	}

    /* Allocate memory for read buffer */
    if ((sysize = Malloc(-1L)) <= 0) {
        ret = err(nomemory);
        goto readend;
	}
	if ((sysize/512L) > MAXBUFSECT)	/* the max # of sector for hread() is 254*/
		sysize = MAXBUFSECT * 512;	/* convert to bytes */
    if ((rbuf = (char *)Malloc(sysize)) <= 0) {
        ret = err(nomemory);
        goto readend;
    }

    /*
     * Read lots of sectors, MAXSECTS sectors at a time;
     * if an error happens, then probe individual sectors
     * in the lump of MAXSECTS that failed.
     */

	newbad = 0;
	/* convert the bytes to the sectors */
	sysize /= 512;
    while (sect2read > 0) {
		if (sect2read > sysize)
		    cnt = sysize;
		else
		    cnt = sect2read;
		if ((ret = rdsects(pdev, (UWORD)cnt, rbuf, pdata)) != 0) {
		    if (tsterr(ret) == OK) {
		    	ret = ERROR;
		    	goto readend;
		    }
		    cnt1 = cnt;
		    while (cnt1) {
		        if ((ret = rdsects(pdev, 1, rbuf, pdata)) != 0) {
		            if (tsterr(ret) == OK) {
		            	ret = ERROR;
		            	goto readend;
		            }
				if (*pbad)	{
					/* if so, see if bad sector found uis one of them */
					if (!fl(pdata, *pbad, pbadbuf)) {
						/* if it is not, it's a newly found one */
						newbad++;
					}
				} else {
					newbad++;
				}
			    badbuf[nbad++] = pdata;

			    /* badbuf is filled */
			    if (nbad == WARNBADSECTS) {
    				if (rbuf > 0) Mfree(rbuf);    
					rbuf = 0L;
			    	if (bslsiz && !full)	/* USER list is not full yet */
			    	    /* try to add bad sectors found to BSL */
			            if ((ret = addbsl(pdev, USER, nbad)) < 0) {
			                if (ret == USRFULL)
			                    full = 1;
			                else {
			                    ret = ERROR;
			                    goto readend;
			                }
			            } else if (ret > 0) {
							if (wrbsl(pdev) != 0) {
						    ret = ERROR;
						    goto readend;
							}
			   			 }
			    
		        	/* mark the bad sectors in the FATs */
		        	if ((ret = fixbadcls(ldev, fat0, fatsiz, 
		        			data, nbad)) < 0) {
			    		goto readend;
		        	}
		        	nbad = 0;	/* reinit bad sectors count to 0 */

    				/* Allocate memory for read buffer */
    				if ((sysize = Malloc(-1L)) <= 0) {
    				    ret = err(nomemory);
    				    goto readend;
					}
    				if ((rbuf = (char *)Malloc(sysize)) <= 0) {
    				    ret = err(nomemory);
    				    goto readend;
    				}
					sysize /= 512;
		    	}
		            		            
	        }
			cnt1--;
			pdata++;
	    }
	} else {
	    pdata += cnt;
	}
		sect2read -= cnt;
    }
    
    if (rbuf > 0) Mfree(rbuf);    
	rbuf = 0;

    if (nbad) {	/* bad sectors found but not recorded in BSL or FATs */
    	if (bslsiz && !full)	/* USER list is not full yet */
    	    /* try to add bad sectors found to BSL */
            if ((ret = addbsl(pdev, USER, nbad)) < 0) {
                if (ret == USRFULL)
                    full = 1;
                else {
                    ret = ERROR;
                    goto readend;
                }
            } else if (ret > 0) {
		if (wrbsl(pdev) != 0) {
		    ret = ERROR;
		    goto readend;
		}
	    }            	
	    
        /* mark the bad sectors in the FATs in terms of clusters */
        if ((ret = fixbadcls(ldev, fat0, fatsiz, data, nbad)) < 0) {
	    goto readend;
        }
    }
    ret = newbad;
    
readend:
    if (rbuf > 0) Mfree(rbuf);    
	if (pbadbuf > 0) Mfree(rbuf);
    return (ret);
}


/*
 * Knownbad() - build a list of bad sectors that have been recorded
 *	        in the BSL within the range provided.
 *
 * Assumes:
 *	BSL exists and has already been read into memory.
 *
 * Returns:
 *	Pointer to a list of bad sectors that have been recorded in the
 * BSL within the range provided, if there is any, and # of elements in 
 * the list.
 *
 */
SECTOR*
knownbad(start, numsect, nbad)
SECTOR	start;		/* starting sector of range */
SECTOR	numsect;	/* # sectors within the range */
UWORD	*nbad;		/* # elements in the list returned */
{
    extern long get3bytes();
    long totbad, i;
    SECTOR end, curr;
    SECTOR *pbadbuf, *bufptr, *ret;
    UWORD cnt;
    char *bslptr, *first;
    
    ret = 0L;			/* no buffer allocated yet */
    *nbad = cnt = 0;		/* no recorded bad sectors found yet */
    
    totbad = nument(MEDIA);	/* num entries in bsl */
    sortbsl(totbad);		/* sort the bsl */
    end = start + numsect;	/* end of range of sectors to be searched */
    
    bslptr = bsl + BPE*RENT;
    for (i = 0L; i < totbad; i++, bslptr += BPE) {
    	if ((curr = get3bytes(bslptr)) >= end) {
	    break;
	} else if (curr >= start) {
	    if (!cnt)
		first = bslptr;
	    cnt++;
	}
    }
	    
    if (cnt) {
	if ((pbadbuf = (SECTOR *)mymalloc(cnt << 2)) <= 0L) {
	    err(nomemory);
	    ret = -1L;
	    goto kend;
	}
    
	*nbad = cnt;
	bufptr = pbadbuf;
	while (cnt) {
	    if ((curr = get3bytes(first)) < end && curr >= start) {
		*bufptr++ = curr;
		cnt--;
	    }
	    first += BPE;
	}
	ret = pbadbuf;
    }
kend:
    return ret;
}



/*
 * Fixup bad sector entries in the FATs;
 * suboptimal, since a FAT sector is read and two are
 * written for EACH bad sector, even if there is
 * more than one bad entry in a given FAT sector.
 *
 *
 */
fixbadcls(ldev, fat0, fatsiz, data, nbad)
int ldev;		/* logical device */
SECTOR fat0, data;
UWORD fatsiz;
int nbad;
{
    long numcl;
    UWORD clno, nxtcl;
    int i;
    UWORD *buf;
    SECTOR fat1;	/* physical starting sector# of 2nd FAT */
    SECTOR pstart;	/* physical starting sector# of partition */
    SECTOR badsect;	/* current bad sector */
    extern SECTOR logstart();
    extern LOGMAP logmap[];
    int did=0, nmarked, ret, spc;
    
    
    if((buf = (UWORD *)Malloc((long)fatsiz << 9)) <= 0)
        return err(nomemory);
    pstart = logstart(ldev);

	spc = 2*ratio;    				/* No, 2 spc */
    numcl = (logmap[ldev-'C'].lm_siz - data) / spc;
    fat1 = fat0 + fatsiz;
            
    if ((ret = rdsects(ldev, fatsiz, (char *)buf, fat0)) != 0) {
    	if (tsterr(ret) != OK)
	    err(fatread);
	ret = ERROR;
	goto fixend;
    }
    nmarked = 0;
    for (i = 0; i < nbad; ++i) {
	badsect = badbuf[i] - pstart;
	if ((clno = (badsect - data)/spc) >= numcl)
	    continue;
    		
   	/* find out the next cluster number */
   	gw((UWORD *)(buf+clno+2), &nxtcl);
    	    
	/* part of file?? */
   	if (nxtcl != 0 && (nxtcl <= 0x7fff || nxtcl >= 0xfff8))	{
   	    /* Yes, bummer */
   	    if ((ret = partoffile(ldev, buf, fatsiz, badsect, clno, nxtcl))
   	    	    < 0)
   	        goto fixend;
   	    nmarked += ret;
	} else {	/* just mark it bad */
	    /* Nope, ah ha, just mark it bad */
	    *(buf+clno+2) = 0xf7ff;	/* 0xfff7 in 8086-land */
	    nmarked++;
	}

	/* write FAT0 and FAT1 */
	if ((ret = wrsects(ldev, fatsiz, (char *)buf, fat0)) != 0 ||
	    (ret = wrsects(ldev, fatsiz, (char *)buf, fat1)) != 0)
	{
	    if (tsterr(ret) != OK)
	        err(fatwrite);
	    ret = ERROR;
	    goto fixend;
	}
    }
    ret = nmarked;
fixend:
    Mfree((long)buf);
    return ret;
}


/*
 *  Handle situations when bad sector found is currently allocated
 *  to a file.
 *
 *	Options for user:
 *		- Delete the victim file. (Lose all data in file.)
 *		  Bad sector will be marked in FATs.
 *		- Skip over the cluster where the bad sector resides.
 *		  (Lose data in bad sector only.)  Need to patch up
 *		  FATs and root directory entry of file.  Bad sector
 *		  will be marked in FATs.
 *		- Ignore the bad sector. Bad sector will stay unmarked
 *		  in FATs.
 *
 *	Input:
 *		ldev - logical device.
 *		fatimg - image of FAT table.
 *		fatsiz - # clusters FAT occupies.
 *		badsect - bad sector in question.
 *		clno - cluster containing the bad sector.
 *		nxtcl - next cluster in chain. (ie. cluster currently
 *			pointed to by cluster with the bad sector.
 *
 *	Output:
 *		ERROR - if something went wrong in the process.
 *		1 - cluster in question is marked.  Image of FATs 'may'
 *		    be modified, depending on the option chosen by the
 *		    user.
 *
 *	Comments:
 *		Things get pretty hairy when the bad sector is allocated
 *	to a subdirectory file (ie. file that contains entries of other
 *	files belonging to that subdirectory).  As of today (17-Mar-88),
 *	no action (may be an alert) will be taken for victim subdirectory
 *	files.
 *		31-Mar-88 : started to add routines to take care of
 *	trashed subdirectories.
 *		11-Apr-88 : froze development of relinking trashed
 *	subdirectories.  Will fix all known bugs and release first.
 *		18-Apr-88 : started to implement recovering of files of
 *	a trashed subdirectory.
 *
 */
partoffile(ldev, fatimg, fatsiz, badsect, clno, nxtcl)
int ldev;			/* logical device number */
UWORD *fatimg;			/* FAT's image */
UWORD fatsiz;		/* #sectors in FAT */
SECTOR badsect;			/* sector which is bad */
UWORD clno, nxtcl;	/* current cluster # and next cluster # */
{
    int *orphans;		/* list of orphans in FAT */
    UWORD numorph;		/* number of orphans found in FAT */
    FCB *dirent;		/* a directory entry */
    int attribs;		/* file attributes */
    int ret;			/* return code */
    int tail;			/* num pixels path name exceeds box's width */
    int sub;			/* TRUE: file in process is a subdirectory */
    int i;			/* index */
    
    ret = OK;	/* assume everything is OK to start with */
    /* Check integrity of FATs */
    if ((orphans = fatck(ldev-'A')) <= 0L) {
	switch (orphans) {
	    case FFATS:
		ret = err(fatread);
		goto leave;
	    case FROOT:
		ret = err(dirread);
		goto leave;
	    case FFAIL:
		ret = err(nomemory);
		goto leave;
	    case FAMBI:
		ret = err(badfat);
		goto leave;
	    default:
		break;
	}
    }

    ltoa(badsect, sectbuf);	/* sector number of bad sector */
    
    /* Find what file bad sector is allocated to */
    if ((finfo = getstart(orphans, clno+2, ldev-'A')) == GORPH) {
    	markorph[ORPHYES].ob_state = NORMAL;
    	markorph[ORPHNO].ob_state = NORMAL;
    	(markorph[ORPHSEC].ob_spec)->te_ptext = sectbuf;
	itoa(clno+2, clusbuf);	/* +2: 2 unused entries at FAT */
    	(markorph[ORPHCLU].ob_spec)->te_ptext = clusbuf;
    	if (execform(markorph) == ORPHYES) {	/* want to mark orphan */
    	    *(fatimg+clno+2) = 0xf7ff;		/* 0xfff7 in 8086-land */
    	    ret = 1;
    	} else {		/* don't want to mark orphan */
    	    ret = 0;
    	}
    	goto leave;
    } else if (finfo == GFAIL) {
	ret = err(nomemory);
	goto leave;
    } /* else if (finfo == GALLO || finfo == GOOFY
	     If these are ever returned, it's this
	     program's fault.
      */

    if (!(finfo->gs_fpath[0])) {	/* 0: can't read subdirectory */
        err(sdirread);
        ret = 0;
        goto leave;
    }
        
    /* root of full path name of file */
    pname[0] = ldev;
    pname[1] = ':';
    pname[2] = '\0';

    /* Have to display entire path name */
    strcat(pname, finfo->gs_fpath);
    
    /* Is trashed file a subdirectory? */
    /* How many characters will the path name exceed width of dialogue? */
    if ((attribs = Fattrib(pname, 0, 0)) & FA_SUB) {
	sub = TRUE;
	tail = (strlen(finfo->gs_fpath)+2)*gl_wchar-lmrksub[BADSUB].ob_width;
    } else {
	sub = FALSE;
	tail = (strlen(finfo->gs_fpath)+2)*gl_wchar-lmrkfile[BADFILE].ob_width;
    } 
	
    /* Display path name, sector & cluster # concerned */    
    if (tail <= 0) {	/* path name of file will fit in dialogue */
	strcpy(dpname, pname);
    } else {		/* path name of file is too long for dialogue */
	dpname[0] = ldev;
	dpname[1] = ':';
	dpname[2] = '\0';
        strcat(dpname, "\\...");
        strcat(dpname, &(finfo->gs_fpath[tail/gl_wchar+4]));
    }
    
    /* Set up dialogue with info of trashed file/subdirectory */
    if (sub == TRUE) {		/* it's a subdirectory file */
        ret = marksub(ldev, fatimg, fatsiz, clno);
    } else {			/* it's a regular file */
    	ret = markfile(ldev, fatimg, fatsiz, clno, nxtcl);
    }
leave:
    return (ret);
}    	    	


/*
 *  Marksub()
 *	Put up dialogue informing which subdirectory is trashed, and
 *  request action from user.
 *
 *  Input:
 *	ldev  - logical device number. ('C' -> 'P')
 *	fatimg  - image of FAT 0.
 *	fatsiz - size of FAT in sectors.
 *	clno - cluster which bad sector resides.
 *
 *  Return:
 *	1 - if successful and cluster with bad sector is marked.
 *	0 - if successful but nothing marked.
 *	ERROR - can't read boot sector.
 *
 *  Comments:
 *	15-Apr-88 ml.  If user choose to delete the subdirectory, all
 *  files and subdirectories belonging to that subdirectory will also
 *  be deleted.
 *	18-Apr-88 ml.  Try to implement recovering files so that the user
 *  only lose the directory structure.  All files and subdirectories
 *  belonging to the 'trouble maker' now become temporary files under
 *  the root directory.  So, number of files recovered depends on number
 *  of empty slots remained in the root directory.
 * 
 */
marksub(ldev, fatimg, fatsiz, clno)
int  ldev;
UWORD *fatimg;
UWORD fatsiz;
UWORD clno;
{
    UWORD *neworphs;		/* list of new orphans */
    int  *lstneworphs();
    FCB  *dirent;		/* a directory entry */
    UWORD clus, nxtcl;		/* current and next cluster number */
    int  act;			/* action requested by user */
    char buf[512];
    int  ret = OK;
    
    lmrksub[BADSUB].ob_width = strlen(dpname)*gl_wchar; 
    lmrksub[BADSUB].ob_x 
	= (lmrksub->ob_width - lmrksub[BADSUB].ob_width) >> 1;
    lmrksub[BADSUB].ob_spec = dpname;
    (lmrksub[SUBSEC].ob_spec)->te_ptext = sectbuf;
    itoa(clno+2, clusbuf);
    (lmrksub[SUBCLU].ob_spec)->te_ptext = clusbuf;
    
    lmrksub[SUBDELSV].ob_state = NORMAL;
    lmrksub[SUBDELNS].ob_state = NORMAL;
    lmrksub[SUBIGNOR].ob_state = NORMAL;
	
    /* Put up the dialogue */
    switch ((act = execform(lmrksub))) {
	case SUBIGNOR:			/* clicked on ignore */
	    ret = 0;
	    goto subend;
    
	case SUBDELSV:			/* clicked on delete and save */
	    ARROW_MOUSE;
	    if (form_alert(2, svfiles) == 2) {	/* bail out */
		BEE_MOUSE;
		ret = 0;
		goto subend;
	    }
	    break;
		
	case SUBDELNS:			/* clicked on delete and not save */
	    ARROW_MOUSE;
	    if (form_alert(2, nsfiles) == 2) {	/* bail out */
		BEE_MOUSE;
		ret = 0;
		goto subend;
	    }
	    break;
	    
	default:
	    break;
    }    

    /* Really removing subdirectory and mark bad sector */
    BEE_MOUSE;
    /* Read directory sector containing the subdirectory file from disk */
    if ((ret = rdsects(ldev, 1, buf, (SECTOR)finfo->gs_dsect*ratio)) != 0) {
    	if (tsterr(ret) != OK)
	    err(sdirread);
	ret = 0;
	goto subend;
    }

    /* Get directory entry of file */
    dirent = (FCB *)(buf + finfo->gs_doff);
    
    /* Delete the subdirectory */
    dirent->f_name[0] = FN_DEL;
    
    /* Write directory sector containing the subdirectory file back to disk */
    if ((ret = wrsects(ldev,1,buf,(SECTOR)finfo->gs_dsect*ratio)) != 0) {
    	if (tsterr(ret) != OK)
	    err(sdirwrit);
    	ret = 0;
	goto subend;
    }

    /* Zero entries of the subdirectory file in FAT, and mark bad sector */
    				/* start from beginning of file */
    for (gw((UWORD *)&dirent->f_clust, &clus);
         clus < 0xfff0;		/* until EOF or a cluster marked bad */
         clus = nxtcl)		/* next cluster becomes current */
    {
         gw((UWORD *)(fatimg+clus), &nxtcl);  /* find where next cluster is */
         *(fatimg+clus) = 0;		     /* zero current cluster */
    }
    *(fatimg+clno+2) = 0xf7ff;	    /* mark cluster with bad sector */
    
    /* Update FATs */
    if ((ret = wrsects(ldev, fatsiz, (char *)fatimg, (SECTOR)ratio)) != 0 ||
        (ret = wrsects(ldev,fatsiz,(char *)fatimg,(SECTOR)ratio+fatsiz)) != 0){
        if (tsterr(ret) != OK)
	    err(fatwrite);
	ret = ERROR;
	goto subend;
    }

    /* Find out list of orphans introduced by deleting the subdirectory */
    if ((neworphs = lstneworphs(ldev)) < 0) {
        ret = ERROR;		/* error occurs when finding new orphans */
        goto subend;
    } else if (!neworphs) {
        ret = 1;		/* No new orphans! No files to recover! */
        goto subend;
    }

    /* Recover files in subdirectory and put them in root directory */
    if (act == SUBDELSV) {	/* requested to recover file */
	if (rcvrfiles(ldev, fatimg, fatsiz, neworphs) != OK) {
	    ret = ERROR;
	    goto subend;
	}
    } else if (act == SUBDELNS) {	/* requested not to recover file */
        if (rmvfiles(fatimg, neworphs) != OK) {
            ret = ERROR;
            goto subend;
	}
    }
    ret = 1;		/* everything is fine.  JUST FINE... */
subend:
    if (neworphs > 0L) Mfree((long)neworphs);
    return ret;
}




/*
 *  Lstneworphs()
 *	Find out what orphans exist and record them in an orphan list.
 *
 *  Input:
 *	ldev - logical device number ('C' -> 'P')
 *
 *  Return:
 *	neworphs - list of new orphans
 *	0 - if there is no new orphans
 *	ERROR - if anything goes wrong
 */
int*
lstneworphs(ldev)
int ldev;
{
    UWORD *neworphs;	/* current orphans in FAT */
    UWORD *orphans;	/* current orphans in FAT */
    int numnew, i;
    long ret;
    
    /* Check integrity of FATs, and find all orphans that exist */
    if ((orphans = fatck(ldev-'A')) <= 0L) {
	switch (orphans) {
	    case FFATS:
		ret = err(fatread);
		goto lstend;
	    case FROOT:
		ret = err(dirread);
		goto lstend;
	    case FFAIL:
		ret = err(nomemory);
		goto lstend;
	    case FAMBI:
		ret = err(badfat);
		goto lstend;
	    default:
		break;
	}
    }

    ret = 0L;	/* assume there is no new orphans */
    
    /* Any orphans in FAT? */
    if (*orphans > 0) {		/* Yes, try to recover them */
	/* Allocate space for new orphans */
	if ((neworphs =
		(UWORD *)Malloc((long)((*orphans+1)<<1))) <= 0L) {
	    ret = err(nomemory);
	    goto lstend;
        }
        
	for (i = 0; i <= *orphans; i++)
	    *(neworphs + i) = *(orphans + i);
	    
	ret = neworphs;
    }
lstend:
    return ret;
}


/*
 *  Rcvrfiles()
 *	Recover files of a trashed subdirectory.  The files will
 *  become temporary files in the root directory of the partition.
 *  Their names will be tmpnnnn, where nnnn is a four digit hex
 *  number which is the starting cluster number of that file.
 *
 *  Input:
 *	ldev - logical device number. ('C' -> 'P')
 *	fatimg  - image of FAT 0.
 *	fatsiz - number of clusters FAT occupies.
 *	neworphs - list of new orphans.
 *
 *  Output:
 *	OK - recover (if necessary) is successful.
 *	ERROR - something is wrong.
 *
 *  Comments:
 *	To recover the new lost files, we construct a temporary FAT
 *  which contains only the newly introduced orphans (excluding clusters
 *  marked bad and reserved; that is, only if they are part of a file). 
 *  All other entries are 0's.  We then walk through the FAT to find the
 *  first non-zero entry, and call getstart() to find out where the head
 *  of this chain is.  This chain will then be saved as a temp file in the
 *  root directory, named tmpnnnn (nnnn is the starting cluster number of
 *  the chain in hex).  To save the temp file in the root directory, we
 *  have to search for an empty slot in the root and enter information of
 *  the temp file into the directory entry.  After a chain is recovered,
 *  zero out the chain in the temporary FAT and start to look for the next
 *  non-zero entry in it for the next chain, until all chains are recovered.
 *	Note that the content of the temporary FAT (referred to as fakefat)
 *  is in regular 68000 word format.  The entries are _NOT_ in 8086 byte-
 *  swapped format.
 */	
rcvrfiles(ldev, fatimg, fatsiz, neworphs)
int ldev;
UWORD *fatimg;
UWORD fatsiz;
UWORD *neworphs;
{
    FCB *rootdir, *availslot;	/* root directory; available slot */
    GSINFO *chain;		/* info of an orphan chain of clusters */
    UWORD *fakefat;		/* a temp fat image */
    UWORD content;		/* cluster pointed to by a FAT entry */
    UWORD orph2del;		/* number of orphan yet to be deleted */
    UWORD i;			/* index into orphan list */
    UWORD orph;			/* an orphan in fake FAT */
    UWORD stfat;		/* index into fake FAT */
    UWORD stdir;		/* index into root directory */
    UWORD dirslot;		/* empty directory slot number */
    UWORD numclus;		/* number of clusters file used */
    UWORD prev, curr;		/* previous and current cluster number */
    int done;			/* 1: finish recovering files */
    int endofchain;		/* 1: reached end of file chain */
    int rootfull;		/* root directory is full */
    int tget;			/* current time or date */
    int ret;			/* return code */
    char namebuf[10];
    
    
    /* Allocate space for root directory */
    rootdir = 0L;
    if ((rootdir = (FCB *)mymalloc(sectdir << 9)) <= 0L) {
        ret = err(nomemory);
        goto rcvrend;
    }
    
    /* Read in root directory */
    if ((ret = rdsects(ldev, sectdir, (char *)rootdir, strootdir)) != 0) {
    	if (tsterr(ret) != OK)
    	    err(dirread);
    	ret = ERROR;
    	goto rcvrend;
    }

    /* Allocate space for a temporary FAT image and zero it out */
    fakefat = 0L;
    if ((fakefat = (UWORD *)Malloc((long)fatsiz << 9)) <= 0L) {
    	ret = err(nomemory);
    	goto rcvrend;
    }
    fillbuf((char *)fakefat, ((long)fatsiz << 9), 0L);
    
    /* Copy the new orphans from current FAT to this	   */
    /* temporary FAT only if they are part of a file chain */
    orph2del = 0;		/* no orphan is copied to fake FAT yet */
    for (i = 1; i <= *neworphs; i++) {
    	gw((fatimg + *(neworphs + i)), &content);
    	if ((content >= 0x0002 && content <= 0x7fff)	/* part of file */
    	    || (content >= 0xfff8 && content <= 0xffff)) {
    	    *(fakefat + *(neworphs + i)) = content;	/* copy to temp FAT */
    	    orph2del++;		/* one more orphan to take care of */
    	}
    }

    /* start recovering... */
    stfat = 2;			/* start at beginning of fake FAT */
    stdir = 0;			/* start at beginning of root directory */
    endofdir = FALSE;		/* not at end of root directory yet */
    rootfull = 0;
    
nextorph:
    while (orph2del > 0) {	/* more orphan to take care of? */
    	/* Yes, find next non-zero entry in fake FAT */
    	for (orph = stfat; *(fakefat+orph) == 0; orph++)
    	    ;
    	stfat = orph + 1;	/* next time start from here to walk FAT */

	/* Root directory was already full, and user choose to 
	   deallocate all remaining new orphans on the disk.   */
	if (rootfull) {			/* root directory is full already */
	    *(fatimg + orph) = 0;	/* deallocate orphan from real FAT */
	    orph2del--;			/* one fewer to go */
	    goto nextorph;		/* find the next one */
	}
	
	/* Find an empty slot in the root directory */
	if ((dirslot = rtdirslot(rootdir, stdir)) == ERROR) {
	    /* FIRST TIME -- Root directory is FULL! */
	    rootfull = 1;
	    if (execform(nodrslot) == NODRNO) {	   /* wanna keep lost clus */
		    goto okend;			   /* Nope! */
	    }
	    /* Yup. */
	    *(fatimg + orph) = 0;	/* Zero out current orphan */
	    orph2del--;			/* one fewer to go */
	    goto nextorph;		/* find the next one to zero out */
	}
	stdir = dirslot + 1; /* next time start from here to find slots */

	/* Find head of chain that this cluster belongs to */    	
	if ((chain = getstart(&emptyorph, orph, ldev-'A')) <= 0L) {
	    ret = ERROR;
	    goto rcvrend;
	}

	/* Erase chain from fake FAT */
	endofchain = 0;				/* not end of chain yet */
	numclus = 0;				/* no cluster zeroed yet */
	prev = curr = chain->gs_head;		/* start from head of chain */
	
	while (!endofchain) {			/* while not end of chain */
	    content = *(fakefat + curr);	/* next cluster in chain */
	    *(fakefat + curr) = 0;		/* zero current entry */
	    if (!content) {			/* next cluster is 0? */
	        endofchain = 1;			/* Yes, BAD! end it */
	        *(fatimg + prev) = 0xffff;	/* stop chain in real FAT */
	    } else if (content >= 0xfff8 && content <= 0xffff) { /* last clus */
	        numclus++;			/* zeroed last one */
		endofchain = 1;			/* end of chain reached */
	    } else {				/* still at middle of chain */
	    	prev = curr;			/* current becomes previous */
		curr = content;			/* next becomes current */
		numclus++;			/* one more is zeroed */
	    }
	}
	
	/* Move the file to root directory and erase chain from fake FAT */
	availslot = rootdir + dirslot;
	strcpy(availslot->f_name, "TMP");		  /* file name */
	htoa((long)chain->gs_head, namebuf, 1);
	strcat(availslot->f_name, namebuf);
	strcat(availslot->f_name, "    ");
	availslot->f_attrib = 0;			  /* file attrib */
	tget = Tgettime();				  /* time created */
	iw(&(availslot->f_time), tget);
	tget = Tgetdate();				  /* date created */
	iw(&(availslot->f_date), tget);
	iw(&(availslot->f_clust), chain->gs_head);	  /* starting clus */
	il(&(availslot->f_fileln), (long)(numclus*clusiz));  /* file length */
	
	/* update number of orphans to delete */
	orph2del -= numclus;
    }

okend:
    /* Write root directory back on disk */
    if ((ret = wrsects(ldev, sectdir, (char *)rootdir, strootdir)) != 0) {
    	if (tsterr(ret) != OK)
      	    err(dirwrite);
      	ret = ERROR;
    	goto rcvrend;
    }
    ret = OK;
rcvrend:
    if (fakefat > 0) Mfree((long)fakefat);
    if (rootdir > 0) free (rootdir);
    return ret;
}


/*
 *  Rtdirslot()
 *	Find the next available directory slot in the root directory
 *  of the given partition.
 *
 *  Input:
 *	dirimg - image of the root directory read from disk.
 *	start - directory slot number to start with.
 *
 *  Return:
 *	dirslot - available directory slot number.
 *	ERROR - no more available slot.
 *
 *  Comments:
 *	Note that, a zero entry marks the end of the directory.  That is,
 *  all subsequent entries are available.
 */
rtdirslot(dirimg, start)
FCB *dirimg;
UWORD start;
{
    int i;
    
    if (endofdir == TRUE) {		/* End of directory reached? */
        if (start < ndirs)		/* Yes, full? */
            return (start);		/* No, next slot will be available. */
        else 				/* Yes, no available slot */
            return ERROR;
    }
        
    for (i = start; i < ndirs; i++) {
        if ((dirimg+i)->f_name[0] == FN_DEL) /* entry of a deleted file is OK */
            return i;
        if (!((dirimg + i)->f_name[0])) {    /* end of directory is reached */
            endofdir = TRUE;
            return i;
        }
    }
    return ERROR;	/* no available slot found */
}


/*
 *  Rmvfiles()
 *	Remove orphan clusters which were allocated to files which
 *  are now lost from the FAT.
 *
 *  Input:
 *	fatimg  - image of FAT 0.
 *	neworphs - list of new orphans.
 *
 *  Return:
 *	OK - when finished.
 */
rmvfiles(fatimg, neworphs)
UWORD *fatimg;
UWORD *neworphs;
{
    int i;		/* index into orphan list */
    UWORD content;	/* pointer to next cluster */
    
    for (i = 1; i <= *neworphs; i++) {
    	gw((fatimg + *(neworphs + i)), &content);
    	if ((content >= 0x0002 && content <= 0x7fff)	/* part of file */
    	    || (content >= 0xfff8 && content <= 0xffff)) {
	    *(fatimg + *(neworphs + i)) = 0;		/* remove it */
	}
    }
    return OK;
}
 
/*
 *  Markfile()
 *	Put up dialogue informing which file is trashed, and
 *  request action from user.
 *
 *  Input:
 *	ldev  - logical device number. ('C' -> 'P')
 *	fatimg  - image of FAT 0.
 *	fatsiz - number of clusters FAT occupies.
 *	clno - cluster which bad sector resides.
 *	nxtcl	- cluster pointed to by bad cluster.
 *
 *  Return:
 *	1 - if successful and cluster with bad sector is marked.
 *	0 - if successful but didn't mark the bad sector.
 *	ERROR - something's wrong.
 */
markfile(ldev, fatimg, fatsiz, clno, nxtcl)
int  ldev;
UWORD *fatimg;
UWORD fatsiz;
UWORD clno;
UWORD nxtcl;
{
    int  ret;

    lmrkfile[BADFILE].ob_width = strlen(dpname)*gl_wchar; 
    lmrkfile[BADFILE].ob_x 
	= (lmrkfile->ob_width - lmrkfile[BADFILE].ob_width) >> 1;
    lmrkfile[BADFILE].ob_spec = dpname;
    (lmrkfile[BADSEC].ob_spec)->te_ptext = sectbuf;
    itoa(clno+2, clusbuf);    
    (lmrkfile[BADCLU].ob_spec)->te_ptext = clusbuf;
    lmrkfile[DELFILE].ob_state = NORMAL;
    lmrkfile[SKIPOVER].ob_state = NORMAL;
    lmrkfile[IGNORBAD].ob_state = NORMAL;

    /* Put up the dialogue */
    ret = execform(lmrkfile);

    /* Action requested by Jackson is... */
    switch (ret) {
	case DELFILE:	/* Delete file */
	    /* User's choice => can delete */
	    if (Fdelete(pname)) {
		ret = err(cantdel);
	    }
    	   
	    /* Read current FAT; fat0 starts at sector 1 */
	    if ((ret = rdsects(ldev, fatsiz, (char *)fatimg, (SECTOR)ratio)) != 0) {
	    	if (tsterr(ret) != OK)
		    err(fatread);
		ret = ERROR;
		break;
	    }
		
	    /* Mark the cluster bad */
	    *(fatimg+clno+2) = 0xf7ff;	/* 0xfff7 in 8086-land */
	    ret = 1;	/* 1 cluster marked bad */
	    break;

	case SKIPOVER:	/* Skip over bad sector */
	    ret = skpfile(ldev, fatimg, fatsiz, clno, nxtcl);
	    break;

	case IGNORBAD:
	    ret = 0;
	    break;
    
	default:
	    ret = ERROR;
	    break;
    }
    return ret;
}
 
 
/*
 *  Skpfile()
 *	Skip over a cluster which contains a bad sector of a file.
 *
 *  Input:
 *	ldev  - logical device number. ('C' -> 'P')
 *	fatimg  - image of FAT 0.
 *	fatsiz - number of clusters FAT occupies.
 *	clno - cluster which bad sector resides.
 *	nxtcl	- cluster pointed to by bad cluster.
 *
 *  Return:
 *	1 - if cluster with bad sector is marked.
 *	OK - if successful.
 *	ERROR - can't read boot sector.
 *
 *  Comments:
 *	Need to adjust length and/or modify directory entry of the
 *  corresponding file.
 *	Complications arise when file is a subdirectory.  For first
 *  trial, nothing is done for subdirectories for now.
 *
 */
skpfile(ldev, fatimg, fatsiz, clno, nxtcl)
int  ldev;
UWORD *fatimg;
UWORD fatsiz;
UWORD clno;
UWORD nxtcl;
{
    FCB  *dirent;		/* a directory entry */
    int  ret;			/* return code */
    long flen;			/* file length (68000 format) */
    long gl();			/* get a long from 8086 format */
    long left;			/* #bytes in last cluster of file */
    char buf[512];
    
    ret = OK;	/* assume everything is OK now... */

    /* Read directory sector containing the file from disk */
    if ((ret = rdsects(ldev, 1, buf, (SECTOR)finfo->gs_dsect*ratio)) != 0) {
    	if (tsterr(ret) != OK)
	    err(sdirread);
	ret = 0;
	goto skipend;
    }

    /* Get directory entry of file */
    dirent = (FCB *)(buf + finfo->gs_doff);

    /* Relink the file */
    if (!(finfo->gs_count - 1)) {	/* it's 1st cluster */
        if (nxtcl >= 0xfff0) {		/* it's also last cluster */
            if (Fdelete(pname))		/* just delete it */
                ret = err(cantdel);
                
    	    /* Read in current FAT; fat0 starts at sector 1 */
    	    if ((ret = rdsects(ldev,fatsiz,(char *)fatimg,(SECTOR)ratio))!= 0){
    	    	if (tsterr(ret) != OK)
    	    	    err(fatread);
    	    	ret = ERROR;
    	    	goto skipend;
    	    }
	    goto markit;
        }
	iw(&(dirent->f_clust), nxtcl);	/* new starting clus = next clus */
    } else {			/* otherwise */
	iw((fatimg + finfo->gs_prev), nxtcl);  /* skip cluster marked bad */
    }

    /* Adjust file size */
    /* Is it end of file, or #bytes give exact clusters?? */
    gl(&(dirent->f_fileln), &flen);
    if (flen) {
	if ((!(left = flen % clusiz)) || nxtcl < 0xfff0)
	    flen -= clusiz;	/* Yes, subtract entire unusable cluster */
	else
	    flen -= left;	/* Nope, subtract unusable bytes */
	
	il(&(dirent->f_fileln), flen);	/* install new file length */
    }

    /* Write directory sector containing the file back to disk */
    if ((ret = wrsects(ldev, 1, buf, (SECTOR)finfo->gs_dsect*ratio)) != 0) {
    	if (tsterr(ret) != OK)
	    err(sdirwrit);
	ret = 0;
	goto skipend;
    }
markit:    
    /* Mark the cluster bad */
    *(fatimg+clno+2) = 0xf7ff;	/* 0xfff7 in 8086-land */
    ret = 1;	/* 1 cluster marked bad */
skipend:
    return (ret);
}


/*
 * Put long in memory in 8086 byte-reversed format.
 *
 */
il(d, s)
long *d;
long s;
{
    char *p;

    p = (char *)d;
    p[0] = s & 0xffff;
    p[1] = ((s >> 8) & 0xffff);
    p[2] = ((s >> 16) & 0xffff);
    p[3] = ((s >> 24) & 0xffff);
}


/*
 * Get word in memory, from 8086 byte-reversed format.
 *
 */
long gl(s, d)
long *s;
long *d;
{
    char *p, *q;

    p = (char *)s;
    q = (char *)d;
    q[0] = p[3];
    q[1] = p[2];
    q[2] = p[1];
    q[3] = p[0];
    return *d;
}

/*
 * fl() - Find a long in an array of longs.
 *	- Returns 1 if found; 0 if not found;
 */
fl(tofind, numl, llist)
long	tofind;		/* long to search for */
UWORD	numl;		/* # of longs in the array */
long	*llist;		/* ptr to array of longs */
{
    long    i, *slist;
    
    slist = llist;
    for (i = 0L; i < numl; i++)
	if (tofind == *slist++)
	    return 1;
	    
    return 0;
}
