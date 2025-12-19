#include <tos.h>
#include <stdio.h>
#include <aes.h>

#include "irqtimer.h"


static long get_ticks_120mS(void)
{volatile long *_hz_200 = (long *)0x04BA;
 long time = 120/5;	/* 120 mS in ticks */
 long n_ticks = 0;
 long test;
 	
 	/* wait until the timer ticks! 
 	 */
 	test = *_hz_200;
 	while(test == *_hz_200);
 	
 	/* count the number of loops in 120 mS 
 	 */
	time += *_hz_200;	/* what time is it i 120 mS ? */	
	while (time > *_hz_200)
	{
		n_ticks++;
	}
	
	return n_ticks;
}


static long sync_ticks(void)
{long free_run;
 int  i;
 
	Supexec(get_ticks_120mS);

	free_run = 0;
	for (i = 1; i <= 16; i++)
		free_run += Supexec(get_ticks_120mS);
	
	/* round and take mean
	 */
	return (free_run+8) / 16;
}


static long get_mean_ticks(int  resync)
{static int index = 0;
 static long run[16];
 int    i;
 long   mean;
 
 	if (resync)
 	{
		mean = sync_ticks();
	
	 	/* copy sync-ticks into the mean array
		 */
		for (i = 0; i < 16; run[i++] = mean);
		
		return mean;
	}
	
	index++;
	index &= 0xF;
	
	run[index] = Supexec(get_ticks_120mS);
	
	mean = 0;
	for (i = 0; i < 16; i++)
		mean += run[i];
	
	/* round and take mean
	 */
	return (mean+8) / 16;
}
	
	
main()
{long free_run, run, total;
 double ratio;
 OBJECT *menu;
 int    msg[8], mx, my, mb, ks, kr, br, which;
 int	more, Index, i;
 
 	appl_init();
 	rsrc_load("irqtimer.rsc");
 	
	rsrc_gaddr(0,MENU,&menu);
 	menu_bar(menu, 1);

	graf_mouse(ARROW, 0);
	
	free_run = get_mean_ticks(1);


 	more = 1;
 	Index = 0;
 	
 	do
 	{
		which = evnt_multi(MU_MESAG | MU_TIMER,
			0x102, 0x03, 0x00,
			0, 0,0,0,0, 	0, 0,0,0,0,
			msg,
			500, 0,
			&mx, &my, &mb, &ks, &kr, &br);
			
		if (which & MU_MESAG && msg[0] == MN_SELECTED)
 		{
 			switch (msg[4])
 			{
 			case ABOUT:
 				form_alert(1,
					"[0][To Index the a background|"
					    "program - disable it and|"
					    "select Sync. Then start it,|"
					    "and Messure.][ OK ]");   
 				break;
 			case SYNC:
				free_run = get_mean_ticks(1);
			 	Index = 0;
			 	break;
 			case INDEX:
 				Index ^= 1;
				total = 0;
			 	i = 0;
				printf("\033H\n\n\n\n");
 				break;
 			case QUIT:
 				more = 0;
 			}
 			menu_tnormal(menu,msg[3],1);
 		}
 		
 		if (which & MU_TIMER && Index)
 		{
			++i;
			run = get_mean_ticks(0);
			total += run;
		
			ratio = 100.0*(free_run-run) / (double)free_run;
			wind_update(BEG_UPDATE);
			
			printf("%7.1lf", ratio);
				
			if (i&7)
				printf(",");
			else
			{
				ratio = 100.0/8.0*(8*free_run-total) / (double)free_run;		
				printf(" = <%7.1lf >\033H\n\n\n\n",ratio);
				total = 0;
			}
			
			wind_update(END_UPDATE);
			
		} 			
	} while (more);	
	
 	menu_bar(menu, 0);
 	rsrc_free();
	appl_exit();
	
	return 0;
} 