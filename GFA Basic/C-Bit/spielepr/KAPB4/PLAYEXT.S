********************************
;	Das GerÅst zu diesem
;	Listing stammt von 
;	CHECKSUM von EQUINOX 11.03.90
	
;	Verbesserungen wie LautstÑrke
;	und Optimierungen sowie
;	Ausgabe auf den Druckerport
;	fÅr Druckerportsampler
;	wurden von Kay Rîmer und
;	Klaus Dieter Pollack vorgenommen

                EXPORT  PLAY

                TEXT
PLAY:           movem.l D0-A6,-(SP)
                movea.l A0,A6
                clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                move.l  D0,2(SP)
                clr.b   $FFFFFA09.w
                movea.l A6,A0
                bsr     mt_init

                lea     $FFFF8800.w,A6
                bsr.s   init_50Hz
                lea     VOLUME(PC),A0

key_wait:       cmpi.b  #$39,$FFFFFC02.w
                bne.s   key_wait
                move    #$2700,SR 

                bsr.s   exit_50Hz

                bsr.w   mt_end
                move.b  #$64,$FFFFFA09.w
                move    #$2300,SR
                move.w  #4000,D0
mfp_wait:       move.b  $FFFFFC02.w,D1
                dbra    D0,mfp_wait
                trap    #1
                addq.l  #6,SP
                movem.l (SP)+,D0-A6
                move.w  mt_cool+2(PC),D0
                rts
                
 init_50Hz:     move.b  #7,$FFFFFA1B.w
                move.b  #245,$FFFFFA21.w
                bset    #0,$FFFFFA07.w
                bset    #0,$FFFFFA13.w
                lea     vbl(PC),A0
                move.l  A0,$120.w
                move    #$2500,SR
                rts
                
exit_50Hz:      clr.b   $FFFFFA1B.w
                andi.b  #$FE,$FFFFFA07.w
                andi.b  #$FE,$FFFFFA13.w
                rts

vbl:            *move   #$2400,SR
                bsr.w   mt_music
                rte

level1:        DS.W  1
level2:        DS.W  1
level3:        DS.W  1
level4:        DS.W  1

mt_init:
                lea     mt_data(PC),A1
                move.l  A0,(A1)
                move.l  #472,D0
                move.l  #600,D1
                cmpi.l  #$4D2E4B2E,1080(A0)
                bne.s   mt_oldversion
                move.l  #$03B8,D0
                move.l  #$043C,D1
mt_oldversion:
                lea     mt_nbr1(PC),A1
                move.l  D0,2(A1)
                lea     mt_nbr2(PC),A1
                move.l  D1,2(A1)
                lea     mt_nbr3(PC),A1
                move.l  D0,2(A1)
                lea     mt_nbr4(PC),A1
                move.l  D1,2(A1)
                adda.l  D0,A0
                moveq   #$7F,D0
                moveq   #0,D1
mt_init1:
                move.l  D1,D2
                subq.w  #1,D0
mt_init2:
                move.b  (A0)+,D1
                cmp.b   D2,D1
                bgt.s   mt_init1
                dbra    D0,mt_init2
                addq.b  #1,D2

mt_init3:
                movea.l mt_data(PC),A0
                lea     mt_sample1(PC),A1
                asl.l   #8,D2
                asl.l   #2,D2
mt_nbr4:        add.l   #$12345678,D2
                add.l   A0,D2
                moveq   #30,D0
mt_init4:
                move.l  D2,(A1)+
                moveq   #0,D1
                move.w  42(A0),D1
                asl.l   #1,D1
                add.l   D1,D2
                adda.l  #30,A0
                dbra    D0,mt_init4
                movea.l D2,A1
                movea.l mt_sample1(PC),A0
mt_init5:
                eori.b  #128,(A0)
                tst.b   (A0)
                bne.s   mt_init6
                addq.b  #1,(A0)
mt_init6:
                addq.l  #1,A0
                cmpa.l  A0,A1
                bgt.s   mt_init5
                lea     mt_sample1(PC),A0
                moveq   #4,D0
mt_clear:
                movea.l 0(A0,D0.w),A1
                clr.l   -4(A1)
                addq.w  #4,D0
                cmp.w   #$7C,D0
                bne.s   mt_clear
                move    #$2700,SR
                lea     $FFFF8800.w,A0
                moveq   #10,D0
mt_yamahaclear:
                move.b  D0,(A0)
                clr.b   2(A0)
                dbra    D0,mt_yamahaclear
                clr.b   (A0)
                clr.b   2(A0)
                move.b  #7,(A0)
                move.b  #$FF,2(A0)
                move.b  #$02,$FFFA19
                move.b  #18,$FFFA1F
                bclr    #3,$FFFA17
                bset    #5,$FFFA07
                bset    #5,$FFFA13
                lea     denise(PC),A0
                move.l  A0,$0134.w
                lea     mt_partnrplay(PC),A0
                clr.l   (A0)+
                clr.l   (A0)+
                clr.l   (A0)+
                clr.w   (A0)
                lea     mt_cool(PC),A0
                move.w  #6,2(A0)
                movea.l mt_data(PC),A0
mt_nbr3:        adda.l  #$12345678,A0
                lea     mt_maxpart(PC),A1
                move.b  -2(A0),1(A1)
                lea     mt_cool(PC),A0
                move.b  #6,3(A0)
                move.b  $FB0001,D7
                lea     no_noise(PC),A2
                lea     voice1(PC),A3
                lea     voice2(PC),A4
                lea     voice3(PC),A5
                lea     voice4(PC),A6
                move.l  A2,16(A3)
                move.l  A2,16(A4)
                move.l  A2,16(A5)
                move.l  A2,16(A6)
                movea.l A2,A3
                movea.l A3,A4
                movea.l A4,A5
                moveq   #0,D2
                moveq   #0,D3
                moveq   #0,D4
                moveq   #0,D5
                lea     $FA0000,A6
                lea     mt_selection(PC),A0
                moveq   #0,D6
                move.b  D7,D6
                and.b   #$F0,D6
                cmp.b   #$70,D6
                bne.s   mt_testbat
                move.w  #$601A,(A0)
                rts
mt_testbat:
                cmp.b   #$FF,D7
                beq.s   mt_monitor_outpout
                move.w  #$6024,(A0)
                rts
mt_monitor_outpout:
                move.w  #$0246,(A0)
                rts

mt_end:
                bset    #3,$FFFA17
                andi.b  #$DF,$FFFA07
                andi.b  #$DF,$FFFA13
                rts

; now the playroutine ! call it every vbl.

mt_music:
                movem.l D0-D1/A0-A1,-(SP)
                lea     mt_counter(PC),A0
                addq.w  #1,(A0)
mt_cool:
                cmpi.w  #6,(A0)
                bne.s   mt_notsix
                clr.w   (A0)
                bra.w   mt_rout2

mt_notsix:
                lea     mt_aud1temp(PC),A1
                tst.b   3(A1)
                beq.s   mt_arp1
                lea     voice1(PC),A0
                bsr.s   mt_arprout
mt_arp1:
                lea     mt_aud2temp(PC),A1
                tst.b   3(A1)
                beq.s   mt_arp2
                lea     voice2(PC),A0
                bsr.s   mt_arprout
mt_arp2:
                lea     mt_aud3temp(PC),A1
                tst.b   3(A1)
                beq.s   mt_arp3
                lea     voice3(PC),A0
                bsr.s   mt_arprout
mt_arp3:
                lea     mt_aud4temp(PC),A1
                tst.b   3(A1)
                beq.s   mt_arp4
                lea     voice4(PC),A0
                bsr.s   mt_arprout
mt_arp4:
                movem.l (SP)+,D0-D1/A0-A1
                rts


mt_arprout:
                move.b  2(A1),D0
                and.b   #$0F,D0
                tst.b   D0
                beq     mt_arpegrt
                cmp.b   #1,D0
                beq     mt_portup
                cmp.b   #2,D0
                beq     mt_portdown
                rts


mt_portup:
                moveq   #0,D0
                move.b  3(A1),D0
                sub.w   D0,22(A1)
                cmpi.w  #$71,22(A1)
                bpl.s   mt_ok1
                move.w  #$71,22(A1)
mt_ok1:         move.w  22(A1),D0
                lea     mt_frequences(PC),A1
                asl.l   #2,D0
                move.l  0(A1,D0.w),2(A0)
                rts

mt_portdown:
                moveq   #0,D0
                move.b  3(A1),D0
                add.w   D0,22(A1)
                cmpi.w  #$0358,22(A1)
                bmi.s   mt_ok2
                move.w  #$0358,22(A1)
mt_ok2:         bra.w   mt_ok1


mt_arpegrt:
                move.w  mt_counter(PC),D0
                cmp.w   #1,D0
                beq.s   mt_loop2
                cmp.w   #2,D0
                beq.s   mt_loop3
                cmp.w   #3,D0
                beq.s   mt_loop4
                cmp.w   #4,D0
                beq.s   mt_loop2
                cmp.w   #5,D0
                beq.s   mt_loop3
                rts

mt_loop2:
                moveq   #0,D0
                move.b  3(A1),D0
                lsr.b   #4,D0
                bra.s   mt_cont
mt_loop3:
                moveq   #0,D0
                move.b  3(A1),D0
                and.b   #$0F,D0
                bra.s   mt_cont
mt_loop4:
                moveq   #0,D1
                move.w  16(A1),D1
                bra.s   mt_endpart
mt_cont:
                add.w   D0,D0
                moveq   #0,D1
                move.w  16(A1),D1
                and.w   #$0FFF,D1
                lea     mt_arpeggio(PC),A1
mt_loop5:
                cmp.w   (A1),D1
                beq.s   loop5_exit
                addq.l  #2,A1
                bra.s   mt_loop5
loop5_exit:
                move.w  0(A1,D0.w),D1
mt_endpart:
                lea     mt_frequences(PC),A1
                asl.l   #2,D1
                move.l  0(A1,D1.w),2(A0)
                rts

mt_rout2:
                movea.l mt_data(PC),A0
                lea     mt_soundpref(PC),A1
                move.l  A0,(A1)
                addi.l  #42,(A1)
                movea.l A0,A1
mt_nbr1:        adda.l  #$12345678,A1
mt_nbr2:        adda.l  #$12345678,A0
                move.l  A1,-(SP)
                lea     mt_firstpattern(PC),A1
                move.l  A0,(A1)
                movea.l (SP)+,A1
                moveq   #0,D1
                move.l  mt_partnrplay(PC),D0
                move.b  0(A1,D0.w),D1
                asl.l   #8,D1
                asl.l   #2,D1
                add.l   mt_partnote(PC),D1
                lea     mt_aud1temp(PC),A1
                bsr.w   mt_playit
                lea     mt_aud2temp(PC),A1
                move.l  mt_currentpos(PC),D1
                bsr.w   mt_playit
                lea     mt_aud3temp(PC),A1
                move.l  mt_currentpos(PC),D1
                bsr.w   mt_playit
                lea     mt_aud4temp(PC),A1
                move.l  mt_currentpos(PC),D1
                bsr.w   mt_playit
                move    #$2700,SR
mt_voice1:
                lea     voice1(PC),A0
                lea     mt_aud1temp(PC),A1
; here is for setting volume
                move.b  25(A1),27(A0)


                tst.w   (A1)
                beq.s   mt_voice2
; here is for equa inf

                move.l  A0,-(SP)
                lea     level1(PC),A0
                move.w  18(A1),(A0)
                movea.l (SP)+,A0
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                move.w  D0,16(A1)
                move.w  D0,22(A1)
                movea.l 4(A1),A2
                moveq   #0,D2
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                asl.l   #2,D0
                move.l  A1,-(SP)
                lea     mt_frequences(PC),A1
                move.l  0(A1,D0.w),2(A0)
                movea.l (SP)+,A1
                tst.w   14(A1)
                beq.s   mt_norepeat1
                move.l  10(A1),16(A0)
                bra.s   mt_voice2
mt_norepeat1:
                lea     no_noise(PC),A1
                move.l  A1,16(A0)
mt_voice2:
                lea     voice2(PC),A0
                lea     mt_aud2temp(PC),A1
; here is for setting volume
                move.b  25(A1),27(A0)


                tst.w   (A1)
                beq.s   mt_voice3
; here is for equa inf
                move.l  A0,-(SP)
                lea     level2(PC),A0
                move.w  18(A1),(A0)
                movea.l (SP)+,A0
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                move.w  D0,16(A1)
                move.w  D0,22(A1)
                movea.l 4(A1),A3
                moveq   #0,D3
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                asl.l   #2,D0
                move.l  A1,-(SP)
                lea     mt_frequences(PC),A1
                move.l  0(A1,D0.w),2(A0)
                movea.l (SP)+,A1
                tst.w   14(A1)
                beq.s   mt_norepeat2
                move.l  10(A1),16(A0)
                bra.s   mt_voice3
mt_norepeat2:
                lea     no_noise(PC),A1
                move.l  A1,16(A0)
mt_voice3:
                lea     voice3(PC),A0
                lea     mt_aud3temp(PC),A1
; here is for setting volume
                move.b  25(A1),27(A0)


                tst.w   (A1)
                beq.s   mt_voice4
; here is for equa inf
                move.l  A0,-(SP)
                lea     level3(PC),A0
                move.w  18(A1),(A0)
                movea.l (SP)+,A0
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                move.w  D0,16(A1)
                move.w  D0,22(A1)
                movea.l 4(A1),A4
                moveq   #0,D4
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                asl.l   #2,D0
                move.l  A1,-(SP)
                lea     mt_frequences(PC),A1
                move.l  0(A1,D0.w),2(A0)
                movea.l (SP)+,A1
                tst.w   14(A1)
                beq.s   mt_norepeat3
                move.l  10(A1),16(A0)
                bra.s   mt_voice4
mt_norepeat3:
                lea     no_noise(PC),A1
                move.l  A1,16(A0)
mt_voice4:
                lea     voice4(PC),A0
                lea     mt_aud4temp(PC),A1
; here  is for setting volume
                move.b  25(A1),27(A0)


                tst.w   (A1)
                beq.s   mt_voice0
; here is for equa inf
                move.l  A0,-(SP)
                lea     level4(PC),A0
                move.w  18(A1),(A0)
                movea.l (SP)+,A0
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                move.w  D0,16(A1)
                move.w  D0,22(A1)
                movea.l 4(A1),A5
                moveq   #0,D5
                moveq   #0,D0
                move.w  (A1),D0
                and.w   #$0FFF,D0
                asl.l   #2,D0
                move.l  A1,-(SP)
                lea     mt_frequences(PC),A1
                move.l  0(A1,D0.w),2(A0)
                movea.l (SP)+,A1
                tst.w   14(A1)
                beq.s   mt_norepeat4
                move.l  10(A1),16(A0)
                bra.s   mt_voice0
mt_norepeat4:
                lea     no_noise(PC),A1
                move.l  A1,16(A0)
mt_voice0:
; here is for setting volume
                lea     denise+2(PC),A1
                move.w  #128*4,(A1)
                lea     VOLUME(PC),A0
                moveq   #0,D0
                moveq   #127,D1
                add.w   mt_aud1temp+24(PC),D1
                move.b  0(A0,D1.w),D0
                sub.w   D0,(A1)
                moveq   #127,D1
                add.w   mt_aud2temp+24(PC),D1
                move.b  0(A0,D1.w),D0
                sub.w   D0,(A1)
                moveq   #127,D1
                add.w   mt_aud3temp+24(PC),D1
                move.b  0(A0,D1.w),D0
                sub.w   D0,(A1)
                moveq   #127,D1
                add.w   mt_aud4temp+24(PC),D1
                move.b  0(A0,D1.w),D0
                sub.w   D0,(A1)

                *move   #$2400,SR
                lea     mt_partnote(PC),A0
                addi.l  #16,(A0)
                cmpi.l  #64*16,(A0)
                bne     mt_nonewpat
mt_higher:
                clr.l   (A0)
                lea     mt_partnrplay(PC),A0
                addq.l  #1,(A0)
                moveq   #0,D0
                move.w  mt_maxpart(PC),D0
                move.l  (A0),D1
                cmp.l   D0,D1
                bne.s   mt_nonewpat
                clr.l   (A0)
mt_nonewpat:
                lea     mt_status(PC),A0
                tst.w   (A0)
                beq.s   mt_stop
                clr.w   (A0)
                lea     mt_partnote(PC),A0
                bra.s   mt_higher
mt_stop:
                movem.l (SP)+,D0-D1/A0-A1
                rts


mt_playit:
                movea.l mt_firstpattern(PC),A0
                move.l  0(A0,D1.l),(A1)
                addq.l  #4,D1
                lea     mt_currentpos(PC),A0
                move.l  D1,(A0)
                moveq   #0,D1
                move.b  2(A1),D1
                lsr.b   #4,D1
                moveq   #0,D0
                move.b  (A1),D0
                and.b   #$F0,D0
                or.b    D0,D1
                tst.b   D1
                beq.w   mt_nosamplechange
                move.l  D1,D0
                asl.l   #2,D1
                subq.b  #1,D0
                mulu    #30,D0
                lea     mt_samples(PC),A0
                move.l  0(A0,D1.l),4(A1)
                movea.l mt_soundpref(PC),A0
                move.w  0(A0,D0.l),8(A1)
                tst.w   8(A1)
                bne.s   mt_sample_exist
                move.l  A0,-(SP)
                lea     no_noise(PC),A0
                move.l  A0,4(A1)
                movea.l (SP)+,A0
mt_sample_exist:
                moveq   #0,D1
                move.w  4(A0,D0.l),D1
                add.l   4(A1),D1
                move.l  D1,10(A1)
                move.w  6(A0,D0.l),14(A1)
                move.w  2(A0,D0.l),18(A1)
                cmpi.w  #1,14(A1)
                bne.w   mt_nosamplechange
                clr.w   14(A1)
mt_nosamplechange:
                moveq   #0,D0
                move.b  2(A1),D0
                and.w   #$0F,D0
                cmp.b   #$0B,D0
                beq.s   mt_posjmp
                cmp.b   #$0C,D0
                beq.s   mt_setvol
                cmp.b   #$0D,D0
                beq.s   mt_break
                cmp.b   #$0E,D0
                beq.s   mt_setfil
                cmp.b   #$0F,D0
                beq.s   mt_setspeed
                rts

mt_posjmp:
                lea     mt_status(PC),A0
                not.w   (A0)
                moveq   #0,D0
                move.b  3(A1),D0
                subq.b  #1,D0
                lea     mt_partnrplay(PC),A0
                move.l  D0,(A0)
                rts

mt_setvol:
; perhaps another time
                moveq   #0,D0
                move.b  3(A1),D0
                tst.b   D0
                bne.s   mt_vol
                lea     no_noise(PC),A0
                move.l  A0,4(A1)
                move.w  #1,(A1)
                rts

mt_vol:         lsl.b   #2,D0
                sub.b   #128,D0
                ext.w   D0
                move.w  D0,24(A1)
                rts

mt_break:
                lea     mt_status(PC),A0
                not.w   (A0)
                rts
mt_setfil:
; a filter ?? i would like have it !!!!
                rts

mt_setspeed:
                move.b  3(A1),D0
                and.b   #$0F,D0
                beq.s   mt_back
                lea     mt_counter(PC),A0
                clr.w   (A0)
                lea     mt_cool(PC),A0
                move.b  D0,3(A0)
mt_back:        rts



;this is the emulation of amiga sound processor !

denise:
                move.w  #$1234,D6       ; selbstmodif.
                moveq   #0,D7
voice1:         add.l   #$12345678,D2   ; selbstmodif.
                swap    D2
                move.b  0(A2,D2.w),D7
                bne.s   no_ini1
                lea     $12345678,A2    ; selbstmodif.
                moveq   #0,D2
                moveq   #$7F,D7
no_ini1:        move.b  124(A0,D7.w),D7 ; selbstmodif.
                add.w   D7,D6
voice2:         add.l   #$12345678,D3   ; selbstmodif.
                swap    D3
                move.b  0(A3,D3.w),D7
                bne.s   no_ini2
                lea     $12345678,A3    ; selbstmodif.
                moveq   #0,D3
                moveq   #$7F,D7
no_ini2:        move.b  124(A0,D7.w),D7 ; selbstmodif.
                add.w   D7,D6
voice3:         add.l   #$12345678,D4   ; selbstmodif.
                swap    D4
                move.b  0(A4,D4.w),D7
                bne.s   no_ini3
                lea     $12345678,A4    ; selbstmodif.
                moveq   #0,D4
                moveq   #$7F,D7
no_ini3:        move.b  124(A0,D7.w),D7 ; selbstmodif.
                add.w   D7,D6
voice4:         add.l   #$12345678,D5   ; selbstmodif.
                swap    D5
                move.b  0(A5,D5.w),D7
                bne.s   no_ini4
                lea     $12345678,A5    ; selbstmodif.
                moveq   #0,D5
                moveq   #$7F,D7
no_ini4:        move.b  124(A0,D7.w),D7 ; selbstmodif.
                add.w   D7,D6
                swap    D2
                swap    D3
                swap    D4
                swap    D5
mt_selection:
                and.w   #$FFFC,D6

; Ausgabe Åber Druckerport
;               lsr.w   #2,D6
;               or.w    #$0F00,D6
;               movep.w D6,0(A6)

; Ausgabe Åber PSG 
                add.w   D6,D6
                move.l  digitab(PC,D6.w),D7
                move.w  digitab+4(PC,D6.w),D6
                movep.l D7,0(A6)
                movep.w D6,0(A6)

                rte

st_replay:
                lsr.w   #1,D6
                move.b  0(A6,D6.w),D6
                rte
bat:
                add.w   D6,D6
                add.w   D6,D6
                move.b  0(A6,D6.w),D6
                rte


digitab:    dc.w  $080D,$090E,$0A0F,$0000,$080D,$090E,$0A0F,$0000
            dc.w  $080D,$090E,$0A0F,$0000,$080D,$090E,$0A0F,$0000
            dc.w  $080D,$090E,$0A0F,$0000,$080D,$090E,$0A0F,$0000
            dc.w  $080D,$090E,$0A0F,$0000,$080C,$090E,$0A0F,$0000
            dc.w  $080C,$090E,$0A0F,$0000,$080C,$090E,$0A0F,$0000
            dc.w  $080C,$090E,$0A0F,$0000,$080C,$090E,$0A0F,$0000
            dc.w  $080C,$090E,$0A0F,$0000,$0800,$090E,$0A0F,$0000
            dc.w  $0800,$090E,$0A0F,$0000,$0800,$090E,$0A0F,$0000
            dc.w  $0800,$090E,$0A0F,$0000,$0800,$090E,$0A0F,$0000
            dc.w  $0800,$090E,$0A0F,$0000,$0800,$090E,$0A0F,$0000
            dc.w  $0800,$090E,$0A0F,$0000,$0800,$090E,$0A0F,$0000
            dc.w  $080D,$090D,$0A0F,$0000,$080D,$090D,$0A0F,$0000
            dc.w  $080D,$090D,$0A0F,$0000,$080D,$090D,$0A0F,$0000
            dc.w  $080D,$090D,$0A0F,$0000,$080D,$090D,$0A0F,$0000
            dc.w  $080C,$090D,$0A0F,$0000,$080C,$090D,$0A0F,$0000
            dc.w  $080C,$090D,$0A0F,$0000,$080C,$090D,$0A0F,$0000
            dc.w  $080C,$090D,$0A0F,$0000,$080C,$090D,$0A0F,$0000
            dc.w  $080B,$090D,$0A0F,$0000,$080B,$090D,$0A0F,$0000
            dc.w  $080B,$090D,$0A0F,$0000,$080B,$090D,$0A0F,$0000
            dc.w  $080B,$090D,$0A0F,$0000,$080B,$090D,$0A0F,$0000
            dc.w  $080B,$090D,$0A0F,$0000,$0800,$090D,$0A0F,$0000
            dc.w  $0800,$090D,$0A0F,$0000,$0800,$090D,$0A0F,$0000
            dc.w  $0800,$090D,$0A0F,$0000,$0800,$090D,$0A0F,$0000
            dc.w  $0800,$090D,$0A0F,$0000,$0800,$090D,$0A0F,$0000
            dc.w  $080C,$090C,$0A0F,$0000,$080C,$090C,$0A0F,$0000
            dc.w  $080C,$090C,$0A0F,$0000,$080B,$090C,$0A0F,$0000
            dc.w  $080B,$090C,$0A0F,$0000,$080B,$090C,$0A0F,$0000
            dc.w  $080A,$090C,$0A0F,$0000,$080A,$090C,$0A0F,$0000
            dc.w  $080A,$090C,$0A0F,$0000,$0809,$090C,$0A0F,$0000
            dc.w  $0809,$090C,$0A0F,$0000,$0800,$090C,$0A0F,$0000
            dc.w  $0800,$090C,$0A0F,$0000,$080A,$090B,$0A0F,$0000
            dc.w  $080A,$090B,$0A0F,$0000,$0800,$090B,$0A0F,$0000
            dc.w  $0800,$090B,$0A0F,$0000,$0800,$090B,$0A0F,$0000
            dc.w  $0809,$090A,$0A0F,$0000,$0800,$090A,$0A0F,$0000
            dc.w  $0800,$090A,$0A0F,$0000,$0800,$0909,$0A0F,$0000
            dc.w  $0800,$0909,$0A0F,$0000,$0800,$0909,$0A0F,$0000
            dc.w  $0800,$0907,$0A0F,$0000,$0800,$0907,$0A0F,$0000
            dc.w  $0800,$0900,$0A0F,$0000,$0800,$0900,$0A0F,$0000
            dc.w  $0800,$0900,$0A0F,$0000,$080B,$090D,$0A0E,$0000
            dc.w  $080B,$090D,$0A0E,$0000,$080B,$090D,$0A0E,$0000
            dc.w  $080A,$090D,$0A0E,$0000,$080A,$090D,$0A0E,$0000
            dc.w  $080A,$090D,$0A0E,$0000,$0809,$090D,$0A0E,$0000
            dc.w  $0809,$090D,$0A0E,$0000,$0809,$090D,$0A0E,$0000
            dc.w  $0807,$090D,$0A0E,$0000,$0807,$090D,$0A0E,$0000
            dc.w  $0807,$090D,$0A0E,$0000,$0800,$090D,$0A0E,$0000
            dc.w  $0800,$090D,$0A0E,$0000,$0800,$090D,$0A0E,$0000
            dc.w  $080B,$090C,$0A0E,$0000,$080B,$090C,$0A0E,$0000
            dc.w  $080B,$090C,$0A0E,$0000,$080A,$090C,$0A0E,$0000
            dc.w  $080A,$090C,$0A0E,$0000,$080A,$090C,$0A0E,$0000
            dc.w  $080A,$090C,$0A0E,$0000,$0809,$090C,$0A0E,$0000
            dc.w  $0808,$090C,$0A0E,$0000,$0808,$090C,$0A0E,$0000
            dc.w  $0807,$090C,$0A0E,$0000,$0807,$090C,$0A0E,$0000
            dc.w  $0800,$090C,$0A0E,$0000,$0800,$090C,$0A0E,$0000
            dc.w  $0800,$090C,$0A0E,$0000,$080A,$090B,$0A0E,$0000
            dc.w  $080A,$090B,$0A0E,$0000,$080A,$090B,$0A0E,$0000
            dc.w  $080A,$090B,$0A0E,$0000,$0809,$090B,$0A0E,$0000
            dc.w  $0809,$090B,$0A0E,$0000,$0808,$090B,$0A0E,$0000
            dc.w  $0807,$090B,$0A0E,$0000,$0803,$090B,$0A0E,$0000
            dc.w  $0809,$090A,$0A0E,$0000,$0809,$090A,$0A0E,$0000
            dc.w  $0809,$090A,$0A0E,$0000,$0808,$090A,$0A0E,$0000
            dc.w  $0807,$090A,$0A0E,$0000,$0806,$090A,$0A0E,$0000
            dc.w  $0802,$090A,$0A0E,$0000,$0808,$0909,$0A0E,$0000
            dc.w  $0808,$0909,$0A0E,$0000,$0807,$0909,$0A0E,$0000
            dc.w  $0806,$0909,$0A0E,$0000,$0803,$0909,$0A0E,$0000
            dc.w  $0800,$0909,$0A0E,$0000,$0805,$0908,$0A0E,$0000
            dc.w  $0801,$0908,$0A0E,$0000,$0805,$0907,$0A0E,$0000
            dc.w  $0802,$0907,$0A0E,$0000,$0802,$0906,$0A0E,$0000
            dc.w  $0802,$0905,$0A0E,$0000,$0801,$0903,$0A0E,$0000
            dc.w  $0800,$0900,$0A0E,$0000,$0806,$090C,$0A0D,$0000
            dc.w  $0805,$090C,$0A0D,$0000,$0802,$090C,$0A0D,$0000
            dc.w  $080A,$090B,$0A0D,$0000,$080A,$090B,$0A0D,$0000
            dc.w  $080A,$090B,$0A0D,$0000,$080A,$090B,$0A0D,$0000
            dc.w  $080A,$090B,$0A0D,$0000,$0809,$090B,$0A0D,$0000
            dc.w  $0809,$090B,$0A0D,$0000,$0809,$090B,$0A0D,$0000
            dc.w  $0808,$090B,$0A0D,$0000,$0808,$090B,$0A0D,$0000
            dc.w  $0807,$090B,$0A0D,$0000,$0807,$090B,$0A0D,$0000
            dc.w  $0806,$090B,$0A0D,$0000,$0804,$090B,$0A0D,$0000
            dc.w  $0801,$090B,$0A0D,$0000,$0808,$090A,$0A0D,$0000
            dc.w  $0808,$090A,$0A0D,$0000,$0808,$090A,$0A0D,$0000
            dc.w  $0807,$090A,$0A0D,$0000,$0806,$090A,$0A0D,$0000
            dc.w  $0805,$090A,$0A0D,$0000,$0803,$090A,$0A0D,$0000
            dc.w  $0800,$090A,$0A0D,$0000,$0800,$090A,$0A0D,$0000
            dc.w  $0807,$0909,$0A0D,$0000,$0806,$0909,$0A0D,$0000
            dc.w  $0805,$0909,$0A0D,$0000,$0804,$0909,$0A0D,$0000
            dc.w  $0801,$0909,$0A0D,$0000,$0800,$0909,$0A0D,$0000
            dc.w  $0804,$0908,$0A0D,$0000,$0802,$0908,$0A0D,$0000
            dc.w  $0805,$0907,$0A0D,$0000,$0804,$0907,$0A0D,$0000
            dc.w  $0802,$0907,$0A0D,$0000,$0800,$0907,$0A0D,$0000
            dc.w  $0801,$0906,$0A0D,$0000,$0802,$0905,$0A0D,$0000
            dc.w  $0800,$0905,$0A0D,$0000,$0801,$0903,$0A0D,$0000
            dc.w  $0800,$0902,$0A0D,$0000,$0803,$090A,$0A0C,$0000
            dc.w  $0800,$090A,$0A0C,$0000,$0807,$0909,$0A0C,$0000
            dc.w  $0807,$0909,$0A0C,$0000,$0806,$0909,$0A0C,$0000
            dc.w  $0805,$0909,$0A0C,$0000,$0804,$0909,$0A0C,$0000
            dc.w  $0802,$0909,$0A0C,$0000,$0800,$0909,$0A0C,$0000
            dc.w  $0805,$0908,$0A0C,$0000,$0804,$0908,$0A0C,$0000
            dc.w  $0802,$0908,$0A0C,$0000,$0805,$0907,$0A0C,$0000
            dc.w  $0804,$0907,$0A0C,$0000,$0802,$0907,$0A0C,$0000
            dc.w  $0800,$0907,$0A0C,$0000,$0802,$0906,$0A0C,$0000
            dc.w  $0803,$0905,$0A0C,$0000,$0801,$0905,$0A0C,$0000
            dc.w  $0801,$0904,$0A0C,$0000,$0801,$0902,$0A0C,$0000
            dc.w  $0800,$0902,$0A0C,$0000,$0804,$0909,$0A0B,$0000
            dc.w  $0803,$0909,$0A0B,$0000,$0801,$0909,$0A0B,$0000
            dc.w  $0805,$0908,$0A0B,$0000,$0804,$0908,$0A0B,$0000
            dc.w  $0803,$0908,$0A0B,$0000,$0801,$0908,$0A0B,$0000
            dc.w  $0800,$0908,$0A0B,$0000,$0804,$0907,$0A0B,$0000
            dc.w  $0802,$0907,$0A0B,$0000,$0803,$0906,$0A0B,$0000
            dc.w  $0802,$0906,$0A0B,$0000,$0803,$0905,$0A0B,$0000
            dc.w  $0801,$0905,$0A0B,$0000,$0801,$0904,$0A0B,$0000
            dc.w  $0801,$0903,$0A0B,$0000,$0800,$0903,$0A0B,$0000
            dc.w  $0800,$0901,$0A0B,$0000,$0802,$0907,$0A0A,$0000
            dc.w  $0800,$0907,$0A0A,$0000,$0802,$0906,$0A0A,$0000
            dc.w  $0803,$0905,$0A0A,$0000,$0802,$0905,$0A0A,$0000
            dc.w  $0800,$0905,$0A0A,$0000,$0801,$0903,$0A0A,$0000
            dc.w  $0800,$0903,$0A0A,$0000,$0800,$0901,$0A0A,$0000
            dc.w  $0803,$0906,$0A09,$0000,$0802,$0906,$0A09,$0000
            dc.w  $0803,$0905,$0A09,$0000,$0801,$0905,$0A09,$0000
            dc.w  $0800,$0905,$0A09,$0000,$0800,$0904,$0A09,$0000
            dc.w  $0800,$0903,$0A09,$0000,$0800,$0901,$0A09,$0000
            dc.w  $0800,$0900,$0A09,$0000,$0801,$0904,$0A08,$0000
            dc.w  $0801,$0903,$0A08,$0000,$0800,$0902,$0A08,$0000
            dc.w  $0800,$0901,$0A08,$0000,$0801,$0904,$0A07,$0000
            dc.w  $0801,$0903,$0A07,$0000,$0800,$0902,$0A07,$0000
            dc.w  $0800,$0901,$0A07,$0000,$0800,$0903,$0A06,$0000
            dc.w  $0800,$0901,$0A06,$0000,$0800,$0900,$0A06,$0000
            dc.w  $0800,$0901,$0A05,$0000,$0800,$0901,$0A04,$0000
            dc.w  $0800,$0901,$0A03,$0000,$0800,$0901,$0A02,$0000
            dc.w  $0800,$0900,$0A02,$0000,$0800,$0900,$0A00,$0000
            dc.w    $0256


                DC.B $00,$00,$00,$00,$00,$00,$00,$00
                DC.B $00,$00,$00,$00,$00,$00,$00,$00
                DC.B $00,$00,$00,$00,$01,$01,$01,$01
                DC.B $01,$01,$01,$01,$01,$01,$01,$01
                DC.B $01,$01,$01,$01,$01,$01,$01,$01
                DC.B $02,$02,$02,$02,$02,$02,$02,$02
                DC.B $02,$02,$02,$02,$02,$02,$03,$03
                DC.B $03,$03,$03,$03,$03,$03,$03,$03
                DC.B $04,$04,$04,$04,$04,$04,$04,$04
                DC.B $05,$05,$05,$05,$05,$05,$06,$06
                DC.B $06,$06,$07,$07,$07,$07,$08,$08
                DC.B $08,$08,$08,$09,$09,$09,$09,$09
                DC.B $0A,$0A,$0A,$0A,$0A,$0B,$0B,$0B
                DC.B $0B,$0B,$0C,$0C,$0C,$0C,$0D,$0D
                DC.B $0D,$0D,$0D,$0E,$0E,$0E,$0E,$0E
                DC.B $0F,$0F,$0F,$10,$10,$10,$10,$11
VOLUME:         DC.B $11,$11,$12,$12,$12,$12,$13,$13
                DC.B $13,$13,$14,$14,$14,$15,$15,$15
                DC.B $16,$16,$16,$16,$17,$17,$17,$17
                DC.B $18,$18,$18,$18,$19,$19,$19,$1A
                DC.B $1A,$1A,$1B,$1B,$1B,$1C,$1C,$1C
                DC.B $1D,$1D,$1D,$1E,$1E,$1E,$1F,$1F
                DC.B $1F,$20,$20,$20,$21,$21,$22,$22
                DC.B $22,$23,$23,$23,$24,$24,$25,$25
                DC.B $25,$26,$26,$27,$27,$27,$28,$28
                DC.B $28,$29,$29,$2A,$2A,$2B,$2B,$2B
                DC.B $2C,$2C,$2D,$2D,$2D,$2E,$2E,$2F
                DC.B $2F,$2F,$30,$30,$31,$31,$32,$32
                DC.B $32,$33,$33,$34,$34,$35,$35,$36
                DC.B $36,$37,$37,$38,$38,$39,$39,$3A
                DC.B $3A,$3B,$3B,$3C,$3C,$3D,$3D,$3E
                DC.B $3E,$3F,$3F,$40,$40,$41,$41,$42
                DC.B $42,$43,$43,$44,$44,$45,$45,$46
                DC.B $46,$47,$47,$48,$48,$49,$49,$4A
                DC.B $4B,$4B,$4C,$4C,$4D,$4D,$4E,$4F
                DC.B $4F,$50,$50,$51,$51,$52,$52,$53
                DC.B $54,$54,$55,$55,$56,$56,$57,$57
                DC.B $58,$59,$59,$5A,$5A,$5B,$5C,$5C
                DC.B $5D,$5E,$5E,$5F,$5F,$60,$61,$61
                DC.B $62,$63,$63,$64,$64,$65,$66,$66
                DC.B $67,$67,$68,$69,$69,$6A,$6B,$6B
                DC.B $6C,$6D,$6D,$6E,$6F,$6F,$70,$71
                DC.B $71,$72,$73,$73,$74,$75,$75,$76
                DC.B $77,$77,$78,$79,$7A,$7A,$7B,$7C
                DC.B $7C,$7D,$7E,$7E,$7F,$80,$80,$81
                DC.B $82,$83,$83,$84,$85,$85,$86,$87
                DC.B $87,$88,$89,$89,$8A,$8B,$8C,$8D
                DC.B $8D,$8E,$8F,$8F,$90,$91,$92,$93
                DC.B $93,$94,$95,$96,$96,$97,$98,$99
                DC.B $9A,$9A,$9B,$9C,$9D,$9D,$9E,$9F
                DC.B $A0,$A1,$A1,$A2,$A3,$A4,$A5,$A6
                DC.B $A7,$A8,$A9,$AA,$AB,$AB,$AC,$AD
                DC.B $AE,$AF,$AF,$B0,$B1,$B2,$B3,$B3
                DC.B $B4,$B5,$B6,$B6,$B7,$B8,$B9,$BA
                DC.B $BB,$BC,$BD,$BD,$BE,$BF,$C0,$C1
                DC.B $C1,$C2,$C3,$C4,$C5,$C6,$C7,$C8
                DC.B $C9,$CA,$CB,$CB,$CC,$CD,$CE,$CF
                DC.B $D0,$D1,$D1,$D2,$D3,$D4,$D5,$D6
                DC.B $D7,$D8,$D9,$D9,$DA,$DB,$DC,$DD
                DC.B $DE,$DF,$E0,$E0,$E1,$E2,$E3,$E4
                DC.B $E5,$E6,$E7,$E8,$E8,$E9,$EA,$EB
                DC.B $EC,$ED,$EE,$EF,$F0,$F1,$F2,$F3
                DC.B $F4,$F5,$F6,$F7,$F8,$F9,$FA,$FB
                DC.B $FC,$FD,$FE,$FF







                EVEN
mt_aud1temp:    DS.B 26
mt_aud2temp:    DS.B 26
mt_aud3temp:    DS.B 26
mt_aud4temp:    DS.B 26
mt_partnrplay:  DS.L 1
mt_partnote:    DS.L 1
mt_firstpattern:DS.L 1
mt_counter:     DS.W 1
mt_samples:     DS.L 1
mt_sample1:     DS.L 31
mt_maxpart:     DS.W 1
mt_status:      DS.W 1
mt_register:    DS.L 1
mt_currentpos:  DS.L 1
mt_soundpref:   DS.L 1
mt_debpat:      DS.L 1
mt_data:        DS.L 1
mt_adrsave:     DS.L 1
mt_arpeggio:    DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C
                DC.W $023A,$021A,$01FC,$01E0,$01C5,$01AC,$0194,$017D
                DC.W $0168,$0153,$0140,$012E,$011D,$010D,$FE,$F0
                DC.W $E2,$D6,$CA,$BE,$B4,$AA,$A0,$97
                DC.W $8F,$87,$7F,$78,$71,$00,$00,$00
no_noise:
                REPT 512
                DC.L $7F7F7F7F
                ENDM
                DC.L 0

mt_frequences:

DC.L 0
DC.L 0
   DC.L  $FFAE90,$7FD748,$553A30,$3FEBA4,$3322E9,$2A9D18,$2486A6,$1FF5D2
   DC.L  $1C68BA,$199174,$173E6A,$154E8C,$13AAF7,$124353,$110BA3,$FFAE9
   DC.L  $F0A44,$E345D,$D74FA,$CC8BA,$C2CE2,$B9F35,$B1DD9,$AA746
   DC.L  $A3A2E,$9D57B,$9783E,$921A9,$8D10D,$885D1,$83F70,$7FD74
   DC.L  $7BF78,$78522,$74E21,$71A2E,$6E90A,$6BA7D,$68E52,$6645D
   DC.L  $63C73,$61671,$5F232,$5CF9A,$5AE8B,$58EEC,$570A6,$553A3
   DC.L  $537CE,$51D17,$5036C,$4EABD,$4D2FD,$4BC1F,$4A615,$490D4
   DC.L  $47C53,$46886,$45566,$442E8,$43106,$41FB8,$40EF6,$3FEBA
   DC.L  $3EEFE,$3DFBC,$3D0EF,$3C291,$3B49D,$3A710,$399E5,$38D17
   DC.L  $380A3,$37485,$368BA,$35D3E,$3520F,$34729,$33C89,$3322E
   DC.L  $32814,$31E39,$3149B,$30B38,$3020D,$2F919,$2F059,$2E7CD
   DC.L  $2DF71,$2D745,$2CF47,$2C776,$2BFD0,$2B853,$2B0FE,$2A9D1
   DC.L  $2A2CA,$29BE7,$29528,$28E8B,$28810,$281B6,$27B7B,$2755E
   DC.L  $26F60,$2697E,$263B9,$25E0F,$25880,$2530A,$24DAE,$2486A
   DC.L  $2433E,$23E29,$2392B,$23443,$22F70,$22AB3,$22609,$22174
   DC.L  $21CF2,$21883,$21426,$20FDC,$20BA2,$2077B,$20363,$1FF5D
   DC.L  $1FB66,$1F77F,$1F3A7,$1EFDE,$1EC23,$1E877,$1E4D9,$1E148
   DC.L  $1DDC5,$1DA4E,$1D6E5,$1D388,$1D037,$1CCF2,$1C9B9,$1C68B
   DC.L  $1C369,$1C051,$1BD44,$1BA42,$1B74A,$1B45D,$1B179,$1AE9F
   DC.L  $1ABCE,$1A907,$1A649,$1A394,$1A0E8,$19E44,$19BA9,$19917
   DC.L  $1968C,$1940A,$1918F,$18F1C,$18CB1,$18A4D,$187F1,$1859C
   DC.L  $1834E,$18106,$17EC6,$17C8C,$17A59,$1782C,$17606,$173E6
   DC.L  $171CC,$16FB8,$16DAA,$16BA2,$169A0,$167A3,$165AC,$163BB
   DC.L  $161CE,$15FE8,$15E06,$15C29,$15A52,$1587F,$156B1,$154E8
   DC.L  $15324,$15165,$14FAA,$14DF3,$14C41,$14A94,$148EA,$14745
   DC.L  $145A5,$14408,$1426F,$140DB,$13F4A,$13DBD,$13C34,$13AAF
   DC.L  $1392E,$137B0,$13636,$134BF,$1334C,$131DC,$13070,$12F07
   DC.L  $12DA2,$12C40,$12AE1,$12985,$1282C,$126D7,$12584,$12435
   DC.L  $122E8,$1219F,$12058,$11F14,$11DD3,$11C95,$11B5A,$11A21
   DC.L  $118EB,$117B8,$11687,$11559,$1142D,$11304,$111DE,$110BA
   DC.L  $10F98,$10E79,$10D5C,$10C41,$10B29,$10A13,$108FF,$107EE
   DC.L  $106DE,$105D1,$104C6,$103BD,$102B6,$101B1,$100AF,$FFAE
   DC.L  $FEAF,$FDB3,$FCB8,$FBBF,$FAC8,$F9D3,$F8E0,$F7EF
   DC.L  $F6FF,$F611,$F525,$F43B,$F353,$F26C,$F187,$F0A4
   DC.L  $EFC2,$EEE2,$EE04,$ED27,$EC4C,$EB72,$EA9A,$E9C4
   DC.L  $E8EF,$E81B,$E749,$E679,$E5AA,$E4DC,$E410,$E345
   DC.L  $E27C,$E1B4,$E0EE,$E028,$DF64,$DEA2,$DDE1,$DD21
   DC.L  $DC62,$DBA5,$DAE9,$DA2E,$D974,$D8BC,$D805,$D74F
   DC.L  $D69A,$D5E7,$D535,$D483,$D3D3,$D324,$D276,$D1CA
   DC.L  $D11E,$D074,$CFCA,$CF22,$CE7B,$CDD4,$CD2F,$CC8B
   DC.L  $CBE8,$CB46,$CAA5,$CA05,$C966,$C8C7,$C82A,$C78E
   DC.L  $C6F3,$C658,$C5BF,$C526,$C48F,$C3F8,$C363,$C2CE
   DC.L  $C23A,$C1A7,$C114,$C083,$BFF2,$BF63,$BED4,$BE46
   DC.L  $BDB9,$BD2C,$BCA1,$BC16,$BB8C,$BB03,$BA7A,$B9F3
   DC.L  $B96C,$B8E6,$B861,$B7DC,$B758,$B6D5,$B653,$B5D1
   DC.L  $B550,$B4D0,$B450,$B3D1,$B353,$B2D6,$B259,$B1DD
   DC.L  $B162,$B0E7,$B06D,$AFF4,$AF7B,$AF03,$AE8B,$AE14
   DC.L  $AD9E,$AD29,$ACB4,$AC3F,$ABCB,$AB58,$AAE6,$AA74
   DC.L  $AA03,$A992,$A922,$A8B2,$A843,$A7D5,$A767,$A6F9
   DC.L  $A68D,$A620,$A5B5,$A54A,$A4DF,$A475,$A40B,$A3A2
   DC.L  $A33A,$A2D2,$A26B,$A204,$A19D,$A137,$A0D2,$A06D
   DC.L  $A009,$9FA5,$9F41,$9EDE,$9E7C,$9E1A,$9DB8,$9D57
   DC.L  $9CF7,$9C97,$9C37,$9BD8,$9B79,$9B1B,$9ABD,$9A5F
   DC.L  $9A02,$99A6,$994A,$98EE,$9893,$9838,$97DD,$9783
   DC.L  $972A,$96D1,$9678,$9620,$95C8,$9570,$9519,$94C2
   DC.L  $946C,$9416,$93C0,$936B,$9316,$92C2,$926E,$921A
   DC.L  $91C7,$9174,$9121,$90CF,$907D,$902C,$8FDB,$8F8A
   DC.L  $8F3A,$8EE9,$8E9A,$8E4A,$8DFB,$8DAD,$8D5E,$8D10
   DC.L  $8CC3,$8C75,$8C28,$8BDC,$8B8F,$8B43,$8AF8,$8AAC
   DC.L  $8A61,$8A16,$89CC,$8982,$8938,$88EF,$88A5,$885D
   DC.L  $8814,$87CC,$8784,$873C,$86F5,$86AE,$8667,$8620
   DC.L  $85DA,$8594,$854F,$8509,$84C4,$847F,$843B,$83F7
   DC.L  $83B3,$836F,$832B,$82E8,$82A5,$8263,$8220,$81DE
   DC.L  $819C,$815B,$811A,$80D8,$8098,$8057,$8017,$7FD7
   DC.L  $7F97,$7F57,$7F18,$7ED9,$7E9A,$7E5C,$7E1D,$7DDF
   DC.L  $7DA1,$7D64,$7D26,$7CE9,$7CAC,$7C70,$7C33,$7BF7
   DC.L  $7BBB,$7B7F,$7B44,$7B08,$7ACD,$7A92,$7A58,$7A1D
   DC.L  $79E3,$79A9,$796F,$7936,$78FC,$78C3,$788A,$7852
   DC.L  $7819,$77E1,$77A9,$7771,$7739,$7702,$76CA,$7693
   DC.L  $765C,$7626,$75EF,$75B9,$7583,$754D,$7517,$74E2
   DC.L  $74AC,$7477,$7442,$740D,$73D9,$73A4,$7370,$733C
   DC.L  $7308,$72D5,$72A1,$726E,$723B,$7208,$71D5,$71A2
   DC.L  $7170,$713E,$710C,$70DA,$70A8,$7077,$7045,$7014
   DC.L  $6FE3,$6FB2,$6F81,$6F51,$6F20,$6EF0,$6EC0,$6E90
   DC.L  $6E60,$6E31,$6E01,$6DD2,$6DA3,$6D74,$6D45,$6D17
   DC.L  $6CE8,$6CBA,$6C8C,$6C5E,$6C30,$6C02,$6BD5,$6BA7
   DC.L  $6B7A,$6B4D,$6B20,$6AF3,$6AC7,$6A9A,$6A6E,$6A41
   DC.L  $6A15,$69E9,$69BE,$6992,$6966,$693B,$6910,$68E5
   DC.L  $68BA,$688F,$6864,$683A,$680F,$67E5,$67BB,$6791
   DC.L  $6767,$673D,$6713,$66EA,$66C1,$6697,$666E,$6645
   DC.L  $661C,$65F4,$65CB,$65A3,$657A,$6552,$652A,$6502
   DC.L  $64DA,$64B3,$648B,$6463,$643C,$6415,$63EE,$63C7
   DC.L  $63A0,$6379,$6352,$632C,$6306,$62DF,$62B9,$6293
   DC.L  $626D,$6247,$6221,$61FC,$61D6,$61B1,$618C,$6167
   DC.L  $6142,$611D,$60F8,$60D3,$60AE,$608A,$6066,$6041
   DC.L  $601D,$5FF9,$5FD5,$5FB1,$5F8D,$5F6A,$5F46,$5F23
   DC.L  $5EFF,$5EDC,$5EB9,$5E96,$5E73,$5E50,$5E2D,$5E0B
   DC.L  $5DE8,$5DC6,$5DA3,$5D81,$5D5F,$5D3D,$5D1B,$5CF9
   DC.L  $5CD7,$5CB6,$5C94,$5C73,$5C51,$5C30,$5C0F,$5BEE
   DC.L  $5BCD,$5BAC,$5B8B,$5B6A,$5B4A,$5B29,$5B09,$5AE8
   DC.L  $5AC8,$5AA8,$5A88,$5A68,$5A48,$5A28,$5A08,$59E8
   DC.L  $59C9,$59A9,$598A,$596B,$594B,$592C,$590D,$58EE
   DC.L  $58CF,$58B1,$5892,$5873,$5855,$5836,$5818,$57FA
   DC.L  $57DB,$57BD,$579F,$5781,$5763,$5745,$5728,$570A
   DC.L  $56EC,$56CF,$56B1,$5694,$5677,$565A,$563C,$561F
   DC.L  $5602,$55E5,$55C9,$55AC,$558F,$5573,$5556,$553A
   DC.L  $551D,$5501,$54E5,$54C9,$54AD,$5491,$5475,$5459
   DC.L  $543D,$5421,$5406,$53EA,$53CF,$53B3,$5398,$537C
   DC.L  $5361,$5346,$532B,$5310,$52F5,$52DA,$52BF,$52A5
   DC.L  $528A,$526F,$5255,$523A,$5220,$5205,$51EB,$51D1
   DC.L  $51B7,$519D,$5183,$5169,$514F,$5135,$511B,$5102
   DC.L  $50E8,$50CE,$50B5,$509B,$5082,$5069,$504F,$5036
   DC.L  $501D,$5004,$4FEB,$4FD2,$4FB9,$4FA0,$4F88,$4F6F
   DC.L  $4F56,$4F3E,$4F25,$4F0D,$4EF4,$4EDC,$4EC4,$4EAB
   DC.L  $4E93,$4E7B,$4E63,$4E4B,$4E33,$4E1B,$4E03,$4DEC
   DC.L  $4DD4,$4DBC,$4DA5,$4D8D,$4D76,$4D5E,$4D47,$4D2F
   DC.L  $4D18,$4D01,$4CEA,$4CD3,$4CBC,$4CA5,$4C8E,$4C77


fin:
                END
