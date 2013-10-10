/**
 * STune - The battle for Aratis
 * sted_aes.c : Handle AES events, keyclicks etc.
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
#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include "stedmain.h"
#include "sted.rsh"
#include "stedgraf.h"
#include "steddisk.h"
#include "sted_aes.h"

#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif

/* **Variablen:** */
OBJECT *menu;							/* Adresse des MenÅs */
OBJECT *aboutdlg;						/* Copyright-Dialog */
OBJECT *lvdatdlg;                       /* Leveldatendialog */



/* ***Slider neu setzen*** */
void setslider(short sldrflg)
{
 if(sldrflg&1) wind_set(wihndl, WF_HSLIDE, (int)((long)rwx*1000L/(r_width-rww)), 0, 0L);
 if(sldrflg&2) wind_set(wihndl, WF_VSLIDE, (int)((long)rwy*1000L/(r_height-rwh)), 0, 0L);
}



/* ***MenÅeintrag wurde angewÑhlt*** */
void reactmenu(void)
{
 int exitbut, dx, dy, dw, dh;

 switch(msgbuf[4])
  {
   case NEWFILE:
     for(dy=0; dy<128; dy++)
      for(dx=0; dx<128; dx++)
       {
        sfeld[dx][dy].feldtyp=1;
        sfeld[dx][dy].befahrbar=TRUE;
        sfeld[dx][dy].besetzt=FALSE;
        sfeld[dx][dy].erforscht=TRUE;
        sfeld[dx][dy].ertrag=0;
       }
     drawoffscr(rwx, rwy, rww, rwh);
     drwindow(&wi);
     en_anz=0;
     break;
   case LOADFILE:
     if( fileselect("Load a level")==0 )
       loadlevel(fname);
     drawoffscr(rwx, rwy, rww, rwh);
     drwindow(&wi);
     break;
   case SAVEFILE:
     if( fileselect("Save a level")==0 )
       savelevel(fname);
     break;
   case ABOUTIT:						/* Copyright anzeigen */
	 form_center(aboutdlg, &dx, &dy, &dw, &dh);
	 form_dial(FMD_START, dx, dy, 0, 0, dx, dy, dw, dh);
	 objc_draw(aboutdlg, 0, 8, dx, dy, dw, dh);
	 form_do(aboutdlg, 0);
	 form_dial(FMD_FINISH, dx, dy, 0, 0, dx, dy, dw, dh);
	 aboutdlg[ABOUTOK].ob_state=NORMAL;
	 break;
   case QUITIT:							/* Spiel verlassen */
	 /*if(form_alert(2, "[1][STED beenden?][Ende|ZurÅck]")==1)*/
	  endeflag=TRUE;
	 break;
   case LVBACKG:
     menu_icheck(menu, LVBACKG+tmodus, 0);
     menu_icheck(menu, LVBACKG, 1);
     tmodus=0;
     acttile=0;
     break;
   case LVGEB:
     menu_icheck(menu, LVBACKG+tmodus, 0);
     menu_icheck(menu, LVGEB, 1);
     tmodus=1;
     acttile=0;
     break;
   case LVEINH:
     menu_icheck(menu, LVBACKG+tmodus, 0);
     menu_icheck(menu, LVEINH, 1);
     tmodus=2;
     acttile=0;
     break;
   case EREASE:
     menu_icheck(menu, LVBACKG+tmodus, 0);
     menu_icheck(menu, EREASE, 1);
     tmodus=3;
     acttile=0;
     break;
   case LVDATEN:
     itoa(r_width, lvdatdlg[LWIDTH].ob_spec.tedinfo->te_ptext, 10);
     itoa(r_height, lvdatdlg[LHEIGHT].ob_spec.tedinfo->te_ptext, 10);
     itoa(knete[0], lvdatdlg[LPGELD].ob_spec.tedinfo->te_ptext, 10);
     itoa(knete[1], lvdatdlg[LEGELD].ob_spec.tedinfo->te_ptext, 10);
     *((char *)lvdatdlg[TECHLVL].ob_spec.tedinfo->te_ptext)='0'+tech_level;
     *((char *)lvdatdlg[LVLTYP].ob_spec.tedinfo->te_ptext)='0'+lvl_type;
     ltoa(lvlid, lvdatdlg[LVLID].ob_spec.tedinfo->te_ptext, 10);
	 form_center(lvdatdlg, &dx, &dy, &dw, &dh);
	 form_dial(FMD_START, dx, dy, 0, 0, dx, dy, dw, dh);
	 objc_draw(lvdatdlg, 0, 8, dx, dy, dw, dh);
	 form_do(lvdatdlg, 0);
	 form_dial(FMD_FINISH, dx, dy, 0, 0, dx, dy, dw, dh);
	 lvdatdlg[LDOKAY].ob_state=NORMAL;
     r_width=atoi(lvdatdlg[LWIDTH].ob_spec.tedinfo->te_ptext);
     r_height=atoi(lvdatdlg[LHEIGHT].ob_spec.tedinfo->te_ptext);
     knete[0]=atoi(lvdatdlg[LPGELD].ob_spec.tedinfo->te_ptext);
     knete[1]=atoi(lvdatdlg[LEGELD].ob_spec.tedinfo->te_ptext);
     tech_level=*((char *)lvdatdlg[TECHLVL].ob_spec.tedinfo->te_ptext)-'0';
     lvl_type=*((char *)lvdatdlg[LVLTYP].ob_spec.tedinfo->te_ptext)-'0';
     lvlid=atol(lvdatdlg[LVLID].ob_spec.tedinfo->te_ptext);
     rwx=rwy=0;
     drawoffscr(rwx, rwy, rww, rwh);
     drwindow(&wi);
     setslider(3);
	 break;
  }

 menu_tnormal(menu, msgbuf[3], 1);
}


/* ***TastendrÅcke*** */
void keyklicks(void)
{
 int knownkey;
 unsigned char scancode;

 scancode=key>>8;

 if(kstate==K_CTRL)
  {
   knownkey=TRUE;
   switch(scancode)
   {
	case 0x10:              /* CTRL-Q */
	  msgbuf[3]=DATEIMEN;
	  msgbuf[4]=QUITIT;
	  break;
	case 0x31:              /* CTRL-N */
	   msgbuf[3]=DATEIMEN;
	   msgbuf[4]=NEWFILE;
	   break;
	case 0x18:              /* CTRL-O */
	   msgbuf[3]=DATEIMEN;
	   msgbuf[4]=LOADFILE;
	   break;
	case 0x1F:              /* CTRL-S */
	   msgbuf[3]=DATEIMEN;
	   msgbuf[4]=SAVEFILE;
	   break;
	default: knownkey=FALSE; break;
   }
   if(knownkey)
   {
	menu_tnormal(menu, msgbuf[3], 0);
	reactmenu();
   }
  }

 if(kstate<=3)                                /* Hîchstens Shift + Taste */
  {
   switch(scancode)
    {
     case 0x48:                               /* Cursor hoch */
       msgbuf[4]=WA_UPLINE;
       break;
     case 0x4B:                               /* Cursor links */
       msgbuf[4]=WA_LFLINE;
       break;
     case 0x50:                               /* Cursor runter */
       msgbuf[4]=WA_DNLINE;
       break;
     case 0x4D:                               /* Cursor rechts */
       msgbuf[4]=WA_RTLINE;
       break;
    }
   if(scancode==0x48 || scancode==0x4B || scancode==0x50 || scancode==0x4D)
    {                                         /* Cursortaste */
     msgbuf[0]=WM_ARROWED;
     if( kstate & (K_RSHIFT|K_LSHIFT) )  msgbuf[4]-=2;
     mesages();
    }
  }

}



/* ***Nachrichten*** */
void mesages(void)
{
 int xy[8];

 switch(msgbuf[0])
  {
   case MN_SELECTED:
	  reactmenu();
	  break;
   case WM_REDRAW:
	  drwindow((GRECT *)&msgbuf[4]);
	  break;
   case WM_TOPPED:
	  wind_set(msgbuf[3], WF_TOP, 0L, 0L);
	  break;
   case WM_MOVED:
	  wind_set(msgbuf[3], WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
	  wind_calc(WC_WORK, SWIGADGETS, msgbuf[4], msgbuf[5],
			msgbuf[6], msgbuf[7], &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
	  break;
   case WM_CLOSED:
	  endeflag=TRUE;
	  break;
   case WM_FULLED:
	  wind_get(msgbuf[3], WF_FULLXYWH, &msgbuf[4], &msgbuf[5], &msgbuf[6], &msgbuf[7]);
   case WM_SIZED:
	  wind_calc(WC_WORK, SWIGADGETS, msgbuf[4], msgbuf[5],
			msgbuf[6], msgbuf[7], &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
	  rww=wi.g_w>>4;
	  rwh=wi.g_h>>4;
	  if(rww>r_width)  rww=r_width;
	  if(rwh>r_height) rwh=r_height;
	  wi.g_w=rww<<4;
	  wi.g_h=rwh<<4;
   	  wind_calc(WC_BORDER, SWIGADGETS, wi.g_x, wi.g_y, wi.g_w, wi.g_h,
			&msgbuf[4], &msgbuf[5],	&msgbuf[6], &msgbuf[7]);
	  wind_set(msgbuf[3], WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
	  if(rwx+rww>r_width)  rwx=r_width-rww;
	  if(rwy+rwh>r_height) rwy=r_height-rwh;
	  drawoffscr(rwx, rwy, rww, rwh);
	  if(smodus==0)
	   {
		wind_set(msgbuf[3], WF_HSLIDE, (int)((long)rwx*1000L/(r_width-rww)), 0, 0L);
		wind_set(msgbuf[3], WF_VSLIDE, (int)((long)rwy*1000L/(r_height-rwh)), 0, 0L);
		wind_set(msgbuf[3], WF_HSLSIZE, (int)((long)rww*1000L/r_width), 0, 0L);
		wind_set(msgbuf[3], WF_VSLSIZE, (int)((long)rwh*1000L/r_height), 0, 0L);
	   }
	   else
	   {
	    drwindow(&wi);
	   }
	  break;
   case WM_ARROWED:
	  if(smodus==1) break;
	  if((msgbuf[4]==WA_LFLINE && rwx==0) || (msgbuf[4]==WA_RTLINE && rwx+rww==r_width)
		 || (msgbuf[4]==WA_UPLINE && rwy==0) || (msgbuf[4]==WA_DNLINE && rwy+rwh==r_height) )
		break;
	  xy[0]=xy[1]=xy[4]=xy[5]=0;
	  xy[2]=xy[6]=rww*16-1; xy[3]=xy[7]=rwh*16-1;
	  switch(msgbuf[4])
	   {
		case WA_UPLINE:					/* Zeile nach oben */
		 --rwy;
		 xy[3]-=16; xy[5]+=16;
		 break;
		case WA_DNLINE:					/* Zeile nach unten */
		 ++rwy;
		 xy[1]+=16; xy[7]-=16;
		 break;
		case WA_LFLINE:					/* Spalte nach links */
		 --rwx;
		 xy[2]-=16; xy[4]+=16;
		 break;
		case WA_RTLINE:					/* Spalte nach rechts */
		 ++rwx;
		 xy[0]+=16; xy[6]-=16;
		 break;
		case WA_UPPAGE:					/* Seite nach oben */
		 rwy-=rwh;
		 if(rwy<0) rwy=0;
		 break;
		case WA_DNPAGE:					/* Seite nach unten */
		 rwy+=rwh;
		 if((unsigned short)rwy>r_height-rwh) rwy=r_height-rwh;
		 break;
		case WA_LFPAGE:					/* Seite nach links */
		 rwx-=rww;
		 if(rwx<0) rwx=0;
		 break;
		case WA_RTPAGE:					/* Seite nach rechts */
		 rwx+=rww;
		 if((unsigned short)rwx>r_width-rww) rwx=r_width-rww;
		 break;
	   }
	  if(msgbuf[4]==WA_UPLINE || msgbuf[4]==WA_DNLINE || msgbuf[4]==WA_LFLINE || msgbuf[4]==WA_RTLINE)
	   { /* Bei zeilenweise Scrollen: Mit vro_cpyfm kopieren statt Bild ganz neu aufzubauen! */
		vro_cpyfm(vhndl, 3, xy, &offscr, &offscr);
		switch(msgbuf[4])
	 	 {
		  case WA_UPLINE:
		   drawoffscr(rwx, rwy, rww, 1);
		   break;
		  case WA_DNLINE:
		   drawoffscr(rwx, rwy+rwh-1, rww, 1);
		   break;
		  case WA_LFLINE:
		   drawoffscr(rwx, rwy, 1, rwh);
		   break;
		  case WA_RTLINE:
		   drawoffscr(rwx+rww-1, rwy, 1, rwh);
		   break;
	     }
	   }
	   else drawoffscr(rwx, rwy, rww, rwh); /* Seitenweise: Bild neu aufbauen */
	  drwindow(&wi);		/* Jetzt ins Fenster kopieren */
	  setslider( (msgbuf[4]>=4)?1:2 );
	  break;
   case WM_HSLID:
	  if(smodus==1) break;
	  rwx=(long)msgbuf[4]*(r_width-rww)/1000L;
	  drawoffscr(rwx, rwy, rww, rwh);
	  drwindow(&wi);
	  setslider(1);
	  break;
   case WM_VSLID:
	  if(smodus==1) break;
	  rwy=(long)msgbuf[4]*(r_height-rwh)/1000L;
	  drawoffscr(rwx, rwy, rww, rwh);
	  drwindow(&wi);
	  setslider(2);
	  break;
  }
}
