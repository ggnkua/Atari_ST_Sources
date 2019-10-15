start:          pea     supinit(pc)
                move.w  #$26,-(sp)
                trap    #14             ; Routine im Supervisor!
                addq.l  #6,sp

                clr.w   -(sp)
                pea     end-start+$0100 ; Programml„nge
                move.w  #$31,-(sp)
                trap    #1              ;Ptermres()

supinit:        lea     oldvec(pc),a0   ; XBRA-Protokoll setzen
                move.l  $0408,(a0)+
                move.l  a0,$0408
                rts

                dc.b 'XBRA'     ; XBRA
                dc.b '__EV'     ; XBRA-ID
oldvec:         ds.l 1          ; Alter-Vektor

                pea     mypalette(pc)
                move.w  #6,-(sp)
                trap    #14             ; Palette setzen
                addq.l  #6,sp
                move.l  oldvec(pc),-(sp) ; alte Routine
                rts                     ; auch noch aufrufen

mypalette:      dc.w $0e7f,$0f00,$03d1,$0ff0,$0d6f,$0f0f
                dc.w $ff,$0555,$0333,$0fcc,$05fd,$0ffc
                dc.w $0ccf,$0fcf,$0cff,$0a

end:            end
