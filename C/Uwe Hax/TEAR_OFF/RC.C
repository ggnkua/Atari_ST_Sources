/*------------------------------------------------------------------*/
/* RC.C                                                             */
/*                                                                  */
/* Rechteck-Verwaltung                                              */
/* (c)1995 by MAXON-Computer                                        */         
/* Autor: Uwe Hax                                                   */
/*------------------------------------------------------------------*/

#include <portab.h>
#include <aes.h>

#include "prototyp.h"
#include "typedef.h"


/*------------------------------------------------------------------*/
/* Feststellen, ob die Koordinaten in einem Rechteck liegen.        */
/*------------------------------------------------------------------*/

WORD rc_inside (GRECT *rect, WORD x, WORD y)
{
  return ((x >= rect->g_x) && (y >= rect->g_y) && 
          (x < rect->g_x + rect->g_w) && (y < rect->g_y + rect->g_h));
} /* rc_inside */


/*------------------------------------------------------------------*/
/* Feststellen, ob sich zwei Rechtecke berlappen.                  */
/*------------------------------------------------------------------*/

WORD rc_intersect (GRECT *rect1, GRECT *rect2)
{
  WORD x, y, w, h;

  x = Max(rect2->g_x, rect1->g_x);
  y = Max(rect2->g_y, rect1->g_y);
  w = Min(rect2->g_x + rect2->g_w, rect1->g_x + rect1->g_w);
  h = Min(rect2->g_y + rect2->g_h, rect1->g_y + rect1->g_h);

  rect2->g_x = x;
  rect2->g_y = y;
  rect2->g_w = w - x;
  rect2->g_h = h - y;

  return ((w > x) && (h > y));
} /* rc_intersect */

