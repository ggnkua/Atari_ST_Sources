/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 89/09/05 14:24:20 $
* =======================================================================
*
* $Locker: apratt $
* =======================================================================
*
* $Log:	relmod.c,v $
* Revision 1.3  89/09/05  14:24:20  apratt
* Removed some debugging printf's for new -a arguments.
* 
* Revision 1.2  89/02/06  20:13:21  apratt
* New, correct handling of absolute linking in symfix...
* The variables tval, dval, and bval were not what they appeared to be.
* 
* Revision 1.1  88/08/23  14:20:30  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.3 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/relmod.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * relmod(header): Run through ofiles and their fixups and create a .prg-style
 * fixup list.  Place the number of bytes of fixups in the header.
 * 
 * symfix(header): Run through the symbol table and add the base of a symbol's
 * segment to its value.  This is what SID expects, rather than having each
 * segment zero-based.
 *
 * absmod(header): Run through ofiles and their fixups and perform the
 * fixups for segments which are absolute.  If, in the end, there are no
 * more fixups, set the "stripped fixups" flag in the header.  Finally,
 * create an absolute header (rather than relocatable).  The bases for
 * relocatable segments will be zero.
 */

#include "aln.h"

/* initial values are reasonable for a file with no fixups */

#define FIXBLOCK 256L

static char *outfixup = NULL;
static char *fixbase = "\0\0\0\0";
static char *fixend;		/* not initialized; not needed */
static long fixsize = 4;
static long lastfixup;		/* offset of last fixup */

relmod(header)
register struct OHEADER *header;
{
    register long pc = 0;
    register struct OFILE *otemp = olist;

#ifdef JAGUAR
    printf("\nWARNING: this version of ALN has not been tested with relocatable output!\n\n");
#endif
    while (otemp) {
	DEBUG1("\ndo_rel(%s...) (text)\n",otemp->o_name);
	if (do_rel((otemp->o_image+28),
		   (otemp->o_image +
		    28 +
		    otemp->o_header.tsize +
		    otemp->o_header.dsize +
		    otemp->o_header.ssize),
		   otemp->o_header.tsize,
		   pc,
		   header->tsize,
		   header->dsize,
		   otemp->o_image+28,
		   otemp)) {
		       return TRUE;
	}
#ifdef JAGUAR
	pc += (otemp->o_header.tsize+7) & ~7;	/* phrase align the segment */
#else
	pc += otemp->o_header.tsize;
#endif
	otemp = otemp->o_next;
    }
    
    otemp = olist;
    while (otemp) {
	DEBUG1("\ndo_rel(%s...) (data)\n",otemp->o_name);
	if (do_rel((otemp->o_image+28+otemp->o_header.tsize),
		   (otemp->o_image +
		    28 +
		    otemp->o_header.tsize +
		    otemp->o_header.dsize +
		    otemp->o_header.ssize +
		    otemp->o_header.tsize),
		   otemp->o_header.dsize,
		   pc,
		   header->tsize,
		   header->dsize,
		   otemp->o_image+28,
		   otemp)) {
		       return TRUE;
	}
#ifdef JAGUAR
	pc += (otemp->o_header.dsize+7) & ~7;
#else
	pc += otemp->o_header.dsize;
#endif
	otemp = otemp->o_next;
    }
    if (add_fixup(-1L)) return TRUE;
    header->fsize = fixsize;
    header->fixups = fixbase;
    return FALSE;
}

do_rel(dataptr,fixptr,size,pc,tsize,dsize,start,otemp)
register char *dataptr, *fixptr;
register long size, pc;		/* size & start location of this segment */
register long tsize,dsize;
register char *start;		/* start of text seg of this module */
struct OFILE *otemp;
{
    int longflag = FALSE;	/* long fixup flag */
    register int fixup;		/* the current fixup */
    register long offset;	/* argument to dofix */

    while (size) {
	fixup = getword(fixptr);
	switch(fixup & F_TYPE) {
	  case F_LONG:
	    DEBUG0("L");
	    if (longflag) {
		printf("Fixup error: two long fixups in a row ");
		printf("at offset %lx in ",dataptr-start);
		put_name(otemp);
		printf("\n");
		return TRUE;
	    }		
	    longflag = TRUE;
	    break;
	  case F_TEXT:
	    DEBUG0("T");
	    offset = 0L;
	    goto dofix;
	  case F_DATA:
	    DEBUG0("D");
	    offset = tsize;
	    goto dofix;
	  case F_BSS:
	    DEBUG0("B");
	    offset = tsize + dsize;
	  dofix:
	    if (!longflag) {
		printf("Fixup error: can't have a short fixup in an executable; ");
		printf("at offset %lx in ",dataptr-start);
		put_name(otemp);
		printf("\n");
		return TRUE;
	    }
	    longflag = FALSE;
	    putlong(dataptr-2,getlong(dataptr-2) + offset);
	    if (add_fixup(pc-2)) return TRUE;
	    break;
	  default:
	    DEBUG0(".");
	    longflag = FALSE;
	}
	pc += 2;
	dataptr += 2;
	size -= 2;
	fixptr += 2;
    }
    return FALSE;
}

add_fixup(offset)
long offset;
{
    if (offset == -1) {		/* trailing null */
	if (outfixup == NULL) return FALSE;
	else offset = lastfixup; /* so offset-lastfixup == 0 */
    }

    if (outfixup == NULL) {
	DEBUG0("F");
	if ((fixbase = malloc(FIXBLOCK)) == NULL) {
	    printf("Out of memory\n");
	    return TRUE;
	}
	fixend = fixbase + FIXBLOCK;
	putlong(fixbase,offset);
	outfixup = fixbase + 4;
	fixsize = 4;
	lastfixup = offset;
	return FALSE;
    }

    /* expand block as necessary. Emit 1's until <= 254, then emit last */
    while (1) {
	if (outfixup == fixend) {
	    DEBUG0("E");
	    if ((fixbase = realloc(fixbase,fixsize+FIXBLOCK)) == NULL) {
		printf("Out of memory\n");
		return TRUE;
	    }
	    outfixup = fixbase + fixsize;
	    fixend = outfixup + FIXBLOCK;
	}
	if ((offset - lastfixup) <= 254) {
	    *outfixup++ = offset - lastfixup;
	    fixsize++;
	    lastfixup = offset;
	    return FALSE;
	}
	else {
	    DEBUG0("S");
	    *outfixup++ = 1;
	    lastfixup += 254;
	    fixsize++;
	}
    }
}

#include <setjmp.h>
static jmp_buf err_jmp;
static int treloc, dreloc, breloc; 	/* initialized to FALSE */
long tbase, dbase, bbase;

/*
 * getbase: determine the base address and reloc flag for each segment.
 * This is necessarily recursive since any seg can be contiguous with
 * any other seg (but they can't be mutually contiguous!), so you might
 * have to determine them in any order.
 *
 * [tdb]flag values are:
 *  -1	relocatable
 *  -2	contiguous with text (inherits reloc flag too)
 *  -3	contiguous with data (inherits reloc flag too)
 *  -4	contiguous with bss (inherits reloc flag too)
 *  -5	already determined.
 * else	absolute at [tdb]val.
 */

getbase(n,header)
int n;
register struct OHEADER *header;
{
    static int nesting = 0;
    extern int ttype, dtype, btype;

/*    if (nesting == 0) printf("*");/**/
/*    printf("%c",n);/**/

    if (++nesting > 3) {
	printf("Error: mutually recursive segment bases\n");
	longjmp(err_jmp,-1);
    }

    switch (n) {
	case 't':
	    switch (ttype) {
		case -1: tbase = 0; treloc = TRUE; break;
	     /* case -2: error; */
		case -3:
		    getbase('d',header);
		    tbase = dbase + header->dsize;
		    treloc = dreloc;
		    break;
	        case -4:
		    getbase('b',header);
		    tbase = bbase + header->bsize;
		    treloc = breloc;
		    break;
		case -5: break;		/* already known */
		default: tbase = tval; treloc = FALSE; break;
	    }
	    ttype = -5;
	    break;

	case 'd':
	    switch (dtype) {
		case -1: dbase = 0; dreloc = TRUE; break;
		case -2:
		    getbase('t',header);
		    dbase = tbase + header->tsize;
		    dreloc = treloc;
		    break;
	     /*	case -3: error; */
		case -4:
		    getbase('b',header);
		    dbase = bbase + header->bsize;
		    dreloc = breloc;
		    break;
		case -5: break;		/* already known */
		default: dbase = dval; dreloc = FALSE; break;
	    }
	    dtype = -5;
	    break;

	case 'b':
	    switch (btype) {
		case -1: bbase = 0; breloc = TRUE; break;
		case -2:
		    getbase('t',header);
		    bbase = tbase + header->tsize;
		    breloc = treloc;
		    break;
		case -3:
		    getbase('d',header);
		    bbase = dbase + header->dsize;
		    breloc = dreloc;
		    break;
	     /*	case -4: error; */
		case -5: break;		/* already known */
		default: bbase = bval; breloc = FALSE; break;
	    }
	    btype = -5;
	    break;
    }
    --nesting;
}

symfix(header)
register struct OHEADER *header;
{
    register char *sptr = header->ostbase;
    register char *send = sptr + header->ssize;

    if (!aflag) {
	tbase = 0;
	dbase = header->tsize;
	bbase = dbase + header->dsize;
    }
    else {
    	getbase('t',header);
    	getbase('d',header);
    	getbase('b',header);
    }

    while (sptr < send) {
	switch(getword(sptr+8) & T_SEG) {
	  case T_TEXT:
	    putlong(sptr+10,getlong(sptr+10) + tbase);
	    break;
	  case T_DATA:
	    putlong(sptr+10,getlong(sptr+10) + dbase);
	    break;
	  case T_BSS:
	    putlong(sptr+10,getlong(sptr+10) + bbase);
	    break;
	}
	sptr += 14;
    }
}

/*
 * fixflag goes false when there are still relocatable fixups in the output
 */

static int fixflag = -1;

/*
 * absmod: perform fixups for which an address is available on the command
 * line: -a text data bss.  If there are ultimately no fixups to be done,
 * set the "relocation information stripped" flag in the header.  In any case,
 * make the header an absolute one, not relocatable.
 */

absmod(header)
register struct OHEADER *header;
{
    register struct OFILE *otemp = olist;

    /* (recursively) get the base addresses for these things */

    if (setjmp(err_jmp)) return -1;

    /* the bases are already set because symfix has already been called */

    while (otemp) {
	DEBUG1("\ndo_abs(%s...) (text)\n",otemp->o_name);
	if (do_abs((otemp->o_image+28),	/* dataptr */
		   (otemp->o_image +
		    28 +
		    otemp->o_header.tsize +
		    otemp->o_header.dsize +
		    otemp->o_header.ssize), /* fixptr */
		   otemp->o_header.tsize, /* size */
		   otemp->o_image+28, /* start of text seg */
		   otemp)) {
		       return TRUE;
		   }
	otemp = otemp->o_next;
    }
    otemp = olist;
    while (otemp) {
	DEBUG1("\ndo_abs(%s...) (data)\n",otemp->o_name);
	if (do_abs((otemp->o_image+28+otemp->o_header.tsize), /* dataptr */
		   (otemp->o_image +
		    28 +
		    otemp->o_header.tsize +
		    otemp->o_header.dsize +
		    otemp->o_header.ssize +
		    otemp->o_header.tsize), 	/* fixptr */
		   otemp->o_header.dsize, 	/* size */
		   otemp->o_image+28,	/* start of text seg */
		   otemp)) {
		       return TRUE;
		   }
	otemp = otemp->o_next;
    }
    header->magic = 0x601b;
    header->absrel.abs.rbflag = fixflag;
    header->absrel.abs.stksize = 0;
    header->absrel.abs.tstart = tbase;
    header->absrel.abs.dstart = dbase;
    header->absrel.abs.bstart = bbase;
    return FALSE;
}

do_abs(dataptr,fixptr,size,start,otemp)
char *dataptr, *fixptr;
long size;
char *start;			/* start of text seg of this module */
struct OFILE *otemp;
{
    register int longflag = FALSE;	/* long fixup flag */
    register int fixup;			/* the current fixup */
    long offset;			/* argument to dofix */
    short wordvalue;			/* used for overflow detection */
    int retval = 0;

    while (size) {
	fixup = getword(fixptr);
	switch(fixup & F_TYPE) {
	  case F_LONG:
	    DEBUG0("L");
	    if (longflag) {
		printf("Fixup error: two long fixups in a row ");
		printf("at offset %lx in ",dataptr - start);
		put_name(otemp);
		printf("\n");
		return TRUE;
	    }		
	    longflag = TRUE;
	    break;
	  case F_TEXT:
	    DEBUG0("T");
	    if (!treloc) {
		offset = tbase;
		goto dofix;
	    }
	    else {
		fixflag = 0;
		longflag = FALSE;
		break;
	    }
	  case F_DATA:
	    DEBUG0("D");
	    if (!dreloc) {
		offset = dbase;
		goto dofix;
	    }
	    else {
		fixflag = 0;
		longflag = FALSE;
		break;
	    }
	  case F_BSS:
	    DEBUG0("B");
	    if (!breloc) {
		offset = bbase;
		/* FALL THROUGH to dofix */
	    }
	    else {
		fixflag = 0;
		longflag = FALSE;
		break;
	    }
	  dofix:
	    if (longflag) putlong(dataptr-2,getlong(dataptr-2) + offset);
	    else {
		if ((wordvalue = (getword(dataptr) + offset)) 
		    != getword(dataptr) + offset) {
			printf("Warning: 16-bit absolute fixup overflow ");
			printf("at offset %lx in ",dataptr-start);
			put_name(otemp);
			printf("\n");
		}
		putword(dataptr,(int)(getword(dataptr)+offset));
	    }
	    putword(fixptr,F_ABS);
	    longflag = FALSE;
	    break;

	  default:
	    DEBUG0(".");
	    longflag = FALSE;
	}
	dataptr += 2;
	size -= 2;
	fixptr += 2;
    }
    return FALSE;	/* no error */
}

