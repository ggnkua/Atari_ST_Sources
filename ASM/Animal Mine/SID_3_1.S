**********************************************************
* SIDSOUND Designer Editor Source Code (v3.5p)
* copyright 1995 by ANIMAL MINE of THE INDEPENDENT
*
* Features:
*           3 SID Voices
*           Extended Instrument System
*           Extended Soundsubsystem
*
**********************************************************
* First version : 10.04.1993 - last changes : 28.04.1995 *
**********************************************************
                PATH 'D:\SIDSOUND.V25\*.*'
                OUTPUT 'D:\EDITOR.PRG'
                DEFAULT 1
                OPT F+
**********************************************************
                >PART 'Offsets !!'
* SONG Offsets
*SPEED           EQU SONG+4
*RESTART         EQU SONG+6
*LAST_POS        EQU SONG+8
*LAST_PAT        EQU SONG+10
*POS_TAB         EQU SONG+12
*PATTERNS        EQU SONG+132
                ENDPART
**********************************************************
                >PART 'Maximum settings'
special_fx_max  SET 12
nois_max        SET 44+5
tones_max       SET 34+9
waves_max       SET 17
                ENDPART
**********************************************************
                >PART 'Channle Field Offsets'
lv              SET $3F

volume_         SET $0E
instr_type      SET $2C
hardw_buzz      SET $3A
**********************************
extend_tone     SET $3D
extend_wave     SET $3E
tfmx_effect     SET $3F
extend_noiz_adr SET $40
extend_tone_adr SET $44
extend_wave_adr SET $48
extend_noiz     SET $4F
extend_tone_flag SET $4E
extend_buzz     SET $50
                ENDPART
**********************************************************
                >PART 'Initialisierungen'
                BRA     rrr
                MOVEA.L 4(SP),A6        ;Basepageadresse holen
                MOVEA.W #$0100+$0400,A5 ;Gr”že der Basepage + Stackgr”že (1k)
                ADDA.L  12(A6),A5       ;+ Gr”že des TEXT-Segments
                ADDA.L  20(A6),A5       ;+ Gr”že des DATA-Segments
                ADDA.L  28(A6),A5       ;+ Gr”že des BSS-Segments
                MOVE.L  A5,D1           ;= Gesamtl„nge des Programms
                AND.W   #$FFFE,D1       ;L„nge nun gerade
                ADD.L   A6,D1           ;+ Programmstart (Basepageadresse)
                MOVEA.L D1,SP           ;Stack endet dort
                MOVE.L  A5,-(SP)        ;Programml„nge
                MOVE.L  A6,-(SP)        ;Adresse der Basepage
                MOVE.L  #$4A0000,-(SP)  ;Funktionsnummer + Dummyword (0)
                TRAP    #1              ;Mshrink(0,Basepageadr,Prgl„nge)
                LEA     12(SP),SP       ;Nur noch den Stack korrigieren

                MOVE.L  SP,oldstack
                LEA     newstack,SP

;Das war schon alles. In A6 befindet sich noch die Basepageadresse und in a5
;liegt die totale Programml„nge (TRAP #1 zerst”rt D0-D2 und A0-A2!)

;Hier kann nun das eigene Programm liegen
rrr:
                PEA     0.w
                MOVE.W  #32,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP


                MOVE.B  #$12,$FFFFFC02.w
                LINEA   #$0A [ Hidem ]

                MOVE.L  D0,-(SP)
                MOVE.W  #32,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP

                MOVEA.L 4(SP),A3
                MOVE.L  $0C(A3),D0
                ADD.L   $14(A3),D0
                ADD.L   $1C(A3),D0
                ADDI.L  #$0100,D0

                MOVE.L  D0,-(SP)
                MOVE.L  A3,merk_
                MOVE.L  A3,-(SP)
                CLR.W   -(SP)
                MOVE.W  #$4A,-(SP)
                TRAP    #1
                LEA     $0C(SP),SP

                LEA     start_bss,A0
                LEA     end_bss,A1
                MOVEQ   #0,D0
kill_bss:       MOVE.L  D0,(A0)+
                CMPA.L  A0,A1
                BGT.S   kill_bss

                MOVE.W  #4,-(SP)
                TRAP    #$0E
                ADDQ.L  #2,SP
                CMPI.W  #2,D0
                BGE     false

                MOVE.L  #"TEST",end_bss ; Reicht der Speicher ??
                CMPI.L  #"TEST",end_bss ;
                BNE     false           ; Nein, dann tss...

                CLR.L   -(SP)
                MOVE.W  #$20,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP
                MOVE.L  D0,ssp

                MOVE.L  SP,oldstack
                LEA     newstack,SP

                LEA     $FFFF8201.w,A0  ; get old screenpointer
                MOVEP.W 0(A0),D0
                MOVE.W  D0,oldscreen

                LINEA   #$0A [ Hidem ]

                MOVEA.L $044E.w,A0
                MOVE.W  #7999,D0
ca1:            CLR.L   (A0)+
                DBRA    D0,ca1

                MOVE.L  $70.w,oldvbl1+2
                MOVE.L  #fade_1_vbl,$70.w

                MOVE.B  $FFFF8260.w,merk_8260
                MOVE.B  #1,$FFFF8260.w
                BSR     vsync
                MOVE.B  #0,$FFFF820A.w
                BSR     vsync
                MOVE.B  #2,$FFFF8260.w
                MOVE.B  #0,$FFFF8260.w
                BSR     vsync
                MOVE.B  #2,$FFFF820A.w
                BSR     vsync

***************************************************
                MOVE.W  #6,D5
fade_black:     SUBI.W  #$0111,col_8240
                REPT 4
                BSR     vsync
                ENDR
                DBRA    D5,fade_black

                MOVEQ   #7,D0
                MOVEA.W #$8240,A0
black:          CLR.L   (A0)+
                DBRA    D0,black

***************************************************

                MOVE.W  #$0909,new_timer+2
                MOVE.W  #$0909,new_timer2+2

                BCLR    #3,$FFFFFA17.w

                BCLR    #0,$0484.w
                BCLR    #1,$0484.w
                BCLR    #2,$0484.w

                MOVE.L  #screen_base,D0
                CLR.B   D0              ; remove lowword in screenpointer
                MOVE.L  D0,screen
                JSR     set_screen

                MOVEA.L screen,A0
                MOVE.W  #7999,D0
ca:             CLR.L   (A0)+
                DBRA    D0,ca

                LEA     title+34,A0
                MOVEA.L screen,A1
                MOVE.W  #7999,D0
copy_titel:     MOVE.L  (A0)+,(A1)+
                DBRA    D0,copy_titel

                MOVE.L  #fade_2_vbl,$70.w
                BSR     FADEUP

                MOVE.W  #(2*50)-1,D5
WART_2_SECS:    BSR     vsync
                DBRA    D5,WART_2_SECS

                BSR     FADEUP2


                MOVEA.L screen,A0
                LEA     EDIT_PIC,A1
                MOVE.W  #4000-1,D0
COPY_MENU:
                MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                CLR.W   (A0)+
                DBRA    D0,COPY_MENU

                MOVEA.L screen,A0
                LEA     editor_buff,A1  ; Zwei Rettbuffer
                MOVEA.L A0,A2           ;merken!
                LEA     144*160(A0),A0
                LEA     160-16(A0),A0
                MOVEQ   #0,D1
                MOVEQ   #42-1,D0

n_scr:          MOVEM.W (A0),D1-D4
                MOVEM.W D1-D4,(A1)
                MOVEM.W 8(A0),D1-D4
                MOVEM.W D1-D4,8(A1)
                LEA     16(A1),A1
                LEA     160(A0),A0
                DBRA    D0,n_scr

                BSR     FADEDOWN2

                MOVE.L  oldvbl1+2,$70.w

                BSR     createxnytab

                BSR     L0208
                BSR     L021C
                BSR     L0209

                LEA     L03CD,A5
                LEA     $20(A5),A5
                MOVEQ   #$0F,D5
L0000:          MOVE.W  #-1,-(SP)
                MOVE.W  D5,-(SP)
                MOVE.W  #7,-(SP)
                TRAP    #$0E
                ADDQ.L  #6,SP
                MOVE.W  D0,-(A5)
                DBRA    D5,L0000

*                MOVE.W  #2,-(SP)
*                TRAP    #$0E
*                ADDQ.L  #2,SP

                JSR     reset_all

                BSR     INIT_AES
                BSR     L007E

                BSR     SHIFT_MOUSE
                CLR.W   D0
                MOVE.W  D0,D1
                BSR     L00AC

********
                BSR     L0010
                BSR     L01CB
                BSR     L000C
                BSR     L007F
                MOVE.W  $0454.w,D0
                MOVEA.L $0456.w,A0
                MOVE.W  D0,L0322
                MOVE.L  A0,L0323
                SUBQ.W  #1,D0
L0001:          TST.L   (A0)+
                BEQ.S   L0003
                DBRA    D0,L0001
                MOVE.W  $0454.w,D0
                SUBQ.W  #1,D0
                MOVEA.L $0456.w,A1
                LEA     L0324,A0
L0002:          MOVE.L  (A1)+,(A0)+
                DBRA    D0,L0002
                MOVE.W  #$20,$0454.w
                MOVE.L  #L0324,$0456.w
L0003:          MOVE.L  A0,L0325
                MOVE.L  #L0013,(A0)

*********
                BSR     L009C
                BSR     L01A1
                CLR.B   L03B7

                MOVE.B  #$08,$FFFFFC02.w
                LINEA   #$09 [ Showm ]

L0004:          MOVE.W  L0350,D0
                ADD.W   L0351,D0
                MOVE.W  L0352,D1
                ADD.W   L0353,D1
                CMP.W   L034F,D0
                BLS.S   L0006
L0005:
                CMP.W   L034F,D1
                BLS.S   L0007
                BRA.S   L0004

L0006:          MOVE.W  L034F,L0350
                BSR     L00B2
                BRA.S   L0005
L0007:          MOVE.W  L034F,L0352
                BSR     L00BA
                BRA.S   L0004
L0008:          TST.B   L0370
                BNE.S   L0009
                MOVE.W  #$64,D0
                MOVE.W  #5,D1

L0009:          MOVE.B  #0,_clock
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
                BSR     L020A
                JSR     L000D
                MOVE.W  #0,-(SP)
                MOVE.W  #$0B,-(SP)
                TRAP    #$0D
                ADDQ.L  #4,SP
                BSR     INIT_AES
                BSET    #0,$0484.w
                BSET    #1,$0484.w
                BSET    #2,$0484.w
                MOVEA.L L0325,A0
                CLR.L   (A0)
                MOVE.W  L0322,$0454
                MOVE.L  L0323,$0456

                PEA     L03CD
                MOVE.W  #6,-(SP)
                TRAP    #$0E
                ADDQ.L  #6,SP

                LINEA   #$09 [ Showm ]

                BSET    #3,$FFFFFA17.w

                MOVE.L  $70.w,oldvbl1+2
                MOVE.L  #sync,$70.w

                MOVE.W  #1,-(SP)
                PEA     -1
                PEA     -1
                MOVE.W  #5,-(SP)
                TRAP    #14
                LEA     12(SP),SP
                BSR     vsync

                MOVE.B  merk_8260,D6
                MOVE.B  #1,$FFFF8260.w
                BSR     vsync
                MOVE.B  #0,$FFFF820A.w
                BSR     vsync
                MOVE.B  #2,$FFFF8260.w
                MOVE.B  D6,$FFFF8260.w
                BSR     vsync
                MOVE.B  #2,$FFFF820A.w
                BSR     vsync
                EXT.W   D6

                MOVE.W  D6,-(SP)
                PEA     -1
                PEA     -1
                MOVE.W  #5,-(SP)
                TRAP    #14
                LEA     12(SP),SP
                BSR     vsync

                MOVE.L  oldvbl1+2,$70.w

************************************************
                MOVE.W  oldscreen,D0
                LEA     $FFFF8201.w,A0
                MOVEP.W D0,0(A0)        ; alte Screenadresse setzen
************************************************

                MOVEA.L oldstack,SP

                MOVE.L  ssp,-(SP)
                MOVE.W  #$20,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP

                PEA     merk_
                MOVE.W  #$49,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP

                PEA     0.w
                TRAP    #1

false:          PEA     L0320
                MOVE.W  #9,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP

                MOVE.W  #1,-(SP)
                TRAP    #1
                ADDQ.L  #2,SP

                CLR.W   -(SP)
                TRAP    #1
                EVEN
merk_8260:      DC.B 0
                EVEN

vsync:          MOVE.W  D1,-(SP)
                MOVE.B  sync_count,D1
wait_:          CMP.B   sync_count,D1
                BEQ.S   wait_
                MOVE.W  (SP)+,D1
                RTS
                EVEN
sync_count:     DC.B 0
                EVEN
                ENDPART
**********************************************************
                >PART ' FADINGS '
FADEDOWN:
; blendet Farbpaletten runter
                LEA     HILFSPALETTE1,A6 ; w„hrend VBL dort Pal1
                BSR     FADEDWN
                BSR     vsync
                MOVEQ   #15,D7          ; 3 Pal. sind hintereinand.
                LEA     HILFSPALETTE1,A0 ; im Speicher -> eine Rout.
COUNT0COL:      MOVE.W  (A0)+,D0
                AND.W   #$0777,D0
                BNE.S   FADEDOWN
                DBRA    D7,COUNT0COL
                RTS
FADEUP2:
; blendet Farbpalette hoch (auf Weiž)
                LEA     HILFSPALETTE1,A6
                BSR     FADE_UP2
                BSR     vsync
                MOVEQ   #15,D7
                LEA     HILFSPALETTE1,A0
COMPCOL2:       MOVE.W  (A0)+,D0
                AND.W   #$0777,D0
                CMP.W   #$0777,D0
                BNE.S   FADEUP2
                DBRA    D7,COMPCOL2
                RTS

FADEDOWN2:
; blendet Farbpalette von weiž runter auf Palette

                LEA     HILFSPALETTE1,A6
                LEA     pal1,A5
                BSR     FADE_DOWN2
                BSR     vsync
                MOVEQ   #15,D7
                LEA     HILFSPALETTE1,A0
                LEA     pal1,A1
COMPCOL3:       MOVE.W  (A0)+,D0
                AND.W   #$0777,D0
                MOVE.W  (A1)+,D1
                AND.W   #$0777,D1
                CMP.W   D0,D1
                BNE.S   FADEDOWN2
                DBRA    D7,COMPCOL3
                RTS

FADEUP:
; blendet Farbpalette hoch

                LEA     HILFSPALETTE1,A6
                LEA     title+2,A5
                BSR     FADE_UP
                BSR     vsync
                BSR     vsync
                MOVEQ   #15,D7
                LEA     title+2,A1
                LEA     HILFSPALETTE1,A0
COMPCOL:        MOVE.W  (A1)+,D0
                AND.W   #$0777,D0
                MOVE.W  (A0)+,D1
                AND.W   #$0777,D1
                CMP.W   D0,D1
                BNE.S   FADEUP
                DBRA    D7,COMPCOL
                RTS

FADEDOWN_2:     LEA     HILFSPALETTE1,A6
                BSR     XFADE_DOWN
                BSR     vsync
                MOVEQ   #15,D7
                LEA     HILFSPALETTE1,A0
COUNT0COLX:     MOVE.W  (A0)+,D0
                AND.W   #$0777,D0
                BNE.S   FADEDOWN_2
                DBRA    D7,COUNT0COLX
                RTS
                ENDPART
**********************************************************
                >PART ' FADERS '
FADE_UP2:       MOVEQ   #15,D7          ; blendet auf Weiss hoch
FUL0:           MOVE.W  (A6),D0
                AND.W   #%111,D0
                MOVEQ   #7,D1
                CMP.W   D0,D1
                BEQ.S   FCOL2
                ADDQ.W  #1,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111111111000,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   FCOLOK
FCOL2:          MOVE.W  (A6),D0
                AND.W   #%1110000,D0
                MOVE.W  #$70,D1
                CMP.W   D0,D1
                BEQ.S   FCOL3
                ADD.W   #$10,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111110001111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   FCOLOK
FCOL3:          MOVE.W  (A6),D0
                AND.W   #%11100000000,D0
                MOVE.W  #$0700,D1
                CMP.W   D0,D1
                BEQ.S   FCOLOK
                ADD.W   #$0100,D0
                MOVE.W  (A6),D1
                AND.W   #%1111100011111111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
FCOLOK:         LEA     2(A6),A6
                LEA     2(A5),A5
                DBRA    D7,FUL0
                RTS

FADE_UP:        MOVEQ   #15,D7
FUL01:          MOVE.W  (A6),D0
                AND.W   #%111,D0
                MOVE.W  (A5),D1
                AND.W   #%111,D1
                CMP.W   D0,D1
                BEQ.S   FCOL21
                ADDQ.W  #1,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111111111000,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   FCOLOK1
FCOL21:         MOVE.W  (A6),D0
                AND.W   #%1110000,D0
                MOVE.W  (A5),D1
                AND.W   #%1110000,D1
                CMP.W   D0,D1
                BEQ.S   FCOL31
                ADD.W   #$10,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111110001111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   FCOLOK1
FCOL31:         MOVE.W  (A6),D0
                AND.W   #%11100000000,D0
                MOVE.W  (A5),D1
                AND.W   #%11100000000,D1
                CMP.W   D0,D1
                BEQ.S   FCOLOK1
                ADD.W   #$0100,D0
                MOVE.W  (A6),D1
                AND.W   #%1111100011111111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
FCOLOK1:        LEA     2(A6),A6
                LEA     2(A5),A5
                DBRA    D7,FUL01
                RTS

FADE_DOWN2:     MOVEQ   #15,D7
FUL012:         MOVE.W  (A6),D0
                AND.W   #%111,D0
                MOVE.W  (A5),D1
                AND.W   #%111,D1
                CMP.W   D0,D1
                BEQ.S   FCOL212
                SUBQ.W  #1,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111111111000,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   FCOLOK12
FCOL212:        MOVE.W  (A6),D0
                AND.W   #%1110000,D0
                MOVE.W  (A5),D1
                AND.W   #%1110000,D1
                CMP.W   D0,D1
                BEQ.S   FCOL312
                SUB.W   #$10,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111110001111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   FCOLOK12
FCOL312:        MOVE.W  (A6),D0
                AND.W   #%11100000000,D0
                MOVE.W  (A5),D1
                AND.W   #%11100000000,D1
                CMP.W   D0,D1
                BEQ.S   FCOLOK12
                SUB.W   #$0100,D0
                MOVE.W  (A6),D1
                AND.W   #%1111100011111111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
FCOLOK12:       LEA     2(A6),A6
                LEA     2(A5),A5
                DBRA    D7,FUL012
                RTS
FADEDWN:        MOVEQ   #15,D7
FDL0:           MOVE.W  (A6),D0
                AND.W   #%111,D0
                BEQ.S   COL2
                SUBQ.W  #1,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111111111000,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   COLOK
COL2:           MOVE.W  (A6),D0
                AND.W   #%1110000,D0
                BEQ.S   COL3
                SUB.W   #$10,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111110001111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   COLOK
COL3:           MOVE.W  (A6),D0
                AND.W   #%11100000000,D0
                BEQ.S   COLOK
                SUB.W   #$0100,D0
                MOVE.W  (A6),D1
                AND.W   #%1111100011111111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
COLOK:          LEA     2(A6),A6
                DBRA    D7,FDL0
                RTS
XFADE_DOWN:     MOVEQ   #15,D2          ; 8 Farben
XFDL0:          MOVE.W  (A6),D0
                AND.W   #%111,D0
                BEQ.S   XCOL2
                SUBQ.W  #1,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111111111000,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   XCOLOK
XCOL2:          MOVE.W  (A6),D0
                AND.W   #%1110000,D0
                BEQ.S   XCOL3
                SUB.W   #$10,D0
                MOVE.W  (A6),D1
                AND.W   #%1111111110001111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
                BRA.S   XCOLOK
XCOL3:          MOVE.W  (A6),D0
                AND.W   #%11100000000,D0
                BEQ.S   XCOLOK
                SUB.W   #$0100,D0
                MOVE.W  (A6),D1
                AND.W   #%1111100011111111,D1
                OR.W    D0,D1
                MOVE.W  D1,(A6)
XCOLOK:         LEA     2(A6),A6
                DBRA    D2,XFDL0
                RTS

                ENDPART
**********************************************************
                >PART 'Faders Calls'
fade_1_vbl:     MOVE.W  col_8240,$FFFF8240.w
sync:           ADDQ.B  #1,sync_count
                BRA.S   oldvbl1

fade_2_vbl:     MOVEM.L D0-D6/A0,reggs_ret
                MOVEM.L HILFSPALETTE1,D0-D6/A0
                MOVEM.L D0-D6/A0,$FFFF8240.w
                MOVEM.L reggs_ret,D0-D6/A0
                ADDQ.B  #1,sync_count
oldvbl1:        JMP     $12345678
                EVEN
col_8240:       DC.W $0777
                EVEN
                ENDPART
**********************************************************
                >PART 'Clear YM-2149'
clear_ym:       MOVE    SR,-(SP)
                MOVE    #$2700,SR
                BCLR    #5,$FFFFFA07.w
                BSET    #0,a_11
                BCLR    #1,a_11
                BSET    #0,b_11
                BSET    #0,c_11
                ST      a_10
                ST      b_10
                ST      c_10
                LEA     $FFFF8800.w,A0
                LEA     $FFFF8802.w,A1
                CLR.B   (A0)
                CLR.B   (A1)
                MOVE.B  #1,(A0)
                CLR.B   (A1)
                MOVE.B  #2,(A0)
                CLR.B   (A1)
                MOVE.B  #3,(A0)
                CLR.B   (A1)
                MOVE.B  #4,(A0)
                CLR.B   (A1)
                MOVE.B  #5,(A0)
                CLR.B   (A1)
                MOVE.B  #6,(A0)
                CLR.B   (A1)
                MOVE.B  #7,(A0)
                MOVE.B  (A0),D0
                ANDI.B  #$C0,D0
                ORI.B   #$3F,D0
                MOVE.B  D0,(A1)
                MOVE.B  #8,(A0)
                CLR.B   (A1)
                MOVE.B  #9,(A0)
                CLR.B   (A1)
                MOVE.B  #$0A,(A0)
                CLR.B   (A1)
                MOVE.B  #$0B,(A0)
                CLR.B   (A1)
                MOVE.B  #$0C,(A0)
                CLR.B   (A1)
                MOVE.B  #$0D,(A0)
                CLR.B   (A1)
                MOVE    (SP)+,SR
                RTS
                ENDPART
**********************************************************
                >PART 'Timer settings'
L000C:          MOVE    SR,-(SP)
                MOVE    #$2700,SR
                BSR     clear_ym
                MOVE.L  $0118.w,oldkey
                MOVE.L  $0120.w,oldhbl
                MOVE.L  #key_vec,$0118.w
                MOVE.L  $70.w,oldvbl
                MOVE.L  $0110.w,old110
                MOVE.L  #vbl,$70.w

                MOVE.L  #new_timer,$0134.w

                MOVE.L  #new_timer_a,$0120.w
                ANDI.B  #$F0,$FFFFFA1D.w
                ORI.B   #1,$FFFFFA1D.w
                CLR.B   $FFFFFA25.w
                BSET    #4,$FFFFFA15.w
                BCLR    #4,$FFFFFA09.w

                MOVE.L  #new_timer_c,$0110.w

                CLR.B   $FFFFFA1F.w
                MOVE.B  #1,$FFFFFA1F.w
                CLR.B   $FFFFFA19.w

                CLR.B   $FFFFFA1B.w
                MOVE.B  #1,$FFFFFA1B.w
                CLR.B   $FFFFFA21.w

                BSET    #5,$FFFFFA13.w
                BCLR    #5,$FFFFFA07.w

                BSET    #0,$FFFFFA13.w
                BCLR    #0,$FFFFFA07.w

                BCLR    #5,$FFFFFA09.w

                CLR.B   X_MOUSE_REL
                CLR.B   Y_MOUSE_REL
                CLR.B   X_MOUSE_POS
                CLR.B   x0201
                CLR.B   x0201_c
                CLR.B   x0201_a
                CLR.W   L0369
                MOVE    (SP)+,SR
                RTS

L000D:          MOVE    SR,-(SP)
                MOVE    #$2700,SR
                BCLR    #4,$FFFFFA09.w
                BCLR    #5,$FFFFFA07.w  ;05F9
                BCLR    #5,$FFFFFA0B.w  ;05F5
                BCLR    #5,$FFFFFA0F.w  ;05F1
                BCLR    #4,$FFFFFA11.w
                BCLR    #0,$FFFFFA0F.w  ;05F1
                BSET    #5,$FFFFFA09.w  ;05F7
                BCLR    #0,$FFFFFA07.w
                BCLR    #0,$FFFFFA13.w
                MOVE.L  oldhbl,$0120.w
                MOVE.L  oldkey,$0118.w
                MOVE.L  oldvbl,$70.w
                BSR     clear_ym
                MOVE    (SP)+,SR
                RTS

L000E:          MOVE    SR,-(SP)
                MOVE    #$2700,SR

                BCLR    #0,$FFFFFA07.w
                BCLR    #0,$FFFFFA0F.w  ;05F1
                BSET    #5,$FFFFFA09.w  ;05F7
                MOVE.L  oldkey,$0118.w
                MOVE.L  oldvbl,$70.w
                MOVE    (SP)+,SR
                RTS

L000F:          MOVE    SR,-(SP)
                MOVE    #$2700,SR
                MOVE.L  $0118,oldkey
                MOVE.L  #key_vec,$0118.w
                MOVE.L  $70.w,oldvbl
                MOVE.L  #vbl,$70.w
                MOVE.L  #new_timer,$0134.w

                MOVE.L  #new_timer_a,$0120.w
                ANDI.B  #$F0,$FFFFFA1D.w
                ORI.B   #1,$FFFFFA1D.w
                CLR.B   $FFFFFA25.w
                BSET    #4,$FFFFFA15.w

                BCLR    #4,$FFFFFA09.w

                BSET    #5,$FFFFFA13.w
                BCLR    #5,$FFFFFA07.w

                BCLR    #0,$FFFFFA07.w
                BSET    #0,$FFFFFA13.w

                MOVE.L  #new_timer_c,$0110.w

                BCLR    #5,$FFFFFA09.w  ;05F7
                CLR.B   X_MOUSE_REL
                CLR.B   Y_MOUSE_REL
                CLR.B   X_MOUSE_POS
                CLR.B   x0201
                CLR.B   x0201_c
                CLR.B   x0201_a
                CLR.W   L0369
                MOVE    (SP)+,SR
                RTS
                ENDPART
**********************************************************
                >PART 'Player init'
L0010:          MOVE    SR,-(SP)
                MOVE    #$2700,SR
                MOVE.W  #1,L03DF
                MOVE.W  #$1F,D0
                LEA     L03E1,A0
                LEA     L03C0,A1

L0011:          MOVE.L  A0,(A1)+
                ADDA.L  #$0300,A0
                DBRA    D0,L0011
                MOVE.W  #1,L03B2
                CLR.W   song_position
                MOVE.L  #L03E1,L03C3
                MOVE.L  #L03E1,act_pat_adr
                MOVE.L  #L03C5,L03C4
                MOVE.L  #L03C7,L03C6
                MOVE.L  #L03C9,L03C8
                MOVE.W  #1,L03BC
                MOVE.B  #$0F,volume
                CLR.B   a_9
                MOVE.L  #L03CB,a_1
                MOVE.W  #2,a_2
                MOVE.W  #5,a_3
                MOVE.W  #9,a_4
                MOVE.L  #L03CB,a_5
                MOVE.W  #2,a_6
                MOVE.W  #5,a_7
                MOVE.W  #9,a_8
                CLR.B   b_9
                MOVE.L  #L03CB,b_1
                MOVE.W  #2,b_2
                MOVE.W  #5,b_3
                MOVE.W  #9,b_4
                MOVE.L  #L03CB,b_5
                MOVE.W  #2,b_6
                MOVE.W  #5,b_7
                MOVE.W  #9,b_8
                CLR.B   c_9
                MOVE.L  #L03CB,c_1
                MOVE.W  #2,c_2
                MOVE.W  #5,c_3
                MOVE.W  #9,c_4
                MOVE.L  #L03CB,c_5
                MOVE.W  #2,c_6
                MOVE.W  #5,c_7
                MOVE.W  #9,c_8
                MOVE    (SP)+,SR
                RTS
                EVEN
intern_x:       DC.B 0
************************************* Ab hier VBL REPLAY
                EVEN
L0012:          MOVE    #$2700,SR
                MOVE.B  #$0E,$FFFF8800.w
                MOVE.B  $FFFF8800.w,D0
                BSET    #1,D0
                MOVE.B  D0,$FFFF8802.w
                MOVE    #$2300,SR

L0013:
                MOVE.W  text_xpos,D0
                MOVE.W  text_ypos,D1
                MOVEM.W D0-D1,-(SP)
                MOVEM.L D0-A6,-(SP)
                ADDQ.B  #1,intern_x
                CMPI.B  #50,intern_x
                BLT.S   keine_sekunde
                BSR     clock
                MOVE.B  #0,intern_x
keine_sekunde:  BSR     show_clock
                MOVEM.L (SP)+,D0-A6
                MOVEM.W (SP)+,D0-D1
                MOVE.W  D0,text_xpos
                MOVE.W  D1,text_ypos

                TST.B   L03B7
                BNE     L0021
                MOVE.W  what_function,D1
                BNE     L0014
                MOVEA.L act_pat_adr,A1
                MOVE.W  pos_in_pat,D0
                MULU    #$0C,D0
                ADDA.W  D0,A1
                MOVE.L  A1,L03C3
                TST.B   L0376
                BEQ     L0021
                MOVE.W  pos_in_pat,D0
                ADD.W   L03BC,D0
*************************************
                ANDI.W  #lv,D0
*************************************
                MOVE.W  D0,pos_in_pat
                ST      L0371
                CLR.B   L0376
                BRA     L001A
L0014:          CMPI.W  #6,D1
                BNE.S   L0016
                LEA     L03CA,A1
                MOVE.L  A1,L03C3
                TST.B   recording_flag
                BNE.S   L0015
                CLR.L   (A1)
                CLR.L   4(A1)
                CLR.L   8(A1)
                LEA     bdata,A0
                ADDQ.L  #4,A1
                BSR     L0054
L0015:          BRA     L001A
L0016:          SUBQ.W  #1,L03B2
                BNE     L0021
                MOVE.W  L03DC,L03B2
                MOVEA.L act_pat_adr,A1
                MOVE.W  pos_in_pat,D0
                MULU    #$0C,D0
                ADDA.W  D0,A1
                MOVE.L  A1,L03C3
                TST.B   L0373
                BNE     no_recording
                MOVE.W  what_function,D0
                BEQ.S   L0017
                CMPI.W  #3,D0
                BCC.S   L0017
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                LEA     L03C7,A3
                LEA     L03C5,A4
                MOVE.L  (A2),(A0)+
                MOVE.L  4(A2),(A0)+
                MOVE.L  8(A2),(A0)+
                MOVE.L  (A3),(A2)
                MOVE.L  4(A3),4(A2)
                MOVE.L  8(A3),8(A2)
                MOVE.L  (A4),(A3)
                MOVE.L  4(A4),4(A3)
                MOVE.L  8(A4),8(A3)
                MOVE.L  (A1),(A4)+
                MOVE.L  4(A1),(A4)+
                MOVE.L  8(A1),(A4)+
                MOVE.L  L03C6,L03C8
                MOVE.L  L03C4,L03C6
                MOVE.L  A1,L03C4

L0017:          TST.B   recording_flag
                BNE.S   no_recording


                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                ADDA.L  0(A2,D0.w),A1
                LEA     L02A8,A2
                MOVEA.L 0(A2,D0.w),A0
                LEA     L02A5,A2
                MOVEA.L 0(A2,D0.w),A2
                JSR     (A2)

                ENDPART
**********************************************************
                >PART 'VBL Replayer'

no_recording:   TST.W   break_cmd
                BPL.S   okay_no_break
                MOVEQ   #lv+2,D0
                CLR.W   break_cmd
                BRA.S   check_dis
okay_no_break:  ADDQ.W  #1,pos_in_pat
                MOVE.W  pos_in_pat,D0
check_dis:      CMPI.W  #lv+1,D0
                BLT.S   L0019
                BSR     L0227
L0019:          ST      L0371
L001A:          CLR.B   L0376

                MOVEA.L L03C3,A1

                LEA     adata,A0
                BSR     getnote
                LEA     bdata,A0
                BSR     getnote
                LEA     cdata,A0
                BSR     getnote
L0021:

* Strenger Sound
                MOVEA.W #$8800,A5

                LEA     bdata,A0
                BSR     check_rept
                BSR     do_all
                LEA     cdata,A0
                BSR     check_rept
                BSR     do_all
                LEA     adata,A0
                BSR     check_rept
                BSR     do_all

                MOVE    SR,-(SP)
                ORI     #$0700,SR
                ENDPART
**********************************************************
                >PART 'SID Channle A'
                LEA     adata,A0

                TST.B   hardw_buzz(A0)
                BNE.S   no_wow_a

                TST.W   sid_a
                BPL.S   no_wow_a

                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   no_wow_a
                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   no_wow_a

                LEA     wave_form1,A6
                MOVE.W  0(A0),D1

scan_more_a:    TST.W   (A6)
                BMI.S   no_wow_a
                CMP.W   (A6)+,D1
                BLT.S   do_tfm_a
                ADDQ.L  #4,A6
                BRA.S   scan_more_a

do_tfm_a:       MOVE.W  (A6)+,D2
                MOVE.W  (A6)+,D3
                MOVE.L  #$01900000,D0
                MULU    #$A3,D2
                DIVU    D2,D0
                MULU    D1,D0

                TST.W   dual_a
                BNE.S   nix_dual_a
                ADDI.L  #$2000,D0
nix_dual_a:     ADDI.L  #$2000,D0
                ADD.L   D0,D0
                ADD.L   D0,D0
                SWAP    D0

                MOVE.B  volume_(A0),x0201_a

                MOVE.B  D0,$FFFFFA21.w
                MOVE.B  D3,$FFFFFA1B.w
                BSET    #0,$FFFFFA07.w

                BRA.S   wow_a
no_wow_a:       BCLR    #0,$FFFFFA07.w  ;#4,$fa09.w

                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   wow_a
                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   wow_a

                BCLR    #0,instr_type(A0)
wow_a:
                ENDPART
**********************************************************
                >PART 'SID Channle B'
                LEA     bdata,A0
                TST.B   hardw_buzz(A0)
                BNE.S   no_wow

                TST.W   sid_b
                BPL.S   no_wow

                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   no_wow
                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   no_wow

what_wave:      LEA     wave_form1,A6
                MOVE.W  0(A0),D1

scan_more:      TST.W   (A6)
                BMI.S   no_wow
                CMP.W   (A6)+,D1
                BLT.S   do_tfm
                ADDQ.L  #4,A6
                BRA.S   scan_more

do_tfm:         MOVE.W  (A6)+,D2
                MOVE.W  (A6)+,D3
                MOVE.L  #$01900000,D0
                MULU    #$A3,D2
                DIVU    D2,D0
                MULU    D1,D0

                CMPI.W  #-1,dual_b
                BNE.S   nix_dual_b
                ADDI.L  #$2000,D0
nix_dual_b:     ADDI.L  #$2000,D0
                LSL.L   #2,D0
                SWAP    D0

                MOVE.B  volume_(A0),x0201

                MOVE.B  D0,$FFFFFA1F.w
                MOVE.B  D3,$FFFFFA19.w
                BSET    #5,$FFFFFA07.w
                BRA.S   wow
no_wow:         BCLR    #5,$FFFFFA07.w

                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   wow
                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   wow
                BCLR    #0,instr_type(A0)
wow:
                ENDPART
**********************************************************
                >PART 'SID Channle C'
                LEA     cdata,A0

                TST.B   hardw_buzz(A0)
                BNE.S   no_wow_c

                TST.W   sid_c
                BPL.S   no_wow_c

                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   no_wow_c
                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   no_wow_c

                LEA     wave_form1(PC),A6
                MOVE.W  0(A0),D1

scan_more_c:    TST.W   (A6)
                BMI.S   no_wow_c
                CMP.W   (A6)+,D1
                BLT.S   do_tfm_c
                ADDQ.L  #4,A6
                BRA.S   scan_more_c

do_tfm_c:       MOVE.W  (A6)+,D2
                MOVE.W  (A6)+,D3
                MOVE.L  #$01900000,D0
                MULU    #$A3,D2
                DIVU    D2,D0
                MULU    D1,D0

                TST.W   dual_c
                BNE.S   nix_dual_c
                ADDI.L  #$2000,D0
nix_dual_c:     ADDI.L  #$2000,D0
                LSL.L   #2,D0
                SWAP    D0

                MOVE.B  volume_(A0),x0201_c

                ANDI.B  #$F0,$FFFFFA1D.w
                OR.B    D3,$FFFFFA1D.w
                MOVE.B  D0,$FFFFFA25.w
                BSET    #4,$FFFFFA09.w

                BRA.S   wow_c
no_wow_c:       BCLR    #4,$FFFFFA09.w  ; #0,$fa07.w

                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   wow_c
                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   wow_c
                BCLR    #0,instr_type(A0)
wow_c:
                ENDPART
**********************************************************
                >PART 'Rest of VBL Replay'
                MOVE    (SP)+,SR
***************************************************************
                MOVE.B  #$FF,D0

                LEA     cdata,A0
                MOVEQ   #2,D6
                MOVEQ   #5,D7
                BSR     rest_control
                LEA     bdata,A0
                MOVEQ   #1,D6
                MOVEQ   #4,D7
                BSR     rest_control
                LEA     adata,A0
                BTST    #1,hardw_buzz(A0)
                BNE.S   no_nois_a
                MOVEQ   #0,D6
                MOVEQ   #3,D7
                BSR     rest_control

no_nois_a:      MOVE.W  #$0700,D7
                MOVE.B  D0,D7
                MOVEP.W D7,0(A5)
                MOVEA.W #$8800,A1
                MOVEA.W #$8802,A2

                LEA     adata,A0
                BTST    #1,hardw_buzz(A0)
                BNE.S   do_nout_a
                MOVE.W  0(A0),D0
                MOVE.B  0(A0),D1
                MOVEQ   #0,D7
                MOVE.B  D0,D7
                MOVEP.W D7,0(A5)
                MOVE.W  #$0100,D7
                MOVE.B  D1,D7
                MOVEP.W D7,0(A5)
                TST.B   hardw_buzz(A0)
                BNE.S   no_hardw_auto_a
                TST.B   extend_buzz(A0)
                BEQ.S   no_hardw_auto_a
                BTST    #2,instr_type(A0)
                BEQ.S   no_hardw_auto_a
                BTST    #3,instr_type(A0)
                BEQ.S   no_hardw_auto_a
                LSR.W   #4,D0
                MOVE.W  #$0B00,D7
                MOVE.B  D0,D7
                MOVEP.W D7,0(A5)
                MOVE.W  #$0C00,D7
                MOVEP.W D7,0(A5)

no_hardw_auto_a:TST.W   sid_a
                BPL.S   okay_a

                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   okay_a
                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   okay_a
                BRA.S   do_nout_a

okay_a:         MOVE.W  #$0800,D7
                MOVE.B  volume_(A0),D7
                MOVEP.W D7,0(A5)

do_nout_a:      LEA     bdata,A0
                MOVE.W  0(A0),D0
                MOVE.B  0(A0),D1
                MOVE.W  #$0200,D7
                MOVE.B  D0,D7
                MOVEP.W D7,0(A5)
                MOVE.W  #$0300,D7
                MOVE.B  D1,D7
                MOVEP.W D7,0(A5)
                TST.B   hardw_buzz(A0)
                BNE.S   no_hardw_auto_b
                TST.B   extend_buzz(A0)
                BEQ.S   no_hardw_auto_b
                BTST    #2,instr_type(A0)
                BEQ.S   no_hardw_auto_b
                BTST    #3,instr_type(A0)
                BEQ.S   no_hardw_auto_b
                LSR.W   #4,D0
                MOVE.W  #$0B00,D7
                MOVE.B  D0,D7
                MOVEP.W D7,0(A5)
                MOVE.W  #$0C00,D7
                MOVEP.W D7,0(A5)

no_hardw_auto_b:
                TST.W   sid_b
                BPL.S   okay_b

                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   okay_b
                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   okay_b
                BRA.S   no_b

okay_b:         MOVE.W  #$0900,D7
                MOVE.B  volume_(A0),D7
                MOVEP.W D7,0(A5)

no_b:           LEA     cdata,A0
                MOVE.W  0(A0),D0
                MOVE.B  0(A0),D1
                MOVE.W  #$0400,D7
                MOVE.B  D0,D7
                MOVEP.W D7,0(A5)
                MOVE.W  #$0500,D7
                MOVE.B  D1,D7
                MOVEP.W D7,0(A5)
                TST.B   hardw_buzz(A0)
                BNE.S   no_hardw_auto_c
                TST.B   extend_buzz(A0)
                BEQ.S   no_hardw_auto_c
                BTST    #2,instr_type(A0)
                BEQ.S   no_hardw_auto_c
                BTST    #3,instr_type(A0)
                BEQ.S   no_hardw_auto_c
                LSR.W   #4,D0
                MOVE.W  #$0B00,D7
                MOVE.B  D0,D7
                MOVEP.W D7,0(A5)
                MOVE.W  #$0C00,D7
                MOVEP.W D7,0(A5)

no_hardw_auto_c:TST.W   sid_c
                BPL.S   okay_c

                CMPI.B  #3,tfmx_effect(A0)
                BLT.S   okay_c
                CMPI.B  #5,tfmx_effect(A0)
                BGT.S   okay_c
                BRA.S   no_c

okay_c:         MOVE.W  #$0A00,D7
                MOVE.B  volume_(A0),D7
                MOVEP.W D7,0(A5)

no_c:
**************************************
*                MOVEM.L (SP)+,D0-A6
* Testabfrage hier
                TST.B   info_page_flag  ; Kein SID-Spektrum auf der Info-Tafel
                BNE.S   go_on
                TST.B   synth_flag
                BNE.S   go_on
                BSR     do_samplespektrum

go_on:          TST.B   ste_page
                BEQ.S   go_on_2
                BSR     STE_DIGI_SET

go_on_2:        TST.B   song_edit_flag
                BNE.S   L0027

                TST.B   L0370
                BNE.S   L0026

                BSR     VOLU_BARS
*                BSR     sample_spektr   ; SAM-Spectr.

L0026:          TST.B   L0371
                BEQ     L0027

                BSR     INSTR_TXT_SET

                CLR.B   L0371

L0027:          TST.B   info_page_flag
                BEQ.S   L0028
                BSR     info_activity
L0028:          RTS

getnote:        TST.B   (A1)
                BEQ     test_env
                BMI     digi_
                MOVE.B  2(A1),D1
                CMPI.B  #$3F,D1
                BHI     same_instr
                MOVE.B  D1,$39(A0)      ; Instrument Nr. in $39
                CLR.B   $38(A0)
                CLR.B   $4C(A0)
                CLR.B   $4D(A0)
                LEA     spec_table,A6
                CLR.W   D0
                MOVE.B  $39(A0),D0      ;
                ADD.W   D0,D0           ; 1 Long fr 1 Instrument (ext.Info)
                ADD.W   D0,D0
                MOVE.L  0(A6,D0.w),D0   ;
                MOVE.L  D0,$3C(A0)      ; Aktuelles Instrument
                LSR.L   #8,D0           ; *256 ( Instrument Adresse !!! )
                TST.B   D0              ; negativ ??
                BEQ.S   no_wave_control ; Dann keine Waveform

                CMPI.B  #$10,$3E(A0)    ; Double Instrument replay (2*im VBL)
                BNE.S   go_on_wave
                MOVEQ   #0,D0           ; Normale Wave
go_on_wave:     LEA     wave_table(PC),A6
                CLR.W   D1
                MOVE.B  D0,D1
                SUBQ.B  #1,D1
                ADD.W   D1,D1
                ADD.W   D1,D1
                MOVE.L  0(A6,D1.w),extend_wave_adr(A0) ; Adresse der Wave
no_wave_control:LSR.L   #8,D0
                TST.B   D0
                BEQ.S   no_tone_control
                LEA     tone_table(PC),A6
                CLR.W   D1
                MOVE.B  D0,D1
                SUBQ.B  #1,D1
                ADD.W   D1,D1
                ADD.W   D1,D1
                MOVE.L  0(A6,D1.w),extend_tone_adr(A0) ; Toneadresse
no_tone_control:LSR.W   #8,D0
                TST.B   D0
                BEQ.S   no_noise_control
                LEA     nois_table(PC),A6
                CLR.W   D1
                MOVE.B  D0,D1
                SUBQ.W  #1,D1
                ADD.W   D1,D1
                ADD.W   D1,D1
                MOVE.L  0(A6,D1.w),extend_noiz_adr(A0)

no_noise_control:MOVE.B $39(A0),D1
                ANDI.W  #$3F,D1

                LEA     instr_datas,A2
                ASL.W   #8,D1
                ADDA.W  D1,A2
                MOVE.W  0(A2),D0
                MOVE.W  D0,$2A(A0)
                MOVE.B  2(A2),instr_type(A0)
                MOVE.W  4(A2),$2E(A0)
                MOVE.B  3(A2),$2D(A0)
                MOVE.W  6(A2),$0A(A0)
                MOVE.W  8(A2),$0C(A0)
                MOVE.W  $FC(A2),$30(A0)
                MOVE.W  $FE(A2),$32(A0)
                CLR.W   $14(A0)
                MOVE.W  $0A(A2),$16(A0)
                MOVE.W  $0C(A2),$18(A0)
                MOVE.W  $0E(A2),$1A(A0)
                LEA     $10(A2),A3
                MOVE.L  A3,$10(A0)
                CLR.W   $20(A0)
                MOVE.W  $F0(A2),$22(A0)
                MOVE.W  $F2(A2),$24(A0)
                MOVE.W  $F4(A2),$26(A0)
                LEA     $80(A2),A3
                MOVE.L  A3,$1C(A0)
                ST      $28(A0)
                MOVEQ   #0,D0
                MOVE.B  (A1),D0
                MOVE.W  D0,D1
                LSR.W   #4,D1
                CMPA.L  #bdata,A0
                BNE.S   bw
                MOVE.W  D1,tfmx_oct
bw:             LEA     note_2_freq(PC),A2
                ANDI.W  #$0F,D0
                CMPA.L  #bdata,A0
                BNE.S   bs
                MOVE.W  D0,tfmx_note
bs:             MOVE.W  D0,D2
                ASL.W   #1,D2
                MOVE.W  0(A2,D2.w),D2
                LSR.W   D1,D2
                MOVE.W  D2,2(A0)
                MOVE.W  D0,D3
                ADD.W   $30(A0),D3
                ASL.W   #1,D3
                MOVE.W  0(A2,D3.w),D3
                LSR.W   D1,D3
                SUB.W   D2,D3
                MOVE.W  D3,$34(A0)
                ADD.W   $32(A0),D0
                ASL.W   #1,D0
                MOVE.W  0(A2,D0.w),D0
                LSR.W   D1,D0
                SUB.W   D2,D0
                MOVE.W  D0,$36(A0)
same_instr:     MOVE.B  1(A1),D1
                BEQ.S   no_calc_tie
                SUB.W   4(A0),D2
                EXT.L   D2
                ANDI.L  #$FF,D1
                MULS    L03DC,D1
                DIVS    D1,D2
                BEQ.S   no_calc_tie
                MOVE.W  D2,6(A0)
                BRA.S   yes_calc_tie
no_calc_tie:    MOVE.W  2(A0),4(A0)
                CLR.W   6(A0)
yes_calc_tie:   MOVE.B  3(A1),D0
                ANDI.W  #$1F,D0
                MOVE.B  D0,$0F(A0)
test_env:       ADDQ.L  #3,A1
                MOVE.B  (A1)+,D1
                LSR.B   #6,D1
                TST.B   D1
                BEQ.S   same_env
                BTST    #2,instr_type(A0)
                BNE.S   he_adsr
                CMPI.B  #1,D1
                BEQ.S   attack_env
                CMPI.B  #2,D1
                BEQ.S   sustain_env
                MOVE.W  $18(A0),$14(A0)
                MOVE.W  $24(A0),$20(A0)
                BCLR    #0,hardw_buzz(A0)
                ST      $28(A0)
                RTS
sustain_env:    MOVE.W  $16(A0),$14(A0)
                MOVE.W  $22(A0),$20(A0)
                BCLR    #0,hardw_buzz(A0)
                ST      $28(A0)
                RTS
attack_env:     CLR.W   $14(A0)
                CLR.W   $20(A0)
                CLR.W   8(A0)
                BCLR    #0,hardw_buzz(A0)
                ST      $28(A0)
                BCLR    #1,hardw_buzz(A0)
same_env:       RTS
he_adsr:        TST.B   D1
                BEQ.S   cont_he
                CMPI.B  #2,D1
                BEQ.S   sustain_he
                CMPI.B  #3,D1
                BEQ     release_he
                MOVE    #$2700,SR
                BTST    #3,instr_type(A0)
                BNE.S   attack_hardw_aut
                MOVE.B  #$0B,$FFFF8800.w
                MOVE.B  $2F(A0),$FFFF8802.w
                MOVE.B  #$0C,$FFFF8800.w
                MOVE.B  $2E(A0),$FFFF8802.w
attack_hardw_aut:MOVE.B #$0D,$FFFF8800.w
                BTST    #0,$2D(A0)
                BNE.S   yes_hardw_type
                MOVE.B  $FFFF8800.w,D0
                CMP.B   $2D(A0),D0
                BEQ.S   no_hardw_type
yes_hardw_type: MOVE.B  $2D(A0),$FFFF8802.w
no_hardw_type:  CLR.W   8(A0)
                CLR.W   $20(A0)
                ST      $28(A0)
                BCLR    #0,hardw_buzz(A0)
                BCLR    #1,hardw_buzz(A0)
                BEQ.S   same_he
                BCLR    #5,$FFFFFA07.w
                BCLR    #0,$FFFFFA07.w
same_he:        MOVE    #$2300,SR
cont_he:        RTS
sustain_he:     MOVE    #$2700,SR
                BTST    #3,instr_type(A0)
                BNE.S   sustain_hardw_au
                MOVE.B  #$0B,$FFFF8800.w
                MOVE.B  $2F(A0),$FFFF8802.w
                MOVE.B  #$0C,$FFFF8800.w
                MOVE.B  $2E(A0),$FFFF8802.w
sustain_hardw_au:
                MOVE.B  #$0D,$FFFF8800.w
                BTST    #0,$2D(A0)
                BNE.S   yes_sus_htype
                MOVE.B  $FFFF8800.w,D0
                CMP.B   $2D(A0),D0
                BEQ.S   no_sus_htype
yes_sus_htype:  MOVE.B  $2D(A0),$FFFF8802.w
no_sus_htype:   CLR.W   8(A0)
                MOVE.W  $22(A0),$20(A0)
                ST      $28(A0)
                BCLR    #0,hardw_buzz(A0)
                BCLR    #1,hardw_buzz(A0)
                BEQ.S   same_sus_he
                BCLR    #5,$FFFFFA07.w
                BCLR    #0,$FFFFFA07.w
same_sus_he:    MOVE    #$2300,SR
                RTS
release_he:     BSET    #0,hardw_buzz(A0)
                RTS

*****************************************************************************
digi_:          BTST    #2,hardw_buzz(A0)
                BNE     L0052

                CMPI.B  #$0E,2(A1)
                BNE.S   test_2
                MOVE.W  #-1,break_cmd
                BRA.S   oka

test_2:         CMPI.B  #$0F,2(A1)      ; Bei Sample Nr.$f
                BNE.S   oka             ; Infobyte als SPEED BYTE anerkennen
                MOVE.W  #-1,what
oka:
                MOVE.B  2(A1),D0        ; Sam.Nr (0-f)
                ANDI.W  #$0F,D0
                LEA     L03D2,A2
                ASL.W   #2,D0
                BEQ.S   okay_
                BRA     no_

                ANDI.B  #$F0,$FFFFFA1D.w
                ORI.B   #1,$FFFFFA1D.w
                CLR.B   $FFFFFA25.w
                MOVE.L  #new_timer_a,$0110.w
                MOVE.B  #-1,digi_spielt

okay_:          MOVE.L  0(A2,D0.w),L007D
                MOVE.B  1(A1),D0        ; Hertz (5-f)
                ANDI.W  #$0F,D0
                LEA     hertz,A2
                MOVE.B  0(A2,D0.w),$FFFFFA25.w
                MOVE.B  #2,hardw_buzz(A0)
                BSET    #4,$FFFFFA09.w
                TST.B   L0373
                BNE.S   L0051
                MOVE.B  #$0E,$FFFF8800.w
                MOVE.B  $FFFF8800.w,D0
                BCLR    #1,D0
                MOVE.B  D0,$FFFF8802.w
L0051:
no_:
*                MOVE    #$2300,SR
                TST.W   what
                BMI.S   only_speed
                MOVEQ   #0,D0
                MOVE.B  3(A1),D0        ;Info Byte holen
                EXT.W   D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                MOVEA.L rout_tab(PC,D0.w),A6 ; und verzweigen
                JSR     (A6)
L0052:          ADDQ.L  #4,A1
                RTS

only_speed:     MOVE.B  3(A1),D0        ; Bei Sample Nummer $f ist das
                EXT.W   D0
                MOVE.W  D0,L03DC
                ADDQ.L  #4,A1
                CLR.W   what
                RTS
                EVEN

rout_tab:       DC.L ertes      ;           0
                DC.L sid_dual_on_b ; 1
                DC.L sid_dual_off_b ; 2
                DC.L ertes      ;sid_dual_on_c_ ; 3
                DC.L sid_on_a   ;           4
                DC.L sid_off_a  ;           5
                DC.L sid_on_b   ;           6
                DC.L sid_off_b  ;           7
                DC.L sid_on_c   ;           8
                DC.L sid_off_c  ;    9
                DC.L do_wave_1  ;    a
                DC.L do_wave_2  ;    b
                DC.L do_wave_3  ;    c
                DC.L reset_all  ;    d
                DC.L ertes      ;    e
                DC.L ertes      ;    f
                EVEN

L0053:          TST.B   L03B5
                BEQ     L0064
L0054:          TST.B   L035C
                BNE     L005C
                LEA     L029F,A2
                MOVEQ   #0,D7
                MOVE.B  L0357,D7
                BEQ     L0059
                BCLR    #7,D7
                BNE.S   L0057
                MOVE.B  0(A2,D7.w),D0
                BEQ.S   L0059
                MOVE.B  L03BB,D1
                ASL.B   #4,D1
                ADD.B   D1,D0
                MOVE.B  D0,(A1)
                MOVE.B  pat_pos_count,1(A1)
                MOVE.B  instr_num,2(A1)
                MOVE.B  volume,3(A1)
                MOVE.B  L03B6,D0
                CMPI.B  #2,D0
                BEQ.S   L0055
                ORI.B   #$40,3(A1)
                BRA.S   L0056
L0055:
                ORI.B   #$80,3(A1)
L0056:
                MOVE.B  D7,L0359
                CLR.B   L0357
                RTS
L0057:
                TST.B   L03B6
                BNE.S   L0058
                LEA     L029F,A0
                TST.B   0(A0,D7.w)
                BEQ.S   L0058
                MOVE.L  #$C0,(A1)
L0058:
                CLR.B   L0359
                CLR.B   L0357
                RTS
L0059:
                MOVEQ   #0,D0
                MOVE.B  L0356,D0
                BEQ.S   L005A
                CMPI.B  #$39,D0
                BEQ.S   L005B
                TST.B   L03B6
                BNE.S   L005A
                LEA     L029F,A0
                TST.B   0(A0,D0.w)
                BEQ.S   L005A
                CLR.L   (A1)
L005A:
                CLR.B   L0357
                RTS
L005B:
                BSET    #0,hardw_buzz(A0)
                CLR.L   (A1)
                CLR.B   L0357
                RTS
L005C:
                LEA     L029E,A2
                MOVEQ   #0,D7
                MOVE.B  L035E,D7
                BEQ.S   L0062
                TST.B   L0360
                BEQ.S   L0060
                MOVE.B  0(A2,D7.w),D0
                BEQ.S   L005F
                MOVE.B  L03BB,D1
                ASL.B   #4,D1
                ADD.B   D1,D0
                BCLR    #7,D0
                MOVE.B  D0,(A1)
                MOVE.B  pat_pos_count,1(A1)
                MOVE.B  instr_num,2(A1)
                MOVE.B  volume,3(A1)
                MOVE.B  L03B6,D0
                BEQ.S   L005D
                CMPI.B  #1,D0
                BEQ.S   L005E
                ORI.B   #$80,3(A1)
                BRA.S   L005F
L005D:
                ST      L0361
L005E:
                ORI.B   #$40,3(A1)
L005F:
                CLR.B   L035E
                RTS
L0060:
                TST.B   L03B6
                BNE.S   L0061
                MOVE.L  #$C0,(A1)
L0061:
                CLR.B   L035E
                CLR.B   L0361
                RTS
L0062:
                TST.B   L0361
                BEQ.S   L0063
                CLR.L   (A1)
L0063:
                CLR.B   L035E
                RTS
L0064:
                MOVEQ   #0,D0
                MOVE.B  L0358,D0
                LEA     L029F,A2
                MOVE.B  0(A2,D0.w),D0
                BEQ.S   L0065
                LEA     L02A0,A2
                MOVE.B  0(A2,D0.w),D0
                BMI.S   L0065
                MOVE.L  #$FF000000,(A1)
                MOVE.B  D0,2(A1)
                LEA     sam_freqs,A2
                MOVE.B  0(A2,D0.w),1(A1)
                CLR.B   L0358
                RTS
L0065:
                MOVE.B  L0356,D0
                CMPI.B  #$39,D0
                BNE.S   L0066
                CLR.L   (A1)
L0066:
                CLR.B   L0358
                RTS
L0067:
                TST.B   L03B5
                BEQ     L006B
L0068:
                BSR     L0185
                TST.B   L035C
                BNE.S   L006A
                MOVEQ   #0,D7
                MOVE.B  L0356,D7
                LEA     L029F,A2
                MOVE.B  0(A2,D7.w),D0
                BEQ.S   L0069
                MOVE.B  L03BB,D1
                ASL.B   #4,D1
                ADD.B   D1,D0
                MOVE.B  D0,(A1)
                MOVE.B  pat_pos_count,1(A1)
                MOVE.B  instr_num,2(A1)
                MOVE.B  volume,3(A1)
                BSET    #6,3(A1)
                ST      L0376
L0069:
                RTS
L006A:
                LEA     L029E,A2
                MOVEQ   #0,D7
                MOVE.B  L0362,D7
                MOVE.B  0(A2,D7.w),D0
                BEQ.S   L0069
                MOVE.B  L03BB,D1
                ASL.B   #4,D1
                ADD.B   D1,D0
                BCLR    #7,D0
                MOVE.B  D0,(A1)
                MOVE.B  pat_pos_count,1(A1)
                MOVE.B  instr_num,2(A1)
                MOVE.B  volume,3(A1)
                BSET    #6,3(A1)
                ST      L0376
                RTS

L006B:          BSR     L0185
                MOVEQ   #0,D0
                MOVE.B  L0356,D0
                LEA     L029F,A2
                MOVE.B  0(A2,D0.w),D0
                BEQ.S   L0069
                LEA     L02A0,A2
                MOVE.B  0(A2,D0.w),D0
                BMI.S   L0069
                MOVE.L  #$FF000000,(A1)
                MOVE.B  D0,2(A1)
                LEA     sam_freqs,A2
                MOVE.B  0(A2,D0.w),1(A1)
                ST      L0376
                RTS

L006C:          TST.B   (A1)
                BMI.S   L006E
                BEQ.S   L006E
                MOVEQ   #0,D0
                MOVE.B  L0356,D0
                LEA     L02A1,A0
                MOVE.B  0(A0,D0.w),D0
                BMI     L0069
                CMPI.B  #7,D0
                BHI     L0069
                TST.W   what_function
                BNE.S   L006D
                BSR     L0185
L006D:
                ANDI.B  #$0F,(A1)
                ASL.B   #4,D0
                OR.B    D0,(A1)
                ST      L0376
L006E:          RTS
L006F:          MOVEQ   #0,D0
                MOVE.B  L0356,D0
                LEA     L02A1,A0
                MOVE.B  0(A0,D0.w),D0
                BMI     L0069
                CMPI.B  #3,D0
                BHI     L0069
                TST.W   what_function
                BNE.S   L0070
                BSR     L0185
L0070:
                ANDI.B  #$0F,1(A1)
                ASL.B   #4,D0
                OR.B    D0,1(A1)
                ST      L0376
                RTS
L0071:
                MOVEQ   #0,D0
                MOVE.B  L0356,D0
                LEA     L02A1,A0
                MOVE.B  0(A0,D0.w),D0
                BMI     L0069
                TST.W   what_function
                BNE.S   L0072
                BSR     L0185
L0072:
                ANDI.B  #$F0,1(A1)
                OR.B    D0,1(A1)
                ST      L0376
                RTS
L0073:
                MOVEQ   #0,D0
                MOVE.B  L0356,D0
                LEA     L02A1,A0
                MOVE.B  0(A0,D0.w),D0
                BMI     L0069
                CMPI.B  #3,D0
                BHI     L0069
                TST.W   what_function
                BNE.S   L0074
                BSR     L0185
L0074:
                ANDI.B  #$0F,2(A1)
                ASL.B   #4,D0
                OR.B    D0,2(A1)
                ST      L0376
                RTS
L0075:
                MOVEQ   #0,D0
                MOVE.B  L0356,D0
                LEA     L02A1,A0
                MOVE.B  0(A0,D0.w),D0
                BMI     L0069
                TST.W   what_function
                BNE.S   L0076
                BSR     L0185
L0076:
                ANDI.B  #$F0,2(A1)
                OR.B    D0,2(A1)
                ST      L0376
                RTS
L0077:
                MOVEQ   #0,D0
                MOVE.B  L0356,D0
                LEA     L02A1,A0
                MOVE.B  0(A0,D0.w),D0
                BMI     L0069
                TST.W   what_function
                BNE.S   L0078
                BSR     L0185
L0078:
                ANDI.B  #$C0,3(A1)
                OR.B    D0,3(A1)
                ST      L0376
                RTS
L0079:
                MOVEQ   #0,D0
                MOVE.B  L0356,D0
                LEA     L02A2,A0
                MOVE.B  0(A0,D0.w),D0
                BMI     L0069
                TST.W   what_function
                BNE.S   L007A
                BSR     L0185
L007A:
                ANDI.B  #$1F,3(A1)
                ASL.B   #6,D0
                OR.B    D0,3(A1)
                ST      L0376
                RTS
                ENDPART
**********************************************************
                >PART 'SID Timer (b) - CH A'
new_timer_a:    MOVE.L  #$080800E0,$FFFF8800.w
                ADDI.W  #new_timer2_a-new_timer_a,$0122.w ;12.w
                RTE

new_timer2_a:   MOVE.L  #$08080000,$FFFF8800.w
x0201_a         EQU *-4
                SUBI.W  #new_timer2_a-new_timer_a,$0122.w ;12.w
                RTE
                ENDPART
**********************************************************
                >PART 'SID Timer (a) - CH B'
new_timer:      MOVE.L  #$090900E0,$FFFF8800.w
                ADDI.W  #new_timer2-new_timer,$0136.w
                RTE

new_timer2:     MOVE.L  #$09090000,$FFFF8800.w
x0201           EQU *-4
                SUBI.W  #new_timer2-new_timer,$0136.w
                RTE
                ENDPART
**********************************************************
                >PART 'SID Timer (d) - CH C'
new_timer_c:    MOVE.L  #$0A0A00E0,$FFFF8800.w
                ADDI.W  #new_timer2_c-new_timer_c,$0112.w ;22.w
                RTE

new_timer2_c:   MOVE.L  #$0A0A0000,$FFFF8800.w
x0201_c         EQU *-4
                SUBI.W  #new_timer2_c-new_timer_c,$0112.w ;22.w
                RTE
                ENDPART
**********************************************************
                >PART 'Nothing-done Timer'
no_timer:       RTE
                ENDPART
**********************************************************
                >PART 'Enhanced Replays'
check_tao_effect:
                CMPI.B  #$11,$3E(A0)
                BNE.S   no_special
                NOP                     ; Ab hier TAO Effekt einbinden

no_special:     RTS

check_rept:     CMPI.B  #$10,$3E(A0)    ; Wave Nr. $10 ist Double-Instr.
                BNE.S   no_doub
                MOVE.W  #1,rep
no_doub:        RTS

do_all:         MOVE.L  A0,merk_a0
                CMPI.W  #1,rep
                BNE.S   do_single
                REPT 2
                MOVEA.L merk_a0,A0
                BSR     do_fx
                BSR     do_tone_control
                BSR     do_wave_control
                ENDR
                CLR.W   rep
                BRA.S   exit
do_single:      MOVEA.L merk_a0,A0
                BSR     do_fx
                BSR     do_tone_control
                BSR     do_wave_control
exit:           RTS
merk_a0:        DS.L 1
rep:            DS.W 1
                ENDPART
**********************************************************
                >PART 'Extended Soundsys Subrouts'

do_tone_control:TST.B   extend_tone(A0)
                BEQ.S   no_tone_fix
                MOVEA.L extend_tone_adr(A0),A6
                MOVEQ   #0,D1
                MOVE.B  (A6)+,D1
                CMP.B   #$FF,D1
                BNE.S   tone_a
                MOVEQ   #0,D1
                CMP.B   #$FE,D1
                BNE.S   tone_a
                SUBQ.L  #1,A6
                MOVE.B  -1(A6),D1
tone_a:         MOVE.L  A6,extend_tone_adr(A0)
                MULU    #3,D1
                MOVE.B  tone_data(PC,D1.w),extend_tone_flag(A0)
                MOVE.B  tone_data+1(PC,D1.w),extend_noiz(A0)
                MOVE.B  tone_data+2(PC,D1.w),extend_buzz(A0)
                RTS
no_tone_fix:    MOVE.B  #1,extend_tone_flag(A0)
                MOVE.B  #1,extend_noiz(A0)
                MOVE.B  #1,extend_buzz(A0)
                RTS
                EVEN
tone_data:
                DC.B 0,0,0      ; Background Drum or Snare Effect
                DC.B 1,0,0
                DC.B 0,1,0
                DC.B 1,1,0
                DC.B 0,0,1
                DC.B 1,0,1
                DC.B 1,1,1
                EVEN

do_wave_control:TST.B   extend_wave(A0)
                BEQ.S   no_control_wave_
                MOVEA.L extend_wave_adr(A0),A6
                MOVE.B  (A6)+,D1
                CMPI.B  #$FF,D1
                BEQ.S   xno_hardw_auto_b
                CMPI.B  #$FE,D1
                BNE.S   wave_b
                SUBQ.B  #1,D1
                MOVE.B  -1(A6),D1
wave_b:         MOVE.L  A6,extend_wave_adr(A0)
                TST.B   D1
                BNE.S   no_control_wave_
xno_hardw_auto_b:BCLR   #2,instr_type(A0)
no_control_wave_:RTS

rest_control:   BTST    #0,instr_type(A0)
                BEQ.S   no_tone_c
                TST.B   extend_tone(A0)
                BNE.S   no_tone_cx
                TST.B   extend_noiz(A0)
                BEQ.S   no_tone_c
no_tone_cx:     BCLR    D6,D0
no_tone_c:      BTST    #1,instr_type(A0)
                BEQ.S   no_nois_c
                TST.B   $3C(A0)
                BNE.S   control_noise_c
                MOVE.W  #$0600,D5
                MOVE.B  $2B(A0),D5
                MOVEP.W D5,0(A5)
                BRA.S   no_nois_cx

control_noise_c:MOVEA.L extend_noiz_adr(A0),A6
                MOVE.B  (A6)+,D1
                CMPI.B  #$FF,D1
                BEQ.S   no_nois_c
                CMPI.B  #$FE,D1
                BNE.S   nois_c
                SUBQ.L  #1,A6
                MOVE.B  -1(A6),D1
nois_c:         MOVE.L  A6,extend_noiz_adr(A0)
                MOVE.W  #$0600,D5
                MOVE.B  D1,D5
                MOVEP.W D5,0(A5)
                TST.B   extend_tone_flag(A0)
                BEQ.S   no_nois_c
no_nois_cx:     BCLR    D7,D0
no_nois_c:      RTS

tfmx_note:      DC.W 0
tfmx_oct:       DC.W 0

do_fx:          TST.B   hardw_buzz(A0)
                BNE     do_silent
                BTST    #2,instr_type(A0)
                BEQ.S   no_he

                CMPI.B  #13,tfmx_effect(A0)
                BNE.S   normal_buzz

                MOVEQ   #1,D7           ; 4 mal hintereinander !!!

double:         MOVEA.W #$8800,A6
                MOVEQ   #0,D0
                MOVE.B  0(A0),D0        ;Bassnote holen
                ADD.B   $53(A0),D0      ;transponieren
                LEA     buzzfreqtab(PC),A2
                ANDI.W  #$3F,D0
                MOVE.B  #11,(A6)
                MOVE.B  0(A2,D0.w),2(A6)
                MOVE.B  #12,(A6)
                MOVE.B  #0,2(A6)
                ADDQ.B  #1,$53(A0)
                CMPI.B  #$3F,$53(A0)
                BLE.S   do_loop
                CLR.B   $53(A0)
do_loop:        BRA.S   to_tie

normal_buzz:    CLR.B   $53(A0)         ;  kein Offset auf BUZZ mehr

                MOVE.B  #$10,volume_(A0) ; BUZZ Tone
                BRA.S   to_tie
no_he:          MOVE.W  $14(A0),D0
                MOVEA.L $10(A0),A2
                MOVE.B  0(A2,D0.w),D1
                MOVE.B  $0F(A0),D2
                ASL.B   #4,D2
                ADD.B   D1,D2
                ANDI.W  #$FF,D2
                LEA     vols(PC),A2
                MOVE.B  0(A2,D2.w),volume_(A0)
                ADDQ.W  #1,D0
                CMP.W   $18(A0),D0
                BNE.S   no_sus_rep
                MOVE.W  $16(A0),D0
no_sus_rep:     CMP.W   $1A(A0),D0
                BCS.S   no_rel
                BSET    #0,hardw_buzz(A0)
no_rel:         MOVE.W  D0,$14(A0)
to_tie:         MOVE.W  6(A0),D0
                BEQ.S   no_tie
                BMI.S   tie_lo
                ADD.W   4(A0),D0
                CMP.W   2(A0),D0
                BLT.S   no_reach_tie_hi
                CLR.W   6(A0)
                MOVE.W  2(A0),D0
no_reach_tie_hi:MOVE.W  D0,4(A0)
                BRA.S   no_tie
tie_lo:         ADD.W   4(A0),D0
                CMP.W   2(A0),D0
                BGT.S   no_reach_tie_lo
                CLR.W   6(A0)
                MOVE.W  2(A0),D0
no_reach_tie_lo:MOVE.W  D0,4(A0)
no_tie:         MOVE.W  8(A0),D1
                ADD.W   $0A(A0),D1
                CMPI.W  #$3B,D1
                BLS.S   no_re_trem
                CLR.W   D1
no_re_trem:     MOVE.W  D1,8(A0)
                ADD.W   D1,D1
                LEA     trem_tab(PC),A2
                MOVE.W  0(A2,D1.w),D1
                MOVE.W  $0C(A0),D2
                ASR.W   D2,D1
                ADD.W   4(A0),D1

                CMPI.B  #1,tfmx_effect(A0)
                BNE.S   no_db_1_notex

                LEA     db_table(PC),A1
                MOVE.B  $4C(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4C(A0)
                CMPI.B  #1,$4C(A0)
                BLT.S   no_db_1_notex
                MOVE.B  #1,$4C(A0)

no_db_1_notex:
                CMPI.B  #4,tfmx_effect(A0)
                BNE.S   no_db_1_notey

                LEA     db_table(PC),A1
                MOVE.B  $4C(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4C(A0)
                CMPI.B  #1,$4C(A0)
                BLT.S   no_db_1_notey
                MOVE.B  #1,$4C(A0)

no_db_1_notey:  CMPI.B  #5,tfmx_effect(A0)
                BNE.S   no_db_1_note

                LEA     da_table(PC),A1
                MOVE.B  $4D(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #2,$4D(A0)
                CMPI.B  #$0C,$4D(A0)
                BLT     da_ok
                CLR.B   $4D(A0)

no_db_1_note:   CMPI.B  #6,tfmx_effect(A0)
                BNE.S   no_db_note2
                LEA     db_1_table(PC),A1
                MOVE.B  $4C(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4C(A0)
                CMPI.B  #64,$4C(A0)
                BLT.S   no_db_note2
                MOVE.B  #1,$4C(A0)

no_db_note2:    CMPI.B  #7,tfmx_effect(A0)
                BNE.S   no_db_note3
                LEA     db_2_table(PC),A1
                MOVE.B  $4D(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #2,$4D(A0)
                CMPI.B  #32,$4D(A0)
                BLT.S   no_db_note3
                MOVE.B  #2,$4D(A0)

no_db_note3:    CMPI.B  #8,tfmx_effect(A0)
                BNE.S   no_db_note4
                LEA     da2_table(PC),A1
                MOVE.B  $4C(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4C(A0)
                CMPI.B  #48,$4C(A0)
                BLT.S   no_db_note4
                CLR.B   $4C(A0)

no_db_note4:    CMPI.B  #9,tfmx_effect(A0)
                BNE.S   no_db_note5
                LEA     dx_table(PC),A1
                MOVE.B  $4D(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4D(A0)
                CMPI.B  #32,$4D(A0)
                BLT.S   no_db_note5
                CLR.B   $4D(A0)

no_db_note5:    CMPI.B  #10,tfmx_effect(A0)
                BNE.S   no_db_note6
                LEA     dx_table(PC),A1
                MOVE.B  $4D(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4D(A0)
                CMPI.B  #32,$4D(A0)
                BLT.S   spe
                CLR.B   $4D(A0)

spe:            LEA     da_table(PC),A1
                MOVE.B  $4C(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4C(A0)
                CMPI.B  #4,$4C(A0)
                BLT.S   no_db_note6
                CLR.B   $4C(A0)

no_db_note6:    CMPI.B  #11,tfmx_effect(A0)
                BNE.S   no_db_note7
                LEA     arp_spec,A1     ;dy_table(PC),A1
                MOVE.B  $4C(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4C(A0)
                CMPI.B  #16,$4C(A0)
                BLT.S   spe2
                CLR.B   $4C(A0)

spe2:           LEA     db_2_table(PC),A1
                MOVE.B  $4D(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4D(A0)
                CMPI.B  #18,$4D(A0)
                BLT.S   no_db_note7
                CLR.B   $4D(A0)

no_db_note7:    CMPI.B  #12,tfmx_effect(A0)
                BNE.S   no_db_note

                TST.B   hardw_buzz(A0)
                BNE     no_db_note
                BTST    #2,instr_type(A0)
                BEQ.S   no_db_note

                LEA     spec_,A1
                MOVE.B  $52(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),D0

                MOVE.B  D0,$38(A0)
                ANDI.W  #$3F,D0
                ADD.W   D0,$20(A0)

                ADDQ.B  #1,$52(A0)
                CMPI.B  #42,$52(A0)
                BLT.S   no_db_note
                CLR.B   $52(A0)

no_db_note:     CMPI.B  #2,tfmx_effect(A0)
                BNE.S   next_db         ;da_ok
                LEA     da_table(PC),A1
                MOVE.B  $4D(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #2,$4D(A0)
                CMPI.B  #$0C,$4D(A0)
                BLT.S   next_db         ;da_ok
                CLR.B   $4D(A0)
***************************************************
next_db:        CMPI.B  #12,tfmx_effect(A0)
                BNE.S   da_ok

                LEA     all_aroun(PC),A1
                MOVE.B  $4B(A0),D7
                EXT.W   D7
                MOVE.B  0(A1,D7.w),$38(A0)
                ADDQ.B  #1,$4B(A0)
                CMPI.B  #16,$4B(A0)
                BLT.S   no_db_1_notea
                MOVE.B  #8,$4B(A0)      ; Endrepeat 8

no_db_1_notea:
da_ok:          MOVE.B  $38(A0),D0
                BEQ.S   intr_0
                CMPI.B  #1,D0
                BEQ.S   intr_1
                ADD.W   $36(A0),D1
                CLR.B   $38(A0)
                BRA.S   intr_2
intr_1:         ADD.W   $34(A0),D1
intr_0:         ADDQ.B  #1,$38(A0)
intr_2:         TST.B   $28(A0)
                BEQ.S   no_pitch
                MOVE.W  $20(A0),D0
                MOVEA.L $1C(A0),A2
                MOVE.B  0(A2,D0.w),D2
                EXT.W   D2
                TST.B   $3C(A0)
                BEQ.S   no_noise_pitch2
                ADD.W   D2,D1
                ADD.W   D2,D1
                ADD.W   D2,D1
no_noise_pitch2:ADD.W   D2,D1
                ADDQ.W  #1,D0
                CMP.W   $24(A0),D0
                BNE.S   no_pit_sus_rep
                MOVE.W  $22(A0),D0
no_pit_sus_rep: CMP.W   $26(A0),D0
                BCS.S   no_pit_rel
                CLR.B   $28(A0)
no_pit_rel:     MOVE.W  D0,$20(A0)

no_pitch:
*****BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
                CMPI.W  #3,D1           ; Bug im SLIDE von Note (SID Status)
                BGT.S   n               ; f3 (arpeggio-pitch) mit SLIDE Speed $f
                ADDQ.W  #1,D1           ; nach note f2 (arpeggio-pitch)
n:              MOVE.W  D1,0(A0)        ; Replayspeed 6 --> Huh, kompliziert
*****BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
                CMPI.B  #13,tfmx_effect(A0)
                BNE.S   no_special_buzz
                DBRA    D7,double
no_special_buzz:MOVEQ   #0,D7
                RTS
do_silent:      CLR.B   volume_(A0)
                RTS

buzzfreqtab:    DC.B 240,226,212,200,190,178,168,158,150,142,134,126
                DC.B 120,113,106,100,95,89,84,79,75,71,67,63
                DC.B 60,56,53,50,47,45,42,40,38,36,34,32
                DC.B 30,28,27,25,24,22,21,20,19,18,17,16
                DC.B 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

all_aroun:      DC.B 10,10,9,8,6,4,2,1,3,4,7,9,10,12,15,17

db_table:       DC.B 1,0
db_1_table:     DC.B 1,0,1,0,2,0,2,0,3,0
db_2_table:     DC.B 0,0,1,1,2,2,3,3,4,4,5,5,6,6,5,5,4,4,3,3,2,2,1,1,0,0
da_table:       DC.B 0,0,1,1,2,2
da2_table:      DC.B 9,9,5,5,3,3,1,1,2,1,1,2,2,3,3,3,4,4,5,0,1,2
dx_table:       DC.B 0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0,1,1,0,2,0,3,0,4,0,5,0,6,0
                EVEN
spec_:          DC.B $10,$0F,$10,$0E,$10,$0D,$10,$0C,$10,$0B,$10,$0A,$10,$09
                DC.B $10,$08,$10,$07,$10,$06
                DC.B $10,$05,$10,$04,$10,$03,$10,$02,$10,$01,$10
                DC.B $10,$10,$10,$09,$08,$06,$04,$02,$00,$02
                EVEN
arp_spec:       DC.B 0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0
                DC.B 1,2,3,4,5,6,7,8,9
                EVEN
                ENDPART
**********************************************************
                >PART 'Command-Subrouts'

sid_dual_on_b:  MOVEM.L D0/A0-A1,-(SP)
                MOVE.W  #-1,dual_b      ; 0
                LEA     dual_on,A0      ; dual off gfx
                MOVEA.L screen,A1
                LEA     68*160+8(A1),A1
                ADDQ.W  #2,A1
                BSR     copy_dis
                MOVEM.L (SP)+,D0/A0-A1
                RTS

sid_dual_off_b: MOVEM.L D0/A0-A1,-(SP)
                CLR.W   dual_b          ; 0
                LEA     dual_off,A0     ; dual off gfx
                MOVEA.L screen,A1
                LEA     68*160+8(A1),A1
                ADDQ.W  #2,A1
                BSR     copy_dis
                MOVEM.L (SP)+,D0/A0-A1
                RTS

sid_on_a:       MOVE.L  #new_timer_a,$0120.w
                ST      sid_a           ; 0
                RTS
sid_on_b:       MOVE.L  #new_timer,$0134.w
                ST      sid_b           ; 0
                RTS
sid_on_c:       MOVE.L  #new_timer_c,$0110.w
                ST      sid_c           ; 0
                RTS
sid_off_a:      MOVE.L  #no_timer,$0120.w
                SF      sid_a           ; 0
                RTS
sid_off_b:      MOVE.L  #no_timer,$0134.w
                SF      sid_b           ; 0
                RTS
sid_off_c:      MOVE.L  #no_timer,$0110.w
                SF      sid_c           ; 0
                RTS

do_wave_1:      MOVEM.L D0/A0-A1,-(SP)
                LEA     wave_sft,A0     ; dual off gfx
                MOVEA.L screen,A1
                LEA     78*160+8(A1),A1
                ADDQ.W  #2,A1
                BSR     copy_dis
g1:             MOVE.L  #wave_form1,what_wave+2
                MOVEM.L (SP)+,D0/A0-A1
                RTS

do_wave_2:      MOVEM.L D0/A0-A1,-(SP)
                LEA     wave_mid,A0     ; dual off gfx
                MOVEA.L screen,A1
                LEA     78*160+8(A1),A1
                ADDQ.W  #2,A1
                BSR     copy_dis
g2:             MOVE.L  #wave_form2,what_wave+2
                MOVEM.L (SP)+,D0/A0-A1
                RTS

do_wave_3:      MOVEM.L D0/A0-A1,-(SP)
                LEA     wave_hrd,A0     ; dual off gfx
                MOVEA.L screen,A1
                LEA     78*160+8(A1),A1
                ADDQ.W  #2,A1
                BSR     copy_dis
g3:             MOVE.L  #wave_form3,what_wave+2
                MOVEM.L (SP)+,D0/A0-A1
ertes:          RTS


reset_all:      MOVE.W  D7,-(SP)
                MOVE.L  #wave_form1,what_wave+2
                MOVE.W  merk_speed,speed_

                ST      dual_a
                ST      dual_b
                ST      dual_c
                ST      sid_a           ; Flag, ob SID Channle an/aus ist
                ST      sid_b
                ST      sid_c

                MOVEM.L D0/A0-A1,-(SP)
                LEA     dual_off,A0     ; dual off gfx
                MOVEA.L screen,A1
                LEA     68*160+8(A1),A1
                ADDQ.W  #2,A1
                BSR     copy_dis
                LEA     wave_sft,A0     ; dual off gfx
                MOVEA.L screen,A1
                LEA     78*160+8(A1),A1
                ADDQ.W  #2,A1
                BSR     copy_dis
                MOVEM.L (SP)+,D0/A0-A1
g4:
                MOVE.W  (SP)+,D7
                RTS

copy_dis:       RTS
                MOVEQ   #4,D0
x               SET 0
y               SET 0
copy:           REPT 5
                MOVE.W  x(A0),y(A1)
x               SET x+2
y               SET y+8
                ENDR
                LEA     10(A0),A0
                LEA     160(A1),A1
                DBRA    D0,copy
                RTS

dual_on:        DC.W $3C89,$C422,$71C7,$BE00,$0722,$228A,$2422,$8888
                DC.W $2000,$08B2,$228B,$E422,$8888,$3C00,$08AA,$228A
                DC.W $2414,$8888,$2000,$08A6,$3C7A,$2788,$71C7,$BE00
                DC.W $0722
dual_off:       DC.W $3C89,$C422,$71C7,$BE01,$CFBE,$228A,$2422,$8888
                DC.W $2002,$2820,$228B,$E422,$8888,$3C02,$2F3C,$228A
                DC.W $2414,$8888,$2002,$2820,$3C7A,$2788,$71C7,$BE01
                DC.W $C820
wave_sft:       DC.W $2272,$2FBE,$73C8,$8079,$CFBE,$228A,$2820,$8A2D
                DC.W $8082,$2808,$2AFA,$2F3C,$8BCA,$8072,$2F08,$3689
                DC.W $4820,$8A88,$800A,$2808,$2288,$8FA0,$7268,$80F1
                DC.W $C808
wave_mid:       DC.W $2272,$2FBE,$73C8,$8002,$273C,$228A,$2820,$8A2D
                DC.W $8003,$6222,$2AFA,$2F3C,$8BCA,$8002,$A222,$3689
                DC.W $4820,$8A88,$8002,$2222,$2288,$8FA0,$7268,$8002
                DC.W $273C
wave_hrd:       DC.W $2272,$2FBE,$73C8,$8089,$CF3C,$228A,$2820,$8A2D
                DC.W $808A,$28A2,$2AFA,$2F3C,$8BCA,$80FB,$EF22,$3689
                DC.W $4820,$8A88,$808A,$2A22,$2288,$8FA0,$7268,$808A
                DC.W $29BC

                ENDPART
**********************************************************
                >PART 'SID Spectrum'
do_samplespektrum:
                CMPI.B  #1,show_info
                BNE     go_out
                CMPI.B  #-1,show_spec
                BEQ     go_out

                TST.W   what_function
                BNE.S   weiter
                BRA     no2
weiter:

; Bildschirm l”schen (1 Plane):
                BTST    #5,$FFFFFA07.w  ; SID Voice an ???
                BEQ     no              ;no              ; Nein, dann Flatline
                MOVEA.L screen,A0
what_buff:      LEA     editor_buff,A1  ; Zwei Rettbuffer
                MOVEA.L A0,A2           ;merken!
                LEA     144*160(A0),A0
                LEA     160-16(A0),A0
                MOVEQ   #0,D1
                MOVEQ   #42-1,D0

l_scr:          MOVEM.W (A1),D1-D4
                MOVEM.W D1-D4,(A0)
                MOVEM.W 8(A1),D1-D4
                MOVEM.W D1-D4,8(A0)
                LEA     16(A1),A1
                LEA     160(A0),A0
                DBRA    D0,l_scr

                MOVEA.L screen,A1
                LEA     160*56(A1),A1
                ADDQ.W  #8,A1
                MOVEA.L A1,A0
                MOVEQ   #30-1,D0
                MOVEQ   #0,D1
clear_dis:
x               SET 0
                REPT 5
                MOVE.W  D1,x(A1)
x               SET x+8
                ENDR
                LEA     160(A1),A1
                DBRA    D0,clear_dis

                LEA     ytab,A1
                MOVE.W  #64,D2          ;Basis y-Wert
                MOVE.W  #18,D3          ;x
                MOVE.W  sid_offset,D6
                MOVEQ   #77-1,D4

next_pixel:     MOVE.B  $FFFFFA19.w,D7
                LSR.W   #4,D7
                ADD.B   $FFFFFA1F.w,D6
                ADD.B   new_timer+4,D6
                DIVU    D7,D6
                SUB.B   D2,D6

                CMPI.B  #1,D6           ; Bereich-Check
                BGT.S   noch_okay
                MOVE.B  #30,D6
noch_okay:      CMPI.B  #126,D6
                BLT.S   noch_ok2
                MOVE.B  #126,D6         ; Bereich-Check
noch_ok2:       MOVE.W  D3,D0           ;x

                MOVEQ   #0,D1
                MOVE.W  D6,D1
                LSR.W   #3,D1
                ADD.W   D2,D1
                MOVE.W  #0,cha+2
                BSR     plot_pixel
                ADDQ.W  #1,D3           ;x=x+1
                DBRA    D4,next_pixel

                BRA     go_out

no__:           BTST    #4,$FFFFFA09.w  ; SID Voice an ???
                BEQ     test_timer_b    ; Nein, dann Flatline

                LEA     ytab,A1
                MOVE.W  #64,D2          ;Basis y-Wert
                MOVE.W  #18,D3          ;x
                MOVE.W  sid_offset2,D6
                MOVEQ   #77-1,D4

next_pixela:    ANDI.B  #$F0,$FFFFFA1D.w
                MOVE.B  $FFFFFA1D.w,D7
                LSR.W   #4,D7
                ADD.B   $FFFFFA25.w,D6
                SUBQ.B  #7,D6
                ADD.B   new_timer_a+4,D6
                DIVS    D7,D6
                SUBX.B  D2,D6

                CMPI.B  #1,D6           ; Bereich-Check
                BGT.S   noch_okaya
                MOVE.B  #30,D6
noch_okaya:     CMPI.B  #126,D6
                BLT.S   noch_ok2a
                MOVE.B  #126,D6         ; Bereich-Check
noch_ok2a:      MOVE.W  D3,D0           ;x

                MOVEQ   #0,D1
                MOVE.W  D6,D1
                LSR.W   #3,D1
                ADD.W   D2,D1
                MOVE.W  #2,cha+2
                BSR     plot_pixel
                ADDQ.W  #1,D3           ;x=x+1
                DBRA    D4,next_pixela

test_timer_b:   BTST    #0,$FFFFFA07.w  ; SID Voice an ???
                BEQ     go_out          ; Nein, dann Flatline
                LEA     ytab,A1
                MOVE.W  #64,D2          ;Basis y-Wert
                MOVE.W  #18,D3          ;x
                MOVE.W  sid_offset3,D6
                MOVEQ   #77-1,D4

next_pixelc:    MOVE.B  $FFFFFA1B.w,D7
                LSR.W   #4,D7
                ADD.B   $FFFFFA21.w,D6
                SUBQ.B  #7,D6
                ADD.B   new_timer_c+4,D6
                DIVS    D7,D6
                SUBX.B  D2,D6

                CMPI.B  #1,D6           ; Bereich-Check
                BGT.S   noch_okayc
                MOVE.B  #30,D6
noch_okayc:     CMPI.B  #126,D6
                BLT.S   noch_ok2c
                MOVE.B  #126,D6         ; Bereich-Check
noch_ok2c:      MOVE.W  D3,D0           ;x

                MOVEQ   #0,D1
                MOVE.W  D6,D1
                LSR.W   #3,D1
                ADD.W   D2,D1
                MOVE.W  #4,cha+2
                BSR     plot_pixel
                ADDQ.W  #1,D3           ;x=x+1
                DBRA    D4,next_pixelc
go_out:         RTS

no:             MOVEA.L screen,A0
what_buff2:     LEA     editor_buff,A1  ; s.o.
                MOVEA.L A0,A2           ;merken!
                LEA     144*160(A0),A0
                LEA     160-16(A0),A0
                MOVEQ   #0,D1
                MOVEQ   #42-1,D0

l_scr2:         MOVEM.W (A1),D1-D4
                MOVEM.W D1-D4,(A0)

                MOVEM.W 8(A1),D1-D4
                MOVEM.W D1-D4,8(A0)
                LEA     16(A1),A1
                LEA     160(A0),A0
                DBRA    D0,l_scr2
                RTS
no2:
                MOVEA.L screen,A2
                LEA     ytab,A1
                MOVE.W  #60,D2          ;Basis y-Wert
                MOVE.W  #18,D3          ;x
                MOVE.W  sid_offset,D6
                MOVEQ   #77-1,D4

next_pixel2:    MOVE.W  D3,D0           ;x
                MOVEQ   #75,D1
                LSR.W   #3,D1           ;/8
                ADD.W   D2,D1
                BSR     plot_pixel
                ADDQ.W  #1,D3           ;x=x+1
                DBRA    D4,next_pixel2
ggg:            RTS


sid_offset:     DC.W 0
sid_offset2:    DC.W 0
sid_offset3:    DC.W 0
                ENDPART
**********************************************************
                >PART 'Uhr'

clock:          CMPI.W  #0,what_function
                BEQ     no_add_
                ADDQ.B  #1,seconds
                ADDQ.B  #1,intern_1er
                CMPI.B  #59,seconds
                BLE.S   raus

                CLR.B   seconds
                CLR.B   intern_1er
                CLR.B   intern_10er
                ADDQ.B  #1,intern_1er_min

raus:           MOVE.B  mins,D0
                ADD.B   #"0",D0
                MOVE.B  D0,lower_min
************************************************************
* Sekunden Umrechnung
                CMPI.B  #10,intern_1er
                BEQ.S   add_first
                BRA.S   wandel

add_first:      ADDQ.B  #1,intern_10er
                CLR.B   intern_1er

wandel:         MOVE.B  intern_1er,D0
                ADD.B   #"0",D0
                MOVE.B  D0,lower_sec
                MOVE.B  intern_10er,D0
                ADD.B   #"0",D0
                MOVE.B  D0,upper_sec
* Ende
************************************************************
* Minuten Umrechnung
                CMPI.B  #10,intern_1er_min
                BEQ.S   add_first_ziff
                BRA.S   wandel_min

add_first_ziff: ADDQ.B  #1,intern_10er_min
                CLR.B   intern_1er_min

wandel_min:     MOVE.B  intern_1er_min,D0
                ADD.B   #"0",D0
                MOVE.B  D0,lower_min
                MOVE.B  intern_10er_min,D0
                ADD.B   #"0",D0
                MOVE.B  D0,upper_min
* Ende
************************************************************
no_add_:        RTS

show_clock:     CMPI.B  #1,_clock
                BNE.S   no_show
                MOVE.W  #$11,text_xpos
                MOVE.W  #12+10,text_ypos
                LEA     font_8x8,A3
                LEA     upper_min,A2
                MOVEQ   #5-1,D3
show_them:      MOVEQ   #0,D0
                MOVE.B  (A2)+,D0
                MOVE.B  0(A3,D0.w),D0
                BSR     set_text
                ADDQ.W  #1,text_xpos
                DBRA    D3,show_them
no_show:        RTS

reset_clock:    MOVE.B  #"0",upper_min
                MOVE.B  #"0",upper_sec
                MOVE.B  #"0",lower_min
                MOVE.B  #"0",lower_sec
                CLR.W   intern_1er
                CLR.W   intern_1er_min
                CLR.W   mins
                RTS

                EVEN
_clock:         DC.B 1
                EVEN
intern_1er:     DC.B 0
intern_10er:    DC.B 0
intern_1er_min: DC.B 0
intern_10er_min:DC.B 0
mins:           DC.B 0
seconds:        DC.B 0
*******************************************
                EVEN
upper_min:      DC.B "0"        ; Fr die Zeichenausgabe
lower_min:      DC.B "0"
                DC.B ":"
upper_sec:      DC.B "0"
lower_sec:      DC.B "0"
                EVEN
                ENDPART
**********************************************************
                >PART 'Set-Screen'
set_screen:     PEA     (A0)            ; in d0 = screenadress
                LSR.L   #8,D0
                LEA     $FFFF8201.w,A0
                MOVEP.W D0,0(A0)        ; set mid and highbyte
                MOVEA.L (SP)+,A0
                RTS
                ENDPART
**********************************************************
                >PART 'Wave Synthese Plotting'

show_wave:      MOVEQ   #45,D1
                MOVE.W  D3,D0
                MOVE.B  (A3)+,D6
                CMPI.B  #$FF,D6
                BNE.S   tt_2
                MOVEQ   #0,D7
                BRA.S   go_out_
tt_2:           CMPI.B  #$FE,D6
                BNE.S   okay_tt
                MOVEQ   #0,D7
                BRA.S   go_out_
okay_tt:        EXT.W   D6
                CMPI.W  #31,D6
                BLE.S   okay_range
                MOVEQ   #31,D6
okay_range:     SUB.W   D6,D1           ; Von Y-Achse abziehen !!!
                BSR     plot_pixel
                ADDQ.W  #1,D3
                DBRA    D7,show_wave
go_out_:        RTS

clear_wave:     MOVEQ   #45,D1
                MOVE.W  D3,D0
                MOVE.B  (A3)+,D6
                EXT.W   D6
                CMPI.W  #$FF,D6
                BEQ.S   go_out_2
                CMPI.W  #$FE,D6
                BEQ.S   go_out_2
                CMPI.W  #31,D6
                BLE.S   okay_range2
                MOVEQ   #31,D6
okay_range2:    SUB.W   D6,D1           ; Von Y-Achse abziehen !!!
                BSR     clear_pixel
                ADDQ.W  #1,D3
                DBRA    D7,clear_wave
go_out_2:       RTS

                ENDPART
**********************************************************
                >PART 'Pixel setting routs'
plot_pixel:
; a1.l - Adresse der ytab=Adresse der xtab, die falschherum vorliegt!
; a2.l - Adresse des Bildschirms
; d0.w - x
; d1.w - y
                MOVEA.L A2,A0
                ADD.W   D0,D0
                ADD.W   D0,D0           ;*4
                NEG.W   D0              ;negativ machen, weil xtab falschherum vorliegt
                ADD.W   D1,D1
                ADD.W   D1,D1           ;*4
                ADDA.L  0(A1,D1.w),A0
                ADDA.W  -4(A1,D0.w),A0  ;Zugriff auf xtab
                MOVE.W  -2(A1,D0.w),D1  ;Zugriff auf xtab
cha:            OR.W    D1,0(A0)
                RTS
clear_pixel:
; a1.l - Adresse der ytab=Adresse der xtab, die falschherum vorliegt!
; a2.l - Adresse des Bildschirms
; d0.w - x
; d1.w - y
                MOVEA.L A2,A0
                ADD.W   D0,D0
                ADD.W   D0,D0           ;*4
                NEG.W   D0              ;negativ machen, weil xtab falschherum vorliegt
                ADD.W   D1,D1
                ADD.W   D1,D1           ;*4
                ADDA.L  0(A1,D1.w),A0
                ADDA.W  -4(A1,D0.w),A0  ;Zugriff auf xtab
                MOVE.W  -2(A1,D0.w),D1  ;Zugriff auf xtab
                EOR.W   D1,(A0)
                RTS
createxnytab:   MOVEQ   #0,D0
                LEA     ytab,A0
                MOVE.W  #200-1,D1
createytab:     MOVE.L  D0,(A0)+
                ADD.L   #160,D0
                DBRA    D1,createytab
                LEA     xtab,A0
                MOVE.W  #319,D1
creatextab:
                MOVEQ   #0,D2
                MOVE.W  D1,D2           ;Pixnr holen (xtab soll falsch rum vorliegen!)
                DIVU    #16,D2
                LSL.W   #3,D2           ;*8
                MOVE.W  D2,(A0)+
                MOVEQ   #0,D3
                SWAP    D2
                MOVEQ   #15,D4
                SUB.W   D2,D4
                BSET    D4,D3
                MOVE.W  D3,(A0)+
                DBRA    D1,creatextab
                RTS
xtab:           DS.L 320        ;die x-Tab soll aber falsch rum vorliegen
ytab:           DS.L 200        ;muž hinter der xtab stehen!!!!
                ENDPART
**********************************************************
                >PART 'Editor Scheiss'
L007E:          MOVE.B  #$13,D0
                BSR     write_ikbd
                CLR.W   L0369
                RTS
L007F:          MOVE.B  #$11,D0
                BSR     write_ikbd
                RTS

write_ikbd:     BTST    #1,$FFFFFC00.w
                BEQ.S   write_ikbd
                MOVE.B  D0,$FFFFFC02.w
                RTS
key_vec:
; neuer Keyinterrupt
                MOVEM.L D0-A6,-(SP)
check_irq:      BSR     key_check
                BSR     do_midi_request
                BTST    #4,$FFFFFA01.w
                BEQ.S   check_irq
                MOVEM.L (SP)+,D0-A6
                RTE

key_check:      LEA     $FFFFFC00.w,A0
                MOVE.B  (A0),D2
                BTST    #7,D2
                BEQ.S   L0085
                BTST    #0,D2
                BEQ     L0084
                BSR     L0086
L0084:          ANDI.B  #$20,D2
                BEQ     L0085
                MOVE.B  2(A0),D0
L0085:          RTS
L0086:          MOVE.B  2(A0),D0
                TST.W   L0369
                BNE     L008F
                CMPI.B  #$F8,D0
                BCC     L008E
                CMPI.B  #$2A,D0
                BEQ     L008A
                CMPI.B  #$AA,D0
                BEQ     L008B
                CMPI.B  #$36,D0
                BEQ     L008C
                CMPI.B  #$B6,D0
                BEQ     L008D
                BCLR    #7,D0
                BNE.S   L0087
                CLR.B   L035C
                CLR.W   L0353
                CLR.B   L035B
                MOVE.B  D0,L0357
                MOVE.B  D0,L0358
                MOVE.B  D0,L0356
                RTS
L0087:          CMP.B   L0356,D0
                BNE.S   L0088
                CLR.B   L0356
L0088:          CMP.B   L0359,D0
                BEQ.S   L0089
                CMP.B   L0357,D0
                BEQ.S   L0089
                RTS
L0089:          BSET    #7,D0
                MOVE.B  D0,L0357
                RTS
L008A:          BSET    #0,L035A
                RTS
L008B:          BCLR    #0,L035A
                RTS
L008C:          BSET    #1,L035A
                RTS
L008D:          BCLR    #1,L035A
                RTS
L008E:          LEA     X_MOUSE_REL,A0
                MOVE.B  D0,(A0)+
                MOVE.L  A0,L0368
                MOVE.W  #2,L0369
                RTS
L008F:          MOVEA.L L0368,A0
                MOVE.B  D0,(A0)+
                MOVE.L  A0,L0368
                SUBQ.W  #1,L0369
                BEQ.S   L0090
                RTS
L0090:          MOVE.W  Y_MOUSE_POS,D0
                MOVE.B  Y_MOUSE_REL,D1
                EXT.W   D1
                ADD.W   D1,D0
                BMI.S   L0091
                CMPI.W  #319,D0
                BHI.S   L0091
                MOVE.W  D0,Y_MOUSE_POS
L0091:          MOVE.W  L0367,D0
                MOVE.B  X_MOUSE_POS,D1
                EXT.W   D1
                ADD.W   D1,D0
                BMI.S   L0092
                CMPI.W  #199,D0
                BHI.S   L0092
                MOVE.W  D0,L0367
L0092:          RTS
do_midi_request:LEA     $FFFFFC04.w,A0
                MOVE.B  (A0),D2
                BTST    #7,D2
                BEQ.S   L0095
                BTST    #0,D2
                BEQ     L0094
                BSR     L0096
L0094:
                ANDI.B  #$20,D2
                BEQ     L0095
                MOVE.B  2(A0),D0
L0095:          RTS

L0096:          MOVE.B  2(A0),D0
                ST      L035C
                MOVE.B  $FFFFFC06.w,D0
                BTST    #7,D0
                BNE.S   L009A
                MOVE.B  L035D,D1
                BEQ.S   L0099
                CMPI.B  #1,D1
                BNE.S   L0097
                MOVE.B  D0,L035F
                MOVE.B  #2,L035D
                BRA.S   L0099
L0097:
                MOVE.B  #1,L035D
                TST.B   D0
                BEQ.S   L0098
                MOVE.B  D0,L0360
                MOVE.B  L035F,L035E
                MOVE.B  L035F,L0362
                BRA.S   L0099
L0098:
                MOVE.B  L035F,D0
                CMP.B   L0362,D0
                BNE.S   L0099
                CLR.B   L0360
                ST      L035E
                CLR.B   L0362
L0099:
                RTS

L009A:          ANDI.B  #$F0,D0
                CMPI.B  #$90,D0
                BNE.S   L009B
                MOVE.B  #1,L035D
                RTS
L009B:
                CLR.B   L035D
                RTS

L009C:          MOVE.W  L034F,D0
L009D:          CMP.W   L034F,D0
                BEQ.S   L009D

                RTS

vbl:            MOVEM.L D0-A6,-(SP)

                TST.B   L0355
                BNE.S   L009F

                MOVE.L  #L02C2,L00A3

L009F:
                BSR     L00B0
                BSR     L00AC
                BSR     L0012
                ADDQ.W  #1,L034F
                BNE.S   L00A0
                CLR.W   L0350
                CLR.W   L0352
L00A0:          MOVEM.L (SP)+,D0-A6
                CLR.W   $FFFF8240.w
                RTE
intern_:
L00A3:          DS.W 2

L00A4:          MOVE.W  pal_number,D0
                ADDQ.W  #1,D0
                CMPI.W  #$0A,D0
                BNE.S   L00A5
                CLR.W   D0
L00A5:          MOVE.W  D0,pal_number
                BSR     set_cols
                RTS

set_cols:       MOVE.W  pal_number,D0
                ADD.W   D0,D0
                ADD.W   D0,D0

                LEA     pal_pointer,A0

                TST.B   info_page_flag
                BEQ.S   L00A7
                LEA     info_page_pal,A0

L00A7:          MOVEA.L 0(A0,D0.w),A0
                LEA     $FFFF8240.w,A1
                MOVEQ   #15,D0
L00A8:          MOVE.W  (A0)+,(A1)+
                DBRA    D0,L00A8
                RTS

SHIFT_MOUSE:    LEA     L03D1,A3
                LEA     MOUSE_POINTER,A0
                MOVEA.L (A0),A1
                MOVEQ   #0,D1
L00AA:
                MOVE.L  A3,(A0)+
                MOVEA.L A1,A2
                MOVE.W  #$0F,D2
L00AB:
                MOVEQ   #0,D4
                MOVE.W  (A2)+,D4
                ROR.L   D1,D4
                MOVE.W  D4,(A3)+
                SWAP    D4
                MOVE.W  D4,(A3)+
                DBRA    D2,L00AB
                ADDQ.W  #1,D1
                CMPI.W  #$10,D1
                BNE     L00AA

                LEA     NEW_MOUSE,A3    ; MOUSESHIFTING BUFFER 2
                LEA     MOUSE_POINTER2,A0
                MOVEA.L (A0),A1
                MOVEQ   #0,D6           ; d1
L00AAX:         MOVE.L  A3,(A0)+
                MOVEA.L A1,A2
                MOVEQ   #$0F,D7         ; d2
L00ABX:         MOVEQ   #0,D5           ; d4
                MOVE.W  (A2)+,D5        ;d4
                ROR.L   D6,D5           ;1,D4
                MOVE.W  D5,(A3)+        ;4,(A3)+
                SWAP    D5              ; d4
                MOVE.W  D5,(A3)+        ;4,(A3)+
                DBRA    D7,L00ABX
                ADDQ.W  #1,D6           ;d1
                CMPI.W  #$10,D6         ; d1
                BNE     L00AAX
                RTS

L00AC:
                MOVE.W  L0367,D0

                LEA     mulu_160,A0
                ADD.W   D0,D0
                MOVE.W  0(A0,D0.w),D0
                MOVEA.L screen,A0
                ADDQ.L  #6,A0

                ADDA.W  D0,A0
                MOVE.W  #$0F,D1
                MOVE.W  #$B8,D0
                SUB.W   L0367,D0
                BPL.S   L00AD
                ADD.W   D0,D1
L00AD:
                MOVE.W  Y_MOUSE_POS,D0
                LSR.W   #4,D0
                ASL.W   #3,D0
                ADDA.W  D0,A0
                MOVE.L  A0,L036A
                MOVE.W  Y_MOUSE_POS,D0
                MOVEA.L #$A0,A2
                ANDI.W  #$0F,D0
                ASL.W   #2,D0

                MOVEA.L WHAT_MOUSE,A1

*               LEA     MOUSE_POINTER,A1
                MOVEA.L 0(A1,D0.w),A1
                MOVE.W  Y_MOUSE_POS,D0
                CMPI.W  #303,D0
                BHI.S   L00AF
L00AE:
                MOVE.W  (A1)+,(A0)
                MOVE.W  (A1)+,8(A0)
                ADDA.L  A2,A0
                DBRA    D1,L00AE

                RTS
L00AF:
                MOVE.W  (A1)+,(A0)
                ADDQ.L  #2,A1
                ADDA.L  A2,A0
                DBRA    D1,L00AF
                RTS

L00B0:          MOVEA.L L036A,A0
                MOVEQ   #$0F,D0
L00B1:          CLR.W   (A0)
                CLR.W   8(A0)
                ADDA.L  #$A0,A0
                DBRA    D0,L00B1
                RTS
L00B2:
                MOVEA.L mouse_tab_pnt,A0
L00B3:
                MOVE.B  X_MOUSE_REL,D0
                ANDI.B  #3,D0
                BEQ     L00B7
                TST.B   L036B
                BNE.S   L00B8
                MOVE.W  Y_MOUSE_POS,D0
                MOVE.W  L0367,D1
L00B4:
                CMP.W   (A0),D0
                BCS.S   L00B6
                CMP.W   2(A0),D1
                BCS.S   L00B6
                CMP.W   4(A0),D0
                BHI.S   L00B6
                CMP.W   6(A0),D1
                BHI.S   L00B6
                MOVEA.L 8(A0),A1
                JSR     (A1)
                CLR.B   L03B7
                MOVEA.L vbl_call,A0
                JSR     (A0)
                TST.B   L036B
                BNE.S   L00B8
                TST.W   L0351
                BNE.S   L00B5
                MOVE.W  #$10,L0351
                RTS
L00B5:
                MOVE.W  #4,L0351
                RTS
L00B6:
                ADDA.L  #$0C,A0
                TST.L   4(A0)
                BNE.S   L00B4
L00B7:
                CLR.B   L036B
L00B8:
                CLR.W   L0351
                RTS
L00B9:
                MOVEA.L L036D,A0
                BSR     L00B3
                RTS

L00BA:          MOVEQ   #0,D0
                MOVE.B  L0356,D0
                BEQ     L00C0
                TST.B   L035B
                BNE     L00BC
                TST.B   recording_flag
                BNE     L00C2
                MOVEA.L key_table_pnt,A0
                TST.B   L035A
                BEQ.S   L00BB
                ADDI.W  #$0100,D0
L00BB:          CMP.W   (A0),D0
                BNE.S   L00BD
                MOVEA.L 2(A0),A3
                MOVEA.L act_pat_adr,A1
                MOVE.W  pos_in_pat,D1
                MULU    #$0C,D1
                ADDA.W  D1,A1
                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                ADDA.L  0(A2,D0.w),A1
                LEA     L02A8,A2
                MOVEA.L 0(A2,D0.w),A0
                JSR     (A3)
                CLR.B   L03B7
                MOVEA.L vbl_call,A0
                JSR     (A0)
                TST.W   L0353
                BNE.S   L00BC
                MOVE.W  #$10,L0353
                RTS
L00BC:
                MOVE.W  #4,L0353
                RTS
L00BD:
                ADDQ.L  #6,A0
                TST.W   (A0)
                BNE.S   L00BB
L00BE:
                TST.W   what_function
                BNE.S   L00C1
                MOVEA.L act_pat_adr,A1
                MOVE.W  pos_in_pat,D0
                MULU    #$0C,D0
                ADDA.W  D0,A1
                MOVE.L  A1,L03C3
                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                ADDA.L  0(A2,D0.w),A1
                LEA     L02A8,A2
                MOVEA.L 0(A2,D0.w),A0
                LEA     L02A6,A2
                MOVEA.L 0(A2,D0.w),A2
                JSR     (A2)
                TST.B   L0376
                BEQ.S   L00C1
                TST.W   L0353
                BNE.S   L00BF
                MOVE.W  #$10,L0353
                RTS
L00BF:
                MOVE.W  #4,L0353
                RTS
L00C0:
                TST.B   L0362
                BNE.S   L00BE
L00C1:
                CLR.W   L0353
                RTS
L00C2:
                CMPI.B  #$1C,D0
                BEQ     L00C5
                CMPI.B  #$0E,D0
                BEQ     L00C6
                CMPI.B  #$53,D0
                BEQ     L00C7
                CMPI.B  #$52,D0
                BEQ     L00C8
                CMPI.B  #$4B,D0
                BEQ     L00C9
                CMPI.B  #$4D,D0
                BEQ     L00CA
                CMPI.B  #$50,D0
                BEQ     L00CB
                CMPI.B  #$48,D0
                BEQ     L00CC
                LEA     KEY_TABLE,A0
                MOVE.B  0(A0,D0.w),D0
                BEQ.S   L00C3
                MOVEA.L L03AF,A0
                MOVE.W  L03AE,D1
                MOVE.B  D0,0(A0,D1.w)
                ADDQ.W  #1,D1
                ANDI.W  #7,D1
                MOVE.W  D1,L03AE
L00C3:
                MOVEA.L vbl_call,A0
                JSR     (A0)
                TST.W   L0353
                BNE.S   L00C4
                MOVE.W  #$10,L0353
                RTS
L00C4:
                MOVE.W  #4,L0353
                RTS
L00C5:
                CLR.B   recording_flag
                BRA.S   L00C3
L00C6:
                SUBQ.W  #1,L03AE
                ANDI.W  #7,L03AE
L00C7:
                MOVEQ   #7,D0
                MOVE.W  L03AE,D1
                SUB.W   D1,D0
                MOVEA.L L03AF,A0
                LEA     7(A0),A2
                LEA     0(A0,D1.w),A1
                LEA     1(A1),A0
                BSR     L01F8
                MOVE.B  #$20,(A2)
                BRA.S   L00C3
L00C8:
                MOVEQ   #7,D0
                MOVE.W  L03AE,D1
                SUB.W   D1,D0
                MOVEA.L L03AF,A0
                LEA     0(A0,D1.w),A2
                LEA     0(A0,D1.w),A0
                LEA     1(A0),A1
                BSR     L01F8
                MOVE.B  #$20,(A2)
                BRA     L00C3
L00C9:
                SUBQ.W  #1,L03AE
                ANDI.W  #7,L03AE
                BRA     L00C3
L00CA:
                ADDQ.W  #1,L03AE
                ANDI.W  #7,L03AE
                BRA     L00C3
L00CB:
                MOVE.W  #7,L03AE
                BRA     L00C3
L00CC:
                CLR.W   L03AE
                BRA     L00C3

add_sam_freq:   RTS

                MOVE.W  sam_num,D0
                LEA     sam_freqs,A2
                CMPI.B  #$0F,0(A2,D0.w)
                BEQ.S   L00CF
                ADDI.B  #1,0(A2,D0.w)
L00CE:          MOVE.B  #1,_clock
                RTS

L00CF:          MOVE.B  #5,0(A2,D0.w)
                RTS

sub_sam_freq:   RTS
************
                MOVE.W  sam_num,D0
                LEA     sam_freqs,A2
                CMPI.B  #5,0(A2,D0.w)
                BEQ     reset_sam_freq
                SUBI.B  #1,0(A2,D0.w)
                RTS

reset_sam_freq: RTS
******
                MOVE.W  sam_num,D0
                LEA     sam_freqs,A2
                MOVE.B  #$0F,0(A2,D0.w) ; Hier ein $f
                RTS

add_sam_num:    RTS
************
                ADDQ.W  #1,sam_num
                ANDI.W  #$0F,sam_num
                CLR.B   recording_flag
                RTS

sub_sam_num:    RTS
*********
                SUBQ.W  #1,sam_num
                ANDI.W  #$0F,sam_num
                CLR.B   recording_flag
                RTS
reset_sam_num:  RTS
***************
                CLR.W   sam_num
                CLR.B   recording_flag
                RTS

add_instr_num:  ADDQ.B  #1,instr_num
                ANDI.B  #$3F,instr_num
                CLR.B   recording_flag
                BSR     L0254
                RTS
sub_instr_num:  SUBQ.B  #1,instr_num
                ANDI.B  #$3F,instr_num
                CLR.B   recording_flag
                BSR     L0254
                RTS

reset_instr_num:CLR.B   instr_num
                CLR.B   recording_flag
                BSR     L0254
                RTS

add_curr_vol:   ADDQ.B  #1,volume
                ANDI.B  #$0F,volume
                RTS

sub_curr_vol:   SUBQ.B  #1,volume
                ANDI.B  #$0F,volume
                RTS

reset_curr_vol: MOVE.B  #$0F,volume
                RTS

add_patt_count: ADDQ.B  #1,pat_pos_count
                ANDI.B  #lv,pat_pos_count
                RTS

sub_patt_count: SUBQ.B  #1,pat_pos_count
                ANDI.B  #lv,pat_pos_count
                RTS
L00DD:          CLR.B   pat_pos_count
                RTS

L00DE:          CMPI.W  #$77,song_position
                BEQ     L00DF
                ADDQ.W  #1,song_position
                BSR     L022A
                ST      L0371
                RTS
L00DF:
                CLR.W   song_position
                BSR     L022A
                ST      L0371
                RTS
L00E0:
                TST.W   song_position
                BEQ     L00E1
                SUBQ.W  #1,song_position
                BSR     L022A
                ST      L0371
                RTS
L00E1:
                MOVE.W  #$77,song_position
                BSR     L022A
                ST      L0371
                RTS
L00E2:
                MOVE.W  pattern_,D2
                ADDQ.W  #1,D2
                CMP.W   L03DF,D2
                BEQ     L00E3
                MOVE.W  song_position,D3
                LEA     L03E0,A0
                ADDI.B  #1,0(A0,D3.w)
                BSR     L022A
                ST      L0371
                RTS
L00E3:
                MOVE.W  song_position,D3
                LEA     L03E0,A0
                CLR.B   0(A0,D3.w)
                BSR     L022A
                ST      L0371
                RTS
L00E4:
                TST.W   pattern_
                BEQ     L00E5
                MOVE.W  song_position,D3
                LEA     L03E0,A0
                SUBI.B  #1,0(A0,D3.w)
                BSR     L022A
                ST      L0371
                RTS
L00E5:
                MOVE.W  L03DF,D2
                SUBQ.W  #1,D2
                MOVE.W  song_position,D3
                LEA     L03E0,A0
                MOVE.B  D2,0(A0,D3.w)
                BSR     L022A
                ST      L0371
                RTS
L00E6:
                CMPI.W  #$77,L03DD
                BEQ     L00E7
                ADDQ.W  #1,L03DD
                RTS
L00E7:
                CLR.W   L03DD
                RTS
L00E8:
                TST.W   L03DD
                BEQ     L00E9
                SUBQ.W  #1,L03DD
                RTS
L00E9:
                MOVE.W  #$77,L03DD
                RTS
L00EA:
                CMPI.W  #$77,L03DE
                BEQ     L00EB
                ADDQ.W  #1,L03DE
                RTS
L00EB:
                CLR.W   L03DE
                RTS
L00EC:
                TST.W   L03DE
                BEQ     L00ED
                SUBQ.W  #1,L03DE
                RTS
L00ED:
                MOVE.W  #$77,L03DE
                RTS
L00EE:          CMPI.W  #$10,L03DC
                BEQ     L00EF
                ADDQ.W  #1,L03DC
                MOVE.W  L03DC,L03B2
                RTS
L00EF:          MOVE.W  #2,L03DC
                RTS
L00F0:          CMPI.W  #2,L03DC
                BEQ     L00F1
                SUBQ.W  #1,L03DC
                MOVE.W  L03DC,L03B2
                RTS
L00F1:          MOVE.W  #$0F,L03DC
                RTS
L00F2:          MOVE.W  #8,L03DC
                RTS
L00F3:          ADDQ.W  #1,L03BC
                ANDI.W  #lv,L03BC
                RTS
L00F4:
                SUBQ.W  #1,L03BC
                ANDI.W  #lv,L03BC
                RTS

L00F5:          MOVE.W  #1,L03BC
                RTS

add_octave:     CMPI.B  #7,L03BB
                BEQ     L00F7
                ADDI.B  #1,L03BB
                RTS

L00F7:          CLR.B   L03BB
                RTS

sub_octave:     TST.B   L03BB
                BEQ     L00F9
                SUBI.B  #1,L03BB
                RTS

L00F9:          MOVE.B  #7,L03BB
                RTS

L00FA:          TST.W   L03A2
                BEQ     L00CE
                SUBQ.W  #1,L03A2
                BSR     L0255
                RTS
L00FB:          CMPI.W  #$48,L03A2
                BEQ     L00CE
                ADDQ.W  #1,L03A2
                BSR     L0255
                RTS
L00FC:          MOVEA.L instrument_adr,A1
                TST.B   L03A6
                BEQ.S   L00FD
                ADDA.L  #$E6,A1
L00FD:          MOVE.W  $0A(A1),D2
                ADDQ.W  #1,D2
                CMP.W   $0C(A1),D2
                BEQ     L00CE
                MOVE.W  D2,$0A(A1)
                BSR     L0255
                RTS
L00FE:          MOVEA.L instrument_adr,A1
                TST.B   L03A6
                BEQ.S   L00FF
                ADDA.L  #$E6,A1
L00FF:
                TST.W   $0A(A1)
                BEQ     L00CE
                SUBQ.W  #1,$0A(A1)
                BSR     L0255
                RTS
L0100:
                MOVEA.L instrument_adr,A1
                TST.B   L03A6
                BEQ.S   L0101
                ADDA.L  #$E6,A1
L0101:
                MOVE.W  $0C(A1),D2
                ADDQ.W  #1,D2
                CMP.W   $0E(A1),D2
                BEQ     L00CE
                MOVE.W  D2,$0C(A1)
                BSR     L0255
                RTS
L0102:
                MOVEA.L instrument_adr,A1
                TST.B   L03A6
                BEQ.S   L0103
                ADDA.L  #$E6,A1
L0103:
                MOVE.W  $0C(A1),D2
                SUBQ.W  #1,D2
                CMP.W   $0A(A1),D2
                BEQ     L00CE
                MOVE.W  D2,$0C(A1)
                BSR     L0255
                RTS
L0104:          MOVEA.L instrument_adr,A1
                TST.B   L03A6
                BEQ.S   L0105
                ADDA.L  #$E6,A1
L0105:          CMPI.W  #$70,$0E(A1)
                BEQ     L00CE
                ADDQ.W  #1,$0E(A1)
                BSR     L0255
                RTS

L0106:          MOVEA.L instrument_adr,A1
                TST.B   L03A6
                BEQ.S   L0107
                ADDA.L  #$E6,A1
L0107:          MOVE.W  $0E(A1),D2
                SUBQ.W  #1,D2
                CMP.W   $0C(A1),D2
                BEQ     L00CE
                MOVE.W  D2,$0E(A1)
                BSR     L0255
                RTS

L0108:          MOVEA.L instrument_adr,A1
                BTST    #0,X_MOUSE_REL
                BEQ.S   L0109
                ADDI.B  #1,4(A1)
                BCLR    #3,2(A1)
                RTS
L0109:          ADDQ.W  #1,4(A1)
                BCLR    #3,2(A1)
                RTS
L010A:          MOVEA.L instrument_adr,A1
                BTST    #0,X_MOUSE_REL
                BEQ.S   L010B
                SUBI.B  #1,4(A1)
                BCLR    #3,2(A1)
                RTS
L010B:          SUBQ.W  #1,4(A1)
                BCLR    #3,2(A1)
                RTS
L010C:          MOVEA.L instrument_adr,A1
                CLR.W   4(A1)
                BCLR    #3,2(A1)
                RTS

L010D:          MOVEA.L instrument_adr,A1
                ADDI.B  #1,3(A1)        ; Octave >
                ANDI.B  #7,3(A1)
                ORI.B   #8,3(A1)
                RTS

L010E:          MOVEA.L instrument_adr,A1
                SUBI.B  #1,3(A1)        ; Octave <
                ANDI.B  #7,3(A1)
                ORI.B   #8,3(A1)
                RTS

L010F:          MOVEA.L instrument_adr,A1
                MOVE.B  #8,3(A1)        ; Max. Octave
                RTS

L0110:          MOVEA.L instrument_adr,A1
                ADDQ.W  #1,6(A1)        ; Volume >
                ANDI.W  #$0F,6(A1)      ;
                RTS

L0111:          MOVEA.L instrument_adr,A1
                SUBQ.W  #1,6(A1)        ; Volume <
                ANDI.W  #$0F,6(A1)
                RTS

L0112:          MOVEA.L instrument_adr,A1
                CLR.W   6(A1)           ; Silence
                RTS

L0113:          MOVEA.L instrument_adr,A1
                TST.W   8(A1)
                BEQ     L0114
                SUBQ.W  #1,8(A1)
                RTS

L0114:          MOVEA.L instrument_adr,A1
                MOVE.W  #$80,8(A1)
                RTS

L0115:          MOVEA.L instrument_adr,A1
                CMPI.W  #$80,8(A1)
                BEQ     L0116
                ADDQ.W  #1,8(A1)
                RTS
L0116:          CLR.W   8(A1)
                RTS

add_nois_freq:  MOVEA.L instrument_adr,A1
                ADDQ.W  #1,(A1)         ; Instrument Nummer >
                ANDI.W  #$7F,(A1)
                RTS

sub_nois_freq:  MOVEA.L instrument_adr,A1
                SUBQ.W  #1,(A1)         ; Instrument Nummer <
                ANDI.W  #$7F,(A1)
                RTS

reset_nois_freq:MOVEA.L instrument_adr,A1
                CLR.W   (A1)            ; No Instrument
                RTS

add_interv_1:   MOVEA.L instrument_adr,A1
                CMPI.W  #$FF,$FC(A1)    ; Interval 1
                BEQ     go_zero_1
                ADDQ.W  #1,$FC(A1)
                RTS
go_zero_1:      MOVEA.L instrument_adr,A1
                CLR.W   $FC(A1)
                RTS

sub_interv_1:   MOVEA.L instrument_adr,A1
                TST.W   $FC(A1)
                BEQ     go_ful_1
                SUBQ.W  #1,$FC(A1)
                RTS
go_ful_1:       MOVE.W  #$FF,$FC(A1)
                RTS

add_interv_2:   MOVEA.L instrument_adr,A1
                CMPI.W  #$FF,$FE(A1)    ; Interval 2
                BEQ     go_zero_2
                ADDQ.W  #1,$FE(A1)
                RTS
go_zero_2:      MOVEA.L instrument_adr,A1
                CLR.W   $FE(A1)
                RTS
sub_interv_2:   MOVEA.L instrument_adr,A1
                TST.W   $FE(A1)
                BEQ     go_ful_2
                SUBQ.W  #1,$FE(A1)
                RTS
go_ful_2:       MOVE.W  #$FF,$FE(A1)
                RTS

add_tone_fx:    MOVE.B  instr_num,D0
                LEA     spec_table,A5
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A5
                ADDQ.B  #1,1(A5)
                CMPI.B  #tones_max,1(A5)
                BLE.S   okay_tones
                MOVE.B  #0,1(A5)
okay_tones:     RTS

sub_tone_fx:    MOVE.B  instr_num,D0
                LEA     spec_table,A5
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A5
                SUBQ.B  #1,1(A5)
                CMPI.B  #0,1(A5)
                BGE.S   okay_sub_tones
                MOVE.B  #tones_max,1(A5)
okay_sub_tones: RTS

add_wave_fx:    MOVE.B  instr_num,D0
                LEA     spec_table,A5
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A5
                ADDQ.B  #1,2(A5)
                CMPI.B  #waves_max,2(A5)
                BLE.S   okay_waves
                MOVE.B  #0,2(A5)
okay_waves:     RTS

sub_wave_fx:    MOVE.B  instr_num,D0
                LEA     spec_table,A5
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A5
                SUBQ.B  #1,2(A5)
                CMPI.B  #0,2(A5)
                BGE.S   okay_sub_waves
                MOVE.B  #waves_max,2(A5)
okay_sub_waves: RTS

add_special_fx: MOVE.B  instr_num,D0
                LEA     spec_table,A5
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A5
                ADDQ.B  #1,3(A5)
                CMPI.B  #special_fx_max,3(A5)
                BLE.S   okay_sp
                CLR.B   3(A5)
okay_sp:        RTS

sub_special_fx: MOVE.B  instr_num,D0
                LEA     spec_table,A5
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A5
                SUBQ.B  #1,3(A5)
                CMPI.B  #0,3(A5)
                BGE.S   okay_sp1
                MOVE.B  #special_fx_max,3(A5)
okay_sp1:       RTS

add_nois_fx:    MOVE.B  instr_num,D0
                LEA     spec_table,A5
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A5
                ADDQ.B  #1,(A5)
                CMPI.B  #nois_max,(A5)
                BLE.S   okay_nois
                CLR.B   (A5)
okay_nois:      RTS

sub_nois_fx:    MOVE.B  instr_num,D0
                LEA     spec_table,A5
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A5
                SUBQ.B  #1,(A5)
                CMPI.B  #0,(A5)
                BGE.S   okay_nois2
                MOVE.B  #nois_max,(A5)
okay_nois2:     RTS

L0122:          MOVEA.L instrument_adr,A1
                BCHG    #2,2(A1)
                RTS
L0123:          MOVEA.L instrument_adr,A1
                BCHG    #0,2(A1)
                RTS
L0124:          MOVEA.L instrument_adr,A1
                BCHG    #1,2(A1)
                RTS
L0125:          MOVEA.L instrument_adr,A1
                BCHG    #3,2(A1)
                RTS

L0126:          NOT.B   L03A6
                ST      L036B
                BSR     L0255
                RTS
L0127:          NOT.B   L03B5
                RTS

L0128:          SUBI.B  #1,L03B6
                BPL.S   L0129
                MOVE.B  #2,L03B6
L0129:
                RTS

L012A:          TST.B   L03A6
                BNE.S   L012C
                MOVEA.L instrument_adr,A0
                ADDA.L  #$10,A0
                SUBI.W  #$10,D0
                LSR.W   #2,D0
                ADD.W   L03A2,D0
                SUBI.W  #$14,D1
                LSR.W   #2,D1
                NOT.W   D1
                ANDI.B  #$0F,D1
                BTST    #0,X_MOUSE_REL
                BNE.S   L012B
                MOVE.B  D1,0(A0,D0.w)
                BSR     L0255
                RTS
L012B:
                LEA     0(A0,D0.w),A2
                MOVE.L  #$70,D2
                SUB.W   D0,D2
                LEA     0(A0,D0.w),A0
                LEA     1(A0),A1
                MOVE.L  D2,D0
                BSR     L01F8
                MOVE.B  D1,(A2)
                BSR     L0255
                RTS

L012C:          MOVEA.L instrument_adr,A0
                ADDA.L  #$80,A0
                SUBI.W  #$10,D0
                LSR.W   #2,D0
                ADD.W   L03A2,D0
                SUBI.W  #$33,D1
                CMPI.W  #$FFE1,D1
                BLT.S   L012D
                CMPI.W  #$1F,D1
                BGT.S   L012D
                ASL.W   #2,D1
                BTST    #0,X_MOUSE_REL
                BNE.S   L012E
                MOVE.B  D1,0(A0,D0.w)
                BSR     L0255
L012D:          RTS
L012E:          LEA     0(A0,D0.w),A2
                MOVE.L  #$70,D2
                SUB.W   D0,D2
                LEA     0(A0,D0.w),A0
                LEA     1(A0),A1
                MOVE.L  D2,D0
                BSR     L01F8
                MOVE.B  D1,(A2)
                BSR     L0255
                RTS
L012F:
                MOVE.W  Y_MOUSE_POS,D2
                CMP.W   #$10,D2
                BCS     L0131
                CMP.W   #$0130,D2
                BHI     L0131
                MOVE.W  L0367,D1
                CMP.W   #$14,D1
                BCS     L0131
                CMP.W   #$53,D1
                BHI     L0131
                MOVEA.L instrument_adr,A0
                ADDA.L  #$10,A0
                TST.B   L03A6
                BEQ.S   L0130
                ADDA.L  #$70,A0
L0130:
                SUBI.W  #$10,D2
                LSR.W   #2,D2
                ADD.W   L03A2,D2
                MOVE.L  #$70,D0
                SUB.W   D2,D0
                LEA     0(A0,D2.w),A1
                LEA     1(A1),A0
                BSR     L01F8
                BSR     L0255
L0131:
                RTS
L0132:
                MOVE.W  Y_MOUSE_POS,D2
                CMP.W   #$10,D2
                BCS     L0131
                CMP.W   #$0130,D2
                BHI     L0131
                MOVE.W  L0367,D1
                CMP.W   #$14,D1
                BCS     L0131
                CMP.W   #$53,D1
                BHI     L0131
                MOVEA.L instrument_adr,A0
                ADDA.L  #$10,A0
                TST.B   L03A6
                BEQ.S   L0133
                ADDA.L  #$70,A0
L0133:
                SUBI.W  #$10,D2
                LSR.W   #2,D2
                ADD.W   L03A2,D2
                CLR.B   0(A0,D2.w)
                BSR     L0255
                RTS
L0134:
                CMPI.W  #$5C,L03B3
                BEQ.S   L0135
                ADDQ.W  #4,L03B3
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                BSR     L0246
L0135:
                RTS
L0136:
                TST.W   L03B3
                BEQ.S   L0135
                SUBQ.W  #4,L03B3
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                BSR     L0246
                RTS
L0137:
                SUBQ.W  #1,pos_in_pat
                ANDI.W  #lv,pos_in_pat
                MOVE.W  #1,L03B2
                ST      L0371
                RTS
L0138:
                ADDQ.W  #1,pos_in_pat
                ANDI.W  #lv,pos_in_pat
                MOVE.W  #1,L03B2
                ST      L0371
                RTS
L0139:
                CLR.W   pos_in_pat
                MOVE.W  #1,L03B2
                ST      L0371
                RTS
L013A:
                MOVE.W  #$10,pos_in_pat
                MOVE.W  #1,L03B2
                ST      L0371
                RTS
L013B:
                MOVE.W  #$20,pos_in_pat
                MOVE.W  #1,L03B2
                ST      L0371
                RTS
L013C:
                MOVE.W  #$30,pos_in_pat
                MOVE.W  #1,L03B2
                ST      L0371
                RTS
L013D:
                BSR     L0185
                BSET    #0,$3A(A0)
                CLR.L   (A1)
                MOVE.W  L03BC,D1
                MOVE.W  #1,L03BC
                ST      L0376
L013E:
                TST.B   L0376
                BNE.S   L013E
                MOVE.W  D1,L03BC
                RTS
L013F:
                BSR     L0185
                BSET    #0,$3A(A0)
                CLR.L   (A1)
                ST      L0376
                RTS
L0140:
                BSR     L0185
                MOVE.W  #lv,D0
                SUB.W   pos_in_pat,D0
                BRA.S   L0142
L0141:
                MOVE.L  $0C(A1),(A1)
                ADDA.L  #$0C,A1
L0142:
                DBRA    D0,L0141
                CLR.L   (A1)
                ST      L0371
                RTS
L0143:
                BSR     L0185
                MOVE.W  #lv,D0
                SUB.W   pos_in_pat,D0
                MOVE.W  D0,D1
                MULU    #$0C,D1
                ADDA.W  D1,A1
                BRA.S   L0145
L0144:
                SUBA.L  #$0C,A1
                MOVE.L  (A1),$0C(A1)
L0145:
                DBRA    D0,L0144
                CLR.L   (A1)
                ST      L0371
                RTS
L0146:
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                MOVEA.L act_pat_adr,A1
                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                ADDA.L  0(A2,D0.w),A1
                LEA     L0398,A0
                MOVE.W  #lv,D0
L0147:
                MOVE.L  (A1),(A0)+
                CLR.L   (A1)+
                ADDQ.L  #8,A1
                DBRA    D0,L0147
                MOVE.W  #1,L038F
                CLR.B   L0390
                ST      L0371
                ST      L035B
                RTS
L0148:
                CMPI.W  #1,L038F
                BNE.S   L014A
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                BSR     L0153
                LEA     L0398,A1
                MOVE.W  #lv,D0
L0149:
                MOVE.L  (A1)+,(A0)+
                ADDQ.L  #8,A0
                DBRA    D0,L0149
                ST      L0371
L014A:
                ST      L035B
                RTS
L014B:
                CMPI.W  #1,L038F
                BNE.S   L014A
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                BSR     L0153
                LEA     L0398,A1
                MOVE.W  #lv,D0
L014C:
                MOVE.L  (A1)+,D1
                ANDI.L  #$FF000000,D1
                BEQ.S   L014D
                MOVE.L  -4(A1),(A0)
L014D:
                ADDA.L  #$0C,A0
                DBRA    D0,L014C
                ST      L0371
                ST      L035B
                RTS
L014E:
                CMPI.W  #1,L038F
                BNE     L014A
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                BSR     L0153
                LEA     L0398,A1
                MOVE.W  #lv,D0
L014F:
                MOVE.L  (A0)+,D1
                ANDI.L  #$FF000000,D1
                BNE.S   L0150
                MOVE.L  (A1),-4(A0)
L0150:
                ADDQ.L  #8,A0
                ADDQ.L  #4,A1
                DBRA    D0,L014F
                ST      L0371
                ST      L035B
                RTS
L0151:
                CMPI.W  #1,L038F
                BNE     L014A
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                BSR     L0153
                LEA     L0399,A1
                MOVE.W  #lv,D0
L0152:
                MOVE.L  -(A1),(A0)+
                ADDQ.L  #8,A0
                DBRA    D0,L0152
                ST      L0371
                ST      L035B
                RTS
L0153:
                MOVEA.L act_pat_adr,A0
                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                MOVE.L  0(A2,D0.w),D0
                BEQ.S   L0156
                ADDA.L  D0,A0
                LEA     L0398,A1
                MOVE.W  #lv,D0
L0154:
                TST.L   (A1)+
                BPL.S   L0155
                CLR.L   -4(A1)
L0155:
                DBRA    D0,L0154
L0156:
                RTS
L0157:
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                MOVEA.L act_pat_adr,A1
                LEA     L0398,A0
                MOVE.W  #lv,D0
L0158:
                MOVE.L  (A1),(A0)+
                CLR.L   (A1)+
                MOVE.L  (A1),(A0)+
                CLR.L   (A1)+
                MOVE.L  (A1),(A0)+
                CLR.L   (A1)+
                DBRA    D0,L0158
                MOVE.W  #2,L038F
                CLR.B   L0390
                ST      L0371
                ST      L035B
                RTS
L0159:
                CMPI.W  #2,L038F
                BNE     L00CE
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                MOVEA.L act_pat_adr,A1
                LEA     L0398,A0
                MOVE.W  #lv,D0
L015A:
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                DBRA    D0,L015A
                ST      L0371
                ST      L035B
                RTS
L015B:
                MOVE.W  pattern_,L0391
                MOVE.W  pos_in_pat,L0392
                MOVE.W  L03B3,L0393
                BSET    #0,L0390
                CLR.W   L038F
                BRA.S   L015D
L015C:
                MOVE.W  pattern_,L0394
                MOVE.W  pos_in_pat,L0395
                MOVE.W  L03B3,L0396
                BSET    #1,L0390
                CLR.W   L038F
L015D:
                CMPI.B  #3,L0390
                BNE     L0160
                MOVE.W  L0391,D0
                CMP.W   L0394,D0
                BNE     L0160
                LEA     L02A7,A0
                MOVE.W  L0393,D0
                MOVE.L  0(A0,D0.w),D0
                MOVE.W  L0396,D1
                CMP.L   0(A0,D1.w),D0
                BNE     L0160
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                MOVEA.L act_pat_adr,A0
                LEA     L02A7,A1
                MOVE.W  L0393,D0
                ADDA.L  0(A1,D0.w),A0
                MOVE.W  L0392,D0
                MOVE.W  L0395,D1
                LEA     L0398,A1
                CLR.W   L0397
L015E:
                MOVE.W  D0,D2
                MULU    #$0C,D2
                MOVE.L  0(A0,D2.w),(A1)+
                ADDQ.W  #1,L0397
                CMP.W   D0,D1
                BEQ.S   L015F
                ADDQ.W  #1,D0
                ANDI.W  #lv,D0
                BRA.S   L015E
L015F:
                MOVE.W  #3,L038F
L0160:
                ST      L035B
                RTS
L0161:
                CMPI.B  #3,L0390
                BNE.S   L0160
                MOVE.W  L0391,D0
                CMP.W   L0394,D0
                BNE.S   L0160
                LEA     L02A7,A0
                MOVE.W  L0393,D0
                MOVE.L  0(A0,D0.w),D0
                MOVE.W  L0396,D1
                CMP.L   0(A0,D1.w),D0
                BNE.S   L0160
                BSR     L0185
                MOVEA.L act_pat_adr,A0
                ADDA.L  D0,A0
                MOVE.W  L0392,D0
                MOVE.W  L0395,D1
L0162:
                MOVE.W  D0,D2
                MULU    #$0C,D2
                CLR.L   0(A0,D2.w)
                CMP.W   D0,D1
                BEQ.S   L0163
                ADDQ.W  #1,D0
                ANDI.W  #lv,D0
                BRA.S   L0162
L0163:
                ST      L0371
                ST      L035B
                RTS
L0164:
                CMPI.W  #3,L038F
                BNE     L0160
                BSR     L0185
                BSR     L0153
                LEA     L0398,A1
                MOVE.W  pos_in_pat,D0
                MOVE.W  L0397,D1
                BRA.S   L0166
L0165:
                MOVE.W  D0,D2
                MULU    #$0C,D2
                MOVE.L  (A1)+,0(A0,D2.w)
                ADDQ.W  #1,D0
                ANDI.W  #lv,D0
L0166:
                DBRA    D1,L0165
                ST      L0371
                ST      L035B
                RTS
L0167:
                CMPI.W  #3,L038F
                BNE     L0160
                BSR     L0185
                BSR     L0153
                LEA     L0398,A1
                MOVE.W  pos_in_pat,D0
                MOVE.W  L0397,D1
                BRA.S   L016A
L0168:
                MOVE.L  (A1)+,D3
                ANDI.L  #$FF000000,D3
                BEQ.S   L0169
                MOVE.W  D0,D2
                MULU    #$0C,D2
                MOVE.L  -4(A1),0(A0,D2.w)
L0169:
                ADDQ.W  #1,D0
                ANDI.W  #lv,D0
L016A:
                DBRA    D1,L0168
                ST      L0371
                ST      L035B
                RTS
L016B:
                CMPI.W  #3,L038F
                BNE     L0160
                BSR     L0185
                BSR     L0153
                LEA     L0398,A1
                MOVE.W  pos_in_pat,D0
                MOVE.W  L0397,D1
                BRA.S   L016E
L016C:
                MOVE.W  D0,D2
                MULU    #$0C,D2
                MOVE.L  0(A0,D2.w),D3
                ANDI.L  #$FF000000,D3
                BNE.S   L016D
                MOVE.L  (A1),0(A0,D2.w)
L016D:
                ADDQ.W  #1,D0
                ANDI.W  #lv,D0
                ADDQ.L  #4,A1
L016E:
                DBRA    D1,L016C
                ST      L0371
                ST      L035B
                RTS
L016F:
                CMPI.W  #3,L038F
                BNE     L0160
                BSR     L0185
                BSR     L0153
                LEA     L0398,A1
                MOVE.W  pos_in_pat,D0
                MOVE.W  L0397,D1
                MOVE.W  D1,D2
                ASL.W   #2,D2
                ADDA.W  D2,A1
                BRA.S   L0171
L0170:
                MOVE.W  D0,D2
                MULU    #$0C,D2
                MOVE.L  -(A1),0(A0,D2.w)
                ADDQ.W  #1,D0
                ANDI.W  #lv,D0
L0171:
                DBRA    D1,L0170
                ST      L0371
                ST      L035B
                RTS
L0172:
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                MOVEA.L act_pat_adr,A1
                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                ADDA.L  0(A2,D0.w),A1
                MOVE.W  #$3F,D0
L0173:
                MOVE.B  (A1),D1
                BEQ.S   L0175
                BMI.S   L0175
                CMPI.B  #$7C,D1
                BEQ.S   L0175
                MOVE.B  D1,D2
                LSR.B   #4,D1
                ANDI.B  #$0F,D2
                ADDI.B  #1,D2
                CMPI.B  #$0D,D2
                BNE.S   L0174
                MOVE.B  #1,D2
                ADDI.B  #1,D1
L0174:
                ASL.B   #4,D1
                OR.B    D2,D1
                MOVE.B  D1,(A1)
L0175:
                ADDA.L  #$0C,A1
                DBRA    D0,L0173
                ST      L0371
                RTS
L0176:
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                MOVEA.L act_pat_adr,A1
                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                ADDA.L  0(A2,D0.w),A1
                MOVE.W  #$3F,D0
L0177:
                MOVE.B  (A1),D1
                BEQ.S   L0179
                BMI.S   L0179
                CMPI.B  #1,D1
                BEQ.S   L0179
                MOVE.B  D1,D2
                LSR.B   #4,D1
                ANDI.B  #$0F,D2
                SUBI.B  #1,D2
                BNE.S   L0178
                MOVE.B  #$0C,D2
                SUBI.B  #1,D1
L0178:
                ASL.B   #4,D1
                OR.B    D2,D1
                MOVE.B  D1,(A1)
L0179:
                ADDA.L  #$0C,A1
                DBRA    D0,L0177
                ST      L0371
                RTS
L017A:
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                MOVEA.L act_pat_adr,A1
                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                ADDA.L  0(A2,D0.w),A1
                MOVE.W  #$3F,D0
L017B:
                TST.B   (A1)
                BEQ.S   L017C
                BMI.S   L017C
                MOVE.B  3(A1),D1
                MOVE.B  D1,D2
                ANDI.B  #$1F,D1
                CMP.B   #$0F,D1
                BEQ.S   L017C
                ADDI.B  #1,D1
                ANDI.B  #$C0,D2
                OR.B    D1,D2
                MOVE.B  D2,3(A1)
L017C:
                ADDA.L  #$0C,A1
                DBRA    D0,L017B
                ST      L0371
                RTS
L017D:
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                BSR     L0185
                MOVEA.L act_pat_adr,A1
                MOVE.W  L03B3,D0
                LEA     L02A7,A2
                ADDA.L  0(A2,D0.w),A1
                MOVE.W  #$3F,D0
L017E:
                TST.B   (A1)
                BEQ.S   L017F
                BMI.S   L017F
                MOVE.B  3(A1),D1
                MOVE.B  D1,D2
                ANDI.B  #$1F,D1
                BEQ.S   L017F
                SUBI.B  #1,D1
                ANDI.B  #$C0,D2
                OR.B    D1,D2
                MOVE.B  D2,3(A1)
L017F:
                ADDA.L  #$0C,A1
                DBRA    D0,L017E
                ST      L0371
                RTS
L0180:
                BSR     L0185
                LEA     L0398,A0
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A1
                MOVE.L  0(A1,D0.w),(A0)+
                MOVE.L  4(A1,D0.w),(A0)+
                MOVEA.L instrument_adr,A1
                MOVE.W  #$FF,D0
L0181:
                MOVE.B  (A1)+,(A0)+
                DBRA    D0,L0181
                BSR     L01DA
                BSR     L0255
                MOVE.W  #4,L038F
                CLR.B   L0390
                ST      L0371
                ST      L035B
                RTS
L0182:
                CMPI.W  #4,L038F
                BNE.S   L0184
                BSR     L0185
                LEA     L0398,A1
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                MOVE.L  (A1)+,0(A0,D0.w)
                MOVE.L  (A1)+,4(A0,D0.w)
                MOVEA.L instrument_adr,A0
                MOVE.W  #$FF,D0
L0183:
                MOVE.B  (A1)+,(A0)+
                DBRA    D0,L0183
                CLR.B   L0390
                BSR     L0255
L0184:
                ST      L035B
                RTS
L0185:
                MOVEM.L D0/A0-A1,-(SP)
                MOVEA.L act_pat_adr,A0
                MOVE.L  A0,L039D
                LEA     L039F,A1
                MOVE.W  #lv,D0
L0186:
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                DBRA    D0,L0186
                LEA     L038F,A0
                LEA     L039A,A1
                MOVE.W  #$0311,D0
L0187:
                MOVE.B  (A0)+,(A1)+
                DBRA    D0,L0187
                LEA     instr_datas,A0
                MOVE.B  instr_num,D0
                ANDI.W  #$3F,D0
                ASL.W   #8,D0
                ADDA.W  D0,A0
                MOVE.L  A0,L039C
                LEA     L03A0,A1
                MOVE.W  #$FF,D0
L0188:
                MOVE.B  (A0)+,(A1)+
                DBRA    D0,L0188
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A0
                MOVE.L  A0,L039B
                LEA     L039E,A1
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0),(A1)+
                ST      L03A1
                MOVEM.L (SP)+,D0/A0-A1
                RTS
L0189:
                TST.B   L03A1
                BEQ.S   L018D
                MOVEA.L L039D,A1
                LEA     L039F,A0
                MOVE.W  #lv,D0
L018A:
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                DBRA    D0,L018A
                LEA     L038F,A1
                LEA     L039A,A0
                MOVE.W  #$0311,D0
L018B:
                MOVE.B  (A0)+,(A1)+
                DBRA    D0,L018B
                MOVEA.L L039C,A1
                LEA     L03A0,A0
                MOVE.W  #$FF,D0
L018C:
                MOVE.B  (A0)+,(A1)+
                DBRA    D0,L018C
                MOVEA.L L039B,A1
                LEA     L039E,A0
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)
                ST      L0371
                CLR.B   L03A1
L018D:
                RTS
L018E:
                BSR     L0189
                BSR     L0255
                RTS
shift_dwn:
                CMPI.W  #$6F,L03A7
                BEQ.S   L0190
                ADDQ.W  #1,L03A7
L0190:
                RTS
shift_up:       TST.W   L03A7
                BEQ.S   L0190
                SUBQ.W  #1,L03A7
                RTS

L0192:          MOVE.W  #1,what_function
                CLR.W   pos_in_pat
                BRA     draw_function

L0193:          MOVE.W  #2,what_function
                CLR.W   pos_in_pat
                BSR     reset_clock
                BRA     draw_function

L0194:          MOVE.W  #3,what_function
                CLR.W   pos_in_pat
                BSR     reset_clock
                BRA     draw_function

L0195:          MOVE.W  #4,what_function
                CLR.W   pos_in_pat
                BSR     reset_clock
                BRA     draw_function

stop_music:     CLR.W   what_function
                BSR     clear_ym

                MOVEA.L screen,A1
                LEA     160*56(A1),A1
                ADDQ.W  #8,A1
                MOVEA.L A1,A0
                MOVEQ   #30-1,D0
                MOVEQ   #0,D1
clear_dis2:
x               SET 0
                REPT 5
                MOVE.W  D1,x(A1)
x               SET x+8
                ENDR
                LEA     160(A1),A1
                DBRA    D0,clear_dis2


draw_function:  ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                CLR.B   L03B7
                MOVE.W  what_function,D0
                ASL.W   #2,D0

                LEA     L02D0,A0
                MOVE.L  0(A0,D0.w),key_table_pnt

                LEA     function_gfx_tab,A0
                MOVEA.L 0(A0,D0.w),A1
                ST      L0371
                MOVEA.L screen,A0
                ADDA.L  #$3B60,A0
                MOVEQ   #$14,D0
L0198:          MOVEQ   #6,D1
L0199:          MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L0199
                ADDA.L  #$68,A0
                DBRA    D0,L0198

                MOVE.W  #1,L03B2

                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                RTS
L019A:
                CLR.W   L03B3
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                BSR     L0246
                RTS
L019B:
                MOVE.W  #$20,L03B3
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                BSR     L0246
                RTS
L019C:
                MOVE.W  #lv+1,L03B3
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                BSR     L0246
                RTS
L019D:
                ST      L036B
                BSET    #0,a_11
                BCHG    #2,a_11
                BNE.S   L019E
                MOVE    #$2700,SR
                BCLR    #1,a_11
                BCLR    #5,-$05F9
                MOVE    #$2300,SR
L019E:
                RTS
L019F:
                ST      L036B
                BSET    #0,b_11
                BCHG    #2,b_11
                RTS
L01A0:
                ST      L036B
                BSET    #0,c_11
                BCHG    #2,c_11
                RTS

L01A1:          TST.W   L03A4
                BEQ.S   L01A2
                MOVE.W  L03A4,L03DC
                MOVE.W  L03A4,merk_speed
                CLR.W   L03A4
L01A2:          MOVE.B  L03A5,D0
                ANDI.B  #4,D0
                BEQ.S   L01A3
                MOVE.B  L03A5,b_11
                CLR.B   L03A5
L01A3:
                CLR.W   what_function
                BSR     clear_ym

song_editor:    MOVE.L  #song_edit_mous_tab,mouse_tab_pnt
                MOVE.L  #MOUSE_POINTER,WHAT_MOUSE
                MOVE.L  #L023C,vbl_call
                CLR.B   ste_page
                CLR.B   recording_flag
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                ST      L035B
                ST      L0371
                CLR.B   song_edit_flag
                CLR.B   L0355
                CLR.B   L0373
                CLR.B   synth_flag
                CLR.B   info_page_flag
                BSR     set_cols
                BSR     L01A5
                RTS

L01A5:          CLR.W   sid_norm
                MOVE.L  #editor_buff,what_buff+2
                MOVE.L  #editor_buff,what_buff2+2
                MOVE.B  #1,show_info    ; SID Spectrum allowed
                MOVE.B  #1,_clock
                MOVEA.L screen,A0
                CLR.B   ste_page
                LEA     EDIT_PIC,A1
                MOVE.W  #4000-1,D0
L01A6:          MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                CLR.W   (A0)+
                DBRA    D0,L01A6

                BSR     L01B6
                BSR     draw_function
                BSR     L023C
                BSR     L0246
                BSR     INSTR_TXT_SET
                RTS

L01A7:          CLR.W   sid_norm
                MOVE.B  #1,show_info    ; SID Spectrum allowed
                MOVE.B  #1,_clock
                MOVEA.L screen,A0
                MOVE.L  #editor_buff,what_buff+2
                MOVE.L  #editor_buff,what_buff2+2
                CLR.B   ste_page
                LEA     EDIT_PIC,A1
                MOVE.W  #$013F,D0
L01A8:
                MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                CLR.W   (A0)+
                DBRA    D0,L01A8
                BSR     L01B6
                BSR     L023C
                RTS
                EVEN
show_info:      DC.B 1
                EVEN

instr_editor:   MOVE.L  #instr_edit_mouse_tab,mouse_tab_pnt
                MOVE.L  #MOUSE_POINTER2,WHAT_MOUSE
                MOVE.L  #L0248,vbl_call
                MOVE.L  #L02B2,key_table_pnt
                MOVE.B  #0,show_info    ; SID Spectrum not allowed
                MOVE.B  #0,_clock
                CLR.B   ste_page
                CLR.B   recording_flag
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                ST      L0355
                ST      song_edit_flag
                MOVE.W  #6,what_function
                BSR     clear_ym
                TST.W   L03A4
                BNE.S   L01AA
                MOVE.W  L03DC,L03A4
                MOVE.W  #2,L03DC
L01AA:
                MOVE.B  b_11,L03A5
                MOVE.B  #1,b_11
                BSR     L01AB
nothing:        RTS

ste_digi_edit:  MOVE.L  #ste_digi_mouse_tab,mouse_tab_pnt
                MOVE.L  #MOUSE_POINTER2,WHAT_MOUSE
                MOVE.L  #nothing,vbl_call
                MOVE.L  #L02B3,key_table_pnt
                MOVE.B  #0,show_info    ; SID Spectrum not allowed
                MOVE.B  #0,_clock
                MOVE.B  #1,ste_page

                CLR.B   recording_flag

                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359

                ST      L0355
                ST      song_edit_flag

*                MOVE.W  #6,what_function
*                BSR     clear_ym

*                TST.W   L03A4
*                BNE.S   x01AA
*                MOVE.W  L03DC,L03A4
*                MOVE.W  #2,L03DC
*x01AA:          MOVE.B  b_11,L03A5
*                MOVE.B  #1,b_11

                MOVE.W  #0,sid_norm
                MOVEA.L screen,A0
                LEA     ste_digi_PIC,A1
                MOVE.W  #4000-1,D0
copy_digi:      MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                ADDQ.L  #2,A0
                DBRA    D0,copy_digi
                RTS


L01AB:          MOVE.W  #1,sid_norm
                MOVEA.L screen,A0
                MOVE.L  #instr_buff,what_buff+2
                MOVE.L  #instr_buff,what_buff2+2
                MOVE.B  #0,show_info    ; SID Spectrum not allowed
                MOVE.B  #0,_clock
                LEA     YM_EDIT_PIC,A1
                MOVE.W  #4000-1,D0
L01AC:
                MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                ADDQ.L  #2,A0
                DBRA    D0,L01AC

                MOVEA.L screen,A0
                LEA     instr_buff,A1   ; Zwei Rettbuffer
                MOVEA.L A0,A2           ;merken!
                LEA     144*160(A0),A0
                LEA     160-16(A0),A0
                MOVEQ   #0,D1
                MOVEQ   #42-1,D0

n_scr1:         MOVEM.W (A0),D1-D4
                MOVEM.W D1-D4,(A1)
                MOVEM.W 8(A0),D1-D4
                MOVEM.W D1-D4,8(A1)
                LEA     16(A1),A1
                LEA     160(A0),A0
                DBRA    D0,n_scr1

                BSR     L0254
                BSR     L0248
                RTS

L01AD:          MOVE.W  #1,sid_norm
                MOVE.B  #0,show_info
                MOVE.B  #1,_clock
                MOVEA.L screen,A0
                MOVE.L  #instr_buff,what_buff+2
                MOVE.L  #instr_buff,what_buff2+2
                LEA     YM_EDIT_PIC,A1
                MOVE.W  #$013F,D0
L01AE:          MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                CLR.W   (A0)+
                DBRA    D0,L01AE
                RTS

*******************************************_-------------_----------_
prep_info_page:
                MOVE.B  #0,show_info    ; Kein SID Spectrum
                MOVE.B  #0,_clock
                MOVE.L  #info_mouse_tab,mouse_tab_pnt
                MOVE.L  #L0272,vbl_call
                MOVE.L  #L02B3,key_table_pnt
                ST      L0355
                ST      song_edit_flag
                CLR.B   recording_flag
                ST      L035B
                ST      L0373
                ST      info_page_flag
                BSR     set_cols
                MOVE.W  #1,L03A8
                MOVE.W  #1,L03A9

                MOVEA.L screen,A0
                MOVE.W  #7999,D0
c_scr:          CLR.L   (A0)+
                DBRA    D0,c_scr

                MOVEA.L screen,A0
                LEA     info_bar,A1
                MOVE.W  #399,D0
L01B0:          MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                ADDQ.L  #2,A0
                DBRA    D0,L01B0
                RTS

L01B3:
                MOVE.B  #1,L0370
                BRA.S   L01B6
L01B4:
                MOVE.B  #2,L0370
                BRA.S   L01B6
QUIT_CURRENT_BOX:
                CLR.B   L0370
L01B6:          MOVEQ   #0,D0
                MOVE.B  L0370,D0
                ASL.W   #3,D0
                LEA     GFX_N_MOUSE_TAB,A0
                MOVE.L  0(A0,D0.w),L036D
                MOVEA.L 4(A0,D0.w),A0
                CMPA.L  #DIGI_BOX,A0
                BNE.S   no_draw
                MOVE.B  #1,show_info
                MOVE.B  #1,_clock
                BRA.S   do_the_draw
no_draw:        MOVE.B  #0,show_info
                MOVE.B  #1,_clock
do_the_draw:    MOVEA.L screen,A1
                ADDA.L  #$0780,A1
                MOVEQ   #$4D,D0
L01B7:
                MOVE.L  (A0)+,(A1)
                MOVE.W  (A0)+,4(A1)
                MOVE.L  (A0)+,8(A1)
                MOVE.W  (A0)+,$0C(A1)
                MOVE.L  (A0)+,$10(A1)
                MOVE.W  (A0)+,$14(A1)
                MOVE.L  (A0)+,$18(A1)
                MOVE.W  (A0)+,$1C(A1)
                MOVE.L  (A0)+,$20(A1)
                MOVE.W  (A0)+,$24(A1)
                MOVE.L  (A0)+,$28(A1)
                MOVE.W  (A0)+,$2C(A1)
                MOVE.L  (A0)+,$30(A1)
                MOVE.W  (A0)+,$34(A1)
                MOVE.L  (A0)+,$38(A1)
                MOVE.W  (A0)+,$3C(A1)
                ADDA.L  #$A0,A1
                DBRA    D0,L01B7
                ST      L036B
                RTS
L01B8:
                MOVE.W  D1,D3
                LEA     mulu_160,A1
                ADD.W   D1,D1
                MOVE.W  0(A1,D1.w),D1
*                MULU    #$A0,D1
                MOVEA.L screen,A1

                CMPI.W  #$C0,D0
                BLS.S   L01B9
                MOVE.W  #$C0,D0
L01B9:
                ANDI.W  #$F0,D0
                MOVE.W  D0,D2
                LSR.W   #1,D0
                ADD.W   D0,D1
                LEA     0(A1,D1.w),A1
                MOVEA.L A1,A3
                LEA     alertbox,A0
                LEA     L03E2,A2
                MOVE.W  #$22,D1
L01BA:
                MOVE.L  (A1),(A2)+
                MOVE.L  (A0)+,(A1)
                MOVE.W  4(A1),(A2)+
                MOVE.W  (A0)+,4(A1)
                MOVE.L  8(A1),(A2)+
                MOVE.L  (A0)+,8(A1)
                MOVE.W  $0C(A1),(A2)+
                MOVE.W  (A0)+,$0C(A1)
                MOVE.L  $10(A1),(A2)+
                MOVE.L  (A0)+,$10(A1)
                MOVE.W  $14(A1),(A2)+
                MOVE.W  (A0)+,$14(A1)
                MOVE.L  $18(A1),(A2)+
                MOVE.L  (A0)+,$18(A1)
                MOVE.W  $1C(A1),(A2)+
                MOVE.W  (A0)+,$1C(A1)
                MOVE.L  $20(A1),(A2)+
                MOVE.L  (A0)+,$20(A1)
                MOVE.W  $24(A1),(A2)+
                MOVE.W  (A0)+,$24(A1)
                MOVE.L  $28(A1),(A2)+
                MOVE.L  (A0)+,$28(A1)
                MOVE.W  $2C(A1),(A2)+
                MOVE.W  (A0)+,$2C(A1)
                ADDA.L  #$A0,A1
                DBRA    D1,L01BA
L01BB:
                MOVE.B  X_MOUSE_REL,D0
                ANDI.B  #3,D0
                BNE.S   L01BB
L01BC:
                MOVE.B  X_MOUSE_REL,D0
                ANDI.B  #3,D0
                BEQ.S   L01BC
                LEA     L02B4,A0
                MOVE.W  Y_MOUSE_POS,D0
                SUB.W   D2,D0
                MOVE.W  L0367,D1
                SUB.W   D3,D1
L01BD:
                CMP.W   (A0),D0
                BCS.S   L01BE
                CMP.W   2(A0),D1
                BCS.S   L01BE
                CMP.W   4(A0),D0
                BHI.S   L01BE
                CMP.W   6(A0),D1
                BHI.S   L01BE
                MOVE.W  8(A0),D0
                BRA.S   L01BF
L01BE:
                ADDA.L  #$0A,A0
                TST.L   4(A0)
                BNE.S   L01BD
                BRA.S   L01BC
L01BF:
                LEA     L03E2,A0
                MOVE.W  #$22,D1
L01C0:
                MOVE.L  (A0)+,(A3)
                MOVE.W  (A0)+,4(A3)
                MOVE.L  (A0)+,8(A3)
                MOVE.W  (A0)+,$0C(A3)
                MOVE.L  (A0)+,$10(A3)
                MOVE.W  (A0)+,$14(A3)
                MOVE.L  (A0)+,$18(A3)
                MOVE.W  (A0)+,$1C(A3)
                MOVE.L  (A0)+,$20(A3)
                MOVE.W  (A0)+,$24(A3)
                MOVE.L  (A0)+,$28(A3)
                MOVE.W  (A0)+,$2C(A3)
                ADDA.L  #$A0,A3
                DBRA    D1,L01C0
                ST      L035B
                ST      L036B
                RTS
L01C1:
                CMPI.W  #$20,L03DF
                BEQ     L00CE
                ST      L03B7
                MOVE.W  L03DF,D0
                ADDQ.W  #1,L03DF
                LEA     L03E1,A0
                MULU    #$0300,D0
                ADDA.W  D0,A0
                MOVE.W  #lv,D0
L01C2:
                CLR.L   (A0)+
                CLR.L   (A0)+
                CLR.L   (A0)+
                DBRA    D0,L01C2
                BSR     L022A
                ST      L0371
                ST      L036B
                RTS
L01C3:
                CMPI.W  #1,L03DF
                BEQ     L00CE
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
                ST      L03B7
                SUBQ.W  #1,L03DF
                MOVEA.L act_pat_adr,A1
                LEA     $0300(A1),A0
                MOVE.L  #L03E2,D0
                SUB.L   A0,D0
                BSR     L01F8
                LEA     L03E0,A0
                MOVE.W  pattern_,D0
                MOVEQ   #$77,D1
L01C4:
                MOVE.B  (A0),D2
                BEQ.S   L01C5
                CMP.B   D0,D2
                BCS.S   L01C5
                SUBI.B  #1,(A0)
L01C5:
                ADDQ.L  #1,A0
                DBRA    D1,L01C4
                BSR     L022A
                ST      L0371
                ST      L036B
                RTS

L01C6:          MOVE.W  #$11,L03AC
                MOVE.W  #$20,L03AD
                CLR.W   L03AE
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                ST      recording_flag
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A0
                MOVE.L  A0,L03AF
                RTS


L01C8:
                MOVE.W  #$11,L03AC
                MOVE.W  #$0C,L03AD
                CLR.W   L03AE
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                ST      recording_flag
                MOVE.L  #L03DA,L03AF
                RTS
L01C9:
                MOVE.W  #$1F,L03AC
                MOVE.W  #$65,L03AD
                CLR.W   L03AE
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                BSET    #0,b_11
                ST      recording_flag
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A0
                MOVE.L  A0,L03AF
                ST      L036B
                RTS
L01CA:
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
L01CB:
                BSR     L01D0
                BSR     L01CD
                RTS
L01CC:
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
L01CD:
                BSR     clear_ym
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  #$20202020,L03DA
                MOVE.L  #$20202020,L03DB
                LEA     L03DC,A0
                MOVE.W  #$0380,D0
L01CE:
                CLR.B   (A0)+
                DBRA    D0,L01CE
                MOVE.W  #8,L03DC
                MOVE.W  #1,L03DF
                CLR.W   song_position
                BSR     L022A
                ST      L0371
                BSR     clear_ym
                ST      L036B
                RTS
L01CF:
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
L01D0:
                ST      L03B7
                LEA     instr_datas,A1
                MOVE.W  #$3F,D0
L01D1:
                MOVE.W  #$FF,D1
L01D2:
                CLR.B   0(A1,D1.w)
                DBRA    D1,L01D2
                MOVE.W  #1,$0C(A1)
                MOVE.W  #2,$0E(A1)
                MOVE.W  #1,$F2(A1)
                MOVE.W  #2,$F4(A1)
                MOVE.B  #1,2(A1)
                MOVE.B  #8,3(A1)
                MOVE.W  #$0B,8(A1)
                ADDA.L  #$0100,A1
                DBRA    D0,L01D1
                LEA     instr_names,A1
                MOVE.W  #$3F,D0
L01D3:
                MOVE.L  #$20202020,(A1)+
                MOVE.L  #$20202020,(A1)+
                DBRA    D0,L01D3
                BSR     L01D5
                RTS
L01D4:          BSR     L01B8
                TST.W   D0
                BNE     L00CE

L01D5:          BSR     clear_ym
                ST      L03B7
                ST      L036B
                RTS
L01D8:
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
                BSR     clear_ym
                ST      L03B7
                MOVE.L  #1,D4
                BSR     L01F4
                ST      (A4)
                ST      L036B
                RTS
L01D9:
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
                ST      L03B7
L01DA:
                BSR     clear_ym
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                MOVE.W  D0,D1
                LEA     instr_names,A0
                ASL.W   #3,D0
                MOVE.L  #$20202020,0(A0,D0.w)
                MOVE.L  #$20202020,4(A0,D0.w)
                ASL.W   #8,D1
                LEA     instr_datas,A1
                LEA     0(A1,D1.w),A1
                MOVE.W  #$FF,D1
L01DB:
                CLR.B   0(A1,D1.w)
                DBRA    D1,L01DB
                MOVE.W  #1,$0C(A1)
                MOVE.W  #2,$0E(A1)
                MOVE.W  #1,$F2(A1)
                MOVE.W  #2,$F4(A1)
                MOVE.B  #1,2(A1)
                MOVE.B  #8,3(A1)
                MOVE.W  #$0B,8(A1)
                ST      L036B
                RTS
                ENDPART
**********************************************************
                >PART 'LOADING/SAVING Routs'

LOAD_SONG:      MOVE.B  #0,_clock
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
                BSR     L01EC
                CLR.B   L0374
                BSR     L01EF
                DC.B $A0,$09
                LEA     L037A,A4
                LEA     L037B,A5
                BSR     CALL_FSEL

                DC.B 'JGg',$00,$02,$C8,$A0,$0A
                DC.B $08,$F9,$00,$04
                DC.L L0374

                BSR     L01A5
                BSR     L01EF
                DC.B $A0,$09
                ST      L03B7
                BSR     clear_ym
                LEA     L0379,A5
                LEA     L03DC,A6
                MOVE.L  #"TSST",D6
                MOVE.L  #$6080,D7
                BSR     LOAD_DIS
                TST.W   D0
                BNE.S   L01DD
                CLR.W   song_position
                CLR.W   pos_in_pat
                BSR     L022A
                LEA     L03DA,A0
                LEA     L037B,A2
                BSR     L0210
L01DD:
                BSR     L01ED
                JSR     reset_all
                JSR     reset_clock
                RTS

SAVE_SONG:
                MOVE.B  #0,_clock
                BSR     L01EC
                MOVE.B  #1,L0374
                BSR     L01EF
                LINEA   #$09 [ Showm ]

                LEA     L03DA,A0
                LEA     L030F,A1
                LEA     L037B,A2
                BSR     set_song

                LEA     L037A,A4
                LEA     L037B,A5
                BSR     CALL_FSEL

                DC.B 'JGg',$00,$02,'&',$A0,$0A
                DC.B $08,$F9,$00,$04
                DC.L L0374

                BSR     L01A5
                BSR     L01EF
                DC.B $A0,$09

                LEA     L0379,A5
                LEA     L03DC,A6
                MOVE.L  #"TSST",D6
                MOVE.L  #$80,D7
                MOVE.W  L03DF,D5
                MULU    #768,D5
                ADD.L   D5,D7

                BSR     SAVE_DIS
                BSR     L01ED
                RTS


*SAVE_VSET:
                RTS

LOAD_VSET:      MOVE.B  #0,_clock
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
                BSR     L01EC
                MOVE.B  #2,L0374
                BSR     L01EF
                DC.B $A0,$09
                LEA     L037C,A4
                LEA     L037D,A5
                BSR     CALL_FSEL

                DC.B 'JGg',$00
                BCLR    D0,$0A(A2,A2.w)
                BSET    #4,L0374

                BSR     L01A5
                BSR     L01EF
                DC.B $A0,$09
                ST      L03B7
                BSR     clear_ym
                LEA     L0379,A5
                LEA     instr_names,A6
                MOVE.L  #$54535353,D6
                MOVE.L  #$024310,D7
                BSR     LOAD_DIS
                BSR     calc_sam_adr
                ST      a_10
                ST      b_10
                ST      c_10
                BSR     L01ED

                LEA     sam_names+4,A1
                CMPI.L  #"INFO",sam_names
                BEQ.S   copy_information
                LEA     standard,A1
                MOVE.B  #0,new_format
copy_information:
                LEA     spec_table,A2
                MOVE.W  #253,D0
copy_spec_dwn:  MOVE.B  (A1)+,(A2)+
                DBRA    D0,copy_spec_dwn
                CMPI.L  #"INFO",sam_names
                BNE.S   out_
                MOVE.B  #1,new_format
out_:           JSR     reset_all
                RTS
                EVEN
new_format:     DC.B 0
                EVEN
SAVE_VSET:      MOVE.B  #0,_clock
                BSR     L01EC
                MOVE.B  #3,L0374
                BSR     L01EF
                LINEA   #$09 [ Showm ]
                LEA     L037C,A4
                LEA     L037D,A5
                BSR     CALL_FSEL

                LEA     sam_names,A1
                MOVE.L  #"INFO",(A1)
                ADDQ.L  #4,A1
                LEA     spec_table,A2

                MOVE.W  #253,D0
copy_spec:      MOVE.B  (A2)+,(A1)+
                DBRA    D0,copy_spec

                DC.B 'JGg',$00
                BTST    D0,$0A(A4,A2.w)
                BSET    #4,L0374

                BSR     L01A5
                BSR     L01EF
                DC.B $A0,$09
                LEA     L0379,A5

                LEA     instr_names,A6
                MOVE.L  #"TSSS",D6
                MOVE.L  #17168,D7
                ADD.L   dummy,D7
                BSR     SAVE_DIS

                BSR     L01ED
                RTS

LOAD_YM_SOUND:  MOVE.B  #0,_clock
                BSR     L01B8
                TST.W   D0
                BNE     L00CE
                BSR     L01EC
                MOVE.B  #4,L0374
                BSR     L01EF
                DC.B $A0,$09
                LEA     L037E,A4
                LEA     L037F,A5
                BSR     CALL_FSEL
                DC.B 'JGg',$00,$FF,$C2,$A0,$0A
                DC.B $08,$F9,$00,$04
                DC.L L0374
                BSR     L01A5
                BSR     L01EF
                DC.B $A0,$09
                ST      L03B7
                BSR     clear_ym
                LEA     L0379,A5
                LEA     instr_datas,A6
                MOVE.B  instr_num,D0
                ANDI.W  #$3F,D0
                ASL.W   #8,D0
                ADDA.W  D0,A6
                MOVE.L  #"TSSY",D6
                MOVE.L  #$0100,D7
                BSR     LOAD_DIS
                TST.W   D0
                BNE.S   L01E7
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A0
                LEA     L037F,A2
                BSR     L0210
                ST      a_10
                ST      b_10
                ST      c_10
L01E7:          BSR     L01ED
                RTS

SAVE_YM_SOUND:  MOVE.B  #0,_clock
                BSR     L01EC
                MOVE.B  #5,L0374
                BSR     L01EF
                DC.B $A0,$09
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A0
                LEA     L0312,A1
                LEA     L037F,A2
                BSR     set_song
                LEA     L037E,A4
                LEA     L037F,A5
                BSR     CALL_FSEL

                DC.B 'JGg',$00,$FE,$F6,$A0,$0A
                DC.B $08,$F9,$00,$04
                DC.L L0374
                BSR     L01A5
                BSR     L01EF
                DC.B $A0,$09

                LEA     instr_datas,A6

                MOVE.B  instr_num,D0
                ASL.W   #8,D0
                ADDA.W  D0,A6

                MOVE.L  #"TSSY",D6

                LEA     L0379,A5

                MOVE.L  #$0100,D7
                BSR     SAVE_DIS
                BSR     L01ED
                RTS

MAKE_MODULE:    MOVE.B  #0,_clock
                BSR     L01EC
                MOVE.B  #1,L0374
                BSR     L01EF
                LINEA   #$09 [ Showm ]

                LEA     L03DA,A0
                LEA     L030F,A1
                LEA     L037B,A2
                BSR     set_song

                LEA     L037A,A4
                LEA     L037B,A5
                BSR     CALL_FSEL

                DC.B 'JGg',$00,$00,$C6,$A0,$0A
                DC.B $08,$F9,$00,$04
                DC.L L0374

                BSR     L01A5
                BSR     L01EF
                DC.B $A0,$09

                LEA     L03DC,A6
                MOVE.L  #$80,D7
                MOVE.W  L03DF,D5
                MULU    #768,D5
                ADD.L   D5,D7
                MOVE.L  D7,D0           ; in D0.l SONG Lenght
                MOVE.L  D0,D5

                LEA     L03DC,A6        ; Songadresse
                LEA     BUFF,A5         ; IN DEN BUFFER KOPIEREN
                MOVE.L  #"SID!",(A5)+   ; KENNUNG SCHREIBEN
COPY_DOWN:      MOVE.B  (A6)+,(A5)+     ; SONG DATEN IN BUFFER
                DBRA    D5,COPY_DOWN

                LEA     instr_names,A6
                MOVE.L  #"TSSS",D6
                MOVE.L  #17168,D7
                MOVE.L  D7,D5

                LEA     BUFF,A5
                ADDA.L  D0,A5           ; BIS LETZTES BYTE "SONG"
                MOVE.L  #"VSET",(A5)+   ; KENNUNG SCHREIBEN
COPY_DOWN2:     MOVE.B  (A6)+,(A5)+     ; INSTRUMENT DATEN IN BUFFER
                DBRA    D5,COPY_DOWN2

                LEA     mod_replay,A6
                LEA     repl_buff,A5
                MOVE.W  #8157,D6
copy_repl:      MOVE.B  (A6)+,(A5)+
                DBRA    D6,copy_repl

                LEA     repl_buff,A0

                CLR.L   $1E94(A0)
                CLR.L   $1E98(A0)

                MOVE.L  #8134,$1E94(A0) ;Als PC-Offset fr Song
                MOVE.L  D0,$1E98(A0)
                ADDI.L  #8134,$1E98(A0) ; Als PC-Offset fr Vset

                LEA     L0379,A5
                LEA     repl_buff,A6
                ADDI.L  #8158,D0
                ADD.L   D0,D7

                BSR     SAVE_DIS_speciale
                BSR     L01ED
                RTS


L01E9:          BSR     L01B8
                TST.W   D0
                BNE     L00CE
                BSR     L01EC
                MOVE.B  #4,L0374
                BSR     L01EF
                DC.B $A0,$09
                LEA     L037E,A4
                LEA     L037F,A5
                BSR     CALL_FSEL
                DC.B 'JGg',$00
                ORI     #$A00A,SR
                BSET    #4,L0374
                BSR     L01AB
                BSR     L01EF
                DC.B $A0,$09
                LEA     L0379,A5
                LEA     instr_datas,A6
                MOVE.B  instr_num,D0
                ANDI.W  #$3F,D0
                ASL.W   #8,D0
                ADDA.W  D0,A6
                MOVE.L  #$54535359,D6
                MOVE.L  #$0100,D7
                BSR     LOAD_DIS
                TST.W   D0
                BNE.S   L01EA
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A0
                LEA     L037F,A2
                BSR     L0210
                ST      a_10
                ST      b_10
                ST      c_10
L01EA:
                BSR     L01EE
                BSR     L0254
                RTS
                DC.B $A0,$0A
                BSR     L01AB
                DC.B $A0,$09
                BSR     L01EE
                RTS
L01EB:
                BSR     L01EC
                MOVE.B  #5,L0374
                BSR     L01EF
                DC.B $A0,$09
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A0
                LEA     L0312,A1
                LEA     L037F,A2
                BSR     set_song
                LEA     L037E,A4
                LEA     L037F,A5
                BSR     CALL_FSEL
                DC.B 'JGg',$00,$FF,$A8,$A0,$0A
                DC.B $08,$F9,$00,$04
                DC.L L0374
                BSR     L01AB
                BSR     L01EF
                DC.B $A0,$09
                LEA     L0379,A5
                LEA     instr_datas,A6
                MOVE.B  instr_num,D0
                ANDI.W  #$3F,D0
                ASL.W   #8,D0
                ADDA.W  D0,A6
                MOVE.L  #$54535359,D6
                MOVE.L  #$0100,D7
                BSR     SAVE_DIS
                BSR     L01EE
                RTS
L01EC:
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                CLR.B   L0356
                ST      song_edit_flag
                ST      L0373
                BSR     L020A
                ST      L03B7
                MOVEA.L L03C8,A0
                LEA     L03C9,A2
                MOVE.L  #L03CA,L03C8
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C6,A0
                LEA     L03C7,A2
                MOVE.L  #L03CA,L03C6
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVEA.L L03C4,A0
                LEA     L03C5,A2
                MOVE.L  #L03CA,L03C4
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                MOVE.L  (A2)+,(A0)+
                CLR.B   L03B7
                BSR     L007E
                MOVE    #$2700,SR
                BSR     L000E
                MOVE    #$2300,SR
                BSR     L007F
                BSR     L0207
                BSR     INIT_AES
                MOVE.W  #0,-(SP)
                MOVE.W  #$0B,-(SP)
                TRAP    #$0D
                ADDQ.L  #4,SP
                RTS

L01ED:          CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                CLR.B   L0356
                BSR     INIT_AES
                BSR     L0209
                DC.B $A0,$0A,'a',$00
                BCHG    D1,-(A0)
                BSR     L007E
                MOVE    #$2700,SR
                BSR     L000F
                MOVE    #$2300,SR
                BSR     L007F
                CLR.B   song_edit_flag
                CLR.B   L03B7
                CLR.B   L0373
                BSR     L01A7
                RTS
L01EE:
                CLR.B   L0357
                CLR.B   L0358
                CLR.B   L0359
                CLR.B   L0356
                BSR     INIT_AES
                BSR     L0209
                DC.B $A0,$0A,'a',$00,$03,$0E
                BSR     L007E
                MOVE    #$2700,SR
                BSR     L000F
                MOVE    #$2300,SR
                BSR     L007F
                CLR.B   L03B7
                CLR.B   L0373
                BSR     L01AD
                RTS
L01EF:
                MOVEQ   #0,D7
                MOVE.B  L0374,D7
                MOVEA.L screen,A0
                ADDQ.L  #8,A0
                MOVEQ   #$0F,D0
                MOVE.L  #$FFFF0000,D5
                MOVEQ   #0,D6
L01F0:
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                MOVE.L  D5,(A0)+
                MOVE.L  D6,(A0)+
                ADDA.L  #$10,A0
                DBRA    D0,L01F0
                BCLR    #4,D7
                BEQ.S   L01F1
                MOVE.W  #2,text_xpos
                MOVE.W  #8,text_ypos
                LEA     L0379,A2
                BSR     L028A
L01F1:
                MOVE.W  #2,text_xpos
                MOVE.W  #0,text_ypos
                ASL.W   #2,D7
                LEA     L0305,A2
                MOVEA.L 0(A2,D7.w),A2
                BSR     L028A
                RTS
L01F2:          MOVE.W  #2,-(SP)
                MOVE.W  #2,-(SP)
                TRAP    #$0D
                ADDQ.L  #4,SP

INIT_AES:       MOVE.W  #2,-(SP)
                MOVE.W  #1,-(SP)
                TRAP    #$0D
                ADDQ.L  #4,SP
                TST.W   D0
                BNE.S   L01F2
                RTS
L01F4:
                LEA     L03D2,A2
                LEA     sam_offset_tab,A3
                MOVE.W  sam_num,D2
                MOVE.W  D2,D1
                ASL.W   #2,D2
                MOVE.L  total_sam_lenght,D0
                SUB.L   0(A3,D2.w),D0
                ADD.L   D4,D0
                CMP.L   #$020000,D0
                BHI.S   L01F7
                MOVEA.L 4(A2,D2.w),A0
                MOVEA.L 0(A2,D2.w),A1
                MOVEA.L A1,A4
                ADDA.L  D4,A1
                MOVE.L  D4,0(A3,D2.w)
                CMPI.W  #$0F,D1
                BEQ.S   L01F6
                MOVEQ   #$0F,D1
                MOVEQ   #0,D0
L01F5:
                ADD.L   4(A3,D2.w),D0
                ADDQ.W  #4,D2
                DBRA    D1,L01F5
                BSR     L01F8
*                BSR     calc_sam_adr
L01F6:
                MOVEQ   #0,D0
                RTS
L01F7:
                MOVEQ   #$FF,D0
                RTS
L01F8:
                TST.L   D0
                BEQ.S   L01FC
                CMPA.L  A0,A1
                BHI.S   L01FA
L01F9:
                MOVE.B  (A0)+,(A1)+
                SUBQ.L  #1,D0
                BNE.S   L01F9
                RTS
L01FA:
                ADDA.L  D0,A0
                ADDA.L  D0,A1
L01FB:
                MOVE.B  -(A0),-(A1)
                SUBQ.L  #1,D0
                BNE.S   L01FB
L01FC:
                RTS

calc_sam_adr:   LEA     L03D2,A0
                LEA     sam_offset_tab,A1
                LEA     first_sample,A2
                MOVEQ   #$0F,D0
                MOVEQ   #0,D1
write_offsets:
                RTS

                MOVE.L  A2,(A0)+
                ADDA.L  (A1),A2
                ADD.L   (A1)+,D1
                DBRA    D0,write_offsets
                MOVE.L  D1,total_sam_lenght
                RTS

LOAD_DIS:       CLR.W   -(SP)
                MOVE.L  A5,-(SP)
                MOVE.W  #$3D,-(SP)
                TRAP    #1
                ADDQ.L  #8,SP
                TST.W   D0
                BMI.S   L0202
                MOVE.W  D0,D5
                PEA     KENNUNGS_LONG
                MOVE.L  #4,-(SP)
                MOVE.W  D5,-(SP)
                MOVE.W  #$3F,-(SP)
                TRAP    #1
                LEA     $0C(SP),SP
                TST.L   D0
                BMI.S   L0201
                CMP.L   KENNUNGS_LONG,D6 ; VERGLEICH OB RICHTIGER DATEITYP
                BNE.S   L0200
                MOVE.L  A6,-(SP)
                MOVE.L  D7,-(SP)
                MOVE.W  D5,-(SP)
                MOVE.W  #$3F,-(SP)
                TRAP    #1
                LEA     $0C(SP),SP
                TST.L   D0
                BMI.S   L0201
                MOVE.W  D5,-(SP)
                MOVE.W  #$3E,-(SP)
                TRAP    #1
                ADDQ.L  #4,SP
                MOVEQ   #0,D0
                RTS


L0200:          MOVEQ   #$C6,D0
L0201:          MOVE.W  D0,D6
                MOVE.W  D5,-(SP)
                MOVE.W  #$3E,-(SP)
                TRAP    #1
                ADDQ.L  #4,SP
                MOVE.W  D6,D0
L0202:          BSR     ERROR_MESSAGE
                MOVEQ   #$FF,D0
                RTS

SAVE_DIS:       CLR.W   -(SP)
                MOVE.L  A5,-(SP)        ; DATEINAME
                MOVE.W  #$3C,-(SP)      ; OPEN FILE
                TRAP    #1
                ADDQ.L  #8,SP
                TST.W   D0
                BMI.S   L0202
                MOVE.W  D0,D5

                MOVE.L  D6,KENNUNGS_LONG ; KENNUNG SETZTEN (Z.B. "TSST")

                PEA     KENNUNGS_LONG
                MOVE.L  #4,-(SP)        ; KENNUNGS BYTES IN DATEI SCHREIBEN
                MOVE.W  D5,-(SP)        ; HANDLER
                MOVE.W  #$40,-(SP)
                TRAP    #1
                LEA     $0C(SP),SP

                TST.L   D0
                BMI     ERROR_CODE      ; IRGENDETWAS PASSIERT ??
                CMP.L   #4,D0
                BNE.S   L0204

                MOVE.L  A6,-(SP)        ; A6 HAT BUFFER
                MOVE.L  D7,-(SP)        ; LAENGE IN BYTES
                MOVE.W  D5,-(SP)        ; HANDLER
                MOVE.W  #$40,-(SP)      ; UND SCHREIBEN ( DEN REST )
                TRAP    #1
                LEA     $0C(SP),SP
                TST.L   D0
                BMI.S   ERROR_CODE
                CMP.L   D7,D0
                BNE.S   L0204

                MOVE.W  D5,-(SP)        ; UND DATEI SCHLIESSEN
                MOVE.W  #$3E,-(SP)
                TRAP    #1
                ADDQ.L  #4,SP
                MOVEQ   #0,D0
                RTS

SAVE_DIS_speciale:
                CLR.W   -(SP)
                MOVE.L  A5,-(SP)        ; DATEINAME
                MOVE.W  #$3C,-(SP)      ; OPEN FILE
                TRAP    #1
                ADDQ.L  #8,SP
                TST.W   D0
                BMI.S   L0202
                MOVE.W  D0,D5

                MOVE.L  A6,-(SP)        ; A6 HAT BUFFER
                MOVE.L  D7,-(SP)        ; LAENGE IN BYTES
                MOVE.W  D5,-(SP)        ; HANDLER
                MOVE.W  #$40,-(SP)      ; UND SCHREIBEN ( DEN REST )
                TRAP    #1
                LEA     $0C(SP),SP

                MOVE.W  D5,-(SP)        ; UND DATEI SCHLIESSEN
                MOVE.W  #$3E,-(SP)
                TRAP    #1
                ADDQ.L  #4,SP
                MOVEQ   #0,D0
                RTS

L0204:          MOVE.W  D5,-(SP)
                MOVE.W  #$3E,-(SP)
                TRAP    #1
                ADDQ.L  #4,SP
                PEA     (A5)
                MOVE.W  #$41,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP
                MOVEQ   #$C5,D0
                BSR     ERROR_MESSAGE
                MOVEQ   #$FF,D0
                RTS

ERROR_CODE:     MOVE.W  D0,D6
                MOVE.W  D5,-(SP)
                MOVE.W  #$3E,-(SP)
                TRAP    #1
                ADDQ.L  #4,SP
                MOVE.W  D6,D0
                BSR     ERROR_MESSAGE
                MOVEQ   #$FF,D0
                RTS

ERROR_MESSAGE:  RTS

                TST.W   D0
                BPL     back_error      ; .s
                CMP.W   #$FFBD,D0
                BLE     s               ; .s
                MOVE.W  #$0700,$FFFF8240.w
                NEG.W   D0
                ASL.W   #2,D0
                LEA     L0314,A0
                MOVE.L  0(A0,D0.w),-(SP)
                LINEA   #$0A [ Hidem ]
                BSR     L01A5
                MOVE.B  #7,L0374
                BSR     L01EF
                LINEA   #$09 [ Showm ]
                BRA     go_dis_way
                DS.W 1000
go_dis_way:     MOVEA.L (SP)+,A2
                MOVE.W  #2,text_xpos
                MOVE.W  #8,text_ypos
                BSR     L028A
                BSR     INIT_AES
s:              CLR.W   $FFFF8240.w
back_error:     RTS

L0207:          LINEA   #$00 [ Init ]
                MOVE.W  Y_MOUSE_POS,-$025A(A0)
                MOVE.W  L0367,-$0258(A0)
                RTS
L0208:          LINEA   #$00 [ Init ]
                MOVE.W  -$025A(A0),Y_MOUSE_POS
                MOVE.W  -$0258(A0),L0367
                RTS

L0209:          MOVE.W  #$25,-(SP)
                TRAP    #$0E
                ADDQ.L  #2,SP
                MOVE.B  #$0E,$FFFF8800.w
                MOVE.B  $FFFF8800.w,D0
                ANDI.B  #6,D0
                CMPI.B  #6,D0
                BNE.S   L0209
                RTS
L020A:          MOVE    #$2700,SR
                MOVE.B  #$0E,$FFFF8800.w
                MOVE.B  $FFFF8800.w,D0
                BSET    #1,D0
                MOVE.B  D0,$FFFF8802.w
                MOVE    #$2300,SR
                RTS

set_song:       MOVEQ   #7,D0
L020C:          CMPI.B  #$20,0(A0,D0.w)
                BNE.S   L020D
                DBRA    D0,L020C
                MOVE.L  #$4E4F4E41,(A2)+
                MOVE.W  #$4D45,(A2)+
                BRA.S   L020F
L020D:
                MOVE.B  (A0)+,D1
                CMPI.B  #$20,D1
                BNE.S   L020E
                MOVE.B  #$5F,D1
L020E:
                MOVE.B  D1,(A2)+
                DBRA    D0,L020D
L020F:
                MOVE.B  (A1)+,(A2)+
                BNE.S   L020F
                RTS
L0210:
                MOVE.L  #$20202020,(A0)
                MOVE.L  #$20202020,4(A0)
L0211:
                MOVE.B  (A2)+,D0
                BEQ.S   L0212
                CMPI.B  #$2E,D0
                BEQ.S   L0212
                MOVE.B  D0,(A0)+
                BRA.S   L0211
L0212:
                RTS

CALL_FSEL:      BSR     sron
                JSR     L0215
                JSR     L0217
                JSR     L0216
exit_fsel:
                BSR     sroff
                JSR     copy_editor_pic
                MOVE.B  #1,_clock
                RTS

L0214:          MOVE.L  #L0321,D1
                MOVE.W  #$C8,D0
                TRAP    #2
                RTS

L0215:          MOVE.W  #$0A,L0384
                CLR.W   L0385
                MOVE.W  #1,L0386
                CLR.W   L0387
                CLR.W   L0388
                JSR     L0214
                MOVE.W  L038A,L0382
                RTS

L0216:          MOVE.W  #$13,L0384
                CLR.W   L0385
                MOVE.W  #1,L0386
                CLR.W   L0387
                CLR.W   L0388
                JSR     L0214
                RTS
L0217:
                MOVE.W  #$5A,L0384
                CLR.W   L0385
                MOVE.W  #2,L0386
                MOVE.W  #2,L0387
                CLR.W   L0388
                MOVE.L  A4,L038C
                MOVE.L  A5,L038D
                JSR     L0214
                TST.W   L038B
                BEQ.S   L021B
                TST.B   (A5)
                BEQ.S   L021B
                LEA     L0379,A3
L0218:          MOVE.B  (A4)+,(A3)+
                BNE.S   L0218
L0219:          CMPI.B  #$5C,-(A3)
                BNE.S   L0219
                ADDQ.L  #1,A3
L021A:          MOVE.B  (A5)+,(A3)+
                BNE.S   L021A
                MOVEQ   #1,D7
                RTS

L021B:          BSR     sroff
                BSR     copy_editor_pic
                BRA     exit_fsel
                RTS

L021C:          LEA     L037A,A2
                MOVE.W  #$19,-(SP)
                TRAP    #1
                ADDQ.L  #2,SP
                ADDI.B  #$41,D0
                MOVE.B  D0,(A2)
                MOVE.B  #$3A,1(A2)
                CLR.W   -(SP)
                PEA     2(A2)
                MOVE.W  #$47,-(SP)
                TRAP    #1
                ADDQ.L  #8,SP
                LEA     L037C,A3
                LEA     L037E,A4
                LEA     L0380,A5
                CLR.W   D1
L021D:          MOVE.B  0(A2,D1.w),D0
                BEQ.S   L021E
                MOVE.B  D0,0(A3,D1.w)
                MOVE.B  D0,0(A4,D1.w)
                MOVE.B  D0,0(A5,D1.w)
                ADDQ.W  #1,D1
                BRA.S   L021D
L021E:          MOVE.W  D1,D3
                MOVE.B  #$5C,0(A2,D1.w)
                LEA     L030E,A0
L021F:          MOVE.B  (A0)+,1(A2,D1.w)
                BEQ.S   L0220
                ADDQ.W  #1,D1
                BRA.S   L021F
L0220:          MOVE.W  D3,D1
                MOVE.B  #$5C,0(A3,D1.w)
                LEA     L0310,A0
L0221:          MOVE.B  (A0)+,1(A3,D1.w)
                BEQ.S   L0222
                ADDQ.W  #1,D1
                BRA.S   L0221
L0222:          MOVE.W  D3,D1
                MOVE.B  #$5C,0(A4,D1.w)
                LEA     L0311,A0
L0223:          MOVE.B  (A0)+,1(A4,D1.w)
                BEQ.S   L0224
                ADDQ.W  #1,D1
                BRA.S   L0223
L0224:          MOVE.W  D3,D1
                MOVE.B  #$5C,0(A5,D1.w)
                LEA     L0313,A0
L0225:
                MOVE.B  (A0)+,1(A5,D1.w)
                BEQ.S   L0226
                ADDQ.W  #1,D1
                BRA.S   L0225
L0226:
                RTS
L0227:
                CLR.W   pos_in_pat
                MOVE.W  song_position,D0
                MOVE.W  what_function,D1
                BTST    #0,D1
                BNE.S   L0228
                BRA.S   L0229
L0228:
                ADDQ.W  #1,D0
                CMP.W   L03DE,D0
                BLS.S   L0229
                MOVE.W  L03DD,D0
L0229:
                MOVE.W  D0,song_position
L022A:
                LEA     L03E0,A0
                MOVE.W  song_position,D0
                MOVE.B  0(A0,D0.w),D0
                ANDI.W  #$7F,D0
                MOVE.W  D0,pattern_
                LEA     L03C0,A0
                ASL.W   #2,D0
                MOVE.L  0(A0,D0.w),act_pat_adr
                RTS

sample_spektr:  MOVEA.L screen,A0
                ADDA.L  #$21CA,A0
                MOVEA.L A0,A1
                MOVE.W  #$0F,D0
L022C:
                CLR.W   (A0)
                CLR.W   8(A0)
                CLR.W   $10(A0)
                CLR.W   $18(A0)
                CLR.W   $20(A0)
                ADDA.L  #$0140,A0
                DBRA    D0,L022C
                MOVEA.L L007D,A0
                BTST    #1,a_11
                BNE.S   L022D
                LEA     L02DA,A0
L022D:          MOVE.W  #4,D0
L022E:          MOVEQ   #7,D2
L022F:          MOVE.B  (A0)+,D1
                BPL.S   L0230
                LEA     L02DA,A0
                MOVE.B  (A0)+,D1
L0230:          ANDI.W  #$0F,D1
                MULU    #$0140,D1
                BSET    D2,0(A1,D1.w)
                DBRA    D2,L022F
                ADDQ.L  #1,A1
                MOVEQ   #7,D2
L0231:          MOVE.B  (A0)+,D1
                BPL.S   L0232
                LEA     L02DA,A0
                MOVE.B  (A0)+,D1
L0232:          ANDI.W  #$0F,D1
                MULU    #$0140,D1
                BSET    D2,0(A1,D1.w)
                DBRA    D2,L0231
                ADDQ.L  #7,A1
                DBRA    D0,L022E
                RTS


VOLU_BARS:      MOVEA.L screen,A1
                LEA     $0AAA(A1),A1
                MOVE.B  adata+14,D2     ;L0341,D2
                MOVEA.L A1,A0
                BSR     volume_bar
                MOVE.B  bdata+14,D2     ;L0327,D2
                LEA     $10(A1),A0
                BSR     volume_bar
                MOVE.B  cdata+14,D2     ;L0334,D2
                LEA     $20(A1),A0
                BSR     volume_bar
                RTS

volume_bar:     MOVE.W  #$0F,D0
                MOVEQ   #0,D1
                SUBQ.B  #1,D2
L0235:          CMP.B   D2,D0
                BNE.S   L0236
                MOVE.W  #%1010101010101010,D1 ; -1
L0236:          MOVE.W  D1,(A0)
                MOVE.W  D1,2(A0)
                LEA     $0140(A0),A0
                DBRA    D0,L0235
                RTS

STE_DIGI_SET:   MOVE.W  text_xpos,-(SP)
                MOVE.W  text_ypos,-(SP)
*************************************************
                MOVE.W  pattern_,D0
                MOVE.W  #$20-9,text_xpos
                MOVE.W  #$3E-9,text_ypos
                BSR     set_numbers
*************************************************
                MOVE.W  #$8B+1,text_ypos
                MOVE.W  pos_in_pat,D7
                SUBQ.W  #3,D7

                MOVEA.L act_pat_adr,A5
                MOVEQ   #6,D6           ; Anzahl Reihen des Patterns

lines_set:      MOVE.W  #1,text_xpos
                MOVE.W  D7,D1
                MOVEA.L A5,A4
                ANDI.W  #$3F,D1         ; Anzahl
                MOVE.W  D1,D0
                MULU    #3*4,D1
                ADDA.W  D1,A4
                BSR     set_numbers
                ADDQ.W  #3,text_xpos
                BSR     update_edit_window
                ADDQ.W  #2,text_xpos
                BSR     update_edit_window
*                ADDQ.W  #2,text_xpos
*                BSR     update_edit_window
                ADDQ.W  #1,D7
                ADDQ.W  #8,text_ypos
                DBRA    D6,lines_set

                MOVE.W  (SP)+,text_ypos
                MOVE.W  (SP)+,text_xpos
                RTS

INSTR_TXT_SET:  MOVE.W  text_xpos,-(SP)
                MOVE.W  text_ypos,-(SP)
*************************************************
                MOVE.W  #$25,text_xpos
                MOVE.W  #$3E,text_ypos
                MOVE.W  song_position,D0
                BSR     set_numbers
*************************************************
                MOVE.W  pattern_,D0
                MOVE.W  #$48,text_ypos
                BSR     set_numbers
*************************************************
                MOVE.W  #$8B,text_ypos
                MOVE.W  pos_in_pat,D7
                SUBQ.W  #3,D7

                MOVEA.L act_pat_adr,A5
                MOVEQ   #6,D6           ; Anzahl Reihen des Patterns

lines:          MOVE.W  #1,text_xpos
                MOVE.W  D7,D1
                MOVEA.L A5,A4
                ANDI.W  #$3F,D1         ; Anzahl
                MOVE.W  D1,D0
                MULU    #3*4,D1
                ADDA.W  D1,A4
                BSR     set_numbers
                ADDQ.W  #3,text_xpos
                BSR     update_edit_window
                ADDQ.W  #2,text_xpos
                BSR     update_edit_window
                ADDQ.W  #2,text_xpos
                BSR     update_edit_window
                ADDQ.W  #1,D7
                ADDQ.W  #8,text_ypos
                DBRA    D6,lines

                MOVE.W  (SP)+,text_ypos
                MOVE.W  (SP)+,text_xpos
                RTS

update_edit_window:
                MOVEQ   #0,D5
                MOVE.B  (A4)+,D5        ; Aktuelle Note nach d5
                BMI.S   set_command_gfx ; Ist es ein Command ???
                MOVE.W  D5,D0

                LEA     tonleiter_tab,A0
                ANDI.W  #$0F,D0
                ADD.W   D0,D0
                MOVE.W  0(A0,D0.w),D4
                MOVE.W  D4,D0
                LSR.W   #8,D0
                BSR     set_text        ; Note

                ADDQ.W  #1,text_xpos
                MOVE.W  D4,D0
                BSR     set_text        ; Black/White Keys
                ADDQ.W  #1,text_xpos

                MOVE.B  D5,D0
                LSR.B   #4,D0
                BSR     set_text        ; Oktave
                ADDQ.W  #1,text_xpos

                BRA.S   skip_command

set_command_gfx:LEA     L02F9,A2
                BSR     set_comm_gfx

skip_command:   MOVE.B  (A4)+,D0
                BSR     set_numbers     ; Portamento
                ADDQ.W  #2,text_xpos

                MOVE.B  (A4)+,D0
                BSR     set_numbers     ; YM-Sound Nummer
                ADDQ.W  #2,text_xpos

                MOVE.B  (A4)+,D5
                MOVE.B  D5,D0
                ANDI.B  #$0F,D0
                BSR     set_text        ; YM-Sound Volume
                ADDQ.W  #1,text_xpos

                MOVE.B  D5,D0
                LSR.B   #6,D0
                BSR     L0287           ; YM-Envelope Value

                RTS

L023C:          MOVE.W  #$25,text_xpos

                MOVE.B  instr_num,D0
                MOVE.W  #$20,text_ypos
                BSR     set_numbers
                MOVE.W  #$2A,text_ypos
                MOVE.B  volume,D0
                BSR     set_numbers
                MOVE.W  #$34,text_ypos
                MOVE.B  pat_pos_count,D0
                BSR     set_numbers
                MOVE.W  #$52,text_ypos
                MOVE.W  L03DE,D0
                BSR     set_numbers
                MOVE.W  #$5C,text_ypos
                MOVE.W  L03DD,D0
                BSR     set_numbers
                MOVE.W  #$66,text_ypos

                MOVE.W  L03DC,D0

                BSR     set_numbers
                MOVE.W  #$70,text_ypos
                MOVE.W  L03BC,D0
                BSR     set_numbers
                MOVE.W  #$7A,text_ypos
                MOVE.B  L03BB,D0
                BSR     set_numbers
                MOVE.W  #$7A,text_ypos
                MOVE.W  #7,text_xpos
                TST.B   L03B5
                BNE.S   L023D
                LEA     L02F9,A2
                BRA.S   L023E
L023D:          LEA     L02FA,A2
L023E:          BSR     set_comm_gfx
                MOVE.W  #$13,text_xpos
                MOVE.B  L03B6,D0
                BEQ.S   L023F
                CMPI.B  #1,D0
                BEQ.S   L0240
                LEA     L02FD,A2
                BRA.S   L0241
L023F:          LEA     L02FB,A2
                BRA.S   L0241
L0240:          LEA     L02FC,A2
L0241:          BSR     set_comm_gfx
                MOVE.W  #$6E,text_ypos
                MOVE.W  #$15,text_xpos
                MOVE.B  a_11,D0
                BSR     L0244
                MOVE.B  b_11,D0
                ADDQ.W  #1,text_xpos
                BSR     L0244
                MOVE.B  c_11,D0
                ADDQ.W  #1,text_xpos
                BSR     L0244
******************************************************
                MOVE.W  #$11,text_xpos
                MOVE.W  #$0C,text_ypos
********************************************
                LEA     L03DA,A2        ; Song Name
                BSR     L0288

                MOVE.W  #$11+10,text_xpos
                MOVE.W  #$0C,text_ypos

                CMPI.B  #1,new_format
                BEQ.S   set_new
                LEA     insig_,A2
                BRA.S   do_
set_new:        LEA     new_,A2
do_:            BSR     x0288

                MOVE.W  #$11,text_xpos
                MOVE.W  #$16,text_ypos
                MOVE.W  sam_num,D0
                ASL.W   #3,D0

*                LEA     L03D6,A0
*                LEA     0(A0,D0.w),A2
*                BSR     L0288

                MOVE.W  #$11,text_xpos
                MOVE.W  #$20,text_ypos
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A2
                BSR     L0288
                TST.B   recording_flag
                BEQ.S   L0242
                BSR     L0285
L0242:          CMPI.B  #2,L0370
                BNE     L0243
                MOVE.W  #$16,text_ypos
                MOVE.W  #5,text_xpos
                MOVE.W  L03DF,D5
                MULU    #$0300,D5
                ADDI.L  #$80,D5
                MOVE.L  total_sam_lenght,D6
                MOVE.L  D5,D0
                ADD.L   D6,D0
                ADDI.L  #$4310,D0
                BSR     L028F
                MOVE.W  #$20,text_ypos
                MOVE.L  D5,D0
                BSR     L028F
                MOVE.W  #$2A,text_ypos
                MOVE.L  D6,D0
                ADDI.L  #$4310,D0
                BSR     L028F
                MOVE.W  #$34,text_ypos
                MOVE.L  D5,D0
                BSR     L028F

*                MOVE.W  #$3E,text_ypos
*                LEA     sam_offset_tab,A0
*                MOVE.W  sam_num,D0
*                ASL.W   #2,D0
*                MOVE.L  0(A0,D0.w),D0
*                BSR     L028F

                MOVE.W  #$48,text_ypos
                MOVE.L  #$0100,D0
                BSR     L028F
                MOVE.W  #$52,text_ypos
                MOVE.L  #$02A390,D0
                SUB.L   D5,D0
                SUB.L   D6,D0
                SUBI.L  #$4310,D0
                BSR     L028F
L0243:          RTS
L0244:          BTST    #2,D0
                BNE.S   L0245
                LEA     L02FE,A2
                BSR     set_comm_gfx
                RTS
L0245:          LEA     L02FF,A2
                BSR     set_comm_gfx
                RTS
L0246:          MOVEA.L screen,A0
                ADDA.L  #$65F2,A0
                MOVEA.L A0,A1
                MOVE.W  #$FFFF,D0
                MOVEQ   #6,D1
L0247:          MOVE.W  D0,(A0)
                MOVE.W  D0,8(A0)
                MOVE.W  D0,$10(A0)
                MOVE.W  D0,$18(A0)
                MOVE.B  D0,$20(A0)
                MOVE.W  D0,$28(A0)
                MOVE.W  D0,$30(A0)
                MOVE.W  D0,$38(A0)
                MOVE.W  D0,$40(A0)
                MOVE.B  D0,$48(A0)
                MOVE.W  D0,$50(A0)
                MOVE.W  D0,$58(A0)
                MOVE.W  D0,$60(A0)
                MOVE.W  D0,$68(A0)
                MOVE.B  D0,$70(A0)
                ADDA.L  #$A0,A0
                DBRA    D1,L0247
                LEA     L02A9,A0
                MOVE.W  L03B3,D0
                ADDA.L  0(A0,D0.w),A1
                CLR.B   (A1)
                CLR.B   $A0(A1)
                CLR.B   $0140(A1)
                CLR.B   $01E0(A1)
                CLR.B   $0280(A1)
                CLR.B   $0320(A1)
                CLR.B   $03C0(A1)
                RTS

L0248:          MOVE.B  instr_num,D0
                LEA     instr_datas,A2
                ANDI.W  #$3F,D0
                ASL.W   #8,D0
                ADDA.W  D0,A2
                MOVE.L  A2,instrument_adr
                ST      b_10
                MOVE.B  L0356,L0357
                MOVE.W  #$58,text_ypos
                MOVE.W  #$17,text_xpos
                MOVE.W  L03A2,D0
                BSR     set_numbers
                MOVE.W  #9,text_xpos
                TST.B   L03A6
                BNE.S   L0249
                LEA     L0304,A2
                BSR     set_comm_gfx
                MOVEA.L instrument_adr,A2
                MOVE.W  #$10,text_xpos
                MOVE.W  #$65,text_ypos
                MOVE.W  $0A(A2),D0
                BSR     set_numbers
                MOVE.W  #$6F,text_ypos
                MOVE.W  $0C(A2),D0
                BSR     set_numbers
                MOVE.W  #$79,text_ypos
                MOVE.W  $0E(A2),D0
                BSR     set_numbers

                BRA.S   L024A
L0249:
                LEA     L0303,A2
                BSR     set_comm_gfx
                MOVEA.L instrument_adr,A2
                MOVE.W  #$10,text_xpos
                MOVE.W  #$65,text_ypos
                MOVE.W  $F0(A2),D0
                BSR     set_numbers
                MOVE.W  #$6F,text_ypos
                MOVE.W  $F2(A2),D0
                BSR     set_numbers
                MOVE.W  #$79,text_ypos
                MOVE.W  $F4(A2),D0
                BSR     set_numbers
L024A:          MOVE.W  #$1F,text_xpos
                MOVE.W  #$6F,text_ypos
                MOVE.B  instr_num,D0
                BSR     set_numbers
                MOVE.W  #$79,text_ypos
                MOVE.B  volume,D0
                BSR     set_numbers
                MOVE.W  #$83,text_ypos
                MOVE.B  L03BB,D0
                BSR     set_numbers
                MOVE.W  #$8D,text_ypos
                MOVE.B  pat_pos_count,D0
                BSR     set_numbers

************************************************************
                MOVE.B  instr_num,D0
                ANDI.W  #$3F,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                LEA     spec_table,A5
                ADDA.W  D0,A5

                MOVE.W  #1,text_ypos
                MOVE.B  1(A5),D0
                BSR     set_numbers

                MOVE.W  #161,text_ypos
                MOVE.B  2(A5),D0
                BSR     set_numbers

                MOVE.W  #171,text_ypos
                MOVE.B  3(A5),D0
                BSR     set_numbers

                MOVE.W  #$10,text_xpos
                MOVE.W  #1,text_ypos
                MOVE.B  0(A5),D0
                BSR     set_numbers

*************************************************

                MOVE.W  #$83,text_ypos
                BTST    #3,2(A2)
                BNE.S   L024B
                MOVE.W  4(A2),D0
                BSR     L0292
                BRA.S   L024C
L024B:          MOVEA.L A2,A3
                LEA     L0302,A2
                BSR     set_comm_gfx
                MOVE.W  #$10,text_xpos
                MOVEA.L A3,A2
L024C:          MOVE.W  #$97,text_ypos
                MOVE.W  (A2),D0
                BSR     set_numbers
                MOVE.W  #$A1,text_ypos
                MOVE.W  6(A2),D0
                BSR     set_numbers
                MOVE.W  #$AB,text_ypos

                MOVEQ   #$0C,D0         ; hier $c

                SUB.W   8(A2),D0
                BSR     set_numbers
                MOVE.W  #$B5,text_ypos
                MOVE.W  $FC(A2),D0
                BSR     set_numbers
                MOVE.W  #$BF,text_ypos
                MOVE.W  $FE(A2),D0
                BSR     set_numbers
                MOVE.B  2(A2),D3
                LEA     L0300,A3
                LEA     L0301,A4
                LEA     L0302,A5
                MOVE.W  #$16,text_xpos
                MOVEA.L A4,A2
                BTST    #0,D3
                BEQ.S   L024D
                MOVEA.L A3,A2
L024D:          BSR     set_comm_gfx
                MOVE.W  #$1A,text_xpos
                MOVEA.L A4,A2
                BTST    #2,D3
                BEQ.S   L024E
                MOVEA.L A3,A2
L024E:          BSR     set_comm_gfx
                MOVE.W  #$1E,text_xpos
                MOVEA.L A4,A2
                BTST    #1,D3
                BEQ.S   L024F
                MOVEA.L A3,A2
L024F:          BSR     set_comm_gfx
                MOVE.W  #$10,text_xpos
                MOVE.W  #$8D,text_ypos
                MOVEA.L instrument_adr,A2
                MOVEQ   #0,D7
                MOVE.B  3(A2),D7
                SUBQ.W  #8,D7
                ASL.W   #3,D7
                LEA     L029A,A5
                LEA     0(A5,D7.w),A2
                BSR     set_comm_gfx
                MOVE.W  #$1F,text_xpos
                MOVE.W  #$65,text_ypos
                MOVEQ   #0,D0
                MOVE.B  instr_num,D0
                ASL.W   #3,D0
                LEA     instr_names,A0
                LEA     0(A0,D0.w),A2
                BSR     L0288
                TST.B   recording_flag
                BEQ.S   L0250
                BSR     L0285
L0250:          MOVE.W  #$1B,text_xpos
                MOVE.W  #$97,text_ypos
                MOVE.B  L03B6,D0
                BEQ.S   L0251
                CMPI.B  #1,D0
                BEQ.S   L0252
                LEA     L02FD,A2
                BRA.S   L0253
L0251:          LEA     L02FB,A2
                BRA.S   L0253
L0252:          LEA     L02FC,A2
L0253:          BSR     set_comm_gfx
                RTS

L0254:          MOVE.B  instr_num,D0    ; Instrument Nummer
                LEA     instr_datas,A2  ; Instr-Tab Adresse
                ANDI.W  #$3F,D0         ; max. 64
                ASL.W   #8,D0           ; *256 (256 Bytes pro Instr.)
                ADDA.W  D0,A2
                MOVE.L  A2,instrument_adr
L0255:          CMPI.W  #6,what_function
                BNE     L00CE
                TST.B   L03A6
                BNE     L0264
                MOVEA.L screen,A0
                ADDA.L  #$0BE8,A0
                MOVE.L  #$77770000,D7
                MOVE.W  #$0F,D0
L0256:          MOVE.W  #$11,D1
L0257:          CLR.L   (A0)+
                CLR.W   (A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L0257
                ADDA.L  #$10,A0
                MOVE.W  #$11,D1
L0258:          MOVE.L  D7,(A0)+
                CLR.W   (A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L0258
                ADDA.L  #$10,A0
                MOVE.W  #$11,D1
L0259:          MOVE.L  D7,(A0)+
                CLR.W   (A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L0259
                ADDA.L  #$10,A0
                MOVE.W  #$11,D1
L025A:          MOVE.L  D7,(A0)+
                CLR.W   (A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L025A
                ADDA.L  #$10,A0
                DBRA    D0,L0256
                MOVE.W  #$11,D1
L025B:          CLR.L   (A0)+
                CLR.W   (A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L025B
                MOVEA.L instrument_adr,A1
                MOVEA.L A1,A2
                MOVE.W  L03A2,D1
                LEA     $10(A1,D1.w),A1

                MOVEA.L screen,A0
                ADDA.L  #$0C88,A0
                MOVE.W  #$8FFF,D7
                MOVE.W  #$7000,D6
                MOVE.W  D6,D5
                MOVE.W  D5,D4
                CMP.W   $0A(A2),D1
                BCS.S   L025C
                MOVEQ   #0,D6
                MOVE.W  D6,D5
                MOVE.W  D5,D4
L025C:          CMP.W   $0C(A2),D1
                BCS.S   L025D
                MOVEQ   #0,D6
                MOVE.W  D6,D4
                MOVE.W  #$7000,D5
L025D:          CMP.W   $0E(A2),D1
                BCS.S   L025E
                MOVE.W  #$5000,D6
                MOVE.W  D6,D5
                MOVEQ   #0,D4
L025E:          MOVE.W  #$47,D3
                MOVEQ   #4,D2
L025F:          MOVE.B  (A1)+,D0
                NOT.B   D0
                ANDI.W  #$0F,D0
                MULU    #$0280,D0
                AND.W   D7,0(A0,D0.w)
                OR.W    D6,0(A0,D0.w)
                OR.W    D5,2(A0,D0.w)
                OR.W    D4,4(A0,D0.w)
                ADDI.W  #$A0,D0
                AND.W   D7,0(A0,D0.w)
                OR.W    D6,0(A0,D0.w)
                OR.W    D5,2(A0,D0.w)
                OR.W    D4,4(A0,D0.w)
                ADDI.W  #$A0,D0
                AND.W   D7,0(A0,D0.w)
                OR.W    D6,0(A0,D0.w)
                OR.W    D5,2(A0,D0.w)
                OR.W    D4,4(A0,D0.w)
                ADDQ.W  #1,D1
                CMP.W   $0A(A2),D1
                BNE.S   L0260
                MOVEQ   #0,D6
                MOVE.W  D6,D5
                MOVE.W  D5,D4
L0260:          CMP.W   $0C(A2),D1
                BNE.S   L0261
                MOVEQ   #0,D6
                MOVE.W  D6,D4
                MOVE.W  #$7000,D5
                ROL.W   D2,D5
                ROL.W   D2,D5
                ROL.W   D2,D5
                ROL.W   D2,D5
L0261:          CMP.W   $0E(A2),D1
                BNE.S   L0262
                MOVE.W  #$5000,D6
                ROL.W   D2,D6
                ROL.W   D2,D6
                ROL.W   D2,D6
                ROL.W   D2,D6
                MOVE.W  D6,D5
                MOVEQ   #0,D4
L0262:          ROR.W   #4,D7
                ROR.W   #4,D6
                ROR.W   #4,D5
                ROR.W   #4,D4
                SUBQ.W  #1,D2
                BNE.S   L0263
                ADDQ.L  #8,A0
                MOVE.W  #4,D2
L0263:          DBRA    D3,L025F
                RTS

L0264:          MOVEA.L screen,A0
                ADDA.L  #$0BE8,A0
                MOVE.L  #$77770000,D7
                MOVE.W  #$1F,D0
L0265:          MOVE.W  #$11,D1
L0266:          MOVE.L  D7,(A0)+
                CLR.W   (A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L0266
                ADDA.L  #$10,A0
                DBRA    D0,L0265
                MOVE.W  #$11,D1
L0267:          CLR.L   (A0)+
                CLR.W   (A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L0267
                ADDA.L  #$10,A0
                MOVE.W  #$1F,D0
L0268:          MOVE.W  #$11,D1
L0269:          MOVE.L  D7,(A0)+
                CLR.W   (A0)+
                ADDQ.L  #2,A0
                DBRA    D1,L0269
                ADDA.L  #$10,A0
                DBRA    D0,L0268
                MOVEA.L instrument_adr,A1
                MOVEA.L A1,A2
                MOVE.W  L03A2,D1
                LEA     0(A1,D1.w),A1
                ADDA.L  #$80,A1
                MOVEA.L screen,A0
                ADDA.L  #$0B48,A0
                MOVE.W  #$8FFF,D7
                MOVE.W  #$7000,D6
                MOVE.W  D6,D5
                MOVE.W  D5,D4
                CMP.W   $F0(A2),D1
                BCS.S   L026A
                MOVEQ   #0,D6
                MOVE.W  D6,D5
                MOVE.W  D5,D4
L026A:          CMP.W   $F2(A2),D1
                BCS.S   L026B
                MOVEQ   #0,D6
                MOVE.W  D6,D4
                MOVE.W  #$7000,D5
L026B:          CMP.W   $F4(A2),D1
                BCS.S   L026C
                MOVE.W  #$5000,D6
                MOVE.W  D6,D5
                MOVEQ   #0,D4
L026C:          MOVE.W  #$47,D3
                MOVEQ   #4,D2
L026D:          MOVEQ   #0,D0
                MOVE.B  (A1)+,D0
                ADDI.B  #$80,D0
                LSR.W   #2,D0
                MULU    #$A0,D0
                LEA     0(A0,D0.w),A3
                AND.W   D7,0(A3)
                OR.W    D6,0(A3)
                OR.W    D5,2(A3)
                OR.W    D4,4(A3)
                AND.W   D7,$A0(A3)
                OR.W    D6,$A0(A3)
                OR.W    D5,$A2(A3)
                OR.W    D4,$A4(A3)
                AND.W   D7,$0140(A3)
                OR.W    D6,$0140(A3)
                OR.W    D5,$0142(A3)
                OR.W    D4,$0144(A3)
                ADDQ.W  #1,D1
                CMP.W   $F0(A2),D1
                BNE.S   L026E
                MOVEQ   #0,D6
                MOVE.W  D6,D5
                MOVE.W  D5,D4
L026E:          CMP.W   $F2(A2),D1
                BNE.S   L026F
                MOVEQ   #0,D6
                MOVE.W  D6,D4
                MOVE.W  #$7000,D5
                ROL.W   D2,D5
                ROL.W   D2,D5
                ROL.W   D2,D5
                ROL.W   D2,D5
L026F:          CMP.W   $F4(A2),D1
                BNE.S   L0270
                MOVE.W  #$5000,D6
                ROL.W   D2,D6
                ROL.W   D2,D6
                ROL.W   D2,D6
                ROL.W   D2,D6
                MOVE.W  D6,D5
                MOVEQ   #0,D4
L0270:          ROR.W   #4,D7
                ROR.W   #4,D6
                ROR.W   #4,D5
                ROR.W   #4,D4
                SUBQ.W  #1,D2
                BNE.S   L0271
                ADDQ.L  #8,A0
                MOVE.W  #4,D2
L0271:          DBRA    D3,L026D
                RTS

L0272:          LEA     L031F,A2
                MOVE.W  L03A7,D0
                BRA.S   L0274
L0273:          CMPI.B  #$0D,(A2)+
                BNE.S   L0273
L0274:          DBRA    D0,L0273
                LEA     font_8x8,A3
                MOVEQ   #$13,D3
                MOVE.W  #4,text_xpos
                MOVE.W  #$15,text_ypos
L0275:          MOVEQ   #0,D0
                MOVE.B  (A2)+,D0
                CMPI.B  #$0D,D0
                BEQ.S   L0277
                MOVE.B  0(A3,D0.w),D0
                BSR     set_text
                ADDQ.W  #1,text_xpos
                BRA.S   L0275
L0276:          MOVE.W  #$2A,D0
                BSR     set_text
                ADDQ.W  #1,text_xpos
L0277:          CMPI.W  #$24,text_xpos
                BCS.S   L0276
                ADDQ.W  #8,text_ypos
                MOVE.W  #4,text_xpos
                DBRA    D3,L0275
                RTS

********************************************************
info_activity:  BSR     ANALYZER
                RTS


ANALYZER:       MOVEA.L screen,A0
                LEA     160*199-17*160(A0),A0
                BSR     SCROLL_DOWN
                LEA     CHIP_REG(PC),A3
                LEA     $FFFF8800.w,A2
                MOVE.B  #$FF,BUZZ_VOL
                MOVEQ   #2,D7
VOICES:         MOVE.B  (A3)+,(A2)
                MOVE.B  (A2),D3
                CMPI.B  #$10,D3
                BLT.S   OK_VOL
                MOVE.B  D3,BUZZ_VOL
                MOVE.B  2(A3),BUZZ_PLANE
OK_VOL:         ANDI.W  #$1F,D3
                MOVE.W  D3,D4
                EORI.W  #$1F,D4
                SUBI.W  #$0F,D4
                MOVEQ   #0,D0
                MOVE.B  (A3)+,(A2)
                MOVE.B  (A2),D0
                LSL.W   #8,D0
                MOVE.B  (A3)+,(A2)
                MOVE.B  (A2),D0
                TST.W   D0
                BNE.S   OK_FREQ
                ADDQ.W  #1,A3
                BRA.S   NO_MORE
OK_FREQ:        ANDI.W  #$07FF,D0
                LSL.W   #5,D4
                MOVE.W  D4,D5
                LSL.W   #2,D4
                ADD.W   D4,D5
                LSL.L   #8,D0
                LSL.L   #3,D0
                MOVE.L  D0,D1
                LSL.L   #2,D1
                ADD.L   D1,D0
                SWAP    D0
                MOVE.W  D0,D1
                ANDI.W  #$FFF0,D0
                LSR.W   #1,D0
                ANDI.W  #$0F,D1
                MOVE.W  #$8000,D2
                LSR.W   D1,D2
                ADD.W   D5,D0
                MOVE.B  (A3)+,D4
                ANDI.W  #$0F,D4
                ADD.W   D4,D0
                LEA     0(A0,D0.w),A1
VOICE:          OR.W    D2,(A1)
                LEA     160(A1),A1
                DBRA    D3,VOICE
NO_MORE:        DBRA    D7,VOICES
                MOVEQ   #0,D0
                MOVE.B  #$0B,(A2)
                MOVE.B  (A2),D0
                LSL.W   #2,D0
                ADDI.W  #256,D0
                LSL.L   #8,D0
                LSL.L   #3,D0
                MOVE.L  D0,D1
                LSL.L   #2,D1
                ADD.L   D1,D0
                SWAP    D0
                MOVE.W  D0,D1
                ANDI.W  #$FFF0,D0
                LSR.W   #1,D0
                ANDI.W  #$0F,D1
                MOVE.W  #$8000,D2
                LSR.W   D1,D2
                ADDI.W  #320,D0
                MOVEQ   #0,D3
                MOVE.B  BUZZ_VOL(PC),D3
                BMI.S   NO_BUZZ
                CMPI.B  #$11,D3
                BEQ.S   LOUD
                ADDI.W  #160,D0
LOUD:           MOVEQ   #0,D1
                MOVE.B  BUZZ_PLANE(PC),D1
                ADD.W   D1,D0
                LEA     0(A0,D0.w),A1
                SUBQ.B  #3,D3
VOICE2:         OR.W    D2,(A1)
                LEA     160(A1),A1
                DBRA    D3,VOICE2
NO_BUZZ:
                RTS
CHIP_REG:       DC.B 8,1,7,0,9,3,2,6
                DC.B 10,5,4,2

                DC.B $08,$01,$07,$00,$09,$03,$02,$02
                DC.B $0A,$05,$04,$06
BUZZ_VOL:       DC.W 0
BUZZ_PLANE:     DC.W 0

SCROLL_DOWN:    LEA     17*160(A0),A1
                LEA     -160(A1),A2
                CLR.L   0(A1)
                CLR.W   6(A1)
                CLR.L   8(A1)
                CLR.W   $0E(A1)
                CLR.L   $10(A1)
                CLR.W   $16(A1)
                CLR.L   $18(A1)
                CLR.W   $1E(A1)
                CLR.L   $20(A1)
                CLR.W   $26(A1)
                CLR.L   $28(A1)
                CLR.W   $2E(A1)
                CLR.L   $30(A1)
                CLR.W   $36(A1)
                CLR.L   $38(A1)
                CLR.W   $3E(A1)
                CLR.L   $40(A1)
                CLR.W   $46(A1)
                CLR.L   $48(A1)
                CLR.W   $4E(A1)
                CLR.L   $50(A1)
                CLR.W   $56(A1)
                CLR.L   $58(A1)
                CLR.W   $5E(A1)
                CLR.L   $60(A1)
                CLR.W   $66(A1)
                CLR.L   $68(A1)
                CLR.W   $6E(A1)
                CLR.L   $70(A1)
                CLR.W   $76(A1)
                CLR.L   $78(A1)
                CLR.W   $7E(A1)
                CLR.L   $80(A1)
                CLR.W   $86(A1)
                CLR.L   $88(A1)
                CLR.W   $8E(A1)
                CLR.L   $90(A1)
                CLR.W   $96(A1)
                CLR.L   $98(A1)
                CLR.W   $9E(A1)
                LEA     -160(A1),A1
                LEA     -160(A2),A2
                MOVEQ   #$10,D0
M_DOWN:
                MOVE.L  0(A2),0(A1)
                MOVE.W  6(A2),6(A1)
                MOVE.L  8(A2),8(A1)
                MOVE.W  $0E(A2),$0E(A1)
                MOVE.L  $10(A2),$10(A1)
                MOVE.W  $16(A2),$16(A1)
                MOVE.L  $18(A2),$18(A1)
                MOVE.W  $1E(A2),$1E(A1)
                MOVE.L  $20(A2),$20(A1)
                MOVE.W  $26(A2),$26(A1)
                MOVE.L  $28(A2),$28(A1)
                MOVE.W  $2E(A2),$2E(A1)
                MOVE.L  $30(A2),$30(A1)
                MOVE.W  $36(A2),$36(A1)
                MOVE.L  $38(A2),$38(A1)
                MOVE.W  $3E(A2),$3E(A1)
                MOVE.L  $40(A2),$40(A1)
                MOVE.W  $46(A2),$46(A1)
                MOVE.L  $48(A2),$48(A1)
                MOVE.W  $4E(A2),$4E(A1)
                MOVE.L  $50(A2),$50(A1)
                MOVE.W  $56(A2),$56(A1)
                MOVE.L  $58(A2),$58(A1)
                MOVE.W  $5E(A2),$5E(A1)
                MOVE.L  $60(A2),$60(A1)
                MOVE.W  $66(A2),$66(A1)
                MOVE.L  $68(A2),$68(A1)
                MOVE.W  $6E(A2),$6E(A1)
                MOVE.L  $70(A2),$70(A1)
                MOVE.W  $76(A2),$76(A1)
                MOVE.L  $78(A2),$78(A1)
                MOVE.W  $7E(A2),$7E(A1)
                MOVE.L  $80(A2),$80(A1)
                MOVE.W  $86(A2),$86(A1)
                MOVE.L  $88(A2),$88(A1)
                MOVE.W  $8E(A2),$8E(A1)
                MOVE.L  $90(A2),$90(A1)
                MOVE.W  $96(A2),$96(A1)
                MOVE.L  $98(A2),$98(A1)
                MOVE.W  $9E(A2),$9E(A1)
                LEA     -160(A1),A1
                LEA     -160(A2),A2
                DBRA    D0,M_DOWN
                RTS
********************************************************

L0285:          MOVEA.L screen,A0
                MOVE.W  L03AD,D2
                MULU    #$A0,D2
                ADDA.W  D2,A0
                MOVE.W  L03AC,D1
                ADD.W   L03AE,D1
                BCLR    #0,D1
                SNE     D2
                ASL.W   #2,D1
                TST.B   D2
                BEQ.S   L0286
                ADDQ.W  #1,D1
L0286:          ADDA.W  D1,A0
                NOT.B   (A0)
                NOT.B   $A0(A0)
                NOT.B   $0140(A0)
                NOT.B   $01E0(A0)
                NOT.B   $0280(A0)
                NOT.B   $0320(A0)
                NOT.B   $03C0(A0)
                NOT.B   $0460(A0)
                RTS

L0287:          LEA     L029B,A0
                ANDI.W  #$0F,D0
                MOVE.B  0(A0,D0.w),D0
                BSR     set_text
                RTS

L0288:          LEA     font_8x8,A3
                MOVEQ   #7,D3
L0289:          MOVEQ   #0,D0
                MOVE.B  (A2)+,D0
                MOVE.B  0(A3,D0.w),D0
                BSR     set_text
                ADDQ.W  #1,text_xpos
                DBRA    D3,L0289
                RTS

x0288:          LEA     font_8x8,A3
                MOVEQ   #12-1,D3
x0289:          MOVEQ   #0,D0
                MOVE.B  (A2)+,D0
                MOVE.B  0(A3,D0.w),D0
                BSR     set_text
                ADDQ.W  #1,text_xpos
                DBRA    D3,x0289
                RTS
                EVEN
insig_:         DC.B "TRISOUND EXT",0
                EVEN
new_:           DC.B "SIDSOUND 3.1",0
                EVEN

L028A:          LEA     font_8x8,A3
L028B:          MOVEQ   #0,D0
                MOVE.B  (A2)+,D0
                BEQ.S   L028C
                MOVE.B  0(A3,D0.w),D0
                BSR     set_text
                ADDQ.W  #1,text_xpos
                BRA.S   L028B
L028C:          RTS

set_comm_gfx:   MOVE.B  (A2)+,D0
                BMI.S   L028E
                BSR     set_text
                ADDQ.W  #1,text_xpos
                BRA.S   set_comm_gfx
L028E:          RTS

L028F:          LEA     L03B1,A0
                MOVE.L  #$2A2A2A2A,(A0)+
                MOVE.B  #$14,(A0)
                MOVE.B  #$0B,1(A0)
                ST      2(A0)
                TST.L   D0
                BEQ.S   L0291
                SUBQ.L  #1,D0
                LSR.L   #8,D0
                LSR.L   #2,D0
                ADDQ.L  #1,D0
L0290:          MOVE.L  D0,D1
                DIVU    #$0A,D1
                MOVE.W  D1,D0
                SWAP    D1
                MOVE.B  D1,-(A0)
                TST.W   D0
                BNE.S   L0290
                LEA     L03B1,A2
                BSR     set_comm_gfx
                SUBQ.W  #6,text_xpos
                RTS
L0291:          LEA     L03B1,A2
                CLR.B   3(A2)
                BSR     set_comm_gfx
                SUBQ.W  #6,text_xpos
                RTS
L0292:          MOVE.W  D0,D3
                MOVEQ   #3,D4
L0293:          ROL.W   #4,D3
                MOVE.B  D3,D0
                ANDI.B  #$0F,D0
                BSR     set_text
                ADDQ.W  #1,text_xpos
                DBRA    D4,L0293
                SUBQ.W  #4,text_xpos
                RTS

set_numbers:    MOVE.B  D0,D3
                ANDI.W  #$0F,D0
                ADDQ.W  #1,text_xpos
                BSR     set_text
                SUBQ.W  #1,text_xpos
                MOVE.B  D3,D0
                LSR.B   #4,D0
                ANDI.W  #$0F,D0
                BSR     set_text
                RTS


set_text:       MOVE.W  text_xpos,D1
                MOVE.W  text_ypos,D2

                ADD.W   D2,D2
                MOVE.W  mulu_160(PC,D2.w),D2

                MOVEA.L screen,A0
                ADDA.W  D2,A0

                BCLR    #0,D1
                SNE     D2
                ADD.W   D1,D1
                ADD.W   D1,D1
                TST.B   D2
                BEQ.S   L0296
                ADDQ.W  #1,D1
L0296:          ADDA.W  D1,A0
                LEA     font,A1
                ANDI.W  #$FF,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADD.W   D0,D0
                ADDA.W  D0,A1
                MOVE.B  (A1)+,(A0)
                MOVE.B  (A1)+,$A0(A0)
                MOVE.B  (A1)+,$0140(A0)
                MOVE.B  (A1)+,$01E0(A0)
                MOVE.B  (A1)+,$0280(A0)
                MOVE.B  (A1)+,$0320(A0)
                MOVE.B  (A1)+,$03C0(A0)
                MOVE.B  (A1)+,$0460(A0)
                RTS

mulu_160:
x               SET 0
                REPT 200
                DC.W x
x               SET x+160
                ENDR

sron:           MOVEM.L D0-A6,-(SP)

                MOVE.B  #-1,show_spec

                LINEA   #$0A [ Hidem ]

                MOVE.W  #1,-(SP)
                MOVE.L  #-1,-(SP)
                MOVE.L  #-1,-(SP)
                MOVE.W  #5,-(SP)
                TRAP    #14
                LEA     12(SP),SP

                MOVE.W  oldscreen,D0
                LEA     $FFFF8201.w,A0
                MOVEP.W D0,0(A0)        ; alte Screenadresse setzen

                CLR.W   $FFFF8240.w
                MOVE.L  #$05550555,$FFFF8242.w
                MOVE.W  #$0555,$FFFF8246.w
                LINEA   #$09 [ Showm ]
                MOVEM.L (SP)+,D0-A6
                RTS

sroff:          MOVEM.L D0-A6,-(SP)

                MOVEA.L $044E.w,A1
                LEA     rett_buff,A0
                MOVE.W  #7999,D4
copy_up:        MOVE.L  (A0)+,(A1)+
                DBRA    D4,copy_up

                MOVE.W  #0,-(SP)
                MOVE.L  #-1,-(SP)
                MOVE.L  #-1,-(SP)
                MOVE.W  #5,-(SP)
                TRAP    #14
                LEA     12(SP),SP
                MOVE.B  #1,show_spec
                MOVEM.L pal1,D0-D7
                MOVEM.L D0-D7,$FFFF8240.w

                MOVE.L  screen,D0       ; set the first screen
                JSR     set_screen

                MOVEM.L (SP)+,D0-A6
                RTS

*farben nach asufruf von fileselect neu setzten.
*sonst farbenscheiss auf falcon.
copy_editor_pic:MOVEA.L screen,A0
                LEA     EDIT_PIC,A1
                MOVE.W  #4000-1,D0
COPY_edit:
                MOVE.L  (A1)+,(A0)+
                MOVE.W  (A1)+,(A0)+
                CLR.W   (A0)+
                DBRA    D0,COPY_edit
                RTS
                ENDPART
**********************************************************
                >PART 'Special Datas'
                DATA
                EVEN
synth_flag:     DC.B 0
show_spec:      DC.B 1
                EVEN
dual_a:         DC.W 1
dual_b:         DC.W 1
dual_c:         DC.W 1

sid_a:          DC.W -1
sid_b:          DC.W -1
sid_c:          DC.W -1

                EVEN
a               SET 4           ;4
b               SET 261
c               SET 2           ;2
d               SET 104         ; 104
e               SET 100
x               SET 20
f               SET 1           ; 1

wave_form1:     DC.B $00,'h',$00,$04,$00,$01,$01,$05
                DC.B $00,$0A,$00,$02,$01,$A2,$00,$10
                DC.B $00,$03,$05,$1A,$00,'2',$00,$04
                DC.B $06,$88,$00,'@',$00,$05,$0A,'5'
                DC.B $00,'d',$00,$06,$0E,$EF,$00,$C8
                DC.B $00,$07,$FF,$FF

wave_form2:     REPT 2
                DC.W 1*d,1*a    ;;       4
                DC.W f,1*b      ;; 1   261
                DC.W x,1*c      ;e-40,1*c   ;;10     2
                DC.W 4*d,4*a    ;418    16
                DC.W f+2,5*b    ;; 3   261
                DC.W 1*e,2*c    ;;50     4
                DC.W 8*d,16*a   ;1672   64
                DC.W f+4,10*b   ;; 5
                DC.W 2*e,3*c    ;;100    6
                DC.W 36*d,64*a  ;;     256
                DC.W f+6,15*b   ;;-1     ;; 7
                ENDR
                DC.W -1

e               SET 150
x               SET 30

wave_form3:

                REPT 2
                DC.W 1*d,1*a    ;;       4
                DC.W f,1*b      ;; 1   261
                DC.W x,1*c      ;e-40,1*c   ;;10     2
                DC.W 4*d,4*a    ;418    16
                DC.W f+2,5*b    ;; 3   261
                DC.W 1*e,2*c    ;;50     4
                DC.W 8*d,16*a   ;1672   64
                DC.W f+4,10*b   ;; 5
                DC.W 2*e,3*c    ;;100    6
                DC.W 36*d,64*a  ;;     256
                DC.W f+6,15*b   ;;-1     ;; 7
                ENDR
                DC.W -1
                EVEN
******************************************************
standard:
*                     ********--------
* Extended Noiz Control = $3c / 0 Offset
* Extended Tone Control = $3d / 1
* Extended Wave Control = $3e / 2
* Sid  Control Flag     = $3f / 3

                DC.B 1          ; Extend Noiz
                DC.B 1          ; Extend Tone
                DC.B 0          ; Extend Wave
                DC.B 0          ; Extended Replay Effect (3=SID)

                DC.B 2
                DC.B 2
                DC.B 0
                DC.B 0

                DC.B 0
                DC.B 0
                DC.B 1
                DC.B 0

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 3

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 3

                DC.B 3
                DC.B 3
                DC.B 0
                DC.B 1

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 1

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 2

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 2

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 2

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 2

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 1

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 3

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0

                DS.W 17

                DC.B 0
                DC.B 3
                DC.B 0
                DC.B 0

                DC.B 0
                DC.B 0
                DC.B 0
                DC.B 0

                DS.W 79


nois_table:     DC.L nois_1
                DC.L nois_2
                DC.L nois_3
                DC.L nois_4
                DC.L nois_5
                DC.L nois_6
                DC.L nois_7
                DC.L nois_8
                DC.L nois_9
                DC.L nois_10
                DC.L nois_11
                DC.L nois_12
                DC.L nois_13
                DC.L nois_14
                DC.L nois_15
                DC.L nois_16
                DC.L nois_17
                DC.L nois_18
                DC.L nois_19
                DC.L nois_20
                DC.L nois_21
                DC.L nois_22
                DC.L nois_23
                DC.L nois_24
                DC.L nois_25
                DC.L nois_26
                DC.L nois_27
                DC.L nois_28
                DC.L nois_29
                DC.L nois_30
                DC.L nois_31
                DC.L nois_32
                DC.L nois_33
                DC.L nois_34
                DC.L nois_35
                DC.L nois_36
                DC.L nois_37
                DC.L nois_38
                DC.L nois_39
                DC.L nois_40
                DC.L nois_41
                DC.L nois_42
                DC.L nois_43
                DC.L nois_44
                DC.L bdrnoz
                DC.L snrnoz
                DC.L hihatnoz

                DC.L sentry_1_nois
                DC.L sentry_2_nois
                DC.L sentry_3_nois
                DC.L sentry_4_nois
                DC.L sentry_5_nois

tone_table:     DC.L tone_1
                DC.L tone_2
                DC.L tone_3
                DC.L tone_4
                DC.L tone_5
                DC.L tone_6
                DC.L tone_7
                DC.L tone_8
                DC.L tone_9
                DC.L tone_10
                DC.L tone_11
                DC.L tone_12
                DC.L tone_13
                DC.L tone_14
                DC.L tone_15
                DC.L tone_17
                DC.L tone_18
                DC.L tone_19
                DC.L tone_20
                DC.L tone_21
                DC.L tone_22
                DC.L tone_23
                DC.L tone_24
                DC.L tone_25
                DC.L tone_26
                DC.L tone_27
                DC.L tone_28
                DC.L tone_29
                DC.L tone_30
                DC.L tone_31
                DC.L tone_32
                DC.L tone_33
                DC.L tone_34

                DC.L sentry_1_tone
                DC.L sentry_2_tone
                DC.L sentry_3_tone
                DC.L sentry_4_tone
                DC.L sentry_5_tone
                DC.L sentry_6_tone
                DC.L sentry_7_tone
                DC.L sentry_8_tone
                DC.L sentry_9_tone

wave_table:     DC.L wave_1
                DC.L wave_2
                DC.L wave_3
                DC.L wave_4
                DC.L wave_5
                DC.L wave_6
                DC.L wave_7
                DC.L wave_8
                DC.L wave_9
                DC.L wave_10
                DC.L wave_11
                DC.L wave_12
                DC.L wave_13
                DC.L wave_14
                REPT 10
                DC.L wave_15
                ENDR
                EVEN

nois_1:         DC.B 16,$FF     ; Drum 1
nois_2:         DC.B 10,17,15,17,13,12,8,$FF ; Snare 1
nois_3:         DC.B 4,$FF
nois_4:         DC.B 3,$FF
nois_5:         DC.B 32,32,$FF
nois_6:         DC.B 9,32,32,$FF
nois_7:         DC.B 32,9,12,32,$FF
nois_8:         DC.B 32,4,8,14,18,22,26,30,$FE
nois_9:         DC.B 32,$FE
nois_10:        DC.B 32,$FE
nois_11:        DC.B 17,$FE
nois_12:        DC.B 32,8,$FE
nois_13:        DC.B 13,9,$FE
nois_14:        DC.B 19,14,12,11,4,$FE
nois_15:        DC.B 32,32,25,10,5,3,2,1,$FE
nois_16:        DC.B 1,2,3,4,5,6,7,8,7,6,5,4,3,2,1,$FE
nois_17:        DC.B 13,3,13,5,13,17,6,17,6,$FE
nois_18:        DC.B 14,21,$FE
nois_19:        DC.B 15,24,$FE
nois_20:        DC.B 24,$FF     ; Drum 2
nois_21:        DC.B 6,21,12,21,7,21,4,21,8,$FF ; Snare 2
nois_22:        DC.B 32,$FF     ; Drum 3
nois_23:        DC.B 15,17+5,15+5,17+5,13+5,12+5,8+5,$FF ; Snare 3
nois_24:        DC.B 32,32,24,16,8,$FF ; Drum 4
nois_25:        DC.B 20,27,25,27,23,22,18,$FF ; Snare 4
nois_26:        DC.B 48,8,$FF   ; Drum 4
nois_27:        DC.B 47,5,47,3,42,1,$FF ; Snare 4
nois_28:        DC.B 8,16,80,$FF ; Drum 4
nois_29:        DC.B 20,18,16,14,12,10,8,$FF ; Snare 4
nois_30:        DC.B 18,8,$FF   ; Drum 4
nois_31:        DC.B 22,18,40,43,42,41,40,$FF ; Snare 4
nois_32:        DC.B 4,$FF      ; Drum 4
nois_33:        DC.B 2,18,49,1,37,5,54,6,$FF ; Snare 4
nois_34:        DC.B 10,11,12,13,14,15,$FF
nois_35:        DC.B 41,1,$FF
nois_36:        DC.B 11,$FF
nois_37:        DC.B 10,0,0,0,14,4,4,$FF
nois_38:        DC.B 43,$FF
nois_39:        DC.B 21,2,$FF
nois_40:        DC.B 12,1,2,1,$FF
nois_41:        DC.B 13,13,13,1,3,$FF
nois_42:        DC.B 1,$FF
nois_43:        DC.B 20,4,10,2,$FF
nois_44:        DC.B 12,1,4,14,4,16,4,18,$FF
bdrnoz:         DC.B 0,0,9,$FF
snrnoz:         DC.B 0,0,9,12,$FF
hihatnoz:       DC.B 0,0,0,1,1,1,0,0,1,1,0,1,$FF

sentry_1_nois:  DC.B 11,$FF
sentry_2_nois:  DC.B 18,16,14,18,10,8,6,4,2,0,0,0,0,0,0,0,0,0,0,$FF
sentry_3_nois:  DC.B 11,$FF
sentry_4_nois:  DC.B 12,11,10,9,8,6,4,2,0,$FF
sentry_5_nois:  DC.B 11,$FE

                EVEN
tone_1:         DC.B 1,2,$FE
tone_2:         DC.B 3,2,2,2,1,1,$FE
tone_3:         DC.B 3,2,$FE
tone_4:         DC.B 7,4,4,4,2,2,$FF
tone_5:         DC.B 1,0,0,0,1,0,14,15,15,14,12,8,0,$FE
tone_6:         DC.B 0,2,2,2,2,3,0,14,13,12,$FE
tone_7:         DC.B 3,0,14,0,13,11,9,7,5,3,1,0,$FE
tone_8:         DC.B 2,14,0,0,2,2,0,1,16,$FE
tone_9:         DC.B 12,4,0,0,12,13,$FE
tone_10:        DC.B 2,3,3,0,0,12,13,$FE
tone_11:        DC.B 1,0,0,0,2,0,15,15,14,13,12,12,0,$FE
tone_12:        DC.B 6,0,0,0,0,$FE
tone_13:        DC.B 25,20,15,10,5,0,$FE
tone_14:        DC.B 0,1,0,7,12,$FE
tone_15:        DC.B 0,0,24,12,0,$FE
tone_16:        DC.B 20,10,0,$FE
tone_17:        DC.B 3,4,$FE
tone_18:        DC.B 8,5,5,5,5,5,5,4,4,4,3,3,2,2,1,$FE
tone_19:        DC.B 8,7,$FE
tone_20:        DC.B 5,4,3,2,1,2,3,4,5,6,7,8,9,10,$FE
tone_21:        DC.B 8,10,$FE
tone_22:        DC.B 9,8,8,8,8,8,8,8,7,7,7,6,6,5,$FE
tone_23:        DC.B 9,6,$FE
tone_24:        DC.B 10,11,12,13,14,15,$FE
tone_25:        DC.B 11,12,13,14,15,$FE
tone_26:        DC.B 1,11,1,12,1,13,$FE
tone_27:        DC.B 40,4,40,4,40,4,40,$FE
tone_28:        DC.B 1,2,3,4,5,6,7,8,9,10,9,8,7,6,5,4,3,2,1,$FE
tone_29:        DC.B 9,8,7,6,5,4,3,2,1,2,3,4,5,6,7,8,9,$FE
tone_30:        DC.B 10,0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0,$FE
tone_31:        DC.B 20,18,16,14,12,10,8,7,6,5,4,3,2,1,$FE
tone_32:        DC.B 32,1,16,2,$FE
tone_33:        DC.B 10,20,0,20,10,$FE
tone_34:        DC.B 10,5,$FE

sentry_1_tone:  DC.B 9,6,4,2,0,$FF
sentry_2_tone:  DC.B 13,14,16,9,0,13,$FF
sentry_3_tone:  DC.B 0,5,8,12,$FF
sentry_4_tone:  DC.B 0,3,7,12,$FF
sentry_5_tone:  DC.B 12,0,$FF
sentry_6_tone:  DC.B 12,0,$FE
sentry_7_tone:  DC.B 13,17,15,9,0,9,13,$FF
sentry_8_tone:  DC.B 0,3,7,12,$FE
sentry_9_tone:  DC.B 16,14,12,10,8,6,4,2,0,$FF
                EVEN
wave_1:         DC.B 1,1,1,$FF
wave_2:         DC.B 1,1,$FF
wave_3:         DC.B 1,$FF
wave_4:         DC.B 1,1,1,1,$FE
wave_5:         DC.B 10,11,12,13,14,15,$FE
wave_6:         DC.B 1,1,1,1,1,$FE
wave_7:         DC.B 1,1,1,1,1,1,$FE
wave_8:         DC.B 40,40,40,40,40,40,40,$FE
wave_9:         DC.B 1,1,1,1,1,1,1,1,$FE
wave_10:        DC.B 1,2,1,2,1,2,1,2,$FE
wave_11:        DC.B 2,1,2,1,2,1,2,1,$FE
wave_12:        DC.B 1,3,1,3,1,3,1,3,$FE
wave_13:        DC.B 3,1,3,1,3,1,3,1,$FE
wave_14:        DC.B 1,4,1,4,1,4,1,4,$FE
wave_15:        REPT 4
                DC.B 1,1,4,1,4,1,4,1,$FE
                ENDR
                EVEN

trem_tab:

                DC.W $00,$01AC,$0354,$04F2
                DC.W $0682,$0800,$0968,$0AB5
                DC.W $0BE4,$0CF2,$0DDB,$0E9E
                DC.W $0F38,$0FA6,$0FEA,$1000
                DC.W $0FEA,$0FA6,$0F38,$0E9E
                DC.W $0DDB,$0CF2,$0BE4,$0AB5
                DC.W $0968,$0800,$0682,$04F2
                DC.W $0354,$01AC,$00,$FE54
                DC.W $FCAC,$FB0E,$F97E,$F800
                DC.W $F698,$F54B,$F41C,$F30E
                DC.W $F225,$F162,$F0C8,$F05A
                DC.W $F016,$F000,$F016,$F05A
                DC.W $F0C8,$F162,$F225,$F30E
                DC.W $F41C,$F54B,$F698,$F800
                DC.W $F97E,$FB0E,$FCAC,$FE54
                EVEN
                ENDPART
**********************************************************
                >PART 'datas'
HILFSPALETTE1:  DS.L 8
speed_:         DC.W 0
break_cmd:      DC.W 0          ; Pattern-Break Command
what:           DC.W 0          ; Speed Change-Flag
merk_speed:     DC.W 0          ; Speed merken
digi_spielt:    DC.B 0          ; -1 ->Digidrum / 0 -> Digi aus / 1 -> SID spielt
                EVEN
oldhbl:         DC.L 0
                EVEN
                PATH 'D:\SIDSOUND.V25\'
editor_buff:    IBYTES 'SONG_ED.BUF'
                EVEN
instr_buff:     IBYTES 'INSTR_ED.BUF'
                EVEN
vols:           DS.W 12
                DC.B $01,$01,$01,$01,$01,$01,$01,$01
                DS.W 2
                DC.B $01,$01,$01,$01,$01,$01,$01,$01
                DC.B $02,$02,$02,$02,$00,$00,$00,$01
                DC.B $01,$01,$01,$01,$02,$02,$02,$02
                DC.B $02,$03,$03,$03,$00,$00,$01,$01
                DC.B $01,$01,$02,$02,$02,$02,$03,$03
                DC.B $03,$03,$04,$04,$00,$00,$01,$01
                DC.B $01,$02,$02,$02,$03,$03,$03,$04
                DC.B $04,$04,$05,$05,$00,$00,$01,$01
                DC.B $02,$02,$02,$03,$03,$04,$04,$04
                DC.B $05,$05,$06,$06,$00,$00,$01,$01
                DC.B $02,$02,$03,$03,$04,$04,$05,$05
                DC.B $06,$06,$07,$07,$00,$01,$01,$02
                DC.B $02,$03,$03,$04,$04,$05,$05,$06
                DC.B $06,$07,$07,$08,$00,$01,$01,$02
                DC.B $02,$03,$04,$04,$05,$05,$06,$07
                DC.B $07,$08,$08,$09,$00,$01,$01,$02
                DC.B $03,$03,$04,$05,$05,$06,$07,$07
                DC.B $08,$08,$09,$0A,$00,$01,$01,$02
                DC.B $03,$04,$04,$05,$06,$07,$07,$08
                DC.B $09,$0A,$0A,$0B,$00,$01,$02,$02
                DC.B $03,$04,$05,$06,$06,$07,$08,$09
                DC.B $0A,$0A,$0B,$0C,$00,$01,$02,$03
                DC.B $03,$04,$05,$06,$07,$08,$09,$0A
                DC.B $0A,$0B,$0C,$0D,$00,$01,$02,$03
                DC.B $04,$05,$06,$07,$07,$08,$09,$0A
                DC.B $0B,$0C,$0D,$0E,$00,$01,$02,$03
                DC.B $04,$05,$06,$07,$08,$09,$0A,$0B
                DC.B $0C,$0D,$0E,$0F
                EVEN

note_2_freq:    DC.W $0FD1
                DC.W $0EEE,$0E17,$0D4D,$0CBE
                DC.W $0BD9,$0B2F,$0A8E,$09F7
                DC.W $0967,$08E0,$0861,$07E8
                DC.W $0777,$070C,$06A7,$0647
                DC.W $05ED,$0598,$0547,$04FC
                DC.W $04B4,$0470,$0431,$03F4
                DC.W $03BB,$0385,$0353,$0323
                DC.W $02F6,$02CB,$02A3,$027D
                DC.W $0259,$0238,$0218,$01FA
                DC.W $01DD,$01C2,$01A9,$0191
                DC.W $017B,$0165,$0151,$013E
                DC.W $012C,$011C,$010C,$FD
                DC.W $EE,$E1,$D4,$C8
                DC.W $BD,$B2,$A8,$9F
                DC.W $96,$8E,$86,$7E
                DC.W $77,$70,$6A,$64
                DC.W $5E,$59,$54,$4F
                DC.W $4B,$47,$43,$3F
                DC.W $3B,$38,$35,$32
                DC.W $2F,$2C,$2A,$27
                DC.W $25,$23,$21,$1F
                DC.W $1D,$1C,$1A,$19
                DC.W $17,$16,$15,$13
                DC.W $12,$11,$10,$0F
                DC.W $0E,$0D,$0C,$0B
                DC.W $0A,$09,$08,$07
                DC.W $06,$05,$04,$03
                DC.W $02,$01,$00,$00


tonleiter_tab:  DC.B '33',$0C,'*',$0C,'$',$0D,'*'
                DC.B $0D,'$',$0E,'*',$0F,'*',$0F,'$'
                DC.B $10,'*',$10,'$',$0A,'*',$0A,'$'
                DC.B $0B,'*'

L029A:          DC.B '&&&&',$FF,$00,$00,$00
                DC.B '&(((',$FF,$00,$00,$00
                DC.B '&',$27,'&',$27,$FF,$00,$00,$00
                DC.B '&)))',$FF,$00,$00,$00
                DC.B $27,$27,$27,$27,$FF,$00,$00,$00
                DC.B $27,')))',$FF,$00,$00,$00
                DC.B $27,'&',$27,'&',$FF,$00,$00,$00
                DC.B $27,'(((',$FF
L029B:          DC.B $00,$0A,$1C,$1B

font_8x8:       DC.B '*',$00,$00,$00,$00,$00,$00,$00,$00
                DS.W 11
                DC.B $00,'*,',$00,'$;',$00,'8'
                DC.B $00,'1279-3.'
                DC.B '0',$00,$01,$02,$03,$04,$05,$06
                DC.B $07,$08,$09,'45',$00,':',$00
                DC.B '+',$00,$0A,$0B,$0C,$0D,$0E,$0F
                DC.B $10,$11,$12,$13,$14,$15,$16,$17
                DC.B $18,$19,$1A,$1B,$1C,$1D,$1E,$1F
                DC.B ' !"#',$00,'6',$00,$00
                DC.B '%',$00,$0A,$0B,$0C,$0D,$0E,$0F
                DC.B $10,$11,$12,$13,$14,$15,$16,$17
                DC.B $18,$19,$1A,$1B,$1C,$1D,$1E,$1F
                DC.B ' !"#',$00,$00,$00,$00
                DS.W 64
                DC.B $00

KEY_TABLE:      DC.B $00,$00,'1234567'
                DC.B '890_',$00,$00,$00,'Q'
                DC.B 'WERTYUIO'
                DC.B 'P',$00,$00,$00,$00,'ASD'
                DC.B 'FGHJKL',$00,$00
                DC.B $00,$00,$00,'ZXCVB'
                DC.B 'NM',$00,$00,$00,$00,$00,$00
                DC.B ' ',$00,$00,$00,$00,$00,$00,$00
                DS.W 95
                DC.B $00

L029E:          DC.B $01,$02,$03,$04,$05,$06,$07,$08,$09
                DC.B $0A,$0B,$0C,$11,$12,$13,$14,$15
                DC.B $16,$17,$18,$19,$1A,$1B,$1C,'!'
                DC.B '"#$%&',$27,'()'
                DC.B '*+,',$01,$02,$03,$04,$05
                DC.B $06,$07,$08,$09,$0A,$0B,$0C,$11
                DC.B $12,$13,$14,$15,$16,$17,$18,$19
                DC.B $1A,$1B,$1C,'!"#$%'
                DC.B '&',$27,'()*+,1'
                DC.B '23456789'
                DC.B ':;<ABCDE'
                DC.B 'FGHIJKLQ'
                DC.B 'RSTUVWXY'
                DC.B 'Z[\abcde'
                DC.B 'fghijklq'
                DC.B 'rstuvwxy'
                DC.B 'z{|',$00

L029F:          DC.B $00,$00,$00,$17,$19,$1B,$00,'"'
                DC.B '$',$00,$27,')+',$00,$00,$00
                DC.B $16,$18,$1A,$1C,'!#%&'
                DC.B '(*,',$00,$00,$00,$00,$02
                DC.B $04,$00,$07,$09,$0B,$00,$12,$14
                DS.W 2
                DC.B $01,$03,$05,$06,$08,$0A,$0C,$11
                DC.B $13,$15,$00,$00,$00,$00,$00,$00
                DS.W 34

L02A0:          DC.B $00,$00,$FF,$01,$FF,$02,$03,$FF
                DC.B $04,$FF,$05,$FF,$06,$00,$00,$00
                DC.B $00,$07,$FF,$08,$FF,$09,$0A,$FF
                DC.B $0B,$FF,$0C,$FF,$0D,$00,$00,$00
                DC.B $00,$0E,$FF,$0F,$FF,$FF,$FF,$FF
                DC.B $FF,$FF,$FF,$FF,$FF

L02A1:          DC.B $FF,$FF,$01,$02,$03,$04,$05,$06,$07
                DC.B $08,$09,$00,$FF,$FF,$FF,$FF,$FF
                DC.B $FF,$0E,$FF,$FF,$FF,$FF,$FF,$FF
                DC.B $FF,$FF,$FF,$FF,$FF,$0A,$FF,$0D
                DC.B $0F,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                DC.B $FF,$FF,$FF,$FF,$FF,$0C,$FF,$0B
                DS.B 128,-1
******************
L02A2:          DC.B $FF,$FF,$FF,$FF,$FF,$FF,$FF,$FF
                DC.B $FF,$FF,$FF,$00,$FF,$FF,$FF,$FF
                DC.B $FF,$FF,$FF,$03,$FF,$FF,$FF,$FF
                DC.B $FF,$FF,$FF,$FF,$FF,$FF,$01,$02
                DS.B 128,-1
************************
hertz:          DC.B $6E+10,$6E+10,$6E+10,$6E+10,$6E+10,$6E+10
                DC.B $5E+10,$52+10,$49+10,$42+10,$3C+10,$37+10,$33+10,$2F+10,$2C+10,$29+10

L02A5:          DC.L L0053
                DC.L L006C
                DC.L L006F
                DC.L L0071
                DC.L L0073
                DC.L L0075
                DC.L L0077
                DC.L L0079
                DC.L L0054
                DC.L L006C
                DC.L L006F
                DC.L L0071
                DC.L L0073
                DC.L L0075
                DC.L L0077
                DC.L L0079
                DC.L L0054
                DC.L L006C
                DC.L L006F
                DC.L L0071
                DC.L L0073
                DC.L L0075
                DC.L L0077
                DC.L L0079
L02A6:          DC.L L0067
                DC.L L006C
                DC.L L006F
                DC.L L0071
                DC.L L0073
                DC.L L0075
                DC.L L0077
                DC.L L0079
                DC.L L0068
                DC.L L006C
                DC.L L006F
                DC.L L0071
                DC.L L0073
                DC.L L0075
                DC.L L0077
                DC.L L0079
                DC.L L0068
                DC.L L006C
                DC.L L006F
                DC.L L0071
                DC.L L0073
                DC.L L0075
                DC.L L0077
                DC.L L0079

L02A7:          DS.W 17
                DC.B $00,$04,$00,$00,$00,$04,$00,$00
                DC.B $00,$04,$00,$00,$00,$04,$00,$00
                DC.B $00,$04,$00,$00,$00,$04,$00,$00
                DC.B $00,$04,$00,$00,$00,$04,$00,$00
                DC.B $00,$08,$00,$00,$00,$08,$00,$00
                DC.B $00,$08,$00,$00,$00,$08,$00,$00
                DC.B $00,$08,$00,$00,$00,$08,$00,$00
                DC.B $00,$08,$00,$00,$00,$08

L02A8:          DC.L adata
                DC.L adata
                DC.L adata
                DC.L adata
                DC.L adata
                DC.L adata
                DC.L adata
                DC.L adata

                DC.L bdata
                DC.L bdata
                DC.L bdata
                DC.L bdata
                DC.L bdata
                DC.L bdata
                DC.L bdata
                DC.L bdata

                DC.L cdata
                DC.L cdata
                DC.L cdata
                DC.L cdata
                DC.L cdata
                DC.L cdata
                DC.L cdata
                DC.L cdata

                EVEN
L02A9:          DS.W 3
                DC.B $00,$08,$00,$00,$00,$09,$00,$00
                DC.B $00,$10,$00,$00,$00,$11,$00,$00
                DC.B $00,$18,$00,$00,$00,$19,$00,$00
                DC.B $00,' ',$00,$00,$00,'(',$00,$00
                DC.B $00,'0',$00,$00,$00,'1',$00,$00
                DC.B $00,'8',$00,$00,$00,'9',$00,$00
                DC.B $00,'@',$00,$00,$00,'A',$00,$00
                DC.B $00,'H',$00,$00,$00,'P',$00,$00
                DC.B $00,'X',$00,$00,$00,'Y',$00,$00
                DC.B $00,'`',$00,$00,$00,'a',$00,$00
                DC.B $00,'h',$00,$00,$00,'i',$00,$00
                DC.B $00,'p'
                EVEN

song_edit_mous_tab:

                DC.W 214,22,318,29
                DC.L ste_digi_edit

                DC.W 181,22,211,29
                DC.L reset_clock
                DC.W 214,12,226,19
                DC.L sub_sam_freq
                DC.W 229,12,241,19
                DC.L add_sam_freq

                DC.B $00,$F4,$00,$0C,$01,'!',$00,$13
                DC.L reset_sam_freq
                DC.B $00,$D6,$00,$16,$00,$E2,$00,$1D
                DC.L sub_sam_num
                DC.B $00,$E5,$00,$16,$00,$F1,$00,$1D
                DC.L add_sam_num
                DC.B $00,$F4,$00,$16,$01,'!',$00,$1D
                DC.L reset_sam_num
                DC.B $00,$D6,$00,' ',$00,$E2,$00,$27
                DC.L sub_instr_num
                DC.B $00,$E5,$00,' ',$00,$F1,$00,$27
                DC.L add_instr_num
                DC.B $00,$F4,$00,' ',$01,'!',$00,$27
                DC.L reset_instr_num
                DC.B $00,$D6,$00,'*',$00,$E2,$00,'1'
                DC.L sub_curr_vol
                DC.B $00,$E5,$00,'*',$00,$F1,$00,'1'
                DC.L add_curr_vol
                DC.B $00,$F4,$00,'*',$01,'!',$00,'1'
                DC.L reset_curr_vol
                DC.B $00,$D6,$00,'4',$00,$E2,$00,';'
                DC.L sub_patt_count
                DC.B $00,$E5,$00,'4',$00,$F1,$00,';'
                DC.L add_patt_count
                DC.B $00,$F4,$00,'4',$01,'!',$00,';'
                DC.L L00DD
                DC.B $00,$D6,$00,'>',$00,$E2,$00,'E'
                DC.L L00E0
                DC.B $00,$E5,$00,'>',$00,$F1,$00,'E'
                DC.L L00DE
                DC.B $00,$F4,$00,'>',$01,'!',$00,'E'
                DC.L L00DF
                DC.B $00,$D6,$00,'H',$00,$E2,$00,'O'
                DC.L L00E4
                DC.B $00,$E5,$00,'H',$00,$F1,$00,'O'
                DC.L L00E2
                DC.B $00,$F4,$00,'H',$01,'!',$00,'O'
                DC.L L00E3
                DC.B $00,$D6,$00,'R',$00,$E2,$00,'Y'
                DC.L L00EC
                DC.B $00,$E5,$00,'R',$00,$F1,$00,'Y'
                DC.L L00EA
                DC.B $00,$F4,$00,'R',$01,'!',$00,'Y'
                DC.L L00EB
                DC.B $00,$D6,$00,'\',$00,$E2,$00,'c'
                DC.L L00E8
                DC.B $00,$E5,$00,'\',$00,$F1,$00,'c'
                DC.L L00E6
                DC.B $00,$F4,$00,'\',$01,'!',$00,'c'
                DC.L L00E7
                DC.B $00,$D6,$00,'f',$00,$E2,$00,'m'
                DC.L L00EE
                DC.B $00,$E5,$00,'f',$00,$F1,$00,'m'
                DC.L L00F0
                DC.B $00,$F4,$00,'f',$01,'!',$00,'m'
                DC.L L00F2
                DC.B $00,$D6,$00,'p',$00,$E2,$00,'w'
                DC.L L00F4
                DC.B $00,$E5,$00,'p',$00,$F1,$00,'w'
                DC.L L00F3
                DC.B $00,$F4,$00,'p',$01,'!',$00,'w'
                DC.L L00F5
                DC.B $00,$D6,$00,'z',$00,$E2,$00,$81
                DC.L sub_octave
                DC.B $00,$E5,$00,'z',$00,$F1,$00,$81
                DC.L add_octave
                DC.B $00,$F4,$00,'z',$01,'!',$00,$81
                DC.L L00F7
                DC.B $00,$01,$00,'\',$00,$1B,$00,'w'
                DC.L L0192
                DC.B $00,$1E,$00,'\',$00,'8',$00,'w'
                DC.L L0193
                DC.B $00,';',$00,'\',$00,'U',$00,'w'
                DC.L L0194
                DC.B $00,'X',$00,'\',$00,'r',$00,'w'
                DC.L L0195
                DC.B $00,'u',$00,'\',$00,$A1,$00,'w'
                DC.L stop_music
                DC.B $00,$01,$00,'z',$00,'U',$00,$81
                DC.L L0127
                DC.B $00,'X',$00,'z',$00,$D3,$00,$81
                DC.L L0128
                DC.B $00,$1D,$00,$84,$00,'j',$00,$C6
                DC.L L019A
                DC.B $00,'m',$00,$84,$00,$BA,$00,$C6
                DC.L L019B
                DC.B $00,$BD,$00,$84,$01,$0A,$00,$C6
                DC.L L019C
                DC.B $00,$A4,$00,'\',$00,$B1,$00,'w'
                DC.L L019D
                DC.B $00,$B4,$00,'\',$00,$C1,$00,'w'
                DC.L L019F
                DC.B $00,$C4,$00,'\',$00,$D3,$00,'w'
                DC.L L01A0
                DC.B $00,'u',$00,$0C,$00,$D3,$00,$13
                DC.L L01C8

                DC.B $00,'u',$00,' ',$00,$D3,$00,$27
                DC.L L01C6
                DC.B $00,'u',$00,'*',$00,$D3,$00,'1'
                DC.L L01B3
                DC.B $00,'u',$00,'4',$00,$D3,$00,';'
                DC.L L01B4
                DC.B $00,'u',$00,'>',$00,$D3,$00,'E'
                DC.L instr_editor
                DC.B $00,'u',$00,'H',$00,$D3,$00,'O'
                DC.L L01C1
                DC.B $00,'u',$00,'R',$00,$D3,$00,'Y'
                DC.L L01C3
                DC.B $00,$01,$00,$0C,$00,'r',$00,'Y'
                DC.L L00B9
                DC.B $01,'$',$00,$01,$01,'>',$00,$09
                DC.L prep_info_page

                DC.B $00,$01,$00,$01,$00,$0D,$00,$09
                DC.L L0008

                DS.W 6
                EVEN

ste_digi_mouse_tab:
                DC.W $01,$01,$0D,$09
                DC.L song_editor
                DS.W 6

instr_edit_mouse_tab:
                DC.W 164,161,176,168
                DC.L sub_wave_fx

                DC.W 179,161,191,168
                DC.L add_wave_fx

                DC.W 164,1,176,9
                DC.L sub_tone_fx

                DC.W 179,1,191,9
                DC.L add_tone_fx

                DC.W 164,171,176,178
                DC.L sub_special_fx

                DC.W 179,171,191,178
                DC.L add_special_fx

                DC.W 58,1,70,9
                DC.L sub_nois_fx

                DC.W 73,1,85,9
                DC.L add_nois_fx

                DC.B $00,$A3,$00,'o',$00,$B0,$00,'v'
                DC.L sub_instr_num
                DC.B $00,$B3,$00,'o',$00,$BF,$00,'v'
                DC.L add_instr_num
                DC.B $00,$C2,$00,'o',$00,$EF,$00,'v'
                DC.L reset_instr_num
                DC.B $00,$A3,$00,'y',$00,$B0,$00,$80
                DC.L sub_curr_vol
                DC.B $00,$B3,$00,'y',$00,$BF,$00,$80
                DC.L add_curr_vol
                DC.B $00,$C2,$00,'y',$00,$EF,$00,$80
                DC.L reset_curr_vol
                DC.B $00,$A3,$00,$83,$00,$B0,$00,$8A
                DC.L sub_octave
                DC.B $00,$B3,$00,$83,$00,$BF,$00,$8A
                DC.L add_octave
                DC.B $00,$C2,$00,$83,$00,$EF,$00,$8A
                DC.L L00F7
                DC.B $00,$A3,$00,$8D,$00,$B0,$00,$94
                DC.L sub_patt_count
                DC.B $00,$B3,$00,$8D,$00,$BF,$00,$94
                DC.L add_patt_count
                DC.B $00,$C2,$00,$8D,$00,$EF,$00,$94
                DC.L L00DD
                DC.B $00,$A3,$00,'e',$01,'>',$00,'l'
                DC.L L01C9
                DC.B $00,$A3,$00,$97,$01,$0B,$00,$9E
                DC.L L0128
                DC.B $00,$A3,$00,$A1,$01,$0B,$00,$A8
                DC.L L01E9
                DC.B $00,$A3,$00,$AB,$01,$0B,$00,$B2
                DC.L L01EB
                DC.B $00,$01,$00,$14,$00,$0E,$00,'R'
                DC.L L00FA
                DC.B $01,'1',$00,$14,$01,'>',$00,'R'
                DC.L L00FB
                DC.B $00,$10,$00,$14,$01,'/',$00,'S'
                DC.L L012A
                DC.B $00,$01,$00,'e',$00,$0D,$00,'l'
                DC.L L00FE
                DC.B $00,$0F,$00,'e',$00,$1C,$00,'l'
                DC.L L00FC
                DC.B $00,$01,$00,'o',$00,$0D,$00,'v'
                DC.L L0102
                DC.B $00,$0F,$00,'o',$00,$1C,$00,'v'
                DC.L L0100
                DC.B $00,$01,$00,'y',$00,$0D,$00,$80
                DC.L L0106
                DC.B $00,$0F,$00,'y',$00,$1C,$00,$80
                DC.L L0104
                DC.B $00,$01,$00,$83,$00,$0D,$00,$8A
                DC.L L010A
                DC.B $00,$0F,$00,$83,$00,$1C,$00,$8A
                DC.L L0108
                DC.B $00,$1F,$00,$83,$00,'l',$00,$8A
                DC.L L010C
                DC.B $00,$01,$00,$8D,$00,$0D,$00,$94
                DC.L L010E
                DC.B $00,$0F,$00,$8D,$00,$1C,$00,$94
                DC.L L010D
                DC.B $00,$1F,$00,$8D,$00,'u',$00,$94
                DC.L L010F
                DC.B $00,$01,$00,$97,$00,$0D,$00,$9E
                DC.L sub_nois_freq
                DC.B $00,$0F,$00,$97,$00,$1C,$00,$9E
                DC.L add_nois_freq
                DC.B $00,$1F,$00,$97,$00,'u',$00,$9E
                DC.L reset_nois_freq
                DC.B $00,$01,$00,$A1,$00,$0D,$00,$A8
                DC.L L0111
                DC.B $00,$0F,$00,$A1,$00,$1C,$00,$A8
                DC.L L0110
                DC.B $00,$1F,$00,$A1,$00,'u',$00,$A8
                DC.L L0112
                DC.B $00,$01,$00,$AB,$00,$0D,$00,$B2
                DC.L L0115
                DC.B $00,$0F,$00,$AB,$00,$1C,$00,$B2
                DC.L L0113
                DC.B $00,$1F,$00,$AB,$00,'u',$00,$B2
                DC.L L0114
                DC.B $00,$01,$00,$B5,$00,$0D,$00,$BC
                DC.L sub_interv_1
                DC.B $00,$0F,$00,$B5,$00,$1C,$00,$BC
                DC.L add_interv_1
                DC.B $00,$1F,$00,$B5,$00,'u',$00,$BC
                DC.L go_zero_1
                DC.B $00,$01,$00,$BF,$00,$0D,$00,$C6
                DC.L sub_interv_2
                DC.B $00,$0F,$00,$BF,$00,$1C,$00,$C6
                DC.L add_interv_2
                DC.B $00,$1F,$00,$BF,$00,'u',$00,$C6
                DC.L go_zero_2
                DC.B $00,$A3,$00,$B5,$00,$C5,$00,$C6
                DC.L L0123
                DC.B $00,$C8,$00,$B5,$00,$EA,$00,$C6
                DC.L L0122
                DC.B $00,$ED,$00,$B5,$01,$0F,$00,$C6
                DC.L L0124
                DC.B $00,'o',$00,$83,$00,'u',$00,$8A
                DC.L L0125
                DC.B $00,$01,$00,'U',$00,$96,$00,'b'
                DC.L L0126
                DC.B $01,'1',$00,$01,$01,'>',$00,$09
                DC.L L01A1
                DS.W 6
                EVEN

info_mouse_tab: DC.W 0,0,11,9
                DC.L shift_up
                DC.W 13,0,24,9
                DC.L shift_dwn
                DC.W 310,0,319,9
                DC.L song_editor
                DS.W 6
                EVEN

NOTHING_MOUSE_TAB:DS.W 12
                EVEN


* AUFBAU --> 4 WORDS = XLINKS - YLINKS - XRECHTS - YRECHTS
*            1 LONG  = ROUTINE NACH BUTTONDRUCK

DISK_MOUSE_TAB: DC.W 103,12,114,19
                DC.L QUIT_CURRENT_BOX ;          PUT NORMAL GFX ONTO SCREEN

                DC.W 1,22,30,30
                DC.L LOAD_SONG  ;                LOAD SONG
                DC.W 85,22,114,30
                DC.L SAVE_SONG  ;                SAVE SONG
                DC.W 1,42,30,50
                DC.L LOAD_VSET  ;                LOAD VOICESET
                DC.W 85,42,114,50
                DC.L SAVE_VSET  ;                SAVE VOICESET
                DC.W 1,62,30,70
                DC.L LOAD_YM_SOUND ;             LOAD YM-SOUND
                DC.W 85,62,114,70
                DC.L SAVE_YM_SOUND ;             SAVE YM-SOUND
                DC.W 1,82,114,89
                DC.L MAKE_MODULE ;               LOAD_SAMPLE ;               LOAD SAMPLE
                DS.W 6
                EVEN

MEMORY_MOUSE_TAB:
                DC.W 103,12,114,19
                DC.L QUIT_CURRENT_BOX
                DC.B $00,']',$00,$16,$00,'r',$00,$1D
                DC.L L01CA
                DC.B $00,']',$00,' ',$00,'r',$00,$27
                DC.L L01CC
                DC.B $00,']',$00,'*',$00,'r',$00,'1'
                DC.L L01CF
                DC.B $00,']',$00,'4',$00,'r',$00,';'
                DC.L L01D4
                DC.B $00,']',$00,'>',$00,'r',$00,'E'
                DC.L L01D8
                DC.B $00,']',$00,'H',$00,'r',$00,'O'
                DC.L L01D9
                DS.W 6
                EVEN
L02B0:          DC.B $00,'R'
                DC.L L0143
                DC.B $00,'S'
                DC.L L0140
                DC.B $00,'9'
                DC.L L013D
                DC.B $00,$0E
                DC.L L013F
                DC.B $01,';'
                DC.L L015B
                DC.B $01,'<'
                DC.L L015C
                DC.B $01,'='
                DC.L L0164
                DC.B $01,'>'
                DC.L L0161
                DC.B $01,'?'
                DC.L L0167
                DC.B $01,'@'
                DC.L L016B
                DC.B $01,'C'
                DC.L L016F
                DC.B $00,'m'
                DC.L L015B
                DC.B $00,'n'
                DC.L L015C
                DC.B $00,'o'
                DC.L L0164
                DC.B $00,'j'
                DC.L L0161
                DC.B $00,'k'
                DC.L L0167
                DC.B $00,'l'
                DC.L L016B
                DC.B $01,'c'
                DC.L L0167
                DC.B $01,'d'
                DC.L L016B
                EVEN
L02B1:          DC.B $00,';'
                DC.L L0146
                DC.B $00,'<'
                DC.L L0148
                DC.B $00,'='
                DC.L L0157
                DC.B $00,'>'
                DC.L L0159
                DC.B $00,'?'
                DC.L L014B
                DC.B $00,'@'
                DC.L L014E
                DC.B $01,'A'
                DC.L L0176
                DC.B $01,'B'
                DC.L L0172
                DC.B $01,'D'
                DC.L L0151
                DC.B $00,'c'
                DC.L L014B
                DC.B $00,'d'
                DC.L L014E
                DC.B $00,'e'
                DC.L sub_instr_num
                DC.B $00,'f'
                DC.L add_instr_num
                DC.B $00,'J'
                DC.L L0176
                DC.B $00,'N'
                DC.L L0172
                DC.B $01,'J'
                DC.L L017D
                DC.B $01,'N'
                DC.L L017A
                DC.B $00,'p'
                DC.L stop_music
                DC.B $00,'r'
                DC.L L0193
                DC.B $00,'M'
                DC.L L0134
                DC.B $00,'K'
                DC.L L0136
                DC.B $00,'H'
                DC.L L0137
                DC.B $00,'P'
                DC.L L0138
                DC.B $01,'H'
                DC.L L0137
                DC.B $01,'P'
                DC.L L0138
                DC.B $00,'G'
                DC.L L0139
                DC.B $00,'A'
                DC.L L0139
                DC.B $00,'B'
                DC.L L013A
                DC.B $00,'C'
                DC.L L013B
                DC.B $00,'D'
                DC.L L013C
                DC.B $00,'`'
                DC.L L00A4
                DC.B $00,'b'
                DC.L prep_info_page
                DC.B $00,'a'
                DC.L L0189
                DS.W 3
                EVEN

L02B2:          DC.B $00,'S'
                DC.L L012F
                DC.B $00,$0E
                DC.L L0132
                DC.B $00,';'
                DC.L L0180
                DC.B $00,'<'
                DC.L L0182
                DC.B $00,'e'
                DC.L sub_instr_num
                DC.B $00,'f'
                DC.L add_instr_num
                DC.B $00,'`'
                DC.L L00A4
                DC.B $00,'a'
                DC.L L018E
                DS.W 3
                EVEN

L02B3:          DC.B $00,'H'
                DC.L shift_up
                DC.B $00,'P'
                DC.L shift_dwn
                DC.B $00,'`'
                DC.L L00A4
                DS.W 3
                EVEN

L02B4:          DC.B $00,$06,$00,$10,$00,$18,$00,$1D
                DC.B $00,$00,$00,'F',$00,$10,$00,'X'
                DC.B $00,$1D,$00,$01,$00,$00,$00,$00
                DS.W 3
                EVEN
pal_pointer:
                DC.L pal1
                DC.L pal7
                DC.L pal2
                DC.L pal4
                DC.L pal5
                DC.L pal6
                DC.L pal3
                DC.L pal8
                DC.L pal9
                DC.L pal10
                EVEN
pal1:           DC.B $00,$00,$03,' ',$07,'d',$05,'B'
                DC.B $06,'S',$02,$10,$04,'1',$07,$00
                DC.B $00,$02,$00,$06,$00,$06,$00,$06
                DC.B $00,$06,$00,$06,$00,$06,$00,$06
                EVEN
pal2:           DC.B $00,$00,$01,'!',$05,'e',$03,'C'
                DC.B $04,'T',$00,$10,$02,'2',$07,$00
                DC.B $00,$02,$00,$06,$00,$06,$00,$06
                DC.B $00,$06,$00,$06,$00,$06,$00,$06
                EVEN
pal3:           DC.B $00,$00,$02,'"',$06,'f',$04,'D'
                DC.B $05,'U',$01,$11,$03,'3',$07,$00
                DC.B $00,$02,$00,$06,$00,$06,$00,$06
                DC.B $00,$06,$00,$06,$00,$06,$00,$06
                EVEN
pal4:           DC.B $00,$00,$00,'!',$00,'e',$00,'C'
                DC.B $00,'T',$00,$10,$00,'2',$07,$00
                DC.B $00,$02,$00,$06,$00,$06,$00,$06
                DC.B $00,$06,$00,$06,$00,$06,$00,$06
                EVEN
pal5:           DC.B $00,$00,$02,$00,$06,'0',$04,$10
                DC.B $05,' ',$01,$00,$03,$00,$07,$00
                DC.B $00,$02,$00,$06,$00,$06,$00,$06
                DC.B $00,$06,$00,$06,$00,$06,$00,$06
                EVEN
pal6:           DC.B $00,$00,$06,'"',$07,'f',$07,'D'
                DC.B $07,'U',$07,$11,$07,'3',$07,$00
                DC.B $02,$02,$07,$07,$07,$07,$07,$07
                DC.B $07,$07,$07,$07,$07,$07,$07,$07
                EVEN
pal7:           DC.B $00,$00,$01,'6',$05,'w',$03,'W'
                DC.B $04,'g',$00,'%',$02,'G',$07,$00
                DC.B $00,$02,$00,$06,$00,$06,$00,$06
                DC.B $00,$06,$00,$06,$00,$06,$00,$06
                EVEN
pal8:           DC.B $00,$00,$02,$02,$06,$06,$04,$04
                DC.B $05,$05,$01,$01,$03,$03,$07,$00
                DC.B $00,$02,$00,$06,$00,$06,$00,$06
                DC.B $00,$06,$00,$06,$00,$06,$00,$06
                EVEN
pal9:           DC.B $00,$00,$05,'U',$02,'"',$03,'3'
                DC.B $02,'"',$06,'f',$04,'D',$07,$00
                DC.B $07,'w',$02,'"',$06,'f',$04,'D'
                DC.B $05,'U',$01,$11,$03,'3',$07,$00
                EVEN
pal10:          DC.B $00,$00,$02,' ',$06,'`',$04,'@'
                DC.B $05,'P',$01,$10,$03,'0',$07,$00
                DC.B $00,$02,$00,$06,$00,$06,$00,$06
                DC.B $00,$06,$00,$06,$00,$06,$00,$06
                EVEN
xpal1:          DC.B $00,$00,$03,' ',$07,'d',$05,'B'
                DC.B $06,'S',$02,$10,$04,'1',$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal2:          DC.B $00,$00,$01,'!',$05,'e',$03,'C'
                DC.B $04,'T',$00,$10,$02,'2',$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal3:          DC.B $00,$00,$02,'"',$06,'f',$04,'D'
                DC.B $05,'U',$01,$11,$03,'3',$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal4:          DC.B $00,$00,$00,'!',$00,'e',$00,'C'
                DC.B $00,'T',$00,$10,$00,'2',$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal5:          DC.B $00,$00,$02,$00,$06,'0',$04,$10
                DC.B $05,' ',$01,$00,$03,$00,$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal6:          DC.B $00,$00,$06,'"',$07,'f',$07,'D'
                DC.B $07,'U',$07,$11,$07,'3',$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal7:          DC.B $00,$00,$01,'6',$05,'w',$03,'W'
                DC.B $04,'g',$00,'%',$02,'G',$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal8:          DC.B $00,$00,$02,$02,$06,$06,$04,$04
                DC.B $05,$05,$01,$01,$03,$03,$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal9:          DC.B $00,$00,$05,'U',$02,'"',$03,'3'
                DC.B $02,'"',$06,'f',$04,'D',$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                DC.W $02,$06,$04,$05
                DC.W $01,$03,$06,$07
                EVEN
xpal10:         DC.B $00,$00,$02,' ',$06,'`',$04,'@'
                DC.B $05,'P',$01,$10,$03,'0',$07,$00
                DC.W $0444,$0555,$0666,$0777 ;2,$06,$04,$05
                DC.W $0777,$0666,$0555,$0444
                EVEN

info_page_pal:  DC.L xpal1
                DC.L xpal7
                DC.L xpal2
                DC.L xpal4
                DC.L xpal5
                DC.L xpal6
                DC.L xpal3
                DC.L xpal8
                DC.L xpal9
                DC.L xpal10
                EVEN

L02C2:          DC.W $0777,$0777,$0677,$0577,$0477,$0377,$0277,$0177
                DC.W $77,$77,$67,$57,$47,$36,$25,$14,$03
                DS.W 10

                DC.B $07,'w',$07,'w',$07,'f',$07,'U'
                DC.B $07,'D',$07,'3',$07,'"',$07,$11
                DC.B $07,$00,$07,$00,$06,$00,$05,$00
                DC.B $04,$00,$03,$00,$02,$00,$01,$00
                DC.B $00,$00
                EVEN
*****************************************************************+
info_bar:       IBYTES 'INFO_BAR.*'
                DS.B 2000
                EVEN
EDIT_PIC:       IBYTES 'EDITOR.3PL' ;MAIN_GFX.3PL'
                EVEN
YM_EDIT_PIC:    IBYTES 'EXTEND.3PL' ;YM_ED_GF.3PL'
                EVEN
ste_digi_PIC:   IBYTES 'STE_DMA.3PL'
                EVEN
font:           IBYTES 'SPEC_FNT.1PL'
                EVEN
alertbox:       IBYTES 'ALERBOX.IMG'
                EVEN
MOUSE_POINTER:  DC.L MOUSE_GFX  ; MOUSEPOINTEREINTRAEGE
                DS.L 15         ; 15 WEITER FUER SHIFTING
                EVEN
WHAT_MOUSE:     DC.L MOUSE_POINTER
                EVEN
MOUSE_POINTER2: DC.L MOUSE_GFX2 ; MOUSEPOINTEREINTRAEGE
                DS.L 15         ; 15 WEITER FUER SHIFTING
                EVEN
MOUSE_GFX:
********************************
                DC.W %1111111111111111
                DC.W %1111111111111110
                DC.W %1111111111111100
                DC.W %1111111111111000
                DC.W %1111111111110000
                DC.W %1111111111100000
                DC.W %1111111111000000
                DC.W %1111111110000000
                DC.W %1111111100000000
                DC.W %1111111000000000
                DC.W %1111110000000000
                DC.W %1111100000000000
                DC.W %1111000000000000
                DC.W %1110000000000000
                DC.W %1100000000000000
                DC.W %1000000000000000
                DC.W %0
                EVEN
MOUSE_GFX2:
********************************
                DC.W %1111111100000000
                DC.W %1000011000000000
                DC.W %1100110000000000
                DC.W %1101100000000000
                DC.W %1101000000000000
                DC.W %1110000000000000
                DC.W %1100000000000000
                DC.W %1000000000000000

                DC.W %0
                DC.W %0
                DC.W %0
                DC.W %0
                DC.W %0
                DC.W %0
                DC.W %0
                DC.W %0
                DC.W %0
                EVEN

y               SET 882         ; 882

function_gfx_tab:
                DC.L function+4*y ;882 ; d5
                DC.L function+0*y ; d1
                DC.L function+1*y ; d2
                DC.L function+2*y ; d3
                DC.L function+3*y ; d4
                DC.L function+4*y ; d5
                DC.L function+4*y ; d5
********************************
L02D0:          DC.L L02B0
                DC.L L02B1
                DC.L L02B1
                DC.L L02B1
                DC.L L02B1
                DC.L L02B2
                DC.L L02B2
                EVEN

function:       IBYTES 'FUNCTION.IMG'
                EVEN

GFX_N_MOUSE_TAB:DC.L NOTHING_MOUSE_TAB
                DC.L DIGI_BOX
                DC.L DISK_MOUSE_TAB
                DC.L LOAD_SAVE_BOX
                DC.L MEMORY_MOUSE_TAB
                DC.L MEM_DIV_BOX
                EVEN
LOAD_SAVE_BOX:  IBYTES 'DISKACC.IMG'
MEM_DIV_BOX:    IBYTES 'MEMORY.IMG'
DIGI_BOX:       IBYTES 'NORMAL.IMG'
                EVEN
L02DA:          DS.B 80,8
                EVEN
L02F9:          DC.B '=>?',$FF
                EVEN
L02FA:          DC.B '"',$16,$1C,$FF
                EVEN
L02FB:          DC.B $1B,$0E,$15,$0E,$0A,$1C,$0E,$FF
                EVEN
L02FC:          DC.B $0A,$1D,$1D,$0A,$0C,$14,'*',$FF
                EVEN
L02FD:          DC.B $1C,$1E,$1C,$1D,$0A,$12,$17,$FF
                EVEN
L02FE:          DC.B '<',$FF
                EVEN
L02FF:          DC.B '*',$FF
                EVEN
L0300:          DC.B $18,$17,'*',$FF
                EVEN
L0301:          DC.B $18,$0F,$0F,$FF
                EVEN
L0302:          DC.B $0A,$1E,$1D,$18,$FF
                EVEN
L0303:          DC.B $0F,$1B,$0E,$1A,$1E,$0E,$17,$0C,'"'
                DC.B $FF
                EVEN
L0304:          DC.B $0A,$16,$19,$15,$12,$1D,$1E,$0D,$0E
                DC.B $FF,$00
                EVEN
L0305:          DC.L L0306
                DC.L L0307
                DC.L L0308
                DC.L L0309
                DC.L L030A
                DC.L L030B
                DC.L L030C
                DC.L L030D
                EVEN
L0306:          DC.B 'Load Tunefile     :',0
L0307:          DC.B 'Save Tunefile     :',0
L0308:          DC.B 'Load VSET         :',0
L0309:          DC.B 'Save VSET         :',0
L030A:          DC.B 'Load YM Sound     :',0
L030B:          DC.B 'Save YM Sound     :',0
L030C:          DC.B 'Save CHIP-MODULE  :',0 ;         Load Sample       :',0
L030D:          DC.B 'Fatal Error       :',0
L030E:          DC.B '*'
L030F:          DC.B '.TRI',0
L0310:          DC.B '*.TVS',0
L0311:          DC.B '*'
L0312:          DC.B '.YMS',0
L0313:          DC.B '*.MOD',0
                EVEN
L0314:          DC.L disk_err
                DC.L disk_err
                DC.L drive_not
                DC.L disk_err
                DC.L L0318
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L L0317
                DC.L L0318
                DC.L disk_err
                DC.L L0319
                DC.L disk_err
                DC.L L031A
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L L031B
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L L031A
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L L031C
                DC.L L031D
                DC.L L031E
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                DC.L disk_err
                EVEN
disk_err:       DC.B 'Disk Error          ',0
drive_not:      DC.B 'Drive not Ready     ',0
L0317:          DC.B 'Write Fault         ',0
L0318:          DC.B 'Read Fault          ',0
L0319:          DC.B 'Write Protected Disk',0
L031A:          DC.B 'Unknown Device      ',0
L031B:          DC.B 'File not Found      ',0
L031C:          DC.B 'Memory Full         ',0
L031D:          DC.B 'Wrong File Format   ',0
L031E:          DC.B 'Disk Full           ',0
                EVEN
**********************************************************************
L031F:          DC.B '                                 ',13
                DC.B 'THE INDEPENDENT DESIGN  1993-1994',13
                DC.B '                                 ',13
                DC.B '  A.M.-Sidsound DESIGNER v3.5 p  ',13
                DC.B '         Pre-release v3.5        ',13
                DC.B '                                 ',13
                DC.B '              WITH               ',13
                DC.B '      EXTENDED INSTRUMENT        ',13
                DC.B '          SYNTHESIZER            ',13
                DC.B '                                 ',13
                DC.B '                                 ',13
                DC.B 'CODING BY:  MC/LYNX              ',13
                DC.B 'Graphics: NO MORE/MC             ',13
                DC.B '                                 ',13
                DC.B '                                 ',13
                DC.B '**** Keyboard Shortcuts: ****    ',13
                DC.B 'F1  - Cut Track/YM sound         ',13
                DC.B 'F2  - Paste Track/YM sound       ',13
                DC.B 'F3  - Cut Pattern                ',13
                DC.B 'F4  - Paste Pattern              ',13
                DC.B 'F5  - Overlay Track              ',13
                DC.B 'F6  - Underlay Track             ',13
                DC.B 'F7  - Goto 00                    ',13
                DC.B 'F8  - Goto 10                    ',13
                DC.B 'F9  - Goto 20                    ',13
                DC.B 'F10 - Goto 30                    ',13
                DC.B '---------------------------------',13
                DC.B 'Shifted:                         ',13
                DC.B 'F1  - Start Block                ',13
                DC.B 'F2  - End Block                  ',13
                DC.B 'F3  - Past Block                 ',13
                DC.B 'F4  - Delete Block               ',13
                DC.B 'F5  - Overlay block              ',13
                DC.B 'F6  - Underlay block             ',13
                DC.B 'F7  - Transpose block up         ',13
                DC.B 'F8  - Transpose block down       ',13
                DC.B 'F9  - Paste reverse block        ',13
                DC.B 'F10 - Paste reverse track        ',13
                DC.B '---------------------------------',13
                DC.B 'Numeric Key block:               ',13
                DC.B '1   - Start block                ',13
                DC.B '2   - End block                  ',13
                DC.B '3   - Paste block                ',13
                DC.B '4   - delete block               ',13
                DC.B '5   - Overlay block              ',13
                DC.B '6   - underlay block             ',13
                DC.B '+   - Transpose up               ',13
                DC.B '-   - Transpose down             ',13
                DC.B 'shift + - transpose volume up    ',13
                DC.B 'shift - - transpose volume down  ',13
                DC.B '/       - previous YM sound      ',13
                DC.B '*       - next ym sound          ',13
                DC.B '(       - overlay track          ',13
                DC.B ')       - underlay track         ',13
                DC.B 'shift ( - overlay track          ',13
                DC.B 'shift ) - underlay track         ',13
                DC.B '0       - Stop                   ',13
                DC.B 'Enter   - Pattern play           ',13
                DC.B '---------------------------------',13
                DC.B 'Other keyboard shortcuts:        ',13
                DC.B '\       - ACIEEEEEEEEDDDDDDDDDD  ',13
                DC.B 'ClrHome - goto 00                ',13
                DC.B 'Space   - clear current note     ',13
                DC.B 'Backspace - clear with step(!)   ',13
                DC.B 'Delete  - delete current note    ',13
                DC.B 'insert  - insert note            ',13
                DC.B 'arrows  - move cursor            ',13
                DC.B 'help    - enter help screen      ',13
                DC.B 'Undo    - undo last operation    ',13
                DC.B '---------------------------------',13
                DC.B '**** The digits: ****            ',13
                DC.B 'ym sound note:                   ',13
                DC.B '---------------------------------',13
                DC.B 'c#2001dfA                        ',13
                DC.B '&                                ',13
                DC.B 'note                             ',13
                DC.B '---------------------------------',13
                DC.B 'c#2001dfA                        ',13
                DC.B '  &                              ',13
                DC.B 'octave - range 0-7               ',13
                DC.B '---------------------------------',13
                DC.B 'c#2001dfA                        ',13
                DC.B '   &&                            ',13
                DC.B 'Portamento (tie) speed           ',13
                DC.B '---------------------------------',13
                DC.B 'c#2001dfA                        ',13
                DC.B '     &&                          ',13
                DC.B 'ym sound number - range 0-3f     ',13
                DC.B '---------------------------------',13
                DC.B 'c#2001dfA                        ',13
                DC.B '       &                         ',13
                DC.B 'ym sound volume - range 0-f      ',13
                DC.B '---------------------------------',13
                DC.B 'c#2001dfA                        ',13
                DC.B '        &                        ',13
                DC.B 'envelope value: (A/S/R)          ',13
                DC.B '---------------------------------',13
                DC.B 'command codes:                   ',13
                DC.B '                                 ',13
                DC.B '  $0e = BREAK COMMAND            ',13
                DC.B '  $0f = Speed COMMAND followed by',13
                DC.B '        Speedvalue in the Cmd    ',13
                DC.B '---------------------------------',13
                DC.B ' Command Code-Table:             ',13
                DC.B '---------------------------------',13
                DC.B ' $00  = Nothing                  ',13
                DC.B ' $01  = SID echo on     -b-      ',13
                DC.B ' $02  = SID echo off    -b-      ',13
                DC.B ' $03  = Nothing                  ',13
                DC.B ' $04  = set SID effect -a- on    ',13
                DC.B ' $05  = set sid effect -a- off   ',13
                DC.B ' $06  = set sid effect -b- on    ',13
                DC.B ' $07  = set sid effect -b- off   ',13
                DC.B ' $08  = set sid effect -c- on    ',13
                DC.B ' $09  = set sid effect -c- off   ',13
                DC.B ' $0a  = wave 1 on channle b      ',13
                DC.B ' $0b  = wave 2 on channle b      ',13
                DC.B ' $0c  = wave 3 on channle b      ',13
                DC.B ' $0d  = reset all settings       ',13
                DC.B ' $0e  = Nothing                  ',13
                DC.B ' $0f  = Nothing                  ',13
                DC.B '---------------------------------',13
                DC.B '                                 ',13
                DC.B ' $10 in WAVE FX achieves double  ',13
                DC.B ' replay speed on current instr.  ',13
                DC.B ' (TWO CALLS per VBL)             ',13
                REPT 10
                DC.B '                                 ',13
                ENDR
                EVEN
L0320:          DC.B $1B,'E',$0A,' This'
                DC.B ' program'
                DC.B ' runs in lo-res, only.'
                DC.B $0D,$0A,' '
                DC.B ' Reboot in lo-res, please.'
                DC.B $0D,$0A,' Press any key to quit...'
                DC.B $0D,$0A
                DC.B $00,$00
                EVEN
L0321:          DC.L L0384
                DC.L L0383
                DC.L L0389
                DC.L L038A
                DC.L L038C
                DC.L L038E
                EVEN
mod_replay:     IBYTES 'PLAY_MOD.BIN'
                DS.W 1000
                EVEN
title:          IBYTES 'TITEL.PI1'
                EVEN
                ENDPART
**********************************************************
                >PART 'BSS'
                BSS
start_bss:
reggs_ret:      DS.L 32
dummy:          DS.L 1
                EVEN
repl_buff:      DS.B 5474
BUFF:           DS.W 30000
sid_norm:       DS.W 1
L0322:          DS.W 1
L0323:          DS.L 1
L0324:          DS.B 128
spec_table:     DS.B 252
L0325:          DS.L 1
L007D:          DS.L 1
******************************************

bdata:          DS.B 16         ; 14
b_1:            DS.B 6
b_2:            DS.W 1
b_3:            DS.W 1
b_4:            DS.W 1
b_5:            DS.B 6
b_6:            DS.W 1
b_7:            DS.W 1
b_8:            DS.B 6
b_9:            DS.B 13
b_10:           DS.B 1
b_11:           DS.B 2          ; Normale L„nge bis Offset $3c

ext_sound_b:    DS.B 26         ; $3d-$52

cdata:          DS.B 16         ; 14
c_1:            DS.B 6
c_2:            DS.W 1
c_3:            DS.W 1
c_4:            DS.W 1
c_5:            DS.B 6
c_6:            DS.W 1
c_7:            DS.W 1
c_8:            DS.B 6
c_9:            DS.B 13
c_10:           DS.B 1
c_11:           DS.B 2          ;24
ext_sound_c:    DS.B 26

adata:          DS.B 16         ;14
a_1:            DS.B 6
a_2:            DS.W 1
a_3:            DS.W 1
a_4:            DS.W 1
a_5:            DS.B 6
a_6:            DS.W 1
a_7:            DS.W 1
a_8:            DS.B 6
a_9:            DS.B 13
a_10:           DS.B 1
a_11:           DS.B 2          ;4
ext_sound_a:    DS.B 26

old110:         DS.L 1
oldvbl:         DS.L 1
oldkey:         DS.L 1
L034F:          DS.W 1
L0350:          DS.W 1
L0351:          DS.W 1
L0352:          DS.W 1
L0353:          DS.W 1
L0355:          DS.B 1
L0356:          DS.B 1
L0357:          DS.B 1
L0358:          DS.B 1
L0359:          DS.B 1
L035A:          DS.B 1
L035B:          DS.B 1
L035C:          DS.B 1
L035D:          DS.B 1
L035E:          DS.B 1
L035F:          DS.B 1
L0360:          DS.B 1
L0361:          DS.B 1
L0362:          DS.B 1

X_MOUSE_REL:    DS.B 1
Y_MOUSE_REL:    DS.B 1
X_MOUSE_POS:    DS.W 1
Y_MOUSE_POS:    DS.W 1


L0367:          DS.W 1
L0368:          DS.L 1
L0369:          DS.W 1
L036A:          DS.L 1
L036B:          DS.W 1
mouse_tab_pnt:  DS.L 1
L036D:          DS.L 1
key_table_pnt:  DS.L 1
vbl_call:       DS.L 1
L0370:          DS.B 1
L0371:          DS.B 1
song_edit_flag: DS.B 1
L0373:          DS.B 1
L0374:          DS.B 1
info_page_flag: DS.B 1
ste_page:       DS.B 1
                EVEN
L0376:          DS.W 1
                EVEN
KENNUNGS_LONG:  DS.L 1          ; HIER KOMMT "TSST"/"TSSS"/"TSSY" REIN
L0379:          DS.B 128
L037A:          DS.B 128
L037B:          DS.B 14
L037C:          DS.B 128
L037D:          DS.B 14
L037E:          DS.B 128
L037F:          DS.B 14
L0380:          DS.B 128
L0382:          DS.W 1
L0383:          DS.B 32
L0384:          DS.W 1
L0385:          DS.W 1
L0386:          DS.W 1
L0387:          DS.W 1
L0388:          DS.B 12
L0389:          DS.B 256
L038A:          DS.W 1
L038B:          DS.B 254
L038C:          DS.L 1
L038D:          DS.B 508
L038E:          DS.B 512
L038F:          DS.W 1
L0390:          DS.W 1
L0391:          DS.W 1
L0392:          DS.W 1
L0393:          DS.W 1
L0394:          DS.W 1
L0395:          DS.W 1
L0396:          DS.W 1
L0397:          DS.W 1
L0398:          DS.B 256
L0399:          DS.B 512
L039A:          DS.B 786
L039B:          DS.L 1
L039C:          DS.L 1
L039D:          DS.L 1
L039E:          DS.B 8
L039F:          DS.B $80*12
L03A0:          DS.B 256
L03A1:          DS.W 1
L03A2:          DS.W 1
instrument_adr: DS.L 1
L03A4:          DS.W 1
L03A5:          DS.B 1
L03A6:          DS.B 1
L03A7:          DS.W 1
L03A8:          DS.W 1
L03A9:          DS.W 1
text_xpos:      DS.W 1
text_ypos:      DS.W 1
L03AC:          DS.W 1
L03AD:          DS.W 1
L03AE:          DS.W 1
L03AF:          DS.L 1
recording_flag: DS.W 1
L03B1:          DS.B 8
L03B2:          DS.W 1
L03B3:          DS.W 1
what_function:  DS.W 1
L03B5:          DS.B 1
L03B6:          DS.B 1
L03B7:          DS.B 1
instr_num:      DS.B 1
volume:         DS.B 1
pat_pos_count:  DS.B 1
L03BB:          DS.W 1
L03BC:          DS.W 1
sam_num:        DS.W 1
song_position:  DS.W 1
pattern_:       DS.W 1
L03C0:          DS.B 480
act_pat_adr:    DS.L 1
pos_in_pat:     DS.W 1
L03C3:          DS.L 1
L03C4:          DS.L 1
L03C5:          DS.B 12
L03C6:          DS.L 1
L03C7:          DS.B 12
L03C8:          DS.L 1
L03C9:          DS.B 12
L03CA:          DS.B 12
L03CB:          DS.B 10
screen:         DS.L 1
L03CD:          DS.B 32
pal_number:     DS.W 1
L03D1:          DS.B 1024
NEW_MOUSE:      DS.B 1024
L03D2:          DS.B 128
total_sam_lenght:DS.L 1
instr_names:    DS.B 512        ; INSTRUMENT NAMES
instr_datas:    DS.B 16384      ; DATAS INSTRUMENT
sam_names:      DS.B 128
sam_offset_tab: DS.B 128
sam_freqs:      DS.B 16
first_sample:   DS.L 2          ;32768
L03DA:          DS.L 1
L03DB:          DS.L 1

L03DC:          DS.W 1
L03DD:          DS.W 1
L03DE:          DS.W 1
L03DF:          DS.W 1
L03E0:          DS.B 120
L03E1:          DS.B 24576
L03E2:          DS.B 32768
*****************************************+
rett_buff:      DS.B 32000
                DS.B 16000
newstack:
end_bss:        DS.B 4
oldstack:       DS.L 1
ssp:            DS.L 1
merk_:          DS.L 1
oldscreen:      DS.W 1
                DS.B 256        ; because of screen lowbyte reserve 256 more
screen_base:    DS.B 32000*2    ; space for two screens
                ENDPART
**********************************************************
                END
