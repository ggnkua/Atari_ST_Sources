
MAIN:
        LEA     DATA,A3
        CLR.W   -(A7)                   ; Ouvre offset en ASCII
        PEA     ascii_nom
        MOVE.W  #$3C,-(A7)
        TRAP    #1
        ADDQ    #8,A7
        MOVE.W  D0,ascii_hdl
        MOVE.W  #15,D4
STRN2HX:
        LEA     tabhexa+11,A2
        MOVE.W  #9,D3
STRN1HX:
        MOVE.W  (A3)+,nombre
        MOVE.L  A2,A1
        BSR     PRINTHEX
        ADDQ    #6,A2
        DBF     D3,STRN1HX
        MOVEM.L D0-D7/A0-A6,-(A7)       ; Sauve une ligne
        PEA     tabhexa
        MOVE.L  #71,-(A7)               ; taille une ligne
        MOVE.W  ascii_hdl,-(A7)
        MOVE.W  #$40,-(A7)
        TRAP    #1
        LEA     12(A7),A7
        MOVEM.L (A7)+,D0-D7/A0-A6
        DBF     D4,STRN2HX
        MOVE.W  ascii_hdl,-(A7)         ; Ferme fichier
        MOVE.W  #$3E,-(A7)
        TRAP    #1
        ADDQ    #4,A7
	illegal

PRINTHEX:
        CLR.L   D0
        MOVE.W  nombre,D0
        LEA     dathexa,A0
        ADDQ    #4,A1
        MOVE.W  #3,D2
PRNT1HEX:
        MOVE.B  D0,D1
        ANDI.W  #$F,D1
        MOVE.B  0(A0,D1.W),-(A1)
        LSR.L   #4,D0
        DBF     D2,PRNT1HEX
        RTS
nombre:
	dc.w	0
ascii_hdl:
        DC.W    0
ascii_nom:
        DC.B    'TLONG8.S',0
tabhexa:
        DC.B    '   DC.W   $0000,$0000,$0000,$0000,$0000,$0000,'
        DC.B    '$0000,$0000,$0000,$0000',$d,$a
dathexa:
        DC.B    '0','1','2','3','4','5','6','7','8','9'
        DC.B    'A','B','C','D','E','F' 
        EVEN
data:
        blk.w   100

