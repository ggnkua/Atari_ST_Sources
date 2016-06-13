/**
 * STune - The battle for Aratis
 * th_graf.c : Sprites and other graphics functions.
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
#include <stdio.h>
#include <string.h>

#include "stunegem.h"
#include "stunmain.h"
#include "st_debug.h"
#include "th_aesev.h"
#include "th_init.h"
#include "windial.h"

#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif

#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<(b)?(a):(b))


/* Noetige Prototypen: */
void drwindow(GRECT *xywh);


/* Variablen: */
int newpal[256][3];
MFDB scrnmfdb={0L, 0,0,0,0,0,0,0,0};  /* Der MFDB fuer'n Bildschirm */
MFDB offscr;                          /* Offscreen-MFDB */
MFDB bodenfdb;                        /* FÅr die Bodengrafik */
MFDB einhfdb;                         /* FÅr die Grafik der Einheiten */
MFDB einhmask;                        /* Maskendaten fÅr die Einheiten-Sprites */
MFDB panelfdb;                        /* FÅr die Steuertafel */
MFDB infogfxfdb;                      /* FÅr Steuertafel (Ausgangsgrafik) */
char energiegfx[16*2*4];              /* Genug Platz fÅr 16*2 in 32 bit Grafiken */
MFDB energiefdb;
int bipp;                             /* Bits per pixel */

char *gebname[26];        /* Gebaeudenamen */
char *einhname[50];       /* Einheitennamen */

char *meldungen[8]={NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL};
short meldunganz=0;

int deskclip[4];       /* Fuers Clipping auf die Desktopgroesse */
int windowsareopen;    /* Flag, ob Windows schon geoeffnet */
int screen_opened;     /* Wurde Ausgabe-Screen schon initialisiert? siehe open_window() */



/* ***Palette setzen*** */
void setpal(int palette[][3])
{
 register int i;
 int work_out[57];

 vq_extnd(vhndl, 0, work_out);

 for(i=0; i<work_out[13]; i++)
  {
   vs_color(vhndl, i, &palette[i][0]);
  }
}


/* *** Briefing zeichnen *** */
void drawbriefing(short wh, GRECT *wrct, GRECT *crct, char **lines, int line, int maxlin)
{
 GRECT clip;
 int i, cw, ch;

 vst_color(vhndl, 3);
 graf_handle(&cw, &ch, &i, &i);

 if(fullscrflag)
  {
   clip.g_x=clip.g_y=0;
   clip.g_w=scrwidth;  clip.g_h=scrheight;
  }
  else
  {
   wind_update(BEG_UPDATE);
   wind_get(wh, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
  }
 graf_mouse(M_OFF, 0L);

 while(clip.g_w!=0 && clip.g_h!=0)
 {
  if( rc_intersect(crct, &clip) )
   {
    clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
    vs_clip(vhndl, 1, (int *)&clip);
    vswr_mode(vhndl, 1);
    vsf_color(vhndl, 1);
    v_bar(vhndl, (int *)&clip);
    vswr_mode(vhndl, 2);
    vsf_color(vhndl, 3);
    for(i=line; i<maxlin && i<line+wrct->g_h/ch-2; i++)
     v_justified(vhndl, wrct->g_x+cw, wrct->g_y+(i-line+1)*ch, lines[i], wrct->g_w-2*cw, 1,0);
   }
  if(fullscrflag)
    clip.g_w=clip.g_h=0;
   else
    wind_get(wh, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
 }
 vs_clip(vhndl, gclipflag, deskclip);

 graf_mouse(M_ON, 0L);
 if(!fullscrflag)
   wind_update(END_UPDATE);
}

/* *** Briefing-Fenster *** */
void briefing(char *titel, char *btext)
{
 short wh, wichevnt;
 char *tbuf, *endptr, *aktptr, *dptr;
 char wtitel[48];
 GRECT wrct, crct;
 short brflag=FALSE, crnlflag=FALSE;
 int i, j, l, cw, ch;
 char *lines[128];
 int xy[8];
 const int wgadgets=CLOSER|NAME/*|MOVER|VSLIDE*/|UPARROW|DNARROW;

 enablemenu(0);

 btext=btext+10;  /* "textstart" Åberspringen */
 endptr=strstr(btext, "textend"); /* Pointer aufs Textende */
 if(endptr==NULL) return;

 strcpy(wtitel, "Briefing: ");
 strcat(wtitel, titel);

 if( appl_xgetinfo(0, &ch, &i, &i, &i)==0 );
  {
   int dh1, dh2;
   graf_handle(&i, &dh1, &i, &dh2);
   for(i=6; i<=dh2; i++)
    {
     vst_point(vhndl, i, &j, &j, &j, &ch);
     if(ch==dh1)  /* Richtige Zeichensatzgrîûe finden... grr... */
      break;
    }
   ch=i;
  }
 vst_point(vhndl, ch, &i, &j, &cw, &ch);

 if(!fullscrflag)
  {
   wh=wind_create(wgadgets, deskx, desky, deskw, deskh);
   wind_set_str(wh, WF_NAME, wtitel);
   wind_calc(WC_WORK, wgadgets, deskx,desky,deskw,deskh, &wrct.g_x,&wrct.g_y,&wrct.g_w,&wrct.g_h);
   wrct.g_w=wrct.g_w/16*15; wrct.g_w-=wrct.g_w%cw;
   wrct.g_h=wrct.g_h/16*15; wrct.g_h-=wrct.g_h%ch;
   wind_calc(WC_BORDER, wgadgets, wrct.g_x,wrct.g_y,wrct.g_w,wrct.g_h, &wrct.g_x,&wrct.g_y,&wrct.g_w,&wrct.g_h);
   wrct.g_x=deskx+(deskw-wrct.g_w)/2;
   wrct.g_y=desky+(deskh-wrct.g_h)/2;
   wind_open(wh, wrct.g_x, wrct.g_y, wrct.g_w, wrct.g_h);
   wind_get(wh, WF_WORKXYWH, &wrct.g_x, &wrct.g_y, &wrct.g_w, &wrct.g_h);
  }
  else
  {
   wh=0;
   wrct.g_x=wrct.g_y=0;
   wrct.g_w=scrwidth;  wrct.g_h=scrheight;
  }

 tbuf=malloc( (size_t)(endptr-btext+128) );
 if(tbuf==NULL)
  {
   if(!fullscrflag)
    {
     wind_close(wh);
     wind_delete(wh);
    }
   return;
  }

 aktptr=btext;
 j=0; l=0;
 do
  {
   lines[l++]=&tbuf[j];
   for(i=0; i<wrct.g_w/cw-2 && aktptr<endptr; i++)
    {
     if(*aktptr==' ' || *aktptr=='\r' || *aktptr=='\n')
      {    /* Passt das nÑchste Wort noch in diese Zeile? */
       dptr=aktptr+1;
       while(*dptr!=' ' && *dptr!='\r' && *dptr!='\n' && dptr<endptr) ++dptr;
       if(i+(dptr-aktptr)>=wrct.g_w/cw-2)
        break;
      }
     if(*aktptr!='\r' && *aktptr!='\n')
      {
       if(i>0 || *aktptr!=' ')
        tbuf[j++]=*aktptr;
       ++aktptr;
      }
      else
      {
       if(!crnlflag)
        {
         crnlflag=TRUE;
         if(i>0) tbuf[j++]=' ';
        }
        else crnlflag=FALSE;
       ++aktptr;
      }
    }
   tbuf[j++]=0;
  }
 while(aktptr<endptr); 

 if(fullscrflag)             /* Im Fullscreenmodus direkt zeichnen */
   drawbriefing(0, &wrct, &wrct, lines, 0, l);

 j=0;
 do
  {
   wichevnt=evnt_multi(MU_KEYBD|(fullscrflag?0:MU_MESAG),
             0, 0, 0, 0,0,0,0,0, 0,0,0,0,0,
             msgbuf, 0,0, &i, &i, &i, &kstate, &key, &i);

   if(wichevnt & MU_MESAG)
    {
     switch(msgbuf[0])
      {
       case WM_TOPPED:
         setpal(newpal);
         wind_set(msgbuf[3], WF_TOP, 0,0,0,0);
         break;
       case WM_ONTOP:
         setpal(newpal);
         break;
       case WM_REDRAW:
         crct.g_x=msgbuf[4]; crct.g_y=msgbuf[5];
         crct.g_w=msgbuf[6]; crct.g_h=msgbuf[7];
         drawbriefing(wh, &wrct, &crct, lines, j, l);
         break;
       case WM_ARROWED:
         wichevnt|=MU_KEYBD;
         kstate=key=0;
         if(msgbuf[4]==WA_UPLINE) key=0x4800;
         if(msgbuf[4]==WA_DNLINE) key=0x5000;
         break;
       case AP_TERM:                                     /* Shutdown? */
       case AP_RESCHG:
         exitflag=TRUE;
         endeflag=TRUE;
       case WM_CLOSED:                                   /* Briefing-Ende */
         brflag=TRUE;
         break;
      }
    }

   if(wichevnt & MU_KEYBD)
    {
     char scancode, asciicode;
     scancode=key>>8;
     asciicode=(char)key;
     if(kstate==0)
      {
       if(scancode==0x01 || asciicode=='q') /* ESC oder q */
         brflag=TRUE;
       if(asciicode==' ')
         brflag=TRUE;
       if(scancode==0x48)  /* Cursor hoch */
        {
         if(j>0)
          {
           --j;
           xy[0]=wrct.g_x+cw;  xy[1]=wrct.g_y+ch;
           xy[2]=wrct.g_x+wrct.g_w-cw-1;  xy[3]=wrct.g_y+wrct.g_h-2*ch-1;
           xy[4]=wrct.g_x+cw;  xy[5]=wrct.g_y+2*ch;
           xy[6]=wrct.g_x+wrct.g_w-cw-1;  xy[7]=wrct.g_y+wrct.g_h-ch-1;
           if(!fullscrflag)  wind_update(BEG_UPDATE);
           graf_mouse(M_OFF, 0L);
           vro_cpyfm(vhndl, 3, xy, &scrnmfdb, &scrnmfdb);
           graf_mouse(M_ON, 0L);
           if(!fullscrflag)  wind_update(END_UPDATE);
           crct.g_x=wrct.g_x;  crct.g_y=wrct.g_y+ch;
           crct.g_w=wrct.g_w;  crct.g_h=ch;
           drawbriefing(wh, &wrct, &crct, lines, j, l);
          }
        }
       if(scancode==0x50)  /* Cursor hoch */
        {
         if(j+wrct.g_h/ch-2<l)
          {
           ++j;
           xy[0]=wrct.g_x+cw;  xy[1]=wrct.g_y+2*ch;
           xy[2]=wrct.g_x+wrct.g_w-cw-1;  xy[3]=wrct.g_y+wrct.g_h-ch-1;
           xy[4]=wrct.g_x+cw;  xy[5]=wrct.g_y+ch;
           xy[6]=wrct.g_x+wrct.g_w-cw-1;  xy[7]=wrct.g_y+wrct.g_h-2*ch-1;
           if(!fullscrflag)  wind_update(BEG_UPDATE);
           graf_mouse(M_OFF, 0L);
           vro_cpyfm(vhndl, 3, xy, &scrnmfdb, &scrnmfdb);
           graf_mouse(M_ON, 0L);
           if(!fullscrflag)  wind_update(END_UPDATE);
           crct.g_x=wrct.g_x;  crct.g_y=wrct.g_y+wrct.g_h-2*ch;
           crct.g_w=wrct.g_w;  crct.g_h=ch;
           drawbriefing(wh, &wrct, &crct, lines, j, l);
          }
        }
      }
     if(kstate==K_CTRL)
      {
       if(scancode==0x10) /* CTRL-Q */
         brflag=exitflag=endeflag=TRUE;
      }
    }

  }
 while(!brflag);

 free(tbuf);

 if(fullscrflag)
  {
   vsf_color(vhndl, 1);
   v_bar(vhndl, deskclip);
  }
  else
  {
   wind_close(wh);
   wind_delete(wh);
  }

 vst_color(vhndl, 1);
 vswr_mode(vhndl, 1);

 enablemenu(1);
}





/* ***Karte im Steueroffscreen neu zeichnen*** */
void drawmap(short mox, short moy, short mow, short moh)
{
 short i, j;
 int dxy[8];
 SPIELFELD *aktfeld;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: drawmap() before window-init!\n"));
   return;
 }
#endif

 dxy[1]=dxy[3]=0;

 for(i=mox; i<mox+mow; i++)
  for(j=moy; j<moy+moh; j++)
   {
    if(radarflag)
     {
      aktfeld=&sfeld[i][j];
      if(aktfeld->erforscht)
       {
        if(aktfeld->feldtyp < 32)
          dxy[0]=5;
         else
          if(aktfeld->gesinnung) dxy[0]=3; else dxy[0]=1;
       }
       else dxy[0]=4;
     }
     else dxy[0]=4;
    dxy[2]=dxy[0];
    dxy[4]=dxy[6]=i+(128-r_width)/2;
    dxy[5]=dxy[7]=j;
    vro_cpyfm(vhndl, 3, dxy, &infogfxfdb, &panelfdb);
   }
}


/* ********  ******** */
#if 0
void drawbuildmen(void)
{
/* int xy[8];*/

/* if(mwi.g_h<INFHEIGHT+128+32+48)  return;*/
/* xy[0]=0;   xy[1]=INFHEIGHT+1;
 xy[2]=63;  xy[3]=xy[1]+15;
 xy[4]=mwi.g_x; xy[5]=mwi.g_y;
 vro_cpyfm(vhndl, 3, xy, &xtragfxfdb, &scrnmfdb);
*/
}
#endif


/* ***Steuerpultgrafik/Karte im Fenster aufbauen*** */
void drwmwind(GRECT *xywh)
{
 int i,b;
 GRECT clip;
 int xy[10];
 char enstr[8];

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: drwmwind() before window-init!\n"));
   return;
 }
#endif

#if 0
xy[0]=xywh->g_x; xy[1]=xywh->g_y; xy[2]=xywh->g_x+xywh->g_w-1; xy[3]=xywh->g_y+xywh->g_h-1;
v_pline(vhndl, 2, xy);/*Zum Debuggen: Bereich markieren */
#endif

 i=abs(energie);
 if(i<10)  b=4;
  else
   if(i<100) b=3;
    else
     if(i<1000) b=2;
      else b=1;
 strcpy(enstr, "    ");
 if(energie>0) b-=1;
 sprintf(&enstr[b], "%i", -energie);

 i=0;
 if(fullscrflag)
   if(modaldlgflag) clip=fsdlgclip[0]; else clip=mwi;
  else
  {
   wind_get(mwihndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
   wind_update(BEG_UPDATE);
  }
 graf_mouse(M_OFF, 0L);
 while(clip.g_w!=0 && clip.g_h!=0)
 {
  if( rc_intersect(xywh, &clip) )
   {
    clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
    xy[0]=clip.g_x-mwi.g_x; xy[1]=clip.g_y-mwi.g_y;
    xy[2]=clip.g_w-mwi.g_x; xy[3]=clip.g_h-mwi.g_y;
    xy[4]=clip.g_x; xy[5]=clip.g_y;
    xy[6]=clip.g_w; xy[7]=clip.g_h;
    vro_cpyfm(vhndl, 3, xy, &panelfdb, &scrnmfdb); /* Ins Fenster kopieren */

    vs_clip(vhndl, 1, (int *)&clip);  /* FÅr folgende Operationen Clipping ein! */

    if(clip.g_h>mwi.g_y+statusypos && clip.g_y<mwi.g_y+statusypos+INFHEIGHT)
     {
      vst_point(vhndl, 10, xy, xy, xy, xy);           /* Groûe Fontgrîûe */
      v_gtext(vhndl, mwi.g_x+4, mwi.g_y+2+statusypos, moneystr); /* Geldstand */
      vst_point(vhndl, 9, xy, xy, xy, xy);
      v_gtext(vhndl, mwi.g_x+63, mwi.g_y+61+statusypos, enstr);  /* Gesamtenergie */
      if(ak_art==1 || ak_art==2)                      /* Energiestand + Name anzeigen */
       {
        int en, max_en;
        char *name1, *name2;
        if(ak_art==1)
         {
          en=geb[ak_nr].zustand;
          max_en=gebaeude_typ[geb[ak_nr].art].zustandspunkte;
          name1=gebname[geb[ak_nr].art*2];
          name2=gebname[geb[ak_nr].art*2+1];
         }
         else /* ak_art==2: */
         {
          en=einheiten[ak_nr].zustand;
          max_en=einheit_typ[einheiten[ak_nr].art].zustandspunkte;
          name1=einhname[einheiten[ak_nr].art*2];
          name2=einhname[einheiten[ak_nr].art*2+1];
         }
        xy[0]=mwi.g_x+104;
        xy[2]=xy[0]+15;    xy[3]=mwi.g_y+23+statusypos;
        xy[1]=xy[3]-en*15/max_en;
        vsf_color(vhndl, 4);
        v_bar(vhndl, xy);                               /* Energiezustand der akt. Einh. */
        vst_point(vhndl, 8, xy, xy, xy, xy);            /* Kleine Fontgrîûe */
        v_gtext(vhndl, mwi.g_x+4, mwi.g_y+16+statusypos, name1);   /* Name anzeigen */
        v_gtext(vhndl, mwi.g_x+4, mwi.g_y+24+statusypos, name2);
       }
     }

    if(clip.g_y<mwi.g_y+r_height)      /* Markierung zeichnen */
     {
      vsl_color(vhndl, 2);  /* Markierungsfarbe */
      xy[0]=xy[8]=mwi.g_x+rwx+(128-r_width)/2;   xy[1]=xy[9]=mwi.g_y+rwy;
      xy[2]=mwi.g_x+rwx+rww-1+(128-r_width)/2;   xy[3]=xy[1];
      xy[4]=xy[2];   xy[5]=mwi.g_y+rwy+rwh-1;
      xy[6]=xy[0];   xy[7]=xy[5];
      v_pline(vhndl, 5, xy);
     }

    /*if(clip.g_y+clip.g_h >= mwi.g_y+statusypos+INFHEIGHT)
     {
      drawbuildmen();
     }*/

    vs_clip(vhndl, gclipflag, deskclip);
   } /* rc_intersect */
  if(fullscrflag)
   {
    if(modaldlgflag && i<3)
      clip=fsdlgclip[++i];
     else
      clip.g_w=0;
   }
   else
    wind_get(mwihndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
 } /* while */

 graf_mouse(M_ON, 0L);
 if(!fullscrflag) wind_update(END_UPDATE);
}


/* *** Redraw-Map: Kopiert die Karte aus dem Offscreen ins Fenster *** */
void rdr_map(int x, int y, int w, int h)
{
 GRECT maprect;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: rdr_map() before window-init!\n"));
   return;
 }
#endif

 maprect.g_x=mwi.g_x+x+(128-r_width)/2;
 maprect.g_y=mwi.g_y+y;
 maprect.g_w=w;
 maprect.g_h=h;
 drwmwind(&maprect);
}


/* *** Redraw-Infobar: Einheit-Info im Panel neu zeichnen*** */
void rdr_infobar()
{
 GRECT rect;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: rdr_infobar() before window-init!\n"));
   return;
 }
#endif

 rect.g_x=mwi.g_x;
 rect.g_y=mwi.g_y+statusypos;
 rect.g_w=128;
 rect.g_h=32;
 drwmwind(&rect);
}


/* *** Redraw-Health: Energie einer Einheit im Infofenster auffrischen *** */
void rdr_health()
{
 GRECT rect;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: rdr_health() before window-init!\n"));
   return;
 }
#endif

 rect.g_x=mwi.g_x+104;
 rect.g_y=mwi.g_y+8+statusypos;
 rect.g_w=rect.g_h=16;
 drwmwind(&rect);
}


/* *** Statusanzeige *** */
void aktualize_status(int gbnr)
{
 int i;
 static char prznt[6];
 GRECT clip;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: aktualize_status() before window-init!\n"));
   return;
 }
#endif

 vst_point(vhndl, 9, &i, &i, &i, &i);
 if( geb[gbnr].art==BAUANLAGE )
   i = (int)(geb[gbnr].wie_weit*100L/gebaeude_typ[geb[gbnr].bauprodukt].kosten);
 else
   i = (int)(geb[gbnr].wie_weit*100L/einheit_typ[geb[gbnr].bauprodukt].kosten);
 if(i<10)
   {
    prznt[0]=' '; prznt[1]=' ';
    prznt[2]='0'+i;
   }
   else
   {
    if(i<100)
     {
      sprintf(prznt, " %i", i);
     }
     else
      sprintf(prznt, "%i", i);
   }

 i=0;
 if(fullscrflag)
   if(modaldlgflag) clip=fsdlgclip[0]; else clip=mwi;
  else
  {
   wind_get(mwihndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
   wind_update(BEG_UPDATE);
  }
 graf_mouse(M_OFF, 0L);
 while(clip.g_w!=0 && clip.g_h!=0)
  {
   if( rc_intersect(&mwi, &clip) )
    {
     clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
     vs_clip(vhndl, 1, (int *)&clip);

     switch( geb[gbnr].art )
      {
       case KASERNE:
         v_gtext(vhndl, mwi.g_x+95, mwi.g_y+41+statusypos, prznt);
         break;
       case FABRIK_KL:
         v_gtext(vhndl, mwi.g_x+95, mwi.g_y+51+statusypos, prznt);
         break;
       case FABRIK_GR:
         v_gtext(vhndl, mwi.g_x+31, mwi.g_y+51+statusypos, prznt);
         break;
       case BAUANLAGE:
         v_gtext(vhndl, mwi.g_x+31, mwi.g_y+41+statusypos, prznt);
         break;
      }
    }
   if(fullscrflag)
    {
     if(i<3 && modaldlgflag)
       clip=fsdlgclip[++i];
      else
       clip.g_w=0;
    }
    else
     wind_get(mwihndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
  } /* while */
 graf_mouse(M_ON, 0L);
 if(!fullscrflag) wind_update(END_UPDATE);

 vs_clip(vhndl, gclipflag, deskclip);
}


/* *** Gesamtenergie anzeigen *** */
void aktualize_energie()
{
 int i,b;
 static char enstr[8];
 GRECT clip;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: aktualize_energie() before window-init!\n"));
   return;
 }
#endif

 i=abs(energie);
 if(i<10)  b=4;
  else
   if(i<100) b=3;
    else
     if(i<1000) b=2;
      else b=1;
 strcpy(enstr, "    ");
 if(energie>0) b-=1;
 sprintf(&enstr[b], "%i", -energie);

 vst_point(vhndl, 9, &i, &i, &i, &i);

 i=0;
 if(fullscrflag)
   if(modaldlgflag) clip=fsdlgclip[0]; else clip=mwi;
  else
  {
   wind_get(mwihndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
   wind_update(BEG_UPDATE);
  }
 graf_mouse(M_OFF, 0L);
 while(clip.g_w!=0 && clip.g_h!=0)
  {
   if( rc_intersect(&mwi, &clip) )
    {
     clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
     vs_clip(vhndl, 1, (int *)&clip);
     v_gtext(vhndl, mwi.g_x+63, mwi.g_y+61+statusypos, enstr);
    }
   if(fullscrflag)
    {
     if(modaldlgflag && i<3)
       clip=fsdlgclip[++i];
      else
       clip.g_w=0;
    }
    else
     wind_get(mwihndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
  } /* while */
 graf_mouse(M_ON, 0L);
 if(!fullscrflag) wind_update(END_UPDATE);

 vs_clip(vhndl, gclipflag, deskclip);
}

/* *** Infofenster (und sel. GebÑude) nach Neuselektion neu zeichnen *** */
void infos_neu_zeichnen(int old_art, int old_nr)
{
 int xy[8];
 GRECT drct;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: infos_neu_zeichnen() before window-init!\n"));
   return;
 }
#endif

 xy[0]=0;
 xy[2]=15;
 xy[4]=72;  xy[5]=8+statusypos;
 xy[6]=87;  xy[7]=23+statusypos;
 if(ak_art==2)
  {
   xy[1]=(einheiten[ak_nr].art+(einheiten[ak_nr].gesinnung?25:0))*8*16;
   xy[3]=xy[1]+15;
   vro_cpyfm(vhndl, 3, xy, &einhfdb, &panelfdb);
  }
  else
  {
   xy[1]=0; xy[3]=15;
   vro_cpyfm(vhndl, (bipp<=8)?0:15, xy, &einhfdb, &panelfdb);
  }
 drct.g_x=mwi.g_x;  drct.g_y=mwi.g_y+statusypos;
 drct.g_w=mwi.g_w;  drct.g_h=32;
 drwmwind(&drct);

 /* Evtl. aktuelles GebÑude neu zeichnen: */
 if(ak_art==1)
  {
   drct.g_x=((geb[ak_nr].xpos-rwx)<<4)+wi.g_x;
   drct.g_y=((geb[ak_nr].ypos-rwy)<<4)+wi.g_y;
   drct.g_w=drct.g_h=gebaeude_typ[geb[ak_nr].art].groesse*16;
   drwindow(&drct);
  }
 if(old_art==1)
  {
   drct.g_x=((geb[old_nr].xpos-rwx)<<4)+wi.g_x;
   drct.g_y=((geb[old_nr].ypos-rwy)<<4)+wi.g_y;
   drct.g_w=drct.g_h=gebaeude_typ[geb[old_nr].art].groesse*16;
   drwindow(&drct);
  }
 if(old_art==3 || old_art==5 )  /* Setzen oder verkaufen */
  {
   drct.g_x=mausx&0xFFF0;
   drct.g_y=mausy&0xFFF0;
   drct.g_w=drct.g_h=48;
   drwindow(&drct);
  }

}





/* *** Neue Meldung in die Meldungsqueue aufnehmen: *** */
void neuemeldung(char *text)
{
 int i=0;
 while(i<7 && meldungen[i]!=NULL) i++;
 if(meldungen[i]==NULL) 
  {
   meldungen[i]=text;
   meldunganz+=1;
  }
}

/* *** Meldungen nacheinander anzeigen: *** */
void meldungenabarbeiten()
{
 static int aktmel=0;
 static signed int aktmpos=-128;
 static int tdelay=16, tmr=0;
 GRECT clip, tr;
 int i;
 char *tmptxt;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: meldungenabarbeiten() before window-init!\n"));
   return;
 }
#endif

 tmr^=1;

 if(!meldunganz || tmr)  return;

 if(meldungen[aktmel]!=NULL)
   {
    vst_point(vhndl, 8, &i, &i, &i, &i);
    tr.g_x=mwi.g_x; tr.g_y=mwi.g_y+32+statusypos;
    tr.g_w=128; tr.g_h=8;
    i=0;
    if(fullscrflag)
      if(modaldlgflag) clip=fsdlgclip[0]; else clip=mwi;
     else
     {
      wind_get(mwihndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
      wind_update(BEG_UPDATE);
     }
    graf_mouse(M_OFF, 0L);
    while(clip.g_w!=0 && clip.g_h!=0)
     {
      if( rc_intersect(&tr, &clip) )
       {
        clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
        vs_clip(vhndl, 1, (int *)&clip);
        tmptxt=meldungen[aktmel];
        if( aktmpos<0 )
          v_gtext(vhndl, mwi.g_x-aktmpos, mwi.g_y+32+statusypos, tmptxt );
         else
          v_gtext(vhndl, mwi.g_x, mwi.g_y+32+statusypos, tmptxt+(long)aktmpos);
       }
      if(fullscrflag)
       {
        if(i<3 && modaldlgflag)
          clip=fsdlgclip[++i];
         else
          clip.g_w=0;
       }
       else
        wind_get(mwihndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
     } /* while */
    graf_mouse(M_ON, 0L);
    if(!fullscrflag) wind_update(END_UPDATE);
    vs_clip(vhndl, gclipflag, deskclip);
    if( aktmpos<0 )  aktmpos+=8;
    if( aktmpos>0 || tdelay==0)
     {
      if(tdelay==0) tdelay=16;
      ++aktmpos;
      if( *(meldungen[aktmel]+aktmpos) == 0 )
       {
        meldungen[aktmel]=NULL;
        meldunganz-=1;
        aktmel+=1;
        if( aktmel>=8 ) aktmel=0;
        aktmpos=-128;
       }
     }
    if( aktmpos==0 )  --tdelay;
   }
  else
   {
    i=8;
    while( i>0 && meldungen[aktmel]==NULL )
     {
      aktmel+=1;
      if( aktmel>=8 ) aktmel=0;
      i-=1;
     }
    if( i==0 )  meldunganz=0;
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
 register short i, j;

 for(i=ox; i<ox+ow; i++)
  for(j=oy; j<oy+oh; j++)
   {
    if(i>=rwx && i<rwx+(short)rww && j>=rwy && j<rwy+(short)rwh)
     drawblk((i-rwx)<<4, (j-rwy)<<4, sfeld[i][j].erforscht ? sfeld[i][j].feldtyp : 0);
   }
}


/* ***Grafik im Fenster aufbauen*** */
void drwindow(GRECT *xywh)
{
 GRECT clip;
 int xy[10];
 int i;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: drwindow() before window-init!\n"));
   return;
 }
#endif

 i=0;
 if(fullscrflag)
   if(modaldlgflag) clip=fsdlgclip[0]; else clip=wi;
  else
  {
   wind_update(BEG_UPDATE);
   wind_get(wihndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
  }
 graf_mouse(M_OFF, 0L);
 while(clip.g_w!=0 && clip.g_h!=0)
 {
  if( rc_intersect(xywh, &clip) )
   {
    clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
    xy[0]=clip.g_x-wi.g_x; xy[1]=clip.g_y-wi.g_y;
    xy[2]=clip.g_w-wi.g_x; xy[3]=clip.g_h-wi.g_y;
    xy[4]=clip.g_x; xy[5]=clip.g_y;
    xy[6]=clip.g_w; xy[7]=clip.g_h;
    vro_cpyfm(vhndl, 3, xy, &offscr, &scrnmfdb);
    if(ak_art==1)    /* Akt. GebÑude evtl. markieren */
     {
      int ggr=gebaeude_typ[geb[ak_nr].art].groesse;
      if((short)geb[ak_nr].xpos+ggr>rwx && (short)geb[ak_nr].xpos<rwx+rww
        && (short)geb[ak_nr].ypos+ggr>rwy && (short)geb[ak_nr].ypos<rwy+rwh)
      {
       vsl_color(vhndl, 15);  /* Markierungsfarbe */
       vs_clip(vhndl, 1, (int *)&clip);
       xy[0]=((geb[ak_nr].xpos-rwx)<<4)+wi.g_x; xy[1]=((geb[ak_nr].ypos-rwy)<<4)+wi.g_y+4;
        xy[2]=xy[0];     xy[3]=xy[1]-4;
        xy[4]=xy[0]+4;   xy[5]=xy[3];
       v_pline(vhndl, 3, xy);
       xy[0]+=(ggr<<4)-5; xy[1]=xy[3];
        xy[2]=xy[0]+4;
        xy[4]=xy[2];     xy[5]=xy[1]+4;
       v_pline(vhndl, 3, xy);
       xy[0]=xy[2];      xy[1]+=(ggr<<4)-5;
                         xy[3]=xy[1]+4;
        xy[4]=xy[0]-4;    xy[5]=xy[3];
       v_pline(vhndl, 3, xy);
       xy[0]=xy[0]-(ggr<<4)+1;
        xy[2]=xy[0];
        xy[4]=xy[0]+4;
       v_pline(vhndl, 3, xy);
       vs_clip(vhndl, gclipflag, deskclip);
      }
     }
   }
  if(fullscrflag)
   {
    if(modaldlgflag && i<3)
      clip=fsdlgclip[++i];
     else
      clip.g_w=0;
   }
   else
    wind_get(wihndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
 }

 if(!fullscrflag) wind_update(END_UPDATE);
 graf_mouse(M_ON, 0L);
}


/* ***Das Spielfeld bei bestimmten Koordinaten neu zeichnen*** */
void drawscreen(int x, int y, int w, int h)
{
 GRECT rect;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: drawscreen() before window-init!\n"));
   return;
 }
#endif

 rect.g_x=((x-rwx)<<4)+wi.g_x;
 rect.g_y=((y-rwy)<<4)+wi.g_y;
 rect.g_w=w<<4;
 rect.g_h=h<<4;
 drwindow(&rect);
}



/* ***** Sprites zeichnen ***** */
void drawsprites(void)
{
 register int i;
 int j;
 int dxy[10];
 GRECT oclip, clip, sprct;
 int mausflag;
 int rwxkoor, rwykoor;
 char rdsprflags[255];  /* 0=Sprite muss nicht neu gezeichnet werden,
                     1=Nur Sprite neu zeichnen
                     2=Auch Umgebung neu zeichnen */
 register EINHEIT *akteinh;
 int maus_x, maus_y;
 int dummy;

#if DEBUGGING
 if(!screen_opened)
 {
   Dprintf(("Warning: drawspritesblk() before window-init!\n"));
   return;
 }
#endif

 rwxkoor=rwx<<4;  rwykoor=rwy<<4;

 /** Karte updaten: **/
 for(i=1; i<=(int)lleinh; i++)
 {
  akteinh=&einheiten[i];
  rdsprflags[i]=0;
  if(!akteinh->gesinnung && (akteinh->status&BEWEG_ABGE))
   {
    short rweite, z1, z2, fl;
    fl=0;
    rweite=einheit_typ[akteinh->art].reichweite;

    /* erforschtes Land aufdecken: */
    z2=akteinh->ypos-rweite; /* oben */
    if(z2>=0)
     for(z1=(signed)akteinh->xpos-rweite; z1<=(signed)akteinh->xpos+rweite; z1++)
     {
      if(z1>=0 && z1<r_width && !sfeld[z1][z2].erforscht)
       {
        fl=1;
        sfeld[z1][z2].erforscht=1;
        if(z1>=rwx && z1<rwx+(short)rww && z2>=rwy && z2<rwy+(short)rwh)
         {
          rdsprflags[i]=2;
          drawblk((z1-rwx)<<4, (z2-rwy)<<4, sfeld[z1][z2].feldtyp); /* Neueentdecktes zeichnen */
         }
        if( radarflag )
         {
          dxy[0]=dxy[2]=5;   dxy[1]=dxy[3]=0;
          dxy[4]=dxy[6]=z1+(128-r_width)/2;
          dxy[5]=dxy[7]=z2;
          vro_cpyfm(vhndl, 3, dxy, &infogfxfdb, &panelfdb);
         }
       }
     }
    z1=akteinh->xpos+rweite; /* rechts */
    if(z1<r_width)
     for(z2=(signed)akteinh->ypos-rweite; z2<=(signed)akteinh->ypos+rweite; z2++)
     {
      if(z2>=0 && z2<r_height && !sfeld[z1][z2].erforscht)
       {
        fl=1;
        sfeld[z1][z2].erforscht=1;
        if(z1>=rwx && z1<rwx+(short)rww && z2>=rwy && z2<rwy+(short)rwh)
         {
          rdsprflags[i]=2;
          drawblk((z1-rwx)<<4, (z2-rwy)<<4, sfeld[z1][z2].feldtyp);
         }
        if( radarflag )
         {
          dxy[0]=dxy[2]=5;   dxy[1]=dxy[3]=0;
          dxy[4]=dxy[6]=z1+(128-r_width)/2;
          dxy[5]=dxy[7]=z2;
          vro_cpyfm(vhndl, 3, dxy, &infogfxfdb, &panelfdb);
         }
       }
     }
    z2=akteinh->ypos+rweite; /* unten */
    if(z2<r_height)
     for(z1=(signed)akteinh->xpos-rweite; z1<=(signed)akteinh->xpos+rweite; z1++)
     {
      if(z1>=0 && z1<r_width && !sfeld[z1][z2].erforscht)
       {
        fl=1;
        sfeld[z1][z2].erforscht=1;
        if(z1>=rwx && z1<rwx+(short)rww && z2>=rwy && z2<rwy+(short)rwh)
         {
          rdsprflags[i]=2;
          drawblk((z1-rwx)<<4, (z2-rwy)<<4, sfeld[z1][z2].feldtyp);
         }
        if( radarflag )
         {
          dxy[0]=dxy[2]=5;   dxy[1]=dxy[3]=0;
          dxy[4]=dxy[6]=z1+(128-r_width)/2;
          dxy[5]=dxy[7]=z2;
          vro_cpyfm(vhndl, 3, dxy, &infogfxfdb, &panelfdb);
         }
       }
     }
    z1=akteinh->xpos-rweite; /* links */
    if(z1>=0)
     for(z2=(signed)akteinh->ypos-rweite; z2<=(signed)akteinh->ypos+rweite; z2++)
     {
      if(z2>=0 && z2<r_height && !sfeld[z1][z2].erforscht)
       {
        fl=1;
        sfeld[z1][z2].erforscht=1;
        if(z1>=rwx && z1<rwx+(short)rww && z2>=rwy && z2<rwy+(short)rwh)
         {
          rdsprflags[i]=2;
          drawblk((z1-rwx)<<4, (z2-rwy)<<4, sfeld[z1][z2].feldtyp);
         }
        if( radarflag )
         {
          dxy[0]=dxy[2]=5;   dxy[1]=dxy[3]=0;
          dxy[4]=dxy[6]=z1+(128-r_width)/2;
          dxy[5]=dxy[7]=z2;
          vro_cpyfm(vhndl, 3, dxy, &infogfxfdb, &panelfdb);
         }
       }
     }
/*    if(fl) rdsprflags[i]=2;*/
    if(radarflag && fl)                    /* Karte neu zeichnen */
     {
      dxy[4]=rweite*2+1;
      dxy[0]=max(akteinh->xpos-rweite,0)+mwi.g_x+(128-r_width)/2;  /* Zu behandelndes Rechteck */
      dxy[1]=max(akteinh->ypos-rweite,0)+mwi.g_y;
      dxy[2]=min((unsigned)dxy[4], r_width-akteinh->xpos+rweite);
      dxy[3]=min((unsigned)dxy[4], r_height-akteinh->ypos+rweite);
      drwmwind((GRECT *)dxy);
     }
   } /* if...BEWEG_ABGE */
 } /* for */

 /** Einheiten auf Karte markieren: **/
 if(radarflag)
  {
   j=0;
   dxy[1]=dxy[3]=0;
   if(fullscrflag)
    {
     if(modaldlgflag) clip=fsdlgclip[0]; else clip=mwi;
    }
    else
    {
     wind_update(BEG_UPDATE);
     wind_get(mwihndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
    }
   while(clip.g_w!=0 && clip.g_h!=0)
    {
     for(i=1; i<=lleinh; i++)
      {
       akteinh=&einheiten[i];
       dxy[4]=akteinh->xpos+mwi.g_x+(128-r_width)/2;   dxy[5]=akteinh->ypos+mwi.g_y;
       if(akteinh->art<20 && dxy[4]>=clip.g_x && dxy[4]<clip.g_x+clip.g_w && dxy[5]>=clip.g_y && dxy[5]<clip.g_y+clip.g_h)
        {
         if( sfeld[akteinh->altxpos][akteinh->altypos].erforscht && (akteinh->xpos!=akteinh->altxpos || akteinh->ypos!=akteinh->altypos) )
          {
           dxy[0]=dxy[2]=5;
           dxy[4]=dxy[6]=akteinh->altxpos+mwi.g_x+(128-r_width)/2;
           dxy[5]=dxy[7]=akteinh->altypos+mwi.g_y;
           vro_cpyfm(vhndl, 3, dxy, &infogfxfdb, &scrnmfdb);
           dxy[4]=akteinh->xpos+mwi.g_x+(128-r_width)/2; dxy[5]=akteinh->ypos+mwi.g_y;
          }
         if( sfeld[akteinh->xpos][akteinh->ypos].erforscht )
           dxy[0]=dxy[2]=(akteinh->gesinnung) ? 2 : 0;
          else
           dxy[0]=-1;
         if(dxy[0]>=0)
          {
           dxy[6]=dxy[4];  dxy[7]=dxy[5];
           vro_cpyfm(vhndl, 3, dxy, &infogfxfdb, &scrnmfdb);
          }
        }
      } /* for */
     if(fullscrflag)
      {
       if(modaldlgflag && j<3)
         clip=fsdlgclip[++j];
        else
         clip.g_w=0;
      }
      else
       wind_get(mwihndl, WF_NEXTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);   
    } /* while */
   if(!fullscrflag) wind_update(END_UPDATE);
  }

 /** Hintergrund wieder herstellen: **/
 dxy[0]=0;  dxy[2]=15;
 j = ( (timer_counter&0x03)==0 );
 for(i=1; i<=lleinh; i++)
  {
   akteinh=&einheiten[i];
   if( ((short)akteinh->altxpos>=rwx && (short)akteinh->altypos>=rwy
        && (short)akteinh->altxpos<rwx+rww && (short)akteinh->altypos<rwy+rwh)
       || ((short)akteinh->xpos>=rwx && (short)akteinh->ypos>=rwy
        && (short)akteinh->xpos<rwx+rww && (short)akteinh->ypos<rwy+rwh)
      && (!akteinh->gesinnung || sfeld[(akteinh->altesx+8)/16][(akteinh->altesy+8)/16].erforscht)
     )
   {
    if(!rdsprflags[i])
      rdsprflags[i]=1;
    if( j || (akteinh->status&(BEWEG|AUSRICHTUNG|BEWEG_ABGE)) )
     {
      short grobaltx=akteinh->altesx/16;
      short grobalty=akteinh->altesy/16;
      if(grobaltx>=rwx && grobalty>=rwy)
       {
        dxy[1]=( (!sfeld[grobaltx][grobalty].erforscht) ? 0 : sfeld[grobaltx][grobalty].feldtyp*16)+(akteinh->altesy&0x0F);
        dxy[3]=((dxy[1]+16)&0xFFF0)-1;
        dxy[4]=(akteinh->altesx-rwxkoor)&0xFFF0;
        dxy[5]=akteinh->altesy-rwykoor;
        dxy[6]=dxy[4]+15;
        dxy[7]=((dxy[5]+16)&0xFFF0)-1;
        vro_cpyfm(vhndl, 3, dxy, &bodenfdb, &offscr);
       }
      if((akteinh->altesy&0x0F) && grobaltx>=rwx && grobalty+1<rwy+(short)rwh)
       {
        dxy[1]=( (!sfeld[grobaltx][grobalty+1].erforscht) ? 0 : sfeld[grobaltx][grobalty+1].feldtyp*16);
        dxy[3]=dxy[1]+(akteinh->altesy&0x0F)-1;
        dxy[4]=(akteinh->altesx-rwxkoor)&0xFFF0;
        dxy[5]=(akteinh->altesy+16-rwykoor)&0xFFF0;
        dxy[6]=dxy[4]+15;
        dxy[7]=akteinh->altesy+15-rwykoor;
        vro_cpyfm(vhndl, 3, dxy, &bodenfdb, &offscr);
       }
      if((akteinh->altesx&0x0F) && grobaltx+1<rwx+(short)rww && grobalty>=rwy)
       {
        dxy[1]=( (!sfeld[grobaltx+1][grobalty].erforscht) ? 0: sfeld[grobaltx+1][grobalty].feldtyp*16)+(akteinh->altesy&0x0F);
        dxy[3]=((dxy[1]+16)&0xFFF0)-1;
        dxy[4]=((akteinh->altesx-rwxkoor)&0xFFF0)+16;
        dxy[5]=akteinh->altesy-rwykoor;
        dxy[6]=dxy[4]+15;
        dxy[7]=((dxy[5]+16)&0xFFF0)-1;
        vro_cpyfm(vhndl, 3, dxy, &bodenfdb, &offscr);
       }
      if((akteinh->altesx&0x0F) && (akteinh->altesy&0x0F) && grobaltx+1<rwx+(short)rww && grobalty+1<rwy+(short)rwh)
       {
        dxy[1]=( (!sfeld[grobaltx+1][grobalty+1].erforscht) ? 0 : sfeld[grobaltx+1][grobalty+1].feldtyp*16);
        dxy[3]=dxy[1]+(akteinh->altesy&0x0F)-1;
        dxy[4]=((akteinh->altesx-rwxkoor)&0xFFF0)+16;
        dxy[5]=(akteinh->altesy+16-rwykoor)&0xFFF0;
        dxy[6]=dxy[4]+15;
        dxy[7]=akteinh->altesy+15-rwykoor;
        vro_cpyfm(vhndl, 3, dxy, &bodenfdb, &offscr);
       }
     }
   }
   else rdsprflags[i]=0;   /* Wenn auûerhalb Fenster => nicht neu zeichnen */
  }

 /** Jetzt das Sprite zeichnen: **/
 for(i=1; i<=lleinh; i++)
  {
   akteinh=&einheiten[i];
   if(rdsprflags[i] && (!akteinh->gesinnung || sfeld[(akteinh->xkoor+8)/16][(akteinh->ykoor+8)/16].erforscht) )
   {
    dxy[1]=((akteinh->art+(akteinh->gesinnung?25:0))*8+akteinh->ausrichtung)<<4;
    dxy[3]=dxy[1]+15;
    dxy[4]=akteinh->xkoor-rwxkoor; dxy[5]=akteinh->ykoor-rwykoor;
    dxy[6]=dxy[4]+15;   dxy[7]=dxy[5]+15;
    if(dxy[4]<0 || dxy[5]<0 || dxy[6]>=(int)(rww<<4) || dxy[7]>=(int)(rwh<<4))  continue;
    vro_cpyfm(vhndl, 1, dxy, &einhmask, &offscr);
    vro_cpyfm(vhndl, 7, dxy, &einhfdb, &offscr);   /* Sprite zeichnen */
   }
  }

 /** Bei selektierten Einheiten Statusbalken zeichnen: **/
 if(ak_art==2)
  {
   dxy[0]=0;  dxy[1]=0;  /* Koordinaten der Energiegfx */
   dxy[3]=1;
   for(j=1; j<=ak_einh[0]; j++)
     {
      akteinh=&einheiten[ak_einh[j]];
      if( rdsprflags[ak_einh[j]] )
       {
        dxy[2]=akteinh->zustand*15/einheit_typ[akteinh->art].zustandspunkte;
        dxy[4]=akteinh->xkoor-rwxkoor;
        dxy[5]=akteinh->ykoor-rwykoor;
        dxy[6]=dxy[4]+dxy[2];
        dxy[7]=dxy[5]+1;
        vro_cpyfm(vhndl, 3, dxy, &energiefdb, &offscr); /* Balken zeichnen */
       }
     }
  }

 /** Jetzt ins Fenster kopieren: **/
 mausflag = FALSE;
 j = 0;
 if(fullscrflag)
   if(modaldlgflag) oclip=fsdlgclip[0]; else oclip=wi;
  else
   {
    wind_update(BEG_UPDATE);
    wind_get(wihndl, WF_FIRSTXYWH, &oclip.g_x, &oclip.g_y, &oclip.g_w, &oclip.g_h);
   }
 while(oclip.g_w!=0 && oclip.g_h!=0)
 {
  for(i=1; i<=lleinh; i++)
  {
   akteinh=&einheiten[i];
   if(!rdsprflags[i]) continue; /* Nur wenn nîtig: Spart einiges an CPU-Zeit */
   clip.g_x=oclip.g_x;  clip.g_y=oclip.g_y;
   clip.g_w=oclip.g_w;  clip.g_h=oclip.g_h;
   if(rdsprflags[i]==1)
    {
     sprct.g_x=min(akteinh->xkoor, akteinh->altesx)-rwxkoor+wi.g_x;
     sprct.g_y=min(akteinh->ykoor, akteinh->altesy)-rwykoor+wi.g_y;
     sprct.g_w=max(akteinh->xkoor, akteinh->altesx)+16-rwxkoor+wi.g_x-sprct.g_x;
     sprct.g_h=max(akteinh->ykoor, akteinh->altesy)+16-rwykoor+wi.g_y-sprct.g_y;
    }
    else
    {
     dxy[0]=einheit_typ[akteinh->art].reichweite;
     sprct.g_x=(akteinh->xpos-rwx-dxy[0])*16+wi.g_x;
     sprct.g_y=(akteinh->ypos-rwy-dxy[0])*16+wi.g_y;
     sprct.g_w=sprct.g_h=(dxy[0]<<5)+16;
    }
   if( rc_intersect(&sprct, &clip) )
    {
     dxy[0]=clip.g_x-wi.g_x;  dxy[1]=clip.g_y-wi.g_y;
     dxy[2]=dxy[0]+clip.g_w-1;   dxy[3]=dxy[1]+clip.g_h-1;
     dxy[4]=clip.g_x;         dxy[5]=clip.g_y;
     dxy[6]=dxy[4]+clip.g_w-1; dxy[7]=dxy[5]+clip.g_h-1;
     graf_mkstate(&maus_x, &maus_y, &dummy, &dummy);  /* Aktuelle Mauspos. holen */
     maus_x &= 0xFFC0;
     if( maus_x+64>=dxy[4] && maus_x-16<=dxy[6] && maus_y+24>=dxy[5] && maus_y-16<=dxy[7] )
      { mausflag=TRUE; graf_mouse(M_OFF, 0L); } /* Maus lîschen */
     vro_cpyfm(vhndl, 3, dxy, &offscr, &scrnmfdb); /* Ins Fenster kopieren */
     /*v_pline(vhndl, 2, &dxy[4]);*/ /*Zum Debuggen: Bereich markieren */
     if(mausflag)
      { mausflag=FALSE; graf_mouse(M_ON, 0L); } /* Maus wieder an */
    }
   if( akteinh->status&BEWEG_ABGE )
    {
     akteinh->status&=~BEWEG_ABGE;
     akteinh->altesx=akteinh->xkoor;  /* Alte Koordinaten richtig setzen */
     akteinh->altesy=akteinh->ykoor;
    }
  }  /* for */

  if(ak_art==1)      /* Akt. GebÑude markieren */
   {
   int ggr=gebaeude_typ[geb[ak_nr].art].groesse;
   if((short)geb[ak_nr].xpos+ggr>rwx && (short)geb[ak_nr].xpos<rwx+rww
      && (short)geb[ak_nr].ypos+ggr>rwy && (short)geb[ak_nr].ypos<rwy+rwh)
    {
     vsl_color(vhndl, 7); /* Markierungsfarbe */
     oclip.g_w+=oclip.g_x-1; oclip.g_h+=oclip.g_y-1;
     vs_clip(vhndl, 1, (int *)&oclip);
     dxy[0]=((geb[ak_nr].xpos-rwx)<<4)+wi.g_x; dxy[1]=((geb[ak_nr].ypos-rwy)<<4)+wi.g_y+4;
      dxy[2]=dxy[0];     dxy[3]=dxy[1]-4;
      dxy[4]=dxy[0]+4;   dxy[5]=dxy[3];
     v_pline(vhndl, 3, dxy);
     dxy[0]+=(ggr<<4)-5; dxy[1]=dxy[3];
      dxy[2]=dxy[0]+4;
      dxy[4]=dxy[2];     dxy[5]=dxy[1]+4;
     v_pline(vhndl, 3, dxy);
     dxy[0]=dxy[2];      dxy[1]+=(ggr<<4)-5;
                         dxy[3]=dxy[1]+4;
      dxy[4]=dxy[0]-4;   dxy[5]=dxy[3];
     v_pline(vhndl, 3, dxy);
     dxy[0]=dxy[0]-(ggr<<4)+1;
      dxy[2]=dxy[0];
      dxy[4]=dxy[0]+4;
     v_pline(vhndl, 3, dxy);
     vs_clip(vhndl, gclipflag, deskclip);
    }
   }

  if(fullscrflag)
   {
    if(modaldlgflag && j<3)
      oclip=fsdlgclip[++j];
     else
      oclip.g_w=0;
   }
   else
    wind_get(wihndl, WF_NEXTXYWH, &oclip.g_x, &oclip.g_y, &oclip.g_w, &oclip.g_h);
 }
 if(!fullscrflag) wind_update(END_UPDATE);

}




/* ***Fenster fuer Fullscreenmodus anpassen*** */
void adjust_fs_windows(void)
{
 static GRECT oldwi, oldmwi;

 if(fullscrflag)
  {
   oldwi=wi;
   oldmwi=mwi;
   wi.g_x=wi.g_y=0;
   wi.g_w=(scrwidth-128)&0xFFF0;   wi.g_h=scrheight&0xFFF0;
   rww=wi.g_w>>4;  rwh=wi.g_h>>4;
   if(rww>r_width)  rww=r_width;
   if(rwh>r_height) rwh=r_height;
   wi.g_w=rww<<4;  wi.g_h=rwh<<4;
   if(rwx+rww>r_width)  rwx=r_width-rww;
   if(rwy+rwh>r_height) rwy=r_height-rwh;
   offscr.fd_w=wi.g_w; offscr.fd_wdwidth=(wi.g_w+15)>>4;
   offscr.fd_h=wi.g_h;
   drawoffscr(rwx, rwy, rww, rwh);
   drwindow(&wi);
   /* Kartenoffscreen vorbereiten: */
   mwi.g_x=scrwidth-128;  mwi.g_y=0;
   mwi.g_w=128;    mwi.g_h=r_height+INFHEIGHT;
   drwmwind(&mwi);
  }
  else
  {
   if(!windowsareopen)
    {
     wind_open(mwihndl, oldmwi.g_x, oldmwi.g_y, oldmwi.g_w, /*deskh*/oldmwi.g_h);
     wind_open(wihndl, oldwi.g_x, oldwi.g_y, oldwi.g_w, oldwi.g_h);
     windowsareopen=TRUE;
    }
   wind_get(mwihndl, WF_WORKXYWH, &mwi.g_x, &mwi.g_y, &mwi.g_w, &mwi.g_h);
   wind_get(wihndl, WF_WORKXYWH, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
   rww=wi.g_w>>4;  rwh=wi.g_h>>4;
   if(rww>r_width)  rww=r_width;
   if(rwh>r_height) rwh=r_height;
   wi.g_w=rww<<4;  wi.g_h=rwh<<4;
   if(rwx+rww>r_width)  rwx=r_width-rww;
   if(rwy+rwh>r_height) rwy=r_height-rwh;
   wind_set(wihndl, WF_HSLIDE, (int)((long)rwx*1000L/(r_width-rww)), 0,0,0);
   wind_set(wihndl, WF_VSLIDE, (int)((long)rwy*1000L/(r_height-rwh)), 0,0,0);
   offscr.fd_w=deskw&0xFFF0;  offscr.fd_h=deskh&0xFFF0;
   offscr.fd_wdwidth=deskw>>4;
   drawoffscr(rwx, rwy, rww, rwh);
   drwindow(&wi);
   drwmwind(&mwi);
  }
}


/* ***** Fullscreenmodus wechseln ***** */
void togglefullscreen(int adjustwindows)
{
 static int olddeskclip[4];
 int i;

 graf_mouse(M_OFF, NULL);
 fullscrflag^=1;
 if(fullscrflag)
  {
   menu_bar(menu, 0);
   wind_update(BEG_MCTRL);
   form_dial(FMD_START, 0,0,scrwidth,scrheight, 0,0,scrwidth,scrheight);
   for(i=0; i<4; i++)
     olddeskclip[i]=deskclip[i];
   deskclip[0]=deskclip[1]=0;
   deskclip[2]=scrwidth-1;
   deskclip[3]=scrheight-1;
   vs_clip(vhndl, gclipflag, deskclip);
   vsf_color(vhndl, 1);
   v_bar(vhndl, deskclip);
  }
  else
  {
   form_dial(FMD_FINISH, 0,0,scrwidth,scrheight, 0,0,scrwidth,scrheight);
   wind_update(END_MCTRL);
   menu_bar(menu, 1);
   for(i=0; i<4; i++)
     deskclip[i]=olddeskclip[i];
   vs_clip(vhndl, gclipflag, deskclip);
  }
 if(adjustwindows)
   adjust_fs_windows();
 graf_mouse(M_ON, NULL);
}
