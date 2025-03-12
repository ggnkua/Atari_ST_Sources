/*--------------------------------------------------------------------*/
/*								Demo zur Fastzoom-Routine														*/
/*																																		*/
/*	Originalroutine in GFA-BASIC: Gerald Schmieder										*/
/*	C-Konvertierung: Thomas Werner																		*/
/*	(c) 1992 MAXON Computer GmbH																			*/
/*--------------------------------------------------------------------*/


#include <tos.h>
#include <vdi.h>
#include <aes.h>
#include "fastzoom.h"


extern	int handle, work_out[];


void gem_prg()
{	
	int		i, j;
	MFDB	schirm;

	void init_MFDB(MFDB *block, int handle);

	
	init_MFDB(&schirm, handle);
	graf_mouse(M_OFF, 0);
	
	for (i=1; i<9; i+=2)
	{
		for (j=1; j<12; j+=3)
		{
			v_clrwk(handle);
			v_gtext(handle, 0, 16,"Zoomdemo");
			great(i,j,0,0,8*8,16,0,0,3,handle,&schirm);
			Crawcin();
		}
	}
	
	graf_mouse(M_ON, 0);
}


void init_MFDB(MFDB *block, int handle)
{
	block->fd_addr = 0;
	vq_extnd(handle, 1, work_out);
	block->fd_nplanes = work_out[4];
}