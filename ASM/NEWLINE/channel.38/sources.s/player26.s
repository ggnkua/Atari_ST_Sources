;=============================================================================
;                                                       StarTrack-Replay V2.61
;=============================================================================
;Ω1990-92 by NEWline/Coders Design/GAMES.Software of The Independent

;-Main Coding:
;.....Peter Haaseman.(NINJA III)......NEWline/Coders.Design/GAMES.Software..
;............................................of.The.Independent.............
;-Replay Coding:
;.......Martin Seidel..(Smart)............Channel.38.of.The.Independent.....
;-Graphix:
;......Frank Kurpiela.(Stallion)..........Channel.38.of.The.Independent.....

;-Preview of the official Replay-Rout for StarTrack, The Ultimate SoundTracker.
; StarTrack V1.0 will be avaiable soon for ATARI (Mega) ST(e)/TT/Falcon030
; and PC-Compatible (or IBM-PCs).

;-Contacts for legal reasons:
;
;                    Mark Fechtner (The Innovator of NEWline)
;                    Amselweg  107
;                   W-2964 Wiesmoor
;                      -Germany-
;
;Ω1992 by NEWline GAMES.Software

           PATH 'A:\PLAYER'
           >PART 'Schalter'
_FLOAD     SET 0

           IF _FLOAD=0
           OPT X+,O+
           DEFAULT 1

           ELSE

           OPT F+,O+
           DEFAULT 4
           OUTPUT 'PLAYER26.PRG'
           ENDC

           ENDPART
           TEXT

           >PART 'MSHRINK & Auflîsung testen'
            movea.l 4(SP),A5
            movea.l 12(A5),A0
            adda.l  20(A5),A0
            adda.l  28(A5),A0
            lea     256(A0),A0

            lea     BASEPAGE(PC),A1
            move.l  A5,(A1)

            move.l  A0,-(SP)
            pea     (A5)
            clr.w   -(SP)
            move.w  #$004A,-(SP)
            trap    #1
            lea     12(SP),SP



            lea     EXIT(PC),A0
            tst.l   D0
            bmi     PR_ERR

            move.w  #4,-(SP)
            trap    #14
            addq.w  #2,SP

            cmp.w   #2,D0
            bne.s   IS_COLOR_MODE

            lea     STRING(PC),A0
            bsr     FORM_ALERT
EXIT:
            clr.w   -(SP)
            trap    #1
           ENDPART

           >PART
IS_COLOR_MODE:

           IF _FLOAD=0
            lea     NINJA_NAME(PC),A0
            lea     ST_COLOR-2(PC),A6
            moveq   #34,D7
            bsr     FLOAD

            lea     NINJA_NAME(PC),A0
            lea     NINJA_PIC-34(PC),A6
            move.l  #160*100,D7
            bsr     FLOAD

            lea     SCRL2_NAME(PC),A0
            lea     SCRL2_FLOAD(PC),A6
            move.l  #3*1024,D7
            bsr     FLOAD
           ENDC

           ENDPART
           >PART 'kopiere Command Zeile'
            movea.l BASEPAGE(PC),A0
            lea     128(A0),A0

            moveq   #0,D0
            move.b  (A0)+,D0
            beq.s   CMD_EX

            lea     0(A0,D0.w),A1

            move.b  -(A1),D1
            lsl.w   #8,D1
            move.b  -(A1),D1
            lsl.l   #8,D1
            move.b  -(A1),D1
            lsl.l   #8,D1
            move.b  -(A1),D1
            cmp.l   #'DOM.',D1
            bne.s   CMD_EX

            lea     FPATHNAME(PC),A1
CMD_LP1:
            move.b  (A0)+,(A1)+
            dbra    D0,CMD_LP1

CMD_LP2:
            move.b  -(A0),D0
            cmp.b   #"\",D0
            beq.s   CMD_LP2_EX
            cmp.b   #":",D0
            bne.s   CMD_LP2
CMD_LP2_EX:

            addq.l  #1,A0
            movea.l A0,A2
            lea     FNAME(PC),A1
CMD_LP3:
            move.b  (A0)+,D0
            beq.s   CMD_LP3_EX
            move.b  D0,(A1)+
            bra.s   CMD_LP3
CMD_LP3_EX:
            clr.b   (A1)

            movea.l BASEPAGE(PC),A1
            lea     128+1(A1),A1
            lea     FPATH(PC),A0
CMD_LP4:
            move.b  (A1)+,(A0)+
            cmpa.l  A1,A2
            bcc.s   CMD_LP4
            bra     CMD_JP_IN
CMD_EX:
           ENDPART
           >PART 'setze aktuellen Pfad'
            clr.w   -(SP)
            pea     FPATH+2(PC)
            move.w  #$0047,-(SP)
            trap    #1
            addq.l  #8,SP
            lea     EXIT(PC),A0
            tst.l   D0
            bmi     PR_ERR

            move.w  #$0019,-(SP)
            trap    #1
            addq.l  #2,SP

            add.w   #"A",D0
            lea     FPATH(PC),A0
            move.b  D0,(A0)+
            move.b  #":",(A0)+
SET_PATH_LP:
            tst.b   (A0)+
            bne.s   SET_PATH_LP
CMD_JP_IN:
            subq.l  #1,A0
            move.b  #"\",(A0)+
            move.b  #"*",(A0)+
            move.b  #".",(A0)+
            move.b  #"M",(A0)+
            move.b  #"O",(A0)+
            move.b  #"D",(A0)+
            clr.b   (A0)
           ENDPART
           >PART 'Alles was sich bei jedem Modul'
MAIN_LP:
            lea     SCROLL1,A0
            lea     MODUL_E,A1
            moveq   #0,D0
CLS_LP:
            move.l  D0,(A0)+
            cmpa.l  A0,A1
            bcc.s   CLS_LP

            bsr.s   DO_LOAD
            tst.l   D0
            bmi.s   MAIN_EX

            bsr     TST_DECRUNCH
            lea     FDAT_LEN(PC),A0
            move.l  D0,(A0)

            move.l  D0,-(SP)

            lea     ESC_L(PC),A0
            bsr     CCONWS


            move.l  (SP)+,D6
            moveq   #6-1,D4
            moveq   #10,D5
            lea     FILE_LEN(PC),A0
            bsr     BINASC

            pea     INIT(PC)
            move.w  #38,-(SP)
            trap    #14
            addq.w  #6,SP

            lea     RET_FLAG(PC),A0
            tst.w   (A0)
            beq.s   MAIN_LP

            bsr     DO_SAVE
            bra.s   MAIN_LP
MAIN_EX:
            clr.w   -(SP)
            trap    #1
           ENDPART

           >PART 'Lade File ?'
DO_LOAD:

            lea     FPATHNAME(PC),A0
            tst.b   (A0)
            bne.s   JP_IN_LOAD

            lea     FLOAD_TXT(PC),A0
            bsr     PR_1ST_LINE
DO_LOAD_LP:
            lea     FPATH(PC),A0
            lea     FNAME(PC),A1
            bsr     FILESELECT
            tst.w   D0
            beq.s   DO_LOAD_EX
            move.w  D1,D0
            beq.s   DO_LOAD_EX

            bsr     PR_LOADING
JP_IN_LOAD:
            bsr     SET_FNAME

            lea     FPATHNAME(PC),A0
            lea     MODUL,A6
            move.l  #256*1024-1,D7
            bsr     FLOAD
            tst.l   D0
            bmi.s   DO_LOAD_LP
            tst.l   D1
            bmi.s   DO_LOAD_LP
            tst.l   D2
            bmi.s   DO_LOAD_LP

            lea     FDAT_LEN(PC),A0
            move.l  D2,(A0)
            move.l  D2,D0

            lea     FPATHNAME(PC),A0
            clr.b   (A0)
            rts
DO_LOAD_EX:
            moveq   #-1,D0
            rts
           ENDPART

           >PART 'Hier sollten die Decrunch'
TST_DECRUNCH:
            lea     MODUL,A0
            move.l  (A0),D1

            lea     ICE__TXT(PC),A1
            cmp.l   (A1)+,D1
            bne.s   NOT_ICE

            bsr     PR_DEPACK
            bsr.s   ICE_DECRUNCH
            bra.s   DELTAFORCE
NOT_ICE:
            lea     ATOM_TXT(PC),A1
            cmp.l   (A1)+,D1
            bne.s   NOT_ATOM

            bsr     PR_DEPACK
            bsr     ATOMDECRUNCH
            bra.s   DELTAFORCE
NOT_ATOM:
            lea     FIRE_TXT(PC),A1
            cmp.l   (A1)+,D1
            bne.s   DELTAFORCE

            bsr     PR_DEPACK
            bsr     FIREDECRUNCH

DELTAFORCE:
            lea     DELTA_TXT(PC),A1
            lea     MODUL,A0
            cmpm.l  (A1)+,(A0)+
            bne.s   DEPACK_EXIT

            cmpm.l  (A1)+,(A0)+
            bne.s   DEPACK_EXIT

            bsr     PR_DEPACK

            lea     MODUL,A1
            lea     8(A1),A0
DELTA_LP:
            move.b  (A0)+,(A1)+
            subq.l  #1,D0
            bne.s   DELTA_LP

           REPT 9
            clr.b   (A0)+
           ENDR

            bsr     DELTADECRUNCH
DEPACK_EXIT:
            rts
           ENDPART

;The following depack-routines are not under our copyright.
;start
           >PART 'ICE!       2.40'      ;ΩAxe of Superior
ICE_DECRUNCH:
            link    A3,#-120

            movem.l D0-A6,-(SP)
            lea     120(A0),A4
            movea.l A4,A6
            addq.w  #4,A0
            bsr.s   ICEGETINFO
            lea     -8(A0,D0.l),A5
            bsr.s   ICEGETINFO
            move.l  D0,(SP)
            adda.l  D0,A6
            movea.l A6,A1

            moveq   #119,D0
ICESAVE:
            move.b  -(A1),-(A3)
            dbra    D0,ICESAVE

            movea.l A6,A3
            move.b  -(A5),D7
            bsr.s   ICENORMAL_BYTES
            movea.l A3,A5

            movem.l (SP),D0-A3

ICEMOVE:    move.b  (A4)+,(A0)+
            subq.l  #1,D0
            bne.s   ICEMOVE
            moveq   #119,D0
ICEREST:    move.b  -(A3),-(A5)
            dbra    D0,ICEREST

            movem.l (SP)+,D0-A6
            unlk    A3
            rts
ICEGETINFO:
            moveq   #3,D1
ICEGETBYTES:
            lsl.l   #8,D0
            move.b  (A0)+,D0
            dbra    D1,ICEGETBYTES
            rts
ICENORMAL_BYTES:
            bsr.s   ICEGET_1_BIT
            bcc.s   ICETEST_IF_END
            moveq   #0,D1
            bsr.s   ICEGET_1_BIT
            bcc.s   ICECOPY_DIREKT
            lea     ICEDIREKT_TAB+20(PC),A1
            moveq   #4,D3
ICENEXTGB:
            move.l  -(A1),D0
            bsr.s   ICEGET_D0_BITS
            swap    D0
            cmp.w   D0,D1
            dbne    D3,ICENEXTGB
            add.l   20(A1),D1
ICECOPY_DIREKT:
            move.b  -(A5),-(A6)
            dbra    D1,ICECOPY_DIREKT
ICETEST_IF_END:cmpa.l A4,A6
            bgt.s   ICESTRINGS
            rts
ICEGET_1_BIT:
            add.b   D7,D7
            bne.s   ICEBITFOUND
            move.b  -(A5),D7
            addx.b  D7,D7
ICEBITFOUND:
            rts
ICEGET_D0_BITS:
            moveq   #0,D1
ICEHOLE_BIT_LOOP:
            add.b   D7,D7
            bne.s   ICEON_D0
            move.b  -(A5),D7
            addx.b  D7,D7
ICEON_D0:   addx.w  D1,D1
            dbra    D0,ICEHOLE_BIT_LOOP
            rts

ICESTRINGS: lea     ICELENGTH_TAB(PC),A1
            moveq   #3,D2
ICEGET_LENGTH_BIT:bsr.s ICEGET_1_BIT
            dbcc    D2,ICEGET_LENGTH_BIT

            moveq   #0,D4
            moveq   #0,D1
            move.b  1(A1,D2.w),D0
            ext.w   D0
            bmi.s   ICENO_öBER

            bsr.s   ICEGET_D0_BITS
ICENO_öBER: move.b  6(A1,D2.w),D4
            add.w   D1,D4
            beq.s   ICEGET_OFFSET_2

            lea     ICEMORE_OFFSET(PC),A1
            moveq   #1,D2
ICEGETOFFS: bsr.s   ICEGET_1_BIT
            dbcc    D2,ICEGETOFFS
            moveq   #0,D1
            move.b  1(A1,D2.w),D0
            ext.w   D0
            bsr.s   ICEGET_D0_BITS
            add.w   D2,D2
            add.w   6(A1,D2.w),D1
            bpl.s   ICEDEPACK_BYTES
            sub.w   D4,D1
            bra.s   ICEDEPACK_BYTES

ICEGET_OFFSET_2:moveq #0,D1
            moveq   #5,D0
            moveq   #-1,D2
            bsr.s   ICEGET_1_BIT
            bcc.s   ICELESS_40
            moveq   #8,D0
            moveq   #$3F,D2
ICELESS_40: bsr.s   ICEGET_D0_BITS
            add.w   D2,D1

ICEDEPACK_BYTES:
            lea     2(A6,D4.w),A1
            adda.w  D1,A1
            move.b  -(A1),-(A6)
ICEDEP_B:   move.b  -(A1),-(A6)
            dbra    D4,ICEDEP_B
            bra     ICENORMAL_BYTES

ICEDIREKT_TAB:
           DC.L 2147418126,16711687,458754,196609,196609
           DC.L 270-1,15-1,8-1,5-1,2-1
ICELENGTH_TAB:
           DC.B 9,1,0,-1,-1
           DC.B 8,4,2,1,0
ICEMORE_OFFSET:
           DC.B 11,4,7,0
           DC.W 287,-1,31
           ENDPART
           >PART 'ATOMIK     3.3 '      ;ΩAltair of VMAX/MCS


DEC_MARGE  EQU $00000010
RESTORE_M  EQU 1
ATOMDECRUNCH:
            movem.l D1-A6,-(SP)

            addq.l  #4,A0
            move.l  (A0)+,D0
            move.l  D0,-(SP)
            lea     DEC_MARGE(A0,D0.l),A5
           IFNE RESTORE_M
            movea.l A5,A4
            lea     BUFF_MARG(PC),A3
            moveq   #DEC_MARGE+9,D0
.SAVE_M:    move.b  -(A4),(A3)+
            dbra    D0,.SAVE_M
            movem.l A3-A4,-(SP)
           ENDC
            move.l  (A0)+,D0
            lea     0(A0,D0.l),A6
            move.b  -(A6),D7
            bra     MAKE_JNK
TABLUS:     lea     TABLUS_TABLE(PC),A4
            moveq   #1,D6
            bsr.s   GET_BIT2
            bra.s   TABLUS2
DECRUNCH:   moveq   #6,D6
TAKE_LENGHT:add.b   D7,D7
            beq.s   .EMPTY1
.CONT_COPY: dbcc    D6,TAKE_LENGHT
            bcs.s   .NEXT_COD
            moveq   #6,D5
            sub.w   D6,D5
            bra.s   .DO_COPY
.NEXT_COD:  moveq   #3,D6
            bsr.s   GET_BIT2
            beq.s   .NEXT_COD1
            addq.w  #6,D5
            bra.s   .DO_COPY
.NEXT_COD1: moveq   #7,D6
            bsr.s   GET_BIT2
            beq.s   .NEXT_COD2
            add.w   #15+6,D5
            bra.s   .DO_COPY
.EMPTY1:    move.b  -(A6),D7
            addx.b  D7,D7
            bra.s   .CONT_COPY
.NEXT_COD2: moveq   #13,D6
            bsr.s   GET_BIT2
            add.w   #255+15+6,D5
.DO_COPY:   move.w  D5,-(SP)
            bne.s   BIGGER
            lea     DECRUN_TABLE2(PC),A4
            moveq   #2,D6
            bsr.s   GET_BIT2
            cmp.w   #5,D5
            blt.s   CONTUS
            addq.w  #2,SP
            subq.w  #6,D5
            bgt.s   TABLUS
            movea.l A5,A4
            blt.s   .FIRST4
            addq.w  #4,A4
.FIRST4:    moveq   #1,D6
            bsr.s   GET_BIT2
TABLUS2:    move.b  0(A4,D5.w),-(A5)
            bra.s   MAKE_JNK
GET_BIT2:   clr.w   D5
.GET_BITS:  add.b   D7,D7
            beq.s   .EMPTY
.CONT:      addx.w  D5,D5
            dbra    D6,.GET_BITS
            tst.w   D5
            rts
.EMPTY:     move.b  -(A6),D7
            addx.b  D7,D7
            bra.s   .CONT
BIGGER:     lea     DECRUN_TABLE(PC),A4
            moveq   #2,D6
            bsr.s   GET_BIT2
CONTUS:     move.w  D5,D4
            move.b  14(A4,D4.w),D6
            ext.w   D6

            bsr.s   GET_BIT2
            add.w   D4,D4
            beq.s   .FIRST
            add.w   -2(A4,D4.w),D5
.FIRST:     lea     1(A5,D5.w),A4

            move.w  (SP)+,D5
            move.b  -(A4),-(A5)
.COPY_SAME: move.b  -(A4),-(A5)
            dbra    D5,.COPY_SAME
MAKE_JNK:   moveq   #11,D6
            moveq   #11,D5
TAKE_JNK:   add.b   D7,D7
            beq.s   EMPTY
CONT_JNK:   dbcc    D6,TAKE_JNK
            bcs.s   NEXT_COD
            sub.w   D6,D5
            bra.s   COPY_JNK1
NEXT_COD:   moveq   #7,D6
            bsr.s   GET_BIT2
            beq.s   CM_NEXT_COD1
            addq.w  #8,D5
            addq.w  #3,D5
            bra.s   COPY_JNK1
CM_NEXT_COD1:moveq  #2,D6
            bsr.s   GET_BIT2
            swap    D5
            moveq   #15,D6
            bsr.s   GET_BIT2
            addq.l  #8,D5
            addq.l  #3,D5
COPY_JNK1:  subq.w  #1,D5
            bmi.s   .END_WORD
            moveq   #1,D6
            swap    D6
.COPY_JNK:  move.b  -(A6),-(A5)
            dbra    D5,.COPY_JNK
            sub.l   D6,D5
            bpl.s   .COPY_JNK
.END_WORD:  cmpa.l  A6,A0
.DECRUNCH:  bne     DECRUNCH
            cmp.b   #$80,D7
            bne.s   .DECRUNCH
           IFNE RESTORE_M
            movem.l (SP)+,A3-A4
           ENDC
            move.l  (SP),D0
            bsr.s   COPY_DECRUN
           IFNE RESTORE_M
            moveq   #DEC_MARGE+9,D0
.RESTORE_M: move.b  -(A3),(A4)+
            dbra    D0,.RESTORE_M
           ENDC

            move.l  (SP)+,D0
            movem.l (SP)+,D1-A6
            rts
EMPTY:      move.b  -(A6),D7
            addx.b  D7,D7
            bra.s   CONT_JNK
DECRUN_TABLE:DC.W $0020,$0060,$0160,$0360,$0760,$0F60,$1F60
           DC.W $0405,$0708,$090A,$0B0C
DECRUN_TABLE2:DC.W $0020,$0060,$00E0,$01E0,$03E0,$05E0,$07E0
           DC.W $0405,$0607,$0808
TABLUS_TABLE:DC.W $6020,$1008
COPY_DECRUN:lsr.l   #4,D0
            lea     -12(A6),A6
.COPY_DECRUN:REPT 4
            move.l  (A5)+,(A6)+
           ENDR
            dbra    D0,.COPY_DECRUN
            rts
           IFNE RESTORE_M
BUFF_MARG: DCB.B DEC_MARGE+10
           ENDC
           ENDPART
           >PART 'FIRE       2.01'      ;ΩAxe of Superior
FIREDECRUNCH:
            link    A3,#-120
            movem.l D0-A6,-(SP)
            lea     120(A0),A4
            movea.l A4,A6
            bsr.s   .GETINFO
            cmpi.l  #'FIRE',D0
            bne.s   .NOT_PACKED

            bsr.s   .GETINFO
            lea     -8(A0,D0.l),A5
            bsr.s   .GETINFO
            move.l  D0,(SP)
            adda.l  D0,A6
            movea.l A6,A1
            moveq   #119,D0
.SAVE:      move.b  -(A1),-(A3)
            dbra    D0,.SAVE
            movea.l A6,A3

            move.b  -(A5),D7
            lea     .TABELLEN(PC),A2
            moveq   #1,D6
            swap    D6
            moveq   #0,D5
.NORMAL_BYTES:
            bsr.s   .GET_1_BIT
            bcc.s   .TEST_IF_END
            moveq   #0,D1
            bsr.s   .GET_1_BIT
            bcc.s   .COPY_DIREKT

            movea.l A2,A0
            moveq   #3,D3
.NEXTGB:    move.l  -(A0),D0
            bsr.s   .GET_D0_BITS
            swap    D0
            cmp.w   D0,D1
            dbne    D3,.NEXTGB

            add.l   16(A0),D1
.COPY_DIREKT:
            move.b  -(A5),-(A6)
            dbra    D1,.COPY_DIREKT
.TEST_IF_END:
            cmpa.l  A4,A6
            bgt.s   .STRINGS

            movem.l (SP),D0-A2/A5
.MOVE:      move.b  (A4)+,(A0)+
            subq.l  #1,D0
            bne.s   .MOVE
            moveq   #119,D0
.REST:      move.b  -(A5),-(A3)
            dbra    D0,.REST
.NOT_PACKED:
            movem.l (SP)+,D0-A6
            unlk    A3
            rts

.GETINFO:
            moveq   #3,D1
.GLW:       rol.l   #8,D0
            move.b  (A0)+,D0
            dbra    D1,.GLW
            rts
.GET_1_BIT:
            add.b   D7,D7
            beq.s   .NO_BIT_FOUND
            rts
.NO_BIT_FOUND:
            move.b  -(A5),D7
            addx.b  D7,D7
            rts
.GET_D0_BITS:
            moveq   #0,D1
.HOLE_BIT_LOOP:
            add.b   D7,D7
            beq.s   .NOT_FOUND
.ON_D0:     addx.w  D1,D1
            dbra    D0,.HOLE_BIT_LOOP
            rts
.NOT_FOUND:
            move.b  -(A5),D7
            addx.b  D7,D7
            bra.s   .ON_D0

.STRINGS:
            moveq   #1,D0
            bsr.s   .GET_D0_BITS
            subq.w  #1,D1
            bmi.s   .GLEICH_MORESTRING
            beq.s   .LENGTH_2
            subq.w  #1,D1
            beq.s   .LENGTH_3
            bsr.s   .GET_1_BIT
            bcc.s   .BITSET
            bsr.s   .GET_1_BIT
            bcc.s   .LENGTH_4
            bra.s   .LENGTH_5
.GET_SHORT_OFFSET:
            moveq   #1,D0
            bsr.s   .GET_D0_BITS
            subq.w  #1,D1
            bpl.s   .CONTOFFS
            moveq   #0,D0
            rts
.GET_LONG_OFFSET:
            moveq   #1,D0
            bsr.s   .GET_D0_BITS
.CONTOFFS:  add.w   D1,D1
            add.w   D1,D1
            movem.w .OFFSET_TABLE-.TABELLEN(A2,D1.w),D0/D5
            bsr.s   .GET_D0_BITS
            add.l   D5,D1
            rts
.GLEICH_MORESTRING:
            moveq   #1,D0
            bsr.s   .GET_D0_BITS
            subq.w  #1,D1
            bmi.s   .GLEICH_STRING

            add.w   D1,D1
            add.w   D1,D1
            movem.w .MORE_TABLE-.TABELLEN(A2,D1.w),D0/D2
            bsr.s   .GET_D0_BITS
            add.w   D1,D2
            bsr.s   .GET_LONG_OFFSET
            move.w  D2,D0
            bra.s   .COPY_LONGSTRING

.BITSET:    moveq   #2,D0
            bsr.s   .GET_D0_BITS
            moveq   #0,D0
            bset    D1,D0
            bra.s   .PUT_D0

.LENGTH_2:
            moveq   #7,D0
            bsr.s   .GET_D0_BITS
            moveq   #2-2,D0
            bra.s   .COPY_STRING

.LENGTH_3:
            bsr.s   .GET_SHORT_OFFSET
            tst.w   D0
            beq.s   .PUT_D0
            moveq   #3-2,D0
            bra.s   .COPY_STRING

.LENGTH_4:
            bsr.s   .GET_SHORT_OFFSET
            tst.w   D0
            beq.s   .VORGéNGER_KOPIEREN
            moveq   #4-2,D0
            bra.s   .COPY_STRING

.LENGTH_5:
            bsr.s   .GET_SHORT_OFFSET
            tst.w   D0
            beq.s   .PUT_FF
            moveq   #5-2,D0
            bra.s   .COPY_STRING


.PUT_FF:    moveq   #-1,D0
            bra.s   .PUT_D0

.VORGéNGER_KOPIEREN:
            move.b  (A6),D0


.PUT_D0:    move.b  D0,-(A6)
            bra.s   .BACKMAIN
.GLEICH_STRING:
            bsr.s   .GET_LONG_OFFSET
            beq.s   .BACKMAIN
            move.b  (A6),D0
.COPY_GL:   move.b  D0,-(A6)
            dbra    D1,.COPY_GL
            sub.l   D6,D1
            bmi.s   .BACKMAIN
            bra.s   .COPY_GL
.COPY_LONGSTRING:
            subq.w  #2,D0
.COPY_STRING:
            lea     2(A6,D1.l),A0
            adda.w  D0,A0
            move.b  -(A0),-(A6)
.DEP_B:     move.b  -(A0),-(A6)
            dbra    D0,.DEP_B
.BACKMAIN:  bra     .NORMAL_BYTES

           DC.L $03FF0009,$00070002,$00030001,$00030001
.TABELLEN: DC.L 15-1,8-1,5-1,2-1

.OFFSET_TABLE:
           DC.W 3,0
           DC.W 7,16+0
           DC.W 11,256+16+0
           DC.W 15,4096+256+16+0
.MORE_TABLE:
           DC.W 3,5
           DC.W 5,16+5
           DC.W 7,64+16+5

           ENDPART
           >PART 'DeltaForce 0.1 '      ;Ωby Delta Force
DELTADECRUNCH:
            bsr.s   INIT_DEPACK

            lea     MODUL,A0
            bsr.s   ANALYSE_MODULE

            move.l  A0,D2
            movea.l SAMPLE_START(PC),A0
            move.l  A0,D1
            sub.l   D2,D1
            move.l  SAMPLE_END(PC),D0
            sub.l   A0,D0
            add.l   D0,D1
            move.l  D1,-(SP)

            bsr.s   DEPACK_SAMPLE

            move.l  (SP)+,D0
            rts

INIT_DEPACK:
            lea     DEPACK_LO(PC),A1
            moveq   #15,D7
INIT1:      lea     POWER_BYTES(PC),A0
            moveq   #15,D6
INIT2:      move.b  (A0)+,(A1)+
            dbra    D6,INIT2
            dbra    D7,INIT1

            lea     POWER_BYTES(PC),A0
            lea     DEPACK_HI(PC),A1
            moveq   #15,D7
INIT3:      moveq   #15,D6
            move.b  (A0)+,D0
INIT4:      move.b  D0,(A1)+
            dbra    D6,INIT4
            dbra    D7,INIT3

            rts
DEPACK_SAMPLE:


            lea     DEPACK_HI(PC),A2
            lea     DEPACK_LO(PC),A3

            addq.l  #1,D0
            and.b   #-2,D0
            move.l  D0,D7
            lsr.l   #1,D7

            lea     0(A0,D0.l),A1
            adda.l  D7,A0

            move.w  #128,D0
            moveq   #0,D1
DEPACK_LOOP:
            move.b  -(A0),D1
            add.b   0(A2,D1.w),D0
            move.b  D0,-(A1)
            add.b   0(A3,D1.w),D0
            move.b  D0,-(A1)

            subq.l  #1,D7
            bne.s   DEPACK_LOOP

            rts

ANALYSE_MODULE:


            cmpi.l  #"M.K.",$0438(A0)
            bne.s   MT_JP0

            lea     $03B8(A0),A1
            move.l  #$0000043C,D6
            moveq   #31-1,D7
            bra.s   MT_JP1
MT_JP0:
            lea     $01D8(A0),A1
            move.l  #$00000258,D6
            moveq   #15-1,D7
MT_JP1:
            moveq   #127,D0
            moveq   #0,D4
MT_LOOP:
            move.l  D4,D2
            subq.w  #1,D0
MT_LOP2:
            move.b  (A1)+,D4
            cmp.b   D2,D4
            bgt.s   MT_LOOP

            dbra    D0,MT_LOP2
            addq.b  #1,D2

            asl.l   #8,D2
            asl.l   #2,D2

            add.l   D6,D2
            move.l  D2,D1
            add.l   A0,D2
            movea.l D2,A2

            lea     SAMPLE_START(PC),A3
            move.l  A2,(A3)


            lea     20(A0),A1
MT_LOP3:
            moveq   #0,D4
            move.w  22(A1),D4
            adda.l  D4,A2
            adda.l  D4,A2
            lea     30(A1),A1
            dbra    D7,MT_LOP3

            move.l  A2,SAMPLE_END-SAMPLE_START(A3)

            rts
POWER_BYTES:DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64
SAMPLE_START:DS.L 1
SAMPLE_END:DS.L 1
DEPACK_LO: DS.B 256
DEPACK_HI: DS.B 256

           ENDPART
;end

           >PART 'Sichere File ?'
RET_FLAG:  DC.W 0
DO_SAVE:

            lea     RET_FLAG(PC),A0
            clr.w   (A0)

            lea     FLSAV_TXT(PC),A0
            bsr     PR_1ST_LINE

            lea     ESC_Y_0_A(PC),A0
            bsr     CCONWS
            lea     FNAME(PC),A0
            bsr     CCONWS

            bsr     JP_IN_LOAD
            tst.l   D0
            bmi.s   DO_SAVE_EX

            bsr     TST_DECRUNCH
            lea     FDAT_LEN(PC),A0
            move.l  D0,(A0)

DO_SAVE_LP:
            lea     FSAVE_TXT(PC),A0
            bsr     PR_1ST_LINE

            lea     FPATH(PC),A0
            lea     FNAME(PC),A1
            bsr.s   FILESELECT
            tst.w   D0
            beq.s   DO_SAVE_EX
            tst.w   D1
            beq.s   DO_SAVE_EX

            bsr     SET_FNAME

            bsr     PR_SAVING
            lea     FPATHNAME(PC),A0
            lea     MODUL,A6
            move.l  FDAT_LEN(PC),D7
            bsr     FSAVE
            tst.l   D0
            bmi.s   DO_SAVE_LP
            tst.l   D1
            bmi.s   DO_SAVE_LP
            tst.l   D2
            bmi.s   DO_SAVE_LP

            lea     FPATHNAME(PC),A0
            clr.b   (A0)
            moveq   #0,D0
            rts
DO_SAVE_EX:
            moveq   #-1,D0
            rts
           ENDPART

           >PART 'FILESELECT'
FILESELECT:
            movem.l D3-D7/A3-A6,-(SP)

            lea     AESPB(PC),A3
            move.l  A3,D1

            lea     CONTRL(PC),A2
            move.l  A2,(A3)+
            move.w  #$005A,(A2)+
            moveq   #2,D0
            move.l  D0,(A2)+
            move.w  D0,(A2)+
            clr.w   (A2)

            lea     GLOBAL(PC),A2
            move.l  A2,(A3)+
            lea     INT_IN(PC),A2
            move.l  A2,(A3)+
            lea     INT_OUT(PC),A2
            move.l  A2,(A3)+
            lea     ADDR_IN(PC),A2
            move.l  A2,(A3)+
            move.l  A0,(A2)+
            move.l  A1,(A2)

            lea     ADDR_OUT(PC),A2
            move.l  A2,(A3)

            movea.l D1,A0
            move.l  #200,D0
            trap    #2

            movem.w INT_OUT(PC),D0-D1
            movem.l (SP)+,D3-D7/A3-A6
            rts
           ENDPART
           >PART 'FORM_ALERT'
FORM_ALERT:
            movem.l D3-D7/A3-A6,-(SP)

            lea     AESPB(PC),A3
            move.l  A3,D1

            lea     CONTRL(PC),A2
            move.l  A2,(A3)+

            move.w  #$0034,(A2)+
            moveq   #1,D0
            move.w  D0,(A2)+
            move.w  D0,(A2)+
            move.w  D0,(A2)+
            clr.w   (A2)+

            lea     GLOBAL(PC),A2
            move.l  A2,(A3)+

            lea     INT_IN(PC),A2
            move.l  A2,(A3)+
            move.w  D0,(A2)

            lea     INT_OUT(PC),A2
            move.l  A2,(A3)+

            lea     ADDR_IN(PC),A2
            move.l  A2,(A3)+
            move.l  A0,(A2)+
            clr.l   (A2)

            lea     ADDR_OUT(PC),A2
            move.l  A2,(A3)+

            move.l  #200,D0
            trap    #2

            move.w  INT_OUT(PC),D0

            movem.l (SP)+,D3-D7/A3-A6
            rts
           ENDPART

           >PART 'setze den kompletten Pfadnamen'
SET_FNAME:
            lea     FPATH(PC),A0
            lea     FPATHNAME(PC),A1

            moveq   #127,D7
ST_FN_LP1:
            move.b  (A0)+,D0
            move.b  D0,(A1)+
            dbeq    D7,ST_FN_LP1

            lea     -1(A1),A2
            moveq   #'\',D0
            moveq   #127,D7
ST_FN_LP2:
            move.b  -(A1),D2
            cmp.b   D0,D2
            beq.s   ST_FN_LP2EX

            dbra    D7,ST_FN_LP2

            movea.l A2,A1
ST_FN_LP2EX:
            move.b  D0,(A1)+

            lea     FNAME(PC),A0
            moveq   #8+1+3-1,D7
ST_FN_LP3:
            move.b  (A0)+,D0
            move.b  D0,(A1)+
            dbeq    D7,ST_FN_LP3

            clr.b   (A1)+
            rts
           ENDPART
           >PART 'FLOAD'
FLOAD:
            movem.l D3-A6,-(SP)

            clr.w   -(SP)
            move.l  A0,-(SP)
            move.w  #$003D,-(SP)
            trap    #1
            addq.l  #8,SP

            lea     FL_ERR(PC),A0
            move.l  D0,D6
            bmi     PR_ERR

            move.l  A6,-(SP)
            move.l  D7,-(SP)
            move.w  D6,-(SP)
            move.w  #$003F,-(SP)
            trap    #1
            lea     12(SP),SP

            lea     FL_ERR(PC),A0
            move.l  D0,D7
            bmi     PR_ERR

            move.w  D6,-(SP)
            move.w  #$003E,-(SP)
            trap    #1
            addq.l  #4,SP

            lea     FL_ERR(PC),A0
            tst.l   D0
            bmi     PR_ERR
FL_ERR:
            move.l  D6,D1
            move.l  D7,D2
            movem.l (SP)+,D3-A6
            rts
           ENDPART
           >PART 'FSAVE'
FSAVE:
            movem.l D3-A6,-(SP)

            clr.w   -(SP)
            move.l  A0,-(SP)
            move.w  #$003C,-(SP)
            trap    #1
            addq.l  #8,SP

            lea     FS_ERR(PC),A0
            move.l  D0,D6
            bmi     PR_ERR

            move.l  A6,-(SP)
            move.l  D7,-(SP)
            move.w  D6,-(SP)
            move.w  #$0040,-(SP)
            trap    #1
            lea     12(SP),SP

            lea     FS_ERR2(PC),A0
            move.l  D0,D5
            bmi     PR_ERR
FS_ERR2:

            move.w  D6,-(SP)
            move.w  #$003E,-(SP)
            trap    #1
            addq.l  #4,SP

            lea     FS_ERR(PC),A0
            tst.l   D0
            bmi.s   PR_ERR
FS_ERR:
            move.l  D6,D1
            move.l  D5,D2
            movem.l (SP)+,D3-A6
            rts
           ENDPART

           >PART 'Printe Text in die oberste'
PR_1ST_LINE:
            movem.l D0-A6,-(SP)
            move.l  A0,-(SP)
            lea     OLD_TEXT(PC),A1
            move.l  A0,(A1)

            lea     ESC_L(PC),A0
            bsr     CCONWS

            movea.l (SP)+,A0
            bsr     CCONWS

            movem.l (SP)+,D0-A6
            rts
OLD_TEXT:  DC.L 0
           ENDPART
           >PART 'Printe LOAD Text'
PR_LOADING:
            lea     LOAD_TXT(PC),A0
            bsr.s   PR_1ST_LINE
            lea     ESC_Y_0_A(PC),A0
            bsr.s   CCONWS
            lea     FNAME(PC),A0
            bsr.s   CCONWS
            rts
           ENDPART
           >PART 'Print Packer Text'
PR_DEPACK:
            movem.l D0-A6,-(SP)

            move.l  A1,-(SP)

            lea     DEPC_TXT(PC),A0
            bsr.s   PR_1ST_LINE
            lea     ESC_Y_0_A(PC),A0
            bsr.s   CCONWS
            lea     FNAME(PC),A0
            bsr.s   CCONWS

            movea.l (SP)+,A0
            bsr.s   CCONWS

            movem.l (SP)+,D0-A6
            rts
           ENDPART
           >PART 'Printe SAVE Text'
PR_SAVING:
            lea     SAVE_TXT(PC),A0
            bsr.s   PR_1ST_LINE
            lea     ESC_Y_0_A(PC),A0
            bsr.s   CCONWS
            lea     FNAME(PC),A0
            bsr.s   CCONWS
            rts
           ENDPART
           >PART 'Printe Error'
PR_ERR:
            movem.l D0-A6,-(SP)
            move.l  D0,-(SP)

            lea     ESC_L(PC),A0
            bsr.s   CCONWS

            lea     ERR_NR(PC),A0
            movea.l A0,A1
            move.l  (SP)+,D0
PR_ERR_LP1:
            move.l  (A1)+,D1
            tst.w   D1
            beq.s   PR_ERRLPEX
            cmp.w   D1,D0
            bne.s   PR_ERR_LP1
PR_ERRLPEX:
            swap    D1
            adda.w  D1,A0
            bsr.s   CCONWS

            lea     PR_KEY(PC),A0
            bsr.s   CCONWS
            bsr.s   CCONIN

            movea.l OLD_TEXT(PC),A0
            bsr     PR_1ST_LINE
            movem.l (SP)+,D0-A6
            jmp     (A0)
           ENDPART

           >PART 'CCONWS'
CCONWS:
            pea     (A0)
            move.w  #9,-(SP)
            trap    #1
            addq.l  #6,SP
            rts
           ENDPART
           >PART 'CCONIN'
CCONIN:
            move.w  #7,-(SP)
            trap    #1
            addq.l  #2,SP
            rts
           ENDPART

           >PART 'AES Parameter'
AESPB:     DS.L 6
CONTRL:    DS.W 5
GLOBAL:    DC.W 0
INT_IN:    DC.W 0
INT_OUT:   DS.W 2
ADDR_IN:   DS.L 2
ADDR_OUT:  DC.L 0
           ENDPART

           >PART 'File Daten'
FPATH:     DS.B 128

FNAME_TXT: DC.B 15,0,0+8+1+3
FNAME:     DS.B 14
FPATHNAME: DS.B 128+14
           EVEN

FDAT_LEN:  DS.L 1
FLEN_TXT:  DC.B 17,0,0+8
FILE_LEN:  DS.B 10
           IF _FLOAD=0
SCRL2_NAME:DC.B "BLABLA.TXT",0
           ENDC
           EVEN
           ENDPART
           >PART 'Form_Alert Daten'
STRING:
           DC.B "[1][Sorry,| It's no Monochrom Version.|"
           DC.B " |Please start it in Color Mode][ OK ]",0
           EVEN
           ENDPART

           >PART 'Print Texte'
ESC_L:     DC.B $1B,'Y',32+0,32+$0000,$1B,'l',0
ESC_Y_0_A: DC.B $1B,'Y',32+0,32+$000A,0
FLOAD_TXT: DC.B 7,'Select Filename for LOADING',0
LOAD_TXT:  DC.B 'Loading',0
DEPC_TXT:  DC.B 'Depacking',0
FLSAV_TXT: DC.B 'Loading                to save DEPACKED',0
FSAVE_TXT: DC.B 7,'Select Filename for SAVING',0
SAVE_TXT:  DC.B 'Saving',0
PR_KEY:    DC.B $1B,'Y',32+0,32+$001B,7,$1B,'p',' PRESS A KEY ',$1B,'q',0
           EVEN

ICE__TXT:  DC.B 'ICE!'
           DC.B $1B,'Y',32+0,32+$0018,'Ice-Packer 2.40',0
           EVEN
ATOM_TXT:  DC.B 'ATOM'
           DC.B $1B,'Y',32+0,32+$0018,'Atomix v3.3',0
           EVEN
FIRE_TXT:  DC.B 'FIRE'
           DC.B $1B,'Y',32+0,32+$0018,'Fire-Packer 2.01',0
           EVEN
DELTA_TXT: DC.B 'FORCE01'
           DC.B $1B,'Y',32+0,32+$0018,'DELTA FORCE v0.1',0
           EVEN

           ENDPART
           >PART 'ERROR Text'
           BASE DC.W,ERR_NR

ERR_NR:
           DC.W ERROR,-1
           DC.W EDRVNR,-2
           DC.W EUNCMD,-3
           DC.W E_CRC,-4
           DC.W EBADRQ,-5
           DC.W E_SEEK,-6
           DC.W EMEDIA,-7
           DC.W ESECNF,-8
           DC.W EPAPER,-9
           DC.W EWRITF,-10
           DC.W EREADF,-11
           DC.W EGENRL,-12
           DC.W EWRPRO,-13
           DC.W E_CHNG,-14
           DC.W EUNDEV,-15
           DC.W EBADSF,-16
           DC.W EOTHER,-17
           DC.W EINSERT,-18
           DC.W EDVNRSP,-19

           DC.W EINVFN,-32
           DC.W EFILNF,-33
           DC.W EPTHNF,-34
           DC.W ENHNDL,-35
           DC.W EACCDN,-36
           DC.W EIHNDL,-37
           DC.W ENSMEM,-39
           DC.W EIMBA,-40
           DC.W EDRIVE,-46
           DC.W ENSAME,-48
           DC.W ENMFIL,-49
           DC.W ELOCKD,-58
           DC.W ENSLOCK,-59
           DC.W ERANGE,-64
           DC.W EINTRN,-65
           DC.W EPLFMT,-66
           DC.W EGSBF,-67

           DC.W EUNKWN,0

ERROR:     DC.B 7,' -1 ERROR',0
EDRVNR:    DC.B 7,' -2 DRIVE NOT READY',0
EUNCMD:    DC.B 7,' -3 UNKNOWN COMMAND',0
E_CRC:     DC.B 7,' -4 CRC ERROR',0
EBADRQ:    DC.B 7,' -5 BAD REQUEST',0
E_SEEK:    DC.B 7,' -6 SEEK ERROR',0
EMEDIA:    DC.B 7,' -7 UNKNOWN MEDIA',0
ESECNF:    DC.B 7,' -8 SECTOR NOT FOUND',0
EPAPER:    DC.B 7,' -9 OUT OF PAPER',0
EWRITF:    DC.B 7,'-10 WRITE FAULT',0
EREADF:    DC.B 7,'-11 READ FAULT',0
EGENRL:    DC.B 7,'-12 GENERAL ERROR',0
EWRPRO:    DC.B 7,'-13 WRITE PROTECT',0
E_CHNG:    DC.B 7,'-14 MEDIA CHANGE',0
EUNDEV:    DC.B 7,'-15 UNKNOWN DEVICE',0
EBADSF:    DC.B 7,'-16 BAD SECTORS',0
EOTHER:    DC.B 7,'-17 INSERT OTHER DISK',0
EINSERT:   DC.B 7,'-18 INSERT DISK',0
EDVNRSP:   DC.B 7,'-19 DEVICE NOT RESPOND',0

EINVFN:    DC.B 7,'-32 INVAL. FUNCTION NUMBER',0
EFILNF:    DC.B 7,'-33 FILE NOT FOUND',0
EPTHNF:    DC.B 7,'-34 PATH NOT FOUND',0
ENHNDL:    DC.B 7,'-35 HANDLE POOL EXHAUST',0
EACCDN:    DC.B 7,'-36 ACCESS DENIED',0
EIHNDL:    DC.B 7,'-37 INVALID HANDLE',0
ENSMEM:    DC.B 7,'-39 INSUFFICIENT MEMORY',0
EIMBA:     DC.B 7,'-40 INVALID MEM. BLOCK ADR.',0
EDRIVE:    DC.B 7,'-46 INVAL. DRIVE SPECIFIC.',0
ENSAME:    DC.B 7,'-48 NOT THE SAME DRIVE',0
ENMFIL:    DC.B 7,'-49 NO MORE FILES',0
ELOCKD:    DC.B 7,'-58 RECORD IS LOCKED',0
ENSLOCK:   DC.B 7,'-59 NO SUCH LOCK',0
ERANGE:    DC.B 7,'-64 RANGE ERROR',0
EINTRN:    DC.B 7,'-65 GEMDOS INTERNAL ERROR',0
EPLFMT:    DC.B 7,'-66 INVAL.EXEC.FILEFORMAT',0
EGSBF:     DC.B 7,'-67 MEM.BLOCK GROWTH FAIL.',0

EUNKWN:    DC.B 'UNKNOWN ERROR',0
           BASE DC.W,OFF
           ENDPART

           >PART 'der Rest der Data`s'
BASEPAGE:  DS.L 1
           ENDPART

           >PART 'Supervisor Main'
INIT:
            bsr.s   TST_MACHINE
            bsr.s   SET_SCREENS
            bsr     GET_MODULNAME

            bsr     STORE_MFP
            bsr     INIT_ALL
            bsr     INIT_TEXT

            bsr     INIT_MOD_PLAYER
            bsr     S_MAIN


            jsr     MOD_PLAYER+8

            bsr     RECALL_MFP
            bsr     RECALL_VIDEO

            lea     STE_FLAG(PC),A0
            tst.w   (A0)
            bpl.s   JUMP
            move.b  STE_MHZ(PC),$FFFF8E21.w
JUMP:
            rts
           ENDPART

           >PART 'Teste auf welche Maschine'
TST_MACHINE:
            lea     STE_FLAG(PC),A2
            clr.l   (A2)

            lea     BUS_ERR1(PC),A4
            movea.l SP,A1
            movea.l $00000008.w,A0
            move.l  A4,$00000008.w

            tst.w   $FFFF8922.w
            addq.w  #1,(A2)
BUS_ERR1:

            lea     BUS_ERR2(PC),A4
            move.l  A4,$00000008.w

            move.b  $FFFF8E21.w,D0
            subq.w  #2,(A2)
BUS_ERR2:

            movea.l A1,SP
            move.l  A0,$00000008.w
            rts
STE_FLAG:  DC.W 0
STE_MHZ:   DC.W 0
           ENDPART
           >PART 'bereite die Bildschirme vor'
SET_SCREENS:
            bsr     STORE_VIDEO

            move.l  #SCREENS+255,D0
            clr.b   D0

            lea     LOGRAM(PC),A0
            move.l  D0,(A0)
            add.l   #32000,D0
            move.l  D0,PHYSRAM-LOGRAM(A0)

            lsr.l   #8,D0
            lea     $FFFF8200.w,A0
            movep.w D0,1(A0)
            bsr     VSYNC

            clr.b   $FFFF8260.w
            bsr     VSYNC
            move.b  #2,$FFFF820A.w

            bsr.s   INTRO

            lea     NINJA_PIC(PC),A0
            movea.l PHYSRAM(PC),A1
            movea.l LOGRAM(PC),A2

            move.w  #16000/4-1,D0
CPY_NINJA:
            move.l  (A0),(A1)+
            move.l  (A0)+,(A2)+
            dbra    D0,CPY_NINJA

            moveq   #0,D1
            move.w  #16000/4-1,D0
CLR_SCREEN:
            move.l  D1,(A1)+
            move.l  D1,(A2)+
            dbra    D0,CLR_SCREEN

            rts
LOGRAM:    DC.L 0
PHYSRAM:   DC.L 0
           ENDPART
           >PART 'a Channel 38 Production'
INTRO_FLAG:DC.W 0
INTRO:
            lea     INTRO_FLAG(PC),A0
            tst.w   (A0)
            bne.s   INTRO_EX

            not.w   (A0)

            movea.l PHYSRAM(PC),A2
            movea.l LOGRAM(PC),A1
            lea     5*160(A1),A1
            lea     5*160(A2),A2
            lea     A_CH38_PRO(PC),A0

            move.w  #172*160/8-1,D0
INTRO_LP1:
            move.l  (A0),(A1)+
            move.l  (A0)+,(A2)+
            addq.w  #4,A1
            addq.w  #4,A2
            dbra    D0,INTRO_LP1

            lea     END_COLOR(PC),A0
            bsr     EINBLEND

            move.w  #25-1,D0
INTRO_LP4:
            bsr     VSYNC
            dbra    D0,INTRO_LP4

            bsr     AUSBLEND
INTRO_EX:
            rts
           ENDPART
           >PART 'Kodiere Modul-Namen'
GET_MODULNAME:

            lea     CHAR_16(PC),A2
           BASE A2,CHAR_16

            lea     MODUL,A1
            lea     SCROLL1,A0
            lea     2*20(A0),A0
            moveq   #20-1,D0
.GTXT_LP1:
            move.b  (A1)+,D1
            beq.s   .GTXT_LP1EX

            cmp.b   #'~',D1
            beq     .GTXT_JP6

            and.w   #$007F,D1
            cmp.b   #' ',D1
            bcc.s   .GTXT_JP1

            moveq   #' ',D1
.GTXT_JP1:
            cmp.b   #'`',D1
            bcs.s   .GTXT_JP2

            bclr    #5,D1
.GTXT_JP2:
            bsr.s   COPY_IT

            dbra    D0,.GTXT_LP1
.GTXT_LP1EX:
            move.w  #320,SCRL1CENTER(A2)

            tst.w   D0
            bmi.s   .GTXT_JP3

            move.w  D0,D1
            lsl.w   #3,D1
            sub.w   D1,SCRL1CENTER(A2)
.GTXT_LP2:
            moveq   #' ',D1
            bsr.s   COPY_IT
            dbra    D0,.GTXT_LP2
.GTXT_JP3:

            lea     SCROLL1,A0

            moveq   #16-1,D0
.GTXT_LP4:
            lea     2*(20-1)(A0),A0

            moveq   #16-2,D1
.GTXT_LP5:
            movem.l (A0),D2-D7/A1-A4
            movem.l D2-D7/A1-A4,82(A0)

            lea     42+82(A0),A0
            move    #0,CCR
           REPT 21
            roxl.w  -(A0)
           ENDR
            dbra    D1,.GTXT_LP5

            lea     82(A0),A0
            dbra    D0,.GTXT_LP4

            rts

COPY_IT:
            sub.w   #" ",D1
            lsl.w   #5,D1
            lea     0(A2,D1.w),A3

            move.w  (A3)+,(A0)+
            move.w  #1350,D6
            move.w  D6,D5
            moveq   #16-1,D7
.GTXT_LP3:
            move.w  (A3)+,-2(A0,D6.w)
            add.w   D5,D6
            dbra    D7,.GTXT_LP3
            rts

.GTXT_JP6:
            moveq   #'a',D1
            bsr.s   COPY_IT
            subq.w  #1,D0
            bmi     .GTXT_LP1EX
            moveq   #'b',D1
            bsr.s   COPY_IT
            subq.w  #1,D0
            bmi     .GTXT_LP1EX
            moveq   #'c',D1
            bsr.s   COPY_IT
            subq.w  #1,D0
            bra     .GTXT_LP1EX
           BASE A2,OFF
           ENDPART
           >PART 'initialisiere Daten'
INIT_ALL:

            lea     SCRL1BUF(PC),A0
           BASE A0,SCRL1BUF
            movea.l A0,A1
            move.w  SCRL1CENTER(PC),D0
            moveq   #SCRL1BUFF_LEN-1,D1
CLS_LP1:
            move.w  D0,(A1)+
            dbra    D1,CLS_LP1

            clr.w   SCRL1WAY(A0)
            clr.w   SCRL1CNT(A0)
            clr.w   SCRL1SOUND(A0)

            lea     SCRL1TAB(PC),A1
CLS_LP2:
            move.w  (A1)+,D0
            bmi.s   CLS_LP2EX

            clr.w   (A1)+
            addq.l  #2,A1
            bra.s   CLS_LP2
CLS_LP2EX:

            lea     SCRL1TAB(PC),A1
            adda.w  (A1),A1

            move.l  A1,SCRL1ADR(A0)
            move.w  (A1),SCRL1OFFSET(A0)

            tst.w   STE_FLAG(A0)
            bne.s   JP_IS_STE

            move.w  #4-1,SCRL1ANZ(A0)
            move.w  #113*160+2,SCRL1HIGH(A0)

            bra.s   JP_NEXT
JP_IS_STE:
            move.w  #5-1,SCRL1ANZ(A0)
            move.w  #104*160+2,SCRL1HIGH(A0)

            tst.w   STE_FLAG(A0)
            bpl.s   JP_NEXT

            move.b  D0,STE_MHZ(A0)
            ori.b   #%00000011,$FFFF8E21.w

JP_NEXT:
           BASE A0,OFF


            lea     SCRL2_POS(PC),A0
           BASE A0,SCRL2_POS
            lea     SCRL2_END(PC),A1
            move.l  A1,(A0)
            lea     SCRL2_TXT1(PC),A1
            move.l  A1,SCRL2_TXT(A0)
            clr.w   SCRL2_X(A0)
           BASE A0,OFF

            lea     ONEPROG_LIST(PC),A0
            lea     4(A0),A1
            move.l  A1,(A0)

            rts
           ENDPART
           >PART 'setze allgemeinen Text'
INIT_TEXT:
            lea     PLANE(PC),A0
            clr.w   (A0)
            lea     TEXT2(PC),A0
            bsr     PR_TEXT

            lea     STE_FLAG(PC),A0
            tst.w   (A0)
            beq.s   I_TEXT_JP1

            lea     TEXT3(PC),A0
            bsr     PR_TEXT
            bra.s   I_TEXT_JP2
I_TEXT_JP1:
            lea     TEXT4(PC),A0
            bsr     PR_TEXT
I_TEXT_JP2:
            lea     PLANE(PC),A0
            move.w  #6,(A0)

            lea     FNAME_TXT(PC),A0
            bsr     PR_TEXT

            lea     FLEN_TXT(PC),A0
            bsr     PR_TEXT

            rts
           ENDPART
           >PART 'Initialisiere Tracker'
INIT_MOD_PLAYER:
            move.w  #12000,D0
            moveq   #3,D1
            moveq   #0,D2


            lea     MODUL,A0
            jsr     MOD_PLAYER

            lea     DUMMY2(PC),A0
            move.l  A0,$00000070.w
            bclr    #3,$FFFFFA17.w



            lea     ST_COLOR(PC),A0
            bsr.s   EINBLEND

            lea     VBL(PC),A0
            move.l  A0,$00000070.w
            rts
           ENDPART

           >PART 'Farbe einblenden'
EINBLEND:
            moveq   #8-1,D0
EIN_LP2:
            moveq   #16-1,D1
            lea     $FFFF8240.w,A1
            movea.l A0,A2
EIN_LP3:
            move.w  (A1),D2
            move.w  (A2),D4
            beq.s   EIN_JP3

            move.w  D2,D3
            and.w   #$0007,D3
            and.w   #$0007,D4
            beq.s   EIN_JP1
            cmp.w   D3,D4
            beq.s   EIN_JP1

            addq.w  #$01,(A1)
EIN_JP1:
            move.w  D2,D3
            move.w  (A2),D4
            and.w   #$0070,D3
            and.w   #$0070,D4
            beq.s   EIN_JP2
            cmp.w   D3,D4
            beq.s   EIN_JP2

            addi.w  #$0010,(A1)
EIN_JP2:
            move.w  D2,D3
            move.w  (A2),D4
            and.w   #$0700,D3
            and.w   #$0700,D4
            beq.s   EIN_JP3
            cmp.w   D3,D4
            beq.s   EIN_JP3

            addi.w  #$0100,(A1)
EIN_JP3:
            addq.l  #2,A1
            addq.l  #2,A2
            dbra    D1,EIN_LP3

            bsr     VSYNC
            bsr     VSYNC
            bsr     VSYNC
            bsr     VSYNC

            dbra    D0,EIN_LP2
            rts
           ENDPART
           >PART 'Farbe ausblenden'
AUSBLEND:
            moveq   #8-1,D0
AUS_LP1:
            moveq   #16-1,D1
            lea     $FFFF8240.w,A0
AUS_LP2:
            move.w  (A0),D2
            move.w  D2,D3
            and.w   #$0777,D3
            beq.s   AUS_JP3

            and.w   #$0007,D3
            beq.s   AUS_JP1
            subq.w  #$01,(A0)
AUS_JP1:
            move.w  D2,D3
            and.w   #$0070,D3
            beq.s   AUS_JP2
            subi.w  #$0010,(A0)
AUS_JP2:
            move.w  D2,D3
            and.w   #$0700,D3
            beq.s   AUS_JP3
            subi.w  #$0100,(A0)
AUS_JP3:
            addq.l  #2,A0
            dbra    D1,AUS_LP2

            bsr     VSYNC
            bsr     VSYNC

            dbra    D0,AUS_LP1

            rts
           ENDPART
           >PART 'Wandelt BIN-Zahl --> ASCII'
BINASC:
            move.w  D4,D0
            moveq   #' ',D1
BINASC_LP1:
            move.b  D1,(A0)+
            dbra    D0,BINASC_LP1
BINASC_LP2:
            bsr.s   DIVISION
            add.b   #'0',D2
            move.b  D2,-(A0)

            tst.l   D6
            dbeq    D4,BINASC_LP2

            rts

DIVISION:
            moveq   #32-1,D0
            moveq   #0,D2
            moveq   #0,D1
NAECHSTESBIT:
            addx.l  D6,D6
            addx.l  D2,D2
            add.l   D1,D1
            sub.l   D5,D2
            bmi.s   UNTERLAUF

            addq.l  #1,D1
ENDEDIV:
            dbra    D0,NAECHSTESBIT

            move.l  D1,D6
            rts
UNTERLAUF:
            add.l   D5,D2
            bra.s   ENDEDIV
           ENDPART

           >PART 'store+recall MFP'
STORE_MFP:
            move    SR,-(SP)
            move    #$2700,SR

            lea     STORE_REGS(PC),A0
            move.b  $FFFFFA07.w,(A0)+
            move.b  $FFFFFA09.w,(A0)+
            move.b  $FFFFFA13.w,(A0)+
            move.b  $FFFFFA15.w,(A0)+
            move.b  $FFFFFA17.w,(A0)+
            move.b  $FFFFFA19.w,(A0)+
            move.b  $FFFFFA1B.w,(A0)+
            move.b  $FFFFFA1D.w,(A0)+

            lea     STORE_VECT(PC),A0
            move.l  $00000068.w,(A0)+
            move.l  $00000070.w,(A0)+
            move.l  $00000110.w,(A0)+
            move.l  $00000114.w,(A0)+
            move.l  $00000118.w,(A0)+
            move.l  $00000120.w,(A0)+
            move.l  $00000134.w,(A0)+

            clr.b   $FFFFFA07.w
            clr.b   $FFFFFA09.w
            lea     DUMMY1(PC),A0
            move.l  A0,$00000070.w
            lea     DUMMY0(PC),A0
            move.l  A0,$00000068.w

            move    (SP)+,SR
            bsr     VSYNC
            rts
DUMMY2:
            movem.l D0-D6/A0-A4,-(SP)
            jsr     MOD_PLAYER+4
            movem.l (SP)+,D0-D6/A0-A4
DUMMY1:     addq.l  #1,$00000466.w
DUMMY0:     rte
STORE_REGS:DS.B 8
STORE_VECT:DS.L 7
RECALL_MFP:
            move    SR,-(SP)
            move    #$2700,SR

            lea     STORE_REGS(PC),A0
            move.b  (A0)+,$FFFFFA07.w
            move.b  (A0)+,$FFFFFA09.w
            move.b  (A0)+,$FFFFFA13.w
            move.b  (A0)+,$FFFFFA15.w
            move.b  (A0)+,$FFFFFA17.w
            move.b  (A0)+,$FFFFFA19.w
            move.b  (A0)+,$FFFFFA1B.w
            move.b  (A0)+,$FFFFFA1D.w

            lea     STORE_VECT(PC),A0
            move.l  (A0)+,$00000068.w
            move.l  (A0)+,$00000070.w
            move.l  (A0)+,$00000110.w
            move.l  (A0)+,$00000114.w
            move.l  (A0)+,$00000118.w
            move.l  (A0)+,$00000120.w
            move.l  (A0)+,$00000134.w

            move    (SP)+,SR
            rts
           ENDPART
           >PART 'store+recall video'
STORE_VIDEO:
            lea     SAVE_AREA(PC),A0
            move.b  $FFFF820A.w,(A0)+
            move.b  $FFFF8260.w,(A0)+
            lea     $FFFF8200.w,A1
            movep.w 1(A1),D0
            move.w  D0,(A0)+

            movem.l $FFFF8240.w,D0-D7
            movem.l D0-D7,(A0)

            move.b  #$12,$FFFFFC02.w
            bsr.s   VSYNC

            bra     AUSBLEND

RECALL_VIDEO:
            bsr     AUSBLEND

            lea     SAVE_AREA(PC),A0
            bsr.s   VSYNC
            move.b  (A0)+,$FFFF820A.w
            bsr.s   VSYNC
            move.b  (A0)+,$FFFF8260.w
            bsr.s   VSYNC

            lea     $FFFF8200.w,A1
            move.w  (A0)+,D0
            movep.w D0,1(A1)
            bsr.s   VSYNC

            move.b  #8,$FFFFFC02.w

            lea     SAVE_AREA+4(PC),A0
            bra     EINBLEND


SAVE_AREA: DS.B 4
           DS.W 16
           ENDPART
           >PART 'Vsync'
VSYNC:
            move.l  D0,-(SP)

            move.l  $00000466.w,D0
VSYNC1:
            cmp.l   $00000466.w,D0
            beq.s   VSYNC1

            move.l  (SP)+,D0
            rts
           ENDPART

           >PART 'Hauptwarteschleife'
S_MAIN:
            bsr.s   VSYNC

            bsr.s   GET_KEY
            bsr.s   DCODE_KEY

            bsr     DO_SINGLE_UPROG
            bsr     DO_SINGLE_UPROG

            tst.w   MOD_PLAYER+26
            bne.s   S_MAIN

            rts
           ENDPART
           >PART 'Hole Key'
GET_KEY:
            moveq   #0,D0

            btst    #7,$FFFFFC00.w
            beq.s   DODEL

            move.b  $FFFFFC02.w,D0
DODEL:
            rts
           ENDPART
           >PART 'welche Key-Routine?'
DCODE_KEY:
            lea     UPRG_TAB(PC),A0
.UPRG_LP1:
            move.w  (A0)+,D1
            beq.s   .UPRG_EX

            cmp.b   D0,D1
            bne.s   .UPRG_LP1
            lsr.w   #8,D1
.UPRG_EX:
            move.w  UPRG_LST(PC,D1.w),D1
            jmp     UPRG_LST(PC,D1.w)

           ENDPART
           >PART 'U-Prog`s'
           OPT W-
UPRG_TAB:

           DC.B 2,128+$0039
           DC.B 4,128+$0068
           DC.B 6,128+$006E
           DC.B 8,128+$0067
           DC.B 10,128+$006D
           DC.B 12,128+$0069
           DC.B 14,128+$006F
           DC.B 16,128+$006A
           DC.B 18,128+$006C
           DC.B 20,128+$006B
           DC.B 22,128+$004B
           DC.B 24,128+$004D
           DC.B 26,128+$001F
           DC.B 28,128+$0017
           DC.B 30,128+$0014

           DC.B 0,0

           OPT W+
           BASE DC.W,UPRG_LST
UPRG_LST:
           DC.W NOTHING,SMAIN_EX
           DC.W ADD_M_VL,SUB_M_VL
           DC.W ADD_TRBL,SUB_TRBL
           DC.W ADD_BASS,SUB_BASS
           DC.W GO_LEFT,GO_RIGHT
           DC.W CENTER
           DC.W KEY_LEFT,KEY_RIGHT
           DC.W SAVE_MODUL
           DC.W INFO_TEXT,BLABLA_TEXT

           BASE DC.W,OFF

SMAIN_EX:
            move.w  #3,MOD_PLAYER+24
NOTHING:
            rts

ADD_M_VL:
            lea     STE_FLAG(PC),A0
            tst.w   (A0)
            bne.s   ADD_STE_VL

            lea     MOD_PLAYER+26,A0
            moveq   #64,D0
            bra.s   .TST_ADD
ADD_STE_VL:
            lea     ST_M_VL(PC),A0
            moveq   #40,D0

.TST_ADD:
            cmp.w   (A0),D0
            bls.s   ADD_EX

            addq.w  #1,(A0)
ADD_EX:
            rts

SUB_M_VL:
            lea     STE_FLAG(PC),A0
            tst.w   (A0)
            bne.s   SUB_STE_VL

            lea     MOD_PLAYER+26,A0
            bra.s   .TST_SUB
SUB_STE_VL:
            lea     ST_M_VL(PC),A0

.TST_SUB:
            tst.w   (A0)
            beq.s   SUB_EX

            subq.w  #1,(A0)
SUB_EX:
            rts

ADD_TRBL:
            lea     ST_TRBL(PC),A0
            moveq   #12,D0
            bra.s   .TST_ADD
SUB_TRBL:
            lea     ST_TRBL(PC),A0
            bra.s   .TST_SUB

ADD_BASS:
            lea     ST_BASS(PC),A0
            moveq   #12,D0
            bra.s   .TST_ADD
SUB_BASS:
            lea     ST_BASS(PC),A0
            bra.s   .TST_SUB

GO_LEFT:
            lea     ST_L_VL(PC),A0
            move.w  #20,(A0)

            lea     ST_R_VL(PC),A0
            bra.s   .TST_SUB
GO_RIGHT:
            lea     ST_R_VL(PC),A0
            move.w  #20,(A0)

            lea     ST_L_VL(PC),A0
            bra.s   .TST_SUB

CENTER:
            lea     ST_M_VL(PC),A0
           BASE A0,ST_M_VL
            move.w  #40,(A0)
            move.w  #64,MOD_PLAYER+26
            moveq   #20,D0
            move.w  D0,ST_L_VL(A0)
            move.w  D0,ST_R_VL(A0)
            moveq   #6,D0
            move.w  D0,ST_TRBL(A0)
            move.w  D0,ST_BASS(A0)

           BASE A0,OFF
            rts
KEY_LEFT:
            lea     SCRL1WAY(PC),A0
            tst.w   (A0)
            bmi.s   KL_JP0
            cmpi.w  #4,(A0)
            bcc.s   KL_JP1
KL_JP0:
            addq.w  #1,(A0)
KL_JP1:
            rts
KEY_RIGHT:
            lea     SCRL1WAY(PC),A0
            tst.w   (A0)
            bpl.s   KR_JP0
            cmpi.w  #-4,(A0)
            bcs.s   KR_JP1
KR_JP0:
            subi.w  #1,(A0)
KR_JP1:
            rts

SAVE_MODUL:
            move.w  #3,MOD_PLAYER+24
            lea     RET_FLAG(PC),A0
            not.w   (A0)
            rts

INFO_TEXT:
            lea     SCRL2_TXT1(PC),A1
JUMP_TEXT:
            lea     SCRL2_POS(PC),A0
            move.l  A1,(A0)+
            move.l  A1,(A0)

            rts

BLABLA_TEXT:
            lea     SCRL2_TXT2(PC),A1
            bra.s   JUMP_TEXT
           ENDPART

           >PART '1 Unterprogramm ausfÅhren'
DO_SINGLE_UPROG:
            lea     ONEPROG_LIST(PC),A0
            movea.l (A0),A1

            move.w  (A1)+,D0
            bpl.s   DO_SINGLE_JP1

            lea     4(A0),A1
            move.w  (A1)+,D0
DO_SINGLE_JP1:
            move.l  A1,(A0)

            jmp     ONEPROG_LIST(PC,D0.w)
ONEPROG_LIST:
           DC.L 0
           BASE DC.W,ONEPROG_LIST

           DC.W SET_MICROWIRE
           DC.W PR_PATR
           DC.W PR_CURSOR
           DC.W SET_MICROWIRE
           DC.W PR_PATR
           DC.W PR_SONG
           DC.W SET_MICROWIRE
           DC.W PR_PATR
           DC.W PR_SCRL2
           DC.W -1

           BASE DC.W,OFF
           ENDPART
           >PART 'Pr Song'
PR_SONG:
            lea     SONG_TXT(PC),A0
            move.w  MOD_PLAYER+20,D6
            bra.s   PR_DEZIMAL
           ENDPART
           >PART 'Pr Pattern'
PR_PATR:
            lea     PATR_TXT(PC),A0
            move.w  MOD_PLAYER+22,D6
            bra.s   PR_DEZIMAL
           ENDPART
           >PART 'Set STE-MicroWire'
SET_MICROWIRE:
            lea     STE_FLAG(PC),A0
            tst.w   (A0)
            bne.s   SET_MW

            lea     MOD__TXT(PC),A0
            move.w  MOD_PLAYER+26,D6
            bra.s   PR_DEZIMAL
SET_MW:

            tst.w   $FFFF8922.w
            bne.s   MW_EXIT

            move.w  #$07FF,$FFFF8924.w

            lea     MW_CNT(PC),A0
            move.w  (A0),D0
            addq.w  #8,D0
            cmp.w   #4*8,D0
            bls.s   MW_JP1

            moveq   #0,D0
MW_JP1:     move.w  D0,(A0)

            lea     2(A0,D0.w),A0
            move.w  (A0)+,D0
            add.w   (A0),D0

            move.w  D0,$FFFF8922.w

            move.w  (A0)+,D6
            movea.l (A0),A0
            bra.s   PR_DEZIMAL
MW_EXIT:
            rts

MW_CNT:    DC.W 0
           DC.W %0000010011000000
ST_M_VL:   DC.W 40
           DC.L M_VL_TXT
           DC.W %0000010101000000
ST_L_VL:   DC.W 20
           DC.L ST_L_TXT
           DC.W %0000010100000000
ST_R_VL:   DC.W 20
           DC.L ST_R_TXT
           DC.W %0000010010000000
ST_TRBL:   DC.W 6
           DC.L TRBL_TXT
           DC.W %0000010001000000
ST_BASS:   DC.W 6
           DC.L BASS_TXT
           ENDPART

           >PART 'Print Dezimal'
PR_DEZIMAL:
            moveq   #10,D5
            moveq   #2-1,D4
            ext.l   D6

            move.l  A0,-(SP)

            addq.l  #3,A0
            bsr     BINASC

            movea.l (SP)+,A0
            bra     PR_TEXT
           ENDPART
           >PART 'Print Cursor'
PR_CURSOR:
            movea.l SCRL2_POS(PC),A0
            move.b  (A0),D0
            cmp.b   #13,D0
            beq.s   PR_CURSOR_EX
            cmp.b   #10,D0
            beq.s   PR_CURSOR_EX

            move.w  SCRL2_X(PC),D1
            cmp.w   #22,D1
            bcs.s   PR_CURSOR_EX
            cmp.w   #24+1,D1
            bcc.s   PR_CURSOR_EX

            move.w  SCRL2_Y(PC),D2
            cmp.w   SCRL2_YA(PC),D2
            bcs.s   PR_CURSOR_EX
            cmp.w   SCRL2_YE(PC),D2
            bcc.s   PR_CURSOR_EX

            lea     SCRL2_FLAG(PC),A0
            tst.w   (A0)
            beq.s   PR_CURSOR_JP1
PR_CURSOR_EX:
            rts
PR_CURSOR_JP1:
            moveq   #'[',D0
            bra     PR_CHAR
           ENDPART
           >PART 'Print Scroll2 V2.1'
PR_SCRL2:
            lea     SCRL2_POS(PC),A0
           BASE A0,SCRL2_POS

            movea.l (A0),A1
            move.w  SCRL2_X(PC),D1
            move.w  SCRL2_Y(PC),D2
            move.w  SCRL2_YE(PC),D3

            move.w  SCRL2_FLAG(PC),D0
            bne.s   SCRL2_SONDER
SCRL2_LP1:
            moveq   #0,D0
            move.b  (A1)+,D0
            bne.s   SCRL2_NOTNEW

            movea.l SCRL2_TXT(PC),A1
            move.b  (A1)+,D0
SCRL2_NOTNEW:
            cmp.b   #'x',D0
            beq.s   GET_NEW_ROW
            cmp.b   #'y',D0
            beq.s   GET_NEW_COLUM
            cmp.b   #'z',D0
            beq.s   GET_NEW_COLUME
            cmp.b   #'p',D0
            beq.s   GET_NEW_WAIT
            cmp.b   #'d',D0
            beq.s   SCRL2_LP1

            cmp.b   #$0D,D0
            beq     SCRL2_CR
            cmp.b   #$0A,D0
            beq     SCRL2_LF


            bsr     PR_CHAR

            addq.w  #1,D2
            cmp.w   D3,D2
            bls.s   SCRL2_EX

            move.w  D3,D2
SCRL2_EX:
            move.l  A1,(A0)
            move.w  D2,SCRL2_Y(A0)
            rts

SCRL2_SONDER:
            cmp.w   #2,D0
            beq.s   SCRL2_WAIT
            cmp.w   #3,D0
            beq.s   SCRL2_CPY

            bra.s   SCRL2_LP1

SCRL2_WAIT:
            subq.w  #1,SCRL2_TIME(A0)
            bpl.s   SCRL2_EX

            clr.w   SCRL2_FLAG(A0)
            bra.s   SCRL2_EX

GET_NEW_ROW:
            bsr     GET_DEZ
            add.w   #22,D0
            move.w  D0,SCRL2_X(A0)
            move.w  D0,D1
            bra.s   SCRL2_LP1

GET_NEW_COLUM:
            bsr     GET_DEZ
            move.w  D0,SCRL2_Y(A0)
            move.w  D0,SCRL2_YA(A0)
            move.w  D0,D2
            bra     SCRL2_LP1

GET_NEW_COLUME:
            bsr     GET_DEZ
            add.w   SCRL2_YA(PC),D0
            move.w  D0,SCRL2_YE(A0)
            move.w  D0,D3
            bra     SCRL2_LP1

GET_NEW_WAIT:
            bsr     GET_DEZ

            moveq   #' ',D0
            bsr     PR_CHAR

            move.w  D0,SCRL2_TIME(A0)
            move.w  #2,SCRL2_FLAG(A0)
            bra.s   SCRL2_EX

SCRL2_CR:
            move.w  SCRL2_YA(PC),D2
            bra     SCRL2_LP1

SCRL2_LF:
            addq.w  #1,D1
            cmp.w   #25-1,D1
            bls.s   SCRL2_LF_JP1

            move.w  #3,SCRL2_FLAG(A0)
            move.w  #8,SCRL2_TIME(A0)
            bra.s   SCRL2_CPY
SCRL2_LF_JP1:
            move.w  D1,SCRL2_X(A0)
            bra     SCRL2_LP1

SCRL2_CPY:
            subq.w  #1,SCRL2_TIME(A0)
            bpl.s   SCRL2_CPY_JP2

            clr.w   SCRL2_FLAG(A0)
            move.w  #22+2,SCRL2_X(A0)
            bra     SCRL2_LP1
SCRL2_CPY_JP2:
            moveq   #0,D4
            move.w  SCRL2_YE(PC),D4
            sub.w   SCRL2_YA(PC),D4
            bmi     SCRL2_EX
            cmp.w   #39,D4
            bcs.s   SCRL2_CPY_JP1

            moveq   #39,D4
SCRL2_CPY_JP1:
            addq.w  #1,D4
            lsr.w   #1,D4
            moveq   #0,D5
            move.w  D4,D5

            mulu    #12,D4
            lea     SCRL2_CPYTAB1(PC),A2
            suba.w  D4,A2

            movea.l LOGRAM(PC),A3
            movea.l PHYSRAM(PC),A4
            lea     160*22*8(A3),A3
            lea     160*22*8(A4),A4
            adda.w  PLANE(PC),A3
            adda.w  PLANE(PC),A4

            move.w  SCRL2_YA(PC),D4
            bclr    #0,D4
            lsl.w   #2,D4
            adda.w  D4,A3
            adda.w  D4,A4

            moveq   #3*8-2,D4
SCRL2_CPY_LP1:
            jsr     (A2)
            lea     160(A3),A3
            lea     160(A4),A4
            dbra    D4,SCRL2_CPY_LP1

            mulu    #8,D5
            lea     SCRL2_CPYTAB2(PC),A2
            suba.w  D5,A2

            moveq   #0,D6
            jsr     (A2)

            bra     SCRL2_EX

V1         SET 160-8
           REPT 40/2
            move.w  160+V1(A3),D6
            move.w  D6,V1(A3)
            move.w  D6,V1(A4)
V1         SET V1-8
           ENDR
SCRL2_CPYTAB1:
            rts

V1         SET 160-8
           REPT 40/2
            move.w  D6,V1(A3)
            move.w  D6,V1(A4)
           ENDR
SCRL2_CPYTAB2:
            rts
           BASE A0,OFF
           EVEN
           ENDPART

           >PART 'Hole Dezimal Zahl'
GET_DEZ:
            move.l  D1,-(SP)
            moveq   #0,D1
NEXT_ZIFFER:
            move.b  (A1),D0
            cmp.b   #'0',D0
            bcs.s   RETOUR
            cmp.b   #'9'+1,D0
            bcc.s   RETOUR

            addq.l  #1,A1

            sub.w   #'0',D0
            mulu    #10,D1
            add.w   D0,D1
            bra.s   NEXT_ZIFFER
RETOUR:
            move.l  D1,D0
            move.l  (SP)+,D1
            rts
           ENDPART

           >PART 'Print Text'




PR_TEXT:
            moveq   #0,D1
            moveq   #0,D2
            moveq   #0,D3
            move.b  (A0)+,D1
            move.b  (A0)+,D2
            move.b  (A0)+,D3

            move.w  D2,D4

            tst.w   D3
            bne.s   PR_TXT_LP1

            moveq   #40,D3
PR_TXT_LP1:
            moveq   #0,D0
            move.b  (A0)+,D0
            beq.s   PR_TXT_EX
            bmi.s   PR_TEXT

            cmp.w   #13,D0
            beq.s   PR_TXT_JP1
            cmp.w   #10,D0
            beq.s   PR_TXT_JP2

            cmp.w   D2,D3
            beq.s   PR_TXT_JP3

            bsr.s   PR_CHAR
            addq.w  #1,D2
            bra.s   PR_TXT_LP1
PR_TXT_EX:
            rts

PR_TXT_JP1:
            cmp.w   D2,D3
            beq.s   PR_TXT_JP11

            moveq   #' ',D0
            bsr.s   PR_CHAR

            addq.w  #1,D2
            bra.s   PR_TXT_JP1
PR_TXT_JP11:
            move.w  D4,D2
            bra.s   PR_TXT_LP1

PR_TXT_JP2:
            addq.w  #1,D1
            bra.s   PR_TXT_LP1

PR_TXT_JP3:
            move.b  (A0)+,D0
            beq.s   PR_TXT_EX
            cmp.w   #13,D0
            beq.s   PR_TXT_JP1
            cmp.w   #10,D0
            beq.s   PR_TXT_JP2
            bra.s   PR_TXT_JP3
           ENDPART
           >PART 'Print Char'



PR_CHAR:
            movem.l D0-D2/A0-A2,-(SP)

            sub.w   #" ",D0
            bmi.s   KO_1

            cmp.w   #61-1,D0
            bls.s   OK_1
KO_1:
            moveq   #0,D0
OK_1:
            lsl.w   #3,D0
            lea     CHAR__8(PC),A0
            adda.w  D0,A0

            movea.l LOGRAM(PC),A1
            movea.l PHYSRAM(PC),A2

            cmp.w   #24,D1
            bhi.s   PR_CHAR_EX

            move.w  D1,D0
            add.w   D1,D1
            add.w   D1,D1
            add.w   D0,D1
            moveq   #8,D0
            lsl.w   D0,D1

            adda.w  D1,A1
            adda.w  D1,A2

            cmp.w   #39,D2
            bhi.s   PR_CHAR_EX


            bclr    #0,D2
            beq.s   OK_2

            addq.l  #1,A1
            addq.l  #1,A2
OK_2:
            add.w   D2,D2
            add.w   D2,D2
            add.w   PLANE(PC),D2
            adda.w  D2,A1
            adda.w  D2,A2

            move.b  (A0),(A1)
            move.b  (A0)+,(A2)
V1         SET 160
           REPT 7-1
            move.b  (A0),V1(A1)
            move.b  (A0)+,V1(A2)
V1         SET V1+160
           ENDR
PR_CHAR_EX:
            movem.l (SP)+,D0-D2/A0-A2
            rts
PLANE:     DC.W 0
           ENDPART

           >PART 'VBlank Routine'
VBL:
            addq.l  #1,$00000466.w

            clr.b   $FFFFFA1B.w
            move.l  #TIMER_B1,$00000120.w

            move.b  #100,$FFFFFA21.w
            move.b  #8,$FFFFFA1B.w
            bset    #0,$FFFFFA07.w
            bset    #0,$FFFFFA13.w

            movem.l D0-D6/A0-A4,-(SP)

            movem.l ST_COLOR(PC),D0-D6/A0
            movem.l D0-D6/A0,$FFFF8240.w

            jsr     MOD_PLAYER+4
            bsr.s   VU_METER
            bsr     DO_SCROLL1

            lea     LOGRAM(PC),A0
            move.l  (A0),D0
            move.l  PHYSRAM(PC),(A0)
            move.l  D0,PHYSRAM-LOGRAM(A0)

            lsr.l   #8,D0
            lea     $FFFF8200.w,A0
            movep.w D0,1(A0)

            movem.l (SP)+,D0-D6/A0-A4
            rte
           ENDPART

           >PART 'VU-Meter'
VU_METER:
            movea.l LOGRAM(PC),A0
            lea     160*100+48+6(A0),A0

            lea     MOD_PLAYER+12,A1
            lea     VU(PC),A2

            moveq   #4-1,D6
VU_LP1:
            movea.l A0,A3
            movea.l A2,A4
            adda.w  (A1)+,A4
V1         SET 0
           REPT 5
            movem.w (A4)+,D0-D5
            move.w  D0,(V1+$0000)*160(A3)
            move.w  D0,(V1+$0001)*160(A3)
            move.w  D1,(V1+$0002)*160(A3)
            move.w  D1,(V1+$0003)*160(A3)
            move.w  D2,(V1+$0004)*160(A3)
            move.w  D2,(V1+$0005)*160(A3)
            move.w  D3,(V1+$0006)*160(A3)
            move.w  D3,(V1+$0007)*160(A3)
            move.w  D4,(V1+$0008)*160(A3)
            move.w  D4,(V1+$0009)*160(A3)
            move.w  D5,(V1+$000A)*160(A3)
            move.w  D5,(V1+$000B)*160(A3)
V1         SET V1+12
           ENDR
            movem.w (A4)+,D0-D3
            move.w  D0,(V1+$0000)*160(A3)
            move.w  D0,(V1+$0001)*160(A3)
            move.w  D1,(V1+$0002)*160(A3)
            move.w  D1,(V1+$0003)*160(A3)
            move.w  D2,(V1+$0004)*160(A3)
            move.w  D2,(V1+$0005)*160(A3)
            move.w  D3,(V1+$0006)*160(A3)
            move.w  D3,(V1+$0007)*160(A3)

            lea     2*8(A0),A0
            dbra    D6,VU_LP1

            rts
VU:
           DS.W 33
           DS.W 33,$00007FFF
           ENDPART
           >PART 'scroll den Modul-Name'
DO_SCROLL1:
           BASE A0,SCRL1BUF
            lea     SCRL1BUF(PC),A0
            movem.l 2(A0),D0-D6/A1-A4
            movem.l D0-D6/A1-A4,(A0)
            movem.l 44+2(A0),D0-D6/A1-A4
            movem.l D0-D6/A1-A4,44(A0)
            movem.l 88+2(A0),D0-D6/A1-A4
            movem.l D0-D6/A1-A4,88(A0)
            movem.l 132+2(A0),D0-D6
            movem.l D0-D6,132(A0)

            movea.l SCRL1ADR(PC),A1
            move.w  (A1)+,D0
            bpl.s   DOSCROLL_JP1

            lea     SCRL1TAB(PC),A1
DOSCROLL_JP02:
            move.w  SCRL1SOUND(PC),D2

            movem.w 0(A1,D2.w),D3-D5
            tst.w   D3
            bpl.s   DOSCROLL_JP0

            clr.w   SCRL1SOUND(A0)
            bra.s   DOSCROLL_JP02
DOSCROLL_JP0:
            addq.w  #1,2(A1,D2.w)
            cmp.w   D4,D5
            bcc.s   DOSCROLL_JP01

            clr.w   2(A1,D2.w)
            addq.w  #6,SCRL1SOUND(A0)
            bra.s   DOSCROLL_JP02
DOSCROLL_JP01:
            adda.w  D3,A1

            move.l  A1,SCRL1ADR(A0)
            move.w  (A1)+,D0
            move.w  D0,SCRL1OFFSET(A0)
DOSCROLL_JP1:
            move.l  A1,SCRL1ADR(A0)
            add.w   SCRL1CENTER(PC),D0

            move.w  #639,D1
            sub.w   SCRL1OFFSET(PC),D0
            bpl.s   DOSCROLL_JP2

            add.w   D1,D0
DOSCROLL_JP2:
            cmp.w   D1,D0
            bls.s   DOSCROLL_JP3

            sub.w   D1,D0
DOSCROLL_JP3:
            move.w  D0,SCRL1BUFN(A0)

            move.w  #639*2,D0
            move.w  SCRL1CNT(PC),D1
            add.w   SCRL1WAY(PC),D1
            bmi.s   DOSCROLL_JP41

            cmp.w   D0,D1
            bls.s   DOSCROLL_JP4

            sub.w   D0,D1
            bra.s   DOSCROLL_JP4
DOSCROLL_JP41:
            add.w   D0,D1
DOSCROLL_JP4:
            move.w  D1,SCRL1CNT(A0)
            lsr.w   #1,D1
           BASE A0,OFF

            movea.l LOGRAM(PC),A1
            adda.w  SCRL1HIGH(PC),A1

            move.w  SCRL1ANZ(PC),D0
DOSCROLL_LP1:
            move.w  D0,-(SP)
            lea     SCROLL1,A2
            moveq   #16-1,D0
DOSCROLL_LP2:
            move.w  (A0)+,D6
            add.w   D1,D6
            cmp.w   #639,D6
            bls.s   DOSCROLL_JP5

            sub.w   #639,D6
DOSCROLL_JP5:
            moveq   #0,D5
            move.w  D6,D5

            and.w   #15,D5
            mulu    #82,D5
            lea     0(A2,D5.w),A3

            lsr.w   #4,D6
            adda.w  D6,A3
            adda.w  D6,A3

            movem.w (A3)+,D2-D6/A4
            move.w  D2,(A1)
            move.w  D3,8(A1)
            move.w  D4,16(A1)
            move.w  D5,24(A1)
            move.w  D6,32(A1)
            move.w  A4,40(A1)
            movem.w (A3)+,D2-D6/A4
            move.w  D2,48(A1)
            move.w  D3,56(A1)
            move.w  D4,64(A1)
            move.w  D5,72(A1)
            move.w  D6,80(A1)
            move.w  A4,88(A1)
            movem.w (A3)+,D2-D6/A4
            move.w  D2,96(A1)
            move.w  D3,104(A1)
            move.w  D4,112(A1)
            move.w  D5,120(A1)
            move.w  D6,128(A1)
            move.w  A4,136(A1)
            move.w  (A3)+,144(A1)
            move.w  (A3)+,152(A1)
            lea     160(A1),A1
            lea     1350(A2),A2
            dbra    D0,DOSCROLL_LP2

            lea     4*160(A1),A1
            move.w  (SP)+,D0
            dbra    D0,DOSCROLL_LP1

            rts
           ENDPART

           >PART 'Timer B Routinen'
TIMER_B1:
            clr.b   $FFFFFA1B.w
            move.l  #TIMER_B2,$00000120.w
            move.b  #2,$FFFFFA21.w
            move.b  #8,$FFFFFA1B.w

            move.w  #$0444,$FFFF8240+2.w
            move.w  #$0DDD,$FFFF8240+6.w
            rte

TIMER_B2:
            move.w  D0,-(SP)

            move.w  RASTER1(PC),D0
            beq.s   TIMER_B2_JP

            move.w  D0,$FFFF8240+16.w
            move.w  D0,$FFFF8240+20.w

            not.w   D0
            move.w  D0,$FFFF8240+4.w
            addq.w  #2,TIMER_B2+4

            move.w  (SP)+,D0
            rte
TIMER_B2_JP:
            move.w  #RASTER1-TIMER_B2-4,TIMER_B2+4

            move.l  #TIMER_B3,$00000120.w
            move.w  #$0777,$FFFF8240+16.w
            move.w  #$0FFF,$FFFF8240+20.w
            move.w  (SP)+,D0
            rte

TIMER_B3:
            move.w  D0,-(SP)

            move.w  RASTER2(PC),D0
            beq.s   TIMER_B3_JP

            move.w  D0,$FFFF8240+4.w
            addq.w  #2,TIMER_B3+4

            move.w  (SP)+,D0
            rte
TIMER_B3_JP:
            move.w  #RASTER2-TIMER_B3-4,TIMER_B3+4
            clr.b   $FFFFFA1B.w
            move.w  (SP)+,D0
            rte

RASTER1:
           DC.W $0E00,$0780,$0F10,$0F90,$0F20,$0FA0,$0F30,$0FB0
           DC.W $0F40,$0FC0,$0F50,$0FD0,$0F60,$0FE0,$0F70,$0FF0
           DC.W $07F0,$0EF0,$06F0,$0DF0,$05F0,$0CF0,$04F0,$0BF0
           DC.W $03F0,$0AF0,$02F0,$09F0,$00F0,$0070,$00E0,$0060
           DC.W $00D0
           DC.W 0
RASTER2:
           DC.W $0FAF,$0F1F,$0F8F,$0F0F,$0F87,$0F1E,$0F96,$0F2D
           DC.W $0FA5,$0F3C,$0FB4,$0F4B,$0FC3,$0F5A,$0FD2
           DC.W 0
           ENDPART

           DATA
           DC.W ^^DATE,^^TIME
           >PART 'Print Texte'





TEXT2:
           DC.B $0E,$00,$0D
           DC.B "FILENAME:",13,10,10
           DC.B "FILELENGHT:",$FF
           DC.B $12,0,0,"PATTERN:",$FF
           DC.B $13,4,4+1,".",0
TEXT3:
           DC.B $0F,$1B,$00
           DC.B "MAIN  VOL.",13,10
           DC.B "LEFT  VOL.",13,10
           DC.B "RIGHT VOL.",13,10
           DC.B "TREBLE",13,10
           DC.B "BASS",0
TEXT4:
           DC.B $0F,$1B,$00
           DC.B "TRACKER VOL.",0

M_VL_TXT:  DC.B $0F,$25,$27,"40",0
ST_L_TXT:  DC.B $10,$25,$27,"20",0
ST_R_TXT:  DC.B $11,$25,$27,"20",0
TRBL_TXT:  DC.B $12,$25,$27,"12",0
BASS_TXT:  DC.B $13,$25,$27,"12",0
MOD__TXT:  DC.B $12,$1F,$21,"00",0
SONG_TXT:  DC.B $13,$01,$03,"00",0
PATR_TXT:  DC.B $13,$05,$08,"00",0

           ENDPART
           >PART 'Scroll2 Texte'

SCRL2_POS: DC.L 0
SCRL2_TXT: DC.L 0
SCRL2_X:   DC.W 0
SCRL2_Y:   DC.W 0
SCRL2_YA:  DC.W 0
SCRL2_YE:  DC.W 0
SCRL2_FLAG:DC.W 0
SCRL2_TIME:DC.W 0

SCRL2_TXT1:
           DC.B 'x00y00z39'
           IBYTES 'PLAYER26.TXT'
SCRL2_END:
           DC.B 0
SCRL2_TXT2:
           IF _FLOAD=0
SCRL2_FLOAD:
           DS.B 3*1024

           ELSE
           IBYTES 'BLABLA.TXT'
           ENDC

           EVEN
           ENDPART
           >PART 'Sinus  Data'
SCRL1BUFF_LEN EQU 5*16
SCRL1BUF:  DS.W SCRL1BUFF_LEN-1
SCRL1BUFN: DS.W 1
SCRL1ANZ:  DC.W 0
SCRL1HIGH: DC.W 0
SCRL1CENTER:DC.W 0
SCRL1CNT:  DC.W 0
SCRL1WAY:  DC.W 0
SCRL1ADR:  DC.L 0
SCRL1OFFSET:DC.W 0
SCRL1SOUND:DC.W 0
           BASE DC.W,SCRL1TAB




SCRL1TAB:
           DC.W STAND,0,50
           DC.W SINUS_68,0,1
           DC.W SINUS_34,0,2
           DC.W SINUS_17,0,4

           REPT 8
           DC.W SINUS_DK,0,1
           DC.W STAND,0,50
           ENDR

           REPT 4
           DC.W SINUS_DM,0,1
           DC.W STAND,0,50
           ENDR

           REPT 2
           DC.W SINUS_DL,0,1
           DC.W STAND,0,50
           ENDR

           DC.W SINUS_DL,0,1
           DC.W SINUS_DM,0,2
           DC.W SINUS_DK,0,4
           DC.W SINUS_68,0,1
           DC.W STAND,0,100
           DC.W SINUS_DK,0,1
           DC.W SINUS_DM,0,1
           DC.W SINUS_DL,0,1
           DC.W SINUS_DM,0,1
           DC.W SINUS_DK,0,1
           DC.W SINUS_17,0,2
           DC.W SINUS_34,0,4
           DC.W SINUS_68,0,4
           DC.W SINUS_17,0,1
           DC.W SINUS_DM,0,1
           DC.W SINUS_DL,0,4
           DC.W SINUS_DM,0,8
           DC.W SINUS_DK,0,16
           DC.W SINUS_17,0,8
           DC.W SINUS_34,0,4
           DC.W SINUS_68,0,2

           DC.W STAND,0,50

           DC.W -1
           BASE DC.W,OFF

STAND:
           DS.W 1
           DC.W -1

SINUS_68:
           DC.W $0044,$0044,$0045,$0046,$0047,$0048,$0049,$004A,$004B,$004C,$004D,$004E,$004F,$0050,$0051,$0052
           DC.W $0053,$0054,$0055,$0056,$0057,$0058,$0059,$005A,$005B,$005C,$005D,$005E,$005F,$0060,$0061,$0061
           DC.W $0062,$0063,$0064,$0065,$0066,$0067,$0068,$0068,$0069,$006A,$006B,$006C,$006C,$006D,$006E,$006F
           DC.W $0070,$0070,$0071,$0072,$0073,$0073,$0074,$0075,$0075,$0076,$0077,$0077,$0078,$0079,$0079,$007A
           DC.W $007A,$007B,$007C,$007C,$007D,$007D,$007E,$007E,$007F,$007F,$0080,$0080,$0081,$0081,$0081,$0082
           DC.W $0082,$0083,$0083,$0083,$0084,$0084,$0084,$0085,$0085,$0085,$0085,$0086,$0086,$0086,$0086,$0086
           DC.W $0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087,$0087
           DC.W $0087,$0087,$0087,$0087,$0087,$0087,$0087,$0086,$0086,$0086,$0086,$0086,$0085,$0085,$0085,$0085
           DC.W $0084,$0084,$0084,$0083,$0083,$0083,$0082,$0082,$0081,$0081,$0080,$0080,$0080,$007F,$007F,$007E
           DC.W $007E,$007D,$007D,$007C,$007B,$007B,$007A,$007A,$0079,$0078,$0078,$0077,$0076,$0076,$0075,$0074
           DC.W $0074,$0073,$0072,$0072,$0071,$0070,$006F,$006F,$006E,$006D,$006C,$006B,$006B,$006A,$0069,$0068
           DC.W $0067,$0066,$0066,$0065,$0064,$0063,$0062,$0061,$0060,$005F,$005E,$005D,$005D,$005C,$005B,$005A
           DC.W $0059,$0058,$0057,$0056,$0055,$0054,$0053,$0052,$0051,$0050,$004F,$004E,$004D,$004C,$004B,$004A
           DC.W $0049,$0048,$0047,$0046,$0045,$0044,$0044,$0043,$0042,$0041,$0040,$003F,$003E,$003D,$003C,$003B
           DC.W $003A,$0039,$0038,$0037,$0036,$0035,$0034,$0033,$0032,$0031,$0030,$002F,$002F,$002E,$002D,$002C
           DC.W $002B,$002A,$0029,$0028,$0027,$0026,$0025,$0024,$0024,$0023,$0022,$0021,$0020,$001F,$001E,$001E
           DC.W $001D,$001C,$001B,$001A,$001A,$0019,$0018,$0017,$0017,$0016,$0015,$0014,$0014,$0013,$0012,$0012
           DC.W $0011,$0010,$0010,$000F,$000F,$000E,$000D,$000D,$000C,$000C,$000B,$000B,$000A,$000A,$0009,$0009
           DC.W $0008,$0008,$0007,$0007,$0006,$0006,$0006,$0005,$0005,$0005,$0004,$0004,$0004,$0003,$0003,$0003
           DC.W $0002,$0002,$0002,$0002,$0002,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
           DC.W $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0002,$0002,$0002
           DC.W $0002,$0003,$0003,$0003,$0003,$0004,$0004,$0004,$0005,$0005,$0005,$0006,$0006,$0006,$0007,$0007
           DC.W $0008,$0008,$0009,$0009,$000A,$000A,$000B,$000B,$000C,$000C,$000D,$000D,$000E,$000F,$000F,$0010
           DC.W $0010,$0011,$0012,$0012,$0013,$0014,$0015,$0015,$0016,$0017,$0017,$0018,$0019,$001A,$001B,$001B
           DC.W $001C,$001D,$001E,$001F,$001F,$0020,$0021,$0022,$0023,$0024,$0025,$0025,$0026,$0027,$0028,$0029
           DC.W $002A,$002B,$002C,$002D,$002E,$002F,$0030,$0031,$0031,$0032,$0033,$0034,$0035,$0036,$0037,$0038
           DC.W $0039,$003A,$003B,$003C,$003D,$003E,$003F,$0040,$0041,$0042,$0043
           DC.W -1
SINUS_34:
           DC.W $0022,$0022,$0023,$0024,$0025,$0026,$0027,$0028,$0029,$002A,$002B,$002C,$002D,$002E,$002F,$0030

           DC.W $0031,$0032,$0033,$0034,$0034,$0035,$0036,$0037,$0038,$0038,$0039,$003A,$003A,$003B,$003C,$003C
           DC.W $003D,$003E,$003E,$003F,$003F,$0040,$0040,$0040,$0041,$0041,$0042,$0042,$0042,$0042,$0043,$0043
           DC.W $0043,$0043,$0043,$0043,$0043,$0043,$0043,$0043,$0043,$0043,$0043,$0043,$0043,$0043,$0042,$0042
           DC.W $0042,$0042,$0041,$0041,$0040,$0040,$0040,$003F,$003F,$003E,$003D,$003D,$003C,$003C,$003B,$003A
           DC.W $003A,$0039,$0038,$0037,$0037,$0036,$0035,$0034,$0033,$0033,$0032,$0031,$0030,$002F,$002E,$002D
           DC.W $002C,$002B,$002A,$0029,$0028,$0027,$0026,$0025,$0024,$0023,$0022,$0022,$0021,$0020,$001F,$001E
           DC.W $001D,$001C,$001B,$001A,$0019,$0018,$0018,$0017,$0016,$0015,$0014,$0013,$0012,$0011,$0010,$000F
           DC.W $000F,$000E,$000D,$000C,$000C,$000B,$000A,$0009,$0009,$0008,$0008,$0007,$0006,$0006,$0005,$0005
           DC.W $0004,$0004,$0003,$0003,$0003,$0002,$0002,$0002,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001
           DC.W $0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0001,$0002,$0002,$0002,$0003,$0003,$0003,$0004
           DC.W $0004,$0005,$0005,$0006,$0006,$0007,$0007,$0008,$0008,$0009,$000A,$000B,$000B,$000C,$000D,$000E
           DC.W $000E,$000F,$0010,$0011,$0012,$0013,$0013,$0014,$0015,$0016,$0017,$0018,$0019,$001A,$001B,$001C

           DC.W $001D,$001E,$001F,$0020,$0021
           DC.W -1
SINUS_17:
           DC.W $0011,$0011,$0012,$0013,$0014,$0015,$0016,$0017,$0018,$0019,$001A,$001B,$001C,$001C,$001D,$001E
           DC.W $001E,$001F,$001F,$0020,$0020,$0021,$0021,$0021,$0021,$0021,$0021,$0021,$0021,$0021,$0021,$0021
           DC.W $0021,$0020,$0020,$0020,$001F,$001E,$001E,$001D,$001D,$001C,$001B,$001A,$0019,$0019,$0018,$0017
           DC.W $0016,$0015,$0014,$0013,$0012,$0011,$0011,$0010,$000F,$000E,$000D,$000C,$000B,$000A,$0009,$0008
           DC.W $0008,$0007,$0006,$0005,$0005,$0004,$0003,$0003,$0002,$0002,$0002,$0001,$0001,$0001,$0001,$0001
           DC.W $0001,$0001,$0001,$0001,$0001,$0001,$0002,$0002,$0002,$0003,$0003,$0004,$0004,$0005,$0006,$0007
           DC.W $0007,$0008,$0009,$000A,$000B,$000C,$000D,$000E,$000F,$0010
           DC.W -1
SINUS_DL:
           DC.W $0022,$0021,$0022,$0020,$0023,$001F,$0024,$001E,$0025,$001D,$0026,$001C,$0027,$001B,$0028,$001A
           DC.W $0029,$0019,$002A,$0018,$002B,$0017,$002C,$0016,$002D,$0015,$002E,$0014,$002F,$0013,$0030,$0013
           DC.W $0031,$0012,$0032,$0011,$0033,$0010,$0034,$000F,$0034,$000E,$0035,$000E,$0036,$000D,$0037,$000C
           DC.W $0038,$000B,$0038,$000B,$0039,$000A,$003A,$0009,$003A,$0008,$003B,$0008,$003C,$0007,$003C,$0007
           DC.W $003D,$0006,$003E,$0006,$003E,$0005,$003F,$0005,$003F,$0004,$0040,$0004,$0040,$0003,$0040,$0003
           DC.W $0041,$0003,$0041,$0002,$0042,$0002,$0042,$0002,$0042,$0001,$0042,$0001,$0043,$0001,$0043,$0001
           DC.W $0043,$0001,$0043,$0001,$0043,$0001,$0043,$0001,$0043,$0001,$0043,$0001,$0043,$0001,$0043,$0001
           DC.W $0043,$0001,$0043,$0001,$0043,$0001,$0043,$0001,$0043,$0001,$0043,$0002,$0042,$0002,$0042,$0002
           DC.W $0042,$0003,$0042,$0003,$0041,$0003,$0041,$0004,$0040,$0004,$0040,$0005,$0040,$0005,$003F,$0006
           DC.W $003F,$0006,$003E,$0007,$003D,$0008,$003D,$0008,$003C,$0009,$003C,$0009,$003B,$000A,$003A,$000B
           DC.W $003A,$000C,$0039,$000C,$0038,$000D,$0037,$000E,$0037,$000F,$0036,$000F,$0035,$0010,$0034,$0011
           DC.W $0033,$0012,$0033,$0013,$0032,$0014,$0031,$0015,$0030,$0016,$002F,$0017,$002E,$0018,$002D,$0018
           DC.W $002C,$0019,$002B,$001A,$002A,$001B,$0029,$001C,$0028,$001D,$0027,$001E,$0026,$001F,$0025,$0020
           DC.W $0024,$0021,$0023,$0022,$0022,$0022
           DC.W -1
SINUS_DM:
           DC.W $0011,$0010,$0011,$000F,$0012,$000E,$0013,$000D,$0014,$000C,$0015,$000B,$0016,$000A,$0017,$0009
           DC.W $0018,$0008,$0019,$0007,$001A,$0007,$001B,$0006,$001C,$0005,$001C,$0004,$001D,$0004,$001E,$0003
           DC.W $001E,$0003,$001F,$0002,$001F,$0002,$0020,$0002,$0020,$0001,$0021,$0001,$0021,$0001,$0021,$0001
           DC.W $0021,$0001,$0021,$0001,$0021,$0001,$0021,$0001,$0021,$0001,$0021,$0001,$0021,$0001,$0021,$0002
           DC.W $0021,$0002,$0020,$0002,$0020,$0003,$0020,$0003,$001F,$0004,$001E,$0005,$001E,$0005,$001D,$0006
           DC.W $001D,$0007,$001C,$0008,$001B,$0008,$001A,$0009,$0019,$000A,$0019,$000B,$0018,$000C,$0017,$000D
           DC.W $0016,$000E,$0015,$000F,$0014,$0010,$0013,$0011,$0012,$0011
           DC.W -1
SINUS_DK:
           DC.W $0008,$0009,$0008,$0008,$0009,$0008,$000A,$0007,$000B,$0006,$000C,$0005,$000D,$0004,$000E,$0004
           DC.W $000E,$0003,$000F,$0002,$000F,$0002,$000F,$0001,$000F,$0001,$000F,$0001,$000F,$0001,$000F,$0001
           DC.W $000F,$0001,$000E,$0001,$000E,$0001,$000D,$0002,$000C,$0002,$000B,$0003,$000B,$0004,$000A,$0005
           DC.W $0009,$0006,$0008,$0007,$0008,$0008
           DC.W -1

           ENDPART
           >PART 'GraFiX Data'
CHAR__8:   IBYTES 'CHAR_8.BLK'
           EVEN
CHAR_16:
           IBYTES 'CHAR_16.BLK',2176
           EVEN

           IF _FLOAD=0
NINJA_NAME:DC.B "NINJA3.PI1",0
           EVEN
           DS.W 1
ST_COLOR:  DS.W 16
NINJA_PIC: DS.B 100*160

           ELSE
ST_COLOR:  IBYTES 'NINJA3.PI1',32,2
NINJA_PIC: IBYTES 'NINJA3.PI1',16000,34
           ENDC
           EVEN

END_COLOR: IBYTES 'A_CH38PR.BLK',32
A_CH38_PRO:IBYTES 'A_CH38PR.BLK',13792,32
           EVEN
           ENDPART
;****************************************
           >PART 'Tracker ErklÑrungen'
;************************************
; MOD_PLAYER INIT :
;bsr MOD_PLAYER
;benîtigte Werte
;a0 = Adresse des Moduls (unkompaktet!)

;d0 = Frequenz in Hertz                  (5000 - 21000)
;d1 = Soundmode                          (0-4)
;                                         0 = mit Volume / 7-Bit-QualitÑt
;                                         1 = mit Volume / 8-Bit-QualitÑt
;                                         2 = ohne Volume (immer 8 Bit)
;                                         3 = STE/TT mit Volume
;                                         4 = STE/TT ohne Volume
;d2 = Nr. des wegzulassenden Tracks      (1-4 oder 0=keiner) nur bei ST-Mode
;************************************
; MOD_PLAYER PLAY
;bsr MOD_PLAYER+4
; muû alle 1/50 Sekunde aufgerufen werden

; abfragbare Daten:
;
; mod_player+12 :  VU-Meter (4 Worte ($3e-$00) nur gerade Zahlen)
;                 (read only)
; mod_player+20:  Position im Song ($00-$7f) (Wort)
;                 (read only)
; mod_player+22:  Position im aktuellen Pattern ($00-$3f) (Wort)
;                 (read only)
; mod_player+24:  Abblendspeed (0=nicht abblenden, 1=schnell bis 10=langsam)
;                 (Wort) (read/write) (Handhabung siehe main)
; mod_player+26:  BasislautstÑrke ($40=normal laut, $00=Stille) (Wort)
;                 (read/write)  (Handhabung siehe main)
;************************************
; MOD_PLAYER EXIT
;bsr MOD_PLAY+8
; der Modplayer rettet alle Hardware Register bei INIT
; und setzt alle wieder zurÅck bei EXIT
;************************************
; Allgemeines
; benutzte Register
; ST        a5/a6/d7
; STe       alle Register frei

; benutzte Timer und Hardware Register
; ST
;           Timer D / Sound Chip
;           MFP im AOI-Modus keine Lîschung des Interrupt_in_Service_A/B
;           Register nîtig. bclr #4,$fffffa11.w z.B. fÅr Timer D
; STe
;           MicoWire Dat / MicroWire Mask / SMODCNTR
;           sowie natÅrlich FRMBAS / FRMEND
;  Steereereeoo & 12517 Hz sind fest eingestellt
           ENDPART
           >PART 'der Tracker'          ;oder was von ihm Åbrig ist
MOD_PLAYER:
           IBYTES 'MODPLY21.IMG'
           EVEN
           ENDPART
;****************************************
           >PART 'BSS'
           BSS
SCROLL1:
           DS.W 20                      ;jeder Buffer ist 1920 Bytes lang
           DS.W 16*675                  ;da aber die 1. und 2. HÑlfte leer
           DS.W 20
; (20+20+20)*16                        ist. Ergeben sich nur 1350 Bytes
; 20 Worte leer            20 20 19
; 20 Worte Grafik                  1 20 19
; 20 Worte leer                           1 20 20
;------------------------------
SCREENS:
           DS.B 256
           DS.W 32000
;------------------------------
MODUL:     DS.L 65535                   ;256 kByte fÅr Musik
; hier hinten muû noch Platz sein, da die Routine das Modul verlÑngert!!!!
; und zwar um genau 900 Bytes pro verw
           DS.B 31*900
MODUL_E:
           DS.L 1
           ENDPART
;=================================================================
;                                               The End, my Friend
;=================================================================
           END
