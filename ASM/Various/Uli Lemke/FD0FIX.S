Version:  macro
          dc.b      13,10
          dc.b      " Flexdisk Grîûe 0 Fix: Malloc(-1)/2 !",13,10
          dc.b      " 1.3, 8.5.89 14:04"
          dc.b      " (C) by Uli Lemke ",13,10,0
          endm
          
          opt       o+                  * Optimiere! 

minlength equ       40*1024             * Mindest-Speicher fÅr ROM
reserve   equ       40*1024             * Reserve fÅr Flexdisk

***************************************************
* Flexdisk Grîûe 0 Fix                            *
* Gibt dem Desktop nur ~ den halben Speicher      *
*  durch Malloc fake.                             *
* (C)1989 by Uli Lemke                            *
***************************************************
* Assembler: Devpac 2.07D                         *
* Tabulatorweite: 10                              *
***************************************************

illegal:  macro
          dc.w      $4afc
          endm

Gemdos    equ       1                   * Trapnummern
Bios      equ       13
Xbios     equ       14

********************
* Funktionsnummern *
********************
* Bios
Bconstat  equ       1
Bconin    equ       2
Bconout   equ       3

* Xbios
Getrez    equ       4
Setscreen equ       5
Setpalet  equ       6
Setcolor  equ       7
supexec   equ       38

* Gemdos
Malloc    equ       $48
ptermres  equ       $31
***********************

_sysbase  equ       $4f2                * Systemvariablen...
tos_len   equ       $30000              * LÑnge des TOS (192K)
stacksize equ       512                 * Programm-Stackgrîûe

fixmagic  equ       "FD0x"              * Magic-Kennung fÅr "FD0fix"

************************************************************************
* BEGINN DES RESIDENTEN PROGRAMMSTöCKS!
************************************************************************

start:    bra       main                * Sprung in's Hauptprogramm

*********************************
* Neue Trap #1-Routine (Gemdos) *
*********************************

xbra:     dc.l      'XBRA'              * XBRA-Struktur anlegen:
          dc.l      fixmagic            * Identifikation
old1:     ds.l      1                   * Alter Vektor f. Trap #1

new1:
          move.l    a7,a0
          move.w    (a0),d0             * Statuswort laden
          btst      #13,d0              * Supervisormode?
          bne.s     supmod              * Ja!
          move.l    usp,a0              * Parameter des laufenden Programms
          subq.l    #6,a0               * holen...
supmod:   addq.l    #6,a0               * Entweder USP oder SSP je nach S-Bit
          move.w    (a0),d0             * gewÑhlte Funktionsnummer lesen
          cmp.w     #Malloc,d0          * Malloc?
          beq.s     malloc              * Ja => fÑlschen
nixtun:   move.l    old1(pc),a0         * Nix dergleichen => normal weiter
          jmp       (a0)

************************
* Neue Malloc-Routine  *
* a0->Parameter (Fnum.)*
************************

malloc:
          cmpi.l    #-1,2(a0)           * War es "wieviel Speicher frei?" ?
          bne.s     nixtun              * nein => normal weiter

          move.l    _sysbase,a0         * Anfang des TOS suchen:
          move.l    8(a0),d0            * aus Header holen
          cmp.l     2(a7),d0            * Liegt Aufrufadresse im ROM (TOS)?
          bgt       nixtun              * Nein => nichts Ñndern!
          add.l     #tos_len,d0         * + TOS-LÑnge
          cmp.l     2(a7),d0            * Liegt Aufrufadresse im ROM (TOS)?
          blt       nixtun              * Nein => nichts Ñndern!

          pea       -1                  * Malloc(-1)
          move.w    #Malloc,-(a7)
          trap      #Gemdos
          addq.l    #6,a7

          cmpi.l    #minlength,d0       * mindestens minlength Bytes Speicher
          blt       malende             * Nein,dann bekommt ROM alles

          cmpi.l    #2*minlength+reserve,d0       * Speicher teilen ?
          blt       knapp                         * nein

          subi.l    #reserve,d0         * Reserve fÅr FD
          asr.l     #1,d0               * d0=d0/2
          bclr.l    #0,d0               * gerade Anzahl

malende:  rte                           * Ende mit Trap #1 - Malloc

knapp:
          move.l    #minlength,d0       * minlength fÅr ROM, Rest fÅr FD
          bra.s     malende


*************************************************************************
* ENDE DES RESIDENTEN PROGRAMMTEILS!
*************************************************************************

main:     move.l    #$100,d0            * Prg.-LÑnge: 256 Bytes Base-Page +
          add.l     #main-start,d0      * + LÑnge des residenten. Prg-Teils
          move.l    d0,bedarf           * Speicherbedarf merken
          lea       stack(pc),a0        * Stack setzen...
          adda.w    #stacksize,a0       * (auf stack+stacksize)
          move.l    a0,a7

          bsr       hello               * Schreibe Titelzeile

          bsr       init                * Traps fÑlschen (#1, #13)

          clr.w     -(a7)               * Return-Code 0
          move.l    bedarf(pc),-(a7)    * Speicherbedarf
          move.w    #ptermres,-(a7)     * Ptermres...
          trap      #1                  * ...ausfÅhren => Programmende


********************
* Lenke Trap #1 um *
********************

init:
          pea       inmain(pc)          * inmain in S-Mode starten
gosuper:  move.w    #supexec,-(a7)
          trap      #Xbios
          addq.l    #6,a7
          rts

inmain:

          move.l    $84,old1            * Trap #1 umlenken
          move.l    #new1,$84
          rts

*************************
* Schreibe String in a0 *
*************************
puts:
          move.l    a0,a5               * Bios macht a5 nicht kaputt !!
          clr.l     d0
putsloop: move.b    (a5)+,d0            * hole Zeichen
          beq.s     putsend             * 00 ist Stringterminator
          move.w    d0,-(a7)            * Bconout(2)
          move.w    #2,-(a7)
          move.w    #Bconout,-(a7)
          trap      #Bios
          addq.l    #6,a7
          bra.s     putsloop

putsend:  rts

hello:
          lea       hellostr(pc),a0     * BegrÅûungsbotschaft
          bsr.s     puts
          rts

***********
* Strings *
***********
          section   DATA
hellostr:
          Version
          
          section   BSS
          even

bedarf:   ds.l      1                   * Speicherbedarf des Programms

stack:    ds.b      stacksize           * Programm-Stack

          end

