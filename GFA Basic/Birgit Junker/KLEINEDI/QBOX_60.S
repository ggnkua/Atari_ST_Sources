; Aufruf ~C:mcode%(W:lineoff%,W:blockstart%,W:blockend%,W:scr_zeile%)
; Soll eine Box zeichnen (XOR)

          movem.w   4(sp),d1-d4

          cmp.w     d2,d1     ; Line-Offset=Blockstart oder gr”žer?
          blt.s     abbruch   ; Nein, dann Ende
          cmp.w     d3,d1     ; Line-Offset<Blockend?
          bge.s     abbruch   ; Nein, dann Ende

          subq.w    #1,d4     ; Bildschirmzeile'1' ist Screen-Adr'0'
          mulu.w    #1280,d4  ; Offset fr Screen-Adr
          movea.l   screen(pc),a0       ; Screen-Adresse aus INLINE
          adda.w    d4,a0     ; Zu Screen-Adr hinzu

          moveq.l   #31,d0
          moveq.l   #$ffffffff,d5       ; ein Linienmuster...

box:      eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          eor.l     d5,(a0)+
          dbra      d0,box

abbruch:  rts       

          .EVEN 
          .DATA 
screen:   .DS.l 1
          .END 
