/**
 * STune - The battle for Aratis
 * building.c : Functions that concern the buildings in STune
 * Copyright (C) 2003 Matthias Alles, Thomas Huth
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

#include <stdlib.h>

#include "stunedef.h"
#include "stunmain.h"
#include "me_routi.h"
#include "th_graf.h"
#include "th_aesev.h"
#include "building.h"
#include "me_kifkt.h"


unsigned short in_reichweite_geb(unsigned short auftr, unsigned short ziel)
{
  unsigned short rweite;
  signed short x,y;

/*  switch(geb[auftr].art)
  {
    case MG_TURM: rweite=6;
                  break;
    case RK_TURM: rweite=10;
                  break;
    default: rweite=8;
             break;
  } */
  rweite=gebaeude_typ[geb[auftr].art].rweite;
  x=(signed)geb[auftr].xpos-(signed)einheiten[ziel].xpos;
  y=(signed)geb[auftr].ypos-(signed)einheiten[ziel].ypos;
  if( (unsigned)abs(x)>rweite || (unsigned)abs(y)>rweite) return(0); else return(1);
}

void gebaeude_angriff(unsigned short nr, signed int xp, signed int yp)
{
  geb[nr].status&=~WACHE;
  geb[nr].status|=ANGRIFF;
  geb[nr].zielnr=nummer_ermitteln((unsigned)(xp),(unsigned)(yp),1);
  geb[nr].wie_weit=0;
  return;
}

void gebaeude_entfernen(unsigned short nr)
{
  unsigned short x,y,i;
  short gebgroesse;

  gebgroesse=gebaeude_typ[geb[nr].art].groesse;
  if(geb[nr].gesinnung && !netflag) gebaeude_wieder_aufbauen(nr);
  if(geb[nr].gesinnung) geb_verl[1]++; else geb_verl[0]++;

  if(ak_art==1 && ak_nr==nr) {ak_art=0; ak_nr=0;rdr_infobar();}
  for(x=geb[nr].xpos;x<geb[nr].xpos+gebgroesse;x++)
  {
    for(y=geb[nr].ypos;y<geb[nr].ypos+gebgroesse;y++)
    {
      sfeld[x][y].besetzt=0;
      sfeld[x][y].befahrbar=1;
      sfeld[x][y].begehbar=1;
      sfeld[x][y].feldtyp=1;
      sfeld[x][y].nr=0;
    }
  }
  if(geb[nr].art==RAFFINERIE)
  {
    x=id_suchen_einh(SAMMLER,geb[nr].ID,geb[nr].gesinnung);
    if(x & !(einheiten[x].status&BEWEG))
    {
      einheiten[x].status=0;
      einheiten[x].zielobj=0;
    }
    else
      einheiten[x].status|=STOP;
  }
  neu_zeichnen(nr);
  x=llgeb;
  if(x!=nr)
    for(i=1;i<=lleinh;i++)
    {
      if(einheiten[i].status&ANGR && einheiten[i].zielobj==x && einheiten[i].zielart==0)
        einheiten[i].zielobj=nr;
      if(einheiten[i].art>19 && einheiten[i].xpospatr==0 && einheiten[i].wie_weit==x)
        einheiten[i].wie_weit=nr;
    }
  geb[nr]=geb[x];
  geb[x].zustand=0;
  for(x=geb[nr].xpos;x<geb[nr].xpos+gebgroesse;x++)
  {
    for(y=geb[nr].ypos;y<geb[nr].ypos+gebgroesse;y++)
    { 
      sfeld[x][y].nr=nr;
    }
  }
  llgeb--;
  return;
}


void neu_zeichnen(unsigned short nr)
{
  unsigned short gebgroesse=gebaeude_typ[geb[nr].art].groesse;
  GRECT ent_grect;

  drawoffscr(geb[nr].xpos,geb[nr].ypos,gebgroesse,gebgroesse);
  ent_grect.g_x=((geb[nr].xpos-rwx)<<4)+wi.g_x;
  ent_grect.g_y=((geb[nr].ypos-rwy)<<4)+wi.g_y;
  ent_grect.g_w=gebgroesse<<4;
  ent_grect.g_h=gebgroesse<<4;
  drwindow(&ent_grect);
  return;
}


void gebaeude_infiltriert(unsigned short von_wem)
{
    EINHEIT *einh;
    signed short z,z2;
    unsigned int i,gh,gw,gart;
    unsigned int gbi;

    einh=&einheiten[von_wem];
    gart=geb[einh->zielobj].art;
    if(gart==RAFFINERIE)
    {
      i=id_suchen_einh(SAMMLER,geb[einh->zielobj].ID,geb[einh->zielobj].gesinnung);
      if(i) einheiten[i].status|=STOP;
    }
    geb[einh->zielobj].gesinnung=einh->gesinnung;
    if(einh->gesinnung==0)
      gbi=32;
    else
      gbi=104;
    for(z=geb[einh->zielobj].xpos;z<geb[einh->zielobj].xpos+gebaeude_typ[gart].groesse;z++)
      for(z2=geb[einh->zielobj].ypos;z2<geb[einh->zielobj].ypos+gebaeude_typ[gart].groesse;z2++)
         sfeld[z][z2].gesinnung=einh->gesinnung;
    angriffe_abschalten(einh->zielobj,0);
    for(i=0; i<gart; i++)
     { gw=gebaeude_typ[i].groesse;  gbi+=gw*gw; }
    i=gebaeude_typ[gart].groesse;
    for(gh=0; gh<i; gh++)
     for(gw=0; gw<i; gw++)
      {
       sfeld[geb[einh->zielobj].xpos+gw][geb[einh->zielobj].ypos+gh].feldtyp=gbi;
       ++gbi;
      }
    neu_zeichnen(einh->zielobj);
    einheit_entfernen(von_wem);    /* Bekehrer verschwindet */
    return;
}


/* ***Ein neues Geb„ude auf Spielfeld setzen*** */
void setgebaeude(unsigned short gart, short gxp, short gyp, short ggesng)
{
 unsigned int i, gbi, gw, gh;
 unsigned short gebnr,id=0;

 if(ggesng==0)
   gbi=32;
  else
   gbi=104;
 gebnr=llgeb+1;
 geb[gebnr].zustand=gebaeude_typ[gart].zustandspunkte;
 geb[gebnr].xpos=gxp;
 geb[gebnr].ypos=gyp;
 geb[gebnr].art=gart;
 geb[gebnr].gesinnung=ggesng;
 do
 {
   id++;
 }
 while(id_suchen(gart,id,ggesng));
 geb[gebnr].ID=id;
 llgeb++;
 for(i=0; i<gart; i++)
  { gw=gebaeude_typ[i].groesse;  gbi+=gw*gw; }
 i=gebaeude_typ[gart].groesse;
 for(gh=0; gh<i; gh++)
  for(gw=0; gw<i; gw++)
   {
    sfeld[gxp+gw][gyp+gh].feldtyp=gbi;
    ++gbi;
    sfeld[gxp+gw][gyp+gh].befahrbar=gebaeude_typ[geb[gebnr].art].befahrbar;
    sfeld[gxp+gw][gyp+gh].gesinnung=ggesng;
    sfeld[gxp+gw][gyp+gh].besetzertyp=0;
    sfeld[gxp+gw][gyp+gh].besetzt=1;
    sfeld[gxp+gw][gyp+gh].begehbar=0;
    sfeld[gxp+gw][gyp+gh].nr=gebnr;
   }
 drawoffscr(gxp,gyp,i,i);
 geb[gebnr].status=0;
 if(gart==RAFFINERIE) einheit_initialisieren(SAMMLER,gebnr,0);
 if(gart==MG_TURM || gart==RK_TURM || gart==INFRATURM) geb[gebnr].status=WACHE;
  else geb[gebnr].status=0;
 ak_art=0;
}


/* ***Bauanlange im Fenster zentrieren*** */
void center_bauanlage(short redraw)
{
 int i, x=0, y=0, oldx, oldy;

 for(i=1; i<=llgeb; i++)
  {
   if(geb[i].art==BAUANLAGE && geb[i].gesinnung==0)
    {
     x=geb[i].xpos;
     y=geb[i].ypos;
     break;
    }
  }

 oldx=rwx; oldy=rwy;
 rwx=x-rww/2;
 if(rwx+rww>r_width) rwx=r_width-rww;
 if(rwx<0) rwx=0;
 rwy=y-rwh/2;
 if(rwy+rwh>r_height) rwy=r_height-rwh;
 if(rwy<0) rwy=0;

 if(redraw)
  {
   drawoffscr(rwx,rwy,rww,rwh);
   drwindow(&wi);
   setslidnmarker(3, oldx, oldy);
  }
}


void gebaeude_definieren(void)
{
 gebaeude_typ[0].kosten=2500;
 gebaeude_typ[0].zustandspunkte=150;  /* Bauanlage */
 gebaeude_typ[0].befahrbar=0;
 gebaeude_typ[0].begehbar=0;
 gebaeude_typ[0].energiebedarf=0;
 gebaeude_typ[0].groesse=2;
 gebaeude_typ[0].prioritaet=0;

 gebaeude_typ[1].kosten=300;
 gebaeude_typ[1].zustandspunkte=110;  /* Kraftwerk */
 gebaeude_typ[1].energiebedarf=-40;
 gebaeude_typ[1].groesse=2;
 gebaeude_typ[1].befahrbar=0;
 gebaeude_typ[1].begehbar=0;
 gebaeude_typ[1].prioritaet=4;

 gebaeude_typ[2].kosten=1000;
 gebaeude_typ[2].zustandspunkte=200; /* Raffinerie */
 gebaeude_typ[2].befahrbar=0;
 gebaeude_typ[2].energiebedarf=30;
 gebaeude_typ[2].groesse=3;
 gebaeude_typ[2].begehbar=0;
 gebaeude_typ[2].prioritaet=10;

 gebaeude_typ[3].kosten=600;
 gebaeude_typ[3].zustandspunkte=120; /* RADAR */
 gebaeude_typ[3].befahrbar=0;
 gebaeude_typ[3].begehbar=0;
 gebaeude_typ[3].energiebedarf=30;
 gebaeude_typ[3].groesse=2;
 gebaeude_typ[3].prioritaet=2;

 gebaeude_typ[4].kosten=300;
 gebaeude_typ[4].zustandspunkte=100; /* Kaserne */
 gebaeude_typ[4].befahrbar=0;
 gebaeude_typ[4].begehbar=0;
 gebaeude_typ[4].energiebedarf=20;
 gebaeude_typ[4].groesse=2;
 gebaeude_typ[4].prioritaet=3;

 gebaeude_typ[5].kosten=600;
 gebaeude_typ[5].zustandspunkte=120; /* kl. Fabrik */
 gebaeude_typ[5].befahrbar=0;
 gebaeude_typ[5].begehbar=0;
 gebaeude_typ[5].energiebedarf=30;
 gebaeude_typ[5].groesse=2;
 gebaeude_typ[5].prioritaet=5;

 gebaeude_typ[6].kosten=250;
 gebaeude_typ[6].zustandspunkte=75; /* Maschinengewehrgeschtz */
 gebaeude_typ[6].befahrbar=0;
 gebaeude_typ[6].begehbar=0;
 gebaeude_typ[6].energiebedarf=5;
 gebaeude_typ[6].groesse=1;
 gebaeude_typ[6].prioritaet=6;
 gebaeude_typ[8].rweite=5;

 gebaeude_typ[7].kosten=800;
 gebaeude_typ[7].zustandspunkte=150; /* Werkstatt */
 gebaeude_typ[7].befahrbar=0;
 gebaeude_typ[7].begehbar=0;
 gebaeude_typ[7].energiebedarf=30;
 gebaeude_typ[7].groesse=3;
 gebaeude_typ[7].prioritaet=4;

 gebaeude_typ[8].kosten=500;
 gebaeude_typ[8].zustandspunkte=100; /* Raketengeschtz */
 gebaeude_typ[8].befahrbar=0;
 gebaeude_typ[8].begehbar=0;
 gebaeude_typ[8].energiebedarf=15;
 gebaeude_typ[8].groesse=1;
 gebaeude_typ[8].prioritaet=7;
 gebaeude_typ[8].rweite=7;

 gebaeude_typ[9].kosten=800;
 gebaeude_typ[9].zustandspunkte=150; /* groáe Fabrik */
 gebaeude_typ[9].befahrbar=0;
 gebaeude_typ[9].begehbar=0;
 gebaeude_typ[9].energiebedarf=40;
 gebaeude_typ[9].groesse=3;
 gebaeude_typ[9].prioritaet=8;

 gebaeude_typ[10].kosten=25;
 gebaeude_typ[10].zustandspunkte=20; /* Sandsack */
 gebaeude_typ[10].befahrbar=1;
 gebaeude_typ[10].begehbar=0;
 gebaeude_typ[10].energiebedarf=0;
 gebaeude_typ[10].groesse=1;
 gebaeude_typ[10].prioritaet=1;

 gebaeude_typ[11].kosten=100;
 gebaeude_typ[11].zustandspunkte=75; /* Betonmauer */
 gebaeude_typ[11].befahrbar=0;
 gebaeude_typ[11].begehbar=0;
 gebaeude_typ[11].energiebedarf=0;
 gebaeude_typ[11].groesse=1;
 gebaeude_typ[11].prioritaet=1;

 gebaeude_typ[12].kosten=700;
 gebaeude_typ[12].zustandspunkte=100; /* Infraturm */
 gebaeude_typ[12].begehbar=0;
 gebaeude_typ[12].befahrbar=0;
 gebaeude_typ[12].energiebedarf=20;
 gebaeude_typ[12].groesse=1;
 gebaeude_typ[12].prioritaet=7;
 gebaeude_typ[12].rweite=6;

}
