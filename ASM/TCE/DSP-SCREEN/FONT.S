; DSP-Screen Font-Lader 
; (c)1993 by MAXON-Computer 
; Autor: Steffen Scharfe 
; Dateiname: FONT.S

host        equ $ffffa200

            export      CopyFont 
CopyFont:   movem.l     d3-d7/a2-a6,-(sp)
            pea         super
            move.w      #$26,-(sp) 
            trap        #14 
            addq.l      #6,sp 
            movem.l     (sp)+,d3-d7/a2-a6 
            rts

super:      aline #0
            move.l      4(a1),a0    ;8*8 Font
            move.l      76(a0),a0   ;Adr Zeichensatz
            moveq       #0,d0       ;Zeichen
            lea         host,a1
CopyFont1:  lea         (a0,d0.w),a2 ;Adresse Zeichen-Font
            moveq       #8-1,d2 
CopyChar:   btst        #1,2(a1)    ;Host empty ?
            beq.s       CopyChar    ;nein 
            move.b      (a2),5(a1)  ;TXH
            move.b      (a2),6(a1)  ;TXM
            clr.b       7(a1)       ;TXL
            add.w       #256,a2 
            dbra        d2,CopyChar 
            addq.w      #1,d0
            cmp.w       #256,d0 
            bne.s       CopyFont1 
            rts
