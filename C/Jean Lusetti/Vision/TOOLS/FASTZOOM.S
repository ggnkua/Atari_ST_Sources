**********************************************
* Routines rapides de zoom x2, x4, x8 et x16 *
**********************************************
    .EXPORT fast_zoom
    .EXPORT fz_tab2, fz_tab4, fz_tab8, fz_tab16

* Equivalences structure FZOOM_DATA
SRC         EQU  0
DST         EQU  4
ZOOM        EQU  8


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


* Pointeur sur la table des pr‚-calculs
fz_tab2:     DC.L     0
fz_tab4:     DC.L     0
fz_tab8:     DC.L     0
fz_tab16:    DC.L     0


************************************
* void fast_zoom(FZOOM_DATA *data) *
*                            A0    *
************************************
fast_zoom:
    MOVEM.L   D0-D7/A0-A6,-(SP)  ; Sauvegarde du contexte

* Chargement des variables communes
    MOVE.L    SRC(A0),A1         ; A1 = data->src
    MOVE.L    DST(A0),A2         ; A2 = data->dst
                                 ; A0 = data
    MOVE.W    FD_WDWIDTH(A1),D0
    SUBQ.W    #1,D0              ; Pour DBF
    MOVE.W    D0,wdwidth

    MOVE.W    FD_NPLANES(A1),D0  ; D0 = src->fd_nplanes
    SUB.W     #1,D0              ; Pour DBF
    MOVE.W    D0,nplanes

    MOVE.W    FD_NPLANES(A1),D2
    MULU.W    FD_WDWIDTH(A1),D2
    ADD.L     D2,D2              ; D2 = nb d'octets / ligne de la source

    MOVE.W    FD_NPLANES(A2),D3
    MULU.W    FD_WDWIDTH(A2),D3  ; D3 = nb mots sur une ligne dst
* Precalcul offset JMP
    MOVE.W    D3,D7
    SWAP      D3
    MOVE.W    D7,D3
    LSR.W     #1,D3              ; On recopiera des mots longs
    ANDI.W    #$0F,D3
    ADD.W     D3,D3
    NEG.W     D3
    SWAP      D3                 ; D3.LOW = nb mots sur une ligne dst
                                 ; D3.HIGH = offset JMP

    MOVE.W    FD_H(A1),D4        ; D4 = nb de lignes … zoomer
    SUBQ.W    #1,D4              ; -1 pour DBF

    MOVE.L    FD_ADDR(A1),A3
    MOVE.L    A3,A5
    MOVE.L    FD_ADDR(A2),A4

    MOVE.W    FD_NPLANES(A1),D7
    ADD.W     D7,D7              ; D7 = nb octets pour 16 pixels fmt atari

    MOVE.W    ZOOM(A0),D5
    LSR.W     #1,D5
    LSL.W     #2,D5              ; Pour calcul adresse
    MOVE.L    level_rout(PC,D5.W),A0
    JMP       (A0)

     .EVEN
level_rout:
    DC.L      level_null, level_2,    level_4,    level_null 
    DC.L      level_8,    level_null, level_null, level_null
    DC.L      level_16


    MACRO     COPY16
* A0 --> Src
* A1 --> Dst
* D3 = LOW  : nb de mots 16 bits
*      HIGH : offset pour JMP
    MOVE.W    D3,D6
    LSR.W     #5,D6
    BTST      #0,D3              ; Nombre impair de mots 16 bits ?
    BEQ       2
    MOVE.W    (A0)+,(A1)+        ; oui : on en copie un, le reste c'est du 32 bits
    SWAP      D3
    JMP       2+2*16(PC,D3.W)
    REPT 16
    MOVE.L    (A0)+,(A1)+
    ENDM
    DBF       D6,-2-2*16
    SWAP      D3

    ENDM


level_null:
    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS

level_2:
    MOVE.L    fz_tab2(PC),A6     ; A6 -->fz_tab
    CMPI.W    #7,D0
    BLE       zl2
    CMPI.W    #15,D0
    BEQ       zl2_16
    CMPI.W    #23,D0
    BEQ       zl2_24
    CMPI.W    #31,D0
    BEQ       zl2_32

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS                          ; Retour au programme C

level_4:
    MOVE.L    fz_tab4(PC),A6     ; A6 -->fz_tab
    CMPI.W    #7,D0
    BLE       zl4
    CMPI.W    #15,D0
    BEQ       zl4_16
    CMPI.W    #23,D0
    BEQ       zl4_24
    CMPI.W    #31,D0
    BEQ       zl4_32

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS                          ; Retour au programme C

level_8:
    MOVE.L    fz_tab8(PC),A6     ; A6 -->fz_tab
    CMPI.W    #7,D0
    BLE       zl8
    CMPI.W    #15,D0
    BEQ       zl8_16
    CMPI.W    #23,D0
    BEQ       zl8_24
    CMPI.W    #31,D0
    BEQ       zl8_32

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS                          ; Retour au programme C

level_16:
    MOVE.L    fz_tab16(PC),A6    ; A6 -->fz_tab
    CMPI.W    #7,D0
    BLE       zl16
    CMPI.W    #15,D0
    BEQ       zl16_16
    CMPI.W    #23,D0
    BEQ       zl16_24
    CMPI.W    #31,D0
    BEQ       zl16_32

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS                          ; Retour au programme C

nb_lines:   DC.W       0
wdwidth :   DC.W       0
nplanes:    DC.W       0
************
* Zooms x2 *
************
zl2:
    MOVE.W    wdwidth(PC),D6
    SWAP      D4
zwd2:
    MOVE.W    D0,D1    ;  D1 = nb_planes -1 pour DBF
zp2:
    MOVEQ.L   #0,D5
    MOVE.W    D5,D4

    MOVE.B    (A5)+,D5
    MOVE.B    (A5)+,D4

    ADD.W     D4,D4
    MOVE.W    (A6,D4.W),(A4,D7.W)

    ADD.W     D5,D5
    MOVE.W    (A6,D5.W),(A4)+

    DBF       D1,zp2                ; plan suivant
    ADD.W     D7,A4
    DBF       D6,zwd2               ; 16 pixels du plan de la ligne

    MOVE.W    D3,D5
    ADD.W     D5,D5
    MOVE.L    A4,A0
    SUB.W     D5,A0
    MOVE.L    A4,A1

    COPY16

    MOVE.L    A1,A4
    ADD.L     D2,A3
    SWAP      D4
    DBF       D4,zl2                 ; ligne suivante

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS


zl2_16:
    MOVE.L    A4,A6
    MOVE.W    wdwidth(PC),D5
zll2_16:
    MOVE.W    D5,D0
    MOVE.L    A6,A4
zw2_16:
    REPT 16
    MOVE.W    (A5)+,D1
    MOVE.W    D1,(A6)+
    MOVE.W    D1,(A6)+
    ENDM
    DBF       D0,zw2_16

    MOVE.L    A4,A0
    MOVE.L    A6,A1
    COPY16
    MOVE.L    A1,A6
    DBF       D4,zll2_16

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    
zl2_24:
    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS

zl2_32:
    MOVE.L    A4,A6
    MOVE.W    wdwidth(PC),D5
zll2_32:
    MOVE.W    D5,D0
    MOVE.L    A6,A4
zw2_32:
    REPT 16
    MOVE.L    (A5)+,D1
    MOVE.L    D1,(A6)+
    MOVE.L    D1,(A6)+
    ENDM
    DBF       D0,zw2_32

    MOVE.L    A4,A0
    MOVE.L    A6,A1
    COPY16
    MOVE.L    A1,A6
    DBF       D4,zll2_32

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    

************
* Zooms x4 *
************
zl4:
    MOVE.W    wdwidth(PC),D6
    SWAP      D4
zwd4:
    MOVE.W    D0,D1    ;  D1 = nb_planes -1 pour DBF
zp4:
    MOVEQ.L   #0,D5
    MOVE.W    D5,D4

    MOVE.B    (A5)+,D5
    MOVE.B    (A5)+,D4

    ADD.W     D7,A4
    ADD.W     D7,A4

    ADD.W     D4,D4
    ADD.W     D4,D4
    MOVE.W    (A6,D4.W),(A4)
    MOVE.W    2(A6,D4.W),(A4,D7.W)

    SUB.W     D7,A4
    SUB.W     D7,A4

    ADD.W     D5,D5
    ADD.W     D5,D5
    MOVE.W    2(A6,D5.W),(A4,D7.W)
    MOVE.W    (A6,D5.W),(A4)+
    DBF       D1,zp4                ; plan suivant
    ADD.W     D7,A4
    ADD.W     D7,A4
    ADD.W     D7,A4
    DBF       D6,zwd4               ; 16 pixels du plan de la ligne

    MOVE.W    D3,D5
    ADD.W     D5,D5
    MOVE.L    A4,A0
    SUB.W     D5,A0
    MOVE.L    A4,A1

    MOVEQ.L   #3-1,D1
cp_line4:
    COPY16
    DBF       D1,cp_line4

    MOVE.L    A1,A4
    ADD.L     D2,A3
    SWAP      D4
    DBF       D4,zl4                 ; ligne suivante

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS


zl4_16:
    MOVE.L    A4,A6
    MOVE.W    wdwidth(PC),D5
zll4_16:
    MOVE.W    D5,D0
    MOVE.L    A6,A4
zw4_16:
    REPT 16
    MOVE.W    (A5)+,D1
    REPT 4
    MOVE.W    D1,(A6)+
    ENDM
    ENDM
    DBF       D0,zw4_16

    MOVE.L    A4,A0
    MOVE.L    A6,A1
    MOVEQ.L   #3-1,D1
cp_line4_16:
    COPY16
    DBF       D1,cp_line4_16
    MOVE.L    A1,A6
    DBF       D4,zll4_16

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    
zl4_24:
    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    
zl4_32:
    MOVE.L    A4,A6
    MOVE.W    wdwidth(PC),D5
zll4_32:
    MOVE.W    D5,D0
    MOVE.L    A6,A4
zw4_32:
    REPT 16
    MOVE.L    (A5)+,D1
    REPT 4
    MOVE.L    D1,(A6)+
    ENDM
    ENDM
    DBF       D0,zw4_32

    MOVE.L    A4,A0
    MOVE.L    A6,A1
    MOVEQ.L   #3-1,D1
cp_line4_32:
    COPY16
    DBF       D1,cp_line4_32
    MOVE.L    A1,A6
    DBF       D4,zll4_32

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    

************
* Zooms x8 *
************
zl8:
    MOVE.W    wdwidth(PC),D6
zwd8:
    MOVE.W    nplanes(PC),D1    ;  D1 = nb_planes -1 pour DBF
zp8:
    MOVEQ.L   #0,D5
    MOVE.B    (A5)+,D5
    LSL.W     #3,D5
    MOVE.L    A4,D0
    ADD.W     D5,A6
    REPT      4
    MOVE.W    (A6)+,(A4)
    ADD.W     D7,A4
    ENDM
    MOVE.L    D0,A4
    SUBQ.W    #8,A6
    SUB.W     D5,A6

    MOVE.L    A4,D0
    MOVE.W    D7,D5
    LSL.W     #2,D5
    ADD.W     D5,A4
    MOVEQ.L   #0,D5
    MOVE.B    (A5)+,D5
    LSL.W     #3,D5
    ADD.W     D5,A6
    REPT      4
    MOVE.W    (A6)+,(A4)
    ADD.W     D7,A4
    ENDM
    MOVE.L    D0,A4
    SUBQ.W    #8,A6
    SUB.W     D5,A6

    ADDQ.W    #2,A4
    DBF       D1,zp8                ; plan suivant
    MOVE.W    D7,D1
    LSL.W     #3,D1
    ADD.W     D1,A4
    SUB.W     D7,A4
    DBF       D6,zwd8               ; 16 pixels du plan de la ligne

    MOVE.W    D3,D5
    ADD.W     D5,D5
    MOVE.L    A4,A0
    SUB.W     D5,A0
    MOVE.L    A4,A1

    MOVEQ.L   #7-1,D1
cp_line8:
    COPY16
    DBF       D1,cp_line8

    MOVE.L    A1,A4
    ADD.L     D2,A3
    DBF       D4,zl8                 ; ligne suivante

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS


zl8_16:
    MOVE.L    A4,A6
    MOVE.W    wdwidth(PC),D5
zll8_16:
    MOVE.W    D5,D0
    MOVE.L    A6,A4
zw8_16:
    REPT 16
    MOVE.W    (A5)+,D1
    REPT 8
    MOVE.W    D1,(A6)+
    ENDM
    ENDM
    DBF       D0,zw8_16

    MOVE.L    A4,A0
    MOVE.L    A6,A1
    MOVEQ.L   #7-1,D1
cp_line8_16:
    COPY16
    DBF       D1,cp_line8_16
    MOVE.L    A1,A6
    DBF       D4,zll8_16

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    
zl8_24:
    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    
zl8_32:
    MOVE.L    A4,A6
    MOVE.W    wdwidth(PC),D5
zll8_32:
    MOVE.W    D5,D0
    MOVE.L    A6,A4
zw8_32:
    REPT 16
    MOVE.L    (A5)+,D1
    REPT 8
    MOVE.L    D1,(A6)+
    ENDM
    ENDM
    DBF       D0,zw8_32

    MOVE.L    A4,A0
    MOVE.L    A6,A1
    MOVEQ.L   #7-1,D1
cp_line8_32:
    COPY16
    DBF       D1,cp_line8_32
    MOVE.L    A1,A6
    DBF       D4,zll8_32

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    

*************
* Zooms x16 *
*************
zl16:
    MOVE.W    wdwidth(PC),D6
zwd16:
    MOVE.W    nplanes(PC),D1    ;  D1 = nb_planes -1 pour DBF
zp16:
    MOVEQ.L   #0,D5
    MOVE.B    (A5)+,D5
    LSL.W     #4,D5
    MOVE.L    A4,D0
    ADD.W     D5,A6
    REPT      8
    MOVE.W    (A6)+,(A4)
    ADD.W     D7,A4
    ENDM
    MOVE.L    D0,A4
    SUBQ.W    #8,A6
    SUBQ.W    #8,A6
    SUB.W     D5,A6

    MOVE.L    A4,D0
    MOVE.W    D7,D5
    LSL.W     #3,D5
    ADD.W     D5,A4
    MOVEQ.L   #0,D5
    MOVE.B    (A5)+,D5
    LSL.W     #4,D5
    ADD.W     D5,A6
    REPT      8
    MOVE.W    (A6)+,(A4)
    ADD.W     D7,A4
    ENDM
    MOVE.L    D0,A4
    SUBQ.W    #8,A6
    SUBQ.W    #8,A6
    SUB.W     D5,A6

    ADDQ.W    #2,A4
    DBF       D1,zp16               ; plan suivant
    MOVE.W    D7,D1
    LSL.W     #4,D1
    ADD.W     D1,A4
    SUB.W     D7,A4
    DBF       D6,zwd16              ; 16 pixels du plan de la ligne

    MOVE.W    D3,D5
    ADD.W     D5,D5
    MOVE.L    A4,A0
    SUB.W     D5,A0
    MOVE.L    A4,A1

    MOVEQ.L   #15-1,D1
cp_line16:
    COPY16
    DBF       D1,cp_line16

    MOVE.L    A1,A4
    ADD.L     D2,A3
    DBF       D4,zl16                ; ligne suivante

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS


zl16_16:
    MOVE.L    A4,A6
    MOVE.W    wdwidth(PC),D5
zll16_16:
    MOVE.W    D5,D0
    MOVE.L    A6,A4
zw16_16:
    REPT 16
    MOVE.W    (A5)+,D1
    REPT 16
    MOVE.W    D1,(A6)+
    ENDM
    ENDM
    DBF       D0,zw16_16

    MOVE.L    A4,A0
    MOVE.L    A6,A1
    MOVEQ.L   #15-1,D1
cp_line16_16:
    COPY16
    DBF       D1,cp_line16_16
    MOVE.L    A1,A6
    DBF       D4,zll16_16

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    
zl16_24:
    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    
zl16_32:
    MOVE.L    A4,A6
    MOVE.W    wdwidth(PC),D5
zll16_32:
    MOVE.W    D5,D0
    MOVE.L    A6,A4
zw16_32:
    REPT 16
    MOVE.L    (A5)+,D1
    REPT 16
    MOVE.L    D1,(A6)+
    ENDM
    ENDM
    DBF       D0,zw16_32

    MOVE.L    A4,A0
    MOVE.L    A6,A1
    MOVEQ.L   #15-1,D1
cp_line16_32:
    COPY16
    DBF       D1,cp_line16_32
    MOVE.L    A1,A6
    DBF       D4,zll16_32

    MOVEM.L   (SP)+,D0-D7/A0-A6  ; Restauration du contexte
    RTS
    
