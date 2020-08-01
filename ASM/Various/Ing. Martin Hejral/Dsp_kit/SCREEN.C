/*******************************************************
* uses DSP to compute screen pixels in 16 bit gr. mode *
*******************************************************/

#include <tos.h>
#include <stdio.h>

#include "dspbind.h"
#include "sndbind.h"

void dsp_screen(void)
{
int *dma_buff,*new_scr,*old_scr;
int i;
long scr_size;
LINE input;

/* launch transfer from DSP to falcon RAM */
Buffoper(0);
scr_size = ((long)320*240*2);
if( (dma_buff=Malloc(scr_size*4)) == 0 ) {
	fprintf(stderr,"Can't allocate screen memory\n");
	return;
}
new_scr = dma_buff;
Setbuffer(1, new_scr, new_scr+scr_size/4 );	/* record buffer */
Buffoper( RECORD_REPEAT|RECORD_ENABLE );

old_scr = Logbase();
Setscreen( new_scr, new_scr, -1 );	/* show data from DSP */
printf("\t buff=$%p; ",new_scr);
Cconws("\x1BH\x1Bv");

input.maxlen = 80;
Cconrs( &input );

Setscreen( old_scr, old_scr, -1 );

/* stop DMA transfer */
Buffoper(0);
Mfree(dma_buff);
} /* dsp_screen() */
