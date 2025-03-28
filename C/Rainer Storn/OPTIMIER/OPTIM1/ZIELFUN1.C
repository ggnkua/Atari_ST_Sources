         float zielf()
/*****************************************/
/*                                       */
/*   Schachteldimensionierungsproblem    */
/*   --------------------------------    */
/*                                       */
/* zielf() liefert den Zielfunktionswert */
/* y zurck, den es zu minimieren gilt.  */
/*                                       */
/* Ben”tigte globale Variablen:          */
/* zz[maxdim], dim.                      */
/*                                       */
/*****************************************/
{
  float area, v, a, b, c, x, y;

  area = 4.0; /*---Willkrliche Festlegung der Gesamtfl„che auf 4.0---*/
  a    = zz[0];
  x    = zz[1];
  b    = area/a;
  c    = 8.0;

  if ((a<0)||(x<0)||(x>b/2.0)||(x>a/2.0)) 
    {
      y = 1000.0;
    }
  else
    {
      v = x*(a-2.0*x)*(b-2.0*x);
      if (v < 0.0)
        {
          y = 1000.0;
        }
      else
        {
          y = c-v;
        }
    }
  return(y);
  
}/*---------Ende von zielf()----------------------------------*/

