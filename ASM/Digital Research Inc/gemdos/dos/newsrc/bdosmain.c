/* bdosmain.c - 'front end' to bdos.  This is OEM definable module	*/


#include <gportab.h>
#include <bios.h>


/*
**  TIMESTAMP - set to 1 if it's okay for the bdos to print the time
**	stamp string at init time.  Otherwise, set to 0.
*/

#define	TIMESTAMP	0




/*
**  bufl - buffer lists
**	two lists:  fat,dir / data
**	these lists should be initialized by the bios.
**	(vme bios does this in biosc.c)
*/

BCB *bufl[2];


extern		_osinit();

#if TIMESTAMP
extern		kprintf();
extern	char	*bdosts;
#endif

/*
**  osinit - the bios calls this routine to initialize the os
*/

osinit()
{
	_osinit();			/*  real routine in bdos.arc	*/

#if TIMESTAMP
	kprintf(bdosts);
#endif
}

