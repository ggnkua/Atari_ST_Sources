/**
 * STune - The battle for Aratis
 * me_gemft.c : GEM related functions that concern the mouse pointer and
 *              build popup menus.
 * Copyright (C) 2003 Matthias Alles
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

#include "stunegem.h"
#include "stune.rsh"
#include "stunedef.h"
#include "stunmain.h"
#include "me_routi.h"
#include "windial.h"
#include "th_aesev.h"
#include "th_graf.h"
#include "units.h"
#include "me_ausla.h"
#include "st_net.h"

#define M_MONEYJ  0x7000
#define M_TOOLJ   0x7001
#define M_FRAME1  0x7002
#define M_AIM     0x7003
#define M_SETJ1   0x7004
#define M_GETIN1  0x7005
#define M_MONEYN  0x7006
#define M_TOOLN   0x7007
#define M_SETN    0x7008
#define M_FRAME2  0x7009
#define M_FRAME3  0x700A
#define M_FRAME4  0x700B
#define M_GETIN2  0x700C
#define M_GETIN3  0x700D
#define M_GETIN4  0x700E
#define M_SETJ2   0x700F
#define M_SETJ3   0x7010
#define M_SETJ4   0x7011



/* Variablen: */
OBJECT *gebpopobj;                                 /* fÅr Popup-MenÅs */
OBJECT *kaspopobj;
OBJECT *klfpopobj;
OBJECT *grfpopobj;
short gebpopitem;
short kaspopitem;
short klfpopitem;
short grfpopitem;
short frame[4]={M_FRAME1,M_FRAME2,M_FRAME3,M_FRAME4};
short getin[4]={M_GETIN1,M_GETIN2,M_GETIN3,M_GETIN4};
short setj[4]={M_SETJ1,M_SETJ2,M_SETJ3,M_SETJ4};


/* ***Neue Mauszeiger:*** */

MFORM mgrfgetin1 = {7, 7, 1, 0, 3,
   0x3FFC, 0x2004, 0x1008, 0x0810, 0x0420, 0x1E78, 0x1008, 0x0810, 0x0420, 0x0240, 0x1FF8, 0x1008, 0x0810, 0x0420, 0x0240, 0x0180,
   0x0000, 0x1FF8, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000};
MFORM  mgrfgetin2 = {7, 7, 1, 0, 3,
   0x1FF8, 0x1008, 0x0810, 0x0420, 0x0240, 0x3FFC, 0x2004, 0x1008, 0x0810, 0x0420, 0x1E78, 0x1008, 0x0810, 0x0420, 0x0240, 0x0180,
   0x0000, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000, 0x1FF8, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000};
MFORM mgrfgetin3 = {7, 7, 1, 0, 3,
   0x1FF8, 0x1008, 0x0810, 0x0420, 0x0240, 0x1FF8, 0x1008, 0x0810, 0x0420, 0x0240, 0x3FFC, 0x2004, 0x1008, 0x0810, 0x0420, 0x0240,
   0x0000, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000, 0x1FF8, 0x0FF0, 0x07E0, 0x03C0, 0x0180};
MFORM mgrfgetin4 = {7, 7, 1, 0, 3,
   0x1FF8, 0x1008, 0x0810, 0x0420, 0x0240, 0x1FF8, 0x1008, 0x0810, 0x0420, 0x0240, 0x1FF8, 0x1008, 0x0810, 0x0420, 0x0240, 0x0180,
   0x0000, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000, 0x0FF0, 0x07E0, 0x03C0, 0x0180, 0x0000};

MFORM mgrfmoneyj=
{
 7,7, 1, 0,11,
 0x0180,0x07F0,0x0FF8,0x1FF8,0x3FF0,0x3FC0,0x3FE0,0x1FF0,
   0x0FF8,0x07FC,0x03FC,0x0FFC,0x1FF8,0x1FF0,0x0FE0,0x0180,
 0x0000,0x0180,0x07F0,0x0FF0,0x1D80,0x1980,0x1D80,0x0FE0,
   0x07F0,0x01B8,0x0198,0x01B8,0x0FF0,0x0FE0,0x0180,0x0000
};
MFORM mgrfmoneyn=
{
 7,7, 1, 0,10,
 0x0180,0x07F0,0x0FF8,0x1FF8,0x3FF0,0x3FC0,0x3FE0,0x1FF0,
   0x0FF8,0x07FC,0x03FC,0x0FFC,0x1FF8,0x1FF0,0x0FE0,0x0180,
 0x0000,0x0180,0x07F0,0x0FF0,0x1D80,0x1980,0x1D80,0x0FE0,
   0x07F0,0x01B8,0x0198,0x01B8,0x0FF0,0x0FE0,0x0180,0x0000
};
MFORM mgrftoolj=
{
 7,7, 1, 0,3,
 0x1800,0x3C00,0x5E00,0xEE00,0xFE00,0x7F00,0x3F80,0x07C0,
    0x03E0,0x01FC,0x00FE,0x007F,0x0077,0x007A,0x003C,0x0018,
 0x0000,0x1800,0x0C00,0x4400,0x6C00,0x3E00,0x0700,0x0380,
    0x01C0,0x00E0,0x007C,0x0036,0x0022,0x0030,0x0018,0x0000
};
MFORM mgrftooln=
{
 7,7, 1, 0,10,
 0x1800,0x3C00,0x5E00,0xEE00,0xFE00,0x7F00,0x3F80,0x07C0,
    0x03E0,0x01FC,0x00FE,0x007F,0x0077,0x007A,0x003C,0x0018,
 0x0000,0x1800,0x0C00,0x4400,0x6C00,0x3E00,0x0700,0x0380,
    0x01C0,0x00E0,0x007C,0x0036,0x0022,0x0030,0x0018,0x0000
};


MFORM  mgrfframe1= {7, 7, 1, 0, 4,
   0xFFFF, 0x8181, 0xBFFD, 0xA005, 0xA005, 0xA005, 0xA005, 0xE007, 0xE007, 0xA005, 0xA005, 0xA005, 0xA005, 0xBFFD, 0x8181, 0xFFFF,
   0x0000, 0x7E7E, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x0000, 0x0000, 0x4002, 0x4002, 0x4002, 0x4002, 0x4002, 0x7E7E, 0x0000};
MFORM mgrfframe2= {7, 7, 1, 0, 4,
   0x0000, 0x7F7E, 0x4142, 0x5F7A, 0x500A, 0x500A, 0x700A, 0x000E, 0x7000, 0x500E, 0x500A, 0x500A, 0x5EFA, 0x4282, 0x7EFE, 0x0000,
   0x0000, 0x0000, 0x3E3C, 0x2004, 0x2004, 0x2004, 0x0004, 0x0000, 0x0000, 0x2000, 0x2004, 0x2004, 0x2004, 0x3C7C, 0x0000, 0x0000};
MFORM mgrfframe3 = {7, 7, 1, 0, 4,
   0x0000, 0x0000, 0x3FFC, 0x20C4, 0x2FF4, 0x2814, 0x3814, 0x3814, 0x281C, 0x281C, 0x2814, 0x2FF4, 0x2304, 0x3FFC, 0x0000, 0x0000,
   0x0000, 0x0000, 0x0000, 0x1F38, 0x1008, 0x1008, 0x0008, 0x0008, 0x1000, 0x1000, 0x1008, 0x1008, 0x1CF8, 0x0000, 0x0000, 0x0000};
MFORM mgrfframe4 = {7, 7, 1, 0, 4,
   0x0000, 0x0000, 0x0000, 0x1FF8, 0x10C8, 0x17E8, 0x1C28, 0x1C28, 0x1438, 0x1438, 0x17E8, 0x1308, 0x1FF8, 0x0000, 0x0000, 0x0000,
   0x0000, 0x0000, 0x0000, 0x0000, 0x0F30, 0x0810, 0x0010, 0x0010, 0x0800, 0x0800, 0x0810, 0x0CF0, 0x0000, 0x0000, 0x0000, 0x0000};

MFORM mgrfaim = {7, 7, 1, 0, 10,
   0x0420, 0x0420, 0x0810, 0x1668, 0x2A54, 0xD18B, 0x1818, 0x0420, 0x0420, 0x1818, 0xD18B, 0x2A54, 0x1668, 0x0810, 0x0420, 0x0420,
   0x0240, 0x03C0, 0x07E0, 0x0990, 0x1188, 0x2004, 0xE007, 0x781E, 0x781E, 0xE007, 0x2004, 0x1188, 0x0990, 0x07E0, 0x03C0, 0x0240};
/* MFORM mgrfset = {7, 7, 1, 0, 3,
   0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000,
   0x0000, 0x2004, 0x700E, 0x381C, 0x1C38, 0x0E70, 0x07E0, 0x03C0, 0x03C0, 0x07E0, 0x0E70, 0x1C38, 0x381C, 0x700E, 0x2004, 0x0000}; */
MFORM mgrfsetj = {7, 7, 1, 0, 3,
   0x7007, 0x4809, 0x4411, 0x2222, 0x1144, 0x0888, 0x0410, 0x0220, 0x0410, 0x0888, 0x1144, 0x2222, 0x4411, 0x4809, 0x7007, 0x0000,
   0x0000, 0x3006, 0x380E, 0x1C1C, 0x0E38, 0x0770, 0x03E0, 0x01C0, 0x03E0, 0x0770, 0x0E38, 0x1C1C, 0x380E, 0x3006, 0x0000, 0x0000};


MFORM mgrfsetj1 = {7, 7, 1, 0, 3,
   0x0000, 0x700E, 0x4812, 0x4422, 0x2244, 0x1188, 0x0810, 0x0420, 0x0420, 0x0810, 0x1188, 0x2244, 0x4422, 0x4812, 0x700E, 0x0000,
   0x0000, 0x0000, 0x300C, 0x381C, 0x1C38, 0x0E70, 0x07E0, 0x03C0, 0x03C0, 0x07E0, 0x0E70, 0x1C38, 0x381C, 0x300C, 0x0000, 0x0000};
MFORM mgrfsetj2 = {7, 7, 1, 0, 3,
   0x1E00, 0x1200, 0x1300, 0x190F, 0x09B9, 0x0CE1, 0x0487, 0x0E1C, 0x3870, 0xE120, 0x8730, 0x9D90, 0xF098, 0x00C8, 0x0048, 0x0078,
   0x0000, 0x0C00, 0x0C00, 0x0600, 0x0606, 0x031E, 0x0378, 0x01E0, 0x0780, 0x1EC0, 0x78C0, 0x6060, 0x0060, 0x0030, 0x0030, 0x0000};
MFORM mgrfsetj3 = {7, 7, 1, 0, 3,
   0x03C0, 0x0240, 0x0240, 0x0240, 0x0240, 0x0240, 0xFE7F, 0x8001, 0x8001, 0xFE7F, 0x0240, 0x0240, 0x0240, 0x0240, 0x0240, 0x03C0,
   0x0000, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x7FFE, 0x7FFE, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0180, 0x0000};
MFORM mgrfsetj4 = {7, 7, 1, 0, 3,
   0x0078, 0x0048, 0x00C8, 0xF098, 0x9D90, 0x8730, 0xE120, 0x3870, 0x0E1C, 0x0487, 0x0CE1, 0x09B9, 0x190F, 0x1300, 0x1200, 0x1E00,
   0x0000, 0x0030, 0x0030, 0x0060, 0x6060, 0x78C0, 0x1EC0, 0x0780, 0x01E0, 0x0378, 0x031E, 0x0606, 0x0600, 0x0C00, 0x0C00, 0x0000};



MFORM mgrfsetn = {7, 7, 1, 0, 10,
   0x7007, 0x4809, 0x4411, 0x2222, 0x1144, 0x0888, 0x0410, 0x0220, 0x0410, 0x0888, 0x1144, 0x2222, 0x4411, 0x4809, 0x7007, 0x0000,
   0x0000, 0x3006, 0x380E, 0x1C1C, 0x0E38, 0x0770, 0x03E0, 0x01C0, 0x03E0, 0x0770, 0x0E38, 0x1C1C, 0x380E, 0x3006, 0x0000, 0x0000};




/* ***Mauszeiger Ñndern*** */
void changemouseform(int newform)
{
 static int oldform=0;

 if(newform!=oldform)
 {
  if(newform<0x7000)
    graf_mouse(newform, 0L);
   else
    switch(newform)
    {
     case M_MONEYJ:  graf_mouse(USER_DEF, &mgrfmoneyj); break;
     case M_MONEYN:  graf_mouse(USER_DEF, &mgrfmoneyn); break;
     case M_TOOLJ:   graf_mouse(USER_DEF, &mgrftoolj); break;
     case M_TOOLN:   graf_mouse(USER_DEF, &mgrftooln); break;
     case M_FRAME1:   graf_mouse(USER_DEF, &mgrfframe1); break;
     case M_FRAME2:   graf_mouse(USER_DEF, &mgrfframe2); break;
     case M_FRAME3:   graf_mouse(USER_DEF, &mgrfframe3); break;
     case M_FRAME4:   graf_mouse(USER_DEF, &mgrfframe4); break;
     case M_AIM:     graf_mouse(USER_DEF, &mgrfaim); break;
     case M_SETJ1:     graf_mouse(USER_DEF, &mgrfsetj1); break;
     case M_SETJ2:     graf_mouse(USER_DEF, &mgrfsetj2); break;
     case M_SETJ3:     graf_mouse(USER_DEF, &mgrfsetj3); break;
     case M_SETJ4:     graf_mouse(USER_DEF, &mgrfsetj4); break;
     case M_SETN:     graf_mouse(USER_DEF, &mgrfsetn); break;
     case M_GETIN1:   graf_mouse(USER_DEF, &mgrfgetin1); break;
     case M_GETIN2:   graf_mouse(USER_DEF, &mgrfgetin2); break;
     case M_GETIN3:   graf_mouse(USER_DEF, &mgrfgetin3); break;
     case M_GETIN4:   graf_mouse(USER_DEF, &mgrfgetin4); break;
    }
 }

 oldform=newform;
}


void set_mouse(unsigned short xpos, unsigned short ypos)
{
   short i;
   static short z=0;

  z++;
  if(z==16) z=0;
  i=z/4;

  if(sfeld[xpos][ypos].erforscht)
  switch(ak_art)
  {
    case 1: if(geb[ak_nr].gesinnung==0)
            {
              if(geb[ak_nr].art==MG_TURM || geb[ak_nr].art==RK_TURM || geb[ak_nr].art==INFRATURM)
                if(sfeld[xpos][ypos].gesinnung && sfeld[xpos][ypos].besetzt) changemouseform(M_AIM);
                   else if(sfeld[xpos][ypos].besetzt) changemouseform(frame[i]);
                           else changemouseform(ARROW);
              else if(sfeld[xpos][ypos].besetzt) changemouseform(frame[i]);
                     else changemouseform(ARROW);
            }
            else
            {
              if(sfeld[xpos][ypos].besetzt) changemouseform(frame[i]);
               else changemouseform(ARROW);
            }
            break;
    case 2: if(einheiten[ak_nr].gesinnung)
            {
              if(sfeld[xpos][ypos].besetzt) changemouseform(frame[i]);
              else changemouseform(ARROW);
            }
            else
              switch(einheiten[ak_nr].art)
              {
              case SAMMLER: if(sfeld[xpos][ypos].ertrag) changemouseform(M_AIM);
                              else if(sfeld[xpos][ypos].besetzt)
                                     if(sfeld[xpos][ypos].gesinnung) changemouseform(ARROW);
                                        else if(geb[nummer_ermitteln(xpos,ypos,0)].art==RAFFINERIE) changemouseform(getin[i]);
                                                else changemouseform(frame[i]);
                             else changemouseform(ARROW);
                            break;
              case BEKEHRER: if(sfeld[xpos][ypos].besetzt && sfeld[xpos][ypos].gesinnung && !sfeld[xpos][ypos].besetzertyp)
                               changemouseform(getin[i]);
                             else
                               if(sfeld[xpos][ypos].besetzt)
                                 changemouseform(frame[i]);
                               else
                                 changemouseform(ARROW);
                             break;
              default:  if(sfeld[xpos][ypos].besetzt)
                        {
                          if(sfeld[xpos][ypos].gesinnung) changemouseform(M_AIM);
                          else
                            if(geb[nummer_ermitteln(xpos,ypos,0)].art==WERKSTATT)
                              changemouseform(getin[i]);
                            else
                              changemouseform(frame[i]);
                        }
                        else changemouseform(ARROW);
                        break;
              }
            break;
    case 3: if(platz_testen(geb[id_suchen(BAUANLAGE,1,0)].bauprodukt,xpos,ypos,0))
              changemouseform(setj[i]);
            else
              changemouseform(M_SETN);
            break;
    case 4: if(sfeld[xpos][ypos].besetzt)
            {
              if(sfeld[xpos][ypos].besetzertyp==0 && sfeld[xpos][ypos].gesinnung==0)
                if(geb[sfeld[xpos][ypos].nr].zustand<gebaeude_typ[geb[sfeld[xpos][ypos].nr].art].zustandspunkte)
                   changemouseform(M_TOOLJ);
            }
            else changemouseform(M_TOOLN);
            break;
    case 5: if(sfeld[xpos][ypos].besetzt)
            {
             if(sfeld[xpos][ypos].besetzertyp==0 && sfeld[xpos][ypos].gesinnung==0)
               changemouseform(M_MONEYJ);
            }
            else changemouseform(M_MONEYN);
            break;
    default: if(sfeld[xpos][ypos].besetzt) changemouseform(frame[i]);
               else changemouseform(ARROW);
             break;
  }
/*  else
   changemouseform(ARROW);  evtl. spÑter aktivieren, je nach dem */
  return;
}

void normalize_popups(unsigned short auftrag)
{
  unsigned short count;
  switch(geb[auftrag].art)
      {
         case KASERNE: kaspopobj[KASPLAY].ob_state=NORMAL;
                       kaspopobj[KASPAUSE].ob_state=DISABLED;
                       kaspopobj[KASSTOP].ob_state=DISABLED;
                       for(count=KPSOLDAT; count<=KPFLAMME; count++)
                         kaspopobj[count].ob_state&=CHECKED;
                       break;
         case FABRIK_KL: klfpopobj[KLFPLAY].ob_state=NORMAL;
                         klfpopobj[KLFPAUSE].ob_state=DISABLED;
                         klfpopobj[KLFSTOP].ob_state=DISABLED;
                         for(count=KFPBUGGY; count<=KFPLASER; count++)
                           klfpopobj[count].ob_state&=CHECKED;
                         break;
         case FABRIK_GR: grfpopobj[GRFPLAY].ob_state=NORMAL;
                         grfpopobj[GRFPAUSE].ob_state=DISABLED;
                         grfpopobj[GRFSTOP].ob_state=DISABLED;
                         for(count=GFPSPANZ; count<=GFPFLAMM; count++)
                           grfpopobj[count].ob_state&=CHECKED;
                         break;
         case BAUANLAGE: gebpopobj[GEBPLAY].ob_state=NORMAL;
                         gebpopobj[GEBPAUSE].ob_state=DISABLED;
                         gebpopobj[GEBSTOP].ob_state=DISABLED;
                         gebpopobj[GEBSET].ob_state=DISABLED;
                         for(count=GPKRAFT; count<=GPINFRA; count++)
                           gebpopobj[count].ob_state&=CHECKED;
                         break;
      }

}


void popup_kaserne(void)
{
 int popret,oldsel,oldchecked;
 unsigned short prim,i,count;

 prim=id_suchen(KASERNE,1,0);
 for(i=KPSOLDAT;i<=KPFLAMME;i++) if(kaspopobj[i].ob_state&CHECKED) oldchecked=i;
 switch(oldchecked){
          case KPSOLDAT: oldsel=TRUPPE;
                         break;
          case KPTRUPPE: oldsel=TRUPPEN;
                         break;
          case KPBEKEH:  oldsel=BEKEHRER;
                         break;
          case KPBAZOOK: oldsel=BAZOOKA;
                         break;
          case KPGRENAD: oldsel=GRENADIER;
                         break;
          case KPFLAMME: oldsel=FLAMMENWERFER;
                         break;
                   }    /* RSC-Nr in STUNEDEF-Nr wnadeln */

 kaspopitem=0;
 popret=wdial_popup(kaspopobj, &kaspopitem, mausx-16,mausy-16, wdmsgs, gamespeed, timer_fun);
 if(popret)
 {
  if(geb[prim].status&BAUEN)
   {
     switch(kaspopitem)
      {
        case KASPLAY:  geb[prim].status&=~PAUSE;
                       if(netflag) set_tm_data(8, prim,0,0,0,0);
                       kaspopobj[KASPAUSE].ob_state=NORMAL;
                       kaspopobj[KASPLAY].ob_state=DISABLED;
                       break;
        case KASPAUSE: geb[prim].status|=PAUSE;
                       if(netflag) set_tm_data(7, prim,0,0,0,0);
                       kaspopobj[KASPAUSE].ob_state=DISABLED;
                       kaspopobj[KASPLAY].ob_state=NORMAL;
                       break;
        case KASSTOP:  knete[0]+=geb[prim].wie_weit;   /* bereits verwendetes Geld zurÅck */
                       geb[prim].status=0;
                       if(netflag) set_tm_data(9, prim,0,0,0,0);
                       kaspopobj[KASPLAY].ob_state=NORMAL;
                       kaspopobj[KASSTOP].ob_state=DISABLED;
                       kaspopobj[KASPAUSE].ob_state=DISABLED;
                       for(count=KPSOLDAT; count<=KPBEKEH; count++)
                         kaspopobj[count].ob_state&=CHECKED;
                       geb[prim].wie_weit=0;
                       aktualize_status(prim);
                       break;
      }
   }
  else       /* falls noch nicht gebaut wird */
   {
    if(kaspopitem!=KASPLAY)
     {
      switch(kaspopitem)    /* RSC-Nr in STUNEDEF-Nr wandeln */
       {
          case KPSOLDAT: oldsel=TRUPPE;
                         break;
          case KPTRUPPE: oldsel=TRUPPEN;
                         break;
          case KPBEKEH:  oldsel=BEKEHRER;
                         break;
          case KPBAZOOK: oldsel=BAZOOKA;
                         break;
          case KPGRENAD: oldsel=GRENADIER;
                         break;
          case KPFLAMME: oldsel=FLAMMENWERFER;
                         break;
       }
      kaspopobj[kaspopitem].ob_state=CHECKED;
      if (kaspopitem!=oldchecked) kaspopobj[oldchecked].ob_state=NORMAL;
      oldchecked=kaspopitem;
     }
    bauen(prim, oldsel);
    if(netflag) set_tm_data(3, prim,0,0,0,oldsel);
    kaspopobj[KASPLAY].ob_state=DISABLED;
    kaspopobj[KASSTOP].ob_state=NORMAL;
    kaspopobj[KASPAUSE].ob_state=NORMAL;
    for(count=KPSOLDAT; count<=KPFLAMME; count++)
      kaspopobj[count].ob_state|=DISABLED;
   }
 }

}


void popup_fabrik_kl(void)
{
 int popret,oldsel,oldchecked;
 unsigned short prim,i,count;

 prim=id_suchen(FABRIK_KL,1,0);
 for(i=KFPBUGGY;i<=KFPLASER;i++) if(klfpopobj[i].ob_state&CHECKED) oldchecked=i;
 switch(oldchecked){
          case KFPBUGGY: oldsel=QUAD;
                         break;
          case KFPLPANZ: oldsel=PANZER_L;
                         break;
          case KFPLASER: oldsel=LASERFAHRZEUG;
                         break;
          case KLFTRIKE: oldsel=TRIKE;
                         break;
                   }    /* RSC-Nr in STUNEDEF-Nr wnadeln */
 klfpopitem=0;
 popret=wdial_popup(klfpopobj,&klfpopitem,mausx-16,mausy-16, wdmsgs, gamespeed, timer_fun);
 if(popret)
  {
   if(geb[prim].status&BAUEN)
    {
     switch(klfpopitem)
      {
        case KLFPLAY:  geb[prim].status&=~PAUSE;
                       if(netflag) set_tm_data(8, prim,0,0,0,0);
                       klfpopobj[KLFPAUSE].ob_state=NORMAL;
                       klfpopobj[KLFPLAY].ob_state=DISABLED;
                       break;
        case KLFPAUSE: geb[prim].status|=PAUSE;
                       if(netflag) set_tm_data(7, prim,0,0,0,0);
                       klfpopobj[KLFPAUSE].ob_state=DISABLED;
                       klfpopobj[KLFPLAY].ob_state=NORMAL;
                       break;
        case KLFSTOP:  knete[0]+=geb[prim].wie_weit;   /* bereits verwendetes Geld zurÅck */
                       geb[prim].status=0;
                       if(netflag) set_tm_data(9, prim,0,0,0,0);
                       klfpopobj[KLFPLAY].ob_state=NORMAL;
                       klfpopobj[KLFSTOP].ob_state=DISABLED;
                       klfpopobj[KLFPAUSE].ob_state=DISABLED;
                       for(count=KFPBUGGY; count<=KFPLASER; count++)
                         klfpopobj[count].ob_state&=CHECKED;
                       geb[prim].wie_weit=0;
                       aktualize_status(prim);
                       break;
      }
    }
   else       /* falls noch nicht gebaut wird */
    {
     if(klfpopitem!=KLFPLAY)
      {
       switch(klfpopitem){
                      case KFPBUGGY: oldsel=QUAD;
                                     break;
                      case KFPLPANZ: oldsel=PANZER_L;
                                     break;
                      case KFPLASER: oldsel=LASERFAHRZEUG;
                                     break;
                      case KLFTRIKE: oldsel=TRIKE;
                                     break;
                     }    /* RSC-Nr in STUNEDEF-Nr wnadeln */
       klfpopobj[klfpopitem].ob_state=CHECKED;
       if (klfpopitem!=oldchecked) klfpopobj[oldchecked].ob_state=NORMAL;
       oldchecked=klfpopitem;
      }
     bauen(prim, oldsel);
     if(netflag) set_tm_data(3, prim,0,0,0,oldsel);
     klfpopobj[KLFPLAY].ob_state=DISABLED;
     klfpopobj[KLFSTOP].ob_state=NORMAL;
     klfpopobj[KLFPAUSE].ob_state=NORMAL;
     for(count=KFPBUGGY; count<=KFPLASER; count++)
       klfpopobj[count].ob_state|=DISABLED;
    }
 }

}


void popup_fabrik_gr(void)
{
 int popret,oldsel,oldchecked;
 unsigned short prim,i,count;

 prim=id_suchen(FABRIK_GR,1,0);
 for(i=GFPSPANZ;i<=GFPFLAMM;i++) if(grfpopobj[i].ob_state&CHECKED) oldchecked=i;
 switch(oldchecked){
          case GFPSPANZ:  oldsel=PANZER_S;
                          break;
          case GFPRAKET:  oldsel=RAKETENWERFER;
                          break;
          case GFPSAMLR:  oldsel=SAMMLER;
                          break;
          case GFPINFRA:  oldsel=INFRATANK;
                          break;
          case GFPFLAMM:  oldsel=FLAMMENTANK;
                          break;
                   }    /* RSC-Nr in STUNEDEF-Nr wnadeln */
 grfpopitem=0;
 popret=wdial_popup(grfpopobj,&grfpopitem,mausx-16,mausy-16, wdmsgs, gamespeed, timer_fun);
 if(popret)
 {
  if(geb[prim].status&BAUEN)
   {
     switch(grfpopitem)
      {
        case GRFPLAY:  geb[prim].status&=~PAUSE;
                       if(netflag) set_tm_data(8, prim,0,0,0,0);
                       grfpopobj[GRFPAUSE].ob_state=NORMAL;
                       grfpopobj[GRFPLAY].ob_state=DISABLED;
                       break;
        case GRFPAUSE: geb[prim].status|=PAUSE;
                       if(netflag) set_tm_data(7, prim,0,0,0,0);
                       grfpopobj[GRFPAUSE].ob_state=DISABLED;
                       grfpopobj[GRFPLAY].ob_state=NORMAL;
                       break;
        case GRFSTOP:  knete[0]+=geb[prim].wie_weit;   /* bereits verwendetes Geld zurÅck */
                       geb[prim].status=0;
                       if(netflag) set_tm_data(9, prim,0,0,0,0);
                       grfpopobj[GRFPLAY].ob_state=NORMAL;
                       grfpopobj[GRFSTOP].ob_state=DISABLED;
                       grfpopobj[GRFPAUSE].ob_state=DISABLED;
                       for(count=GFPSPANZ; count<=GFPFLAMM; count++)
                         grfpopobj[count].ob_state&=CHECKED;
                       geb[prim].wie_weit=0;
                       aktualize_status(prim);
                       break;
      }
   }
  else       /* falls noch nicht gebaut wird */
   {
    if(grfpopitem!=GRFPLAY)
     {
      switch(grfpopitem){
          case GFPSPANZ:   oldsel=PANZER_S;
                          break;
          case GFPRAKET:    oldsel=RAKETENWERFER;
                          break;
          case GFPSAMLR:  oldsel=SAMMLER;
                          break;
          case GFPINFRA:  oldsel=INFRATANK;
                          break;
          case GFPFLAMM:  oldsel=FLAMMENTANK;
                          break;
                   }    /* RSC-Nr in STUNEDEF-Nr wnadeln */
      grfpopobj[grfpopitem].ob_state=CHECKED;
      if (grfpopitem!=oldchecked) grfpopobj[oldchecked].ob_state=NORMAL;
      oldchecked=grfpopitem;
     }
    bauen(prim, oldsel);
    if(netflag) set_tm_data(3, prim,0,0,0,oldsel);
    grfpopobj[GRFPLAY].ob_state=DISABLED;
    grfpopobj[GRFSTOP].ob_state=NORMAL;
    grfpopobj[GRFPAUSE].ob_state=NORMAL;
    for(count=GFPSPANZ; count<=GFPFLAMM; count++)
      grfpopobj[count].ob_state|=DISABLED;
   }
 }

}


void popup_bauanlage(void)
{
 int popret,oldsel,oldchecked;
 unsigned short prim,i,count;

 prim=id_suchen(BAUANLAGE,1,0);
 for(i=GPKRAFT;i<=GPINFRA;i++)
   if(gebpopobj[i].ob_state&CHECKED) {oldchecked=i;oldsel=i;}
 gebpopitem=0;
 popret=wdial_popup(gebpopobj,&gebpopitem,mausx-16,mausy-16, wdmsgs, gamespeed, timer_fun);
 if(popret)
 {
  if(geb[prim].status&BAUEN)
   {
    switch(gebpopitem)
      {
        case GEBPLAY:  geb[prim].status&=~PAUSE;
                       if(netflag) set_tm_data(8, prim,0,0,0,0);
                       gebpopobj[GEBPAUSE].ob_state=NORMAL;
                       gebpopobj[GEBPLAY].ob_state=DISABLED;
                       break;
        case GEBPAUSE: geb[prim].status|=PAUSE;
                       if(netflag) set_tm_data(7, prim,0,0,0,0);
                       gebpopobj[GEBPAUSE].ob_state=DISABLED;
                       gebpopobj[GEBPLAY].ob_state=NORMAL;
                       break;
        case GEBSTOP:  knete[0]+=geb[prim].wie_weit;   /* bereits verwendetes Geld zurÅck */
                       geb[prim].status=0;
                       if(netflag) set_tm_data(9, prim,0,0,0,0);
                       gebpopobj[GEBPLAY].ob_state=NORMAL;
                       gebpopobj[GEBSTOP].ob_state=DISABLED;
                       gebpopobj[GEBPAUSE].ob_state=DISABLED;
                       for(count=GPKRAFT; count<=GPINFRA; count++)
                         gebpopobj[count].ob_state&=CHECKED;
                       geb[prim].wie_weit=0;
                       aktualize_status(prim);
                       break;
      }
   }
  else       /* falls noch nicht gebaut wird */
   {
    switch(gebpopitem)
     {
      default:       oldsel=gebpopitem;
                     gebpopobj[gebpopitem].ob_state=CHECKED;
                     if(gebpopitem!=oldchecked)
                       gebpopobj[oldchecked].ob_state=NORMAL;
                     oldchecked=gebpopitem;
      case GEBPLAY:  bauen(prim,oldsel);
                     if(netflag) set_tm_data(3, prim,0,0,0,oldsel);
                     gebpopobj[GEBPLAY].ob_state=DISABLED;
                     gebpopobj[GEBSTOP].ob_state=NORMAL;
                     gebpopobj[GEBPAUSE].ob_state=NORMAL;
                     for(count=GPKRAFT; count<=GPINFRA; count++)
                       gebpopobj[count].ob_state|=DISABLED;
                     break;
      case GEBSTOP:  knete[0]+=geb[prim].wie_weit;
                     normalize_popups(prim);
                     geb[prim].wie_weit=0;
                     aktualize_status(prim);
                     break;
      case GEBSET:   ak_art=3;
                     break;
     }
   }
 }

}

void set_enable(void)
{
  gebpopobj[GEBSET].ob_state=NORMAL;
  gebpopobj[GEBPAUSE].ob_state=DISABLED;
}



/* ***Popups je nach Technologielevel zusammenbasteln*** */
void techlev2popups(int tlvl)
{
 unsigned int i, obh, iconh;

 obh=gebpopobj[1].ob_height;         /* Hîhe eines Stringobjects - willkÅrlich mal von gebpopobj */
 iconh=gebpopobj[GEBPLAY].ob_height; /* Hîhe eines Iconobjects */

 /* Kasernenpopup */
 for(i=KPSOLDAT; i<=KPBEKEH; i++) kaspopobj[i].ob_flags|=HIDETREE;
 for(i=0; i<tech_level[tlvl].kas[0]; i++)
  {
   switch(tech_level[tlvl].kas[i+1])
    {
     case TRUPPE:
        kaspopobj[KPSOLDAT].ob_flags&=~HIDETREE;  kaspopobj[KPSOLDAT].ob_y=i*obh;
        break;
     case TRUPPEN:
        kaspopobj[KPTRUPPE].ob_flags&=~HIDETREE;  kaspopobj[KPTRUPPE].ob_y=i*obh;
        break;
     case BEKEHRER:
        kaspopobj[KPBEKEH].ob_flags&=~HIDETREE;  kaspopobj[KPBEKEH].ob_y=i*obh;
        break;
     case BAZOOKA:
        kaspopobj[KPBAZOOK].ob_flags&=~HIDETREE;  kaspopobj[KPBAZOOK].ob_y=i*obh;
        break;
     case GRENADIER:
        kaspopobj[KPGRENAD].ob_flags&=~HIDETREE;  kaspopobj[KPGRENAD].ob_y=i*obh;
        break;
     case FLAMMENWERFER:
        kaspopobj[KPFLAMME].ob_flags&=~HIDETREE;  kaspopobj[KPFLAMME].ob_y=i*obh;
        break;
    }
  }
 kaspopobj[0].ob_height=i*obh+iconh;  kaspopobj[KASPLAY].ob_y=i*obh;
 kaspopobj[KASPAUSE].ob_y=i*obh;  kaspopobj[KASSTOP].ob_y=i*obh;

 /* Kleine-Fabrik-Popup */
 for(i=KFPBUGGY; i<=KFPLASER; i++) klfpopobj[i].ob_flags|=HIDETREE;
 for(i=0; i<tech_level[tlvl].klf[0]; i++)
  {
   switch(tech_level[tlvl].klf[i+1])
    {
     case QUAD:
        klfpopobj[KFPBUGGY].ob_flags&=~HIDETREE;  klfpopobj[KFPBUGGY].ob_y=i*obh;
        break;
     case TRIKE:
        klfpopobj[KLFTRIKE].ob_flags&=~HIDETREE;  klfpopobj[KLFTRIKE].ob_y=i*obh;
        break;
     case PANZER_L:
        klfpopobj[KFPLPANZ].ob_flags&=~HIDETREE;  klfpopobj[KFPLPANZ].ob_y=i*obh;
        break;
     case LASERFAHRZEUG:
        klfpopobj[KFPLASER].ob_flags&=~HIDETREE;  klfpopobj[KFPLASER].ob_y=i*obh;
        break;
    }
  }
 klfpopobj[0].ob_height=i*obh+iconh;  klfpopobj[KLFPLAY].ob_y=i*obh;
 klfpopobj[KLFPAUSE].ob_y=i*obh;  klfpopobj[KLFSTOP].ob_y=i*obh;

 /* Groûe-Fabrik-Popup */
 for(i=GFPSPANZ; i<=GFPFLAMM; i++) grfpopobj[i].ob_flags|=HIDETREE;
 for(i=0; i<tech_level[tlvl].grf[0]; i++)
  {
   switch(tech_level[tlvl].grf[i+1])
    {
     case RAKETENWERFER:
        grfpopobj[GFPRAKET].ob_flags&=~HIDETREE;  grfpopobj[GFPRAKET].ob_y=i*obh;
        break;
     case PANZER_S:
        grfpopobj[GFPSPANZ].ob_flags&=~HIDETREE;  grfpopobj[GFPSPANZ].ob_y=i*obh;
        break;
     case SAMMLER:
        grfpopobj[GFPSAMLR].ob_flags&=~HIDETREE;  grfpopobj[GFPSAMLR].ob_y=i*obh;
        break;
     case INFRATANK:
        grfpopobj[GFPINFRA].ob_flags&=~HIDETREE;  grfpopobj[GFPINFRA].ob_y=i*obh;
        break;
     case FLAMMENTANK:
        grfpopobj[GFPFLAMM].ob_flags&=~HIDETREE;  grfpopobj[GFPFLAMM].ob_y=i*obh;
        break;
    }
  }
 grfpopobj[0].ob_height=i*obh+iconh;  grfpopobj[GRFPLAY].ob_y=i*obh;
 grfpopobj[GRFPAUSE].ob_y=i*obh;  grfpopobj[GRFSTOP].ob_y=i*obh;

 /* GebÑude-Popup */
 for(i=GPKRAFT; i<=GPINFRA; i++) gebpopobj[i].ob_flags|=HIDETREE;
 for(i=0; i<tech_level[tlvl].bau[0]; i++)
  {
   gebpopobj[tech_level[tlvl].bau[i+1]].ob_flags&=~HIDETREE;
   gebpopobj[tech_level[tlvl].bau[i+1]].ob_y=i*obh;
  }
 gebpopobj[0].ob_height=i*obh+iconh;
 gebpopobj[GEBPLAY].ob_y=i*obh;  gebpopobj[GEBPAUSE].ob_y=i*obh;
 gebpopobj[GEBSTOP].ob_y=i*obh;  gebpopobj[GEBSET].ob_y=i*obh;

}
