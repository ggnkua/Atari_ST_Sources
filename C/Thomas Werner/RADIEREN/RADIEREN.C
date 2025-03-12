/*----------------------------------------------------------------*/
/*			            	 		RADIER-Routine    					            */
/*			             		  								   					            */
/* Originalroutine in GFA-BASIC von Hans-H. Ackermann							*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <stdio.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>

MFDB	Schirm_mfdb;

extern	int	handle, work_out[];

void Radieren(void)
{
	void	*Puffer, *Radier, *Undo;
	MFDB	Puffer_mfdb, Radier_mfdb, Undo_mfdb;
	
	int		xx, yy, x, y, x1, y1, xd, yd, ux, uy;
	int		k, d, w_out[57], xy[4];
	
	
	void	Box(int x1, int y1, int x2, int y2);
	void	FillBox(int x1, int y1, int x2, int y2);
	void	Get(int x1, int y1, int x2, int y2, void *p, MFDB *mp);
	void	Put(int x1, int y1, MFDB *mp, int Mode);
	
	
	vq_extnd(handle,1, w_out);
	Schirm_mfdb.fd_addr = Physbase();
	Schirm_mfdb.fd_nplanes = w_out[4];
	Schirm_mfdb.fd_w = work_out[0];
	Schirm_mfdb.fd_h = work_out[1];
	Schirm_mfdb.fd_wdwidth = (work_out[0] + 1)/16;
	Schirm_mfdb.fd_stand = 0;
	
	xy[0] = 0;
	xy[1] = 0;
	xy[2] = work_out[0];
	xy[3] = work_out[1];
	vs_clip(handle,1,xy);
	
	while(graf_mkstate(&x1, &y1, &k, &d), k&1);
	
  graf_mouse(THIN_CROSS, 0);					/* Fadenkreuz */
  xx = 10;                            /* Linke-obere Ecke */
  yy = 10;                            /* der Radierbox und */
  vsin_mode(handle,1,2);							/* Default fÅr rechte- */
  x = 40;
  y = 40;
  vrq_locator(handle,x,y, &d, &d, &d);/* untere Ecke */
  vswr_mode(handle, 3);
  Box(xx,yy,x,y);                   	/* Radierbox zeigen */
  
	while(graf_mkstate(&ux, &uy, &k, &d), (ux == x1) && (uy == y1));
	
  Box(xx,yy,x,y);                   /* Radierbox zeigen */
  do					                        /* Rahmen-Schleife */
  {
    Box(xx,yy,x,y);                   /* Radierbox zeigen */
    								/* bis Maustaste losgelassen oder Maus bewegt */
	 	while(graf_mkstate(&x1, &y1, &k, &d),
    		  (!(k&1)) && (x1 == x) && (y1 == y));
    Box(xx,yy,x,y);                   /* Radierbox lîschen */
    x = x1;
    y = y1;
		
    if (x < xx)                       /* Keine "negativen" Werte */
    {
		  vsin_mode(handle,1,2);
		  vrq_locator(handle,xx,y, &d, &d, &d);
		  x = xx;
		}
    if (y < yy)
    {
		  vsin_mode(handle,1,2);
		  vrq_locator(handle,x,yy, &d, &d, &d);
		  y = yy;
		}
  } while (!(k&1));
  
	while(graf_mkstate(&x1, &y1, &k, &d),k&1);
   
  Puffer = Malloc((long)(x-xx+16) * (long)(y-yy) * (long)w_out[4]);
  if (Puffer == NULL)
  {
  	form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
		vs_clip(handle,0,xy);
	  vswr_mode(handle, 1);
  	return;
  }
  Radier = Malloc((long)(x-xx+16) * (long)(y-yy) * (long)w_out[4]);
  if (Radier == NULL)
  {
  	form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
  	Mfree(Puffer);
		vs_clip(handle,0,xy);
	  vswr_mode(handle, 1);
  	return;
  }
  Undo = Malloc((long)(work_out[0]+1) * (long)(work_out[1]+1) * (long)w_out[4]);
  if (Undo == NULL)
  {
  	form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
  	Mfree(Puffer);
  	Mfree(Radier);
		vs_clip(handle,0,xy);
	  vswr_mode(handle, 1);
  	return;
  }
  vswr_mode(handle, 1);
  Get(xx,yy,x,y,Puffer,&Puffer_mfdb);	/* Hintergrund retten */
  vsf_color(handle, 0);               /* und fÅr						*/
  FillBox(xx+1,yy+1,x-1,y-1);         /* Radierbox sÑubern	*/
  vsf_color(handle, 1);
  Box(xx,yy,x,y);
  Get(xx,yy,x,y,Radier,&Radier_mfdb); /* und puffern									*/
  Put(xx,yy,&Puffer_mfdb,3); 				   	/* Hintergrund restaurieren */
  vswr_mode(handle, 3);
  
  xd = x - xx;                        /* Boxmaûe fÅr 			*/
  yd = y - yy;                        /* Offset berechnen */
  
  graf_mouse(ARROW, 0);
  
	while(graf_mkstate(&x1, &y1, &k, &d), k&1);
  
	vsin_mode(handle,1,2);							/* Radierbox in Bildmitte */
	x = work_out[0]/2;
	y = work_out[1]/2;
	vrq_locator(handle,x,y, &d, &d, &d);
	
	ux = x;
	uy = y;
  Get(0,0,work_out[0],work_out[1],Undo,&Undo_mfdb); /* Bild fÅr UNDO puffern */
  
  Get(x,y,x+xd,y+yd,Puffer,&Puffer_mfdb);/* Hintergrund puffern */
  Put(x,y,&Radier_mfdb,3); 			         /* Radierbox zeigen    */
  
	while(graf_mkstate(&xx, &yy, &k, &d), (xx == x1) && (yy == y1));
  
  Put(x,y,&Puffer_mfdb,3); 							/* Hintergrund zeichnen */
  x = xx;
  y = yy;
  
  do						                      /* Radierschleife */
  {
  	while ((!(k&1)) && (!(k&2)))      /* Verschiebeschleife */
  	{
      Get(x,y,x+xd,y+yd,Puffer,&Puffer_mfdb);/* Hintergrund puffern */
      Put(x,y,&Radier_mfdb,3);    			     /* Radierbox zeigen    */
      
			while(graf_mkstate(&x1, &y1, &k, &d),
            (!(k&1)) && (!(k&2)) && (x1==x) & (y1 == y)); /* warten */
      
      Put(x,y,&Puffer_mfdb,3); 				/* Hintergrund zeichnen */
      x = x1;
      y = y1;
    }
    
 		while ((k&1) && (d&8))		/* linke MT und ALTERNATE (Undo-Fkt.) */
		{
      Put(0,0,&Undo_mfdb,3);         /* Bild restaurieren */
	    Get(x,y,x+xd,y+yd,Puffer,&Puffer_mfdb);/* Hintergrund puffern */
 	    Put(x,y,&Radier_mfdb,3);     /* Radierbox zeigen    */
			graf_mkstate(&x, &y, &k, &d);
  	}
    while (k&1)                   /* Wenn linke MT gedrÅckt */
  	{
		  vswr_mode(handle, 1);
		  vsf_color(handle, 0);
 	    FillBox(x,y,x+xd,y+yd);		          /* und lîschen */
		  vsf_color(handle, 1);
		  vswr_mode(handle, 3);
		  Box(x,y,x+xd,y+yd);
			while(graf_mkstate(&x1, &y1, &k, &d),
		  		  (!(k&2)) && (x1 == x) && (y1 == y));
		  Box(x,y,x+xd,y+yd);
		  x = x1;
		  y = y1;
    }
  } while (!(k&2));
  
	do	
		graf_mkstate(&x1, &y1, &k, &d);
  while ((k&1) || (k&2));
  
  vsf_color(handle, 1);
  vswr_mode(handle, 1);
 	Mfree(Puffer);
 	Mfree(Radier);
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
	
	graf_mouse(M_OFF,0);	
	v_pline(handle, 5, xy);
	graf_mouse(M_ON,0);	
}


/*----------------------------------------------------------------*/
/*								gefÅlltes Rechteck zeichnen											*/
/*----------------------------------------------------------------*/

void	FillBox(int x1, int y1, int x2, int y2)
{
	int		xy[4];
	
	xy[0] = x1;
	xy[1] = y1;
	xy[2] = x2;
	xy[3] = y2;
	
	graf_mouse(M_OFF,0);	
	v_bar(handle, xy);
	graf_mouse(M_ON,0);	
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
	
	graf_mouse(M_OFF,0);
	vro_cpyfm(handle, 3, xy, &Schirm_mfdb, mp);
	graf_mouse(M_ON,0);
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
	
	graf_mouse(M_OFF,0);
	vro_cpyfm(handle, Mode, xy, mp, &Schirm_mfdb);
	graf_mouse(M_ON,0);
}
