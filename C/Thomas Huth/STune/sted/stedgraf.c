/**
 * STune - The battle for Aratis
 * stedgraf.c : Graphic functions.
 * Copyright (C) 2003 Thomas Huth
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 */

#include <aes.h>
#include <vdi.h>

#include "stedmain.h"

#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif



#ifdef __TURBOC__
#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<(b)?(a):(b))
int rc_intersect( GRECT *r1, GRECT *r2 )
{
   int x, y, w, h;

   x = max( r2->g_x, r1->g_x );
   y = max( r2->g_y, r1->g_y );
   w = min( r2->g_x + r2->g_w, r1->g_x + r1->g_w );
   h = min( r2->g_y + r2->g_h, r1->g_y + r1->g_h );

   r2->g_x = x;
   r2->g_y = y;
   r2->g_w = w - x;
   r2->g_h = h - y;

   return ( ((w > x) && (h > y) ) );
}
#endif



/* ***Palette setzen*** */
void setpal(int palette[][3])
{
 int i;

 for(i=0; i<15; i++)
  {
   vs_color(vhndl, i, &palette[i][0]);
  }
}


/* ***16x16 Bodenblock in Offscreen zeichnen*** */
void drawblk(short destx, short desty, unsigned short index)
{
 int xy[8];

 xy[0]=0;
 xy[1]=index<<4;
 xy[2]=15;
 xy[3]=xy[1]+15;
 xy[4]=destx;
 xy[5]=desty;
 xy[6]=destx+15;
 xy[7]=desty+15;

 vro_cpyfm(vhndl, 3, xy, &bodenfdb, &offscr);
}


/* *** Teil des Offscreens neu zeichnen *** */
void drawoffscr(short ox, short oy, short ow, short oh)
{
 short i, j; int xy[8];

 for(i=ox; i<ox+ow; i++)
  for(j=oy; j<oy+oh; j++)
   {
	drawblk((i-rwx)<<4, (j-rwy)<<4, sfeld[i][j].feldtyp);
   }
 for(i=0; i<en_anz; i++)
  {
   if( en[i].typ==1 && (short)en[i].xpos>=ox && (short)en[i].ypos>=oy
      && (short)en[i].xpos<ox+ow && (short)en[i].ypos<oy+oh )
    {
     xy[0]=0; xy[1]=en[i].art*32;
     if( en[i].ges ) xy[1]+=25*32;
     xy[2]=15; xy[3]=xy[1]+15;
     xy[4]=(en[i].xpos-rwx)*16; xy[5]=(en[i].ypos-rwy)*16;
     xy[6]=xy[4]+15; xy[7]=xy[5]+15;
     vro_cpyfm(vhndl, 3, xy, &einhfdb, &offscr);
    }
      
  }
}


/* ***Ein Geb„ude Zeichnen*** */
void drawgebaeude(unsigned short gart, short gxp, short gyp, short ggesng)
{
 unsigned int i, gbi, gw, gh;
 int xy[8];

 if(ggesng==0)
   gbi=32;
  else
   gbi=104;
 for(i=0; i<gart; i++)
  { gw=gebaeude_typ[i].groesse;  gbi+=gw*gw; }
 i=gebaeude_typ[gart].groesse;
 for(gh=0; gh<i; gh++)
  for(gw=0; gw<i; gw++)
   {
    xy[0]=0; xy[1]=gbi*16;
    xy[2]=15; xy[3]=xy[1]+15;
    xy[4]=(gxp+gw)*16+wi.g_x; xy[5]=(gyp+gh)*16+wi.g_y;
    xy[6]=xy[4]+15; xy[7]=xy[5]+15;
    vro_cpyfm(vhndl, 3, xy, &bodenfdb, &scrnmfdb);
    ++gbi;
   }
}


/* ***Grafik im Fenster aufbauen*** */
void drwindow(GRECT *xywh)
{
 GRECT clip;
 int xy[8];

 wind_update(BEG_UPDATE);
 graf_mouse(M_OFF, 0L);

 wind_get(wihndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
 while(clip.g_w!=0 && clip.g_h!=0)
 {
  if( rc_intersect(xywh, &clip) )
	{
	 clip.g_w+=clip.g_x-1;	clip.g_h+=clip.g_y-1;
	 if(smodus==0)  /* Editiermodus */
	  {
	   xy[0]=clip.g_x-wi.g_x; xy[1]=clip.g_y-wi.g_y;
	   xy[2]=clip.g_w-wi.g_x; xy[3]=clip.g_h-wi.g_y;
	   xy[4]=clip.g_x; xy[5]=clip.g_y;
	   xy[6]=clip.g_w; xy[7]=clip.g_h;
	   vro_cpyfm(vhndl, 3, xy, &offscr, &scrnmfdb);
	  }
	  else  /* Ausw„hlmodus */
	  {
	   short dcx, dcy, i;
	   vs_clip(vhndl, 1, (int *)&clip);
	   switch(tmodus)
	    {
	     case 0:
	       xy[0]=0; xy[2]=15;
	       for(dcy=0; dcy<(short)rwh; dcy++)
	        for(dcx=0; dcx<(short)rww; dcx++)
		     {
		      if(dcy*rww+dcx<32) 
		        xy[1]=(dcy*rww+dcx)*16;
		      xy[3]=xy[1]+15;
		      xy[4]=dcx*16+wi.g_x;
		      xy[5]=dcy*16+wi.g_y;
		      xy[6]=xy[4]+15;	xy[7]=xy[5]+15;
		      vro_cpyfm(vhndl, (dcy*rww+dcx<32)?3:15, xy, &bodenfdb, &scrnmfdb);
		     }
		   break;
		 case 1:
		   xy[0]=xy[4]=wi.g_x; xy[1]=xy[5]=wi.g_y;
		   xy[2]=xy[6]=wi.g_x+wi.g_w-1; xy[3]=xy[7]=wi.g_y+wi.g_h-1;
	       vro_cpyfm(vhndl, 15, xy, &scrnmfdb, &scrnmfdb);
		   i=0;
	       for(dcy=0; dcy+2<(short)rwh && i<=25; dcy+=3)
	        for(dcx=0; dcx+2<(short)rww && i<=25; dcx+=3)
		     {
		      drawgebaeude((i>12)?(i-13):(i), dcx, dcy, (i>12));
		      ++i;
		     }
		   break;
		 case 2:
	       xy[0]=0; xy[2]=15;
	       for(dcy=0; dcy<(short)rwh; dcy++)
	        for(dcx=0; dcx<(short)rww; dcx++)
		     {
		      int index=dcy*rww+dcx;
		      if(index<45) 
		        xy[1]=(index)*32;
		      xy[3]=xy[1]+15;
		      xy[4]=dcx*16+wi.g_x;
		      xy[5]=dcy*16+wi.g_y;
		      xy[6]=xy[4]+15;	xy[7]=xy[5]+15;
		      vro_cpyfm(vhndl, ((index>=25 && index<45) || index<20)?3:15, xy, &einhfdb, &scrnmfdb);
		     }
		   break;
		}
	   vs_clip(vhndl, 0, (int *)&clip);
	  }
	}
  wind_get(wihndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
 }

 graf_mouse(M_ON, 0L);
 wind_update(END_UPDATE);
}
