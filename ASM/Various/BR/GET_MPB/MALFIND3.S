* --------------------------------------------------------------------------
* mal_find.s  lists MD's of mal, MPB & MD's of mfl               (c) br 2/90
* 1st revision: multiple tries in backtracing thru dead MD links     br 1/91
* --------------------------------------------------------------------------
action:   move.l    4(sp),a0            ;basepage addr
          lea       mystk,a1            ;end of code
          move.l    a1,sp               ;new sp
          suba.l    a0,a1               ;prog length

          move.l    a1,-(sp)            ;newsize
          move.l    a0,-(sp)            ;block
          clr       -(sp)               ;filler
          move.w    #$4A,-(sp)          ;Mshrink
          trap      #1                  ;GEMDOS
          lea       $C(sp),sp

start:    dc.w      $A000               ;line_a init
          cmpi      #79,-$2C(a0)        ;v_cel_mx: minimum #columns = 80
          blt       sorry               ;schade!
          cmpi      #24,-$2A(a0)        ;v_cel_my: minimum #lines = 25
          blt       sorry               ;traurig!

          lea       title1(pc),a0       ;Titelzeile
          bsr       conws               ;ausgeben
          lea       subtit(pc),a0       ;Untertitel
          bsr       conws               ;ausgeben

          pea       main(pc)
          move      #$26,-(sp)          ;Supexec
          trap      #14                 ;XBIOS
          addq      #6,sp

term:     bsr       cnecin              ;warte auf Taste
          clr       -(sp)               ;Pterm0
          trap      #1                  ;GEMDOS
* --------------------------------------------------------------------------
main:     lea       $48E,a3     ;themd = letzter MD der mal
          lea       $2000,a4    ;Endadresse
          movea.l   $432,a5     ;Startadresse = membot
          bsr       show_md     ;zum Display (a3 -> MD)

loop_0:   movea.l   a5,a0       ;Startadresse = membot
          moveq     #0,d6       ;VersuchszÑhler
loop_1:   subq      #2,a0       ;nur gerade Adressen
          cmpa.l    a0,a4       ;Endadresse erreicht?
          bhi       stuck       ;fertig

          cmpa.l    (a0),a3     ;Zeiger da ?
          bne       loop_1      ;weiter testen

* PlausibilitÑts-Tests fÅr MD's, falls (a0) = mp_mal/mp_rover - kritisch!

          btst      #0,15(a0)   ;m_own gerade? (!)
          bne       loop_1      ;weiter testen
          btst      #0,7(a0)    ;m_start gerade? (!)
          bne       loop_1      ;weiter testen
          btst      #0,11(a0)   ;m_length gerade? (!)
          bne       loop_1      ;weiter testen
          tst.b     8(a0)       ;m_length > 16 MB? (!)
          bne       loop_1      ;weiter testen

          move.l    a0,a3       ;neuer MD ?
          bsr       show_md     ;als Eintrag der 'mal' ausgeben

*          move.l    -4(a3),d0   ;mp_mfl leer?
*          beq.s     loop_1
*          cmp.l     4(a3),d0    ;mp_mfl = mp_rover ?
*          beq.s     weiter

*          move.l    -8(a3),d0   ;mp_rover erwischt?
*          cmp.l     (a3),d0     ;mp_mfl = mp_rover ?
*          beq       gotcha      ;ok! 

*          tst.l     -8(a3)      ;ist's der mp_mal?
*          beq       thats_it    ;ok! 

weiter:   tst.l     12(a3)      ;m_own = 0 ? (!!!)
          bne       loop_0      ;nÑchsten Zeiger suchen

thats_it: lea       marker(pc),a0       ;als ungÅltig 
          bsr       conws               ;markieren
          lea       title3(pc),a0       ;neue öberschrift
          bsr       conws               ;ausgeben
          subq      #4,a3               ;Adresse mpb
          move.l    a3,d3               ;umrechnen und
          bsr       prt_hex             ;ausgeben
          moveq     #5,d4
sp_loop:  bsr.s     space               ;Zwischenraum
          dbf       d4,sp_loop
          move.l    (a3),d3             ;mp_mfl
          bsr       prt_hex             ;ausgeben
          bsr.s     space               ;Zwischenraum
          move.l    4(a3),d3            ;mp_mal
          bsr       prt_hex             ;ausgeben
          bsr.s     space               ;Zwischenraum
          move.l    8(a3),d3            ;mp_rover
          bsr       prt_hex             ;ausgeben
          lea       crlf2(pc),a0        ;2 * CR LF
          bsr.s     conws               ;ausgeben
          lea       title2(pc),a0       ;letzte Titelzeile
          bsr.s     conws               ;ausgeben
          lea       subtit(pc),a0       ;Untertitel
          bsr.s     conws               ;ausgeben

loop_2:   tst.l     (a3)                ;und jetzt
          beq.s     return              ;schîn
          move.l    (a3),a3             ;einfach
          bsr.s     show_md             ;die 'mfl' ausgeben
          bra       loop_2
return:   rts

*gotcha:   subq      #4,a3               ;es war der mp_rover!
*          bra       thats_it

stuck:    lea       marker(pc),a0       ;als ungÅltig
          bsr.s     conws               ;markieren
          addq      #1,d6               ;# Versuche hochzÑhlen
          move.l    a3,a0               ;ab hier weiter suchen
          move.l    (a3),a3             ;wieder alten Zeiger nehmen
          cmp       #10,d6              ;max. Anzahl der Versuche = 11
          bls       loop_1              ;nochmal versuchen!
          lea       sticky(pc),a0       ;leider
          bsr.s     conws               ;steckengeblieben!
          rts
* --------------------------------------------------------------------------
show_md:  lea       crlf(pc),a0         ;CR LF
          bsr.s     conws               ;ausgeben
          move.l    a3,d3               ;md_addr
          bsr.s     prt_hex             ;ausgeben
          bsr.s     space               ;Zwischenraum ausgeben
          moveq     #3,d5               ;4 Werte
next_1:   move.l    (a3)+,d3            ;Wert holen
          bsr.s     prt_hex             ;ausgeben
          bsr.s     space               ;Zwischenraum
          dbf       d5,next_1           ;um durchzuschaun
          lea       -16(a3),a3          ;a3 restaurieren
          rts
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

prt_hex:  moveq     #7,d7               ;8 mal
nibble:   rol.l     #4,d3               ;jeweils ein Nibble
          move      d3,d0               ;ans Ende rollen
          andi      #$000f,d0           ;isolieren
          lea       hextab(pc),a0       ;Hextabelle holen
          move.b    0(a0,d0.w),d0       ;und Zeichen
          bsr       cconout             ;ausgeben
          dbf       d7,nibble           ;weiter
          rts
* --------------------------------------------------------------------------
sorry:    lea       lorez(pc),a0        ;'sorry, min screen size 80 * 25!'
          bsr       conws               ;ausgeben
          bra       term                ;das war's
* --------------------------------------------------------------------------
hextab:   dc.b '0123456789ABCDEF'
title1:   dc.b 13,'mal: memory allocated list          (c) br 90,91',13,10,0
subtit:   dc.b    'md_addr   m_link    m_start   m_length  m_own',13,10
          dc.b    '------------------------------------------------',13,0
title2:   dc.b 13,'mfl: memory free list               (c) br 90,91',13,10,0
title3:   dc.b 13,10,10,'mpb: memory parameter block         (c) br 90,91',13,10
          dc.b          'mpb_addr            mp_mfl    mp_mal    mp_rover',13,10
          dc.b          '------------------------------------------------',13,10,0
sticky:   dc.b    13,10,'* * * * * *    sorry,  got stuck!    * * * * * *',13,10,0
space_1:  dc.b      '  ',0
crlf2:    dc.b      10
crlf:     dc.b      13,10,0
marker:   dc.b      '<invalid! ',0
lorez:    dc.b      13,10,'sorry, min screen size 80 * 25!',13,10,0
* --------------------------------------------------------------------------
          even
          bss
          ds.l      100
mystk:
* --------------------------------------------------------------------------
