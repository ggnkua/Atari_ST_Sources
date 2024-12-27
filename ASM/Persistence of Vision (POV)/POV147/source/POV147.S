**************************************************************************
*			PERSISTENCE OF VISION 147			*
*			-------------------------			*
*									*
* Written by: 	MAC SYS DATA of PERSISTENCE OF VISION			*
*   Based on:	Pulsion 174						*
*									*
*									*
* Music by:	Jedi/Sector One						*
*									*
*									*
* Grafix by: 	MAC SYS DATA						*
*									*
*									*
* Date:		25-May-1994 finally bug fixed 15-Jun-1994		*
*									*
*			½ Persistence Of Vision 1994			*
*									*
*************************************************************************
yes=1
no=0
YES=yes
NO=no
		opt	o+,w-

AUTORUN4	equ	no
FINAL		equ	no
		ifne	FINAL
		opt	d-
		endc

multinop	macro
		dcb.w	\1,$4e71
		endm

;***********************************************************************
		ifeq	AUTORUN4
begin		bra	start
		ds.b	100
ustack		ds.l	1

exec		pea	blank
		pea	blank
		pea	$200.w
		clr.w	-(sp)
		move.w	#$4b,-(sp)
		trap	#1
		lea	16(sp),sp
		pea	reset_me(pc)
		move.w	#$26,-(sp)
		trap	#14
reset_me	move.l	4.w,-(sp)
		rts

blank		dc.l	0

start		move.l	4(a7),a0
		move.l	#ustack,a7
		move.l	#start-begin+$100,-(a7)	;keep only EXEC routine
		move.l	a0,-(a7)
		clr.w	-(a7)
		move.w	#$4a,-(a7)
		trap	#1
		lea	12(a7),a7
		endc

		bsr	set_up
		move.w	#$2700,sr
		jsr	start_isrs
		move.w	#$2300,sr

main_loop	jsr	flip_screen

		moveq	#0,d0
		move.b	$fffffc02.w,d0
		cmp.b	#$1d,d0
		bne.s	.k1
		bset	#2,key
.k1		cmp.b	#$9d,d0
		bne.s	.k2
		bclr	#2,key
.k2		cmp.b	#$38,d0
		bne.s	.k3
		bset	#3,key
.k3		cmp.b	#$b8,d0
		bne.s	.k4
		bclr	#3,key
.k4		move.b	d0,key+1

		move.w	key,d0

		ifeq	FINAL
		cmp.w	#1,d0		;ESC
		beq	assem
		ENDC

		cmp.w	#11,d0		;0 keyboard
		beq	zero

		cmp.w	#$70,d0		;0 keypad
		beq	zero

		cmp.w	#$c53,d0	;ALT+CONTROL+DELETE=RESET!
		beq	reset

		lea	demo_keys,a4
.next		move.w	(a4)+,d1
		bmi.s	main_loop
		cmp.b	d1,d0
		beq.s	.run
		bra.s	.next
.run		move.w	#$2300,sr
		lsr.w	#8,d1
		and.w	#$f,d1
		lsl.w	#2,d1
		lea	filename_table,a3
		move.l	(a3,d1.w),a3
		lea	$200.w,a1
		REPT	4
		move.l	(a3)+,(a1)+
		ENDR

assem		tst.w	hertz_toggle
		beq.s	hz50
		and.b	#%11111101,$ffff820a.w	;60Hz
hz50

* attempt to shut down tidily without screen screwing up
		clr.b	$fffffa1b.w
		movem.l	d0/a0,-(sp)
.wait		cmp.b	#$60,$ffff8209.w
		blo.s	.wait
		dbt	d0,*
		dbt	d0,*
		lea	.nops(pc),a0
		moveq	#0,d0
		move.b	$ffff8209.w,d0
		sub.b	#$62,d0
		add.w	d0,a0
		jmp	(a0)
.nops		REPT	$62
		nop
		ENDR
		dbt	d0,*
		dbt	d0,*
		clr.b	$ffff820a.w
		nop
		movem.l	(sp)+,d0/a0
		move.b	#2,$ffff820a.w

		move.w	#$2700,sr
		lea	storage,a0
		move.l	(a0)+,$68.w
		move.l	(a0)+,$70.w
		move.l	(a0)+,$120.w
		move.b	(a0)+,$fffffa07.w
		move.b	(a0)+,$fffffa09.w
		move.b	(a0)+,$fffffa13.w
		move.b	(a0)+,$fffffa15.w
		move.b	(a0)+,$fffffa17.w
		move.b	(a0)+,$fffffa1b.w
		move.b	(a0)+,$fffffa21.w
		move.b	old_key,$484.w
		move.w	#$2300,sr
bp		move.l	#$8080000,$ffff8800.w
		move.l	#$9090000,$ffff8800.w
		move.l	#$a0a0000,$ffff8800.w
		movem.l	org_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w
;;;		move.l	org_base,$44e.w
		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		move.b	old_rez,$ffff8260.w
		move.w	#1,-(sp)
		move.l	org_base,-(sp)
		move.l	(sp),-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp
		move.w	#30-1,d7
.waitstate	move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		dbf	d7,.waitstate
		clr.w	-(sp)
		move.l	org_base,-(sp)
		move.l	org_base,-(sp)
		move.w	#5,-(sp)
		trap	#14
		lea	12(sp),sp

		move.b	#$8,$fffffc02.w

		move.l	old_stack,-(a7)
		move.w	#$20,-(a7)
		trap	#1
		addq.l	#6,a7

		ifeq	FINAL
		clr.w	-(sp)
		trap	#1
		endc

		ifeq	AUTORUN4
		bra	exec
		elseif
		clr.w	-(sp)
		trap	#1
		endc


zero		;flip hertz indicator...
		tst.w	hertz_delay
		bne	main_loop
		eor.w	#-1,hertz_toggle
		move.w	#8,hertz_delay	;delay used to stop key being pressed too fast
		bra	main_loop

reset		move.l	4.w,-(sp)
		rts

vsync		move.w	#-1,vsync_flag
.loop		tst.w	vsync_flag
		bne.s	.loop
		rts

new_hbl		rte

new_vbl		clr.w	vsync_flag
		clr.b	$fffffa1b.w
		move.b	#100,$fffffa21.w
		move.b	#4,$fffffa1b.w
		move.b	#1,$fffffa07.w
		movem.l	a0-a6/d0-d7,-(sp)
		jsr	music+8
		movem.l	(sp)+,a0-a6/d0-d7
		addq.w	#4,sine_table_offset	;change this in 2's for background speed
;sine table is 5772 bytes long really!
		cmp.w	#(sine_table_end-sine_table)-1444,sine_table_offset
		bne	.no_reset
		clr.w	sine_table_offset
.no_reset	tst.w	hertz_delay
		bne.s	.dec
		rte
.dec		sub.w	#1,hertz_delay
		rte

***** INFORMATION ONLY ****************	open up 1 line of borders
;;		multinop	11
;;		move.b	d1,(a1)
;;		nop
;;		nop
;;		move.b	d0,(a1)
;;		multinop	89
;;		move.b	d0,(a0)
;;		move.b	d1,(a0)
;;		multinop	13
;;		move.b	d1,(a1)
;;		nop
;;		move.b	d0,(a1)
***************************************

new_timerb	clr.b	$fffffa07.w
		move.l	#new_hbl,$68.w
		stop	#$2100
		stop	#$2100
		move	#$2700,sr
		movem.l	a0-a6/d0-d7,-(a7)
		lea	$ffff820a.w,a0
		lea	$ffff8260.w,a1
		moveq	#0,d0
		moveq	#2,d1
		lea	background_colour_space,a4
		adda.w	background_col_offset,a4
		movea.l	a4,a5
		lea	sine_table,a2
		adda.w	sine_table_offset,a2
		adda.w	(a2)+,a5
		lea	$ffff8242.w,a3
		move.l	(a5)+,(a3)+
		move.l	(a5)+,(a3)+
		move.l	(a5)+,(a3)+
		move.l	(a5)+,(a3)+
		move	a7,usp
		lea	194+(82*230)(a6),a7
		lea	shifted_text,a3
		lea	ripple_table,a6
		adda.w	shifted_text_offset,a6
		move.b	#0,(a0)
		adda.w	(a6)+,a3
		adda.w	(a6),a7
		moveq	#9-1,d7

		multinop	6

		move.b	#2,(a0)

		multinop	14

		moveq	#0,d2
		move.b	$ffff8209.w,d2
		neg.w	d2
		lsl.w	d2,d2			;sync
		move.l	#$111,$ffff8250.w	;main pal
		move.l	#$2220333,$ffff8254.w
		move.l	#$4440555,$ffff8258.w
		move.l	#$6660777,$ffff825c.w

		multinop	17

		move.b	d0,(a0)
		move.b	d1,(a0)
		multinop	13
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)

		multinop	11
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)

		lea	-5040(a3),a3
		nop
.loop		suba.w	-2(a6),a3
		suba.w	(a6)+,a7
		lea	460(a7),a7
		lea	5040(a3),a3
		adda.w	(a6)+,a3
		adda.w	(a6),a7

		multinop	65

		movea.l	a4,a5
		adda.w	(a2)+,a5

		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		move.w	(a3)+,(a7)
		move.w	(a3)+,8(a7)
		move.w	(a3)+,16(a7)
		move.w	(a3)+,24(a7)
		move.w	(a3)+,32(a7)
		move.w	(a3)+,40(a7)
		move.w	(a3)+,48(a7)
		move.w	(a3)+,56(a7)
		move.w	(a3)+,64(a7)
		move.w	(a3)+,72(a7)
		move.w	(a3)+,80(a7)
		move.w	(a3)+,88(a7)
		move.w	(a3)+,96(a7)
		move.w	(a3)+,104(a7)
		move.w	(a3)+,112(a7)
		move.w	(a3)+,120(a7)
		move.w	(a3)+,128(a7)
		move.w	(a3)+,136(a7)
		move.w	(a3)+,144(a7)
		move.w	(a3)+,152(a7)
		move.w	(a3)+,160(a7)
		nop
		nop
		movea.l	a4,a5
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4

		rept	7
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		lea	230(a7),a7
		move.b	d0,(a1)
		move.w	(a3)+,(a7)
		move.w	(a3)+,8(a7)
		move.w	(a3)+,16(a7)
		move.w	(a3)+,24(a7)
		move.w	(a3)+,32(a7)
		move.w	(a3)+,40(a7)
		move.w	(a3)+,48(a7)
		move.w	(a3)+,56(a7)
		move.w	(a3)+,64(a7)
		move.w	(a3)+,72(a7)
		move.w	(a3)+,80(a7)
		move.w	(a3)+,88(a7)
		move.w	(a3)+,96(a7)
		move.w	(a3)+,104(a7)
		move.w	(a3)+,112(a7)
		move.w	(a3)+,120(a7)
		move.w	(a3)+,128(a7)
		move.w	(a3)+,136(a7)
		move.w	(a3)+,144(a7)
		move.w	(a3)+,152(a7)
		move.w	(a3)+,160(a7)
		nop
		nop
		movea.l	a4,a5
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4
		endr

		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		lea	230(a7),a7
		move.b	d0,(a1)
		dbf	d7,.loop

		suba.w	-2(a6),a3
		suba.w	(a6)+,a7
		lea	460(a7),a7
		lea	5040(a3),a3
		adda.w	(a6)+,a3
		adda.w	(a6),a7
		moveq	#8,d7

		multinop	32

		move.l	#$670067,$ffff8250.w
		move.l	#$670067,$ffff8254.w
		move.l	#$670067,$ffff8258.w
		move.l	#$670067,$ffff825c.w
		move.l	#raster_cols,raster_cols_pos

		movea.l	a4,a5
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		move.w	(a3)+,(a7)
		move.w	(a3)+,8(a7)
		move.w	(a3)+,16(a7)
		move.w	(a3)+,24(a7)
		move.w	(a3)+,32(a7)
		move.w	(a3)+,40(a7)
		move.w	(a3)+,48(a7)
		move.w	(a3)+,56(a7)
		move.w	(a3)+,64(a7)
		move.w	(a3)+,72(a7)
		move.w	(a3)+,80(a7)
		move.w	(a3)+,88(a7)
		move.w	(a3)+,96(a7)
		move.w	(a3)+,104(a7)
		move.w	(a3)+,112(a7)
		move.w	(a3)+,120(a7)
		move.w	(a3)+,128(a7)
		move.w	(a3)+,136(a7)
		move.w	(a3)+,144(a7)
		move.w	(a3)+,152(a7)
		move.w	(a3)+,160(a7)
		nop
		nop

		rept	7
		movea.l	a4,a5
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		lea	230(a7),a7
		move.b	d0,(a1)
		move.w	(a3)+,(a7)
		move.w	(a3)+,8(a7)
		move.w	(a3)+,16(a7)
		move.w	(a3)+,24(a7)
		move.w	(a3)+,32(a7)
		move.w	(a3)+,40(a7)
		move.w	(a3)+,48(a7)
		move.w	(a3)+,56(a7)
		move.w	(a3)+,64(a7)
		move.w	(a3)+,72(a7)
		move.w	(a3)+,80(a7)
		move.w	(a3)+,88(a7)
		move.w	(a3)+,96(a7)
		move.w	(a3)+,104(a7)
		move.w	(a3)+,112(a7)
		move.w	(a3)+,120(a7)
		move.w	(a3)+,128(a7)
		move.w	(a3)+,136(a7)
		move.w	(a3)+,144(a7)
		move.w	(a3)+,152(a7)
		move.w	(a3)+,160(a7)
		nop
		nop
		endr

		movea.l	a4,a5
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		lea	230(a7),a7
		move.b	d0,(a1)
		nop
		nop
		nop
.loop2		movea.l	raster_cols_pos,a5
		move.l	(a5)+,d3
		move.l	a5,raster_cols_pos
		move.l	d3,$ffff8250.w
		move.l	d3,$ffff8254.w
		move.l	d3,$ffff8258.w
		move.l	d3,$ffff825c.w
		suba.w	-2(a6),a3
		suba.w	(a6)+,a7
		lea	460(a7),a7
		lea	5040(a3),a3
		adda.w	(a6)+,a3
		adda.w	(a6),a7
		multinop	36

		movea.l	a4,a5
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		move.w	(a3)+,(a7)
		move.w	(a3)+,8(a7)
		move.w	(a3)+,16(a7)
		move.w	(a3)+,24(a7)
		move.w	(a3)+,32(a7)
		move.w	(a3)+,40(a7)
		move.w	(a3)+,48(a7)
		move.w	(a3)+,56(a7)
		move.w	(a3)+,64(a7)
		move.w	(a3)+,72(a7)
		move.w	(a3)+,80(a7)
		move.w	(a3)+,88(a7)
		move.w	(a3)+,96(a7)
		move.w	(a3)+,104(a7)
		move.w	(a3)+,112(a7)
		move.w	(a3)+,120(a7)
		move.w	(a3)+,128(a7)
		move.w	(a3)+,136(a7)
		move.w	(a3)+,144(a7)
		move.w	(a3)+,152(a7)
		move.w	(a3)+,160(a7)
		nop
		nop

		rept	7
		movea.l	a4,a5
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		lea	230(a7),a7
		move.b	d0,(a1)
		move.w	(a3)+,(a7)
		move.w	(a3)+,8(a7)
		move.w	(a3)+,16(a7)
		move.w	(a3)+,24(a7)
		move.w	(a3)+,32(a7)
		move.w	(a3)+,40(a7)
		move.w	(a3)+,48(a7)
		move.w	(a3)+,56(a7)
		move.w	(a3)+,64(a7)
		move.w	(a3)+,72(a7)
		move.w	(a3)+,80(a7)
		move.w	(a3)+,88(a7)
		move.w	(a3)+,96(a7)
		move.w	(a3)+,104(a7)
		move.w	(a3)+,112(a7)
		move.w	(a3)+,120(a7)
		move.w	(a3)+,128(a7)
		move.w	(a3)+,136(a7)
		move.w	(a3)+,144(a7)
		move.w	(a3)+,152(a7)
		move.w	(a3)+,160(a7)
		nop
		nop
		endr

		movea.l	a4,a5
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		lea	32(a4),a4
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		lea	230(a7),a7
		move.b	d0,(a1)
		dbf	d7,.loop2

		movea.l	raster_cols_pos,a5
		move.l	(a5)+,d3
		move.l	a5,raster_cols_pos
		move.l	d3,$ffff8250.w
		move.l	d3,$ffff8254.w
		move.l	d3,$ffff8258.w
		move.l	d3,$ffff825c.w

		multinop	50

		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		moveq	#3,d7
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		nop
		nop
		nop

.loop3		movea.l	raster_cols_pos,a5
		move.l	(a5)+,d3
		move.l	a5,raster_cols_pos
		move.l	d3,$ffff8250.w
		move.l	d3,$ffff8254.w
		move.l	d3,$ffff8258.w
		move.l	d3,$ffff825c.w

		multinop	51

		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)

		rept	8
		multinop	83
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		endr
		dbf	d7,.loop3

		movea.l	raster_cols_pos,a5
		move.l	(a5)+,d3
		move.l	a5,raster_cols_pos
		move.l	d3,$ffff8250.w
		move.l	d3,$ffff8254.w
		move.l	d3,$ffff8258.w
		move.l	d3,$ffff825c.w
		multinop	50
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)

		rept	2
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		multinop	83
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		endr

		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		multinop	72
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		movem.l	(a5),d3-d6
		move.b	d0,(a0)
		move.b	d1,(a0)
		multinop	10
		move.b	d0,(a0)
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		move.b	d1,(a0)
		move.b	d0,(a1)
		multinop	83
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)

		rept	4
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		multinop	83
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		endr

		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		movea.l	raster_cols_pos,a5
		move.l	(a5)+,d3
		move.l	a5,raster_cols_pos
		move.l	d3,$ffff8250.w
		move.l	d3,$ffff8254.w
		move.l	d3,$ffff8258.w
		move.l	d3,$ffff825c.w
		multinop	54
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)

		rept	9
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		multinop	83
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		endr

		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		movea.l	raster_cols_pos,a5
		move.l	(a5)+,d3
		move.l	a5,raster_cols_pos
		move.l	d3,$ffff8250.w
		move.l	d3,$ffff8254.w
		move.l	d3,$ffff8258.w
		move.l	d3,$ffff825c.w
		multinop	43

		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		movem.l	(a5),d3-d6
		move.b	d0,(a0)
		move.b	d1,(a0)
		multinop	10
		move.b	d0,(a0)
		nop
		move.b	d1,(a1)
		moveq	#4,d7
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		move.b	d1,(a0)
		move.b	d0,(a1)
		nop
		nop
		nop
.loop4		multinop	80
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)

		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)

		rept	7
		multinop	83
		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)
		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		endr

		movea.l	raster_cols_pos,a5
		move.l	(a5)+,d3
		move.l	a5,raster_cols_pos
		move.l	d3,$ffff8250.w
		move.l	d3,$ffff8254.w
		move.l	d3,$ffff8258.w
		move.l	d3,$ffff825c.w
		multinop	54

		movea.l	a4,a5
		lea	32(a4),a4
		adda.w	(a2)+,a5
		move.b	d0,(a0)
		move.b	d1,(a0)
		movem.l	(a5),d3-d6
		nop
		nop
		move.b	d1,(a1)
		nop
		move.b	d0,(a1)

		movem.l	d3-d6,$ffff8240.w
		move.b	d1,(a1)
		nop
		nop
		move.b	d0,(a1)
		dbf	d7,.loop4

		addi.w	#32,background_col_offset
		cmpi.w	#$180,background_col_offset
		bne	.no_reset
		clr.w	background_col_offset
.no_reset	addq.w	#4,shifted_text_offset
		cmpi.w	#732,shifted_text_offset
		bne	.no_reset2
		clr.w	shifted_text_offset
.no_reset2	move	usp,a7
		movem.l	(a7)+,a0-a6/d0-d7
		rte

flip_screen	exg	a5,a6
		move.l	a5,d0
		lsr.l	#8,d0
		lea	$ffff8201.w,a4
		movep.w	d0,(a4)
		move.w	hertz_toggle,$ffff8240.w
		bsr	vsync
		rts



make_background_cols
		lea	back_pattern,a0
		lea	32(a0),a0
		lea	background_colour_space,a1
		lea	background_cols,a2
		move.w	#51-1,d7
.loop3		move.w	#12-1,d6
.loop2		move.w	#7,d5
		move.b	(a0)+,d1
		move.b	(a0)+,d2
		move.b	(a0)+,d3
		move.b	(a0)+,d4

.loop		moveq	#0,d0
		roxl.b	#1,d4
		roxl.b	#1,d0
		roxl.b	#1,d3
		roxl.b	#1,d0
		roxl.b	#1,d2
		roxl.b	#1,d0
		roxl.b	#1,d1
		roxl.b	#1,d0
		lsl.w	#1,d0
		movea.l	a2,a3
		adda.w	d0,a3
		move.w	(a3),(a1)+
		dbf	d5,.loop

		movem.l	-16(a1),d0-d3
		movem.l	d0-d3,(a1)
		lea	16(a1),a1
		dbf	d6,.loop2

		lea	-48(a0),a0
		dbf	d7,.loop3
		rts


start_isrs	lea	storage,a0
		move.l	$68.w,(a0)+
		move.l	$70.w,(a0)+
		move.l	$120.w,(a0)+
		move.b	$fffffa07.w,(a0)+
		move.b	$fffffa09.w,(a0)+
		move.b	$fffffa13.w,(a0)+
		move.b	$fffffa15.w,(a0)+
		move.b	$fffffa17.w,(a0)+
		move.b	$fffffa1b.w,(a0)+
		move.b	$fffffa21.w,(a0)+
		move.b	$484.w,old_key
		bclr	#3,$fffffa17.w
		clr.b	$fffffa09.w
		clr.b	$fffffa07.w
		move.b	#$21,$fffffa13.w
		move.l	#new_hbl,$68.w
		move.l	#new_vbl,$70.w
		move.l	#new_timerb,$120.w
		clr.b	$fffffa15.w
		move.b	#1,$fffffa07.w
		move.b	#1,$fffffa13.w
		bclr	#0,$484.w
		rts

clear_scrnspace	lea	scrnspace,a0
		move.l	#(bssend-scrnspace)/4,d0
.loop		clr.l	(a0)+
		sub.l	#1,d0
		bne.s	.loop
		rts	

fade2black	lea	$ffff8242.w,a0	;fade to black
		clr.w	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		clr.l	(a0)+
		move.w	#6,d6
.loop		move.w	#$25,-(sp)
		trap	#14
		addq.w	#2,sp
		subi.w	#$111,$ffff8240.w
		dbf	d6,.loop
		rts

shift_text	lea	screen_text,a0
		lea	font,a1
		lea	shifted_text,a2
		move.w	#19-1,d6
.down		move.l	d6,-(a7)
		move.w	#40-1,d7
.across		movea.l	a1,a3
		moveq	#0,d0
		move.b	(a0)+,d0
		subi.b	#$20,d0
		lsl.w	#3,d0		;*8
		adda.l	d0,a3
		bsr	.print_char
		addq.l	#1,a2
		dbf	d7,.across
		lea	-40(a2),a2
		bsr	.shift_char
		move.l	(a7)+,d6
		dbf	d6,.down
		rts

.print_char	move.b	(a3)+,(a2)
		move.b	(a3)+,42(a2)
		move.b	(a3)+,84(a2)
		move.b	(a3)+,126(a2)
		move.b	(a3)+,168(a2)
		move.b	(a3)+,210(a2)
		move.b	(a3)+,252(a2)
		move.b	(a3)+,294(a2)
		rts
.shift_char	moveq	#15-1,d0
.loop2		moveq	#14-1,d7
.loop		movem.l	(a2)+,d1-d6
		roxr.l	#1,d1
		roxr.l	#1,d2
		roxr.l	#1,d3
		roxr.l	#1,d4
		roxr.l	#1,d5
		roxr.l	#1,d6
		movem.l	d1-d6,312(a2)
		dbf	d7,.loop
		dbf	d0,.loop2
		lea	336(a2),a2
		rts


set_up		lea	bssstart,a0
		move.l	#bssend-bssstart,d0
		lsr.w	#2,d0
		moveq	#0,d1
.clear		move.l	d1,(a0)+
		sub.l	#1,d0
		bne.s	.clear

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,old_stack

		ifne	FINAL
		move.l	#.go,$24.w
		ENDC
.go
		move.b	$ffff8260.w,old_rez

		move.b	#$12,$fffffc02.w
		movem.l	$ffff8240.w,d0-d7
		movem.l	d0-d7,org_pal
		jsr	shift_text

		move.l	$44e.w,org_base
		clr.b	$ffff8260.w

		move.l	#screens,d0	;calc screens
		clr.b	d0
		move.l	d0,a6
		move.l	d0,a5
		add.l	#64000,a5
		move.l	a5,d0
		lsr.l	#8,d0
		lea	$ffff8201.w,a4
		movep.w	d0,(a4)

		bsr	clear_scrnspace

		lea	initlogo+34,a0	;show init logo
		move.l	a5,a1
		move.w	#32000/4-1,d7
.loop		move.l	(a0)+,(a1)+
		dbf	d7,.loop
		movem.l	initlogo+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.w	#10000,d7
.delay		move.w	#$b,-(sp)
		trap	#1
		addq.w	#2,sp
		tst.l	d0
		bmi.s	.yes
		dbf	d7,.delay
		bra.s	.no
.yes		move.w	#7,-(sp)
		trap	#1
		addq.w	#2,sp
.no
		bsr	clear_scrnspace
		bsr	fade2black
		jsr	make_background_cols
		jsr	build_main_screen	;put logos + background

		moveq	#1,d0
		jsr	music

		rts

build_main_screen
		movem.l	a5-a6,-(a7)
		lea	188+230(a5),a5
		lea	188+230(a6),a6
		lea	background_mask,a0
		movea.l	a6,a1
		movea.l	a5,a2
		move.w	#8,d6
.loop2		move.l	(a0)+,d0
		move.l	(a0)+,d1
		move.w	#28-1,d7
.loop		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d0,(a2)+
		move.l	d1,(a2)+
		dbf	d7,.loop
		addq.w	#6,a1
		addq.w	#6,a2
		dbf	d6,.loop2

*** Make background
		movea.l	a6,a0
		lea	8*230(a5),a5
		lea	8*230(a6),a6
		move.w	#33-1,d6
.down		move.w	#46-1,d7		;print 8*230 bytes
.8rows		movem.l	(a0)+,a1-a4/d0-d5
		movem.l	a1-a4/d0-d5,(a6)
		movem.l	a1-a4/d0-d5,(a5)
		lea	40(a6),a6
		lea	40(a5),a5
		dbf	d7,.8rows
		lea	-8*230(a0),a0
		dbf	d6,.down

		movem.l	(a7),a5-a6	;screens are in a5/a6
		lea	2*230+30(a5),a5
		lea	2*230+30(a6),a6
		lea	mainlogo,a0
		move.w	#81-1,d7
.print_main_logo
		movem.l	(a0)+,a4/d0-d6
		movem.l	a4/d0-d6,(a5)
		movem.l	a4/d0-d6,(a6)
		movem.l	(a0)+,a4/d0-d6
		movem.l	a4/d0-d6,32(a5)
		movem.l	a4/d0-d6,32(a6)
		movem.l	(a0)+,a4/d0-d6
		movem.l	a4/d0-d6,64(a5)
		movem.l	a4/d0-d6,64(a6)
		lea	230(a6),a6	;1 line of full scrn=230 bytes
		lea	230(a5),a5
		dbf	d7,.print_main_logo

*** Put members list on screen
		movem.l	(a7),a5-a6	;screens into a5/a6
		lea	(35*230)+220(a5),a5
		lea	(35*230)+220(a6),a6
		lea	members,a0		;put members list on...
		move.w	#25-1,d7
.print_members_list
		movem.l	(a0)+,a1-a3/d0-d6
		movem.l	a1-a3/d0-d6,(a5)
		movem.l	a1-a3/d0-d6,(a6)
		lea	230(a6),a6
		lea	230(a5),a5
		dbf	d7,.print_members_list


*** members on right as well
		movem.l	(a7),a5-a6
		lea	(35*230)+220+(8*18)(a5),a5
		lea	(35*230)+220+(8*18)(a6),a6
		move.w	#25-1,d7
.put_right	movem.l	(a0)+,a1-a3/d0-d6
		movem.l	a1-a3/d0-d6,(a5)
		movem.l	a1-a3/d0-d6,(a6)
		lea	230(a6),a6
		lea	230(a5),a5
		dbf	d7,.put_right
		movem.l	(a7)+,a5-a6
		rts


*******************************
	section data
*******************************

screen_text
	dc.b	"        PERSISTENCE OF VISION 147       "
	dc.b	"        *************************       "
	dc.b	"                                        "
	dc.b	"  1:.BRACE DEMO (FIXED FOR STE BY MSD)  "
	dc.b	"  2:.................. GESOX INTRO 1    "
	dc.b	"  3:.................. AMAZINE 4 INTRO  "
	dc.b	"  4:..... EXCELLENCE IN ART MUSIC DEMO  "
	dc.b	"  5:.......... RISK INTRO 1 (OVER 16?)  "
	dc.b	"  6:..................... RISK INTRO 2  "
	dc.b	"  7:.................... CLAN 20 INTRO  "
	dc.b	"  8:.............. PURE ENERGY MENU 38  "
	dc.b	"  9:........................... COPIER  "
	dc.b	"                                        "
	dc.b	"        RELEASE DATE: 15-JUNE-1994      "
	dc.b	" MUSIC BY JEDI/SECTOR ONE FROM EIA DEMO "
	dc.b	" MENU CODED BY MAC SYS DATA BASED UPON  "
	dc.b	"      CODE BY PILGRIM OF PULSION.       "
	dc.b	"  DO NOT WRITE TO THE P.O.V. PO BOX AS  "
	dc.b	" IT NO LONGER EXISTS - NEW ADDRESS SOON ",0
	even
background_mask
	dc.w	%0101010101010101,%0011001100110011,%0000111100001111,0
	dc.w	%0101010101010101,%0011001100110011,%0000111100001111,0
	dc.w	%0101010101010101,%0011001100110011,%0000111100001111,0
	dc.w	%0101010101010101,%0011001100110011,%0000111100001111,0
	dc.w	%0101010101010101,%0011001100110011,%0000111100001111,0
	dc.w	%0101010101010101,%0011001100110011,%0000111100001111,0
	dc.w	%0101010101010101,%0011001100110011,%0000111100001111,0
	dc.w	%0101010101010101,%0011001100110011,%0000111100001111,0
	dc.w	%1100110011001100,%0101010101010101,%0000001111111100,%11


music		incbin	i_wonder.mus

background_cols	
back_pattern	incbin	backgnd.dat
		dcb.w	20

sine_table
	dc.w	4,4,4,4,4,4,4,4
	dc.w	2,2,2,2,2,0,0,0
	dc.w	$E,$E,$E,$C,$C,$C,$A,$A
	dc.w	8,8,6,6,4,4,2,2
	dc.w	0,0,$E,$C,$C,$A,8,8
	dc.w	6,4,2,2,0,$E,$C,$A
	dc.w	8,8,6,4,2,0,$E,$C
	dc.w	$A,8,6,4,2,2,0,$E
	dc.w	$A,8,6,4,2,0,$E,$C
	dc.w	$A,8,6,4,2,0,$E,$A
	dc.w	8,6,4,2,0,$E,$C,8
	dc.w	6,4,2,0,$E,$C,8,6
	dc.w	4,2,0,$E,$C,$A,6,4
	dc.w	2,0,$E,$C,$A,8,6,4
	dc.w	2,0,$E,$C,$A,6,4,2
	dc.w	0,0,$E,$C,$A,8,6,4
	dc.w	2,0,$E,$C,$C,$A,8,6
	dc.w	4,2,2,0,$E,$C,$C,$A
	dc.w	8,8,6,4,4,2,2,0
	dc.w	0,$E,$E,$C,$C,$A,$A,8
	dc.w	8,8,6,6,6,4,4,4
	dc.w	2,2,2,2,2,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,2,2,2,2
	dc.w	2,4,4,4,6,6,6,8
	dc.w	8,8,$A,$A,$C,$C,$E,$E
	dc.w	0,0,2,2,4,4,6,8
	dc.w	8,$A,$C,$C,$E,0,2,2
	dc.w	4,6,8,$A,$C,$C,$E,0
	dc.w	2,4,6,8,$A,$C,$E,0
	dc.w	2,2,4,6,$A,$C,$E,0
	dc.w	2,4,6,8,$A,$C,$E,0
	dc.w	2,4,6,$A,$C,$E,0,2
	dc.w	4,6,8,$C,$E,0,2,4
	dc.w	6,8,$C,$E,0,2,4,6
	dc.w	8,$A,$E,0,2,4,6,8
	dc.w	$A,$C,$E,0,2,4,6,8
	dc.w	$A,$E,0,2,4,4,6,8
	dc.w	$A,$C,$E,0,2,4,6,8
	dc.w	8,$A,$C,$E,0,2,2,4
	dc.w	6,8,8,$A,$C,$C,$E,0
	dc.w	0,2,2,4,4,6,6,8
	dc.w	8,$A,$A,$C,$C,$C,$E,$E
	dc.w	$E,0,0,0,2,2,2,2
	dc.w	2,4,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	2,2,2,2,2,0,0,0
	dc.w	$E,$E,$E,$C,$C,$C,$A,$A
	dc.w	8,8,6,6,4,4,2,2
	dc.w	0,0,$E,$C,$C,$A,8,8
	dc.w	6,4,2,2,0,$E,$C,$A
	dc.w	8,8,6,4,2,0,$E,$C
	dc.w	$A,8,6,4,2,2,0,$E
	dc.w	$A,8,6,4,2,0,$E,$C
	dc.w	$A,8,6,4,2,0,$E,$A
	dc.w	8,6,4,2,0,$E,$C,8
	dc.w	6,4,2,0,$E,$C,8,6
	dc.w	4,2,0,$E,$C,$A,6,4
	dc.w	2,0,$E,$C,$A,8,6,4
	dc.w	2,0,$E,$C,$A,6,4,2
	dc.w	0,0,$E,$C,$A,8,6,4
	dc.w	2,0,$E,$C,$C,$A,8,6
	dc.w	4,2,2,0,$E,$C,$C,$A
	dc.w	8,8,6,4,4,2,2,0
	dc.w	0,$E,$E,$C,$C,$A,$A,8
	dc.w	8,8,6,6,6,4,4,4
	dc.w	2,2,2,2,2,0,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,2,2,2,2
	dc.w	2,4,4,4,6,6,6,8
	dc.w	8,8,$A,$A,$C,$C,$E,$E
	dc.w	0,0,2,2,4,4,6,8
	dc.w	8,$A,$C,$C,$E,0,2,2
	dc.w	4,6,8,$A,$C,$C,$E,0
	dc.w	2,4,6,8,$A,$C,$E,0
	dc.w	2,2,4,6,$A,$C,$E,0
	dc.w	2,4,6,8,$A,$C,$E,0
	dc.w	2,4,6,$A,$C,$E,0,2
	dc.w	4,6,8,$C,$E,0,2,4
	dc.w	6,8,$C,$E,0,2,4,6
	dc.w	8,$A,$E,0,2,4,6,8
	dc.w	$A,$C,$E,0,2,4,6,8
	dc.w	$A,$E,0,2,4,4,6,8
	dc.w	$A,$C,$E,0,2,4,6,8
	dc.w	8,$A,$C,$E,0,2,2,4
	dc.w	6,8,8,$A,$C,$C,$E,0
	dc.w	0,2,2,4,4,6,6,8
	dc.w	8,$A,$A,$C,$C,$C,$E,$E
	dc.w	$E,0,0,0,2,2,2,2
	dc.w	2,4,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,2,2,2,2,2
	dc.w	2,2,0,0,0,0,0,$E
	dc.w	$E,$E,$E,$C,$C,$C,$C,$A
	dc.w	$A,$A,8,8,8,6,6,6
	dc.w	4,4,2,2,2,0,0,$E
	dc.w	$E,$C,$C,$A,$A,$A,8,8
	dc.w	6,6,4,4,2,0,0,$E
	dc.w	$E,$C,$C,$A,$A,8,8,6
	dc.w	4,4,2,2,0,$E,$E,$C
	dc.w	$C,$A,8,8,6,6,4,2
	dc.w	2,0,0,$E,$C,$C,$A,$A
	dc.w	8,6,6,4,4,2,0,0
	dc.w	$E,$E,$C,$A,$A,8,8,6
	dc.w	4,4,2,2,0,0,$E,$E
	dc.w	$C,$A,$A,8,8,6,6,4
	dc.w	4,2,2,2,0,0,$E,$E
	dc.w	$C,$C,$A,$A,$A,8,8,6
	dc.w	6,6,4,4,4,2,2,2
	dc.w	0,0,0,0,$E,$E,$E,$E
	dc.w	$C,$C,$C,$C,$C,$A,$A,$A
	dc.w	$A,$A,$A,$A,8,8,8,8
	dc.w	8,8,8,8,8,8,8,8
	dc.w	8,8,8,8,8,8,8,$A
	dc.w	$A,$A,$A,$A,$A,$A,$C,$C
	dc.w	$C,$C,$C,$E,$E,$E,$E,0
	dc.w	0,0,0,2,2,2,4,4
	dc.w	4,6,6,6,8,8,$A,$A
	dc.w	$A,$C,$C,$E,$E,0,0,2
	dc.w	2,2,4,4,6,6,8,8
	dc.w	$A,$C,$C,$E,$E,0,0,2
	dc.w	2,4,4,6,8,8,$A,$A
	dc.w	$C,$E,$E,0,0,2,4,4
	dc.w	6,6,8,$A,$A,$C,$C,$E
	dc.w	0,0,2,2,4,6,6,8
	dc.w	8,$A,$C,$C,$E,$E,0,2
	dc.w	2,4,4,6,8,8,$A,$A
	dc.w	$C,$C,$E,$E,0,2,2,4
	dc.w	4,6,6,8,8,$A,$A,$A
	dc.w	$C,$C,$E,$E,0,0,2,2
	dc.w	2,4,4,6,6,6,8,8
	dc.w	8,$A,$A,$A,$C,$C,$C,$C
	dc.w	$E,$E,$E,$E,0,0,0,0
	dc.w	0,2,2,2,2,2,2,2
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,2,2,2,2,2
	dc.w	2,2,0,0,0,0,0,$E
	dc.w	$E,$E,$E,$C,$C,$C,$C,$A
	dc.w	$A,$A,8,8,8,6,6,6
	dc.w	4,4,2,2,2,0,0,$E
	dc.w	$E,$C,$C,$A,$A,$A,8,8
	dc.w	6,6,4,4,2,0,0,$E
	dc.w	$E,$C,$C,$A,$A,8,8,6
	dc.w	4,4,2,2,0,$E,$E,$C
	dc.w	$C,$A,8,8,6,6,4,2
	dc.w	2,0,0,$E,$C,$C,$A,$A
	dc.w	8,6,6,4,4,2,0,0
	dc.w	$E,$E,$C,$A,$A,8,8,6
	dc.w	4,4,2,2,0,0,$E,$E
	dc.w	$C,$A,$A,8,8,6,6,4
	dc.w	4,2,2,2,0,0,$E,$E
	dc.w	$C,$C,$A,$A,$A,8,8,6
	dc.w	6,6,4,4,4,2,2,2
	dc.w	0,0,0,0,$E,$E,$E,$E
	dc.w	$C,$C,$C,$C,$C,$A,$A,$A
	dc.w	$A,$A,$A,$A,8,8,8,8
	dc.w	8,8,8,8,8,8,8,8
	dc.w	8,8,8,8,8,8,8,$A
	dc.w	$A,$A,$A,$A,$A,$A,$C,$C
	dc.w	$C,$C,$C,$E,$E,$E,$E,0
	dc.w	0,0,0,2,2,2,4,4
	dc.w	4,6,6,6,8,8,$A,$A
	dc.w	$A,$C,$C,$E,$E,0,0,2
	dc.w	2,2,4,4,6,6,8,8
	dc.w	$A,$C,$C,$E,$E,0,0,2
	dc.w	2,4,4,6,8,8,$A,$A
	dc.w	$C,$E,$E,0,0,2,4,4
	dc.w	6,6,8,$A,$A,$C,$C,$E
	dc.w	0,0,2,2,4,6,6,8
	dc.w	8,$A,$C,$C,$E,$E,0,2
	dc.w	2,4,4,6,8,8,$A,$A
	dc.w	$C,$C,$E,$E,0,2,2,4
	dc.w	4,6,6,8,8,$A,$A,$A
	dc.w	$C,$C,$E,$E,0,0,2,2
	dc.w	2,4,4,6,6,6,8,8
	dc.w	8,$A,$A,$A,$C,$C,$C,$C
	dc.w	$E,$E,$E,$E,0,0,0,0
	dc.w	0,2,2,2,2,2,2,2
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,4,2,2,2,2
	dc.w	2,2,2,0,0,0,0,0
	dc.w	$E,$E,$E,$E,$C,$C,$C,$C
	dc.w	$A,$A,$A,8,8,8,6,6
	dc.w	6,4,4,2,2,2,0,0
	dc.w	$E,$E,$C,$C,$A,$A,$A,8
	dc.w	8,6,6,4,4,2,0,0
	dc.w	$E,$E,$C,$C,$A,$A,8,8
	dc.w	6,4,4,2,2,0,$E,$E
	dc.w	$C,$C,$A,8,8,6,6,4
	dc.w	2,2,0,0,$E,$C,$C,$A
	dc.w	$A,8,6,6,4,4,2,0
	dc.w	0,$E,$E,$C,$A,$A,8,8
	dc.w	6,4,4,2,2,0,0,$E
	dc.w	$E,$C,$A,$A,8,8,6,6
	dc.w	4,4,2,2,2,0,0,$E
	dc.w	$E,$C,$C,$A,$A,$A,8,8
	dc.w	6,6,6,4,4,4,2,2
	dc.w	2,0,0,0,0,$E,$E,$E
	dc.w	$E,$C,$C,$C,$C,$C,$A,$A
	dc.w	$A,$A,$A,$A,$A,8,8,8
	dc.w	8,8,8,8,8,8,8,8
	dc.w	8,8,8,8,8,8,8,8
	dc.w	8,6,6,6,6,6,6,6
	dc.w	4,4,4,4,4,2,2,2
	dc.w	2,0,0,0,0,$E,$E,$E
	dc.w	$C,$C,$C,$A,$A,$A,8,8
	dc.w	6,6,6,4,4,2,2,0
	dc.w	0,$E,$E,$E,$C,$C,$A,$A
	dc.w	8,8,6,4,4,2,2,0
	dc.w	0,$E,$E,$C,$C,$A,8,8
	dc.w	6,6,4,2,2,0,0,$E
	dc.w	$C,$C,$A,$A,8,6,6,4
	dc.w	4,2,0,0,$E,$E,$C,$A
	dc.w	$A,8,8,6,4,4,2,2
	dc.w	0,$E,$E,$C,$C,$A,8,8
	dc.w	6,6,4,4,2,2,0,$E
	dc.w	$E,$C,$C,$A,$A,8,8,6
	dc.w	6,6,4,4,2,2,0,0
	dc.w	$E,$E,$E,$C,$C,$A,$A,$A
	dc.w	8,8,8,6,6,6,4,4
	dc.w	4,4,2,2,2,2,0,0
	dc.w	0,0,0,$E,$E,$E,$E,$E
	dc.w	$E,$E,$C,$C,$C,$C,$C,$C
	dc.w	$C,$C,$C,$C,$C,$C,$C,$C
	dc.w	$C,$C,$C,$C,$C,$E,$E,$E
	dc.w	$E,$E,$E,$E,0,0,0,0
	dc.w	0,2,2,2,2,4,4,4
	dc.w	4,6,6,6,8,8,8,$A
	dc.w	$A,$A,$C,$C,$E,$E,$E,0
	dc.w	0,2,2,4,4,6,6,6
	dc.w	8,8,$A,$A,$C,$C,$E,0
	dc.w	0,2,2,4,4,6,6,8
	dc.w	8,$A,$C,$C,$E,$E,0,2
	dc.w	2,4,4,6,8,8,$A,$A
	dc.w	$C,$E,$E,0,0,2,4,4
	dc.w	6,6,8,$A,$A,$C,$C,$E
	dc.w	0,0,2,2,4,6,6,8
	dc.w	8,$A,$C,$C,$E,$E,0,0
	dc.w	2,2,4,6,6,8,8,$A
	dc.w	$A,$C,$C,$E,$E,$E,0,0
	dc.w	2,2,4,4,6,6,6,8
	dc.w	8,$A,$A,$A,$C,$C,$C,$E
	dc.w	$E,$E,0,0,0,0,2,2
	dc.w	2,2,4,4,4,4,4,6
	dc.w	6,6,6,6,6,6,8,8
	dc.w	8,8,8,8,8,8,8,8
	dc.w	8,8,8,8,8,8,8,8
	dc.w	8,8,$A,$A,$A,$A,$A,$A
	dc.w	$A,$C,$C,$C,$C,$C,$E,$E
	dc.w	$E,$E,0,0,0,0,2,2,2,4,4,4
	dc.w	6,6,6,8,8,$A,$A,$A
	dc.w	$C,$C,$E,$E,0,0,2,2
	dc.w	2,4,4,6,6,8,8,$A
	dc.w	$C,$C,$E,$E,0,0,2,2
	dc.w	4,4,6,8,8,$A,$A,$C
	dc.w	$E,$E,0,0,2,4,4,6
	dc.w	6,8,$A,$A,$C,$C,$E,0
	dc.w	0,2,2,4,6,6,8,8
	dc.w	$A,$C,$C,$E,$E,0,2,2
	dc.w	4,4,6,8,8,$A,$A,$C
	dc.w	$C,$E,$E,0,2,2,4,4
	dc.w	6,6,8,8,$A,$A,$A,$C
	dc.w	$C,$E,$E,0,0,2,2,2
	dc.w	4,4,6,6,6,8,8,8
	dc.w	$A,$A,$A,$C,$C,$C,$C,$E
	dc.w	$E,$E,$E,0,0,0,0,0
	dc.w	2,2,2,2,2,2,2,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,2,2,2,2,2,0,0
	dc.w	0,$E,$E,$E,$C,$C,$C,$A
	dc.w	$A,8,8,6,6,4,4,2
	dc.w	2,0,0,$E,$C,$C,$A,8
	dc.w	8,6,4,2,2,0,$E,$C
	dc.w	$A,8,8,6,4,2,0,$E
	dc.w	$C,$A,8,6,4,2,2,0
	dc.w	$E,$A,8,6,4,2,0,$E
	dc.w	$C,$A,8,6,4,2,0,$E
	dc.w	$A,8,6,4,2,0,$E,$C
	dc.w	8,6,4,2,0,$E,$C,8
	dc.w	6,4,2,0,$E,$C,$A,6
	dc.w	4,2,0,$E,$C,$A,8,6
	dc.w	4,2,0,$E,$C,$A,6,4
	dc.w	2,0,0,$E,$C,$A,8,6
	dc.w	4,2,0,$E,$C,$C,$A,8
	dc.w	6,4,2,2,0,$E,$C,$C
	dc.w	$A,8,8,6,4,4,2,2
	dc.w	0,0,$E,$E,$C,$C,$A,$A
	dc.w	8,8,8,6,6,6,4,4
	dc.w	4,2,2,2,2,2,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,2,2,2
	dc.w	2,2,4,4,4,6,6,6
	dc.w	8,8,8,$A,$A,$C,$C,$E
	dc.w	$E,0,0,2,2,4,4,6
	dc.w	8,8,$A,$C,$C,$E,0,2
	dc.w	2,4,6,8,$A,$C,$C,$E
	dc.w	0,2,4,6,8,$A,$C,$E
	dc.w	0,2,2,4,6,$A,$C,$E
	dc.w	0,2,4,6,8,$A,$C,$E
	dc.w	0,2,4,6,$A,$C,$E,0
	dc.w	2,4,6,8,$C,$E,0,2
	dc.w	4,6,8,$C,$E,0,2,4
	dc.w	6,8,$A,$E,0,2,4,6
	dc.w	8,$A,$C,$E,0,2,4,6
	dc.w	8,$A,$E,0,2,4,4,6
	dc.w	8,$A,$C,$E,0,2,4,6
	dc.w	8,8,$A,$C,$E,0,2,2
	dc.w	4,6,8,8,$A,$C,$C,$E
	dc.w	0,0,2,2,4,4,6,6
	dc.w	8,8,$A,$A,$C,$C,$C,$E
	dc.w	$E,$E,0,0,0,2,2,2
	dc.w	2,2,4,4,4,4,4,4
	dc.w	4,4,4,4,4,4,4,4
	dc.w	4,2,2,2,2,2,0,0
	dc.w	0,$E,$E,$E,$C,$C,$C,$A
	dc.w	$A,8,8,6,6,4,4,2
	dc.w	2,0,0,$E,$C,$C,$A,8
	dc.w	8,6,4,2,2,0,$E,$C
	dc.w	$A,8,8,6,4,2,0,$E
	dc.w	$C,$A,8,6,4,2,2,0
	dc.w	$E,$A,8,6,4,2,0,$E
	dc.w	$C,$A,8,6,4,2,0,$E
	dc.w	$A,8,6,4,2,0,$E,$C
	dc.w	8,6,4,2,0,$E,$C,8
	dc.w	6,4,2,0,$E,$C,$A,6
	dc.w	4,2,0,$E,$C,$A,8,6
	dc.w	4,2,0,$E,$C,$A,6,4
	dc.w	2,0,0,$E,$C,$A,8,6
	dc.w	4,2,0,$E,$C,$C,$A,8
	dc.w	6,4,2,2,0,$E,$C,$C
	dc.w	$A,8,8,6,4,4,2,2
	dc.w	0,0,$E,$E,$C,$C,$A,$A
	dc.w	8,8,8,6,6,6,4,4
	dc.w	4,2,2,2,2,2,0,0
	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,2,2,2
	dc.w	2,2,4,4,4,6,6,6
	dc.w	8,8,8,$A,$A,$C,$C,$E
	dc.w	$E,0,0,2,2,4,4,6
	dc.w	8,8,$A,$C,$C,$E,0,2
	dc.w	2,4,6,8,$A,$C,$C,$E
	dc.w	0,2,4,6,8,$A,$C,$E
	dc.w	0,2,2,4,6,$A,$C,$E
	dc.w	0,2,4,6,8,$A,$C,$E
	dc.w	0,2,4,6,$A,$C,$E,0
	dc.w	2,4,6,8,$C,$E,0,2
	dc.w	4,6,8,$C,$E,0,2,4
	dc.w	6,8,$A,$E,0,2,4,6
	dc.w	8,$A,$C,$E,0,2,4,6
	dc.w	8,$A,$E,0,2,4,4,6
	dc.w	8,$A,$C,$E,0,2,4,6
	dc.w	8,8,$A,$C,$E,0,2,2
	dc.w	4,6,8,8,$A,$C,$C,$E
	dc.w	0,0,2,2,4,4,6,6
	dc.w	8,8,$A,$A,$C,$C,$C,$E
	dc.w	$E,$E,0,0,0,2,2,2
	dc.w	2,2,4,4,4,4,4,4
	dc.w	4,4
sine_table_end

mainlogo	incbin	mainlogo.dat

initlogo	incbin	initlogo.pi1

ripple_table
	dc.w	0,	0
	dc.w	0,	0
	dc.w	0,	0
	dc.w	1*336,	0
	dc.w	1*336,	0
	dc.w	2*336,	0
	dc.w	3*336,	0
	dc.w	4*336,	0
	dc.w	5*336,	0
	dc.w	7*336,	0
	dc.w	8*336,	0
	dc.w	10*336,	0
	dc.w	12*336,	0
	dc.w	13*336,	0
	dc.w	15*336,	0
	dc.w	2*336,	8
	dc.w	4*336,	8
	dc.w	6*336,	8
	dc.w	8*336,	8
	dc.w	11*336,	8
	dc.w	13*336,	8
	dc.w	15*336,	8
	dc.w	2*336,	16
	dc.w	4*336,	16
	dc.w	7*336,	16
	dc.w	9*336,	16
	dc.w	11*336,	16
	dc.w	14*336,	16
	dc.w	0,	24
	dc.w	2*336,	24
	dc.w	5*336,	24
	dc.w	7*336,	24
	dc.w	9*336,	24
	dc.w	10*336,	24
	dc.w	12*336,	24
	dc.w	14*336,	24
	dc.w	15*336,	24
	dc.w	1*336,	32
	dc.w	2*336,	32
	dc.w	3*336,	32
	dc.w	4*336,	32
	dc.w	5*336,	32
	dc.w	5*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	7*336,	32
	dc.w	7*336,	32
	dc.w	8*336,	32
	dc.w	9*336,	32
	dc.w	10*336,	32
	dc.w	11*336,	32
	dc.w	13*336,	32
	dc.w	14*336,	32
	dc.w	0,	40
	dc.w	2*336,	40
	dc.w	3*336,	40
	dc.w	5*336,	40
	dc.w	8*336,	40
	dc.w	10*336,	40
	dc.w	12*336,	40
	dc.w	14*336,	40
	dc.w	1*336,	48
	dc.w	3*336,	48
	dc.w	5*336,	48
	dc.w	8*336,	48
	dc.w	10*336,	48
	dc.w	13*336,	48
	dc.w	15*336,	48
	dc.w	1*336,	56
	dc.w	4*336,	56
	dc.w	6*336,	56
	dc.w	8*336,	56
	dc.w	11*336,	56
	dc.w	13*336,	56
	dc.w	15*336,	56
	dc.w	0,	64
	dc.w	2*336,	64
	dc.w	4*336,	64
	dc.w	5*336,	64
	dc.w	7*336,	64
	dc.w	8*336,	64
	dc.w	9*336,	64
	dc.w	10*336,	64
	dc.w	11*336,	64
	dc.w	11*336,	64
	dc.w	12*336,	64
	dc.w	12*336,	64
	dc.w	12*336,	64
	dc.w	12*336,	64
	dc.w	12*336,	64
	dc.w	11*336,	64
	dc.w	11*336,	64
	dc.w	10*336,	64
	dc.w	9*336,	64
	dc.w	8*336,	64
	dc.w	7*336,	64
	dc.w	5*336,	64
	dc.w	4*336,	64
	dc.w	2*336,	64
	dc.w	0,	64
	dc.w	15*336,	56
	dc.w	13*336,	56
	dc.w	10*336,	56
	dc.w	8*336,	56
	dc.w	6*336,	56
	dc.w	4*336,	56
	dc.w	1*336,	56
	dc.w	15*336,	48
	dc.w	13*336,	48
	dc.w	10*336,	48
	dc.w	8*336,	48
	dc.w	5*336,	48
	dc.w	3*336,	48
	dc.w	1*336,	48
	dc.w	14*336,	40
	dc.w	12*336,	40
	dc.w	10*336,	40
	dc.w	7*336,	40
	dc.w	5*336,	40
	dc.w	3*336,	40
	dc.w	2*336,	40
	dc.w	0,	40
	dc.w	14*336,	32
	dc.w	13*336,	32
	dc.w	11*336,	32
	dc.w	10*336,	32
	dc.w	9*336,	32
	dc.w	8*336,	32
	dc.w	7*336,	32
	dc.w	7*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	5*336,	32
	dc.w	5*336,	32
	dc.w	4*336,	32
	dc.w	3*336,	32
	dc.w	2*336,	32
	dc.w	1*336,	32
	dc.w	15*336,	24
	dc.w	14*336,	24
	dc.w	12*336,	24
	dc.w	10*336,	24
	dc.w	9*336,	24
	dc.w	7*336,	24
	dc.w	4*336,	24
	dc.w	2*336,	24
	dc.w	0,	24
	dc.w	14*336,	16
	dc.w	11*336,	16
	dc.w	9*336,	16
	dc.w	7*336,	16
	dc.w	4*336,	16
	dc.w	2*336,	16
	dc.w	15*336,	8
	dc.w	13*336,	8
	dc.w	11*336,	8
	dc.w	8*336,	8
	dc.w	6*336,	8
	dc.w	4*336,	8
	dc.w	1*336,	8
	dc.w	15*336,	0
	dc.w	13*336,	0
	dc.w	12*336,	0
	dc.w	10*336,	0
	dc.w	8*336,	0
	dc.w	7*336,	0
	dc.w	5*336,	0
	dc.w	4*336,	0
	dc.w	3*336,	0
	dc.w	2*336,	0
	dc.w	1*336,	0
	dc.w	1*336,	0
	dc.w	0,	0
	dc.w	0,	0
	dc.w	0,	0
	dc.w	0,	0
	dc.w	0,	0
	dc.w	0,	0
	dc.w	1*336,	0
	dc.w	1*336,	0
	dc.w	2*336,	0
	dc.w	3*336,	0
	dc.w	4*336,	0
	dc.w	5*336,	0
	dc.w	7*336,	0
	dc.w	8*336,	0
	dc.w	10*336,	0
	dc.w	12*336,	0
	dc.w	13*336,	0
	dc.w	15*336,	0
	dc.w	2*336,	8
	dc.w	4*336,	8
	dc.w	6*336,	8
	dc.w	8*336,	8
	dc.w	11*336,	8
	dc.w	13*336,	8
	dc.w	15*336,	8
	dc.w	2*336,	16
	dc.w	4*336,	16
	dc.w	7*336,	16
	dc.w	9*336,	16
	dc.w	11*336,	16
	dc.w	14*336,	16
	dc.w	0,	24
	dc.w	2*336,	24
	dc.w	5*336,	24
	dc.w	7*336,	24
	dc.w	9*336,	24
	dc.w	10*336,	24
	dc.w	12*336,	24
	dc.w	14*336,	24
	dc.w	15*336,	24
	dc.w	1*336,	32
	dc.w	2*336,	32
	dc.w	3*336,	32
	dc.w	4*336,	32
	dc.w	5*336,	32
	dc.w	5*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32
	dc.w	6*336,	32


raster_cols	dc.w	$066,$066
		dc.w	$055,$055
		dc.w	$054,$054
		dc.w	$063,$063
		dc.w	$072,$072
		dc.w	$171,$171
		dc.w	$270,$270
		dc.w	$370,$370
		dc.w	$470,$470
		dc.w	$570,$570
		dc.w	$670,$670
		dc.w	$770,$770
		dc.w	$761,$761
		dc.w	$752,$752
		dc.w	$743,$743
		dc.w	$734,$734
		dc.w	$725,$725
		dc.w	$716,$716
		dc.w	$707,$707
		dc.w	$606,$606
		dc.w	$505,$505

members	incbin	members.dat

font	incbin	font.dat

demo_keys
	dc.b	0, $02		;key 1
	dc.b	1, $03		;key 2
	dc.b	2, $04		;key 3
	dc.b	3, $05		;key 4
	dc.b	4, $06		;key 5
	dc.b	5, $07		;key 6
	dc.b	6, $08		;key 7
	dc.b	7, $08		;key 8
	dc.b	8, $08		;key 9

	dc.b	0, $6d		;keypad 1
	dc.b	1, $6e		;keypad 2
	dc.b	2, $6f		;keypad 3
	dc.b	3, $6a		;keypad 4
	dc.b	4, $6b		;keypad 5
	dc.b	5, $6C		;keypad 6
	dc.b	6, $67		;keypad 7
	dc.b	7, $68		;keypad 8
	dc.b	8, $69		;keypad 9
	dc.b	-1, -1

filename_table	dc.l	exec1,exec2,exec3,exec4,exec5,exec6,exec7,exec8,exec9
exec1	dc.b	"brace",0
	even
exec2	dc.b	"gesox1",0
	even
exec3	dc.b	"amazine4",0
	even
exec4	dc.b	"x_in_art",0
	even
exec5	dc.b	"risk1",0
	even
exec6	dc.b	"risk2",0
	even
exec7	dc.b	"clan20",0
	even
exec8	dc.b	"pure38",0
	even
exec9	dc.b	"copier.pov",0
	even

	section bss
bssstart

org_base		ds.l	1
hertz_toggle		ds.w	1
hertz_delay		ds.w	1
key			ds.w	1
org_pal			ds.w	16
raster_cols_pos		ds.l	1
shifted_text_offset	ds.w	1
shifted_text		ds.b	102144
background_col_offset	ds.w	1
background_colour_space	ds.b	20000
sine_table_offset	ds.w	1

vsync_flag		ds.w	1

old_stack		ds.l	1
old_key			ds.b	1
		even
old_rez			ds.w	1
storage			ds.b	20

		even
scrnspace
		ds.b	256
screens		ds.b	102900
		ds.b	26100
bssend
