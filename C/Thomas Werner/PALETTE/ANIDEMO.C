/*----------------------------------------------------------------*/
/*			         				 Animations-Demo    					            */
/*			             		  								   					            */
/* Originalroutine in MAXON-PASCAL von Christen Fihl							*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/


#include	<tos.h>
#include	<aes.h>
#include	<vdi.h>


typedef enum
{
    FALSE,
    TRUE
}
boolean;

  
extern	int	handle;

void	gem_prg(void)
{
	int			P1[16], P2[16], P3[16], n, d, k;
	boolean	Snow;
	
	void	Box(int x1, int y1, int x2, int y2);
	
	
	graf_mouse(ARROW,0);
	v_clrwk(handle);
	Snow = FALSE;
	  
  P1[0] = P1[4] = P1[8] = P1[12] = 0;
  P1[1] = P1[5] = P1[9] = P1[13] = 9;
  P1[2] = P1[6] = P1[10]= P1[14] = 2;
  P1[3] = P1[7] = P1[11]= P1[15] = 3;

  P2[0] = P2[1] = P2[2] = P2[3] = 0;
  P2[4] = P2[5] = P2[6] = P2[7] = 9;
  P2[8] = P2[9] = P2[10]= P2[11] = 2;
  P2[12]= P2[13]= P2[14]= P2[15] = 3;

  P3[0] = P3[12]= 0;
  P3[1] = P3[5] = P3[9] = P3[13]= 9;
  P3[2] = P3[4] = P3[6] = P3[8] = P3[10]= P3[14] = 2;
  P3[3] = P3[7] = P3[11]= P3[15] = 3;
	
	graf_mouse(M_OFF,0);
  vswr_mode(handle, MD_XOR);
  vsl_color(handle,2);
  Box(220,10,250,40);
  vsl_color(handle,8);
  Box(220+50,10,250+50,40);
  
  do
  {
  	n = 0;
	  vsl_color(handle,8);
	  Box(n+1,n+1,n+181,n+181);
    for (n=1; n<20; n++)
    {
		  vsl_color(handle,2);
      Box(n,n,n+180,n+180);
      if (!Snow)
      	Setpalette(P3);
      Setpalette(P1);
      evnt_timer(10,0);
		  vsl_color(handle,8);
      Box(n,n,n+180,n+180);
      Box(n+1,n+1,n+181,n+181);
      if (!Snow)
      	Setpalette(P3);
      Setpalette(P2);
      evnt_timer(10,0);
	  	vsl_color(handle,2);
      Box(n,n,n+180,n+180);
    }
    n=20+1;
	  vsl_color(handle,8);
    Box(n,n,n+180,n+180);
    graf_mkstate(&d, &d, &d, &k);
  }
  while(!(k&8));
	graf_mouse(M_ON,0);
}

/*----------------------------------------------------------------*/
/*											Rechteck zeichnen													*/
/*----------------------------------------------------------------*/

void	Box(int x1, int y1, int x2, int y2)
{
	int		xy[10];
	
	xy[0] = x1;
	xy[1] = y1;
	xy[2] = x2;
	xy[3] = y1;
	xy[4] = x2;
	xy[5] = y2;
	xy[6] = x1;
	xy[7] = y2;
	xy[8] = x1;
	xy[9] = y1;
	
	v_pline(handle, 5, xy);
}
