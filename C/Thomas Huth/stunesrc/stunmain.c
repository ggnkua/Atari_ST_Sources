/**
 * STune - The battle for Aratis
 * stunmain.c : main() and other core functions.
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
#include <string.h>
#include <stdio.h>
#include <stddef.h>
#include <stdlib.h>

#include "stunedef.h"
#include "stunegem.h"
#include "units.h"
#include "building.h"
#include "th_init.h"
#include "th_graf.h"
#include "th_aesev.h"
#include "th_musik.h"
#include "th_intro.h"
#include "me_routi.h"
#include "me_ausla.h"
#include "me_gemft.h"
#include "me_kifkt.h"
#include "st_debug.h"
#include "stunfile.h"
#include "stune.rsh"
#include "st_net.h"
#include "windial.h"
#include "transprt.h"


#if DEBUGGING
int DBfhndl;
#endif


/* ************Variablen:************ */
int ap_id;                              /* AES-Handle */
int vhndl;                              /* VDI-Handle */
int deskx, desky, deskw, deskh;         /* Desktopausmaûe */
int scrwidth, scrheight;                /* Bildschirmauflîsung */
int wihndl;                             /* Fenster-Handle */
int mwihndl;                            /*  " fÅrs Steuerfenster */
GRECT wi;                               /* Fenster-Koordinaten */
GRECT mwi;                              /* Steuerfenster-Koord. */
int mausx, mausy, mausk, klicks;        /* Zur Mausabfrage */
int kstate, key;                        /* Zur Tastaturabfrage */
short mb_pressed;                       /* War der Mausknopf gedrÅckt? */
int msgbuf[8];                          /* Der Nachrichtenbuffer */
short wichevnt;                         /* Aufgetretene Evnt-Multi-Ereignisse */
const int ereig=MU_TIMER|MU_MESAG|MU_BUTTON|MU_KEYBD; /* FÅr evnt_multi */
int winfokus;                           /* Welches Fenster ist weiter vorne? */

int endeflag=FALSE;                     /* TRUE=Spiel verlassen */
int radarflag=FALSE;                    /* TRUE=Karte weiter aufdeckbar */
int geb_gebaut=FALSE;                   /* kein Gebaeude gebaut */
int netflag=FALSE;
int exitflag=FALSE;
int level_done=FALSE;                   /* 1= verloren, 2=gewonnen */
int in_game_flag=FALSE;                 /* TRUE=gerade im Spiel */

int gamespeed=0;                        /* Spieltakt (->evnt_multi) */
char *langstr="de";                     /* Aktuelle Sprache */

char moneystr[]=" 10000$";              /* String fÅr Geldstandanzeige */
unsigned int knete[2]={10000, 10000};   /* Geld d. Compis und eigenes */
unsigned int oldknete;
unsigned short lleinh=0;
unsigned short llgeb=0;
signed int energie;
COMP_GEB geblist[15];                   /* GebÑude, die der Compi noch bauen muû */
unsigned long timer_counter;

SPIELFELD sfeld[128][128];              /* Das Spielfeld */
short rwx=0, rwy=0;                     /* Ab diesem Planquadrat beginnt das Fenster */
short rww=18, rwh=9;                    /* Aktuelle Fenstergrîûe (in Planquadraten) */
short r_width=56, r_height=40;          /* Raumausmaûe */
int box_width,box_height;               /* Rubber-Box */
int im_spielfeld;                       /* Mauszeiger-im-Spielfeldbereich-Flag */
int im_infowin;                         /* Mauszeiger im Info/Kartenfenster? */
short xposition, yposition;             /* Spielfeldkoordinaten, Åber denen sich der Mauszeiger befindet */
int statusypos;                         /* y-pos vom der Statusanzeige im Infofenster */

AUS ausrzahl[8];
EINHEIT einheiten[256];                 /* Die Einheiten */
unsigned short ak_nr=0;                 /* Nummer der ausg. Einheit (0=keine Einheit ausgewÑhlt) */
unsigned short ak_art=0;                /* ak_art: 0=nichts ausgewÑhlt */
                                        /*         1=GebÑude aktiv */
                                        /*         2=Einheit aktiv */
                                        /*         3=GebÑude setzen (?) */
                                        /*         4=GebÑude reparieren (?) */
                                        /*         5=GebÑude verkaufen (?) */
unsigned short ak_einh[10];             /* selektierte Einheiten: [0] enthÑlt anzahl */
unsigned short groups[5][10];           /* definierte Gruppen */

GEBAEUDE geb[100];                      /* 100 sollten reichen */
GEB_D gebaeude_typ[13];                 /* die verschiedenen Typen */
EIN_D einheit_typ[20];

char stunepath[120];                    /* Das STune-Hauptverzeichnis */
char levelpath[128];                    /* Pfad mit den Leveldateien */
char levelname[136];                    /* Pfad+Name des akt. Levels */
char leveltitel[32];                    /* Titel des Levels */
char levelinfo[20];                     /* Name des Levelinfofiles */
char musicpath[128];                    /* Pfad mit den Musikdateien */
char musicname[140];                    /* Pfad+Name des akt. MOD */
char savename[140];                     /* Pfad+Name der Spielstandes */


short techlevelnr;
short level=0;
short spielart=0;                       /* 0=Kampagne; 1=GeplÑnkel; 2=Multi */
char *lvldescription=NULL;              /* Zeiger auf Levelinformationstext */

int nethandle=0;
TRANSMIT trans;
char p1name[13], p2name[13];            /* Die Spielernamen */
char net_msg[40];                       /* Die Textnachrichten */

short startzeit;                        /* Zum berechnen der Spielzeit */




#if DEBUGGING
/* ***Wenn 'i' gedrÅckt wurde, wird diese Funktion Aufgerufen*** */
void debug_on_key()
{
 Dprintf(("Gerade %i Einheiten und %i GebÑude in der Liste\n", lleinh, llgeb));
 Dprintf(("sizeof(SPIELFELD)=%i\n",(int)sizeof(SPIELFELD)));
 Dprintf(("offscr.fd_w=%i, offscr.fd_h=%i\n", offscr.fd_w, offscr.fd_h));
 Dprintf(("bipp=%i\n", bipp));
}
#endif





/* ************RegelmÑûig aufzurufende Funktion************ */
void timer_fun(void)
{
 short stat;

 if(netflag)
   if((timer_counter&7)==7)
    {
     if(trans.art==0)
      { trans.timer_nr=timer_counter;  Dprintf(("Nullevent at %li\n",timer_counter)); }
     net_write(nethandle, &trans, sizeof(trans), 1);
     if(trans.art==2)
       net_write(nethandle, net_msg, sizeof(net_msg), 1);
     stat=net_read(nethandle, &trans, sizeof(trans), 1);
     if(stat==E_NODATA)
      {
       endeflag=1;
       fm_error(get_err_text(stat));
       netflag=0;
       net_close(nethandle);
       Dprintf(("NODATA bei net_read\n"));
      }
     if(stat==E_EOF)
      {
       endeflag=1;
       fm_error(get_err_text(stat));
       netflag=0;
       net_close(nethandle);
      }
     #if DEBUGGING
       if(stat<0 && stat!=E_EOF && stat!=E_NODATA)
         Dprintf(("Netzfehler %i: %s", stat, get_err_text(stat) ));
     #endif
     if(stat>=0)
      to_do_list(trans);
     trans.art=0;
    }

 abarbeiten();
 if (!netflag) abarbeiten_computer();
 drawsprites();
 meldungenabarbeiten();
 sam_abarbeiten();
 if(oldknete!=knete[0] && !(timer_counter&0x07)) /* GeldzÑhler neu zeichnen? */
  {
   GRECT clip, z; int i, k;
   for(i=0; i<6; i++)  moneystr[i]=' ';
   k=knete[0];
   for(i=5; k>=10; i--)  k/=10;
   sprintf(&moneystr[i], "%i", knete[0]);
   moneystr[6]='$';
   vst_point(vhndl, 10, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
   z.g_x=mwi.g_x; z.g_y=mwi.g_y+statusypos; z.g_w=56; z.g_h=16;
   i=0;
   if(fullscrflag)
     if(modaldlgflag) clip=fsdlgclip[0]; else clip=mwi;
    else
    {
     wind_update(BEG_UPDATE);
     wind_get(mwihndl, WF_FIRSTXYWH, &clip.g_x, &clip.g_y, &clip.g_w, &clip.g_h);
    }
   while(clip.g_w!=0 && clip.g_h!=0)
    {
     if( rc_intersect(&z, &clip) )
      {
       clip.g_w+=clip.g_x-1;  clip.g_h+=clip.g_y-1;
       vs_clip(vhndl, 1, (int *)&clip);
       v_gtext(vhndl, mwi.g_x+4, mwi.g_y+2+statusypos, moneystr);
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
    }
   if(!fullscrflag)  wind_update(END_UPDATE);
   vs_clip(vhndl, gclipflag, deskclip);
   oldknete=knete[0];
  }
 if((timer_counter&255)==255) auftrag_erledigt(); /* Level geschafft ? */
 timer_counter++;
}



/****** Die Spiel-Haupt-Funktion ******/
void run_game_engine(void)
{

 einh_verl[0]=einh_verl[1]=0;
 geb_verl[0]=geb_verl[1]=0;
 saft_ges[0]=saft_ges[1]=0;

 timer_counter=0;  

 strcpy(musicname, musicpath);
 strcat(musicname, "alien.mod");
 mod_stop();
 if( ptyp==1 && sndmodflag)
   if( mod_play(musicname) ) form_alert(1, "[3][Could not load|or play the MOD file][Ok]");

 if(netflag)
  {
   trans.art=0;
   trans.timer_nr=0;
   net_write(nethandle, &trans, sizeof(trans), 0);
  }

 if( open_window() )         /* Fenster initialisieren und îffnen */
  { exitGEM(); mod_stop(); exit(-1); }

 center_bauanlage(TRUE);

 /* Popups vorbereiten: */
 geb[0].art=KASERNE; normalize_popups(0);
 geb[0].art=BAUANLAGE; normalize_popups(0);
 geb[0].art=FABRIK_KL; normalize_popups(0);
 geb[0].art=FABRIK_GR; normalize_popups(0);
 geb[0].art=0;

 startzeit=Tgettime();
 startzeit=((startzeit>>11)&31)*60+((startzeit>>5)&63);

 in_game_flag=TRUE;

 /* Die Hauptschleife: */
 do
 {
  wichevnt=evnt_multi(ereig, 0x101, 3, (mb_pressed?3:0), 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
             msgbuf, gamespeed, 0, &mausx, &mausy, &mausk, &kstate, &key, &klicks);

  if(mausx>wi.g_x && mausx<wi.g_x+wi.g_w-1 && mausy>wi.g_y && mausy<wi.g_y+wi.g_h-1)
     im_spielfeld=TRUE; else im_spielfeld=FALSE;

  if(im_spielfeld)
   {
    xposition=((mausx-wi.g_x)>>4)+rwx;
    yposition=((mausy-wi.g_y)>>4)+rwy;
   }
 im_infowin=mausx>mwi.g_x && mausx<mwi.g_x+mwi.g_w-1 && mausy>mwi.g_y && mausy<mwi.g_y+mwi.g_h-1;

 if(wichevnt & MU_TIMER)
   {
    if(im_spielfeld)
       set_mouse(xposition,yposition);
    else
      if(im_infowin && ak_art)
        set_mouse(mausx-mwi.g_x-rwx,mausy-mwi.g_y-INFHEIGHT-rwy);
       else
        changemouseform(ARROW);
    if(fullscrflag)
     {
      int doscrflag=0;
      if(mausx<8)
       { doscrflag=1; msgbuf[4]=WA_LFLINE; }  /* links */
      if(mausx>scrwidth-8)
       { doscrflag=1; msgbuf[4]=WA_RTLINE; }  /* rechts */
      if(mausy<8)
       { doscrflag=1; msgbuf[4]=WA_UPLINE; }  /* oben */
      if(mausy>scrheight-8)
       { doscrflag=1; msgbuf[4]=WA_DNLINE; }  /* unten */
      if(doscrflag)
       {
        msgbuf[0]=WM_ARROWED;
        mesages();
       }
     }
    timer_fun();
   }

  if(wichevnt & MU_BUTTON)
   {
    if(mb_pressed)
    {
     graf_mkstate(&mausx, &mausy, &mausk, &kstate);
     if(mausk==0) mb_pressed=FALSE;
       if(mb_pressed && mausk==1 && ak_art==0 && !netflag)
       {
           changemouseform(POINT_HAND);
           if(graf_rubbox(mausx,mausy,4,4,&box_width,&box_height))
           {
             unsigned short old_art=ak_art, old_nr=ak_nr;
             box_width/=16; box_height/=16;
             if(xposition+box_width>rww+rwx) box_width=rww+rwx-xposition; /* nur sichtbarer bereich abdecken */
             if(yposition+box_height>rwh+rwy) box_height=rwh+rwy-yposition;
             einheiten_selektieren(xposition,yposition,box_width,box_height);
             if(old_art!=ak_art || old_nr!=ak_nr)
              infos_neu_zeichnen(old_art, old_nr);
           }           
       }
    }
    else
    {
    if( im_spielfeld && (winfokus==wihndl || !im_infowin) )
     {
      unsigned short old_nr, old_art;
      mb_pressed=TRUE;
      old_nr=ak_nr; old_art=ak_art;
      if(mausk==1)
          geklickt(ak_nr, ak_art,mausx-wi.g_x ,mausy-wi.g_y);
       else /*if(mausk==2)*/
        {
         if(ak_art==1 && !geb[ak_nr].gesinnung)
         {
          if(nummer_ermitteln(xposition, yposition, 0)==ak_nr)
          {
            changemouseform(ARROW);
            switch(geb[ak_nr].art)
            {
             case KASERNE:  popup_kaserne(); break;
             case FABRIK_KL: popup_fabrik_kl(); break;
             case FABRIK_GR: popup_fabrik_gr(); break;
             case BAUANLAGE: popup_bauanlage(); break;
            }
          }
          else {ak_art=0; ak_nr=0; ak_einh[0]=0;}
         }
         else {ak_art=0; ak_nr=0; ak_einh[0]=0;}
        }
      if(old_nr!=ak_nr || old_art!=ak_art) /* Einheit/GebÑude gewechselt? */
        infos_neu_zeichnen(old_art, old_nr);
     }
    else if(im_infowin)
     {
      unsigned short old_nr, old_art;
      old_nr=ak_nr; old_art=ak_art;
      if(mausk==1)
      {
       if(ak_art==0)
       {
        if( mausy-mwi.g_y<r_height )     /* Auf Karte geklickt? */
         {
          short omx=rwx, omy=rwy;
          rwx=mausx-mwi.g_x-(128-r_width)/2-rww/2;
          rwy=mausy-mwi.g_y-rwh/2;
          if(rwx+rww>r_width) rwx=r_width-rww;
          if(rwy+rwh>r_height) rwy=r_height-rwh;
          if(rwx<0) rwx=0;
          if(rwy<0) rwy=0;
          drawoffscr(rwx, rwy, rww, rwh);
          drwindow(&wi);
          setslidnmarker(3, omx, omy);
         }
       }
       else
       {
        mb_pressed=TRUE;
        geklickt(ak_nr, ak_art,(mausx-mwi.g_x-rwx)*16,(mausy-mwi.g_y-INFHEIGHT-rwy)*16);
       }
     }
     else {ak_art=0; ak_nr=0;}
     if(old_nr!=ak_nr || old_art!=ak_art)  /* Einheit/GebÑude gewechselt? */
      infos_neu_zeichnen(old_art, old_nr);
    }
   }
  }

  if(wichevnt & MU_MESAG)
    mesages();

  if(wichevnt & MU_KEYBD)
    keyklicks();

 }
 while( !endeflag && !level_done);

 if(netflag)
  {
   trans.art=3;    /* Dem Gegner melden! */
   net_write(nethandle, &trans, sizeof(trans), 1);
   evnt_timer(1000,0);
   net_close(nethandle);
  }

 if(fullscrflag)
  {
   if(exitflag)
     togglefullscreen(windowsareopen);
    else
    {
     graf_mouse(M_OFF, 0L);
     vsf_color(vhndl, 1);
     v_bar(vhndl, deskclip); 
     graf_mouse(M_ON, 0L);
    }
  }

 in_game_flag=FALSE;

 close_window();

 mod_stop();

}



/* ************Die Hauptroutine************ */
int main(void)
{
 int iwdh;
 int exitbut;

#if DEBUGGING
 DBfhndl=Fcreate("debuglog.txt",0);
 Fforce(1,DBfhndl);
 Dprintf(("Debugfile - STune compiliert am %s, %s Uhr.\n",__DATE__,__TIME__));
#endif

  /* Pfad ermitteln: */
 stunepath[0]='A'+Dgetdrv(); stunepath[1]=':';
 Dgetpath(&stunepath[2], 0);
 if(stunepath[strlen(stunepath)-1]!='\\') strcat(stunepath, "\\");
 strcpy(levelpath, stunepath);
 strcat(levelpath, "levels\\");
 strcpy(musicpath, stunepath);
 strcat(musicpath, "musik\\");
 strcpy(savename, stunepath);
 strcat(savename, "save\\DEFAULT.SAV");

 if( initGEM() )  return(-1);            /* Beim GEM anmelden */

 loadoptions();

 if( load_rsc(langstr) )
  {
   if(!strcmp("en", langstr))
     langstr="de"; else langstr="en";
   if( load_rsc(langstr) )
    if( load_rsc(NULL) )
     {
      form_alert(1, "[3][Could not|load the RSC!][Ok]");
      exitGEM();
      return(-1);
     }
  }

 if(fullscrflag)                    /* Im Fullscreenmodus starten? */
  {
   fullscrflag=0;   /* Wird in togglefullscreen wieder "getoggelt" */
   togglefullscreen(FALSE);
  }

 enablemenu(0);
 changemouseform(BUSYBEE);
 iwdh=wdial_init(initdlg, "Initialisation",1);

 gebaeude_definieren();
 einheiten_definieren();
 ausrzahl_definieren();                  /* vereinfacht ausweichen */

 strcpy(levelinfo,"levels\\lvl_");
 strcat(levelinfo,langstr);
 strcat(levelinfo,".inf");
 if( loadinfofile(levelinfo) )
   if( loadinfofile("levels\\lvl_en.inf") )
     if( loadinfofile("levels\\lvl_de.inf") )
     { form_alert(1, "[3][Can't load|level info file!][Ok]");
      wdial_close(iwdh, initdlg); exitGEM(); exit(-1); }

 if( initgraf() )
  { form_alert(1, "[3][Error while|initializing the|graphics!][Ok]");
    wdial_close(iwdh, initdlg); exitGEM(); exit(-1); }

 /* Musik initialisieren: */
 if( mod_init() )
  {
   /*form_alert(1, "[3][Konnte Player nicht|initialisieren][Ok]");*/
   sounddlg[MODBGSND].ob_state|=DISABLED;
  }

 if( initsamples() )
   form_alert(1, "[3][Could not load|the sound samples][Ok]");

 wdial_close(iwdh, initdlg);

 if( xgetcookie(0x5354694BL, NULL)==0 )  /* 0x5354694BL='STiK' */
   strtdlg[STRTNET].ob_state|=DISABLED;

 if( loadhighscore() )
   strtdlg[STRTHIGH].ob_state|=DISABLED; 
 else 
   strtdlg[STRTHIGH].ob_state&=~DISABLED;

 strcpy(musicname, musicpath);
 strcat(musicname, "dungeon.mod");
 if( ptyp>=1 && sndmodflag)
  if( mod_play(musicname) )
    form_alert(1, "[3][Could not load|or play the MOD file][Ok]");

 do
 {
  enablemenu(0);
  iwdh=wdial_init(strtdlg, "Welcome to STune", 0);
  exitbut=wdial_formdo(iwdh, strtdlg, 0, 0L, -1, 0L) & 0x7FFF;
  wdial_close(iwdh, strtdlg);
  enablemenu(1);
  strtdlg[exitbut].ob_state&=~SELECTED;
  level=0;

  switch(exitbut)
  {
   case STRTLOAD:
     if( fileselect(savename, "*.SAV", "Load game") )  break;
     spielart=0;
     if( loadgame() )  break;   /* Spielstand laden */
     level_done=FALSE;
     endeflag=FALSE;
     run_game_engine();
     ++level;
     if(endeflag)
       break;  /* Bei Abbruch zurueck zum Menu, sonst unten weiter! */
   case STRTNEW:
     do
      {
       int i; char *ptr, *ptr2;
       i=level;
       ptr=lvldescription;
       do
        {
         ptr=strstr(ptr+1,"level=");
        }
       while(i-->0 && ptr!=NULL);
       level_done=FALSE;
       endeflag=FALSE;
       if(ptr==NULL)
        { /* Alle Levels geschafft! */
         form_alert(1,"[1][Well done!|All levels solved!][Hurray!]");
         exitflag=TRUE;
        }
        else
        {
         ptr2=ptr+6; /* Levelname */
         strcpy(levelname, levelpath);
         i=strlen(levelname);
         while(*ptr2!='\r' && *ptr2!='\n' && *ptr2!=' ')
           levelname[i++]=*ptr2++;  /* Dateiname anfÅgen */
         levelname[i]=0;
         i=0;
         ptr2=strstr(ptr, "titel=")+6;
         while(*ptr2!='\r' && *ptr2!='\n')
           leveltitel[i++]=*ptr2++;  /* Leveltitel heraussuchen */
         leveltitel[i]=0;
         /* *Briefing - Um was gehts im Level?* */
         briefing(leveltitel, strstr(ptr,"textstart"));
         /* *Und los gehts mit dem Level:* */
         if( !loadlevel(levelname, 0) )
          {
           spielart=0;
           initialize_computer();
           run_game_engine();
           ++level;
          }
          else
          {
           form_alert(1,"[3][Fatal Error:|Can't load|level file!][Ok]");
           exitflag=TRUE;
          }
        }
      } while(level_done==2);
     if(level_done==1) form_alert(1,"[3][Looooooser!!!][Hmmm]");
     endeflag=FALSE;
     break;
   case STRTNET:
     menu_ienable(menu, SAVEGAME, 0);  /* Kein Speichern im Netzmodus */
     menu_ienable(menu, SAVEAS, 0);
     netflag=TRUE;
     spielart=2;
     if( init_network() )              /* siehe st_net.c */
        run_game_engine();
     endeflag=FALSE;
     netflag=FALSE;
     menu_ienable(menu, SAVEGAME, 1);
     menu_ienable(menu, SAVEAS, 1);
     break;
   case STRTEDLV:
     level_done=FALSE;
     endeflag=FALSE;
     strcpy(levelname, levelpath);
     strcat(levelname, "LVL_U000");
     if( fileselect(levelname, "LVL_U*", "Load game") )
       break;
     if( !loadlevel(levelname, 2) )
      {
       spielart=1;
       initialize_computer();
       run_game_engine();
      }
     break;
   case STRTINTR:
     enablemenu(0);
     intro_start(introtxt);
     intro_main();
     enablemenu(1);
     break;
   case STRTHIGH:
     if(loadhighscore()==0)
     {
       rsrc_gaddr(R_TREE, HIGHSCOR, &highdlg);
       hs_to_gem();
       enablemenu(0);
       iwdh=wdial_init(highdlg ,"STune scores", 0);
       wdial_formdo(iwdh, highdlg, 0, 0, 0, 0);
       highdlg[HIGHEXIT].ob_state&=~SELECTED;
       wdial_close(iwdh, highdlg);
       enablemenu(1);
     }
     else strtdlg[STRTHIGH].ob_state|=DISABLED;
     break;
   case STRTOPTS:
     setupdialog(0L, -1, 0L);
     break;
   case STRTQUIT:
     exitflag=TRUE;
     break;
  }
 } while(!exitflag);

 exitGEM();

 mod_stop();

#if DEBUGGING
 Fclose(DBfhndl);
#endif

 return(0);
}
