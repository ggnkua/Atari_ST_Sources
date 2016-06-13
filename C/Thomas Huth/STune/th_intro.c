/**
 * STune - The battle for Aratis
 * th_intro.c : A little "starwars" scroller.
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

#include <stdlib.h>
#include <string.h>
#include <osbind.h>

#include "stunegem.h"
#include "stunmain.h"
#include "th_aesev.h"
#include "th_graf.h"
#include "windial.h"

#ifndef DBLACK
#define DBLACK 9
#define DWHITE 8
#endif

#define rand() Random()

#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif

#ifndef NULL
#define NULL 0L
#endif


int iwh;                  /* Fensterhandle */
GRECT iwrct;              /* Fensterkoordinaten */

int introendeflag;        /* Falls TRUE -> Intro beenden */
char **scrtxt;
int actst;

char *introtxt[]=
{
 "DER WELTRAUM, UNENDLICHE WEITEN!",
 "IM UNIVERSUM HERRSCHT KRIEG. DAS",
 "MACROSAFT-IMPERIUM BEDROHT DAS",
 "SONNENSYSTEM BONI OSI. AUF DEN",
 "DORTIGEN PLANETEN HABEN SICH JE-",
 "DOCH REBELLIONEN GEBILDET, DIE",
 "NUR EIN ZIEL HABEN",
 " - MACROSAFT ZU VERTREIBEN! -",
 "",
 "DU BIST NUN ANFUEHRER DER RE-",
 "BELLION AUF DEM STEPPENPLANE-",
 "TEN ARATIS. WIRD ES DIR GELINGEN",
 "DAS MACROSAFT-IMPERIUM ZU BE-",
 "KAEMPFEN UND VON DEINEM HEIMAT-",
 "PLANETEN ZU VERTREIBEN?",
 NULL
};

char *greetinx[]=
{
 "           GREETINGS",
 "      -IN RANDOM ORDER-",
 "             GO TO:",
 "",
 "           ATARI.ORG",
 "             ESCAPE",
 "            PARANOIA",
 "              DHS",
 "             NOCREW",
 "              TSCC",
 "",
 "           BITMASTER",
 "         THOMAS KERKLOH",
 "         BERND MAEDICKE",
 "          DAN ACKERMAN",
 "       GUILLAUME DEFLACHE",
 "          RAFAL KAWECKI",
 "          FREDRIK OLSSON",
 "          ADAM PERGLER",
 "       STANISLAV OPICHALS       ",
 "            MILHOUSE",
 "    AND ALL THE PEOPLE OF THE",
 "      IRC CHANNELS ATARI.DE",
 "          AND ATARISCNE",
 "",
 " AND OF COURSE TO ALL WE FORGOT",
 "        HERE - SORRY THEN.",
 NULL
};


/* Anfangs-z-Wert einer Linie: */
#define LSTARTZ  92

/* Anzahl der Linien: */
#define LINIEN 5

/* Anzahl der Sterne: */
#define STERNE 20

struct
{
 int x,y,z;
 int oldx, oldy, oldz;
} stars[STERNE];

int oixy[LINIEN][32][4][32];
int oldp[LINIEN][32][4];
int nextoixy[LINIEN][32][4][32];
int nextoldp[LINIEN][32][4];


const short vletterA[]={ 0,0, 7,15, 14,0, -2,-2, 3,6, 12,6, -1,-1 };
const short vletterB[]={ 1,0, 1,15, 13,13, 13,9, 1,8, 13,6, 13,2, 1,0, -1,-1 };
const short vletterC[]={ 13,12, 9,15, 5,15, 0,10, 0,5, 5,0, 9,0, 13,3, -1,-1 };
const short vletterD[]={ 0,0, 0,15, 8,14, 12,11, 12,3, 8,1, 0,0, -1,-1 };
const short vletterE[]={ 13,15, 1,15, 1,0, 13,0, -2,-2, 1,7, 8,7, -1,-1 };
const short vletterF[]={ 7,0, 7,15, -2,-2, 0,15, 14,15, -2,-2, 2,8, 12,8, -1,-1 };
const short vletterG[]={ 13,12, 7,15, 0,11, 0,4, 7,0, 14,3, 14,7, 7,7, -1,-1 };
const short vletterH[]={ 0,0, 0,15, -2,-2, 14,0, 14,15, -2,-2, 0,7, 14,7, -1,-1 };
const short vletterI[]={ 7,0, 7,15, -2,-2, 3,0, 11,0, -2,-2, 3,15, 11,15, -1,-1 };
const short vletterJ[]={ 12,15, 12,3, 7,0, 2,3, -1,-1 };
const short vletterK[]={ 2,0, 2,15, -2,-2, 12,0, 2,7, 12,15, -1,-1 };
const short vletterL[]={ 2,15, 2,0, 13,0, -1,-1 };
const short vletterM[]={ 0,0, 0,15, 7,6, 14,15, 14,0, -1, -1 };
const short vletterN[]={ 1,0, 1,15, 14,0, 14,15, -1,-1 };
const short vletterO[]={ 0,4, 0,11, 7,15, 14,11, 14,4, 7,0, 0,4, -1,-1 };
const short vletterP[]={ 1,0, 1,15, 13,15, 13,7, 1,7, -1,-1 };
const short vletterQ[]={ 0,4, 0,11, 7,15, 14,11, 14,4, 7,0, 0,4, -2,-2, 13,0, 8,4, -1,-1 };
const short vletterR[]={ 1,0, 1,15, 13,15, 13,7, 1,7, 13,0, -1,-1 };
const short vletterS[]={ 2,4, 5,0, 9,0, 12,4, 9,7, 5,8, 2,11, 5,15, 9,15, 12,11, -1,-1 };
const short vletterT[]={ 1,15, 13,15, -2,-2, 7,15, 7,0, -1,-1 };
const short vletterU[]={ 1,15, 1,4, 3,1, 7,0, 11,1, 13,4, 13,15, -1,-1 };
const short vletterV[]={ 0,15, 7,0, 14,15, -1,-1 };
const short vletterW[]={ 0,15, 1,0, 7,6, 13,0, 14,15, -1,-1 };
const short vletterX[]={ 0,0, 14,15, -2,-2, 0,15, 14,0, -1,-1 };
const short vletterY[]={ 7,7, 7,0, -2,-2, 0,15, 7,7, 14,15, -1,-1 };
const short vletterZ[]={ 0,15, 14,15, 0,0, 14,0, -1,-1 };
const short vziffer1[]={ 3,8, 11,15, 11,0, -1,-1 };
const short vziffer9[]={ 2,0, 13,0, 13,15, 2,15, 2,7, 13,7, -1,-1 };
const short vpunkt[]={ 6,0, 6,1, 7,1, 7,0, -1,-1 };
const short vkomma[]={ 6,0, 7,3, -1,-1 };
const short vstrich[]={ 1,7, 13,7, -1,-1 };
const short vausruf[]={ 7,0, 7,1, 8,1, 8,0, -2,-2, 7,4, 5,15, 9,15, 7,4, -1,-1 };
const short vfragez[]={ 7,0, 7,1, 8,1, 8,0, -2,-2, 3,11, 7,15, 11,11, 3,6, 7,3, 11,6, -1,-1 };

const short *abc[]=    /* Zuordnung ASCII-Code (ab 32) -> Vektorgrafik */
{
 NULL, vausruf, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, NULL, NULL, NULL, vkomma, vstrich, vpunkt, NULL,
 NULL, vziffer1, NULL, NULL, NULL, NULL, NULL, NULL,
 NULL, vziffer9, NULL, NULL, NULL, NULL, NULL, vfragez, NULL,
 vletterA, vletterB, vletterC, vletterD, vletterE, vletterF,
 vletterG, vletterH, vletterI, vletterJ, vletterK, vletterL, vletterM,
 vletterN, vletterO, vletterP, vletterQ, vletterR, vletterS,
 vletterT, vletterU, vletterV, vletterW, vletterX, vletterY, vletterZ,
};


struct
{
 char *text;
 int z;
} scrolline[LINIEN];



/* *** Text und Sterne weiterbewegen *** */
void intro_move(void)
{
 int i, z, p, b;
 char c;
 int *oldpptr, *noldpptr;

 for(i=0; i<LINIEN; i++)
  {
	scrolline[i].z+=2;
	z=scrolline[i].z;

	for(b=0; b<32; b++)
	 {
	  if( b<(int)strlen(scrolline[i].text) )
		 c=(char)((scrolline[i].text[b])-32);
		else
		 c=0;
	  if( abc[c]!=NULL )
       {
        oldpptr = &oldp[i][b][0];
        noldpptr = &nextoldp[i][b][0];
        p = *noldpptr++;
        *oldpptr++ = p;
        memcpy(&oixy[i][b][0][0], &nextoixy[i][b][0][0], 2*p*sizeof(int) );
        p = *noldpptr++;
        *oldpptr++ = p;
        memcpy(&oixy[i][b][1][0], &nextoixy[i][b][1][0], 2*p*sizeof(int) );
        p = *noldpptr++;
        *oldpptr++ = p;
        memcpy(&oixy[i][b][2][0], &nextoixy[i][b][2][0], 2*p*sizeof(int) );
        p = *noldpptr;
        *oldpptr = p;
        memcpy(&oixy[i][b][3][0], &nextoixy[i][b][3][0], 2*p*sizeof(int) );
      }
	 }

	if( z>=(LINIEN*32+2+LSTARTZ) )
	 {
	  scrolline[i].z=LSTARTZ;
	  if( scrtxt[actst]!=NULL )
		{
		 scrolline[i].text=scrtxt[actst];
		 ++actst;
		}
		else
		{
		 scrolline[i].text="";
		}
      for(b=0; b<32; b++)
        oldp[i][b][0]=oldp[i][b][1]=oldp[i][b][2]=oldp[i][b][3]=0;
	 }

  }

 /* Sterne bewegen: */
 for(i=0; i<STERNE; i++)
  {
    stars[i].oldz = stars[i].z;
    stars[i].oldx = stars[i].x;
    stars[i].oldy = stars[i].y;
    stars[i].z -= 10;
	if( stars[i].z<40 )
	 {
	  stars[i].x=(int)(rand()&0x03FF)-512;
	  stars[i].y=(int)(rand()&0x03FF)-512;
	  stars[i].z=800;
	 }
  }

}


/* **** Zeichenfunktion **** */
void intro_draw(void)
{
 int i, z, b, k, p;
 int qw, qz;
 long qh;
 char c;
 int mx, my;
 long max_w, max_h;
 int ixy[32];
 int anz;

 max_w=iwrct.g_w/2-1;       /* Breite */
 max_h=iwrct.g_h/2-1;       /* H”he */
 mx=iwrct.g_x+iwrct.g_w/2;  /* X-Mittelpunkt */
 my=iwrct.g_y+iwrct.g_h/3;  /* Y-Mittelpunkt */
 qh=max_h*128;

 /* Textlinien: */
 for(i=0; i<LINIEN; i++)
  {
	z=scrolline[i].z;
	for(b=0; b<32; b++)
	 {
	  if( b<(int)strlen(scrolline[i].text) )
		 c=(char)((scrolline[i].text[b])-32);
		else
		 c=0;
	  if( abc[c]!=NULL )
       {
        qw=(b-16)*16;
        k=0;
        anz=0;
        vsl_color(vhndl, BLACK);       /* Alten Buchstaben l”schen */
		while( (*(abc[c]+k))!=-1 )
		 {
          p = oldp[i][b][anz];
          k += p*2;
		  if(p>0)
		    v_pline(vhndl, p, oixy[i][b][anz]);
		  if( (*(abc[c]+k))!=-1 ) k+=2;
		  ++anz;
		 }
	    k=0;
        anz=0;
	    if( z<146 )                     /* Neuen Buchstaben zeichnen */
	      vsl_color(vhndl, WHITE);
	     else
          {
           if( z>208 )
             vsl_color(vhndl, DBLACK);
            else
             vsl_color(vhndl, DWHITE);
           if( z>=(LINIEN*32+LSTARTZ) )
            vsl_color(vhndl, BLACK);
          }
        nextoldp[i][b][0]=nextoldp[i][b][1]=
        nextoldp[i][b][2]=nextoldp[i][b][3]=0;
		while( (*(abc[c]+k))!=-1 )
		 {
		  static int *dxyptr1, *dxyptr2;
		  p=0;
          dxyptr1=dxyptr2=nextoixy[i][b][anz];
		  while( (*(abc[c]+k))>=0 )
			{
			 qz=z+(*(abc[c]+k+1));
			 *dxyptr2++=mx+( max_w * ( qw+(*(abc[c]+k)) ) )/2/qz;
			 *dxyptr2++=my+qh/qz;
			 p+=1;
			 k+=2;
			}
		  if(p>0)
		    v_pline(vhndl, p, dxyptr1);
		  nextoldp[i][b][anz]=p;
          ++anz;
		  if( (*(abc[c]+k))!=-1 ) k+=2;
		 }
       }

	 }
  }

 /* Sterne zeichnen: */
 for(i=0; i<STERNE; i++)
  {
	z = stars[i].oldz;
	ixy[0]=mx+( max_w * stars[i].oldx )/2/z;
	ixy[1]=my+( max_h * stars[i].oldy )/2/z;
	vsm_color(vhndl, BLACK);
	v_pmarker(vhndl, 1, ixy); /* Alten Stern loeschen */
    z = stars[i].z;
	ixy[0]=mx+( max_w * stars[i].x )/2/z;
	ixy[1]=my+( max_h * stars[i].y )/2/z;
	if( z<220 )
	  vsm_color(vhndl, WHITE);
	 else
	  {
		if( z>380 )
		  vsm_color(vhndl, DBLACK);
		 else
		  vsm_color(vhndl, DWHITE);
	  }
	v_pmarker(vhndl, 1, ixy);
  }

}



/* **** Scroller-Init + Start **** */
void intro_start(char **newtxt)
{
 int i,j;

 for(i=0; i<LINIEN; i++)
  {
   scrolline[i].text="";
   scrolline[i].z=LSTARTZ+i*32+28;
   for(j=0; j<32; j++)
    oldp[i][j][0]=oldp[i][j][1]=oldp[i][j][2]=oldp[i][j][3]=0;
  }
 actst=0;
 scrtxt=newtxt;

 for(i=0; i<STERNE; i++)
  {
   stars[i].x=stars[i].oldx=(int)(rand()&0x03FF)-512;
   stars[i].y=stars[i].oldy=(int)(rand()&0x03FF)-512;
   stars[i].z=stars[i].oldz=(rand()&0x03FF)+60;
  }
}


/* **** Scroller Hauptschleife **** */
void intro_main(void)
{
 int wichevnt, i;
 GRECT clip;

 /* Fenster vorbereiten: */
 if(!fullscrflag)
  {
   iwh=wind_create(CLOSER|FULLER|SIZER|MOVER|NAME, deskx, desky, deskw, deskh);
   wind_set_str(iwh, WF_NAME, "STune");
   iwrct.g_w=deskw/8*5;   iwrct.g_h=deskh/8*5;
   iwrct.g_x=deskx+(deskw-iwrct.g_w)/2;
   iwrct.g_y=desky+(deskh-iwrct.g_h)/2;
   wind_open(iwh, iwrct.g_x, iwrct.g_y, iwrct.g_w, iwrct.g_h);
   wind_get(iwh, WF_WORKXYWH, &iwrct.g_x, &iwrct.g_y, &iwrct.g_w, &iwrct.g_h);
  }
  else
  {
   iwh=0;
   iwrct.g_x=iwrct.g_y=0;
   iwrct.g_w=scrwidth;  iwrct.g_h=scrheight;
  }

 vsm_type(vhndl, 1);      /* Punkt als Marker */
 vsf_color(vhndl, 1);

 introendeflag=FALSE;

 if(fullscrflag)
  {
   graf_mouse(M_OFF, 0L);
   vsf_color(vhndl, 1);
   v_bar(vhndl, deskclip);
  }

 /* Hauptschleife: */
 do
  {
   wichevnt=evnt_multi(MU_TIMER|MU_KEYBD|(fullscrflag?0:MU_MESAG),
             1, 3, 0, 0,0,0,0,0, 0,0,0,0,0,
             msgbuf, 1, 0, &i, &i, &i, &i, &i, &i);

   if( wichevnt & MU_TIMER )
    {
     if(fullscrflag)
       clip=iwrct;
      else
      {
       wind_get(iwh, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
       wind_update(BEG_UPDATE);
      }
     while(clip.g_w!=0 && clip.g_h!=0)
      {
       if( rc_intersect(&iwrct, &clip) )
        {
         clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
         vs_clip(vhndl, 1, (int *)&clip);
         intro_draw();
        }
       if(fullscrflag)
         clip.g_w=clip.g_h=0;
        else
         wind_get(iwh, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
      }
     if(!fullscrflag)  wind_update(END_UPDATE);
     intro_move();
    }

   if( wichevnt & MU_KEYBD )
    introendeflag=TRUE;

   if( wichevnt & MU_MESAG )
    {
     switch(msgbuf[0])
      {
       case WM_REDRAW:
         wind_get(iwh, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
 	     wind_update(BEG_UPDATE);
         graf_mouse(M_OFF, 0L);
         vs_clip(vhndl, 0, (int *)&clip);
         while(clip.g_w!=0 && clip.g_h!=0)
          {
           if( rc_intersect((GRECT *)&msgbuf[4], &clip) )
            {
             clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
             /*vs_clip(vhndl, 1, (int *)&clip);*/
             v_bar(vhndl, (int *)&clip);
             /*intro_draw();*/
            }
           wind_get(iwh, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
          }
         graf_mouse(M_ON, 0L);
         wind_update(END_UPDATE);
         break;
       case WM_TOPPED:
         wind_set(msgbuf[3], WF_TOP, 0,0,0,0);
         break;
       case WM_CLOSED:
         introendeflag=TRUE;
         break;
       case WM_FULLED:
         wind_get(msgbuf[3], WF_FULLXYWH, &msgbuf[4], &msgbuf[5], &msgbuf[6], &msgbuf[7]);
       case WM_MOVED:
       case WM_SIZED:
         wind_set(msgbuf[3], WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
         wind_get(iwh, WF_WORKXYWH, &iwrct.g_x, &iwrct.g_y, &iwrct.g_w, &iwrct.g_h);
         break;
      }
    }

  }
 while(!introendeflag);

 if(fullscrflag)
  {
   if(in_game_flag)
    {
     drwindow(&wi);
     drwmwind(&mwi);
    }
    else
    {
     vsf_color(vhndl, 1);
     v_bar(vhndl, deskclip);
    }
   graf_mouse(M_ON, 0L);
  }
  else
  {
   wind_close(iwh);
   wind_delete(iwh);
  }
}

