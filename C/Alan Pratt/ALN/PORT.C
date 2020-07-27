/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:28 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	port.c,v $
* Revision 1.1  88/08/23  14:20:28  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/port.c,v $
* =======================================================================
*
*************************************************************************
*/
#include "port.h"

#if defined(VAX) || defined(ATARI_GCC)
#include <sys/types.h>
#include <sys/stat.h>
long FSIZE(fd)
int fd;
{ 
    struct stat temp;
    fstat(fd,&temp);
    return temp.st_size;
}
#endif VAX

#ifdef ATARIST
long FSIZE(fd)
register int fd;
{
	register long temp, hold;
	temp = Fseek(0L,fd,1);	/* get current position */
	hold = Fseek(0L,fd,2);	/* seek to EOF, hold byte number */
	Fseek(temp,fd,0);
	return hold;
}
#endif ATARIST
