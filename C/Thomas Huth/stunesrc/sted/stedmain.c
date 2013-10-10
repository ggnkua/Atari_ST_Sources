/**
 * STune - The battle for Aratis
 * stedmain.c : Main functions.
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

#include <osbind.h>
#include <aes.h>
#include <vdi.h>
#include <falcon.h>

#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

#ifdef SOZOBON
#include <macros.h>		/* FÅr min() und max() */
#endif

#include "stunedef.h"
#include "gebaeude.h"
#include "level.h"

#include "stedinit.h"
#include "stedgraf.h"
#include "sted_aes.h"
#include "steddisk.h"


#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif


/* **Variablen:** */
int vhndl;                              /* VDI-Handle */
int deskx, desky, deskw, deskh;         /* Desktopausmaûe */
int wihndl;                             /* Fenster-Handle */
GRECT wi;                               /* Fenster-Koordinaten */
int mausx, mausy, mausk, klicks;        /* Zur Mausabfrage */
int kstate, key;                        /* Zur Tastaturabfrage */
int msgbuf[8];                          /* Der Nachrichtenbuffer */
char infostr[20];						/* Fensterinfostring */
char xinfo[]=" X=___"; char yinfo[]=" Y=___", finfo[]=" Typ=___";

MFDB scrnmfdb={0L, 0, 0, 0, 0, 0, 0, 0, 0}; /* Der MFDB fÅr'n Bildschirm */
MFDB offscr;                            /* Offscreen-MFDB */
MFDB bodenfdb;                          /* FÅr die Bodengrafik */
MFDB einhfdb;                           /* FÅr die Einheitengrafik */
int bipp;                               /* Bits per pixel */
int newpal[16][3]=
{ 1000,1000,1000, 0,0,0, 1000,0,0, 0,1000,0, 0,0,1000, 0,1000,1000,
    800,800,0, 800,600,400, 730,730,730, 523,523,523, 660,0,0, 0,660,0,
    0,0,660, 0,660,660, 660,660,0, 660,0,660}; /* Die neue Palette */

int endeflag=FALSE;                     /* TRUE=Spiel verlassen */

SPIELFELD sfeld[128][128];              /* Das Spielfeld */
short rwx=0, rwy=0;                     /* Ab diesem Planquadrat beginnt das Fenster */
short rww=18, rwh=9;                    /* Aktuelle Fenstergrîûe (in Planquadraten) */
short r_width=56, r_height=40;          /* Raumausmaûe */
short tech_level=9;
short lvl_type=0;
unsigned long lvlid;

unsigned char acttile=0;				/* AusgewÑhlter Bodentyp */
unsigned char actges=0;                 /* AusgewÑhlte Gesinnung */
short smodus=0;							/* 0=Feld editieren; 1=Typ auswÑhlen */
short tmodus=0;                         /* 0=Feld; 1=GebÑude; 2=Einheiten; */
GEB_D gebaeude_typ[13];                 /* die verschiedenen Typen */

LEVEL_EINTRAG en[256];                  /* GebÑude, Einheiten, etc. */
int en_anz=0;                           /* Anzahl der EintrÑge */
int knete[2]={10000, 10000};            /* Geld d. Compis und eigenes */



/* ***Wird benîtigt, um gebaeude.o einzubinden:*** */
short llgeb, lleinh;
GEBAEUDE geb[100];
EINHEIT einheiten[256];
short ak_art;
short netflag;
unsigned short geb_verl[2];
int id_suchen() { return 0; };
int id_suchen_einh() { return 0; };
int nummer_ermitteln() {return 0; };
void einheit_initialisieren() {};
void einheit_entfernen() {};
void angriffe_abschalten() {};
void gebaeude_wieder_aufbauen() {};
void setslidnmarker() {};




/* ***Die Hauptroutine*** */
int main(void)
{
 short wichevnt;
 short dx,dy; /* Dummyvariablen fÅr die Initialisation */

 gebaeude_definieren();

 /* Pfad ermitteln: */
 fpath[0]='A'+Dgetdrv(); fpath[1]=':';
 Dgetpath(&fpath[2], 0); strcat(fpath, "\\");

 if( initGEM() )  return(-1);

 if( initgraf() )  { form_alert(1, "[3][Fehler bei der|Grafikinitialisation][Ok]"); exitGEM(); return(-1); }

 if( open_window() )    { exitGEM(); return(-1); }

 /* Feld vorbelegen */
 for(dy=0; dy<128; dy++)
  for(dx=0; dx<128; dx++)
   {
    sfeld[dx][dy].feldtyp=1;
    sfeld[dx][dy].befahrbar=TRUE;
    sfeld[dx][dy].begehbar=TRUE;
    sfeld[dx][dy].besetzt=FALSE;
    sfeld[dx][dy].ertrag=0;
   }

 drawoffscr(rwx, rwy, rww, rwh);
 drwindow(&wi);

 /* Die Hauptschleife: */
 do
 {
  wichevnt=evnt_multi(MU_TIMER|MU_MESAG|MU_BUTTON|MU_KEYBD, 0x102, 3, 0,0,0,0,0,0,0,0,0,0,0,
             msgbuf, 600, 0, &mausx, &mausy, &mausk, &kstate, &key, &klicks);

  if(mausx>wi.g_x && mausx<wi.g_x+wi.g_w-1 && mausy>wi.g_y && mausy<wi.g_y+wi.g_h-1)
   {
    if(smodus==0)
     {
      unsigned short destx=(mausx-wi.g_x)/16+rwx, desty=(mausy-wi.g_y)/16+rwy;
	  itoa(destx, &xinfo[3], 10);
	  itoa(desty, &yinfo[3], 10);
	  strcpy(infostr, xinfo);	strcat(infostr,yinfo);
	  wind_set(wihndl, WF_INFO, infostr, 0L);
      if((wichevnt & MU_BUTTON) && mausk==1)  /* Ins Spielfeld geklickt? */
       {
        GRECT drc;
        int f, x,y;
        switch(tmodus)
         {
          case 0:
            if( sfeld[destx][desty].feldtyp<32 )
             {
              sfeld[destx][desty].feldtyp=acttile;
/*
//              sfeld[destx][desty].ertrag=0;
//              if(acttile==2 || acttile==3) sfeld[destx][desty].ertrag=1;
//              if(acttile==4 || acttile==5) sfeld[destx][desty].ertrag=2;
//              if(acttile==6 || acttile==7) sfeld[destx][desty].ertrag=3;
//              if(acttile>=16)
//               {
//                sfeld[destx][desty].befahrbar=FALSE;
//                sfeld[destx][desty].begehbar=FALSE;
//               }
//               else
//               {
//                sfeld[destx][desty].befahrbar=TRUE;
//                sfeld[destx][desty].begehbar=TRUE;
//               }
*/
             }
            drawoffscr(destx, desty, 1, 1);
            drc.g_x=((mausx-wi.g_x)&0xFFF0)+wi.g_x;
            drc.g_y=((mausy-wi.g_y)&0xFFF0)+wi.g_y;
            drc.g_w=drc.g_h=16;
            drwindow(&drc);
            break;
          case 1:
            f=FALSE;
            for(x=destx; x<(int)destx+gebaeude_typ[acttile].groesse; x++)
             for(y=desty; y<(int)desty+gebaeude_typ[acttile].groesse; y++)
              if(sfeld[x][y].besetzt) f=TRUE;
            if( f ) break;
            en[en_anz].typ=0;
            en[en_anz].art=acttile;
            en[en_anz].xpos=destx;  en[en_anz].ypos=desty;
            en[en_anz].ges=actges;
            ++en_anz;
            setgebaeude(acttile, destx, desty, actges);
            drc.g_x=((mausx-wi.g_x)&0xFFF0)+wi.g_x;
            drc.g_y=((mausy-wi.g_y)&0xFFF0)+wi.g_y;
            drc.g_w=drc.g_h=48;
            drwindow(&drc);
            break;
          case 2:
            if( sfeld[destx][desty].besetzt )  break;
            en[en_anz].typ=1;
            en[en_anz].art=acttile;
            en[en_anz].xpos=destx;  en[en_anz].ypos=desty;
            en[en_anz].ges=actges;
            ++en_anz;
            sfeld[destx][desty].besetzt=1;
/*
//            sfeld[destx][desty].befahrbar=FALSE;
//            sfeld[destx][desty].begehbar=FALSE;
//            sfeld[destx][desty].besetzertyp=1;
//            sfeld[destx][desty].gesinnung=actges;
*/
            drawoffscr(destx, desty, 1, 1);
            drc.g_x=((mausx-wi.g_x)&0xFFF0)+wi.g_x;
            drc.g_y=((mausy-wi.g_y)&0xFFF0)+wi.g_y;
            drc.g_w=drc.g_h=16;
            drwindow(&drc);
            break;
          case 3:
            for( f=0; f<en_anz; f++ )
             if( (en[f].typ==1 && en[f].xpos==destx && en[f].ypos==desty)
                || (en[f].typ==0 && destx>=en[f].xpos && destx<en[f].xpos+gebaeude_typ[en[f].art].groesse
                    && desty>=en[f].ypos && desty<en[f].ypos+gebaeude_typ[en[f].art].groesse) )
              {
               if(en[f].typ==1)
                {
                 /*sfeld[destx][desty].befahrbar=TRUE; sfeld[destx][desty].begehbar=TRUE;*/
                 sfeld[destx][desty].besetzt=FALSE;
                }
                else
                {
                 for(x=en[f].xpos; x<(int)en[f].xpos+gebaeude_typ[en[f].art].groesse; x++)
                  for(y=en[f].ypos; y<(int)en[f].ypos+gebaeude_typ[en[f].art].groesse; y++)
                   {
                    sfeld[x][y].feldtyp=1; sfeld[x][y].ertrag=0;
                    /*sfeld[x][y].befahrbar=TRUE; sfeld[x][y].begehbar=TRUE;*/
                    sfeld[x][y].besetzt=FALSE;
                   }
                 x=gebaeude_typ[en[f].art].groesse;
                 drawoffscr(en[f].xpos,en[f].ypos,x,x);
                }
               x=en[f].xpos; y=en[f].ypos;
               if( f != en_anz-1 )
                 memcpy(&en[f], &en[en_anz-1], sizeof(LEVEL_EINTRAG));
               --en_anz;
               drawoffscr(x,y,1,1);
               drc.g_x=(x-rwx)*16+wi.g_x;
               drc.g_y=(y-rwy)*16+wi.g_y;
               drc.g_w=drc.g_h=48;
               drwindow(&drc);
              }
            break;
         }
       }
     }
     else
     {
      unsigned short desttile;
      desttile=(mausy-wi.g_y)/16*rww+(mausx-wi.g_x)/16;
      if(tmodus==0 && desttile>=32) desttile=0;
      if(tmodus==1)
       {
        desttile=(mausy-wi.g_y)/48*(rww/3)+(mausx-wi.g_x)/48;
        if(desttile>25)  desttile=0;
        if(desttile>=13)
         { desttile-=13; actges=1; } else actges=0;
       }
      if(tmodus==2)
       {
        if(desttile>=45 || (desttile>=20 && desttile<=24)) desttile=0;
        if(desttile>=25)
         { desttile-=25; actges=1; } else actges=0;
       }
      itoa(desttile, &finfo[5], 10);
      wind_set(wihndl, WF_INFO, finfo, 0L);
      if((wichevnt & MU_BUTTON) && mausk==1)
       {
        acttile=desttile;
		wichevnt|=MU_BUTTON; mausk=2;	/* Modus wechseln (s.u.) */
	   }
     }
   }

  if( tmodus<3 && ( ((wichevnt & MU_BUTTON) && mausk==2)
     || ((wichevnt & MU_KEYBD) && ((char)key)==' ')) ) 	/* Modus wechseln? */
   {
    smodus^=1;
    do graf_mkstate(&mausx, &mausy, &mausk, &kstate); while(mausk);
    if(smodus==0)
     {
      wind_set(wihndl, WF_INFO, " Spielfeld editieren", 0L);
	  wind_set(wihndl, WF_HSLIDE, (int)((long)rwx*1000L/(r_width-rww)), 0, 0L);
	  wind_set(wihndl, WF_VSLIDE, (int)((long)rwy*1000L/(r_height-rwh)), 0, 0L);
	  wind_set(wihndl, WF_HSLSIZE, (int)((long)rww*1000L/r_width), 0, 0L);
	  wind_set(wihndl, WF_VSLSIZE, (int)((long)rwh*1000L/r_height), 0, 0L);
     }
     else
     {
      switch(tmodus)
       {
        case 0:  wind_set(wihndl, WF_INFO, " Bodentyp auswÑhlen", 0L); break;
        case 1:  wind_set(wihndl, WF_INFO, " GebÑude auswÑhlen", 0L); break;
        case 2:  wind_set(wihndl, WF_INFO, " Einheit auswÑhlen", 0L); break;
       }
	  wind_set(wihndl, WF_HSLIDE, 1, 0, 0L);
	  wind_set(wihndl, WF_VSLIDE, 1, 0, 0L);
	  wind_set(wihndl, WF_HSLSIZE, 1000, 0, 0L);
	  wind_set(wihndl, WF_VSLSIZE, 1000, 0, 0L);
     }
    drwindow(&wi);
   }

  if(wichevnt & MU_MESAG)
    mesages();

  if(wichevnt & MU_KEYBD)
    keyklicks();

 }
 while( !endeflag );

 close_window();
 exitGEM();

 return(0);
}
