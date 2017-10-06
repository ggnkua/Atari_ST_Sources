/*
   Modul: M_ADVANC (Headerdatei)

   geschrieben von:
   
   Thomas KÅnneth
   Friedrich-Neuper-Str. 2b
   90552 Rîthenbach

	und
	
	Dirk Stadler
	Friedrich-Kînig Weg 4
	90513 Zirndorf
	
   Diese Datei ist Bestandteil der C-Version von Magic 4.0 von
   Peter Hellinger und Thomas KÅnneth und darf nur gemÑû den
   Nutzungsbedingungen von Magic fÅr C verwendet werden

   Alle Rechte bei den Autoren
*/

#ifndef _MPADVANC_
#define _MPADVANC_

#ifndef _MAGICTYP_
#include <magic\m_types.h>
#endif

/* Modus-flags */

                              /* Generelle Flags                                 */
                              /*-------------------------------------------------*/
#define fbRedraw     lBit0;   /* List- bzw. Dropbox nach dem FÅllen neu anzeigen */
#define fbOneSpace   lBit1;   /* 1 Leerzeichen vor dem Eintrag lassen            */
#define fbTwoSpace   lBit2;   /* 2 Leerzeichen vor dem Eintrag lassen            */

                              /* Bits fÅr Fillfontbox                            */
                              /*-------------------------------------------------*/
#define fbAll        lBit8;   /* Alle Fonts in die Listbox                       */
#define fbBitmap     lBit9;   /* Nur Bitmapfonts in die Listbox                  */
#define fbSpeedo     lBit10;  /* Nur Speedofonts in die Listbox                  */
#define fbTTF        lBit11;  /* Nur Truetypefonts in die Listbox                */
#define fbType1      lBit12;  /* Nur Postscriptfonts in die Listbox              */
#define fbMono       lBit13;  /* Nur monospaced Fonts in die Listbox             */
#define fbMarkMono   lBit14;  /* monospaced speziell Markieren                   */

                              /* Bits fÅr Fillcolorbox                           */
                              /*-------------------------------------------------*/
#define fbEnglish    lBit8;   /* Texte in englischer Sprache                     */



void FillFontbox(OBJECT *tree, int item, int ws, int Default, LONGBITSET mode);
/* FÅllt eine List- oder Dropbox mit eine Liste von Fonts 
 *
 * tree = Adresse des Objektbaums der Listbox 
 * item = Objektnummer der Listbox 
 * ws =   Handle der Workstation
 * mode = Modus
 *
 * Wenn man den Inhalt eines Listboxeintrags einer mit dieser Funktion
 * gefÅllten Listbox mit GetEntry abfragt, erhÑlt man im Parameter 'data'
 * einen Zeiger auf ein Datenfeld vom Typ PtrFONT.
 */

void FillDriverbox(OBJECT *tree, int item, Device dev, int Default, LONGBITSET mode);
/* FÅllt eine List- oder Dropbox mit eine Liste von VDI-Treibern 
 *
 * tree = Adresse des Objektbaums der Listbox 
 * item = Objektnummer der Listbox 
 * dev =  Device das behandelt werden soll
 * mode = Nur allgemeine Funktionen
 *
 * Wenn man den Inhalt eines Listboxeintrags einer mit dieser Funktion
 * gefÅllten Listbox mit GetEntry abfragt, erhÑlt man im Parameter 'data'
 * gewandelt in ein INTEGER (physnum:= INTEGER (data);) die physikalische 
 * Devicenummer.  Diese braucht man zum gezielten îffnen des jeweiligen GerÑts!
 */

void FillFilebox(OBJECT *tree, int item, int Default, char *path, LONGBITSET mode);
/*
 * NOCH NICHT IMPLEMENTIERT!!!
 *
 * FÅllt eine List- oder Dropbox mit eine Liste von Files 
 *
 * tree = Adresse des Objektbaums der Listbox 
 * item = Objektnummer der Listbox 
 * path = Laufwerk und Pfad, das behandelt werden soll
 * mode = Nur allgemeine Funktionen
 *
 * Wenn man den Inhalt eines Listboxeintrags einer mit dieser Funktion
 * gefÅllten Listbox mit GetEntry abfragt, erhÑlt man im Parameter 'data'
 * einen Zeiger auf folgende Struktur:
 */

void FillColorbox(OBJECT *tree, int item, int Default, LONGBITSET mode);

#endif /*_MPADVANC_*/