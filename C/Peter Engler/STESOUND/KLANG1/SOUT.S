* ------------------------------------------------------------------ *
* --- SOUT.S : Routinen zur Programmierung der DMA-Soundchips    --- *
* ---                                                            --- *
* --- Zum Einbinden in Turbo-C 2.0 , von Peter Engler        --- *
* --- (c) MAXON Computer 1991                     --- *
* ------------------------------------------------------------------ *


* --- Deklaration der Routinen

GLOBL snd_stop
GLOBL   snd_play

* --- Adressen der DMA-Soundchipregister

S_CNTRL  EQU      $FF8900
F_BASE   EQU      $FF8903
F_COUNT EQU       $FF8908
F_END EQU      $FF890F
 
S_MODE   EQU      $FF8920



* --- Daten

      DATA
      EVEN
      
      
* --- Heap

      BSS
      EVEN
      
      
* --- Speicher fr Parameter reservieren
      
SND_ADR:
         ds.l  1
         
      
* --- Code

      TEXT
      EVEN

     
* --- Aufruf von s_stop im Supervisormodus 

snd_stop:
      pea      s_stop         * Adresse von s_stop auf Stack
      move.w   #$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
      trap  #14            * Xbios Aufruf
      addq.l   #6,sp       * Stackpointer korrigieren
      rts


* --- Aufruf von s_play im Supervisormodus

snd_play:
      move.l   a0,SND_ADR     * Adresse der Struktur retten
      pea      s_play         * Adresse von s_stop auf Stack
      move.w   #$26,-(sp)      * Xbios Nr. $26 (->SUPEXEC)
      trap  #14            * Xbios Aufruf
      addq.l   #6,sp       * Stackpointer korrigieren
      rts


* --- Stoppen der Tonausgabe 
      
s_stop:
      move.w   #0, S_CNTRL    * Sound-Control-Register l”schen
      rts
      
      
* --- Ton ausgeben. Der Ton wird durch die SOUND-Struktur 
*               beschrieben.

s_play:
      movem.l  d3/d4,-(sp)    * d3 und d4 retten
      movea.l  SND_ADR,a0     * Adresse der Sound-Struktur in a0
      move.l   (a0)+,d0    * Anzahl Bytes in d0 
      lea.l 4(a0),a0    * Auf 'control_reg' positionieren
      move.w   (a0)+,d3    * 'control_reg' in d3
      move.w   (a0),d4        * 'mode_reg' in d4
      lea.l 4(a0),a0    * Auf 's_ptr' positionieren
      move.l  (a0),d1         * Adresse der Bytes in d1
      move.l   d1,d2       * Adresse merken
      move.b   d1,F_BASE+4       * Low-Byte eintragen
      asr.l #8,d1       * Mid-Byte holen
      move.b   d1,F_BASE+2    * Mid-Byte eintragen
      asr.l #8,d1       * High-Byte holen
      move.b   d1,F_BASE      * High-Byte eintragen
      add.l d0,d2       * Frame-End berechnen
      move.b   d2,F_END+4     * Low-Byte eintragen
      asr.l #8,d2       * Mid-Byte holen
      move.b   d2,F_END+2     * Mid-Byte eintragen
      asr.l #8,d2       * High-Byte holen
      move.b   d2,F_END    * High-Byte eintragen
      move.w   d4,S_MODE      * Mode-Register setzen
      move.w   d3,S_CNTRL     * Sound ausgeben (Control-Register)
      movem.l  (sp)+,d3/d4    * d3 und d4 restaurieren
      rts
      
      END

