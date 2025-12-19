    .EXPORT dither_216c

* Equivalences structure MFDB
FD_ADDR     EQU  0
FD_W        EQU  4
FD_H        EQU  6
FD_WDWIDTH  EQU  8
FD_STAND    EQU 10
FD_NPLANES  EQU 12
FD_R1       EQU 14
FD_R2       EQU 16
FD_R3       EQU 18

*
* Trame une image TC 15, 16, 24 ou 32 bits (format FALCON)
* En une image 216 couleurs au format naturel 1 octet = 1 pixel
* Les indices utilises sont [16...231] afin d'eviter une
* Distinction entre indices TOS et VDI
* void dither_216c(MFDB *in, unsigned char *indexes)
*                        A0                 A1
*

dither_216c:
    MOVEM.L   D2-D7/A2-A6,-(SP) ; Sauvegarde du contexte

* Init des variables
    LEA.L     mat16_16,A2        ; A2 --> Matrice 16x16
    MOVE.W    FD_W(A0),D4
    SUBQ.W    #1,D4              ; D4 = nb colonnes - 1
    MOVE.W    FD_H(A0),D6
    SUBQ.W    #1,D6              ; D6 = nb lignes source - 1
    MOVE.L    A1,A3              ; A3 --> indices destination 
    MOVE.W    FD_NPLANES(A0),D7  ; D7 = nb plans
    MOVE.L    FD_ADDR(A0),A1     ; A1 --> image source
    LEA.L     restes(PC),A0      ; A0 --> restes
    LEA.L     quot_vert6(PC),A5  ; A5 --> quot_vert
    LEA.L     quot_bleu36(PC),A6 ; A6 --> quot_bleu
                                 ; quot_rouge peut etre adresse par PC
    MOVEQ.L   #0,D0
    MOVEQ.L   #16,D5             ; Pour ajout indice >= 16 (24/32bit)
    MOVEQ.L   #0,D1              ; For 16bit: scratch register, for 24bit:0, for 32bit:1

* Determination du nombre de plans de l'image source
    CMPI.W    #15,D7
    BEQ       dither_216c_16b
    CMPI.W    #16,D7
    BEQ       dither_216c_16b
    CMPI.W    #24,D7
    BEQ       dither_216c_24b
    CMPI.W    #32,D7
    BNE       dither_216c_rts
    MOVEQ.L   #1,D1
    BRA       dither_216c_24b

tab_32K:
   DC.B 000, 008, 016, 025, 033, 041, 049, 058
   DC.B 065, 074, 082, 090, 099, 107, 115, 123
   DC.B 132, 140, 148, 156, 165, 173, 181, 189
   DC.B 197, 206, 214, 222, 230, 239, 247, 255


dither_216c_16b:
    MOVE.W    D4,D7
    LEA.L     16(A2),A4
pixel_16b:
    MOVE.B    (A2)+,D2
    MOVE.W    (A1)+,D1       ; D1 = RRRRRVVVVVVBBBBB
    MOVE.W    D1,D0
    ROL.W     #5,D0
    ANDI.W    #$1F,D0
    MOVE.B    tab_32K(PC,D0.W),D0
    MOVE.L    A3,D5
    LEA.L     quot_rouge(PC),A3
    MOVE.B    (A3,D0.W),D3
    MOVE.L    D5,A3
    CMP.B     (A0,D0.W),D2
    BCC.S     pas_rouge_16b
    ADDQ.B    #1,D3
pas_rouge_16b:
    MOVE.W    D1,D0
    LSR.W     #6,D0
    ANDI.W    #$1F,D0
    MOVE.B    tab_32K(PC,D0.W),D0
    ADD.B     (A5,D0.W),D3
    CMP.B     (A0,D0.W),D2
    BCC.S     pas_vert_16b
    ADDQ.B    #6,D3
pas_vert_16b:
    MOVE.W    D1,D0
    ANDI.W    #$1F,D0
    MOVE.B    tab_32K(PC,D0.W),D0
    ADD.B     (A6,D0.W),D3
    CMP.B     (A0,D0.W),D2
    BCC.S     pas_bleu_16b
    ADD.B     #36,D3
pas_bleu_16b:
    ADD.B     #16,D3      ; Pour 16 <= index < 232
    MOVE.B    D3,(A3)+
    CMPA.L    A2,A4
    BNE.S     pas_fin_16b
    LEA.L     -16(A4),A2
pas_fin_16b:
    DBF       D7,pixel_16b
    CMP.L     #mat16_16+256,A4
    BNE.S     pas_fin_mat_16b
    LEA.L     -256(A4),A4
pas_fin_mat_16b:
    MOVE.L    A4,A2
    DBF       D6,dither_216c_16b

    BRA       dither_216c_rts


dither_216c_24b:
    MOVE.W    D4,D7
    LEA.L     16(A2),A4
pixel_24b:
    MOVE.B    (A2)+,D2
    MOVE.B    (A1)+,D0       ; D0 = rouge
    MOVE.B    quot_rouge(PC,D0.W),D3
    CMP.B     (A0,D0.W),D2
    BCC.S     pas_rouge_24b
    ADDQ.B    #1,D3
pas_rouge_24b:
    MOVE.B    (A1)+,D0
    ADD.B     (A5,D0.W),D3
    CMP.B     (A0,D0.W),D2
    BCC.S     pas_vert_24b
    ADDQ.B    #6,D3
pas_vert_24b:
    MOVE.B    (A1)+,D0
    ADD.B     (A6,D0.W),D3
    CMP.B     (A0,D0.W),D2
    BCC.S     pas_bleu_24b
    ADD.B     #36,D3
pas_bleu_24b:
    ADD.B     D5,D3      ; Pour 16 <= index < 232
    MOVE.B    D3,(A3)+
    CMPA.L    A2,A4
    BNE.S     pas_fin_24b
    LEA.L     -16(A4),A2
pas_fin_24b:
    ADD.L     D1,A1          ; +1 if 32bit
    DBF       D7,pixel_24b
    CMP.L     #mat16_16+256,A4
    BNE.S     pas_fin_mat_24b
    LEA.L     -256(A4),A4
pas_fin_mat_24b:
    MOVE.L    A4,A2
    DBF       D6,dither_216c_24b

    BRA       dither_216c_rts

dither_216c_rts:
    MOVEM.L   (SP)+,D2-D7/A2-A6 ; Restauration du contexte
    RTS

quot_rouge:
   DCB.B     51,0
   DCB.B     51,1
   DCB.B     51,2
   DCB.B     51,3
   DCB.B     51,4
   DC.B      5

quot_vert6:
   DCB.B     51,0
   DCB.B     51,6
   DCB.B     51,12
   DCB.B     51,18
   DCB.B     51,24
   DC.B      30

quot_bleu36:
   DCB.B     51,0
   DCB.B     51,36
   DCB.B     51,72
   DCB.B     51,108
   DCB.B     51,144
   DC.B      180

restes:
   REPT 5
   VAL=0
   REPT 51
   DC.B VAL
   VAL = VAL+1
   ENDM
   ENDM
   DC.B 0

mat16_16:
   DC.B    34, 05, 21, 44, 32, 03, 20, 42, 33, 04, 21, 43, 35, 06, 22, 44
   DC.B    15, 50, 28, 12, 13, 48, 26, 10, 14, 49, 27, 11, 15, 51, 28, 12
   DC.B    31, 08, 18, 47, 29, 07, 16, 45, 30, 08, 17, 46, 32, 09, 19, 48
   DC.B    25, 41, 37, 02, 23, 39, 36, 00, 24, 40, 37, 01, 25, 41, 38, 03
   DC.B    33, 04, 20, 43, 35, 06, 22, 45, 34, 05, 21, 43, 33, 04, 20, 42
   DC.B    14, 49, 27, 10, 16, 51, 29, 13, 14, 50, 27, 11, 13, 49, 26, 10
   DC.B    30, 07, 17, 46, 32, 09, 19, 48, 31, 08, 18, 47, 30, 07, 17, 46
   DC.B    23, 39, 36, 01, 26, 42, 38, 03, 24, 40, 37, 02, 23, 39, 36, 01
   DC.B    34, 05, 21, 44, 33, 04, 20, 42, 33, 04, 20, 43, 35, 06, 22, 45
   DC.B    15, 50, 28, 11, 13, 49, 26, 10, 14, 49, 27, 11, 16, 51, 29, 12
   DC.B    31, 08, 18, 47, 29, 07, 16, 45, 30, 07, 17, 46, 32, 09, 19, 48
   DC.B    24, 40, 37, 02, 23, 39, 36, 00, 24, 40, 36, 01, 25, 41, 38, 03
   DC.B    34, 05, 21, 43, 35, 06, 22, 44, 34, 05, 22, 44, 32, 03, 19, 42
   DC.B    14, 50, 27, 11, 15, 51, 28, 12, 15, 50, 28, 12, 13, 48, 26, 10
   DC.B    30, 08, 18, 46, 31, 09, 19, 47, 31, 09, 18, 47, 29, 06, 16, 45
   DC.B    24, 40, 37, 01, 25, 41, 38, 02, 25, 41, 38, 02, 23, 39, 35, 00
   