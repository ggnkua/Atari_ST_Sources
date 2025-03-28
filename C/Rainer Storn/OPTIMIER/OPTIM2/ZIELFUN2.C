         float zielf()
/*****************************************/
/*                                       */
/*        Sinusapproximation             */
/*        ------------------             */
/*                                       */
/* zielf() liefert den Zielfunktionswert */
/* y zurÅck, den es zu minimieren gilt.  */
/*                                       */
/* Benîtigte globale Variablen: pi,      */
/* zz[maxdim], dim.                      */
/*                                       */
/*****************************************/
{
  int   i, n;
  float a, alpha, diff, y;

  alpha = pi/100.0;
  y     = 0.0;
  
  for (i=0; i<50; i=i+1)
    {
      a    = (float)i*alpha;
      diff = 0.0;
      for (n=dim-1; n>0; n=n-1)
        {
          diff = (diff + zz[n])*a;
        }
      diff = diff + zz[0] - sin(a);
      y    = y + diff*diff;
    }
  return(y);
}/*---------Ende von zielf()----------------------------------*/

