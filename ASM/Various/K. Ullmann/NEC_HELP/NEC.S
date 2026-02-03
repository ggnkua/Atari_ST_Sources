*
* Drucker : NEC P5,P6,P7
*
* Converter von 8 Nadelgraphik auf 24 Nadelgraphik
* fr alle 8 Nadelgraphik Einstellungen
*
* (c) 1987 K. Ullmann & ATARI Corp. Deutschland
*
* frei fr private Nutzung
* Komerzielle Nutzung m”glich nach rcksprache mit dem Programmierer
*
* Format: as68 -l -u nec.s
*         link68 [u] nec.68k=nec
*         relmod nec
*         rm nec.o
*
* Achtung: Die Graphikstufen mit 80 DPI und 240 DPI k”nnen nicht 1:1
*          konvertiert werden, da entsprechende Aufl”sungen im 24
*          Nadelbetrieb nicht vorhanden sind.
*
*          80 DPI wird zu 90 DPI und
*          240 DPI wird zu 180 DPI konvertiert
*

bios     equ $0d     * BIOS   TRAP
keep     equ $31     * halte Programm resistent
gemdos   equ $01     * GEMDOS TRAP
setexec  equ $05     * setze Exeptionvektor
conout   equ $03     * Cconout()
prt      equ $00     * 00 = Druckerdevice
v_trap13 equ $2d     * Trap 13 Vektorennummer

         .text

* Programmgr”e berechnen fr keep resistant

init_p6  move.l   4(sp),a0
         move.l   #$100,d6
         add.l    12(a0),d6
         add.l    20(a0),d6
         add.l    28(a0),d6
         move.l   d6,save_ssp

*    TRAP Vektor #13 initialisieren
         move.l   #trap13,-(sp)
         move.w   #v_trap13,-(sp)
         move.w   #setexec,-(sp)
         trap     #bios
         addq.l   #8,sp
         move.l   d0,save_t13
         move.l   #esc,var_jmp

*    Programm wird verlassen, bleibt aber im Speicher
         clr.l    -(sp)
         move.l   save_ssp,-(sp)
         move.w   #keep,-(sp)
         trap     #gemdos

* print sendet das Zeichen in d0 an den Drucker

print    movem.l  d0-d7/a0-a6,-(sp)       * Rette Register
         move.w   d0,-(sp)                * Zeichen auf Stack
         move.w   #prt,-(sp)              * Ausgabeger„t (Drucker) auf Stack
         move.w   #conout,-(sp)           * Funktion (Cconout) auf Stack
         pea      e_print(pc)             * Rcksprungadresse festlegen
         move.w   sr,-(sp)                * Statusregister fr TRAP auf Stack
normal   move.l   save_t13,a0             * alte TRAP Adresse in a0
         jmp      (a0)                    * und ber a0 ausfhren
e_print  addq.l   #6,sp                   * nach TRAP Stackpointer aufr„umen
         movem.l  (sp)+,d0-d7/a0-a6       * Register zurck
         rts                              * Ende von Print

* trap13 ersetzt die alte TRAP #13 Routine

trap13   move.l   sp,a2                   * Stackpointer nach a2
         btst     #5,(sp)                 * berprfe ob supervisor-mode
         bne      super                   * ja
         move.l   usp,a2                  * sonst usp benutzen
         subq.l   #6,a2                   * und aufr„umen
super    cmp.w    #conout,6(a2)           * falls Cconout()
         bne      normal                  * nein
         cmp      #prt,8(a2)              * dann falls Drucker
         bne      normal                  * nein
         move.w   10(a2),char             * Zeichen retten nach char
         movem.l  d0-d7/a0-a6,-(sp)       * Register retten
         move.l   var_jmp,a1              * entsprechende Routine in a1
         jsr      (a1)                    * und ausfhren
         movem.l  (sp)+,d0-d7/a0-a6       * Register zurck
         rte                              * Ende von trap13 ist ein RTE

* esc wartet auf esc

esc      cmp.w    #$1b,char               * teste esc
         bne      no_esc                  * falls nicht ende
do_esc   move.l   #esc_2,var_jmp          * neuer var_jmp
no_esc   move.w   char,d0                 * nicht esc
         bsr      print                   * zeichen ausdrucken
         rts

* esc_2 wartet auf den Wert nach esc

esc_2    move.w   char,d0
         cmp.w    #$2a,char               * auf * berprfen
         bne      esc_2_5                 * falls nicht K,L,Y und Z berprfen
         bsr      print                   * '*' ausdrucken
         move.l   #esc_2_1,var_jmp        * neuer var_jmp
         rts

* Graphikmode von '*' berprfen

esc_2_1  move.w   char,d0             * schiebe Graphikmode nach d0
         cmp.w    #0,d0               *  60 DPI 8 Nadeln
         bne      esc_2_2             * nein
         move.w   #32,d0              * ersetze ->  60 DPI 24 Nadeln
         bra      e_esc_2             * 
esc_2_2  cmp.w    #1,d0               * 120 DPI 8 Nadeln
         bne      esc_2_3             * nein
         move.w   #33,d0              * ersetze -> 120 DPI 24 Nadeln
         bra      e_esc_2             *
esc_2_3  cmp.w    #2,d0               * 120 DPI 24 Nadeln Geschwindigkeit*2
         bne      esc_2_4             * nein
         move.w   #33,d0              * ersetze -> 120 DPI 24 Nadeln
         bra      e_esc_2             *
esc_2_4  cmp.w    #6,d0               *  90 DPI 8 Nadeln
         bne      esc_2_8             * nein
         move.w   #38,d0              * ersetze ->  90 DPI 24 Nadeln
         bra      e_esc_2             *
esc_2_8  cmp.w    #4,d0               *  80 DPI 8 Nadeln
         bne      esc_2_9             * nein
         move.w   #38,d0              * ersetze ->  90 DPI 24 Nadeln
         bra      e_esc_2             *
esc_2_9  cmp.w    #3,d0               * 240 DPI 8 Nadeln
         bne      e_esc               * nein, dann sind es schon 24 Nadeln
         move.w   #39,d0              * ersetze -> 180 DPI 24 Nadeln
         bra      e_esc_2             *

* Graphikstufen K,L,Y und Z testen

esc_2_5  cmp.w    #$4b,d0             *  60 DPI 8 Nadeln
         bne      esc_2_6             * nein
         move.w   #$2a,d0             * ja, dann '*'
         bsr      print               * drucken
         move.w   #32,d0              * ersetze ->  60 DPI 24 Nadeln
         bra      e_esc_2             *
esc_2_6  cmp.w    #$4c,d0             * 120 DPI 8 Nadeln
         bne      esc_2_7             * nein
         move.w   #$2a,d0             * ja, dann '*'
         bsr      print               * drucken
         move.w   #32,d0              * ersetze -> 120 DPI 24 Nadeln
         bra      e_esc_2             *
esc_2_7  cmp.w    #$59,d0             * 120 DPI 8 Nadeln Geschwindigkeit*2
         bne      esc_2_0             * nein
         move.w   #$2a,d0             * ja, dann '*'
         bsr      print               * drucken
         move.w   #32,d0              * ersetze -> 120 DPI 24 Nadeln
         bra      e_esc_2             *
esc_2_0  cmp.w    #$5a,d0             * 240 DPI 8 Nadeln
         bne      esc_end             * nein, dann keine Graphik
         move.w   #$2a,d0             * ja, dann '*'
         bsr      print               * drucken
         move.w   #39,d0              * ersetze -> 180 DPI 24 Nadeln
         bra      e_esc_2             *

* e_esc initialisiert 24 Nadelgraphik

e_esc    bsr      print               * drucke Zeichen aus
         move.l   #convert,var_jmp    * setze var_jmp auf Funktion convert
         move.b   #0,conv             * nicht Konvertieren da 24 Nadelgraphik
         rts

* e_esc_2 initialisiert 8 Nadelgraphikconverter

e_esc_2  bsr      print               * drucke Zeichen aus
         move.l   #convert,var_jmp    * setze var_jmp auf Funktion convert
         move.b   #1,conv             * Konvertieren da 8 Nadelgraphik
         rts

* esc_end, keine Escapesequenz fr Graphik gefunden -> warte auf esc

esc_end  move.w   char,d0             * schiebe Zeichen nach d0
         jsr      print               * und drucke es aus
         move.l   #esc,var_jmp        * setze var_jmp auf Funktion esc
         rts

* convert stellt die Anzahl der Spalten pro Zeile fest
* aus der die Graphik besteht
* Spaltenn = n1 + n2 * #$100
* warten auf n1

convert  move.w   char,d0             * schiebe n1 nach d0
         and.w    #$00ff,d0           * isoliere letzten beiden Stellen (hex)
         move.w   d0,num              * speichere in num
         bsr      print               * drucke n1
         move.l   #conv_2,var_jmp     * setze var_jmp auf Funktion conv_2
         rts

* warten auf n2

conv_2   move.w   char,d0             * schiebe n2 nach d0
         lsl.w    #8,d0               * schiebe letzen beiden Stellen
         and.w    #$ff00,d0           * und isoliere nun ersetn beiden Stellen
         or.w     d0,num              * bilde n1 + n2 * #$100
         move.w   char,d0             * schiebe n2 nach d0
         bsr      print               * drucke n2
         cmp.w    #$00,num            * ist num = 0
         bne      conv_22             * nein
         move.l   #esc,var_jmp        * ja, setze var_jmp Funktion auf esc
         rts                          * da keine Graphikdaten folgen

conv_22  move.l   #conv_4,var_jmp     * setze var_jmp Funktion auf count_4
         cmp.b    #1,conv             * wird Convertiert
         beq      conv_3              * ja
         move.w   num,d1              * nein, dann -> num = num * 3
         add.w    d1,num              *
         add.w    d1,num              *
conv_3   rts                          *

* conv_4 ebertr„gt bzw. convertiert Graphik

conv_4   cmp.b    #0,conv             * wird Convertiert
         beq      no_conv             * nein
         move.w   char,d0             * ja, schiebe char nach d0
         lsl.w    #8,d0               * schiebe 8 Zeichen nach links
         move.w   d0,char             * speicher d0 in char
         move.w   #0,d0               * l”sche d0 fr Ausgabe
         lsl.w    char                * schiebe Graphikdaten nach links
         bcc      c_1                 * ist 1. Punkt vorhanden
         or.w     #$e0,d0             * setze Daten fr 1. Punkt
c_1      lsl.w    char                * schiebe Graphikdaten nach links
         bcc      c_2                 * ist 2. Punkt vorhanden
         or.w     #$1c,d0             * setze Daten fr 2. Punkt
c_2      lsl.w    char                * schiebe Graphikdaten nach links
         move.w   sr,save_sr          * sichere Statusregister
         bcc      c_3                 * ist 3. Punkt vorhanden
         or.w     #$03,d0             * setze 1. Daten fr 3. Punkt
c_3      bsr      print               * drucke erstes drittel
         move.w   #0,d0               * l”sche d0 fr Ausgabe
         move.w   save_sr,sr          * Statusregister zurck
         bcc      c_4                 * ist 3. Punkt vorhanden
         or.w     #$80,d0             * setze 2. Daten fr 3. Punkt
c_4      lsl.w    char                * schiebe Graphikdaten nach links
         bcc      c_5                 * ist 4. Punkt vorhanden
         or.w     #$70,d0             * setze Daten fr 4. Punkt
c_5      lsl.w    char                * schiebe Graphikdaten nach links
         bcc      c_6                 * ist 5. Punkt vorhanden
         or.w     #$0e,d0             * setze Daten fr 5. Punkt
c_6      lsl.w    char                * schiebe Graphikdaten nach links
         move.w   sr,save_sr          * sichere Statusregister
         bcc      c_7                 * ist 6. Punkt vorhanden
         or.w     #$01,d0             * setze 1. Daten fr 6. Punkt
c_7      bsr      print               * drucke zweites drittel
         move.w   #0,d0               * l”sche d0 fr Ausgabe
         move.w   save_sr,sr          * Statusregister zurck
         bcc      c_8                 * ist 6. Punkt vorhanden
         or.w     #$c0,d0             * setze 2. Daten fr 6. Punkt
c_8      lsl.w    char                * schiebe Graphikdaten nach links
         bcc      c_9                 * ist 7. Punkt vorhanden
         or.w     #$38,d0             * setze Daten fr 7. Punkt
c_9      lsl.w    char                * schiebe Graphikdaten nach links
         bcc      c_0                 * ist 8. Punkt vorhanden
         or.w     #$07,d0             * setze Daten fr 8. Punkt
c_0      bsr      print               * drucke drittes drittel
         bra      count               * teste ob Ende der Zeile erreicht ist

* no_conv l„t 24 Nadelgraphik passieren

no_conv  move.w   char,d0             * schiebe Daten nach d0
         bsr      print               * und drucke sie
count    sub.w    #1,num              * num = num - 1
         cmp.w    #0,num              * ist num = 0
         bne      conv_5              * nein
         move.l   #esc,var_jmp        * ja, dann var_jmp auf Funktion esc
conv_5   rts

         .data
         .even
conv     .ds.b    1     * Flag ob Convertiert wird oder nicht
         .even
save_ssp .ds.l    1     * speicher fr Programmgr”e
save_t13 .ds.l    1     * speicher fr geseicherten TRAP Vektor #13
char     .ds.w    1     * speicher fr zu druckendes Zeichen
var_jmp  .ds.l    1     * speicher fr den variablen jump-Vektor
num      .ds.w    1     * speicher fr counter
save_sr  .ds.w    1     * speicher fr Statusregister

         .end

                                                                                                        