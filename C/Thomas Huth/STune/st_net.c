/**
 * STune - The battle for Aratis
 * st_net.c : STune's network code for a connection with STik/STinG.
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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>

#include "stunegem.h"
#include "transprt.h"
#include "stunedef.h"
#include "building.h"
#include "units.h"
#include "me_ausla.h"
#include "me_routi.h"
#include "me_gemft.h"
#include "me_kifkt.h"
#include "stunmain.h"
#include "stune.rsh"
#include "th_aesev.h"
#include "th_init.h"
#include "th_graf.h"
#include "windial.h"
#include "st_debug.h"
#include "stunfile.h"


#define CLIENT 1
#define HOST   2
#define E_INIT 3


/* Variablen: */
short is_initialized=0;
DRV_LIST *drivers;
TPL *tpl;
short netmode=0;
short ntin_stat=0;
unsigned short ne[13];


/* Prototypen: */
int net_open(char *hostname, int port);
short net_close(int16 cn);
int initstnet(void);
void fm_error(char *errtxt);
void set_einh(unsigned short anz);
void set_lleinh(unsigned short anz);
void invertiere_gesinnungen();


int net_open(char *hostname, int netport)
{
 int16 tstat, cn;
 uint32 rhost;

 /* Initialization, if necessary */
 if(!is_initialized)
   is_initialized=!initstnet();
 if(!is_initialized)
  { form_alert(1, "[3][Could not init|the net driver!][Abort]"); return -1; }

 /* Resolve the domain name */
 if(hostname!=NULL)
  {
   tstat = resolve(hostname, (char **)NULL, &rhost, 1);
   if(tstat <= 0)
    { fm_error(get_err_text(tstat)); return -1; }
  }
  else rhost=0L;

 cn=TCP_open(rhost, netport, 0, 1024);
 if(cn < 0)
  { fm_error(get_err_text(cn)); return -1; }

 if( hostname!=NULL )
  {
   tstat=TCP_wait_state(cn, TESTABLISH, 60);
   if(tstat < 0)
    { fm_error(get_err_text(tstat)); TCP_close(cn, 0); return -1; }
  }
  else
  {
   int i=0;
   do
    { evnt_timer(1000, 0);  tstat=CNbyte_count(cn);  ++i; }
   while(tstat==E_LISTEN && i<=60);
   if(tstat < 0)
    { fm_error(get_err_text(tstat)); TCP_close(cn, 0); return -1; }
  }

 return(cn);
}

short net_close(int16 cn)
{
 return TCP_close(cn, 8);
}


short net_write(int16 cn, void *buf, int16 len, short flag)
{
 int16 tstat;
 int i;

 tstat=TCP_send(cn, buf, len);
 if(flag)
  {
   i=0;
   while(tstat==E_OBUFFULL && i<=100)
    {
     evnt_timer(50, 0);
     tstat=TCP_send(cn, buf, len);
     ++i;
    }
   if(tstat!=E_NORMAL)  return(tstat);
   tstat=TCP_ack_wait(cn, 2000);
  }

 return tstat;
}

short net_read(int16 cn, void *blk, int16 len, short flag)
{
 int16 tstat; int i;

 tstat=CNget_block(cn, blk, len);
 if(flag)
  {
   i=0;
   while(tstat==E_NODATA && i<=1000)
    {
     evnt_timer(10, 0);
     tstat=CNget_block(cn, blk, len);
     ++i;
    }
  }

 return tstat;
}


int initstnet()
{
/* char trnsdrvstr[256];*/
 unsigned long cookieval;

 if( xgetcookie(0x5354694BL, &cookieval)==0 )   /* 0x5354694BL='STiK' */
  { form_alert(1, "[1][STinG/STik is not loaded|or enabled !][Hmmm]");
    return -1; }
 drivers=(DRV_LIST *)cookieval;
 if(strcmp(drivers->magic, MAGIC) != 0)
  { form_alert (1, "[1][STinG/STik structures|corrupted !][Oooops]");
    return -1; }

 tpl = (TPL *)get_dftab(TRANSPORT_DRIVER);
 if(tpl == (TPL *)NULL)
  { form_alert(1, "[1][Transport Driver not found !][Grmbl]");
    return -1; }

 return 0;
}



void tausche_ini_data()
{
 static NET_INIT oldinidata;
 NET_INIT sendinidata, getinidata;
 char *dptr;

 if( ntin_stat )  return;

 sendinidata.type=0;
 strncpy(sendinidata.playername, netinit[NTINNAM1].ob_spec.tedinfo->te_ptext, 12);

 if(netmode==HOST)
  {
   if(atoi(netinit[NTINUNIT].ob_spec.tedinfo->te_ptext)>12)
     netinit[NTINUNIT].ob_spec.tedinfo->te_ptext="12";
   sendinidata.einh=atoi(netinit[NTINUNIT].ob_spec.tedinfo->te_ptext);
   sendinidata.stpkte=netinit[NTINSPKT].ob_state&SELECTED;
   sendinidata.techlvl=atoi(netinit[NTINTECH].ob_spec.tedinfo->te_ptext);
   sendinidata.credits=atoi(netinit[NTINCRED].ob_spec.tedinfo->te_ptext);
   strcpy(sendinidata.lvl, netinit[NTINLVNM].ob_spec.tedinfo->te_ptext);
   net_write(nethandle, &sendinidata, sizeof(sendinidata), 1);
   if( net_read(nethandle, &getinidata, sizeof(getinidata), 1) < 0 )
    getinidata.type=-1;
  }
  else
  {
   if( net_read(nethandle, &getinidata, sizeof(getinidata), 1) < 0)
    getinidata.type=-1;
   net_write(nethandle, &sendinidata, sizeof(sendinidata), 1);
  }

 /* Und nun die empfangenen Daten auswerten: */
 if( getinidata.type==0)
  {
   if( strncmp(oldinidata.playername, getinidata.playername, 12) )
    {
     strncpy(netinit[NTINNAM2].ob_spec.tedinfo->te_ptext, getinidata.playername, 12);
     if( netinit[NTINNAM2].ob_spec.tedinfo->te_ptext[0]=='@' )
       netinit[NTINNAM2].ob_spec.tedinfo->te_ptext[0]=0;
     objc_draw(netinit, NTINNAM2, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
    }
   if(netmode==CLIENT)
    {
     if( getinidata.einh!=oldinidata.einh )
      {
       sprintf(netinit[NTINUNIT].ob_spec.tedinfo->te_ptext, "%i", (int)getinidata.einh);
       objc_draw(netinit, NTINUNIT, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
      }
     if( getinidata.stpkte!=oldinidata.stpkte )
      {
       if(getinidata.stpkte)
        netinit[NTINSPKT].ob_state|=SELECTED;  else  netinit[NTINSPKT].ob_state&=~SELECTED;
       objc_draw(netinit, NTINSPKT, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
      }
     if( getinidata.techlvl!=oldinidata.techlvl )
      {
       sprintf(netinit[NTINTECH].ob_spec.tedinfo->te_ptext, "%i", (int)getinidata.techlvl);
       objc_draw(netinit, NTINTECH, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
      }
     if( getinidata.credits!=oldinidata.credits )
      {
       sprintf(netinit[NTINCRED].ob_spec.tedinfo->te_ptext, "%i", (int)getinidata.credits);
       objc_draw(netinit, NTINCRED, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
      }
     if( strcmp(getinidata.lvl, oldinidata.lvl) )
      {
       strcpy(levelname, levelpath);
       strcat(levelname, getinidata.lvl);
       strcpy(netinit[NTINLVNM].ob_spec.tedinfo->te_ptext, getinidata.lvl);
       objc_draw(netinit, NTINLVNM, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
      }
    }
  }

 if( getinidata.type==1 || getinidata.type==2 )
  {
   netinit[NTINUNIT].ob_flags&=~EDITABLE;
   netinit[NTINSPKT].ob_flags&=~SELECTABLE;
   netinit[NTINTECH].ob_flags&=~EDITABLE;
   netinit[NTINCRED].ob_flags&=~EDITABLE;
   netinit[NTINLVNM].ob_flags&=~SELECTABLE;
  }

 if( getinidata.type==1 )
  {
   ntin_stat=1;
   dptr=netinit[NTINTXT1].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT1].ob_spec.tedinfo->te_ptext=netinit[NTINTXT2].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT2].ob_spec.tedinfo->te_ptext=netinit[NTINTXT3].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT3].ob_spec.tedinfo->te_ptext=dptr;
   if(netmode==HOST)
     strcpy(netinit[NTINTXT3].ob_spec.tedinfo->te_ptext, "Client: Okay!");
    else
     strcpy(netinit[NTINTXT3].ob_spec.tedinfo->te_ptext, "Host: Okay!");
   sprintf(netinit[NTINUNIT].ob_spec.tedinfo->te_ptext, "%i", (int)getinidata.einh);
   if(getinidata.stpkte)
     netinit[NTINSPKT].ob_state|=SELECTED;  else  netinit[NTINSPKT].ob_state&=~SELECTED;
   sprintf(netinit[NTINTECH].ob_spec.tedinfo->te_ptext, "%i", (int)getinidata.techlvl);
   sprintf(netinit[NTINCRED].ob_spec.tedinfo->te_ptext, "%i", (int)getinidata.credits);
   strcpy(levelname, levelpath);
   strcat(levelname, getinidata.lvl);
   strcpy(netinit[NTINLVNM].ob_spec.tedinfo->te_ptext, getinidata.lvl);
   objc_draw(netinit, 0, 8, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
  }

 if( getinidata.type==2 )
  {
   ntin_stat=2;
   dptr=netinit[NTINTXT1].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT1].ob_spec.tedinfo->te_ptext=netinit[NTINTXT2].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT2].ob_spec.tedinfo->te_ptext=netinit[NTINTXT3].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT3].ob_spec.tedinfo->te_ptext=dptr;
   if(netmode==HOST)
     strcpy(netinit[NTINTXT3].ob_spec.tedinfo->te_ptext, "Client: Cancel!");
    else
     strcpy(netinit[NTINTXT3].ob_spec.tedinfo->te_ptext, "Host: Cancel!");
   netinit[NTINOKAY].ob_state=DISABLED;
   netinit[NTINMSND].ob_state=DISABLED;
   objc_draw(netinit, NTINOKAY, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
   objc_draw(netinit, NTINMSND, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
   objc_draw(netinit, NTINTXTB, 1, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
  }

 if(getinidata.type==3)
  {
   dptr=netinit[NTINTXT1].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT1].ob_spec.tedinfo->te_ptext=netinit[NTINTXT2].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT2].ob_spec.tedinfo->te_ptext=netinit[NTINTXT3].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT3].ob_spec.tedinfo->te_ptext=dptr;
   strcpy(netinit[NTINTXT3].ob_spec.tedinfo->te_ptext, ((char *)&getinidata)+sizeof(short));
   objc_draw(netinit, NTINTXTB, 1, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
  }

 if(getinidata.type==0 || getinidata.type==1)
  memcpy(&oldinidata, &getinidata, sizeof(getinidata));

 return;
}


/* ***Dialoge zum Ausw„hlen der IP-Verbindung und Daten des Netzwerkspieles*** */
short init_network()
{
 int wdlgh, exitbut /*,button */;
 char msg1txt[34], msg2txt[34], msg3txt[34]; /* Speicher fr die Nachrichten */

 msg1txt[0]=0; msg2txt[0]=0; msg3txt[0]=0;
 netinit[NTINTXT1].ob_spec.tedinfo->te_ptext=msg1txt;
 netinit[NTINTXT2].ob_spec.tedinfo->te_ptext=msg2txt;
 netinit[NTINTXT3].ob_spec.tedinfo->te_ptext=msg3txt;

 strcpy(levelname, levelpath);
 strcat(levelname, "lvl_m000");
 strcpy(netinit[NTINLVNM].ob_spec.tedinfo->te_ptext, "lvl_m000");

 wdlgh=wdial_init(netdia, "Networking", 0);
 exitbut=wdial_formdo(wdlgh, netdia, IPADRSTR, wdmsgs, -1, 0L);
 wdial_close(wdlgh, netdia);
 netdia[exitbut].ob_state&=~SELECTED;

 if(exitbut==NVERBIND)
 {
   nethandle=net_open(netdia[IPADRSTR].ob_spec.tedinfo->te_ptext,
                 atoi(netdia[IPPORTS].ob_spec.tedinfo->te_ptext) );
   netmode=CLIENT;
 }
 if(exitbut==NWAITCON)
 {
   nethandle=net_open(NULL, atoi(netdia[IPPORTS].ob_spec.tedinfo->te_ptext) );
   netmode=HOST;
 }

 if(exitbut==NABORT || nethandle<0)  /* falls die Verbindung nicht klappt */
 {
   netmode=0;
   return(0);
 }

 netflag=TRUE;
 ntin_stat=0;
 if(netmode==HOST)
  {
   netinit[NTINMODE].ob_spec.tedinfo->te_ptext="Host";
   netinit[NTINUNIT].ob_flags|=EDITABLE;
   netinit[NTINSPKT].ob_flags|=SELECTABLE;
   netinit[NTINTECH].ob_flags|=EDITABLE;
   netinit[NTINCRED].ob_flags|=EDITABLE;
   netinit[NTINLVNM].ob_flags|=SELECTABLE;
  }
  else
  {
   netinit[NTINMODE].ob_spec.tedinfo->te_ptext="Client";
   netinit[NTINUNIT].ob_flags&=~EDITABLE;
   netinit[NTINSPKT].ob_flags&=~SELECTABLE;
   netinit[NTINTECH].ob_flags&=~EDITABLE;
   netinit[NTINCRED].ob_flags&=~EDITABLE;
   netinit[NTINLVNM].ob_flags&=~SELECTABLE;
  }

 netinit[NTINOKAY].ob_state=NORMAL;
 netinit[NTINMSND].ob_state=NORMAL;

 wdlgh=wdial_init(netinit ,"Game options", 0);

 do
  {
   exitbut=wdial_formdo(wdlgh, netinit, NTINNAM1, wdmsgs, 1500, tausche_ini_data);
   if(exitbut==NTINLVNM)
    {
     if( !fileselect(levelname, "*", "Load a level") )
      {
       char *ptr;
       ptr=strrchr(levelname, '\\');
       if( ptr ) ptr+=1; else ptr=levelname;
       strcpy(netinit[NTINLVNM].ob_spec.tedinfo->te_ptext, ptr);
       netinit[NTINLVNM].ob_state&=~SELECTED;
       objc_draw(netinit, NTINLVNM, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
      }
    }
   if(exitbut==NTINMSND)
    {
     NET_INIT sendinimsg;
     sendinimsg.type=3;
     strcpy(((char *)&sendinimsg)+sizeof(short), netinit[NTINMSG].ob_spec.tedinfo->te_ptext);
     net_write(nethandle, &sendinimsg, sizeof(sendinimsg), 1);
     netinit[NTINMSND].ob_state&=~SELECTED;
     objc_draw(netinit, NTINMSND, 0, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
    }
  }
 while(exitbut!=NTINOKAY && exitbut!=NTINABRT );

 if(exitbut==NTINOKAY)
  {
   NET_INIT sendinidata;
   sendinidata.type=1;
   if(atoi(netinit[NTINUNIT].ob_spec.tedinfo->te_ptext)>12)
     netinit[NTINUNIT].ob_spec.tedinfo->te_ptext="12";
   sendinidata.einh=atoi(netinit[NTINUNIT].ob_spec.tedinfo->te_ptext);
   sendinidata.stpkte=netinit[NTINSPKT].ob_state&SELECTED;
   sendinidata.techlvl=atoi(netinit[NTINTECH].ob_spec.tedinfo->te_ptext);
   sendinidata.credits=atoi(netinit[NTINCRED].ob_spec.tedinfo->te_ptext);
   strcpy(sendinidata.lvl, netinit[NTINLVNM].ob_spec.tedinfo->te_ptext);
   net_write(nethandle, &sendinidata, sizeof(sendinidata), 1);
  }
 if(exitbut==NTINABRT)
  {
   NET_INIT sendinidata;
   sendinidata.type=2;
   net_write(nethandle, &sendinidata, sizeof(sendinidata), 1);
  }

 if(ntin_stat==0 && exitbut==NTINOKAY)
  {
   NET_INIT getinidata; int s; char *dptr;
   dptr=netinit[NTINTXT1].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT1].ob_spec.tedinfo->te_ptext=netinit[NTINTXT2].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT2].ob_spec.tedinfo->te_ptext=netinit[NTINTXT3].ob_spec.tedinfo->te_ptext;
   netinit[NTINTXT3].ob_spec.tedinfo->te_ptext=dptr;
   strcpy(netinit[NTINTXT3].ob_spec.tedinfo->te_ptext, "Waiting for the other side...");
   objc_draw(netinit, NTINTXTB, 1, netinit->ob_x, netinit->ob_y, netinit->ob_width, netinit->ob_height);
   do
    {
     s=net_read(nethandle, &getinidata, sizeof(getinidata), 1);
    }
   while(getinidata.type!=1 && getinidata.type!=2 && s!=E_EOF);
   ntin_stat=getinidata.type;
   if(ntin_stat==1)
    {
     if(getinidata.stpkte)
       netinit[NTINSPKT].ob_state|=SELECTED;  else  netinit[NTINSPKT].ob_state&=~SELECTED;
     sprintf(netinit[NTINTECH].ob_spec.tedinfo->te_ptext, "%i", (int)getinidata.techlvl);
     sprintf(netinit[NTINCRED].ob_spec.tedinfo->te_ptext, "%i", (int)getinidata.credits);
     strcpy(levelname, levelpath);
     strcat(levelname, getinidata.lvl);
     strcpy(netinit[NTINLVNM].ob_spec.tedinfo->te_ptext, getinidata.lvl);
    }
  }

 wdial_close(wdlgh, netinit);

 netinit[exitbut].ob_state&=~SELECTED;

 if( exitbut==NTINABRT || ntin_stat!=1 )
  {
   netflag=FALSE;
   netmode=0;
   return(0);
  }

 loadlevel(levelname, 1);

 strncpy(p1name, netinit[NTINNAM1].ob_spec.tedinfo->te_ptext, 12);
 strncpy(p2name, netinit[NTINNAM2].ob_spec.tedinfo->te_ptext, 12);
 knete[0]=knete[1]=atoi(netinit[NTINCRED].ob_spec.tedinfo->te_ptext);
 techlevelnr=atoi(netinit[NTINTECH].ob_spec.tedinfo->te_ptext);
 techlev2popups(techlevelnr);
 if(netmode==HOST)
   set_einh(atoi(netinit[NTINUNIT].ob_spec.tedinfo->te_ptext));
 else
 {
   evnt_timer(100,0);
   net_read(nethandle, ne, sizeof(ne), 1);
   netmode=E_INIT;
   set_lleinh(atoi(netinit[NTINUNIT].ob_spec.tedinfo->te_ptext));
   netmode=CLIENT;
 }

 return(1);
}


void set_einh(unsigned short anz)
{
  unsigned short i,z,tnr=1;

  if(anz>12) anz=12;
  if(techlevelnr) tnr=2;            /* welche Einheiten gehen? */
  if(techlevelnr>5) tnr=3;
  for(i=1;i<=12;i++)
  {
    z=rnd(tnr);

    switch(z)
    {
      case 0:
        ne[i]=rnd(tech_level[techlevelnr].grf[rnd(tech_level[techlevelnr].grf[0])+1]);;
        break;
      case 1:
        ne[i]=rnd(tech_level[techlevelnr].klf[rnd(tech_level[techlevelnr].klf[0])+1]);;
        break;
      case 2:
        ne[i]=rnd(tech_level[techlevelnr].kas[rnd(tech_level[techlevelnr].kas[0])+1]);;
        break;
    }

    if(i>anz) ne[i]=255;                   /* nicht ben”tigt; */

  }
  net_write(nethandle, ne, sizeof(ne), 1);

  netmode=E_INIT;
  set_lleinh(anz);
  netmode=HOST;

  return;
}


void set_lleinh(unsigned short anz)
{

 unsigned short i,gel,g0=1,g1=1;

 if(anz>12) anz=12;
 for(i=1;i<=lleinh;i++)
 {
   if(einheiten[i].gesinnung)
   {
     if(g1<=anz)  einheiten[i].art=ne[g1]; else einheiten[i].art=255;
   }
   else
   {
     if(g0<=anz) einheiten[i].art=ne[g0]; else einheiten[i].art=255;
   }

   if(einheiten[i].gesinnung) g1++; else g0++;

 }

 do
 {
   gel=0;
   for(i=1;i<=lleinh;i++)
    if(einheiten[i].art==255)
    { einheit_entfernen(i); gel=1; }
    else
      einheiten[i].zustand=einheit_typ[einheiten[i].art].zustandspunkte;
 }while(gel);

 return;
}


void gepaused(unsigned short nr)
{

 if(geb[nr].wie_weit)
 {
   geb[nr].wie_weit--;
   knete[geb[nr].gesinnung]++;
 }
 return;
}

void unpaused(unsigned short nr)
{
 unsigned short anz;

 if(geb[nr].art==BAUANLAGE)
   anz=gebaeude_typ[geb[nr].bauprodukt].kosten;
 else
   anz=einheit_typ[geb[nr].bauprodukt].kosten;

 if(geb[nr].wie_weit>anz)
 {
   geb[nr].wie_weit++;
   knete[geb[nr].gesinnung]--;
 }
 return;
}

void gestoppt(unsigned short nr, unsigned long i)
{
 do
 {
   knete[1]++;
   i--;
 }while(i);
 geb[nr].status&=~(PAUSE+BAUEN);
 return;
}

void to_do_list(TRANSMIT trans)
{
  unsigned long i;
  unsigned int wdlgh,exitbut;
  static char net_text[56];

Dprintf(("empf: trans.art = %i\n",(int)trans.art));
Dprintf(("empf: trans.timer_nr = %li\n",(long)trans.timer_nr));

  switch(trans.art)
  {
    case 0:
      break;       /* tue nichts */
    case 1:
      i=/*abs(*/ (long)timer_counter-(long)trans.timer_nr /*)*/;
      i++;
      DBprnt(("i: %li  tc: %li  ttnr: %li mode=%i \n",i,timer_counter, trans.timer_nr,netmode));
      if(i>16)
      {
        fm_error("Games aren't running synchronous anymore !");
        endeflag=1;
        netflag=0;
      }
      if(i<0)
      {
        fm_error("Aaaaargh! i<0 !!!!");
        endeflag=1;
        netflag=0;
      }
      switch(trans.aktion)
      {
       case 1:
         bewegung(trans.nr, trans.xpos, trans.ypos, trans.flag);
         if (   einheiten[trans.nr].art == SAMMLER
             && sfeld[trans.xpos][trans.ypos].ertrag != 0 )
           einheiten[trans.nr].status|=SAMMELN;
         einheiten[trans.nr].status&=~PATROLIE;
         while(i)
         {
           work_list_einh(trans.nr,0);
           i--;
         }
         break;
       case 2:
         angriff(trans.nr, trans.xpos, trans.ypos, trans.flag);
         while(i)
         {
           work_list_einh(trans.nr,0);
           i--;
         }
         break;
       case 3:
         bauen(trans.nr, trans.objekt);
         while(i)
         {
           work_list_geb(trans.nr,0);
           i--;
         }
         break;
       case 4:
         setzen(trans.xpos, trans.ypos,1);
         while(i)
         {
           work_list_geb(llgeb+1,0);
           i--;
         }
         break;
       case 5:
         verkaufen(trans.nr,1);
         break;
       case 6:
         reparieren(trans.nr,1);
         while(i)
         {
           work_list_geb(trans.nr,0);
           i--;
         }
         break;
       case 7:
         geb[trans.nr].status|=PAUSE;
         while(i)
         {
           gepaused(trans.nr);
           i--;
         }
         break;
       case 8:
         geb[trans.nr].status&=~PAUSE;
         while(i)
         {
           unpaused(trans.nr);
           i--;
         }
         break;
       case 9:
         gestoppt(trans.nr,i);
         break;
       case 10:
         gebaeude_angriff(trans.nr,trans.xpos, trans.ypos);
         while(i)
         {
           work_list_geb(trans.nr,0);
           i--;
         }
         break;
       case 11:
         einheiten[trans.nr].status&=~SAMMELN;
         einheiten[trans.nr].status&=~STOP;
         rueckkehr(trans.nr);
         while(i)
         {
           work_list_einh(trans.nr,0);
           i--;
         }
         break;
       case 12:
         zur_reperatur(trans.nr,trans.objekt);
         while(i)
         {
           work_list_einh(trans.nr,0);
           i--;
         }
         break;
       case 13:
         bewegung(trans.nr, trans.xpos, trans.ypos, trans.flag);
         einheiten[trans.nr].xpospatr=einheiten[trans.nr].xpos;
         einheiten[trans.nr].ypospatr=einheiten[trans.nr].ypos;
         einheiten[trans.nr].status|=PATROLIE;
         while(i)
         {
           work_list_einh(trans.nr,0);
           i--;
         }
         break;
      }
      break;
    case 2:
      strncpy(net_text, p2name, 13);
      net_text[13]=0;
      strcat(net_text, ": ");
      net_read(nethandle, &net_text[strlen(net_text)], sizeof(net_msg), 1);
      strcat(net_text, " ");
      neuemeldung(net_text);
/*      display_message(trans.text); */ /* Textnachricht vom Gegner */
      break;
    case 3:
      endeflag=TRUE;
      netflag=0;
      wdlgh=wdial_init(netend ,"STune",0);
      exitbut=wdial_formdo(wdlgh, netend, 0, wdmsgs, 0, 0);
      netend[exitbut].ob_state&=~SELECTED;
      wdial_close(wdlgh, netend);
      net_close(nethandle);
      break;
    default: break;
  }
  return;
}


void set_tm_data(unsigned short aktion, unsigned short nr,
                 unsigned short xpos, unsigned short ypos,
                 unsigned short flag, unsigned short objekt)
{

#if DEBUGGING
 if(trans.art) Dprintf(("trans.art ist nicht null!\n"));
#endif
  trans.art=1;
  trans.aktion=aktion;
  trans.nr=nr;
  trans.xpos=xpos;
  trans.ypos=ypos;
  trans.flag=flag;
  trans.objekt=objekt;
  trans.timer_nr=timer_counter;

Dprintf(("sende: trans.art = %i\n",(int)trans.art));
Dprintf(("sende: trans.timer_nr = %li\n",(long)trans.timer_nr));

  return;
}

