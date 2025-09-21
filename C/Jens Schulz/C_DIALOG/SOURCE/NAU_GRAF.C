#include <stdio.h>
#include <vdi.h>
#include <tos.h>  
#include <aes.h> 
#include <string.h>   
#include <stdlib.h>  

#include "nau_rsc.h" 
#include "n_global.h" 
#include "nau_graf.inc"    
 
/************ Globale Variablen. **********************************/

static long restore_buff[39000L];  /* Puffer fÅr Dialogboxen     */
                                   /* VGA = benîtigt 154 KB      */
/*********************** Funktionen ***********************************/
/**********************************************************************/
/*                                                                    */
/*   Aufgabe : Initialisiert die Grafikparameter je nach Auflîsung.   */
/*                                                                    */
/*--------------------------------------------------------------------*/
/*                                                                    */
/*   Eingabeparameter : keine                                         */
/*                                                                    */
/*   Ausgabeparameter : Die globalen Grafikparameter.                 */
/*                                                                    */
/*                                                                    */
/**********************************************************************/
int graf_init(void)
{
  int status={0};

  switch(video_mode())
  {
    case 1  : sc = MK_SCREEN; break; /* monochrom Kleinbildschirm */
    case 2  : sc = MG_SCREEN; break; /* monochrom Groûbildschirm  */
    case 3  : sc = CK_SCREEN; break; /* 16-Farben ST-Low          */
    case 4  : sc = CG_SCREEN; break; /* 16-Farben VGA             */
    default : status = 2;            /* Falsche-Auflîsung         */
  }

  return (status);
}


void recht_eck(int xanf, int yanf, int breite, int hoehe, int rahmen)
{
  int xend,yend;

  vswr_mode(handle,1);           /* Replace         */  
  vsf_interior(handle,0);        /* innen leer      */
  vsf_perimeter(handle,rahmen);  /* Box mit Rahmen  */

  xend = xanf + breite;
  yend = yanf + hoehe;
  fill_square(xanf,yanf,xend,yend);
}  


/*====================================================================*/
/*  Hier folgen einige Grafik-Grundroutinen :                         */
/*====================================================================*/

/**********************************************************************/
/*                                                                    */
/*   Aufgabe : Zeichnet ein Rechteck mit Fillaerea. Die FlÑchen-      */
/*             attribute mÅssen schon vorher gesetzt sein.            */
/*                                                                    */
/*--------------------------------------------------------------------*/
/*                                                                    */
/*   Eingabeparameter : Koordinaten der Eckpunkte                     */
/*                                                                    */
/*   Ausgabeparameter : keine                                         */
/*                                                                    */
/**********************************************************************/
void fill_square(int x1, int y1, int x2, int y2)
{
   int pxyarray[10];

   pxyarray[0] = x1;   	   pxyarray[1] = y1;
   pxyarray[2] = x2;       pxyarray[3] = y1;
   pxyarray[4] = x2;       pxyarray[5] = y2;
   pxyarray[6] = x1;       pxyarray[7] = y2;
   pxyarray[8] = x1;       pxyarray[9] = y1;

   v_fillarea(handle,5,pxyarray); /* Breich zeichnen */
}

/**********************************************************************/
/*                                                                    */
/*   Aufgabe : Bestimmt den Video-Mode (1-4)                          */
/*                                                                    */
/*--------------------------------------------------------------------*/
/*                                                                    */
/*   Eingabeparameter : keine                                         */
/*                                                                    */
/*   Ausgabeparameter : Video-Mode.                                   */
/*                                                                    */
/**********************************************************************/
int video_mode(void)
{
    int testplanes; 
    int test_out[58];

    /* Es gibt vier Auflîsungen :
            1 : monochrom gering (640 * 400)
            2 : monochrom gross  (1280 * 960)
            3 : farbig gering    (320 * 200 ; 16 Farben)
            4 : VGA Farbe        (640 * 480 ; 16 Farben)  
           -1 : unbekannte Auflîsung                        */
  int mode;

  mode = -1;  

  vq_extnd(handle,1,test_out);    /* Bitplanes holen */
  testplanes = test_out[4];

  if(work_out[0] >= 639 && work_out[0] < 1279 &&    /*ST-High,Overscan */ 
    work_out[1] >= 399 && testplanes == 1)
    mode = 1;
    
  if(work_out[0] >= 1279 && work_out[1] >= 959 && testplanes == 1)  /* Groûbildschirm */
    mode = 2;

  if(work_out[0] == 319 && work_out[1] == 199 && testplanes == 4)   /* ST-LOW */
    mode = 3;
    
  if(work_out[0] >= 639 && work_out[1] >= 479 && testplanes == 4)   /* VGA, Super-VGA */
    mode = 4;    
  return mode;    
}

/**********************************************************************/
/*                                                                    */
/*   Aufgabe : Zeichnet eine FlÑche wie Hintergrund gemustert.        */
/*                                                                    */
/*--------------------------------------------------------------------*/
/*                                                                    */
/*   Eingabeparameter : Koordinaten der beiden Eckpunkte.             */
/*                                                                    */
/*   Ausgabeparameter : keine                                         */
/*                                                                    */
/**********************************************************************/
void hintergrund(int xanf, int yanf, int xend, int yend)
{
  vswr_mode(handle,1);           /* Replace */  

  if ((sc.V_MODE == 1) || (sc.V_MODE == 2))        /* Monochrom */
  {
    vsf_interior(handle,2);	/* Muster            */
    vsf_style(handle,3);       /* und zwar Muster 3 */
    vsf_perimeter(handle,0);   /* ohne Rahmen       */
  }
  else                                             /* Farbe */
  {
    vsf_interior(handle,1);	/* voll              */
    vsf_perimeter(handle,0);   /* ohne Rahmen       */
    vsf_color(handle,3);       /* Farbe dunkelblau  */
  }

  xanf--; xend++; yanf--; yend++;
  fill_square(xanf,yanf,xend,yend);
}


/* Rechteckausschnitt sichern in Zwischenpuffer */
void save_rechteck(int x_pos, int y_pos, int breite, int hoehe)
{

  MFDB quell,ziel;
  int pxyarray[8];

  quell.fd_addr =  0;	  		/* Bildschirmparameter */

  ziel.fd_addr  = restore_buff;  	/* Adresse Quellbereich */
  ziel.fd_w     = sc.X_PIXEL;    	/* Breite in Punkten */
  ziel.fd_h     = sc.Y_PIXEL; 	    /* Hoehe in Punkten  */
  	                                /* Breite in Words */
  ziel.fd_wdwidth = sc.X_PIXEL/16;	     
  ziel.fd_stand = 0;			    /* Geraeteabhaengiges Format */
  ziel.fd_nplanes = sc.PLANES;		/* Bitplanes */


  pxyarray[0] = x_pos; 	                /* X1 Quell-Raster */
  pxyarray[1] = y_pos;                  /* Y1 Quell-Raster */
  pxyarray[2] = x_pos+breite;           /* Breite Quelle   */
  pxyarray[3] = y_pos+hoehe;            /* Hoehe Quelle    */
  pxyarray[4] = 0;                      /* X1 Ziel         */
  pxyarray[5] = 0;
  pxyarray[6] = breite;
  pxyarray[7] = hoehe;

  vro_cpyfm(handle,3,pxyarray,&quell,&ziel);
}

/* Gesichertes Rechteck zurÅck in Bildspeicher */
void restore_rechteck(int x_pos, int y_pos, int breite, int hoehe)
{

  MFDB quell,ziel;
  int pxyarray[8];

  quell.fd_addr = restore_buff;	    /* Adresse Quellbereich */
  quell.fd_w    = sc.X_PIXEL;    	/* Breite in Punkten    */
  quell.fd_h    = sc.Y_PIXEL; 	    /* Hoehe in Punkten     */
  quell.fd_wdwidth = sc.X_PIXEL / 16;	
  quell.fd_stand = 0;			    /* Geraeteabhaengiges Format */
  quell.fd_nplanes = sc.PLANES;		/* Bitplanes */

  ziel.fd_addr =  0;	  	   	    /* Bildschirmparameter */

  pxyarray[0] = 0;                     
  pxyarray[1] = 0;
  pxyarray[2] = breite;
  pxyarray[3] = hoehe;
  pxyarray[4] = x_pos; 	                
  pxyarray[5] = y_pos;                  
  pxyarray[6] = x_pos+breite;           
  pxyarray[7] = y_pos+hoehe;            

  vro_cpyfm(handle,3,pxyarray,&quell,&ziel);
}

