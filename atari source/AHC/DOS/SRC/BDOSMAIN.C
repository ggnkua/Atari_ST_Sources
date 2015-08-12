/* bdosmain.c - 'front end' to bdos.  This is OEM definable module	*/


#include <gportab.h>
#include <bios.h>


/*
**  TIMESTAMP - set to 1 if it's okay for the bdos to print the time
**	stamp string at init time.  Otherwise, set to 0.
*/

#define	TIMESTAMP	1


/*
**  supstk - common sup stack for all procs.  OEMs may change the size of 
**	this stack.
*/

#define	SUPSIZ	1024
int	supstk[SUPSIZ];		



/*
**  bufl - buffer lists
**	two lists:  fat,dir / data
**	these lists should be initialized by the bios.
**	(vme bios does this in biosc.c)
*/

BCB *bufl[2];


extern		_osinit() ;
extern		kprintf() ; 
extern	char	*bdosts ;

/*
**  osinit - the bios calls this routine to initialize the os
*/

osinit()
{
	_osinit() ;			/*  real routine in bdos.arc	*/
#if	TIMESTAMP
	kprintf(bdosts) ;		/*  kprintf is in tools.arc	*/
					/*  bdosts is in bdos.arc	*/
#endif
}

