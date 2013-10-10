
	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	$c(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1c(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	bsr	set_super
	dc.w	$a00a		;hide mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	lea	pic+34,a0
	move.l	screen_base,a1
	move.l	#32000/4-1,d0
loop	move.l	(a0)+,(a1)+
	dbf	d0,loop

	bsr	animate
wait:	bsr	v_sync
	move.w	#$123,$ff8240
	bsr	return_screen
	bsr	animate
	move.w	pic+2,$ff8240
	bsr	tst_key
	tst.l	d0
	beq.s	wait

	bsr	set_old_palette
	bsr	set_med_rez
	dc.w	$a009
	bsr	set_user

	clr.w	-(sp)
	MOVE.W	#$4c,-(SP)	; RETURN TO GEM DESKTOP.
	TRAP	#1
ERR:	bra.s	ERR


*******************
* CUSTOM ROUTINES *
*******************
return_screen
	move.l	old_pos,d0
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pic+34,a0
	add.w	d0,a0
	REPT	35
	movem.l	(a0),d0/d1/d2/d3/d4/d5/d6/d7/a2/a3
	movem.l	d0-d7/a2/a3,(a1)
	add.w	#160,a0
	add.w	#160,a1
	ENDR
	rts

animate:
	moveq	#0,d7
	move.l	d7,d6
	move.l	d6,d5
	move.l	d5,d4
	move.l	xtable_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.xno_reset
	lea	xtable,a0
	move.l	a0,xtable_pos
.xno_reset
	move.b	(a0)+,d6
	move.b	(a0)+,d5
	move.l	a0,xtable_pos

	move.l	ytable_pos,a0
	cmp.b	#$ff,(a0)
	bne.s	.yno_reset
	lea	ytable,a0
	move.l	a0,ytable_pos
.yno_reset
	move.b	(a0)+,d7
	move.l	a0,ytable_pos

	mulu	#160,d7
	mulu	#8,d6

	add.w	d6,d7
	move.l	d7,old_pos
	move.l	screen_base,a1
	add.w	d7,a1

	lea	logo,a0
	mulu	#(35*40),d5
	add.w	d5,a0
	REPT	35
	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d3,(a1)
	or.w	d2,2(a1)
	or.w	d1,4(a1)
	or.w	d0,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d3,(a1)
	or.w	d2,2(a1)
	or.w	d1,4(a1)
	or.w	d0,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	move.w	(a0)+,d3
	move.w	(a0)+,d2
	move.w	(a0)+,d1
	move.w	(a0)+,d0
	or.w	d0,(a1)
	or.w	d1,2(a1)
	or.w	d2,4(a1)
	or.w	d3,6(a1)
	add.w	#8,a1

	add.w	#160-40,a1
	ENDR
	rts

***********************
* SUBROUTINES SECTION *
***********************
v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

tst_key:
	move.w	#11,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

set_super:
	clr.l	-(sp)		;Set super stack equal
	move.w	#$20,-(sp)	; to user stack before call
	trap	#1
	addq.l	#6,sp		;correct stack
	move.l	d0,stack_save	;save old supervisor stack value
	rts
set_user:
	move.l	stack_save,-(sp)
	move.w	#$20,-(sp)
	trap	#1		;back to user
	addq.l	#6,sp		;correct stack
	rts

get_old_palette:
	move.w	#8-1,d0
	lea	$ff8240,a0
	lea	old_palette,a1
get_old:
	move.l	(a0)+,(a1)+
	dbf	D0,get_old
	rts

set_new_palette:
	lea	pic+2,a0
	bra	set_pal
set_old_palette:
	lea	old_palette,a0
set_pal:
	lea	$ff8240,a1
	move.w	#8-1,d0
set_p:	move.l	(a0)+,(a1)+
	dbf	d0,set_p
	rts

get_screen_base:
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base
	rts

get_original_rez:
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,original_rez
	rts

set_low_rez:
	clr.w	-(sp)
	bra	set_rez
set_med_rez:
	move.w	#1,-(sp)
set_rez:
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

****************
* DATA SECTION *
****************
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
old_palette:	ds.w	16

pic:	incbin	"pov38.pi1"
	even
********** animation data ************
xtable_pos	dc.l	xtable
xtable
	incbin	xtable.dat
	dc.b	$ff,$ff,$ff,$ff
	even
ytable_pos	dc.l	ytable
ytable	
	incbin	ytable.dat
	dc.b	$ff,$ff,$ff,$ff
	even
old_pos	dc.l	0
logo	incbin	logo.dat