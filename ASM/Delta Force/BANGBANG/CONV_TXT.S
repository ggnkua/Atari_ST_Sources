;convert ascii to small-scroller
; Megarast

                OPT X+
; von dest bis a1 saven

x:
                movea.l #source,A0
                movea.l #dest,A1
                movea.l #contab,A2
prepare:
                moveq   #0,D0
                move.b  (A0)+,D0
                beq.s   convende
                cmp.b   #$0a,D0
                beq.s   prepare
                cmp.b   #$0d,D0
                beq.s   prepare
                move.b  0(A2,D0.w),(A1)+
                bra.s   prepare
convende:
                move.b  #-1,(A1)+
                illegal

;-----------------------------
contab:         DCB.B 33,26      ; 0-32
                DC.B 41,37,26,26,26,26,37,38,39,26,26,42,26,43,26 ; Sonder
                DC.B 27,28,29,30,31,32,33,34,35,36 ; 0-9
                DC.B 26,42,26,26,26,40,26 ; Sonder
                DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
                DC.B 18,19,20,21,22,23,24,25 ; A-Z
                DCB.B 6,26
                DC.B 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17
                DC.B 18,19,20,21,22,23,24,25 ; a-z
                DCB.B 133,26

                EVEN

source:         INCBIN 'TEXT.TXT'
end_text:
text_length     EQU end_text-source
                EVEN

dest:           DS.B text_length+100


