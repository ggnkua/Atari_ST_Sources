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
#include "xcontrol.h"


/* PROTOTYPES
 *==========================================================================
 */

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
		char Alert5[] = "[1][ | There is not enough | memory to load the | CPX. ][ OK ]";
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
		char Alert5[] = "[1][ | There is not enough | memory to load the | CPX. ][ OK ]";

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
		char Alert5[] = "[1][ | There is not enough | memory to load the | CPX. ][ OK ]";
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
/*				    
		char Alert5[] = "[1][ | There is not enough | memory to load the | CPX. ][ CONFIRME ]";
 */
		char Alert5[] = "[1][ | Il n'y a pas assez | de m‚moire pour charger | le CPX. ][ CONFIRMER ]";
 
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
		char Alert5[] = "[1][ | There is not enough | memory to load the | CPX. ][CONFIRMAR]";
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
		char Alert5[] = "[1][ | There is not enough | memory to load the | CPX. ][ OK ]";
#endif


 
 

char *ALERT[] = {

#if USA | UK  
  	     "[1][ | Save Defaults?][ OK | Cancel ]",
	     "[1][ |  Memory    |  Allocation  |  Error!][ OK ]",
	     "[1][ |  File I/O  |  Error!][ OK ]",
	     "[1][ |  File Not  |  Found!][ OK ]",
	     "[1][ | Unable to load  | any more CPXs| at this time.][ OK ]",
	     "[1][ |  Reload CPXs?    ][ OK | Cancel ]",
	     "[1][ |  Unload the|  current CPX?][ OK | Cancel ]",
	     "[1][ |  Resident CPXs   |  cannot be|  unloaded!][ OK ]",
	     "[1][ | Save the CPX| configuration?][ OK | Cancel ]",
	     "[1][ | File Not a CPX. | Write Cancelled.][ OK ]",
	     "[1][ | Stereo Sound   |    Is Not|  Available.][ OK ]",
	     "[1][ | Shutdown the | Control Panel?][ OK | Cancel ]"
#endif


#if ITALY
  	     "[1][ |  Salvo i parametri? ][ OK | Annulla ]",
	     "[1][ |  Errore di   |  allocazione   |  in memoria!   ][ OK ]",
	     "[1][ | Errore di I/O! ][ OK ]",
	     "[1][ | File non trovato! ][ OK ]",
	     "[1][ | Non possono | essere caricati | altri CPX. ][ OK ]",
	     "[1][ | Ricarico i CPX? ][ OK | Annulla ]",
	     "[1][ | Rimuovo il CPX | corrente? ][ OK | Annulla ]",
	     "[1][ | I CPX residenti   | non possono   | essere rimossi!   ][ OK ]",
	     "[1][ | Salvo la | configurazione | dei file CPX? ][ OK | Annulla ]",
	     "[1][ |  File non CPX.  |  Scrittura  |  annullata.  ][ OK ]",
	     "[1][ | Audio stereo non | disponibile. ][ OK ]",
	     "[1][ | Disattivo il Pannello | di Controllo? ][ OK | Annulla ]"
#endif

#if GERMAN
  	     "[1][ | Voreinstellungen | sichern? ][ OK | Abbruch ]",
	     "[1][ | Fehler bei    | Speicheran-   | forderung!    ][ OK ]",
	     "[1][ | Fehler beim | Schreiben/Lesen | von Dateien! ][ OK ]",
	     "[1][ | Datei nicht  | gefunden!   ][ OK ]",
	     "[1][ | Zur Zeit k”nnen  | nicht mehr CPX  | geladen werden!  ][ OK ]",
	     "[1][ | CPX neu laden? ][ OK | Abbruch ]",
	     "[1][ | CPX entfernen? ][ OK | Abbruch ]",
	     "[1][ | Residente CPX  | k”nnen nicht  | entfernt werden!  ][ OK ]",
	     "[1][ | CPX-Konfiguration | sichern? ][ OK | Abbruch ]",
	     "[1][ | Datei ist kein  | CPX. Schreiben  | abgebrochen!  ][ OK ]",
	     "[1][ | Stereo-Sound  | nicht m”glich!  ][ OK ]",
	     "[1][ | Kontrollfeld | abschalten? ][ OK | Abbruch ]"
#endif

#if FRENCH
  	     "[1][ | Sauve la| Configuration? ][ CONFIRME | Annule ]",
	     "[1][ | Erreur| d'allocation   | m‚moire! ][ CONFIRME ]",
	     "[1][ | Erreur en| entr‚e/sortie | sur un fichier! ][ CONFIRME ]",
	     "[1][ | Fichier | Non trouv‚!   ][ CONFIRME ]",
	     "[1][ | Impossible | de charger | plus de CPXs. ][ CONFIRME ]",
	     "[1][ | Recharge CPXs?   ][ CONFIRME | Annule ]",
	     "[1][ | Effacer le CPX | en cours? ][ CONFIRME | Annule ]",
	     "[1][ | Un CPX r‚sident | ne peut pas | ˆtre effac‚!   ][ CONFIRME ]",
	     "[1][ | Sauver la | configuration? ][ CONFIRME | Annule ]",
	     "[1][ | Le fichier n'est | pas de type CPX. ][ CONFIRME ]",
	     "[1][ | Le son st‚r‚o | n'est pas | disponible. ][ CONFIRME ]",
	     "[1][ | Fermer le panneau | de contr“le? ][ CONFIRME | Annule ]"
#endif

#if SPAIN
  	     "[1][ | \250Grabar valores por | defecto?   ][CONFIRMAR| Anular ]",
	     "[1][ | \255Error de     | ubicaci¢n de    | memoria!   ][ CONFIRMAR ]",
	     "[1][ | \255Error en  | fichero E/S!   ][ CONFIRMAR ]",
	     "[1][ | \255Fichero no   | encontrado! ][ CONFIRMAR ]",
	     "[1][ | No puede cargar   | m s CPXs en   | este momento. ][ CONFIRMAR ]",
	     "[1][ | \250Cargar CPXs? ][CONFIRMAR| Anular ]",
	     "[1][ | \250Quitar el CPX actual?   ][CONFIRMAR| Anular ]",
	     "[1][ | \255No es posible   | quitar los CPXs   | residentes!   ][ CONFIRMAR ]",
	     "[1][ | \250Grabar la Configuraci¢n | del CPX?   ][CONFIRMAR| Anular ]",
	     "[1][ | Fichero no CPX.| Escritura cancelada. ][ CONFIRMAR ]",
	     "[1][ | Sonido Est‚reo  | no disponible.   ][ CONFIRMAR ]",
	     "[1][ | \250Suprimir el Panel | de Control?   ][CONFIRMAR| Anular ]"
#endif


#if SWEDEN
  	     "[1][ | Spara f”rval? ][ OK | AVBRYT ]",
	     "[1][ | Fel vid minnes-  | tilldelning! ][ OK ]",
	     "[1][ | Fel vid | filoperation! ][ OK ]",
	     "[1][ | Filen ej funnen! ][ OK ]",
	     "[1][ | Kan ej l„sa in   | fler CPXer f”r   | tillf„llet. ][ OK ]",
	     "[1][ | L„s in CPXer p\206 nytt? ][ OK | AVBRYT ]",
	     "[1][ | Ta bort aktuell CPX? ][ OK | AVBRYT ]",
	     "[1][ | Permanenta CPXer | kan ej tas bort! ][ OK ]",
	     "[1][ | Spara CPX- | inst„llningar? ][ OK | AVBRYT ]",
	     "[1][ | Filen „r ej en   | CPX. Skrivning   | avbruten. ][ OK ]",
	     "[1][ | Stereoljud ej   | tillg„ngligt.   ][ OK ]",
	     "[1][ | St„nga av | kontrollpanelen? ][ OK | AVBRYT ]"
#endif
	   };




/* FUNCTIONS
 *==========================================================================
 */
 

/* XGen_Alert()
 *==========================================================================
 * General Form Alert for XCONTROL.ACC
 * The alert requested can be chosen from group shown up above.
 * RETURN - TRUE- CLICKED OK
 *	    FALSE - Clicked FALSE;
 */
BOOLEAN
cdecl XGen_Alert( int id )
{
    int button;

    button = form_alert( 1, ALERT[ id ] );
    return( button == 1 );
}

