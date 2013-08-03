******************************************************
* Spezial Code um Musik abzuspielen !!!
* Replay kostet max. 1.3 Scanlines
******************************************************

                PEA     0.w
                MOVE.W  #32,-(SP)
                TRAP    #1
                ADDQ.L  #6,SP

                CLR.L   $FFFFFA06.w
                CLR.L   $FFFFFA12.w

                MOVEM.L end_datas,D0-D7
                MOVEM.L D0-D7,$FFFF8240.w

                MOVEA.L $044E.w,A0
                MOVE.W  #7999,D0
clear:          CLR.L   (A0)+
                DBRA    D0,clear

                LEA     info_txt,A0
                MOVEA.L $044E.w,A1
                BSR     depack_35

                LEA     datas,A0
                MOVEA.L A0,A1
                BSR     depack

                MOVE.L  #new_timer,$0110.w
                BSET    #4,$FFFFFA15.w
                BCLR    #4,$FFFFFA09.w  ; Timer A Disablen
                BSET    #0,$FFFFFA07.w
                BSET    #0,$FFFFFA13.w
                CLR.B   $FFFFFA1D.w
                CLR.B   $FFFFFA25.w
                BCLR    #3,$FFFFFA17.w

                MOVE.L  #vbl,$70.w

w:              CMPI.B  #$39,$FFFFFC02.w
                BNE.S   w

                PEA     0
                TRAP    #1


vbl:            MOVEM.L D0-A6,-(SP)
sync:           MOVE.B  $FFFF8209.w,D0
                BEQ.S   sync
                NOT.W   D0
                LSR.W   D0,D0
                REPT 28
                NOP
                ENDR

                CLR.B   $FFFFFA1B.w
                MOVE.B  #177,$FFFFFA21.w
                MOVE.B  #8,$FFFFFA1B.w
                MOVE.L  #change,$0120.w


                MOVE.W  #$0500,$FFFF8240.w
                MOVE.W  d46,$FFFF8246.w
                BSR     player
                CLR.W   $FFFF8240.w
                MOVEQ   #2,D0
repeat_:
                REPT 122
                NOP
                ENDR
                DBRA    D0,repeat_
                MOVE.W  what,D7
                TST.W   D7
                BEQ.S   nix_sub
                SUBQ.W  #1,D7
                MOVE.W  #$05,$FFFF8240.w

ki:             MOVE.L  #0,$FFFF825C.w
                ADDI.W  #0,$08.w
                DBRA    D7,ki

nix_sub:        CLR.W   what
                CLR.W   $FFFF8240.w

                TST.W   fertig
                BEQ.S   nix_test
                SUBQ.W  #1,c
                BNE.S   nix_test
                ADDI.W  #$10,d46
                MOVE.W  #5,c
                CMPI.W  #$40,d46
                BLT.S   nix_test
                MOVE.W  #$42,d46
                CLR.W   fertig
nix_test:
                BSR     ANALYZER
                MOVEM.L (SP)+,D0-A6
                RTE
change:
*                MOVE.W  #$0555,$FFFF8240.w

                MOVEM.L A0-A1,-(SP)

                MOVEA.W #$8242,A1
                LEA     PAL+2,A0
                MOVE.W  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                MOVE.L  (A0)+,(A1)+
                MOVEM.L (SP)+,A0-A1

                CLR.B   $FFFFFA1B.w
                MOVE.B  #1,$FFFFFA21.w
                MOVE.B  #8,$FFFFFA1B.w
                MOVE.L  #black,$0120.w
                RTE

black:
                CLR.W   $FFFF8240.w
                CLR.B   $FFFFFA1B.w
                MOVE.B  #16+4,$FFFFFA21.w
                MOVE.B  #8,$FFFFFA1B.w
                MOVE.L  #b2,$0120.w
                RTE
b2:
*                MOVE.W  #$0555,$FFFF8240.w
                CLR.B   $FFFFFA1B.w
                MOVE.B  #1,$FFFFFA21.w
                MOVE.B  #8,$FFFFFA1B.w
                MOVE.L  #black2,$0120.w
                RTE
black2:
                CLR.W   $FFFF8240.w
                MOVE.L  #erte,$0120.w
                CLR.B   $FFFFFA1B.w
erte:           RTE
c:              DC.W 5
fertig:         DC.W 1
                EVEN

nw:                                     * MOVE    #$2500,SR
new_timer:      MOVE.L  #$09090000,$FFFF8800.w
                ADDI.W  #new_timer2w-nw,$0112.w ;ew_timer,$0112.w
                ADDQ.W  #1,what
                RTE
new_timer2w:                            * MOVE    #$2500,SR
new_timer2:     MOVE.L  #$09090000,$FFFF8800.w
                SUBI.W  #new_timer2w-nw,$0112.w ;new_timer,$0112.w
                ADDQ.W  #1,what
                RTE

player:         PART
                MOVEM.L actual_a0,A0-A1 ; Raw chip-data & SID Table
                MOVEA.W #$8800,A5       ; Soundchip Reg
                MOVEA.W #$FA09,A6       ; Timer Reg
                MOVE.B  (A1)+,D7        ; Get amount of CHIP-Data per VBL

                SUBQ.W  #1,count
                BNE.S   replay_

                MOVE.W  #(end_sid-sid_dat)/4+1,count
                MOVE.L  #datas,actual_a0
                MOVE.L  #sid_dat,sid_

                BRA.S   player

replay_:        MOVE.W  (A0)+,D6        ; Soundchip-Data
                MOVEP.W D6,0(A5)        ; Write raw-data
                DBRA    D7,replay_      ; lolipop

                MOVE.B  (A1)+,D5        ; Volume
                MOVE.B  (A1)+,D0        ; Timer Data
                MOVE.B  (A1)+,D3        ; Timer Control
                TST.B   D5              ; Check out SID state
                BMI.S   nix_sid         ; negative means no SID
                MOVE.B  D5,new_timer2+4 ; Okay transfer VOLUME to Timer
                MOVE.B  D0,$1C(A6)      ; Set Timer Data
                MOVE.B  D3,$14(A6)      ; Set its control
                BSET    #4,(A6)         ; and start the show
                BRA.S   sid             ; Go on
nix_sid:        BCLR    #4,(A6)         ; When no SID is used, no Timer
sid:            MOVE.L  A0,actual_a0    ; Write back all adresses
                MOVE.L  A1,sid_         ;
                RTS
                ENDPART
                >PART 'Depacker'
sentry2:        LEA     (A1),A3
                LEA     0(A0,D0.l),A0
                TST.B   -1(A0)
                BNE.S   .cont1
                SUBQ.L  #1,A0
.cont1:         MOVEQ   #8,D6
                BSR     get_long1
                CMPI.L  #'2tnS',D0      ; Snt2
                BEQ.S   .unpack
                RTS
.unpack:        BSR     get_long1
                LEA     0(A3,D0.l),A2   ; dest adres
                MOVE.L  D0,-(SP)
                MOVEA.L A2,A5           ; save for picture depack
                BSR     get_long1
                MOVEQ   #0,D1
                BSR     .getbyte
                MOVE.W  D2,unp_pic
                MOVEQ   #0,D1
                BSR     .getbyte
                MOVE.W  D2,unp_sam
                BNE.S   .no_sam
                MOVE.L  D0,-(SP)
                BSR     get_long1
                MOVE.L  D0,samoff1+4
                BSR     get_long1
                MOVE.L  D0,samoff1
                MOVE.L  (SP)+,D0
.no_sam:        BSR.S   .unp_loop       ; unpack data
                TST.W   unp_pic
                BNE.S   .no_pic
                BSR     unp_picture
.no_pic:        TST.W   unp_sam
                BNE.S   .no_mod
                BSR     samples
.no_mod:        MOVE.L  (SP)+,D0
                RTS

.unp_loop:
                BSR.S   .getbit
.cont:          BCS.S   .blocks
                BSR.S   .getbit
                BCS.S   .copy_2
                MOVE.B  -(A0),-(A2)     ; 1 byte copy
                BRA     .l_col
.copy_2:        BSR.S   .getbit
                BCS.S   .c_more
                MOVEQ   #1,D2           ; copy 2 bytes
                BRA.S   .copy
.c_more:        LEA     copy_tab1(PC),A4
.c_loop:        MOVE.L  (A4)+,D1
                BSR.S   .getbyte        ; haal aantal
                SUBQ.W  #1,D2
                BPL.S   .found
                BRA.S   .c_loop
.found:         SWAP    D1
                ADD.W   D1,D2

.copy:          MOVE.B  -(A0),-(A2)
                DBRA    D2,.copy
                BRA     .l_col

.get_off:
                MOVEQ   #1,D1           ;OFFSET
                BSR.S   .getbyte
                MOVE.B  0(A4,D2.w),D1   ; bits
                ADD.W   D2,D2
                EXT.W   D1
                MOVE.W  4(A4,D2.w),D4
                BSR.S   .getbyte
                ADD.W   D4,D2
                RTS
.getbit:        ADD.L   D0,D0           ;LSR.L  #1,D0
                BEQ.S   .haha
                RTS
.haha:          BSR.S   get_long1
                ADDX.L  D0,D0           ;ROXR.L  #1,D0
                RTS
.haha1:         BSR.S   get_long1
                ADDX.L  D0,D0           ;ROXR.L  #1,D0
                BRA.S   .getbyt
.getbyte:
                CLR.W   D2
.loop:          ADD.L   D0,D0           ;LSR.L  #1,D0
                BEQ.S   .haha1
.getbyt:        ADDX.L  D2,D2
                DBRA    D1,.loop
                RTS

.blocks:        BSR.S   .getbit
                BCS.S   .string3
                MOVEQ   #1,D3           ; 2 bytes-string
                MOVEQ   #8-1,D1         ; small-bits-offset
                BRA.S   .string_copy
.string3:
                LEA     small_offset1(PC),A4
                BSR.S   .getbit
                BCS.S   .string_more
                MOVEQ   #2,D3           ; 3 bytes-string
                BRA.S   .do_strings
.string_more:
                MOVEQ   #1,D1           ; 2 bits-commando
                BSR.S   .getbyte
                SUBQ.W  #1,D2           ; large string?
                BMI.S   .large
                MOVEQ   #3,D3           ; minimaal 4 bytes-string
                ADD.W   D2,D3           ; meer?
                BRA.S   .do_strings
.large:         LEA     aantal_tab1(PC),A4
                BSR.S   .get_off
                MOVE.W  D2,D3
                LEA     offset_tab1(PC),A4
.do_strings:
                BSR.S   .get_off
                BRA.S   .s_copy
.string_copy:
                BSR.S   .getbyte
.s_copy:        MOVE.B  -1(A2,D2.w),-(A2)
                DBRA    D3,.s_copy

.l_col:         CMPA.L  A2,A3
                BLT     .unp_loop
                RTS
get_long1:
                MOVE.B  -(A0),D0
                LSL.L   D6,D0
                MOVE.B  -(A0),D0
                LSL.L   D6,D0
                MOVE.B  -(A0),D0
                LSL.L   D6,D0
                MOVE.B  -(A0),D0
                MOVE    #$10,CCR
                RTS
samples:        LEA     samoff1(PC),A1
                MOVEA.L A3,A0           ; source adres
                ADDA.L  (A1)+,A0
                MOVE.L  (A1),D0
                LEA     0(A0,D0.l),A2
.loopx:         MOVE.B  (A0)+,D0
                SUB.B   D0,(A0)
                NEG.B   (A0)
                CMPA.L  A2,A0
                BLT.S   .loopx
                RTS
unp_picture:
.low:           MOVE.W  #$0F9F,D7
snt2_01:        MOVEQ   #3,D6
snt2_02:        MOVE.W  -(A5),D4
                MOVEQ   #3,D5
snt2_03:        ADD.W   D4,D4
                ADDX.W  D0,D0
                ADD.W   D4,D4
                ADDX.W  D1,D1
                ADD.W   D4,D4
                ADDX.W  D2,D2
                ADD.W   D4,D4
                ADDX.W  D3,D3
                DBRA    D5,snt2_03
                DBRA    D6,snt2_02
                MOVEM.W D0-D3,(A5)
                DBRA    D7,snt2_01
                RTS
samoff1:        DC.L 0,0
unp_pic:        DC.W 0
unp_sam:        DC.W 0
offset_tab1:
                DC.B 5-1,8-1,9-1,13-1
                DC.W 1,1+32,1+32+256,1+32+256+512
aantal_tab1:
                DC.B 2-1,3-1,5-1,9-1
                DC.W 6,6+4,6+4+8,6+4+8+32
small_offset1:
                DC.B 4-1,5-1,7-1,9-1
                DC.W 1,1+16,1+16+32,1+16+32+128
copy_tab1:
                DC.W 2,1
                DC.W 5,2
                DC.W 12,3
                DC.W 27,4
                ENDPART
                >PART 'Picture Depack'
depack_35:      MOVEM.L D0-A6,-(SP)
                CMPI.L  #"ATM5",(A0)+
                BNE     not_packed
                LINK    A2,#$FFE4
                MOVE.L  (A0)+,D0
                MOVEA.L A1,A5
                ADDA.L  D0,A5
                MOVEA.L A5,A4
                LEA     -$0C(A4),A4
                MOVE.L  (A0)+,D0
                MOVEA.L A0,A6
                ADDA.L  D0,A6
                MOVEQ   #0,D0
                MOVE.B  -(A6),D0
                MOVE.W  D0,-2(A2)
                PEA     (A5)
                MOVE.B  -(A6),D7
                BRA     take_type
decrunch:       MOVE.W  D3,D5
take_lenght:    ADD.B   D7,D7
L0002:          DBCS    D5,take_lenght
                BEQ.S   L0005
                BCC.S   L0003
                SUB.W   D3,D5
                NEG.W   D5
                BRA.S   L0008
L0003:          MOVEQ   #3,D6
                BSR.S   get_bit2
                BEQ.S   L0004
                BRA.S   L0007
L0004:          MOVEQ   #7,D6
                BSR.S   get_bit2
                BEQ.S   L0006
                ADDI.W  #$0F,D5
                BRA.S   L0007
L0005:          MOVE.B  -(A6),D7
                ADDX.B  D7,D7
                BRA.S   L0002
L0006:          MOVEQ   #$0D,D6
                BSR.S   get_bit2
                ADDI.W  #$010E,D5
L0007:          ADD.W   D3,D5
L0008:          LEA     decrun_table(PC),A4
                MOVE.W  D5,D2
                BNE.S   bigger
                ADD.B   D7,D7
                BNE.S   L0009
                MOVE.B  -(A6),D7
                ADDX.B  D7,D7
L0009:          BCS.S   L000A
                MOVEQ   #1,D6
                BRA.S   word
L000A:          MOVEQ   #3,D6
                BSR.S   get_bit2
                TST.B   -$1C(A2)
                BEQ.S   L000B
                MOVE.B  -$12(A2,D5.w),-(A5)
                BRA     tst_end
L000B:          MOVE.B  (A5),D0
                BTST    #3,D5
                BNE.S   L000C
                BRA.S   L000D
L000C:          ADDI.B  #$F0,D5
L000D:          SUB.B   D5,D0
                MOVE.B  D0,-(A5)
                BRA     tst_end
get_bit2:       CLR.W   D5
L000F:          ADD.B   D7,D7
                BEQ.S   L0011
L0010:          ADDX.W  D5,D5
                DBRA    D6,L000F
                TST.W   D5
                RTS
L0011:          MOVE.B  -(A6),D7
                ADDX.B  D7,D7
                BRA.S   L0010
bigger:         MOVEQ   #2,D6
word:           BSR.S   get_bit2
                MOVE.W  D5,D4
                MOVE.B  $0E(A4,D4.w),D6
                EXT.W   D6
                TST.B   -$1B(A2)
                BNE.S   L0014
                ADDQ.W  #4,D6
                BRA.S   L0018
L0014:          BSR.S   get_bit2
                MOVE.W  D5,D1
                LSL.W   #4,D1
                MOVEQ   #2,D6
                BSR.S   get_bit2
                CMP.B   #7,D5
                BLT.S   L0016
                MOVEQ   #0,D6
                BSR.S   get_bit2
                BEQ.S   L0015
                MOVEQ   #2,D6
                BSR.S   get_bit2
                ADD.W   D5,D5
                OR.W    D1,D5
                BRA.S   L0019
L0015:          OR.B    -$1A(A2),D1
                BRA.S   L0017
L0016:          OR.B    -$19(A2,D5.w),D1
L0017:          MOVE.W  D1,D5
                BRA.S   L0019
L0018:          BSR.S   get_bit2
L0019:          ADD.W   D4,D4
                BEQ.S   L001A
                ADD.W   -2(A4,D4.w),D5
L001A:          LEA     1(A5,D5.w),A4
                MOVE.B  -(A4),-(A5)
L001B:          MOVE.B  -(A4),-(A5)
                DBRA    D2,L001B
                BRA.S   tst_end
make_jnk:       ADD.B   D7,D7
                BNE.S   L001D
                MOVE.B  -(A6),D7
                ADDX.B  D7,D7
L001D:          BCS.S   string
                MOVE.B  -(A6),-(A5)
tst_end:        CMPA.L  A5,A3
                BNE.S   make_jnk
                CMPA.L  A6,A0
                BEQ.S   work_done
take_type:      MOVEQ   #0,D6
                BSR     get_bit2
                BEQ.S   L0022
                MOVE.B  -(A6),D0
                LEA     -$1A(A2),A1
                MOVE.B  D0,(A1)+
                MOVEQ   #1,D1
                MOVEQ   #6,D2
L0020:          CMP.B   D0,D1
                BNE.S   L0021
                ADDQ.W  #2,D1
L0021:          MOVE.B  D1,(A1)+
                ADDQ.W  #2,D1
                DBRA    D2,L0020
                ST      -$1B(A2)
                BRA.S   L0023
L0022:          SF      -$1B(A2)
L0023:          MOVEQ   #0,D6
                BSR     get_bit2
                BEQ.S   L0025
                LEA     -$12(A2),A1
                MOVEQ   #$0F,D0
L0024:          MOVE.B  -(A6),(A1)+
                DBRA    D0,L0024
                ST      -$1C(A2)
                BRA.S   L0026
L0025:          SF      -$1C(A2)
L0026:          CLR.W   D3
                MOVE.B  -(A6),D3
                MOVE.B  -(A6),D0
                LSL.W   #8,D0
                MOVE.B  -(A6),D0
                MOVEA.L A5,A3
                SUBA.W  D0,A3
                BRA.S   make_jnk
string:         BRA     decrunch
work_done:      MOVEA.L (SP)+,A0
                PEA     (A2)
                BSR.S   decod_picture
                MOVEA.L (SP)+,A2
                UNLK    A2
not_packed:     MOVEM.L (SP)+,D0-A6
                RTS
decrun_table:   DC.B $00,$20,$00,$60,$01,$60,$03,$60
                DC.B $07,$60,$0F,$60,$1F,$60,$00,$01
                DC.B $03,$04,$05,$06,$07,$08
decod_picture:  MOVE.W  -2(A2),D7
L002C:          DBRA    D7,L002D
                RTS
L002D:          MOVE.L  -(A0),D0
                LEA     0(A5,D0.l),A1
                LEA     $7D00(A1),A2
L002E:          MOVEQ   #3,D6
L002F:          MOVE.W  (A1)+,D0
                MOVEQ   #3,D5
L0030:          ADD.W   D0,D0
                ADDX.W  D1,D1
                ADD.W   D0,D0
                ADDX.W  D2,D2
                ADD.W   D0,D0
                ADDX.W  D3,D3
                ADD.W   D0,D0
                ADDX.W  D4,D4
                DBRA    D5,L0030
                DBRA    D6,L002F
                MOVEM.W D1-D4,-8(A1)
                CMPA.L  A1,A2
                BNE.S   L002E
                BRA.S   L002C
                ENDPART
                >PART 'ATOMIC v3.5 Depack'
depack:
************************************************
* Atomic V3.5 Depack Code
* a0.l Packed Data
* a1.l Depacked Data
************************************************
                MOVEM.L D0-A6,-(SP)
                CMPI.L  #"ATM5",(A0)+
                BNE     xnot_packed
                LINK    A2,#$FFE4
                MOVE.L  (A0)+,D0
                MOVEA.L A1,A5
                ADDA.L  D0,A5
                MOVEA.L A5,A4
                LEA     -$0C(A4),A4
                MOVE.L  (A0)+,D0
                MOVEA.L A0,A6
                ADDA.L  D0,A6
                SUBQ.W  #1,A6
                MOVE.B  -(A6),D7
                BRA     xtake_type
xdecrunch:      MOVE.W  D3,D5
xtake_lenght:   ADD.B   D7,D7
xL0002:         DBCS    D5,xtake_lenght
                BEQ.S   xL0005
                BCC.S   xL0003
                SUB.W   D3,D5
                NEG.W   D5
                BRA.S   xL0008
xL0003:         MOVEQ   #3,D6
                BSR.S   xget_bit2
                BEQ.S   xL0004
                BRA.S   xL0007
xL0004:         MOVEQ   #7,D6
                BSR.S   xget_bit2
                BEQ.S   xL0006
                ADDI.W  #$0F,D5
                BRA.S   xL0007
xL0005:         MOVE.B  -(A6),D7
                ADDX.B  D7,D7
                BRA.S   xL0002
xL0006:         MOVEQ   #$0D,D6
                BSR.S   xget_bit2
                ADDI.W  #$010E,D5
xL0007:         ADD.W   D3,D5
xL0008:         LEA     xdecrun_table(PC),A4
                MOVE.W  D5,D2
                BNE.S   xbigger
                ADD.B   D7,D7
                BNE.S   xL0009
                MOVE.B  -(A6),D7
                ADDX.B  D7,D7
xL0009:         BCS.S   xL000A
                MOVEQ   #1,D6
                BRA.S   xword
xL000A:         MOVEQ   #3,D6
                BSR.S   xget_bit2
                TST.B   -$1C(A2)
                BEQ.S   xL000B
                MOVE.B  -$12(A2,D5.w),-(A5)
                BRA     xtst_end
xL000B:         MOVE.B  (A5),D0
                BTST    #3,D5
                BNE.S   xL000C
                BRA.S   xL000D
xL000C:         ADDI.B  #$F0,D5
xL000D:         SUB.B   D5,D0
                MOVE.B  D0,-(A5)
                BRA     xtst_end
xget_bit2:      CLR.W   D5
xL000F:         ADD.B   D7,D7
                BEQ.S   xL0011
xL0010:         ADDX.W  D5,D5
                DBRA    D6,xL000F
                TST.W   D5
                RTS
xL0011:         MOVE.B  -(A6),D7
                ADDX.B  D7,D7
                BRA.S   xL0010
xbigger:        MOVEQ   #2,D6
xword:          BSR.S   xget_bit2
                MOVE.W  D5,D4
                MOVE.B  $0E(A4,D4.w),D6
                EXT.W   D6
                TST.B   -$1B(A2)
                BNE.S   xL0014
                ADDQ.W  #4,D6
                BRA.S   xL0018
xL0014:         BSR.S   xget_bit2
                MOVE.W  D5,D1
                LSL.W   #4,D1
                MOVEQ   #2,D6
                BSR.S   xget_bit2
                CMP.B   #7,D5
                BLT.S   xL0016
                MOVEQ   #0,D6
                BSR.S   xget_bit2
                BEQ.S   xL0015
                MOVEQ   #2,D6
                BSR.S   xget_bit2
                ADD.W   D5,D5
                OR.W    D1,D5
                BRA.S   xL0019
xL0015:         OR.B    -$1A(A2),D1
                BRA.S   xL0017
xL0016:         OR.B    -$19(A2,D5.w),D1
xL0017:         MOVE.W  D1,D5
                BRA.S   xL0019
xL0018:         BSR.S   xget_bit2
xL0019:         ADD.W   D4,D4
                BEQ.S   xL001A
                ADD.W   -2(A4,D4.w),D5
xL001A:         LEA     1(A5,D5.w),A4
                MOVE.B  -(A4),-(A5)
xL001B:         MOVE.B  -(A4),-(A5)
                DBRA    D2,xL001B
                BRA.S   xtst_end
xmake_jnk:      ADD.B   D7,D7
                BNE.S   xL001D
                MOVE.B  -(A6),D7
                ADDX.B  D7,D7
xL001D:         BCS.S   xstring
                MOVE.B  -(A6),-(A5)
xtst_end:       CMPA.L  A5,A3
                BNE.S   xmake_jnk
                CMPA.L  A6,A0
                BEQ.S   xwork_done
xtake_type:     MOVEQ   #0,D6
                BSR     xget_bit2
                BEQ.S   xL0022
                MOVE.B  -(A6),D0
                LEA     -$1A(A2),A1
                MOVE.B  D0,(A1)+
                MOVEQ   #1,D1
                MOVEQ   #6,D2
xL0020:         CMP.B   D0,D1
                BNE.S   xL0021
                ADDQ.W  #2,D1
xL0021:         MOVE.B  D1,(A1)+
                ADDQ.W  #2,D1
                DBRA    D2,xL0020
                ST      -$1B(A2)
                BRA.S   xL0023
xL0022:         SF      -$1B(A2)
xL0023:         MOVEQ   #0,D6
                BSR     xget_bit2
                BEQ.S   xL0025
                LEA     -$12(A2),A1
                MOVEQ   #$0F,D0
xL0024:         MOVE.B  -(A6),(A1)+
                DBRA    D0,xL0024
                ST      -$1C(A2)
                BRA.S   xL0026
xL0025:         SF      -$1C(A2)
xL0026:         CLR.W   D3
                MOVE.B  -(A6),D3
                MOVE.B  -(A6),D0
                LSL.W   #8,D0
                MOVE.B  -(A6),D0
                MOVEA.L A5,A3
                SUBA.W  D0,A3
                BRA.S   xmake_jnk
xstring:        BRA     xdecrunch
xwork_done:     UNLK    A2
xnot_packed:    MOVEM.L (SP)+,D0-A6
                RTS
xdecrun_table:  DC.B $00,$20,$00,$60,$01,$60,$03,$60
                DC.B $07,$60,$0F,$60,$1F,$60,$00,$01
                DC.B $03,$04,$05,$06,$07,$08
                ENDPART
                >PART 'Analyzer'
ANALYZER:       MOVEA.L $044E.w,A0
                LEA     160*180(A0),A0
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

*                ADD.L   D0,D0
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

*               ADD.L   D0,D0
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
CHIP_REG:
                DC.B 10,5,4,2
                DC.B 9,3,2,6
                DC.B 8,1
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
                EVEN
                ENDPART
                PATH 'D:\TESTSOUN.TRI\'
                EVEN
what:           DC.W 0
d46:            DC.W 0
                EVEN

PAL:            DC.W $0777,$0700,$0770,$0777,$77,$07,$0707,$70
                DC.W $0500,$0550,$0555,$55,$05,$0505,$50

                EVEN
info_txt:                               *   IBYTES 'TITLE.PIC'
end_info:
                EVEN
actual_a0:      DC.L datas
sid_:           DC.L sid_dat
count:          DC.W (end_sid-sid_dat)/4+1
                EVEN
sid_dat:        IBYTES 'NIGHTWAL.DAT' ;KYWAY.DAT' ;SID_.DAT'
                EVEN
end_sid:
datas:          IBYTES 'NIGHTWAL.SNG' ;SKYWAY.SNG' ;ELECTRA.SNG'
                EVEN
end_datas:
                BSS
                DS.L 150000/4
                EVEN
                END
