                XDEF  sqrt_nyh1

; unsigned long wortel(unsigned long value);

						    TEXT
						      
; Aanroep: D0: Long Int
; Return:  D0: SQRT(D0)
;
; Trekt de wortel uit de long integer D0, antwoord staat weer in D0
;

sqrt_nyh1:
                move.l  d3,a0
                move.l  #$40000000,d1   ; mask
                moveq   #0,d2           ; result=0
loop:
                move.l  d2,d3           ; tmp=result
                add.l   d1,d3           ; tmp+=mask
                lsr.l   #1,d2           ; result>>=1
                cmp.l   d3,d0           ; x-tmp<0?
                bcs.s   cont            ; yep
                sub.l   d3,d0           ; x-=tmp
                add.l   d1,d2           ; result+=mask
cont:
                lsr.l   #2,d1           ; mask>>=2;
                bne.s   loop            ; nogmal
                move.l  d2,d0           ; d0=result
                move.l  a0,d3
                rts                     ; Einde

                END
