/*----------------------------------------------------------------*/
/*			       		  Demo zur	RADIER-Routine  				            */
/*			             		  								   					            */
/* Originalroutine in GFA-BASIC von Hans-H. Ackermann							*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <stdlib.h>
#include <math.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "radieren.h"

extern	int	handle, work_out[];


void gem_prg(void)
{
	void Zeichne_Bild(void);

	graf_mouse(ARROW, 0);
	Zeichne_Bild();
	form_alert(0,"[0][ Demo zur Radier-Routine   ][ weiter ]");
	Radieren();
	form_alert(1,"[0][ Demo-Ende   ][ Ok ]");
}


void Zeichne_Bild(void)
{
	int		i, x, y, r, xy[4];

	
	graf_mouse(M_OFF, 0);
	
	xy[0] = 0;
	xy[1] = 0;
	xy[2] = work_out[0];
	xy[3] = work_out[1];
	vs_clip(handle, 1, xy);
	
	v_clrwk(handle);
  vswr_mode(handle, 1);
  
  for (i=0; i<10; i++)
  {
  	x = abs(work_out[0]*(Random()/pow(2,24)));
  	y = abs(work_out[1]*(Random()/pow(2,24)));
  	r = 20 + abs(100*(Random()/pow(2,24)));
  	v_circle(handle, x, y, r);
  }
  
	vs_clip(handle, 0, xy);
	
	graf_mouse(M_ON, 0);
}