/**
 * STune - The battle for Aratis
 * units.c : Functions that concern the units in STune
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
#include <stdio.h>
#include <string.h>

#include "stunedef.h"
#include "stunmain.h"
#include "me_routi.h"
#include "th_graf.h"


void einheit_selektiert(unsigned short nr)
{
  unsigned short i;

  if(ak_einh[0]==9) return;
  for(i=1; i<=ak_einh[0]; i++)
    if(ak_einh[i]==nr) return;
  ak_einh[++ak_einh[0]]=ak_nr=nr;
}

void einheiten_selektieren(int x, int y, int w, int h)
{
  unsigned int xc,yc;

  ak_einh[0]=0;
  for(xc=x ; xc<=x+w ; xc++)
   for(yc=y ; yc<=y+h ; yc++)
    if(sfeld[xc][yc].besetzt && sfeld[xc][yc].besetzertyp && !sfeld[xc][yc].gesinnung)
    {
      if(ak_einh[0]<9)
        einheit_selektiert(sfeld[xc][yc].nr);
      else 
        if(ak_einh[0]) ak_art=2; else {ak_art=0; return;}
    } 
  if(ak_einh[0]) ak_art=2; else ak_art=0;
}


TECHNOLOGIE tech_level[10]=
{
 {2,TRUPPE,TRUPPEN,0,0,0,0, /* Level 0 */
   0,0,0,0,0,0,
   0,0,0,0,0,0,
   3,KRAFTWERK,RAFFINERIE,KASERNE,0,0,0,0,0,0,0,0,0,0,0},

 {3,TRUPPE,TRUPPEN,GRENADIER,0,0,0, /* lev. 1 */
   1,QUAD,0,0,0,0,
   0,0,0,0,0,0,
   5,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,SANDSACK,0,0,0,0,0,0,0,0},

 {3,TRUPPE,TRUPPEN,GRENADIER,0,0,0, /* levl 2 */
   2,QUAD,PANZER_L,0,0,0,
   0,0,0,0,0,0,
   6,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,RADAR,SANDSACK,0,0,0,0,0,0,0},

 {3,TRUPPE,TRUPPEN,GRENADIER,0,0,0,  /*levl 3*/
   3,QUAD,PANZER_L,TRIKE,0,0,
   0,0,0,0,0,0,
   7,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,RADAR,SANDSACK,MG_TURM,0,0,0,0,0,0,0},

 {4,TRUPPE,TRUPPEN,GRENADIER,BAZOOKA,0,0,  /* levl 4 */
   3,QUAD,PANZER_L,TRIKE,0,0,
   1,RAKETENWERFER,0,0,0,0,
   8,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,RADAR,SANDSACK,MG_TURM,FABRIK_GR,0,0,0,0,0,0},

 {5,TRUPPE,TRUPPEN,GRENADIER,BAZOOKA,BEKEHRER,0, /* levl 5 */
   3,QUAD,PANZER_L,TRIKE,0,0,
   2,RAKETENWERFER,SAMMLER,0,0,0,
   9,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,RADAR,SANDSACK,MG_TURM,FABRIK_GR,WERKSTATT,0,0,0,0,0},

 {5,TRUPPE,TRUPPEN,BEKEHRER,GRENADIER,BAZOOKA,0, /* levl 6 */
   3,QUAD,PANZER_L,TRIKE,0,0,
   3,RAKETENWERFER,SAMMLER,PANZER_S,0,0,
   11,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,RADAR,SANDSACK,MG_TURM,FABRIK_GR,WERKSTATT,MAUER,RK_TURM,0,0,0},

 {5,TRUPPE,TRUPPEN,BEKEHRER,GRENADIER,BAZOOKA,0, /* levl 7 */
   4,QUAD,PANZER_L,LASERFAHRZEUG,TRIKE,0,
   3,RAKETENWERFER,PANZER_S,SAMMLER,0,0,
   11,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,RADAR,SANDSACK,MG_TURM,FABRIK_GR,WERKSTATT,MAUER,RK_TURM,0,0,0},

 {6,TRUPPE,TRUPPEN,BEKEHRER,GRENADIER,BAZOOKA,FLAMMENWERFER, /* levl 8 */
   4,QUAD,PANZER_L,LASERFAHRZEUG,TRIKE,0,
   4,RAKETENWERFER,PANZER_S,SAMMLER,FLAMMENTANK,0,
   11,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,RADAR,SANDSACK,MG_TURM,FABRIK_GR,WERKSTATT,MAUER,RK_TURM,0,0,0},

 {6,TRUPPE,TRUPPEN,BEKEHRER,GRENADIER,BAZOOKA,FLAMMENWERFER, /* levl 9 */
   4,QUAD,PANZER_L,LASERFAHRZEUG,TRIKE,0,
   5,RAKETENWERFER,PANZER_S,SAMMLER,INFRATANK,FLAMMENTANK,
   12,KRAFTWERK,RAFFINERIE,KASERNE,FABRIK_KL,RADAR,SANDSACK,MG_TURM,FABRIK_GR,WERKSTATT,MAUER,RK_TURM,INFRATURM,0,0},

};


void sammler_inhalt(unsigned short nr)
{
  static char *sammler[2]={"Sammler ist zu","% gefÅllt... "};
  static char txt[64];
  unsigned int inhalt;

  inhalt=einheiten[nr].zielobj;
  sprintf(txt, "%s %i %s", sammler[0], (inhalt*100/70), sammler[1]); /*NEW*/ /* Unter GNU-C gibt's kein itoa() mehr */
  neuemeldung(txt);
}


void set_einheit(unsigned short art, unsigned short xpos, unsigned short ypos, unsigned short ges, short obj)
{
  lleinh++;
  if(!obj)  /* obj: 0 Einheit;  1 Geschoss(ohne Zielangaben) */
  {
   einheiten[lleinh].xpos=einheiten[lleinh].altxpos=xpos;
   einheiten[lleinh].ypos=einheiten[lleinh].altypos=ypos;
   einheiten[lleinh].xkoor=einheiten[lleinh].altesx=xpos<<4;
   einheiten[lleinh].ykoor=einheiten[lleinh].altesy=ypos<<4;
   einheiten[lleinh].art=art;
   einheiten[lleinh].zustand=einheit_typ[art].zustandspunkte;
   einheiten[lleinh].ausrichtung=4;
   if(art!=SAMMLER) einheiten[lleinh].status=WACHEN|BEWEG_ABGE; else einheiten[lleinh].status=0;
   einheiten[lleinh].gesinnung=ges;
   sfeld[xpos][ypos].nr=lleinh;
  }
  else
  {
   einheiten[lleinh].xpos=einheiten[lleinh].altxpos=xpos;
   einheiten[lleinh].ypos=einheiten[lleinh].altypos=ypos;
   einheiten[lleinh].xkoor=einheiten[lleinh].altesx=(xpos<<4);
   einheiten[lleinh].ykoor=einheiten[lleinh].altesy=(ypos<<4);
   einheiten[lleinh].art=art;
   if(art==RAKETE) einheiten[lleinh].zustand=10;
   if(art==SCHALL) einheiten[lleinh].zustand=11;
   else einheiten[lleinh].zustand= einheit_typ[einheiten[einheiten[lleinh].wie_weit].art].feuerkraft;
   einheiten[lleinh].status=BEWEG;
  }
}


void sammeln_schicken(unsigned short nr,unsigned short xziel, unsigned short yziel)
{
  einheiten[nr].status|=SAMMELN;
  bewegung(nr,xziel,yziel,1);
  return;
}

void saft_suchen(unsigned short nr)
{
  signed short l=einheiten[nr].xpos,r=einheiten[nr].xpos,
              o=einheiten[nr].ypos,u=einheiten[nr].ypos+1,i;
  short leer=1,test;

if(einheiten[nr].gesinnung==0) /* nur bei eigenen auf erforscht prÅfen */
 do   /* Abfrage ob Åberhaupt noch Saft vorhanden ist noch einbauen */
  {
  test=0;
  r++;
  for(i=l;i<=r;i++) 
  {
    if(i<0 || i>127) continue;
    if(u<0 || u>127) continue;
    test++;
    if(sfeld[i][u].ertrag && sfeld[i][u].erforscht) {sammeln_schicken(nr,i,u);leer=0;}
  }
  o--;
  for(i=u;i>=o;i--)
  {
    if(r<0 || r>127) continue;
    if(i<0 || i>127) continue;
    test++;
    if(sfeld[r][i].ertrag && sfeld[r][i].erforscht) {sammeln_schicken(nr,r,i);leer=0;}
  }
  l--;
  for(i=r;i>=l;i--)
  {
    if(i<0 || i>127) continue;
    if(o<0 || o>127) continue;
    test++;
    if(sfeld[i][o].ertrag && sfeld[i][o].erforscht) {sammeln_schicken(nr,i,o);leer=0;}
  }
  u++;
  for(i=o;i<=u;i++)
  {
    if(l<0 || l>127) continue;
    if(i<0 || i>127) continue;
    test++;
    if(sfeld[l][i].ertrag && sfeld[l][i].erforscht) {sammeln_schicken(nr,l,i);leer=0;}
  } 
 } while(leer && test);  /* wenn kein test mehr durchgefÅhrt wurde */
 else 
  do   /* Abfrage ob Åberhaupt noch Saft vorhanden ist noch einbauen */
  {
  test=0;
  r++;
  for(i=l;i<=r;i++) 
  {
    if(i<0 || i>127) continue;
    if(u<0 || u>127) continue;
    test++;
    if(sfeld[i][u].ertrag) {sammeln_schicken(nr,i,u);leer=0;}
  }
  o--;
  for(i=u;i>=o;i--)
  {
    if(r<0 || r>127) continue;
    if(i<0 || i>127) continue;
    test++;
    if(sfeld[r][i].ertrag) {sammeln_schicken(nr,r,i);leer=0;}
  }
  l--;
  for(i=r;i>=l;i--)
  {
    if(i<0 || i>127) continue;
    if(o<0 || o>127) continue;
    test++;
    if(sfeld[i][o].ertrag) {sammeln_schicken(nr,i,o);leer=0;}
  }
  u++;
  for(i=o;i<=u;i++)
  {
    if(l<0 || l>127) continue;
    if(i<0 || i>127) continue;
    test++;
    if(sfeld[l][i].ertrag) {sammeln_schicken(nr,l,i);leer=0;}
  } 
 } while(leer && test);

 return;                 /* ist das Spielfeld saftfrei */
}


void einheiten_definieren(void)
{
 einheit_typ[0].zustandspunkte=15;   /* Fuûtruppe einfach*/
 einheit_typ[0].geschwindigkeit=4;
 einheit_typ[0].ausrgeschw=20;
 einheit_typ[0].schiessgeschw=9;
 einheit_typ[0].kosten=50;
 einheit_typ[0].feuerkraft=3;
 einheit_typ[0].reichweite=3;
 einheit_typ[0].befahrbar=1;

 einheit_typ[1].zustandspunkte=29;   /* Fuûtruppenverband */
 einheit_typ[1].geschwindigkeit=5;
 einheit_typ[1].ausrgeschw=20;
 einheit_typ[1].schiessgeschw=9;
 einheit_typ[1].kosten=200;
 einheit_typ[1].feuerkraft=5;
 einheit_typ[1].reichweite=3;
 einheit_typ[1].befahrbar=1;

 einheit_typ[2].zustandspunkte=36;   /* Buggy/Quad/Jeep ?  */
 einheit_typ[2].geschwindigkeit=10;
 einheit_typ[2].ausrgeschw=8;
 einheit_typ[2].schiessgeschw=8;
 einheit_typ[2].kosten=400;
 einheit_typ[2].feuerkraft=6;
 einheit_typ[2].reichweite=4;
 einheit_typ[2].befahrbar=0;

 einheit_typ[3].zustandspunkte=14;   /* Bekehrer */
 einheit_typ[3].geschwindigkeit=7;
 einheit_typ[3].ausrgeschw=20;
 einheit_typ[3].schiessgeschw=0;
 einheit_typ[3].kosten=600;
 einheit_typ[3].feuerkraft=0;
 einheit_typ[3].reichweite=2;
 einheit_typ[3].befahrbar=1;

 einheit_typ[4].zustandspunkte=26;   /* Bazooka */
 einheit_typ[4].geschwindigkeit=4;
 einheit_typ[4].ausrgeschw=20;
 einheit_typ[4].schiessgeschw=6;
 einheit_typ[4].kosten=225;
 einheit_typ[4].feuerkraft=10;
 einheit_typ[4].reichweite=6;
 einheit_typ[4].befahrbar=1;

 einheit_typ[5].zustandspunkte=31;   /* Grenadier */
 einheit_typ[5].geschwindigkeit=4;
 einheit_typ[5].ausrgeschw=20;
 einheit_typ[5].schiessgeschw=6;
 einheit_typ[5].kosten=200;
 einheit_typ[5].feuerkraft=9;
 einheit_typ[5].reichweite=4;
 einheit_typ[5].befahrbar=1;

 einheit_typ[6].zustandspunkte=31;   /* Flammenwerfer */
 einheit_typ[6].geschwindigkeit=4;
 einheit_typ[6].ausrgeschw=20;
 einheit_typ[6].schiessgeschw=8;
 einheit_typ[6].kosten=250;
 einheit_typ[6].feuerkraft=8;
 einheit_typ[6].reichweite=4;
 einheit_typ[6].befahrbar=1;

 einheit_typ[7].zustandspunkte=25;   /* Trike */
 einheit_typ[7].geschwindigkeit=16;
 einheit_typ[7].ausrgeschw=10;
 einheit_typ[7].schiessgeschw=8;
 einheit_typ[7].kosten=500;
 einheit_typ[7].feuerkraft=5;
 einheit_typ[7].reichweite=4;
 einheit_typ[7].befahrbar=0;

 einheit_typ[10].zustandspunkte=50;   /* leichter Panzer */
 einheit_typ[10].geschwindigkeit=7;
 einheit_typ[10].ausrgeschw=5;
 einheit_typ[10].schiessgeschw=6;
 einheit_typ[10].kosten=600;
 einheit_typ[10].feuerkraft=9;
 einheit_typ[10].reichweite=6;
 einheit_typ[10].befahrbar=0;

 einheit_typ[11].zustandspunkte=65;   /* Raketenwerfer */
 einheit_typ[11].geschwindigkeit=7;
 einheit_typ[11].ausrgeschw=5;
 einheit_typ[11].schiessgeschw=6;
 einheit_typ[11].kosten=1000;
 einheit_typ[11].feuerkraft=12;
 einheit_typ[11].reichweite=10;
 einheit_typ[11].befahrbar=0;

 einheit_typ[12].zustandspunkte=80;   /* schwerer Panzer */
 einheit_typ[12].geschwindigkeit=5;
 einheit_typ[12].ausrgeschw=3;
 einheit_typ[12].schiessgeschw=5;
 einheit_typ[12].kosten=800;
 einheit_typ[12].feuerkraft=13;
 einheit_typ[12].reichweite=8;
 einheit_typ[12].befahrbar=0;

 einheit_typ[13].zustandspunkte=100;   /* Erntemaschine */
 einheit_typ[13].geschwindigkeit=7;
 einheit_typ[13].ausrgeschw=6;
 einheit_typ[13].schiessgeschw=0;
 einheit_typ[13].kosten=700;
 einheit_typ[13].feuerkraft=0;
 einheit_typ[13].reichweite=2;
 einheit_typ[13].befahrbar=0;

 einheit_typ[14].zustandspunkte=55;   /* Laser Fahrzeug? */
 einheit_typ[14].geschwindigkeit=7;
 einheit_typ[14].ausrgeschw=8;
 einheit_typ[14].schiessgeschw=5;
 einheit_typ[14].kosten=900;
 einheit_typ[14].feuerkraft=15;
 einheit_typ[14].reichweite=8;
 einheit_typ[14].befahrbar=0;

 einheit_typ[15].zustandspunkte=45;   /* Flammentank */
 einheit_typ[15].geschwindigkeit=7;
 einheit_typ[15].ausrgeschw=7;
 einheit_typ[15].schiessgeschw=6;
 einheit_typ[15].kosten=500;
 einheit_typ[15].feuerkraft=9;
 einheit_typ[15].reichweite=7;
 einheit_typ[15].befahrbar=0;

 einheit_typ[16].zustandspunkte=65;   /* Infra-Tank */
 einheit_typ[16].geschwindigkeit=7;
 einheit_typ[16].ausrgeschw=6;
 einheit_typ[16].schiessgeschw=6;
 einheit_typ[16].kosten=900;
 einheit_typ[16].feuerkraft=11;
 einheit_typ[16].reichweite=8;
 einheit_typ[16].befahrbar=0;

 return;
}

void ausrzahl_definieren(void)
{
  ausrzahl[0].x=0; ausrzahl[0].y=-1;
  ausrzahl[1].x=1; ausrzahl[1].y=-1;
  ausrzahl[2].x=1; ausrzahl[2].y=0;
  ausrzahl[3].x=1; ausrzahl[3].y=1;
  ausrzahl[4].x=0; ausrzahl[4].y=1;
  ausrzahl[5].x=-1; ausrzahl[5].y=1;
  ausrzahl[6].x=-1; ausrzahl[6].y=0;
  ausrzahl[7].x=-1; ausrzahl[7].y=-1;
  return;
}

