/**
 * STune - The battle for Aratis
 * th_init.c : Graphic initialization
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
#include <string.h>

#include "stunegem.h"
#include "stune.rsh"
#include "stunedef.h"
#include "stunmain.h"
#include "th_graf.h"
#include "th_aesev.h"
#include "loadimg.h"
#include "me_gemft.h"
#include "th_musik.h"
#include "st_debug.h"

#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif
#ifndef NULL
#define NULL 0L
#endif

#ifdef SOZOBON /* Sozobon GEM Lib */
#define aesversion gl_apversion
#define wind_set_str(handle,what,strn)  wind_set(handle,what,strn,0L)
#endif

#ifdef _GEMLIB_H_ /* GNU-C GEM Lib */
#define aesversion gl_ap_version
#define lmemcpy memcpy
#endif

#ifdef LATTICE /* Lattice-C GEM Lib */
#define aesversion _AESglobal[0]
#endif

#ifdef __TURBOC__ /* Turbo-C GEM Lib */
#define aesversion _GemParBlk.global[0]
#define wind_set_str(handle,what,strn)  wind_set(handle,what,strn,0L)
#define lmemcpy memcpy
#define WF_BEVENT 24
/* appl_getinfo von der NEW_AES.LIB : */
int appl_getinfo(int ap_gtype,int *ap_gout1, int *ap_gout2, int *ap_gout3, int *ap_gout4);
#endif

#ifndef Ssystem
#ifndef __TURBOC__
#define Ssystem(mode,arg1,arg2)  trap_1_wwll(0x154,(int)(mode),(unsigned long)(arg1),(unsigned long)(arg2))
#else
#define Ssystem(mode,arg1,arg2)  gemdos(0x154,(int)(mode),(unsigned long)(arg1),(unsigned long)(arg2))
#endif
#endif



/* **Variablen:** */
int oldpal[256][3];                    /* Die alte Palette */
char *sprname="grafik\\sprites#.img";  /* Name der Spritedatei */
char *bdnname="grafik\\boden#.img";    /* Name der Hintergrunddatendatei */
char *panlname="grafik\\panel#.img";   /* Name der Steuertafelgrafik */

unsigned long huntc_cookie;
unsigned long *huntc_value;


/* *** Search a cookie in the cookie jar *** */
long huntcookie()
{
 unsigned long *actptr;
 unsigned long actcookie, actvalue;
 actptr=(unsigned long *) (*(unsigned long *)0x5a0);
 if( actptr==NULL )  return FALSE;
 do
  {
   actcookie=*actptr++;
   actvalue=*actptr++;
   if(actcookie==huntc_cookie)
    {
     if( huntc_value!=NULL )
       *huntc_value=actvalue;
     return TRUE;
    }
  }
 while(actcookie!=0L);
 return FALSE;
}

/* *** A new getcookie function *** */
int xgetcookie(unsigned long cookie, unsigned long *value)
{
 int ret; unsigned long dummy;
 if( value!=NULL )
   ret=Ssystem(8, cookie, value);
  else
   ret=Ssystem(8, cookie, &dummy);
Dprintf(("Cookiejar:Ssystem-ret: %i\n",ret));
 if( ret != -32 )  return( ret==0 );  /* Okay, Ssystem() did not go wrong */
 /* If Ssystem does not exist we use the old way: */
 huntc_cookie=cookie;
 huntc_value=value;
 return Supexec( huntcookie );
}


/* *** Try to use appl_getinfo  *** */
int appl_xgetinfo(int type, int *out1, int *out2, int *out3, int *out4)
{
 static int axgi_init=FALSE, has_agi;

 if(!axgi_init)      /* Already initialized? */
  {               /* Check if agi is possible */
   axgi_init=TRUE;
   if(   appl_find("?AGI\0\0\0\0")>=0
      || aesversion>0x0400
      || xgetcookie(0x4D616758L, 0L)                        /* 'MagX' */
      || (aesversion==0x400 && xgetcookie(0x4D694E54L, 0L)) /* 'MiNT' */
     )
     has_agi=TRUE;
    else
     has_agi=FALSE;
  }

 if(has_agi)
   return( appl_getinfo(type, out1, out2, out3, out4) );
  else
   return(0);
}


/* *** Load the RSC file *** */
int load_rsc(char *lang)
{
 char rscname[16];
 int i;
 char *stringptr;

 if( lang )
  {
   strcpy(rscname, "stune_");
   strcat(rscname, lang);
   strcat(rscname, ".rsc");
  }
  else
   strcpy(rscname, "stune.rsc");

 if( !rsrc_load(rscname) )
  {
   char errstr[80];
   strcpy(errstr, "[3][Could not load|<");
   strcat(errstr, rscname);  strcat(errstr, ">][Mhh]");
   /*form_alert(1, errstr);*/
   return -1;
  }

 rsrc_gaddr(R_TREE, MAINMENU, &menu);  /* Adresse holen */
 rsrc_gaddr(R_TREE, INIT, &initdlg);
 rsrc_gaddr(R_TREE, SPEEDDIA, &speeddlg);
 rsrc_gaddr(R_TREE, SOUNDDIA, &sounddlg);
 rsrc_gaddr(R_TREE, LANGDLG, &langdlg);
 rsrc_gaddr(R_TREE, STRTDLG, &strtdlg);
 rsrc_gaddr(R_TREE, SETUPDLG, &setupdlg);
 rsrc_gaddr(R_TREE, NETDIA, &netdia);
 rsrc_gaddr(R_TREE, NETDLGIN, &netinit);
 rsrc_gaddr(R_TREE, NETEND, &netend);
 rsrc_gaddr(R_TREE, POPUPGEB, &gebpopobj);
 rsrc_gaddr(R_TREE, POPUPKAS, &kaspopobj);
 rsrc_gaddr(R_TREE, POPUPKLF, &klfpopobj);
 rsrc_gaddr(R_TREE, POPUPGRF, &grfpopobj);

 /* Gegebenenfalls muss die Grîûe der Popups angepasst werden: */
 if(kaspopobj[KASPLAY].ob_y+kaspopobj[KASPLAY].ob_spec.iconblk->ib_hicon
    > kaspopobj[KAPOPBOX].ob_height)
  {
   kaspopobj[KASPLAY].ob_height=kaspopobj[KASPLAY].ob_spec.iconblk->ib_hicon;
   kaspopobj[KASPAUSE].ob_height=kaspopobj[KASPAUSE].ob_spec.iconblk->ib_hicon;
   kaspopobj[KASSTOP].ob_height=kaspopobj[KASSTOP].ob_spec.iconblk->ib_hicon;
   kaspopobj[KAPOPBOX].ob_height=kaspopobj[KASPLAY].ob_y+kaspopobj[KASPLAY].ob_height;

   klfpopobj[KLFPLAY].ob_height=klfpopobj[KLFPLAY].ob_spec.iconblk->ib_hicon;
   klfpopobj[KLFPAUSE].ob_height=klfpopobj[KLFPAUSE].ob_spec.iconblk->ib_hicon;
   klfpopobj[KLFSTOP].ob_height=klfpopobj[KLFSTOP].ob_spec.iconblk->ib_hicon;
   klfpopobj[KFPOPBOX].ob_height=klfpopobj[KLFPLAY].ob_y+klfpopobj[KLFPLAY].ob_height;

   grfpopobj[GRFPLAY].ob_height=grfpopobj[GRFPLAY].ob_spec.iconblk->ib_hicon;
   grfpopobj[GRFPAUSE].ob_height=grfpopobj[GRFPAUSE].ob_spec.iconblk->ib_hicon;
   grfpopobj[GRFSTOP].ob_height=grfpopobj[GRFSTOP].ob_spec.iconblk->ib_hicon;
   grfpopobj[GFPOPBOX].ob_height=grfpopobj[GRFPLAY].ob_y+grfpopobj[GRFPLAY].ob_height;

   gebpopobj[GEBPLAY].ob_height=gebpopobj[GEBPLAY].ob_spec.iconblk->ib_hicon;
   gebpopobj[GEBPAUSE].ob_height=gebpopobj[GEBPAUSE].ob_spec.iconblk->ib_hicon;
   gebpopobj[GEBSTOP].ob_height=gebpopobj[GEBSTOP].ob_spec.iconblk->ib_hicon;
   gebpopobj[GPOPBOX].ob_height=gebpopobj[GEBPLAY].ob_y+gebpopobj[GEBPLAY].ob_height;
  }

 /* FÅr LOW-RES: MenÅ anpassen: */
 if(menu[OPTIOBOX].ob_x+menu[OPTIOBOX].ob_width>deskx+deskw)  menu[OPTIOBOX].ob_x=deskx+deskw-menu[OPTIOBOX].ob_width;
 if(menu[AKTIOBOX].ob_x+menu[AKTIOBOX].ob_width>deskx+deskw)  menu[AKTIOBOX].ob_x=deskx+deskw-menu[AKTIOBOX].ob_width;

 /* Diverse Strings vorbereiten: */
 i=0;
 rsrc_gaddr(R_STRING, GEBNAMES, &stringptr);
 while(*stringptr!='#')
  {
   gebname[i*2]=stringptr;
   stringptr=strchr(stringptr, '|');
   *stringptr=0;  ++stringptr;
   gebname[i*2+1]=stringptr;
   stringptr=strchr(stringptr, '|');
   *stringptr=0;  ++stringptr;
   ++i;
  }
 i=0;
 rsrc_gaddr(R_STRING, EINHNAMS, &stringptr);
 while(*stringptr!='#')
  {
   einhname[i*2]=stringptr;
   stringptr=strchr(stringptr, '|');
   *stringptr=0;  ++stringptr;
   einhname[i*2+1]=stringptr;
   stringptr=strchr(stringptr, '|');
   *stringptr=0;  ++stringptr;
   ++i;
  }
 i=0;
 rsrc_gaddr(R_STRING, MESGSTRS, &stringptr);
 while(*stringptr!='#')
  {
   samples[i].text=stringptr;
   stringptr=strchr(stringptr, '|');
   *stringptr=0;  ++stringptr;
   if( *samples[i].text==0 ) samples[i].text=0L;
   ++i;
  }

 speeddlg[SPDSLIDR].ob_x=gamespeed*(speeddlg[SPDSLPAR].ob_width-speeddlg[SPDSLIDR].ob_width)/50;
 speeddlg[SPDSLIDR].ob_spec.tedinfo->te_ptext[0]='0'+gamespeed/10;
 speeddlg[SPDSLIDR].ob_spec.tedinfo->te_ptext[1]='0'+gamespeed%10;
 if(scrlsprflag)
   speeddlg[SCROLLSP].ob_state|=SELECTED;
  else
   speeddlg[SCROLLSP].ob_state&=~SELECTED;
 if(sndpsgflag)
   sounddlg[PSGSND].ob_state|=SELECTED;
  else
   sounddlg[PSGSND].ob_state&=~SELECTED;
 if(sndsamflag)
   sounddlg[SAMSND].ob_state|=SELECTED;
  else
   sounddlg[SAMSND].ob_state&=~SELECTED;
 if(sndvocflag)
   sounddlg[VOICESAM].ob_state|=SELECTED;
  else
   sounddlg[VOICESAM].ob_state&=~SELECTED;
 if(sndmodflag)
   sounddlg[MODBGSND].ob_state|=SELECTED;
  else
   sounddlg[MODBGSND].ob_state&=~SELECTED;
 if(gclipflag)
   speeddlg[CLIPFLAG].ob_state|=SELECTED;
  else
   speeddlg[CLIPFLAG].ob_state&=~SELECTED;

 for(i=LANGDE; i<=LANGCZ; i++)
  if(strcmp(langstr, langdlg[i].ob_spec.free_string)==0)
   {
    langdlg[i].ob_state|=SELECTED;
    break;
   }

 if(!fullscrflag)
 {
   menu_bar(menu, 1);        /* MenÅ darstellen */
 }

 techlev2popups(techlevelnr);

 return 0;
}


/* *** Beim GEM anmelden *** */
int initGEM(void)
{
 int work_in[12], work_out[57];      /* VDI-Felder */
 int i;
 int agi1, agi2, agi3, agi4;

 ap_id=appl_init();
 if(ap_id==-1)  return(-1);
 if(aesversion>=0x400)              /* Wenn mîglich einen Namen anmelden */
   menu_register(ap_id, "  STune\0\0\0");
 graf_mouse(ARROW, 0L);             /* Maus als Pfeil */

 wind_get(0, WF_WORKXYWH, &deskx, &desky, &deskw, &deskh); /* Desktopgrîûe */

 /* VDI initialisieren: */
 vhndl=graf_handle(&i, &i, &i, &i);
 for(i=0; i<10; i++) work_in[i]=1;
 work_in[10]=2;
 v_opnvwk(work_in, &vhndl, work_out);  /* VDI-Station îffnen */
 scrwidth=work_out[0]+1;
 scrheight=work_out[1]+1;

 for(i=0; i<work_out[13]; i++)    /* Alte Farben sichern */
   vq_color(vhndl, i, 1, &oldpal[i][0]);

 vq_extnd(vhndl, 1, work_out);
 bipp=work_out[4];                  /* Bits pro Bitplane ermitteln */

Dprintf(("Screen res.: w=%i , h=%i , bipp=%i\n",scrwidth,scrheight,bipp));

 deskclip[0]=deskx; deskclip[1]=desky;
 deskclip[2]=deskx+deskw-1; deskclip[3]=desky+deskh-1;
 vs_clip(vhndl, 1, deskclip);

 /* Einige Textattribute einstellen: */
 vst_alignment(vhndl, 0, 2, &i, &i);

 /* Try to tell the AES that we understand AP_TERM */
 if( (appl_xgetinfo(10, &agi1, &agi2, &agi3, &agi4) && (agi1&0x0FF)>=9)
     || aesversion>=0x0400)
   shel_write(9, 1, 0, 0L, 0L);

 return 0;
}


/* ***Beim GEM abmelden*** */
void exitGEM(void)
{
 if(fullscrflag)  togglefullscreen(FALSE);
 setpal(oldpal);
 v_clsvwk(vhndl);
 menu_bar(menu,0);
 rsrc_free();
 appl_exit();
}


/* ***Fenster îffnen*** */
int open_window(void)
{
 int x,y,w,h;
 static char *wtitle="STune";
 int xy[8];

 if(rww>r_width) rww=r_width;
 if(rwh>r_height) rwh=r_height;
 wind_calc(WC_WORK, WINDOWGADGETS, deskx, desky, deskw, deskh, &x, &y, &w, &h);
 if((int)rww>w/16) rww=w/16;
 if((int)rwh>h/16) rwh=h/16;
 w=w&0xFFF0; h=h&0xFFF0;
 wind_calc(WC_BORDER, WINDOWGADGETS, x, y, w, h, &x, &y, &w, &h);
 wihndl=wind_create(WINDOWGADGETS, deskx, desky, w, h);

 wind_calc(WC_BORDER, WINDOWGADGETS, wi.g_x, wi.g_y, rww<<4, rwh<<4,
         &x, &y, &wi.g_w, &wi.g_h);
 if(wi.g_x==0 && wi.g_y==0)
  {
   wi.g_x=deskx+(deskw-wi.g_w)/2;
   wi.g_y=desky+(deskh-wi.g_h)/2;
  }
  else
  {
   wi.g_x=x; wi.g_y=y;
   if(wi.g_y<desky) wi.g_y=desky;
  }

 wind_set_str(wihndl, WF_NAME, wtitle);
 wind_set(wihndl, WF_HSLSIZE, (int)((long)rww*1000L/r_width), 0, 0, 0);
 wind_set(wihndl, WF_VSLSIZE, (int)((long)rwh*1000L/r_height), 0, 0, 0);

 /* Das Steuerfensters: */
 wind_calc(WC_BORDER, MWIGADGETS, mwi.g_x, mwi.g_y,
     128, r_height+INFHEIGHT, &x, &y, &mwi.g_w, &mwi.g_h);
 if(mwi.g_x==0 && mwi.g_y==0)
  {
   mwi.g_x=deskx+deskw-mwi.g_w;
   mwi.g_y=desky;
  }
  else
  {
   mwi.g_x=x; mwi.g_y=y;
   if(mwi.g_y<desky)
     mwi.g_y=desky;
   if(mwi.g_x+mwi.g_w>deskx+deskw)  
     mwi.g_x=deskx+deskw-mwi.g_w;
  }
 mwihndl=wind_create(MWIGADGETS, deskx, desky, mwi.g_w, scrheight);
 if(mwihndl<0)
  {
   form_alert(1, "[3][No enough windows|available!][Mhh]");
   return -1;
  }

 wind_set_str(mwihndl, WF_NAME, wtitle);

 if( (appl_xgetinfo(11, &x, &y, &w, &h) && (x&32)) || aesversion>=0x0300)
  {
   wind_set(mwihndl, WF_BEVENT, 1, 0, 0, 0);
   wind_set(wihndl, WF_BEVENT, 1, 0, 0, 0);
  }

 /* *Kartenoffscreen vorbereiten:* */
 statusypos=r_height;
 xy[0]=0;   xy[1]=1;
 xy[2]=127; xy[3]=INFHEIGHT;
 xy[4]=0;   xy[5]=statusypos;
 xy[6]=127; xy[7]=statusypos+INFHEIGHT-1;
 vro_cpyfm(vhndl, 3, xy, &infogfxfdb, &panelfdb);
#if 0
 /* BaumenÅ-Hintergrund lîschen: */
 xy[0]=xy[4]=0;   xy[1]=xy[5]=INFHEIGHT+1+statusypos;
 xy[2]=xy[6]=127; xy[3]=xy[7]=mwi.g_h-1;
 vro_cpyfm(vhndl, (bipp<=8)?15:0, xy, &panelfdb, &panelfdb);
 /* Pfeile kopieren: */
 xy[0]=0;   xy[1]=INFHEIGHT+1;
 xy[2]=63;  xy[3]=xy[1]+15;
 xy[4]=0;   xy[5]=r_height+INFHEIGHT;
 xy[6]=63;  xy[7]=xy[5]+15;
 vro_cpyfm(vhndl, 3, xy, &infogfxfdb, &panelfdb);
#endif
 /* Rahmen um die Karte zeichnen: */
 xy[5]=0;    xy[7]=((r_height<16)?(r_height-1):15);
 xy[0]=0;    xy[1]=INFHEIGHT+1;
 xy[2]=15;   xy[3]=xy[1]+xy[7];
 for(x=0; x+15<128; x+=16)        /* 1. Zeile */
  {
   xy[4]=x;    xy[6]=x+15;
   vro_cpyfm(vhndl, 3, xy, &infogfxfdb, &panelfdb);
  }
 xy[0]=0;   xy[1]=0;
 xy[2]=127; xy[3]=15;
 xy[4]=0;   xy[6]=127;
 for(y=16; y+15<r_height; y+=16)  /* Mittlere Zeilen */
  {
   xy[5]=y;   xy[7]=y+15;
   vro_cpyfm(vhndl, 3, xy, &panelfdb, &panelfdb);
  }
 if(r_height&0x0F)                /* Letzte Zeile */
  {
   xy[3]=r_height&0x0F;
   xy[5]=r_height&0xFFF0;  xy[7]=r_height-1;
   vro_cpyfm(vhndl, 3, xy, &panelfdb, &panelfdb);
  }
 /* Karte lîschen: */
 xy[0]=xy[4]=64-r_width/2;   xy[1]=xy[5]=0;
 xy[2]=xy[6]=64+r_width/2-1;   xy[3]=xy[7]=r_height-1;
 vro_cpyfm(vhndl, (bipp<=8)?15:0, xy, &panelfdb, &panelfdb);

 screen_opened = TRUE;

 /* Jetzt Fenster/Fullscreen zeigen */
 if(fullscrflag)
  {
   adjust_fs_windows();
   windowsareopen=FALSE;
  }
  else
  {
   wind_open(mwihndl, mwi.g_x, mwi.g_y, mwi.g_w, /*deskh*/mwi.g_h);
   wind_get(mwihndl, WF_WORKXYWH, &mwi.g_x, &mwi.g_y, &mwi.g_w, &mwi.g_h);
   wind_open(wihndl, wi.g_x, wi.g_y, wi.g_w, wi.g_h);
   wind_get(wihndl, WF_WORKXYWH, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
   windowsareopen=TRUE;
   /*
   wind_set(wihndl, WF_HSLIDE, (int)((long)rwx*1000L/(r_width-rww)), 0,0,0);
   wind_set(wihndl, WF_VSLIDE, (int)((long)rwy*1000L/(r_height-rwh)), 0,0,0);
   drawoffscr(rwx, rwy, rww, rwh);
   */
   /*drwindow(&wi);*/
  }

 winfokus = wihndl;

 return 0;
}

/* ***Fenster schlieûen*** */
void close_window(void)
{
 if(windowsareopen)
  {
   wind_close(wihndl);
   wind_close(mwihndl);
  }
 wind_delete(wihndl);
 wind_delete(mwihndl);

 screen_opened = FALSE;
}


/* ***Normale Grafik laden und ins aktuelle Format wandeln*** */
int loadpic(char *pname, MFDB *destfdb)
{
 MFDB loadfdb;
 char alerttxt[64];
 long psize;

 if( LoadImg(pname, &loadfdb) )
  {
   strcpy(alerttxt, "[3][Could not load|\"");
   strcat(alerttxt, pname);
   strcat(alerttxt, "\"][Cancel]");
   form_alert(1, alerttxt);
   return -1;
  }
 destfdb->fd_w=loadfdb.fd_w;  destfdb->fd_h=loadfdb.fd_h;
 destfdb->fd_wdwidth=loadfdb.fd_wdwidth;
 destfdb->fd_stand=0;
 destfdb->fd_nplanes=bipp;
 psize=(long)destfdb->fd_w*destfdb->fd_h*bipp/8;
 destfdb->fd_addr=(void *)Mxalloc(psize, 2);
 if( ((signed long)destfdb->fd_addr)==-32L )
   destfdb->fd_addr=(void *)Malloc(psize);
 if( ((signed long)destfdb->fd_addr)<=0L )
   { form_alert(1, "[3][Not enough memory!][Ok]");  return(-1); }
 vr_trnfm(vhndl, &loadfdb, destfdb);   /* Ins aktuelle Format wandeln */
 Mfree(loadfdb.fd_addr);

 return 0;
}

/* ***Normale Grafik laden und in Truecolor Grafik wandeln*** */
int loadpic2true(char *pname, MFDB *destfdb)
{
 MFDB loadfdb;
 char alerttxt[64];

 if( LoadImg(pname, &loadfdb) )
  {
   strcpy(alerttxt, "[3][Could not load|\"");
   strcat(alerttxt, pname);
   strcat(alerttxt, "\"][Cancel]");
   form_alert(1, alerttxt);
   return -1;
  }

 if( !transform_truecolor(&loadfdb, (long)loadfdb.fd_wdwidth * loadfdb.fd_h, bipp, vhndl) )
  {
   form_alert(1, "[3][Could not transform|graphic to truecolor][Ok]");
   return -1;
  }

 destfdb->fd_addr=loadfdb.fd_addr;
 destfdb->fd_w=loadfdb.fd_w;  destfdb->fd_h=loadfdb.fd_h;
 destfdb->fd_wdwidth=loadfdb.fd_wdwidth;
 destfdb->fd_stand=0;
 destfdb->fd_nplanes=bipp;

 return 0;
}


/* ***Grafik laden und vorbereiten*** */
long initgraf(void)
{
 MFDB loadfdb, buffdb, mbuffdb;
 unsigned long picsize1, picsize2;
 register long b, i, j, k;
 long *mptrs, *mptrd;
 unsigned short bitbuf;
 unsigned char spiegel[256];  /* Zum Spiegeln der Sprites */
 char alerttxt[64];
 int xy[8];

 /* Spiegelfeld vorbereiten: */
 for(i=0; i<=255; i++)
  {
   spiegel[i]=0;
   for(j=0; j<=8; j++)
   if(i&(1<<j))   spiegel[i]|=(128>>j);
  }

 /* Offscreen vorbereiten: */
 picsize1 = ((long)scrwidth+7)/8 * scrheight * bipp;
 /* Speicher reservieren fÅr Offscreen: */
 offscr.fd_addr=(void *)Mxalloc(picsize1, 2);
 if( ((signed long)offscr.fd_addr)==-32L )
   offscr.fd_addr=(void *)Malloc(picsize1);
 if( (signed long)offscr.fd_addr<=0L )
   { form_alert(1,"[3][Not enough memory!][Ok]"); return(-1); }
 offscr.fd_w=deskw&0xFFF0;  offscr.fd_h=deskh&0xFFF0;
 offscr.fd_wdwidth=deskw>>4;
 offscr.fd_stand=0; offscr.fd_nplanes=bipp;

 /* Grafik der Einheiten laden und vorbereiten: */
 if(bipp<=8)
  {
   for(i=0; i<strlen(sprname); i++)
     if(sprname[i]=='#')  { sprname[i]='0'+bipp; break; }
  }
  else
  {
   for(i=0; i<strlen(sprname); i++)
     if(sprname[i]=='#')  { sprname[i]='8'; break; }
  }
 /* Palette setzen: */
 if( getximgpal(sprname, newpal)==0 )
   setpal(newpal);
  else
   {
    int work_out[57];
    vq_extnd(vhndl, 0, work_out);
    for(i=0; i<work_out[13]; i++)
      vq_color(vhndl, (int)i, 1, &newpal[i][0]);
    form_alert(1,"[3][Could not set|color palette!][Ok]");
   }

 if( LoadImg(sprname, &loadfdb) )
  {
   strcpy(alerttxt, "[3][Could not load|\"");
   strcat(alerttxt, sprname);
   strcat(alerttxt, "\"][Cancel]");
   form_alert(1, alerttxt);
   return -1;
  }
 einhfdb.fd_w=einhmask.fd_w=buffdb.fd_w=mbuffdb.fd_w=loadfdb.fd_w;
 einhfdb.fd_h=einhmask.fd_h=buffdb.fd_h=mbuffdb.fd_h=loadfdb.fd_h*4;
 einhfdb.fd_wdwidth=einhmask.fd_wdwidth=buffdb.fd_wdwidth=mbuffdb.fd_wdwidth=loadfdb.fd_wdwidth;
 einhfdb.fd_stand=einhmask.fd_stand=0; buffdb.fd_stand=mbuffdb.fd_stand=1;
 einhfdb.fd_nplanes=einhmask.fd_nplanes=bipp;
 buffdb.fd_nplanes=mbuffdb.fd_nplanes=loadfdb.fd_nplanes;
 /* Speicher fÅr Sprites: */
 picsize1=einhfdb.fd_h*(2L*bipp);
 einhfdb.fd_addr=(void *)Mxalloc(picsize1, 2);
 if( ((signed long)einhfdb.fd_addr)==-32L )
   einhfdb.fd_addr=(void *)Malloc(picsize1);
 if( (signed long)einhfdb.fd_addr<=0L)
   { form_alert(1, "[3][Not enough|memory for|the gfx][Ok]");  return(-1); }
 /* Speicher fÅr Sprite-Masken: */
 einhmask.fd_addr=(void *)Mxalloc(picsize1, 2);
 if( ((signed long)einhmask.fd_addr)==-32L )
   einhmask.fd_addr=(void *)Malloc(picsize1);
 if( (signed long)einhmask.fd_addr<=0L)
   { form_alert(1, "[3][Not enough|memory for|the gfx][Ok]");  return(-1); }
 /* Speicher fÅr temporÑre Buffer: */
 picsize2=buffdb.fd_h*(2L*buffdb.fd_nplanes);
 buffdb.fd_addr=(void *)Mxalloc(2L*picsize2, 2);
 if( ((signed long)buffdb.fd_addr)==-32L )
   buffdb.fd_addr=(void *)Malloc(2L*picsize2);
 if( (signed long)buffdb.fd_addr<=0L)
   { form_alert(1,"[3][Not enough|temporary memory][Ok]");  return(-1); }
 mbuffdb.fd_addr=(void *)((char *)buffdb.fd_addr+picsize2);
Dprintf(( "size of size_t = %i\n",(int)sizeof(size_t) ));
 /* Gedrehte Sprites erstellen: */
 for(i=0; i<(einhfdb.fd_h>>4); i++)
  {
   switch(i&7)
   {
    case 0:
      for(k=0; k<loadfdb.fd_nplanes; k++)
       lmemcpy((char *)buffdb.fd_addr+2*(i*16+k*buffdb.fd_h),
         (char *)loadfdb.fd_addr+2*(i/8*32+k*loadfdb.fd_h), 32);
      break;
    case 1:
      for(k=0; k<loadfdb.fd_nplanes; k++)
       lmemcpy((char *)buffdb.fd_addr+2*(i*16+buffdb.fd_h*k),
         (char *)loadfdb.fd_addr+2*(i/8*32+16+loadfdb.fd_h*k), 32);
      break;
    case 2:
      for(k=0; k<loadfdb.fd_nplanes; k++)
       {
        for(j=0; j<16; j++) *((unsigned short *)buffdb.fd_addr+(i*16+buffdb.fd_h*k+j))=0;
        for(j=0; j<16; j++)
         {
         bitbuf=*((unsigned short *)loadfdb.fd_addr+(i/8*32+loadfdb.fd_h*k+j));
         for(b=0; b<16; b++)
           if( bitbuf&(32768L>>b) )
            *((unsigned short *)buffdb.fd_addr+(i*16+buffdb.fd_h*k+b))|=(1<<j);
         }
       }
      break;
    case 3:
      for(k=0; k<loadfdb.fd_nplanes; k++)
       for(j=0; j<16; j++)
        lmemcpy((char *)buffdb.fd_addr+2*(i*16+buffdb.fd_h*k+15-j),
         (char *)loadfdb.fd_addr+2*(i/8*32+16+loadfdb.fd_h*k+j), 2);
      break;
    case 4:
      for(k=0; k<loadfdb.fd_nplanes; k++)
       for(j=0; j<16; j++)
        lmemcpy((char *)buffdb.fd_addr+2*(i*16+buffdb.fd_h*k+15-j),
         (char *)loadfdb.fd_addr+2*(i/8*32+loadfdb.fd_h*k+j), 2);
      break;
    case 5:
      for(k=0; k<loadfdb.fd_nplanes; k++)
       for(j=0; j<16; j++)
        for(b=0; b<2; b++)
         *((unsigned char *)buffdb.fd_addr+2*(i*16+buffdb.fd_h*k+15-j)+1-b)
            =spiegel[*((unsigned char *)loadfdb.fd_addr+2*(i/8*32+16+loadfdb.fd_h*k+j)+b)];
      break;
    case 6:
      for(k=0; k<loadfdb.fd_nplanes; k++)
       {
        for(j=0; j<16; j++) *((unsigned short *)buffdb.fd_addr+(i*16+buffdb.fd_h*k+j))=0;
        for(j=0; j<16; j++)
         {
         bitbuf=*((unsigned short *)loadfdb.fd_addr+(i/8*32+loadfdb.fd_h*k+j));
         for(b=0; b<16; b++)
           if( bitbuf&(32768L>>b) )
            *((unsigned short *)buffdb.fd_addr+(i*16+buffdb.fd_h*k+b))|=(32768L>>j);
         }
       }
      break;
    case 7:
      for(k=0; k<loadfdb.fd_nplanes; k++)
       for(j=0; j<16; j++)
        for(b=0; b<2; b++)
         *((unsigned char *)buffdb.fd_addr+2*(i*16+buffdb.fd_h*k+j)+1-b)
            =spiegel[*((unsigned char *)loadfdb.fd_addr+2*(i/8*32+16+loadfdb.fd_h*k+j)+b)];
      break;
   }
  }
 if(bipp<=8)
   vr_trnfm(vhndl, &buffdb, &einhfdb);
  else
  {
   lmemcpy(einhfdb.fd_addr, buffdb.fd_addr, picsize2);
   einhfdb.fd_nplanes=buffdb.fd_nplanes;
   einhfdb.fd_stand=1;
   if( !transform_truecolor(&einhfdb, (long)einhfdb.fd_wdwidth * einhfdb.fd_h, bipp, vhndl) )
     form_alert(1, "[3][Could not transform|sprites to truecolor][Ok]");
  }

 /* Masken erstellen, dazu erstmal Maskenbuffer loeschen: */
 memset(mbuffdb.fd_addr, 0, 2L*mbuffdb.fd_h*mbuffdb.fd_nplanes);
 /* Jetzt Masken erstellen: */
 mptrs=(long *)buffdb.fd_addr;
 for(i=0; i<mbuffdb.fd_nplanes; i++)
  {
   mptrd=(long *)mbuffdb.fd_addr;
   for(j=0; j<mbuffdb.fd_h/2; j++)
   {
    *mptrd++ |= *mptrs++;
   }
  }
 for(i=1; i<mbuffdb.fd_nplanes; i++)
  {
   lmemcpy((short *)mbuffdb.fd_addr+i*mbuffdb.fd_h, mbuffdb.fd_addr, mbuffdb.fd_h*2);
  }
 /* Jetzt Maskendaten ins Standardformat konvertieren: */
 if(bipp<=8)
 { 
   mptrd=(long *)mbuffdb.fd_addr;
   j = (long)mbuffdb.fd_nplanes*mbuffdb.fd_h/2;
   for(i=0; i<j; i++)
   {
     *mptrd++ ^= -1L;                     /* Daten invertieren */
   }
   vr_trnfm(vhndl, &mbuffdb, &einhmask);  /* und konvertieren */
 }
 else
 {
   lmemcpy(einhmask.fd_addr, mbuffdb.fd_addr, picsize2);
   einhmask.fd_nplanes=mbuffdb.fd_nplanes;
   einhmask.fd_stand=1;
   if( !transform_truecolor(&einhmask, (long)einhmask.fd_wdwidth * einhmask.fd_h, bipp, vhndl) )
     form_alert(1, "[3][Could not transform|sprite masks to truecolor][Ok]");
   xy[0]=xy[1]=xy[4]=xy[5]=0;   xy[2]=xy[6]=15;   xy[3]=xy[7]=mbuffdb.fd_h-1;
   vro_cpyfm(vhndl, 6/*S_XOR_D*/, xy, &einhmask, &einhfdb);
 }
 Mfree(buffdb.fd_addr);
 Mfree(loadfdb.fd_addr);         /* Nicht mehr benîtigten Speicher freigeben */

 /* Bodengrafik laden und vorbereiten: */
 if(bipp<=8)
  {
   for(i=0; i<strlen(bdnname); i++)
     if( bdnname[i]=='#' )   { bdnname[i]='0'+bipp; break; }
   if( loadpic(bdnname, &bodenfdb) )  return(-1);
  }
  else
  {
   for(i=0; i<strlen(bdnname); i++)
     if( bdnname[i]=='#' )   { bdnname[i]='8'; break; }
   if( loadpic2true(bdnname, &bodenfdb) )  return(-1);
  }

 /* Karten/Kontroll-MFDB vorbereiten: */
 if(bipp<=8)
  {
   for(i=0; i<strlen(panlname); i++)
     if(panlname[i]=='#')  { panlname[i]='0'+bipp; break; }
   if( loadpic(panlname, &infogfxfdb) )  return(-1);
  }
  else
  {
   for(i=0; i<strlen(panlname); i++)
     if(panlname[i]=='#')  { panlname[i]='8'; break; }
   if( loadpic2true(panlname, &infogfxfdb) )  return(-1);
  }

 /* Energiegrafik-FDB vorbereiten: */
 energiefdb.fd_addr=energiegfx;
 energiefdb.fd_w=16;
 energiefdb.fd_h=2;
 energiefdb.fd_wdwidth=1;
 energiefdb.fd_nplanes=bipp;
 energiefdb.fd_stand=0;
 xy[0]=48;  xy[1]=0;
 xy[2]=63;  xy[3]=0;
 xy[4]=0;   xy[5]=0;
 xy[6]=15;  xy[7]=0;
 vro_cpyfm(vhndl, 3, xy, &infogfxfdb, &energiefdb);
 xy[5]=xy[7]=1;
 vro_cpyfm(vhndl, 3, xy, &infogfxfdb, &energiefdb);

 /* MFDB fÅr Karte: */
 /* Speicher reservieren fÅr panel-fdb: */
 picsize1=128L*scrheight*bipp/8;
 panelfdb.fd_addr=(void *)Mxalloc(picsize1, 2);
 if( ((signed long)panelfdb.fd_addr)==-32L )
   panelfdb.fd_addr=(void *)Malloc(picsize1);
 if( (signed long)panelfdb.fd_addr<=0L )
   { form_alert(1,"[3][Not enough memory!][Ok]"); return(-1); }
 panelfdb.fd_w=128; panelfdb.fd_h=scrheight;
 panelfdb.fd_wdwidth=128/16;
 panelfdb.fd_stand=0;
 panelfdb.fd_nplanes=bipp;

 return 0;
}
