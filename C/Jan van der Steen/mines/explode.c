#include <vdi.h>
#include <aes.h>
#include <stdlib.h>

#include "stdc.h"
#include "mines.h"
#include "explode.h"

extern int	vdi_handle;

/* #[putflash:		*/

void
putflash(i, j)
int i, j;
{
    static int rect[8] = {               0,   0, 127, 141,   0,   0,   0,  0 };
    static MFDB screen = { (void *) 0,   0,   0,   0,   0,   0,   0,   0,  0 };
    static MFDB shapep = { (void *) 1, 128, 142,   8,   1,   1,   0,   0,  0 };
    long which;

#define WIDTH	 128
#define HEIGTH	 142
#define sleep(t) evnt_timer((t), 0)

    mouse_off();

    rect[4] = OFFX+ i*PIXELS + PIXELS/2 -  WIDTH/2;
    rect[5] = OFFY+ j*PIXELS + PIXELS/2 - HEIGTH/2;
    rect[6] = rect[4] +  WIDTH -1;
    rect[7] = rect[5] + HEIGTH -1;

    for (which = 0; which < 6; which++) {
	shapep.fd_addr = expl[which];

	vro_cpyfm(vdi_handle, S_XOR_D, rect, &shapep, &screen);
	sleep(100);
	vro_cpyfm(vdi_handle, S_XOR_D, rect, &shapep, &screen);
    }
    mouse_on();
}

/* #]putflash:		*/
