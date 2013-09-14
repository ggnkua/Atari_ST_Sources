/*
 * BSL.C
 *
 * 	Functions to manipulate the Bad Sector List.
 *
 * 25-Nov-87	ml.	Started this mess.
 * 04-Dec-87	ml.	Hmmm, looks OK.
 * 11-Dec-87	ml.	Added bsl2fat().
 * 14-Dec-87	ml.	Structure of BSL is changed (_again_!).
 *			Now, first entry in BSL contains number VENDOR
 *			entries.  First byte of 2nd entry is the checksum
 *			byte, while 2nd and 3rd bytes are reserved for 
 *			future use.
 * 08-Nov-87	jye. change or add codes so that can be used for MS-DOS
 *
 */

#include "obdefs.h"
#include "osbind.h"
#include "mydefs.h"
#include "part.h"
#include "bsl.h" 
#include "hdx.h"
#include "addr.h" 
#include "myerror.h" 

/* Globals */
BYTE *bsl;			/* bad sector list */
long bslsiz;			/* num sectors BSL occupies */
SECTOR badbuf[WARNBADSECTS];	/* bad sectors buffer */
extern int tformat;		/* 1: called by Format */


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


/*
 *  Set BSL parameters (starting sector and size of BSL) into
 *  root sector image.
 *	Input:
 *		image - root sector image.
 */

sbslparm(image)
char *image;
{
    ((RSECT *)(image + 0x200 - sizeof(RSECT)))->bsl_st = STBSL;
    ((RSECT *)(image + 0x200 - sizeof(RSECT)))->bsl_cnt = bslsiz;
}


/* 
 *  Create a BSL in memory.
 *	Input:
 *		pdev - physical unit BSL will belong to.
 *		type - kind of BSL to be created. NEW or EXPAND.
 *		nents - number of VENDOR entries BSL should hold.
 *	Output:
 *		bsl - pointer to the BSL. (in bsl.h)
 *	Return:
 *		OK - everything is fine.
 *		ERROR - anything is wrong.
 *	Comment:
 *		"NEW" means to create a totally new BSL.
 *		"EXPAND" means to expand an existing BSL.
 */
creabsl(pdev, type, nents)
int  pdev;	/* physical unit number */
int  type;	/* kind of BSL to be created */
long  nents;	/* num VENDOR entries in BSL */
{
    BYTE *newbsl;  /* BSL just created */
    long l, size;  /* l - index into BSL;  size - size of BSL in bytes */ 
    long start;	   /* where to start initializing entries to zeroes */
    long nument();

    if (nents == 0) {	/* no VENDOR entries specified */
        size = 512L;	/* default size of BSL to 1 sector */
    } else {	   /* num VENDOR entries is specified */
        /*------------------------------------------------------*/
        /* Calculate length of BSL in bytes.			*/
        /* Have to add space for reserved entries and USER list	*/
        /* (note: (+1) to round up)				*/
        /*------------------------------------------------------*/
	size = (((nents + RENT + WARNBADSECTS)/EPS) + 1) * 512L;
    }
    
    /* allocate enough memory for new BSL */
    if ((newbsl = (BYTE *)mymalloc((int)size)) <= 0)
        return err(nomemory);
    
    if (type == NEW) {	/* a new BSL */
        start = 0;	/* start at 0th entry, i.e. init whole BSL to 0s */
    }    
    else {		/* expand the BSL */
        /* start init to 0s after VENDOR list */
	start = (nument(VENDOR) + RENT) * BPE;
	
        /* copy original BSL into this expanded memory */
        for (l = 0; l < start; l++)
            newbsl[l] = bsl[l];
    }
        
            
    /* free up old BSL */
    if (bsl > 0) free(bsl);
    bsl = newbsl;
    
    /* init BSL to zeroes beginning at 'start'th entry */
    for (l = start; l < size; l++)
        bsl[l] = 0;
        
    /* install BSL info */
    bslsiz = size/512;	/* current num sectors BSL occupies */
    put3bytes(bsl, nents);  /* num VENDOR entries */
    mkmagic();	/* make the BSL checks sum to BSLMAGIC byte-wise */
    					  
    return OK;
}


/*
 *  Read the BSL into memory.
 *	Input:
 *		pdev - physical unit that contains the BSL.
 *	Output:
 *		bsl - pointer to the BSL.  (in bsl.h)
 *	Return:
 *		OK - everything is fine.
 *		INVALID - BSL doesn't checksum correctly.
 *		ERROR - can't read BSL.
 */
rdbsl(pdev)
int pdev;	/* physical unit to read from */
{
    int ret;
    
    if ((ret = rdsects(pdev, (UWORD)bslsiz, bsl, (SECTOR)STBSL)) != 0) {
    	if (tsterr(ret) != OK) {
    	    if (tformat == FALSE)
	        err(bslread);
		}
	return ERROR;
    }
    	
    return(sumbsl());	/* Checksum BSL and return */
}


/*
 *  Count number of entries in the requested portion of BSL.
 *	Input:
 *		portion - portion of BSL.  MEDIA, VENDOR, USER or UNUSED.
 *	Return:
 *		Number of entries of the requested portion.
 *	Comments:
 *		There are 3 bytes per entry (BPE), and the first 2 entries
 *	are reserved (RENT) for BSL info.
 */
long
nument(portion)
int portion;		/* portion of BSL to be counted */
{
    long  vdr, usr;	    /* num ent in VENDOR list, num ent in USER list */
    long  nbytes, offset;   /* BSL's len in bytes, index into BSL */
    long  get3bytes();
    
    /* 2nd entry in BSL contains num entries in VENDOR list */
    vdr = get3bytes(bsl);
    
    if (portion == VENDOR)  return (vdr);
    
    nbytes = bslsiz*512;    /* num bytes in BSL */
    
    /* num bytes available for valid entries */
    /* (need this because nbytes may not be divisible by BPE) */
    nbytes -= (nbytes % BPE);
    
    /* find out num entries in USER list */
    usr = 0;
    for (offset = (RENT+vdr)*BPE;  /* index into beginning of USER list */
         (offset < nbytes)	   /* while not at end of BSL */
	 && get3bytes(bsl+offset); /* and it's a used entry */
         offset += BPE)		   /* increment index */
        usr++;		/* increment num entries for USER list */
         
    if (portion == USER)
        return (usr);		/* num entries in USER list */
        
    if (portion == MEDIA)
        return (vdr+usr);	/* num entries in MEDIA list */     
        
    /* portion == UNUSED */
    return ((nbytes/BPE)-RENT-vdr-usr);
}


/*
 *  Write the BSL into the disk.
 *	Input:
 *		pdev - physical unit number BSL belongs to.
 *		bsl - pointer to buffer containing the BSL. (in bsl.h)
 *	Return:
 *		OK - everything is fine.
 *		ERROR - can't write BSL.
 */
wrbsl(pdev)
int pdev;	/* physical unit number */
{
    int ret;			/* return code */

	*((int *)(bsl + 0x4)) = 0; 	   /* set the 4th & 5th byte to 0 in BSL */
	mkmagic();
    if ((ret = wrsects(pdev, (UWORD)bslsiz, bsl, (SECTOR)STBSL)) != 0) {
    	if (tsterr(ret) != OK)
    	    err(bslwrite);
    	return ERROR;
    }

    return OK;
} 


/*
 *  Sort the BSL in memory in ascending order.
 *	Input:
 *		entries - number of used entries in BSL
 *		bsl - pointer to the BSL. (in bsl.h)
 *	Output:
 *		a sorted bsl.
 *	Algorithm:
 *		Bubble sort.
 *	Comments:
 *		The reserved entries won't be sorted.
 */
sortbsl(entries)
long  entries;	/* num entries in BSL */
{
    long  i, e1, e2;
    long  start;	/* beginning byte of entries in BSL */
    long  end;		/* tail byte of BSL */
    int   change;	/* signal if changes have been made in current pass */
    long  get3bytes();
    
    if (entries == 0L || entries == 1L)	/* BSL is empty */
        return;
            
    change = 1;		/* assume list is not in order */
    start = RENT*BPE;	/* beginning of entries in BSL */
    end = entries * BPE;
    while (1) {
    	if (change == 0)	/* if no changes made, DONE --> HOME */
	    return;
    	
    	change = 0;    /* assume list is in order */
    	for (i = start; i <= end; i += BPE) {
    	    e1 = get3bytes(bsl+i);
    	    e2 = get3bytes(bsl+i+BPE);
    	    if (e1 > e2) {		    /* switch if out of order */
    	    	put3bytes(bsl+i, e2);
    	    	put3bytes(bsl+i+BPE, e1);
    	    	change = 1;
    	    }
    	}
    	end -= BPE;
    }
}
 

/*
 *  Search through a sorted BSL for a given sector number.
 *	Input:
 *		sect - sector number searching for.
 *		entries - number of used entries in the BSL.
 *	Return:
 *		YES - if given sector is found.
 *		NO - if given sector is not found.
 *	Algorithm:
 *		Binary Search.
 */
srchbsl(sect, entries)
SECTOR  sect;	/* sector searching for */
long  entries;	/* num used entries in BSL */
{
    long  start, mid, end; /* start, middle and end indices into list */
    SECTOR  temp;	   /* sector number in middle of list */
    long  get3bytes();

    start = RENT;		/* start after reserved entries */
    end = entries+RENT-1;	/* end of BSL */ 
    
    while (1) {
     	mid = (start + end) / 2;		/* middle entry in list */
    	temp = get3bytes(bsl+(mid*BPE));	/* sector num at mid entry */
    	
    	if (sect == temp)	/* given sector == sector at mid entry */
    	    return YES;		/* given sector found in list */
    	else if (sect < temp)	/* given sector < sector at mid entry */
    	    end = mid - 1;	/* limit search to smaller sector num */
    	else			/* given sector > sector at mid entry */
    	    start = mid + 1;	/* limit search to larger sector num */
    	    
    	if (end < start)	/* list is exhausted */
    	    return NO;		/* can't find given sector */    
    }
}

 
/*
 *  Checksum (byte-wise) the BSL.
 *	Input:
 *		bsl - pointer to the BSL.  (in bsl.h)
 *	Return:
 *		OK - BSL checksum to BSLMAGIC (0xa5).
 *		INVALID - BSL does not checksum to BSLMAGIC.
 */
sumbsl()
{
    register BYTE sum;	/* byte-wise sum of BSL */
    long i;		/* index into BSL */
    long length;	/* length of BSL in bytes */

    length = bslsiz*512;	/* length of entire BSL */
    sum = 0;	/* initialize the sum */
    
    /* Sum up values in the BSL by byte */
    for (i = 0; i < length; i++) {
    	sum += bsl[i];
    }
    if (sum != BSLMAGIC) {	/* doesn't checksum correctly */
        return INVALID;
    }
    return OK;	/* checksum correctly */
}


/*
 *  Make the BSL checks sum to BSLMAGIC.
 */
mkmagic()
{
    register BYTE diff;	/* difference to make BSL checks sum correctly */
    long i;		/* index into BSL */
    long len;		/* length of BSL in bytes */
    
    len = bslsiz*512;	/* length of entire BSl */
    diff = BSLMAGIC;	/* initialize the difference */
    
    /* find out what number would make BSL checks sum to BSLMAGIC */
    for (i = 0; i < len; i++) {
    	diff -= bsl[i];
    }
    
    /* add that difference to checksum byte (1st byte of 2nd entry of BSL) */
    bsl[BPE] += diff;
}

 
/*
 *  Add bad sectors found to the Bad Sector List.
 *	Input:
 *		pdev - physical unit BSL belongs to.
 *		portion - portion of BSL to add to.  VENDOR or USER.
 *		nbad - number of bad sectors to be added.
 *	Return:
 *		toadd - number of new bad sectors added to the BSL.
 *		USRFULL - user part of the BSL is filled up.
 *		NOMEM - not enough memory for add buffer or BSL.
 *		ERROR - something is wrong.
 *	Comment:
 *		The entry will be added only if it is not already on the
 *	bad sector list.  Binary search is performed to guarantee this.
 *		If the VENDOR list is full, this routine will take care
 *	of the expansion of the list also.
 */
addbsl(pdev, portion, nbad) 
int pdev;		/* physical unit number */
int portion;		/* portion of BSL */
int nbad;		/* num of bad sectors to be added */
{
    long  entries;	/* num entries to be retained in BSL */
    long  empty;	/* num empty slots available for adding entries */
    long  end;		/* address of end of BSL */
    int  i, toadd;	/* index to badbuf, num of bad sectors to be added */
    int  ret = 0;	/* return code */
    SECTOR *addbuf;	/* bad sectors to be added to BSL */
    long  nument();
    
    /* Allocate memory for sector numbers of bad sectors to be added */
    if ((addbuf = (SECTOR *)mymalloc(nbad*4)) <= 0) {
    	err(nomemory);
        return NOMEM;
    }
    
    if (portion == VENDOR) {	/* adding to VENDOR list */
        entries = nument(VENDOR);   /* only keep the VENDOR list */
        empty = 0;		    /* there's no unused slot for VENDOR ent */
    } else {			/* adding to USER list */
        entries = nument(MEDIA);    /* keep entire list */
        empty = nument(UNUSED);     /* slots left unused */
    }
    sortbsl(entries);		/* sort BSL in ascending order */
    toadd = 0;			/* none is to be added to BSL yet */

    /* For all bad sectors found, search for them in the current BSL.
       Add them to the list only when they are not already recorded.  */    
    if (entries) {	/* only search if BSL is not empty */
	for (i = 0; i < nbad; i++) {
	    if (srchbsl(badbuf[i], entries) == NO) {
		addbuf[toadd] = badbuf[i];
		toadd++;
	    }
    	}
    } else {  /* add in all bad sectors found */
	for (i = 0; i < nbad; i++)
	    addbuf[i] = badbuf[i];
        toadd = nbad;
    }
    
    /* All bad sectors found have been recorded.  Nothing is added to BSL */
    if (toadd == 0) {
        if (portion == USER && (ret = rdbsl(pdev)) != OK) {
            if (ret == INVALID)
                err(cruptbsl);
	    goto togo;
	}
        ret = toadd;
    }
    
    /*------------------------------------------------------------------*/
    /* Check if there are enough empty slots for new entries.  If not,	*/
    /* determine what kind of entries we are adding, VENDOR or USER.	*/    
    /* Expand the BSL if we are adding to VENDOR list.  Give warning	*/
    /* if we are adding to USER list.				      	*/
    /*------------------------------------------------------------------*/
    if (toadd > empty) {
    	if (portion == VENDOR) {    /* this only happens at format time */
	    /* expanded BSL should hold (entries + toadd) VENDOR entries */
	    if (creabsl(pdev, EXPAND, entries+toadd) != OK)
	        goto togo;
    	} else {		    /* We are adding to USER list */
    	    err(manybad);
    	    toadd = empty;	/* num ent to add = empty slots available */
    	}
    }
    
    /* Read in orig unsorted list if adding USER entries */
    if (portion == USER) {
        if ((ret = rdbsl(pdev)) != OK) {
            if (ret == INVALID)
                err(cruptbsl);
            goto togo;
        }
    }
                
    /* Append new entries to end of BSL */
    end = bsl + (RENT + entries)*BPE;    /* end of BSL */
    for (i = 0; i < toadd; i++) {
    	put3bytes((end + i*BPE), addbuf[i]);
    }
    
    /* make BSL checks sum to magic number */
    mkmagic();

    if (portion == USER && toadd == empty) {
        ret = USRFULL;
        goto togo;
    }
        
    ret = toadd;
    
togo:
    if (addbuf > 0) free(addbuf);            
    return(ret);
}


/*
 *  Mark bad sectors from the BSL to FATs of a partition.
 *	Input:
 *		ldev - logical device the FATs belong to.
 *		fat0 - logical sector number of where FAT 0 starts.
 *		fatsiz - size of FAT in sectors.
 *		data - logical sector number of where data clusters start.
 *		portion - part of BSL to mark from.
 */
bsl2fat(ldev, fat0, fatsiz, data, portion)
int  ldev;	/* logical device number */
SECTOR fat0;	/* starting sector number (logical) of FAT 0 */ 
UWORD fatsiz;	/* FAT size */
SECTOR data;	/* starting sector number (logical) of data clusters */
int portion;	/* part of BSL to mark from, VENDOR or MEDIA */
{
    long nument(), entries;	/* num entries in the list to be considered */
    long i, end;		/* indices to the list to be considered */
	long get3bytes();
    SECTOR badsect;		/* a bad sector in the list */
    SECTOR pstart;		/* phys sector num where partition starts */
    SECTOR pdata;		/* phys sector num where data block starts */
    SECTOR pend;		/* phys sector num where data block ends */
    SECTOR logstart(), logend();
    int nbad;
    
    nbad = 0;			/* assume none to be marked */
    pstart = logstart(ldev);	/* find where partition starts */
    pdata = pstart + data;	/* find where data block starts */
    pend = logend(ldev);	/* find where data block ends */    
    entries = nument(portion);	/* find num entries in given portion */
    sortbsl(entries);		/* sort given portion of BSL */
    
    end = (RENT + entries) * BPE;
    
    /* Store vendor bad sectors of the logical device in badbuf */
    for (i = BPE*RENT; i < end; i += BPE) {
    	if ((badsect = get3bytes(bsl+i)) > pend)
    	    break;
    	    
    	if (badsect >= pdata) {
    	    badbuf[nbad++] = badsect;
    	    
    	    /* if badbuf overflows, mark what we have so far in the FAT */
    	    if (nbad == WARNBADSECTS) {
    	        if (fixbadcls(ldev, fat0, fatsiz, data, nbad) < 0) {
    	            return ERROR;
    	        }
    	        nbad = 0;	/* reinit num bad sectors in partition to 0 */
    	    }
    	}
    }
    
    /* Bad sectors in partition not marked in FAT yet */
    if (nbad) {
        if (fixbadcls(ldev, fat0, fatsiz, data, nbad) < 0) {
            return ERROR;
        }
    }
    
    return OK;
}


/*
 *  Count number of bad sectors on a logical drive recorded in BSL.
 *	Input:
 *		ldev - logical drive to be considered.
 *	Return:
 *		nbad - number of bad sectors found.
 */
long
cntbad(ldev)
int  ldev;	/* logical drive number */
{
    SECTOR pstart, pend;	/* phys starting and ending block of ldev */
    extern SECTOR logstart(), logend();
    long nbad=0L;		/* num bad sectors on ldev */
    long entries, nument(), bslend;
    long curr, get3bytes();
    int done, i;
    
    pstart = logstart(ldev);	/* starting block # of partition */
    pend = logend(ldev);	/* ending block # of partition */
    entries = nument(MEDIA);	/* num entries in BSL */
    sortbsl(entries);		/* sort BSL */
    
    done = 0;
    bslend = (RENT+entries) * BPE;
    for (i = RENT*BPE; (!done) && (i < bslend); i += BPE) {
    	curr = get3bytes(bsl+i);  /* get next entry in BSL */
    	if (curr < pstart)	  /* not within logical drive's range yet */
    	    continue;
    	if (curr <= pend)	  /* within logical drive's range */
    	    nbad++;
    	else done = 1;		  /* pass logical drive's range */
    }
    return (nbad);
}


/*
 *  Put a word into memory in 68000 format.
 *	Input:
 *		p - pointer to memory.
 *		i - word to be put.
 */
putword(p, i)
BYTE *p;
UWORD i;
{
    *p = i >> 8;
    *(p+1) = i;
}


/*
 *  Get a 68000 format word from memory.
 *	Input:
 *		p - pointer to memory.
 *	Return:
 *		i - word read from memory.
 */	    
getword(p)
BYTE *p;
{
    UWORD i=0x00ff, j=0x00ff;
    
    i &= *p;		/* first byte */
    i <<= 8;
    j &= *(p+1);	/* second byte */
    i |= j;
    return (i);
}


/*
 *  Put 3 bytes (68000 format) into memory.
 *	Input:
 *		p - pointer to memory.
 *		l - long which contains the 3 bytes at the low-bit end.
 */
put3bytes(p, l)
BYTE *p;
long l;
{
    *p = l >> 16;
    *(p+1) = l >> 8;
    *(p+2) = l;
}    


/*
 *  Get 3 bytes (68000 format) from memory.
 *	Input:
 *		p - pointer to memory.
 *	Return:
 *		l - a long which contains the 3 bytes read in last 3 bytes.
 */
long
get3bytes(p)
BYTE *p;
{
    long  k=0x000000ff, l=0x000000ff;
    
    l &= *p;		/* first byte */
    l <<= 16;
    k &= *(p+1);	/* second byte */
    k <<= 8;
    l |= k;
    k = 0x000000ff;
    k &= *(p+2);	/* third byte */
    l |= k;
    return (l);
}



/*
 *  Get 4 bytes (68000 format) from memory.
 *	Input:
 *		p - pointer to memory.
 *	Return:
 *		l - a long which contains the 3 bytes read in last 3 bytes.
 */
long
get4bytes(p)
BYTE *p;
{
    long  k=0x000000ff, l=0x000000ff;
    
    l &= *p;		/* first byte */
    l <<= 32;
    k &= *(p+1);	/* second byte */
    k <<= 16;
    l |= k;
    k = 0x000000ff;
    k &= *(p+2);	/* third byte */
	k <<= 8;
    l |= k;
    k = 0x000000ff;
    k &= *(p+3);	/* Fourth byte */
    l |= k;
    return (l);
}
