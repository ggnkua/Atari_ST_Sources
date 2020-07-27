/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:34 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	slongio.c,v $
* Revision 1.1  88/08/23  14:20:34  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/slongio.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * slongio.c: longio from memory
 *
 * getlong(src) return a native long from the 68K-format long at src
 * getword(src) return a native word from the 68K-format word at src
 * putlong(dest,val)  fill dest with the 68K format of the native long `val'
 * putword(dest,val)  fill dest with the 68K format of the native word `val'
 * char *src, *dest;
 */

/*
 * LONG format:
 * 68K:		VAX:
 * hh hl lh ll ==> ll lh hl hh
 *
 * WORD format:
 * 68K:		VAX:
 * lh ll       ==> ll lh 00 00
 *
 */

#ifdef VAX

long getlong(src)
register char *src;
{
    long temp;
    register char *out;

    out = (char *)&temp;

    *out++ = src[3];
    *out++ = src[2];
    *out++ = src[1];
    *out = src[0];
    return temp;
}

putlong(dest,val)
register char *dest;
register long val;
{
	*dest++ = (val >> 24);
	*dest++ = (val >> 16);
	*dest++ = (val >> 8);
	*dest = val;
}

int getword(src)
register char *src;
{
    int temp;
    register char *out;

    out = (char *)&temp;

    *out++ = src[1];
    *out++ = src[0];
    *out++ = 0;
    *out = 0;
    return temp;
}

putword(dest,val)
register char *dest;
register int val;
{
    *dest++ = (val >> 8);
    *dest = val;
}

#else	/* atarist */
static slongio () { ;}	/* place holder so c68 doesn't bomb */

#endif VAX
