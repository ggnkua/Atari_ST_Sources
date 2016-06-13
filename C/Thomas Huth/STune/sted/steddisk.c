/**
 * STune - The battle for Aratis
 * steddisk.c : Functions for loading and saving.
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
#include <osbind.h>
#include <stdlib.h>
#include <string.h>

#ifdef SOZOBON
#include <macros.h>
#endif

#include "stunedef.h"
#include "level.h"
#include "gebaeude.h"
#include "stedmain.h"

#ifndef FALSE
#define FALSE 0
#endif


#ifdef SOZOBON
#define aesversion gl_apversion		/* Die AES-Versionsnummer */
#endif

#ifdef __TURBOC__
#define aesversion _GemParBlk.global[0]
#endif


/* **Variablen** */
char fpath[256], fname[64];			/* Pfadnamen */
unsigned char sfbuf[128*128];
LEVEL_HEADER hd;


/* ***Fileselector-Box*** */
int fileselect(char *fstitle)
{
 int i, retbut;

#ifdef RESTRIC_STED
 strcat(fpath, "LVL_U*");
#else
 strcat(fpath, "LVL_*");		/* Add file mask */
#endif

 wind_update(BEG_MCTRL);
 if(aesversion>0x130)
   fsel_exinput(fpath, fname, &retbut, fstitle);
  else
   fsel_input(fpath, fname, &retbut);
 wind_update(END_MCTRL);

 for(i=strlen(fpath); fpath[i]!='\\' && i>0; i--) ;
 fpath[i+1]=0;				/* Disable file mask */

 if(retbut==0)  return(-1);

 if( fpath[1]==':' )
 {
   Dsetdrv(fpath[0]-'A');
 }

 return( Dsetpath(&fpath[2]) );
}


/* *** Level laden *** */
int loadlevel(char *fname)
{
 int fhndl;
 int i,dx,dy;
 LEVEL_HEADER hd;
 unsigned char *aktfld;

 fhndl=Fopen(fname, 0);
 if(fhndl<0)
  {
   form_alert(1,"[3][Konnte Leveldatei|nicht ”ffnen!][Ok]");
   return -1;
  }

 Fread(fhndl, sizeof(LEVEL_HEADER), &hd);
 if(hd.hmagic!='STUN')
  {
   form_alert(1,"[3][Not a STune|level file!][Ok]");
   Fclose(fhndl);
   return -1;
  }
 if(hd.version<LVLVERSION)
  {
   form_alert(1,"[3][This level file|is out of date!][Ok]");
   Fclose(fhndl);
   return -1;
  }

#ifdef RESTRIC_STED
 if(hd.lvltyp!=2)
  {
   form_alert(1,
     "[3][Sorry, you're not allowed|to change this level file!][Ok]");
   Fclose(fhndl);
   return -1;
  }
#endif

 r_width=hd.r_wdth;
 r_height=hd.r_hght;
 knete[0]=hd.geld[0]; knete[1]=hd.geld[1];
 tech_level=hd.techlevel;
 lvl_type=hd.lvltyp;
 lvlid=hd.id;

 if( Fread(fhndl, (long)sizeof(char)*r_width*r_height, sfbuf) 
     != sizeof(char)*r_width*r_height )
   { form_alert(1,"[3][Fehler beim Lesen|der Leveldatei!][Ok]");
     Fclose(fhndl); return -1; }
 aktfld=sfbuf;
 for(dy=0; dy<(int)r_height; dy++)
  for(dx=0; dx<(int)r_width; dx++)
   {
    sfeld[dx][dy].feldtyp=*aktfld;
    sfeld[dx][dy].erforscht=0;
    if(*aktfld<16)
     { sfeld[dx][dy].begehbar=1; sfeld[dx][dy].befahrbar=1; }
     else
     { sfeld[dx][dy].begehbar=0; sfeld[dx][dy].befahrbar=0; }
    sfeld[dx][dy].besetzt=0;
    ++aktfld;
   }

 en_anz=hd.anz_obj;

 i=0;
 while( i < en_anz )
  {
   if( Fread(fhndl, sizeof(LEVEL_EINTRAG), &en[i]) != sizeof(LEVEL_EINTRAG) )
    { form_alert(1,"[3][Fehler beim Lesen|der Leveldatei!][Ok]");
      Fclose(fhndl); return -1; }
   switch(en[i].typ)
    {
     case 0:
       setgebaeude(en[i].art, en[i].xpos, en[i].ypos, en[i].ges);
       break;
     case 1:
       sfeld[en[i].xpos][en[i].ypos].befahrbar=FALSE;
       sfeld[en[i].xpos][en[i].ypos].begehbar=FALSE;
       sfeld[en[i].xpos][en[i].ypos].besetzt=1;
       sfeld[en[i].xpos][en[i].ypos].besetzertyp=1;
       sfeld[en[i].xpos][en[i].ypos].gesinnung=en[i].ges;
       break;
    }
   i+=1;
  }

 Fclose(fhndl);

 rwx=rwy=0;

 return 0;
}




/* *** Level speichern *** */
int savelevel(char *lname)
{
 int fhndl;
 int dx, dy, i;
 unsigned char *aktfld;

 hd.hmagic='STUN';
 hd.headlen=sizeof(LEVEL_HEADER);
 hd.techlevel=tech_level;
 hd.anz_obj=en_anz;
 hd.r_wdth=r_width;  hd.r_hght=r_height;
 hd.geld[0]=knete[0]; hd.geld[1]=knete[1];
 hd.flags=0;
 hd.id=lvlid;
 hd.ext1=hd.ext2=0;

#if LVLVERSION<0x0095
 hd.version = 0x0095;
#else
 hd.version = LVLVERSION;  /* Level-Version */
#endif

#ifdef RESTRIC_STED
 hd.lvltyp = 2;
#else
 hd.lvltyp = lvl_type;     /* Level Typ */
#endif

 fhndl=Fcreate(lname, 0);
 if(fhndl<0)
  {
   form_alert(1,"[3][Couldn't create|levelfile!][Ok]");
   return(fhndl);
  }

 Fwrite(fhndl, sizeof(hd), &hd);

 aktfld=sfbuf;
 for(dy=0; dy<(int)r_height; dy++)
  for(dx=0; dx<(int)r_width; dx++)
   {
    *aktfld++=sfeld[dx][dy].feldtyp;
   }
 if( Fwrite(fhndl, (long)sizeof(char)*r_height*r_width, sfbuf)
    != sizeof(char)*r_height*r_width )
  form_alert(1,"[3][Error while writing][Ok]");

 if( Fwrite(fhndl, (long)sizeof(LEVEL_EINTRAG)*en_anz, en)
    != sizeof(LEVEL_EINTRAG)*en_anz )
  form_alert(1,"[3][Error while writing][Ok]");

 Fclose(fhndl);

 return 0;
}
