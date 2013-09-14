/* XERROR.C
 *==========================================================================
 * DATE: February 15, 1990
 * Description: General Form Do Alert Handling
 *
 * INCLUDE FILE: XERROR.H
 */
 
 
/* INCLUDE FILES
 *==========================================================================
 */ 
#include <sys\gemskel.h>

#include "country.h"


/*
 * NOTE: FILE: ALERT.RSH
 *==========================================================================
 * The rs--- variables must be changed to as---
 * Note the variable names in the fixrsh() routine below
 * ie: rs_trindex[]  to as_trindex[];
 * IMAG0 should be AMAG0 instead, otherwise, it interferes with
 * the existing IMAG0 of XCONTROL.
 */
#include "alert.h"
#include "alert.rsh"



#include "xcontrol.h"
#include "windows.h"
#include "fixrsh.h"
#include "stuffptr.h"


/* PROTOTYPES
 *==========================================================================
 */
void blit_alert( GRECT *rect, BOOLEAN flag );


/* DEFINES
 *==========================================================================
 */
#define SAVE_DEFAULTS	0
#define MEM_ERR		1
#define FILE_ERR	2
#define FILE_NOT_FOUND  3

#define NO_NODES_ERR	4
#define RELOAD_CPXS	5
#define UNLOAD_CPX	6
#define NO_RELOAD	7
#define SAVE_HEADER	8
#define FILE_NOT_CPX	9
#define NO_SOUND_DMA	10
#define SHUTDOWN	11

/* EXTERNS
 *==========================================================================
 */
extern BOOLEAN Fix_As_Dialog;		/* FIXRSH.C */
extern int nplanes;			/* number of planes XCONTROL.C */

void open_vwork( void );
void close_vwork( void );

/* GLOBALS
 *==========================================================================
 */
#if USA | UK
		char Shut_String[] = "[1][ The Control Panel has | been Shutdown. Please | Reboot to Restart the | Control Panel. ][Exit]";

		char Alert1A[] = "[3][| Name Conflict!| Destination: ";
		char Alert1B[] = "| This file already exists!][COPY|Skip|Cancel]";

		char Alert2A[] = "[3][| Source File Not Found!| Source: ";
		char Alert2B[] = "][SKIP|Retry|Cancel]";

		char Alert3[] = "[3][ | | Critical File Error! ][SKIP|Retry|Cancel]";

		char Alert4A[] = "[1][ ";
		char Alert4B[] = " is too| large to load now.| Reboot if you want| to load it.][ OK ]";
		
		char *exit_text[] = {
				      "Cancel",
				      "OK"
				    }; 
#endif


#if ITALY
		char Shut_String[] = "[1][|Il Pannello di Controllo non Š|pi— attivo. Riavvia il sistema|per attivare il Pannello|di Controllo.][Esci]";


		char Alert1A[] = "[3][| Conflitto sul nome!| Destinazione: ";
		char Alert1B[] = "| Questo file esiste gi…!][COPIA|Salta|Annulla]";

		char Alert2A[] = "[3][|File sorgente non trovato!|Sorgente: ";
		char Alert2B[] = "][SALTA|Riprova|Annulla]";

		char Alert3[] = "[3][| |      Errore nel file!][SALTA|Riprova|Annulla]";

		char Alert4A[] = "[1][| ";
		char Alert4B[] = " ‚ troppo| grande per essere caricato| ora. Riavvia il sistema se| vuoi caricarlo.][ OK ]";

		char *exit_text[] = {
				      "Annulla",
				      "OK"
				    }; 
#endif



#if GERMAN
		char Shut_String[] = "[1][ Das Kontrollfeld wurde| abgeschaltet.  Bitte neu| booten um das Kontroll-| feld zu reaktivieren.][Ausgang]";
		char Alert1A[] = "[3][| Namenskonflikt!| Ziel: ";
		char Alert1B[] = "| Diese Datei existiert beneits!][Kopieren|Weiter|Abbruch]";

		char Alert2A[] = "[3][| Quelldatei nicht gefunden!| Quelle: ";
		char Alert2B[] = "][Weiter|Nochmal|Abbruch]";

		char Alert3[] = "[3][ | | Kritischer Dateifehler!][Weiter|Nochmal|Abbruch]";

		char Alert4A[] = "[1][ ";
		char Alert4B[] = " ben”tigt| mehr Speicher um gestartet| zu werden. Zum Starten| bitte neu booten.][ OK ]";
		
		char *exit_text[] = {
				      "Abbruch",
				      "OK"
				    }; 
#endif



#if FRENCH
		char Shut_String[] = "[1][ Le panneau de contr“le a| ‚t‚ verrouill‚. Veuillez| red‚marrer le systŠme pour| valider de nouveau le| panneau de contr“le.][ CONFIRME ]";

		char Alert1A[] = "[3][| Conflit de noms!| Destination: ";
		char Alert1B[] = "| Ce fichier existe d‚j…!][COPIE|Suivant|Annule]";

		char Alert2A[] = "[3][| Fichier source non trouv‚!| Source: ";
		char Alert2B[] = "][SUIVANT|R‚essayer|Annule]";

		char Alert3[] = "[3][| |   Erreur fatale sur fichier!][SUIVANT|R‚essayer|Annule]";

		char Alert4A[] = "[1][ ";
		char Alert4B[] = " est trop| important pour ˆtre utilis‚.| Red‚marrez le systŠme| pour le mettre en m‚moire.][ CONFIRME ]";

		char *exit_text[] = {
				      "Annule",
				      "CONFIRME"
				    }; 
#endif



#if SPAIN
		char Shut_String[] = "[1][ El Panel de Control| ha sido suprimido.| Arranque de nuevo| para Instalarlo.][Salir]";

		char Alert1A[] = "[3][| \255Nombre Conflictivo!| Destino: ";
		char Alert1B[] = "| \255Este fichero ya Existe!][COPIAR|Omitir|Anular]";

		char Alert2A[] = "[3][| \255No encuentro fichero fuente!| Fuente: ";
		char Alert2B[] = "][Omitir|Reintentar|Anular]";

		char Alert3[] = "[3][| |    \255Error critico en fichero!][Omitir|Reintentar|Anular]";

		char Alert4A[] = "[1][";
		char Alert4B[] = " es demasiado|grande para cargarlo en|este momento. Arranque de|nuevo si quiere cargarlo.][ OK ]"; 

		char *exit_text[] = {
				      "Anular",
				      "CONFIRMAR"
				    }; 
#endif


#if SWEDEN
		char Shut_String[] = "[1][ Kontrollpanelen har| st„ngts av. Starta om| datorn f”r aktivera| kontrollpanelen igen.][OK]";

		char Alert1A[] = "[3][| Namnkonflikt!| ";
		char Alert1B[] = "| finns redan.][KOPIERA|HOPPA|AVBRYT]";

		char Alert2A[] = "[3][| Kan ej ”ppna fil:| ";
		char Alert2B[] = "][HOPPA|IGEN|AVBRYT]";

		char Alert3[] = "[3][| |  Katastrofalt filfel!][HOPPA|IGEN|AVBRYT]";

		char Alert4A[] = "[1][ Det finns inte plats f”r| ";
		char Alert4B[] = " nu.| G”r en omstart om du vill| l„sa in den.][ OK ]";
		
		char *exit_text[] = {
				      "AVBRYT",
				      "OK"
				    }; 
#endif


 
 
 /* btext is for those with only 1 button.
  * TRUE - use OK
  * FALSE - use Cancel
  */
  
struct alert
{
    char text1[17];
    char text2[17];
    char text3[17];
    int  num_buttons;
    BOOLEAN  btext;
}ALERT[] = { 

#if USA | UK  
  	     { " Save Defaults?", "", "", 2, FALSE },
	     { "  Memory", "  Allocation", "  Error!", 1, FALSE },
	     { "  File I/O", "  Error!", "", 1, FALSE },
	     { "  File Not", "  Found!", "", 1, FALSE },
	     { " Unable to load", " any more CPXs", " at this time.", 1, FALSE },
	     { "  Reload CPXs?" , "", "", 2, FALSE },
	     { "  Unload the"   , "  current CPX?", "", 2, FALSE },
	     { "  Resident CPXs" , "  cannot be", "  unloaded!", 1, TRUE },
	     { " Save the CPX", " configuration?", "", 2, FALSE },
	     { "File Not a CPX.", "Write Cancelled.", "", 1, TRUE },
	     { " Stereo Sound", "    Is Not", "   Available.", 1, TRUE },
	     { " Shutdown the", " Control Panel?", "", 2, FALSE }
#endif


#if ITALY
  	     { "  Salvo i", "  parametri?", "", 2, FALSE },
	     { "  Errore di", "  allocazione", "  in memoria!", 1, FALSE },
/*	     { "    Errore", "    di I/O!", "", 1, FALSE },*/
	     { " ", " Errore di I/O!","", 1, FALSE },
/*	     { "   File non", "   trovato!", "", 1, FALSE },*/
	     { "", "File non trovato!", "", 1, FALSE },
	     { "Non possono", "essere caricati", "altri CPX.", 1, FALSE },
	     { " " , " Ricarico i CPX?", "", 2, FALSE },
	     { " Rimuovo il"   , " CPX corrente?", "", 2, FALSE },
	     { " I CPX residenti" , " non possono", " essere rimossi!", 1, TRUE },
	     { " Salvo la", " configurazione", " dei file CPX?", 2, FALSE },
	     { "  File non CPX.", "  Scrittura", "  annullata.", 1, TRUE },
	     { " Audio stereo", "non disponibile.", "", 1, TRUE },
	     { " Disattivo il", " Pannello di", " Controllo?", 2, FALSE }
#endif

#if GERMAN
  	     { "Voreinstellungen", "sichern?", "", 2, FALSE },
	     { " Fehler bei", " Speicheran-", " forderung!", 1, FALSE },
	     { "Fehler beim", "Schreiben/Lesen", "von Dateien!", 1, FALSE },
	     { " Datei nicht", " gefunden!", "", 1, FALSE },
	     { "Zur Zeit k”nnen", "nicht mehr CPX", "geladen werden!", 1, FALSE },
	     { " CPX neu laden?" , "", "", 2, FALSE },
	     { " CPX entfernen?" , "", "", 2, FALSE },
	     { " Residente CPX" , " k”nnen nicht", " entfernt werden!", 1, TRUE },
	     { "CPX-Konfigura-", "tion sichern?", "", 2, FALSE },
	     { "Datei ist kein", "CPX. Schreiben", "abgebrochen!", 1, TRUE },
	     { " Stereo-Sound", " nicht m”glich!", "", 1, TRUE },
	     { " Kontrollfeld", " abschalten?", "", 2, FALSE }
#endif

#if FRENCH
  	     { " Sauve la", " Configuration?", "", 2, FALSE },
	     { " Erreur", " d'allocation", " m‚moire!", 1, FALSE },
	     { "Erreur en", "entr‚e/sortie", "sur un fichier!", 1, FALSE },
	     { " Fichier", " Non trouv‚!", "", 1, FALSE },
	     { " Impossible", " de charger", " plus de CPXs.", 1, FALSE },
	     { " Recharge CPXs?" , "", "", 2, FALSE },
	     { " Effacer le"   , " CPX en cours?", "", 2, FALSE },
	     { "Un CPX r‚sident" , "ne peut pas", "ˆtre effac‚!", 1, TRUE },
	     { "Sauver la", "configuration?", "", 2, FALSE },
	     { "Le fichier n'est", "pas de type CPX.", "", 1, TRUE },
	     { " Le son st‚r‚o", " n'est pas", " disponible.", 1, TRUE },
	     { " Fermer", " le panneau", " de contr“le?", 2, FALSE }
#endif

#if SPAIN
  	     { "\250Grabar valores", "por defecto?", "", 2, FALSE },
	     { " \255Error de", " ubicaci¢n de", " memoria!", 1, FALSE },
	     { " \255Error en", " fichero E/S!", "", 1, FALSE },
	     { " \255Fichero no", " encontrado!", "", 1, FALSE },
	     { "No puede cargar", "m s CPXs en", "este momento.", 1, FALSE },
	     { " \250Cargar CPXs?" , "", "", 2, FALSE },
	     { " \250Quitar el"   , " CPX actual?", "", 2, FALSE },
	     { "\255No es posible" , "quitar los CPXs", "residentes!", 1, TRUE },
	     { " \250Grabar la", " Configuraci¢n", " del CPX?", 2, FALSE },
	     { "Fichero no CPX.", "Escritura", "cancelada.", 1, TRUE },
	     { "Sonido Est‚reo", "no disponible.", "", 1, TRUE },
	     { " \250Suprimir", " el Panel", " de Control?", 2, FALSE }
#endif


#if SWEDEN
  	     { "", " Spara f”rval?", "", 2, FALSE },
	     { "", "Fel vid minnes-", "tilldelning!", 1, FALSE },
	     { " Fel vid", " filoperation!", "", 1, FALSE },
	     { "","Filen ej funnen!", "", 1, FALSE },
	     { "Kan ej l„sa in", "fler CPXer f”r", "tillf„llet.", 1, FALSE },
	     { " L„s in CPXer" , " p\206 nytt?", "", 2, FALSE },
	     { " Ta bort", " aktuell CPX?", "", 2, FALSE },
	     { " Permanenta" , " CPXer kan ej", " tas bort!", 1, TRUE },
	     { " Spara CPX-", " inst„llningar?", "", 2, FALSE },
	     { "Filen „r ej en", "CPX. Skrivning", "avbruten.", 1, TRUE },
	     { " Stereoljud ej", " tillg„ngligt.", "", 1, TRUE },
	     { " St„nga av", " kontrollpanelen?", "", 2, FALSE }
#endif
	   };




/* FUNCTIONS
 *==========================================================================
 */
 


/* XGen_Alert()
 *==========================================================================
 * General Form Alert for XCONTROL.ACC
 * The alert requested can be chosen from group shown up above.
 */
BOOLEAN
cdecl XGen_Alert( int id )
{
     OBJECT *tree;
     GRECT  rect;
     int    button;
     GRECT  xrect;
     static BOOLEAN used_flag = FALSE;

     MFsave( MFSAVE, &mfAlert );
     graf_mouse( ARROW, 0L );
     if( !used_flag )
     {
        Fix_As_Dialog = TRUE;
        fix_rsh( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE, as_object,
                 as_tedinfo, as_strings, as_iconblk, as_bitblk, as_frstr,
                 as_frimg, as_trindex, as_imdope );
     }   
     used_flag = TRUE;
     
     
     tree = ( OBJECT *)as_trindex[ ALERTS ];     
     rect = ObRect( ROOT );
     ObX( ROOT ) =  rect.g_x = (( w.work.g_w - rect.g_w ) / 2 )+w.work.g_x;
     ObY( ROOT ) =  rect.g_y = (( w.work.g_h - rect.g_h ) / 2 )+w.work.g_y;
  
     xrect.g_x = ( rect.g_x -= 3 ) - 1;
     xrect.g_y = ( rect.g_y -= 3 ) - 1;
     xrect.g_w = ( rect.g_w += 6 ) + 2;
     xrect.g_h = ( rect.g_h += 6 ) + 2;

     blit_alert( &xrect, FALSE );
     
     HideObj( AOK1 );
     HideObj( AOK2 );
     HideObj( ACANCEL );
     
     ObString( ALERT1 ) = &ALERT[ id ].text1[0];
     ObString( ALERT2 ) = &ALERT[ id ].text2[0];
     ObString( ALERT3 ) = &ALERT[ id ].text3[0];
     
     if( ALERT[ id ].num_buttons == 2 )
     {
         ShowObj( AOK1 );
         ShowObj( ACANCEL );
         ObString( AOK1 ) = exit_text[ TRUE ];
         ObString( ACANCEL ) = exit_text[ FALSE ];
     }
     else
     {
	 ShowObj( AOK2 );
	 ObString( AOK2 ) = exit_text[ ALERT[ id ].btext ];
     }
     Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
     button = form_do( tree, 0 );
     SetNormal( button );
     

     blit_alert( &xrect, TRUE );
     MFsave( MFRESTORE, &mfAlert );
     return( ( ( button == AOK1 ) || ( button == AOK2 ) ) );
}



/* blit_alert()
 *==========================================================================
 * Blits the rectangle TO/FROM the AES menu/alert buffer
 * 
 * IN: GRECT *rect:	rectangle to blit TO/FROM on the screen
 *     BOOLEAN flag:	FALSE = Blit screen to buffer
 *			TRUE  = Blit buffer to screen
 *
 * OUT void
 */
void
blit_alert( GRECT *rect, BOOLEAN flag )
{
   int   pxy[8];
   MFDB  alert_mfdb;
   long  *alert_buffer;
   long  location = 0L;

   open_vwork();

   rc_intersect( &desk, rect );
   rc_2xy( rect, ( WORD *)&pxy[0] );
   vs_clip( vhandle, 1, pxy );

   
   Wind_get( 0, WF_SCREEN, ( WARGS *)&alert_buffer );   

   alert_mfdb.fd_addr	 = alert_buffer;
   alert_mfdb.fd_w 	 = rect->g_w;
   alert_mfdb.fd_h	 = rect->g_h;
   alert_mfdb.fd_wdwidth = (rect->g_w + 15)/16;
   alert_mfdb.fd_stand   = 0;
   alert_mfdb.fd_nplanes = nplanes;
   alert_mfdb.fd_r1	 = alert_mfdb.fd_r2 = alert_mfdb.fd_r3 = 0;
   
   graf_mouse( M_OFF, 0L );
   if( !flag )			/* blit screen to buffer */
   {
       rc_2xy( rect, ( WORD *)&pxy[0] );
       pxy[4] = pxy[5] = 0;
       pxy[6] = rect->g_w - 1;
       pxy[7] = rect->g_h - 1;
       vro_cpyfm( vhandle, 3, pxy, ( MFDB *)&location , &alert_mfdb );
   }
   else				/* buffer to screen */
   {
       pxy[0] = pxy[1] = 0;
       pxy[2] = rect->g_w - 1;
       pxy[3] = rect->g_h - 1;
       rc_2xy( rect, ( WORD *)&pxy[4] );
       vro_cpyfm( vhandle, 3, pxy, &alert_mfdb, ( MFDB *)&location );
   }
   graf_mouse( M_ON, 0L );

   close_vwork();
}
