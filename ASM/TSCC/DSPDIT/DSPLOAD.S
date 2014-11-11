                PART 'dsp_load'
dspprg:         IBYTES 'X.P56'
dspprglen       EQU *-dspprg
                EVEN
dsploader:      DC.L $00,$00,$3A60F400,$61
                DC.L $F4000070,$068080,$0707,$D8840759
                DC.L $840AF080,$700A08,$F4A00000,$01200013
                DC.L $21D00008,$CE2B0640,$A007588E,$0AA98000
                DC.L $7011084E,$2B200003,$0EB0000A,$A9800070
                DC.L $1608502B,$0AA98000,$70190844,$2B200003
                DC.L $0AF0AA00,$70322000,$230AF0AA,$702A06
                DC.L $C4000070,$270AA980,$702408,$452B4D58
                DC.L $0AF080,$701106,$C4000070,$2F0AA980
                DC.L $702C08,$452B4558,$0AF080,$701106
                DC.L $C4000070,$370AA980,$703408,$452B0758
                DC.L $850AF080,$701100,$00
;---------------------------------------
dsp_load:
                IF 1
                lea     $FFFF8800.w,A0
                move    SR,-(SP)
                move    #$2700,SR       ;DSP-Reset via PSG
                move.b  #$0E,(A0)
                move.b  (A0),D0
                and.b   #-$11,D0
                move.b  D0,2(A0)
                or.b    #$10,D0
                move.b  D0,2(A0)

                move.l  $0114.w,-(SP)
                move.l  #dsp_load_hz_200,$0114.w
                move.l  $FFFFFA06.w,-(SP)
                andi.b  #$0F,$FFFFFA1D.w

                move.l  #$20,$FFFFFA06.w
                ori.b   #$20,$FFFFFA15.w
                move.b  #192,$FFFFFA23.w
                ori.b   #$50,$FFFFFA1D.w

                move    #$2500,SR

                move.l  $04BA.w,D0
                addq.l  #4,D0
dsp_load_wait200hz:cmp.l $04BA.w,D0
                blt.s   dsp_load_wait200hz

                move    #$2700,SR
                move.l  (SP)+,$FFFFFA06.w
                move.l  (SP)+,$0114.w

                move.b  #$0E,(A0)
                move.b  (A0),D0
                and.b   #-$11,D0
                move.b  D0,2(A0)

                lea     $FFFFA200.w,A0
                lea     dsploader(PC),A1
                move.w  #$0200,D0
                move.w  7(A1),D1
                subq.w  #1,D1
                lea     9(A1),A1
dsp_load_copyloader:move.b (A1)+,5(A0)  ;Programm hochjagen
                move.b  (A1)+,6(A0)
                move.b  (A1)+,7(A0)
                subq.w  #1,D0
                dbra    D1,dsp_load_copyloader

                tst.w   D0
                beq.s   dsp_load_nomore
dsp_load_fillrest:clr.b 5(A0)           ;Rest mit #0 fÅllen
                clr.b   6(A0)
                clr.b   7(A0)
                subq.w  #1,D0
                bne.s   dsp_load_fillrest
dsp_load_nomore:
;-----
                lea     $FFFFA204.w,A4

                moveq   #127,D0
dsp_load__waitabit2:bsr.s dsp_load_dspinit_wait
                dbra    D0,dsp_load__waitabit2
                move.l  (A4),D0

                lea     dspprg(PC),A0
                move.w  #dspprglen/3-1,D0
dsp_load_copyplayer:move.b (A0)+,1(A4)
                move.b  (A0)+,2(A4)
                move.b  (A0)+,3(A4)
                bsr.s   dsp_load_dspinit_wait
                dbra    D0,dsp_load_copyplayer

                moveq   #-1,D0
                move.l  D0,(A4)         ;Ende signalisieren

                moveq   #127,D0
dsp_load__waitabit:bsr.s dsp_load_dspinit_wait
                dbra    D0,dsp_load__waitabit

                move    (SP)+,SR
                rts
;-----
dsp_load_hz_200:addq.l  #1,$04BA.w
                bclr    #5,$FFFFFA11.w
                rte
                ELSE
                move.w  #105,-(SP)      ;DSP_Unlock
                trap    #14
                addq.l  #2,SP

                move.w  #104,-(SP)      ;DSP_lock
                trap    #14
                addq.l  #2,SP

                pea     dsp_load_xavail(PC)
                pea     dsp_load_yavail(PC)
                move.w  #106,-(SP)
                trap    #14

                lea     10(SP),SP

                move.l  dsp_load_xavail(PC),-(SP)
                move.l  dsp_load_yavail(PC),-(SP)
                move.w  #107,-(SP)
                trap    #14
                lea     10(SP),SP

                move.w  #113,-(SP)      ;DSP_RequestUniqueAbility
                trap    #14
                addq.l  #2,SP

                move.w  D0,-(SP)
                move.l  #dspprglen/3,-(SP)
                pea     dspprg(PC)
                move.w  #109,-(SP)
                trap    #14
                lea     12(SP),SP
                rts
                ENDC
;-----
dsp_load_dspinit_wait:bsr.s dsp_load_dspinit_rts
                bsr.s   dsp_load_dspinit_rts
                rts
dsp_load_dspinit_rts:rts
;-----
dsp_load_xavail:DC.L 0
dsp_load_yavail:DC.L 0

                ENDPART
