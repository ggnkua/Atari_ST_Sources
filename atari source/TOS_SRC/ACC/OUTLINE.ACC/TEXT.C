/*==========================================================================
 * FILE: TEXT.C
 *==========================================================================
 * DATE: November 20, 1992
 *
 * DESCRIPTION: Country Specific Text Strings
 * COMPILER: TURBO C Version 2.0
 */
#include "country.h"

char notice1[] = "Outline Fonts Accessory by CJG";
char notice2[] = "Copyright (c) 1992-1993 Atari Corporation";

 
#if USA | UK
char menu_title[] = "  Outline Fonts ";
char alert13[] = "[1][The GEM Desktop has no more|windows. Please close a|window that you are not|using.][ OK ]";
char window_title[] = " Outline Fonts ";

char alerte11[] = "[3][ | Error opening the | EXTEND.SYS file. The | operation is cancelled.][ OK ]";

char *cache_text[] = { "Load Cache Buffer",
		       "Merge Cache Buffer",
		       "Save Cache Buffer",
		       "Clear Cache Buffer"
		    };  




char driver_null[] = "None Selected              ";	/* Text if there is no device 21 active    */
char alert56[]= "[1][ | Remove the Selected Fonts? ][OK|Cancel]";
char alert58[]= "[1][ | Install the Selected Fonts? ][OK|Cancel]";

char alert2[] = "[3][ | Build Width Tables?][  OK  | Cancel ]";

char alert3[] = "[3][Error reading!][ OK ]";
char alert10[] = "[1][ |Save the font parameters? ][OK|Cancel]";
char alert12[] = "[1][ |The font parameters have |been changed. Save the|new parameters? ][OK|Cancel]";

char wider[] = "[1][An 80 column screen is|required for this program.|Please re-boot in a higher|resolution. ][ Sorry ]";
char dtext[] = "Select Font Path";

char alert17[] = "[3][ | Clear the Cache Buffer? ][OK|Cancel]";
char alert18[] = "[3][ | A workstation error| has occurred. The| operation has been| cancelled. ][ Sorry ]";
char alert19[] = "[3][ | Cache I/O Error!| The operation has| been cancelled.][ Sorry ]";
char alert21[] = "[3][ WARNING: The size of the | font cache may be too small. | Please increase the size | of the Miscellaneous Cache. ][ OK ]";
char alert22[] = "[3][WARNING: The size of the font |cache may be too small. Please |increase the size of the |Miscellaneous Cache at |a later time. ][ OK ]";
char otitle1[] = " Outline Font Options ";
char otitle2[] = " Width Table Options ";
char alertw3[] = "[3][ | There are no installed| Outline Fonts. Width Table | files will not be built. ][ OK ]";
char alertw16[] = "[1][ | |Cancel building Width Tables? ][ YES | No ]";

char etitle1[] = "; Speedo Configuration File\r\n";
char alertw4[] = "[1][ File Creation Error][ OK ]";
char alertw5[] = "[1][ | %s is not| in the EXTEND.SYS| file. The WIDTH file| will not be built.][ OK ]";
char msg1[] = "; Last modified on %d/%d/%d %02d:%02d\r\n";

char pnt_title1[] = " Point Size Settings ";
char pnt_title2[] = " Group Point Size Settings ";
char pnt_title3[] = " Default Point Size Settings ";

char pnt1[] = "[1][ No Outline Fonts were| selected to configure | their point sizes. ][ OK ]";
char pnt_title4[] = "Set To Defaults";
char pnt_title5[] = "Set All Fonts";
char alertdel[] = "[1][ | Remove the selected point | sizes from this font? ][OK|Cancel]";
char alertpnt14[] = "[3][ |Set the current font to|the Default Point Sizes?][OK|Cancel]";
char alertpnt15[] = "[3][ | Set all fonts to the | Default Point Sizes?][OK|Cancel]";
char alertpnt20[] = "[3][Fonts must have at least|ONE point size available.|Either Add a Point Size|or Cancel the operation.][ADD|Cancel]";
char alertpnt23[] = "[3][ | The width tables are no | longer valid. Please | update your width tables. ][OK|Cancel]";
char point_invalid[] = "[1][ |The point size is invalid.][ OK ]";
char point_exists[] = "[1][ |The point size already exists.][ OK ]";
char point_noroom[] = "[1][ | There is no more room | for any more point sizes.][ OK ]";
char nomore[] = "[1][ | All of the fonts are | currently installed. ][ OK ]";
char showall[] = "[1][ |Install all available fonts? ][OK|Cancel]";
char selall[] = "[1][ | Select all available fonts? ][OK|Cancel]";
char nosel[] = "[1][ | All of the fonts are | currently selected. ][ OK ]";
char nofile[] = "[1][ | File Not Found. ][ OK ]";

char SetTitle00[] = "Bitstream Text";
char SetTitle01[] = "Bitstream Symbol";
char SetTitle02[] = "Bitstream Dingbats";
char SetTitle11[] = "PostScript Text";
char SetTitle12[] = "PostScript Symbol";
char SetTitle13[] = "PostScript Dingbats";
char SetTitle14[] = "Atari Wingbats";
char SetTitlexx[] = "Unknown";

#endif




#if GERMAN

char menu_title[] = "  Outline Fonts ";
char alert13[] = "[1][Der GEM Desktop hat keine|Fenster mehr. Bitte schlieûen|Sie ein unbenutztes Fenster.][ OK ]";
char window_title[] = " Outline Fonts ";

char alerte11[] = "[3][ | Fehler beim ôffnen der | EXTEND.SYS Datei. Die | Operation wird abgebrochen.][ OK ]";

char *cache_text[] = { "Lade Cache-Inhalt",
		       "An Cache-Inhalt anfÅgen",
		       "Sichere Cache-Inhalt",
		       "Lîsche Cache-Inhalt"
		    };  

char driver_null[] = "Nichts ausgewÑhlt            ";	/* Text if there is no device 21 active    */
char alert56[]= "[1][ | AusgewÑhlte Fonts entfernen? ][OK|Abbruch]";
char alert58[]= "[1][ |AusgewÑhlte Fonts installieren?][OK|Abbruch]";

char alert2[] = "[3][ | Breitentabellen erzeugen?][  OK  | Abbruch ]";

char alert3[] = "[3][Lesefehler!][ OK ]";
char alert10[] = "[1][ |Font-Einstellungen sichern? ][OK|Abbruch]";
char alert12[] = "[1][ |Die Font-Einstellungen wurden|verÑndert. Neue Einstellungen|sichern? ][OK|Abbruch]";

char wider[] = "[1][För dieses Programm ist eine|80-spaltige Bilddarstellung|erforderlich. Bitte booten Sie|in einer hîheren Auflîsung neu.][ OK ]";
char dtext[] = "Font Pfad auswÑhlen";

char alert17[] = "[3][ | Cache Inhalt lîschen? ][OK|Abbruch]";
char alert18[] = "[3][ | Ein Workstation-Fehler ist| aufgetreten. Die Operation| wurde abgebrochen. ][ OK ]";
char alert19[] = "[3][ | Cache I/O Fehler!| Die Operation wurde | abgebrochen.][ OK ]";
char alert21[] = "[3][ ACHTUNG: Die Grîûe des| Font-Cache ist zu klein. | Bitte vergrîûern Sie die| Grîûe des Mehrzweck-Cache. ][ OK ]";
char alert22[] = "[3][ACHTUNG: Die Grîûe des |Cache ist zu klein. Bitte |vergrîûern Sie die Grîûe|des Mehrzweck-Cache zu|einem spÑteren Zeitpunkt. ][ OK ]";
char otitle1[] = " Outline Font Optionen ";
char otitle2[] = " Breitentabellen Optionen ";
char alertw3[] = "[3][ |Es gibt keine aktiven Fonts.|Die Dateien der Breitentabellen|werden nicht erzeugt. ][ OK ]";
char alertw16[] = "[1][ |Breitentabellen-Berechnung|abbrechen? ][ Ja | Nein ]";

char etitle1[] = "; Speedo Konfigurationsdatei\r\n";
char alertw4[] = "[1][ Fehler beim Anlegen| einer Datei.][ OK ]";
char alertw5[] = "[1][ | %s ist nicht| in der EXTEND.SYS Datei.| Die WIDTH-Datei wird nicht| angelegt.][ OK ]";
char msg1[] = "; Letzte Modifikation am %d.%d.%d %02d:%02d\r\n";

char pnt_title1[] = " Grîûeneinstellung ";
char pnt_title2[] = " Gruppenweise Grîûeneinstellung ";
char pnt_title3[] = " Default Grîûeneinstellung ";

char pnt1[] = "[1][ Es wurden keine Outline Fonts| ausgewÑhlt deren Grîûe nun| konfiguriert werden kînnte.][ OK ]";
char pnt_title4[] = "Setze auf Defaultwerte";
char pnt_title5[] = "Setze fÅr alle Fonts";
char alertdel[] = "[1][ |Entferne die selektierten|Grîûen fÅr diesen Font? ][OK|Abbruch]";
char alertpnt14[] = "[3][ |Den aktuellen Font auf die|Default-Grîûe setzen?][OK|Abbruch]";
char alertpnt15[] = "[3][ | Alle Fonts auf Default-| Grîûe setzen?][OK|Abbruch]";
char alertpnt20[] = "[3][Die Fonts mÅssen mindestens|EINE verfÅgbare Grîûe haben.|Eine weitere Grîûe hinzufÅgen|oder die Operation abbrechen?][HinzufÅgen|Abbruch]";
char alertpnt23[] = "[3][ | Die Breitentabellen sind nicht| lÑnger gÅltig. Bitte berechnen| Sie sie spÑter neu. ][OK|Abbruch]";
char point_invalid[] = "[1][ | Die Grîûe ist ungÅltig.][ OK ]";
char point_exists[] = "[1][ | Diese Grîûe exestiert schon.][ OK ]";
char point_noroom[] = "[1][ | Kein Platz mehr fÅr weitere| Grîûeneintragungen.][ OK ]";
char nomore[] = "[1][ | Alle Fonts sind zur Zeit| installiert. ][ OK ]";
char showall[] = "[1][ | Alle verfÅgbaren Fonts| installieren? ][OK|Abbruch]";
char selall[] = "[1][ | Alle verfÅgbaren Fonts| selektieren? ][OK|Abbruch]";
char nosel[] = "[1][ | Alle Fonts sind zur| Zeit selektiert. ][ OK ]";
char nofile[] = "[1][ | Datei nicht gefunden. ][ OK ]";

char SetTitle00[] = "Bitstream Text";
char SetTitle01[] = "Bitstream Symbol";
char SetTitle02[] = "Bitstream Dingbats";
char SetTitle11[] = "PostScript Text";
char SetTitle12[] = "PostScript Symbol";
char SetTitle13[] = "PostScript Dingbats";
char SetTitle14[] = "Atari Wingbats";
char SetTitlexx[] = "Unbekannt";

#endif





		
#if FRENCH


char menu_title[] = "  Polices";
char alert13[] = "[1][Le bureau GEM n'as plus de|fenàtres. Fermez-en une|devenue inutile...][CONFIRMER]";
char window_title[] = " Polices vectorielles ";

char alerte11[] = "[3][Impossible d'ouvrir le |fichier EXTEND.SYS. |L'opÇration est annulÇe. ][CONFIRMER]";

char *cache_text[] = { "Charger buffer du Cache",
		       "InsÇrer buffer du Cache",
		       "Sauver buffer du Cache",
		       "Effacer buffer du Cache"
		     };  




char driver_null[] = "Pas de sÇlection           ";	/* Text if there is no device 21 active    */
char alert56[]= "[1][ | Enlever les polices | sÇlectionnÇes?][CONFIRMER|Annuler]";
char alert58[]= "[1][ | Installer les polices | sÇlectionnÇes? ][CONFIRMER|Annuler]";

char alert2[] = "[3][ |Construire les tables |de tailles? ][CONFIRMER|Annuler]";

char alert3[] = "[3][ | Erreur de lecture! ][CONFIRMER]";
char alert10[] = "[1][ |Sauver les paramätres |des polices? ][CONFIRMER|Annuller]";
char alert12[] = "[1][ Les paramätres des | polices ont ÇtÇ changÇs. | Faut-il sauver les| nouveaux paramätres? ][CONFIRMER|Annuler]";

char wider[] = "[1][Un affichage 80 colonnes|est nÇcessaire pour utiliser|ce programme. Passez dans|une rÇsolution supÇrieure.][DÇsolÇ]";
char dtext[] = "Chemin des polices";

char alert17[] = "[3][ |Effacer le buffer du Cache? ][CONFIRMER|Annuler]";
char alert18[] = "[3][ |Une erreur GEM s'est produite.|L'opÇration est abandonnÇe.][DÇsolÇ]";
char alert19[] = "[3][ |Erreur d'E/S sur Cache!|OpÇration annulÇe.][CONFIRMER]";
char alert21[] = "[3][ATTENTION: la taille du Cache|est insuffisante. Augmentez|la taille du Cache ÆDiversØ.][CONFIRMER]";
char alert22[] = "[3][ATTENTION: la taille du Cache|est insuffisante. Augmentez|un peu plus tard, la taille|du Cache ÆDiversØ.][CONFIRMER]";
char otitle1[] = " Options des Polices Vectorielles ";
char otitle2[] = " Options des Tables de Tailles ";
char alertw3[] = "[3][Aucune police vectorielles|n'est installÇe. Les tables|ne peuvent pas àtre crÇes. ][CONFIRMER]";
char alertw16[] = "[1][ |Annuler la construction |des tables? ][OUI| Non ]";

char etitle1[] = "; Fichier de configuration de Speedo\r\n";
char alertw4[] = "[1][ | Erreur CrÇation Fichier. ][CONFIRMER]";
char alertw5[] = "[1][%s n'est pas |dans le fichier EXTEND.SYS. |La table ne sera pas crÇÇe... ][CONFIRMER]";
char msg1[] = "; Derniäre modification le %d/%d/%d %02d:%02d\r\n";

char pnt_title1[] = " ParamÇtrage des tailles ";
char pnt_title2[] = " ParamÇtrage des tailles par groupe ";
char pnt_title3[] = " ParamÇtrage des tailles par dÇfaut ";

char pnt1[] = "[1][Pas de polices vectorielles|sÇlectionnÇes. Configuration|des tailles impossible!][CONFIRMER]";
char pnt_title4[] = "DÇfinir les options par dÇfaut";
char pnt_title5[] = "DÇfinir toutes les polices";
char alertdel[] = "[1][ Enlever la taille | sÇlectionnÇe de cette | police? ][CONFIRMER|Annuler]";
char alertpnt14[] = "[3][ |Mettre la police courante|aux tailles par dÇfaut?][CONFIRMER|Annuler]";
char alertpnt15[] = "[3][ |Mettre toutes les polices|aux tailles par dÇfaut?][CONFIRMER|Annuler]";
char alertpnt20[] = "[3][Les polices doivent avoir|au moins UNE taille possible.|Ajoutez une taille ou annulez|l'opÇration. ][AJOUTER|Annuler]";
char alertpnt23[] = "[3][ |Les tables ne sont plus |valides. Veillez Ö les |mettre Ö jour.][CONFIRMER|Annuler]";
char point_invalid[] = "[1][ |La taille n'est pas|valide!][CONFIRMER]";
char point_exists[] = "[1][ | La taille existe dÇjÖ!][CONFIRMER]";
char point_noroom[] = "[1][ |Il n'y a plus de place |pour aucune autre taille. ][CONFIRMER]";
char nomore[] = "[1][ |Toutes les polices sont |dÇjÖ installÇes. ][CONFIRMER]";
char showall[] = "[1][ |Installer toutes les |polices disponibles? ][CONFIRMER|Annuler]";
char selall[] = "[1][ |SÇlectionner toutes les |polices disponibles? ][CONFIRMER|Annuler]";
char nosel[] = "[1][ |Toutes les polices |sont sÇlectionnÇes. ][CONFIRMER]";
char nofile[] = "[1][ | Fichier non trouvÇ. ][CONFIRMER]";

char SetTitle00[] = "Texte Bitstream";
char SetTitle01[] = "Symbole Bitstream";
char SetTitle02[] = "Dingbats Bitstream";
char SetTitle11[] = "Texte PostScript";
char SetTitle12[] = "Symbole PostScript";
char SetTitle13[] = "Dingbats PostScript";
char SetTitle14[] = "Atari Wingbats";
char SetTitlexx[] = "Inconnu";



#endif








