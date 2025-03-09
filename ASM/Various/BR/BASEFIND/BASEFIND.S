* --------------------------------------------------------------------------
* basefind.s     find & display basepage locations in memory     (c) br 1/90
* find XNAM, XBRA (with vecs), vbl-slots, magic packs, GEMDOS i/o    br 2/90
* --------------------------------------------------------------------------
* Register: a3 Basepage; a4 memtop; a5 XBRA-Suchlauf; d7 flag; d3,d4 prt_hex
*           a4,d5 slotties;
* --------------------------------------------------------------------------
          bra.s     start
* --------------------------------------------------------------------------
xnam:     dc.l      'XNAM'              ;bei Offset 2 oder 4 vom Textbeginn
base:     dc.l      'BASE'              ;steht diese Programmkennung
* --------------------------------------------------------------------------
start:    dc.w      $A000               ;line_a init
          cmpi      #79,-$2C(a0)        ;v_cel_mx: minimum #columns = 80
          blt       sorry               ;schade!
          cmpi      #24,-$2A(a0)        ;v_cel_my: minimum #lines = 25
          blt       sorry               ;traurig!

          lea       title(pc),a0        ;Titelzeile
          bsr       conws               ;ausgeben

          pea       memtop(pc)          ;Endadresse holen
          move      #$26,-(sp)          ;Supexec
          trap      #14                 ;XBIOS
          addq      #6,sp

          movea.l   d0,a4               ;Endadresse
          movea.l   #$800,a3            ;Startadresse

preloop:  addq      #2,a3               ;nur gerade Adressen
          cmpa.l    (a3),a3             ;enth„lt Adresse sich selbst?
          bne       preloop             ;weiter
          move.l    $24(a3),a3          ;p_parent = neue Startadresse

          move.l    #$600,a5            ;fr XBRA-Suche
          move.l    a4,a6               ;retten
          move.l    a3,a4               ;Bereichsende
          moveq     #-1,d6              ;flag fr diese

          pea       next_2(pc)          ;Teilroutine
          move      #$26,-(sp)          ;Supexec
          trap      #14                 ;XBIOS
          addq      #6,sp

          moveq     #0,d6               ;flag l”schen
          move.l    a6,a4               ;alte Endadresse
          bra.s     output              ;zur Ausgabe

loop:     moveq     #0,d7               ;flag l”schen
          addq      #2,a3               ;nur gerade Adressen
          cmpa.l    (a3),a3             ;enth„lt Adresse sich selbst?
          beq.s     output              ;dann verarbeiten
          cmpa.l    a3,a4               ;Endadresse erreicht?
          beq       task_2              ;fertig
          bra       loop                ;n„chste Basepage suchen

output:   move.l    a3,d3               ;Basepage-Adresse
          bsr       prt_hex             ;ausgeben
          bsr       space               ;Zwischenraum
          move.l    $C(a3),d3           ;p_tlen
          add.l     $14(a3),d3          ;p_dlen
          add.l     $1C(a3),d3          ;p_blen addieren
          bsr       prt_hex             ;und ausgeben
          bsr       space               ;Zwischenraum
          move.l    $24(a3),d3          ;p_parent
          bsr       prt_hex             ;und ausgeben
          lea       $102(a3),a1         ;Offset 'XNAM'-Struktur
          lea       xnam(pc),a0         ;was drin steh'n soll
          move.l    (a1),d0             ;gucken
          cmp.l     (a0),d0             ;steht's dort?
          beq.s     right_on            ;ok
          addq      #2,a1               ;um 2 erh”hen
          move.l    (a1),d0             ;nachschauen
          cmp.l     (a0),d0             ;steht's dort?
          bne.s     no_name             ;leider nicht

right_on: lea       write(pc),a0        ;Leerstring
          move.l    $4(a1),d3           ;merken
          move.l    d3,2(a0)            ;Namen dorthin
          bsr       conws               ;und ausgeben
          cmp.l     base(pc),d3         ;das prg h”chstselbst?
          beq       special             ;zur Spezialausgabe

          bra.s     next_1              ;weiter

no_name:  lea       empty(pc),a0        ;6 * Space
          bsr       conws               ;ausgeben
next_1:   lea       $100(a3),a5         ;Suchanfang
next_2:   addq      #2,a5               ;nur gerade Adressen
          cmp.l     (a5),a5             ;schon n„chste BP?
          beq.s     thats_it            ;Suche beenden
          cmpa.l    a5,a4               ;Endadresse erreicht?
          beq.s     thats_it            ;fertig
          move.l    xbra(pc),d0         ;Kennung
          cmp.l     (a5),d0             ;steht's da?
          bne       next_2              ;weitersuchen

          lea       4(a5),a0            ;xb_id
          moveq     #3,d1               ;4 Byte
test_a:   cmpi.b    #' ',(a0)+          ;ASCII?
          bls       next_2              ;nein -> weitersuchen
          dbf       d1,test_a           ;Langwort durchnudeln

          move.l    8(a5),d3            ;xb_oldvec
          beq.s     next_2              ;war nichts!
          tst.b     8(a5)               ;sinnvolle Adresse?
          bne.s     next_2              ;wieder nichts!
          btst      #0,$B(a5)           ;Adresse gerade?
          bne.s     next_2              ;total entnervt!

          tst       d7                  ;flag testen
          beq.s     skip_1              ;erstes Mal

          lea       posit(pc),a0        ;Cursor neu positionieren
          bsr.s     conws               ;und ausgeben
skip_1:   lea       write(pc),a0        ;Leerstring
          move.l    4(a5),2(a0)         ;Namen dorthin
          bsr.s     conws               ;und ausgeben
          bsr.s     space               ;Zwischenraum
          bsr       prt_hex             ;xb_oldvec ausgeben
          bsr.s     space               ;Zwischenraum
          lea       12(a5),a0           ;es ist die Adresse
          move.l    a0,d3               ;xb_newvec
          bsr.s     prt_hex             ;ausgeben
          moveq     #-1,d7              ;flag setzen
          bra       next_2              ;weitersuchen

thats_it: lea       crlf(pc),a0         ;CR LF
          bsr.s     conws               ;ausgeben
          tst       d6                  ;flag
          beq       loop                ;weiter geht's
          rts

special:  lea       the_prg(pc),a0      ;Text laden (mit CR LF)
          bsr.s     conws               ;ausgeben
          moveq     #-1,d7              ;set flag
          bra       next_1              ;evtl. weitersuchen (*)

task_2:   lea       slot_txt(pc),a0     ;Text laden
          bsr.s     conws               ;und ausgeben

          pea       slotties(pc)        ;Subroutine
          move      #$26,-(sp)          ;Supexec
          trap      #14                 ;XBIOS
          addq      #6,sp

task_3:   lea       mag_txt(pc),a0      ;Text laden
          bsr.s     conws               ;ausgeben
          lea       flag_2(pc),a4       ;vorbereiten

          pea       magic_pk(pc)        ;Subroutine
          move      #$26,-(sp)          ;Supexec
          trap      #14                 ;XBIOS
          addq      #6,sp

          tst.b     (a4)                ;flag testen
          bne.s     term                ;dann nicht

          lea       none(pc),a0         ;'keine da' Text
          bsr.s     conws               ;ausgeben
term:     bsr.s     cnecin              ;warte auf Taste
          clr       -(sp)               ;Pterm0
          trap      #1                  ;GEMDOS
* --------------------------------------------------------------------------
space:    lea       space_1(pc),a0      ;Zwischenraum
conws:    pea       (a0)                ;Stringadresse
          move      #9,-(sp)            ;Cconws
          trap      #1                  ;GEMDOS
          addq      #6,sp               ;SP restaurieren
          rts
* --------------------------------------------------------------------------
cnecin:   move      #7,-(sp)            ;Cnecin
          trap      #1                  ;GEMDOS
          addq      #2,sp
          rts
* --------------------------------------------------------------------------
cconout:  move      d0,-(sp)            ;char
          move      #2,-(sp)            ;Cconout
          trap      #1                  ;GEMDOS
          addq      #4,sp
          rts
* --------------------------------------------------------------------------
* Langwort in d3 in Hex (als Text) auf Konsole ausgeben

prt_hex:  moveq     #7,d4               ;8 Nibble
nibble:   rol.l     #4,d3               ;rotieren
          move.l    d3,d0               ;holen
          andi.b    #$F,d0              ;maskieren
          addi.b    #'0',d0             ;in ASCII wandeln
          cmpi.b    #'9',d0             ;na
          ble.s     put_out             ;weg damit
          addq.b    #7,d0               ;sonst fr 'A'..'F'
put_out:  bsr       cconout             ;ausgeben
          dbf       d4,nibble           ;weiter geht's
          rts                           ;und zurck
* --------------------------------------------------------------------------
sorry:    lea       lorez(pc),a0        ;'sorry, min screen size 80 * 25!'
          bsr       conws               ;ausgeben
          bra       term                ;das war's
* --------------------------------------------------------------------------
* Magische P„ckchen finden, „hnlich der Routine aus dem Betriebssystem

magic_pk: movea.l   $42E,a3             ;von phystop
repeat:   suba      #$200,a3            ;nach unten
          cmpa.l    #$400,a3            ;bis $600 einschl.
          beq.s     finish              ;untersuchen
          cmpi.l    #$12123456,(a3)     ;magic
          bne.s     repeat              ;weitersuchen
          cmpa.l    4(a3),a3            ;Adresse des magic
          bne.s     repeat              ;n„chster Versuch
          moveq     #0,d0               ;l”schen
          movea.l   a3,a1               ;zum Durchz„hlen
          move      #$FF,d1             ;512 Byte
sum_up:   add       (a1)+,d0            ;Checksumme
          dbf       d1,sum_up           ;berechnen
          cmp       #$5678,d0           ;noch'n magic
          bne.s     repeat              ;war's nicht
          move.l    a3,d3               ;doch
          bsr       prt_hex             ;ausgeben
          bsr       space               ;Zwischenraum
          st        (a4)                ;flag setzen
          bra.s     repeat              ;und so weiter
finish:   rts                           ;und wieder zurck
* --------------------------------------------------------------------------
memtop: move.b  $424,d0         ;memcntrl holen
        andi    #$F,d0          ;low nibble
        lea     mem_list(pc),a0 ;memconf-Tabelle
        moveq   #count/6-1,d1   ;Eintrag 6 Byte
search: cmp     (a0)+,d0        ;Eintrag da?
        beq.s   recogn          ;gefunden?
         addq   #4,a0           ;Wert berspringen
        dbf     d1,search       ;weitersuchen

recogn: move.l  (a0),d0         ;RAM-Gr”že
        bne.s   skip_3          ;stattdessen
        move.l  $42E,d0         ;phystop nehmen
skip_3: subi.l  #16,d0          ;Busfehler vermeiden
        rts
* --------------------------------------------------------------------------
slotties: move      $454,d5             ;nvbls
          movea.l   $456,a4             ;_vblqueue
          tst       d5                  ;nvbls
          beq.s     finis               ;kein Slot da ? -> return
          moveq     #0,d7               ;flag l”schen
          subq      #1,d5               ;Z„hler fr dbf Schleife
getslot:  move.l    (a4)+,d3            ;Eintrag holen
          tst.l     d3                  ;steht was drin ?
          beq.s     next_3              ;n„chstes slot
          bsr       space               ;Zwischenraum
          bsr       prt_hex             ;ausgeben
          moveq     #-1,d7              ;flag setzen

          lea       xnam(pc),a2         ;XNAM-Eintrag
          move.l    -4(a4),a1           ;Slot-Adresse
          subq      #8,a1               ;Suchposition
          cmpm.l    (a1)+,(a2)+         ;'XNAM' da ?
          bne.s     next_5              ;nein -> weitersuchen

          lea       write(pc),a0        ;Leerstring
          move.l    (a1),2(a0)          ;Namen dorthin
          bsr       conws               ;und ausgeben

next_5:   tst       d7                  ;flag testen
          beq.s     next_3              ;erstes Mal

next_4:   lea       slot_col(pc),a0     ;Zeile umbrechen
          bsr       conws
next_3:   dbf       d5,getslot          ;weiter suchen
finis:    rts
* --------------------------------------------------------------------------
mem_list: dc.w      4
          dc.l      $80000    ;512K
          dc.w      5
          dc.l      $100000   ;1M
          dc.w      6
          dc.l      $280000   ;2M5
          dc.w      8
          dc.l      $200000   ;2M
          dc.w      9
          dc.l      $280000   ;2M5
          dc.w      $A
          dc.l      $400000   ;4M
count     =    *-mem_list     ;Tabellenl„nge
          dc.w      0,0,0     ;Tabellenende

xbra:     dc.l      'XBRA',0,0
write:    dc.b      '  1234',0
flag_2:   dc.b      0
empty:    dc.b      '      ',0
space_1:  dc.b      '  ',0
crlf:     dc.b      13,10,0
none:     dc.b      'none!',13,10,0
title:    dc.b      13,'basepage  prog_len  p_parent  XNAM  XBRA  _old_vec'             
          dc.b      "  _new_vec BASEFIND (c) br 90",13,10,0
the_prg:  dc.b      '  Obviously the program BASEFIND itself!',13,10,0
lorez:    dc.b      13,10,'sorry, min screen size 80 * 25!',13,10,00
posit:    dc.b      13,10,'                                  ',0
slot_col: dc.b      13,10,'                  ',0
slot_txt: dc.b      13,10,'active vbl_slots: ',0
mag_txt:  dc.b      13,10,'magic_pk: ',0
* --------------------------------------------------------------------------

