/*--------------------------------------------------------*/
/*                                                        */
/*           ------------------------------               */
/*                                                        */
/*      P r o g r a m m - S k e l e t t                   */
/*                                                        */
/*      Hauptmodul zum GEM-Programm                       */
/*                                                        */
/*      entwickelt auf ATARI TT030                        */
/*                 mit Mark Williams C  Version 3.09      */
/*                                                        */
/*      (c) 1992  by Volker Nawrath                       */
/*--------------------------------------------------------*/


/* Include-Dateien
 * --------------- */

/* >>>>>	eigene Headerdateien (spez. zur Resource-Datei eintragen
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
#include  "xxxxxxxx.h"	/* >>>>>	Resource-Datei 			*/
#include  "xxxxxxxx.h"   /* >>>>>	Definitionen zum Programm	*/
/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

#include  <aesbind.h>
#include  <event.h>
#include  <gemdefs.h>
#include  <gemsys.h>
#include  <obdefs.h>
#include  <osbind.h>
#include  <stdio.h>
#include  <vdibind.h>
#include  <window.h>


/* >>>>>	globale Strings 
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
char rsc_name[]    = "xxxxxxxx.RSC";	/* >>>>>	Resource-Datei	*/
char std_scrap[]   = "x:\\CLIPBRD";	/* >>>>>	Clipboard-Pfad	*/
/* hier auch Parameter-Datei angeben! */
/*  Format  : <Programm-Name>.INF     */
/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<	*/


/* Prototypen - GEM-Manager
 * ------------------------ */
extern    int  clip();
extern    int  do_movedial();
extern	void	draw_deskobjc();
extern    int  gem_exit();
extern    int  gem_init();
extern    int  handle_to_index();
extern    void handle_window();
extern    void init_buttons();
extern    int  menu_search();
extern	void	move_deskobjc();
extern    void neupix();
extern    int  open_window();
extern    int  popup_menu();
extern    void v_evntinit();
extern    void v_event();
extern    void wind_info_set();
extern    void win_exit();
extern    void win_init();
extern    int  wm_call();

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * hier noch evtl. weitere Funktionen des GEM-Managers eintragen
 * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */



/* Prototypen - Programm
 * --------------------- */
static    int  init_prg();
static    void exit_prg();
static    void hdle_key();
static    void hdle_menu();
static    void hdle_mouse();

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 * hier noch evtl. weitere Funktionen dieses Programms eintragen
 * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */


/* Variablen - GEM-Manager
 * ---------------------- */
int            ap_id,vdi_handle,work_in[12],work_out[57],contrl[12];
int            intin[128],ptsin[128],intout[128],ptsout[128],global[15];
EVNT           event;
EVNT_RETURN    event_return;
WIND_DATA      *windows;
ACT            aktuell,before;


/* Variablen - Programm
 * -------------------- */
extern    int  Prog_End;		/* Programmende-Schalter, vom GEM-
						 * Manager bereitgestellt		*/
GRECT     desksize;           /* Desk-Grîsse                     */

/* >>>>>	Hier sind die Zeiger fÅr die Resourcen (MenÅ, eigener
 * >>>>>  Desktop, Dialogboxen usw.) zu definieren
 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>	*/

OBJECT    *menu,              /* >>>>>	MenÅ                     */
          *desktop,           /* >>>>>  Desktop                  */
          *xxxxxxxx,          /* >>>>>  z.B. Dialogbox           */
          *xxxxxxxx,          /* >>>>>  z.B. Dialogbox			*/
          *xxxxxxxx;          /* >>>>>  z.B. Dialogbox			*/

/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<	*/



/* ########################################################################
 * Anmeldung des Programms
 * Aufgabe: Anmeldung beim AES, laden und auswerten der Resource-Datei,
 *          Scrap-Pfad setzen, MenÅ ausgeben, Desktop setzen,
 *          Mauszeiger auf Pfeil setzen
 * ######################################################################## */

static    int  init_prg()
{
     int       fehler;		/* RÅckgabefeld fÅr Funktionsaufrufe		*/
     OBJECT    *trees[99];	/* Zeiger auf Dialoge fÅr Button-Manager	*/
/*   char      scrp_path[MAXSTRING]; */

     /* Programm beim anmelden
      * ---------------------- */
     fehler = gem_init();
     if (fehler == -1)
          return(NO_INIT);
     
     /* Maus als Biene/Sanduhr
      * ---------------------- */
     graf_mouse(HOURGLASS,0L);

     wind_update(BEG_UPDATE);
     
     /* Resource-Datei laden
      * -------------------- */
     if (!rsrc_load(rsc_name))
          return(NO_RESOURCE);
     /* !!! Accessories, die unter GEM 2.x laufen sollen,
      * !!! dÅrfen keine Resource-Dateien laden */

     /* >>>>>	Anfangsadressen von Objekten ermitteln
      * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
     rsrc_gaddr(R_TREE  ,<Name vom MenÅ>     ,&menu);
     rsrc_gaddr(R_TREE  ,<Name vom Desktop>  ,&desktop);
     rsrc_gaddr(R_TREE  ,<Name von Dialogbox>,&xxxxxxxx);
     rsrc_gaddr(R_TREE  ,<Name von Dialogbox>,&xxxxxxxx);
     rsrc_gaddr(R_TREE  ,<Name von Dialogbox>,&xxxxxxxx);
     rsrc_gaddr(R_TREE  ,<Name von Dialogbox>,&xxxxxxxx);
	/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */


     /* >>>>>	Dialogboxen durch Button-Manager anpassen
      * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
     trees[0] = <zeiger auf Dialogbox>;
     trees[1] = <zeiger auf Dialogbox>;
     trees[2] = <zeiger auf Dialogbox>;
     trees[3] = <zeiger auf Dialogbox>;
     trees[4] = NULL;		/* Endekriterium der Liste		*/
     init_buttons(trees);	/* Buttons der Dialoge anpassen	*/
	/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
     
     /* Grîsse des Desktops ermitteln und Object-Struktur anpassen
      * ---------------------------------------------------------- */
     wind_get(DESK,WF_WORKXYWH,
              &desksize.g_x,&desksize.g_y,
              &desksize.g_w,&desksize.g_h);
     desktop[ROOT].ob_x      = desksize.g_x;
     desktop[ROOT].ob_y      = desksize.g_y;
     desktop[ROOT].ob_width  = desksize.g_w;
     desktop[ROOT].ob_height = desksize.g_h;

     /* Default-Objektbaum setzen (Desktop)
      * ----------------------------------- */
     objc_draw(desktop,ROOT,MAX_DEPTH,
               desksize.g_x,desksize.g_y,
               desksize.g_w,desksize.g_h);
     wind_set(DESK,WF_NEWDESK,desktop,ROOT);


     /* >>>>>	Scrap-Pfad setzen
	 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
      * scrp_read(scrp_path);
      * if (scrp_path[0] == 0)
      *   { std_scrap[0] = 'A' + (char) boot_dev();
      *     scrp_write(std_scrap);
      *   }
      * <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

	
     /* >>>>>	hier kann die INF-Datei geladen werden!
      * >>>>>	Der Pfad wird mit shel_find ermittelt.
	 * >>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

	
     /* >>>>>	MenÅ ausgeben und evtl. einige MenÅtitel inaktivieren
      * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
     menu_ienable(menu,<Name des MenÅeintrages>,0);
     menu_ienable(menu,<Name des MenÅeintrages>,0);
     menu_bar(menu,1);
	
	/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
     
     wind_update(END_UPDATE);

     /* Maus als Pfeil
      * -------------- */
     graf_mouse(ARROW,0L);

     return(INIT_OK);

} /* ENDE: init_prg() */


/* ##################################################################
 * Abmeldung des Programms
 * Aufgabe: MenÅ abmelden, Desktop zurÅcksetzen,
 *          Resource-Speicher freigeben
 * ################################################################## */

static    void exit_prg()
{
     /* MenÅ abmelden
      * ------------- */
     menu_bar(menu,0);

     /* Leerer Default-Objektbaum
      * ------------------------- */
     wind_set(DESK,WF_NEWDESK,0L,0);

     /* Resource-Speicher freigeben
      * --------------------------- */
     rsrc_free();

} /* ENDE: exit_prg() */


/* ####################################################################
 * Tastatur-Handler
 * Aufgabe: Auswertung der gedrÅckten Tasten
 * #################################################################### */

static    void hdle_key()
{
	/* >>>>>	Auswerten der Tastendrucke mit Hilfe des Event-Managers
	 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

} /* ENDE: hdle_key() */


/* ####################################################################
 * MenÅ-Handler
 * Aufgabe: Auswertung des ausgewÑhlten MenÅ-Eintrags
 * #################################################################### */

static    void hdle_menu(title,item)
          int  title,item;
{
	/* >>>>> Ermitteln des gewÅnschten MenÅeintrages. In "Title" wird
	 * >>>>> der MenÅtitel mitgegeben, in "Item" der MenÅeintrag. Die
	 * >>>>> Titel bzw. EintrÑge kînnen mit Hilfe der im Resource-
	 * >>>>> Construction-Kid angegebenen Namen abgefragt werden.
	 * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
    
     switch ()
     {
          case :
          {
               break;
          }
          case :
          {
               break;
          }
		
	} /* ENDE: switch() */
	
	/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
	
     /* Invertierung des MenÅeintrages aufheben
      * --------------------------------------- */
     menu_tnormal(menu,title,1);

} /* ENDE: hdle_menu() */


/* ####################################################################
 * Maus-Handler
 * Aufgabe: Auswertung des Mausklicks (linke Taste)
 * #################################################################### */

static    void hdle_mouse(clicks,taste,x,y)
          int       clicks,taste,x,y;
{
     int  obj;
     
     /* öber welchem Objekt befindet sich der Mauszeiger ?
      * ------------------------------------------------ */
     obj = objc_find(desktop,ROOT,MAX_DEPTH,x,y);

     /* >>>>>	Abfrage der Mausklicks
      * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
     if ((clicks == 2) && (taste == 1))
     {
		/* Doppelklick der linken Maustaste
		 * -------------------------------- */
          switch (obj)
          {
	          /* Aktionen je nach ausgewÑhltem Objekt durchfÅhren
     	      * ------------------------------------------------ */
               case :
               {
                    break;
               }
          }
     } /* ENDE: Aktion bei Doppelklick */

     else if ((clicks == 1) && (taste == 1))
     {
	     /* Einfachklick linke Maustaste?
     	 * ----------------------------- */

          graf_mkstate(&dummy,&dummy,&but_state,&dummy);

          /* linke Maustaste festgehalten?
           * ----------------------------- */
          if (but_state & 0x01)
          {
               /* Welches Object soll bewegt werden?
                * ---------------------------------- */
               switch (obj)
               {
                    case  :
                    {
                         move_deskobjc(desktop,obj);
                         break;
                    }
                    /* FÅr weitere Icons... */
               }
          }
          else
          {
	          /* linke Maustaste losgelassen:
                * Welches Object soll invertiert werden?
                * -------------------------------------- */
               switch (obj)
               {
                    case :
                    {
                         break;
                    }
			}
          } /* ENDE: Statusabfrage der Maustaste */
     }
     else if ((clicks == 1) && (taste == 2))
     {
	     /* Einfachklick rechte Maustaste?
     	 * ------------------------------ */
		 
     } /* ENDE: Abfrage der Anzahl Mausklicks */
	
	/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

} /* ENDE: hdle_mouse() */


/* ##########################################################
 * Hauptprogramm
 * Aufgabe: Initialisierung, Auswertung der Events, Abmeldung
 * ########################################################## */

int main()
{
     int       ret_code;           /* Allgemeines Feld fÅr RÅckgabewerte */
     char      t[200],alert[200];

     if ((ret_code = init_prg()) == INIT_OK)
     {
          /* >>>>>	Window-Manager initialisieren (max. Anzahl der
		 * >>>>>	Fenster mÅssen mitgegeben werden) !!!!!!!!!!!!
           * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
          win_init(7);
		/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */
          
          /* >>>>>	Event-Manager fÅr die Hauptschleife initialisieren
           * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
          v_evntinit(0);
          v_evntinit(1);
          event.event  = (MU_MESAG|MU_BUTTON|MU_KEYBD|........);
          event.clicks = 000;
          event.state  = 0;
          event.button = 0;
		.
		.
		.
		/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */


          /* >>>>>	weitere programminterne Initialisierungen
           * >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */
		
		
		/* <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<< */

		
		/* Hauptschleife
		/* ------------- */
          do
          {
               v_event();
               
               if (EVNT_MESAG())
               {
                    /* Nachricht auswerten
                     * ------------------- */
                    switch (event_return.buffer[0])
                    {
                         case MN_SELECTED:
                         {
                              /* MenÅ wurde angewÑhlt
                               * -------------------- */
                              hdle_menu(event_return.buffer[3],
                                        event_return.buffer[4]);
                              break;
                         }
                         
                         default:
                         {
                              /* PrÅfen, ob Meldung Fenster betrifft
                               * ----------------------------------- */
                              handle_window(event_return.buffer);
                         }
                         
                         /* >>>>>	Platz fÅr weitere Message-Auswertungen
                          * >>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<< */
                    }
               }
               
               if (EVNT_BUTTON())
               {
                    /* Mausknopfereignis
                     * ----------------- */
                    hdle_mouse(event_return.times,
                               event_return.mouse_b,
                               event_return.mouse_x,
                               event_return.mouse_y);
               }
               
               if (EVNT_KEYBD())
               {
                    /* Tastaturereignis; Zuerst muû geprÅft werden, ob
                     * ein MenÅeintrag selektiert wurde
                     * ----------------------------------------------- */
                    ret_code = menu_search(ap_id,menu,
                                             event_return.mouse_k,
                                             event_return.key     );
                    if (!ret_code)
                    {
                         /* Kein MenÅeintrag selectiert, Taste auswerten
                          * -------------------------------------------- */
                         hdle_key();
                    }
               }
          } while(!Prog_End);

     } /* ENDE: Programmschleife */

     else
     {
          /* Schwerer Fehler beim Programmstart
           * ---------------------------------- */
          if (ret_code==NO_INIT)
          {
               strcpy(t,"!!!!!  Schwerer Fehler  !!!!!|");
               strcat(t,"-----------------------------|");
               strcat(t," Das AES konnte Applikation  |");
               strcat(t," nicht anmelden =>  Abbruch  ");
          }
          else if (ret_code==NO_RESOURCE)
          {
               strcpy(t,"!!!!!  Schwerer Fehler  !!!!!|");
               strcat(t,"-----------------------------|");
               strcat(t,"Resource-Datei nicht gefunden|");
          }
          sprintf(alert,"[1][%s][Abbruch]",t);
          form_alert(1,alert);
          exit(1);
     }
     
     win_exit();		/* Window-Manager abmelden		*/
     exit_prg();		/* MenÅ, Speicher usw. freigeben	*/
     gem_exit();		/* Programm abmelden			*/

} /* ENDE: main() */

