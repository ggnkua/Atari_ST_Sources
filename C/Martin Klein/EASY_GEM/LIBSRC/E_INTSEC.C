#include <aes.h>

int min( int a, int b)
{
   if( a > b )
      return( b );
   else
      return( a );
}

int max( int a, int b)
{
   if( a < b )
      return( b );
   else
      return( a );
}

/* ----------------------------------------------------------------- */
/* rc_intersect()                                                    */
/*                                                                   */
/* Schnittfl„che zweier Rechtecke berechnen.                         */
/* Ergebnisrechteck in r2                                                                  */
/* ----------------------------------------------------------------- */

int rc_intersect(GRECT *r1, GRECT *r2)
{
	int xl, yu, xr, yd;     /* left, upper, right, down */
	
	xl = max(r1->g_x, r2->g_x);
	yu = max(r1->g_y, r2->g_y);
	xr = min(r1->g_x + r1->g_w, r2->g_x + r2->g_w);
	yd = min(r1->g_y + r1->g_h, r2->g_y + r2->g_h);
	
	r2->g_x = xl;
	r2->g_y = yu;
	r2->g_w = xr - xl;
	r2->g_h = yd - yu;
	
	return(r2->g_w > 0 && r2->g_h > 0);
}
