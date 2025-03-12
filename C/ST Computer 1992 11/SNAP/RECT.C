/* RECT.C
   (c) 1992 MAXON Computer
*/

#include <aes.h>
#include "rect.h"



void RectToElement( GRECT *rect,
                    int   welm,
                    int   helm,
                    int   flag )
{
   int  x, y,
        vx, vy,
        sw, sh,
        dx, dy, dw, dh;


   /* Breite und Hîhe ermitteln */
   wind_get( 0, WF_WORKXYWH,
             &dx, &dy, &dw, &dh );
   sw = dx + dw;
   sh = dy + dh;


   /* Wenn die X-Koordinate gesetzt
      werden soll... */
   if( flag & DOSETX )
   {
      /* relativ zur rechten unteren
         Bilschirmecke */
      x = sw - rect->g_x;

      /* Muû Åberhaupt was geÑndert werden? */
      if( x % welm )
      {
         /* In die beiden verschiedenen
            Richtungen snappen */
         if( (flag & TOSMALLER) ||
             (x % welm < welm/2) )
            x  -= x % welm;
         if( (flag & TOBIGGER) ||
             (x % welm >= welm/2) )
            x  += welm - (x % welm);

         /* Verschub ermitteln */
         vx  = rect->g_x;
         rect->g_x  = sw - x;
         vx  = -(vx - rect->g_x);

         /* Verschub evtl. von der
            Breite abziehen */
         if( flag & DOSETW )
            rect->g_w -= vx;
      }
   }


   /* Wenn die Y-Koordinate gesetzt
      werden soll... */
   if( flag & DOSETY )
   {
      /* relativ zur rechten unteren
         Bilschirmecke */
      y = sh - rect->g_y;

      /* Muû Åberhaupt was geÑndert werden? */
      if( y % helm )
      {
         /* In die beiden verschiedenen
            Richtungen snappen */
         if( (flag & TOSMALLER) ||
             (y % helm < helm/2) )
            y  -= y % helm;
         if( (flag & TOBIGGER) ||
             (y % helm >= helm/2) )
            y  += helm - (y % helm);

         /* Verschub ermitteln */
         vy  = rect->g_y;
         rect->g_y  = sh - y;
         vy  = -(vy - rect->g_y);

         /* Verschub evtl. von der
            Hîhe abziehen */
         if( flag & DOSETH )
            rect->g_h -= vy;
      }
   }


   /* Wenn die Breite gesetzt werden soll... */
   if( flag & DOSETW )
      /* Muû Åberhaupt was geÑndert werden? */
      if( rect->g_w % welm )
      {
         /* In die beiden verschiedenen
            Richtungen snappen */
         if( (flag & TOSMALLER) ||
             (rect->g_w % welm < welm/2) )
            rect->g_w -= rect->g_w % welm;
         if( (flag & TOBIGGER) ||
             (rect->g_w % welm >= welm/2) )
            rect->g_w += welm - (rect->g_w % welm);
      }


   /* Wenn die Hîhe gesetzt werden soll... */
   if( flag & DOSETH )
      /* Muû Åberhaupt was geÑndert werden? */
      if( rect->g_h % helm )
      {
         /* In die beiden verschiedenen
            Richtungen snappen */
         if( (flag & TOSMALLER) ||
             (rect->g_h % helm < helm/2) )
            rect->g_h -= rect->g_h % helm;
         if( (flag & TOBIGGER) ||
             (rect->g_h % helm >= helm/2) )
            rect->g_h += helm - (rect->g_h % helm);
      }
}
