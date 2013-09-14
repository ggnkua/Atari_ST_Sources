/*==========================================================================
 * FILE: SAMPLE.C
 *==========================================================================
 * DATE: February 11, 1990
 * DESCRIPTION: Sample CPX at its new size
 */
 

/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>

#include "alerts.h"
#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "alerts.rsh"
#pragma warn .apt
#pragma warn .rpt
#include "..\cpxdata.h"


/* PROTOTYPES
 *==========================================================================
 */
CPXINFO *cdecl cpx_init( XCPB *Xcpb );
BOOLEAN cdecl cpx_call( GRECT *rect );
	
	
/* DEFINES
 *==========================================================================
 */

#define USA	0			/* United States of Amerika */
#define FRG	1			/* Federal Republic of Germany */
#define FRA	2			/* Gaul aka France */
#define UK	3			/* United Kingdom */
#define SPA	4			/* Spain */
#define ITA	5			/* Italia */
#define SWE	6			/* Sweden */


/* USA | UK*/
		char Alert0[] = "[1][ The Control Panel has | been Shutdown. Please | Reboot to Restart the | Control Panel. ][Exit]";

		char Alert1[] = "[3][| Name Conflict!| Destination: %S| This file already exists!][COPY|Skip|Cancel]";

		char Alert2[] = "[3][| Source File Not Found!| Source: %S][SKIP|Retry|Cancel]";

		char Alert3[] = "[3][ | | Critical File Error! ][SKIP|Retry|Cancel]";

		char Alert4[] = "[1][ %S is too| large to load now.| Reboot if you want| to load it.][ OK ]";


/* ITALY  */
		char Blert0[] = "[1][|Il Pannello di Controllo non Š|pi— attivo. Riavvia il sistema|per attivare il Pannello|di Controllo.][Esci]";

		char Blert1[] = "[3][| Conflitto sul nome!| Destinazione: %S| Questo file esiste gi…!][COPIA|Salta|Annulla]";

		char Blert2[] = "[3][|File sorgente non trovato!|Sorgente: %S][SALTA|Riprova|Annulla]";

		char Blert3[] = "[3][| |      Errore nel file!][SALTA|Riprova|Annulla]";

		char Blert4[] = "[1][| %S ‚ troppo| grande per essere caricato| ora. Riavvia il sistema se| vuoi caricarlo.][ OK ]";


/* GERMAN  */
		char Clert0[] = "[1][ Das Kontrollfeld wurde| abgeschaltet.  Bitte neu| booten um das Kontroll-| feld zu reaktivieren.][Ausgang]";
				
		char Clert1[] = "[3][| Namenskonflikt!| Ziel: %S| Diese Datei existiert beneits!][Kopieren|Weiter|Abbruch]";

		char Clert2[] = "[3][| Quelldatei nicht gefunden!| Quelle: %S][Weiter|Nochmal|Abbruch]";

		char Clert3[] = "[3][ | | Kritischer Dateifehler!][Weiter|Nochmal|Abbruch]";

		char Clert4[] = "[1][ %S ben”tigt| mehr Speicher um gestartet| zu werden. Zum Starten| bitte neu booten.][ OK ]";


/* FRENCH */
		char Dlert0[] = "[1][ Le panneau de contr“le a| ‚t‚ verrouill‚. Veuillez| red‚marrer le systŠme pour| valider de nouveau le| panneau de contr“le.][ CONFIRME ]";

		char Dlert1[] = "[3][| Conflit de noms!| Destination: %S| Ce fichier existe d‚j…!][COPIE|Suivant|Annule]";

		char Dlert2[] = "[3][| Fichier source non trouv‚!| Source: %S][SUIVANT|R‚essayer|Annule]";

		char Dlert3[] = "[3][| |   Erreur fatale sur fichier!][SUIVANT|R‚essayer|Annule]";

		char Dlert4[] = "[1][ %S est trop| important pour ˆtre utilis‚.| Red‚marrez le systŠme| pour le mettre en m‚moire.][ CONFIRME ]";


/* SPAIN  */
		char Elert0[] = "[1][ El Panel de Control| ha sido suprimido.| Arranque de nuevo| para Instalarlo.][Salir]";
		
		char Elert1[] = "[3][| \255Nombre Conflictivo!| Destino: %S| \255Este fichero ya Existe!][COPIAR|Omitir|Anular]";

		char Elert2[] = "[3][| \255No encuentro fichero fuente!| Fuente: %S][Omitir|Reintentar|Anular]";

		char Elert3[] = "[3][| |    \255Error critico en fichero!][Omitir|Reintentar|Anular]";

		char Elert4[] = "[1][%S es demasiado|grande para cargarlo en|este momento. Arranque de|nuevo si quiere cargarlo.][ OK ]"; 

/* SWEDEN */
		char Flert0[] = "[1][ Kontrollpanelen har| st„ngts av. Starta om| datorn f”r aktivera| kontrollpanelen igen.][OK]";

		char Flert1[] = "[3][| Namnkonflikt!| %S| finns redan.][KOPIERA|Hoppa|Avbryt]";

		char Flert2[] = "[3][| Kan ej ”ppna fil:| %S][HOPPA|Igen|Avbryt]";

		char Flert3[] = "[3][| |  Katastrofalt filfel!][HOPPA|Igen|Avbryt]";

		char Flert4[] = "[1][ Det finns inte plats f”r| %S nu.| G”r en omstart om du vill| l„sa in den.][ OK ]";
		




 

/* EXTERNALS
 *==========================================================================
 */

/* GLOBALS
 *==========================================================================
 */
XCPB *xcpb;
CPXINFO cpxinfo;


/* FUNCTIONS
 *==========================================================================
 */
		
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    xcpb = Xcpb;
    if( xcpb->booting )
    {
      /* Read in defaults and set the options */
      return( ( CPXINFO *)TRUE );  
    }
    else
    {    
      if( !xcpb->SkipRshFix )
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                            rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                            rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                            rs_imdope );
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = NULL;
      cpxinfo.cpx_wmove  = NULL;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = NULL;
      cpxinfo.cpx_button = NULL;
      cpxinfo.cpx_m1 	 = NULL;
      cpxinfo.cpx_m2	 = NULL;
      cpxinfo.cpx_hook   = NULL;
      cpxinfo.cpx_close  = NULL;



      return( &cpxinfo );
    }
}





BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     OBJECT *tree  = (OBJECT *)rs_trindex[ SAMPLE ];

     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;
               
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );

     (*xcpb->XGen_Alert)(0);
     (*xcpb->XGen_Alert)(1);
     (*xcpb->XGen_Alert)(2);
     (*xcpb->XGen_Alert)(3);
     (*xcpb->XGen_Alert)(4);
     (*xcpb->XGen_Alert)(5);
     (*xcpb->XGen_Alert)(6);
     (*xcpb->XGen_Alert)(7);
     (*xcpb->XGen_Alert)(8);
     (*xcpb->XGen_Alert)(9);
     (*xcpb->XGen_Alert)(10);	
     (*xcpb->XGen_Alert)(11);	

     switch( xcpb->Country_Code )
     {
        case UK:
        case USA:  form_alert( 1, Alert0 );
        	   form_alert( 1, Alert1 );
        	   form_alert( 1, Alert2 );
        	   form_alert( 1, Alert3 );
        	   form_alert( 1, Alert4 );
        	   break;
        	   
        case FRG:  form_alert( 1, Clert0 );
        	   form_alert( 1, Clert1 );
        	   form_alert( 1, Clert2 );
        	   form_alert( 1, Clert3 );
        	   form_alert( 1, Clert4 );
        	   break;
        	   
        case FRA:  form_alert( 1, Dlert0 );
        	   form_alert( 1, Dlert1 );
        	   form_alert( 1, Dlert2 );
        	   form_alert( 1, Dlert3 );
        	   form_alert( 1, Dlert4 );
        	   break;
        	   
        case SPA:  form_alert( 1, Elert0 );
                   form_alert( 1, Elert1 );
                   form_alert( 1, Elert2 );
                   form_alert( 1, Elert3 );
        	   form_alert( 1, Elert4 );
        	   break;
        	   
        case ITA:  form_alert( 1, Blert0 );
        	   form_alert( 1, Blert1 );
        	   form_alert( 1, Blert2 );
        	   form_alert( 1, Blert3 );
        	   form_alert( 1, Blert4 );
        	   break;
        	   
        case SWE:  form_alert( 1, Flert0 );
        	   form_alert( 1, Flert1 );
        	   form_alert( 1, Flert2 );
        	   form_alert( 1, Flert3 );
        	   form_alert( 1, Flert4 );
        	   break;
     }     
     return( FALSE );
}
