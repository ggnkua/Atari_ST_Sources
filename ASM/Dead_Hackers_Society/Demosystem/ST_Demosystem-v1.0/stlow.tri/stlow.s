; Normal ST-LOW template
;
; Works with ST, STe and Falcon
;
; Tripple buffered display
; Use for >1 VBL stuff
;
; September 7, 2011


stlow_tri_init:	rts

stlow_tri_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		jsr	black_pal
		jsr	clear_screens
		bsr	stlow_tri_setup_screens		;Setup new screen addresses for tripple buffering

		lea	stlow_tri_c2pbuf,a0		;c2p precalc
		jsr	init_c2p			;

		jsr	stlow_tri_copy_background
		rts


stlow_tri_main:
.again:		clr.w	vbl_counter

		bsr	stlow_tri_effect		;Effect code

		move.l	scr1,d0				;Swapscreens
		move.l	scr2,scr1			;
		move.l	scr3,scr2			;
		move.l	d0,scr3				;

		tst.w	exit_demo			;Check if VBL told us to exit
		bne	exit				;

		tst.w	vbl_counter			;If efx was <=1VBL, wait for next VBL
		beq.s	.waitvbl			;

		cmp.l	#stlow_tri_main,main_routine	;Check if the mainroutine has changed
		beq.s	.again				;

.waitvbl:	rts


stlow_tri_vbl:	move.l  scr3,d0				;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		movem.l	stlow_tri_pal,d0-d7		;Set palette
		movem.l	d0-d7,$ffff8240.w		;

		rts


stlow_tri_effect:
;shitslow example effect

		lea	stlow_tri_chunky,a0		;Let's copy some random data to the chunky buffer
		moveq	#0,d0
		move.b	#8,$ffff8800.w			;Just get some random seed value from YM channel 1 volume register
		move.b	$ffff8800.w,d0
		move.w	#160-1,d7
.noise:
		rol.l d0,d0
		addq.l #5,d0
		move.l	d0,d1
		and.w	#$1fff,d1

		bclr	#0,d1
		move.l	#$0f0f0f0f,(a0,d1.w)

		dbra	d7,.noise


		lea	stlow_tri_chunky,a0		;Now let's smooth it out
		lea	160-1(a0),a1
		lea	160(a0),a2
		lea	160+1(a0),a3
		moveq	#0,d0

		move.w	#52-1,d7
.y:
		rept	160
		move.b	(a0),d0
		add.b	(a1)+,d0
		add.b	(a2)+,d0
		add.b	(a3)+,d0
		lsr.b	#2,d0
		move.b	d0,(a0)+
		endr

		dbra	d7,.y



		move.l	scr1,a0				;And finally c2p it to screen
		lea	160*40(a0),a0
		lea	stlow_tri_chunky,a1
		lea	stlow_tri_c2pbuf,a2
		move.w	#50-1,d7
.c2p_y:
.q:		set	0
		rept	160/8
		moveq	#0,d0
		move.b	(a1)+,d0
		lsl.w	#4,d0
		or.b	(a1)+,d0
		lsl.w	#4,d0
		or.b	(a1)+,d0
		lsl.w	#4,d0
		or.b	(a1)+,d0
		lsl.l	#2,d0
		move.l	(a2,d0.l),d0
		movep.l	d0,.q(a0)
		movep.l	d0,.q+160(a0)

		moveq	#0,d0
		move.b	(a1)+,d0
		lsl.w	#4,d0
		or.b	(a1)+,d0
		lsl.w	#4,d0
		or.b	(a1)+,d0
		lsl.w	#4,d0
		or.b	(a1)+,d0
		lsl.l	#2,d0
		move.l	(a2,d0.l),d0
		movep.l	d0,.q+1(a0)
		movep.l	d0,.q+161(a0)
.q:		set	.q+8
		endr

		lea	320(a0),a0

		dbra	d7,.c2p_y

		rts

stlow_tri_setup_screens:
		move.l	screen_adr_base,d0		;Setup new screen addresses for tripple buffering
		move.l	d0,scr1				;
		add.l	#32000,d0			;
		move.l	d0,scr2				;
		add.l	#32000,d0			;
		move.l	d0,scr3				;
		rts

stlow_tri_copy_background:
		lea	stlow_tri_background+34,a0
		move.l	scr1,a1
		move.l	scr2,a2
		move.l	scr3,a3
		move.w	#32000/4-1,d7
.l:		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		move.l	d0,(a3)+
		dbra	d7,.l
		rts


		section	data


scr1:		dc.l	0				;Screen addr 1
scr2:		dc.l	0				;Screen addr 2
scr3:		dc.l	0				;Screen addr 3

stlow_tri_pal:	dc.w	$0000,$0100,$0200,$0300,$0400,$0510,$0620,$0730
		dc.w	$0740,$0751,$0762,$0773,$0774,$0775,$0776,$0777

stlow_tri_background:
		incbin	'stlow.tri/pic.pi1'
		even

		section	bss

stlow_tri_chunky:
		ds.b	160*70

stlow_tri_c2pbuf:
		ds.l	256*256


		section	text
