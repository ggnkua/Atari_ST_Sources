;*******************************************************************
;*                                                                 *
;* Published in the Ledgers Disk Magazine Volume 8                 *
;*                                           Release Date : 1/2/92 *
;*                                                                 *
;*   Updated for GFA Basic by King of Disk/Charon in 26.11.1992    *
;*******************************************************************

* musiq player for .MUS files!
* most tune inits are 0 or 1, else in brackets ....
* all ripping done by Tony -B-, so greet me or else !!!

                OPT D+
                clr.l   D0
                move.b  D1,D0
                move.l  A0,mus
                move.l  A0,init+2
init:           jsr     $00
                move    #$2700,SR
                move.l  $70,oldvbl
                move.l  #vbl,$70.w
                move    #$2300,SR
                rts

vbl:
                movem.l D0-A6,retteall
                movem.l retteall2(PC),D0-A6
                movea.l mus(PC),A0
                jsr     play(A0)
                movem.l D0-A6,retteall2
                movem.l retteall(PC),D0-A6
                move.l  oldvbl(PC),end_vbl+2
end_vbl:        jmp     $00

                DATA
oldvbl:         DS.L 1
retteall:       DS.L 15
retteall2:      DS.L 15
mus:            DS.L 1

play            EQU $08
                END
