/*********************************************************/
/* textmem.c                                             */
/* Text laden und gemaess den Benutzerwuenschen umformen */
/*********************************************************/
#include <portab.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>
#include <vdibind.h>
#include <aesbind.h>
#include "gprint.h"
#include "gdos.h"

extern long load_datei (const char *name, unsigned long *laenge,
                        unsigned long *z_mem);

long text_laden      (const char *text_name, unsigned long *laenge);
void text_relozieren (char *text_anfang, unsigned long *laenge,
                      unsigned long zmemory);
/**********************************************************/
/* Einsprungpunkt in dieses Modul. Von hier aus wird der  */
/* Text geladen und anschliessend entsprechend der        */
/* Benutzerwuensche (Umlaute, Tab-> SPACE usw.)           */
/* modifiziert.                                           */
/**********************************************************/
long text_laden(const char *text_name, unsigned long *laenge)
{
  unsigned long mem, len, zmemory;

  mem = load_datei(text_name, &len, &zmemory);
  text_relozieren((char *)mem, (unsigned long *)&len, zmemory);
  *laenge = len;

  return mem;

} /* text_laden() */

/***********************************************************/
/* Den geladenen Text umformen
   Folgende Moeglichkeiten:
   Tab in SPACE umwandeln, Umlaute ersetzen, Absaetze neu formatieren
   Diese Dinge koennen beliebig gemischt auftreten.
   Dabei wird der Text von der ersten Speicherposition immer weiter
   nach unten verschoben.
***********************************************************/
void text_relozieren(char *text_anfang, unsigned long *laenge, unsigned long zusaetz_mem)
{
  unsigned int count;
  unsigned char *ptext1, *ptext2;

  ptext1 = (unsigned char *)(text_anfang + 1024);
  ptext2 = (unsigned char *)(text_anfang + zusaetz_mem);

  if(PF.tab2space && !PF.umlaut_ers)
  {
    do
    {
      switch(*ptext2)
      {
        case 9   :  for(count = 1; count <= PF.tabspace; count++)
                      *ptext1++ = ' ';
                    break;
        default  :  *ptext1++ = *ptext2;
      }
      ptext2++;
    } while((char *)ptext2 < (char *)(text_anfang + *laenge + zusaetz_mem));
    *laenge = (char *)ptext1 - (char *)text_anfang - 1024;
  }

  if(PF.umlaut_ers)   /* Umlaute ersetzen */
  {
    do
    {
      switch(*ptext2)
      {
        case 142 :  *ptext1++ = 'A'; *ptext1++ = 'e';
                    break;
        case 132 :  *ptext1++ = 'a'; *ptext1++ = 'e';
                    break;
        case 153 :  *ptext1++ = 'O'; *ptext1++ = 'e';
                    break;
        case 148 :  *ptext1++ = 'o'; *ptext1++ = 'e';
                    break;
        case 154 :  *ptext1++ = 'U'; *ptext1++ = 'e';
                    break;
        case 129 :  *ptext1++ = 'u'; *ptext1++ = 'e';
                    break;
        case 158 :  *ptext1++ = 's'; *ptext1++ = 's';
                    break;
        case 9   :  if(PF.tab2space)             /* auch TAB's ersetzen ? */
                    {
                      for(count = 1; count <= PF.tabspace; count++)
                        *ptext1++ = ' ';
                    }
                    break;
        default  :  *ptext1++ = *ptext2;         /* sonst uebernehmen     */
      }
      ptext2++;
    } while((char *)ptext2 < (char *)(text_anfang + zusaetz_mem + *laenge));
    *laenge = ((char *)ptext1 - (char *)text_anfang) - 1024;
  }

  if(!PF.tab2space && !PF.umlaut_ers)          /* fuer Absatzformatierung */
  {
    ptext1 = (unsigned char *)text_anfang + 1024;
    ptext2 = (unsigned char *)(text_anfang + zusaetz_mem);
    do
    {
      *ptext1++ = *ptext2++;
    } while((char *)ptext2 < (char *)(text_anfang + zusaetz_mem + *laenge));
  }

  if(PF.absatz)                            /* Absaetze neu formatieren */
  {
    /* Ende eines Absatzes: Return + SPACE
                            Return + Return
       Zeilenende         : 0xD 0xA   =>    \r\n
    */
    unsigned char *cp;
    unsigned int  *ip, iz;
    unsigned long *lp;

    ptext1 = (unsigned char *)text_anfang;
    ptext2 = (unsigned char *)(text_anfang + 1024);
    do
    {
      switch(*ptext2)
      {
        case 0xD :                            /* Zeilenende?            */
          cp = ptext2;
          ip = (unsigned int *)ptext2;
          lp = (unsigned long *)ptext2;

          if(*lp == 0x0D0A0D0AL)     /* zwei Zeilenenden hintereinander */
          {
            lp++;                             /* ueberspringen          */
            *ptext1++ = 0x00;                 /* Stringende eintragen   */
            *ptext1++ = 0x0A;                 /* Leerzeile              */
            ptext2 = (unsigned char *)lp;     /* weiterkopieren ab hier */
            break;
          }
          if(*ip == 0x0D0A)                   /* Zeilenende             */
          {
            *ptext1++ = 0x20;                /* sonst kein Zwischenraum */
            ip++;                             /* Zeilenende uebergehen  */
            ptext2 = (unsigned char *)ip;     /* hier gehts weiter      */
            if(*ptext2 == 0x20)    /* beginnt naechste Zeile mit SPACE? */
            {
              *ptext1++ = 0x0;                /* Stringende markieren   */
              break;
            }
          }
          break;
        default  :  *ptext1++ = *ptext2++;        /* sonst uebernehmen  */
      }
    } while((char *)ptext2 < (char *)(text_anfang + 1024 + *laenge));
    *ptext1 = 0x0;
    *laenge = (char *)ptext1 - (char *)text_anfang;
  }
  else                                     /* keine Absatzformatierung  */
  {
    ptext1 = (unsigned char *)text_anfang; /* Text an Bereichsanfang kopieren */
    ptext2 = (unsigned char *)(text_anfang + 1024);
    do
    {
      *ptext1++ = *ptext2++;
    } while((char *)ptext2 < (char *)(text_anfang + 1024 + *laenge));
  }

} /* text_reolozieren() */
