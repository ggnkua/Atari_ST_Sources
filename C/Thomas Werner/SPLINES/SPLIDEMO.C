/*-------------------------------------------------------------------*/
/* Berechnung von Splines in der Ebene zur GlÑttung von PolygonzÅgen */
/* oder zur Verbindung einzelner Punkte                              */
/*																																	 */
/* Demoprogramm zu den Splines-Routinen                              */
/* Originalroutine in Modula 2: Dietmar Rabich, DÅlmen               */
/* C-Konvertierung: Thomas Werner																		 */
/* (c) 1992 MAXON Computer GmbH																			 */
/*-------------------------------------------------------------------*/

#include <tos.h>
#include <vdi.h>
#include "spline.h"


extern	int	handle;


void gem_prg(void)
{
	int			n;
	int			yA, yB;
	Points	p;
	spline	splX[MaxPoint], splY[MaxPoint];
	
	
	yA = 0;      		                   /* 2. Ableitung = 0                      */
  yB = 0;         	                 /*  <=> keine KrÅmmung an den Enden      */
  n  = 12;                           /* 12 Punkte                             */
  p[0].x = 200;                      /* Koordinaten                           */
  p[0].y = 100;                      /*     .                                 */
  p[1].x = 100;                      /*     .                                 */
  p[1].y = 100;                      /*     .                                 */
  p[2].x = 100;
  p[2].y = 200;
  p[3].x = 200;
  p[3].y = 200;
  p[4].x = 200;
  p[4].y = 300;
  p[5].x = 100;
  p[5].y = 300;
  p[6].x = 300;
  p[6].y = 100;
  p[7].x = 400;
  p[7].y = 100;
  p[8].x = 350;
  p[8].y = 100;
  p[9].x = 350;
  p[9].y = 200;
  p[10].x = 350;
  p[10].y = 250;
  p[11].x = 350;
  p[11].y = 300;
  v_clrwk(handle);									    /* Bildschirm lîschen */
  vsm_type(handle,5);	  							  /* Kreuz als Marker   */
  v_pmarker(handle,n,p);     			      /* Marker setzen (nicht unbedingt nîtig) */
  MakeSplines(p,n,splX,splY,yA,yB); 	  /* Splines berechnen */
  DrawSplines(handle,splX,splY,n);      /* Splines ausgeben */
  Crawcin();							              /* auf Taste warten */
}
