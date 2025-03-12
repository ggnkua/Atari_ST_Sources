/******************************************************************/
/* Beispielprogramm zum Verfahren von Newton.                     */
/* -------------------------------------------------------------- */
/* Entwickelt mit Turbo C.                             15.02.1989 */
/* (c) MAXON Computer GmbH                                        */     
/******************************************************************/

/* --------- + ---------------- */
/* Listing 1 /  by D. Rabich    */
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

/* Ableitung der Funktion f */
float fs(float *x)

 {
  return(2.0*(*x));
 }

/* Berechnet Nullstelle Funktion f */
float newton(float (*f)(), float (*fs)(), float xs)

 {
  float x,
        def;
  int   n;

  n=1;
  
  /* Annahme, daû Genauigkeit nicht ereicht wurde */
  def=2.0*FLOATFEHLER;

  /* hîchstens 50 Iterationsschritte durchfÅhren */
  while ((n<50) && (fabs(def)>FLOATFEHLER))
   {
    x=xs-(*f)(&xs)/(*fs)(&xs);
    def=x-xs;
    xs=x;
    n++;
   }

  printf("Benîtigte Schritte: %d\n",--n);

  if (fabs(x-xs)>FLOATFEHLER)
   printf("*** Genauigkeit nicht erreicht ***");
   
  return(x);
 }

/* Hauptprogramm */
void main(void)

 {
  /* Ausgabe der Nullstelle */
  printf("f(%12.10g)=0\n",
          newton(f,fs,3.0));

  /* Auf Taste warten... */
  getchar();
 }

