/* Fenster anordnen */
/*****************************************************************************
*
*											  7UP
*									  Modul: WARRANGE.C
*									 (c) by TheoSoft '95
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#if GEMDOS
#include <tos.h>
#else
#include <alloc.h>
#endif
#include <aes.h>
#include <vdi.h>

#include "7up.h"
#include "windows.h"
#include "undo.h"

extern WINDOW _wind[MAXWINDOWS];

typedef struct
{
  GRECT rect[MAXWINDOWS];
}TWindpos;

void Warrange(int how)
{
   TWindpos pos;
   int i,k,xd,yd,wd,hd;

   wind_get(0,WF_WORKXYWH,&xd,&yd,&wd,&hd);

   switch(Wcount(OPENED))
   {
      case 1:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd;
         pos.rect[1].g_h = hd;

         break;
      case 2:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd;
         pos.rect[1].g_h = hd/2;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/2;
         pos.rect[2].g_w = wd;
         pos.rect[2].g_h = hd/2;

         break;
      case 3:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd;
         pos.rect[1].g_h = hd/3;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/3;
         pos.rect[2].g_w = wd;
         pos.rect[2].g_h = hd/3;

         pos.rect[3].g_x = xd;
         pos.rect[3].g_y = yd+2*hd/3;
         pos.rect[3].g_w = wd;
         pos.rect[3].g_h = hd/3;

         break;
      case 4:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd/2;
         pos.rect[1].g_h = hd/2;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/2;
         pos.rect[2].g_w = wd/2;
         pos.rect[2].g_h = hd/2;

         pos.rect[3].g_x = xd+wd/2;
         pos.rect[3].g_y = yd;
         pos.rect[3].g_w = wd/2;
         pos.rect[3].g_h = hd/2;

         pos.rect[4].g_x = xd+wd/2;
         pos.rect[4].g_y = yd+hd/2;
         pos.rect[4].g_w = wd/2;
         pos.rect[4].g_h = hd/2;

         break;
      case 5:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd/2;
         pos.rect[1].g_h = hd/2;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/2;
         pos.rect[2].g_w = wd/2;
         pos.rect[2].g_h = hd/2;

         pos.rect[3].g_x = xd+wd/2;
         pos.rect[3].g_y = yd;
         pos.rect[3].g_w = wd/2;
         pos.rect[3].g_h = hd/3;

         pos.rect[4].g_x = xd+wd/2;
         pos.rect[4].g_y = yd+hd/3;
         pos.rect[4].g_w = wd/2;
         pos.rect[4].g_h = hd/3;

         pos.rect[5].g_x = xd+wd/2;
         pos.rect[5].g_y = yd+2*hd/3;
         pos.rect[5].g_w = wd/2;
         pos.rect[5].g_h = hd/3;

         break;
      case 6:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd/2;
         pos.rect[1].g_h = hd/3;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/3;
         pos.rect[2].g_w = wd/2;
         pos.rect[2].g_h = hd/3;

         pos.rect[3].g_x = xd;
         pos.rect[3].g_y = yd+2*hd/3;
         pos.rect[3].g_w = wd/2;
         pos.rect[3].g_h = hd/3;

         pos.rect[4].g_x = xd+wd/2;
         pos.rect[4].g_y = yd;
         pos.rect[4].g_w = wd/2;
         pos.rect[4].g_h = hd/3;

         pos.rect[5].g_x = xd+wd/2;
         pos.rect[5].g_y = yd+hd/3;
         pos.rect[5].g_w = wd/2;
         pos.rect[5].g_h = hd/3;

         pos.rect[6].g_x = xd+wd/2;
         pos.rect[6].g_y = yd+2*hd/3;
         pos.rect[6].g_w = wd/2;
         pos.rect[6].g_h = hd/3;

         break;
      case 7:
         pos.rect[1].g_x = xd;
         pos.rect[1].g_y = yd;
         pos.rect[1].g_w = wd/2;
         pos.rect[1].g_h = hd/3;

         pos.rect[2].g_x = xd;
         pos.rect[2].g_y = yd+hd/3;
         pos.rect[2].g_w = wd/2;
         pos.rect[2].g_h = hd/3;

         pos.rect[3].g_x = xd;
         pos.rect[3].g_y = yd+2*hd/3;
         pos.rect[3].g_w = wd/2;
         pos.rect[3].g_h = hd/3;

         pos.rect[4].g_x = xd+wd/2;
         pos.rect[4].g_y = yd;
         pos.rect[4].g_w = wd/2;
         pos.rect[4].g_h = hd/4;

         pos.rect[5].g_x = xd+wd/2;
         pos.rect[5].g_y = yd+hd/4;
         pos.rect[5].g_w = wd/2;
         pos.rect[5].g_h = hd/4;

         pos.rect[6].g_x = xd+wd/2;
         pos.rect[6].g_y = yd+2*hd/4;
         pos.rect[6].g_w = wd/2;
         pos.rect[6].g_h = hd/4;

         pos.rect[7].g_x = xd+wd/2;
         pos.rect[7].g_y = yd+3*hd/4;
         pos.rect[7].g_w = wd/2;
         pos.rect[7].g_h = hd/4;

         break;
   }
   for(i=1, k=1; i<MAXWINDOWS; i++)
      if(_wind[i].w_state & CREATED && _wind[i].w_state & OPENED)
         if(pos.rect[k].g_w && pos.rect[k].g_h)
            Wmovesize(&_wind[i],&pos.rect[k++]);
}
