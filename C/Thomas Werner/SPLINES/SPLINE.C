/*-------------------------------------------------------------------*/
/* Berechnung von Splines in der Ebene zur GlÑttung von PolygonzÅgen */
/* oder zur Verbindung einzelner Punkte                              */
/*																																	 */
/* Originalroutine in Modula 2: Dietmar Rabich, DÅlmen               */
/* C-Konvertierung: Thomas Werner																		 */
/* (c) 1992 MAXON Computer GmbH																			 */
/*-------------------------------------------------------------------*/

#include <stdlib.h>
#include <math.h>
#include <vdi.h>
#include "spline.h"

#define		Round(a)		ceil(a)



void MakeSplines(Points pts, unsigned int NoPts,
								 spline *splA, spline *splB,
								 unsigned int ysa, unsigned int ysb)
{	
	int		Param[MaxPoint];									/* Parameter      */
	int		ergA[MaxPoint], ergB[MaxPoint];		/* Ergebnis (y'') */
	TriGlSys		SystemA, SystemB;
	
	void MakeParameters (Points p, int *t, unsigned int No);
	void MakeSystem (TriGlSys *system1, TriGlSys *system2, Points p,
									 int t[], unsigned int No, unsigned int ysa, unsigned int ysb);
	void SolveSystem(TriGlSys *system, int *erg, unsigned int No);
	void SetSplines(spline *spl1, spline *spl2, 
									int erg1[], int erg2[], int par[],
									Points p, unsigned int No, unsigned int ysa, unsigned int ysb);

	MakeParameters(pts,Param,NoPts);
  MakeSystem(&SystemA,&SystemB,pts,Param,NoPts,ysa,ysb);
  SolveSystem(&SystemA,ergA,NoPts);
  SolveSystem(&SystemB,ergB,NoPts);
  SetSplines(splA,splB,ergA,ergB,Param,pts,NoPts,ysa,ysb);
}

/*-------------------------------------------------------------------------*/
/* Routine wertet Interpolationspolynom aus und stellt Kurve graphisch dar */
/*-------------------------------------------------------------------------*/

void DrawSplines (int dev, spline splX[], spline splY[], unsigned int No)
{
 	unsigned int 			i, x, Abst;
  long							X, Y;
  int								xy[4];
  point							PMem, P;
  boolean 					set;
	
	
	vswr_mode(dev, MD_REPLACE);
	vsl_type(dev, 1);
	vsl_color(dev, 1);
  set = FALSE;
  
  /* alle Polynome nacheinander */
  for (i=0; i <= No-2; i++)
  {
  	/* alle Werte von XStart bis XEnde */
   	Abst = (splX[i].XEnde-splX[i].XStart)/20; /* Feinheit der Unterteilung  */
   	/* je feiner die Unterteilung, desto genauer wird die Kurve dargestellt, */
   	/* aber auch desto langsamer wird die Darstellung                        */
   	x = splX[i].XStart;
    while (x<=splX[i].XEnde)
    {
			/* Interpolationspolynome */
    	X = splX[i].a * pow((x-splX[i].XStart),3)+
       		splX[i].b * pow((x-splX[i].XStart),2)+
       		splX[i].c * (x-splX[i].XStart)+
       		splX[i].d;
    	Y = splY[i].a * pow((x-splY[i].XStart),3)+
       		splY[i].b * pow((x-splY[i].XStart),2)+
       		splY[i].c * (x-splY[i].XStart)+
       		splY[i].d;

    	P.x = (int) X;
    	P.y = (int) Y;
    	
    	if (!set)
    	{
     		PMem = P;                  /* erster Punkt als Startpunkt */
     		set  = TRUE;
     	}
     	else
     	{
     		xy[0] = PMem.x;
     		xy[1] = PMem.y;
     		xy[2] = P.x;
     		xy[3] = P.y;
     		v_pline(dev,2,xy);         /* Linie zu P ziehen           */
  	  	PMem = P;
  	  }
    x += Abst;
		}
	}
}


/* berechnet Parameter, damit die Koordinaten als normale StÅtzwerte */
/* genutzt werden kînnen                                             */
void MakeParameters (Points p, int *t, unsigned int No)
{
  unsigned int	i;
	
  t[0] = 0;         		                        /* bei 0 geht's los */
  for (i = 1; i <= No-1; i++)
  	t[i] = t[i-1] +                         /* alter Wert +     */
           (int) (sqrt(pow((p[i].x-p[i-1].x),2)+     /* Abstand der      */
                  pow((p[i].y-p[i-1].y),2)));  /* Punkte           */
}


/* berechnet lineares Gleichungssystem mit tridiagonaler */
/* Koeefizientenmatrix                                   */
void MakeSystem (TriGlSys *system1, TriGlSys *system2, Points p,
								 int t[], unsigned int No, unsigned int ysa, unsigned int ysb)
{
  int			 			h[MaxPoint];
  unsigned int	i;
	
  for (i = 0; i <= No-2; i++)					/* Schrittweiten */
    h[i] = t[i+1]-t[i];
  for (i = 0; i <= No-4; i++)         /* Haupt- und Nebendiagonale */
  {
    system1->m[i] = 2 * (h[i]+h[i+1]);
    system2->m[i] = 2 * (h[i]+h[i+1]);
    system1->o[i] = h[i+1];
    system2->o[i] = h[i+1];
    system1->u[i] = system1->o[i];
    system2->u[i] = system1->o[i];
   }
  system1->m[No-3] = 2 * (h[No-3]+h[No-2]);
  system2->m[No-3] = 2 * (h[No-3]+h[No-2]);
  
  for (i = 0; i <= No-3; i++)          /* InhomogenitÑt */
  {
    system1->l[i] = 6 * ((p[i+1].x-p[i].x) / h[i]
                         -(p[i+2].x-p[i+1].x) / h[i+1]);
    system2->l[i] = 6 * ((p[i+1].y-p[i].y) / h[i]
                         -(p[i+2].y-p[i+1].y) / h[i+1]);
  }
  system1->l[0] 	 += h[0]    * ysa; /* Randwerte dazu */
  system1->l[No-3] += h[No-2] * ysb;
  system2->l[0]    += h[0]    * ysa;
  system2->l[No-3] += h[No-2] * ysb;
}


/* berechnet Lîsung des Gleichungssystems         */
/* stark vereinfacht, da Matrix Tridiagonalmatrix */

void SolveSystem(TriGlSys *system, int *erg, unsigned int No)
{

  unsigned int	i, Back;
  int			 			m[MaxPoint], l[MaxPoint], x[MaxPoint];
	
  m[0] = system->m[0];                     /* LR - Zerlegung             */
  for (i = 0; i<= No-4; i++)
  {
  	l[i]   = system->u[i] / m[i];               /* L - Matrix, Nebendiagonale */
  	m[i+1] = system->m[i+1]-l[i] / system->o[i];/* R - Matrix, Hauptdiagonale */
  }
  x[0] = system->l[0];                     /* einsetzen                  */
  for (i = 1; i<= No-3; i++)               /* berechnet x aus            */
    x[i] = system->l[i]-l[i-1] * x[i-1];     /* L x - system.l = 0         */
  erg[No-3] = -x[No-3] / m[No-3];           /* Lîsung                     */
  for (i = 0; i<= No-4; i++)               /* berechnet erg aus          */
  {
    Back = No-4-i;                         /* R erg + x = 0              */
    erg[Back] = -(x[Back] + system->o[Back] * (erg[Back+1])) / m[Back];
  }
}


/* berechnet die Koeffizienten des Interpolationspolynoms */
void SetSplines(spline *spl1, spline *spl2, 
								int erg1[], int erg2[], int par[],
								Points p, unsigned int No,
								unsigned int ysa, unsigned int ysb)
{
  unsigned int	i;
  int						y[MaxPoint];
	
																		  /* 1. fÅr x-Werte */
  for(i = 0; i<= No-3; i++)                      /* 2. Ableitung  */ 
    y[i+1] = erg1[i];
  y[0]    = ysa;
  y[No-1] = ysb;
  for (i = 0; i <= No-2; i++)
  {
    spl1->a      = (y[i+1]-y[i]) / (6 * (par[i+1]-par[i]));   /* Koeffizienten */
    spl1->b      = y[i] / 2;
    spl1->c      = abs(p[i+1].x-p[i].x) / (par[i+1]-par[i])
                       -(par[i+1]-par[i]) * (y[i+1]+2 * y[i]) / 6;
    spl1->d      = (p[i].x);
    spl1->XStart = par[i];                                  /* Anfang        */
    spl1->XEnde  = par[i+1];                                /* Ende          */
    spl1++;
	}
  /* 2. fÅr y-Werte */
  for (i = 0; i<= No-3; i++)                      /* 2. Ableitung  */
    y[i+1] = erg2[i];
  for (i = 0; i<= No-2; i++)
  {
    spl2->a      = (y[i+1]-y[i]) / (6 * (par[i+1]-par[i]));   /* Koeffizienten */
    spl2->b      = y[i] / 2;
    spl2->c      = abs(p[i+1].y-p[i].y) / (par[i+1]-par[i])
             					-(par[i+1]-par[i]) * (y[i+1]+2.0*y[i]) / 6;
    spl2->d      = p[i].y;
    spl2->XStart = par[i];                                  /* Anfang        */
    spl2->XEnde  = par[i+1];                                 /* Ende          */
    spl2++;
  }
}
