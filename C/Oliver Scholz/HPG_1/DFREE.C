/*
 * Demonstrationsprogramm zur Programmierung
 * eines HPG Moduls:
 * Grafische Darstellung des Belegungsgrades
 * der Harddisk Partitionen
 *
 * Version 1.0
 ************************************************
 * von Oliver Scholz, Januar 1992
 * (c) 1992 MAXON Computer
 */
 

#include <portab.h>
#include <stdlib.h>
#include <tos.h>
#include <string.h>

/* 
 * aus <stdio.h>: (kann nicht included werden)
 */
WORD sprintf(BYTE *string, 
         const BYTE *format, ... );
WORD errno;  /* Startup-Code fehlt */

#include "hpglib.h"

/*
 * Objektdefinitionen, vom RCS erstellt
 */
#include "dfree.h"  

/* 
 * Name der Resourcedatei
 */
#define RSC_RSH "dfree.rsh"

#include "rshi.h"

/*
 * Definitionen abschalten, siehe Text
 */
#undef WORD 
#undef BYTE
#undef LONG

/*
 * Die Texte der Objekte, hier leider nur
 * Englisch/Deutsch, die dÑnische/franzîsische
 * Åbersetzung darf der Leser nach Geschmack 
 * selbst einfÅgen...
 * (erste praktische öbung...)
 */
static LNGDEF language[] =
{
  DFREE, TITLE,
  " Auslastung der Harddisk-Partitionen ", "",
  DFREE, DRIVE, "Laufwerk", "",
  DFREE, USAGE, "Belegungsgrad", "",
  DFREE, FREE, "Freie MB", "",
  -1
};

#define MAXDRIVE 8

WORD names[MAXDRIVE] = 
{
    CNAME, DNAME, ENAME, FNAME,
    GNAME, HNAME, INAME, JNAME
};
    
WORD gauges[MAXDRIVE] = 
{
    CBAR, DBAR, EBAR, FBAR,
    GBAR, HBAR, IBAR, JBAR
};
    
WORD backgd[MAXDRIVE] = 
{
    CGREY, DGREY, EGREY, FGREY,
    GGREY, HGREY, IGREY, JGREY
};
    
WORD _free[MAXDRIVE] = 
{
    FREEC, FREED, FREEE, FREEF,
    FREEG, FREEH, FREEI, FREEJ
};

WORD total[MAXDRIVE] =
{
    TOTALC, TOTALD, TOTALE, TOTALF,
    TOTALG, TOTALH, TOTALI, TOTALJ
};
    
OBJECT *dfree;

LONG read_drvbits(VOID);
VOID main (VOID);

/*
 * Das Hauptprogramm.. (endlich!)
 */
VOID main (VOID)
{
  WORD button,i,mask;
  WORD drvbits = (WORD)read_drvbits();
  DISKINFO info;
  float mb;
  char buffer[16];

  FIX_RSC();
  /* 
   * eingestellte Sprache eintragen
   */
  fix_language(tree, language);
  
  /*
   * Adresse des Objektbaumes holen
   */
  dfree = tree[DFREE];

  /* 
   * Laufwerk C maskieren
   */
  mask = 0x4;
  
  for (i = 0; i < MAXDRIVE; i++)
  {
   /* 
    * Laufwerk vorhanden ?
    */

    if (!(drvbits & mask))
    {
      /* 
       * Nein: dazugehîrige Objekte verstecken
       */
      dfree[names[i]].ob_flags |= HIDETREE;
      dfree[gauges[i]].ob_flags |= HIDETREE;
      dfree[backgd[i]].ob_flags |= HIDETREE;
      dfree[_free[i]].ob_flags |= HIDETREE;
      dfree[total[i]].ob_flags |= HIDETREE;
    } 
    else
    {
      /* 
       * Ja: Objekte zeigen
       */
      dfree[names[i]].ob_flags &= ~HIDETREE;
      dfree[gauges[i]].ob_flags &= ~HIDETREE;
      dfree[backgd[i]].ob_flags &= ~HIDETREE;
      dfree[_free[i]].ob_flags &= ~HIDETREE;    
      dfree[total[i]].ob_flags &= ~HIDETREE;    
      
      /*
       * Diskinformationen lesen
       */
      if (!Dfree(&info,i + 3))
      {
        /*
         * Balkenbreite berechnen und 
         * einstellen
         */
        dfree[gauges[i]].ob_width = (WORD)
          ((info.b_total - info.b_free)
          * dfree[backgd[i]].ob_width 
          / info.b_total);
          
        mb = (float)info.b_free * info.b_secsiz *
                    info.b_clsiz / 1024 / 1024;
           
        sprintf(buffer,"%6.2f",mb);
        strncpy(dfree[_free[i]].ob_spec.
                free_string,buffer,6);
          
        mb = (float)info.b_total * info.b_secsiz
             * info.b_clsiz / 1024 / 1024;
           
        sprintf(buffer,"%6.2f",mb);
        strncpy(dfree[total[i]].ob_spec.
                free_string,buffer,6);
      }
    }
    
    /* 
     * Maske fÅr nÑchstes Laufwerk 
     */
    mask = mask << 1;
  }
    
  /* 
   * Maus abschalten und Dialogbox zeichnen 
   */
  mouse_off();
  obopen(dfree);
  mouse_on();

  do
  {
    /* 
     * Dialog abarbeiten, Doppelclick ignorieren 
     */
    button = obdoform(dfree, 0) & 0x7fff;
  }
  while (button != CLOSE);

  
  /* 
   * Dialogbox schlieûen, zurÅck zum Harlekin 
   */
  obclose(dfree);
  
  /* 
   * _keine_ exit()-Aufrufe verwenden ! 
   */
}

/*
 * drvbits-Variable lesen
 */
LONG read_drvbits (VOID)
{
  LONG ssp;
  LONG value;
  
  ssp=Super(0L);
  value = *(LONG *)0x4C2L;
  Super((VOID *)ssp);
  
  return(value);
}

