/*--------------------------------------------------------------*/
/*							Demo zu den vier öberblendroutinen							*/
/*																															*/
/*								(c) 1992 MAXON Computer GmbH									*/
/*--------------------------------------------------------------*/

#include <stdio.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include <math.h>
#include "fade.h"

extern	int	handle, work_out[];

void gem_prg(void)
{
	void 	*Bild1, *Bild2;
	int		w_out[57];
	
	void Zeichne_Bild(void);
	
	
	vq_extnd(handle,1, w_out);
	graf_mouse(ARROW,0);	
  Bild1 = Malloc(((long)(work_out[0]+1) * (long)(work_out[1]+1) * (long)w_out[4])/8);
  if (Bild1 == NULL)
  {
  	form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
  	return;
  }
  Bild2 = Malloc(((long)(work_out[0]+1) * (long)(work_out[1]+1) * (long)w_out[4])/8);
  if (Bild2 == NULL)
  {
  	form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
  	Mfree(Bild1);
  	return;
  }
	
	Setscreen(Bild1, Physbase(),-1);
	Zeichne_Bild();
	Setscreen(Bild2, Physbase(),-1);
	Zeichne_Bild();
	Setscreen(Physbase(), Physbase(),-1);
	
	
	graf_mouse(M_OFF, 0);
	
	add1fade(Bild1, Physbase(), 123457L);
	Crawcin();
	add8fade(Bild2, Physbase(), 117);
	Crawcin();
	rnd1fade(Bild1, Physbase());
	Crawcin();
	rnd8fade(Bild2, Physbase());
	Crawcin();
	
	graf_mouse(M_ON, 0);
	Mfree(Bild1);
	Mfree(Bild2);
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