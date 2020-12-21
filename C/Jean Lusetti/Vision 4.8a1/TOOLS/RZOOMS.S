    .EXPORT sraster_zoom
    .IMPORT raster2ind, ind2raster
    .IMPORT i2r_data, i2r_nb, i2rout


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

IN                 EQU  0
OUT                EQU  4
SRC_ADDR_LINE      EQU  8
XOFFSETS           EQU  12
YOFFSETS           EQU  16
FLAGS              EQU  20
INDEXES_IN         EQU  22
INDEXES_OUT        EQU  26
LOUT               EQU  30
INCREMENT          EQU  34
SRCW16             EQU  38
DSTW16             EQU  42
NPLANES            EQU  46
WPROG              EQU  48
PROGRESS_FUNCTION  EQU  52    ; int ProgRange(void *wnd, long val, long max, char *txt)
XOFFSET_JUMP_COPY  EQU  56
XOFFSET_JUMP_SCALE EQU  58
PROG               EQU  60



do_progress:
    MOVEM.L A0/A1/A6/D0/D1,-(SP)
    MOVE.L  OUT(A6),A0
    MOVEQ.L #0,D1
    MOVE.W  FD_H(A0),D1               ; D1.L = max
    NEG.W   D0                        ; D0 goes from fd_h to 0
    EXT.L   D0
    ADD.L   D1,D0                     ; D0.L = val
    MOVE.L  WPROG(A6),A0              ; wnd
    CLR.L   A1                        ; txt = NULL
    MOVE.L  PROGRESS_FUNCTION(A6),A6
    JSR     (A6)                      ; ProgRange(wnd, val, max, txt)
    MOVEM.L (SP)+,A0/A1/A6/D0/D1      ;            A0   D0   D1   A1
    RTS

* void sraster_zoom(RASTER_ZOOM *rz)
*                                A0
sraster_zoom:
    MOVEM.L A0-A6/D0-D7,-(SP)
    MOVE.L  LOUT(A0),D7          ; D7.L = dest line in bytes
    MOVE.W  FLAGS(A0),D6         ; D6.W = flags (temp)
    MOVE.L  OUT(A0),A1
    MOVE.W  FD_H(A1),D0          ; D0.W = # dest line
    SUBQ.W  #1,D0
    MOVE.L  FD_ADDR(A1),A4       ; A4 --> dst line
    MOVE.L  IN(A0),A1
    MOVEQ.L #0,D5
    MOVE.W  FD_W(A1),D5          ; D5.W = src size in pixels
    MOVE.W  FD_NPLANES(A1),D2    ; D2.W = # of planes
    MOVE.L  XOFFSETS(A0),A1      ; A1 --> XOffsets
    MOVE.L  YOFFSETS(A0),A2      ; A2 --> YOffsets
    MOVE.L  A0,A6                ; A6 --> rz
    MOVE.L  SRC_ADDR_LINE(A0),A0 ; A0 --> SrcAddrLine
    MOVEQ.L #-1,D3               ; D3.W = last src line
    CLR.L   A5                   ; A5 --> last dst line
    MOVEQ.L #0,D1                ; current dest line
    MOVE.L  D7,D4                ; D4.W = dest line in bytes (to be converted into pixels)
    CMPI.W  #32,D2
    BEQ     sraster_zoom32
    CMPI.W  #16,D2
    BEQ     sraster_zoom16

* Bit-Planes
    LSR.L     #1,D4              ; D4.W = number of words on a dst line
    MOVE.L    INDEXES_OUT(A6),i2r_data
    MOVE.L    DSTW16(A6),i2r_nb
    MOVE.L    INDEXES_IN(A6),A3 ; A3 --> indexes_in
* Prealcul de l'offset pour JMP copy_last_line (D4 doit etre connu)
    MOVE.W    D4,D2
    LSR.W     #1,D2             ; On recopiera des mots longs
    ANDI.W    #$0F,D2
    ADD.W     D2,D2
    NEG.W     D2
    MOVE.W    D2,XOFFSET_JUMP_COPY(A6)

sraster_zoombp:
    MOVE.L   INCREMENT(A6),D5
    SWAP      D5
    TST.W     D5
    BPL.S     loopbp
    SUB.L     #$010000,D5
loopbp:
    MOVE.W    D1,D2
    ADD.W     D2,D2
    MOVE.W    (A2,D2.W),D2       ; D2.W = src line
    MOVE.L    A4,-(SP)
    CMP.W     D3,D2
    BNE.S     xscalebp
    MOVE.L    A5,-(SP)
    MOVE.W    D4,D2
    LSR.W     #5,D2
    BTST      #0,D4              ; Nombre impair de mots 16 bits ?
    BEQ       no_wcopybp
    MOVE.W    (A5)+,(A4)+        ; oui : on en copie un, le reste c'est du 32 bits
no_wcopybp:
    MOVE.W    XOFFSET_JUMP_COPY(A6),D6
    JMP       copy_last_lineendloopbp(PC,D6.W)
copy_last_linebp:
    REPT 16
    MOVE.L    (A5)+,(A4)+
    ENDM
copy_last_lineendloopbp:
    DBF       D2,copy_last_linebp
    MOVE.L    (SP)+,A5
    BRA       end_loopbp
xscalebp:
    MOVE.W    D2,D3
    LSL.W     #2,D2

    MOVEM.L   A0/D0/D1,-(SP)
    MOVE.L    (A0,D2.W),A0      ; A0 --> pt_raster
    MOVE.L    A3,A1             ; A1 --> out
    MOVE.L    SRCW16(A6),D0     ; D0.L = nb pts (16 aligned) src
    MOVE.W    NPLANES(A6),D1    ; D1.W = nb_planes
    BSR       raster2ind
    MOVEM.L   (SP)+,A0/D0/D1

    MOVE.L    A4,A5             ; Remember last dst
    MOVE.L    DSTW16(A6),D2
    LSR.W     #4,D2
    SUBQ.W    #1,D2

    MOVEQ     #0,D6   ; D6 = offset_src
    MOVE.L    INDEXES_OUT(A6),A4
    SUB.W     D5,D6
    ADD.L     D5,D6   ; pour positionner X flag
scale_linebp:
    REPT 16
    MOVE.B    (A3,D6.W),(A4)+   ; Code sur 2 mot
    ADDX.L    D5,D6             ; Code sur 1 mot
    ENDM
    DBF       D2,scale_linebp

    MOVE.L    A5,A4
    MOVE.L    A4,i2rout
    BSR       ind2raster

end_loopbp:
    MOVE.L    (SP)+,A4
    ADDQ.W    #1,D1

    TST.L   PROGRESS_FUNCTION(A6)
    BEQ     no_progressbp
    MOVE.W  D1,D2
    ANDI.B  #$1F,D2
    BNE     no_progressbp
    BSR     do_progress
no_progressbp:

    ADD.L     D7,A4
    DBF       D0,loopbp
    BRA       sraster_zoom_return


sraster_zoom32:
    LSR.L     #2,D4              ; D4.W = number of pixels on a dst line
* Prealcul de l'offset pour JMP copy_last_line (D4 doit etre connu)
    MOVE.W    D4,D2
    ANDI.W    #$0F,D2
    ADD.W     D2,D2
    NEG.W     D2
    MOVE.W    D2,XOFFSET_JUMP_COPY(A6)

loop32:
    MOVE.W    D1,D2
    ADD.W     D2,D2
    MOVE.W    (A2,D2.W),D2       ; D2.W = src line
    MOVE.L    A4,-(SP)
    CMP.W     D3,D2
    BNE.S     xscale32
    MOVE.L    A5,-(SP)
    MOVE.W    D4,D2
    LSR.W     #4,D2
    MOVE.W    XOFFSET_JUMP_COPY(A6),D6
    JMP       copy_last_lineendloop32(PC,D6.W)
copy_last_line32:
    REPT 16
    MOVE.L    (A5)+,(A4)+
    ENDM
copy_last_lineendloop32:
    DBF       D2,copy_last_line32
    MOVE.L    (SP)+,A5
    BRA       end_loop32
xscale32:
    MOVE.W    D2,D3
    LSL.W     #2,D2
    MOVE.L    (A0,D2.W),A3      ; A3 --> src_line
    MOVE.L    A4,A5             ; Remember last dst
    MOVE.W    D4,D2
    MOVE.W    D2,D6
    LSR.W     #3,D2
    ANDI.W    #$07,D6
    MOVE.W    D6,D5
    LSL.W     #3,D6
    ADD.W     D5,D6            ; D6 = D6 * 10
    NEG.W     D6
    MOVEQ.L   #0,D5
    JMP       scale_lineendloop32(PC,D6.W)
scale_line32:
    REPT 8
    MOVE.W    (A1,D5.W),D6
    MOVE.L    (A3,D6.W),(A4)+
    ADDQ.W    #2,D5
    ENDM
scale_lineendloop32:
    DBF       D2,scale_line32    
end_loop32:
    MOVE.L    (SP)+,A4
    ADDQ.W    #1,D1

    TST.L   PROGRESS_FUNCTION(A6)
    BEQ     no_progress32
    MOVE.W  D1,D2
    ANDI.B  #$1F,D2
    BNE     no_progress32
    BSR     do_progress
no_progress32:

    ADD.L     D7,A4
    DBF       D0,loop32
    BRA       sraster_zoom_return

sraster_zoom16:
    LSR.L     #1,D4              ; D4.W = number of pixels on a dst line
* Prealcul de l'offset pour JMP copy_last_line (D4 doit etre connu)
    MOVE.W    D4,D2
    LSR.W     #1,D2             ; On recopiera des mots longs
    ANDI.W    #$0F,D2
    ADD.W     D2,D2
    NEG.W     D2
    MOVE.W    D2,XOFFSET_JUMP_COPY(A6)

    BTST      #1,D6
    BNE       sraster_zoom16_030

* Prealcul de l'offset pour JMP scale_line (D4 doit etre connu)
    MOVE.W    D4,D2
    ANDI.W    #$07,D2
    MULU      #10,D2
    NEG.W     D2
    MOVE.W    D2,XOFFSET_JUMP_SCALE(A6)

loop16:
    MOVE.W    D1,D2
    ADD.W     D2,D2
    MOVE.W    (A2,D2.W),D2       ; D2.W = src line
    MOVE.L    A4,-(SP)
    CMP.W     D3,D2
    BNE.S     xscale16
    MOVE.L    A5,-(SP)
    MOVE.W    D4,D2
    LSR.W     #5,D2
    BTST      #0,D4              ; Nombre impair de mots 16 bits ?
    BEQ       no_wcopy16
    MOVE.W    (A5)+,(A4)+        ; oui : on en copie un, le reste c'est du 32 bits
no_wcopy16:
    MOVE.W    XOFFSET_JUMP_COPY(A6),D6
    JMP       copy_last_lineendloop16(PC,D6.W)
copy_last_line16:
    REPT 16
    MOVE.L    (A5)+,(A4)+
    ENDM
copy_last_lineendloop16:
    DBF       D2,copy_last_line16
    MOVE.L    (SP)+,A5
    BRA       end_loop16
xscale16:
    MOVE.W    D2,D3
    LSL.W     #2,D2
    MOVE.L    (A0,D2.W),A3      ; A3 --> src_line
    MOVE.L    A4,A5             ; Remember last dst
    MOVE.W    D4,D2
    LSR.W     #3,D2

    MOVEQ.L   #0,D5
    MOVE.W    XOFFSET_JUMP_SCALE(A6),D6
    JMP       scale_lineendloop16(PC,D6.W)
scale_line16:
    REPT 8
    MOVE.W    (A1,D5.W),D6
    MOVE.W    (A3,D6.W),(A4)+
    ADDQ.W    #2,D5
    ENDM
scale_lineendloop16:
    DBF       D2,scale_line16    
end_loop16:
    MOVE.L    (SP)+,A4
    ADDQ.W    #1,D1

    TST.L   PROGRESS_FUNCTION(A6)
    BEQ     no_progress16
    MOVE.W  D1,D2
    ANDI.B  #$1F,D2
    BNE     no_progress16
    BSR     do_progress
no_progress16:

    ADD.L     D7,A4
    DBF       D0,loop16
    BRA       sraster_zoom_return

sraster_zoom16_030:
* Prealcul de l'offset pour JMP scale_line (D4 doit etre connu)
    MOVE.W    D4,D2
    ANDI.W    #$0F,D2
    MULU      #6,D2
    NEG.W     D2
    MOVE.W    D2,XOFFSET_JUMP_SCALE(A6)
    LEA.L     scale_lineendloop16_030,A1
    ADDA.W    D2,A1

    SWAP    D5
    DIVU.L  D4,D5
    SWAP    D5
    TST.W   D5
    BPL.S   loop16_030
    SUB.L   #$010000,D5
loop16_030:
    MOVE.W    D1,D2
    ADD.W     D2,D2
    MOVE.W    (A2,D2.W),D2       ; D2.W = src line
    MOVE.L    A4,-(SP)
    CMP.W     D3,D2
    BNE.S     xscale16_030
    MOVE.L    A5,-(SP)
    MOVE.W    D4,D2
    LSR.W     #5,D2
    BTST      #0,D4              ; Nombre impair de mots 16 bits ?
    BEQ       no_wcopy16_030
    MOVE.W    (A5)+,(A4)+        ; oui : on en copie un, le reste c'est du 32 bits
no_wcopy16_030:
    MOVE.W    XOFFSET_JUMP_COPY(A6),D6
    JMP       copy_last_lineendloop16_030(PC,D6.W)
copy_last_line16_030:
    REPT 16
    MOVE.L    (A5)+,(A4)+
    ENDM
copy_last_lineendloop16_030:
    DBF       D2,copy_last_line16_030
    MOVE.L    (SP)+,A5
    BRA       end_loop16_030
xscale16_030:
    MOVE.W    D2,D3
    LSL.W     #2,D2
    MOVE.L    (A0,D2.W),A3      ; A3 --> src_line
    MOVE.L    A4,A5             ; Remember last dst
    MOVE.W    D4,D2
    LSR.W     #4,D2

    MOVEQ     #0,D6   ; D6 = offset_src
    SUB.W     D5,D6
    ADD.L     D5,D6   ; pour positionner X flag

    JMP       (A1)
scale_line16_030:
    REPT 16
    MOVE.W    (A3,D6.W*2),(A4)+ ; Code sur 2 mots
    ADDX.L    D5,D6             ; Code sur 1 mot
    ENDM
scale_lineendloop16_030:
    DBF       D2,scale_line16_030
end_loop16_030:
    MOVE.L    (SP)+,A4
    ADDQ.W    #1,D1

    TST.L   PROGRESS_FUNCTION(A6)
    BEQ     no_progress16_030
    MOVE.W  D1,D2
    ANDI.B  #$1F,D2
    BNE     no_progress16_030
    BSR     do_progress
no_progress16_030:

    ADD.L     D7,A4
    DBF       D0,loop16_030

sraster_zoom_return:
    MOVEM.L   (SP)+,A0-A6/D0-D7
    RTS


