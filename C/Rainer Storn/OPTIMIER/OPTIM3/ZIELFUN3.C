         float zielf()
/*****************************************/
/*                                       */
/*       Toleranzschemaeinpassung        */
/*       ------------------------        */
/*                                       */
/* zielf() liefert den Zielfunktionswert */
/* y zurÅck, den es zu minimieren gilt.  */
/*                                       */
/* Benîtigte globale Variablen:          */
/* zz[maxdim], dim.                      */
/*                                       */
/*****************************************/
{
  int   i, n;
  float delta1, delta2, delta3, x, y, maxdev;

/*----Untersuche Bereich fÅr Argument zwischen -1 und 1------*/

  delta1 = 0.0;
  maxdev = 0.0;
  for (i=0; i<=100; i=i+1)
    {
      y = 0.0;
      x = -1.0 + (float)i/50;
      for (n=dim-1; n>0; n=n-1)
        {
          y = (y + zz[n])*x;
        }
      y = y + zz[0];
      if (fabs(y) > 1.0) maxdev = (1-fabs(y))*(1-fabs(y));
      if (maxdev > delta1) delta1 = maxdev; 
    }
    
/*-----Untersuche Argumentenwert +1.2-------------------------*/

  delta2 = 0.0;
  x      = 1.2;
  y      = 0.0;
  for (n=dim-1; n>0; n=n-1)
    {
      y = (y + zz[n])*x;
    }
  y = y + zz[0];
  if (y < 5.9) delta2 = (y-5.9)*(y-5.9);
  
/*-----Untersuche Argumentenwert -1.2-------------------------*/

  delta3 = 0.0;
  x      = -1.2;
  y      = 0.0;
  for (n=dim-1; n>0; n=n-1)
    {
      y = (y + zz[n])*x;
    }
  y = y + zz[0];
  if (y < 5.9) delta3 = (y-5.9)*(y-5.9);
  
  return(sqrt(delta1+delta2+delta3));
  
}/*---------Ende von zielf()----------------------------------*/

