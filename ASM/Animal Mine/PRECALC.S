******************************************************
* Spezial Code um Musik vorzuberechnen !!!
************* Replay kostet dann max. 2 Scans
******************************************************

                PEA     0.w
                MOVE.W  #32,-(sp)
                TRAP    #1
                ADDQ.L  #6,sp

                CLR.L   $FFFFFA06.w
                CLR.L   $FFFFFA12.w

                LEA     song1,a0
                LEA     voice,a1
                MOVEQ   #1,d0           ; 0-keine SID Voice
*                                         1-SID Channle B      --> Timer A
*                                         2-SID Channle B+A    --> Timer A+B
*                                         3-SID Channle B+A+C  --> Timer A+B+D
                BSR     player          ; +0 -> Init / +8 -> VBL / +4 -> Reset

                PEA     txt
                MOVE.W  #9,-(sp)
                TRAP    #1
                ADDQ.L  #6,sp

                MOVE.L  #vbl,$70.w

w:              CMPI.B  #$39,$FFFFFC02.w
                BNE.S   w

                BSR     player+4

                LEA     fat_buff,a0
                MOVEA.L a0,a1
                ADDA.L  gesamt,a1

                LEA     sid_buff,a2
                MOVEA.L sid_vols,a3

                PEA     0
                TRAP    #1


vbl:            MOVEM.L d0-a6,-(sp)
sync:           MOVE.B  $FFFF8209.w,d0
                BEQ.S   sync
                NOT.B   d0
                LSR.W   d0,d0
                DS.W 72,$4E71
                LEA     player,a0
                MOVE.W  #$03,$FFFF8240.w
                BSR     player+8
                CLR.W   $FFFF8240.w
                MOVEM.L (sp)+,d0-a6
                RTE
                EVEN
txt:            DC.B "E",0
                EVEN
                PATH 'D:\SIDSOUND.V25\'
player:         BRA     init_sound_sys
                BRA     re_init
                BRA.S   do_play
                EVEN
                DC.B "SIDSOUND DESIGNER v3.1  "
                DC.B "(c) '93 by ENIM LAMINA/THE INDEPENDENT"
                EVEN

                PART 'Offsets'
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
do_play:        PART            ; VBL Player
                MOVEQ   #0,d4           ; d4 wird als CLR-Ersatz gebraucht !!

                MOVEA.L actual_a5,a5
                MOVEA.L sid_vols,a3

                MOVEA.W #$8800,a4
                SUBQ.W  #1,note_count   ;
                BNE.S   do_fx_all
x07:            MOVE.W  x07,note_count
                MOVEA.L pat_base(pc),a1
                MOVE.W  pat_lin(pc),d0
                MOVE.W  d0,d1
                ADD.W   d0,d0
                ADD.W   d0,d0
                ADD.W   d0,d0
                ADD.W   d1,d1
                ADD.W   d1,d1
                ADD.W   d1,d0
                ADDA.W  d0,a1
                MOVE.L  a1,pat_ptr

                TST.B   break_cmd
                BPL.S   okay_no_break
                MOVEQ   #$41,d0         ; Break-Command (Pattern break)
                SF      break_cmd       ;
                BRA.S   check_dis

okay_no_break:  ADDQ.W  #1,pat_lin
check_dis:      CMPI.W  #$40,pat_lin
                BNE.S   no_re_pat
                BSR     load_pos
no_re_pat:      LEA     adata(pc),a0
                BSR     getnote
                LEA     bdata(pc),a0
                BSR     getnote
                LEA     cdata(pc),a0
                BSR     getnote

do_fx_all:      LEA     bdata(pc),a0
                BSR     do_fx
                BSR     do_tone_control
                BSR     do_wave_control
                LEA     cdata(pc),a0
                BSR     do_fx
                BSR     do_tone_control
                BSR     do_wave_control
                LEA     adata(pc),a0
                BSR     do_fx
                BSR     do_tone_control
                BSR     do_wave_control

                MOVE    #$2700,sr
                ENDPART
**********************************************************
                PART 'SID Channle A'
                CMPI.W  #-1,sid_a1
                BEQ     go_ahead1

                LEA     adata,a0

                TST.B   hardw_buzz(a0)
                BNE.S   no_wow_a

                TST.W   sid_a
                BPL.S   no_wow_a

                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   no_wow_a
                CMPI.B  #3,tfmx_effect(a0)
                BLT.S   no_wow_a

                LEA     wave_form1,a6
                MOVE.W  0(a0),d1

scan_more_a:    TST.W   (a6)
                BMI.S   no_wow_a
                CMP.W   (a6)+,d1
                BLT.S   do_tfm_a
                ADDQ.L  #4,a6
                BRA.S   scan_more_a

do_tfm_a:       MOVE.W  (a6)+,d2
                MOVE.W  (a6)+,d3
                MOVE.L  #$01900000,d0
                MULU    #$A3,d2
                DIVU    d2,d0
                MULU    d1,d0

                TST.W   dual_a
                BNE.S   nix_dual_a
                ADDI.L  #$2000,d0
nix_dual_a:     ADDI.L  #$2000,d0
                ADD.L   d0,d0
                ADD.L   d0,d0
                SWAP    d0

                MOVE.B  volume_(a0),d7
                MOVE.B  d7,new_timer2_a+4
                MOVE.B  d7,fast_new_2_a+4

                MOVE.B  d0,$FFFFFA21.w
                MOVE.B  d3,$FFFFFA1B.w
                BSET    #0,$FFFFFA07.w

                BRA.S   wow_a
no_wow_a:       BCLR    #0,$FFFFFA07.w

                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   wow_a
                CMPI.B  #3,tfmx_effect(a0)
                BLT.S   wow_a

                BCLR    #0,instr_type(a0)
wow_a:
                ENDPART
**********************************************************
                PART 'SID Channle B'
go_ahead1:      CMPI.W  #-1,sid_b1
                BEQ     go_ahead2


                LEA     bdata,a0
                TST.B   hardw_buzz(a0)
                BNE     no_wow

                TST.W   sid_b
                BPL     no_wow

                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   no_wow
                CMPI.B  #3,tfmx_effect(a0)
                BLT.S   no_wow

what_wave:      LEA     wave_form1,a6
                MOVE.W  0(a0),d1

scan_more:      TST.W   (a6)
                BMI.S   no_wow
                CMP.W   (a6)+,d1
                BLT.S   do_tfm
                ADDQ.L  #4,a6
                BRA.S   scan_more

do_tfm:         MOVE.W  (a6)+,d2
                MOVE.W  (a6)+,d3
                MOVE.L  #$01900000,d0
                MULU    #$A3,d2
                DIVU    d2,d0
                MULU    d1,d0

                TST.W   dual_b
                BNE.S   nix_dual_b
                ADDI.L  #$2000,d0
nix_dual_b:     ADDI.L  #$2000,d0
                LSL.L   #2,d0
                SWAP    d0

                MOVE.B  volume_(a0),d7

                MOVE.B  d7,merk_d7
                MOVE.B  d0,merk_d0x
                MOVE.B  d3,merk_d3

                MOVE.B  d7,new_timer2+4
*                MOVE.B  d7,fast_new2+4

                MOVE.B  d0,$FFFFFA1F.w
                MOVE.B  d3,$FFFFFA19.w


                BSET    #5,$FFFFFA07.w
                BRA.S   wow
no_wow:         BCLR    #5,$FFFFFA07.w
                MOVE.B  #-1,merk_d7
                MOVE.B  #-1,merk_d0x
                MOVE.B  #-1,merk_d3

                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   wow
                CMPI.B  #3,tfmx_effect(a0)
                BLT.S   wow
                BCLR    #0,instr_type(a0)


wow:            ENDPART
**********************************************************
                PART 'SID Channle C'
go_ahead2:      CMPI.W  #-1,sid_c1
                BEQ     go_ahead3
                LEA     cdata,a0

                TST.B   hardw_buzz(a0)
                BNE.S   no_wow_c

                TST.W   sid_c
                BPL.S   no_wow_c

                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   no_wow_c
                CMPI.B  #3,tfmx_effect(a0)
                BLT.S   no_wow_c

                LEA     wave_form1(pc),a6
                MOVE.W  0(a0),d1

scan_more_c:    TST.W   (a6)
                BMI.S   no_wow_c
                CMP.W   (a6)+,d1
                BLT.S   do_tfm_c
                ADDQ.L  #4,a6
                BRA.S   scan_more_c

do_tfm_c:       MOVE.W  (a6)+,d2
                MOVE.W  (a6)+,d3
                MOVE.L  #$01900000,d0
                MULU    #$A3,d2
                DIVU    d2,d0
                MULU    d1,d0

                TST.W   dual_c
                BNE.S   nix_dual_c
                ADDI.L  #$2000,d0
nix_dual_c:     ADDI.L  #$2000,d0
                LSL.L   #2,d0
                SWAP    d0

                MOVE.B  volume_(a0),d7
                MOVE.B  d7,new_timer2_c+4
                MOVE.B  d7,fast_new_2_c+4

                ANDI.B  #$F0,$FFFFFA1D.w
                OR.B    d3,$FFFFFA1D.w
                MOVE.B  d0,$FFFFFA25.w
                BSET    #4,$FFFFFA09.w

                BRA.S   wow_c
no_wow_c:       BCLR    #4,$FFFFFA09.w  ; #0,$fa07.w

                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   wow_c
                CMPI.B  #3,tfmx_effect(a0)
                BLT.S   wow_c
                BCLR    #0,instr_type(a0)
wow_c:
                ENDPART
**********************************************************
                PART 'Rest of VBL Replay'
go_ahead3:      MOVE    #$2300,sr
***************************************************************
                MOVE.B  #$FF,d0

                LEA     cdata,a0
                MOVEQ   #2,d6
                MOVEQ   #5,d7
                BSR     rest_control
                LEA     bdata,a0
                MOVEQ   #1,d6
                MOVEQ   #4,d7
                BSR     rest_control
                LEA     adata,a0
                BTST    #1,hardw_buzz(a0)
                BNE.S   no_nois_a
                MOVEQ   #0,d6
                MOVEQ   #3,d7
                BSR     rest_control

no_nois_a:      MOVE.W  #$0700,d7
                MOVE.B  d0,d7


                MOVE.W  d7,(a5)+
                MOVEP.W d7,0(a4)
                ADDQ.L  #1,zaehl

                LEA     adata,a0
                BTST    #1,hardw_buzz(a0)
                BNE     do_nout_a
                MOVE.W  0(a0),d0
                MOVE.B  0(a0),d1
                MOVEQ   #0,d7
                MOVE.B  d0,d7

                MOVE.W  d7,(a5)+
                MOVEP.W d7,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  #$0100,d7
                MOVE.B  d1,d7

                ADDQ.L  #1,zaehl
                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+

                TST.B   hardw_buzz(a0)
                BNE.S   no_hardw_auto_a
                TST.B   extend_buzz(a0)
                BEQ.S   no_hardw_auto_a
                BTST    #2,instr_type(a0)
                BEQ.S   no_hardw_auto_a
                BTST    #3,instr_type(a0)
                BEQ.S   no_hardw_auto_a
                LSR.W   #4,d0
                MOVE.W  #$0B00,d7
                MOVE.B  d0,d7

                MOVE.W  d7,(a5)+
                MOVEP.W d7,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  #$0C00,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

no_hardw_auto_a:CMPI.W  #-1,sid_a1
                BEQ.S   okay_a

                CMPI.B  #3,tfmx_effect(a0)
                BLT.S   okay_a
                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   okay_a
                BRA.S   do_nout_a

okay_a:         MOVE.W  #$0800,d7
                MOVE.B  volume_(a0),d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

do_nout_a:      LEA     bdata,a0
                MOVE.W  0(a0),d0
                MOVE.B  0(a0),d1
                MOVE.W  #$0200,d7
                MOVE.B  d0,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

                MOVE.W  #$0300,d7
                MOVE.B  d1,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

                TST.B   hardw_buzz(a0)
                BNE.S   no_hardw_auto_b
                TST.B   extend_buzz(a0)
                BEQ.S   no_hardw_auto_b
                BTST    #2,instr_type(a0)
                BEQ.S   no_hardw_auto_b
                BTST    #3,instr_type(a0)
                BEQ.S   no_hardw_auto_b
                LSR.W   #4,d0
                MOVE.W  #$0B00,d7
                MOVE.B  d0,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

                MOVE.W  #$0C00,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

no_hardw_auto_b:CMPI.W  #-1,sid_b1
                BEQ.S   okay_b
                CMPI.B  #3,tfmx_effect(a0)
                BLT.S   okay_b
                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   okay_b
                BRA.S   no_b

okay_b:         MOVE.W  #$0900,d7
                MOVE.B  volume_(a0),d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

no_b:           LEA     cdata,a0
                MOVE.W  0(a0),d0
                MOVE.B  0(a0),d1
                MOVE.W  #$0400,d7
                MOVE.B  d0,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

                MOVE.W  #$0500,d7
                MOVE.B  d1,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

                TST.B   hardw_buzz(a0)
                BNE.S   no_hardw_auto_c
                TST.B   extend_buzz(a0)
                BEQ.S   no_hardw_auto_c
                BTST    #2,instr_type(a0)
                BEQ.S   no_hardw_auto_c
                BTST    #3,instr_type(a0)
                BEQ.S   no_hardw_auto_c
                LSR.W   #4,d0
                MOVE.W  #$0B00,d7
                MOVE.B  d0,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

                MOVE.W  #$0C00,d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

no_hardw_auto_c:CMPI.W  #-1,sid_c1
                BEQ.S   okay_c
xc_1:           CMPI.B  #3,tfmx_effect(a0)
                BLT.S   okay_c
                CMPI.B  #5,tfmx_effect(a0)
                BGT.S   okay_c
                BRA.S   no_c

okay_c:         MOVE.W  #$0A00,d7
                MOVE.B  volume_(a0),d7

                MOVEP.W d7,0(a4)
                MOVE.W  d7,(a5)+
                ADDQ.L  #1,zaehl

no_c:
**************************************
                MOVE.L  a5,actual_a5

                MOVE.L  zaehl,d7
                MOVE.L  d7,d6
                ADD.L   d6,d6
                ADD.L   d6,gesamt
                SUBQ.L  #1,d7           ; wegen DBRA Struktur

                MOVEA.L sid_vols,a3
                MOVE.B  d7,(a3)+        ; Anzahl
                MOVE.B  merk_d7,(a3)+   ; Volume
                MOVE.B  merk_d0x,(a3)+  ; Timer Data
                MOVE.B  merk_d3,(a3)+   ; Timer Control
                MOVE.L  a3,sid_vols
                ADDQ.W  #4,offset
                CLR.L   zaehl

                CMPI.L  #260000,gesamt
                BLT.S   ok
                LEA     fat_buff,a0
                MOVEA.L a0,a1
                ADDA.L  #260000,a1
                ILLEGAL
ok:             RTS

getnote:        TST.B   (a1)
                BEQ     test_env
                BMI     digi_
                MOVE.B  2(a1),d1
                CMPI.B  #$3F,d1
                BHI     same_instr
                MOVE.B  d1,$39(a0)      ; Instrument Nr. in $39

                MOVE.W  d4,$4C(a0)
                MOVE.B  d4,$38(a0)

                LEA     spec_table,a6

                MOVEQ   #0,d0

                MOVE.B  $39(a0),d0      ;
                ADD.W   d0,d0
                ADD.W   d0,d0
                MOVE.L  0(a6,d0.w),d0   ;
                MOVE.L  d0,$3C(a0)      ; Aktuelles Instrument
                LSR.L   #8,d0           ; *256 ( Instrument Adresse !!! )
                TST.B   d0              ; negativ ??
                BEQ.S   no_wave_control ; Dann keine Waveform
                LEA     wave_table(pc),a6

                MOVEQ   #0,d1

                MOVE.B  d0,d1
                SUBQ.B  #1,d1
                ADD.W   d1,d1
                ADD.W   d1,d1
                MOVE.L  0(a6,d1.w),extend_wave_adr(a0) ; Adresse der Wave
no_wave_control:LSR.L   #8,d0
                TST.B   d0
                BEQ.S   no_tone_control
                LEA     tone_table(pc),a6

                MOVEQ   #0,d1

                MOVE.B  d0,d1
                SUBQ.B  #1,d1
                ADD.W   d1,d1
                ADD.W   d1,d1
                MOVE.L  0(a6,d1.w),extend_tone_adr(a0) ; Toneadresse
no_tone_control:LSR.W   #8,d0
                TST.B   d0
                BEQ.S   no_noise_control
                LEA     nois_table(pc),a6

                MOVEQ   #0,d1

                MOVE.B  d0,d1
                SUBQ.W  #1,d1
                ADD.W   d1,d1
                ADD.W   d1,d1
                MOVE.L  0(a6,d1.w),extend_noiz_adr(a0)
no_noise_control:MOVE.B $39(a0),d1
                ANDI.W  #$3F,d1

x01:            LEA     x01,a2
                ASL.W   #8,d1
                ADDA.W  d1,a2
                MOVE.W  0(a2),d0
                MOVE.W  d0,$2A(a0)
                MOVE.B  2(a2),instr_type(a0)
                MOVE.W  4(a2),$2E(a0)
                MOVE.B  3(a2),$2D(a0)
                MOVE.L  6(a2),$0A(a0)
                MOVE.L  $FC(a2),$30(a0)
                MOVE.W  d4,$14(a0)
                MOVE.L  $0A(a2),$16(a0)
                MOVE.W  $0E(a2),$1A(a0)

                MOVE.L  a3,merk_a3
                LEA     $10(a2),a3
                MOVE.L  a3,$10(a0)
                MOVE.W  d4,$20(a0)
                MOVE.L  $F0(a2),$22(a0)
                MOVE.W  $F4(a2),$26(a0)
                LEA     $80(a2),a3
                MOVEQ   #0,d0
                MOVE.B  (a1),d0
                MOVE.W  d0,d1
                LSR.W   #4,d1
                LEA     note_2_freq(pc),a2
                ANDI.W  #$0F,d0
                MOVE.L  a3,$1C(a0)
                MOVEA.L merk_a3,a3

                ST      $28(a0)
                ANDI.W  #$0F,d0
                MOVE.W  d0,d2
                ADD.W   d2,d2
                MOVE.W  0(a2,d2.w),d2
                LSR.W   d1,d2
                MOVE.W  d2,2(a0)
                MOVE.W  d0,d3
                ADD.W   $30(a0),d3
                ADD.W   d3,d3
                MOVE.W  0(a2,d3.w),d3
                LSR.W   d1,d3
                SUB.W   d2,d3
                MOVE.W  d3,$34(a0)
                ADD.W   $32(a0),d0
                ADD.W   d0,d0
                MOVE.W  0(a2,d0.w),d0
                LSR.W   d1,d0
                SUB.W   d2,d0
                MOVE.W  d0,$36(a0)
same_instr:     MOVE.B  1(a1),d1
                BEQ.S   no_calc_tie
                SUB.W   4(a0),d2
                EXT.L   d2
                ANDI.L  #$FF,d1
x08:            MULS    x08,d1          ; Speed
                DIVS    d1,d2
                BEQ.S   no_calc_tie
                MOVE.W  d2,6(a0)
                BRA.S   yes_calc_tie
no_calc_tie:    MOVE.W  2(a0),4(a0)
                MOVE.W  d4,6(a0)
yes_calc_tie:   MOVE.B  3(a1),d0
                ANDI.W  #$1F,d0
                MOVE.B  d0,$0F(a0)
test_env:       ADDQ.L  #3,a1
                MOVE.B  (a1)+,d1
                LSR.B   #6,d1
                TST.B   d1
                BEQ.S   same_env
                BTST    #2,instr_type(a0)
                BNE.S   he_adsr
                CMPI.B  #1,d1
                BEQ.S   attack_env
                CMPI.B  #2,d1
                BEQ.S   sustain_env
                MOVE.W  $18(a0),$14(a0)
                MOVE.W  $24(a0),$20(a0)
                BCLR    #0,hardw_buzz(a0)
                ST      $28(a0)
                RTS
sustain_env:    MOVE.W  $16(a0),$14(a0)
                MOVE.W  $22(a0),$20(a0)
                BCLR    #0,hardw_buzz(a0)
                ST      $28(a0)
                RTS

attack_env:     MOVE.W  d4,$08(a0)
                MOVE.W  d4,$14(a0)
                MOVE.W  d4,$20(a0)
                BCLR    #0,hardw_buzz(a0)
                ST      $28(a0)
                BCLR    #1,hardw_buzz(a0)
same_env:       RTS

he_adsr:        MOVE.W  #$0B00,d7
                MOVE.W  #$0C00,d6
                MOVE.W  #$0D00,d5
                TST.B   d1
                BEQ     cont_he
                CMPI.B  #2,d1
                BEQ     sustain_he
                CMPI.B  #3,d1
                BEQ     release_he
                MOVE    #$2700,sr
                BTST    #3,instr_type(a0)
                BNE.S   attack_hardw_aut

                MOVE.B  $2F(a0),d7
                MOVEP.W d7,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  d7,(a5)+

*                MOVE.B  D7,(A5)
*                MOVE.B  $2F(A0),2(A5)

                MOVE.B  $2E(a0),d6
                MOVEP.W d6,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  d6,(a5)+

*                MOVE.B  D6,(A5)
*                MOVE.B  $2E(A0),2(A5)
attack_hardw_aut:
*                MOVE.B  D5,(A5)
                BTST    #0,$2D(a0)
                BNE.S   yes_hardw_type
                MOVE.B  (a5),d0
                CMP.B   $2D(a0),d0
                BEQ.S   no_hardw_type
yes_hardw_type:
                MOVE.B  $2D(a0),d5
                MOVEP.W d5,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  d5,(a5)+

*                MOVE.B  $2D(A0),2(A5)
no_hardw_type:  MOVE.W  d4,8(a0)
                MOVE.W  d4,$20(a0)
                ST      $28(a0)
                BCLR    #0,hardw_buzz(a0)
                BCLR    #1,hardw_buzz(a0)
                BEQ.S   same_he
                BCLR    #5,$FFFFFA07.w
                BCLR    #0,$FFFFFA07.w
same_he:        MOVE    #$2300,sr
cont_he:        RTS
sustain_he:     MOVE    #$2700,sr
                BTST    #3,instr_type(a0)
                BNE.S   sustain_hardw_au

                MOVE.W  #$0B00,d7
                MOVE.B  $2F(a0),d7
                MOVEP.W d7,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  d7,(a5)+

*               MOVE.B  D7,(A5)
*               MOVE.B  $2F(A0),2(A5)

                MOVE.W  #$0C00,d6
                MOVE.B  $2E(a0),d6
                MOVEP.W d6,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  d6,(a5)+

*                MOVE.B  D6,(A5)
*                MOVE.B  $2E(A0),2(A5)
sustain_hardw_au:
                MOVE.W  #$0D00,d5
                MOVE.B  #$0D,(a5)
                BTST    #0,$2D(a0)
                BNE.S   yes_sus_htype
                MOVE.B  (a5),d0
                CMP.B   $2D(a0),d0
                BEQ.S   no_sus_htype
yes_sus_htype:
                MOVE.B  $2D(a0),d5
                MOVEP.W d5,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  d5,(a5)+

*                MOVE.B  $2D(A0),2(A5)

no_sus_htype:   MOVE.W  d4,8(a0)
                MOVE.W  $22(a0),$20(a0)
                ST      $28(a0)
                BCLR    #0,hardw_buzz(a0)
                BCLR    #1,hardw_buzz(a0)
                BEQ.S   same_sus_he
                BCLR    #5,$FFFFFA07.w
                BCLR    #0,$FFFFFA07.w
same_sus_he:    MOVE    #$2300,sr
                RTS
release_he:     BSET    #0,hardw_buzz(a0)
                RTS

*****************************************************************************
digi_:          BTST    #2,hardw_buzz(a0)
                BNE     L0052

                CMPI.B  #$0E,2(a1)
                BNE.S   test_2
                MOVE.W  #-1,break_cmd
                BRA.S   oka

test_2:         CMPI.B  #$0F,2(a1)      ; Bei Sample Nr.$f
                BNE.S   oka             ; Infobyte als SPEED BYTE anerkennen
                MOVE.W  #-1,what

oka:            MOVE.B  2(a1),d0        ; Sam.Nr (0-f)
                ANDI.W  #$0F,d0
                ASL.W   #2,d0
                TST.W   what
                BMI.S   only_speed
                MOVEQ   #0,d0
                MOVE.B  3(a1),d0        ;Info Byte holen
                EXT.W   d0
                ADD.W   d0,d0
                ADD.W   d0,d0
                MOVEA.L rout_tab(pc,d0.w),a6 ; und verzweigen
                JSR     (a6)
L0052:          ADDQ.L  #4,a1
                RTS

only_speed:     MOVE.B  3(a1),d0        ; Bei Sample Nummer $f ist das
                EXT.W   d0
                MOVE.W  d0,x08+2
                ADDQ.L  #4,a1
                MOVE.W  d4,what
                RTS
                EVEN

rout_tab:       DC.L ertes      ;           0
                DC.L sid_dual_on_a ; 1
                DC.L sid_dual_on_b ; 2
                DC.L sid_dual_on_c_ ; 3
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
                ENDPART
**********************************************************
                >PART 'SID Timer (b) - CH A'
new_timer_a:    MOVE.L  #$08080000,$FFFF8800.w
                ADDI.W  #new_timer2_a-new_timer_a,$0122.w ;122.w ;12.w
                RTE

new_timer2_a:   MOVE.L  #$08080000,$FFFF8800.w
                SUBI.W  #new_timer2_a-new_timer_a,$0122.w ;22.w ;12.w
                RTE
************************
* Schnellere Version !!!
* Optional mit -1 in d1.w
************************
fast_new_a:     MOVE    #$2400,sr
                MOVE.L  #$08080000,(a5)
                ADDI.W  #fast_new_2_a-fast_new_a,$0122.w ;122.w ;12.w
                RTE

fast_new_2_a:   MOVE    #$2400,sr
                MOVE.L  #$08080000,(a5)
x0201_af        SET *-2
                SUBI.W  #fast_new_2_a-fast_new_a,$0122.w ;22.w ;12.w
                RTE
                ENDPART
**********************************************************
                >PART 'SID Timer (a) - CH B'
new_timer:      MOVE.L  #$09090000,$FFFF8800.w
                ADDI.W  #new_timer2-new_timer,$0136.w
                RTE

new_timer2:     MOVE.L  #$09090000,$FFFF8800.w
                SUBI.W  #new_timer2-new_timer,$0136.w
                RTE

fast_new:       MOVE.L  #$08080000,(a5)
                ADDI.W  #fast_new2-fast_new,$0136.w
                RTE

fast_new2:      MOVE.L  #$08080000,(a5)
x0201f          SET *-2
                SUBI.W  #fast_new2-fast_new,$0136.w
                RTE
                ENDPART
**********************************************************
                >PART 'SID Timer (d) - CH C'
new_timer_c:    MOVE.L  #$0A0A0000,$FFFF8800.w
                ADDI.W  #new_timer2_c-new_timer_c,$0112.w
                RTE

new_timer2_c:   MOVE.L  #$0A0A0000,$FFFF8800.w
                SUBI.W  #new_timer2_c-new_timer_c,$0112.w
                RTE

fast_new_c:     MOVE    #$2700,sr
                MOVE.L  #$08080000,(a5)
                ADDI.W  #fast_new_2_c-fast_new_c,$0112.w
                RTE

fast_new_2_c:   MOVE    #$2700,sr
                MOVE.L  #$08080000,(a5)
x0201_cf        SET *-2
                SUBI.W  #fast_new_2_c-fast_new_c,$0122.w
                RTE
                ENDPART
**********************************************************
                >PART 'Nothing-done Timer'
no_timer:       RTE
                ENDPART
**********************************************************
                >PART 'Extended Soundsys Subrouts'

do_tone_control:MOVE.L  #$01010100,d6
                TST.B   extend_tone(a0)
                BEQ.S   no_tone_fix
                MOVEA.L extend_tone_adr(a0),a6
                MOVEQ   #0,d1
                MOVE.B  (a6)+,d1
                CMP.B   #$FF,d1
                BNE.S   tone_a
                MOVEQ   #0,d1
                CMP.B   #$FE,d1
                BNE.S   tone_a
                SUBQ.L  #1,a6
                MOVE.B  -1(a6),d1
tone_a:         MOVE.L  a6,extend_tone_adr(a0)
                ADD.W   d1,d1
                ADD.W   d1,d1
                MOVE.L  tone_data(pc,d1.w),d7
                MOVE.L  d7,extend_tone_flag(a0)
                RTS
no_tone_fix:    MOVE.L  d6,extend_tone_flag(a0)
                RTS
                EVEN

tone_data:      DC.B 0,0,0,0    ; Background Drum or Snare Effect
                DC.B 1,0,0,0
                DC.B 0,1,0,0
                DC.B 1,1,0,0
                DC.B 0,0,1,0
                DC.B 1,0,1,0
                DC.B 1,1,1,0
                EVEN

do_wave_control:TST.B   extend_wave(a0)
                BEQ.S   no_control_wave_
                MOVEA.L extend_wave_adr(a0),a6
                MOVE.B  (a6)+,d1
                CMPI.B  #$FF,d1
                BEQ.S   xno_hardw_auto_b
                CMPI.B  #$FE,d1
                BNE.S   wave_b
                SUBQ.B  #1,d1
                MOVE.B  -1(a6),d1
wave_b:         MOVE.L  a6,extend_wave_adr(a0)
                TST.B   d1
                BNE.S   no_control_wave_
xno_hardw_auto_b:BCLR   #2,instr_type(a0)
no_control_wave_:RTS

rest_control:   BTST    #0,instr_type(a0)
                BEQ.S   no_tone_c
                TST.B   extend_tone(a0)
                BNE.S   no_tone_cx
                TST.B   extend_noiz(a0)
                BEQ.S   no_tone_c
no_tone_cx:     BCLR    d6,d0
no_tone_c:      BTST    #1,instr_type(a0)
                BEQ.S   no_nois_c
                TST.B   $3C(a0)
                BNE.S   control_noise_c

                MOVE.W  #$0600,d5
                MOVE.B  $2B(a0),d5

                MOVEP.W d5,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  d5,(a5)+

                BRA.S   no_nois_cx

control_noise_c:MOVEA.L extend_noiz_adr(a0),a6
                MOVE.B  (a6)+,d1
                CMPI.B  #$FF,d1
                BEQ.S   no_nois_c
                CMPI.B  #$FE,d1
                BNE.S   nois_c
                SUBQ.L  #1,a6
                MOVE.B  -1(a6),d1
nois_c:         MOVE.L  a6,extend_noiz_adr(a0)
                MOVE.W  #$0600,d5
                MOVE.B  d1,d5

                MOVEP.W d5,0(a4)
                ADDQ.L  #1,zaehl

                MOVE.W  d5,(a5)+

                TST.B   extend_tone_flag(a0)
                BEQ.S   no_nois_c
no_nois_cx:     BCLR    d7,d0
no_nois_c:      RTS

do_fx:          TST.B   hardw_buzz(a0)
                BNE     do_silent
                BTST    #2,instr_type(a0)
                BEQ.S   no_he

                CMPI.B  #13,tfmx_effect
                BNE.S   normal_buzz

                MOVEQ   #1,d7           ; 2 mal hintereinander !!!

double:         MOVEA.W #$8800,a6
                MOVEQ   #0,d0
                MOVE.B  0(a0),d0        ;Bassnote holen
                ADD.B   $53(a0),d0      ;transponieren
                LEA     buzzfreqtab(pc),a2
                ANDI.W  #$3F,d0
                MOVE.B  #11,(a6)
                MOVE.B  0(a2,d0.w),2(a6)
                MOVE.B  #12,(a6)
                MOVE.B  #0,2(a6)
                ADDQ.B  #1,$53(a0)
                CMPI.B  #$3F,$53(a0)
                BLE.S   do_loop
                MOVE.B  d4,$53(a0)
do_loop:        BRA.S   to_tie

normal_buzz:    MOVE.B  d4,$53(a0)
                MOVE.B  #$10,volume_(a0) ; create BUZZ Tone
                BRA.S   to_tie
no_he:          MOVE.W  $14(a0),d0
                MOVEA.L $10(a0),a2
                MOVE.B  0(a2,d0.w),d1
                MOVE.B  $0F(a0),d2
                ASL.B   #4,d2
                ADD.B   d1,d2
                ANDI.W  #$FF,d2
                LEA     vols(pc),a2
                MOVE.B  0(a2,d2.w),volume_(a0)
                ADDQ.W  #1,d0
                CMP.W   $18(a0),d0
                BNE.S   no_sus_rep
                MOVE.W  $16(a0),d0
no_sus_rep:     CMP.W   $1A(a0),d0
                BCS.S   no_rel
                BSET    #0,hardw_buzz(a0)
no_rel:         MOVE.W  d0,$14(a0)
to_tie:         MOVE.W  6(a0),d0
                BEQ.S   no_tie
                BMI.S   tie_lo
                ADD.W   4(a0),d0
                CMP.W   2(a0),d0
                BLT.S   no_reach_tie_hi
                MOVE.W  d4,6(a0)
                MOVE.W  2(a0),d0
no_reach_tie_hi:MOVE.W  d0,4(a0)
                BRA.S   no_tie
tie_lo:         ADD.W   4(a0),d0
                CMP.W   2(a0),d0
                BGT.S   no_reach_tie_lo
                MOVE.W  d4,6(a0)
                MOVE.W  2(a0),d0
no_reach_tie_lo:MOVE.W  d0,4(a0)
no_tie:         MOVE.W  8(a0),d1
                ADD.W   $0A(a0),d1
                CMPI.W  #$3B,d1
                BLS.S   no_re_trem
                MOVEQ   #0,d1
no_re_trem:     MOVE.W  d1,8(a0)
                ADD.W   d1,d1
                LEA     trem_tab(pc),a2
                MOVE.W  0(a2,d1.w),d1
                MOVE.W  $0C(a0),d2
                ASR.W   d2,d1
                ADD.W   4(a0),d1

******************************************************
* Hi-End-Pitch-Arpeggio Effect
******************************************************
                CMPI.B  #1,tfmx_effect(a0)
                BNE.S   no_db_1_notex

                LEA     db_table(pc),a1
                MOVE.B  $4C(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4C(a0)
                CMPI.B  #1,$4C(a0)
                BLT.S   no_db_1_notex
                MOVE.B  #1,$4C(a0)

no_db_1_notex:
*************************************************
* SID-Effect combined with Hi-End-Pitch-Arpeggio
*************************************************

                CMPI.B  #4,tfmx_effect(a0)
                BNE.S   no_db_1_notey

                LEA     db_table(pc),a1
                MOVE.B  $4C(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4C(a0)
                CMPI.B  #1,$4C(a0)
                BLT.S   no_db_1_notey
                MOVE.B  #1,$4C(a0)

no_db_1_notey:
*********************************************
* Arpeggio-Double with SID Effect
*********************************************
                CMPI.B  #5,tfmx_effect(a0)
                BNE.S   no_db_1_note

                LEA     da_table(pc),a1
                MOVE.B  $4D(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #2,$4D(a0)
                CMPI.B  #$0C,$4D(a0)
                BLT     da_ok
                MOVE.B  d4,$4D(a0)

*                CLR.B   $4D(A0)

no_db_1_note:
**************************************************
* Different Arpeggio Wavesyntheses (3 pcs.) 6-9
**************************************************
                CMPI.B  #6,tfmx_effect(a0)
                BNE.S   no_db_note2
                LEA     db_1_table(pc),a1
                MOVE.B  $4C(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4C(a0)
                CMPI.B  #64,$4C(a0)
                BLT.S   no_db_note2
                MOVE.B  #1,$4C(a0)

no_db_note2:    CMPI.B  #7,tfmx_effect(a0)
                BNE.S   no_db_note3
                LEA     db_2_table(pc),a1
                MOVE.B  $4D(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #2,$4D(a0)
                CMPI.B  #32,$4D(a0)
                BLT.S   no_db_note3
                MOVE.B  #2,$4D(a0)

no_db_note3:    CMPI.B  #8,tfmx_effect(a0)
                BNE.S   no_db_note4
                LEA     da2_table(pc),a1
                MOVE.B  $4C(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4C(a0)
                CMPI.B  #48,$4C(a0)
                BLT.S   no_db_note4

                MOVE.B  d4,$4C(a0)

no_db_note4:    CMPI.B  #9,tfmx_effect(a0)
                BNE.S   no_db_note5
                LEA     dx_table(pc),a1
                MOVE.B  $4D(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4D(a0)
                CMPI.B  #32,$4D(a0)
                BLT.S   no_db_note5
                MOVE.B  d4,$4D(a0)

no_db_note5:
***************************************************
* Hi-End-Pitch-Arpeggio mixed with double-Arpeggio
***************************************************

                CMPI.B  #10,tfmx_effect(a0)
                BNE.S   no_db_note6
                LEA     dx_table(pc),a1
                MOVE.B  $4D(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4D(a0)
                CMPI.B  #32,$4D(a0)
                BLT.S   spe
                MOVE.B  d4,$4D(a0)

spe:            LEA     da_table(pc),a1
                MOVE.B  $4C(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4C(a0)
                CMPI.B  #4,$4C(a0)
                BLT.S   no_db_note6
                MOVE.B  d4,$4C(a0)

no_db_note6:    CMPI.B  #11,tfmx_effect(a0)
                BNE.S   no_db_note7
                LEA     arp_spec,a1     ;dy_table(PC),A1
                MOVE.B  $4C(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4C(a0)
                CMPI.B  #16,$4C(a0)
                BLT.S   spe2
                MOVE.B  d4,$4C(a0)

spe2:           LEA     db_2_table(pc),a1
                MOVE.B  $4D(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #1,$4D(a0)
                CMPI.B  #18,$4D(a0)
                BLT.S   no_db_note7
                MOVE.B  d4,$4D(a0)

no_db_note7:    CMPI.B  #12,tfmx_effect(a0)
                BNE.S   no_db_note

                TST.B   hardw_buzz(a0)
                BNE     no_db_note
                BTST    #2,instr_type(a0)
                BEQ.S   no_db_note

                LEA     spec_,a1
                MOVE.B  $52(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),d0

                MOVE.B  d0,$38(a0)
                ANDI.W  #$3F,d0
                ADD.W   d0,$20(a0)

                ADDQ.B  #1,$52(a0)
                CMPI.B  #42,$52(a0)
                BLT.S   no_db_note
                MOVE.B  d4,$52(a0)

no_db_note:
********************************************
* New Arpeggio (double) with wavesynthese
********************************************
                CMPI.B  #2,tfmx_effect(a0)
                BNE.S   da_ok
                LEA     da_table(pc),a1
                MOVE.B  $4D(a0),d7
                EXT.W   d7
                MOVE.B  0(a1,d7.w),$38(a0)
                ADDQ.B  #2,$4D(a0)
                CMPI.B  #$0C,$4D(a0)
                BLT.S   da_ok
                MOVE.B  d4,$4D(a0)

da_ok:
*******************************************************************************
                MOVE.B  $38(a0),d0
                BEQ.S   intr_0
                CMPI.B  #1,d0
                BEQ.S   intr_1
                ADD.W   $36(a0),d1
                MOVE.B  d4,$38(a0)

                BRA.S   intr_2
intr_1:         ADD.W   $34(a0),d1
intr_0:         ADDQ.B  #1,$38(a0)
intr_2:         TST.B   $28(a0)
                BEQ.S   no_pitch
                MOVE.W  $20(a0),d0
                MOVEA.L $1C(a0),a2
                MOVE.B  0(a2,d0.w),d2
                EXT.W   d2
                TST.B   $3C(a0)
                BEQ.S   no_noise_pitch2
                ADD.W   d2,d1
                ADD.W   d2,d1
                ADD.W   d2,d1
no_noise_pitch2:ADD.W   d2,d1
                ADDQ.W  #1,d0
                CMP.W   $24(a0),d0
                BNE.S   no_pit_sus_rep
                MOVE.W  $22(a0),d0
no_pit_sus_rep: CMP.W   $26(a0),d0
                BCS.S   no_pit_rel
                MOVE.B  d4,$28(a0)
no_pit_rel:     MOVE.W  d0,$20(a0)
no_pitch:       MOVE.W  d1,0(a0)

                CMPI.B  #13,tfmx_effect(a0)
                BNE.S   no_special_buzz
                DBRA    d7,double
no_special_buzz:MOVEQ   #0,d7
                RTS
do_silent:      MOVE.B  d4,volume_(a0)
                RTS

buzzfreqtab:    DC.B 240,226,212,200,190,178,168,158,150,142,134,126
                DC.B 120,113,106,100,95,89,84,79,75,71,67,63
                DC.B 60,56,53,50,47,45,42,40,38,36,34,32
                DC.B 30,28,27,25,24,22,21,20,19,18,17,16
                DC.B 15,14,13,12,11,10,9,8,7,6,5,4,3,2,1,0

db_table:       DC.B 1,0,$FF
db_1_table:     DC.B 1,0,1,0,2,0,2,0,3,0,$FF
db_2_table:     DC.B 0,0,1,1,2,2,3,3,4,4,5,5,6,6,5,5,4,4,3,3,2,2,1,1,0,0,$FF
da_table:       DC.B 0,0,1,1,2,2,$FF
da2_table:      DC.B 9,9,5,5,3,3,1,1,2,1,1,2,2,3,3,3,4,4,5,0,1,2,$FF
dx_table:       DC.B 0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0,1,1,0,2,0,3,0,4,0,5,0,6,0,$FF
dy_table:       DC.B 1,1,1,0,0,0,2,2,2,0,0,0,3,3,3,0,0,0,4,4,4,0,0,0,5,5,5,$FF
                EVEN
spec_:          DC.B $10,$0F,$10,$0E,$10,$0D,$10,$0C,$10,$0B,$10,$0A,$10,$09
                DC.B $10,$08,$10,$07,$10,$06
                DC.B $10,$05,$10,$04,$10,$03,$10,$02,$10,$01,$10
                DC.B $10,$10,$10,$09,$08,$06,$04,$02,$00,$02,-1
                EVEN
arp_spec:       DC.B 0,9,0,8,0,7,0,6,0,5,0,4,0,3,0,2,0,1,0
                DC.B 1,2,3,4,5,6,7,8,9,-1
                EVEN
                ENDPART
**********************************************************
                >PART 'Command-Subrouts'

sid_dual_on_a:  NOT.W   dual_a          ; 0
                RTS
sid_dual_on_b:  NOT.W   dual_b          ; 0
                RTS
sid_dual_on_c_: NOT.W   dual_c          ; 0
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

do_wave_1:      MOVE.L  #wave_form1,what_wave+2
                RTS
do_wave_2:      MOVE.L  #wave_form2,what_wave+2
                RTS
do_wave_3:      MOVE.L  #wave_form3,what_wave+2
ertes:          RTS


reset_all:      MOVE.L  #wave_form1,what_wave+2
                MOVE.W  merk_speed,speed_
                ST      dual_a
                ST      dual_b
                ST      dual_c
                ST      sid_a           ; Flag, ob SID Channle an/aus ist
                ST      sid_b
                ST      sid_c
                RTS
                ENDPART
**********************************************************
init_sound_sys: >PART
                MOVE    sr,-(sp)
                MOVE.W  d1,merk_d1      ; Fast-Flag
                MOVE.W  d0,merk_d0      ; Wieviele SID Channles
                MOVE.L  a0,song_ptr
                MOVE.L  a1,vct_ptr
                MOVEA.L vct_ptr(pc),a0
                LEA     $0204(a0),a0
                MOVE.L  a0,x01+2
                MOVEA.L song_ptr(pc),a0
                ADDQ.L  #4,a0
                MOVE.W  (a0),merk_speed
                MOVE.L  a0,x07+2
                MOVE.L  a0,x08+2
                ADDQ.L  #2,a0
                MOVE.L  a0,x06+2
                ADDQ.L  #2,a0
                MOVE.L  a0,x05+2
                ADDQ.L  #2,a0
                MOVE.L  a0,play3v+4
                ADDQ.L  #2,a0
                MOVE.L  a0,calc_pos+2
                LEA     $78(a0),a0
                MOVE.L  a0,x02+2
                MOVE.L  a0,x03+2
                MOVE.L  a0,x04+2

                LEA     spec_table,a1
                MOVEA.L vct_ptr,a0
                LEA     16900(a0),a0
                CMPI.L  #"INFO",(a0)+   ; New Instrument Info ??
                BEQ.S   copy_info_tab   ; Ja, dann diese runter kopieren
                LEA     standard,a0     ; Nein, dann in a0.l die Standard Tab
copy_info_tab:  MOVEQ   #31,d0
copy_dwn:       MOVE.L  (a0)+,(a1)+
                MOVE.L  (a0)+,(a1)+
                DBRA    d0,copy_dwn

                BSR     init_music

                MOVE.L  $0110.w,old110
                MOVE.L  $0120.w,old114
                MOVE.L  $0134.w,old134
                MOVE.B  $FFFFFA07.w,olda07
                MOVE.B  $FFFFFA09.w,olda09
                MOVE.B  $FFFFFA13.w,olda13
                MOVE.B  $FFFFFA15.w,olda15
                MOVE.B  $FFFFFA17.w,olda17
                MOVE.B  $FFFFFA19.w,olda19
                MOVE.B  $FFFFFA1D.w,olda1d
                MOVE.B  $FFFFFA25.w,olda25

                MOVE.W  merk_d0,d0
                MOVE.W  merk_d1,d1
                CMPI.W  #0,d0
                BNE     ttest_2
                MOVEQ   #-1,d7
                MOVE.W  d7,sid_a1
                MOVE.W  d7,sid_b1
                MOVE.W  d7,sid_c1
                BRA     go_no_timer
ttest_2:        CMPI.W  #1,d0
                BNE.S   ttest_3
                MOVEQ   #-1,d7
                MOVE.W  d7,sid_a1
                MOVE.W  d7,sid_c1
                BRA     go_only_1
ttest_3:        CMPI.W  #2,d0
                BNE.S   go_all
                MOVEQ   #-1,d7
                MOVE.W  d7,sid_c1
                BRA     go_2

go_all:         MOVE.L  #new_timer_c,$0110.w
                ANDI.B  #-$10,$FFFFFA1D.w
                ORI.B   #1,$FFFFFA1D.w
                CLR.B   $FFFFFA19.w
                CLR.B   $FFFFFA25.w
                BSET    #4,$FFFFFA15.w
                BCLR    #4,$FFFFFA09.w
                CMP.W   #-1,d1
                BNE.S   go_2
                MOVE.L  #fast_new_c,$0110.w

go_2:           MOVE.L  #new_timer_a,$0120.w
                BCLR    #0,$FFFFFA07.w
                BSET    #0,$FFFFFA13.w
                CLR.B   $FFFFFA1B.w
                CLR.B   $FFFFFA21.w
                CMP.W   #-1,d1
                BNE.S   go_only_1
                MOVE.L  #fast_new_a,$0120.w

go_only_1:      MOVE.L  #new_timer,$0134.w
                BSET    #5,$FFFFFA13.w
                BCLR    #5,$FFFFFA07.w  ; Timer A Disablen
                CLR.B   $FFFFFA19.w
                CLR.B   $FFFFFA1F.w
                CMP.W   #-1,d1
                BNE.S   go_next
                MOVE.L  #fast_new,$0134.w

go_next:        BCLR    #3,$FFFFFA17.w

go_no_timer:    BSR     snd_init
                MOVE    (sp)+,sr
                RTS

re_init:        MOVE    sr,-(sp)
                MOVE    #$2700,sr
                MOVE.L  old110(pc),$0110.w
                MOVE.L  old114(pc),$0120.w
                MOVE.L  old134(pc),$0134.w
                MOVE.B  olda07(pc),$FFFFFA07.w
                MOVE.B  olda09(pc),$FFFFFA09.w
                MOVE.B  olda13(pc),$FFFFFA13.w
                MOVE.B  olda15(pc),$FFFFFA15.w
                MOVE.B  olda19(pc),$FFFFFA19.w
                MOVE.B  olda1d(pc),$FFFFFA1D.w
                MOVE.B  olda25(pc),$FFFFFA25.w
                MOVE.B  olda17(pc),$FFFFFA17.w
                BSR.S   snd_init
                MOVE    (sp)+,sr
                RTS
                ENDPART
**********************************************************
snd_init:       >PART
                LEA     bdata(pc),a0
                BCLR    #5,$FFFFFA07.w
                BCLR    #4,$FFFFFA09.w
                BCLR    #0,$FFFFFA07.w

                BSET    #0,82+82+60(a0)
                BCLR    #1,82+82+60(a0)
                BSET    #0,60(a0)
                BSET    #0,82+60(a0)
                ST      82+82+59(a0)
                ST      59(a0)
                ST      82+59(a0)

                LEA     $FFFF8800.w,a0
                LEA     clear_ym(pc),a1
                MOVEQ   #$0C,d1
cym:            MOVE.W  (a1)+,d0
                MOVEP.W d0,0(a0)
                DBRA    d1,cym
                MOVE.B  #7,(a0)
                MOVE.B  (a0),d0
                ANDI.B  #$C0,d0
                ORI.B   #$3F,d0
                MOVE.B  d0,2(a0)
                RTS

clear_ym:       DC.W $00,$0100,$0200,$0300
                DC.W $0400,$0500,$0600,$0800
                DC.W $0900,$0A00,$0B00,$0C00
                DC.W $0D00
                ENDPART
**********************************************************
init_music:     >PART
                BSR.S   play3v
                CLR.W   pat_lin
                CLR.B   new_timer2+4
                CLR.B   new_timer2_a+4
                CLR.B   new_timer2_c+4
                CLR.B   fast_new_2_a+4
                CLR.B   fast_new2+4
                CLR.B   fast_new_2_c+4

                BRA     calc_pos

play3v:         MOVE.W  #1,play3v
                MOVEQ   #$1F,d0
x02:            LEA     x02,a0
                MOVE.L  #$020005,d7
                LEA     pat_tab(pc),a1
init_pat_tab:   MOVE.L  a0,(a1)+
                LEA     $0300(a0),a0
                DBRA    d0,init_pat_tab
                MOVE.W  #1,note_count
                CLR.W   pos_now
x03:            MOVE.L  #x03,pat_ptr
x04:            MOVE.L  #x04,pat_base
                LEA     env_0(pc),a1
                LEA     bdata(pc),a0
                MOVEQ   #9,d1
                MOVEQ   #2,d2
init_lop:       CLR.B   46(a0)
                MOVE.L  a1,16(a0)
                MOVE.L  d7,24(a0)
                MOVE.W  d1,28(a0)
                MOVE.L  a1,30(a0)
                MOVE.L  d7,36(a0)
                MOVE.W  d1,40(a0)
                LEA     82(a0),a0
                DBRA    d2,init_lop
                RTS
                ENDPART
**********************************************************
load_pos:       >PART
                MOVE.W  d4,pat_lin
                MOVE.W  pos_now(pc),d0
                ADDQ.W  #1,d0
x05:            CMP.W   x05,d0
                BLS.S   no_restart

                LEA     fat_buff,a0
                MOVEA.L a0,a1
                ADDA.L  gesamt,a1
                MOVE.L  #"END!",(a1)+
                LEA     sid_buff,a5
                MOVEA.L a5,a6
                ADDA.W  offset,a6
                ILLEGAL

x06:            MOVE.W  x06,d0
no_restart:     MOVE.W  d0,pos_now
calc_pos:       LEA     calc_pos,a0
                MOVE.W  pos_now(pc),d0
                MOVE.B  0(a0,d0.w),d0
                ANDI.W  #$7F,d0
                MOVE.W  d0,pat_now
                LEA     pat_tab(pc),a0
                ADD.W   d0,d0
                ADD.W   d0,d0
                MOVE.L  0(a0,d0.w),pat_base
                RTS
                ENDPART
**********************************************************
                >PART 'Special Datas'
                DATA
                EVEN
dual_a:         DC.W 1
dual_b:         DC.W 1
dual_c:         DC.W 1

sid_a:          DC.W -1
sid_b:          DC.W -1
sid_c:          DC.W -1
sid_a1:         DC.W 0
sid_b1:         DC.W 0
sid_c1:         DC.W 0

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

wave_form3:     REPT 2
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

arps_max        SET 9
special_fx_max  SET 11
nois_max        SET 44+5
tones_max       SET 34+9
waves_max       SET 15
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

                DS.W 80



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

trem_tab:       DC.W $00,$01AC,$0354,$04F2
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
                PART 'datas'
merk_d0:        DC.W 0
merk_d1:        DC.W 0
offset:         DC.B 0
                EVEN
speed_:         DC.W 0
break_cmd:      DC.W 0          ; Pattern-Break Command
what:           DC.W 0          ; Speed Change-Flag
merk_speed:     DC.W 0          ; Speed merken
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

                DC.B -1

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

ext_sound_b:    DS.B 34         ; $3d-$52

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
ext_sound_c:    DS.B 34

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
ext_sound_a:    DS.B 34
spec_table:     DS.B 252
pos_now:        DS.W 1
pat_now:        DS.W 1
pat_tab:        DS.B 480
pat_base:       DS.L 1
pat_lin:        DS.W 1
pat_ptr:        DS.L 1
env_0:          DS.B 10
old110:         DC.L 0
old114:         DC.L 0
old134:         DC.L 0
olda07:         DC.B 0
olda09:         DC.B 0
olda13:         DC.B 0
olda15:         DC.B 0
olda17:         DC.B 0
olda19:         DC.B 0
olda1d:         DC.B 0
olda25:         DC.B 0
note_count:     DS.W 1
song_ptr:       DC.L $DEADFACE
vct_ptr:        DC.L "M.C."
gesamt:         DC.L 0
zaehl:          DC.L 0
actual_a5:      DC.L fat_buff
sid_vols:       DC.L sid_buff
merk_a3:        DC.L sid_buff
                EVEN
merk_d7:        DC.B 0
merk_d0x:       DC.B 0
merk_d3:        DC.B 0
                EVEN
                ENDPART

                PATH 'D:\TESTSOUN.TRI\'
song1:          IBYTES 'C:\SCAVY5.TRI'
                EVEN
voice:          IBYTES 'C:\SCAVY5.TVS'
                BSS
sid_buff:       DS.B 64000
fat_buff:       DS.L 176000/4
                END
