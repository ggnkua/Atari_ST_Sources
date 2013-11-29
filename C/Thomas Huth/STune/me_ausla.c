/**
 * STune - The battle for Aratis
 * me_ausla.c : Various functions of the game engine
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

#include <stdio.h>
#include <stdlib.h>
#include <osbind.h>
#include <string.h>

#include "stunegem.h"
#include "stunmain.h"
#include "st_debug.h"
#include "me_kifkt.h"
#include "me_gemft.h"
#include "me_routi.h"
#include "building.h"
#include "units.h"
#include "stune.rsh"
#include "th_musik.h"
#include "th_graf.h"
#include "th_aesev.h"
#include "windial.h"
#include "stunfile.h"


void level_geschafft(unsigned short);

unsigned short wer_lebt_noch(void)
{
  unsigned short i, j, flanke=einheiten[1].gesinnung;

  for(i=1; i<=lleinh; i++)
    if(einheiten[i].gesinnung!=flanke) return 0; 
  
  for(j=1; j<=llgeb; j++)
    if(geb[j].art!=MAUER && geb[j].art!=SANDSACK)
      if(geb[j].gesinnung!=flanke) return 0;
   
  if(flanke) return 1 ; else return 2;

}


void auftrag_erledigt(void)
{
  unsigned short x=wer_lebt_noch();   /* 0=beide; 1=gegner; 2=aratis */  

 if(!spielart)            /* Kampagne */
  switch(level)
  { 
    case 0: 
      if(saft_ges[0]>=1000) level_geschafft(2);
      if(x==1) level_geschafft(1);
      break;
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    default: if(x) level_geschafft(x);
             break;
  }
 else
  wer_lebt_noch();      /* bei netzwerk/user-lvls immer alles platt machen */ 

 return;
}
       

void hs_to_gem(void)
{
  unsigned short i;

  for(i=HIGHNAME; i<=HIGHNAME+27; i+=3)
    highdlg[i].ob_spec.tedinfo->te_ptext=hs[(i-HIGHNAME)/3].name;

  for(i=HIGHLEVL; i<=HIGHLEVL+27; i+=3)
    sprintf(highdlg[i].ob_spec.tedinfo->te_ptext, "%i", (int)hs[(i-HIGHLEVL)/3].level ); /*NEW*/ /* Unter GNU-C gibt's kein itoa mehr :-( */

  for(i=HIGHPKTE; i<=HIGHPKTE+27; i+=3)
    sprintf(highdlg[i].ob_spec.tedinfo->te_ptext, "%i", (unsigned int)hs[(i-HIGHPKTE)/3].punkte ); /*NEW*/

  return;
}

void level_geschafft(unsigned short well_done)
{
  OBJECT *auswdlg;
  unsigned int wd, punkte, i, z, verschoben=0;
  short endezeit;
  char *dptr;

  if(well_done==2)
    playsample(S_EINSATZERFOLG);
  else
    playsample(S_EINSATZ_FEHL);
  sam_abarbeiten(); sam_abarbeiten();
  rsrc_gaddr(R_TREE, AUSWERT, &auswdlg);
  sprintf(auswdlg[AUSWUNAR].ob_spec.tedinfo->te_ptext, "%i", (int)einh_verl[0]); /*NEW*/
  sprintf(auswdlg[AUSWUNMA].ob_spec.tedinfo->te_ptext, "%i", (int)einh_verl[1]); /*NEW*/
  sprintf(auswdlg[AUSWGEAR].ob_spec.tedinfo->te_ptext, "%i", (int)geb_verl[0]); /*NEW*/
  sprintf(auswdlg[AUSWGEMA].ob_spec.tedinfo->te_ptext, "%i", (int)geb_verl[1]); /*NEW*/
  sprintf(auswdlg[AUSWSAAR].ob_spec.tedinfo->te_ptext, "%i", (int)saft_ges[0]); /*NEW*/
  sprintf(auswdlg[AUSWSAMA].ob_spec.tedinfo->te_ptext, "%i", (int)saft_ges[1]); /*NEW*/
  punkte=(long)(einh_verl[1]-einh_verl[0])*2+(long)(geb_verl[1]-geb_verl[0])*10+(long)(saft_ges[0]-saft_ges[1])/100;
  punkte*=well_done;  /* wenn gewonnen *2! */
  if((int)punkte<0) punkte=0;
  sprintf(auswdlg[AUSWPNTS].ob_spec.tedinfo->te_ptext, "%i", punkte); /*NEW*/

  endezeit=Tgettime();
  endezeit=((endezeit>>11)&31)*60+((endezeit>>5)&63);
  if(endezeit<startzeit)  endezeit+=24*60;
  endezeit=endezeit-startzeit;
  dptr=auswdlg[AUSWLEN].ob_spec.tedinfo->te_ptext;
  dptr[0]='0'+endezeit/600;  dptr[1]='0'+((endezeit/60)%10);
  dptr[2]=':';
  dptr[3]='0'+((endezeit/10)%10);  dptr[4]='0'+(endezeit%10);

  sam_abarbeiten(); sam_abarbeiten();

  wd=wdial_init(auswdlg ,"STune", 0);
  wdial_formdo(wd, auswdlg, 0, 0, 0, 0);
  wdial_close(wd, auswdlg);

  rsrc_gaddr(R_TREE, HIGHSCOR, &highdlg);

  if(loadhighscore()==0)
  {
  for(i=0; i<=9; i++)
    if(hs[i].punkte<=punkte && !verschoben)
    {
      verschoben=1;
      z=10;
      do
      {
        z--;
        hs[z]=hs[z-1];
      }while(z!=i);
      hs[i].punkte=punkte;
      strncpy(hs[i].name, auswdlg[AUSWNAME].ob_spec.tedinfo->te_ptext, 12);
/*      hs[i].name=auswdlg[AUSWNAME].ob_spec.tedinfo->te_ptext; */
        hs[i].level=level;
    }

    hs_to_gem();
  }
  else
  {
    hs[0].punkte=punkte;
    strncpy(hs[0].name, auswdlg[AUSWNAME].ob_spec.tedinfo->te_ptext, 12);
/*    hs[0].name=auswdlg[AUSWNAME].ob_spec.tedinfo->te_ptext; */
    hs[0].level=level;
    for(i=1; i<=9; i++)
     {
      hs[i].punkte=hs[i].level=0;
      hs[i].name[0]=0;    /*NEW*/ /* So ist Stringl”schen besser */
     }
    strncpy(highdlg[HIGHNAME].ob_spec.tedinfo->te_ptext, hs[0].name, 12);
    sprintf(highdlg[HIGHLEVL].ob_spec.tedinfo->te_ptext, "%i", (int)hs[0].level); /*NEW*/
    sprintf(highdlg[HIGHPKTE].ob_spec.tedinfo->te_ptext, "%i", (int)hs[0].punkte); /*NEW*/
  }
/*  DBprnt(("bin hier5\n")); */

  sam_abarbeiten(); sam_abarbeiten();

  wd=wdial_init(highdlg ,"STune", 0);
  wdial_formdo(wd, highdlg, 0, 0, 0, 0);
  highdlg[HIGHEXIT].ob_state&=~SELECTED;
  wdial_close(wd, highdlg);
  savehighscore();

  level_done=well_done;
  return;
}


void work_list_einh(unsigned short a, unsigned int count)
{
 unsigned short xp,yp,ausr,ausrziel,h1,h2,art,g,hilf=0;
 signed int x,y,nx,ny;
 unsigned int s;
 EINHEIT *einh;

 einh=&einheiten[a];
 s=einh->status;
 art=einh->art;
 g=einh->gesinnung;

 if(s&AUSRICHTUNG) {
                     if(einh->ausrziel!=einh->ausrichtung && einh->ausrziel<8)
                     {
                      einh->wie_weit+= einheit_typ[art].ausrgeschw;
                      if(einh->wie_weit> 40)
                      {
                        einh->wie_weit=0;
                        ausr=einh->ausrichtung;
                        ausrziel=einh->ausrziel;
                        if (ausr>4)
                        {
                          if((unsigned)(8+ausrziel-ausr)<=ausr-ausrziel)
                          {
                            einh->ausrichtung++;
                          }
                          else
                          {
                            einh->ausrichtung--;
                          }
                        }
                        else
                        {
                          if((unsigned)(8+ausr-ausrziel)<=ausrziel-ausr)
                          {
                            if(ausr==0)
                            {
                              einh->ausrichtung=7;
                            }
                            else
                            {
                              einh->ausrichtung--;
                            }
                          }
                          else
                          {
                            einh->ausrichtung++;
                          }
                        }
                        if (einh->ausrichtung==8) einh->ausrichtung=0;
                       }
                      }
                      else
                      {
                        einh->status &=~AUSRICHTUNG; /* Ausrichtung beendet */
                      }
                      s=einh->status;
                      return;
                     }

 if (s & BEWEG) {
                  if(art<20)  /* nur wenn k. Ausrichtung */
                  {                        /* und kein Geschoss */
                  einh->altesx=einh->xkoor;
                  einh->altesy=einh->ykoor;
                  einh->wie_weit += einheit_typ[einh->art].geschwindigkeit;
                  x=einh->nochschrx;
                  y=einh->nochschry;
                  xp=einh->xpos;
                  yp=einh->ypos;
                  einh->xkoor= xp << 4; /* mal 16 */
                  einh->ykoor= yp << 4;
                  switch (x)
                  {
                    case -1 : einh->xkoor -= einh->wie_weit>>4;
                              y_switchen(y,a);      /* Bewegungen n.l.*/
                              break;
                    case  1 : einh->xkoor += einh->wie_weit>>4;
                              y_switchen(y,a);     /* Bew. n.r. */
                              break;
                    default : y_switchen(y,a);    /* Bewegungen n. oben/unten */
                              break;
                  }
                  if (einh->wie_weit > 255)
                  {
/*->*/              sfeld[xp][yp].befahrbar=1;
                    sfeld[xp][yp].begehbar=1;
                    sfeld[xp][yp].besetzt=0;
                    sfeld[xp][yp].nr=0;
                    einh->altxpos=xp;
                    einh->altypos=yp;
                    einh->status|=NOCHM_BERE; 
                    switch(x)
                    {
                      case -1 : einh->xpos -= 1;
                                einh->nochschrx=einh->schrittx;
                                y_berechnen(a);
                                break;
                      case  0 : y_berechnen(a);
                                break;
                      case  1 : einh->xpos += 1;
                                einh->nochschrx=einh->schrittx;
                                y_berechnen(a);
                                break;
                      default : if (x < -1) einh->nochschrx ++;
                                  else     einh->nochschrx --;
                                y_berechnen(a);
                                break;
                    }
                    xp = einh->xpos ; yp = einh->ypos;
                    if(einh->status&NOCH_ANGR)
                    {
                      if(in_reichweite(a,einh->xziel,einh->yziel))
                      {
                        einh->status&=~BEWEG;
                        einh->status&=~NOCHM_BERE;
						einh->status&=~WACHEN;
                        if(einh->zielart)
						  angriff(a,einheiten[einh->zielobj].xpos,einheiten[einh->zielobj].ypos,0);
                        else
                          angriff(a,einh->xziel,einh->yziel,0);  /* geb„ude stehen fest */
                        s=einh->status;
                      } 
                    }
                    if(einh->status&UEBERROLLEN)
                    {
                      h1=setze_freigaben(a);
                      if(h1)
                      {
                        sfeld[einheiten[h1].xpos][einheiten[h1].ypos].feldtyp=8;
                        einheit_entfernen(h1);
                        playsample(S_SCREAM);
                      }
                      einh->status&=~UEBERROLLEN;
                    }
                    if(g==0)
                    {
                      einh->status|=BEWEG_ABGE;
                    }
/*Ziel erreicht? */ if (xp == einh->xziel
                        && yp == einh->yziel)
                    {
                      einh->status&=~BEWEG;
                      einh->status&=~NOCHM_BERE;
                      einh->status|=WACHEN;
                      einh->wie_weit=0;
/*                      einh->altxpos=0; einh->altypos=0; */
                      if(einh->status&PATROLIE)
                      {
                        bewegung(a,einh->xpospatr,einh->ypospatr,1);
                        einh->xpospatr=einh->xpos;
                        einh->ypospatr=einh->ypos;
                      }
                      if(einh->status&IN_WERKST)
                          {
                            einh->status|=REPERATUR;
                            einh->status|=AUSRICHTUNG;
                            einh->ausrziel=4;
                            einh->status&=~IN_WERKST;
                          }
                      if(g && einh->verbund && !netflag)
                      {
                        compeinh[einh->verbund].flags++;
                      }
                    }
                    else
                    {
                      if (s & NOCHM_BERE)
                      {
                        einh->status&=~BEWEG;
                        bewegung(a,einh->xziel,einh->yziel,FALSE); /* Feld nicht reservieren, da sonst eigener Weg verbaut */
                      }
                      ausrichten(a,1);
                      nx=einh->nochschrx;
                      if(nx<-1 || nx>1) nx=0;
                      ny=einh->nochschry;
                      if(ny<-1 || ny>1) ny=0;
                      h1=(unsigned)(xp+nx);
                      h2=(unsigned)(yp+ny);
/* n„chste Position */if(!sfeld[h1][h2].befahrbar || sfeld[h1][h2].besetzt)
/* gleich Ziel ? */   {
                        if(h1==einh->xziel && h2==einh->yziel)
                        {
 /*                        if(einh->status&PATROLIE)
                         {
                           bewegung(a,einh->xpospatr,einh->ypospatr,1);
                           einh->xpospatr=einh->xpos;
                           einh->ypospatr=einh->ypos;
                         }
                         else
                         {  */
                          einh->status&=~BEWEG;
                          einh->status&=~NOCHM_BERE;
                          if(g && einh->verbund && !netflag)
                          {
                            compeinh[einh->verbund].flags++;
                          }
                          if(art==SAMMLER)
                          {
                             h1=id_suchen(RAFFINERIE,einh->ID,einh->gesinnung);
                             if(h1 && (h1==nummer_ermitteln(einh->xziel,einh->yziel,0)))
                             {
                              einh->status|=LOESCHEN;
                              einh->status|=AUSRICHTUNG;
                              einh->ausrziel=4;
                             }
/*falls d. zu sam. F. bes*/  if(einh->status&SAMMELN)
                             {
                          /*    einh->ausrziel+=2;*/
                          /*    if(einh->ausrziel==8) einh->ausrziel=0;*/
                          /*    if(einh->ausrziel==9) einh->ausrziel=1;*/
                              neu_suchen(a,1);
                              einh->xziel=einh->xpos+ausrzahl[einh->ausrziel].x;
                              einh->yziel=einh->ypos+ausrzahl[einh->ausrziel].y;
                              einh->status|=(BEWEG+AUSRICHTUNG);
                             }
                          }
                          if(art==BEKEHRER && einh->status&ANGR)
                          {
                            gebaeude_infiltriert(a);
                          }
                          if(einh->status&IN_WERKST)
                          {
                            einh->status|=REPERATUR;
                            einh->status|=AUSRICHTUNG;
                            einh->ausrziel=4;
                            einh->status&=~IN_WERKST;
                          }
                       /*  } */
                        }
                        else
                        {
                          if(art<9) if(!sfeld[h1][h2].begehbar) neu_suchen(a,0);
                          if(art>9) if(!sfeld[h1][h2].befahrbar) neu_suchen(a,1);
                           else if(sfeld[h1][h2].besetzt && sfeld[h1][h2].gesinnung!=g)
                                   einh->status|=UEBERROLLEN;
                                 else neu_suchen(a,1);
                          ausrichten(a,1);
                        }
                      }
                      if (s&PATROLIE && art!=SAMMLER)
                      {
                        patr_wachen(a);
                      }
                      if(einh->status&BEWEG) feld_reservieren(a); /* Feld nicht reservieren, da sonst eigener Weg verbaut */
                    }
                    einh->wie_weit=0;
                    if(art==SAMMLER)  if(einh->status&STOP) einh->status=0;
                    }
                    s=einh->status;
                    if(!(s&ANGR)) return;
                  }
                  else  /* fr Geschosse  */
                  {

				/*   else  wenn keine Mauer im Weg auf treffer prfen */
                    if ((abs(einh->xkoor-einh->xziel)<9) &&
                        (abs(einh->ykoor-einh->yziel)<9))
                    {
                       if(einh->zielart)   /* Einheit anvisiert */
                       {
                         hilf=nummer_ermitteln(einh->xziel>>4,einh->yziel>>4,1);
                         if(hilf)
                         {
                           einheiten[hilf].zustand-=einh->zustand; /* treffer */
                           if(einheiten[hilf].zustand<1)
                           {
                             angriffe_abschalten(hilf,1);
                             einheit_entfernen(hilf); /* einheit zerst”rt */
                             if(a==(lleinh+1))        /* geschoss wurde in */
                             {                        /* Liste verschoben */
                               a=hilf;                /* hilf enth„lt den */
                             }                        /* neuen Platz */
                           }
                           else
                           {
                             if(ak_nr==hilf)  rdr_health(); /*NEW*/
                             if(einheiten[hilf].gesinnung && einheiten[hilf].zielobj!=a  && !(einheiten[hilf].status&ANGR))
                                einheit_wird_angegriffen(hilf,a);
                           }
                         }
                  /*       einheit_entfernen(a); */
                       }
                       else   /* geb„ude anvisiert */
                       {
                         hilf=nummer_ermitteln(einh->xziel>>4,einh->yziel>>4,0);
                         if(hilf/* && geb[hilf].art!=MAUER*/)  /* geb„ude noch existend? */
                         {
                           geb[hilf].zustand-=einh->zustand;
                           if(ak_nr==hilf)  rdr_health(); /*NEW*/
                           if(geb[hilf].zustand<1)
                           {
                             angriffe_abschalten(hilf,0);
                             if(g && geb[einh->zielobj].gesinnung==0)
                                 compeinh[einh->verbund].target_destroyed=1;
                             gebaeude_entfernen(hilf);
                           }
                         }
                    /*     einheit_entfernen(a); */
                       }
                     einheit_entfernen(a); 
                   }
                   else
                   {
 /* Mauer im Weg? */if(einh->xpos!=(einh->altesx>>4) || einh->ypos!=(einh->altesy>>4))
                     if(sfeld[einh->xpos][einh->ypos].besetzt && sfeld[einh->xpos][einh->ypos].besetzertyp==0)
                      if(geb[hilf=sfeld[einh->xpos][einh->ypos].nr].art==MAUER)
                       {
                         geb[hilf].zustand-=einh->zustand;
                         if(ak_nr==hilf)  rdr_health();  /*NEW*/ /*Funktion zum neuzeichnen des Energiebalkens einer Einheit */
                        /* einheit_entfernen(a); */
                         if(geb[hilf].zustand <1)
                         {
                           angriffe_abschalten(hilf,0);
                           if(g && geb[einh->zielobj].gesinnung==0)
                               compeinh[einh->verbund].target_destroyed=1;
                           gebaeude_entfernen(hilf);
                         }
                         einheit_entfernen(a);
                         return;
                       } 
                     einh->altesy=einh->ykoor;
                     einh->altesx=einh->xkoor;
                     switch(art)
                     {
                       case GRANATE: einh->xkoor+=einh->nochschrx<<2;
                                     einh->ykoor+=einh->nochschry<<2;
                                     break;
                       case RAKETE:  einh->xkoor+=einh->nochschrx<<1;
                                     einh->ykoor+=einh->nochschry<<1;
                                     break;
                       case LASER:   einh->xkoor+=einh->nochschrx<<2;
                                     einh->ykoor+=einh->nochschry<<2;
                                     break;
                       case SCHALL:  einh->xkoor+=einh->nochschrx<<2;
                                     einh->ykoor+=einh->nochschry<<2;
                                     break;
                       case FLAMME:  einh->xkoor+=einh->nochschrx;
                                     einh->ykoor+=einh->nochschry;
                                     break;
                     }
                     einh->xpos=einh->xkoor>>4;
                     einh->ypos=einh->ykoor>>4;
                     if(s&NOCHM_BERE) flugbahn_berechnen(a);
                   }
                   return;
                  }
                }

   if(s&REPERATUR) {
                    if(!((count-1)&3))
                     if(einheit_typ[art].zustandspunkte>einh->zustand)
                     {
                       einh->zustand ++;
                       knete[g]-=einheit_typ[art].zustandspunkte*100/einheit_typ[art].kosten;
                     }
                     else
                     {
                       einh->status &=~REPERATUR; /* Reperatur beendet */
                       einh->status |=WACHEN;
                     }
                     if(ak_nr==a)  rdr_health(); /*NEW*/
                     return;
                   }


  if (s&ANGR)        {
                      if(einh->zielart)
                      {
                        xp=in_reichweite(a,einheiten[einh->zielobj].xpos,einheiten[einh->zielobj].ypos);
               /*         else
                          einh->status&=~ZIEL_IN_BEW;  */
                        if(s&ZIEL_IN_BEW)
                        {
                          einh->xziel=einheiten[einh->zielobj].xpos;
                          einh->yziel=einheiten[einh->zielobj].ypos;
                          if(!(einheiten[einh->zielobj].status&BEWEG))
                            einh->status&=~ZIEL_IN_BEW;
                        }
                        if(einheiten[einh->zielobj].status&BEWEG)
                          einh->status|=ZIEL_IN_BEW;
                      }
                      else
                        xp=in_reichweite(a,geb[einh->zielobj].xpos,geb[einh->zielobj].ypos);
                      if (!(s&WACHEN))
                      {
/*                        DBprnt(("bin da1")); */
/*                        DBprnt(("in_reichweite: %i \n",xp)); */
                        if(xp)
                        {
/*                          DBprnt(("bin da2")); */
                          einh->status&=~BEWEG;
                          einh->status&=~NOCHM_BERE;
                          nx=einh->nochschrx; ny=einh->nochschry;
                          if(nx<-1 || nx>1) nx=0;    /* Feld wurde noch reserviert */
                          if(ny<-1 || ny>1) ny=0;    /* muss aber frei bleiben, */
                          xp=einh->xpos;      /* da es nicht mehr befahren wird */
                          yp=einh->ypos;
                          if(!(nummer_ermitteln2(xp+nx,yp+ny) || nummer_ermitteln(xp+nx,yp+ny,0)))
                          {
                            sfeld[xp+nx][yp+ny].befahrbar=1;
                            sfeld[xp+nx][yp+ny].begehbar=1;
                            sfeld[xp+nx][yp+ny].besetzt=0;
                            sfeld[xp+nx][yp+ny].nr=0;
                          }
                          ausrichten_fuer_schiessen(a,0);
                          if(einh->ausrziel==einh->ausrichtung)
                              einh->status&=~AUSRICHTUNG;
                        }
                        else
                        {
                          if(!(s&BEWEG)) bewegung(a,einheiten[einh->zielobj].xpos,einheiten[einh->zielobj].ypos,TRUE);
                        }
                      }
                      else          /* wenn wachen und ziel aužerhalb reichweite kein wachen mehr */
                      {
                        if(!xp) einh->status&=~ANGR;
                      }
                      s=einh->status;
                      if(s&ZIEL_IN_BEW)
                      {
                        einh->xziel=einheiten[einh->zielobj].xpos;
                        einh->yziel=einheiten[einh->zielobj].ypos;
                        if(!(einheiten[einh->zielobj].status&BEWEG))
                          einh->status&=~ZIEL_IN_BEW;
                      }
                     /* DBprnt(("xp: %i \n",xp)); */
                      if(!(s&AUSRICHTUNG) && !(s&BEWEG) && xp)
                      {
                        einh->wie_weit+=einheit_typ[art].schiessgeschw;
                        /* DBprnt(("wie_weit: %i \n",einh->wie_weit)); */
                        if(einh->wie_weit>=255)
                        {
                          schiessen(a);
                          einh->wie_weit=0;
                          s=einh->status;
                          if (s&WACHEN && s&ANGR) einh->status&=~ANGR;
                        }
                      }
                    }
     if(s&LOESCHEN)
                    {
                      if(einh->zielobj) /* zielobj enthaelt den Saft */
                      {
                        if(einh->zielobj<4)
                        {
                          knete[g]+=einh->zielobj*10;
                          saft_ges[g]+=einh->zielobj*10;
                          einh->zielobj=0;
                        }
                        else
                        {
                          einh->wie_weit++;
                          if (einh->wie_weit==10)
                          {
                            einh->zielobj-=4;
                            einh->wie_weit=0;
                          }
                          knete[g]+=4;
                          saft_ges[g]+=4;
                        }
                        if(knete[g]>30000) knete[g]=30000;
                      }
                      else
                      {
                        einh->status&=~LOESCHEN;
                        saft_suchen(a);
                      }
                      return;
                    }
     if(s&SAMMELN)  
       if(!(s&BEWEG))
          {
                        if(einh->zielobj>69){einh->status&=~SAMMELN;rueckkehr(a);} /* falls Sammler schon voll und trotzdem noch geklickt wird */
                        xp=einh->xpos;
                        yp=einh->ypos;
                        einh->wie_weit+=2;
                        if(einh->wie_weit>40)
                        {
                          einh->wie_weit=0;
                        /*  einh->zielobj+=5; */
                          if(sfeld[xp][yp].ertrag)
						  {
							 sfeld[xp][yp].ertrag-=1;
							 einh->zielobj+=5;
						  }
                          if(einh->zielobj>69)    /*Sammler voll?*/
                             {
                              einh->status&=~SAMMELN;
                              rueckkehr(a); /* RAFF. noch vorhanden? */
                             }
                           else
                            if(sfeld[xp][yp].ertrag==0)  /* Feld leer ?*/
                            {
                              sfeld[xp][yp].feldtyp=1;
                              h1=0;
                              do
                              {
                                neu_suchen(a,1);
                                h1++;
                              }while(sfeld[xp+einh->nochschrx][yp+einh->nochschry].ertrag==0 && h1!=8);
                              if(sfeld[xp+einh->nochschrx][yp+einh->nochschry].ertrag)
                                 bewegung(a,xp+einh->nochschrx,yp+einh->nochschry,TRUE);
                              else
                              {
                                 if(einh->ausrichtung==einh->ausrziel)
                                   {
                                     einh->status&=~SAMMELN;
                                     rueckkehr(a);
                                   }
                             /*   ausrichten(a,1); */
                              }
                            }
                        }

                    }
}


void work_list_geb(unsigned short a, unsigned int count)
{
 unsigned short xp,yp,h1,art,g,rweite,i,prior,i_sik;
 signed int z,z2;
 unsigned int s;
 GEBAEUDE *gebs;


 gebs=&geb[a];
 s=gebs->status;
 art=gebs->art;
 g=gebs->gesinnung;
 if(s&REPE){ if(!((count-1)&3))
                {
                  if(gebs->zustand != gebaeude_typ[art].zustandspunkte)
                  {
                    h1=gebaeude_typ[art].kosten/gebaeude_typ[art].zustandspunkte;
                    if(h1<=knete[g])
                    {
                      if(saft<=0)
                      {
                        gebs->zustand+=1;
                        knete[g]-=h1;
                      }
                      else
                       if(timer_counter%4==0)
                       {
                         gebs->zustand+=1;
                         knete[g]-=h1;
                       }
                    }
                  }
                  else gebs->status&=~REPE;
                  if(ak_nr==a)  rdr_health(); /*NEW*/
                }
              }
  if(gebs->ID==1)
    if(s&BAUEN && !(s&PAUSE))
                {
                  if(art==BAUANLAGE) z=gebaeude_typ[gebs->bauprodukt].kosten;
                    else z=einheit_typ[gebs->bauprodukt].kosten;
                  if(gebs->wie_weit!=z)
                  {
                    if(knete[g])
					  if(saft<=0)
					  {
                        gebs->wie_weit++;
                        knete[g]--;
                      }
                      else
                       if(timer_counter%4==0)
                       {
                         gebs->wie_weit++;
                         knete[g]--;
                       }
                  }
                  else
                  {
                    if(art==BAUANLAGE)
                       if(!g)
                        {
                          aktualize_status(a);
                          playsample(S_KONSTR_OK);
                          set_enable();
                          gebs->status&=~BAUEN;
                        }
                        else
                        {
                          if(!netflag && platz_testen(gebs->bauprodukt, geblist[0].xpos, geblist[0].ypos, 1))
                          {
                            setgebaeude(gebs->bauprodukt, geblist[0].xpos, geblist[0].ypos, 1);
                            i=0;
                            prior=0;
                            i_sik=0;
                            while(geblist[i].art!=0xFF)
                            {
                              if(gebaeude_typ[geblist[i].art].prioritaet>=prior)
                                i_sik=i;
                              i++;
                            }
                            if(i==1)
                            {                  /* noch vom gebauten Geb. 1 */
                              gebs->status&=~BAUEN;   /* Liste leer=> nicht mehr bauen */
                              geblist[0].art=0xFF;
                            }
                            else
                            {
                              i--;
                              gebs->bauprodukt=geblist[i_sik].art;  /* es wird immer das in geblist[0] gebaut */
                              geblist[0]=geblist[i_sik];
                              geblist[i_sik]=geblist[i];
                              geblist[i].art=0xFF;
                              gebs->wie_weit=0;
                            }
                          }
                        }
                     else
                      {
                         if(!g)aktualize_status(a);
                         z=einheit_initialisieren(gebs->bauprodukt,a,0);
                         if(z && !g)
                             gebs->status&=~BAUEN;
                         if(g && z && !netflag)
                         {
                           gebs->wie_weit=0;
                           switch(art)
                           {
                            case KASERNE:   gebs->bauprodukt=tech_level[techlevelnr].kas[rnd(tech_level[techlevelnr].kas[0])+1];
                                            break;
                            case FABRIK_KL: gebs->bauprodukt=tech_level[techlevelnr].klf[rnd(tech_level[techlevelnr].klf[0])+1];
                                            break;
                            case FABRIK_GR: do
                                            {
                                              gebs->bauprodukt=tech_level[techlevelnr].grf[rnd(tech_level[techlevelnr].grf[0])+1];
                                            }while(gebs->bauprodukt==SAMMLER);
                                            break;
                            default:        break;
                           }
                         }
                         else if(g && z && netflag) gebs->status&=~BAUEN;
                      }
                  }
                  if(!((count-1)&7) && !g) aktualize_status(a);
               }
    if(s&WACHE){
               if(count==32)
               {
                 xp=gebs->xpos;
                 yp=gebs->ypos;
                 rweite=gebaeude_typ[art].rweite;
                 for(z=(signed)(xp-rweite);z<=(signed)(xp+rweite);z++)
                 {
                   if(z<0) continue;
                   if(z>127) continue;
                   for(z2=(signed)(yp-rweite);z2<=(signed)(yp+rweite);z2++)
                   {
                     if(z2<0) continue;
                     if(z2>127) continue;
                     if(sfeld[z][z2].besetzt==1 && sfeld[z][z2].besetzertyp && sfeld[z][z2].gesinnung!=g)
                        {gebaeude_angriff(a,z,z2);z=(signed)(xp+rweite);}
                   }
                 }
                }
               }
   if(s&ANGRIFF){
                  if(in_reichweite_geb(a,gebs->zielnr))
                  {
                    gebs->wie_weit++;
                    switch(art)
                    {
                     case MG_TURM: if(gebs->wie_weit==60)
                                   {
                                     playsample(S_MG);
                                     gebs->wie_weit=0;
                                     einheiten[gebs->zielnr].zustand-=3;
                                     if(ak_nr==gebs->zielnr)  rdr_health(); /*NEW*/
                                     z=einheiten[gebs->zielnr].zustand;
                                     if(z<=0){
                                                        angriffe_abschalten(gebs->zielnr,1);
                                                        einheit_entfernen(gebs->zielnr);
                                                      }
                                   }
                                   break;
                     case RK_TURM: if(gebs->wie_weit>=110 && saft<=0 )
                                   {
                                     einheit_initialisieren(RAKETE,a,2);
                                     gebs->wie_weit=0;
                                   }
                                   break;
                     case INFRATURM: if(gebs->wie_weit>=80 && saft<=0 )
                                   {
                                     einheit_initialisieren(SCHALL,a,2);
                                     gebs->wie_weit=0;
                                   }
                                   break;
                    }
                  }
                  else
                  {
                    gebs->status&=~ANGRIFF;
                    gebs->status|=WACHE;
                  }
               }
 return;
}

void verkaufen(unsigned short a, unsigned short ges)
{
  if(a && geb[a].gesinnung==ges)
  {
    knete[ges]+=gebaeude_typ[geb[a].art].kosten>>1;
    gebaeude_entfernen(a);
    playsample(S_CLICK2);
  }
  return;
}

void reparieren(unsigned short a, unsigned short ges)
{
 if(a && geb[a].gesinnung==ges)
  {
    geb[a].status|=REPE;
    if(!ges) playsample(S_CLICK2);
  }
 return;
}

void setzen(unsigned short xziel,unsigned short yziel,unsigned short ges)
{
 unsigned short z;

 z=geb[id_suchen(BAUANLAGE,1,ges)].bauprodukt;

 if(!ges)
   if(platz_testen(z,xziel,yziel,0))
   {
     setgebaeude(z,xziel,yziel,0);
     normalize_popups(id_suchen(BAUANLAGE,1,0));
   }
   else playsample(S_MOEP);
 else
   setgebaeude(z,xziel,yziel,1);

 return;
}

void bauen(unsigned short prim, unsigned short oldsel)
{
  geb[prim].wie_weit=0;
  geb[prim].status=BAUEN;
  geb[prim].bauprodukt=oldsel;
  return;
}
