/**
 * STune - The battle for Aratis
 * stunfile.c : Loading and saving of highscores, levels etc.
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

#include <osbind.h>

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#ifdef __GNUC__
#include <fcntl.h>
#endif

#include "stunedef.h"
#include "level.h"
#include "building.h"
#include "stunmain.h"
#include "st_debug.h"
#include "units.h"
#include "th_musik.h"
#include "th_aesev.h"
#include "stune.rsh"
#include "me_gemft.h"
#include "me_kifkt.h"
#include "st_net.h"
#include "th_graf.h"


#ifndef FALSE
#define FALSE 0
#define TRUE  1
#endif

#ifdef SOZOBON    /* Sozobon-C GEM Lib */
#define aesversion gl_apversion
#endif

#ifdef _GEMLIB_H_ /* GNU-C GEM Lib */
#define aesversion gl_ap_version
#endif

#ifdef LATTICE    /* Lattice-C GEM Lib */
#define aesversion _AESglobal[0]
#endif

#ifdef __TURBOC__ /* Turbo-C GEM Lib */
#define aesversion _GemParBlk.global[0]
#endif


HIGH_SCORE hs[10];
OBJECT *highdlg;

/* Texte fr die STUNE.CFG Datei: */
char *optiontexts[]=
{
 "lang",
 "gamespeed",
 "scrolldraw",
 "sndpsg",
 "sndsam",
 "sndvoc",
 "sndmod",
 "mainwin",
 "mapwin",
 "gclip",
 "fullscreen",
 NULL
};


/* Kopf von Spielstandsdateien: */
typedef struct
{
 long magic;               /* Erkennungskonstante */
 short version;            /* Zum Versionscheck */
 short r_wdth, r_hght;     /* Breite und H”he des Levels */
 unsigned short geld[2];   /* Geld */
 short techlevel;          /* Der Technologielevel */
 short level;              /* Levelnummer */
 short einhnr;             /* Anzahl Einheiten */
 short gebnr;              /* Anzahl Geb„ude */
 signed int energie;
 unsigned long timercnt;
 VERBUND s_compeinh[8];    /* KI-Werte */
 STRATEGIE s_strat[3];
 BASIS_PLATZ s_comp_basis, s_mensch_basis;
 unsigned short s_anzahl_verbund;
 unsigned int s_comp_bauspeed;
 unsigned int s_phase;
} SAVEHEADER;

/* SAVEHEADER + Spielfeld  + einhnr*einheiten + gebnr*geb = Leveldatei */
 


/* ***Fileselectbox darstellen und Name zusammenfgen*** */
int fileselect(char *pathnname, char *mask, char *boxtitle)
{
 int i, fs_button;
 char *pathend;
 char tmppath[128], tmpname[16];

 strcpy(tmppath, pathnname);
 pathend=strrchr(tmppath, '\\');
 if(pathend!=0)
   *(pathend+1)=0;
  else strcpy(tmppath, ".\\");
 strcat(tmppath, mask);
 pathend=strrchr(pathnname, '\\');
 if(pathend!=0)
   strcpy(tmpname, pathend+1);
  else strcpy(tmpname, pathnname);

 if(!fullscrflag)       /* If not in fullscreen, lock mouse control */
   wind_update(BEG_MCTRL);

 if(aesversion>0x0130)
   i=fsel_exinput(tmppath, tmpname, &fs_button, boxtitle);
  else
   i=fsel_input(tmppath, tmpname, &fs_button);

 if(!fullscrflag)
   wind_update(END_MCTRL);
 else
 {
   vsf_color(vhndl, 1);
   v_bar(vhndl, deskclip);
 }

 if(i==0 || fs_button==0)  return(-1);

 strcpy(pathnname, tmppath);
 pathend=strrchr(pathnname, '\\');
 if(pathend==0)
   pathend=pathnname; else ++pathend;
 strcpy(pathend, tmpname);            /* Pfad und Name zusammen */

 return(0);
}


/* *** Highscores laden *** */
int loadhighscore()
{
 int i;
 int fh;

 fh=open("highscor.dat", O_RDONLY);
 if(fh<0) return -1;

 for(i=0;i<=9;i++)
  if( read(fh, &hs[i], sizeof(HIGH_SCORE)) != sizeof(HIGH_SCORE) )
    return -1;

 close(fh);

 return 0;
}


/* **** Highscore speichern **** */
int savehighscore()
{
 int i;
 int fh;

 fh=creat("highscor.dat", 0644);
 if(fh<0)  return -1;

 for(i=0;i<=9;i++)
  if( write(fh, &hs[i], sizeof(HIGH_SCORE)) != sizeof(HIGH_SCORE) )
    return -1;

 close(fh);

 return 0;
}


/* *** Ein Level laden *** */
int loadlevel(char *fname, int type)
{
 int fhndl;
 int i;
 int dx,dy;
 LEVEL_HEADER hd;
 LEVEL_EINTRAG enbuf;
 unsigned char *sfbuf, *aktfld;
 size_t len;

 fhndl=open(fname, O_RDONLY);
 if(fhndl<0)
  {
   char tmpstr[80]; char *ptr;
   sprintf(tmpstr,"[3][Could not open|%s!][Ok]",fname);
   ptr=strrchr(tmpstr, '\\');
   *ptr='|';
   form_alert(1,tmpstr);
   return -1;
  }

 read(fhndl, &hd, sizeof(LEVEL_HEADER));
 if( hd.hmagic!=0x5354554EL )      /* 'STUN' */
  {
   form_alert(1,"[3][Not a STune|level file!][Ok]");
   Dprintf(("hd.hmagic was %lx\n",hd.hmagic));
   close(fhndl);
   return -1;
  }
 if(hd.version<LVLVERSION)
  {
   form_alert(1,"[3][This level file|is out of date!][Ok]");
   close(fhndl);
   return -1;
  }
 if(hd.lvltyp!=type)
  {
   form_alert(1,"[3][Sorry, wrong|level type!][Ok]");
   close(fhndl);
   return -1;
  }

 r_width=hd.r_wdth;
 r_height=hd.r_hght;
 knete[0]=hd.geld[0];
 knete[1]=hd.geld[1];
 techlevelnr=hd.techlevel;

 len=sizeof(char)*r_width*r_height;
 sfbuf=malloc( len );
 if(sfbuf==NULL)
  { form_alert(1,"[3][Could not read|the level file!][Ok]");
   close(fhndl); return (errno); }
 if( read(fhndl, sfbuf, len) != len )
  { form_alert(1,"[3][Could not read|the level file!][Ok]");
   close(fhndl); return (errno); }
 aktfld=sfbuf;
 for(dy=0; dy<r_height; dy++)
  for(dx=0; dx<r_width; dx++)
   {
    sfeld[dx][dy].feldtyp=*aktfld;
    sfeld[dx][dy].erforscht=0;
    if(*aktfld<16)
     { sfeld[dx][dy].begehbar=1; sfeld[dx][dy].befahrbar=1; }
     else
     { sfeld[dx][dy].begehbar=0; sfeld[dx][dy].befahrbar=0; }
    sfeld[dx][dy].besetzt=0;
    sfeld[dx][dy].nr=0;
    sfeld[dx][dy].ertrag=0;
    if(*aktfld==2 || *aktfld==3) sfeld[dx][dy].ertrag=1;
    if(*aktfld==4 || *aktfld==5) sfeld[dx][dy].ertrag=2;
    if(*aktfld==6 || *aktfld==7) sfeld[dx][dy].ertrag=3;
    ++aktfld;
   }
 free(sfbuf);

 for(i=1; i<256; i++)  einheiten[i].zustand=einheiten[i].status=0;
 for(i=1; i<100; i++)  geb[i].zustand=geb[i].status=0;
 i=hd.anz_obj;
 lleinh=llgeb=0;

 while( i>0 )
  {
   if( read(fhndl, &enbuf, sizeof(LEVEL_EINTRAG)) !=  sizeof(LEVEL_EINTRAG) )
    {
     form_alert(1,"[3][Could not read|the level file!][Ok]");
     close(fhndl);
     return -1;
    }
   switch(enbuf.typ)
    {
     case 0:
       if(netflag && netmode==CLIENT)  enbuf.ges^=1; /* Invertiere Gesinnung */
       if(netflag && /*enbuf.art==BAUANLAGE && */ !(netinit[NTINSPKT].ob_state&SELECTED) )
       {
         for(dx=(int)enbuf.xpos; dx<(int)enbuf.xpos+(int)gebaeude_typ[enbuf.art].groesse; dx++)
         {
          if(dx>=0 && dx<(int)r_width)
           for(dy=(int)enbuf.ypos; dy<(int)enbuf.ypos+(int)gebaeude_typ[enbuf.art].groesse; dy++)
            if(dy>=0 && dy<(int)r_height)
            {
             sfeld[dx][dy].feldtyp=1;
             sfeld[dx][dy].befahrbar=sfeld[dx][dy].begehbar=1;
            }
         }
        break;
       }
       if(enbuf.ges==0)
       {
        for(dx=(int)enbuf.xpos-8; dx<=(int)enbuf.xpos+(int)gebaeude_typ[enbuf.art].groesse+8; dx++)
         {
          if(dx>=0 && dx<r_width)
           for(dy=(int)enbuf.ypos-8; dy<=(int)enbuf.ypos+(int)gebaeude_typ[enbuf.art].groesse+8; dy++)
            if(dy>=0 && dy<r_height)
             sfeld[dx][dy].erforscht=1;
         }
       }
       setgebaeude(enbuf.art, enbuf.xpos, enbuf.ypos, enbuf.ges);
       break;
     case 1:
       if(netflag && netmode==CLIENT)  enbuf.ges^=1; /* Invertiere Gesinnung */
       set_einheit(enbuf.art, enbuf.xpos, enbuf.ypos, enbuf.ges,0);
       sfeld[enbuf.xpos][enbuf.ypos].befahrbar=einheit_typ[enbuf.art].befahrbar;
       sfeld[enbuf.xpos][enbuf.ypos].begehbar=FALSE;
       sfeld[enbuf.xpos][enbuf.ypos].besetzt=1;
       sfeld[enbuf.xpos][enbuf.ypos].besetzertyp=1;
       sfeld[enbuf.xpos][enbuf.ypos].gesinnung=enbuf.ges;
       if(enbuf.ges==0)
       {
        for(dx=(int)enbuf.xpos-(int)einheit_typ[enbuf.art].reichweite; dx<=(int)enbuf.xpos+(int)einheit_typ[enbuf.art].reichweite; dx++)
         {
          if(dx>=0 && dx<r_width)
           for(dy=(int)enbuf.ypos-(int)einheit_typ[enbuf.art].reichweite; dy<=(int)enbuf.ypos+(int)einheit_typ[enbuf.art].reichweite; dy++)
            if(dy>=0 && dy<r_height)
             sfeld[dx][dy].erforscht=TRUE;
         }
       }
       break;
    }
   i-=1;
  }

 close(fhndl);

 techlev2popups(techlevelnr);

 return 0;
}



/* *** Parameter sichern *** */
int saveoptions()
{
 int fhndl;
 int i;
 char textbuf[256], *valtxt;

 fhndl=creat("stune.cfg", 0644);
 if( fhndl<0 )
  { form_alert(1,"[3][Could not|create STUNE.CFG][Ok]"); return(fhndl); }
 for(i=1; i<=10; i++)
  {
   strcpy(textbuf, optiontexts[i]);
   strcat(textbuf, " = ");
   switch(i)
    {
     case 0: valtxt=langstr; break;
     case 1: valtxt=""; sprintf(&textbuf[strlen(textbuf)], "%i", gamespeed); break;
     case 2: if( scrlsprflag ) valtxt="1"; else valtxt="0"; break;
     case 3: if( sndpsgflag ) valtxt="1"; else valtxt="0"; break;
     case 4: if( sndsamflag ) valtxt="1"; else valtxt="0"; break;
     case 5: if( sndvocflag ) valtxt="1"; else valtxt="0"; break;
     case 6: if( sndmodflag ) valtxt="1"; else valtxt="0"; break;
     case 7:
       valtxt="";
       sprintf(&textbuf[strlen(textbuf)], "%i", (int)((long)(wi.g_x-deskx)*32256/deskw));
       strcat(textbuf, ";");
       sprintf(&textbuf[strlen(textbuf)], "%i", (int)((long)(wi.g_y-desky)*32256/deskh));
       strcat(textbuf, ";");
       sprintf(&textbuf[strlen(textbuf)], "%i", rww);
       strcat(textbuf, ";");
       sprintf(&textbuf[strlen(textbuf)], "%i", rwh);
       break;
     case 8:
       valtxt="";
       sprintf(&textbuf[strlen(textbuf)], "%i", (int)((long)(mwi.g_x-deskx)*32256/deskw));
       strcat(textbuf, ";");
       sprintf(&textbuf[strlen(textbuf)], "%i", (int)((long)(mwi.g_y-desky)*32256/deskh));
       break;
     case 9: if( gclipflag ) valtxt="1"; else valtxt="0"; break;
     case 10: if( fullscrflag ) valtxt="1"; else valtxt="0"; break;
    }
   strcat(textbuf, valtxt);
   strcat(textbuf, "\r\n");
   if( write(fhndl, textbuf, strlen(textbuf)) != (int)strlen(textbuf) )
    { form_alert(1,"[3][Could not|write STUNE.CFG!][Ok]");
      close(fhndl); return -1; }
  }

 close(fhndl);
 return 0;
}



/* *** Parameter laden *** */
int loadoptions()
{
 int fhndl; int i;
 long f_siz;
 char *p; char buf[512];

 wi.g_x=wi.g_y=mwi.g_x=mwi.g_y=0;

 fhndl=open("stune.cfg", O_RDONLY);
 if( fhndl < 0L )
  { form_alert(1, "[3][Could not|load STUNE.CFG!][OK]"); return(fhndl); }

 f_siz=lseek(fhndl, 0L, SEEK_END);  /* Dateigr”že ermitteln */
 lseek(fhndl, 0L, SEEK_SET);

 if(f_siz>512)
  { form_alert(1, "[3][Could not|load STUNE.CFG!][OK]");
    close(fhndl); return -1; }

 if( read(fhndl, buf, f_siz) != f_siz )
  { form_alert(1, "[3][Could not|load STUNE.CFG!][OK]");
    close(fhndl); return -1; }

 close(fhndl);

 for(i=0; i<=10; i++)
  {
   p=strstr(buf, optiontexts[i]);
   if(p)
    {
     p+=strlen(optiontexts[i]);
     while(*p!='=' && *p!='\n') p++;
     if( *p=='\n' )
      { form_alert(1, "[3][Error in|configuration file][Ok]"); continue; }
     p+=1;
     while(*p==' ') p++;
     switch(i)
      {
       case 0:
         strncpy(langstr, p, 2);
         if(*langstr == '\n' || *langstr == '\r')  *langstr = 0;
         break;
       case 1: gamespeed = atoi(p); break;
       case 2: scrlsprflag = atoi(p);  break;
       case 3: sndpsgflag = atoi(p);  break;
       case 4: sndsamflag = atoi(p);  break;
       case 5: sndvocflag = atoi(p);  break;
       case 6: sndmodflag = atoi(p);  break;
       case 7:
         wi.g_x = (int)((long)atoi(p) * deskw / 32256) + deskx;
         while(*p != ';') p++;
         p += 1;
         wi.g_y = (int)((long)atoi(p) * deskh / 32256) + desky;
         while(*p != ';') p++;
         p += 1;
         rww = atoi(p);
         while(*p != ';') p++;
         p += 1;
         rwh = atoi(p);
         break;
       case 8:
         mwi.g_x = (int)((long)atoi(p) * deskw / 32256) + deskx;
         while(*p!=';') p++;
         p += 1;
         mwi.g_y = (int)((long)atoi(p) * deskh / 32256) + desky;
         break;
       case 9: gclipflag = atoi(p);  break;
       case 10: fullscrflag = atoi(p);  break;
      }
    }
  }

 return 0;
}


/* *** Ein einfacher XOR Verschlsseler/Entschlsseler *** */
void xor_codec(char *addr, long len)
{
  static unsigned char xtable[8]={~16,~128,~1,~4,~64,~2,~32,~8};
  int i=0;

  do
  {
    *addr ^= xtable[i];
    ++addr;
    i = (i + 1) & 0x07;
  }
  while( --len > 0 );
}


/* ***Levelinfodatei laden und entschluesseln*** */
int loadinfofile(char *fname)
{
 int fhndl;
 long f_siz;

 fhndl=open(fname, 0);
 if(fhndl<0)  return(fhndl);

 f_siz=lseek(fhndl, 0L, SEEK_END);  /* Dateigroesse ermitteln */
 lseek(fhndl, 0L, SEEK_SET);

 if(lvldescription!=NULL) free(lvldescription);
 lvldescription=malloc((size_t)f_siz);
 if(lvldescription==NULL)  return(-1);
 
 if( read(fhndl, lvldescription, f_siz) != f_siz )
  {
   close(fhndl);
   return -1;
  }

 close(fhndl);

 /* Entschlsseln: */
 xor_codec(lvldescription, f_siz);

 if( strncmp(lvldescription, "#!stune", 7) )
  { form_alert(1, "[3][Not a STune|level info|file!][OK]"); return -1; }

 return 0;
}


/* *** Spielstand speichern *** */
int savegame(void)
{
 SAVEHEADER hd;
 int fhndl;
 SPIELFELD *buf, *actbuf;
 int x, y;
 long len;

 Dprintf(("Saving %s\n",savename));

 /* Header aufbauen: */
 hd.magic=0x53545347L;      /* 'STSG' */
 hd.version=0x0091;

 hd.r_wdth=r_width;
 hd.r_hght=r_height;
 hd.geld[0]=knete[0];  hd.geld[1]=knete[1];
 hd.techlevel=techlevelnr;
 hd.level=level;
 hd.einhnr=lleinh;
 hd.gebnr=llgeb;
 hd.energie=energie;
 hd.timercnt=timer_counter;
 for(x=0;x<=7;x++) hd.s_compeinh[x]=compeinh[x];
 for(x=0;x<=2;x++) hd.s_strat[x]=strat[x];
 hd.s_comp_basis=comp_basis;
 hd.s_mensch_basis=mensch_basis;
 hd.s_anzahl_verbund=anzahl_verbund;
 hd.s_comp_bauspeed=comp_bauspeed;
 hd.s_phase=phase;

 /* Datei erstellen: */
 fhndl=creat(savename, 0644);
 if( fhndl<0 )
  {
   char errtxt[200]; char *ptr;
   sprintf(errtxt, "[3][Could not create|%s][Ok]",savename);
   ptr=strrchr(errtxt, '\\');
   *ptr='|';
   form_alert(1, errtxt);
   return(fhndl);
  }

 /* Header speichern: */
 if( write(fhndl, &hd, sizeof(hd)) != sizeof(hd) )
  { form_alert(1,"[3][Could not|write file!][Ok]");
    close(fhndl); return -1; }

 /* Spielfeld speichern: */
 len=sizeof(SPIELFELD)*r_width*r_height;
 buf=malloc(len);
 if( !buf )  { form_alert(1,"[3][Fatal error|(no mem).][Ok]"); return -2; }
 actbuf=buf;
 for(y=0; y<r_height; y++)
  for(x=0; x<r_width; x++)
   {
    memcpy(actbuf, &sfeld[x][y], sizeof(SPIELFELD));
    ++actbuf;
   }
 if( write(fhndl, buf, len) != len )
  { form_alert(1,"[3][Could not|write file!][Ok]");
    close(fhndl); return -1; }
 free( buf );

 /* Einheiten speichern: */
 if( write(fhndl, &einheiten[1], sizeof(EINHEIT)*lleinh) != sizeof(EINHEIT)*lleinh )
  { form_alert(1,"[3][Could not|write file!][Ok]");
    close(fhndl); return -1; }

 /* Gebaeude speichern: */
 if( write(fhndl, &geb[1], sizeof(GEBAEUDE)*llgeb) != sizeof(GEBAEUDE)*llgeb )
  { form_alert(1,"[3][Could not|write file!][Ok]");
    close(fhndl); return -1; }

 close(fhndl);

 return 0;
}


/* *** Spielstand laden *** */
int loadgame(void)
{
 SAVEHEADER hd;
 int fhndl;
 SPIELFELD *buf, *actbuf;
 int x, y;
 long len;

 Dprintf(("Loading %s\n",savename));

 fhndl=open(savename, O_RDONLY);
 if(fhndl<0)
  {
   char tmpstr[80]; char *ptr;
   sprintf(tmpstr,"[3][Could not open|%s!][Ok]",savename);
   ptr=strrchr(tmpstr, '\\');
   *ptr='|';
   form_alert(1,tmpstr);
   return -1;
  }

 read(fhndl, &hd, sizeof(hd));
 if( hd.magic!=0x53545347L )      /* 'STSG' */
  {
   form_alert(1,"[3][Not a STune|game file!][Ok]");
   close(fhndl);
   return -1;
  }
 if(hd.version!=0x0091)
  {
   form_alert(1,"[3][Version number of|this game file|is wrong!][Ok]");
   close(fhndl);
   return -1;
  }

 r_width=hd.r_wdth;
 r_height=hd.r_hght;
 knete[0]=hd.geld[0];  knete[1]=hd.geld[1];
 techlevelnr=hd.techlevel;
 level=hd.level;
 lleinh=hd.einhnr;
 llgeb=hd.gebnr;
 energie=hd.energie;
 timer_counter=hd.timercnt;
 for(x=0;x<=7;x++) compeinh[x]=hd.s_compeinh[x];
 for(x=0;x<=2;x++) strat[x]=hd.s_strat[x];
 comp_basis=hd.s_comp_basis;
 mensch_basis=hd.s_mensch_basis;
 anzahl_verbund=hd.s_anzahl_verbund;
 comp_bauspeed=hd.s_comp_bauspeed;
 phase=hd.s_phase;

 /* Spielfeld laden: */
 len=sizeof(SPIELFELD)*r_width*r_height;
 buf=malloc(len);
 if( !buf )  { form_alert(1,"[3][Fatal error|(no mem).][Ok]"); return -2; }
 if( read(fhndl, buf, len) != len )
  { form_alert(1,"[3][Could not|read file 1!][Ok]");
    close(fhndl); return -1; }
 actbuf=buf;
 for(y=0; y<r_height; y++)
  for(x=0; x<r_width; x++)
   {
    memcpy(&sfeld[x][y], actbuf, sizeof(SPIELFELD));
    ++actbuf;
   }
 free( buf );

 /* Einheiten laden: */
 if( read(fhndl, &einheiten[1], sizeof(EINHEIT)*lleinh) != sizeof(EINHEIT)*lleinh )
  { form_alert(1,"[3][Could not|read file 2!][Ok]");
    close(fhndl); return -1; }

 /* Gebaeude laden: */
 if( read(fhndl, &geb[1], sizeof(GEBAEUDE)*llgeb) != sizeof(GEBAEUDE)*llgeb )
  { form_alert(1,"[3][Could not|read file 3!][Ok]");
    close(fhndl); return -1; }

 close(fhndl);

 techlev2popups(techlevelnr);

 return 0;
}
