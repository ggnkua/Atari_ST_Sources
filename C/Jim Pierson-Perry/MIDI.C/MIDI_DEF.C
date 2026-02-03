/****************************************************************/
/*                                                              */
/*      MIDI-Library & Definitions                              */
/*                                                              */
/*      Public Domain Service                                   */
/*      von                                                     */
/*      Wolfgang Schmidt, ST VISION                    6/88     */
/*                                                              */
/*      ST VISION                                               */
/*      Postfach 1651                                           */
/*      6070 Langen                                             */
/*                                                              */
/************                                           *********/
/*                                                              */
/*      Diese Library enthÑlt die meisten Grundfunktionen,      */
/*      die der MIDI-Standard beschreibt.                       */
/*                                                              */
/****************************************************************/


/* benîtigt wird das Header-File <osbind.h>                     */
 
#include <osbind.h>

#define MIDI            3       /* BIOS Kanal-Nummer fÅr MIDI */ 

/* System-IDs der verschiedenen Hersteller */
#define ID_CASIO        68
#define ID_Yamaha       67
#define ID_Korg         66
#define SYS_ID          ID_CASIO      /* als Beispiel fÅr einen 
                                         CASIO CZ-101           */

/* Channel-Voice Messages */
#define NOTE_ON         144
#define NOTE_OFF        128
#define AFTER_TOUCH1    160
#define CONTROL_CHANGE  176
#define PROGRAM_CHANGE  192
#define AFTER_TOUCH2    208
#define PITCH_BENDING   224

/* System Messages */
#define SYSTEM_EXCLUSIVE 240
#define EOX              247

#define TRUE            1
#define FALSE           0

#define cls() printf("\33E");                   /* Bildschirm lîschen */


extern long systime();          /* Wird fÅr die Timerabfrage benîtigt */

int midi_chan = 1;              /* aktueller MIDI-Kanal (1..16)       */




/***                    Die MIDI-Funktionen                   ***/


/* midi_in Status */
/* Status-Abfrage zum Einlesen des MIDI-Kanals.                 */
/* -1 = ein Byte liegt an (kann eingelesen werden)              */
/*  0 = kein Byte vorhanden                                     */

int midi_in_stat()
{
        return(Bconstat(MIDI));
}


/* midi_out Status */
/* Abfrage, ob ein Zeichen an den MIDI-Kanal ausgegeben werden kann */

int midi_out_stat()
{
        return((int)Bcostat(MIDI));
}


/* MIDI-Input */
/* Einlesen eines Zeichens vom MIDI-Kanal. (Wartet auf das Zeichen). */

int midi_in()
{
        return(0xFF & Bconin(MIDI));
}


/* MIDI-Output */
/* Ausgabe eines Zeichens an den MIDI-Kanal                     */
/* Mit RÅckmeldung Åber den Erfolg der Ausgabe.                 */

int midi_out(d)
int d;
{
int r;
        if (midi_out_stat())
           {
           Bconout(MIDI,d);
           r = TRUE;
           }
         else
           r = FALSE;
        
        return(r);
}        


/* MIDI-Daten 'auslaufen lassen' - Kanal frei lesen */

midi_clear()
{
        while (midi_in_stat())
           midi_in();
}           


/* Alle Tîne auf dem aktuellen Kanal ausschalten */

all_notes_off()             
{ midi_out(175+midi_chan);       
  midi_out(123);
  midi_out(0); 
}


/* Unterbrechung der Kopplung   Keyboard <-> Klangerzeugung */

local_off()
{ midi_out(CONTROL_CHANGE);      /* Ab hier sind alle Routinen fest */
  midi_out(122);                 /* auf MIDI-Kanal 1 eingestellt    */
  midi_out(0); /* off */
}


/* Verbindung der Funktionen von   Keyboard <-> Klangerzeugung */

local_on()
{ midi_out(CONTROL_CHANGE);
  midi_out(122);
  midi_out(127); /* on */
}


/* Tune request - automatische Anpassung der Oszillatoren bei analogen Synthis */

tune_requ()
{ midi_out(246); }


/* Active Sensing - laufende "Ready"-Meldung wÑhrend Spielpausen */

active_sensing()
{ midi_out(254); }


/* Start-Befehl fÅr/von einem Sequenzer */

midi_start()
{ midi_out(250); }


/* Continue-Funktion bei Sequenzern */

midi_continue()
{ midi_out(251); }


/* Stop-Befehl bei Sequenzern */

midi_stop()
{ midi_out(252); }


/* System Reset fÅr alle MIDI-GerÑte  -  zurÅcksetzen auf Einschalt-Zustand */

sys_reset()
{ midi_out(255); }


/* Omni-Modus ein */

omni_on()
{ midi_out(CONTROL_CHANGE);
  midi_out(125);
  midi_out(0); 
}


/* Omni-Modus aus */

omni_off()
{ midi_out(CONTROL_CHANGE);
  midi_out(124);
  midi_out(0); 
}


/* Poly-Modus ein */
poly_on()
{ midi_out(CONTROL_CHANGE);
  midi_out(127);
  midi_out(0); 
}


/* Mono-Modus ein */

mono_on()
{ midi_out(CONTROL_CHANGE);
  midi_out(126);
  midi_out(8);
}

/* ----------------------------------------------------------------*/

/* Ermitteln der System-Zeit im Supervisor-Modus */

long systime ()                            /* Timer-Wert ermitteln */
{
   long l, *p, stack;
  p = (long*)0x4baL;            /* Pointer auf 200 Hz System Timer */   
   stack = gemdos (0x20, 0L);   /* Supervisor Modus einschalten    */                  
   l = *p;                      /* Timer-Wert kopieren             */        
   gemdos (0x20, stack);        /* User Modus einschalten          */                      
   return   (l);                /* Timer-Wert zurÅckgeben          */                     
}

