/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 90/05/23 13:19:51 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	resolve.c,v $
* Revision 1.4  90/05/23  13:19:51  apratt
* Fixed a bug in long PC-relative fixups - undiscovered until 68030 made
* those legal and more common.
* 
* Revision 1.3  90/04/20  17:12:42  apratt
* Added an error message: if -p or -q, and the output file actually
* contains a reference to a symbol whose index > 8191, it's an error,
* since you only have 13 bits for the symbol index in the fixup.
* 
* Revision 1.2  88/08/24  10:36:36  apratt
* Klist and qflag processing.
* 
* Revision 1.1  88/08/23  14:20:32  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.4 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/resolve.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * make_ofile: build the output symbol table from the unresolved list
 * and the commons from the hash table.  Then, relocate all the symbols
 * in all the object files, and add the appropriate ones to the output
 * symbol table (based on their globality and lflag).  Finally, go through
 * the ofiles' images and rework their fixups.
 *
 * For memory savings, this code also collapses symbols out of ofiles when
 * it's done with them, and realloc's the ofile image.
 */

#include "aln.h"

static long textsize, datasize, bsssize; /* cumulative sizes */
char *ost;		/* the output symbol table (global for ostlook) */

long docommon();

/*
 * macros to get you into a symbol table, and the fields of an ost symbol
 */

#define nth_sym(symptr,n) ((symptr) + ((n)*14L))

#define ost_type(index) (getword(nth_sym(ost,(index)) + 8))
#define ost_value(index) (getlong(nth_sym(ost,(index)) + 10))

/* symbol-index part of a fixup: shift BUT DON'T PRESERVE HI BIT! */
#define s_part(fixup) ((unsigned)(fixup) >> 3)

#define OST_BLOCK (14L*64)


/*
 * make_ofile(): create one big .o file from the images already in memory.
 * RETURNS a pointer an OHEADER.
 *
 * Note that the oheader is just the header for the output (plus some other
 * information).  The text, data, and fixups are all still in the ofile
 * images hanging off the global `olist'.
 */

struct OHEADER *make_ofile()
{
    char *ost_base();
    register struct OFILE *otemp, *oprev, *ohold;
    long tptr, dptr, bptr;			/* bases in runtime model */
    register struct OHEADER *header;
    int i;
    int ret = 0;

    textsize = datasize = bsssize = 0;

    /* for each object file, accumulate the sizes of the segments */
    /* but remove those object files which are unused */

    oprev = NULL;
    otemp = olist;
    while (otemp != NULL) {
	if (!(otemp->o_flags & O_ARCHIVE)) {
	    if ((otemp->o_flags & O_USED) == 0) {
		if (wflag) {
		    printf("Unused object file ");
		    put_name(otemp);
		    printf(" discarded.\n");
		}
		if (oprev == NULL) {
		    olist = otemp->o_next;
		}
		else {
		    oprev -> o_next = otemp->o_next;
		}
		ohold = otemp;
		free(ohold->o_image);
		free(ohold);
	    }
	    else {
#ifdef JAGUAR
		textsize += (otemp->o_header.tsize+7) & ~7;	/* make sure everything is phrase aligned */
		datasize += (otemp->o_header.dsize+7) & ~7;
		bsssize += (otemp->o_header.bsize+7) & ~7;
#else
		textsize += otemp->o_header.tsize;
		datasize += otemp->o_header.dsize;
		bsssize += otemp->o_header.bsize;
#endif
		oprev = otemp;
	    }
	}
	otemp = otemp->o_next;
    }
    
    /* place each unresolved symbol in the symbol table */
    if (dounresolved()) return NULL;

    /* place each common symbol in output symbol table */
    /* add the number of common bytes to bsssize if not partial link */

    if ((bptr = docommon(bsssize)) == -1) return NULL;
    hash_free();		/* we're done with hash tables! */

    if (!pflag || qflag) bsssize += bptr;

    /* for each file, relocate its symbols & add them to the output symtab. */

    tptr = 0;
    dptr = 0;
    bptr = 0;

    otemp = olist;
    oprev = NULL;
    while (otemp != NULL) {
	otemp->o_tbase = tptr;
	/* do the rest only for non-ARCHIVE markers */
	if (!(otemp->o_flags & O_ARCHIVE)) {
	    otemp->o_dbase = dptr;
	    otemp->o_bbase = bptr;
#ifdef JAGUAR
	    tptr += (otemp->o_header.tsize+7) & ~7;
	    dptr += (otemp->o_header.dsize+7) & ~7;
	    bptr += (otemp->o_header.bsize+7) & ~7;
#else
	    tptr += otemp->o_header.tsize;
	    dptr += otemp->o_header.dsize;
	    bptr += otemp->o_header.bsize;
#endif
	}

	/* for each symbol, (conditionally) add it to the ost */
	/* for ARCHIVE markers, this adds the symbol for the file & returns */
	if (dosym(otemp)) return NULL;
	if (otemp->o_flags & O_ARCHIVE) {
	    /* now that the archive is marked, remove it from list */
	    if (oprev == NULL) {
		olist = otemp->o_next;
	    }
	    else {
		oprev->o_next = otemp->o_next;
	    }
	    ohold = otemp;
	    if (ohold->o_image) free(ohold->o_image);
	    free(ohold);
	}
	else {
	    oprev = otemp;
	}
	otemp = otemp->o_next;
    }
    

#ifdef DEBUG
    if (_dbflag) dump_ost();
#endif DEBUG

    if ((header = Newoheader()) == NULL) {
	printf("Out of memory\n");
	return NULL;
    }
    
    /* fill in the output header */
    header->magic = 0x601a;
    header->tsize = textsize;
    header->dsize = datasize;
    header->bsize = bsssize;
    header->ssize = ost_size();
    header->ostbase = ost_base();
    for (i=0; i<10; i++) {
	header->absrel.reloc.reserved[i] = 0;
    }
    
    /*
     * for each file, relocate its text & data segments, copy to output
     * OR the result into ret so all files get moved (and errors reported)
     * before returning with the error condition.
     */

    for (otemp = olist; otemp != NULL; otemp = otemp->o_next) {
	if (!(otemp->o_flags & O_ARCHIVE)) {
	    ret |= write_seg(otemp,T_TEXT);
	    ret |= write_seg(otemp,T_DATA);
	}
    }
    return (ret ? (long)NULL : header);
}


/*
 * Dosym(): for this object file,
 * Add symbols to the output symbol table after relocating them.
 * 	Add local symbols only if lflag (but do relocate them).
 *	Don't add external symbols.
 *
 * Returns TRUE if ost_lookup returns an error (-1).
 */
dosym(ofile)
register struct OFILE *ofile;
{
    register char *symptr;
    register char *symend;
    register int type;
    register long value;
    int index;
    int i;
    
    symptr = (ofile->o_image +
	   28 +
	   ofile->o_header.tsize +
	   ofile->o_header.dsize); 			/* first symbol */
    symend = symptr + ofile->o_header.ssize;

    DEBUG1("DOSYM(%s)\n",ofile->o_name);

    if (fflag) {
	/* make a file symbol: copy up to null or '.', then null-fill rest */
	char namebuf[SYMLEN];
	char *ptr = ofile->o_name;
	
	for (i=0; i<SYMLEN; i++) {
	    if (*ptr && *ptr != '.') namebuf[i] = *ptr++;
	    else namebuf[i] = '\0';
	}
	if (ost_add(namebuf,
		    (T_TEXT | T_FILE |
		     (ofile->o_flags & O_ARCHIVE ? T_ARCHIVE : 0)),
		    ofile->o_tbase) == -1)
	    return TRUE;
	/* if this is just an ARCHIVE marker, return. */
	if (ofile->o_flags & O_ARCHIVE) return FALSE;
    }
    
    /*
     * for (each symbol) {
     *	relocate the symbol (change value field if relocatable);
     *	if (it belongs in ost) {
     *	    if (local || global) {
     *		index = add_it();
     *	    }
     *	    else (extern or common) {
     *		index = find_it()  (-1 if not there);
     *	    }
     *	    type |= T_OST;
     *	    value = index;
     *	}
     * }
     */
    
    for ( ; symptr != symend ; symptr += 14) {
	type = getword(symptr + 8);
	value = getlong(symptr+10);
	switch (type & T_SEG) {
	  case T_TEXT:
	    value += ofile->o_tbase;
	    break;
	  case T_DATA:
	    value += ofile->o_dbase;
	    break;
	  case T_BSS:
	    value += ofile->o_bbase;
	    break;
	  default:
	    goto dontput;
	}
	/* do this put only if the value changed */
	putlong(symptr+10,value);
dontput:
	if (lflag || !islocal(type)) {
	    if (islocal(type) || isglobal(type)) {
		if ((index = ost_add(symptr,type,value)) == -1) return TRUE;
	    }
	    else {
		index = -1;	/* belongs in OST, but don't look it up yet */
	    }
	    putword(symptr+8,type | T_OST);
	    *(int *)(symptr+10) = index;
	}
    }
    return FALSE;
}

/*
 * docommon(base): Add all common symbols to the output symbol table.
 * Return the number of bytes represented by common regions.
 * If (!pflag || qflag), nail the common regions down starting at 'base', 
 * and change the types of the common symbols to DEF/BSS.
 */

long docommon(base)
register long base;
{
    register struct HREC *hptr;
    register int i;
    register long nbytes = 0;
    register long temp;
    int first;

    DEBUG0("DOCOMMON\n");

    for (i=0; i<NBUCKETS; i++) {
	first = TRUE;
	for(hptr = htable[i]; hptr != NULL; hptr = hptr->h_next) {
/*
#ifdef DEBUG
	    if (first) {
		DEBUG1("Bucket #%d\n",i);
		first = FALSE;
	    }
#endif DEBUG
	    DEBUG1("%s: ",hptr->h_sym);
*/
	    if (iscommon(hptr->h_type)) {
/*		DEBUG0("COMMON ");/**/
		if (!pflag || qflag) {
		    /* set type and nail down value */
		    hptr->h_type = T_DEFINED | T_GLOBAL | T_BSS;
		    temp = hptr->h_value;
		    hptr->h_value = base;
		    base += temp;
		    nbytes += temp;
		}
		if (ost_add(hptr->h_sym,hptr->h_type,hptr->h_value) == -1) {
		    return -1;
		}
	    }
	    else {
/*		DEBUG0("GLOBAL ");/**/
	    }
/*	    DEBUG0("\n");	/* newline between buckets /**/
	}
    }
    return nbytes;
}

/*
 * dounresolved(): add unresolved externs to the output symbol table.
 */

dounresolved()
{
    register struct HREC *hptr, *htemp;

    DEBUG0("DOUNRESOLVED\n");
    hptr = unresolved;
    while (hptr != NULL) {
	if (ost_add(hptr->h_sym,T_EXTERN | T_DEFINED,0L) == -1)
	    return TRUE;
	htemp = hptr->h_next;
	free(hptr);
	hptr = htemp;
    }
    unresolved = NULL;
    return FALSE;
}
    

/*
 * write_seg: pass in an ofile and a flag: T_TEXT or T_DATA.
 */

write_seg(ofile,flag)
int flag;
register struct OFILE *ofile;
{
    register char *srcptr;		/* actual image start */
    register char *fixsrc;		/* start of fixups for image */
    register long count;		/* number of bytes involved */
    register int longflag = 0;		/* was last fixup F_LONG? */
    register int symtype;
    register long symvalue;
    int symindex;
    char *symstart;			/* start of symtab in this ofile */
    int fixup;				/* fixup word read from fixsrc */
    char *symptr;			/* ptr to this symbol for F_SYMBOL */
    register long pc;			/* current pc (for PC-relative) */
    short wordtemp;			/* used for overflow detection */
    int ret = FALSE;			/* goes TRUE when there's an error */

    symstart = (ofile->o_image +
		28 +
		ofile->o_header.tsize +
		ofile->o_header.dsize);

    srcptr = ofile->o_image + 28;
    fixsrc = srcptr + (ofile->o_header.tsize +
		       ofile->o_header.dsize +
		       ofile->o_header.ssize);

    if (flag == T_TEXT) {
	pc = ofile->o_tbase;
	count = ofile->o_header.tsize;
    }
    else {				/* data seg; add tsize to src's */
	srcptr += ofile->o_header.tsize;
	fixsrc += ofile->o_header.tsize;
	pc = textsize + ofile->o_dbase;
	count = ofile->o_header.dsize;
    }
    
    DEBUG2("\nWrite_seg(%s,%s):\n",
	   ofile->o_name,
	   flag == T_DATA ? "data" : "text");
    DEBUG3("srcptr:%lx fixsrc:%lx count:%lx\n", srcptr, fixsrc, count);

    for (; count; count -= 2) {		/* two bytes at a time */
	fixup = getword(fixsrc);
	switch(fixup & F_TYPE) {
	  case F_LONG:
	    DEBUG0("L");
	    if (longflag) {
		printf("Fixup error: two longword prefixes in a row\n");
		return TRUE;
	    }
	    longflag = TRUE;
	    break;
	  case F_TEXT:
	    DEBUG0("T");
	    if (longflag) {
		putlong(srcptr - 2,
			getlong(srcptr - 2) + ofile->o_tbase);
	    }
	    else {
		putword(srcptr,
			(int)(getword(srcptr) + ofile->o_tbase));
	    }
	    longflag = 0;
	    break;
	  case F_DATA:
	    DEBUG0("D");
	    if (longflag) {
		putlong(srcptr - 2,
			getlong(srcptr - 2) + ofile->o_dbase);
	    }
	    else {
		putword(srcptr,
			(int)(getword(srcptr) + ofile->o_dbase));
	    }
	    longflag = 0;
	    break;
	  case F_BSS:
	    DEBUG0("B");
	    if (longflag) {
		putlong(srcptr - 2,
			getlong(srcptr - 2) + ofile->o_bbase);
	    }
	    else {
		putword(srcptr,
			(int)(getword(srcptr) + ofile->o_bbase));
	    }
	    longflag = 0;
	    break;

	  case F_PC:
	    /*
	     * if OST {
	     *	get its index;
	     *	if (pflag) {
	     *	    make new PC fixup;
	     *	    done;
	     *	}
	     *	else symvalue = ostvalue;
	     * }
	     * else symvalue = value of symbol;
	     * symvalue -= current PC;
	     * dest = src + symvalue;
	     * fixup = ABS;
	     * break;
	     */

	    symptr = nth_sym(symstart,s_part(fixup));
	    symtype = getword(symptr+8);
	    DEBUG2("\nPC: %s (#%d): ",make_string(symptr),s_part(fixup));
	    if (symtype & T_OST) {
		if ((symindex = *(int *)(symptr+10)) == -1) {
		    symindex = ost_lookup(symptr);
		    *(int *)(symptr+10) = symindex;
		}
		if (pflag) {
		    /* data doesn't change, but fixup does */
		    if (symindex > 8191) {
			printf(
		"Error: more than 8192 symbols in output object file\n");
			ret = TRUE;
		    }
		    putword(fixsrc,F_PC + (symindex << 3));
		    longflag = 0;
		    break;
		}
		else {		/* !pflag */
		    symtype = ost_type(symindex);
		    symvalue = ost_value(symindex);
		}
	    }
	    else {		/* !ost */
		symtype = getword(symptr+8);
		symvalue = getlong(symptr+10);
	    }
	    symvalue -= pc;		/* offset by current pc */

	    if ((symtype & T_SEG) != T_TEXT) {
		printf(
		  "Warning: PC-relative fixup across segment boundaries in ");
		put_name(ofile);
		printf("\nSymbol ptr is %lx, symbol name is %s, type is %04x, value is %08lx\n",
		       symptr, make_string(symptr), symtype,symvalue);
	    }

	    /* at this point, symvalue has the value to add to src */
	    if (longflag) {
		/* if long, must offset by +2 (BUG until 5/90 was -2) */
		putlong(srcptr-2,(getlong(srcptr-2) + (symvalue+2)));
	    }
	    else {
		symvalue += getword(srcptr);
		if ((wordtemp=symvalue) != symvalue) {
		    printf("16-bit PC-relative overflow in file ");
		    put_name(ofile);
		    printf(", symbol %s\n",make_string(symptr));
		    ret = TRUE;
		}
		putword(srcptr,(int)symvalue);
	    }
	    putword(fixsrc,F_ABS);
	    longflag = 0;
	    break;

	  case F_SYMBOL:
	    symptr = nth_sym(symstart,s_part(fixup));
	    symtype = getword(symptr+8);
	    DEBUG1("\nSymbol %s: ",make_string(symptr));
	    if (symtype & T_OST) {
		DEBUG0("in ost");
		if ((symindex = *(int *)(symptr+10)) == -1) {
		    symindex = ost_lookup(symptr);
		    *(int *)(symptr+10) = symindex;
		    DEBUG0(", now");
		}
		DEBUG1(" #%d ",symindex);
		if (pflag) {
		    DEBUG0("new sym fixup\n");
		    /* data doesn't change, but fixup does */
		    if (symindex > 8191) {
			printf(
		"Error: more than 8192 symbols in output object file\n");
			ret = TRUE;
		    }
		    putword(fixsrc,F_SYMBOL + (symindex << 3));
		    longflag = 0;
		    break;
		}
		else {		/* !pflag */
		    symtype = ost_type(symindex);
		    symvalue = ost_value(symindex);
		}
	    }
	    else {		/* !ost */
		symtype = getword(symptr+8);
		symvalue = getlong(symptr+10);
	    }
	    /* at this point, symvalue has the value to add to src */
	    DEBUG1("value %lx ",symvalue);
	    if (longflag) {
		putlong(srcptr-2,(getlong(srcptr-2) + symvalue));
	    }
	    else {
		symvalue += getword(srcptr);
		if ((wordtemp = symvalue) != symvalue) {
		    printf("Warning: 16-bit overflow in file ");
		    put_name(ofile);
		    printf(", symbol %s\n",make_string(symptr));
		}
		putword(srcptr,(int)symvalue);
	    }
	    DEBUG0("now ");
	    switch(symtype & T_SEG) {
	      case T_TEXT:
		DEBUG0("text ");
		putword(fixsrc,F_TEXT);
		break;
	      case T_DATA:
		DEBUG0("data ");
		putword(fixsrc,F_DATA);
		break;
	      case T_BSS:
		DEBUG0("bss ");
		putword(fixsrc,F_BSS);
		break;
	      default:
		DEBUG0("abs ");
		putword(fixsrc,F_ABS);
		break;
	    }
	    DEBUG0("fixup\n");
	    longflag = 0;
	    break;

	  case F_ABS:
	    DEBUG0(".");
	    longflag = 0;
	    break;
	  case F_INST:
	    DEBUG0("I");
	    longflag = 0;
	    break;
	}
	fixsrc += 2;
	srcptr += 2;
	pc += 2;
    }
    return ret;		/* return TRUE if there was an error */
}


/*
 * the OST abstraction:
 * ost_add(name,type,value) => index in ost, -1 for error
 * ost_lookup(name) => index in ost, -1 for not found
 * ost_value(index) => symbol value of ost[index]
 * ost_type(index) => symbol type of ost[index]
 * ost_base() => pointer to the base of the ost
 * ost_size() => (long) size of the ost in bytes.
 *
 * Note that ost_value, _type, _base, and _size are all macros, and
 * they use some globals.  In a true abstraction, the globals would be
 * private to the ost module.
 */

#ifdef ATARIST

/*
 * If atarist, ost_look is implemented in assembly code.
 */
extern int ost_look();
int ost_index = 0;		/* index of next addition */
char *ost_end;
char *ost_ptr;

#else

static int ost_index = 0;	/* index of NEXT ADDITION */
static char *ost_end;
static char *ost_ptr;

#endif ATARIST

/*
 * ost_add: add a symbol's name, type, and value to the ost.
 * Return the index of the symbol in ost.
 * RETURNS -1 FOR ERROR.
 */

ost_add(name,type,value)
char *name;
int type;
long value;
{
    if (ost_index == 0) {	/* uninitialized? */
	DEBUG0("Initialize symbols ");
	if ((ost = malloc(OST_BLOCK)) == NULL) {
	    printf("Out of memory\n");
	    return -1;
	}
	ost_ptr = ost;
	ost_end = ost + OST_BLOCK;
    }
    else if (ost_ptr == ost_end) {
	DEBUG0("expand symbols ");
	if ((ost = realloc(ost,(ost_index*14L) + OST_BLOCK)) == NULL) {
	    printf("Out of memory\n");
	    return -1;
	}
	ost_ptr = ost + ost_index*14L;
	ost_end = ost_ptr + OST_BLOCK;
    }
/*
    DEBUG3("ost_add(%s,%04x,%lx) ",make_string(name),type,value);
    DEBUG1("=> %d\n",ost_index);
*/
    symcopy(ost_ptr,name);
    putword(ost_ptr+8,type);
    putlong(ost_ptr+10,value);
    ost_ptr += 14;
    return ost_index++;
}

/*
 * ost_lookup(sym): Return the index of the symbol in the ost.
 *
 * Returns -1 if the symbol isn't there.
 */

#ifndef ATARIST

ost_lookup(sym)
register char *sym;
{
    register int curindex = ost_index;
    register int index;
    register char *temp;

    /* look it up, return its index if it's there */
    for (index = 0, temp = ost;
	 index < curindex;
	 temp += 14, ++index) {
	     if ((getword(temp+8) & (T_GLOBAL | T_EXTERN)) &&
		 symcmp(temp,sym))
		 return index;
    }
    return -1;
}

#endif ATARIST

char *ost_base()
{
    return ost;
}

long ost_size()
{
    return ost_index * 14L;
}

#ifdef DEBUG
dump_ost()
{
    register char *temp = ost;
    while (temp < ost+ost_index*14L) {
	printf("%-8s %04x %08lx\n",
	       make_string(temp),getword(temp+8),getlong(temp+10));
	temp += 14;
    }
}
#endif DEBUG
