/*--------------------------------------------------------*/
/*                 G E M _ A L L G . C                    */
/*           ------------------------------               */
/*                                                        */
/*      Beispielprogramm zum GEM-Manager                  */
/*                                                        */
/*      Modul mit allgemeinen Funktionen fÅr das          */
/*      Beispielprogramm.                                 */
/*                                                        */
/*                                                        */
/*      Version 1.00    vom 29.11.1992                    */
/*                                                        */
/*      entwickelt auf ATARI TT030                        */
/*                 mit Mark Williams C  Version 3.09      */
/*                                                        */
/*      (c) 1992  by Volker Nawrath                       */
/*--------------------------------------------------------*/

/* Include-Dateien
 * --------------- */
#include  <aesbind.h>
#include  <event.h>
#include  <gemdefs.h>
#include  <gemprog.h>
#include  <gemsys.h>
#include  <obdefs.h>
#include  <osbind.h>
#include  <vdibind.h>
#include  <window.h>


/* Prototypen - GEM-Manager
 * ------------------------ */
extern	int  do_movedial();


/* Prototypen - Programm
 * --------------------- */
void systeminfo();
int  umwandlung();


/* Felder - GEM-Manager
 * -------------------- */
extern    ACT  aktuell;


/* Felder dieses Programms
 * ----------------------- */
extern    OBJECT    *sysdial;


/* Strukturen dieses Programm
 * -------------------------- */
typedef struct
{
     unsigned int   nvdi_version;
     unsigned long  nvdi_datum;
     struct
     {
          unsigned gdos       :1;  /* GDOS                       */
          unsigned fehler     :1;  /* FehlerkompatibilitÑt       */
          unsigned gemdos     :1;  /* GEMDOS - Zeichenausgabe    */
          unsigned mouse      :1;  /* dynamische Maus            */
          unsigned linea      :1;  /* LINE-A                     */
          unsigned            :11; /* reserviert                 */
     } nvdi_config;
} NVDIPARAM;


/* #####################################################
 * Systeminformationen
 * Aufgabe: Ausgabe von Systeminformationen in Dialogbox
 * ##################################################### */

void systeminfo()
{
     int       ret_code;
     long      pointer;
     char      text[30];
     NVDIPARAM *nvdi;
     
     /* PrÅfen, ob NVDI installiert ist
      * ------------------------------- */
     ret_code = is_cookie(COOKIE_NVDI,&pointer);
     nvdi = (NVDIPARAM *) pointer;

     if (ret_code == TRUE)
     {
          /* NVDI ist installiert
           * -------------------- */
          sprintf(text,"Version: %2u.%02u",nvdi->nvdi_version >> 8,
                                           nvdi->nvdi_version & 0xff);
          put_dialogtext(sysdial,SYSNVDI,text);
     }
     else
     {
          strcpy(text,"nicht installiert");
          put_dialogtext(sysdial,SYSNVDI,text);
     }
     
     /* PrÅfen, ob Multitasking-System vorliegt
      * --------------------------------------- */
     if (aktuell.multitsk == TRUE)
     {
          strcpy(text,"ist vorhanden");
          put_dialogtext(sysdial,SYSMULTI,text);
     }
     else
     {
          strcpy(text,"nicht installiert");
          put_dialogtext(sysdial,SYSMULTI,text);
     }

     do_movedial(sysdial,SYSDRAG,0);
     
} /* ENDE: systeminfo() */


/* ###########################################################
 * Ausgaberoutine Nr. 1 fÅr Fenster
 * Aufgabe: Text in einem Fenster bzw. Fensterbereich ausgeben
 * ########################################################### */

int  umwandlung(string)
     char string[];
{
     int  zahl;
     
     if (string[0]=='@')
     {
          string[0] = '0';
     }
     
     zahl = atoi(string);
     return(zahl);

} /* ENDE: umwandlung() */


