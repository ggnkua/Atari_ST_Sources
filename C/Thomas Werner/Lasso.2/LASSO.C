/*----------------------------------------------------------------*/
/*			             		  LASSO-FUNKTION    					            */
/*			             		  								   					            */
/* Originalroutine in OMIKRON.BASIC: L. Canisius									*/
/* C-Konvertierung: Thomas Werner																	*/
/* (c) 1992 Maxon Computer GmbH																		*/
/*----------------------------------------------------------------*/

#include <stdio.h>
#include <tos.h>
#include <aes.h>
#include <vdi.h>


#define MAX(a, b)					((a>b) ? a : b)
#define MIN(a, b)					((a>b) ? b : a)


extern	int handle, work_out[];



/*----------------------------------------------------------------*/
/*			             		  LASSO-FUNKTION    					            */
/*			             		  								   					            */
/*		Aufruf: Lasso(Undo, Modus, handle)             							*/
/* 				Undo:   1, wenn Bild gerettet werden soll      					*/
/*				Modus:  VerknÅpfungsart des Ausschnitts (0-15)					*/
/*				handle: Grafik-Handle																		*/
/*----------------------------------------------------------------*/
 
void	Lasso(int Undo, int Modus)
{
	void					*Puffer, *Undo_Puffer, *Schirm;
	int						Xstart, Ystart, Xmax, Ymax, Xmin, Ymin, XMAX, YMAX;
	int						X, X1, X2, Y, Y1, Y2, Breite, Hoehe;
	int						pstatus, dummy, w_out[57], xy[10];
	unsigned int	Bildx, Bildy;
	long	Bildg;
	MFDB	Schirm_mfdb, Puffer_mfdb, Undo_mfdb;

	
	void	Draw(int x1, int y1, int x2, int y2);
	void	Box(int x1, int y1, int x2, int y2);


	
	vsl_type(handle, 1);				/* durchgehende Linien */
	vsl_width(handle, 1);
	vsl_ends(handle, 0, 0);
	vsl_color(handle, 1);
	vsf_interior(handle, 1);		/* schwarze FÅllung */
	
	Schirm = Physbase();
  Bildx = work_out[0];
  Bildy = work_out[1];
	vq_extnd(handle,1, w_out);
	Bildg = ((Bildx+1)/8) * (Bildy+1) * w_out[4];
	Schirm_mfdb.fd_addr = Schirm;
	Schirm_mfdb.fd_nplanes = w_out[4];
	Schirm_mfdb.fd_w = Bildx;
	Schirm_mfdb.fd_h = Bildy;
	Schirm_mfdb.fd_wdwidth = (Bildx+1)/16;
	Schirm_mfdb.fd_stand = 0;
  	
	/* Arbeitspuffer in Bildschirmgîûe */
	
	Puffer = Malloc(Bildg);
  if (Puffer == NULL)
  {
  	form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
	  vswr_mode(handle, 1);
  	return;
  }
	Puffer_mfdb.fd_addr = Puffer;
	Puffer_mfdb.fd_nplanes = Schirm_mfdb.fd_nplanes;
	Puffer_mfdb.fd_w = Bildx;
	Puffer_mfdb.fd_h = Bildy;
	Puffer_mfdb.fd_wdwidth = (Bildx+1)/16;
	Puffer_mfdb.fd_stand = 0;
	
	graf_mouse(M_OFF,0);
	Setscreen(Puffer, Schirm, -1);
	v_clrwk(handle);
	Setscreen(Schirm, Schirm, -1);
	graf_mouse(M_ON,0);


  /* Anfangswerte des Begrenzungsrechtecks (Bildschirmauflîsung) */
  
  Xmax = 0;
  Ymax = 0;
  Xmin = Bildx;
  Ymin = Bildy;
  
  XMAX = Bildx-2;
  YMAX = Bildy-2;
  
  /* Original retten, wenn gewÅnscht */
  
  if (Undo==1)
  {
		xy[0] = 0;
		xy[1] = 0;
		xy[2] = Bildx;
		xy[3] = Bildy;
		xy[4] = 0;
		xy[5] = 0;
		xy[6] = Bildx;
		xy[7] = Bildy;

		Undo_Puffer = Malloc(Bildg);
	  if (Undo_Puffer == NULL)
  	{
  		form_alert(1,"[3][ Nicht genÅgend Speicher frei! ][ Abbruch ]");
	  	Mfree(Puffer);
		  vswr_mode(handle, 1);
  		return;
	  }
		Undo_mfdb.fd_addr = Undo_Puffer;
		Undo_mfdb.fd_nplanes = Schirm_mfdb.fd_nplanes;
		Undo_mfdb.fd_w = Bildx;
		Undo_mfdb.fd_h = Bildy;
		Undo_mfdb.fd_wdwidth = (Bildx+1)/16;
		Undo_mfdb.fd_stand = 0;
		
		graf_mouse(M_OFF, 0);
		vro_cpyfm(handle, 3, xy, &Schirm_mfdb, &Undo_mfdb);
		graf_mouse(M_ON, 0);
  }
  
	/* auf Mausklick warten und Anfangskoordinaten ermitteln */

 	while(graf_mkstate(&Xstart, &Ystart, &pstatus, &dummy),!(pstatus & 1));
	
  X1 = Xstart;
  X2 = X1;
  Y1 = Ystart;
  Y2 = Y1;
	/* Ausschnitt mit der Maus wÑhlen */
  do
  {
  	while(graf_mkstate(&X1, &Y1, &pstatus, &dummy),
		      (pstatus & 1) && (X1 == X2) && (Y1 == Y2));
		
    /* Lasso nicht an den Rand lassen */
    
    X1 = MIN(X1,XMAX);
    X1 = MAX(X1,2);
    Y1 = MIN(Y1,YMAX);
    Y1 = MAX(Y1,2);
    
    /* Ermittlung des Begrenzungsrechtecks */
    
    Xmax = MAX(X1 ,Xmax);
    Xmin = MIN(X1 ,Xmin);
    Ymax = MAX(Y1 ,Ymax);
    Ymin = MIN(Y1 ,Ymin);
		
    /* Zeichnen des Lassos: */
    
    /* 1) versteckt */
		graf_mouse(M_OFF,0);		
		Setscreen(Puffer, Schirm, -1);
		vswr_mode(handle, 1);
    Draw(X2, Y2, X1, Y1);
		Setscreen(Schirm, Schirm, -1);
		graf_mouse(M_ON,0);		
		
    /* 2) sichtbar */
    
    vswr_mode(handle, 3);
    Draw(X2, Y2, X2, Y2);
    Draw(X2, Y2, X1, Y1);
    
    X2 = X1;
    Y2 = Y1;
 	}	while((pstatus & 1));
	
  /* Umrandung schliessen */
  
  
  Draw(X2, Y2, X2, Y2);
  Draw(Xstart, Ystart, Xstart, Ystart);
  Draw(X2, Y2, Xstart, Ystart);
  
  /* Ab jetzt alles im Puffer ausfÅhren */

	graf_mouse(M_OFF,0);
	  
	Setscreen(Puffer, Schirm, -1);
	vswr_mode(handle, 1);
  Draw(X2, Y2, Xstart, Ystart);
  
  /* Maske durch FÅllen des Begrenzungsrechtecks erstellen */
  
  Breite = Xmax-Xmin;
  Hoehe = Ymax-Ymin;
  Box(Xmin-2,Ymin-2,Breite+6,Hoehe+6);
  v_contourfill(handle, Xmin-1, Ymin-1, 1);
  
  /* Maske mit Bild NOT AND-VerknÅpfen */
  
	xy[0] = 0;
	xy[1] = 0;
	xy[2] = Bildx;
	xy[3] = Bildy;
	xy[4] = 0;
	xy[5] = 0;
	xy[6] = Bildx;
	xy[7] = Bildy;
	
	vro_cpyfm(handle, 2, xy, &Schirm_mfdb, &Puffer_mfdb);
    
  /* Ab jetzt wieder alles auf sichtbarem Bildschirm ausfÅhren *
  
	Setscreen(Schirm, Schirm, -1);
	
  /* Bild restaurieren */
  
  if (Undo==1)
  {
		xy[0] = 0;
		xy[1] = 0;
		xy[2] = Bildx;
		xy[3] = Bildy;
		xy[4] = 0;
		xy[5] = 0;
		xy[6] = Bildx;
		xy[7] = Bildy;
		vro_cpyfm(handle, 3, xy, &Undo_mfdb, &Schirm_mfdb);
  }
  
  /* Weiterverarbeitung: Verschieben des Ausschnitts */
  
  xy[0] = 0;
  xy[1] = 0;
  xy[2] = Bildx;
  xy[3] = Bildy;
  vs_clip(handle, 1, xy);
  
	graf_mkstate(&X, &Y, &pstatus, &dummy);
	
	xy[0] = Xmin;
	xy[1] = Ymin;
	xy[2] = Xmin + Breite;
	xy[3] = Ymin + Hoehe;
	xy[4] = X;
	xy[5] = Y;
	xy[6] = X + Breite;
	xy[7] = Y + Hoehe;
	
	vro_cpyfm(handle, 6, xy, &Puffer_mfdb, &Schirm_mfdb);
	
	graf_mouse(M_ON, 0);
  
  do
  {
  	while(graf_mkstate(&X1, &Y1, &pstatus, &dummy),
		      (!(pstatus&1)) && (!(pstatus&2)) && (X == X1) && (Y == Y1));
		
		xy[0] = Xmin;
		xy[1] = Ymin;
		xy[2] = Xmin + Breite;
		xy[3] = Ymin + Hoehe;
		xy[4] = X;
		xy[5] = Y;
		xy[6] = X + Breite;
		xy[7] = Y + Hoehe;
		graf_mouse(M_OFF, 0);
		vro_cpyfm(handle, 6, xy, &Puffer_mfdb, &Schirm_mfdb);
		
		X = X1;
		Y = Y1;
		
		xy[0] = Xmin;
		xy[1] = Ymin;
		xy[2] = Xmin + Breite;
		xy[3] = Ymin + Hoehe;
		xy[4] = X;
		xy[5] = Y;
		xy[6] = X + Breite;
		xy[7] = Y + Hoehe;
		vro_cpyfm(handle, 6, xy, &Puffer_mfdb, &Schirm_mfdb);
		graf_mouse(M_ON, 0);
	}	while((!(pstatus&1)) && (!(pstatus&2)));
	
	graf_mouse(M_OFF, 0);

	xy[0] = Xmin;
	xy[1] = Ymin;
	xy[2] = Xmin + Breite;
	xy[3] = Ymin + Hoehe;
	xy[4] = X;
	xy[5] = Y;
	xy[6] = X + Breite;
	xy[7] = Y + Hoehe;
  if (pstatus&2)			    /* Ausschnitt gemÑû Modus einkopieren */
		vro_cpyfm(handle, Modus, xy, &Puffer_mfdb, &Schirm_mfdb);
	else
		vro_cpyfm(handle, 6, xy, &Puffer_mfdb, &Schirm_mfdb);

	graf_mouse(M_ON, 0);
  xy[0] = 0;
  xy[1] = 0;
  xy[2] = Bildx;
  xy[3] = Bildy;
  vs_clip(handle, 0, xy);
   
  /* Speicher freigeben */
   
  Mfree(Puffer);
  if (Undo==1)
		Mfree(Undo_Puffer);
		
	Setscreen(Schirm, Schirm, -1);
	vswr_mode(handle, 1);
	vst_color(handle, 1);
}


/*----------------------------------------------------------------*/
/*												Linie zeichnen													*/
/*----------------------------------------------------------------*/

void	Draw(int x1, int y1, int x2, int y2)
{
	int		xy[4];
	
	xy[0] = x1;
	xy[1] = y1;
	xy[2] = x2;
	xy[3] = y2;
	
	graf_mouse(M_OFF, 0);
	v_pline(handle, 2, xy);
	graf_mouse(M_ON, 0);
}

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
