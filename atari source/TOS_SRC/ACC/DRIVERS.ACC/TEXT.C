/*==========================================================================
 * FILE: TEXT.C
 *==========================================================================
 * DATE: November 20, 1992
 *
 * DESCRIPTION: Country Specific Text Strings
 * COMPILER: TURBO C Version 2.0
 */
#include "country.h"

char notice1[] = "GDOS Devices Accessory by CJG";
char notice2[] = "Copyright (c) 1992 - 1993 Atari Corporation";

 
#if USA
char menu_title[] = "  Printer Drivers ";
char alert13[] = "[1][The GEM Desktop has no more|windows. Please close a|window that you are not|using.][ OK ]";
char driver_null[] = "None Selected              ";	/* Text if there is no device 21 active    */
char window_title[] = " Printer Drivers ";
char alert56[]= "[1][ | Remove the Printer Driver? ][OK|Cancel]";
char alert1[] = "[1][ | Remove the Selected Device? ][OK|Cancel]";
char alert2[] = "[1][ | Add a new device? ][OK|Cancel]";
char alert3[] = "[3][Error reading!][ OK ]";
char alert4[] = "[1][ | There is not enough | memory to read the | ASSIGN.SYS file. ][ OK ]";
char alert5[] = "[3][ | Cannot open ASSIGN.SYS. ][ OK ]";
char alert6[] = "[3][ | Error opening the | ASSIGN.SYS file. The | operation is cancelled.][ OK ]";
char alert7[] = "[1][ | There is no more room | for any more devices. ][ OK ]";

char data_null[] =    "Unknown          ";
char *page_data[] = { "Letter  ",
		      "Legal   ",
		      "A4      ",
		      "B5      ",
		      "Other   "
		    };


char alert10[] = "[1][ | Save the device drivers? ][OK|Cancel]";
char alert12[] = "[1][ |The device drivers have |been changed. Save the|changes? ][OK|Cancel]";

char head1[] = ";> ASSIGN.SYS Created with DRIVERS.ACC Copyright 1992 - 1993 Atari Corp.\r\n";
char head2[] = ";> For use with GDOS 1.1 and higher.\r\n";
char head3[] = ";> Last modified on %d/%d/%d %02d:%02d\r\n";	             

char *print_text[] = {
		      "Draft    ",
		      "Final",
		      "Draft",
		      "Final"
		     };


char *size_text[] = {
		      "Letter   ",
		      "Legal",
		      "A4",
		      "B5",
		      "Other~2",
		      "Letter",
		      "Legal",
		      "A4",
		      "B5",
		      "Other"
		    };

char *rez_text[] = {
		    "                   ",
		    "                   "
		   };

char rez_width[] = "Width: %2.1f inches";
char rez_height[] = "Height: %2.1f inches";

char rez2_width[] = "Width: %2.2f cm";
char rez2_height[] = "Height: %2.2f cm";

char xy1_unit[] = "Units: Inches";
char xy2_unit[] = "Units: Centimeters";

char *color_text[] = {
			"B/W",
			"4 Colors",
			"8 Colors",
			"16 Colors"
		     };

char *port_text[] = {
			"Printer  ",
			"Modem",
			"Printer",
			"Modem"
		    };
		    

char *tray_text[] = {
			"Tractor  ",
			"Tray 1",
			"Tray 2",
			"Manual",
			"Tractor",
			"Tray 1",
			"Tray 2",
			"Manual"
		    };		    		     

char alert50[] = "[1][ | Save the Driver? ][ OK | Cancel ]";
char NoDrivers[]  = "No Speedo Drivers Found";
char YesDrivers[] = "Select Drivers";

char alert51[] = "[1][ | | File I/O Error ][ OK ]";
char alert52[] = "[1][ | File Load Error!| The operation is | cancelled. ][ OK ]";
char alert53[] = "[1][ | This driver is not | a SpeedoGDOS driver. ][ OK ]";
char alert54[] = "[1][ | Memory Allocation Error! ][ OK ]";

char wider[] = "[1][An 80 column screen is|required for this program.|Please re-boot in a higher|resolution. ][ Sorry ]";
char dtext[] = "Select Driver Path";

char modtext[] = " Modify Device ";
char addtext[] = " Add Device ";
char alert55[] = "[1][ This device already exists. ][ REPLACE | Cancel ]";
char alert57[] = "[1][ | The Device Number must| be between 10 and 99. ][OK]";
char NonSpeedo[] = " ( NON-SPEEDO )";


#endif




/* --------------------------------------------------------*/

#if UK

char menu_title[] = "  Printer Drivers ";
char alert13[] = "[1][The GEM Desktop has no more|windows. Please close a|window that you are not|using.][ OK ]";
char driver_null[] = "None Selected              ";	/* Text if there is no device 21 active    */
char window_title[] = " Printer Drivers ";
char alert56[]= "[1][ | Remove the Printer Driver? ][OK|Cancel]";
char alert1[] = "[1][ | Remove the Selected Device? ][OK|Cancel]";
char alert2[] = "[1][ | Add a new device? ][OK|Cancel]";
char alert3[] = "[3][Error reading!][ OK ]";
char alert4[] = "[1][ | There is not enough | memory to read the | ASSIGN.SYS file. ][ OK ]";
char alert5[] = "[3][ | Cannot open ASSIGN.SYS. ][ OK ]";
char alert6[] = "[3][ | Error opening the | ASSIGN.SYS file. The | operation is cancelled.][ OK ]";
char alert7[] = "[1][ | There is no more room | for any more devices. ][ OK ]";

char data_null[] =    "Unknown          ";
char *page_data[] = { "Letter  ",
		      "Legal   ",
		      "A4      ",
		      "B5      ",
		      "Other   "
		    };


char alert10[] = "[1][ | Save the device drivers? ][OK|Cancel]";
char alert12[] = "[1][ |The device drivers have |been changed. Save the|changes? ][OK|Cancel]";

char head1[] = ";> ASSIGN.SYS Created with DRIVERS.ACC Copyright 1992 - 1993 Atari Corp.\r\n";
char head2[] = ";> For use with GDOS 1.1 and higher.\r\n";
char head3[] = ";> Last modified on %d/%d/%d %02d:%02d\r\n";	             

char *print_text[] = {
		      "Draft    ",
		      "Final",
		      "Draft",
		      "Final"
		     };


char *size_text[] = {
		      "Letter   ",
		      "Legal",
		      "A4",
		      "B5",
		      "Other~2",
		      "Letter",
		      "Legal",
		      "A4",
		      "B5",
		      "Other"
		    };

char *rez_text[] = {
		     "                  ",
		     "                  "
		   };

char rez_width[] = "Width: %2.1f inches";
char rez_height[] = "Height: %2.1f inches";

char rez2_width[] =  "Width: %2.2f cm";
char rez2_height[] = "Height: %2.2f cm";

char xy1_unit[] = "Units: Inches";
char xy2_unit[] = "Units: Centimeters";

char *color_text[] = {
			"B/W",
			"4 Colours",
			"8 Colours",
			"16 Colours"
		     };

char *port_text[] = {
			"Printer  ",
			"Modem",
			"Printer",
			"Modem"
		    };
		    

char *tray_text[] = {
			"Tractor  ",
			"Tray 1",
			"Tray 2",
			"Manual",
			"Tractor",
			"Tray 1",
			"Tray 2",
			"Manual"
		    };		    		     

char alert50[] = "[1][ | Save the Driver? ][ OK | Cancel ]";
char NoDrivers[]  = "No Speedo Drivers Found";
char YesDrivers[] = "Select Drivers";

char alert51[] = "[1][ | | File I/O Error ][ OK ]";
char alert52[] = "[1][ | File Load Error!| The operation is | cancelled. ][ OK ]";
char alert53[] = "[1][ | This driver is not | a SpeedoGDOS driver. ][ OK ]";
char alert54[] = "[1][ | Memory Allocation Error! ][ OK ]";

char wider[] = "[1][An 80 column screen is|required for this program.|Please re-boot in a higher|resolution. ][ Sorry ]";
char dtext[] = "Select Driver Path";

char modtext[] = " Modify Device ";
char addtext[] = " Add Device ";
char alert55[] = "[1][ This device already exists. ][ REPLACE | Cancel ]";
char alert57[] = "[1][ | The Device Number must| be between 10 and 99. ][OK]";
char NonSpeedo[] = " ( NON-SPEEDO )";


#endif







/* ------------------------------------------------------------------*/

#if GERMAN
char menu_title[] = "  Druckertreiber";
char alert13[] = "[1][ Der GEM Desktop hat keine | Fenster mehr. Bitte schliežen Sie | ein unbenutzes Fenster.][ OK ]";
char driver_null[] = "Nichts ausgew„hlt          ";	/* Text if there is no device 21 active    */
char window_title[] = " Druckertreiber ";
char alert56[]= "[1][ | Druckertreiber entfernen? ][ OK |Abbruch]";
char alert1[] = "[1][ | Ausgew„hltes Ger„t entfernen? ][ OK |Abbruch]";
char alert2[] = "[1][ | Ein neues Ger„t hinzufgen? ][ OK |Abbruch]";
char alert3[] = "[3][ | Lesefehler! ][ OK ]";
char alert4[] = "[1][ | Nicht genug Speicher frei | um die Datei ASSIGN.SYS | zu laden. ][ OK ]";
char alert5[] = "[3][ | Kann die Datei ASSIGN.SYS | nicht ”ffnen. ][ OK ]";
char alert6[] = "[3][ | Fehler beim ™ffnen der | ASSIGN.SYS Datei. Die | Operation wird abgebrochen.][ OK ]";
char alert7[] = "[1][ | Es gibt keinen Platz mehr | fr weitere Ger„te. ][ OK ]";

char data_null[] =    "Unbekannt        ";
char *page_data[] = { "Letter  ",
		      "Legal   ",
		      "A4      ",
		      "B5      ",
		      "Anderes "
		    };


char alert10[] = "[1][ | Druckertreiber sichern? ][ OK |Abbruch]";
char alert12[] = "[1][ |Die Ger„te-Treiber wurden|ver„ndert. Neue Einstellungen|sichern? ][ OK |Abbruch]";

char head1[] = ";> ASSIGN.SYS erstellt mit DRIVERS.ACC Copyright 1992 - 1993 Atari Corp.\r\n";
char head2[] = ";> Zur Benutzung mit GDOS 1.1 oder neuer.\r\n";
char head3[] = ";> Zuletzt geaendert am %d.%d.%d %02d:%02d\r\n";	             

char *print_text[] = {
		      "Entwurf  ",
		      "Endgltig",
		      "Entwurf",
		      "Endgltig"
		     };


char *size_text[] = {
		      "Letter   ",
		      "Legal",
		      "A4",
		      "B5",
		      "Anderes~2",
		      "Letter",
		      "Legal",
		      "A4",
		      "B5",
		      "Anderes"
		    };

char *rez_text[] = {
		     "                  ",
		     "                  "
		   };

char rez_width[] = "Width: %2.1f inches";
char rez_height[] = "Height: %2.1f inches";

char rez2_width[] =  "Breite: %2.2f cm";
char rez2_height[] = "H”he: %2.2f cm";

char xy1_unit[] = "Units: Inches";
char xy2_unit[] = "Einheit: Zentimeter";

char *color_text[] = {
			"S/W",
			"4 Farben",
			"8 Farben",
			"16 Farben"
		     };

char *port_text[] = {
			"Drucker  ",
			"Modem",
			"Drucker",
			"Modem"
		    };
		    

char *tray_text[] = {
			"Traktor",
			"Schacht 1  ",
			"Schacht 2",
			"Manuell",
			"Traktor",
			"Schacht 1",
			"Schacht 2",
			"Manuell"
		    };		    		     

char alert50[] = "[1][ | Treiber sichern? ][ OK |Abbruch]";
char NoDrivers[]  = "Keine Speedo Treiber gefunden.";
char YesDrivers[] = "Treiber ausw„hlen";

char alert51[] = "[1][ | | Datei I/O Fehler ][ OK ]";
char alert52[] = "[1][ | Fehler beim Dateiladen.| Die Operation wird| abgebrochen.][ OK ]";
char alert53[] = "[1][ | Dieser Treiber ist kein | SpeedoGDOS Treiber. ][ OK ]";
char alert54[] = "[1][ | Fehler bei der | Speicheranforderung! ][ OK ]";

char wider[] = "[1][Fr dieses Programm ist eine|80-spaltige Bilddarstellung|erforderlich. Bitte booten Sie|in einer h”heren Aufl”sung neu.][ Schade ]";
char dtext[] = "Pfad fr Treiber w„hlen";

char modtext[] = " Ger„t ver„ndern ";
char addtext[] = " Ger„t hinzufgen ";
char alert55[] = "[1][ Dieses Ger„t gibt es| schon.][ERSETZEN| Abbruch ]";
char alert57[] = "[1][ | Die Ger„tenummer muž| zwischen 10 und 99 liegen.][ OK ]";
char NonSpeedo[] = " ( NICHT SPEEDO )";
#endif
		




/* ------------------------------------------------------------------*/

#if FRENCH
char menu_title[] = "  Drivers ";
char alert13[] = "[1][Le bureau GEM n'as plus de|fenˆtres. Fermez-en une|devenue inutile...][CONFIRMER]";
char driver_null[] = "Pas de s‚lection           ";	/* Text if there is no device 21 active    */
char window_title[] = " Drivers d'impression ";
char alert56[]= "[1][ |Enlever le driver d'impression?][CONFIRMER|Annuler]";
char alert1[] = "[1][ | Enlever le p‚riph‚rique | s‚lectionn‚? ][CONFIRMER|Annuler]";
char alert2[] = "[1][ | Ajouter un nouveau | p‚riph‚rique? ][CONFIRMER|Annuler]";
char alert3[] = "[3][ | Erreur de lecture! ][CONFIRMER]";
char alert4[] = "[1][ | Il n'y a pas assez de| m‚moire pour lire le| fichier ASSIGN.SYS. ][CONFIRMER]";
char alert5[] = "[3][ | Ouverture d'ASSIGN.SYS | impossible. ][CONFIRMER]";
char alert6[] = "[3][ | Erreur … l'ouverture du| fichier ASSIGN.SYS. | L'op‚ration est abandonn‚e.][CONFIRMER]";
char alert7[] = "[1][ | Il n'y a plus d'espace | pour un nouveau | p‚riph‚rique. ][CONFIRMER]";

char data_null[] =    "Inconnu          ";
char *page_data[] = { "Lettre  ",
		      "L‚gal   ",
		      "A4      ",
		      "B5      ",
		      "Autre   "
		    };


char alert10[] = "[1][ | Sauver les drivers? ][CONFIRMER|Annuler]";
char alert12[] = "[1][ |Les drivers de p‚riph‚riques|ont ‚te chang‚s. Voulez-vous|sauver les changements? ][CONFIRMER|Annuler]";

char head1[] = ";> ASSIGN.SYS Cr‚‚ avec DRIVERS.ACC, Copyright 1992-1993 Atari Corp.\r\n";
char head2[] = ";> Pour utiliser avec GDOS 1.1 ou sup‚rieur.\r\n";
char head3[] = ";> DerniŠre modification le %d/%d/%d %02d:%02d\r\n";	             

char *print_text[] = {
		      "Brouillon",
		      "Courrier",
		      "Brouillon",
		      "Courrier"
		     };


char *size_text[] = {
		      "Lettre   ",
		      "L‚gal",
		      "A4",
		      "B5",
		      "Autre~2",
		      "Lettre",
		      "L‚gal",
		      "A4",
		      "B5",
		      "Autre"
		    };

char *rez_text[] = { /* This must be 2 characters longer than
		      * the text used. either rez_width or 
		      * rez2_width etc...
		      */
		     "                   ",
		     "                   "
		   };

char rez_width[] =  "Width: %2.1f inches";
char rez_height[] = "Height: %2.1f inches";

char rez2_width[] =  "Largeur: %2.2f cm";
char rez2_height[] = "Hauteur: %2.2f cm";

char xy1_unit[] = "Units: Inches";
char xy2_unit[] = "Unit‚: CentimŠtres";

char *color_text[] = {
			"N/B",
			"4 Couleurs",
			"8 Couleurs",
			"16 Couleurs"
		     };

char *port_text[] = {   "Imprimante",
			"Modem",
			"Imprimante",
			"Modem"
		    };
		    

char *tray_text[] = {
			"Tracteur ",
			"Bloc 1",
			"Bloc 2",
			"Manuel",
			"Tracteur",
			"Bloc 1",
			"Bloc 2",
			"Manuel"
		    };		    		     

char alert50[] = "[1][ | Sauver le driver? ][CONFIRMER|Annuler]";
char NoDrivers[]  = "Aucun driver Speedo n'a ‚t‚ trouv‚";
char YesDrivers[] = "S‚lection des drivers";

char alert51[] = "[1][ | | Erreur sur fichier. ][CONFIRMER]";
char alert52[] = "[1][ | Erreur de chargement!| L'op‚ration est| abandonn‚e. ][CONFIRMER]";
char alert53[] = "[1][ | Ce driver n'est pas | un driver SpeedoGdos. ][CONFIRMER]";
char alert54[] = "[1][ | Erreur d'allocation m‚moire! ][CONFIRMER]";

char wider[] = "[1][Un affichage 80 colonnes|est n‚cessaire pour utiliser|ce programme. Passez dans|une r‚solution sup‚rieure.][ D‚sol‚ ]";
char dtext[] = "S‚lectionnez un chemin";

char modtext[] = " Modifier un p‚riph‚rique ";
char addtext[] = " Ajouter un p‚riph‚rique ";
char alert55[] = "[1][ |Ce p‚riph‚rique existe d‚j…. ][REMPLACER|Annuler]";
char alert57[] = "[1][ |Le Num‚ro de p‚riph‚rique|doit ˆtre entre 10 et 99. ][CONFIRMER]";
char NonSpeedo[] = " ( NON-SPEEDO )";
#endif





