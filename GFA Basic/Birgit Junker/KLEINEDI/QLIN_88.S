; Aufruf ~C:mcode%(W:line_off%,W:form_len%,W:zeile%)
; Soll eine Linie ziehen, Screen-Adr im INLINE

          movem.w   4(sp),d1-d3
          moveq.l   #1,d4     ; die 1 in d4

          cmp.w     d4,d1     ; Offset>1
          ble.s     abbruch   ; Nein, dann Ende

          sub.w     d4,d1
          ext.l     d1
          divu.w    d2,d1     ; Line-Offset/Form_len -> d1
          andi.l    #$ffff0000,d1       ; die unteren 16 Bit auf 0 setzen
          tst.l     d1        ; ist ein Rest vorhanden?
          bne.s     abbruch   ; Ja, dann Ende

          sub.w     d4,d3     ; Bildschirmzeile eins kleiner
          mulu.w    #1280,d3  ; Offset fÅr Screen-Adr
          movea.l   screen(pc),a0       ;Screen-Adr aus Speicherbereich
          adda.w    d3,a0     ; Zu Screen-Adr hinzu
          moveq.l   #$ffffffff,d5       ; ein Linienmuster...

          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+
          move.l    d5,(a0)+

abbruch:  rts       

          .EVEN 
          .DATA 
screen:   .DS.l 1
          .END 




