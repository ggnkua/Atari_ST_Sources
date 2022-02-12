
	xdef detect_machine
	xdef initialize_machine
	xdef release_machine

	xdef machine_type
	xdef machine_cpu
	xdef machine_fpu
	xdef machine_video
	xdef machine_sound
	xdef machine_supervidel
	xdef machine_has_fast_ram

; ------------------------------------------------------------------------------
	text
; ------------------------------------------------------------------------------

_p_cookies=$5a0

detect_machine:
	move.l	_p_cookies,d0
	beq		.exit

	move.l	d0,a6

	move.l	(a6)+,d0
	beq		.no_more_cookies

.cookies_loop:
	move.l	(a6)+,d1

	cmp.l	#'_MCH',d0
	bne		.skip_mch

	move.l	d1,machine_type

	bra		.next_cookie

.skip_mch:	
	cmp.l	#'_CPU',d0
	bne		.skip_cpu

	move.l	d1,machine_cpu

	bra		.next_cookie

.skip_cpu:
	cmp.l	#'_FPU',d0
	bne		.skip_fpu

	move.l	d1,machine_fpu

	bra		.next_cookie

.skip_fpu:
	cmp.l	#'_VDO',d0
	bne		.skip_video

	move.l	d1,machine_video

	bra		.next_cookie

.skip_video:
	cmp.l	#'SupV',d0
	bne		.skip_supervidel

	move.l	d1,machine_supervidel

	bra		.next_cookie

.skip_supervidel:
	cmp.l	#'_SND',d0
	bne		.skip_sound

	move.l	d1,machine_sound

	bra		.next_cookie

.skip_sound:
.next_cookie:
	move.l	(a6)+,d0
	bne		.cookies_loop

.no_more_cookies:
    ; Detect Fast-RAM.

	move	#1,-(sp)
	move.l	#1024,-(sp)
	move	#68,-(sp)
	trap	#1
	addq.l	#8,sp

    tst.l   d0
	beq		.exit

    move    #-1,machine_has_fast_ram

	move.l	d0,-(sp)
	move	#73,-(sp)
	trap	#1
	addq.l	#6,sp

.exit:
	rts

; ------------------------------------------------------------------------------

initialize_machine:
	move	#$2700,sr

	lea		$ffff9800.w,a0
	lea		old_palette,a1
	move	#256-1,d7

.copy_palette_loop:
	move.l	(a0)+,(a1)+

	dbra	d7,.copy_palette_loop

	clr.l	$ffff9800.w

	move	$ffff8900.w,old_8900
	move	$ffff8920.w,old_8920
	move.l	$ffff8930.w,old_8930
	move.l	$ffff8934.w,old_8934
	move.l	$ffff8938.w,old_8938
	move.b	$ffff893c.w,old_893c
	move.b	$ffff8941.w,old_8941

	move.b	#0,$ffff8900.w														| Interrupt selection.
	move.b	#0,$ffff8901.w														| DMA control.
	move.b	#0,$ffff8920.w														| DMA track selection.
	move.b	#1,$ffff8921.w														| Sample size and Frequency (8 bit + 12517 Hz).
	move	#1,$ffff8930.w														| Crossbar source.
	move	#1,$ffff8932.w														| Crossbar destination.
	move.b	#0,$ffff8934.w														| Frequency external clock (STE compatible).
	move.b	#0,$ffff8935.w														| Frequency internal clock (STE compatible).
	move.b	#0,$ffff8936.w														| Record track selection.

	move.b	$fffffa07.w,old_fa07
	move.b	$fffffa09.w,old_fa09
	move.b	$fffffa13.w,old_fa13
	move.b	$fffffa15.w,old_fa15
	move.b	$fffffa1b.w,old_fa1b
	move.b	$fffffa21.w,old_fa21

	move.l	$2c.w,old_line_f_handler
	move.l	$88.w,old_trap_2_handler
	move.l	$90.w,old_trap_4_handler
	move.l	$bc.w,old_trap_f_handler
	move.l	$70.w,old_vbl_handler
	move.l	$118.w,old_ikbd_handler
	move.l	$120.w,old_timer_b_handler

	move.b	$ffff8201.w,old_screen_address+1
	move.b	$ffff8203.w,old_screen_address+2
	move.b	$ffff820d.w,old_screen_address+3

	move.b	display_screen_address+1,$ffff8201.w
	move.b	display_screen_address+2,$ffff8203.w
	move.b	display_screen_address+3,$ffff820d.w

	move.l	$ffff820e.w,d0
	move.l	$ffff8264.w,d1
	movem.l	$ffff8282.w,d2-d5
	movem.l	$ffff82a2.w,d6-a0
	move.l	$ffff82c0.w,a1
	move	$ffff820a.w,a2
	movem.l	d0-a2,old_videl

	; 256 * 240, TC.

	btst	#6,$ffff8006.w
	beq		.set_vga_mode

	move.l	#$c7009e,$ffff8282.w
	move.l	#$1e001b,$ffff8286.w
	move.l	#$7300ab,$ffff828a.w
	move.l	#$20d0201,$ffff82a2.w
	move.l	#$170025,$ffff82a6.w
	move.l	#$2050207,$ffff82aa.w
	move	#$200,$ffff820a.w
	move	#$185,$ffff82c0.w
	clr		$ffff8266.w
	move	#$100,$ffff8266.w
	move	#$0,$ffff82c2.w
	move	#$100,$ffff8210.w

	bra		.skip_vga_mode

.set_vga_mode:
	move.l	#$c6008d,$ffff8282.w
	move.l	#$150004,$ffff8286.w
	move.l	#$6d0097,$ffff828a.w
	move.l	#$41903ff,$ffff82a2.w
	move.l	#$3f003d,$ffff82a6.w
	move.l	#$3fd0415,$ffff82aa.w
	move	#$200,$ffff820a.w
	move	#$186,$ffff82c0.w
	clr		$ffff8266.w
	move	#$100,$ffff8266.w
	move	#$5,$ffff82c2.w
	move	#$100,$ffff8210.w

.skip_vga_mode:
	move	#(256*2-256),$ffff820e.w

	clr.b	$fffffa07.w
	clr.b	$fffffa09.w
	clr.b	$fffffa13.w
	clr.b	$fffffa15.w

	move.l	#line_f_handler,$2c.w
	move.l	#trap_2_handler,$88.w
	move.l	#trap_4_handler,$90.w
	move.l	#trap_f_handler,$bc.w
	move.l	#vbl_handler,$70.w
	move.l	#ikbd_handler,$118.w
	move.l	#timer_b_handler,$120.w

	bset	#6,$fffffa09.w
	bset	#6,$fffffa15.w

	bclr	#3,$fffffa17.w

	clr.b	$fffffa1b.w
	bset	#0,$fffffa07
	bset	#0,$fffffa13

	rts

; ------------------------------------------------------------------------------

release_machine:
	move	#$2700,sr

	clr		$ffff820e.w
	clr.b	$ffff8265.w

	lea		old_palette,a0
	lea		$ffff9800.w,a1

	move	#256-1,d7

.copy_palette_loop:
	move.l	(a0)+,(a1)+

	dbra	d7,.copy_palette_loop

	move	old_8900,$ffff8900.w
	move	old_8920,$ffff8920.w
	move.l	old_8930,$ffff8930.w
	move.l	old_8934,$ffff8934.w
	move.l	old_8938,$ffff8938.w
	move.b	old_893c,$ffff893c.w
	move.b	old_8941,$ffff8941.w

	move.b	old_fa07,$fffffa07.w
	move.b	old_fa09,$fffffa09.w
	move.b	old_fa13,$fffffa13.w
	move.b	old_fa15,$fffffa15.w
	move.b	old_fa1b,$fffffa1b.w
	move.b	old_fa21,$fffffa21.w

	move.l	old_line_f_handler,$2c.w
	move.l	old_trap_2_handler,$88.w
	move.l	old_trap_4_handler,$90.w
	move.l	old_trap_f_handler,$bc.w
	move.l	old_vbl_handler,$70.w
	move.l	old_ikbd_handler,$118.w
	move.l	old_timer_b_handler,$120.w

	move.b	old_screen_address+1,$ffff8201.w
	move.b	old_screen_address+2,$ffff8203.w
	move.b	old_screen_address+3,$ffff820d.w

	movem.l	old_videl,d0-a2
	move.l	d0,$ffff820e.w
	move.l	d1,$ffff8264.w
	movem.l	d2-d5,$ffff8282.w
	movem.l	d6-a0,$ffff82a2.w
	move.l	a1,$ffff82c0.w
	move	a2,$ffff820a.w

	rts

; ------------------------------------------------------------------------------
	data
; ------------------------------------------------------------------------------

machine_type:
	dc.l	-1

machine_cpu:
	dc.l	-1

machine_fpu:
	dc.l	-1

machine_video:
	dc.l	-1

machine_sound:
	dc.l	-1

machine_supervidel:
	dc.l	-1

; ------------------------------------------------------------------------------
	bss
; ------------------------------------------------------------------------------

old_screen_address:
	ds.l	1
old_palette:
	ds.l	256
old_videl:
	ds.l	11

old_line_f_handler:
	ds.l	1
old_trap_2_handler:
	ds.l	1
old_trap_4_handler:
	ds.l	1
old_trap_f_handler:
	ds.l	1
old_vbl_handler:
	ds.l	1
old_ikbd_handler:
	ds.l	1
old_timer_b_handler:
	ds.l	1

old_8900:
	ds.w	1
old_8920:
	ds.w	1
old_8930:
	ds.l	1
old_8934:
	ds.l	1
old_8938:
	ds.l	1
old_893c:
	ds.b	1
old_8941:
	ds.b	1

old_fa07:
	ds.b	1
old_fa09:
	ds.b	1
old_fa13:
	ds.b	1
old_fa15:
	ds.b	1
old_fa1b:
	ds.b	1
old_fa21:
	ds.b	1

	even

machine_has_fast_ram:
	ds		1

; ------------------------------------------------------------------------------
	end
; ------------------------------------------------------------------------------

