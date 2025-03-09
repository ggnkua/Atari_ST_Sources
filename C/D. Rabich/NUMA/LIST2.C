/******************************************************************/
/* Beispielprogramm zur Sekantenmethode.                          */
/* -------------------------------------------------------------- */
/* Entwickelt mit Turbo C.                             15.02.1989 */
/* (c) MAXON Computer GmbH                                        */
/******************************************************************/

/* --------- + ---------------- */
/* Listing 2 /  by D. Rabich    */
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
float sekante(float (*f)(), float x0, float x1)

 {
  float x,
        y0,y1;
  int   n;

  n=1;
  
  if (fabs(x0-x1)<FLOATFEHLER)
   x1+=4.0*FLOATFEHLER;
  
  y0=(*f)(&x0);
  y1=(*f)(&x1);

  if (y0==0.0)
   return(x0);
   
  if (y1==0.0)
   return(x1);
   
  /* hîchstens 50 Iterationsschritte durchfÅhren */
  while ((n<50) && (fabs(x1-x0)>FLOATFEHLER))
   {
    x =x1-y1*(x1-x0)/(y1-y0);      
    x0=x1;
    x1=x;
    y0=y1;
    y1=(*f)(&x);
    n++;
   }

  printf("Benîtigte Schritte: %d\n",--n);

  if (fabs(x-x1)>FLOATFEHLER)
   printf("*** Genauigkeit nicht erreicht ***");
   
  return(x);
 }

/* Hauptprogramm */
void main(void)

 {
  /* Ausgabe der Nullstelle */
  printf("f(%12.10g)=0\n",
          sekante(f,2.0,3.0));

  /* Auf Taste warten... */
  getchar();
 }

