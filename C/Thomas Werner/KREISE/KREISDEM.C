/*----------------------------------------------------------------*/
/* Demo zum inkrementalen Kreisgenerator (nach Horns Algorithmus) */
/*			             		  								   					            */
/* Originalroutine in GFA-BASIC von Andreas Hollmann 							*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <tos.h>
#include <aes.h>
#include <vdi.h>
#include "kreise.h"

extern	int	handle;


void gem_prg()
{
	int						i, r, type, t[3];
	
	
	t[0] = 0xFFFF;				/* durchgezogene Linie */
	t[1] = 0xAAAA;	   	  /* gepunktete Linie */
	t[2] = 0xEEEE;				/* gestrichelte Linie */
	
	for (i=0; i<3; i++)
	{
		type = t[i];
		
	  graf_mouse(M_OFF,0);
		v_clrwk(handle);
  	graf_mouse(M_ON,0);
	
		for (r=2; r<80; r+=5)
		{
	  vsl_type(handle, 7);
	  vsl_udsty(handle,type);
	  graf_mouse(M_OFF,0);
	  v_arc(handle,480,199,r,0,3600);  	/* VDI-'Kreis'  */
	  graf_mouse(M_ON,0);
		vsl_type(handle, 1);
	  circle(160,199,r,type);      			/* echter Kreis */
		}
		Crawcin();
	}
}
