#include "sparrow.h"
#include <osbind.h>

/* This prgram sets the SDMA and RASCAL into a state that causes them
to copy the middle part of the screen to the top
1) Find the location of the screen, save in vidbase
2) Set SDMA record begin registers to vid_base
3) Set SDMA record end registers to vid_base + 0x1000
4) Set SDMA playback registers to vidbase + 0x2000
5) Set SDMA playback registers to vidbase + 0x3000
6) Set the MicroWire stuff to mask=0xFFE0 data=0xB920
7) turn on SDMA playback and record with looping
8) exit
*/

unsigned int bytehm,bytelm,bytell;
long vidbase;

doit()
{

bytehm=*(char *)0xFF8201L;
bytelm=*(char *)0xFF8203L;
bytell=*(char *)0xFF820dL;

bytehm=bytehm&0xFF;
bytelm=bytelm&0xFF;
bytell=bytell&0xFF;
vidbase=((long)bytehm<<16)+(bytelm<<8)+(bytell);

*s_dma_ctl=0x80;

*f_b_um=vidbase>>16;
*f_b_lm=(vidbase>>8)&(0xFFL);
*f_b_ll=vidbase&0xFFL;

vidbase+=0x2000L;

*f_e_um=vidbase>>16;
*f_e_lm=(vidbase>>8)&(0xFFL);
*f_e_ll=vidbase&0xFFL;

vidbase+=0x0L;

*s_dma_ctl=0x00;

*f_b_um=vidbase>>16;
*f_b_lm=(vidbase>>8)&(0xFFL);
*f_b_ll=vidbase&0xFFL;

vidbase+=0x2000L;

*f_e_um=vidbase>>16;
*f_e_lm=(vidbase>>8)&(0xFFL);
*f_e_ll=vidbase&0xFFL;

*uwire_mask=0xFFE0;
*uwire_data=0xB920;

*s_mode_ctl=0x43;

*s_dma_ctl=0x30;
*s_dma_ctl=0x33;
}

disable_loop()
{
*s_dma_ctl=0x0;
}

enable_loop()
{
*s_dma_ctl=0x30;
*s_dma_ctl=0x33;
}

inner_loop()
{
*uwire_mask=0xFFE0;
*uwire_data=0xB920;
}

monitor_sound()
{
*uwire_mask=0xFFE0;
*uwire_data=0xB940;
}

outer_loop()
{
*uwire_mask=0xFFE0;
*uwire_data=0xB960;
}

main()
{
int key;

Supexec(doit);
for (;;)
	{
	while (Bconstat(2)!=-1);
	key=Bconin(2);
	if (key=='r') Supexec(inner_loop);
	if (key=='c') Supexec(outer_loop);
	if (key=='s') Supexec(monitor_sound);
	if (key=='d') Supexec(disable_loop);
	if (key=='e') Supexec(enable_loop);
	if (key==' ') break;
	}
}
