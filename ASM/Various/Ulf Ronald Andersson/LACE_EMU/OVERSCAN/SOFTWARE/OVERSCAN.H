/*************************************************************
 * HEADER-File fÅr die OVERSCAN-Xbios-Erweiterungen 
 *
 * K.Isakovic   Berlin,23.08.89
 *
 * fÅr TurboC 
 */
#include <tos.h>

typedef struct
{
 int  width;            /* Breite in Pixel                              */
 int  height;           /* Hîhe   in Pixel                              */
 int  bytes_per_line;   /* Bytes pro Bildschirmzeile                    */
 long length_of_screen; /* LÑnge des BildschirmSpeichers in Bytes       */
 long physbase_offset;  /* Offset StartBildschirmSpeicher<>Physbase     */
 long logbase_offset;   /* Offset StartBildschirmSpeicher<>Logbase      */
} SCREEN;

int Oscanis(void)
{
  return (int)xbios(84) ;
}
/*
 * liefert entweder 84 oder Versionsnummer. Die Version 1.8 die als
 * erste Xbios unterstÅtzt liefert $0108 (HEX !), diese vorliegende 
 * OVERSCAN-Version 2.0 liefert $200 usw....
 */
 
SCREEN *Oscantab(int Res)
{
 return (SCREEN *)xbios(85,Res) ;
}
/*
 * liefert einen Zeiger auf die Datenstruktur SCREEN. Dabei gibt Res an,
 * welche der Auflîsungungen der Zeiger zurÅckgeliefert werden soll. FÅr
 * jede Auflîsung wird ein anderer Zeiger zurÅckgeliefert . Es gilt :
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
 return (int)xbios(86,Mode);
}
/*    
 * Mit dieser Funktion kann der PhysbaseEmulator umgeschaltet werden. 
 * Wenn der Emulator eingeschaltet ist, wird beim Aufruf von Physbase der
 * Wert von Logbase zurÅckgeliefert.
 *
 *    Mode  0 -> PhysbaseEmulator aus
 *    Mode  1 -> PhysbaseEmulator an  (Default)
 *    Mode -1 -> Status abfragen
 *
 * WICHTIG !
 *------------
 *   Man muû vor dem ProgrammEnde den PhybaseEmulator wieder anschalten !
 */

int Oscanscr(int Mode)
{
  return (int)xbios(87,Mode);
}
/*    
 * Mit dieser Funktion kann der 'Setscreen'-Aufruf umgeschaltet werden. 
 * Normalerweise ist unter OVERSCAN ein Verlegen des Bildschirms oder
 * ein Wechsel der Auflîsung nicht mîglich.
 *
 *    Mode  0 -> Setscreen NICHT zulÑssig (Default)
 *    Mode  1 -> Setscreen zulÑssig
 *    Mode -1 -> Status abfragen
 * Es wird jeweils die aktuelle Einstellung zurÅckgeliefert.
 *
 * Wenn man den BildschirmSpeicher mit Setscreen verlegen will, darf 
 * man den Offset zwischen Logbase und PhaseBase nicht zerstîren.
 *
 * WICHTIG !
 *------------
 *   Man muû vor dem ProgrammEnde den SetscreenAufruf wieder sperren !
 */


int Oscanvb(int Mode)
{
  return (int)xbios(88,Mode);
}
/*    
 * Mit dieser Funktion kann die VB RandTest-Routine und der Test auf
 * Shift/Shift/Clear im IKBD-Interrupt ausgeschaltet werden. Diese
 * Tests benîtigen 1-2% Rechenzeit, dieses kînnte aber fÅr zeitkritische
 * MidiRoutinen & Animationen zuviel sein.
 *
 *    Mode  0 -> Tests auschalten
 *    Mode  1 -> Tests einschalten
 *    Mode -1 -> Status abfragen
 * Es wird jeweils die aktuelle Einstellung zurÅckgeliefert.
 *
 * WICHTIG !
 *------------
 *   Man muû vor dem ProgrammEnde die Tests wieder einschalten !
 */


/*************************************************************
 *  UtilityFunktion zum Anlegen einer 2. Bildschirmseite
 *  LÑuft auch ohne OVERSCAN 
 */

int OverscanScreen(long *Block,long *NewLog,long *NewPhy,int Res)
{
/*  Block       Zeiger auf den mit Malloc besorgten Speicherplatz
 *  NewLog      Zeiger auf den LogbaseWert  der neuen Bildschirmseite
 *  NewPhy      Zeiger auf den PhysbaseWert der neuen Bildschirmseite
 *  Rez         GewÅnschte Auflîsung der neuen Bildschirmseite
 *
 *  Wenn nicht genug Speicher fÅr die 2.Bildschirmseite da ist, ist Block
 *  negativ und die Funktion liefert eine 0 zurÅck. Wenn alles glatt ging,
 *  liefert die Funktion eine 1 zurÅck.
 */
  if ((int)Oscanis()>= 0x107)             /* OVERSCAN-Version testen   */
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
    *Block  = (long)Malloc(32256L);           /* ohne OVERSCAN        */
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
 * UtilityFunktion zum Erfahren von Logbase/Physbase
 * LÑuft auch ohne OVERSCAN
 */
void OscanLogPhy(long *AktLog,long *AktPhy)
{
int Emulator;

 Emulator = Oscanphy(-1);       /* Alte Einstellung retten      */
 Oscanphy(0);                   /* PhysbaseEmulator aus         */
 *AktLog = (long)Logbase();
 *AktPhy = (long)Physbase();
 Oscanphy(Emulator);            /* Alte Einstellung wieder an   */
}

