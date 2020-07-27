/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 90/10/19 17:03:08 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	writefns.c,v $
* Revision 1.3  90/10/19  17:03:08  apratt
* Added -n flag and noheaderflag variable.
* 
* Revision 1.2  89/03/30  14:10:31  apratt
* Added -h option: sets hflags in prg header (aln.c, writefns.c)
* 
* Revision 1.1  88/08/23  14:20:37  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.3 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/writefns.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * writefns: 
 * write_ofile(header) creates ofile[.o], writes image, closes it
 * write_prg(header) creates ofile[.prg], writes image, closes it
 * write_abs(header) creates ofile[.abs], writes image, closes it
 * write_map(header) sorts symbols, writes load map to stdout
 */

#include "aln.h"

static long dowrite();

write_ofile(header)
register struct OHEADER *header;
{
    register int fd;
    register long osize;
    register struct OFILE *otemp;
    int i;
    char himage[36];

    if (index(ofile,'.') == NULL) {
	if (aflag) strcat(ofile,".abs");
	else strcat(ofile,".o");
    }

    if ((fd = CREAT(ofile)) < 0) {
	printf("Can't open output file %s\n",ofile);
	return TRUE;
    }

    /* build new header (with zeros in reserved bytes) */

    putword(himage,header->magic);
    putlong(himage+2,header->tsize);
    putlong(himage+6,header->dsize);
    putlong(himage+10,header->bsize);

    /* if abs link & no -s, don't write symbols */
    if (aflag && !sflag) putlong(himage+14,0L);
    else putlong(himage+14,header->ssize);

    if (!aflag) {
	for (i=0; i<10; i++) {
	    himage[18+i] = header->absrel.reloc.reserved[i];
	}
    }
    else {
	/* abs header */
	putlong(himage+18,header->absrel.abs.stksize);
	putlong(himage+22,header->absrel.abs.tstart);
	putword(himage+26,header->absrel.abs.rbflag);
	putlong(himage+28,header->absrel.abs.dstart);
	putlong(himage+32,header->absrel.abs.bstart);
    }
    
    /* write the header, but not if noheaderflag */
    if (aflag) {
    	if (!noheaderflag)
	    if (WRITE(fd,himage,36L) != 36) goto werror;
    }
    else {
	if (WRITE(fd,himage,28L) != 28) goto werror;
    }
    
    /* write the text & data segment of each ofile */
    for (otemp = olist; otemp != NULL; otemp = otemp->o_next) {
	osize = otemp->o_header.tsize;
	if (osize) {
	    if (WRITE(fd,otemp->o_image+28,osize) != osize) goto werror;
#ifdef JAGUAR
	    if (phrasepad(fd, osize, 0x4e71))		/* pad to a phrase boundary with no-ops */
		goto werror;
#endif
	}
    }
    for (otemp = olist; otemp != NULL; otemp = otemp->o_next) {
	osize = otemp->o_header.dsize;
	if (osize) {
	    if (WRITE(fd,
		      (otemp->o_image +
		       28 +
		       otemp->o_header.tsize),
		      osize) != osize) goto werror;
#ifdef JAGUAR
	    if (phrasepad(fd, osize, 0))	/* pad to a phrase boundary with 0's */
		goto werror;
#endif
	}
    }

    /* write the symbols, if any.  Don't write if (aflag && !sflag) */
    if (!(aflag && !sflag) && header->ssize) {
	if (WRITE(fd,header->ostbase,header->ssize) != header->ssize)
	    goto werror;
    }

    /* write the fixups from each ofile */
    if (!aflag || (header->absrel.abs.rbflag == 0)) {
	for (otemp = olist; otemp != NULL; otemp = otemp->o_next) {
	    osize = otemp->o_header.tsize;
	    if (osize) {
		if (WRITE(fd,
			  (otemp->o_image +
			   28 +
			   otemp->o_header.tsize +
			   otemp->o_header.dsize +
			   otemp->o_header.ssize),
			  osize) != osize) goto werror;
#ifdef JAGUAR
	        if (phrasepad(fd, osize, F_INST))	/* text was padded with no-ops */
		    goto werror;
#endif
	    }
	}
	for (otemp = olist; otemp != NULL; otemp = otemp->o_next) {
	    osize = otemp->o_header.dsize;
	    if (osize) {
		if (WRITE(fd,
			  (otemp->o_image +
			   28 +
			   otemp->o_header.tsize +
			   otemp->o_header.dsize +
			   otemp->o_header.ssize +
			   otemp->o_header.tsize),
			  osize) != osize) goto werror;
#ifdef JAGUAR
	        if (phrasepad(fd, osize, F_ABS))	/* data was padded with 0's */
		    goto werror;
#endif
	    }
	}
    }
    
    /* close the file */
    if (CLOSE(fd)) {
	printf("Close error on output file %s\n",ofile);
	return TRUE;
    }
    else return FALSE;
    
  werror:
    printf("Write error on output file %s\n",ofile);
    CLOSE(fd);			/* try to close it anyway. */
    return TRUE;
}

write_map(header)
register struct OHEADER *header;
{
    register char *symtab = header->ostbase;
    register long ssize = header->ssize;
    register char *symend = symtab + ssize;
    register int segment = -1;
    register int type;
    register long value;
    int test();			/* defined in util.c */

    if (ssize == 0) return FALSE;
    qsort(symtab,(int)(ssize/14),14,test);

    printf("LOAD MAP\n\n");

    while (symtab != symend) {
	register char *temp;
	int third;
	char *c[3];
	register int i,j,n;
	
	type = getword(symtab+8);
	segment = type & T_SEG;
	printf("\n\n");
	switch(segment) {
	  case T_TEXT:
	    printf("TEXT-SEGMENT RELOCATABLE SYMBOLS\n\n");
	    break;
	  case T_DATA:
	    printf("DATA-SEGMENT RELOCATABLE SYMBOLS\n\n");
	    break;
	  case T_BSS:
	    printf("BSS-SEGMENT RELOCATABLE SYMBOLS\n\n");
	    break;
	  default:
	    printf("NON-RELOCATABLE SYMBOLS\n\n");
	    break;
	}
	for (temp = symtab, n = 0; temp < symend; n++, temp += 14) {
	    if ((getword(temp+8) & T_SEG) != segment) break;
	}
	third = (n+2)/3;
	c[0] = symtab;
	c[1] = symtab+third*14;
	c[2] = symtab+2*third*14;
	for (i = 0; i < third; i++) {
	    for (j=0; j<3; j++) {
		if (c[j] >= temp) break;
		type = getword(c[j]+8);
		value = getlong(c[j]+10);
		printf("%-8s ",make_string(c[j]));
	    
		if (type & T_GLOBAL) {
		    if (type & T_EXTERN) printf("C");
		    else printf("G");
		}
		else if (type & T_EXTERN) printf("E");
		else printf("L");
		
		if (type & T_FILE) printf("F");
		else if (type & T_EQUATED) printf("Q");
		else printf(" ");
		if (type & T_REGISTER) printf("R");
		else printf(" ");
		
		printf(" %08lx\t",value);
	    }
	    printf("\n");
	    c[0] += 14;
	    c[1] += 14;
	    c[2] += 14;
	}
	symtab = temp;
    }
    return FALSE;
}

write_prg(header)
register struct OHEADER *header;
{
    register long osize;
    register int fd;
    register struct OFILE *otemp;
    char himage[28];

    /* zero the symbol table size if symbols aren't to be included */
    
    /* build the output header */
    putword(himage,0x601a);
    putlong(himage+2,header->tsize);
    putlong(himage+6,header->dsize);
    putlong(himage+10,header->bsize);
    if (sflag) putlong(himage+14,header->ssize);
    else putlong(himage+14,0L); 
    putlong(himage+18,0L);
    putlong(himage+22,hflags);	/* this is new */
    putword(himage+26,0);

    /* open the file */
    if (index(ofile,'.') == NULL) strcat(ofile,".prg");
    if ((fd = CREAT(ofile)) < 0) {
	printf("Can't create output file %s\n",ofile);
	return TRUE;
    }

    DEBUG0("dobegin\n");
    dobegin(fd);
    
    /* write the header */
    DEBUG0("Write the header\n");
    if (dowrite(himage,28L) != 28) goto werror;

    /* write the text & data image from each ofile */
    for (otemp = olist; otemp != NULL; otemp = otemp->o_next) {
	osize = otemp->o_header.tsize;
	if (osize) {
	    DEBUG1("write %lx bytes text\n",osize);
	    if (dowrite(otemp->o_image+28,osize) != osize) goto werror;
#ifdef JAGUAR
	    if (phrasepad(fd, osize, 0x4e71))		/* pad to a phrase boundary with no-ops */
		goto werror;
#endif
	}
    }
    for (otemp = olist; otemp != NULL; otemp = otemp->o_next) {
	osize = otemp->o_header.dsize;
	if (osize) {
	    DEBUG1("write %lx bytes data\n",osize);
	    if (dowrite((otemp->o_image +
			 28 +
			 otemp->o_header.tsize),
			osize) != osize) goto werror;
	}
#ifdef JAGUAR
	    if (phrasepad(fd, osize, 0))	/* pad to a phrase boundary with 0's */
		goto werror;
#endif
    }

    /* write the symbol table, if any */
    if (sflag) {
	DEBUG0("write symbol table\n");
	if (dowrite(header->ostbase,header->ssize) != header->ssize) {
	    goto werror;
	}
    }

    /* write the fixups */
    DEBUG0("Write fixups\n");
    if (dowrite(header->fixups,header->fsize) != header->fsize) goto werror;
    DEBUG0("Close\n");
    if (doclose()) {
	printf("Close error on file %s\n",ofile);
	return TRUE;
    }
    else return FALSE;

  werror:
    printf("Write error on file %s\n",ofile);
    return TRUE;
}

#ifdef JAGUAR
/*
 * pad a (text or data) segment to a phrase boundary
 * returns TRUE if a write error occurs, false otherwise
 */
int
phrasepad(fd, segsize, value)
    int fd;
    long segsize;
    int value;
{
    long padsize;
    int i;
    char padarray[8];
    char *padptr;

    padsize = ((segsize+7) & ~7) - segsize;	/* how many bytes of padding are needed? */
    if (padsize) {
        padptr = padarray;
	for (i = 0; i < 4; i ++) {		/* fill the padding array */
	    putword(padptr, value);
	    padptr += 2;
	}
	if (WRITE(fd, padarray, padsize) != padsize)
	    return TRUE;
    }
    return FALSE;
}

#endif

static int ofd;

#ifdef ATARIST

/*
 * Atari ST output buffering code
 *
 * VERY Atari-specific.
 */

static char *bufstart, *bufptr, *bufend;

static dobegin(fd)
int fd;
{
    char *sp;
    extern char *_break;

    ofd = fd;
    bufstart = _break;
    bufptr = bufstart;
    bufend = (char *)(&sp) - 1024;
}

static long dowrite(buf,count)
char *buf;
long count;
{
    long orgcount = count;
    long icount;

    DEBUG2("dowrite(%lx,%lx): ",buf,count);

    while (count) {
	if (bufend - bufptr < count) {
	    icount = bufend-bufptr;
	    DEBUG2("too big: split to %lx and %lx; ",icount,count-icount);
	}
	else icount = count;
	
	bmove(buf,bufptr,icount);
	bufptr += icount;
	buf += icount;

	if (bufptr == bufend)
	    if (doflush()) return -1;

	count -= icount;
    }
    
    DEBUG0("write done\n");
    return orgcount;
}

static doclose()
{
    DEBUG0("close ");
    if (doflush()) return -1;
    DEBUG0("close done.\n");
    return CLOSE(ofd);
}

static doflush()
{
    DEBUG0("flush ");
    if (bufptr-bufstart) {
	if (WRITE(ofd,bufstart,(bufptr-bufstart)) != (bufptr - bufstart)) {
	    DEBUG0("Write error. ");
	    return TRUE;
	}
    
	bufptr = bufstart;
	DEBUG0("done. ");
    }
    return FALSE;
}

#else /* NOT ATARIST */

static dobegin(fd)
int fd;
{
    ofd = fd;
}

static long dowrite(buf,count)
char *buf;
long count;
{
    return WRITE(ofd,buf,count);
}

static doclose()
{
    return CLOSE(ofd);
}

#endif

