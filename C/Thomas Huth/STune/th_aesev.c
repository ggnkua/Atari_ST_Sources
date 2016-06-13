/**
 * STune - The battle for Aratis
 * th_aesev.c : Handle AES events, keyclicks etc.
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

#include <stddef.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#include "stunegem.h"
#include "stunmain.h"
#include "stune.rsh"
#include "th_init.h"
#include "th_graf.h"
#include "th_aesev.h"
#include "th_musik.h"
#include "me_gemft.h"
#include "st_debug.h"
#include "st_net.h"
#include "stunfile.h"
#include "windial.h"
#include "building.h"
#include "th_intro.h"



/* **Variablen:** */
OBJECT *menu;                                      /* Adresse des Menues */
OBJECT *speeddlg;                                  /* Geschwindigkeitsdialog */
OBJECT *initdlg;
OBJECT *sounddlg;
OBJECT *langdlg;
OBJECT *strtdlg;
OBJECT *setupdlg;
OBJECT *netdia;
OBJECT *netinit;
OBJECT *netend;
OBJECT *netmsg;
char scrlsprflag=FALSE;                            /* TRUE=Sprites waehrend Scrolling zeichnen */
char gclipflag=TRUE;                               /* TRUE=Clipping immer an */
char fullscrflag=FALSE;


/* ***Fehlermeldung ausgeben*** */
void fm_error(char *msgtxt)
{
 char errtxt[256];
 int i;

 strcpy(errtxt, "[3][Error:|");
 strcat(errtxt, msgtxt);
 if(strlen(errtxt)>20)
  {
   i=15;
   while(errtxt[i]!=' ' && i<strlen(errtxt)) ++i;
   if(errtxt[i]==' ')  errtxt[i]='|';
  }
 strcat(errtxt, "][Grmpf]");
Dprintf(("fm_error: %s\n",errtxt));
 form_alert(1, errtxt);
}


/* ***Hauptmenu erlauben/nicht erlauben*** */
void enablemenu(short lflag)
{
  menu_ienable(menu, SPIELMEN, lflag);
  menu_ienable(menu, AKTIOMEN, lflag);
  menu_ienable(menu, OPTIOMEN, lflag);
  menu_ienable(menu, ABOUTIT, lflag);

  if(!fullscrflag)
  {
    menu_bar(menu, 1);
  }
}


/* ***Messagehandler fuer die Fensterdialoge*** */
void wdmsgs(int msgbf[])
{
 if( msgbf[0]==WM_REDRAW )
  {
   if(msgbf[3]==wihndl)
     drwindow((GRECT *)&msgbf[4]);
    else
     drwmwind((GRECT *)&msgbf[4]);
  }
 if( msgbf[0]==WM_MOVED )
  {
   wind_set(msgbf[3], WF_CURRXYWH, msgbf[4], msgbf[5], msgbf[6], msgbf[7]);
   if(msgbf[3]==wihndl)
     wind_calc(WC_WORK, WINDOWGADGETS, msgbf[4], msgbf[5], msgbf[6], msgbf[7],
               &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
    else
     wind_calc(WC_WORK, MWIGADGETS, msgbf[4], msgbf[5], msgbf[6], msgbf[7],
               &mwi.g_x, &mwi.g_y, &mwi.g_w, &mwi.g_h);
  }
}


/* ***Dialog fuer: Sprache einstellen*** */
void setup_lang(void (*msghndlr)(int msg[]), long msec, void (*tmrhndlr)(void))
{
 int wdh, i;

 wdh=wdial_init(langdlg, "STune", 0);
 wdial_formdo(wdh, langdlg, 0, msghndlr, msec, tmrhndlr);
 wdial_close(wdh, langdlg);
 langdlg[LANGOKAY].ob_state=NORMAL;
 for(i=LANGDE; i<=LANGCZ; i++)
  if( langdlg[i].ob_state&SELECTED )
   strcpy(langstr, langdlg[i].ob_spec.free_string);
 if( load_rsc(langstr) )
   form_alert(1, "[3][Could not|load the RSC!][Ok]");
 strcpy(levelinfo,"levels\\lvl_");
 strcat(levelinfo,langstr);
 strcat(levelinfo,".inf");
 if( loadinfofile(levelinfo) )
   if( loadinfofile("levels\\lvl_en.inf") )
    { form_alert(1, "[3][Can't load|level info file!][Ok]");}
      
}

/* ***Dialog fuer: Sound einstellen*** */
void setup_sound(void (*msghndlr)(int msg[]), long msec, void (*tmrhndlr)(void))
{
 int wdh;
 short exitbut;

 wdh=wdial_init(sounddlg, "Sound options", 0);
 do
  {
   exitbut=wdial_formdo(wdh, sounddlg, 0, msghndlr, msec, tmrhndlr) & 0x7FFF;
  }
 while(exitbut!=SOUNDOK);
 wdial_close(wdh, sounddlg);
 sounddlg[SOUNDOK].ob_state=NORMAL;
 sndmodflag=sounddlg[MODBGSND].ob_state&SELECTED;
 sndvocflag=sounddlg[VOICESAM].ob_state&SELECTED;
 sndpsgflag=sounddlg[PSGSND].ob_state&SELECTED;
 sndsamflag=sounddlg[SAMSND].ob_state&SELECTED;
 if(sndmodflag && ptyp==1 && !playflag)
   mod_play("musik\\alien.mod");
 if(!sndmodflag && ptyp==1 && playflag)
   mod_stop();
}

/* ***Dialog fuer: Geschwindigkeit einstellen*** */
void setup_speed(void (*msghndlr)(int msg[]), long msec, void (*tmrhndlr)(void))
{
 int wdh;
 short exitbut;

 wdh=wdial_init(speeddlg, "Game Speed", 0);
 do
  {
   exitbut=wdial_formdo(wdh, speeddlg, 0, msghndlr, msec, tmrhndlr) & 0x7FFF;
   if(exitbut==SPDLARRW) /* switch() scheint hier nicht richtig zu funken? */
    { if(gamespeed>0)  --gamespeed; else exitbut=0; }
   if(exitbut==SPDRARRW)
    { if(gamespeed<50)  ++gamespeed; else exitbut=0; }
   if(exitbut==SPDSLIDR)
    gamespeed = (int)(50L * graf_slidebox(speeddlg, SPDSLPAR, SPDSLIDR, 0) / 1000);
   if(exitbut!=SPEEDOK)
    {
     speeddlg[SPDSLIDR].ob_x=gamespeed*(speeddlg[SPDSLPAR].ob_width-speeddlg[SPDSLIDR].ob_width)/50;
     speeddlg[SPDSLIDR].ob_spec.tedinfo->te_ptext[0]='0'+gamespeed/10;
     speeddlg[SPDSLIDR].ob_spec.tedinfo->te_ptext[1]='0'+gamespeed%10;
     objc_draw(speeddlg, SPDSLPAR, 2, speeddlg->ob_x, speeddlg->ob_y,
               speeddlg->ob_width, speeddlg->ob_height);
    }
  }
 while(exitbut!=SPEEDOK);
 wdial_close(wdh, speeddlg);
 speeddlg[SPEEDOK].ob_state=NORMAL;
 if(speeddlg[SCROLLSP].ob_state&SELECTED)  scrlsprflag=TRUE; else scrlsprflag=FALSE;
 if(speeddlg[CLIPFLAG].ob_state&SELECTED)  gclipflag=1; else gclipflag=0;
}

/* ***Der Setup-Hauptdialog*** */
void setupdialog(void (*msghndlr)(int msg[]), long msec, void (*tmrhndlr)(void))
{
 int setupwh, but;
 enablemenu(0);
 do
  {
   setupwh=wdial_init(setupdlg, "STune options",0);
   but=wdial_formdo(setupwh, setupdlg, 0, msghndlr, msec, tmrhndlr) & 0x7FFF;
   wdial_close(setupwh, setupdlg);
   setupdlg[but].ob_state &= ~SELECTED;
   switch(but)
    {
     case SETUPLNG:
       setup_lang(msghndlr, msec, tmrhndlr);
       enablemenu(0);
       break;
     case SETUPSND:
       setup_sound(msghndlr, msec, tmrhndlr);
       break;
     case SETUPSPD:
       setup_speed(msghndlr, msec, tmrhndlr);
       break;
     case SETUPFSM:
       togglefullscreen(in_game_flag);
       break;
     case SETUPSAV:
       saveoptions();
       break;
    }
  }
 while( but!=SETUPOK );
 enablemenu(1);
}


/* ***Menue-Eintrag wurde angewaehlt*** */
void reactmenu(void)
{
 OBJECT *actdlg;
 int oldart, oldnr;
 int wdh;

 switch(msgbuf[4])
  {
   case ABOUTIT:                       /* Copyright anzeigen */
     enablemenu(0);
     rsrc_gaddr(R_TREE, ABOUTSTN, &actdlg);
     wdh=wdial_init(actdlg, "About STune", 0);
     wdial_formdo(wdh, actdlg, 0, wdmsgs, gamespeed, timer_fun);
     wdial_close(wdh, actdlg);
     enablemenu(1);
     actdlg[ABOUTOK].ob_state=NORMAL;
     break;
   case SAVEAS:
     fileselect(savename, "*.SAV", "Save game");
   case SAVEGAME:
     savegame();
     break;
   case MENPAUSE:
     if(netflag) break;
     rsrc_gaddr(R_TREE, PAUSEDLG, &actdlg);
     enablemenu(0);
     wdh=wdial_init(actdlg, "STune", 0);
     wdial_formdo(wdh, actdlg, 0, wdmsgs, -1, 0L);
     wdial_close(wdh, actdlg);
     enablemenu(1);
     actdlg[PAUSEOK].ob_state=NORMAL;
     break;
   case MENFULL:
     togglefullscreen(TRUE);
     break;
   case MENQUIT:                        /* Spiel verlassen */
     /*if(form_alert(2, "[1][Quit STune?][Quit|Continue]")==1)*/
      exitflag=TRUE; /* else break; */
   case MENABORT:                       /* Spiel abbrechen */
     endeflag=TRUE;
     break;
   case SETSPEED:                      /* Geschwindigkeit einstellen */
     enablemenu(0);
     setup_speed(wdmsgs, gamespeed, timer_fun);
     enablemenu(1);
     break;
   case SETSOUND:                      /* Sounddialog */
     enablemenu(0);
     setup_sound(wdmsgs, gamespeed, timer_fun);
     enablemenu(1);
     break;
   case MENLANG:                        /* Sprache auswaehlen */
     enablemenu(0);
     setup_lang(wdmsgs, gamespeed, timer_fun);
     enablemenu(1);
     break;
   case OPTSAVE:
     saveoptions();
     break;
   case GREPA:                         /* Gebaeude reparieren */
     oldart=ak_art;  oldnr=ak_nr;
     ak_art=4;
     infos_neu_zeichnen(oldart, oldnr);
     break;
   case GVERKAUF:                      /* Gebaeude verkaufen */
     oldart=ak_art;  oldnr=ak_nr;
     ak_art=5;
     infos_neu_zeichnen(oldart, oldnr);
     break;
  }

 if(!fullscrflag) menu_tnormal(menu, msgbuf[3], 1);
}


/* ***Tastendruecke*** */
void keyklicks(void)
{
 short use_reactmen;
 int i,d;
 int oldart, oldnr;
 char scancode, asciicode;
 int xy[8];

 use_reactmen=FALSE;
 scancode=key>>8;
 asciicode=(char)key;

/* Dprintf(("Taste gedrueckt: key=0x%x\n", key)); */

 if(kstate==0)                                /* Normale Taste? */
  {
   switch(asciicode)
    {
     case 'y':
     case 'z':                                /* Z/Y: Geb. platzieren */
       if( !(gebpopobj[GEBSET].ob_state & DISABLED) )
        {
         oldart=ak_art;  oldnr=ak_nr;
         ak_art=3;
         infos_neu_zeichnen(oldart, oldnr);
        }
       break;
     case 'r':                               /* R: Geb. reparieren */
       oldart=ak_art;  oldnr=ak_nr;
       ak_art=4;
       infos_neu_zeichnen(oldart, oldnr);
       break;
     case 'v':                               /* V: Geb. verkaufen */
       oldart=ak_art;  oldnr=ak_nr;
       ak_art=5;
       infos_neu_zeichnen(oldart, oldnr);
       break;
     case 'o':
       setupdialog(wdmsgs, gamespeed, timer_fun);
       break;
     case 'm':
       if(netflag)
       {
        rsrc_gaddr(R_TREE, NETMSG, &netmsg);
        d=wdial_init(netmsg, "STune", 0);
        i=wdial_formdo(d, netmsg, NMSGTEXT, wdmsgs, gamespeed, timer_fun);
        netmsg[i].ob_state&=~SELECTED;
        if(i==NMSGSEND)
        {
#if DEBUGGING
        if( trans.art ) Dprintf(("trans.art ist nicht null!\n"));
#endif
         trans.art=2;  /* Textnachricht */
         strcpy(net_msg,netmsg[NMSGTEXT].ob_spec.tedinfo->te_ptext);
        }
        wdial_close(d, netmsg);
       }
       break;
     case 'p':                                    /* Pause */
       if(netflag) break;
       if(fullscrflag)
        {
         evnt_keybd();
        }
        else
        {
         msgbuf[3]=SPIELMEN;  msgbuf[4]=MENPAUSE;
         use_reactmen=TRUE;
        }
       break;
     case 'c':                               /* Bauanlage zentrieren */
       center_bauanlage(TRUE);
       break;
     case 'w':                               /* hoch */
       msgbuf[4]=WA_UPLINE;
       break;
     case 'a':                               /* links */
       msgbuf[4]=WA_LFLINE;
       break;
     case 's':                               /* runter */
       msgbuf[4]=WA_DNLINE;
       break;
     case 'd':                               /* rechts */
       msgbuf[4]=WA_RTLINE;
       break;
     case '1':
     case '2':
     case '3':
     case '4':
     case '5':
       for(i=0;i<=9;i++)
       ak_einh[i]=groups[scancode-2][i];
       ak_art=2;
       break;
#if DEBUGGING
     case 'i':
       debug_on_key();
       break;
#endif
    }
   if(asciicode=='a' || asciicode=='s' || asciicode=='d' || asciicode=='w')
    {                                         /* Scrollen */
     msgbuf[0]=WM_ARROWED;
     mesages();
    }
  }

 if(kstate==K_CTRL)                           /* Control + Taste */
  {
   switch(scancode)
   {
    case 0x10:                                /* ^Q : Spiel verlassen */
      msgbuf[3]=SPIELMEN;  msgbuf[4]=MENQUIT;
      use_reactmen=TRUE;
      break;
    case 0x11:                                /* ^W : Fenster wechseln */
      if(!fullscrflag)
       {
        wind_get(0, WF_TOP, &i, &d, &d, &d);
        if(i==wihndl)
          { wind_set(mwihndl, WF_TOP, 0,0,0,0); winfokus=mwihndl; }
         else
          { wind_set(wihndl, WF_TOP, 0,0,0,0);  winfokus=wihndl; }
       }
      break;
    case 0x1E:                                /* ^A : Spiel abbrechen */
      endeflag=TRUE;
      break;
    case 0x02:
    case 0x03:
    case 0x04:
    case 0x05:
    case 0x06:
      for(i=0;i<=ak_einh[0];i++)
        groups[scancode-2][i]=ak_einh[i];
      break;
   }
  }

#if 1     /* Eastereggs */
 if(kstate==(K_ALT|K_RSHIFT))
  {
   switch(scancode)
    {
     case 0x12:                                    /* ALT-RS-E: XOR screen */
       xy[0]=xy[4]=wi.g_x; xy[1]=xy[5]=wi.g_y;
       xy[2]=xy[6]=wi.g_x+wi.g_w-1; xy[3]=xy[7]=wi.g_y+wi.g_h-1;
       vro_cpyfm(vhndl, 10, xy, &scrnmfdb, &scrnmfdb);
       break;
     case 0x31:                                    /* ALT-RS-N: Blinded */
       xy[0]=xy[4]=wi.g_x; xy[1]=xy[5]=wi.g_y;
       xy[2]=xy[6]=wi.g_x+wi.g_w-1; xy[3]=xy[7]=wi.g_y+wi.g_h-1;
       vro_cpyfm(vhndl, 15, xy, &scrnmfdb, &scrnmfdb);
       for(d=0; d<r_height; d++)
        for(i=0; i<r_width; i++)
         if(!sfeld[i][d].besetzt)
          sfeld[i][d].erforscht=FALSE;
       break;
     case 0x57:                                    /* ALT-RS-F4: Erleuchtung */
       for(d=0; d<r_height; d++)
        for(i=0; i<r_width; i++)
         sfeld[i][d].erforscht=TRUE;
       drawoffscr(rwx, rwy, rww, rwh);
       drwindow(&wi);
       break;
     case 0x32:                                    /* ALT-RS-M: Slogan */
       neuemeldung("Macrosaft must die! ");
       break;
     case 0x22:                                    /* ALT-RS-G: Greetings */
       enablemenu(FALSE);
       intro_start(greetinx);
       intro_main();
       enablemenu(TRUE);
       break;
     case 0x66:                                    /* Thothys kleines Geheimnis! ;-) */
       for(i=0; i<lleinh; i++)
        {
         einheiten[i].gesinnung=0;
         sfeld[einheiten[i].xpos][einheiten[i].ypos].gesinnung=0;
        }
       for(i=0; i<llgeb; i++)
        geb[i].gesinnung=0;
       break;
    }
  }
#endif

 if(kstate<=3)                                /* H”chstens Shift + Taste */
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
     case 0x01:                               /* ESC: Fullscreen */
       togglefullscreen(TRUE);
       break;
    }
   if(scancode==0x48 || scancode==0x4B || scancode==0x50 || scancode==0x4D)
    {                                         /* Cursortaste */
     msgbuf[0]=WM_ARROWED;
     if( kstate & (K_RSHIFT|K_LSHIFT) )  msgbuf[4]-=2;
     mesages();
    }
  }

 if(use_reactmen)
  {
   if(!fullscrflag) menu_tnormal(menu, msgbuf[3], 0);
   reactmenu();
  }
}


/* ***Slider und Kartenmarkierung neu setzen*** */
void setslidnmarker(short sldrflg, short oldx, short oldy)
{
 GRECT rdtmp;

 /* Neues Rechteck auf Karte zeichnen und altes l”schen: */
 rdtmp.g_w=rww;  rdtmp.g_h=rwh;
 rdtmp.g_x=mwi.g_x+oldx+(128-r_width)/2;  rdtmp.g_y=mwi.g_y+oldy;
 drwmwind(&rdtmp);
 rdtmp.g_x=mwi.g_x+rwx+(128-r_width)/2;  rdtmp.g_y=mwi.g_y+rwy;
 drwmwind(&rdtmp);

 /* Slider updaten: */
 if(!fullscrflag)
  {
   if(sldrflg&1) wind_set(wihndl, WF_HSLIDE, (int)((long)rwx*1000L/(r_width-rww)), 0,0,0);
   if(sldrflg&2) wind_set(wihndl, WF_VSLIDE, (int)((long)rwy*1000L/(r_height-rwh)), 0,0,0);
  }
}


/* ***Nachrichten*** */
void mesages(void)
{
 int xy[8];
 int omx, omy;

 switch(msgbuf[0])
  {
   case MN_SELECTED:
     reactmenu();
     break;
   case WM_REDRAW:
     if(msgbuf[3]==wihndl)
       drwindow((GRECT *)&msgbuf[4]);
      else
       drwmwind((GRECT *)&msgbuf[4]);
     break;
   case WM_TOPPED:
     setpal(newpal);
     wind_set(msgbuf[3], WF_TOP, 0,0,0,0);
     winfokus=msgbuf[3];
     break;
   case WM_ONTOP:
     setpal(newpal);
     break;
   case WM_MOVED:
     wind_set(msgbuf[3], WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
     if(msgbuf[3]==wihndl)
       wind_calc(WC_WORK, WINDOWGADGETS, msgbuf[4], msgbuf[5],
           msgbuf[6], msgbuf[7], &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
      else
       wind_calc(WC_WORK, MWIGADGETS, msgbuf[4], msgbuf[5],
           msgbuf[6], msgbuf[7], &mwi.g_x, &mwi.g_y, &mwi.g_w, &mwi.g_h);
     break;
   case WM_FULLED:
     wind_get(msgbuf[3], WF_FULLXYWH, &msgbuf[4], &msgbuf[5], &msgbuf[6], &msgbuf[7]);
   case WM_SIZED:
     wind_calc(WC_WORK, WINDOWGADGETS, msgbuf[4], msgbuf[5],
         msgbuf[6], msgbuf[7], &wi.g_x, &wi.g_y, &wi.g_w, &wi.g_h);
     rww=wi.g_w>>4;
     rwh=wi.g_h>>4;
     if(rww>r_width)  rww=r_width;
     if(rwh>r_height) rwh=r_height;
     wi.g_w=rww<<4;
     wi.g_h=rwh<<4;
     if( wi.g_w>(deskw&0xFFF0) ) wi.g_w=(deskw&0xFFF0);
     if( wi.g_h>(deskh&0xFFF0) ) wi.g_h=(deskh&0xFFF0);
     wind_calc(WC_BORDER, WINDOWGADGETS, wi.g_x, wi.g_y, wi.g_w, wi.g_h,
         &msgbuf[4], &msgbuf[5], &msgbuf[6], &msgbuf[7]);
     wind_set(msgbuf[3], WF_CURRXYWH, msgbuf[4], msgbuf[5], msgbuf[6], msgbuf[7]);
     if(rwx+rww>r_width)  rwx=r_width-rww;
     if(rwy+rwh>r_height) rwy=r_height-rwh;
     drawoffscr(rwx, rwy, rww, rwh);
     /* Set window sliders: */
     if(rww<r_width)
     {
       wind_set(msgbuf[3], WF_HSLIDE, (int)((long)rwx*1000L/(r_width-rww)), 0,0,0);
       wind_set(msgbuf[3], WF_HSLSIZE, (int)((long)rww*1000L/r_width), 0,0,0);
     }
     else
     {
       wind_set(msgbuf[3], WF_HSLIDE, 1000, 0,0,0);
       wind_set(msgbuf[3], WF_HSLSIZE, 1000, 0,0,0);
     }
     if(rwh<r_height)
     {
       wind_set(msgbuf[3], WF_VSLIDE, (int)((long)rwy*1000L/(r_height-rwh)), 0,0,0);
       wind_set(msgbuf[3], WF_VSLSIZE, (int)((long)rwh*1000L/r_height), 0,0,0);
     }
     else
     {
       wind_set(msgbuf[3], WF_VSLIDE, 1000, 0,0,0);
       wind_set(msgbuf[3], WF_VSLSIZE, 1000, 0,0,0);
     }
     /* Redraw map window: */
     xy[0]=mwi.g_x+(128-r_width)/2;  xy[1]=mwi.g_y;
     xy[2]=r_width;                  xy[3]=r_height;
     drwmwind((GRECT *)xy);
     break;
   case WM_ARROWED:
     if((msgbuf[4]==WA_LFLINE && rwx==0) || (msgbuf[4]==WA_RTLINE && rwx+rww==r_width)
        || (msgbuf[4]==WA_UPLINE && rwy==0) || (msgbuf[4]==WA_DNLINE && rwy+rwh==r_height) )
      break;
     omx=rwx; omy=rwy;
     xy[0]=xy[1]=xy[4]=xy[5]=0;
     xy[2]=xy[6]=rww*16-1; xy[3]=xy[7]=rwh*16-1;
     switch(msgbuf[4])
      {
       case WA_UPLINE:                 /* Zeile nach oben */
         --rwy;
         xy[3]-=16; xy[5]+=16;
         break;
       case WA_DNLINE:                 /* Zeile nach unten */
         ++rwy;
         xy[1]+=16; xy[7]-=16;
         break;
       case WA_LFLINE:                 /* Spalte nach links */
         --rwx;
         xy[2]-=16; xy[4]+=16;
         break;
       case WA_RTLINE:                 /* Spalte nach rechts */
         ++rwx;
         xy[0]+=16; xy[6]-=16;
         break;
       case WA_UPPAGE:                 /* Seite nach oben */
         rwy-=rwh;
         if(rwy<0) rwy=0;
         break;
       case WA_DNPAGE:                 /* Seite nach unten */
         rwy+=rwh;
         if(rwy>r_height-rwh) rwy=r_height-rwh;
         break;
       case WA_LFPAGE:                 /* Seite nach links */
         rwx-=rww;
         if(rwx<0) rwx=0;
         break;
       case WA_RTPAGE:                 /* Seite nach rechts */
         rwx+=rww;
         if(rwx>r_width-rww) rwx=r_width-rww;
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
     drwindow(&wi);                    /* Jetzt ins Fenster kopieren */
     if(scrlsprflag)  drawsprites();
     setslidnmarker( (msgbuf[4]>=4)?1:2, omx, omy);
     break;
   case WM_HSLID:
     omx=rwx;
     rwx=(long)msgbuf[4]*(r_width-rww)/1000L;
     drawoffscr(rwx, rwy, rww, rwh);
     drwindow(&wi);
     setslidnmarker(1, omx, rwy);
     break;
   case WM_VSLID:
     omy=rwy;
     rwy=(long)msgbuf[4]*(r_height-rwh)/1000L;
     drawoffscr(rwx, rwy, rww, rwh);
     drwindow(&wi);
     setslidnmarker(2, rwx, omy);
     break;
   case AP_TERM:                                     /* Shutdown? */
   case AP_RESCHG:
     exitflag=TRUE;
   case WM_CLOSED:                                   /* Spielende */
     endeflag=TRUE;
    break;
  }
}
