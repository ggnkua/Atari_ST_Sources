/*             DESK.C V1.0, 9.9.1990            */
/* Autor: Grischa Ekart / (c) by Grischa Ekart  */

#include "gem_it.h"

extern   GRECT gl_desk;

void
desk_init(int ob_index)
{
   OBJECT   *desk;

   rsrc_gaddr(R_TREE, ob_index, &desk);
   desk->ob_x = gl_desk.g_x;
   desk->ob_y = gl_desk.g_y;
   desk->ob_width = gl_desk.g_w;
   desk->ob_height = gl_desk.g_h;
   wind_set(0, WF_NEWDESK, desk, 0, 0);
   objc_draw(desk, ROOT, MAX_DEPTH,
      desk->ob_x, desk->ob_y,
      desk->ob_width, desk->ob_height);
}
