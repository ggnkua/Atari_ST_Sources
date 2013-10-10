**************************************************
* Quelques routines ‚l‚mentaires pour RASTEROP.C *
**************************************************
    .IMPORT i2r_data, i2rout, i2rnbplan, i2r_nb, i2rmaxx, i2rx, i2rlo
    .IMPORT i2r_a16, i2r_use030
    .IMPORT pixel_adrin, pixel_adr, pixel_lgoff
    .IMPORT adr_palette, nb_plane
    .IMPORT FRVBOrg, RVBOrg
    .IMPORT UseStdVDI
    .EXPORT word_xsym, xrvb, yrvb, wrvb, hrvb
    .EXPORT ind2raster, find2raster, raster2ind
    .EXPORT tc24to16, tc24ito16, tc16to24, tc16to32
    .EXPORT tc16_rvbchange
    .EXPORT tc16_imgchange, tc32_imgchange
    .EXPORT tc24targato16, tc16targato16, tc16totarga24
    .EXPORT tc16totarga16, tc24totarga24, tc32totarga24
    .EXPORT tc24targato32, tc16targato32
    .EXPORT tc24targato24, tc16targato24
    .EXPORT tc32to24, tc24to32
    .EXPORT row2dind, row2find
    .EXPORT red_pal, green_pal, blue_pal
    .EXPORT pixel_getmode1, pixel_getmode2, pixel_getmode4, pixel_getmode8, pixel_tcget, pixel_030tcget, pixel_030tcget32, pixel_tcget32, pixel_tcget24
    .EXPORT cycling_ado
    .EXPORT ClassicAtari2StdVDI, StdVDI2ClassicAtari
    .EXPORT img_raz
    .EXPORT tc_convert, tc_invconvert
    .EXPORT GetRolw, GetRoll
    .EXPORT TC15RemapColors, TC16RemapColors, TC32RemapColors
    .EXPORT r2i_bitarray, raster2ind_old

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

* Equivalences structure RVB_ORG
RRED        EQU  0
RGREEN      EQU  2
RBLUE       EQU  4
IS15BITS    EQU  6

* Equivalences structure REMAP_COLORS
REDMAP        EQU  0
GREENMAP      EQU  4
BLUEMAP       EQU  8
PTIMG         EQU  12
NBPTS         EQU  16

* Quelques macros ‚l‚mentaires
* D0 = Point en entr‚e ou final
* D1 = Composante Rouge          D4 = RRed   --> format sp‚cifique
* D2 = Composante Verte          D5 = RGreen --> format sp‚cifique
* D3 = Composante Bleue          D6 = RBlue  --> format sp‚cifique

MACRO   GET_FRGB16

    MOVE.W  (A0),D0
    MOVE.W  D0,D1
    ROL.W   #5,D1
    ANDI.W  #$1F,D1      ; D1.W = Composante ROUGE

    MOVE.W  D0,D2
    LSR.W   #5,D2
    ANDI.W  #$3F,D2      ; D2.W = Composante VERTE (0...63)

    MOVE.W  D0,D3
    ANDI.W  #$1F,D3      ; D3.W = Composante BLEU (0...31)

ENDM

MACRO   GET_FRGB15

    GET_FRGB16
    LSR.W   #1,D2

ENDM

MACRO   GET_RGB16

    MOVE.W  (A0),D0
    MOVE.W  D0,D1
    ROR.W   D4,D1
    ANDI.W  #$1F,D1      ; D1.W = Composante ROUGE

    MOVE.W  D0,D2
    ROR.W   D5,D2
    ANDI.W  #$3F,D2      ; D2.W = Composante VERTE (0...63)

    MOVE.W  D0,D3
    ROR.W   D6,D3
    ANDI.W  #$1F,D3      ; D3.W = Composante BLEU (0...31)

ENDM

MACRO   GET_RGB15

    MOVE.W  (A0),D0
    MOVE.W  D0,D1
    ROR.W   D4,D1
    ANDI.W  #$1F,D1      ; D1.W = Composante ROUGE

    MOVE.W  D0,D2
    ROR.W   D5,D2
    ANDI.W  #$1F,D2      ; D2.W = Composante VERTE (0...31)

    MOVE.W  D0,D3
    ROR.W   D6,D3
    ANDI.W  #$1F,D3      ; D3.W = Composante BLEU (0...31)

ENDM

MACRO    SET_FRGB16

    MOVE.W  D3,D0        ; D3 = Composante Bleu
    LSL.W   #5,D2
    ADD.W   D2,D0        ; D0 += Composante Verte
    ROR.W   #5,D1
    ADD.W   D1,D0        ; D0 += Composante Rouge

ENDM

MACRO    SET_RGB16

    ROL.W   D4,D1
    ROL.W   D5,D2
    ROL.W   D6,D3
    MOVE.W  D1,D0
    ADD.W   D2,D0
    ADD.W   D3,D0

ENDM

MACRO   GET_FRGB24

    MOVE.B  0(A0),D1     ; D1.B = Composante ROUGE
    MOVE.B  1(A0),D2     ; D2.B = Composante VERTE
    MOVE.B  2(A0),D3     ; D3.B = Composante BLEUE

ENDM

MACRO   GET_RGB24

    MOVE.B  (A0,D4.W),D1 ; D1.B = Composante ROUGE
    MOVE.B  (A0,D5.W),D2 ; D2.B = Composante VERTE
    MOVE.B  (A0,D6.W),D3 ; D3.B = Composante BLEU

ENDM

MACRO   SET_FRGB24

    MOVE.B  D1,0(A0)     ; D1.B = Composante ROUGE
    MOVE.B  D2,1(A0)     ; D2.B = Composante VERTE
    MOVE.B  D3,2(A0)     ; D3.B = Composante BLEUE

ENDM

MACRO   SET_RGB24

    MOVE.B  D1,(A0,D4.W)
    MOVE.B  D2,(A0,D5.W)
    MOVE.B  D3,(A0,D6.W)

ENDM

MACRO   GET_FRGB32

    MOVE.B  0(A0),D1     ; D1.B = Composante ROUGE
    MOVE.B  1(A0),D2     ; D2.B = Composante VERTE
    MOVE.B  2(A0),D3     ; D3.B = Composante BLEU

ENDM

MACRO   GET_RGB32

    MOVE.B  (A0,D4.W),D1 ; D1.B = Composante ROUGE
    MOVE.B  (A0,D5.W),D2 ; D2.B = Composante VERTE
    MOVE.B  (A0,D6.W),D3 ; D3.B = Composante BLEU

ENDM

MACRO   SET_FRGB32

    CLR.L   (A0)
    MOVE.B  D1,0(A0)
    MOVE.B  D2,1(A0)
    MOVE.B  D3,2(A0)

ENDM

MACRO   SET_RGB32

    CLR.L   (A0)
    MOVE.B  D1,(A0,D4.W)
    MOVE.B  D2,(A0,D5.W)
    MOVE.B  D3,(A0,D6.W)

ENDM



ind2raster:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rmaxx,A3
    MOVE.W    i2rnbplan,D3
    MOVEQ.L   #0,D4
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1
    ; Mise en place des flags pour routines de flux et 68030
    MOVEQ.L   #0,D5
    MOVE.W    i2r_a16,D4
    LSL.W     #2,D4
    BTST      #2,D4
    BEQ       after_030        ; Si flux, pas de 030
    MOVE.W    i2r_use030,D5
after_030:
    LSL.W     #2,D5
    ; Calcul de l'adresse de la routine
    SUBQ.W    #1,D3
    LSL.W     #4,D3                     ; Pour 1 plan, 4 adresses de routine --> 16 octets
    ADD.W     D4,D3                     ; Offset 4 si routine sur 16 pixels
    ADD.W     D5,D3                     ; Offset 4 si code 68030

    MOVE.L    adr_ir2routine(PC,D3.W),A4
    JSR       (A4)

i2r_end:
    MOVE.W    D3,i2rx
    MOVE.L    A1,i2rout
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C

; Pour chaque nombre de plans (0--->8)
; 1. Routine 68000 acceptant le flux de pixels sans alignement sur 16 pixels
; 2. Routine 68000 alignement obligatoire sur 16 pixels
; 3. Routine 68030 alignement obligatoire sur 16 pixels (si optimisation possible)
; 4. RFU ?
adr_ir2routine:
    DC.L      i2r1_flux, i2r1_000,  i2r1_000,  i2r_null    ; 1 Plan
    DC.L      i2r2_flux, i2r2_flux, i2r2_flux, i2r_null    ; 2 Plans
    DC.L      i2r_null,  i2r_null,  i2r_null,  i2r_null    ; 3 Plans
    DC.L      i2r4_flux, i2r4_000,  i2r4_030,  i2r_null    ; 4 Plans
    DC.L      i2r5_flux, i2r5_flux, i2r5_flux, i2r_null    ; 5 Plans
    DC.L      i2r_null,  i2r_null,  i2r_null,  i2r_null    ; 6 Plans
    DC.L      i2r_null,  i2r_null,  i2r_null,  i2r_null    ; 7 Plans
    DC.L      i2r8_flux, i2r8_000,  i2r8_030,  i2r_null    ; 8 Plans


i2r_null:
    RTS

i2r1_000:
    MOVE.W    i2rmaxx,D1
    LSR.W     #1,D1
    MOVE.W    D1,mfdb_w
    LSR.W     #3,D1
    SUBQ.W    #1,D1               ; D1 = largeur/16-1
    MOVE.W    D1,width
    MOVE.W    i2rmaxx,D1
    DIVS.W    D1,D0               ; nb lignes --> D0.W
    MOVE.W    D0,height
    
    MOVEQ.L   #0,D2
    MOVE.W    mfdb_w(PC),D2
    MOVE.W    width(PC),D0
    ADDQ.L    #1,D0
    LSL.W     #2,D0
    SUB.W     D0,D2
    MOVEQ.L   #0,D5
    MOVE.L    #$70001,D6
    
    MOVE.W    height(PC),D1
    BEQ      not_a_line1_000
    SUBQ.W    #1,D1
not_a_line1_000:
    MOVEQ     #%1111,D4
    
.ligne_1:
    MOVE.W    width(PC),D0
.groupe16_1:
    MOVEQ.L   #0,D7

    REPT      4
    MOVE.L    (A0)+,D3
    ROL.L     #8,D3
    REPT      3
    MOVE.B    D3,D5
    ROXR.W    #1,D5
    ADDX.W    D7,D7
    ROL.L     #8,D3
    ENDM
    MOVE.B    D3,D5
    ROXR.W    #1,D5
    ADDX.W    D7,D7
    ENDM
    
    MOVE.W    D7,(A1)+
    
    DBRA      D0,.groupe16_1
    DBRA      D1,.ligne_1

    MOVE.L    A1,i2rout
    RTS

i2r1_flux:
    MOVE.W    i2rx,D3
i2r1l:
    MOVE.W    D3,D4
    LSR.W     #3,D4
    MOVE.W    D3,D1
    ANDI.W    #7,D1
    NEG.W     D1
    ADDQ.W    #7,D1             ; Bit … affecter
    BTST      #0,(A0)+
    BEQ       n1
    BSET      D1,(A1,D4)
n1: ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       nl1
    ADD.L     i2rlo,A1
    MOVEQ.L   #0,D3
nl1:SUBQ.L    #1,D0
    BNE       i2r1l
    RTS

i2r2_flux:
    MOVE.W    i2rx,D3
    MOVE.W    #$FFFC,D6
i2r2l:
    MOVE.W    D3,D4
    LSR.W     #2,D4
    AND.W     D6,D4
    BTST      D7,D3
    BEQ       na2
    ADDQ.W    #1,D4             ;  Offset / au d‚but de la ligne en octets
na2:MOVE.W    D3,D1
    ANDI.W    #7,D1
    NEG.W     D1
    ADDQ.W    #7,D1             ; Bit … affecter
    MOVE.B    (A0)+,D5
    BTST      #0,D5
    BEQ       n21
    BSET      D1,(A1,D4)
n21:BTST      #1,D5
    BEQ       n22
    BSET      D1,2(A1,D4)
n22:ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       nl2
    ADD.L     i2rlo,A1
    MOVEQ.L   #0,D3
nl2:SUBQ.L    #1,D0
    BNE       i2r2l
    RTS

i2r4_flux:
    MOVE.W    i2rx,D3
    MOVE.W    #$FFF8,D6

    MOVE.W    D3,D1
    ANDI.W    #7,D1
    NEG.W     D1
    ADDQ.W    #7,D1             ; Bit … affecter
i2r4l:
    MOVE.W    D3,D4
    LSR.W     #1,D4
    AND.W     D6,D4
    BTST      #3,D3
    BEQ       na4
    ADDQ.W    #1,D4             ;  Offset / au d‚but de la ligne en octets
na4:
    MOVE.L    A1,A2
    ADD.L     D4,A2
    MOVE.B    (A0)+,D5

    BTST      #0,D5
    BEQ       n41
    BSET      D1,(A2)
n41:BTST      #1,D5
    BEQ       n42
    BSET      D1,2(A2)
n42:BTST      #2,D5
    BEQ       n43
    BSET      D1,4(A2)
n43:BTST      #3,D5
    BEQ       n44
    BSET      D1,6(A2)
n44:
    SUBQ.W    #1,D1
    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       nl4
    ADD.L     i2rlo,A1
    MOVEQ.L   #0,D3
    MOVEQ.L   #7,D1
nl4:
    SUBQ.L    #1,D0
    BGT       i2r4l
    RTS


i2r5_flux:
    MOVE.W    i2rx,D3
i2r5l:
    MOVE.W    D3,D4
    LSR.W     #4,D4
    MULU.W    #10,D4
    BTST      #3,D3
    BEQ       na5
    ADDQ.W    #1,D4             ;  Offset / au d‚but de la ligne en octets
na5:MOVE.W    D3,D1
    ANDI.W    #7,D1
    NEG.W     D1
    ADDQ.W    #7,D1             ; Bit … affecter
    MOVE.B    (A0)+,D5
    BTST      #0,D5
    BEQ       n51
    BSET      D1,(A1,D4)
n51:BTST      #1,D5
    BEQ       n52
    BSET      D1,2(A1,D4)
n52:BTST      #2,D5
    BEQ       n53
    BSET      D1,4(A1,D4)
n53:BTST      #3,D5
    BEQ       n54
    BSET      D1,6(A1,D4)
n54:BTST      #4,D5
    BEQ       n55
    BSET      D1,8(A1,D4)
n55:ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       nl5
    ADD.L     i2rlo,A1
    MOVEQ.L   #0,D3
nl5:SUBQ.L    #1,D0
    BNE       i2r5l
    RTS

i2r8_flux:
    MOVE.W    i2rx,D3
    MOVE.W    #$FFF0,D6

    MOVE.W    D3,D1
    ANDI.W    #7,D1
    NEG.W     D1
    ADDQ.W    #7,D1             ; Bit … affecter
i2r8l:
    MOVE.W    D3,D4
    AND.W     D6,D4
    BTST      #3,D3
    BEQ       na8
    ADDQ.W    #1,D4             ;  Offset / au d‚but de la ligne en octets
na8:
    MOVE.L    A1,A2
    ADD.L     D4,A2
    MOVE.B    (A0)+,D5

    BTST      #0,D5
    BEQ       n81
    BSET      D1,(A2)
n81:BTST      #1,D5
    BEQ       n82
    BSET      D1,2(A2)
n82:BTST      #2,D5
    BEQ       n83
    BSET      D1,4(A2)
n83:BTST      #3,D5
    BEQ       n84
    BSET      D1,6(A2)
n84:BTST      #4,D5
    BEQ       n85
    BSET      D1,8(A2)
n85:BTST      #5,D5
    BEQ       n86
    BSET      D1,10(A2)
n86:BTST      #6,D5
    BEQ       n87
    BSET      D1,12(A2)
n87:BTST      #7,D5
    BEQ       n88
    BSET      D1,14(A2)


n88:SUBQ.W    #1,D1
*    ANDI.B    #7,D1       ; Nouveau bit … affecter : INUTILE le 68000 le fait automatiquement
    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       nl8
    ADD.L     i2rlo,A1
    MOVEQ.L   #0,D3
    MOVEQ.L   #7,D1
nl8:SUBQ.L    #1,D0
    BGT       i2r8l
    RTS

tc24to16:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rx,D3
    MOVE.W    i2rmaxx,A3
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1
    
    MOVE.W    #$F800,D7        ; Masque pour la composante Rouge
    MOVE.W    #$07C0,D6        ; Masque pour la composante Verte
    MOVE.W    #8,D5            ; D‚calage por la composante Rouge
    MOVEQ.L   #3,D4            ; D‚calage pour la composante Verte

tcloop:
    MOVE.B    (A0)+,D1         ; Composante Rouge
    LSL.W     D5,D1
    AND.W     D7,D1

    MOVE.B    (A0)+,D2         ; Composante Verte
    LSL.W     D4,D2
    AND.W     D6,D2
    OR.W      D2,D1

    MOVEQ.L   #0,D2
    MOVE.B   (A0)+,D2         ; Composante Bleu
    LSR.W     D4,D2
    OR.W      D2,D1

    MOVE.W    D1,(A1)+        ; Valeur RRRRRVVVVVXBBBBB

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       tcl
    MOVE.L    i2rout,A1
    ADD.L     i2rlo,A1
    MOVE.L    A1,i2rout
    MOVEQ.L   #0,D3
tcl:SUBQ.L    #3,D0
    BGT       tcloop
    BRA       i2r_end

*
* Conversion 24 bits Targa (BGR...) -> 16 bits Falcon
tc24targato16:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rx,D3
    MOVE.W    i2rmaxx,A3
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1
    
    MOVE.W    #$F800,D7        ; Masque pour la composante Rouge
    MOVE.W    #$07C0,D6        ; Masque pour la composante Verte
    MOVE.W    #8,D5            ; D‚calage por la composante Rouge
    MOVEQ.L   #3,D4            ; D‚calage pour la composante Verte

tctargaloop:
    MOVEQ.L   #0,D1
    MOVEQ.L   #0,D2
    MOVE.B   (A0)+,D1         ; Composante Bleu
    LSR.W     D4,D1

    MOVE.B    (A0)+,D2         ; Composante Verte
    LSL.W     D4,D2
    AND.W     D6,D2
    OR.W      D2,D1

    MOVE.B    (A0)+,D2         ; Composante Rouge
    LSL.W     D5,D2
    AND.W     D7,D2
    OR.W      D2,D1

    MOVE.W    D1,(A1)+        ; Valeur RRRRRVVVVVXBBBBB

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       tctl
    MOVE.L    i2rout,A1
    ADD.L     i2rlo,A1
    MOVE.L    A1,i2rout
    MOVEQ.L   #0,D3
tctl:
    SUBQ.L    #3,D0
    BGT       tctargaloop
    BRA       i2r_end

*
* Conversion 24 bits Targa (BGR...) -> 32 bits RVB0
tc24targato32:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rx,D3
    MOVE.W    i2rmaxx,A3
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1
    
tctargaloop24to32:
    MOVE.B    (A0)+,D1        ; Composante Bleu
    MOVE.B    (A0)+,D2        ; Composante Verte
    MOVE.B    (A0)+,D4        ; Composante Rouge

    MOVE.B    D4,(A1)+
    MOVE.B    D2,(A1)+
    MOVE.B    D1,(A1)+
    CLR.B     (A1)+

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       tctl24to32
    MOVE.L    i2rout,A1
    ADD.L     i2rlo,A1
    MOVE.L    A1,i2rout
    MOVEQ.L   #0,D3
tctl24to32:
    SUBQ.L    #3,D0
    BGT       tctargaloop24to32
    BRA       i2r_end

*
* Conversion 24 bits Targa (BGR...) -> 24 bits RVB
tc24targato24:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rx,D3
    MOVE.W    i2rmaxx,A3
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1
    
tctargaloop24to24:
    MOVE.B    (A0)+,D1        ; Composante Bleu
    MOVE.B    (A0)+,D2        ; Composante Verte
    MOVE.B    (A0)+,D4        ; Composante Rouge

    MOVE.B    D4,(A1)+
    MOVE.B    D2,(A1)+
    MOVE.B    D1,(A1)+

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       tctl24to24
    MOVE.L    i2rout,A1
    ADD.L     i2rlo,A1
    MOVE.L    A1,i2rout
    MOVEQ.L   #0,D3
tctl24to24:
    SUBQ.L    #3,D0
    BGT       tctargaloop24to24
    BRA       i2r_end

*
* Conversion 16 bits Targa (GGGBBBBB ARRRRRGG) -> 16 bits Falcon
tc16targato16:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rx,D3
    MOVE.W    i2rmaxx,A3
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1

    MOVE.B    #$1F,D6
    MOVE.W    #9,D5
    MOVE.B    #$E0,D4

tctarga16loop:
    MOVEQ.L  #0,D1
    MOVE.B   (A0)+,D1         ; GGGBBBBB
    MOVE.W   D1,D2
    AND.B    D4,D2
    ADD.W    D2,D2
    AND.B    D6,D1
    OR.W     D2,D1
   
    MOVE.B   (A0)+,D2         ; ARRRRRGG
    LSL.W    D5,D2
    OR.W     D2,D1
    
    MOVE.W    D1,(A1)+        ; Valeur RRRRRVVVVVXBBBBB

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       tct16l
    MOVE.L    i2rout,A1
    ADD.L     i2rlo,A1
    MOVE.L    A1,i2rout
    MOVEQ.L   #0,D3
tct16l:
    SUBQ.L    #2,D0
    BGT       tctarga16loop
    BRA       i2r_end

*
* Conversion 16 bits Targa (GGGBBBBB ARRRRRGG) -> 32 Bits RVB0
tc16targato32:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rx,D3
    MOVE.W    i2rmaxx,A3
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1

    MOVE.W    #$1F,D4
tctarga16loop16to32:
    MOVE.W    (A0)+,D2         ; D0.W = GGGBBBBB ARRRRRGG
    MOVE.W    D2,D1
    LSR.W     #2,D1
    AND.B     D4,D1
    LSL.W     #3,D1            ; --> Composante Rouge
    MOVE.B    D1,(A1)+

    MOVE.W    D2,D1
    ROL.W     #3,D1
    AND.B     D4,D1
    LSL.W     #3,D1            ; --> Composante Rouge
    MOVE.B    D1,(A1)+
    
    MOVE.W    D2,D1
    LSR.W     #8,D1
    AND.B     D4,D1
    LSL.W     #3,D1            ; --> Composante Bleu
    MOVE.B    D1,(A1)+

    CLR.B     (A1)+

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       tct16l16to32
    MOVE.L    i2rout,A1
    ADD.L     i2rlo,A1
    MOVE.L    A1,i2rout
    MOVEQ.L   #0,D3
tct16l16to32:
    SUBQ.L    #2,D0
    BGT       tctarga16loop16to32
    BRA       i2r_end

*
* Conversion 16 bits Targa (GGGBBBBB ARRRRRGG) -> 24 Bits RVB
tc16targato24:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rx,D3
    MOVE.W    i2rmaxx,A3
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1

    MOVE.W    #$1F,D4
tctarga16loop16to24:
    MOVE.W    (A0)+,D2         ; D0.W = GGGBBBBB ARRRRRGG
    MOVE.W    D2,D1
    LSR.W     #2,D1
    AND.B     D4,D1
    LSL.W     #3,D1            ; --> Composante Rouge
    MOVE.B    D1,(A1)+

    MOVE.W    D2,D1
    ROL.W     #3,D1
    AND.B     D4,D1
    LSL.W     #3,D1            ; --> Composante Rouge
    MOVE.B    D1,(A1)+
    
    MOVE.W    D2,D1
    LSR.W     #8,D1
    AND.B     D4,D1
    LSL.W     #3,D1            ; --> Composante Bleu
    MOVE.B    D1,(A1)+

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       tct16l16to24
    MOVE.L    i2rout,A1
    ADD.L     i2rlo,A1
    MOVE.L    A1,i2rout
    MOVEQ.L   #0,D3
tct16l16to24:
    SUBQ.L    #2,D0
    BGT       tctarga16loop16to24
    BRA       i2r_end


*
* void tc24ito16(long l_plane)
*                   D0
* l_plane : Nombre de points d'un plan (i2r_nb/3)
tc24ito16:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    D0,D4
    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rx,D3
    MOVE.W    i2rmaxx,A3
    MOVE.L    i2r_data,A4      ; Pointeur sur plan Rouge
    MOVE.L    A4,A5
    ADD.L     D4,A5            ; Pointeur sur plan Vert
    MOVE.L    A5,A6
    ADD.L     D4,A6            ; Pointeur sur plan Bleu
    MOVE.L    i2rout,A1
    MOVE.W    #$F800,D7        ; Masque pour la composante Rouge
    MOVE.W    #$07C0,D6        ; Masque pour la composante Verte
    MOVE.W    #8,D5            ; D‚calage por la composante Rouge
    MOVEQ.L   #3,D4            ; D‚calage pour la composante Verte

tciloop:
    MOVE.B    (A4)+,D1         ; Composante Rouge
    LSL.W     D5,D1
    AND.W     D7,D1

    MOVE.B    (A5)+,D2         ; Composante Verte
    LSL.W     D4,D2
    AND.W     D6,D2
    OR.W      D2,D1

    MOVEQ.L   #0,D2
    MOVE.B   (A6)+,D2         ; Composante Bleu
    LSR.W     D4,D2
    OR.W      D2,D1

    MOVE.W    D1,(A1)+        ; Valeur RRRRRVVVVVXBBBBB

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BNE       tcli
    MOVE.L    i2rout,A1
    ADD.L     i2rlo,A1
    MOVE.L    A1,i2rout
    MOVEQ.L   #0,D3
tcli:
    SUBQ.L    #3,D0
    BGT       tciloop
    BRA       i2r_end


* void tc16to24(int *pt_img, unsigned char *buffer, long nb_pts)
*                   A0                 A1            D0

tc16to24:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    CMP.L     #0,D0
    BEQ       tc16to24end

tc2loop:
    MOVE.W    (A0)+,D2          ; D1.W = RRRRRGGGGGXBBBBB

    ROL.W     #5,D2
    MOVE.W    D2,D1
    ANDI.B    #$1F,D1           ; Masque 5 bits
    LSL.W     #3,D1             ; Cadrage sur 8 bits
    MOVE.B    D1,(A1)+          ; --> Composante Rouge

    ROL.W     #6,D2
    MOVE.W    D2,D1
    ANDI.B    #$3F,D1           ; Masque 6 bits
    LSL.W     #2,D1             ; Cadrage sur 8 bits
    MOVE.B    D1,(A1)+          ; --> Composante Verte

    ROL.W     #5,D2
    MOVE.W    D2,D1
    ANDI.B    #$1F,D1           ; Masque 5 bits
    LSL.W     #3,D1             ; Cadrage sur 8 bits
    MOVE.B    D1,(A1)+          ; --> Composante Bleu

    SUBQ.L     #1,D0
    BGT        tc2loop

tc16to24end:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C

* void tc16to32(int *pt_img, unsigned char *buffer, long nb_pts)
*                   A0                 A1            D0

tc16to32:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    CMP.L     #0,D0
    BEQ       tc16to32end

tc2loop32:
    MOVE.W    (A0)+,D2          ; D1.W = RRRRRGGGGGXBBBBB

    ROL.W     #5,D2
    MOVE.W    D2,D1
    ANDI.B    #$1F,D1           ; Masque 5 bits
    LSL.W     #3,D1             ; Cadrage sur 8 bits
    MOVE.B    D1,(A1)+          ; --> Composante Rouge

    ROL.W     #6,D2
    MOVE.W    D2,D1
    ANDI.B    #$3F,D1           ; Masque 6 bits
    LSL.W     #2,D1             ; Cadrage sur 8 bits
    MOVE.B    D1,(A1)+          ; --> Composante Verte

    ROL.W     #5,D2
    MOVE.W    D2,D1
    ANDI.B    #$1F,D1           ; Masque 5 bits
    LSL.W     #3,D1             ; Cadrage sur 8 bits
    MOVE.B    D1,(A1)+          ; --> Composante Bleu

    CLR.B      (A1)+            ; Canal Alpha

    SUBQ.L     #1,D0
    BGT        tc2loop32

tc16to32end:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C


* void tc24to32(unsigned char *pt_img, unsigned long *buffer, long nb_pts)
*                   A0                 A1            D0

tc24to32:
    CMP.L     #0,D0
    BEQ       tc24to32end

tc24loop32:
    MOVE.B    (A0)+,(A1)+
    MOVE.B    (A0)+,(A1)+
    MOVE.B    (A0)+,(A1)+
    CLR.B     (A1)+            ; Canal Alpha

    SUBQ.L     #1,D0
    BGT        tc24loop32

tc24to32end:
    RTS                         ; Retour au programme C


* void tc32to24(long *pt_img, unsigned char *buffer, long nb_pts)
*                      A0                 A1            D0

tc32to24:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    CMP.L     #0,D0
    BEQ       tc32to24end

tc32loop:
    MOVE.L    (A0)+,D1         ; D1 = RVB0

    SWAP      D1
    ROL.W     #8,D1
    MOVE.B    D1,(A1)+         ; --> Composante Rouge
    ROL.W     #8,D1
    MOVE.B    D1,(A1)+         ; --> Composante Verte
    SWAP      D1
    LSR.W     #8,D1
    MOVE.B    D1,(A1)+         ; --> Composante Bleu

    SUBQ.L     #1,D0
    BGT        tc32loop

tc32to24end:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C

* void (int *pt_img, unsigned char *buffer, long nb_pts)
*                          A0                 A1            D0

tc16totarga24:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    CMP.L     #0,D0
    BEQ       tc16totarga24end
    MOVE.W    #8,D7             ; D‚calage pour le Rouge
    MOVE.W    #3,D6             ; D‚calage pour le Vert et le Bleu
    MOVE.B    #$F8,D5           ; Masque 5 Bits -> 8 Bits
    MOVE.B    #$FC,D4           ; Masque 6 Bits -> 8 Bits

tc2targaloop:
    MOVE.W    (A0)+,D1

    MOVE.W     D1,D2
    LSL.W      D6,D2
    MOVE.B     D2,(A1)+         ; Composante Bleu

    MOVE.W     D1,D2
    LSR.W      D6,D2
    AND.B      D4,D2
    MOVE.B     D2,(A1)+         ; Composante Verte

    LSR.W      D7,D1
    AND.B      D5,D1
    MOVE.B     D1,(A1)+         ; Composante Rouge

    SUBQ.L     #1,D0
    BGT        tc2targaloop

tc16totarga24end:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C

* void tc24totarga24(int *pt_img, unsigned char *buffer, long nb_pts)
*                          A0                 A1            D0

tc24totarga24:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    CMP.L     #0,D0
    BEQ       tc24totarga24end

tc24targaloop:
    MOVE.B    (A0)+,D1
    MOVE.B    (A0)+,D2
    MOVE.B    (A0)+,D3

    MOVE.B     D3,(A1)+         ; Composante Bleu
    MOVE.B     D2,(A1)+         ; Composante Bleu
    MOVE.B     D1,(A1)+         ; Composante Bleu

    SUBQ.L     #1,D0
    BGT        tc24targaloop

tc24totarga24end:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C

* void tc32totarga24(int *pt_img, unsigned char *buffer, long nb_pts)
*                          A0                 A1            D0

tc32totarga24:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    CMP.L     #0,D0
    BEQ       tc32totarga24end

tc32targaloop:
    MOVE.B    (A0)+,D1
    MOVE.B    (A0)+,D2
    MOVE.B    (A0)+,D3
    ADDQ.L    #1,A0

    MOVE.B     D3,(A1)+         ; Composante Bleu
    MOVE.B     D2,(A1)+         ; Composante Bleu
    MOVE.B     D1,(A1)+         ; Composante Bleu

    SUBQ.L     #1,D0
    BGT        tc32targaloop

tc32totarga24end:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C


* void tc16totarga16(int *pt_img, int *buffer, long nb_pts)
*                          A0          A1            D0

tc16totarga16:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    CMP.L     #0,D0
    BEQ       tc16totarga16end
    MOVE.W    #1,D7
    MOVE.W    #9,D6
    MOVE.W    #7,D5
    MOVE.W    #$E000,D4

tc2t16loop:
    MOVE.W    (A0)+,D1

    MOVE.W     D1,D2            ;      RRRRRGGGGGXBBBBB
    LSR.W      D6,D1            ; D1 = 000000000RRRRRGG
    LSL.W      D5,D2            ; D2 = GGGXBBBBB0000000
    MOVE.W     D2,D3
    AND.W      D4,D2            ; D2 = GGG0000000000000
    LSL.W      D7,D3
    ANDI.W     #$1F00,D3        ; D3 = 000BBBBB00000000

    OR.W       D2,D3
    OR.W       D3,D1            ; D1 = GGGBBBBB0RRRRRGG
    MOVE.W     D1,(A1)+

    SUBQ.L     #1,D0
    BGT        tc2t16loop

tc16totarga16end:
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C


.EVEN
r2i_bitarray:  DS.B  8*256

* void raster2ind(int *pt_raster, unsigned char *out, long nb_pts, int nplans)
*                      A0                       A1        D0          D1
raster2ind:
    MOVEM.L A2/D2-D7,-(SP)
    LSR.L   #4,D0    ; par paquets de 16 pixels
    SUB.L   #1,D0    ; -1 pour DBF
    LEA.L   r2i_bitarray(PC),A2

p16_loop:
    MOVEQ.L #0,D3
    MOVEQ.L #0,D4
    MOVEQ.L #0,D5
    MOVEQ.L #0,D6
    MOVEQ.L #0,D7
    SWAP    D0
bp_loop:
    CLR.W   D0
    MOVE.B  (A0)+,D0
    LSL.W   #3,D0
    MOVE.L  (A2,D0.W),D2
    LSL.L   D3,D2
    OR.L    D2,D4
    MOVE.L  4(A2,D0.W),D2
    LSL.L   D3,D2
    OR.L    D2,D5
    CLR.W   D0
    MOVE.B  (A0)+,D0
    LSL.W   #3,D0
    MOVE.L  (A2,D0.W),D2
    LSL.L   D3,D2
    OR.L    D2,D6
    MOVE.L  4(A2,D0.W),D2
    LSL.L   D3,D2
    OR.L    D2,D7

    ADD.W   #1,D3
    CMP.W   D3,D1
    BNE     bp_loop
    MOVE.L  D4,(A1)+
    MOVE.L  D5,(A1)+
    MOVE.L  D6,(A1)+
    MOVE.L  D7,(A1)+
    SWAP    D0
    DBF     D0,p16_loop

    MOVEM.L (SP)+,A2/D2-D7
    RTS
 

* void raster2ind(int *pt_raster, unsigned char *out, long nb_pts, int nplans)
*                      A0                       A1        D0          D1
* Alignement sur 16 pixels INDISPENSABLE
_raster2ind:
    BRA        raster2ind_old
    MOVEM.L    D0-D7/A0-A7,-(SP)

    LEA.L      adr_r2irout(PC),A2
    SUBQ.W     #1,D1                 ; D1 = nb planes - 1
    LSL.W      #2,D1                 ; 4 octets par adresse de routine
    MOVE.L     (A2,D1.W),A2

    JSR        (A2)

    MOVEM.L    (SP)+,D0-D7/A0-A7
    RTS

adr_r2irout:
    DC.L       raster2ind_old        ; 1 Plan
    DC.L       raster2ind_old        ; 2 Plans : Pas d'optimisation
    DC.L       raster2ind_null       ; 3 Plans : pas de routine
    DC.L       raster2ind_old        ; 4 Plans
    DC.L       raster2ind_null       ; 5 Plans : pas de routine
    DC.L       raster2ind_null       ; 6 Plans : pas de routine
    DC.L       raster2ind_null       ; 7 Plans : pas de routine
    DC.L       raster2ind_old        ; 8 Plans
    
; Les d‚finitifs
    DC.L       raster2ind_1          ; 1 Plan
    DC.L       raster2ind_old        ; 2 Plans : Pas d'optimisation
    DC.L       raster2ind_null       ; 3 Plans : pas de routine
    DC.L       raster2ind_4          ; 4 Plans
    DC.L       raster2ind_null       ; 5 Plans : pas de routine
    DC.L       raster2ind_null       ; 6 Plans : pas de routine
    DC.L       raster2ind_null       ; 7 Plans : pas de routine
    DC.L       raster2ind_8          ; 8 Plans

    
raster2ind_null:
    RTS

raster2ind_1:

    RTS

raster2ind_4:

    RTS

raster2ind_8:

    RTS


raster2ind_old:
    MOVEM.L    D3-D7/A2,-(SP)

    LSR.L      #4,D0
    MOVE.W     D1,D6
    ADD.W      D6,D6            ; Nombre d'octets pour sauter 16 pixels
    SUBQ.W     #1,D1
r2iloop_old:
    MOVEQ.L    #15,D2
r2ibloop_old:
    MOVE.L     A0,A2            ; Adresse du mot … convertir
    MOVE.W     D1,D4
    MOVEQ.L    #0,D3            ; Indice TOS en sortie
    MOVEQ.L    #0,D7
r2iploop_old:
    MOVE.W     (A2)+,D5
    BTST       D2,D5
    BEQ        no_one_old
    BSET       D7,D3
no_one_old:
    ADDQ.W     #1,D7
    DBF        D4,r2iploop_old
    MOVE.B     D3,(A1)+
    DBF        D2,r2ibloop_old
    ADD.W      D6,A0            ; 16 points suivants
    SUBQ.L     #1,D0
    BGT        r2iloop_old

    MOVEM.L    (SP)+,D3-D7/A2
    RTS

find2raster_old:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.W    i2rmaxx,A3
    MOVE.W    i2rnbplan,D3
    MOVEQ.L   #0,D4
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1
    MOVE.W    #3,D7             ; Bit … consulter pour 8 bits

    MOVE.W    i2rx,D3
    MOVE.W    #$FFF8,D6

fi2r4l:
    MOVE.W    D3,D4
    LSR.W     #1,D4
    AND.W     D6,D4
    MOVE.W    D3,D5
    BTST      D7,D5
    BEQ       fna4
    ADDQ.W    #1,D4             ;  Offset / au d‚but de la ligne en octets
fna4:
    MOVE.W    D3,D1
    ANDI.W    #7,D1
    NEG.W     D1
    ADDQ.W    #7,D1             ; Bit … affecter
    MOVE.B    (A0)+,D5
    BTST      #4,D5
    BEQ       fn41
    BSET      D1,(A1,D4)
fn41:
    BTST      #5,D5
    BEQ       fn42
    BSET      D1,2(A1,D4)
fn42:
    BTST      #6,D5
    BEQ       fn43
    BSET      D1,4(A1,D4)
fn43:
    BTST      #7,D5
    BEQ       fn44
    BSET      D1,6(A1,D4)
fn44:

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BGT       snl4
    ADD.L     i2rlo,A1
    MOVEQ.L   #0,D3
    BRA       fnl4
snl4:

    SUBQ.W    #1,D1
    BTST      #0,D5
    BEQ       fns41
    BSET      D1,(A1,D4)
fns41:
    BTST      #1,D5
    BEQ       fns42
    BSET      D1,2(A1,D4)
fns42:
    BTST      #2,D5
    BEQ       fns43
    BSET      D1,4(A1,D4)
fns43:
    BTST      #3,D5
    BEQ       fns44
    BSET      D1,6(A1,D4)
fns44:

    ADDQ.W    #1,D3
    CMP.W     D3,A3
    BGT       fnl4
    ADD.L     i2rlo,A1
    MOVEQ.L   #0,D3
fnl4:
    SUBQ.L    #1,D0
    BNE       fi2r4l
    BRA       i2r_end

find2raster:
    TST.W     i2r_a16
    BEQ       find2raster_old   ; Si optimisation non souhaitable
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    i2r_nb,D0
    CMP.L     #0,D0
    BEQ       i2r_end
    MOVE.L    i2r_data,A0
    MOVE.L    i2rout,A1
    LEA.L     mask4bits(PC),A2

    MOVE.W    i2rmaxx,D1
    LSR.W     #1,D1
    MOVE.W    D1,mfdb_w
    LSR.W     #2,D1
    SUBQ.W    #1,D1               ; D1 = largeur/8-1
    MOVE.W    D1,width
    MOVE.W    i2rmaxx,D1
    ADD.L     D0,D0               ; car 1 octet = 2 pixels
    DIVS.W    D1,D0               ; nb lignes --> D0.W
    MOVE.W    D0,height
    
    MOVEQ.L   #0,D2
    MOVE.W    mfdb_w(PC),D2
    MOVE.W    width(PC),D0
    ADDQ.L    #1,D0
    LSL.W     #2,D0
    SUB.W     D0,D2
    MOVEQ.L   #0,D5
    MOVE.L    #$70001,D6
    
    MOVE.W    height(PC),D1
    BEQ       not_a_line
    SUBQ.W    #1,D1
not_a_line:
    MOVEQ     #%1111,D4
    
.ligne:
    MOVE.W    width(PC),D0
.groupe8:
    MOVEQ.L   #0,D7
    MOVE.L    (A0)+,D3
    ROL.L     #4,D3

    REPT      7
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
    ROL.L     #4,D3
    ADD.L     D7,D7
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
   
    MOVEP.L   D7,(A1)
    ADDA.W    D6,A1
    SWAP      D6
    
    DBRA      D0,.groupe8
    ADDA.L    D2,A1
    DBRA      D1,.ligne

    MOVE.L    A1,i2rout
    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C

width:
    .DS.W     1
height:
    .DS.W     1
mfdb_w:
    .DS.W     1
mask4bits:
    DC.L      $00000000
    DC.L      $01000000
    DC.L      $00010000
    DC.L      $01010000
    DC.L      $00000100
    DC.L      $01000100
    DC.L      $00010100
    DC.L      $01010100
    DC.L      $00000001
    DC.L      $01000001
    DC.L      $00010001
    DC.L      $01010001
    DC.L      $00000101
    DC.L      $01000101
    DC.L      $00010101
    DC.L      $01010101


i2r4_030:
    LEA.L     mask4bits(PC),A2

    MOVE.W    i2rmaxx,D1
    LSR.W     #1,D1
    MOVE.W    D1,mfdb_w
    LSR.W     #2,D1
    SUBQ.W    #1,D1               ; D1 = largeur/8-1
    MOVE.W    D1,width
    MOVE.W    i2rmaxx,D1
    DIVS.W    D1,D0               ; nb lignes --> D0.W
    MOVE.W    D0,height
    
    MOVEQ.L   #0,D2
    MOVE.W    mfdb_w(PC),D2
    MOVE.W    width(PC),D0
    ADDQ.L    #1,D0
    LSL.W     #2,D0
    SUB.W     D0,D2
    MOVEQ.L   #0,D5
    MOVE.L    #$70001,D6
    
    MOVE.W    height(PC),D1
    BEQ       not_a_line4_030
    SUBQ.W    #1,D1
not_a_line4_030:
    MOVEQ     #%1111,D4
    
.ligne_4030:
    MOVE.W    width(PC),D0
.groupe8_4030:
    MOVEQ.L   #0,D7
    MOVE.L    (A0)+,D3
    ROL.L     #8,D3

    REPT      3
    MOVE.B    D3,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D7
    ROL.L     #8,D3
    ADD.L     D7,D7
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D7
    ADD.L     D7,D7

    MOVE.L    (A0)+,D3
    ROL.L     #8,D3

    REPT      3
    MOVE.B    D3,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D7
    ROL.L     #8,D3
    ADD.L     D7,D7
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D7

    MOVEP.L   D7,(A1)
    ADDA.W    D6,A1
    SWAP      D6
    
    DBRA      D0,.groupe8_4030
    ADDA.L    D2,A1
    DBRA      D1,.ligne_4030

    MOVE.L    A1,i2rout
    RTS

i2r4_000:
    LEA.L     mask4bits(PC),A2

    MOVE.W    i2rmaxx,D1
    LSR.W     #1,D1
    MOVE.W    D1,mfdb_w
    LSR.W     #2,D1
    SUBQ.W    #1,D1               ; D1 = largeur/8-1
    MOVE.W    D1,width
    MOVE.W    i2rmaxx,D1
    DIVS.W    D1,D0               ; nb lignes --> D0.W
    MOVE.W    D0,height
    
    MOVEQ.L   #0,D2
    MOVE.W    mfdb_w(PC),D2
    MOVE.W    width(PC),D0
    ADDQ.L    #1,D0
    LSL.W     #2,D0
    SUB.W     D0,D2
    MOVEQ.L   #0,D5
    MOVE.L    #$70001,D6
    
    MOVE.W    height(PC),D1
    BEQ       not_a_line4_000
    SUBQ.W    #1,D1
not_a_line4_000:
    MOVEQ     #%1111,D4
    
.ligne_4:
    MOVE.W    width(PC),D0
.groupe8_4:
    MOVEQ.L   #0,D7
    MOVE.L    (A0)+,D3
    ROL.L     #8,D3

    REPT      3
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
    ROL.L     #8,D3
    ADD.L     D7,D7
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
    ADD.L     D7,D7

    MOVE.L    (A0)+,D3
    ROL.L     #8,D3

    REPT      3
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
    ROL.L     #8,D3
    ADD.L     D7,D7
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7

    MOVEP.L   D7,(A1)
    ADDA.W    D6,A1
    SWAP      D6
    
    DBRA      D0,.groupe8_4
    ADDA.L    D2,A1
    DBRA      D1,.ligne_4

    MOVE.L    A1,i2rout
    RTS


i2r8_030:
    LEA.L     mask4bits(PC),A2

    MOVE.W    i2rmaxx,D1
    LSR.W     #1,D1
    MOVE.W    D1,mfdb_w
    LSR.W     #2,D1
    SUBQ.W    #1,D1               ; D1 = largeur/8-1
    MOVE.W    D1,width
    MOVE.W    i2rmaxx,D1
    DIVS.W    D1,D0               ; nb lignes --> D0.W
    MOVE.W    D0,height

    MOVEQ.L   #0,D2
    MOVE.W    mfdb_w(PC),D2
    MOVE.W    width(PC),D0
    ADDQ.L    #1,D0
    LSL.W     #2,D0
    SUB.W     D0,D2
    MOVEQ.L   #0,D5
    MOVE.L    #$F0001,D6
    
    MOVE.W    height(PC),D1
    BEQ       not_a_line8_030
    SUBQ.W    #1,D1
not_a_line8_030:
    MOVEQ     #%1111,D4
    
.ligne_8030:
    MOVE.W    width(PC),D0
.groupe8_8030:
    MOVEQ.L   #0,D7
    MOVEQ.L   #0,D2
    MOVE.L    (A0)+,D3
    ROL.L     #8,D3

    REPT      3
    MOVE.B    D3,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D7
    MOVE.B    D3,D5
    LSR.W     #4,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D2
    ROL.L     #8,D3
    ADD.L     D7,D7
    ADD.L     D2,D2
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D7
    MOVE.B    D3,D5
    LSR.W     #4,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D2
    ADD.L     D7,D7
    ADD.L     D2,D2

    MOVE.L    (A0)+,D3
    ROL.L     #8,D3

    REPT      3
    MOVE.B    D3,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D7
    MOVE.B    D3,D5
    LSR.W     #4,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D2
    ROL.L     #8,D3
    ADD.L     D7,D7
    ADD.L     D2,D2
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D7
    MOVE.B    D3,D5
    LSR.W     #4,D5
    AND.W     D4,D5
    OR.L      (A2,D5*4),D2

    MOVEP.L   D7,(A1)
    MOVEP.L   D2,8(A1)
    ADDA.W    D6,A1
    SWAP      D6

    DBRA      D0,.groupe8_8030
;    ADDA.L    D2,A1
    DBRA      D1,.ligne_8030

    MOVE.L    A1,i2rout
    RTS

i2r8_000:
    LEA.L     mask4bits(PC),A2

    MOVE.W    i2rmaxx,D1
    LSR.W     #1,D1
    MOVE.W    D1,mfdb_w
    LSR.W     #2,D1
    SUBQ.W    #1,D1               ; D1 = largeur/8-1
    MOVE.W    D1,width
    MOVE.W    i2rmaxx,D1
    DIVS.W    D1,D0               ; nb lignes --> D0.W
    MOVE.W    D0,height

    MOVEQ.L   #0,D2
    MOVE.W    mfdb_w(PC),D2
    MOVE.W    width(PC),D0
    ADDQ.L    #1,D0
    LSL.W     #2,D0
    SUB.W     D0,D2
    MOVEQ.L   #0,D5
    MOVE.L    #$F0001,D6
    
    MOVE.W    height(PC),D1
    BEQ       not_a_line8_000
    SUBQ.W    #1,D1
not_a_line8_000:
    MOVEQ     #%1111,D4
    
.ligne_8:
    MOVE.W    width(PC),D0
.groupe8_8:
    MOVEQ.L   #0,D7
    MOVEQ.L   #0,D2
    MOVE.L    (A0)+,D3
    ROL.L     #8,D3

    REPT      3
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
    MOVE.B    D3,D5
    LSR.W     #4,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D2
    ROL.L     #8,D3
    ADD.L     D7,D7
    ADD.L     D2,D2
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
    MOVE.B    D3,D5
    LSR.W     #4,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D2
    ADD.L     D7,D7
    ADD.L     D2,D2

    MOVE.L    (A0)+,D3
    ROL.L     #8,D3

    REPT      3
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
    MOVE.B    D3,D5
    LSR.W     #4,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D2
    ROL.L     #8,D3
    ADD.L     D7,D7
    ADD.L     D2,D2
    ENDM
    MOVE.B    D3,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D7
    MOVE.B    D3,D5
    LSR.W     #4,D5
    AND.W     D4,D5
    LSL.W     #2,D5
    OR.L      (A2,D5.W),D2

    MOVEP.L   D7,(A1)
    MOVEP.L   D2,8(A1)
    ADDA.W    D6,A1
    SWAP      D6

    DBRA      D0,.groupe8_8
;    ADDA.L    D2,A1
    DBRA      D1,.ligne_8

    MOVE.L    A1,i2rout
    RTS

* void tc16_rvbchange(int lo_inligne, int lo_outligne, void *adr_in)
*                          D0              D1                 A0
tc16_rvbchange:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    A0,D3
    MOVE.W    D0,D2             ; D2 = longueur d'une ligne image
    SUBA.L    A5,A5
    MOVE.W    D1,A5             ; A5 = longueur d'une ligne ‚cran

    MOVE.W    #2,-(SP)
    TRAP      #14
    ADDQ.L    #2,SP
    MOVE.L    D0,A2             ; A2 = Adresse ‚cran physique

    MOVE.L    D3,A1             ; A1 -> donn‚es image
    MOVEQ.L   #0,D0
    MOVEQ.L   #0,D1
    MOVE.W    A5,D0
    MOVE.W    yrvb,D1           ; Ligne de d‚part
    MULU.W    D1,D0
    ADD.L     D0,A2
    MOVEQ.L   #0,D0
    MOVE.W    xrvb,D0
    LSL.W     #1,D0
    ADD.L     D0,A2             ; A2 -> 1 er point True Color

    MOVE.W    hrvb,D1           ; D1 = hauteur en points
    SUBQ.W    #1,D1
    ANDI.L    #$FFFF,D2         ; Pour pouvoir faire un ADD.L
    MOVEQ.L   #11,D6
    MOVEQ.L   #$1F,D7

    MOVE.L    red_pal,A0
yrvbloop:
    MOVE.W    wrvb,D0          ; D0 = largeur en points
    SUBQ.W    #1,D0
    MOVE.L    A1,A3
    MOVE.L    A2,A4
xrvbloop:
    MOVE.W    (A3)+,D3

    MOVE.W    D3,D4
    AND.W     D7,D4
    MOVE.L    blue_pal,A6
    MOVE.B    (A6,D4.W),D4     ; D4 = nouvelle composante bleu

    MOVE.W    D3,D5
    LSR.W     #6,D5
    AND.W     D7,D5
    MOVE.L    green_pal,A6
    MOVE.B    (A6,D5.W),D5
    LSL.W     #6,D5            ; D5 = nouvelle composante verte
    ADD.W     D5,D4
    
    MOVE.W    D3,D5
    LSR.W     D6,D5
    AND.W     D7,D5
    MOVE.B    (A0,D5.W),D5
    LSL.W     D6,D5            ; D5 = nouvelle composante rouge
    ADD.W     D5,D4
    
    MOVE.W    D4,(A4)+
    DBF       D0,xrvbloop
    ADD.L     D2,A1
    ADD.L     A5,A2
    DBF       D1,yrvbloop

    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C


* void tc16_imgchange(void *adr_in, long nb)
*                          A0         D0
tc16_imgchange:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVEQ.L   #1,D4
    MOVEQ.L   #6,D5
    MOVEQ.L   #11,D6
    MOVEQ.L   #$1F,D7

    MOVE.L    red_pal,A1
    MOVE.L    green_pal,A2
    MOVE.L    blue_pal,A3
rvbloop:
    MOVE.W    (A0),D1

    MOVE.W    D1,D2
    AND.W     D7,D2
    MOVE.B    (A3,D2.W),D2     ; D2 = nouvelle composante bleu

    MOVE.W    D1,D3
    LSR.W     D5,D3
    AND.W     D7,D3
    MOVE.B    (A2,D3.W),D3
    LSL.W     D5,D3            ; D3 = nouvelle composante verte
    ADD.W     D3,D2

    MOVE.W    D1,D3
    LSR.W     D6,D3
    AND.W     D7,D3
    MOVE.B    (A1,D3.W),D3
    LSL.W     D6,D3            ; D3 = nouvelle composante rouge
    ADD.W     D3,D2
    
    MOVE.W    D2,(A0)+
    SUB.L     D4,D0
    BGT       rvbloop

    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C

* void tc32_imgchange(void *adr_in, long nb)
*                          A0         D0
tc32_imgchange:
    MOVEM.L   D0-D7/A0-A6,-(SP) ; Sauvegarde du contexte

    MOVE.L    red_pal,A1
    MOVE.L    green_pal,A2
    MOVE.L    blue_pal,A3
    MOVEQ.L   #0,D1
rvbloop32:
    MOVE.B    (A0),D1
    MOVE.B    (A1,D1.W),(A0)+
    MOVE.B    (A0),D1
    MOVE.B    (A2,D1.W),(A0)+
    MOVE.B    (A0),D1
    MOVE.B    (A3,D1.W),(A0)+
    ADDQ.L    #1,A0

    SUBQ.L    #1,D0
    BGT       rvbloop32

    MOVEM.L   (SP)+,D0-D7/A0-A6 ; Restauration du contexte
    RTS                         ; Retour au programme C


*****************************************************************
* row2find(MFDB *in, int col, unsigned char *buffer)            *
*            A0       D0              A1                        *
* Transformation d'une colonne raster en un suite d'indices TOS *
* On commence … remplir la fin du buffer                        *
*****************************************************************
row2find:
    MOVEM.L   D0-D7/A0-A3,-(SP)
    MOVEQ.L   #0,D1
    MOVEQ.L   #0,D2
    MOVEQ.L   #0,D3

    MOVE.W    6(A0),D4
    SUBQ.W    #1,D4             ; Nombre de points sur cette colonne

    MOVE.W    12(A0),D3         ; D3 = Nombre de plans
    MOVE.W    8(A0),D1          ; D1 = in->fd_wdwidth
    MULU.W    D3,D1             ; Nombre de mots sur une ligne
    ADD.L     D1,D1             ; D1 = Longueur d'une ligne en octets

    ADD.W     6(A0),A1          ; On commence … remplir le buffer par la fin

    MOVE.W    D0,D2
    LSR.W     #4,D2
    MULU.W    D3,D2
    ADD.W     D2,D2
    MOVE.L    (A0),A0           ; A0 = in->fd_addr
    ADD.L     D2,A0             ; Adresse du 1 er mot … traiter
    BTST.B    #3,D0
    BEQ       fnadd1
    ADD.L     #1,A0             ; Bit < 8 : Octet suivant

fnadd1:
    NOT.B     D0                ; Bit … traiter
    SUBQ.W    #1,D3

frowloop:
    MOVEQ.L   #0,D5             ; Contiendra l'indice TOS
    MOVE.W    D3,D6
    MOVEQ.L   #0,D7
    MOVE.L    A0,A2
fplane_loop:
    BTST.B    D0,(A2)
    BEQ       frnotset
    BSET      D7,D5
frnotset:
    ADDQ.W    #1,D7
    ADDQ.W    #2,A2
    DBF       D6,fplane_loop
    MOVE.B    D5,-(A1)
    ADD.L     D1,A0    
    DBF       D4,frowloop

    MOVEM.L   (SP)+,D0-D7/A0-A3
    RTS


*****************************************************************
* row2dind(MFDB *in, int col, unsigned char *buffer)            *
*            A0       D0              A1                        *
* Transformation d'une colonne raster en un suite d'indices TOS *
* On commence … remplir le d‚but du buffer                      *
*****************************************************************
row2dind:
    MOVEM.L   D0-D7/A0-A3,-(SP)
    MOVEQ.L   #0,D1
    MOVEQ.L   #0,D2
    MOVEQ.L   #0,D3

    MOVE.W    6(A0),D4
    SUBQ.W    #1,D4             ; Nombre de points sur cette colonne

    MOVE.W    12(A0),D3         ; D3 = Nombre de plans
    MOVE.W    8(A0),D1          ; D1 = in->fd_wdwidth
    MULU.W    D3,D1             ; Nombre de mots sur une ligne
    ADD.L     D1,D1             ; D1 = Longueur d'une ligne en octets

    MOVE.W    D0,D2
    LSR.W     #4,D2
    MULU.W    D3,D2
    ADD.W     D2,D2
    MOVE.L    (A0),A0           ; A0 = in->fd_addr
    ADD.L     D2,A0             ; Adresse du 1 er mot … traiter
    BTST.B    #3,D0
    BEQ       dnadd1
    ADD.L     #1,A0             ; Bit < 8 : Octet suivant

dnadd1:
    NOT.B     D0                ; Bit … traiter
    SUBQ.W    #1,D3

drowloop:
    MOVEQ.L   #0,D5             ; Contiendra l'indice TOS
    MOVE.W    D3,D6
    MOVEQ.L   #0,D7
    MOVE.L    A0,A2
dplane_loop:
    BTST.B    D0,(A2)
    BEQ       rnotset
    BSET      D7,D5
rnotset:
    ADDQ.W    #1,D7
    ADDQ.W    #2,A2
    DBF       D6,dplane_loop
    MOVE.B    D5,(A1)+
    ADD.L     D1,A0    
    DBF       D4,drowloop

    MOVEM.L   (SP)+,D0-D7/A0-A3
    RTS


* int pixel_getmode1(int x, int y)
*                      D0     D1
pixel_getmode1:
    MOVE.L    D2,-(SP)
    MOVE.W    D0,D2
    LSR.W     #3,D2
    NEG.W     D0
    MOVE.L    pixel_adrin,A0
    MOVE.L    pixel_lgoff,A1
    ADD.L     (A1,D1),A0
    ADD.L     D2,A0
    BTST.B    D0,(A0)
    BEQ       p10
    MOVEQ.L   #1,D0
    MOVE.L    (SP)+,D2
    RTS
p10:
    MOVEQ.L   #0,D0
    MOVE.L    (SP)+,D2
    RTS

* int pixel_getmode2(int x, int y)
*                      D0     D1
pixel_getmode2:
    MOVE.L    D2,-(SP)
    MOVE.W    D0,D2
    LSR.W     #3,D2
    NEG.W     D0
    MOVE.L    pixel_adrin,A0
    MOVE.L    pixel_lgoff,A1
    ADD.L     (A1,D1),A0
    ADD.L     D2,A0
    BTST.B    D0,(A0)
    BEQ       p20
    MOVEQ.L   #1,D0
    MOVE.L    (SP)+,D2
    RTS
p20:
    MOVEQ.L   #0,D0
    MOVE.L    (SP)+,D2
    RTS

* int pixel_getmode4(int x, int y)
*                      D0     D1
pixel_getmode4:
    MOVE.L    D2,-(SP)
    MOVE.W    D0,D2
    LSR.W     #3,D2
    NEG.W     D0
    MOVE.L    pixel_adrin,A0
    MOVE.L    pixel_lgoff,A1
    ADD.L     (A1,D1),A0
    ADD.L     D2,A0
    BTST.B    D0,(A0)
    BEQ       p40
    MOVEQ.L   #1,D0
    MOVE.L    (SP)+,D2
    RTS
p40:
    MOVEQ.L   #0,D0
    MOVE.L    (SP)+,D2
    RTS


* int pixel_getmode8(int x, int y)
*                      D0     D1
pixel_getmode8:
    MOVE.L    D2,-(SP)
    MOVE.W    D0,D2
    LSR.W     #3,D2
    NEG.W     D0
    MOVE.L    pixel_adrin,A0
    MOVE.L    pixel_lgoff,A1
    ADD.L     (A1,D1),A0
    ADD.L     D2,A0
    BTST.B    D0,(A0)
    BEQ       p80
    MOVEQ.L   #1,D0
    MOVE.L    (SP)+,D2
    RTS
p80:
    MOVEQ.L   #0,D0
    MOVE.L    (SP)+,D2
    RTS

* int pixel_tcget(int x, int y)
*                   D0     D1
pixel_tcget:
    MOVE.L    pixel_adr,A0
    MOVE.L    pixel_lgoff,A1
    ADD.W     D0,D0
    LSL.W     #2,D1
    ADD.L     (A1,D1),A0
    MOVE.W    (A0,D0),D0
    RTS

pixel_030tcget:
    MOVE.L    pixel_adr,A0
    MOVE.L    pixel_lgoff,A1
    ADD.L     (A1,D1*4),A0
    MOVE.W    (A0,D0*2),D0
    RTS

pixel_tcget32:
    MOVE.L    pixel_adr,A0
    MOVE.L    pixel_lgoff,A1
    LSL.W     #2,D0
    LSL.W     #2,D1
    ADD.L     (A1,D1),A0
    MOVE.L    (A0,D0),D0
    RTS

pixel_030tcget32:
    MOVE.L    pixel_adr,A0
    MOVE.L    pixel_lgoff,A1
    ADD.L     (A1,D1*4),A0
    MOVE.L    (A0,D0*4),D0
    RTS

pixel_tcget24:
    MOVE.L    pixel_adr,A0
    MOVE.L    pixel_lgoff,A1
    LSL.W     #2,D1
    ANDI.L    #$FFFF,D0
    ADD.L     (A1,D1),A0
    ADD.L     A1,D0
    ADD.L     A1,D0
    ADD.L     A1,D0
    MOVE.B    (A0)+,D0
    LSL.L     #8,D0
    MOVE.B    (A0)+,D0
    LSL.L     #8,D0
    MOVE.B    (A0)+,D0
    LSL.L     #8,D0
    RTS

* void cycling_ado(int sens)
*                   D0
cycling_ado:
    CMP.W      #4,nb_plane
    BEQ        cycling_do4
    CMP.W      #8,nb_plane
    BEQ        cycling_do8
    RTS

cycling_do4:
    BTST       #0,D0
    BEQ cycling_do40
    BTST       #1,D0
    BNE        cycling_do41w
cycling_do41l:
    MOVE.L     adr_palette,A0
    MOVE.L     A0,A1
    ADDQ.L     #4,A1
    MOVE.L     (A0),D0
    REPT       14
    MOVE.L     (A1)+,(A0)+
    ENDM
    MOVE.L     D0,(A0)
    RTS

cycling_do41w:
    MOVE.L     adr_palette,A0
    MOVE.L     A0,A1
    ADDQ.L     #4,A1
    MOVE.W     (A0),D0
    REPT       14
    MOVE.W     (A1)+,(A0)+
    ENDM
    MOVE.W     D0,(A0)
    RTS

cycling_do40:
    BTST       #1,D0
    BNE        cycling_do40w
cycling_do40l:
    MOVE.L     adr_palette,A0
    ADD.L      #15*4,A0
    MOVE.L     A0,A1
    SUBQ.L     #4,A1
    MOVE.L     (A1),D0
    REPT       14
    MOVE.L     -(A1),-(A0)
    ENDM
    MOVE.L     D0,(A1)
    RTS

cycling_do40w:
    MOVE.L     adr_palette,A0
    ADD.L      #15*4,A0
    MOVE.L     A0,A1
    SUBQ.L     #4,A1
    MOVE.W     (A1),D0
    REPT       14
    MOVE.W     -(A1),-(A0)
    ENDM
    MOVE.W     D0,(A1)
    RTS

cycling_do8:
    BTST       #0,D0
    BEQ cycling_do80
    BTST       #1,D0
    BNE        cycling_do81w
cycling_do81l:
    MOVE.L     adr_palette,A0
    MOVE.L     A0,A1
    ADDQ.L     #4,A1
    MOVE.L     (A0),D0
    REPT       254
    MOVE.L     (A1)+,(A0)+
    ENDM
    MOVE.L     D0,(A0)
    RTS

cycling_do81w:
    MOVE.L     adr_palette,A0
    MOVE.L     A0,A1
    ADDQ.L     #4,A1
    MOVE.W     (A0),D0
    REPT       254
    MOVE.W     (A1)+,(A0)+
    ENDM
    MOVE.W     D0,(A0)
    RTS

cycling_do80:
    BTST       #1,D0
    BNE        cycling_do80w
cycling_do80l:
    MOVE.L     adr_palette,A0
    ADD.L      #255*4,A0
    MOVE.L     A0,A1
    SUBQ.L     #4,A1
    MOVE.L     (A1),D0
    REPT       254
    MOVE.L     -(A1),-(A0)
    ENDM
    MOVE.L     D0,(A1)
    RTS

cycling_do80w:
    MOVE.L     adr_palette,A0
    ADD.L      #255*4,A0
    MOVE.L     A0,A1
    SUBQ.L     #4,A1
    MOVE.W     (A1),D0
    REPT       254
    MOVE.W     -(A1),-(A0)
    ENDM
    MOVE.W     D0,(A1)
    RTS


********************************************
* ClassicAtari2StdVDI(MFDB *in, MFDB *out) *
*                         A0       A1      *
********************************************
ClassicAtari2StdVDI:
    MOVEM.L    D0-D3/A0-A2,-(SP)
    MOVEQ.L    #0,D0
    MOVEQ.L    #0,D1
    MOVEQ.L    #0,D2
    MOVE.W     FD_NPLANES(A0),D0
    SUBQ.W     #1,D0                 ; Pour DBF
    MOVE.W     FD_NPLANES(A0),D1
    ADD.L      D1,D1                 ; Plan suivant
    MOVE.W     FD_WDWIDTH(A0),D3
    MULU.W     FD_H(A0),D3

    MOVE.L     FD_ADDR(A0),A2
    MOVE.L     FD_ADDR(A1),A1

trn_otherplane:
    MOVE.L     A2,A0
    MOVE.L     D3,D2
trn_thisplane:
    MOVE.W     (A0),(A1)+
    ADD.L      D1,A0
    SUBQ.L     #1,D2
    BNE        trn_thisplane
    ADDQ.L     #2,A2
    DBF        D0,trn_otherplane

    MOVEM.L    (SP)+,D0-D3/A0-A2

    RTS


********************************************
* StdVDI2ClassicAtari(MFDB *in, MFDB *out) *
*                         A0       A1      *
********************************************
StdVDI2ClassicAtari:
    MOVEM.L    D0-D3/A0-A2,-(SP)
    MOVEQ.L    #0,D0
    MOVEQ.L    #0,D1
    MOVEQ.L    #0,D2
    MOVE.W     FD_NPLANES(A0),D0
    SUBQ.W     #1,D0                 ; Pour DBF
    MOVE.W     FD_NPLANES(A0),D1
    ADD.L      D1,D1                 ; Plan suivant
    MOVE.W     FD_WDWIDTH(A0),D3
    MULU.W     FD_H(A0),D3

    MOVE.L     FD_ADDR(A0),A0
    MOVE.L     FD_ADDR(A1),A2

vtrn_otherplane:
    MOVE.L     A2,A1
    MOVE.L     D3,D2
vtrn_thisplane:
    MOVE.W     (A0)+,(A1)
    ADD.L      D1,A1
    SUBQ.L     #1,D2
    BNE        vtrn_thisplane
    ADDQ.L     #2,A2
    DBF        D0,vtrn_otherplane

    MOVEM.L    (SP)+,D0-D3/A0-A2

    RTS


    MACRO     SET16
* A0 --> Dst
* D0 = Mot 16 bits a copier (initialiser parties hautes & basses)
* D1 = nb de mots 16 bits a copier
* D2,D3 : variables temporaires
    MOVE.L    D1,D2
    LSR.L     #5,D2
    BTST      #0,D1           ; Nombre impair de mots 16 bits ?
    BEQ       2
    MOVE.W    D0,(A0)+        ; oui : on en copie un, le reste c'est du 32 bits
* Calcul offset
    MOVE.L    D1,D3
    LSR.L     #1,D3           ; On recopiera des mots longs
    ANDI.W    #$0F,D3
    ADD.W     D3,D3
    NEG.W     D3
    JMP       2+2*16(PC,D3.W)
    REPT 16
    MOVE.L    D0,(A0)+
    ENDM
    DBF       D2,-2-2*16

    ENDM

    MACRO     SET32
* A0 --> Dst
* D0 = Mot 32 bits a copier (initialiser parties hautes & basses)
* D1 = nb de mots 32 bits a copier
* D2,D3 : variables temporaires
    MOVE.L    D1,D2
    LSR.L     #4,D2
* Calcul offset
    MOVE.L    D1,D3
    ANDI.W    #$0F,D3
    ADD.W     D3,D3
    NEG.W     D3
    JMP       2+2*16(PC,D3.W)
    REPT 16
    MOVE.L    D0,(A0)+
    ENDM
    DBF       D2,-2-2*16

    ENDM

***************************
* void img_raz(MFDB *img) *
*                 A0      *
***************************
img_raz:
    MOVEM.L    D0-D3/A0,-(SP)

    MOVE.W     FD_NPLANES(A0),D2        ; D2.W = nb planes
    MOVE.W     FD_WDWIDTH(A0),D1        ; D1 = Largeur en mots
    MULU.W     D2,D1                    ; D1 = Nb de mots 16 bits sur une ligne
    MULU.W     FD_H(A0),D1              ; Nb de mots 16 bits dans l'image
    MOVE.L     FD_ADDR(A0),A0           ; A0 --> donn‚es image
    MOVEQ.L    #0,D0

    CMPI.W     #32,D2
    BEQ        img_raztc32
    CMPI.W     #8,D2
    BLE        img_razwords
* Cas 16 ou 24 bits
    MOVEQ.L    #$FFFFFFFF,D0

img_razwords:
    SET16
    BRA        img_razend

img_raztc32:
    MOVE.L     #$FFFFFF00,D0
    LSR.L      #1,D1
    SET32

img_razend:
    MOVEM.L    (SP)+,D0-D3/A0
    RTS

***************************
* void img_raz(MFDB *img) *
*                 A0      *
***************************
old_img_raz:
    MOVEM.L    D0-D4/A0,-(SP)

    MOVE.W     FD_NPLANES(A0),D0        ; D0 = Nb Plans
    MOVE.W     FD_WDWIDTH(A0),D1        ; D1 = Largeur en mots
    SUBQ.W     #1,D1                    ; Largeur en mots -1 pour DBF
    MOVE.W     FD_H(A0),D2              ; D2 = Hauteur
    SUBQ.W     #1,D2                    ;      -1 pour DBF
    MOVE.L     FD_ADDR(A0),A0           ; A0 --> donn‚es image
    MOVEQ.L    #0,D3                    ; D3 = 0 (cas non TC)

    CMPI.W     #1,D0
    BEQ        proc_raz1
    CMPI.W     #2,D0
    BEQ        proc_raz2
    CMPI.W     #4,D0
    BEQ        proc_raz4
    CMPI.W     #8,D0
    BEQ        proc_raz8
    CMPI.W     #16,D0
    BEQ        proc_raz16
    CMPI.W     #24,D0
    BEQ        proc_raz24
    CMPI.W     #32,D0
    BEQ        proc_raz32

img_raz_end:
    MOVEM.L    (SP)+,D0-D4/A0

    RTS

proc_raz1:
img_raz1:
    MOVE.W     D1,D4
raz_w1:
    MOVE.W     D3,(A0)+
    DBF        D4,raz_w1
    DBF        D2,img_raz1
    BRA        img_raz_end

proc_raz2:
img_raz2:
    MOVE.W     D1,D4
raz_w2:
    MOVE.L     D3,(A0)+
    DBF        D4,raz_w2
    DBF        D2,img_raz2
    BRA        img_raz_end

proc_raz4:
img_raz4:
    MOVE.W     D1,D4
raz_w4:
    REPT       2
    MOVE.L     D3,(A0)+
    ENDM
    DBF        D4,raz_w4
    DBF        D2,img_raz4
    BRA        img_raz_end

proc_raz8:
img_raz8:
    MOVE.W     D1,D4
raz_w8:
    REPT       4
    MOVE.L     D3,(A0)+
    ENDM
    DBF        D4,raz_w8
    DBF        D2,img_raz8
    BRA        img_raz_end

proc_raz16:
img_raz16:
    MOVE.L     #$FFFFFFFF,D3            ; 2 Blancs 16 Bits = %1111111111111111
    MOVE.W     D1,D4
raz_w16:
    REPT       8
    MOVE.L     D3,(A0)+
    ENDM
    DBF        D4,raz_w16
    DBF        D2,img_raz16
    BRA        img_raz_end

proc_raz24:
img_raz24:
    MOVE.L     #$FFFFFFFF,D3    ; Blanc 24 Bits
    MOVE.W     D1,D4
raz_w24:
    REPT       12
    MOVE.L     D3,(A0)+
    ENDM
    DBF        D4,raz_w24
    DBF        D2,img_raz24
    BRA        img_raz_end

proc_raz32:
img_raz32:
    MOVE.L     #$FFFFFF00,D3            ; 1 Blanc 32 Bits
    MOVE.W     D1,D4
raz_w32:
    REPT       16
    MOVE.L     D3,(A0)+
    ENDM
    DBF        D4,raz_w32
    DBF        D2,img_raz32
    BRA        img_raz_end


********************************
* void tc_convert( MFDB *img ) *
*                      A0      *
* RRRRRGGGGGGBBBBB ---> ?????? *
********************************
tc_convert:
    MOVEM.L    D0-D7/A0-A1,-(SP)
    TST.W      UseStdVDI
    BEQ        tc_convert_rts

    MOVE.W     FD_NPLANES(A0),D2     ; D2 = Nombre de Plans (16, 24 ou 32)
    MOVE.W     FD_H(A0),D7
    MULU.W     FD_W(A0),D7           ; D7.L = Nombre de pixels 16 bits … convertir
    MOVE.L     FD_ADDR(A0),A0        ; A0 --> Adresse du premier pixel a convertir

    LEA.L      RVBOrg,A1
    MOVE.W     RRED(A1),D4           ; D6 = Rotate Rouge pour SET_RBG16
    MOVE.W     RGREEN(A1),D5         ; D5 = Rotate Vert pour SET_RBG16
    MOVE.W     RBLUE(A1),D6          ; D4 = Rotate Bleu pour SET_RBG16

    TST.W      IS15BITS(A1)
    BNE        tcconv_15
    CMPI.W     #16,D2
    BEQ        tcconv_16
    CMPI.W     #24,D2
    BEQ        tcconv_24
    CMPI.W     #32,D2
    BEQ        tcconv_32

tc_convert_rts:
    MOVEM.L    (SP)+,D0-D7/A0-A1
    RTS

tcconv_15:
    GET_FRGB15        ; D1.W = BLEU, D2.W = VERT, D3.W = ROUGE
                      ;    0...31,      0...31,      0...31
    SET_RGB16

    MOVE.W  D0,(A0)+
    SUBQ.L  #1,D7
    BGT     tcconv_15
    BRA     tc_convert_rts

tcconv_16:
    GET_FRGB16        ; D1.W = BLEU, D2.W = VERT, D3.W = ROUGE
                      ;    0...31,      0...63,      0...31
    SET_RGB16

    MOVE.W  D0,(A0)+
    SUBQ.L  #1,D7
    BGT     tcconv_16
    BRA     tc_convert_rts

tcconv_24:
    GET_FRGB24        ; D1.W = BLEU, D2.W = VERT, D3.W = ROUGE
                      ;    0...255,      0...255,      0...255
    SET_RGB24 

    ADD.L  #3,A0      ; SET_RGB24 travaille en memoire !
    SUBQ.L  #1,D7
    BGT     tcconv_24
    BRA     tc_convert_rts

tcconv_32:
    GET_FRGB32        ; D1.W = BLEU, D2.W = VERT, D3.W = ROUGE
                      ;    0...255,      0...255,      0...255
    SET_RGB32 

    ADD.L  #4,A0      ; SET_RGB32 travaille en memoire !
    SUBQ.L  #1,D7
    BGT     tcconv_32
    BRA     tc_convert_rts


***********************************
* void tc_invconvert( MFDB *img ) *
*                         A0      *
* ??????? --> RRRRRGGGGGGBBBBB    *
***********************************
tc_invconvert:
    MOVEM.L    D0-D7/A0-A1,-(SP)
    TST.W      UseStdVDI
    BEQ        tc_iconvert_rts

    MOVE.W     FD_NPLANES(A0),D2     ; D2 = Nombre de Plans (16, 24 ou 32)
    MOVE.W     FD_H(A0),D7
    MULU.W     FD_W(A0),D7           ; D7.L = Nombre de pixels 16 bits … convertir
    MOVE.L     FD_ADDR(A0),A0        ; A0 --> Adresse du premier pixel a convertir

    LEA.L      RVBOrg,A1
    MOVE.W     RRED(A1),D4           ; D6 = Rotate Rouge pour SET_RBG16
    MOVE.W     RGREEN(A1),D5         ; D5 = Rotate Vert pour SET_RBG16
    MOVE.W     RBLUE(A1),D6          ; D4 = Rotate Bleu pour SET_RBG16

    TST.W      IS15BITS(A1)
    BNE        tciconv_15
    CMPI.W     #16,D2
    BEQ        tciconv_16
    CMPI.W     #24,D2
    BEQ        tciconv_24
    CMPI.W     #32,D2
    BEQ        tciconv_32

tc_iconvert_rts:
    MOVEM.L    (SP)+,D0-D7/A0-A1
    RTS


tciconv_15:
    GET_RGB15        ; D1.W = BLEU, D2.W = VERT, D3.W = ROUGE
                     ;    0...31,      0...31,      0...31
    ADD.W    D2,D2
    SET_FRGB16

    MOVE.W  D0,(A0)+
    SUBQ.L  #1,D7
    BGT     tciconv_15
    BRA     tc_iconvert_rts

tciconv_16:
    GET_RGB16        ; D1.W = BLEU, D2.W = VERT, D3.W = ROUGE
                     ;    0...31,      0...63,      0...31
    SET_FRGB16

    MOVE.W  D0,(A0)+
    SUBQ.L  #1,D7
    BGT     tciconv_16
    BRA     tc_iconvert_rts

tciconv_24:
    GET_RGB24        ; D1.W = BLEU, D2.W = VERT, D3.W = ROUGE
                     ;    0...31,      0...63,      0...31
    SET_FRGB24

    ADD.L   #3,A0      ; SET_FRGB24 travaille en memoire !
    SUBQ.L  #1,D7
    BGT     tciconv_24
    BRA     tc_iconvert_rts

tciconv_32:
    GET_RGB32        ; D1.W = BLEU, D2.W = VERT, D3.W = ROUGE
                     ;    0...31,      0...63,      0...31
    SET_FRGB32

    ADD.L  #4,A0      ; SET_FRGB32 travaille en memoire !
    SUBQ.L  #1,D7
    BGT     tciconv_32
    BRA     tc_iconvert_rts

************************************
* int  GetRolw(int w, int motif)   *
*                D0         D1     *
************************************
GetRolw:
    MOVEM.L    D2/D3,-(SP)

    MOVEQ.L    #15,D2
rtstw:
    MOVE.W     D1,D3
    ROL.W      D2,D3
    CMP.W      D0,D3
    DBEQ       D2, rtstw

    MOVE.W     D2,D0
    MOVEM.L    (SP)+,D2/D3
    RTS

************************************
* int  GetRoll(long w, int motif)  *
*                D0         D1     *
************************************
GetRoll:
    MOVEM.L    D2/D3,-(SP)

    ANDI.L     #$0000FFFF,D1
    MOVEQ.L    #31,D2
rtstl:
    MOVE.L     D1,D3
    ROL.L      D2,D3
    CMP.L      D0,D3
    DBEQ       D2, rtstl

    MOVE.W     D2,D0
    MOVEM.L    (SP)+,D2/D3
    RTS

********************************************
* void  TC15RemapColors(REMAP_COLORS *rc)  *
*                                    A0    *
********************************************
TC15RemapColors:
    MOVEM.L   A2/A3/D2-D7,-(SP)

    LEA.L     RVBOrg,A1
    MOVE.W    RRED(A1),D4     ; D4 = Rotate Rouge pour SET_RBG16
    MOVE.W    RGREEN(A1),D5   ; D5 = Rotate Vert pour SET_RBG16
    MOVE.W    RBLUE(A1),D6    ; D6 = Rotate Bleu pour SET_RBG16

    MOVE.L    REDMAP(A0),A1   ; A1 -> red map
    MOVE.L    GREENMAP(A0),A2 ; A2 -> green map
    MOVE.L    BLUEMAP(A0),A3  ; A3 -> blue map
    MOVE.L    NBPTS(A0),D7    ; D7 = nb_pts
    SUBI.L    #1,D7           ; -1 por DBF
    MOVE.L    PTIMG(A0),A0    ; A0 --> img

TC15RemapColors_loop:
    GET_RGB15              ; D1 = Red, D2=Green, D3=Blue
    MOVE.B    (A1,D1.W),D1
    MOVE.B    (A2,D2.W),D2
    MOVE.B    (A3,D3.W),D3
    SET_RGB16              ; D0 = RRRRR0VVVVVBBBBB
    MOVE.W    D0,(A0)+
    DBF       D7,TC15RemapColors_loop
    MOVEM.L   (SP)+,A2/A3/D2-D7
    RTS

********************************************
* void  TC16RemapColors(REMAP_COLORS *rc)  *
*                                    A0    *
********************************************
TC16RemapColors:
    MOVEM.L   A2/A3/D2-D7,-(SP)

    LEA.L     RVBOrg,A1
    MOVE.W    RRED(A1),D4     ; D4 = Rotate Rouge pour SET_RBG16
    MOVE.W    RGREEN(A1),D5   ; D5 = Rotate Vert pour SET_RBG16
    MOVE.W    RBLUE(A1),D6    ; D6 = Rotate Bleu pour SET_RBG16

    MOVE.L    REDMAP(A0),A1   ; A1 -> red map
    MOVE.L    GREENMAP(A0),A2 ; A2 -> green map
    MOVE.L    BLUEMAP(A0),A3  ; A3 -> blue map
    MOVE.L    NBPTS(A0),D7    ; D7 = nb_pts
    SUBI.L    #1,D7           ; -1 por DBF
    MOVE.L    PTIMG(A0),A0    ; A0 --> img

TC16RemapColors_loop:
    GET_RGB16              ; D1 = Red, D2=Green, D3=Blue
    MOVE.B    (A1,D1.W),D1
    MOVE.B    (A2,D2.W),D2
    MOVE.B    (A3,D3.W),D3
    SET_RGB16              ; D0 = RRRRRVVVVVVBBBBB
    MOVE.W    D0,(A0)+
    DBF       D7,TC16RemapColors_loop
    MOVEM.L   (SP)+,A2/A3/D2-D7
    RTS

********************************************
* void  TC32RemapColors(REMAP_COLORS *rc)  *
*                                    A0    *
********************************************
TC32RemapColors:
    MOVEM.L   A2/A3/D2-D7,-(SP)

    LEA.L     RVBOrg,A1
    MOVE.W    RRED(A1),D4     ; D4 = Rotate Rouge pour SET_RBG16
    MOVE.W    RGREEN(A1),D5   ; D5 = Rotate Vert pour SET_RBG16
    MOVE.W    RBLUE(A1),D6    ; D6 = Rotate Bleu pour SET_RBG16

    MOVE.L    REDMAP(A0),A1   ; A1 -> red map
    MOVE.L    GREENMAP(A0),A2 ; A2 -> green map
    MOVE.L    BLUEMAP(A0),A3  ; A3 -> blue map
    MOVE.L    NBPTS(A0),D7    ; D7 = nb_pts
    SUBI.L    #1,D7           ; -1 por DBF
    MOVE.L    PTIMG(A0),A0    ; A0 --> img
    MOVEQ.L   #0,D1           ; Car D1,D2,D3 sont affectes en Byte par GET_RGB32
    MOVEQ.L   #0,D2
    MOVEQ.L   #0,D3

TC32RemapColors_loop:
    GET_RGB32                 ; D1 = Red, D2=Green, D3=Blue
    MOVE.B    (A1,D1.W),D1
    MOVE.B    (A2,D2.W),D2
    MOVE.B    (A3,D3.W),D3
    SET_RGB32 
    ADD.L      #4,A0          ; SET_RGB32 travaille en memoire !
    DBF       D7,TC32RemapColors_loop
    MOVEM.L   (SP)+,A2/A3/D2-D7
    RTS



    .EVEN
xrvb:
    .DS.W     1
yrvb:
    .DS.W     1
wrvb:
    .DS.W     1
hrvb:
    .DS.W     1
red_pal:
    .DS.L     1
blue_pal:
    .DS.L     1
green_pal:
    .DS.L     1
