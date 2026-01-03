time      equ       21000

nvbls      equ      $454           * anzahl der vertical blank routinen
_vblqueue  equ      $456           * zeiger auf liste mit nvbls routinen
_dumpflg   equ      $4ee           * dumpflag fÅr alt-help-taste
_v_bas_ad  equ      $44e           * logische bildadresse

          .text
dummy:    bra.b     scrdmp
liss:     dc.b      0,'Liss',0     * Ω
scrdmp:   move.l    4(a7),a6       * base page adresse
          move.l    #$100,d7       * programmlÑnge berechnen
          add.l     12(a6),d7
          add.l     20(a6),d7
          add.l     28(a6),d7

          move.l    #init,-(a7)    * initialisierung im supervisor
          move.w    #38,-(a7)      * ausfÅhren
          trap      #14
          addq.l    #6,a7

          lea       ust,a7
          clr.w     -(a7)
          move.l    d7,-(a7)       * programmlÑnge
          move.w    #$31,-(a7)     * kepp process
          trap      #1             * programm im speicher halten

********************** programm ************************

init:     move.w    nvbls,d0       * anzahl der Slots
          lsl.w     #2,d0          * mal 4 = zahl der bytes
          movea.l   _vblqueue,a0   * liste der slots

          move.w    #4,d1
suche:    tst.l     (a0,d1)        * freien slot suchen
          beq.b     gefunden
          addq.w    #4,d1
          cmp.w     d0,d1
          bne.b     suche
          rts                      * keinen gefunden

gefunden: lea       (a0,d1),a1     * routine in vblqueue einbinden
ust:      move.l    #start,(a1)
          rts

start:    tst.w     ypos
          beq.b     weit1
          bsr.b     draw
          rts
weit1:    subq.w    #1,_time
          tst.w     _time
          bgt.b     weit2
          bsr.b     draw
          move.w    #time,_time
          rts
weit2:    tst.w     _dumpflg       * auf alt-help testen
          bne.b     return
          bsr.b     draw
          move.w    #-1,_dumpflg
return:   rts

draw:     clr.l     d0
          clr.l     d1
          move.w    xpos,d1
          add.w     ypos,d1
          move.l    #8,d0
          move.l    _v_bas_ad,a1
          lea       pattern,a0
loop:     move.b    (a0)+,(a1,d1)
          add.w     #80,d1
          dbf       d0,loop
          move      ymax,d1
          cmp.w     ypos,d1
          blt.b     res
          add.w     #80,ypos
          rts
res:      clr.w     ypos
          move.w    xpos,d0
          add.w     #33,d0
          divu      #80,d0
          swap      d0
          move.w    d0,xpos
          add.w     #3333,d1
          divu      #31200,d1
          swap      d1
          add.w     #240,d1
          move.w    d1,ymax
          rts

          .data
xpos:     dc.w      31
ypos:     dc.w      0
ymax:     dc.w      24000
_time:    dc.w      time

pattern:  dc.b      %00010000
          dc.b      %01111100
          dc.b      %10111010
          dc.b      %10111010
          dc.b      %00111000
          dc.b      %01010100
          dc.b      %10111010
          dc.b      %10000010
          dc.b      %00000000
          .end


