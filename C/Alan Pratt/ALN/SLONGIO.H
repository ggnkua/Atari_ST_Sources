/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:43 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	slongio.h,v $
* Revision 1.1  88/08/23  14:20:43  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/slongio.h,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * slongio.h: header for slongio.c; don't need slongio.o on ATARIST
 *
 * getlong(src) return a native long from the 68K-format long at src
 * getword(src) return a native word from the 68K-format word at src
 * putlong(dest,val)  fill dest with the 68K format of the native long `val'
 * putword(dest,val)  fill dest with the 68K format of the native word `val'
 * char *src, *dest;
 */

#if defined(ATARIST) || defined(ATARI_GCC)
/* these must evaluate their arguments only once! it's relied upon in	*/
/* write_dependencies							*/

#define getlong(src)		(*(long *)(src))
#define putlong(dest,val)	(*(long *)(dest) = (val))
#define getword(ptr)  		(*(short *)(ptr))
#define putword(dest,val)	(*(short *)(dest) = (val))

#else
#ifdef VAX
extern long getlong();
extern int getword();
extern putlong(), putword();

#else
#if 1+	/* deliberate syntax error: you must define one or the other */
#endif
#endif
#endif
