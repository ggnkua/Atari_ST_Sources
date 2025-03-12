/******************************************************************/
/* Beispielprogramm zur Methode der Intervallhalbierung.          */
/* -------------------------------------------------------------- */
/* Entwickelt mit Turbo C.                             15.02.1989 */
/* (c) MAXON Computer GmbH                                        */
/******************************************************************/

/* --------- + ---------------- */
/* Listing 3 /  by D. Rabich    */
/* --------- + ---------------- */

/* Routinen importieren */
# include <stdio.h>
# include <math.h>

/* Grenze zur BerÅcksichtigung eventueller Ungenauigkeiten */
# define FLOATFEHLER 1.0E-6

/* Funktion f */
float f(float *x)

 {
  return((*x)*(*x)-2.0);
 }

/* Berechnet Nullstelle Funktion f */
float bisektion(float (*f)(), float x0, float x1)

 {
  float x,y,
        y0,y1;
  int   n;

  n=1;
  
  y0=(*f)(&x0);
  y1=(*f)(&x1);

  if (y0==0.0)
   return(x0);
   
  if (y1==0.0)
   return(x1);

  if(y0*y1>0.0)
   {
    printf("*** falsche Wahl der Startwerte ***");
    return(0.0);  
   }
    
  /* hîchstens 50 Iterationsschritte durchfÅhren */
  while ((n<50) && (fabs(x1-x0)>FLOATFEHLER))
   {
    x=(x0+x1)/2.0;
    y=(*f)(&x);
    if (y0*y<0.0)
     {
      x1=x;
     }
    else
     {
      x0=x;
     }
    n++;
   }

  printf("Benîtigte Schritte: %d\n",--n);

  if (fabs(x1-x0)>FLOATFEHLER)
   printf("*** Genauigkeit nicht erreicht ***");
   
  return(x);
 }

/* Hauptprogramm */
void main(void)

 {
  /* Ausgabe der Nullstelle */
  printf("f(%12.10g)=0\n",
          bisektion(f,1.4,1.5));

  /* Auf Taste warten... */
  getchar();
 }

