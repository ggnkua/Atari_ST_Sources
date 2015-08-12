/*
 *  Atari ST specific code
 *
 */
#include "as.h"
#include <osbind.h>


/*
 *  Return contents of 200hz system ticker
 *
 */
LONG get_tick()
{
	register LONG ssp;
	register LONG lw;

	ssp = Super(0L);
	lw = *(LONG *)0x4ba;
	Super(ssp);
	return lw;
}
