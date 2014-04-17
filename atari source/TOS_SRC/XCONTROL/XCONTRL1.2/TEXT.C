/* TEXT.C
 *==========================================================================
 * DATE: April 3, 1990
 * Text Strings for XCONTROL
 * INCLUDE FILE: TEXT.H
 * 
 * DESCRIPTION: Below are the text strings from the approriate files.
 *		The files must now include text.h
 *		The ALERT TEXT STRINGS remain in XERROR.C
 *		PLUS, when making a foreign version, don't forget to
 *		change the country flag in COUNTRY.H
 */

/* INCLUDE FILES
 *==========================================================================
 */ 
#include "country.h"


/* PROTOTYPES
 *==========================================================================
 */


/* GLOBALS
 *==========================================================================
 */
 

/* XERROR.C
 *==========================================================================
 * ALERT Text will remain IN XERROR.C
 */


/* XOPTIONS.C
 *==========================================================================
 * Function: xopt_option()
 * 12/24 Hour Toggle - for US | UK | SPAIN | FRENCH
 */
 


/* COUNTRY TRANSLATIONS
 *==========================================================================
 */



/* COUNTRY: USA | UK
 *==========================================================================
 */    
#if USA | UK

  /* WINDOWS.C */
  char 	Menu_Text[] = "  Control Panel";	/* ACC menu text!	*/
  char	Wind_Text[] = " CONTROL PANEL ";	/* Window text		*/
  
  /* XCONFIG.C */
  int  XOPT_WIDTH = 17;				/* xconfig_string width */
  char *xconfig_string[5];

  char *First_String[] = { "About...",
  			   "Setup...",
  			   "Shutdown..."
  			 };
  			 
  char *Second_String[] = { "About...",
  			    "Setup...",
  			    "Open CPX...",
  			    "CPX Info...",
  			    "Unload CPX..."
  			  };  			 
  			 
  /* XOPTIONS.C */
  char title[] = "CPX Directory Path";
  char *stat_string[] = {			/* text for cpx status */
			  "No",
			  "Yes"
		        };
  
  char *slit_text[] = { "                 ",
  		        " Activate CPX(s) ",
  		        "Deactivate CPX(s)"
  		      };

  /* TIMEDATE.C */
  char *hour_string[] = {
		          "12 Hour",
			  "24 Hour"
		        };
#endif



/* COUNTRY: ITALY
 *==========================================================================
 */
#if ITALY

  /* WINDOWS.C */
  char 	Menu_Text[] = "  Control Panel"; 	 /* ACC menu text!	*/
  char	Wind_Text[] = " PANNELLO DI CONTROLLO "; /* Window text		*/

  int  XOPT_WIDTH = 21;				/* xconfig_string width */
  char *xconfig_string[5];
  char *First_String[] = { "Informazioni...",
			   "Installazione...",
			   "Disattivazione..."
			 };

  char *Second_String[] = { "Informazioni...",
  			    "Installazione...",
  			    "Apri CPX...",
  			    "Info CPX...",
  			    "Rimuovi CPX..."
  			  };  			 
  			 


  /* XOPTIONS.C */
  char title[] = "Percorso file CPX";
  char *stat_string[] = {			/* text for cpx status */
			  "No",
			  "Si"
		        };

  char *slit_text[] = { "                 ",
  		        "    Attivo CPX   ",
  		        "  Disattivo CPX  "
  		      };


  /* TIMEDATE.C */
  char *hour_string[] = {
		          "12 Ore",
			  "24 Ore"
		        };
#endif




/* COUNTRY: GERMAN
 *==========================================================================
 */
#if GERMAN

  /* WINDOWS.C */
  char 	Menu_Text[] = "  Kontrollfeld";		/* ACC menu text!	*/
  char	Wind_Text[] = " KONTROLLFELD ";		/* Window text		*/

  /* XCONFIG.C */
  int  XOPT_WIDTH = 21;				/* xconfig_string width */
  char *xconfig_string[5];

  char *First_String[] = { "Info...",
  			   "Voreinstellung...",
  			   "Abschalten..."
  			 };

  char *Second_String[] = { "Info...",
			    "Voreinstellung...",
			    "™ffne CPX...",
			    "CPX Info...",
			    "Entferne CPX..."
			  };
			   

  /* XOPTIONS.C */
  char title[] = "CPX Verzeichnispfad";
  char *stat_string[] = {			/* text for cpx status */
			  "Nein",
			  "Ja"
		        };
 
   char *slit_text[] = { "                 ",
  		         "  CPX Aktivieren ",
  		         "CPX Deaktivieren "
  		      };
 
  /* TIMEDATE.C */
  char *hour_string[] = {
		          "12 Hour",
			  "24 Hour"
		        };
#endif



/* COUNTRY : FRENCH
 *==========================================================================
 */
#if FRENCH

  /* WINDOWS.C */
  char 	Menu_Text[] = "  Panneau Contr“le";	/* ACC menu text!	*/
  char	Wind_Text[] = " PANNEAU DE CONTROLE ";	/* Window text		*/

  /* XCONFIG.C */
  int XOPT_WIDTH = 20;				/* xconfig_string width */
  char *xconfig_string[5];
  
  char *First_String[]  = {  "Informations...",
  			     "Configuration...",
  			     "Verrouiller..."
  			  };
  			  
  char *Second_String[] = {  "Informations...",
			     "Configuration...",
			     "Ouvrir CPX...",
			     "Info CPX...",
			     "Efface CPX..."
			   };

  /* XOPTIONS.C */
  char title[] = "R‚pertoire des CPX";
  char *stat_string[] = {			/* text for cpx status */
			  "Non",
			  "Oui"
		        };


  char *slit_text[] = { "                 ",
  		        "   Active CPX(s) ",
  		        " D‚sactive CPX(s)"
  		      };


  /* TIMEDATE.C */
  char *hour_string[] = {
			  "12 Heures",
			  "24 Heures"
		        };
#endif



/* COUNTRY: SPAIN
 *==========================================================================
 */
#if SPAIN

  /* WINDOWS.C */
  char 	Menu_Text[] = "  Panel de Control";	/* ACC menu text!	*/
  char	Wind_Text[] = " PANEL DE CONTROL ";	/* Window text		*/

  /* XCONFIG.C */
  int XOPT_WIDTH = 18;				/* xconfig_string width */
  char *xconfig_string[5];
  
  char *First_String[]  = {  "Informaci¢n...",
			     "Setup...",
			     "Suprimir..."
  			  };
  			  
  char *Second_String[] = {  "Informaci¢n...",
			     "Setup...",
			     "Abrir CPX...",
			     "Info CPX...",
			     "Quitar CPX..."
			   };

  /* XOPTIONS.C */			   
  char title[] = "Path Directorio CPX";
  char *stat_string[] = {			/* text for cpx status */
			  "No",
			  "Si"
		        };


  char *slit_text[] = { "                 ",
  		        "  Activar CPX(s) ",
  		        "Desactivar CPX(s)"
  		      };

  /* TIMEDATE.C */
  char *hour_string[] = {
			  "12 Horas",
			  "24 Horas"
		        };
#endif






/* COUNTRY: SWEDEN
 *==========================================================================
 */
#if SWEDEN

  /* WINDOWS.C */
  char 	Menu_Text[] = "  Kontrollpanel";	/* ACC menu text!	*/
  char	Wind_Text[] = " KONTROLLPANEL ";	/* Window text		*/

  /* XCONFIG.C */
  int  XOPT_WIDTH = 19;				/* xconfig_string width */
  char *xconfig_string[5];
  
  char *First_String[] = {   "Info...",
  			     "Inst„llningar...",
  			     "St„ng av..."
  			 };
  			 
  			 
  char *Second_String[] =  { "Info...",
	  		     "Inst„llningar...",
			     "™ppna CPX...",
			     "Info om CPX...",
			     "Ta bort CPX..."
			   };
  
  /* XOPTIONS.C */
  char title[] = "S”kv„g f”r CPX";
  char *stat_string[] = {			/* text for cpx status */
			  "Nej",
			  "Ja"
		        };
  

  char *slit_text[] = { "                  ",
  		        " Aktivera CPX(er) ",
  		        "Deaktivera CPX(er)"
  		      };

  /* TIMEDATE.C */
  char *hour_string[] = {
		          "12 Hour",
			  "24 Hour"
		        };
#endif



