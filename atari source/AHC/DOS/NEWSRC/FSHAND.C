/*  fshand.c - file handle routines for the file system			*/



#include	"gportab.h"
#include	"fs.h"
#include	"bios.h"		/*  M01.01.01			*/
#include	"gemerror.h"




/*
**  xforce -
**
**	Function 0x46	f_force
**
**	Error returns
**		EIHNDL
**
**	Last modified	SCC	5 Apr 85
*/

long	xforce(std,h)
	int std,h;
{
	long	ixforce() ;
	return(ixforce(std,h,run));
}

/*
**  ixforce - force a std handle to a non-std handle.
**	if the std handle is for an open non-char device, close it
*/

long	ixforce(std,h,p)	
	PD *p;			
	int std;		/* std must	be a standard handle 	*/
	int h;			/* h   must NOT be a standard handle	*/
{
	long fh;

	if ((std < 0) || (std >= NUMSTD))
		return(EIHNDL);
	
	if( p->p_uft[std] > 0 )
		xclose( std ) ;

	if (h < 0)
		p->p_uft[std] = h;
	else
	{
		if (h < NUMSTD)
			return(EIHNDL);

		if ((fh = (long) sft[h-NUMSTD].f_ofd) < 0L)
			p->p_uft[std] = fh;
		else
		{
			p->p_uft[std] = h;
			sft[h-NUMSTD].f_use++;
		}
	}
	return(E_OK);
}



/*
**  syshnd -
*/

syshnd(h)
	int h;
{
	if (h >= NUMSTD)
		return(h-NUMSTD);

	if ((h = run->p_uft[h]) > 0 )
		return(h-NUMSTD);

	return(h);
}



/*
**  ixdirdup -
*/

ixdirdup(h,dn,p)
	PD *p;
	int h;			/* file handle				*/
	int dn;			/* directory number			*/
{
	p->p_curdir[h] = dn;
	diruse[dn]++;
}


/*
**  dup -
**	duplicate a file handle.
**
**	Function 0x45	f_dup
**
**	Error returns
**		EIHNDL
**		ENHNDL
**
**	Last modified	SCC	 5 Apr 85
*/

long	dup(h)	
	int h;			/*+ h must be a standard handle (checked) */
{
	register int i;

	if ((h<0) || (h >= NUMSTD))
		return(EIHNDL);		/* only dup standard */

	for (i = 0; i < OPNFILES; i++)	/* find the first free handle */
		if (!sft[i].f_own)
			break;

	if (i == OPNFILES)
		return(ENHNDL);		/* no free handles */

	sft[i].f_own = run;

	if ((h = run->p_uft[h]) > 0)
		sft[i].f_ofd = sft[h-NUMSTD].f_ofd;
	else
		sft[i].f_ofd = (OFD *) h;

	sft[i].f_use = 1;

	return(i+NUMSTD);
}




