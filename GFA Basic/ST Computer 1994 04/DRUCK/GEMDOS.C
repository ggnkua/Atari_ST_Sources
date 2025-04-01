/* GEMDOS-PRINTER */
/* Sinn und Zweck:
   Als Druckericon auf dem Desktop ablegen.
   Eine daraufgezogene Datei wird dann ausgedruckt */

#include <aes.h>
#include <tos.h>
#include <stdio.h>

main(int argc, char *argv[])
{
   /* Der erste Eintrag der Kommando-Zeile steht in argv[1]
      Wenn's Åberhaupt einen gibt. Anzahl der EintrÑge (incl.
      argv[0]) steht in argc, sollte mindestens 2 sein      */

   int               ap_id, handle, cont, time;
   size_t            got, one;
   unsigned char  item;
   char              *doprint, *anofile, *anready, *aeropen, *aerfile;

   doprint="[2][Datei drucken ?][ OK |Abbruch]";
   anofile="[1][DrÅck mich, ich |bin der Drucker ! ][ OK ]";
   anready="[1][Bitte Drucker |bereit schalten. ][ OK |Abbruch]";
   aeropen="[3][Datei konnte nicht |geîffnet werden.][Abbruch]";
   aerfile="[3][Fehler beim Lesen der |Datei.][Abbruch]";

   ap_id=appl_init( );

   if ((argc>1) && (ap_id != -1))   /* Wenn Åberhaupt was in der TTP-Line war...*/
   {
      handle=open(argv[1], O_RDONLY);  /* Datei îffnen */
      one=1;      /* Immer nur ein Byte lesen   */
      cont=1;  /* RÅckgabewert vordefinieren */
      got=1;
      if (((form_alert(1,doprint))==1) && (handle != -1))
      {  /* Wenns was zu drucken gibt... */
         while (((got=read(handle, &item, one)) == 1) && (cont == 1))
            {  /* Ein Byte aus Datei geholt */
               while ((Cprnos( ) == 0) && (cont == 1))
               {  /* Solange Drucker nicht bereit... */
                  time=0;
                  while ((Cprnos( ) == 0) && (time < 250))
                     {  /* ...5 Sekunden prÅfen... */
                     evnt_timer(20,0);  /* (wichtig fÅr Multi-Tasking) */
                     time++;
                     }
                  if (Cprnos( ) == 0)  /* ... und Beschwerde ablassen */
                     cont=form_alert(1,anready);
               }
               if (cont == 1)  /* Zeichen an Drucker */
                     Cprnout(item);
            }
         close(handle); /* Fertig - Datei schlieûen */
      }
      if (handle == -1)  /* Melden, falls Abbruch wegen Fehler */
         form_alert(1,aeropen);
      if (got == -1)
         form_alert(1,aerfile);
   }
   else /* Drucker ohne Parameter aufgerufen */
      form_alert(1,anofile);

   if (ap_id != -1)  /* Das war's */
      appl_exit( );

   return 0;
}