/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:24 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	doobj.c,v $
* Revision 1.1  88/08/23  14:20:24  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/doobj.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * doobj.c: "do an object file" code for aln
 *
 * Read the object file in, place its OFILE record on the OLIST.
 * Add its exports to GLOBALS, its imports to the UNRESOLVED list,
 * and its common declarations to GLOBALS, too.
 *
 * doinclude takes a file name, its handle, and two symbols.
 * It builds a dummy header for the file (zero text, N data, zero bss),
 * a dummy relocation area (all zeroes), and a dummy symbol table
 * (sym1 at zero, sym2 at N, both DEFINED, GLOBAL, DATA).  Then it's
 * processed just like a normal object file.
 */

#include "aln.h"

/*
 * macro for max: good because longs, shorts, or pointers can be compared.
 */
#ifndef max
#define max(a,b) ((a) > (b) ? (a) : (b))
#endif max

/*
 * doobject: takes a file name, gets in its image, puts it on plist.
 * The image may already be in memory:  if so, the ptr arg is non-null.
 * If so, the file is already closed.
 * Note that the file is already open (from dofile()).
 * RETURNS a pointer to the OFILE structure for this file, so you can
 * diddle its flags (dofile sets O_USED for files on the command line).
 */

doobject(fname,fd,ptr)
char *fname;
int fd;
char *ptr;
{
    long size;
    
    DEBUG1("Do object file %s\n",fname);
    
    if (ptr == NULL) {
	size = FSIZE(fd);
	if ((ptr = malloc(size)) == NULL) {
	    printf("Out of memory while processing %s\n",fname);
	    CLOSE(fd);
	    return TRUE;
	}
	if (READ(fd,ptr,size) != size) {
	    printf("File read error on %s\n",fname);
	    CLOSE (fd);
	    free(ptr);
	    return TRUE;
	}
	CLOSE(fd);
    }    

    /* now add this image to the list of pending ofiles (plist) */
    /* This routine is shared by doinclude after it builds the image. */
    return pladd(ptr,fname);
}

doinclude(fname,handle,sym1,sym2,segment)
char *fname;
int handle;
char *sym1, *sym2;
int segment;			/* 0 for data segment, 1 for text segment */
{
    long fsize, dsize, size;	/* file, data seg, and image sizes */
    char *ptr, *sptr;
    int i;
    int symtype;

    DEBUG1("Do include file %s\n",fname);
    fsize = FSIZE(handle);
#ifdef JAGUAR
    dsize = (fsize+7) & ~7;	/* round up to a phrase boundary */
#else
    dsize = (fsize+1) & ~1;	/* round up to even number of bytes */
#endif

    /* image size is:
     * header +
     * 0 text +
     * fsize data +
     * fsize fixups +
     * two symbols
     */

    size = 28 + 2*dsize + 2*14;

    /* use calloc so the header & fixups initialize to zero */

    if ((ptr = calloc(size,1L)) == NULL) {
	printf("Out of memory while including %s\n",fname);
	CLOSE(handle);
	return TRUE;
    }
    if (READ(handle,ptr+28,fsize) != fsize) {
	printf("File read error on %s\n",fname);
	CLOSE(handle);
	free(ptr);
	return TRUE;
    }
    CLOSE(handle);

    /* build this image's dummy header */

    putword(ptr,0x601a);	/* magic */
    if (segment) {
	putlong(ptr+2,dsize);	/* text size */
	putlong(ptr+6,0L);	/* data size */
    } else {
	putlong(ptr+2,0L);		/* text size */
	putlong(ptr+6,dsize);	/* data size */
    }
    putlong(ptr+10,0L);		/* bss size */
    putlong(ptr+14,2*14L);	/* symbol table size */

    /* build this image's symbol table, at ptr + 28 + dsize */

    sptr = ptr + 28 + dsize;
    for (i=0; i<8; i++) {
	if (*sym1) sptr[i] = *sym1++;
    }
    symtype = (segment) ? (T_DEFINED|T_GLOBAL|T_TEXT) : (T_DEFINED|T_GLOBAL|T_DATA);

    putword(sptr+8,symtype);
    putlong(sptr+10,0L);	/* symbol's value is zero */
    sptr += 14;
    for (i=0; i<8; i++) {
	if (*sym2) sptr[i] = *sym2++;
    }
    putword(sptr+8,symtype);
    putlong(sptr+10,fsize);
    
    return pladd(ptr,fname);
}

pladd(ptr,fname)
char *ptr;
char *fname;
{
    if (plist == NULL) {
	plist = Newofile();
	plast = plist;
    }
    else {
	plast->o_next = Newofile();
	plast = plast->o_next;
    }
    if (plast == NULL) {
	printf("Out of memory\n");
	return TRUE;
    }
    
    if (strlen(path_tail(fname)) > FNLEN-1) {
	printf("File name too long: %s (sorry!)\n",fname);
	return TRUE;
    }
    strcpy(plast->o_name,path_tail(fname));
    *plast->o_arname = 0;		/* no archive name for this file */
    plast->o_image = ptr;
    plast->o_flags = O_USED;
    plast->o_next = NULL;
    return FALSE;
}

doobj(fname,ptr,aname,flags)
char *fname;
register char *ptr;
char *aname;
int flags;			/* the flags to give this ofile */
{
	register struct OFILE *Ofile;
	register char *temp;
	register int i;

	DEBUG3("Doobj(%s,%lx,%s)\n",fname,ptr,(*aname ? aname : "<none>"));
	if ((Ofile = Newofile()) == NULL) {
		printf("Out of memory processing %s\n",fname);
		return TRUE;
	}

	/* starting after all pathnames, etc., copy .o file name to Ofile */

	temp = path_tail(fname);

	if (strlen(temp) > FNLEN-1) {
	    printf("File name too long: %s (sorry!)\n",temp);
	    return TRUE;
	}
	if (strlen(aname) > FNLEN-1) {
	    printf("Archive name too long: %s (sorry!)\n",aname);
	    return TRUE;
	}
	strcpy(Ofile->o_name,temp);
	strcpy(Ofile->o_arname,aname);

	Ofile->o_next = NULL;
	Ofile->o_tbase = 0;
	Ofile->o_dbase = 0;
	Ofile->o_bbase = 0;
	Ofile->o_flags = flags;
	Ofile->o_image = ptr;
	    
	/* don't do anything if this is just an ARCHIVE marker */
	/* just add the file to the olist */
	if (!(flags & O_ARCHIVE)) {
	    Ofile->o_header.magic = getword(ptr);
	    Ofile->o_header.tsize = getlong(ptr+2);
	    Ofile->o_header.dsize = getlong(ptr+6);
	    Ofile->o_header.bsize = getlong(ptr+10);
	    Ofile->o_header.ssize = getlong(ptr+14);
	    for (i=0; i<10; i++) {
		Ofile->o_header.absrel.reloc.reserved[i] = *(ptr+18+i);
	    }
	    
#ifdef JAGUAR
	    /* round bss off to phrase boundary */
	    Ofile->o_header.bsize = (Ofile->o_header.bsize + 7) & ~7;
	    if (Ofile->o_header.dsize & 7) {
		printf("Warning: data segment size of ");
		put_name(Ofile);
		printf(" is not a phrase multiple\n");
	    }
#else
	    /* as68 is capable of producing odd-sized bss segments */
	    if (Ofile->o_header.bsize & 0x01) Ofile->o_header.bsize++;
#endif
	    /* check for odd sizes (or symbol table not a multiple of 14 long) */
	    if ((Ofile->o_header.tsize & 1) ||
		(Ofile->o_header.dsize & 1) ||
		(Ofile->o_header.bsize & 1) ||
		(Ofile->o_header.ssize % 14)) {
		    printf("Error: odd-sized segment in ");
		    put_name(Ofile);
		    printf("; link aborted.\n");
		    return TRUE;
	    }
	
	    if (add_symbols(Ofile)) return TRUE;
	}
	
	/* add this file to the olist */
	if (olist == NULL) olist = Ofile;
	else olast->o_next = Ofile;
	olast = Ofile;
	return FALSE;
}

/*
 * add_symbols: add the imported symbols from this file to unresolved,
 * and the global and common symbols to the exported hash table.
 *
 * Change old-style commons (type == T_EXTERN, value != 0) to new-style
 * ones (type == (T_GLOBAL | T_EXTERN)).
 */

add_symbols(Ofile)
register struct OFILE *Ofile;
{
    register long	nsymbols;
    register char  	*ptr;
    register int 	type;
    register long 	value;
    register struct HREC *hptr;

    DEBUG1("Add_symbols for file %s\n",Ofile->o_name);
    ptr = Ofile -> o_image + 28 + Ofile -> o_header.tsize +
	Ofile -> o_header.dsize;

				/* 14 is the size of a symbol in a .o file */
    for (nsymbols = (Ofile -> o_header.ssize / 14); nsymbols--;) {
	type = getword(ptr + 8);
	value = getlong(ptr + 10);

	/* clobber T_OST bit just in case it came in set */
	type &= ~T_OST;
	putword(ptr + 8,type);

	/* convert old-style commons to new-style ones. */
	if (((type & (T_EXTERN | T_GLOBAL)) == T_EXTERN) && (value != 0)) {
	    type |= T_COMMON;
	    putword(ptr + 8,type);
	}

	switch(type & T_COMMON) {
	  case T_COMMON:
	    if (value != 0) {
		if (hash_add(ptr,Ofile)) return TRUE;
		else break;
	    }
	    /* else FALL THROUGH for common with value == 0 */
	  case T_EXTERN:
	    if ((hptr = lookup(ptr)) != NULL) {
		hptr->h_ofile->o_flags |= O_USED;
	    }
	    else if (add_unresolved(ptr,Ofile)) return TRUE;
	    break;
	  case T_GLOBAL:
	    if (hash_add(ptr,Ofile)) return TRUE;
	    break;
	}
	ptr += 14;
    }
    return FALSE;
}

