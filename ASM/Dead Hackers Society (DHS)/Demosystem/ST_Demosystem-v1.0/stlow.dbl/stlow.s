; Normal ST-LOW template
;
; Works with ST, STe and Falcon
;
; Double buffered display
; Use for 1 VBL stuff - for slower effects, look at the tripple buffer template
;
; September 4, 2011


stlow_init:	rts

stlow_runtime_init:
		run_once				;Macro to ensure the runtime init only run once
		jsr	black_pal
		jsr	clear_screens
		rts


stlow_main:	bsr	stlow_draw_graphics

		move.l	screen_adr,d0
		move.l	screen_adr2,screen_adr
		move.l	d0,screen_adr2
		rts

stlow_vbl:	move.l  screen_adr,d0			;Set screenaddress
		lsr.w	#8,d0				;
		move.l	d0,$ffff8200.w			;

		movem.l	stlow_picture+2,d0-d7		;Set palette
		movem.l	d0-d7,$ffff8240.w		;

		rts

stlow_draw_graphics:
		;Super-simple test effect

		move.l	screen_adr,a0
		add.w	.ofs,a0
		lea	stlow_picture+34,a1

		move.w	#64-1,d7
.y:
		rept	160/4
		move.l	(a1)+,(a0)+
		endr

		dbra	d7,.y

		cmp.w	#135,.cnt
		blt.s	.add
		neg.w	.val
		clr.w	.cnt
.add:		addq.w	#1,.cnt
		move.w	.val,d0
		add.w	d0,.ofs

		rts
.cnt:		dc.w	0
.ofs:		dc.w	0
.val:		dc.w	160

		section	data

stlow_picture:	incbin	'stlow.dbl/pic.pi1'
		even

		section	text
