/*----------------------------------------------------------------*/
/*		 Routine zum Verschieben und Kopieren von Bildbereichen			*/
/*			             		  								   					            */
/* Originalroutine in GFA-BASIC von Hans-H. Ackermann							*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <stddef.h>
#include <stdlib.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>

extern	int		handle, work_out[];

MFDB		Schirm_mfdb;


void Verschieben(int Copy)
{
	int		Xl, Xr, X, Xt, Yl, Yr, Y, Yt, K, d, w_out[57], xy[4];
	MFDB	Puffer_mfdb, Zwischen_mfdb;
	void	*Puffer, *Zwischen;
	
	void	Get(int x1, int y1, int x2, int y2, void *p, MFDB *mp);
	void	Put(int x1, int y1, MFDB *mp, int Mode);
	void	Box(int x1, int y1, int x2, int y2);
	void	Box_filled(int x1, int y1, int x2, int y2);
	
	
	vq_extnd(handle,1, w_out);
	Schirm_mfdb.fd_addr = Physbase();
	Schirm_mfdb.fd_nplanes = w_out[4];
	Schirm_mfdb.fd_w = work_out[0] + 1;
	Schirm_mfdb.fd_h = work_out[1];
	Schirm_mfdb.fd_wdwidth = (work_out[0] + 1)/16;
	Schirm_mfdb.fd_stand = 0;
	
	xy[0] = 0;
	xy[1] = 0;
	xy[2] = work_out[0];
	xy[3] = work_out[1];
	vs_clip(handle,1,xy);
	
	do
	{
		while (graf_mkstate(&Xl,&Yl,&K,&d), (!(K&1))&&(!(K&2)));
		
		vswr_mode(handle, MD_XOR);
		vsl_type(handle,2);
		
    /***** Rahmen zeichnen *****/

		graf_mouse(THIN_CROSS,0);
		Xr = Xl;
		Yr = Yl;
		
    while ((K&1) && (!(K&2)))
    {
			Box(Xl,Yl,Xr,Yr);									/* Verschiebe Bildumrahmen */      while(graf_mkstate(&X,&Y,&K,&d), 
      		  ((K&1) && (!(K&2)) && (X==Xr) && (Y==Yr)));
      
	    if (X < Xl)                       /* Keine "negativen" Werte */
  	  {
  	  	X = Xl;
			  vsin_mode(handle,1,2);
			  vrq_locator(handle,X,Y, &d, &d, &d);
			}
  	  if (Y < Yl)
    	{
    		Y = Yl;
			  vsin_mode(handle,1,2);
			  vrq_locator(handle,X,Y, &d, &d, &d);
			}
			
			Box(Xl,Yl,Xr,Yr);									/* alten Rahmen loeschen */
			Xr = X;
			Yr = Y;
    }		
		vsl_type(handle,1);

	  Puffer = Malloc((long)(Xr-Xl+15) * (long)(Yr-Yl) * (long)w_out[4]);
  	if (Puffer == NULL)
	  {
  		form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
			vs_clip(handle,0,xy);
		  vswr_mode(handle, MD_REPLACE);
  		return;
	  }
	  Zwischen = Malloc((long)(Xr-Xl+15) * (long)(Yr-Yl) * (long)w_out[4]);
  	if (Zwischen == NULL)
	  {
	  	Mfree(Puffer);
  		form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
			vs_clip(handle,0,xy);
		  vswr_mode(handle, MD_REPLACE);
  		return;
	  }
		
    Get(Xl,Yl,Xr,Yr,Puffer,&Puffer_mfdb); /* Ausschnitt puffern */
        if(Copy!=1)									/* Nicht kopieren? */
    {			vsf_color(handle,0);
		  vswr_mode(handle, MD_REPLACE);
      Box_filled(Xl,Yl,Xr,Yr);	/* dann Original Åberdecken */			vsf_color(handle,1);
		}
		
		X = Xl;									/* Maus an Boxanfang */
		Y = Yl;
		vsin_mode(handle,1,2);
		vrq_locator(handle,X,Y, &d, &d, &d);
		graf_mouse(ARROW,0);
		while(graf_mkstate(&Xt,&Yt,&K,&d), 
					((!(K&1)) && (!(K&2)) && (Xt==Xr) && (Yt==Yr)));
		
    /***** Verschieben/Kopieren *****/
    while((!(K&1)) && (!(K&2)))
    {
	    Get(X,Y,Xr+(X-Xl),Yr+(Y-Yl),Zwischen,&Zwischen_mfdb); /* Hintergrund puffern */
			Put(X,Y,&Puffer_mfdb,3);		/* Ausschnitt zeigen */      while(graf_mkstate(&Xt,&Yt,&K,&d),
      			(!(K&1)) && (!(K&2)) && (X==Xt) && (Y==Yt));
			Put(X,Y,&Zwischen_mfdb,3);	/* Hintergrund zurÅckschreiben */
			X = Xt;
			Y = Yt;
    }
        Put(X,Y,&Puffer_mfdb,3);			/* Ausschnitt entgÅltig zeichnen */		Mfree(Puffer);
		Mfree(Zwischen);

		while (graf_mkstate(&Xl,&Yl,&K,&d), ((K&1)&&(!(K&2))));

  }while (!(K&2));
	graf_mouse(ARROW,0);
  vswr_mode(handle, MD_REPLACE);
	vs_clip(handle,0,xy);
}


void	Get(int x1, int y1, int x2, int y2, void *p, MFDB *mp)
{
	int	xy[8];


	xy[0] = x1;
	xy[1] = y1;
	xy[2] = x2;
	xy[3] = y2;
	xy[4] = 0;
	xy[5] = 0;
	xy[6] = x2 - x1;
	xy[7] = y2 - y1;
	
	mp->fd_addr = p;
	mp->fd_w = x2 - x1;
	mp->fd_h = y2 - y1;
	mp->fd_wdwidth = ((mp->fd_w+15)&0xFFF0)/16;
	mp->fd_nplanes = Schirm_mfdb.fd_nplanes;
	mp->fd_stand = 0;
	
	graf_mouse(M_OFF, 0);
	vro_cpyfm(handle, 3, xy, &Schirm_mfdb, mp);
	graf_mouse(M_ON, 0);
}


void	Put(int x1, int y1, MFDB *mp, int Mode)
{
	int	xy[8];


	xy[0] = 0;
	xy[1] = 0;
	xy[2] = mp->fd_w;
	xy[3] = mp->fd_h;
	xy[4] = x1;
	xy[5] = y1;
	xy[6] = x1 + mp->fd_w;
	xy[7] = y1 + mp->fd_h;
	
	graf_mouse(M_OFF, 0);
	vro_cpyfm(handle, Mode, xy, mp, &Schirm_mfdb);
	graf_mouse(M_ON, 0);
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
	
	graf_mouse(M_OFF, 0);
	v_pline(handle, 5, xy);
	graf_mouse(M_ON, 0);
}


/*----------------------------------------------------------------*/
/*								GefÅlltes	Rechteck zeichnen											*/
/*----------------------------------------------------------------*/

void	Box_filled(int x1, int y1, int x2, int y2)
{
	int		xy[4];
	
	xy[0] = x1;
	xy[1] = y1;
	xy[2] = x2;
	xy[3] = y2;
	
	graf_mouse(M_OFF, 0);
	v_bar(handle, xy);
	graf_mouse(M_ON, 0);
}