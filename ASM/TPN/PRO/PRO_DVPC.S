********************************************************************************
**                                                                            **
**  4 TRACK REPLAY FALCON 030                             ½ 12.1.1993 by TPN  **
**  Running at 33Khz 16Bit Stereo.                          Written by CYLAB  **
**                                                                            **
**  This routine uses 25 percent of the 030 processortime.                    **
**  Even if the routine ft_fillbuff doesn't look optimized, it's the (yet)    **
**  fastest way to mix the samples. Also the DBRA-loop is faster than repea-  **
**  ted code, because the hole routine is able to stay in the instruction-    **
**  cache! Perhaps I will do a DSP-version, but I think you should use the    **
**  DSP for more complex calculations (or for more voices).                   **
**                                                                            **
**  start:      pea     module             stop:    move.w  #0,-(sp)          **
**              move.w  #1,-(SP)                    bsr     ft_main           **
**              bsr     ft_main                     addq.w  #4,sp             **
**              addq.w  #6,SP                                                 **
**                                                                            **
**  D0=0  --> No Error                                                        **
**  D0=-1 --> Soundsystem locked                                              **
**                                                                            **
**  The routine needs a space of 31000 Bytes behind the module.               **
**                                                                            **
********************************************************************************

ft_main:                                ; 'Mainprogramm'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                tst.w   4(SP)
                bne.s   ft_start
                tst.b   ft_act
                beq.s   ft_noplay
                movem.l D0-A6,-(SP)
                bsr     ft_res_mode
                bsr     ft_stop_mfp
                bsr     ft_res_add
                clr.b   ft_act
                bsr     ft_clear_bss
                movem.l (SP)+,D0-A6
ft_noplay:      rts
ft_start:       tst.b   ft_act
                beq.s   ft_play
                move.w  #0,-(SP)
                bsr     ft_main
                addq.w  #2,SP
ft_play:        move.l  6(SP),mt_data
                movem.l D1-A6,-(SP)
                bsr     ft_tstsnd
                tst.l   D0
                bne.s   ft_sndlocked
                bsr     ft_heal_rept
                bsr     mt_init
                bsr     ft_calc_vol
                bsr     ft_calc_freq
                bsr     ft_init
                bsr     ft_set_add
                bsr     ft_set_buff
                bsr     ft_set_sndmode
                bsr     ft_set_datapath
                bsr     ft_set_mfp
                bsr     ft_start_play
                st      ft_act
                moveq   #0,D0
ft_sndlocked:   movem.l (SP)+,D1-A6
                rts
ft_act:         DC.W 0

ft_tstsnd:                              ; 'Tests lockstatus'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.w  #$0080,-(SP)
                trap    #14
                addq.w  #2,SP
                tst.w   D0
                bmi.s   ft_locked
                move.w  #$0081,-(SP)
                trap    #14
                addq.w  #2,SP
                moveq   #0,D0
                rts
ft_locked:      moveq   #-1,D0
                rts

ft_heal_rept:                           ; 'Heals repeat'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                movea.l mt_data,A0
                movea.l A0,A1
                lea     952(A1),A1
                moveq   #127,D0
                moveq   #0,D1
ft_loop:        move.l  D1,D2
                subq.w  #1,D0
ft_loop2:       move.b  (A1)+,D1
                cmp.b   D2,D1
                bgt.s   ft_loop
                dbra    D0,ft_loop2
                addq.b  #1,D2

                lea     ft_sam_adds,A1
                lea     ft_rep_adds,A4
                lea     ft_rep_lens,A5
                asl.l   #8,D2
                asl.l   #2,D2
                add.l   #1084,D2
                add.l   A0,D2
                movea.l D2,A2
                moveq   #30,D0
ft_loop3:       move.l  A2,(A1)+
                move.l  A2,(A4)
                moveq   #0,D1
                move.w  42(A0),D1
                asl.l   #1,D1
                adda.l  D1,A2
                moveq   #0,D1
                move.w  46(A0),D1
                asl.l   #1,D1
                add.l   D1,(A4)+
                moveq   #0,D1
                move.w  48(A0),D1
                asl.l   #1,D1
                move.l  D1,(A5)+
                adda.l  #30,A0
                dbra    D0,ft_loop3
                moveq   #30,D0
                move.l  #30000,D1
ft_loop4:       lea     0(A2,D1.w),A3
                move.b  -1(A2),D4
                movea.l -(A4),A6
                move.l  -(A5),D3
                cmp.l   #3,D3
                bhs.s   ft_rept
                move.l  #999,D2
ft_loop5a:      move.b  D4,(A3)+
                dbra    D2,ft_loop5a
                bra.s   ft_rep_end
ft_rept:        move.l  #999,D2
ft_loop5:       subq.l  #1,D3
                bpl.s   ft_set
                movea.l (A4),A6
                move.l  (A5),D3
                subq.l  #1,D3
ft_set:         move.b  (A6)+,(A3)+
                dbra    D2,ft_loop5
ft_rep_end:     suba.w  #1000,A3
                movea.l -(A1),A0
                cmpa.l  A2,A0
                beq.s   ft_noloop
ft_loop6:       move.b  -(A2),-(A3)
                cmpa.l  A2,A0
                bne.s   ft_loop6
ft_noloop:      sub.l   #1000,D1
                dbra    D0,ft_loop4
                rts

ft_calc_vol:                            ; 'Calculates Volumetable'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.l  #ft_volumes,D0
                add.l   #$00000200,D0
                andi.l  #$FFFFFE00,D0
                move.l  D0,ft_voladd
                movea.l D0,A0
                adda.l  #512*65,A0
                move.w  #64,D1
ft_mulloop:     move.w  #255,D2
ft_byteloop:    move.w  D2,D3
                ext.w   D3
                muls    D1,D3
                add.w   D3,D3
                move.w  D3,-(A0)
                dbra    D2,ft_byteloop
                dbra    D1,ft_mulloop
                rts

ft_calc_freq:                           ; 'Calculates the frequencytable'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                lea     ft_frequencies,A0
                clr.l   (A0)+
                move.l  #$006D3304,D2
                moveq   #1,D1
                move.w  #998,D0
ft_freqloop:    move.l  D2,D3
                clr.w   D3
                swap    D3
                divu    D1,D3
                move.w  D3,(A0)+
                move.w  D2,D3
                divu    D1,D3
                move.w  D3,(A0)+
                addq.w  #1,D1
                dbra    D0,ft_freqloop
                rts

ft_init:                                ; 'Initilizes'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.l  #ft_soundbuff,ft_sndstart1
                move.l  #ft_soundbuff2,ft_sndstart2
                move.l  #ft_buffend,ft_sndend1
                move.l  #ft_buffend2,ft_sndend2
                rts

ft_set_add:                             ; 'Sets the hardware adder'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.w  #-1,-(SP)
                move.w  #$0004,-(SP)
                move.w  #$0082,-(SP)
                trap    #14
                addq.w  #6,SP
                move.w  D0,ft_oldadd
                move.w  #$0002,-(SP)
                move.w  #$0004,-(SP)
                move.w  #$0082,-(SP)
                trap    #14
                addq.w  #6,SP
                rts

ft_res_add:                             ; 'Restores the hardware adder'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.w  ft_oldadd,-(SP)
                move.w  #$0004,-(SP)
                move.w  #$0082,-(SP)
                trap    #14
                addq.w  #6,SP
                rts

ft_set_buff:                            ; 'Sets the playbuffer'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                pea     ft_buffend
                pea     ft_soundbuff
                move.w  #0,-(SP)
                move.w  #$0083,-(SP)
                trap    #14
                lea     12(SP),SP
                rts

ft_set_sndmode:                         ; 'Sets the replay mode'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.w  #1,-(SP)
                move.w  #$0084,-(SP)
                trap    #14
                addq.w  #4,SP
                move.w  #0,-(SP)
                move.w  #0,-(SP)
                move.w  #$0085,-(SP)
                trap    #14
                addq.w  #6,SP
                move.w  #0,-(SP)
                move.w  #$0086,-(SP)
                trap    #14
                addq.w  #4,SP
                rts

ft_set_datapath:                        ; 'Sets the datapath'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.w  #1,-(SP)
                move.w  #2,-(SP)
                move.w  #0,-(SP)
                move.w  #8,-(SP)
                move.w  #0,-(SP)
                move.w  #$008B,-(SP)
                trap    #14
                lea     12(SP),SP
                rts

ft_set_mfp:                             ; 'Sets the Timer A interrupt'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                pea     ft_newta
                move.w  #1,-(SP)
                move.w  #8,-(SP)
                move.w  #0,-(SP)
                move.w  #31,-(SP)
                trap    #14
                lea     12(SP),SP
                rts

ft_stop_mfp:                            ; 'Stops the Timer A interrupt'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                pea     -1
                move.w  #$00FF,-(SP)
                move.w  #0,-(SP)
                move.w  #0,-(SP)
                move.w  #31,-(SP)
                trap    #14
                lea     12(SP),SP
                rts

ft_start_play:                          ; 'Starts the DMA play'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.w  #$0001,-(SP)
                move.w  #0,-(SP)
                move.w  #$0087,-(SP)
                trap    #14
                addq.w  #6,SP
                move.w  #-1,-(SP)
                move.w  #$0088,-(SP)
                trap    #14
                addq.w  #4,SP
                move.w  D0,ft_oldplaymode
                move.w  #3,-(SP)
                move.w  #$0088,-(SP)
                trap    #14
                addq.w  #4,SP
                rts

ft_res_mode:                            ; 'Restores playmode'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.w  ft_oldplaymode,-(SP)
                move.w  #$0088,-(SP)
                trap    #14
                addq.w  #4,SP
                rts

ft_clear_bss:                           ; 'Clears the BSS-Segment'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                lea     ft_bss,A0
                lea     ft_end,A1
ft_bssclear:    clr.b   (A0)+
                cmpa.l  A0,A1
                bne.s   ft_bssclear
                rts

;               INTERRUPTHANDLING
ft_newta:                               ; 'New timer A'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                bclr    #5,$FFFFFA0F.w
                move.l  D0,-(SP)
                move.w  4(SP),D0
                ori.w   #$2000,D0
                move    D0,SR
                movem.l D1-A6,-(SP)
                bsr     mt_music
                move.l  $000004A2.w,ft_oldsave
                move.l  #ft_newsave,$000004A2.w
                movem.l ft_sndstart1,D0-D3
                exg     D0,D1
                exg     D2,D3
                movem.l D0-D3,ft_sndstart1
                move.l  D2,-(SP)
                move.l  D0,-(SP)
                move.w  #0,-(SP)
                move.w  #$0083,-(SP)
                trap    #14
                lea     12(SP),SP
                move.l  ft_oldsave,$000004A2.w
                bsr     ft_settings
                bsr     ft_set_left
                bsr     ft_fillbuff
                bsr     ft_res_lsets
                bsr     ft_set_right
                bsr     ft_fillbuff
                bsr     ft_res_rsets
                movem.l (SP)+,D1-A6
                move.l  (SP)+,D0
                rte

ft_set_adds:                            ; 'Sets the sampleadresses'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                move.w  ft_ch_dma,D0
                move.w  ft_int_dma,D1
                and.w   D0,D1
                move.w  D0,ft_int_dma
                btst    #0,D0
                bne.s   ft_no_silence1
                move.l  #ft_no_noise,ft_samcount_a
                bra.s   ft_no_newstart1
ft_no_silence1: btst    #0,D1
                bne.s   ft_no_newstart1
                move.l  ft_samstart_a,ft_samcount_a
                move.l  ft_samstart_a,ft_samend_a
                clr.w   ft_sampoint_a
                moveq   #0,D2
                move.w  ft_samlength_a,D2
                add.l   D2,D2
                add.l   D2,ft_samend_a
ft_no_newstart1:btst    #1,D0
                bne.s   ft_no_silence2
                move.l  #ft_no_noise,ft_samcount_b
                bra.s   ft_no_newstart2
ft_no_silence2: btst    #1,D1
                bne.s   ft_no_newstart2
                move.l  ft_samstart_b,ft_samcount_b
                move.l  ft_samstart_b,ft_samend_b
                clr.w   ft_sampoint_b
                moveq   #0,D2
                move.w  ft_samlength_b,D2
                add.l   D2,D2
                add.l   D2,ft_samend_b
ft_no_newstart2:btst    #2,D0
                bne.s   ft_no_silence3
                move.l  #ft_no_noise,ft_samcount_c
                bra.s   ft_no_newstart3
ft_no_silence3: btst    #2,D1
                bne.s   ft_no_newstart3
                move.l  ft_samstart_c,ft_samcount_c
                move.l  ft_samstart_c,ft_samend_c
                clr.w   ft_sampoint_c
                moveq   #0,D2
                move.w  ft_samlength_c,D2
                add.l   D2,D2
                add.l   D2,ft_samend_c
ft_no_newstart3:btst    #3,D0
                bne.s   ft_no_silence4
                move.l  #ft_no_noise,ft_samcount_d
                bra.s   ft_no_newstart4
ft_no_silence4: btst    #3,D1
                bne.s   ft_no_newstart4
                move.l  ft_samstart_d,ft_samcount_d
                move.l  ft_samstart_d,ft_samend_d
                clr.w   ft_sampoint_d
                moveq   #0,D2
                move.w  ft_samlength_d,D2
                add.l   D2,D2
                add.l   D2,ft_samend_d
ft_no_newstart4:rts

ft_settings:                            ; 'Guess it'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                cmpi.w  #$0040,ft_samvol_a
                bls.s   ft_volok_a
                clr.w   ft_samvol_a
ft_volok_a:     cmpi.w  #$0040,ft_samvol_b
                bls.s   ft_volok_b
                clr.w   ft_samvol_b
ft_volok_b:     cmpi.w  #$0040,ft_samvol_c
                bls.s   ft_volok_c
                clr.w   ft_samvol_c
ft_volok_c:     cmpi.w  #$0040,ft_samvol_d
                bls.s   ft_volok_d
                clr.w   ft_samvol_d
ft_volok_d:     move.w  ft_samper_a,ft_intper_a
                move.w  ft_samper_b,ft_intper_b
                move.w  ft_samper_c,ft_intper_c
                move.w  ft_samper_d,ft_intper_d
                tst.w   ft_flag_a
                beq.s   ft_per_enable1
                clr.w   ft_intper_a
                clr.w   ft_flag_a
ft_per_enable1:
                tst.w   ft_flag_b
                beq.s   ft_per_enable2
                clr.w   ft_intper_b
                clr.w   ft_flag_b
ft_per_enable2:
                tst.w   ft_flag_c
                beq.s   ft_per_enable3
                clr.w   ft_intper_c
                clr.w   ft_flag_c
ft_per_enable3:
                tst.w   ft_flag_d
                beq.s   ft_per_enable4
                clr.w   ft_intper_d
                clr.w   ft_flag_d
ft_per_enable4:
                rts

ft_set_left:                            ; 'Sets datas for left Channel'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                lea     ft_frequencies,A3
                move.w  ft_intper_a,D0  ; Get frequencies
                move.w  ft_intper_d,D1
                add.w   D0,D0
                add.w   D0,D0
                add.w   D1,D1
                add.w   D1,D1
                movea.l 0(A3,D0.w),A5   ; Get offsets
                move.l  0(A3,D1.w),D6
                swap    D6
                move.w  0(A3,D0.w),D6
                move.w  0(A3,D1.w),D7
                moveq   #0,D0
                moveq   #0,D1
                move.w  ft_samvol_a,D0  ; Get volume
                move.w  ft_samvol_d,D1
                add.w   D0,D0
                add.w   D1,D1
                lsl.l   #8,D0
                lsl.l   #8,D1
                movea.l ft_voladd,A2    ; Get start of volumetable
                movea.l ft_voladd,A3
                adda.l  D0,A2           ; Calculate adress of volumetable
                adda.l  D1,A3
                move.w  ft_sampoint_a,D5 ; Get realpart of samcounter
                move.w  ft_sampoint_d,D0
                swap    D0
                clr.w   D0
                clr.l   D1
                movea.l ft_sndstart1,A4 ; Get bufferadress
                movea.l ft_samcount_a,A0 ; Get Sampleadress
                movea.l ft_samcount_d,A1
                rts

ft_res_lsets:                           ; 'Save samsettings'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                adda.w  D0,A0
                adda.w  D1,A1
                swap    D0
                move.w  D5,ft_sampoint_a ; Save realpart
                move.w  D0,ft_sampoint_b
                cmpa.l  ft_samend_a,A0  ; End of sample ?
                blo.s   ft_no_end1
                cmpi.w  #3,ft_samlength_a
                bhi.s   ft_noise_a
                move.w  #1,ft_flag_a
                bra.s   ft_no_end1
ft_noise_a:     moveq   #0,D0
                move.w  ft_samlength_a,D0
                add.l   D0,D0
                suba.l  ft_samend_a,A0
ft_sub_a:       cmpa.l  D0,A0
                bls.s   ft_reptok_a
                suba.l  D0,A0
                bra.s   ft_sub_a
ft_reptok_a:    add.l   ft_samstart_a,D0
                move.l  D0,ft_samend_a
                adda.l  ft_samstart_a,A0
ft_no_end1:     cmpa.l  ft_samend_d,A1  ; End of sample ?
                blo.s   ft_no_end2
                cmpi.w  #3,ft_samlength_d
                bhi.s   ft_noise_d
                move.w  #1,ft_flag_d
                bra.s   ft_no_end2
ft_noise_d:     moveq   #0,D0
                move.w  ft_samlength_d,D0
                add.l   D0,D0
                suba.l  ft_samend_d,A1
ft_sub_d:       cmpa.l  D0,A1
                blo.s   ft_reptok_d
                suba.l  D0,A1
                bra.s   ft_sub_d
ft_reptok_d:    add.l   ft_samstart_d,D0
                move.l  D0,ft_samend_d
                adda.l  ft_samstart_d,A1
ft_no_end2:     move.l  A0,ft_samcount_a ; Save sampleadresses
                move.l  A1,ft_samcount_d
                rts

ft_set_right:                           ; 'Sets datas for right Channel'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                lea     ft_frequencies,A3
                move.w  ft_intper_b,D0  ; Get frequencies
                move.w  ft_intper_c,D1
                add.w   D0,D0
                add.w   D0,D0
                add.w   D1,D1
                add.w   D1,D1
                movea.l 0(A3,D0.w),A5   ; Get offsets
                move.l  0(A3,D1.w),D6
                swap    D6
                move.w  0(A3,D0.w),D6
                move.w  0(A3,D1.w),D7
                moveq   #0,D0
                moveq   #0,D1
                move.w  ft_samvol_b,D0  ; Get volume
                move.w  ft_samvol_c,D1
                add.w   D0,D0
                add.w   D1,D1
                lsl.l   #8,D0
                lsl.l   #8,D1
                movea.l ft_voladd,A2    ; Get start of volumetable
                movea.l ft_voladd,A3
                adda.l  D0,A2           ; Calculate adress of volumetable
                adda.l  D1,A3
                move.w  ft_sampoint_b,D5 ; Get realpart of samcounter
                move.w  ft_sampoint_c,D0
                swap    D0
                clr.w   D0
                clr.l   D1
                movea.l ft_sndstart1,A4 ; Get bufferadress
                addq.w  #2,A4
                movea.l ft_samcount_b,A0 ; Get Sampleadress
                movea.l ft_samcount_c,A1
                rts

ft_res_rsets:                           ; 'Save samsettings'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                adda.w  D0,A0
                adda.w  D1,A1
                swap    D0
                move.w  D5,ft_sampoint_b ; Save realpart
                move.w  D0,ft_sampoint_c
                cmpa.l  ft_samend_b,A0  ; End of sample ?
                blo.s   ft_no_end1b
                cmpi.w  #3,ft_samlength_b
                bhi.s   ft_noise_b
                move.w  #1,ft_flag_b
                bra.s   ft_no_end1b
ft_noise_b:     moveq   #0,D0
                move.w  ft_samlength_b,D0
                add.l   D0,D0
                suba.l  ft_samend_b,A0
ft_sub_b:       cmpa.l  D0,A0
                blo.s   ft_reptok_b
                suba.l  D0,A0
                bra.s   ft_sub_b
ft_reptok_b:    add.l   ft_samstart_b,D0
                move.l  D0,ft_samend_b
                adda.l  ft_samstart_b,A0
ft_no_end1b:    cmpa.l  ft_samend_c,A1  ; End of sample ?
                blo.s   ft_no_end2b
                cmpi.w  #3,ft_samlength_c
                bhi.s   ft_noise_c
                move.w  #1,ft_flag_c
                bra.s   ft_no_end2b
ft_noise_c:     moveq   #0,D0
                move.w  ft_samlength_c,D0
                add.l   D0,D0
                suba.l  ft_samend_c,A1
ft_sub_c:       cmpa.l  D0,A1
                blo.s   ft_reptok_c
                suba.l  D0,A1
                bra.s   ft_sub_c
ft_reptok_c:    add.l   ft_samstart_c,D0
                move.l  D0,ft_samend_c
                adda.l  ft_samstart_c,A1
ft_no_end2b:    move.l  A0,ft_samcount_b ; Save sampleadresses
                move.l  A1,ft_samcount_c
                rts

ft_fillbuff:                            ; 'Fills the playbuffer'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                moveq   #0,D3
                move.w  #655,D2
ft_fillloop:    move.b  0(A0,D0.w),D3
                DC.L $38323200          ; move.w  0(a2,d3.w*2),d4
                move.b  0(A1,D1.w),D3
                DC.L $D8733200          ; add.w   0(a3,d3.w*2),d4
                move.w  D4,(A4)
                addq.w  #4,A4
                add.w   A5,D5
                addx.l  D6,D0
                addx.w  D7,D1
                dbra    D2,ft_fillloop
                rts

ft_set_dma:                             ; 'Emulates Paula DMA handling'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
                add.w   D7,D7
                bcc     ft_clear
                lsr.w   #1,D7
                or.w    D7,ft_ch_dma
                rts
ft_clear:       lsr.w   #1,D7
                not.w   D7
                and.w   D7,ft_ch_dma
                and.w   D7,ft_int_dma
                rts

;+-----------------------------------------+
;| **** Protracker V1.0C  Playroutine **** |
;|                                         |
;| Lars "Zap" Hamre/Amiga Freelancers 1990 |
;| Bekkeliveien 10, 2010 STRØMMEN, Norway  |
;|     Optimized & Recoded For Seka By     |
;|            The Master Of Aero           |
;|   Converted to Falcon by CYLAB of TPN   |
;+-----------------------------------------+

; This playroutine is not very fast, optimized or well commented,
; but all the new commands in PT1.0C should function correctly.
; If it's not good enough, you'll have to change it yourself.

mt_chanxtemp:                           ; 'Offsets'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
n_note          EQU 0                   ; W
n_cmd           EQU 2                   ; W
n_cmdlo         EQU 3                   ; low B of n_cmd
n_start         EQU 4                   ; L
n_length        EQU 8                   ; W
n_loopstart     EQU 10                  ; L
n_replen        EQU 14                  ; W
n_period        EQU 16                  ; W
n_finetune      EQU 18                  ; B
n_volume        EQU 19                  ; B
n_dmabit        EQU 20                  ; W
n_toneportdirec EQU 22                  ; B
n_toneportspeed EQU 23                  ; B
n_wantedperiod  EQU 24                  ; W
n_vibratocmd    EQU 26                  ; B
n_vibratopos    EQU 27                  ; B
n_tremolocmd    EQU 28                  ; B
n_tremolopos    EQU 29                  ; B
n_wavecontrol   EQU 30                  ; B
n_glissfunk     EQU 31                  ; B
n_sampleoffset  EQU 32                  ; B
n_pattpos       EQU 33                  ; B
n_loopcount     EQU 34                  ; B
n_funkoffset    EQU 35                  ; B
n_wavestart     EQU 36                  ; L
n_reallength    EQU 40                  ; W
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*

mt_init:        movea.l mt_data,A0      ; 'Starts modulereplay'
                move.l  A0,mt_songdataptr
                movea.l A0,A1
                lea     952(A1),A1
                moveq   #127,D0
                moveq   #0,D1

mtloop:         move.l  D1,D2
                subq.w  #1,D0

mtloop2:        move.b  (A1)+,D1
                cmp.b   D2,D1
                bgt.s   mtloop
                dbra    D0,mtloop2
                addq.b  #1,D2

                lea     mt_samplestarts(PC),A1
                asl.l   #8,D2
                asl.l   #2,D2
                add.l   #1084,D2
                add.l   A0,D2
                movea.l D2,A2
                moveq   #30,D0

mtloop3:        clr.l   (A2)
                move.l  A2,(A1)+
                moveq   #0,D1
                move.w  42(A0),D1
                asl.l   #1,D1
                add.w   #1000,D1
                adda.l  D1,A2
                adda.l  #30,A0
                dbra    D0,mtloop3

                ori.b   #2,ft_filter
                move.b  #6,mt_speed
                clr.w   ft_samvol_a
                clr.w   ft_samvol_b
                clr.w   ft_samvol_c
                clr.w   ft_samvol_d
                clr.b   mt_counter
                clr.b   mt_songpos
                clr.w   mt_patternpos
                rts

mt_music:       movem.l D0-D4/A0-A6,-(SP) ; 'Sequencer'
                addq.b  #1,mt_counter
                move.b  mt_counter(PC),D0
                cmp.b   mt_speed(PC),D0
                blo.s   mt_nonewnote
                clr.b   mt_counter
                tst.b   mt_pattdeltime2
                beq.s   mt_getnewnote
                bsr     mt_nonewallchannels
                bra     mt_dskip

mt_nonewnote:   bsr     mt_nonewallchannels
                bra     mt_nonewposyet

mt_nonewallchannels:lea ft_samstart_a,A5
                lea     mt_chan1temp(PC),A6
                bsr     mt_checkefx
                lea     ft_samstart_b,A5
                lea     mt_chan2temp(PC),A6
                bsr     mt_checkefx
                lea     ft_samstart_c,A5
                lea     mt_chan3temp(PC),A6
                bsr     mt_checkefx
                lea     ft_samstart_d,A5
                lea     mt_chan4temp(PC),A6
                bra     mt_checkefx

mt_getnewnote:  movea.l mt_songdataptr(PC),A0
                lea     12(A0),A3
                lea     952(A0),A2      ;pattpo
                lea     1084(A0),A0     ;patterndata
                moveq   #0,D0
                moveq   #0,D1
                move.b  mt_songpos(PC),D0
                move.b  0(A2,D0.w),D1
                asl.l   #8,D1
                asl.l   #2,D1
                add.w   mt_patternpos(PC),D1
                clr.w   mt_dmacontemp

                lea     ft_samstart_a,A5
                lea     mt_chan1temp(PC),A6
                bsr     mt_playvoice
                lea     ft_samstart_b,A5
                lea     mt_chan2temp(PC),A6
                bsr     mt_playvoice
                lea     ft_samstart_c,A5
                lea     mt_chan3temp(PC),A6
                bsr     mt_playvoice
                lea     ft_samstart_d,A5
                lea     mt_chan4temp(PC),A6
                bsr     mt_playvoice
                bra     mt_setdma

mt_playvoice:   tst.l   (A6)
                bne.s   mt_plvskip
                bsr     mt_pernop

mt_plvskip:     move.l  0(A0,D1.l),(A6)
                addq.l  #4,D1
                moveq   #0,D2
                move.b  n_cmd(A6),D2
                and.b   #$F0,D2
                lsr.b   #4,D2
                move.b  (A6),D0
                and.b   #$F0,D0
                or.b    D0,D2
                tst.b   D2
                beq     mt_setregs
                moveq   #0,D3
                lea     mt_samplestarts(PC),A1
                move.w  D2,D4
                subq.l  #1,D2
                asl.l   #2,D2
                mulu    #30,D4
                move.l  0(A1,D2.l),n_start(A6)
                move.w  0(A3,D4.l),n_length(A6)
                move.w  0(A3,D4.l),n_reallength(A6)
                move.b  2(A3,D4.l),n_finetune(A6)
                move.b  3(A3,D4.l),n_volume(A6)
                move.w  4(A3,D4.l),D3   ; Get repeat
                tst.w   D3
                beq.s   mt_noloop
                move.l  n_start(A6),D2  ; Get start
                asl.w   #1,D3
                add.l   D3,D2           ; Add repeat
                move.l  D2,n_loopstart(A6)
                move.l  D2,n_wavestart(A6)
                move.w  4(A3,D4.l),D0   ; Get repeat
                add.w   6(A3,D4.l),D0   ; Add replen
                move.w  D0,n_length(A6)
                move.w  6(A3,D4.l),n_replen(A6) ; Save replen
                moveq   #0,D0
                move.b  n_volume(A6),D0
                move.w  D0,8(A5)        ; Set volume
                bra.s   mt_setregs

mt_noloop:      move.l  n_start(A6),D2
                add.l   D3,D2
                move.l  D2,n_loopstart(A6)
                move.l  D2,n_wavestart(A6)
                move.w  6(A3,D4.l),n_replen(A6) ; Save replen
                moveq   #0,D0
                move.b  n_volume(A6),D0
                move.w  D0,8(A5)        ; Set volume

mt_setregs:     move.w  (A6),D0
                and.w   #$0FFF,D0
                beq     mt_checkmoreefx ; If no note
                move.w  2(A6),D0
                and.w   #$0FF0,D0
                cmp.w   #$0E50,D0
                beq.s   mt_dosetfinetune
                move.b  2(A6),D0
                and.b   #$0F,D0
                cmp.b   #3,D0           ; TonePortamento
                beq.s   mt_chktoneporta
                cmp.b   #5,D0
                beq.s   mt_chktoneporta
                cmp.b   #9,D0           ; Sample Offset
                bne.s   mt_setperiod
                bsr     mt_checkmoreefx
                bra.s   mt_setperiod

mt_dosetfinetune:bsr    mt_setfinetune
                bra.s   mt_setperiod

mt_chktoneporta:bsr     mt_settoneporta
                bra     mt_checkmoreefx

mt_setperiod:   movem.l D0-D1/A0-A1,-(SP)
                move.w  (A6),D1
                and.w   #$0FFF,D1
                lea     mt_periodtable(PC),A1
                moveq   #0,D0
                moveq   #36,D7

mt_ftuloop:     cmp.w   0(A1,D0.w),D1
                bhs.s   mt_ftufound
                addq.l  #2,D0
                dbra    D7,mt_ftuloop

mt_ftufound:    moveq   #0,D1
                move.b  n_finetune(A6),D1
                mulu    #36*2,D1
                adda.l  D1,A1
                move.w  0(A1,D0.w),n_period(A6)
                movem.l (SP)+,D0-D1/A0-A1

                move.w  2(A6),D0
                and.w   #$0FF0,D0
                cmp.w   #$0ED0,D0       ; Notedelay
                beq     mt_checkmoreefx

                move.w  n_dmabit(A6),D7
                bsr     ft_set_dma
                btst    #2,n_wavecontrol(A6)
                bne.s   mt_vibnoc
                clr.b   n_vibratopos(A6)

mt_vibnoc:      btst    #6,n_wavecontrol(A6)
                bne.s   mt_trenoc
                clr.b   n_tremolopos(A6)

mt_trenoc:      move.l  n_start(A6),(A5) ; Set start
                move.w  n_length(A6),4(A5) ; Set length
                move.w  n_period(A6),D0
                move.w  D0,6(A5)        ; Set period
                move.w  n_dmabit(A6),D0
                or.w    D0,mt_dmacontemp
                bra     mt_checkmoreefx

mt_setdma:      move.w  mt_dmacontemp(PC),D7
                or.w    #$8000,D7
                bsr     ft_set_dma
                bsr     ft_set_adds
                lea     ft_samstart_d,A5
                lea     mt_chan4temp(PC),A6
                move.l  n_loopstart(A6),(A5)
                move.w  n_replen(A6),$0004(A5)
                lea     ft_samstart_c,A5
                lea     mt_chan3temp(PC),A6
                move.l  n_loopstart(A6),(A5)
                move.w  n_replen(A6),$0004(A5)
                lea     ft_samstart_b,A5
                lea     mt_chan2temp(PC),A6
                move.l  n_loopstart(A6),(A5)
                move.w  n_replen(A6),$0004(A5)
                lea     ft_samstart_a,A5
                lea     mt_chan1temp(PC),A6
                move.l  n_loopstart(A6),(A5)
                move.w  n_replen(A6),$0004(A5)

mt_dskip:       addi.w  #16,mt_patternpos
                move.b  mt_pattdeltime,D0
                beq.s   mt_dskc
                move.b  D0,mt_pattdeltime2
                clr.b   mt_pattdeltime

mt_dskc:        tst.b   mt_pattdeltime2
                beq.s   mt_dska
                subq.b  #1,mt_pattdeltime2
                beq.s   mt_dska
                subi.w  #16,mt_patternpos

mt_dska:        tst.b   mt_pbreakflag
                beq.s   mt_nnpysk
                sf      mt_pbreakflag
                moveq   #0,D0
                move.b  mt_pbreakpos(PC),D0
                clr.b   mt_pbreakpos
                lsl.w   #4,D0
                move.w  D0,mt_patternpos

mt_nnpysk:      cmpi.w  #1024,mt_patternpos
                blo.s   mt_nonewposyet

mt_nextposition:moveq   #0,D0
                move.b  mt_pbreakpos(PC),D0
                lsl.w   #4,D0
                move.w  D0,mt_patternpos
                clr.b   mt_pbreakpos
                clr.b   mt_posjumpflag
                addq.b  #1,mt_songpos
                andi.b  #$7F,mt_songpos
                move.b  mt_songpos(PC),D1
                movea.l mt_songdataptr(PC),A0
                cmp.b   950(A0),D1
                blo.s   mt_nonewposyet
                clr.b   mt_songpos

mt_nonewposyet: tst.b   mt_posjumpflag
                bne.s   mt_nextposition
                movem.l (SP)+,D0-D4/A0-A6
                rts

mt_checkefx:    bsr     mt_updatefunk
                move.w  n_cmd(A6),D0
                and.w   #$0FFF,D0
                beq.s   mt_pernop
                move.b  n_cmd(A6),D0
                and.b   #$0F,D0
                beq.s   mt_arpeggio
                cmp.b   #1,D0
                beq     mt_portaup
                cmp.b   #2,D0
                beq     mt_portadown
                cmp.b   #3,D0
                beq     mt_toneportamento
                cmp.b   #4,D0
                beq     mt_vibrato
                cmp.b   #5,D0
                beq     mt_toneplusvolslide
                cmp.b   #6,D0
                beq     mt_vibratoplusvolslide
                cmp.b   #$0E,D0
                beq     mt_e_commands

setback:        move.w  n_period(A6),6(A5)
                cmp.b   #7,D0
                beq     mt_tremolo
                cmp.b   #$0A,D0
                beq     mt_volumeslide

mt_return2:     rts

mt_pernop:      move.w  n_period(A6),6(A5)
                rts

mt_arpeggio:    moveq   #0,D0
                move.b  mt_counter(PC),D0
                divs    #3,D0
                swap    D0
                cmp.w   #0,D0
                beq.s   mt_arpeggio2
                cmp.w   #2,D0
                beq.s   mt_arpeggio1
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                lsr.b   #4,D0
                bra.s   mt_arpeggio3

mt_arpeggio1:   moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #15,D0
;       BRA.s   mt_Arpeggio3

mt_arpeggio3:   asl.w   #1,D0
                moveq   #0,D1
                move.b  n_finetune(A6),D1
                mulu    #36*2,D1
                lea     mt_periodtable(PC),A0
                adda.l  D1,A0
                moveq   #0,D1
                move.w  n_period(A6),D1
                moveq   #36,D7

mt_arploop:     move.w  0(A0,D0.w),D2
                cmp.w   (A0),D1
                bhs.s   mt_arpeggio4
                addq.l  #2,A0
                dbra    D7,mt_arploop
                rts

mt_arpeggio2:   move.w  n_period(A6),D2
;       BRA     mt_Arpeggio4

mt_arpeggio4:   move.w  D2,6(A5)
                rts

mt_fineportaup: tst.b   mt_counter
                bne.s   mt_return2
                move.b  #$0F,mt_lowmask

mt_portaup:     moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   mt_lowmask(PC),D0
                move.b  #$FF,mt_lowmask
                sub.w   D0,n_period(A6)
                move.w  n_period(A6),D0
                and.w   #$0FFF,D0
                cmp.w   #113,D0
                bpl.s   mt_portauskip
                andi.w  #$F000,n_period(A6)
                ori.w   #113,n_period(A6)

mt_portauskip:  move.w  n_period(A6),D0
                and.w   #$0FFF,D0
                move.w  D0,6(A5)
                rts

mt_fineportadown:tst.b  mt_counter
                bne     mt_return2
                move.b  #$0F,mt_lowmask

mt_portadown:   clr.w   D0
                move.b  n_cmdlo(A6),D0
                and.b   mt_lowmask(PC),D0
                move.b  #$FF,mt_lowmask
                add.w   D0,n_period(A6)
                move.w  n_period(A6),D0
                and.w   #$0FFF,D0
                cmp.w   #856,D0
                bmi.s   mt_portadskip
                andi.w  #$F000,n_period(A6)
                ori.w   #856,n_period(A6)

mt_portadskip:  move.w  n_period(A6),D0
                and.w   #$0FFF,D0
                move.w  D0,6(A5)
                rts

mt_settoneporta:move.l  A0,-(SP)
                move.w  (A6),D2
                and.w   #$0FFF,D2
                moveq   #0,D0
                move.b  n_finetune(A6),D0
                mulu    #37*2,D0
                lea     mt_periodtable(PC),A0
                adda.l  D0,A0
                moveq   #0,D0

mt_stploop:     cmp.w   0(A0,D0.w),D2
                bhs.s   mt_stpfound
                addq.w  #2,D0
                cmp.w   #37*2,D0
                blo.s   mt_stploop
                moveq   #35*2,D0

mt_stpfound:    move.b  n_finetune(A6),D2
                and.b   #8,D2
                beq.s   mt_stpgoss
                tst.w   D0
                beq.s   mt_stpgoss
                subq.w  #2,D0

mt_stpgoss:     move.w  0(A0,D0.w),D2
                movea.l (SP)+,A0
                move.w  D2,n_wantedperiod(A6)
                move.w  n_period(A6),D0
                clr.b   n_toneportdirec(A6)
                cmp.w   D0,D2
                beq.s   mt_cleartoneporta
                bge     mt_return2
                move.b  #1,n_toneportdirec(A6)
                rts

mt_cleartoneporta:clr.w n_wantedperiod(A6)
                rts

mt_toneportamento:move.b n_cmdlo(A6),D0
                beq.s   mt_toneportnochange
                move.b  D0,n_toneportspeed(A6)
                clr.b   n_cmdlo(A6)

mt_toneportnochange:tst.w n_wantedperiod(A6)
                beq     mt_return2
                moveq   #0,D0
                move.b  n_toneportspeed(A6),D0
                tst.b   n_toneportdirec(A6)
                bne.s   mt_toneportaup

mt_toneportadown:add.w  D0,n_period(A6)
                move.w  n_wantedperiod(A6),D0
                cmp.w   n_period(A6),D0
                bgt.s   mt_toneportasetper
                move.w  n_wantedperiod(A6),n_period(A6)
                clr.w   n_wantedperiod(A6)
                bra.s   mt_toneportasetper

mt_toneportaup: sub.w   D0,n_period(A6)
                move.w  n_wantedperiod(A6),D0
                cmp.w   n_period(A6),D0
                blt.s   mt_toneportasetper
                move.w  n_wantedperiod(A6),n_period(A6)
                clr.w   n_wantedperiod(A6)

mt_toneportasetper:move.w n_period(A6),D2
                move.b  n_glissfunk(A6),D0
                and.b   #$0F,D0
                beq.s   mt_glissskip
                moveq   #0,D0
                move.b  n_finetune(A6),D0
                mulu    #36*2,D0
                lea     mt_periodtable(PC),A0
                adda.l  D0,A0
                moveq   #0,D0

mt_glissloop:   cmp.w   0(A0,D0.w),D2
                bhs.s   mt_glissfound
                addq.w  #2,D0
                cmp.w   #36*2,D0
                blo.s   mt_glissloop
                moveq   #35*2,D0

mt_glissfound:  move.w  0(A0,D0.w),D2

mt_glissskip:   move.w  D2,6(A5)        ; Set period
                rts

mt_vibrato:     move.b  n_cmdlo(A6),D0
                beq.s   mt_vibrato2
                move.b  n_vibratocmd(A6),D2
                and.b   #$0F,D0
                beq.s   mt_vibskip
                and.b   #$F0,D2
                or.b    D0,D2

mt_vibskip:     move.b  n_cmdlo(A6),D0
                and.b   #$F0,D0
                beq.s   mt_vibskip2
                and.b   #$0F,D2
                or.b    D0,D2

mt_vibskip2:    move.b  D2,n_vibratocmd(A6)

mt_vibrato2:    move.b  n_vibratopos(A6),D0
                lea     mt_vibratotable(PC),A4
                lsr.w   #2,D0
                and.w   #$001F,D0
                moveq   #0,D2
                move.b  n_wavecontrol(A6),D2
                and.b   #$03,D2
                beq.s   mt_vib_sine
                lsl.b   #3,D0
                cmp.b   #1,D2
                beq.s   mt_vib_rampdown
                move.b  #255,D2
                bra.s   mt_vib_set

mt_vib_rampdown:tst.b   n_vibratopos(A6)
                bpl.s   mt_vib_rampdown2
                move.b  #255,D2
                sub.b   D0,D2
                bra.s   mt_vib_set

mt_vib_rampdown2:move.b D0,D2
                bra.s   mt_vib_set

mt_vib_sine:    move.b  0(A4,D0.w),D2

mt_vib_set:     move.b  n_vibratocmd(A6),D0
                and.w   #15,D0
                mulu    D0,D2
                lsr.w   #6,D2
                move.w  n_period(A6),D0
                tst.b   n_vibratopos(A6)
                bmi.s   mt_vibratoneg
                add.w   D2,D0
                bra.s   mt_vibrato3

mt_vibratoneg:  sub.w   D2,D0

mt_vibrato3:    move.w  D0,6(A5)
                move.b  n_vibratocmd(A6),D0
                lsr.w   #2,D0
                and.w   #$003C,D0
                add.b   D0,n_vibratopos(A6)
                rts

mt_toneplusvolslide:bsr mt_toneportnochange
                bra     mt_volumeslide

mt_vibratoplusvolslide:bsr mt_vibrato2
                bra     mt_volumeslide

mt_tremolo:     move.b  n_cmdlo(A6),D0
                beq.s   mt_tremolo2
                move.b  n_tremolocmd(A6),D2
                and.b   #$0F,D0
                beq.s   mt_treskip
                and.b   #$F0,D2
                or.b    D0,D2

mt_treskip:     move.b  n_cmdlo(A6),D0
                and.b   #$F0,D0
                beq.s   mt_treskip2
                and.b   #$0F,D2
                or.b    D0,D2

mt_treskip2:    move.b  D2,n_tremolocmd(A6)

mt_tremolo2:    move.b  n_tremolopos(A6),D0
                lea     mt_vibratotable(PC),A4
                lsr.w   #2,D0
                and.w   #$001F,D0
                moveq   #0,D2
                move.b  n_wavecontrol(A6),D2
                lsr.b   #4,D2
                and.b   #$03,D2
                beq.s   mt_tre_sine
                lsl.b   #3,D0
                cmp.b   #1,D2
                beq.s   mt_tre_rampdown
                move.b  #255,D2
                bra.s   mt_tre_set

mt_tre_rampdown:tst.b   n_vibratopos(A6)
                bpl.s   mt_tre_rampdown2
                move.b  #255,D2
                sub.b   D0,D2
                bra.s   mt_tre_set

mt_tre_rampdown2:move.b D0,D2
                bra.s   mt_tre_set

mt_tre_sine:    move.b  0(A4,D0.w),D2

mt_tre_set:     move.b  n_tremolocmd(A6),D0
                and.w   #15,D0
                mulu    D0,D2
                lsr.w   #6,D2
                moveq   #0,D0
                move.b  n_volume(A6),D0
                tst.b   n_tremolopos(A6)
                bmi.s   mt_tremoloneg
                add.w   D2,D0
                bra.s   mt_tremolo3

mt_tremoloneg:  sub.w   D2,D0

mt_tremolo3:    bpl.s   mt_tremoloskip
                clr.w   D0

mt_tremoloskip: cmp.w   #$0040,D0
                bls.s   mt_tremolook
                move.w  #$0040,D0

mt_tremolook:   move.w  D0,8(A5)
                move.b  n_tremolocmd(A6),D0
                lsr.w   #2,D0
                and.w   #$003C,D0
                add.b   D0,n_tremolopos(A6)
                rts

mt_sampleoffset:moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                beq.s   mt_sononew
                move.b  D0,n_sampleoffset(A6)

mt_sononew:     move.b  n_sampleoffset(A6),D0
                lsl.w   #7,D0
                cmp.w   n_length(A6),D0
                bge.s   mt_sofskip
                sub.w   D0,n_length(A6)
                lsl.w   #1,D0
                add.l   D0,n_start(A6)
                rts

mt_sofskip:     move.w  #$0001,n_length(A6)
                rts

mt_volumeslide: moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                lsr.b   #4,D0
                tst.b   D0
                beq     mt_volslidedown

mt_volslideup:  add.b   D0,n_volume(A6)
                cmpi.b  #$40,n_volume(A6)
                bmi.s   mt_vsuskip
                move.b  #$40,n_volume(A6)

mt_vsuskip:     move.b  n_volume(A6),D0
                move.w  D0,8(A5)
                rts

mt_volslidedown:moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0

mt_volslidedown2:sub.b  D0,n_volume(A6)
                bpl.s   mt_vsdskip
                clr.b   n_volume(A6)

mt_vsdskip:     move.b  n_volume(A6),D0
                move.w  D0,8(A5)
                rts

mt_positionjump:move.b  n_cmdlo(A6),D0
                subq.b  #1,D0
                move.b  D0,mt_songpos
mt_pj2:         clr.b   mt_pbreakpos
                st      mt_posjumpflag
                rts

mt_volumechange:moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                cmp.b   #$40,D0
                bls.s   mt_volumeok
                moveq   #$40,D0

mt_volumeok:    move.b  D0,n_volume(A6)
                move.w  D0,8(A5)
                rts

mt_patternbreak:moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                move.l  D0,D2
                lsr.b   #4,D0
                mulu    #10,D0
                and.b   #$0F,D2
                add.b   D2,D0
                cmp.b   #63,D0
                bhi.s   mt_pj2
                move.b  D0,mt_pbreakpos
                st      mt_posjumpflag
                rts

mt_setspeed:    move.b  3(A6),D0
                beq     mt_return2
                clr.b   mt_counter
                move.b  D0,mt_speed
                rts

mt_checkmoreefx:bsr     mt_updatefunk
                move.b  2(A6),D0
                and.b   #$0F,D0
                cmp.b   #$09,D0
                beq     mt_sampleoffset
                cmp.b   #$0B,D0
                beq     mt_positionjump
                cmp.b   #$0D,D0
                beq.s   mt_patternbreak
                cmp.b   #$0E,D0
                beq.s   mt_e_commands
                cmp.b   #$0F,D0
                beq.s   mt_setspeed
                cmp.b   #$0C,D0
                beq     mt_volumechange
                rts

mt_e_commands:  move.b  n_cmdlo(A6),D0
                and.b   #$F0,D0
                lsr.b   #4,D0
                beq.s   mt_filteronoff
                cmp.b   #1,D0
                beq     mt_fineportaup
                cmp.b   #2,D0
                beq     mt_fineportadown
                cmp.b   #3,D0
                beq.s   mt_setglisscontrol
                cmp.b   #4,D0
                beq     mt_setvibratocontrol
                cmp.b   #5,D0
                beq     mt_setfinetune
                cmp.b   #6,D0
                beq     mt_jumploop
                cmp.b   #7,D0
                beq     mt_settremolocontrol
                cmp.b   #9,D0
                beq     mt_retrignote
                cmp.b   #$0A,D0
                beq     mt_volumefineup
                cmp.b   #$0B,D0
                beq     mt_volumefinedown
                cmp.b   #$0C,D0
                beq     mt_notecut
                cmp.b   #$0D,D0
                beq     mt_notedelay
                cmp.b   #$0E,D0
                beq     mt_patterndelay
                cmp.b   #$0F,D0
                beq     mt_funkit
                rts

mt_filteronoff: move.b  n_cmdlo(A6),D0
                and.b   #1,D0
                asl.b   #1,D0
                andi.b  #$FD,ft_filter
                or.b    D0,ft_filter
                rts

mt_setglisscontrol:move.b n_cmdlo(A6),D0
                and.b   #$0F,D0
                andi.b  #$F0,n_glissfunk(A6)
                or.b    D0,n_glissfunk(A6)
                rts

mt_setvibratocontrol:move.b n_cmdlo(A6),D0
                and.b   #$0F,D0
                andi.b  #$F0,n_wavecontrol(A6)
                or.b    D0,n_wavecontrol(A6)
                rts

mt_setfinetune: move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                move.b  D0,n_finetune(A6)
                rts

mt_jumploop:    tst.b   mt_counter
                bne     mt_return2
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                beq.s   mt_setloop
                tst.b   n_loopcount(A6)
                beq.s   mt_jumpcnt
                subi.b  #1,n_loopcount(A6)
                beq     mt_return2
mt_jmploop:     move.b  n_pattpos(A6),mt_pbreakpos
                st      mt_pbreakflag
                rts

mt_jumpcnt:     move.b  D0,n_loopcount(A6)
                bra.s   mt_jmploop

mt_setloop:     move.w  mt_patternpos(PC),D0
                lsr.w   #4,D0
                move.b  D0,n_pattpos(A6)
                rts

mt_settremolocontrol:move.b n_cmdlo(A6),D0
                and.b   #$0F,D0
                lsl.b   #4,D0
                andi.b  #$0F,n_wavecontrol(A6)
                or.b    D0,n_wavecontrol(A6)
                rts

mt_retrignote:  move.l  D1,-(SP)
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                beq.s   mt_rtnend
                moveq   #0,D1
                move.b  mt_counter(PC),D1
                bne.s   mt_rtnskp
                move.w  n_note(A6),D1
                and.w   #$0FFF,D1
                bne.s   mt_rtnend
                moveq   #0,D1
                move.b  mt_counter(PC),D1

mt_rtnskp:      divu    D0,D1
                swap    D1
                tst.w   D1
                bne     mt_rtnend

mt_doretrig:    move.w  n_dmabit(A6),D7 ; Channel DMA off
                bsr     ft_set_dma
                move.l  n_start(A6),(A5) ; Set sampledata pointer
                move.w  n_length(A6),4(A5) ; Set length
                move.w  n_dmabit(A6),D7
                ori.w   #$8000,D7
                bsr     ft_set_dma
                bsr     ft_set_adds
                move.l  n_loopstart(A6),(A5)
                move.l  n_replen(A6),4(A5)

mt_rtnend:      move.l  (SP)+,D1
                rts

mt_volumefineup:tst.b   mt_counter
                bne     mt_return2
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                bra     mt_volslideup

mt_volumefinedown:tst.b mt_counter
                bne     mt_return2
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                bra     mt_volslidedown2

mt_notecut:     moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                cmp.b   mt_counter(PC),D0
                bne     mt_return2
                clr.b   n_volume(A6)
                move.w  #0,8(A5)
                rts

mt_notedelay:   moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                cmp.b   mt_counter,D0
                bne     mt_return2
                move.w  (A6),D0
                beq     mt_return2
                move.l  D1,-(SP)
                bra     mt_doretrig

mt_patterndelay:tst.b   mt_counter
                bne     mt_return2
                moveq   #0,D0
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                tst.b   mt_pattdeltime2
                bne     mt_return2
                addq.b  #1,D0
                move.b  D0,mt_pattdeltime
                rts

mt_funkit:      tst.b   mt_counter
                bne     mt_return2
                move.b  n_cmdlo(A6),D0
                and.b   #$0F,D0
                lsl.b   #4,D0
                andi.b  #$0F,n_glissfunk(A6)
                or.b    D0,n_glissfunk(A6)
                tst.b   D0
                beq     mt_return2

mt_updatefunk:  movem.l D1-D2/A0,-(SP)
                moveq   #0,D0
                move.b  n_glissfunk(A6),D0
                lsr.b   #4,D0
                beq.s   mt_funkend
                lea     mt_funktable(PC),A0
                move.b  0(A0,D0.w),D0
                add.b   D0,n_funkoffset(A6)
                btst    #7,n_funkoffset(A6)
                beq.s   mt_funkend
                clr.b   n_funkoffset(A6)

                move.l  n_start(A6),D1
                moveq   #0,D2
                move.w  n_reallength(A6),D2
                lsl.w   #1,D2
                add.l   D2,D1
                move.w  n_replen(A6),D2
                lsl.l   #1,D2
                sub.l   D2,D1

                move.l  n_wavestart(A6),D2
                moveq   #0,D0
                move.w  n_replen(A6),D0
                lsl.l   #1,D0
                add.l   D0,D2
                cmp.l   D1,D2
                bls.s   mt_funkok
                move.l  n_loopstart(A6),D2

mt_funkok:      move.l  D2,n_wavestart(A6)
                move.l  D2,(A5)

mt_funkend:     movem.l (SP)+,D1-D2/A0
                rts

mt_funktable:   DC.B 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mt_vibratotable:DC.B 0,24,49,74,97,120,141,161
                DC.B 180,197,212,224,235,244,250,253
                DC.B 255,253,250,244,235,224,212,197
                DC.B 180,161,141,120,97,74,49,24
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mt_periodtable:                         ; Tuning 0, Normal
                DC.W 856,808,762,720,678,640,604,570,538,508,480,453
                DC.W 428,404,381,360,339,320,302,285,269,254,240,226
                DC.W 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
                DC.W 850,802,757,715,674,637,601,567,535,505,477,450
                DC.W 425,401,379,357,337,318,300,284,268,253,239,225
                DC.W 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
                DC.W 844,796,752,709,670,632,597,563,532,502,474,447
                DC.W 422,398,376,355,335,316,298,282,266,251,237,224
                DC.W 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
                DC.W 838,791,746,704,665,628,592,559,528,498,470,444
                DC.W 419,395,373,352,332,314,296,280,264,249,235,222
                DC.W 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
                DC.W 832,785,741,699,660,623,588,555,524,495,467,441
                DC.W 416,392,370,350,330,312,294,278,262,247,233,220
                DC.W 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
                DC.W 826,779,736,694,655,619,584,551,520,491,463,437
                DC.W 413,390,368,347,328,309,292,276,260,245,232,219
                DC.W 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
                DC.W 820,774,730,689,651,614,580,547,516,487,460,434
                DC.W 410,387,365,345,325,307,290,274,258,244,230,217
                DC.W 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
                DC.W 814,768,725,684,646,610,575,543,513,484,457,431
                DC.W 407,384,363,342,323,305,288,272,256,242,228,216
                DC.W 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
                DC.W 907,856,808,762,720,678,640,604,570,538,508,480
                DC.W 453,428,404,381,360,339,320,302,285,269,254,240
                DC.W 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
                DC.W 900,850,802,757,715,675,636,601,567,535,505,477
                DC.W 450,425,401,379,357,337,318,300,284,268,253,238
                DC.W 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
                DC.W 894,844,796,752,709,670,632,597,563,532,502,474
                DC.W 447,422,398,376,355,335,316,298,282,266,251,237
                DC.W 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
                DC.W 887,838,791,746,704,665,628,592,559,528,498,470
                DC.W 444,419,395,373,352,332,314,296,280,264,249,235
                DC.W 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
                DC.W 881,832,785,741,699,660,623,588,555,524,494,467
                DC.W 441,416,392,370,350,330,312,294,278,262,247,233
                DC.W 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
                DC.W 875,826,779,736,694,655,619,584,551,520,491,463
                DC.W 437,413,390,368,347,328,309,292,276,260,245,232
                DC.W 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
                DC.W 868,820,774,730,689,651,614,580,547,516,487,460
                DC.W 434,410,387,365,345,325,307,290,274,258,244,230
                DC.W 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
                DC.W 862,814,768,725,684,646,610,575,543,513,484,457
                DC.W 431,407,384,363,342,323,305,288,272,256,242,228
                DC.W 216,203,192,181,171,161,152,144,136,128,121,114
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mt_chan1temp:   DC.L 0,0,0,0,0,$00010000,0,0,0,0,0
mt_chan2temp:   DC.L 0,0,0,0,0,$00020000,0,0,0,0,0
mt_chan3temp:   DC.L 0,0,0,0,0,$00040000,0,0,0,0,0
mt_chan4temp:   DC.L 0,0,0,0,0,$00080000,0,0,0,0,0
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mt_samplestarts:DC.L 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.L 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
mt_songdataptr: DC.L 0
mt_speed:       DC.B 6
mt_counter:     DC.B 0
mt_songpos:     DC.B 0
mt_pbreakpos:   DC.B 0
mt_posjumpflag: DC.B 0
mt_pbreakflag:  DC.B 0
mt_lowmask:     DC.B 0
mt_pattdeltime: DC.B 0
mt_pattdeltime2:DC.B 0
                DC.B 0

mt_patternpos:  DC.W 0
mt_dmacontemp:  DC.W 0
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
**  Could be taken to your BSS-Segment  **
******************************************
ft_bss:
ft_variables:                           ; 'Variables'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
ft_oldsave:     DS.L 1
                DS.L 24
ft_newsave:     DS.L 24
ft_sam_adds:    DS.L 31
ft_rep_adds:    DS.L 31
ft_rep_lens:    DS.L 31
ft_lockflag:    DS.W 1
ft_oldadd:      DS.W 1
ft_oldplaymode: DS.W 1
ft_sndstart1:   DS.L 1
ft_sndstart2:   DS.L 1
ft_sndend1:     DS.L 1
ft_sndend2:     DS.L 1
mt_data:        DS.L 1
ft_voladd:      DS.L 1
ft_samstart_a:  DS.L 1                  ; Sampleadresses of channel
ft_samlength_a: DS.W 1                  ; Length of actual sample in WORDS
ft_samper_a:    DS.W 1                  ; AMIGA-periods(1-1000)
ft_samvol_a:    DS.W 1                  ; Volume of actual sample (0-64)
ft_samstart_b:  DS.L 1                  ; Sampleadresses of channel
ft_samlength_b: DS.W 1                  ; Length of actual sample in WORDS
ft_samper_b:    DS.W 1                  ; AMIGA-periods(1-1000)
ft_samvol_b:    DS.W 1                  ; Volume of actual sample (0-64)
ft_samstart_c:  DS.L 1                  ; Sampleadresses of channel
ft_samlength_c: DS.W 1                  ; Length of actual sample in WORDS
ft_samper_c:    DS.W 1                  ; AMIGA-periods(1-1000)
ft_samvol_c:    DS.W 1                  ; Volume of actual sample (0-64)
ft_samstart_d:  DS.L 1                  ; Sampleadresses of channel
ft_samlength_d: DS.W 1                  ; Length of actual sample in WORDS
ft_samper_d:    DS.W 1                  ; AMIGA-periods(1-1000)
ft_samvol_d:    DS.W 1                  ; Volume of actual sample (0-64)
ft_ch_dma:      DS.W 1                  ; bit 0 = 1 => Channel A enable etc.
ft_int_dma:     DS.W 1
ft_samcount_a:  DS.L 1                  ; Intern counter
ft_samcount_b:  DS.L 1
ft_samcount_c:  DS.L 1
ft_samcount_d:  DS.L 1
ft_sampoint_a:  DS.W 1                  ; Real part of counter
ft_sampoint_b:  DS.W 1
ft_sampoint_c:  DS.W 1
ft_sampoint_d:  DS.W 1
ft_samend_a:    DS.L 1                  ; Intern sampleendadress
ft_samend_b:    DS.L 1
ft_samend_c:    DS.L 1
ft_samend_d:    DS.L 1
ft_intper_a:    DS.W 1
ft_intper_b:    DS.W 1
ft_intper_c:    DS.W 1
ft_intper_d:    DS.W 1
ft_flag_a:      DS.W 1
ft_flag_b:      DS.W 1
ft_flag_c:      DS.W 1
ft_flag_d:      DS.W 1
ft_filter:      DS.W 1                  ; Dummy
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
ft_volumes:     DS.W 256                ; 'Volumetables'
                DS.W 16640
ft_frequencies: DS.L 1000               ; 'Frequencytable'
ft_no_noise:    DS.B 1000               ; 'Silence buffer'
ft_soundbuff:   DS.L 656                ; 'Playbuffer1'
ft_buffend:
ft_soundbuff2:  DS.L 656                ; 'Playbuffer2'
ft_buffend2:
ft_end:         END
