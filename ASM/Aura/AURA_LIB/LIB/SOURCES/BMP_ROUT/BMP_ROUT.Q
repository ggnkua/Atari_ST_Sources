*****************************************************************************
* Kopier, L”sch- und Fllroutine (auf Speicherbl”cke). Absolut nicht gesch- *
* windigkeitsoptimiert, aber ja auch nicht fr die Verwendung an zeitkrit-  *
* ischen Stellen gedacht. Der Blitter wird NICHT benutzt.                   *
* Nicht ultragenau getestet, sollte aber fehlerfrei sein.                   *
*                                                                           *
* Start:      17.5.1995                                                     *
* Finish:     19.5.                                                         *
* Version:    1.00                                                          *
*****************************************************************************

              MC68000
              MODUL   "f:\lib\cpyclr.inc"
              OPT     D+,O+
              ORG     0

              bra.s   clr_mem           ; L”schroutine.
              bra.s   cpy_mem           ; Kopierroutine.
              bra.w   fill_mem          ; Fllt Speicher mit Blk.

              DC.B    'PMOD'
              DC.B    'Copy/Clr/Fill.',0,0
              DC.B    'Jochen Knaus',0,0,0,0
              DC.B    '05950595'
              DC.B    '010000--'
              DC.B    '--------'

*****************************************************************************
* L”scht max. 32*16KByte grožen Block.                                      *
*       a0.l  -  Blockstartadr.                                             *
*       a1.l  -  Blockendadr.                                               *
*****************************************************************************
clr_mem:      movem.l d2-a1,-(sp)

              cmpa.l  a0,a1
              bgt.s   right_order
              exg     a0,a1
right_order:  move.l  a1,d7
              sub.l   a0,d7
              move.w  d7,d6
              asr.l   #5,d7
              subq.w  #1,d7
              bmi.s   no_clr_1
clr_loop:     movem.l d2-d5,-(a1)       ; 32 Bytes l”schen.
              movem.l d2-d5,-(a1)
              dbra    d7,clr_loop
no_clr_1:     andi.w  #$1f,d6           ; Den Rest byteweise l”schen.
              subq.w  #1,d6
              bmi.s   no_clr_2
clr_rest:     clr.b   (a0)+
              dbra    d7,clr_rest
              
no_clr_2:     movem.l (sp)+,d2-a1
              rts


*****************************************************************************
* Kopiert max. 32*16KByte grožen Block.                                     *
* Die Bl”cke drfen sich NICHT berlappen.                                  *
*       a0.l  -  Source.                                                    *
*       a1.l  -  Destination.                                               *
*       d0.l  -  Anzahl Bytes.                                              *
*****************************************************************************
cpy_mem:      movem.l d6-a1,-(sp)

              cmpa.l  a0,a1
              bgt.s   right_order2
              exg     a0,a1
right_order2: move.l  d0,d7
              move.w  d7,d6
              asr.l   #5,d7
              subq.w  #1,d7
              bmi.s   no_cpy_1
cpy_loop:                               ; 32 Bytes kopieren.
        REPEAT
              move.l  (a0)+,(a1)+
        UNTIL #(8-1)
              dbra    d7,cpy_loop
no_cpy_1:     andi.w  #$1f,d6
              subq.w  #1,d6
              bmi.s   no_cpy_2
cpy_rest:     move.b  (a0)+,(a1)+       ; Rest kopieren.
              dbra    d6,cpy_rest

no_cpy_2:     movem.l (sp)+,d6-a1
              rts


*****************************************************************************
* Fllt Speicherbereich mit anderem Speicherblock.                          *
* Wenn die Aufteilung nicht aufgeht, wird NICHT mit Rest gefllt.           *
*   a0.l  -  Sourcestring.                                                  *
*   a1.l  -  Destinationbuffer.                                             *
*   a2.l  -  Destinationbufferende.                                         *
*   d0.w  -  L„nge Sourcestring.                                            *
*****************************************************************************
fill_mem:     movem.l d0-a6,-(sp)

              tst.w   d0                ; L„nge ó 0 --> sofort abbrechen.
              ble.s   no_fill

              move.l  a2,d7             ; Anzahl der zu kopierenden Bl”cke.
              sub.l   a1,d7
              divu.w  d0,d7
              subq.w  #1,d7
              bmi.s   no_fill

              movea.l a0,a2             ; Mit <cpy_mem> kopieren.
              moveq   #0,d1
              move.w  d0,d1
fill_lp:      movea.l a2,a0
              move.l  d1,d0
              bsr.w   cpy_mem
              adda.l  d1,a1                 
              dbra    d7,fill_lp

no_fill:      movem.l (sp)+,d0-a6
              rts