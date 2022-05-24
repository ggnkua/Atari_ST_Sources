/* Amiga Tempo -> STE DMA Frame Count(sample bvffer length) 	*/
/* Dodgy 'C' code By Griff.. (Compile with GCC 2.0 or above...) */

#include <stdio.h>
#define FILENAME "CIA_EMU.TAB"

void main()
{	FILE *out;
	void *x;
	double tempo,hz,cia_clock=709378.92,temponum=1773447.0;
	unsigned int i=0;
	out = fopen(FILENAME,"wb");
	x = (&i);
	fwrite(x,2,1,out);			/* tempo=0 case */
	for (tempo = 1 ; tempo <= 255 ; tempo++) 
	{	hz = (cia_clock/temponum)*tempo;
		i = (25033.0/hz);            	/* FRAME COUNT 	*/
		i = i << 16;
		fwrite(x,2,1,out);		/* OUTPUT IT!   */
	}
	fclose(out);
}
