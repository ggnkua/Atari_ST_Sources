* --------------------------------------------------------------------------
* xbrafind.s  find XBRA structs from $600 to physical end of RAM (c) br 2/90
* --------------------------------------------------------------------------
start:    dc.w      $A000           ;line_a init
          cmpi      #39,-$2C(a0)    ;v_cel_mx: minimum #columns = 40
          blt       sorry           ;schade!
          cmpi      #11,-$2A(a0)    ;v_cel_my: minimum #lines = 12
          blt       sorry           ;traurig!

          lea       title(pc),a0    ;Titelzeile
          bsr       conws           ;ausgeben

          clr.l     -(sp)           ;stack -> superstack
          move      #$20,-(sp)      ;Super
          trap      #1              ;GEMDOS
          addq      #6,sp           ;restore sp
          move.l    d0,-(sp)        ;ssp
          move      #$20,-(sp)      ;Super -> back to user

          lea       $600,a5         ;Startadresse
memtop:   move.b    $424,d0         ;memcntrl holen
          andi      #$F,d0          ;low nibble
          lea       mem_list(pc),a0 ;memconf-Tabelle
          moveq     #count/6-1,d1   ;Eintrag ist 6 Byte lang
search:   cmp       (a0)+,d0        ;Eintrag da?
          beq.s     recogn          ;gefunden?
           addq     #4,a0           ;Wert Åberspringen
          dbf       d1,search       ;und weitersuchen

recogn:   move.l    (a0),d0         ;RAM-Grîûe holen
          bne.s     skip_3          ;stattdessen
          move.l    $42E,d0         ;phystop nehmen
*          subi.l    #$8000,d0       ;ohne Video-RAM
skip_3:   subi.l    #12,d0          ;Busfehler vermeiden

          move.l    d0,a4           ;Endadresse

loop_1:   addq      #2,a5           ;nur gerade Adressen
          cmpa.l    a5,a4           ;Endadresse erreicht?
          beq       thats_it        ;fertig
          move.l    xbra(pc),d0     ;Kennung
          cmp.l     (a5),d0         ;steht's da?
          bne       loop_1          ;weitersuchen

          lea       4(a5),a0        ;xb_id
          moveq     #3,d1           ;4 Byte
test_a:   cmpi.b    #' ',(a0)+      ;ASCII?
          bls       loop_1          ;nein -> weitersuchen
          dbf       d1,test_a       ;Langwort durchnudeln

          move.l    8(a5),d3        ;xb_oldvec
          beq.s     loop_1          ;war nichts!
          tst.b     8(a5)           ;sinnvolle jmp-Adresse?
          bne.s     loop_1          ;wieder nichts!
          btst      #0,11(a5)       ;Adresse gerade?
          bne.s     loop_1          ;total entnervt!

skip_1:   lea       write(pc),a0    ;Leerstring
          move.l    4(a5),2(a0)     ;Namen dorthin
          bsr.s     conws           ;und ausgeben
          bsr       prt_hex         ;xb_oldvec ausgeben
          bsr.s     space           ;Zwischenraum
          lea       12(a5),a0       ;es ist die Adresse
          move.l    a0,d3           ;xb_newvec
          bsr.s     prt_hex         ;ausgeben
          lea       crlf(pc),a0     ;CR LF
          bsr.s     conws           ;ausgeben
          bra       loop_1          ;weitersuchen

thats_it: trap      #1              ;GEMDOS back to user
          addq      #6,sp           ;restore sp
          lea       end_prg(pc),a0  ;'  final address:  '
          bsr.s     conws           ;ausgeben
          move.l    a5,d3           ;Endadresse
          bsr.s     prt_hex         ;ausgeben
          lea       crlf_2(pc),a0   ;2*CRLF
          bsr.s     conws           ;ausgeben
          lea       none(pc),a0     ;Text
          bsr.s     conws           ;ausgeben
term:     bsr.s     cnecin          ;warte auf Taste
          clr       -(sp)           ;Pterm0
          trap      #1              ;GEMDOS
* --------------------------------------------------------------------------
space:    lea       space_1(pc),a0  ;Zwischenraum
conws:    pea       (a0)            ;Stringadresse
          move      #9,-(sp)        ;Cconws
          trap      #1              ;GEMDOS
          addq      #6,sp           ;SP restaurieren
          rts
* --------------------------------------------------------------------------
cnecin:   move      #7,-(sp)        ;Cnecin
          trap      #1              ;GEMDOS
          addq      #2,sp
          rts
* --------------------------------------------------------------------------
cconout:  move      d0,-(sp)        ;char
          move      #2,-(sp)        ;Cconout
          trap      #1              ;GEMDOS
          addq      #4,sp
          rts
* --------------------------------------------------------------------------
* Langwort in d3 in Hex (als Text) auf Konsole ausgeben

prt_hex:  moveq     #7,d4           ;8 Nibble
nibble:   rol.l     #4,d3           ;rotieren
          move.l    d3,d0           ;holen
          andi.b    #$F,d0          ;maskieren
          addi.b    #'0',d0         ;in ASCII wandeln
          cmpi.b    #'9',d0         ;na
          ble.s     put_out         ;weg damit
          addq.b    #7,d0           ;sonst fÅr 'A'..'F'
put_out:  bsr       cconout         ;ausgeben
          dbf       d4,nibble       ;weiter geht's
          rts                       ;und zurÅck
* --------------------------------------------------------------------------
sorry:    lea       lorez(pc),a0    ;'sorry, min screen size 40 * 12!'
          bsr       conws           ;ausgeben
          bra       term            ;das war's
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
count     =    *-mem_list     ;TabellenlÑnge
          dc.w      0,0,0     ;Tabellenende

xbra:     dc.l      'XBRA',0,0
write:    dc.b      '  1234  ',0
flag_2:   dc.b      0
space_1:  dc.b      '  ',0
crlf:     dc.b      13,10,0
crlf_2:   dc.b      13,10,10,0
end_prg:  dc.b      13,10,'  final address:  ',0
none:     dc.b      '  no more XBRAø in memory!',13,10,0
title:    dc.b   13,"  xbrafind.tos    Ω br '90",13,10,10
          dc.b      '  XBRA  _old_vec  _new_vec',13,10,10,0
lorez:    dc.b      13,10,'sorry, min screen size 40 * 12!',13,10,0
* --------------------------------------------------------------------------

