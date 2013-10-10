/**
 * STune - The battle for Aratis
 * stedinit.c : Initialization of the GEM and graphics.
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

#include <aes.h>
#include <vdi.h>
#include <osbind.h>
#include <string.h>
#include "stunedef.h"
#include "loadimg.h"
#include "sted.rsh"
#include "stedmain.h"
#include "stedgraf.h"
#include "sted_aes.h"

#ifdef SOZOBON
#define aesversion gl_apversion
#endif

#ifdef __TURBOC__
#define aesversion _GemParBlk.global[0]
#define WF_BEVENT 24
#endif


/* **Variablen:** */
int oldpal[256][3];                         /* Die alte Palette */
char *bdnname="..\\grafik\\boden4.img";     /* Name der Hintergrunddatendatei */
char *einhname="..\\grafik\\sprites4.img";  /* Name der Sprites */


/* *** Beim GEM anmelden *** */
int initGEM(void)
{
 int rgb[3];
 int work_in[12], work_out[57];		/* VDI-Felder */
 int i, ap_id;

 ap_id=appl_init();
 if(ap_id==-1)	return(-1);
 if(aesversion>=0x400)					/* Wenn mîglich einen Namen anmelden */
	menu_register(ap_id, "  STed\0\0\0\0");
 graf_mouse(ARROW, 0L);					/* Maus als Pfeil */

 if( !rsrc_load("sted.rsc") )
  {
   form_alert(1, "[3][Could not|load <sted.rsc>][Cancel]");
   appl_exit();
   return(-1);
  }
 rsrc_gaddr(R_TREE, MAINMENU, &menu);	/* Adresse holen */
 rsrc_gaddr(R_TREE, ABOUTSED, &aboutdlg);
 rsrc_gaddr(R_TREE, LDATDIA, &lvdatdlg);

#ifdef RESTRIC_STED
 lvdatdlg[LVLTYP].ob_flags |= HIDETREE;
 lvdatdlg[LVLTYP].ob_flags &= ~EDITABLE;
 lvdatdlg[LVLTYPT1].ob_flags |= HIDETREE;
 lvdatdlg[LVLTYPT2].ob_flags |= HIDETREE;
 lvdatdlg[LVLID].ob_flags |= HIDETREE;
 lvdatdlg[LVLID].ob_flags &= ~EDITABLE;
 lvdatdlg[LVLIDT1].ob_flags |= HIDETREE;
#endif

 wind_get(0, WF_WORKXYWH, &deskx, &desky, &deskw, &deskh); /* Desktopgrîûe */

 vhndl=graf_handle(&i, &i, &i, &i);
 for(i=0; i<10; i++)	work_in[i]=1;
 work_in[10]=2;
 v_opnvwk(work_in, &vhndl, work_out);	/* VDI-Station îffnen */

 vq_extnd(vhndl, 1, work_out);
 bipp=work_out[4];						/* Bits pro Bitplane ermitteln */
 if(bipp>8)
  {
   form_alert(1, "[3][Sorry, STed only works|in 16 and 256 colors!][Ok]");
   v_clsvwk(vhndl); rsrc_free(); appl_exit();
   return(-1);
  }

 menu_bar(menu, 1);			/* MenÅ darstellen */

 for(i=0; i<15; i++)		/* Alte Farben sichern */
  {
   vq_color(vhndl, i, 1, rgb);
   oldpal[i][0]=rgb[0];
   oldpal[i][1]=rgb[1];
   oldpal[i][2]=rgb[2];
  }
 setpal(newpal);			/* Neue Farben setzen */

 return(0);
}


/* ***Beim GEM abmelden*** */
void exitGEM(void)
{
 setpal(oldpal);
 v_clsvwk(vhndl);
 rsrc_free();
 appl_exit();
}


/* ***Fenster îffnen*** */
int open_window(void)
{
 wind_calc(WC_WORK, SWIGADGETS, deskx, desky, deskw, deskh, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
 wi.g_w=wi.g_w&0xFFF0; wi.g_h=wi.g_h&0xFFF0;
 wind_calc(WC_BORDER, SWIGADGETS, wi.g_x, wi.g_y, wi.g_w, wi.g_h, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
 wihndl=wind_create(SWIGADGETS, deskx, desky, wi.g_w, wi.g_h);
 if(wihndl<0)
  {
   form_alert(1, "[3][Could not create|the windows!][Cancel]");
   return(-1);
  }

 wind_set(wihndl, WF_NAME, "STED", 0L);
 wind_set(wihndl, WF_INFO, " Spielfeld editieren", 0L);

 wind_calc(WC_BORDER, SWIGADGETS, 32, 32, rww<<4, rwh<<4,
			&wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
 wi.g_x=deskx+(deskw-wi.g_w)/2;
 wi.g_y=desky+(deskh-wi.g_h)/2;

 if(aesversion>=0x0300)
  {
   wind_set(wihndl, WF_BEVENT, 1, 0, 0L);
  }

 /* Fenster îffnen: */
 wind_open(wihndl, wi.g_x, wi.g_y, wi.g_w, wi.g_h);
 wind_get(wihndl, WF_WORKXYWH, &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);

 return(0);
}

/* ***Fenster schlieûen*** */
void close_window(void)
{
 wind_close(wihndl);
 wind_delete(wihndl);
}


/* ***Normale Grafik laden und ins aktuelle Format wandeln*** */
int loadpic(char *pname, MFDB *destfdb)
{
 MFDB loadfdb;
 char alerttxt[64];

 if( LoadImg(pname, &loadfdb) )
  {
   strcpy(alerttxt, "[3][Could not load|<");
   strcat(alerttxt, pname);
   strcat(alerttxt, ">][Cancel]");
   form_alert(1, alerttxt);
   return(-1);
  }
 destfdb->fd_w=loadfdb.fd_w;	destfdb->fd_h=loadfdb.fd_h;
 destfdb->fd_wdwidth=loadfdb.fd_wdwidth;
 destfdb->fd_stand=0;
 destfdb->fd_nplanes=bipp;
 destfdb->fd_addr=(void *)Malloc((long)destfdb->fd_w*destfdb->fd_h*bipp/8);
 if(destfdb->fd_addr<=0L)  return((int)destfdb->fd_addr);
 vr_trnfm(vhndl, &loadfdb, destfdb);	/* Ins aktuelle Format wandeln */
 Mfree(loadfdb.fd_addr);

 return(0);
}

/* ***Grafik laden und vorbereiten*** */
long initgraf(void)
{
 char alerttxt[64];
 int xy[4];

 /* Offscreen vorbereiten: */
 wind_calc(WC_WORK, SWIGADGETS, deskx, desky, deskw, deskh,
			&xy[0], &xy[1], &xy[2], &xy[3]);
 offscr.fd_addr=(void *)Malloc((long)(xy[2]+7)/8*xy[3]*bipp);	/* Get memory */
 if((long)offscr.fd_addr<=0L)
 {
   return((long)offscr.fd_addr);
 }
 offscr.fd_w=xy[2];	offscr.fd_h=xy[3];
 offscr.fd_wdwidth=(xy[2]+15)>>4;
 offscr.fd_stand=0; offscr.fd_nplanes=bipp;

 /* Bodengrafik laden und vorbereiten: */
 bdnname[15]='0'+bipp;
 if( loadpic(bdnname, &bodenfdb) )	return(-1);

 /* Einheitengrafik laden und vorbereiten: */
 einhname[17]='0'+bipp;
 if( loadpic(einhname, &einhfdb) )	return(-1);

 return(0);
}
