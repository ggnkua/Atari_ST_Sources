; intro.s
;
; Simple intro with words synced to music

intcol:		equ	$0555

		section	text

;--- Init ----------------------------------------------------------------------------

intro_init:
		lea.l	intro_pic,a0
		lea.l	intro_depack,a1
		jsr	lz77

		lea.l	intro_depack,a0
		move.l	screen_adr_base,a1
		lea.l	160(a1),a1
		move.w	#273-1,d7
.y:		move.w	#208/4-1,d6
.x:		move.l	(a0)+,(a1)+
		dbra	d6,.x
		ifne	hatari
		lea.l	22(a0),a0
		lea.l	22(a1),a1
		endc
		ifeq	hatari
		lea.l	22(a0),a0
		lea.l	16(a1),a1
		endc
		dbra	d7,.y

		rts

;--- Runtime Init ---------------------------------------------------------------------

;intro_runtime_init:
;		subq.w	#1,.once
;		bne.w	.done
;
;		jsr	black_pal
;		jsr	clear_screens
;		jsr	syncfix				;fix eventual bitplane corruption
;		jsr	black_pal
;
;
;		ifne	init_green
;		move.w	#$0070,$ffff8240.w
;		endc
;
;.done:		rts
;.once:		dc.w	1

;--- VBL ----------------------------------------------------------------------------

intro_vbl:	move.l	screen_adr_base,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)
		
		movem.l	intro_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		rts

intro_vbl_out:	move.l	screen_adr_base,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		lea.l	intro_pal,a0
		lea.l	intro_outpal,a1
		jsr	component_fade
		
		movem.l	intro_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		rts

;--- Main ----------------------------------------------------------------------------

intro_main1:	move.w	#intcol,intro_pal+2*1
		rts
intro_main2:	move.w	#intcol,intro_pal+2*2
		rts
intro_main3:	move.w	#intcol,intro_pal+2*3
		rts
intro_main4:	move.w	#intcol,intro_pal+2*4
		rts
intro_main5:	move.w	#intcol,intro_pal+2*5
		rts
intro_main6:	move.w	#intcol,intro_pal+2*6
		rts
intro_main7:	move.w	#intcol,intro_pal+2*7
		rts


;--- Timer A ------------------------------------------------------------------------------

intro_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-2,$4e71

		moveq.l	#0,d7			;1
		moveq.l	#2,d6			;1


		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0
		moveq.l	#127,d1
		move.b	#2,$ffff820a.w

.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;


;		66 nops until the first scanline, use for inits etc
		dcb.w 	66-2,$4e71	
		move.w	#228-1,d5		;2


;line 1-228
.y1:
		movem.w	d0-d1,global_dump	;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-d6,global_dump	;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.w	d0-a4,global_dump	;17
		dbra	d5,.y1

;line 229
		dcb.w	2,$4e71			;3
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		movem.w	d0-a2,global_dump	;15
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.l	d0-d6,global_dump	;18
		move.w	#44-1,d5		;2

; line 230-273
.y2:
		movem.w	d0-d1,global_dump	;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-a7,global_dump	;36
		movem.l	d0-d6,global_dump	;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.w	d0-a4,global_dump	;17
		dbra	d5,.y2

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts

;--- Data ---------------------------------------------------------------------------------------------
		
		section	data

intro_pal:	dcb.w	16,$0000
intro_outpal:	dcb.w	16,$0000

intro_pic:	incbin	'intro/intro.z77'	;lz77!
		even

		section	text
