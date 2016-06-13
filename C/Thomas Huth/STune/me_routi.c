/**
 * STune - The battle for Aratis
 * me_routi.c : Various functions concerning the game engine
 * Copyright (C) 2003 Matthias Alles
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
#include <osbind.h>

#include "stunmain.h"
#include "building.h"
#include "units.h"
#include "st_debug.h"
#include "st_net.h"
#include "th_musik.h"
#include "th_graf.h"
#include "me_kifkt.h"
#include "me_gemft.h"
#include "me_ausla.h"
#include "me_routi.h"

#ifdef SOZOBON
#pragma -CUS
#endif

#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif


unsigned short einh_verl[2];
unsigned short geb_verl[2];
unsigned long saft_ges[2];
int saft;

void patr_wachen(unsigned short a)
{
  unsigned short rweite,xp,yp;
  signed short z,z2;

  rweite=einheit_typ[einheiten[a].art].reichweite;
  xp=einheiten[a].xpos;
  yp=einheiten[a].ypos;
  for(z=(signed)(xp-rweite);z<=(signed)(xp+rweite);z++)
  {
    if(z<0) continue;
    if(z>127) continue;
    for(z2=(signed)(yp-rweite);z2<=(signed)(yp+rweite);z2++)
    {
      if(z2<0) continue;
      if(z2>127) continue;
      if(sfeld[z][z2].besetzt==1 && sfeld[z][z2].gesinnung!=einheiten[a].gesinnung)
      {
         einheiten[a].status&=~BEWEG;
         einheiten[a].status&=~NOCHM_BERE;
         einheiten[a].status&=~PATROLIE;
         einheiten[a].status|=WACHEN;
         angriff(a,z,z2,0);
/*         DBprnt(("status: %i",einheiten[a].status)); */
         return;
      }
    }
 }
 return;
}


unsigned short setze_freigaben(unsigned short a)
{
  unsigned short i,nx=einheiten[a].xpos,ny=einheiten[a].ypos;
  EINHEIT *einh;

  for(i=1;i<=lleinh;i++)
  {
    einh=&einheiten[i];

    if(einh->neuxpos==nx && einh->neuypos==ny && i!=a)
    {
      einh->status|=K_FREIGABE_N;
      return(i);
    }
    if(einh->xpos==nx && einh->ypos==ny && i!=a)
    {
      einh->status|=K_FREIGABE_A;
      return(i);
    }
  }
  return(0);
}


unsigned short id_suchen(unsigned short obj,unsigned short id,unsigned short ges)
{
  unsigned short i,j=llgeb+1;
  GEBAEUDE *gebs;

  for(i=1;i<j;i++)
  {
   gebs=&geb[i];
    if(gebs->art==obj)
      if(gebs->gesinnung==ges)
        if(gebs->ID==id)
          return(i);
  }
  return(0);
}


unsigned short id_suchen_einh(unsigned short obj,unsigned short id,unsigned short ges)
{
  unsigned short i,j=lleinh+1;
  EINHEIT *einh;

  for(i=1;i<j;i++)
  {
    einh=&einheiten[i];
    if(einh->art==obj)
      if(einh->gesinnung==ges)
        if(einh->ID==id)
          return(i);
  }
  return(0);
}


void zur_reperatur(unsigned short nr, unsigned short ng)
{
  bewegung(nr,geb[ng].xpos+1,geb[ng].ypos+3,1);
  einheiten[nr].status|=IN_WERKST;
}


void feld_reservieren(unsigned short a)
{
  unsigned short p,q,art=einheiten[a].art;
  short nx=einheiten[a].nochschrx,ny=einheiten[a].nochschry;

  if(nx<-1 || nx>1) nx=0;
  if(ny<-1 || ny>1) ny=0;
  p=einheiten[a].xpos+nx;
  q=einheiten[a].ypos+ny;
  sfeld[p][q].befahrbar=einheit_typ[art].befahrbar;
/*  if(art==TRUPPE || art==TRUPPEN || art==BEKEHRER || art==BAZOOKA */
/*                 || art==GRENADIER || art==FLAMMENWERFER) */
/*    sfeld[p][q].befahrbar=1; */
/*  else */
/*    sfeld[p][q].befahrbar=0; */
  sfeld[p][q].begehbar=0;
  sfeld[p][q].besetzt=1;
  sfeld[p][q].besetzertyp=1;
  sfeld[p][q].gesinnung=einheiten[a].gesinnung;
  sfeld[p][q].nr=a;
  return;
}


void rueckkehr(unsigned short a)
{
  unsigned short h1;

  h1=id_suchen(RAFFINERIE,einheiten[a].ID,einheiten[a].gesinnung);
  if(h1 && einheiten[a].ypos==(geb[h1].ypos+3) && (abs(einheiten[a].xpos-geb[h1].xpos)+1)<2)
  {
    einheiten[a].status|=LOESCHEN;
    einheiten[a].status|=AUSRICHTUNG;
    einheiten[a].ausrziel=4;
    return;
  }
  if(h1)
  {
    bewegung(a,geb[h1].xpos+1,geb[h1].ypos+2,TRUE); /* unten Mitte der Raff. */
    return;
  }
  einheiten[a].status=0;
  return;
}

void einheit_entfernen(unsigned short nr)
{
  unsigned short laenge=lleinh, i, p, q;
  /*unsigned short off=0;*/
  /*short nx=einheiten[nr].nochschrx,ny=einheiten[nr].nochschry;*/

/*  DBprnt(("einheit entfernen: %i \n", nr)); */
/*  DBprnt(("    ListenlÑnge Einheiten vorher: %i \n", lleinh)); */

  if(netmode!=E_INIT)   /* Bei Netzwerkinitialisierung nicht n.z. */
  {
   if(ak_art==2)
   {
     for(i=1; i<=ak_einh[0]; i++)
       if(ak_einh[i]==nr) 
          {ak_einh[i]=ak_einh[ak_einh[0]]; ak_einh[0]--; ak_nr=0;}
     if(ak_einh[0]==0) ak_art=0;
     rdr_infobar();  /*NEW*/ /* Neue Routine zum Neuzeichnen der Informationszeile */
   }
   drawoffscr(einheiten[nr].xpos-1,einheiten[nr].ypos-1,3,3);  /* nîtig wegen Geschossen */
   drawscreen(einheiten[nr].xpos-1,einheiten[nr].ypos-1,3,3); /*NEW*/ /* Neue Routine zum Neuzeichnen des Spielfeldes an bestimmten Koordinaten */
  }
  if(einheiten[nr].art!=BEKEHRER && einheiten[nr].art<20) playsample(S_KAPUTT);
  if( !(einheiten[nr].gesinnung) && (einheiten[nr].art<20) && (einheiten[nr].art!=BEKEHRER))
     playsample(S_EINH_VERLOREN);
  if(einheiten[nr].art<20 || einheiten[nr].art==255)  /*wg netzwerk-init. */
  {
    if(einheiten[nr].gesinnung) einh_verl[1]++; else einh_verl[0]++;
    if(!(einheiten[nr].status&K_FREIGABE_A))
    {
      sfeld[einheiten[nr].xpos][einheiten[nr].ypos].begehbar=1;
      sfeld[einheiten[nr].xpos][einheiten[nr].ypos].befahrbar=1;
      sfeld[einheiten[nr].xpos][einheiten[nr].ypos].besetzt=0;
      sfeld[einheiten[nr].xpos][einheiten[nr].ypos].nr=0;
    }
    if(einheiten[nr].status&BEWEG && !(einheiten[nr].status&K_FREIGABE_N))
    {
        p=einheiten[nr].neuxpos;
        q=einheiten[nr].neuypos;
        sfeld[p][q].begehbar=1;
        sfeld[p][q].befahrbar=1;
        sfeld[p][q].besetzt=0;
        sfeld[p][q].nr=0;
    }
    for(p=einheiten[nr].xpos-1;p<einheiten[nr].xpos+2;p++)    /* zur Sicherheit ;) */
     for(q=einheiten[nr].ypos-1;q<einheiten[nr].ypos+2;q++)
       if(sfeld[p][q].besetzt && sfeld[p][q].nr==nr)
       {
        sfeld[p][q].begehbar=1;
        sfeld[p][q].befahrbar=1;
        sfeld[p][q].besetzt=0;
        sfeld[p][q].nr=0;
       }
  }
  if(einheiten[nr].gesinnung && einheiten[nr].verbund)
  {
    for(i=1; i<=compeinh[einheiten[nr].verbund].anz_in_verb; i++)
    {
      if(compeinh[einheiten[nr].verbund].nr[i]==nr)
      {
        if(i!=compeinh[einheiten[nr].verbund].anz_in_verb)
        {
          compeinh[einheiten[nr].verbund].nr[i]=compeinh[einheiten[nr].verbund].nr[compeinh[einheiten[nr].verbund].anz_in_verb];
        }
        compeinh[einheiten[nr].verbund].nr[compeinh[einheiten[nr].verbund].anz_in_verb]=0;
        compeinh[einheiten[nr].verbund].anz_in_verb--;
        if(compeinh[einheiten[nr].verbund].anz_in_verb==0)
        {
          compeinh[einheiten[nr].verbund].status=0;
          compeinh[einheiten[nr].verbund].nr[1]=0;
        }
      }
    }
  }

  if(ak_einh[0])
   for(i=1;i<=ak_einh[0];i++)
   {
     if(nr==ak_einh[i])
     { 
       ak_einh[i]=ak_einh[ak_einh[0]];
       ak_einh[0]--;
       if(!ak_einh[0]) ak_art=0;
     }
   }
  for(p=0; p<=4; p++)
   for(q=1; q<=groups[p][0]; q++)
     if(groups[p][q]==nr)
     {
       groups[p][q]=groups[p][0];
       groups[p][0]--;
     }
  if(nr!=laenge)
  {
    einheiten[nr]=einheiten[laenge];
    for(p=1; p<=ak_einh[0]; p++)  if(ak_einh[p]==laenge) ak_einh[p]=nr;
    if(!einheiten[laenge].gesinnung)
      for(p=0;p<=4;p++)
        for(q=1;q<=groups[p][0];q++)
          if(groups[p][q]==laenge) groups[p][q]=nr;
    if(einheiten[nr].art<20)
    {
      sfeld[einheiten[nr].xpos][einheiten[nr].ypos].nr=nr;  /* noch auf begehbar achten! */
      if(einheiten[nr].status&BEWEG)
      {
        sfeld[einheiten[nr].neuxpos][einheiten[nr].neuypos].nr=nr;
      }
    }
    if(einheiten[laenge].gesinnung && einheiten[laenge].verbund)
    {
      for(i=1;i<=compeinh[einheiten[laenge].verbund].anz_in_verb;i++)
      {
        if(compeinh[einheiten[laenge].verbund].nr[i]==laenge)
          compeinh[einheiten[laenge].verbund].nr[i]=nr;
      }
    }
    for(i=1;i<laenge;i++)
    {
      if(einheiten[i].status&ANGR && einheiten[i].zielobj==laenge && einheiten[i].zielart)
        einheiten[i].zielobj=nr;
      if(einheiten[i].art>19 && einheiten[i].xpospatr && einheiten[i].wie_weit==laenge)
        einheiten[i].wie_weit=nr;
    }
    for(i=1;i<=llgeb;i++)
    {
      if(geb[i].status&ANGRIFF && geb[i].zielnr==laenge)
        geb[i].zielnr=nr;
    }
  }
  einheiten[laenge].zustand=0;
  lleinh--;

  return;
}


void flugbahn_berechnen(unsigned short l)
{
  unsigned int xk=einheiten[l].xkoor,yk=einheiten[l].ykoor,
               xz=einheiten[l].xziel,yz=einheiten[l].yziel;

  if (abs(xk-xz)> abs(yk-yz))
   {
      if(yz-yk)    /* bei keinem Unterschied keine Division!!! */
      {
         einheiten[l].nochschry=2;
         if (yk>yz) einheiten[l].nochschry*=-1;
         einheiten[l].nochschrx=(abs(xz-xk)<<1)/abs(yz-yk);
         if (xk>xz) einheiten[l].nochschrx*=-1;
         if(abs(xz-xk) % abs(yz-yk))
         einheiten[l].status|=NOCHM_BERE; else einheiten[l].status&=~NOCHM_BERE;
      }
      else
      {
        einheiten[l].nochschry=0;
        if(xz>xk)einheiten[l].nochschrx=2; else einheiten[l].nochschrx=-2;
      }
   }
   else
   {
      if(xz-xk)
      {
        einheiten[l].nochschrx=2;
        if (xk>xz) einheiten[l].nochschrx*=-1;
        einheiten[l].nochschry=(abs(yz-yk)<<1)/abs(xz-xk);
        if(abs(yz-yk) % abs(xz-xk))
          einheiten[l].status|=NOCHM_BERE; else einheiten[l].status&=~NOCHM_BERE;
        if (yk>yz) einheiten[l].nochschry*=-1;
      }
      else
      {
        einheiten[l].nochschrx=0;
        if(yz>yk) einheiten[l].nochschry=2; else einheiten[l].nochschry=-2;
      }
   }
   return;
}


unsigned short einheit_initialisieren(unsigned short typ,unsigned short auftrag,unsigned short von_wem)
{
 /* von_wem: 1: Einheit=>Geschoss   0: GebÑude=>Einheit   2: GeschÅtz=>Geschoss*/
 unsigned short l=lleinh+1;
 short x,y;
 unsigned short rweite;
 /* static unsigned int i=0; */

 /* i++; */
/* DBprnt(("Einheit initialisieren: %i \n",l));*/
/* DBprnt(("    Listenlaenge vorher: %i \n",lleinh)); */
Dprintf(("Einheit typ=%i\n",typ));

 switch(von_wem)
 {
   case 0:        /* von Gebaeude   => Einheit initialisieren */
     y=geb[auftrag].ypos+gebaeude_typ[geb[auftrag].art].groesse;
     x=geb[auftrag].xpos-2;
     if(x>253) x=0;
     do                     /* Platz fÅr Einheit am unteren Rand des Geb. suchen */
     {
       x++;           /* Hier noch berÅcksichtigen, falls kein Platz gefunden */
     }
     while(    x<=geb[auftrag].xpos+gebaeude_typ[geb[auftrag].art].groesse
            && sfeld[x][y].besetzt && !sfeld[x][y].begehbar);
     if(x==geb[auftrag].xpos+gebaeude_typ[geb[auftrag].art].groesse+1)
     {
       bewegung(nummer_ermitteln(geb[auftrag].xpos-1,y,1),geb[auftrag].xpos-1,y-2,1);
       return(0);
     }
     set_einheit(typ, x, y, geb[auftrag].gesinnung,0);
     einheiten[l].ID=geb[auftrag].ID;
     sfeld[x][y].besetzt=1;
     sfeld[x][y].begehbar=0;
     sfeld[x][y].gesinnung=geb[auftrag].gesinnung;
     sfeld[x][y].besetzertyp=1;
     sfeld[x][y].befahrbar=einheit_typ[typ].befahrbar;
     /* sfeld[x][y].nr=l;           siehe set_einheit */
     if(geb[auftrag].gesinnung==0)
     {
        normalize_popups(auftrag);
        playsample(S_EINH_BEREIT);
     }
     else
       if(typ!=SAMMLER && !netflag) einheit_in_verbund(l);
     einheiten[l].altxpos=einheiten[l].neuxpos=einheiten[l].xpos;
     einheiten[l].altypos=einheiten[l].neuypos=einheiten[l].ypos;
/*     einheiten[l].status|=BEWEG_ABGE;  */                 
     rweite=einheit_typ[einheiten[l].art].reichweite;
     if(geb[auftrag].gesinnung==0)
      for(x=(signed)(einheiten[l].xpos-rweite);x<=(signed)(einheiten[l].xpos+rweite);x++)
      {
       if(x<0) continue;
       if(x>127) continue;
       for(y=(signed)(einheiten[l].ypos-rweite);y<=(signed)(einheiten[l].ypos+rweite);y++)
       {
         if(y<0) continue;
         if(y>127) continue;
         sfeld[x][y].erforscht=1;
       }
      }
     drawoffscr(einheiten[l].xpos-rweite,einheiten[l].ypos-rweite,rweite*2,rweite*2);
     if(screen_opened)
       drawscreen(einheiten[l].xpos-rweite,einheiten[l].ypos-rweite,rweite*2,rweite*2);
     if(typ==SAMMLER) saft_suchen(l);
     break;

   case 1:
     einheiten[l].wie_weit=auftrag;
     set_einheit(typ, einheiten[auftrag].xpos, einheiten[auftrag].ypos,einheiten[auftrag].gesinnung, 1);
     einheiten[l].zielobj=einheiten[auftrag].zielobj;
     einheiten[l].zielart=einheiten[auftrag].zielart;
     einheiten[l].xziel=(einheiten[auftrag].xziel<<4);    /* Koordinaten */
     einheiten[l].yziel=(einheiten[auftrag].yziel<<4);
     einheiten[l].ausrichtung=einheiten[auftrag].ausrichtung;
     if(einheiten[auftrag].gesinnung)
       einheiten[l].verbund=/* einheiten[auftrag].verbund */ 0;
     else
       einheiten[l].verbund=0;
     einheiten[l].xpospatr=1;   /* von Einheit initialisiert */
     flugbahn_berechnen(l);
     break;

   case 2:
     set_einheit(typ, geb[auftrag].xpos, geb[auftrag].ypos, geb[auftrag].gesinnung, 1);
     einheiten[l].zielobj=geb[auftrag].zielnr;
     einheiten[l].zielart=1;
     einheiten[l].xziel=(einheiten[geb[auftrag].zielnr].xpos);    /* Koordinaten s.u.*/
     einheiten[l].yziel=(einheiten[geb[auftrag].zielnr].ypos);
     einheiten[l+1].xpos=geb[auftrag].xpos;        /* Pseudo-Einheit */
     einheiten[l+1].ypos=geb[auftrag].ypos;        /* um Ausrichtung zu erh. */
     einheiten[l+1].xziel=einheiten[l].xziel;
     einheiten[l+1].yziel=einheiten[l].yziel;
     einheiten[l].xziel<<=4;
     einheiten[l].yziel<<=4;
     einheiten[l].verbund=0;
     ausrichten_fuer_schiessen(l+1,0);
     einheiten[l].ausrichtung=einheiten[l+1].ausrziel;
     einheiten[l].wie_weit=auftrag;
     einheiten[l].xpospatr=0;    /* von GebÑude initialisiert */
     flugbahn_berechnen(l);
     break;
 }
/* DBprnt(("    Listenlaenge nachher: %i \n",lleinh)); */

 return(1);
}

void angriffe_abschalten(unsigned short ziel,unsigned short typ)
{
  /*signed short x, y;*/
  /*unsigned short a, b;*/
  unsigned short laenge=lleinh+1,i;

  for(i=1;i<laenge;i++)
  {
    if(einheiten[i].zielobj==ziel && einheiten[i].zielart==typ)
    {
      if(einheiten[i].status&BEWEG && einheiten[i].art<20)
      {
    /*    x=einheiten[i].nochschrx;
        y=einheiten[i].nochschry;
        if(einheiten[i].nochschrx<-1 || einheiten[i].nochschrx>1) x=0;
        if(einheiten[i].nochschry<-1 || einheiten[i].nochschry>1) y=0;
        a=(unsigned)(einheiten[i].xpos+x);
        b=(unsigned)(einheiten[i].ypos+y);
        einheiten[i].xziel=a;
        einheiten[i].yziel=b;  */
        einheiten[i].xziel=einheiten[i].neuxpos;
        einheiten[i].yziel=einheiten[i].neuypos;
      }
      if(einheiten[i].status&(ANGR|NOCH_ANGR))
      {
         einheiten[i].status&=~ANGR;
         einheiten[i].status&=~NOCH_ANGR;
         einheiten[i].status|=WACHEN;
         if(einheiten[i].gesinnung)
           compeinh[einheiten[i].verbund].target_destroyed=1;
      }
      if(einheiten[i].gesinnung && compeinh[einheiten[i].verbund].status&FIGHTING)
      {
        verbund_aufbrechen(einheiten[i].verbund);      /* Strategie Ñndert sich hier :-( */
        compeinh[einheiten[i].verbund].status&=~FIGHTING;
      }
    }
  }
  if(typ)
  {
   laenge=llgeb+1;
   for(i=1;i<laenge;i++)
   {
     if(geb[i].zielnr==ziel) if(geb[i].status&ANGRIFF) {geb[i].status|=WACHE;geb[i].status&=~ANGRIFF;}
   }
  }
}

void schiessen(unsigned short nr)
{
  unsigned short /* z,*/ a,za,ziel;
  signed int z;

  a=einheiten[nr].art;
  switch(a)
  {
  case TRUPPE :
  case TRUPPEN:
  case QUAD   :
    playsample(S_MG);
    za=einheiten[nr].zielart;
    ziel=einheiten[nr].zielobj;
    if(za)
    {
      einheiten[ziel].zustand-=einheit_typ[a].feuerkraft;
      z=einheiten[ziel].zustand;
      if(einheiten[ziel].gesinnung && einheiten[ziel].zielobj!=nr )
         einheit_wird_angegriffen(ziel,nr);
    }
    else
    {
      geb[ziel].zustand-=einheit_typ[a].feuerkraft;
      z=geb[ziel].zustand;
    }
    if(ak_nr==ziel)
      rdr_health();  /*NEW*/ /* Funktion zum Neuzeichnen des Energiebalkens */
    if(z<1)
    {
      angriffe_abschalten(ziel,za);
      if(za)
        einheit_entfernen(ziel);
      else
      {
        gebaeude_entfernen(ziel);
        if(einheiten[nr].gesinnung && geb[ziel].gesinnung==0)
            compeinh[einheiten[nr].verbund].target_destroyed=1;
      }
    }
    break;
  case PANZER_L:
  case PANZER_S:
  case GRENADIER:
    einheit_initialisieren(GRANATE,nr,1);
    playsample(S_GRANATE);
    break;
  case RAKETENWERFER:
  case BAZOOKA:
    einheit_initialisieren(RAKETE,nr,1);
    break;
  case LASERFAHRZEUG:
    einheit_initialisieren(LASER,nr,1);
    break;
  case INFRATANK:
    einheit_initialisieren(SCHALL,nr,1);
    break;
  case FLAMMENWERFER:
  case FLAMMENTANK:
    einheit_initialisieren(FLAMME,nr,1);
  }
  return;
}

void ausrichten_fuer_schiessen(unsigned short nu,unsigned short wann)
{
  signed short a,b;

  a=einheiten[nu].xziel-einheiten[nu].xpos;
  b=einheiten[nu].yziel-einheiten[nu].ypos;
/*  DBprnt(("a ist %i, b ist %i \n ",a,b)); */
  if(a<0) einheiten[nu].nochschrx=-1;
  if(a>0) einheiten[nu].nochschrx=1;
  if(a==0) einheiten[nu].nochschrx=0;
  if(b<0) einheiten[nu].nochschry=-1;
  if(b>0) einheiten[nu].nochschry=1;
  if(b==0) einheiten[nu].nochschry=0;
  ausrichten(nu,wann);
  return;
}


void angriff(unsigned short nr, unsigned short zielx,unsigned short ziely,short wann)
{
  unsigned short zielnr;

  if(einheiten[nr].status&BEWEG)
  {
    einheiten[nr].status|=NOCH_ANGR;
    einheiten[nr].xziel=zielx;
    einheiten[nr].yziel=ziely;
    if(sfeld[zielx][ziely].besetzertyp)
    {
      einheiten[nr].zielart=1;
      einheiten[nr].zielobj=nummer_ermitteln(zielx,ziely,1);
    }
    else
    {
      einheiten[nr].zielart=0;
      einheiten[nr].zielobj=nummer_ermitteln(zielx,ziely,0);
    }
    return;
  }
  einheiten[nr].status&=~NOCH_ANGR;
  einheiten[nr].wie_weit=0;
  einheiten[nr].xziel=zielx;
  einheiten[nr].yziel=ziely;
  zielnr=nummer_ermitteln(zielx,ziely,1);
  einheiten[nr].zielart=1;                  /* zielart: 1=Einh */
  if (zielnr==0)                                      /*  0=GEB  */
  {
    zielnr=nummer_ermitteln(zielx,ziely,0);
    einheiten[nr].zielart=0;
  }
  else if(einheiten[zielnr].status&BEWEG) einheiten[nr].status|=ZIEL_IN_BEW;
  einheiten[nr].zielobj=zielnr;
  einheiten[nr].status|=ANGR;
 if(!wann)   /* Bei wachen, dann sowieso in Reichweite */
  {
    ausrichten_fuer_schiessen(nr,1);
  }
  else
  {
    einheiten[nr].status&=~WACHEN; /*evtl. wachen schon ausgeschaltet, wenn schon auf Angriff geklickt */
    if(!in_reichweite(nr,zielx,ziely))
    {
      einheiten[nr].status|=NOCH_ANGR;
      bewegung(nr,zielx,ziely,1);
     /* einheiten[nr].status|=NOCH_ANGR; */
    }
  }
  if(einheiten[nr].art==BEKEHRER && einheiten[nr].zielart==1)
  {
    einheiten[nr].status&=~ANGR;         /* Nur bei Gebaeude aktiv werden */
    einheiten[nr].status&=~BEWEG;
  }
  return;
}


void neu_suchen(unsigned short a, unsigned short wann)
{
  unsigned short i=einheiten[a].ausrziel,j=i,x,y,z,hilf=0;
  /*unsigned short hilf=0;*/
  x=einheiten[a].xpos;
  y=einheiten[a].ypos;                  /* wann: 1 befahrbar suchen */
  einheiten[a].status|=NOCHM_BERE;      /*     <>1 begehbar suchen  */
  if((unsigned)(x+ausrzahl[i].x)==einheiten[a].xziel
     && (unsigned)(y+ausrzahl[i].y)==einheiten[a].yziel)
   if(einheiten[a].art!=SAMMLER && !(einheiten[a].status&SAMMELN) )
    return;
 do
 {
  if(wann)
  {
    do
    {
     i--;
     j++;
     if(i>254) i=7;
     if(j>7)   j=0;
    }
    while(   !sfeld[x+ausrzahl[i].x][y+ausrzahl[i].y].befahrbar
          && !sfeld[x+ausrzahl[j].x][y+ausrzahl[j].y].befahrbar
          && i!=j);
  }
  else
  {
   do
    {
     i--;
     j++;
     if(i>254) i=7;
     if(j>7)   j=0;
    }
    while(   !sfeld[x+ausrzahl[i].x][y+ausrzahl[i].y].begehbar
          && !sfeld[x+ausrzahl[j].x][y+ausrzahl[j].y].begehbar
          && i!=j);
  }
  if(i==j)
  {
    einheiten[a].status&=~BEWEG;  /* kein Weg gefunden */
    einheiten[a].status&=~NOCHM_BERE;
    return;
  }
 
   if(wann) if(sfeld[x+ausrzahl[j].x][y+ausrzahl[j].y].befahrbar /* && hilf==j */) z=j; else z=i;
   if(wann && x+ausrzahl[z].x==einheiten[a].altxpos && y+ausrzahl[z].y==einheiten[a].altypos)
     if( !(einheiten[a].status&SAMMELN) )   
       if(sfeld[x+ausrzahl[i].x][y+ausrzahl[z].y].befahrbar) z=i;

   if(!wann) if(sfeld[x+ausrzahl[j].x][y+ausrzahl[j].y].begehbar) z=j; else z=i;
   if(!wann && x+ausrzahl[z].x==einheiten[a].altxpos && y+ausrzahl[z].y==einheiten[a].altypos)
     if(sfeld[x+ausrzahl[i].x][y+ausrzahl[z].y].begehbar) z=i;

   hilf=1;
   if(wann) /* damit panzer nicht eigene Fuûtruppen Åberrollen */
   if(sfeld[x+ausrzahl[z].x][y+ausrzahl[z].y].besetzt)
     if(sfeld[x+ausrzahl[z].x][y+ausrzahl[z].y].gesinnung==einheiten[a].gesinnung)
     {
      if(z==j) z=i; else z=j;
      if(sfeld[x+ausrzahl[z].x][y+ausrzahl[z].y].besetzt)
        if(sfeld[x+ausrzahl[z].x][y+ausrzahl[z].y].gesinnung==einheiten[a].gesinnung)
          hilf=0;
     }
  }while(   (unsigned)(x+ausrzahl[z].x)==einheiten[a].altxpos
         && (unsigned)(y+ausrzahl[z].y)==einheiten[a].altypos
         || !hilf);
  einheiten[a].ausrziel=z;
  einheiten[a].nochschrx=ausrzahl[z].x;
  einheiten[a].nochschry=ausrzahl[z].y;
  return;
}


unsigned short in_reichweite(unsigned short aktive, unsigned short zielx, unsigned short ziely)
{
  unsigned short rweite;
  signed short x,y;

  x=(signed)zielx-(signed)einheiten[aktive].xpos;
  y=(signed)ziely-(signed)einheiten[aktive].ypos;
 /* DBprnt(("x ist %i, y ist %i \n",x,y)); */
  rweite=einheit_typ[einheiten[aktive].art].reichweite;
  if((unsigned)abs(x)<=rweite && (unsigned)abs(y)<=rweite) return(1); else return(0);
}


void ausrichten(unsigned short nr,unsigned short wann)
{
  signed short x,y,i=8;
  x=einheiten[nr].nochschrx;
  y=einheiten[nr].nochschry;
  if(x<-1 || x>1) x=0;
  if(y<-1 || y>1) y=0;
  if(wann) einheiten[nr].wie_weit=0;
  einheiten[nr].status |= AUSRICHTUNG;
  do
  {
    i--;
  }
  while(!(ausrzahl[i].x==x && ausrzahl[i].y==y));
  einheiten[nr].ausrziel=i;
  return;
}


void y_switchen(signed short wert,unsigned short nr)
{
  switch(wert)
  {
  case -1 : einheiten[nr].ykoor -= einheiten[nr].wie_weit>>4;
            break;
  case 1  : einheiten[nr].ykoor += einheiten[nr].wie_weit>>4;
            break;
  }
  return;
}

void y_berechnen(unsigned short nr)
{
 signed short a=einheiten[nr].nochschry;
 switch(a)
 {
  case -1 : einheiten[nr].ypos -= 1;
            break;
  case  0 : break;
  case  1 : einheiten[nr].ypos += 1;
            break;
  default : if (a<-1) einheiten[nr].nochschry++;
              else  einheiten[nr].nochschry--;
            break;
 }
 return;
}


void abarbeiten(void)
{
 unsigned short a,xp,yp,art,g,zspunkte_akt=0;
 unsigned short radar=FALSE,rweite;
 signed int z,z2;
 static int count=0,zspunkte=0,ang_sample=0,
            en_talked=TRUE,an_talked=0;
 unsigned int s;
 EINHEIT *einh;
 GEBAEUDE *gebs;
 static unsigned short stat=(ANGR+PATROLIE+LOESCHEN+SAMMELN+BEWEG);
/*
 counter++;
 if(counter>10)
 {
   a= rand() & 0x00FE + 1;
   if(einheiten[a].status==WACHEN) einheiten[a].status|=AUSRICHTUNG;
   einheiten[a].ausrziel=rand() & 7;
   einheiten[a].wie_weit=0;
   counter=0;
 }
*/
 energie=0;
 count++;
 if(count==33) count=1;

 for(a=0;a<lleinh;a+=32)
 {
   if(a+count>lleinh) continue;
   einh=&einheiten[a+count];
   s=einh->status;
   art=einh->art;
   if(s & WACHEN)
     if(!(s&stat))
     {
       rweite=einheit_typ[art].reichweite;
       xp=einh->xpos;
       yp=einh->ypos;
       for(z=(signed)(xp-rweite);z<=(signed)(xp+rweite);z++)
       {
         if(z<0) continue;
         if(z>127) continue;
         for(z2=(signed)(yp-rweite);z2<=(signed)(yp+rweite);z2++)
         {
           if(z2<0) continue;
           if(z2>127) continue;
           if(sfeld[z][z2].besetzt==1 && sfeld[z][z2].gesinnung!=einh->gesinnung)
           {angriff(a+count,z,z2,0); z=(signed)(xp+rweite);}
         }
       }
    }
  }

 for(a=1;a<=lleinh;a++)      /* Einheiten abarbeiten */
 {
   work_list_einh(a,count);
 }

                     /***** Gebaeude bearbeiten *****/

  for(a=1;a<=llgeb;a++)
  {
    work_list_geb(a,count);

   g=geb[a].gesinnung;
   art=geb[a].art;
   gebs=&geb[a];

   if(art==RADAR && !g) radar=TRUE;
   if(!((count-1)&7))
   {
     if(g && !netflag)
     {
       if(gebaeude_typ[art].zustandspunkte!=gebs->zustand)
          gebs->status|=REPE;   /* GebÑude kaputt, dann Reperatur */
     }

     if(!g)
     {
       if(gebs->art!=KRAFTWERK)
         energie+=gebaeude_typ[art].energiebedarf;
        else
         energie += (int)((long)gebaeude_typ[art].energiebedarf*gebs->zustand/gebaeude_typ[art].zustandspunkte);
       zspunkte_akt+=gebs->zustand;
     }
   }
   else {energie=saft; zspunkte_akt=zspunkte; }
  }

 if(ang_sample)
 {
   an_talked++;
   if(an_talked==1000) {an_talked=0; ang_sample=0; }
 }  /* alle 1000 timer erneut sprechen, wenn nîtig */
   if(zspunkte_akt<zspunkte && !ang_sample)
   {
      playsample(S_ANGRIFF);
      zspunkte=zspunkte_akt;
      ang_sample=1;
   }
   if(energie<=0 && radar)
   {
    if(!radarflag)
     {
      radarflag=TRUE;
      playsample(S_RADAR_AKTIV);
      drawmap(0,0, r_width, r_height);  /* Karte im Map-Offscreen neu zeichnen */
      rdr_map(0,0, r_width, r_height);  /*NEW*/ /* Funktion zum Kopieren der Offscreenkarte ins Fenster */
     }
   }
   else
   {
    if(radarflag)
     {
      radarflag=FALSE;
      playsample(S_RADAR_DEAKTIV);
      drawmap(0, 0, r_width, r_height);
      rdr_map(0,0, r_width, r_height);  /*NEW*/
     }
   }

  if (energie>=-10 && !en_talked) {playsample(S_LOW_ENERGY);en_talked=1;}
  if (energie<-10) en_talked=0;
  if(saft!=energie) aktualize_energie();
  saft=energie;

  return;
}

signed short getmax(signed short a, signed short b)
{
 if (abs(a)>=abs(b)) return(a);
 return(b);
}

void bewegung(unsigned short nr, unsigned short xz, unsigned short yz,short res)
{
 short a,b,x,y;
 unsigned short neuer_status=BEWEG,art=einheiten[nr].art;

 if (einheiten[nr].status&BEWEG)  /* Wenn schon Bewegung, dann Zug zu Ende bringen */
 {
   einheiten[nr].status|=NOCHM_BERE;
   einheiten[nr].xziel=xz;
   einheiten[nr].yziel=yz;
   return;
 }
 else
 {
 if(!(einheiten[nr].status&NOCHM_BERE) && einheiten[nr].status&ANGR)
 {
        einheiten[nr].status&=~ANGR; /* wenn angriff diesen abschalten */
     /*   einheiten[nr].status|=NOCH_ANGR; */
 }
 /* if(einheiten[nr].status&NOCH_ANGR) einheiten[nr].status|=ANGR; */
 a=einheiten[nr].xpos-xz;
 b=einheiten[nr].ypos-yz;
 einheiten[nr].xziel=xz;
 einheiten[nr].yziel=yz;
 if (getmax(a,b)==a)      /* je nach dem, wo am meisten Unterschied*/
 {                             /* jeden Zug in diese Richtung fahren */
   einheiten[nr].schrittx=1;
   einheiten[nr].nochschrx=1;
   if (b)
   {
     einheiten[nr].schritty=abs(a/b);
     einheiten[nr].nochschry=einheiten[nr].schritty;
/* if(einheiten[nr].art==QUAD) DBprnt(("a ist %i, b ist %i, a%%b ist %i \n",a,b,a%b)); */
     if (a%b)
     {
      neuer_status += NOCHM_BERE;   /* geht die Berechnung nicht auf */
     }                                             /* wird im naÑchsten Planquadrat nochmal berechnet */
     else
     {
        einheiten[nr].status&=~NOCHM_BERE;
     }
   }
   else
   {
     einheiten[nr].schritty=0;
     einheiten[nr].nochschry=0;
   }
 }
 else
 {
   einheiten[nr].schritty=1;
   einheiten[nr].nochschry=1;
   if (a)
   {
     einheiten[nr].schrittx=abs(b/a);
     einheiten[nr].nochschrx=einheiten[nr].schrittx;
/*  if(einheiten[nr].art==QUAD) DBprnt(("a ist %i, b ist %i, b%%a ist %i \n",a,b,b%a)); */
     if(b%a)
     {
       neuer_status += NOCHM_BERE;
     }
     else
     {
        einheiten[nr].status&=~NOCHM_BERE;
     }
   }
   else
   {
     einheiten[nr].schrittx=0;
     einheiten[nr].nochschrx=0;
   }
 }
 if (a>0)                         /* Bei Richtung nach links sind */
 {                                /* Schritte negativ */
   einheiten[nr].schrittx *= (-1);
   einheiten[nr].nochschrx = einheiten[nr].schrittx;
 }
 if (b>0)
 {
   einheiten[nr].schritty *=(-1);                  /* Bei Richtung nach oben ebenfalls */
   einheiten[nr].nochschry=einheiten[nr].schritty;
 }
 einheiten[nr].status |= neuer_status;
 ausrichten(nr,1);
 x=einheiten[nr].nochschrx;
 y=einheiten[nr].nochschry;
 if(einheiten[nr].nochschrx<-1 || einheiten[nr].nochschrx>1) x=0;
 if(einheiten[nr].nochschry<-1 || einheiten[nr].nochschry>1) y=0;
 a=(unsigned)(einheiten[nr].xpos+x);
 b=(unsigned)(einheiten[nr].ypos+y);
 if(a==xz && b==yz && sfeld[a][b].besetzt)
 {
   einheiten[nr].status&=~BEWEG;
   einheiten[nr].status&=~NOCHM_BERE;
   res=0;
   return;
 }
 else
 {
   einheiten[nr].neuxpos=a;
   einheiten[nr].neuypos=b;
 }
 /* if(a!=einheiten[nr].xziel && b!=einheiten[nr].yziel) */
  if(art >9) {
               if(!sfeld[a][b].besetzt)
               {
                 if(!sfeld[a][b].befahrbar) neu_suchen(nr,1);
               }
               else
               {
                 if(sfeld[a][b].gesinnung==einheiten[nr].gesinnung)
                   neu_suchen(nr,1);
                 else
                   if(!sfeld[a][b].befahrbar) neu_suchen(nr,1);
                   else einheiten[nr].status|=UEBERROLLEN;   /* wenn Feld besetzt von gegn. Einheit, dann Åberrollen, wenn begehbar */
               }
             }
    else
             {
               if(!sfeld[a][b].begehbar) neu_suchen(nr,0);
             }
 if(res) feld_reservieren(nr);
 if(art==SAMMLER) einheiten[nr].status&=~LOESCHEN;
 ausrichten(nr,1);
/* if(einheiten[nr].status&UEBERROLLEN) */
/*   setze_freigaben(nr); */
 return;
 }
}

unsigned short nummer_ermitteln_fein(unsigned int xz, unsigned int yz)
{
  unsigned short x;
  for(x=1;x<=lleinh;x++)
  {
    if(xz-einheiten[x].xkoor<16)
        if(yz-einheiten[x].ykoor<16)
        {
/*          DBprnt(("x: %i \n",x)); */
/*          DBprnt(("xz,yz: %i,%i \n",xz,yz)); */
/*          DBprnt(("exz,eyz: %i,%i \n",einheiten[x].xkoor,einheiten[x].ykoor)); */
           return(x);
        }
  }
  return(0);
}

unsigned short nummer_ermitteln2(unsigned short xz, unsigned short yz)
{
 unsigned short x;

 for(x=1;x<=lleinh;x++)
 {
   if(xz==einheiten[x].xpos && yz==einheiten[x].ypos)
   {
     return(x);
   }
   else
   {
     if(einheiten[x].status&BEWEG)
        if(xz==einheiten[x].neuxpos && yz==einheiten[x].neuypos)
          return(x);
   }
 }
 return(0);
}

unsigned short nummer_ermitteln(unsigned short xz, unsigned short yz, unsigned short z)
{
 if (z==1)                      /* z:1=E, <>1=G */
 {
   if(sfeld[xz][yz].besetzt && sfeld[xz][yz].besetzertyp==1)
     return(sfeld[xz][yz].nr);
 }
 else
 {
   if(sfeld[xz][yz].besetzt && sfeld[xz][yz].besetzertyp==0)
     return(sfeld[xz][yz].nr);
 }
 return(0);
}

int platz_testen(unsigned short art,unsigned short x, unsigned short y, unsigned short ges)
{
 /*int platz_flag=TRUE;*/
 unsigned short a,b;

 for(a=x;a<x+gebaeude_typ[art].groesse;a++)
 {
   for(b=y;b<y+gebaeude_typ[art].groesse;b++)
   {
     if(!sfeld[a][b].begehbar || sfeld[a][b].besetzt)
        return(0);
   }
 }
 for(a=x-2;a<x+gebaeude_typ[art].groesse+2;a++)
 {
   for(b=y-2;b<y+gebaeude_typ[art].groesse+2;b++)
   {
     if(sfeld[a][b].besetzt && sfeld[a][b].gesinnung==ges && sfeld[a][b].besetzertyp==0)
        return(1);
   }
 }
 return(0);
}


void anwaehlen(unsigned short x,unsigned short y, unsigned short a, unsigned short b)
{
  playsample(S_CLICK1);
  if (!sfeld[x][y].besetzertyp) /* von GebÑude besetzt? */
  {
    ak_nr=a;            /* ja, dann Gebaeude wechseln */
    ak_art=1;
    return;
  }
  else         /* nein, dann Einheit aktiv */
  {
    ak_nr=b;
    ak_art=2;
    ak_einh[0]=1;
    ak_einh[1]=b;
    if(b>lleinh)
    {
      sfeld[x][y].besetzt=0;
      sfeld[x][y].nr=0;
      ak_nr=0; ak_art=0;
    }
    return;
  }
}

void geklickt(unsigned short aktive_nr, unsigned short aktive_art, unsigned int xkoor, unsigned int ykoor)
{
 unsigned short a=0,b=0,gesinnung=0,akt_ges=0,i,bes;
 /*unsigned short platz_flag=TRUE;*/
 unsigned short hilf,xziel,yziel;

 xziel=(xkoor>>4)+rwx;
 yziel=(ykoor>>4)+rwy;

 if(xziel>r_width) xziel=r_width;
 if(yziel>r_height) yziel=r_height;

 if(aktive_art<3)
   if(sfeld[xziel][yziel].besetzt)
   {
    if(sfeld[xziel][yziel].besetzertyp)
/*      b=nummer_ermitteln_fein(xkoor+(rwx<<4),ykoor+(rwy<<4)); */
      b=nummer_ermitteln(xziel,yziel,1);
    else
      a=nummer_ermitteln(xziel,yziel,0);     /* aktive_art:           */
    if(a) gesinnung=geb[a].gesinnung;
    if(b) gesinnung=einheiten[b].gesinnung; else if(!a) return;
   }
 switch (aktive_art)                              /*  0: nichts aktiv      */
 {                                                /*  1: GebÑude angewÑhlt */
  case 0: if(sfeld[xziel][yziel].erforscht)
          {
            if ( b == 0 )                         /*  2: Einheit angewÑhlt */
            {                                     /*  3: Geb. plazieren    */
              if ( a == 0 )
              {
                return;
              }
              ak_nr=a;
              ak_art=1;
              ak_einh[0]=0;
              playsample(S_CLICK1);
              return;
            }
            else
            {
              ak_nr=b;
              ak_art=2;
              ak_einh[0]=1;
              ak_einh[1]=b;
              if(einheiten[ak_nr].art==SAMMLER) sammler_inhalt(ak_nr);
              playsample(S_CLICK1);
              return;
            }
          }
          break;
  case 1 : akt_ges=geb[aktive_nr].gesinnung;
           if (sfeld[xziel][yziel].besetzt == 1 ) /* gewÑhltes Feld besetzt? */
           {
             if(gesinnung==akt_ges)    /* aus gleichem Haus? */
             {
               anwaehlen(xziel,yziel,a,b);
             }
             else       /* nein, dann feindliche */
             {
               if(!akt_ges) /* eigenes gebaeude aktiv? */
                 if (geb[aktive_nr].art==MG_TURM ||
                     geb[aktive_nr].art==RK_TURM ||
                     geb[aktive_nr].art==INFRATURM)
                  {
                      gebaeude_angriff(aktive_nr,xziel,yziel);
                      if(netflag) set_tm_data(10,aktive_nr,xziel,yziel,0,0);
                      playsample(S_CLICK2);
                      return;
                  }
               anwaehlen(xziel,yziel,a,b);
             }
           }
           break;

  case 2 : hilf=ak_einh[0];
           bes=sfeld[xziel][yziel].besetzt;
           for(i=1;i<=hilf;i++)
           {
           ak_nr=ak_einh[i];
           akt_ges=einheiten[ak_nr].gesinnung;
           if  ( bes )
           {
             if(gesinnung==akt_ges)
             {
              if(a)
               { 
               if (geb[a].art==RAFFINERIE && einheiten[ak_nr].art==SAMMLER)
                 if(!akt_ges)
                 {
                   einheiten[a].status&=~SAMMELN;
                   einheiten[a].status&=~STOP;
                   rueckkehr(ak_nr);
                   if(netflag) set_tm_data(11,ak_nr,0,0,0,0);
                   playsample(S_CLICK2);
              /*  return; */
                 }
               if(geb[a].art==WERKSTATT && !gesinnung)
               {
                 zur_reperatur(ak_nr,a);
                 if(netflag) set_tm_data(12,ak_nr,0,0,0,a);
                 playsample(S_CLICK2);
              /*   return; */
               }
               else
               {
                 anwaehlen(xziel,yziel,a,b);
               }
              }
              else   /* auf eigene Einheit geklickt */
              {
                if(kstate!=8)
                {
                  anwaehlen(xziel,yziel,a,b);
                  if(einheiten[ak_nr].art==SAMMLER) sammler_inhalt(ak_nr);
                }else
                {
                  if(sfeld[xziel][yziel].besetzertyp && !netflag)
                  {
                     einheit_selektiert(b);
                     if (ak_einh[0]) ak_art=2;
                     return;
                  }
                  else
                  { ak_nr=a; ak_art=1; ak_einh[0]=0; }
                }
              }
             }
             else         /* einheiten feindlich */
             {
               if(!akt_ges)  /* eigene aktiv? */
               {
                 if (einheiten[ak_nr].art != SAMMLER && einheiten[ak_nr].art!=BEKEHRER)
                 {
                   playsample(S_CLICK2);
                   angriff(ak_nr,xziel,yziel,1);
                   if(netflag) set_tm_data(2,ak_nr,xziel,yziel,1,0);
                 /*  return; */
                 }
                 else
                 {
                   playsample(S_CLICK2);
                   bewegung(ak_nr,xziel,yziel,TRUE);
                   if(netflag) set_tm_data(1,ak_nr,xziel,yziel,1,0);
                 /*  return; */
                 }
               }
               else    /* nein, dann wechseln */
               {
                 anwaehlen(xziel,yziel,a,b);
               }
             }
           }
           else   /* gewaehltes Feld nicht besetzt */
           {
            if(!akt_ges)  /* eigene aktiv */
            {
              if (   einheiten[ak_nr].art == SAMMLER
                   &&    sfeld[xziel][yziel].ertrag != 0 )
                       einheiten[ak_nr].status|=SAMMELN;
              playsample(S_CLICK2);
              bewegung(ak_nr,xziel,yziel,TRUE);
              if(netflag) set_tm_data(1,ak_nr,xziel,yziel,1,0);
              if(kstate&3 && einheiten[ak_nr].art!=SAMMLER)
              {
               einheiten[ak_nr].xpospatr=einheiten[ak_nr].xpos;
               einheiten[ak_nr].ypospatr=einheiten[ak_nr].ypos;
               einheiten[ak_nr].status|=PATROLIE;
               if(netflag) set_tm_data(13,ak_nr,xziel,yziel,1,0);
              }
              else einheiten[ak_nr].status&=~PATROLIE;
           /*   return; */
            }
            else return; /* bei feindl. tue nichts */
           }
           } /* for schleife */
           break;
  case 3 : setzen(xziel,yziel,0);
           if(netflag) set_tm_data(4,0,xziel,yziel,0,0);
           break;
  case 4 : a=nummer_ermitteln(xziel,yziel,0);
           reparieren(a,0);
           if(netflag) set_tm_data(6,a,0,0,0,0);
           break;
  case 5 : a=nummer_ermitteln(xziel,yziel,0);
           if(netflag) set_tm_data(5,a,0,0,0,0);
           verkaufen(a,0);
           geb_verl[0]--;
           break;
 }
 return;
}

