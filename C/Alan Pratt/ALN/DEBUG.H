/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:42 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	debug.h,v $
* Revision 1.1  88/08/23  14:20:42  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/debug.h,v $
* =======================================================================
*
*************************************************************************
*/
/* debug.h: macros to help with debugging */

extern int _dbflag;

#ifdef VAX
#define flush ,fflush(stdout)
#else
#define flush /**/
#endif

#define DEBUG0(x) (_dbflag ? printf("%s",x) flush : 0)
#define DEBUG1(s,a) (_dbflag ? printf(s,a) flush : 0)
#define DEBUG2(s,a,b) (_dbflag ? printf(s,a,b) flush : 0)
#define DEBUG3(s,a,b,c) (_dbflag ? printf(s,a,b,c) flush : 0)
