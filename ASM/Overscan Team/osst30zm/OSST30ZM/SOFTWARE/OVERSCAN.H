/*************************************************************
 *
 * OVERSCAN.H         (c)1990   K.Isakovic   Berlin, 12.03.90
 *
 *************************************************************
 *      HEADER-File f�r die OverScan-Xbios-Erweiterungen 
 *
 * Die speziellen OverScan-Xbios-Funktionen haben unter dem 
 * 'normalen Betrieb' keinen Einflu�, sie produzieren keine Bomben
 * oder Fehlermeldungen, werden also einfach ignoriert.
 *
 * Die Funktionsnummern haben sich gegen�ber den vorherigen
 * OverScan Versionen ge�ndert, da die Nummern 84-90 vom TT-TOS
 * ben�tigt werden. Die alten Nummern werden trotzdem noch bearbeitet.
 *
 * f�r TurboC  1.1
 */ 
#include <tos.h>

typedef struct
{
 int  width;            /* Breite in Pixel                              */
 int  height;           /* H�he   in Pixel                              */
 int  bytes_per_line;   /* Bytes pro Bildschirmzeile                    */
 long length_of_screen; /* L�nge des Bildschirmspeichers in Bytes       */
 long physbase_offset;  /* Offset Start-Bildschirmspeicher<>Physbase    */
 long logbase_offset;   /* Offset Start-Bildschirmspeicher<>Logbase     */
} SCREEN;

typedef struct
{
 int  low_w  ,mid_w  ,high_w;	/* Breite in Pixeln 			*/
 int  low_h  ,mid_h  ,high_h;	/* H�he   in Pixeln			*/
 long low_off,mid_off,high_off;	/* Offset Bildschirmspeicher<>Logbase	*/
 long mono_add,color_add;	/* Zus�tzlicher Speicherbedarf		*/
 char clear_scan;		/* Scancode  der Clear-Funktion		*/
 char clear_shift;		/* Shiftcode der Clear-Funktion		*/
 char setup_shift;		/* Shiftcode f�r Setup (Maske)		*/
 char invert_shift;		/* Shiftcode zum Invertieren des Moduse	*/
 char abort_shift;		/* Shiftcode zum Abbrechen 		*/
} OVERPATCH;

int Oscanis(void)
{
  return (int)xbios(4200) ;
}
/*
 * Liefert entweder 4200 oder Versionsnummer. Die Version 1.8 die als
 * erste Xbios unterst�tzt, liefert $0108 (HEX !), diese vorliegende 
 * OverScan-Version 3.0 liefert $300 usw....
 * Die Funktionsnummer 4200 w�rde der Version 10.68 entsprechen, 
 * die demnach nie erscheinen darf.
 * 
 */
 
SCREEN *Oscantab(int Res)
{
 return (SCREEN *)xbios(4201,Res) ;
}
/*
 * Liefert einen Zeiger auf die Datenstruktur SCREEN. Dabei gibt Res an,
 * welche der Aufl�sungungen der Zeiger zur�ckgeliefert werden soll. F�r
 * jede Aufl�sung wird ein anderer Zeiger zur�ckgeliefert . Es gilt :
 *    Res  0 -> Low  
 *    Res  1 -> Mid  
 *    Res  2 -> High 
 *    Res -1 -> Aktuelle Einstellung, wobei die Schalterstellung beachtet
 *              wird.
 * Die Datenstruktur der aktuellen Einstellung wird bei jedem Aufruf von
 * Oscantab aktualisiert. 
 */
 
int Oscanphy(int Mode)
{
 return (int)xbios(4202,Mode);
}
/*    
 * Mit dieser Funktion kann der Physbase-Emulator umgeschaltet werden. 
 * Wenn der Emulator eingeschaltet ist, wird beim Aufruf von Physbase der
 * Wert von Logbase zur�ckgeliefert.
 *
 *    Mode  0 -> PhysbaseEmulator aus
 *    Mode  1 -> PhysbaseEmulator an  (Default)
 *    Mode -1 -> Status abfragen
 *
 * WICHTIG !
 *------------
 *   Man mu� vor dem Programmende den Phybase-Emulator wieder anschalten !
 */

int Oscanscr(int Mode)
{
  return (int)xbios(4203,Mode);
}
/*    
 * Mit dieser Funktion kann der 'Setscreen'-Aufruf umgeschaltet werden. 
 * Normalerweise ist unter OverScan ein Verlegen des Bildschirms oder
 * ein Wechsel der Aufl�sung nicht m�glich.
 *
 *    Mode  0 -> Setscreen zul�ssig
 *    Mode  1 -> Setscreen NICHT zul�ssig (Default)
 *    Mode -1 -> Status abfragen
 * Es wird jeweils die aktuelle Einstellung zur�ckgeliefert.
 *
 * Wenn man den Bildschirmspeicher mit Setscreen verlegen will, darf 
 * man den Offset zwischen Logbase und Physbase nicht zerst�ren.
 *
 * WICHTIG !
 *------------
 *   Man mu� vor dem Programmende den 'Setscreen'-Aufruf wieder sperren !
 */


int Oscanvb(int Mode)
{
  return (int)xbios(4204,Mode);
}
/*    
 * Mit dieser Funktion kann die VB Randtest-Routine und der Test auf
 * Shift/Shift/Clear im IKBD-Interrupt ausgeschaltet werden. Diese
 * Tests ben�tigen 1-2% Rechenzeit, dieses k�nnte aber f�r zeitkritische
 * Midi-Routinen & Animationen zuviel sein.
 *
 *    Mode  0 -> Tests auschalten
 *    Mode  1 -> Tests einschalten (Default)
 *    Mode -1 -> Status abfragen
 * Es wird jeweils die aktuelle Einstellung zur�ckgeliefert.
 *
 * WICHTIG !
 *------------
 *   Man mu� vor dem Programmende die Tests wieder einschalten !
 */


OVERPATCH *Oscanpatch(void)
{
  return (OVERPATCH *)xbios(4205);
}
/*
 * Liefert einen Zeiger auf den Patchbereich von OverScan.
 */
 
int Oscanswitch(int Mode)
{
  return (int)xbios(4206,Mode);
}
/*
 * Dieses ist die m�chtigste Funktion, die OverScan anbietet,
 * sie schaltet den aktuellen Modus um. Es wird dabei nicht nur
 * die Hardware umgeschaltet, sondern auch alle internen
 * GEM-Variablen gepatcht und der Bildschirm umkopiert.
 *
 *    Mode  0 -> Normalmodus
 *    Mode  1 -> OverScan
 *    Mode -1 -> Status abfragen
 * Es wird jeweils die aktuelle Einstellung zur�ckgeliefert.
 */



/*************************************************************
 *  UtilityFunktion zum Anlegen einer 2. Bildschirmseite
 *  L�uft auch ohne OverScan 
 */
int OverscanScreen(long *Block,long *NewLog,long *NewPhy,int Res)
{
/*  Block       Zeiger auf den mit Malloc besorgten Speicherplatz
 *  NewLog      Zeiger auf den Logbasewert  der neuen Bildschirmseite
 *  NewPhy      Zeiger auf den Physbasewert der neuen Bildschirmseite
 *  Rez         Gew�nschte Aufl�sung der neuen Bildschirmseite
 *
 *  Wenn nicht genug Speicher f�r die 2.Bildschirmseite da ist, ist Block
 *  negativ und die Funktion liefert eine 0 zur�ck. Wenn alles glatt ging,
 *  liefert die Funktion eine 1 zur�ck.
 */
  if ((int)Oscanis()!= 4200)             /* OverScan-Version testen   */
    {
    SCREEN *Over;

    Over   = Oscantab(Res);                    /* Werte holen          */
    *Block = (long)Malloc(Over->length_of_screen);   /* Speicher anlegen     */
    if (*Block > 0)
      {
      *NewLog = ((*Block+256L)&0xffff00L) + Over->logbase_offset;
      *NewPhy = ((*Block+256L)&0xffff00L) + Over->physbase_offset;
      return 1;
      }
    }
  else
    {
    *Block  = (long)Malloc(32256L);           /* ohne OverScan        */
    if (*Block>0)
      {
      *NewLog = (*Block+256L)&0xffff00L;
      *NewPhy = *NewLog;
      return 1;
      }
    }
  return 0;
}

/*************************************************************
 * Utilityfunktion zum Erfahren von Logbase/Physbase
 * L�uft auch ohne OverScan
 */
void OscanLogPhy(long *AktLog,long *AktPhy)
{
int Emulator;

 Emulator = Oscanphy(-1);       /* Alte Einstellung retten      */
 Oscanphy(0);                   /* Physbase-Emulator aus        */
 *AktLog = (long)Logbase();
 *AktPhy = (long)Physbase();
 Oscanphy(Emulator);            /* Alte Einstellung wieder an   */
}
	