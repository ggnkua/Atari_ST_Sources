/* test blitter */

#include <stdlib.h>
#include <stdio.h>
#include <osbind.h>

int main(void)
{
	short old = Blitmode(-1);
	printf( "Blitter %d\n", old );
	if (old & 2) {
		Blitmode( 3 /*old | 1*/ );
		printf( "Blitter enabled\n" );
	} else {
		printf( "Sorry no blitter\n" );
	}
	old = Blitmode(-1);
	printf( "Blitter is now %d\n", old );
	return(0);
}
