/**
 * STune - The battle for Aratis
 * me_kifkt.c : Functions for the artificial intelligence
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

#include "stunedef.h"
#include "stunmain.h"
#include "me_routi.h"
#include "me_kifkt.h"
#include "st_debug.h"
#include "units.h"


unsigned short anzahl_verbund=3;

unsigned int comp_bauspeed=2500;
unsigned int phase=DEFENSE1;

VERBUND compeinh[8];
STRATEGIE strat[3];
BASIS_PLATZ comp_basis, mensch_basis;


void ziel_suchen(unsigned short);


void einheit_wird_angegriffen(unsigned short i,unsigned short von_wem)
{
  unsigned short verb=einheiten[i].verbund, x=0, z;

 if(einheiten[i].art!=SAMMLER)
 {
   switch(compeinh[verb].status)
   {
     case ATTACK: 
       if(einheiten[von_wem].art>19) /* Geschoss */
         if(einheiten[von_wem].xpospatr)  /* von Einheit */
           angriff(i,einheiten[einheiten[von_wem].wie_weit].xpos,einheiten[einheiten[von_wem].wie_weit].ypos,1);
         else
           angriff(i,geb[einheiten[von_wem].wie_weit].xpos, geb[einheiten[von_wem].wie_weit].ypos,1);
       else
         angriff(i,einheiten[von_wem].xpos,einheiten[von_wem].ypos,1);
       break;  
 
     case MOVING:
       for(z=1;z<=compeinh[verb].anz_in_verb;z++)
        if(einheiten[von_wem].art>19)
          if(einheiten[von_wem].xpospatr)  /* von Einheit */
            angriff(i,einheiten[einheiten[von_wem].wie_weit].xpos,einheiten[einheiten[von_wem].wie_weit].ypos,1);
          else
            angriff(i,geb[einheiten[von_wem].wie_weit].xpos, geb[einheiten[von_wem].wie_weit].ypos,1);
        else
          angriff(compeinh[verb].nr[z],einheiten[von_wem].xpos,einheiten[von_wem].ypos,1);
        break;
  
     default:
       if(einheiten[von_wem].art>19) /* Geschoss */
         if(einheiten[von_wem].xpospatr)  /* von Einheit */
           angriff(i,einheiten[einheiten[von_wem].wie_weit].xpos,einheiten[einheiten[von_wem].wie_weit].ypos,1);
         else
           angriff(i,geb[einheiten[von_wem].wie_weit].xpos, geb[einheiten[von_wem].wie_weit].ypos,1);
       else
         angriff(i,einheiten[von_wem].xpos,einheiten[von_wem].ypos,1);
       break;  
   }   
   compeinh[verb].status|=FIGHTING;
 }
 else  /* Sammler */
 {
  for(z=1;z<=lleinh;z++)
  {
    if(einheiten[z].art==SAMMLER && einheiten[z].gesinnung) x++;
  }
  if(x<3)
   {
    i=id_suchen(FABRIK_GR,1,1);
    if(i)
    {
      if(geb[i].status&=BAUEN)
         if(geb[i].bauprodukt!=SAMMLER) knete[1]+=geb[i].wie_weit;
      else
         geb[i].status|=BAUEN;
      if(geb[i].bauprodukt!=SAMMLER) geb[i].wie_weit=0;
      geb[i].bauprodukt=SAMMLER;
    }
   }
  /* und noch sicherheitstrupp losschicken */
  if(compeinh[2].status==WAITING)
  {
    for(z=1;z<=compeinh[2].anz_in_verb;z++)
    {
      angriff(compeinh[2].nr[z], einheiten[von_wem].xpos, einheiten[von_wem].ypos, 1);
    }
  }
 }

 return;
}




short int rnd(unsigned short int bereich) /* Bereich: 0 bis bereich-1 */
{
  static short next=1;  /* hier VBL-Z„hler benutzen */
  next=next * 15245 + 12345;
  return( (unsigned short)next % bereich);
}


void set_complist(void)
{
  unsigned short i;

  for(i=0;i<15;i++) geblist[i].art=0xFF;
  return;
}

void gebaeude_wieder_aufbauen(unsigned short nr)
{
  unsigned short a=id_suchen(BAUANLAGE,1,1),i=0;

  while(geblist[i].art!=0xFF) i++;
  geblist[i].art=geb[nr].art;
  geblist[i].xpos=geb[nr].xpos;
  geblist[i].ypos=geb[nr].ypos;
  if (a && knete[1]>1000 && !(geb[a].status&BAUEN))
    {
      geb[a].status|=BAUEN;
      geb[a].bauprodukt=geb[nr].art;
      geb[a].wie_weit=0;
    }
  return;
}

void set_strategieen(void)
{
  unsigned short i;

  for(i=0;i<3;i++)
  {
    strat[i].xpl[0]=comp_basis.xpl;
    strat[i].ypl[0]=comp_basis.ypl;
    strat[i].erfolg=0xFFFF;          /* Bei diesem Wert muž die Strategie noch erprobt werden */
  }
  strat[0].xpl[1]=comp_basis.xpl;
  strat[0].ypl[1]=mensch_basis.ypl;
  strat[0].xpl[2]=strat[0].ypl[2]=0xFF;    /* Angriff auf gegnerische Basis */
  strat[1].xpl[1]=mensch_basis.xpl;
  strat[1].ypl[1]=comp_basis.ypl;
  strat[1].xpl[2]=strat[1].ypl[2]=0xFF;
  strat[2].xpl[1]=strat[2].ypl[1]=0xFF;
  return;
}

void set_basis_planes(void)
{
  unsigned short a,x,y;

  x=r_width>>2;
  y=r_height>>2;
  a=id_suchen(BAUANLAGE, 1, 0);
  mensch_basis.xpl=geb[a].xpos/x;
  mensch_basis.ypl=geb[a].ypos/y;
  a=id_suchen(BAUANLAGE, 1, 1);
  comp_basis.xpl=geb[a].xpos/x;
  comp_basis.ypl=geb[a].ypos/y;
  return;
}

void set_buildings(void)
{
  unsigned short i=id_suchen(KASERNE,1,1);
  if(i)
  {
   geb[i].status|=BAUEN;
   geb[i].bauprodukt=tech_level[techlevelnr].kas[rnd(tech_level[techlevelnr].kas[0])+1];
   geb[i].wie_weit=0;
   if((compeinh[1].status&AUFBAU || compeinh[2].status&AUFBAU) && geb[i].bauprodukt==BEKEHRER);
     geb[i].bauprodukt=TRUPPEN;
  }
  i=id_suchen(FABRIK_KL,1,1);
  if(i)
  {
   geb[i].status|=BAUEN;
   geb[i].bauprodukt=tech_level[techlevelnr].klf[rnd(tech_level[techlevelnr].klf[0])+1];;
   geb[i].wie_weit=0;
  }
  i=id_suchen(FABRIK_GR,1,1);
  if(i)
  {
    geb[i].status|=BAUEN;
    geb[i].bauprodukt=tech_level[techlevelnr].grf[rnd(tech_level[techlevelnr].grf[0])+1];;
    geb[i].wie_weit=0;
  }
  return;
}

void gebaeude_deaktivieren(void)
{
  unsigned short i=id_suchen(KASERNE,1,1);

  if(i)
  {
     geb[i].status&=~BAUEN;
     knete[1]+=geb[i].wie_weit;
  }
  i=id_suchen(FABRIK_KL,1,1);
  if(i)
  {
     geb[i].status&=~BAUEN;
     knete[1]+=geb[i].wie_weit;
  }
  i=id_suchen(FABRIK_GR,1,1);
  if(i)
  {
     geb[i].status&=~BAUEN;
     knete[1]+=geb[i].wie_weit;
  }
  return;
}

void set_verbunde(void)
{
  unsigned short i,l;

  for(i=0; i<8; i++)
  {
    compeinh[i].status=0;
    compeinh[i].flags=0;
    compeinh[i].anz_in_verb=0;
    for(l=0; l<=anzahl_verbund; l++) compeinh[i].nr[l]=0;
    compeinh[i].target_destroyed=0;
  }
  compeinh[1].status|=AUFBAU;    /*   0 reservieren fr kein Mitglied in Verbnden */
  return;
}

void initialize_computer(void)
{
  set_complist();
  set_basis_planes();
  set_strategieen();
  set_buildings();
  set_verbunde();
  return;
}


unsigned short verteidigung(void)
{
  unsigned int i,j=0;
  static unsigned short anz=0;

  if(!anz)
  {
    for(i=1;i<llgeb;i++)
    {
      if(geb[i].gesinnung)
        if(geb[i].art!=MAUER && geb[i].art!=SANDSACK && geb[i].art!=MG_TURM
           && geb[i].art!=RK_TURM  && geb[i].art!=INFRATURM)
          j++;
    }
    anz=j/2;   /* jedes zweite Geb. hat eine Verteidigungseinheit */
    if(anz>9) anz=9;
  }
  return(anz);
}


void verbund_zur_aktiven_verteidigung(unsigned short i)
{
  unsigned short j, xk_sik, xg_sik, yk_sik, yg_sik, xp, yp, z;

  xk_sik=xg_sik=geb[z=id_suchen(BAUANLAGE,1,1)].xpos;
  yk_sik=yg_sik=geb[z].ypos;
  for(j=1;j<=llgeb;j++)         /* Berechnung der Grenzen der comp-Basis */
  {
    if(geb[j].gesinnung)
    {
      xp=geb[j].xpos;
      yp=geb[j].ypos;
      if(xp<xk_sik) xk_sik=xp;
      if(xp>xg_sik) xg_sik=xp;
      if(yp<yk_sik) yk_sik=yp;
      if(yp>yg_sik) yg_sik=yp;
    }
  }
  compeinh[i].status=WAITING;

  if(geb[z=id_suchen(BAUANLAGE,1,0)].xpos<xk_sik && geb[z].ypos<yk_sik)
  {
    for(j=1;j<=compeinh[i].anz_in_verb;j++)
    {
      bewegung(compeinh[i].nr[j],xk_sik-5,yk_sik-5,1);
    }
  }
  else
  {
    for(j=1;j<=compeinh[i].anz_in_verb;j++)
    {
      bewegung(compeinh[i].nr[j],xg_sik+5,yg_sik+5,1);
    }
  }
}


void verbund_zur_verteidigung(unsigned short i)
{
  unsigned short j, xk_sik, xg_sik, yk_sik, yg_sik, xp, yp, z;

  xk_sik=xg_sik=geb[z=id_suchen(BAUANLAGE,1,1)].xpos;
  yk_sik=yg_sik=geb[z].ypos;
  for(j=1;j<=llgeb;j++)         /* Berechnung der Grenzen der comp-Basis */
  {
    if(geb[j].gesinnung)
    {
      xp=geb[j].xpos;
      yp=geb[j].ypos;
      if(xp<xk_sik) xk_sik=xp;
      if(xp>xg_sik) xg_sik=xp;
      if(yp<yk_sik) yk_sik=yp;
      if(yp>yg_sik) yg_sik=yp;
    }
  }
  compeinh[i].status=WAITING;

  if(geb[z=id_suchen(BAUANLAGE,1,0)].xpos<xk_sik && geb[z].ypos<yk_sik)
  {
    for(j=1;j<=compeinh[i].anz_in_verb;j++)
    switch(j)
    {
    case 0:  bewegung(compeinh[i].nr[j],xk_sik-3,yk_sik-3,1);
             break;
    case 1:  bewegung(compeinh[i].nr[j],(r_width<=xg_sik+3) ? r_width-1 : xg_sik+3,yk_sik-3,1);
             break;
    case 2:  bewegung(compeinh[i].nr[j],xk_sik-3,(r_height<=yg_sik+3) ? r_height-1 : yg_sik+3,1);
             break;
    case 3:  bewegung(compeinh[i].nr[j],xk_sik-3,(yk_sik+yg_sik)/2,1);
             break;
    case 4:  bewegung(compeinh[i].nr[j],(xk_sik+xg_sik)/2,yk_sik-3,1);
             break;
    case 5:  bewegung(compeinh[i].nr[j],((xk_sik+xg_sik)/2+xk_sik-3)/2,yk_sik-3,1);
             break;
    case 6:  bewegung(compeinh[i].nr[j],xk_sik-3,((yk_sik+yg_sik)/2+yg_sik+3)/2,1);
             break;
    case 7:  bewegung(compeinh[i].nr[j],((xk_sik+xg_sik)/2+xg_sik+3)/2,yk_sik-3,1);
             break;
    case 8:  bewegung(compeinh[i].nr[j],xk_sik-3,((yk_sik+yg_sik)/2+yk_sik-3)/2,1);
             break;
    }
  }
  else
  {
    for(j=1;j<=compeinh[i].anz_in_verb;j++)
    switch(j)
    {
    case 0:  bewegung(compeinh[i].nr[j],xg_sik+3,yg_sik+3,1);
             break;
    case 1:  bewegung(compeinh[i].nr[j],xg_sik+3,((signed)yk_sik-3<0) ? 0 : yk_sik-3,1);
             break;
    case 2:  bewegung(compeinh[i].nr[j],((signed)xk_sik-3<0) ? 0 : xk_sik-3,yg_sik+3,1);
             break;
    case 3:  bewegung(compeinh[i].nr[j],xg_sik+3,(yk_sik+yg_sik)/2,1);
             break;
    case 4:  bewegung(compeinh[i].nr[j],(xk_sik+xg_sik)/2,yg_sik+3,1);
             break;
    case 5:  bewegung(compeinh[i].nr[j],((xk_sik+xg_sik)/2+xk_sik-3)/2,yg_sik+3,1);
             break;
    case 6:  bewegung(compeinh[i].nr[j],((xk_sik+xg_sik)/2+xg_sik+3)/2,yg_sik+3,1);
             break;
    case 7:  bewegung(compeinh[i].nr[j],xg_sik+3,((yk_sik+yg_sik)/2+yk_sik-3)/2,1);
             break;
    case 8:  bewegung(compeinh[i].nr[j],xg_sik+3,((yk_sik+yg_sik)/2+xg_sik+3)/2,1);
             break;
    }
  }
}


void einheit_in_verbund(unsigned short nr)
{
  unsigned short i=1,l=1;

  while(!(compeinh[i].status&AUFBAU))  i++;
  while(compeinh[i].nr[l])           l++;
  compeinh[i].nr[l]=nr;
  compeinh[i].anz_in_verb++;
  einheiten[nr].verbund=i;
/*  DBprnt(("verbund: %i , anz_in_verb: %i , nr: %i \n",i,compeinh[i].anz_in_verb,nr)); */

  switch(phase)
  {
  case BATTLE:
    if(compeinh[i].anz_in_verb==anzahl_verbund)  /* bei 6 Einheiten aufbrechen */
    {
      compeinh[i].status&=~AUFBAU;
      verbund_aufbrechen(i);
      gebaeude_deaktivieren();
    }
    break;

  case DEFENSE1:
    if(compeinh[i].anz_in_verb==verteidigung())
    {
      compeinh[i].status&=~AUFBAU;
      verbund_zur_verteidigung(i);
      gebaeude_deaktivieren();
      phase=DEFENSE2;
    }
    break;

  case DEFENSE2:
    if(compeinh[i].anz_in_verb==anzahl_verbund)
    {
      compeinh[i].status&=~AUFBAU;
      verbund_zur_aktiven_verteidigung(i);
      gebaeude_deaktivieren();
      phase=BATTLE;
    }
    break;

  }
  return;
}


void verbund_aufbrechen(unsigned short verb)
{
  /*unsigned short i_sik=0;*/
  unsigned short x,y,z;
  static unsigned short i=2;

/*  for(i=0;i<3;i++) if(strat[i].erfolg > strat[i_sik].erfolg) i_sik=i; */
/*  i=i_sik; */
  i++;
  if(i==3) i=0;
  if(strat[i].erfolg==0xFFFF) strat[i].erfolg=0;        /* wird die Strategie zum ersten mal gefahren, dann noch kein Erfolg */
  compeinh[verb].strategie=i;
  if(strat[i].xpl[1]==0xFF && strat[i].ypl[1]==0xFF)    /* direkter Angriff ? */
  {
    compeinh[verb].status=ATTACK;
    compeinh[verb].target_destroyed=0;
    ziel_suchen(verb);
  }
  else
  {
    compeinh[verb].status=MOVING;
    x=r_width>>2;
    y=r_height>>2;
    x=x*strat[i].xpl[1];
    y=y*strat[i].ypl[1];
    for(z=1; z<=compeinh[verb].anz_in_verb; z++)
    {
      DBprnt(("Aufbruch: verbund: %i , anz_in_verb: %i , nr: %i \n",verb,compeinh[verb].anz_in_verb,compeinh[verb].nr[z]));
      bewegung(compeinh[verb].nr[z],x+z+2,y+z+2,1);
    }
  }
  return;
}


void abarbeiten_computer()
{
  unsigned short i,l=1,aufbau=1;
  static unsigned int vorher_aufgebaut=0;

  switch(phase)
  {
  case BATTLE:
   {
    if(timer_counter%comp_bauspeed==(comp_bauspeed-1) && !vorher_aufgebaut)
    {
       while(compeinh[l].status!=0)
       {
         if(compeinh[l].status==AUFBAU) aufbau=0;  /* Ist ein Verbund noch nicht ferig keinen neuen */
         l++;                                     /* neuer Verbund wird aufgebaut */
       }
       if(aufbau)
       {
         compeinh[l].status=AUFBAU;
         vorher_aufgebaut=1;
         set_buildings();
       }
    }
    else
      if(timer_counter%comp_bauspeed!=comp_bauspeed-1) vorher_aufgebaut=0; /* zurcksetzen */

    for(i=1;i<8;i++)                       /* Verbunde abarbeiten */
    {
      switch(compeinh[i].status)
      {
      case MOVING:
          if(compeinh[i].flags>(compeinh[i].anz_in_verb>>1))   /* bei mehr als H„lfte n„chster Befehl */
          {
            compeinh[i].status=ATTACK;
            ziel_suchen(i);
            compeinh[i].target_destroyed=0;
          }
          break;

      case ATTACK:
          if(compeinh[i].target_destroyed)
          {
            ziel_suchen(i);
            compeinh[i].target_destroyed=0;
          }
          break;
      }
    }
   }
   break;


   case DEFENSE1:
       if(compeinh[1].status==0)
       {
         compeinh[1].status|=AUFBAU;
         set_buildings();
       }
       break;

   case DEFENSE2:
       if(compeinh[2].status==0)
       {
         compeinh[2].status|=AUFBAU;
         set_buildings();
       }
       break;

  }
  return;
}

void ziel_suchen(unsigned short nr)
{
  unsigned short i,a,xe,ye,i_sik,wert_sik=255;

  xe=einheiten[compeinh[nr].nr[1]].xpos;
  ye=einheiten[compeinh[nr].nr[1]].ypos;
  for(i=1;i<=llgeb;i++)
  {
    if(geb[i].gesinnung==0)
      if(abs(xe-geb[i].xpos)+abs(ye-geb[i].ypos)<wert_sik)
      {
        wert_sik=abs(xe-geb[i].xpos)+abs(ye-geb[i].ypos);
        i_sik=i;
      }
  }
  for(a=1;a<=anzahl_verbund;a++)
  {
    angriff(compeinh[nr].nr[a],geb[i_sik].xpos,geb[i_sik].ypos,1);
  }
  return;
}


