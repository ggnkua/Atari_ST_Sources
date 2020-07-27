/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 89/06/15 14:10:40 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	bdcommon.c,v $
* Revision 1.2  89/06/15  14:10:40  apratt
* Fixed a bug where hitting exactly end of file caused an error
* ("Incomplete file header in archive") rather than normal eof.
* 
* Revision 1.1  88/08/23  14:20:18  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.2 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/bdcommon.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * bdcommon.c: shared routines between aln and builddir.
 */

/* for our purposes, builddir.h is a sufficient subset of aln.h */
#include "builddir.h"

/*
 * vector_or(dest,src,size)  dest |= src, for vectors of size vecsize.
 */

vector_or(i,j,vecsize)
register char *i;
register char *j;
int vecsize;
{
	register int k;
	for (k=vecsize; k; k--) *i++ |= *j++;
}

/*
 * find_file_number: find the file number of the module exporting a symbol
 *
 * This function is used from doarc.c, too.  That's why it takes so many
 * arguments rather then using globals in the build-directory phase.
 */

find_file_number(key,list,nelem)
register char *key;
register char *list;
int nelem;
{
    register int    i;
    register int    l;
    register int    u;
    register int    hold;
    register char * loc;

 /* binary search from Knuth */
    l = 1;
    u = nelem;
    for (;;) {
	if (u < l)
	    return -1;		/* not found */
	i = (l + u) >> 1;
	loc = list + ((i-1) * SYMSIZE);
	hold = strcmp (key, loc);
	if (hold < 0)
		u = i - 1;
	else if (hold == 0)
		return getword (loc+SYMLEN);
	else l = i + 1;
    }
}

/*
 * get_header: Fills its Header argument with the header of the next file
 *	       in the archive.
 * RETURNS: zero for end-of-file, nonzero otherwise.
 */

int get_header(ifd,Header)
struct ARHEADER *Header;
int ifd;
{
    register char *ptr;
    register int temp;
    char buffer[28];

#   ifdef ATARIST		/* we can read directly into the Header */

    if ((temp = READ(ifd,Header,28L)) != 28) {
	if (temp == 0) return 1;		/* eof */
	else if (temp > 0) {
	    if (Header->a_fname[0] == '\0') {	/* eof */
		return 1;
	    }
	    else {
		printf("Incomplete file header in archive\n");
		return 1;
	    }
	}
	else {
	    printf("Error reading archive\n");
	    return 1;
	}
    }
    if (Header->a_fname[0] == '\0') {
	return 1;		/* end of file */
    }

#   else /* not ATARI */

    if ((temp = READ(ifd,buffer,28L)) != 28) {
	if (temp >= 0)
	    if (buffer[0] == '\0') {	/* eof */
		return 1;
	    }
	    else {
		printf("Incomplete file header in archive\n");
		return 1;
	    }
	else {
	    printf("Error reading archive.\n");
	    return 1;
	}
    }
    if (buffer[0] == '\0') {
	return 1;
    }
    ptr = buffer;
    for (temp=0; temp<14; temp++)
	Header->a_fname[temp] = *ptr++;

    Header->a_modti = getlong(ptr); ptr += 4;
    Header->a_userid = *ptr++;
    Header->a_gid = *ptr++;
    Header->a_fimode = getword(ptr); ptr += 2;
    Header->a_fsize = getlong(ptr); ptr += 4;
    Header->reserved = getword(ptr); ptr += 2;

#   endif

    /* now we have the header, one way or the other */
    return 0;
}

/*
 * symcopy(dest,src) copy SYMLEN-1 characters plus a null from src to dest
 * ASSUMES SYMBOLS ARE ZERO TO EIGHT CHARACTERS. SYMLEN must be >= 9.
 */

symcopy(dest,src)
char *dest;
char *src;
{
    register long *d = (long *)dest;
    register long *s = (long *)src;
    
    *d++ = *s++;
    *d++ = *s++;
    *(char *)d = '\0';
}
