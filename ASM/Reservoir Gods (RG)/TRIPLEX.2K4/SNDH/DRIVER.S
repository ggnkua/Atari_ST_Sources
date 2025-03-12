	opt p+

		bra.w	init
		bra.w	exit
		bra.w	vbl

	dc.b	"triplex replay.  Original code - Big Alec/Delta Force"
	dc.b	" additional work - Damo/Reservoirgods."
		even

;-----------------------
init		bsr	init_player
                bsr     install_all          ; install all hw-registers
		rts

exit            bsr     restore_all          ; set back all hw-registers
		rts
;----------------------

* saves and installs all hardware registers

install_all	bsr     init_mfp
                bsr     init_soundchip

                move    #$2300,SR            ; allow IRQ's
                rts
;---------------------
* set back all hardware registers like they were before

restore_all	
                bsr     restore_mfp
                bsr     restore_soundchip
                rts
;---------------------
init_mfp	move    SR,-(SP)
                ori     #$0700,SR            ; Lock all IRQ's

                lea     $fffffa00.w,A0       ; MFP-Baseregister
                lea     $03(A0),A1           ; Start at MFP Reg $03
                lea     mfp_registers(pc),A2
                moveq   #3,D0                ; Get all registers

save_mfp_loop   movep.l 0(A1),D1             ; get 4 registers once
                move.l  D1,(A2)+             ; store them
                addq.l  #8,A1                ; next 4 registers
                dbra    D0,save_mfp_loop

                lea     $60.w,A1             ; First Autovector-IRQ
                lea     auto_vec_save(pc),A2     ; Store the 8 Autovectors here
                moveq   #7,D0                ; 8 pointers

save_avc_loop   move.l  (A1)+,(a2)+              ; get old pointer
                dbra    D0,save_avc_loop

                lea     $0100.w,A1           ; First MFP-Irq
                lea     mfp_vec_save(pc),A2      ; Store the 16 MFP-Pointers here
                moveq   #15,D0               ; 16 pointers

save_irq_loop   move.l  (A1)+,(a2)+              ; get old pointer
                dbra    D0,save_irq_loop

		lea	sound_timer1a(pc),a5
		move.l	a5,$134.w		;sid voice timer a
		lea	sound_timer1b(pc),a5
		move.l	a5,$110.w		;sid voice timer d

;                move.b  #$04,$03(A0)         ; Set Active Edge Register
;                clr.b   $05(A0)              ; All ports on Input
                or.b  #%100000,$07(A0)     ; Allow Timer A (IRQ-Enab. A)
                or.b  #%0010000,$09(A0)    ; Allow Timer D (IRQ-Enab. B)
                or.b  #%100000,$13(A0)     ; Allow Timer A (IRQ-Mask A)
                or.b  #%0010000,$15(A0)    ; Allow Timer D (IRQ-Mask B)
;                clr.b   $0b(A0)              ; Clear IRQ Pending A
;                clr.b   $0d(A0)              ; Clear IRQ Pending B
;                clr.b   $0f(A0)              ; Clear IRQ-In Service A
;                clr.b   $11(A0)              ; Clear IRQ-In Service B
                move.b  #%1000000,$17(A0)    ; IRQ Vector Register (Automat. EOI)
                clr.b   $19(A0)              ; Stop Timer A (Timer A Control)
		and.b	#%11111000,$fffa1d	;stop Timer D
                clr.b   $1f(A0)              ; Timer A Data = 0
                clr.b   $25(A0)              ; Timer D Data = 0

                move    (SP)+,SR
                rts

* restores all MFP registers and IRQ's

restore_mfp	move    SR,-(SP)
                ori     #$0700,SR            ; Lock all IRQ's

                lea     $fffffa03.w,A1       ; MFP
                lea     mfp_registers(pc),A2
                moveq   #3,D0                ; Get all registers

rest_mfp_loop   move.l  (A2)+,D1             ; get 4 registers once
                movep.l D1,0(A1)             ; restore them
                addq.l  #8,A1                ; next 4 registers
                dbra    D0,rest_mfp_loop

                lea     $60.w,A1             ; First Autovector-IRQ
                lea     auto_vec_save(pc),A2     ; Store the 8 Autovectors here
                moveq   #7,D0                ; 8 pointers

rest_avc_loop   move.l  (A2)+,(A1)+          ; restore old pointer
                dbra    D0,rest_avc_loop

                lea     $0100.w,A1           ; First MFP-Irq
                lea     mfp_vec_save(pc),A2      ; Store the 16 MFP-Pointers here
                moveq   #15,D0               ; 16 pointers

rest_irq_loop   move.l  (A2)+,(A1)+          ; restore old pointer
                dbra    D0,rest_irq_loop

                move    (SP)+,SR
                rts

*** 'Soundchip-Install+DeInstall'

* saves all soundchip values and inits the soundchip

init_soundchip	lea     $ffff8800.w,A0
                lea     sound_save(pc),A1
                moveq   #15,D0               ; save soundchip

save_sound      move.b  D0,(A0)              ; select port
                move.b  (A0),(A1)+           ; get register
                dbra    D0,save_sound

                move.b  #8,(A0)              ; soundchip off (voulume a+b+c)
                clr.b   2(A0)
                move.b  #9,(A0)
                clr.b   2(A0)
                move.b  #10,(A0)
                clr.b   2(A0)
                rts

* restores the soundchip status

restore_soundchip
                lea     sound_save(pc),A0
                lea     $ffff8800.w,A1
                moveq   #15,D0               ; restore soundchip

restore_sound   move.b  D0,(A1)              ; select port
                move.b  (A0)+,2(A1)
                dbra    D0,restore_sound
                rts
;-------------------------------------------------------------------------------
*** 'VBL'

vbl		movem.l D0-A6,-(SP)
                jsr     player(pc)
                movem.l (SP)+,D0-A6
                rts


;###############################################################################
;============================ Play Routine ==========================
patt_length     EQU 64


init_player	
		lea	mod(pc),a1	;store tune address
		move.l	a0,(a1)
		lea	current_pos(pc),a1
		move.w	d0,(a1)		;store start pattern

		lea     player_data(pc),A0
                clr.b   (A0)
                clr.b   2(A0)
                move.w  current_pos(pc),D0
                move.b  D0,3(A0)
                lea     track1_data(pc),A0
                clr.b   6(A0)
                move.b  #$3f,$11(A0)
                lea     track2_data(pc),A0
                clr.b   6(A0)
                move.b  #$3f,$11(A0)
                lea     track3_data(pc),A0
                clr.b   6(A0)
                move.b  #$3f,$11(A0)
                rts

player		lea     player_data(pc),A0
                subq.b  #1,(A0)              ;NeXT step?
                bpl     no_player_step

                move.b  1(A0),(A0)           ;Set speed anew

                move.b  2(A0),D0             ;Pattern counter
                moveq   #64,D1
                sub.b   D0,D1
		lea	patt_pos(pc),a5
                move.w  D1,(a5)

                subq.b  #1,2(A0)             ;Pattern end?
                bpl     no_new_pattern

                move.b  #patt_length-1,2(A0) ;Set pattern length
                movea.l mod(pc),A3
                movea.l A3,A1
                adda.l  $0c(A3),A3           ;a3 is now a pointer on the seq's

                moveq   #0,D0
                move.b  3(A0),D0             ;get song position
                addq.b  #1,3(A0)             ;prepare next position
                cmp.b   $14(A1),D0           ;at end position?
                bne     no_restart

                move.b  $15(A1),D0
                move.b  D0,3(A0)
                addq.b  #1,3(A0)

no_restart	
		lea	current_pos(pc),a5
		move.w  D0,(a5)

                move.b  0(A3,D0.w),D0        ;d0 contains next sequence nr.
                andi.w  #$ff,D0
                mulu    #patt_length*3*4,D0

                movea.l mod(pc),A3
                adda.l  $10(A3),A3
                lea     0(A3,D0.w),A2

                bra     shortcut1

no_new_pattern	movea.l $08(A0),A2           ;get old position

shortcut1	lea     track1_data(pc),A1
                bsr     pattern_check
                lea     track2_data(pc),A1
                bsr     pattern_check
                cmpi.b  #5,6(A1)
                beq     no_timer_stop2
                cmpi.b  #8,6(A1)
                beq     no_timer_stop2
                andi.b  #$f0,$fffffa1d.w

no_timer_stop2	lea     track3_data(pc),A1
                bsr     pattern_check
                cmpi.b  #5,6(A1)
                beq     no_timer_stop
                cmpi.b  #8,6(A1)
                beq     no_timer_stop
                clr.b   $fffffa19.w

no_timer_stop	move.l  A2,$08(A0)           ;Save old position

no_player_step	move.b  #$ff,D7

                lea     ym2149(pc),A6

                moveq   #3,D6
                lea     track1_data(pc),A1
                bsr     wave_shape

                move.b  D0,8*4+2(A6)
                move.b  D2,2(A6)
                ror.w   #8,D2
                move.b  D2,4+2(A6)

;-----

                moveq   #4,D6
                lea     track2_data(pc),A1
                bsr     wave_shape

                move.b  D0,9*4+2(A6)
                move.b  D2,2*4+2(A6)
                ror.w   #8,D2
                move.b  D2,3*4+2(A6)

;-----

                moveq   #5,D6
                lea     track3_data(pc),A1
                bsr     wave_shape

                move.b  D0,10*4+2(A6)
                move.b  D2,4*4+2(A6)
                ror.w   #8,D2
                move.b  D2,5*4+2(A6)

;-----

                move.b  D7,7*4+2(A6)


                lea     $ffff8800.w,A0
                move.l  (A6)+,(A0)           ;0
                move.l  (A6)+,(A0)           ;1
                move.l  (A6)+,(A0)           ;2
                move.l  (A6)+,(A0)           ;3
                move.l  (A6)+,(A0)           ;4
                move.l  (A6)+,(A0)           ;5
                move.l  (A6)+,(A0)           ;6
                move.l  (A6)+,(A0)           ;7
                move.l  (A6),(A0)            ;8

no_v1_play	addq.l  #4,A6

                lea     track2_data(pc),A1
                cmpi.b  #5,6(A1)
                beq     no_v2_play
                cmpi.b  #8,6(A1)
                beq     no_v2_play

                move.l  (A6),(A0)            ;9

no_v2_play	addq.l  #4,A6

                lea     track3_data(pc),A1
                cmpi.b  #5,6(A1)
                beq     no_tenth
                cmpi.b  #8,6(A1)
                beq     no_tenth

                move.l  (A6),(A0)            ;10

no_tenth	addq.l  #4,A6
                move.l  (A6)+,(A0)           ;11
                move.l  (A6)+,(A0)           ;12

                rts

wave_shape	tst.b   (A1)
                bne     go_ahead
                moveq   #0,D0
                moveq   #0,D2
                rts

go_ahead	movea.l $1e(A1),A2           ;get pointer on wave
                move.b  (A2),D0
                bpl     ok_adsr
                subq.l  #1,A2
                move.b  (A2),D0
                bra     ok_wave

ok_adsr		subq.b  #1,$1d(A1)
                bpl     end_adsr
                addq.l  #1,A2
                move.b  $1c(A1),$1d(A1)

end_adsr	move.l  A2,$1e(A1)

ok_wave		move.b  $11(A1),D1           ;get max. volume
                sub.b   D1,D0
                bpl     allright_vol
                moveq   #0,D0                ;silence...

allright_vol	move.l  A2,$1e(A1)           ;save pointer

no_adsr		move.w  D6,D5
                subq.w  #3,D5
                btst    #5,D0                ;mask?
                beq     no_mask_adsr
                bset    D5,D7
                bra     fin_adsr

no_mask_adsr	bclr    D5,D7

fin_adsr	movea.l $18(A1),A2           ;get noise pointer
                move.b  (A2),D2
                bpl     ok_noise
                subq.l  #1,A2
                move.b  (A2),D2

ok_noise	subq.b  #1,$13(A1)
                bpl     no_noise_add
                move.b  $12(A1),$13(A1)
                addq.l  #1,A2

no_noise_add	move.l  A2,$18(A1)

                btst    #5,D2
                bne     no_noise
                bclr    D6,D7
                move.b  D2,6*4+2(A6)
                bra     noise_end

no_noise	bset    D6,D7

noise_end	move.b  (A1),D1              ;get note

                movea.l $0c(A1),A2           ;get arpeggio pointer
                move.b  (A2),D2
                bpl     ok_arpeggio
                cmpi.b  #$ff,D2
                bne     loop_arpeggio
                subq.l  #1,A2
                move.b  (A2),D2
                bra     ok_arpeggio

loop_arpeggio	movea.l 8(A1),A2
                move.b  (A2),D2

ok_arpeggio	subq.b  #1,$10(A1)
                bpl     no_arp_add
                move.b  7(A1),$10(A1)
                addq.l  #1,A2

no_arp_add	move.l  A2,$0c(A1)
                add.b   D2,D1                ;-> note + arpeggio
                andi.w  #$7f,D1

;======================================================================

                move.b  6(A1),D3             ;get type
                beq     normal
                cmpi.b  #2,D3
                ble     norm_buzz
                cmpi.b  #4,D3
                ble     calc_buzz
                cmpi.b  #5,D3
                beq     future_sound
                cmpi.b  #6,D3
                beq     calc_buzz2
                cmpi.b  #7,D3
                beq     calc_buzz3
                cmpi.b  #8,D3
                beq     future_sound2

no_sound_yo	moveq   #0,D2
                moveq   #0,D0
                rts

;======================================================================

normal		add.w   D1,D1
                lea     frequency_tab(pc),A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding
                cmpi.b  #3,1(A1)
                bgt     no_sliding
                beq     gliss

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     no_sliding

gliss		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     slide_down

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     slide_to_it1
                move.w  D1,D4
                neg.w   D4

slide_to_it1	add.w   D4,D1
                bra     no_sliding

slide_down	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     slide_to_it2
                move.w  D3,D4

slide_to_it2	add.w   D4,D1

no_sliding	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     no_null
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

no_null		cmp.b   D4,D1
                blt     no_max
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

no_max		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

*                moveq   #-1,D1
                rts

;======================================================================

norm_buzz	lea     buzzfreqtab(pc),A2
                move.b  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding1
                cmpi.b  #2,1(A1)
                bgt     no_sliding1

                add.w   $24(A1),D1
                move.w  D1,$22(A1)

no_sliding1	add.b   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed
                move.b  3(A1),D4

                add.b   D3,D1
                bpl     no_null1
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

no_null1	cmp.b   D4,D1
                blt     no_max1
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

no_max1		move.b  D1,5(A1)

                lsr.b   #1,D4
                sub.b   D4,D2
                add.b   D1,D2
                move.b  D2,11*4+2(A6)
                clr.b   12*4+2(A6)
                clr.w   D2
*                moveq   #-1,D1
                rts

;======================================================================

calc_buzz	moveq   #0,D2

                lea     buzzfreqtab(pc),A2
                move.b  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding2
                cmpi.b  #2,1(A1)
                bgt     no_sliding2

                add.w   $24(A1),D1
                move.w  D1,$22(A1)

no_sliding2	add.b   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D5             ;speed
                move.b  3(A1),D4

                add.b   D5,D1
                bpl     no_null2
                neg.b   D5
                move.b  D5,4(A1)
                moveq   #0,D1

no_null2	cmp.b   D4,D1
                blt     no_max2
                neg.b   D5
                move.b  D5,4(A1)
                move.b  D4,D1

no_max2		move.b  D1,5(A1)

                lsr.b   #1,D4
                sub.b   D4,D2
                add.b   D1,D2
                move.b  D2,11*4+2(A6)
                clr.b   12*4+2(A6)
                lsl.w   #4,D2
                cmpi.b  #4,D3
                bne     goon_calc
                add.w   D2,D2

goon_calc	subq.w  #3,D2
*                moveq   #-1,D1
                rts

;======================================================================

future_sound	add.w   D1,D1
                lea     frequency_tab(pc),A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding3
                cmpi.b  #3,1(A1)
                bgt     no_sliding3
                beq     gliss2

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     no_sliding3

gliss2		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     slide_down2

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     slide_to_it12
                move.w  D1,D4
                neg.w   D4

slide_to_it12	add.w   D4,D1
                bra     no_sliding3

slide_down2	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     slide_to_it22
                move.w  D3,D4

slide_to_it22	add.w   D4,D1

no_sliding3	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     no_null3
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

no_null3	cmp.b   D4,D1
                blt     no_max3
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

no_max3		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

                cmpi.b  #4,D6
                bne     voice3_synth

                cmpi.w  #17,D2
                bgt     ok_max_freq

no_future_v2	andi.b  #$f0,$fffffa1d.w
                rts

voice3_synth	
                cmpi.w  #17,D2
                bgt     ok_max_freq

no_future_v3	clr.b   $fffffa19.w
                rts

ok_max_freq	cmpi.w  #2593,D2
                blt     do_future

                cmpi.b  #4,D6
                bne     voice3_synth2

                andi.b  #$f0,$fffffa1d.w
                rts

voice3_synth2	clr.b   $fffffa19.w
                rts

do_future	lea     future_freq(pc),A2

                move.w  D2,D3
                add.w   D3,D3
                lea     0(A2,D3.w),A2

                move.b  (A2)+,D3
                move.b  (A2)+,D1

                cmpi.b  #4,D6
                bne     v3_synth3

		lea	sound_timer2b(pc),a5
		move.b	d0,6(a5)
		lea	sound_timer4b(pc),a5
		move.b	d0,6(a5)

                cmp.b   $fffffa25.w,D3
                beq     same_period2
                move.b  D3,$fffffa25.w

same_period2	move.b  $fffffa1d.w,D0		;%00001111
                andi.b  #$0f,D0
                cmp.b   D0,D1
                beq     same_div2
                andi.b  #$f0,$fffffa1d.w
                or.b    D1,$fffffa1d.w

same_div2	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     ok_phaser2
                moveq   #0,D2

ok_phaser2	rts

v3_synth3	
;		move.b  D0,sound_timer2a+4   ;volume
;                move.b  D0,sound_timer4a+4
		lea	sound_timer2a(pc),a5
		move.b	d0,6(a5)
		lea	sound_timer4a(pc),a5
		move.b	d0,6(a5)

                cmp.b   $fffffa1f.w,D3
                beq     same_period
                move.b  D3,$fffffa1f.w

same_period	cmp.b   $fffffa19.w,D1
                beq     same_div
                move.b  D1,$fffffa19.w

same_div	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     ok_phaser
                moveq   #0,D2

ok_phaser	rts

;======================================================================

future_sound2	add.w   D1,D1
                lea     frequency_tab(pc),A2
                move.w  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding5
                cmpi.b  #3,1(A1)
                bgt     no_sliding5
                beq     gliss5

                add.w   $24(A1),D1
                move.w  D1,$22(A1)
                bra     no_sliding5

gliss5		move.w  $24(A1),D4           ;glissando speed

                move.w  $28(A1),D1
                sub.w   D2,D1
                bmi     slide_down5

                neg.w   D4

                cmp.w   $24(A1),D1
                bgt     slide_to_it15
                move.w  D1,D4
                neg.w   D4

slide_to_it15	add.w   D4,D1
                bra     no_sliding5

slide_down5	move.w  D1,D3
                neg.w   D3
                cmp.w   $24(A1),D3
                bgt     slide_to_it25
                move.w  D3,D4

slide_to_it25	add.w   D4,D1

no_sliding5	add.w   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D3             ;speed (signed!)
                move.b  3(A1),D4             ;width

                add.b   D3,D1
                bpl     no_null5
                neg.b   D3
                move.b  D3,4(A1)
                moveq   #0,D1

no_null5	cmp.b   D4,D1
                blt     no_max5
                neg.b   D3
                move.b  D3,4(A1)
                move.b  D4,D1

no_max5		move.b  D1,5(A1)

                ext.w   D1
                ext.w   D4
                lsr.w   #1,D4
                sub.w   D4,D2
                add.w   D1,D2

                move.w  D2,$28(A1)

                cmpi.b  #4,D6
                bne     voice3_synth5

                cmpi.w  #17,D2
                bgt     ok_max_freq5

no_future_v25	andi.b  #$f0,$fffffa1d.w
                rts

voice3_synth5	
                cmpi.w  #17,D2
                bgt     ok_max_freq5

no_future_v35	clr.b   $fffffa19.w
                rts

ok_max_freq5	cmpi.w  #2593,D2
                blt     do_future5

                cmpi.b  #4,D6
                bne     voice3_synth25

                andi.b  #$f0,$fffffa1d.w
                rts

voice3_synth25	clr.b   $fffffa19.w
                rts

do_future5	lea     future_freq(pc),A2

                move.w  D2,D3
                add.w   D3,D3
                lea     0(A2,D3.w),A2

                move.b  (A2)+,D3
                move.b  (A2)+,D1

                cmpi.b  #4,D6
                bne     v3_synth35

;                move.b  D0,sound_timer2b+4   ;volume
;                clr.b   sound_timer4b+4
		lea	sound_timer2b(pc),a5
		move.b	d0,6(a5)
		lea	sound_timer4b(pc),a5
		move.b	#0,6(a5)



                cmp.b   $fffffa25.w,D3
                beq     same_period25
                move.b  D3,$fffffa25.w

same_period25	move.b  $fffffa1d.w,D0
                andi.b  #$0f,D0
                cmp.b   D0,D1
                beq     same_div25
                andi.b  #$f0,$fffffa1d.w
                or.b    D1,$fffffa1d.w

same_div25	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     ok_phaser25
                moveq   #0,D2

ok_phaser25	rts

v3_synth35	
;		move.b  D0,sound_timer2a+4   ;volume
;                clr.b   sound_timer4a+4

		lea	sound_timer2a(pc),a5
		move.b	d0,6(a5)
		lea	sound_timer4a(pc),a5
		move.b	#0,6(a5)

                cmp.b   $fffffa1f.w,D3
                beq     same_period5
                move.b  D3,$fffffa1f.w

same_period5	cmp.b   $fffffa19.w,D1
                beq     same_div5
                move.b  D1,$fffffa19.w

same_div5	move.b  $26(A1),D3
                andi.w  #$ff,D3
                add.w   D3,D2
                bcc     ok_phaser5
                moveq   #0,D2

ok_phaser5	rts

;======================================================================

calc_buzz2	moveq   #0,D2

                lea     buzzfreqtab(pc),A2
                move.b  0(A2,D1.w),D2        ;d2 - frequency

                move.w  $22(A1),D1
                cmpi.b  #1,1(A1)
                blt     no_sliding4
                cmpi.b  #2,1(A1)
                bgt     no_sliding4

                add.w   $24(A1),D1
                move.w  D1,$22(A1)

no_sliding4	add.b   D1,D2

                move.b  5(A1),D1             ;vib. position
                move.b  4(A1),D5             ;speed
                move.b  3(A1),D4

                add.b   D5,D1
                bpl     no_null4
                neg.b   D5
                move.b  D5,4(A1)
                moveq   #0,D1

no_null4	cmp.b   D4,D1
                blt     no_max4
                neg.b   D5
                move.b  D5,4(A1)
                move.b  D4,D1

no_max4		move.b  D1,5(A1)

                lsr.b   #1,D4
                sub.b   D4,D2
                add.b   D1,D2

                move.b  D2,11*4+2(A6)
                clr.b   12*4+2(A6)

                lsl.w   #6,D2

                divu    #3,D2
                subq.w  #2,D2
*                moveq   #-1,D1
                rts

;======================================================================

calc_buzz3	moveq   #0,D2

                lea     buzzfreqtab(pc),A2
                move.b  0(A2,D1.w),D2        ;d2 - frequency
                lea     frequency_tab(pc),A2
                addi.w  #12,D1
                add.w   D1,D1
                move.w  0(A2,D1.w),D3

                move.b  D2,11*4+2(A6)
                clr.b   12*4+2(A6)

                move.w  D3,D2

*                moveq   #-1,D1
                rts

;======================================================================

pattern_check	move.b  (A2)+,D0             ;get note
                beq     no_new_note

                move.b  D0,(A1)              ;$00 - note
                clr.l   $22(A1)              ;clear slide parameters

no_new_note	move.b  (A2)+,D0             ;get instrument
                beq     no_instrument

                andi.w  #$1f,D0
                add.w   D0,D0

                movea.l mod(pc),A3

                adda.l  (A3),A3
                move.w  0(A3,D0.w),D0
                lea     0(A3,D0.w),A3        ;a3 - address of instrument

                moveq   #0,D0
                move.l  #$ff0dff00,D1
                move.b  (A3)+,D0             ;$06 - instrument type
                move.b  D0,6(A1)
                lea     buzz_types(pc),A4
                move.b  0(A4,D0.w),D1
                bmi     no_buzzers
                rol.l   #8,D1
                move.l  D1,$ffff8800.w

no_buzzers	move.b  (A3)+,D0             ;get arpeggio number
                andi.w  #$1f,D0
                add.w   D0,D0

                movea.l mod(pc),A4

                adda.l  4(A4),A4             ;4 is offset for arpeggio table
                move.w  0(A4,D0.w),D0        ;get offset
                lea     0(A4,D0.w),A4
                move.b  (A4),7(A1)           ;$07 - arpeggio speed save
                move.b  (A4)+,$10(A1)        ;$10 - arpeggio speed counter
                move.l  A4,8(A1)             ;$08 - arpeggio start
                move.l  A4,$0c(A1)           ;$0c - arpeggio pointer

                move.b  (A3)+,D0             ;get noise number
                andi.w  #$1f,D0
                add.w   D0,D0

                movea.l mod(pc),A4

                adda.l  8(A4),A4             ;8 is offset for noise table
                move.w  0(A4,D0.w),D0        ;get offset
                lea     0(A4,D0.w),A4
                move.b  (A4),$12(A1)         ;$12 - noise speed save
                move.b  (A4)+,$13(A1)        ;$13 - noise speed counter
                move.l  A4,$14(A1)           ;$14 - noise start
                move.l  A4,$18(A1)           ;$18 - noise pointer

                move.b  (A3)+,$11(A1)        ;$11 - volume

                clr.b   5(A1)                ;$05 - vibrato counter
                clr.b   3(A1)                ;$04 - vibrato width
                clr.b   4(A1)

                move.b  (A3),$1c(A1)         ;$1c - wave speed save
                move.b  (A3)+,$1d(A1)        ;$1d - wave speed counter
                move.l  A3,$1e(A1)           ;$1e - wave pointer

no_instrument	move.b  (A2),D0
                move.b  D0,1(A1)             ;$01 - effect
                beq     no_effect

                move.b  1(A2),2(A1)          ;$02 - value

                cmpi.b  #$0c,D0
                beq     fx_set_volume
                cmpi.b  #$04,D0
                beq     fx_set_vibrato
                cmpi.b  #$01,D0
                beq     fx_slide_up
                cmpi.b  #$02,D0
                beq     fx_slide_down
                cmpi.b  #$03,D0
                beq     fx_glissando
                cmpi.b  #$0f,D0
                beq     fx_speed_change
                cmpi.b  #$0d,D0
                beq     fx_patt_break
                cmpi.b  #$05,D0
                beq     fx_phase_change
                bra     no_effect

fx_set_volume	move.b  2(A1),$11(A1)        ;set volume
                bra     no_effect

fx_speed_change move.b  2(A1),(A0)           ;set pattern speed
                move.b  2(A1),1(A0)
                bra     no_effect

fx_phase_change	move.b  2(A1),$26(A1)
                bra     no_effect

fx_set_vibrato	move.b  2(A1),D0             ;set vibrato
                move.b  D0,4(A1)
                add.b   D0,D0
                add.b   D0,D0
                move.b  D0,3(A1)
                bra     no_effect

fx_slide_up	move.b  2(A1),D0
                neg.b   D0
                ext.w   D0
                move.w  D0,$24(A1)
                bra     no_effect

fx_slide_down	move.b  2(A1),D0
                ext.w   D0
                move.w  D0,$24(A1)
                bra     no_effect

fx_glissando	move.b  2(A1),D0
                andi.w  #$ff,D0
                move.w  D0,$24(A1)
                bra     no_effect

fx_patt_break	clr.b   2(A0)
*                bra     no_effect

no_effect	addq.l  #2,A2

                rts

sound_timer1a	
		move.l	a5,-(sp)
		move.l  #$0aff00ff,$ffff8800.w
                lea	sound_timer2a(pc),a5
		move.l	a5,$0134.w
		move.l	(sp)+,a5
                rte

sound_timer2a	move.l	a5,-(sp)
		move.l  #$0aff00ff,$ffff8800.w
                lea	sound_timer3a(pc),a5
		move.l	a5,$0134.w
		move.l	(sp)+,a5
                rte

sound_timer3a	move.l	a5,-(sp)
		move.l  #$0aff00ff,$ffff8800.w
                lea  	sound_timer4a(pc),a5
		move.l	a5,$0134.w
		move.l	(sp)+,a5
                rte

sound_timer4a	move.l	a5,-(sp)
		move.l  #$0aff00ff,$ffff8800.w
                lea	sound_timer1a(pc),a5
		move.l	a5,$0134.w
		move.l	(sp)+,a5
                rte

sound_timer1b	move.l	a5,-(sp)
		move.l  #$09ff00ff,$ffff8800.w
                lea	sound_timer2b(pc),a5
		move.l	a5,$0110.w
		move.l	(sp)+,a5
                rte

sound_timer2b	
		move.l	a5,-(sp)
		move.l  #$09ff00ff,$ffff8800.w
                lea  	sound_timer3b(pc),a5
		move.l	a5,$0110.w
		move.l	(sp)+,a5
                rte

sound_timer3b	move.l	a5,-(sp)
		move.l  #$09ff00ff,$ffff8800.w
                lea  	sound_timer4b(pc),a5
		move.l	a5,$0110.w
		move.l	(sp)+,a5
                rte

sound_timer4b	move.l	a5,-(sp)
		move.l  #$09ff00ff,$ffff8800.w
                lea	sound_timer1b(pc),a5
		move.l	a5,$0110.w
		move.l	(sp)+,a5
                rte



;-------------------------------------------------------------------------------
*** 'Composer relevant data'

                DATA

patt_pos        DC.W 0
current_pos     DC.W 0
curr_patt_base  DC.L 0
play_flag       DC.W 0


buzz_types	DC.B -1,$0e,$0c,$0e,$0c,-1,$0e,$0e,-1
                EVEN

div_tab		DC.W 0,4,10,16,50,64,100,200

ym2149		DC.L $ff00ff                 ;freq. A
                DC.L $01ff00ff
                DC.L $02ff00ff               ;freq. B
                DC.L $03ff00ff
                DC.L $04ff00ff               ;freq. C
                DC.L $05ff00ff
                DC.L $06ff00ff               ;noise
                DC.L $07ffffff               ;mix
                DC.L $08ff00ff               ;vol. A
                DC.L $09ff00ff               ;vol. B
                DC.L $0aff00ff               ;vol. C
                DC.L $0bff00ff               ;buzz freq.
                DC.L $0cff00ff               ;0

player_data	DC.B 0                       ;$00 - speed counter
                DC.B 6                       ;$01 - speed save
                DC.B 0                       ;$02 - pattern counter
                DC.B 0
                DC.L 0                       ;$04 - start of current pattern
                DC.L 0                       ;$08 - current position
                DC.L 0
                DC.L 0

track1_data	DC.B 0                       ;$00 - note
                DC.B 0                       ;$01 - effect
                DC.B 0                       ;$02 - value
                DC.B 0                       ;$03 - vibrato width
                DC.B 0                       ;$04 - vibrato speed
                DC.B 0                       ;$05 - vibrato count
                DC.B 0                       ;$06 - instrument type
                DC.B 0                       ;$07 - arpeggio speed
                DC.L 0                       ;$08 - arpeggio start
                DC.L 0                       ;$0c - arpeggio pointer
                DC.B 0                       ;$10 - arpeggio speed counter
                DC.B 0                       ;$11 - volume
                DC.B 0                       ;$12 - noise speed
                DC.B 0                       ;$13 - noise counter
                DC.L 0                       ;$14 - noise start
                DC.L 0                       ;$18 - noise pointer
                DC.B 0                       ;$1c - wave speed
                DC.B 0                       ;$1d - wave counter
                DC.L 0                       ;$1e - wave pointer
                DC.W 0                       ;$22 - slide position
                DC.W 0                       ;$24 - slide value
                DC.B 0                       ;$26 - phase
                DC.B 0                       ;
                DC.W 0                       ;$28 - old frequency
                DC.W 0
                EVEN

track2_data	DC.B 0                       ;$00 - note
                DC.B 0                       ;$01 - effect
                DC.B 0                       ;$02 - value
                DC.B 0                       ;$03 - vibrato width
                DC.B 0                       ;$04 - vibrato speed
                DC.B 0                       ;$05 - vibrato count
                DC.B 0                       ;$06 - instrument type
                DC.B 0                       ;$07 - arpeggio speed
                DC.L 0                       ;$08 - arpeggio start
                DC.L 0                       ;$0c - arpeggio pointer
                DC.B 0                       ;$10 - arpeggio speed counter
                DC.B 0                       ;$11 - volume
                DC.B 0                       ;$12 - noise speed
                DC.B 0                       ;$13 - noise counter
                DC.L 0                       ;$14 - noise start
                DC.L 0                       ;$18 - noise pointer
                DC.B 0                       ;$1c - wave speed
                DC.B 0                       ;$1d - wave counter
                DC.L 0                       ;$1e - wave pointer
                DC.W 0                       ;$22 - slide position
                DC.W 0                       ;$24 - slide value
                DC.B 0                       ;$26 - phase
                DC.B 0                       ;
                DC.W 0                       ;$28 - old frequency
                DC.W 0
                EVEN

track3_data	DC.B 0                       ;$00 - note
                DC.B 0                       ;$01 - effect
                DC.B 0                       ;$02 - value
                DC.B 0                       ;$03 - vibrato width
                DC.B 0                       ;$04 - vibrato speed
                DC.B 0                       ;$05 - vibrato count
                DC.B 0                       ;$06 - instrument type
                DC.B 0                       ;$07 - arpeggio speed
                DC.L 0                       ;$08 - arpeggio start
                DC.L 0                       ;$0c - arpeggio pointer
                DC.B 0                       ;$10 - arpeggio speed counter
                DC.B 0                       ;$11 - volume
                DC.B 0                       ;$12 - noise speed
                DC.B 0                       ;$13 - noise counter
                DC.L 0                       ;$14 - noise start
                DC.L 0                       ;$18 - noise pointer
                DC.B 0                       ;$1c - wave speed
                DC.B 0                       ;$1d - wave counter
                DC.L 0                       ;$1e - wave pointer
                DC.W 0                       ;$22 - slide position
                DC.W 0                       ;$24 - slide value
                DC.B 0                       ;$26 - phase
                DC.B 0                       ;
                DC.W 0                       ;$28 - old frequency
                DC.W 0
                EVEN

frequency_tab	DC.B 0,0,14,238,14,24,13,75,12,140,11,218,11,48
                DC.B 10,145,9,246,9,105,8,225,8,96
                DC.B 7,234,7,120,7,12,6,165,6,72
                DC.B 5,237,5,151,5,71,4,251,4,180
                DC.B 4,112,4,48,3,244,3,187,3,134
                DC.B 3,83,3,35,2,246,2,203,2,163
                DC.B 2,125,2,90,2,56,2,24,1,250
                DC.B 1,221,1,195,1,169,1,145,1,123
                DC.B 1,101,1,81,1,62,1,45,1,28
                DC.B 1,12,0,253,0,238,0,225,0,212
                DC.B 0,200,0,189,0,178,0,168,0,159
                DC.B 0,150,0,142,0,134,0,126,0,119
                DC.B 0,112,0,106,0,100,0,94,0,89
                DC.B 0,84,0,79,0,75,0,71,0,67
                DC.B 0,63,0,59,0,56,0,53,0,50
                DC.B 0,47,0,44,0,42,0,39,0,37
                DC.B 0,35,0,33,0,31,0,29,0,28
                DC.B 0,26,0,25,0,23,0,22,0,21
                DC.B 0,19,0,18,0,17,0,16,0,15
                DC.B 0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.B 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                EVEN

buzzfreqtab	DC.B 0,240,226,212,200,190,178,168,158,150,142,134,126
                DC.B 120,113,106,100,95,89,84,79,75,71,67,63
                DC.B 60,56,53,50,47,45,42,40,38,36,34,32
                DC.B 30,28,27,25,24,22,21,20,19,18,17,16
                DC.B 15,14,13,12,12,11,11,10,9,9,8,8,7,6,5,4,3,2,1
                EVEN

future_freq	incbin d:\dev\triplex\sources\FUTURE.FRQ
;-------------------------------------------------------------------------------
		even
mod             Dcb.L 	4,0

;------------------------------------------------------------------------------
                BSS
bss_start 

*** 'Saveregs'             ; Space for all the backupped hw-registers

mfp_registers   DS.L 4
auto_vec_save   DS.L 8
mfp_vec_save    DS.L 16


sound_save      DS.B 16


                DS.B 512                     ; 512 bytes stack
stack		DS.B 256                     ; because of screen lowbyte reserve 256 more

bss_end 	END
