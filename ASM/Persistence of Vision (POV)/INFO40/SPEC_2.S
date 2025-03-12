
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

	move.l	screen_base,a1
	add.w	#160*50,a1

	move.l	a1,spec_pos
	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
pic_sho	move.l	(a0)+,(a1)+
	dbf	d0,pic_sho

	move.l	#1,d0
	jsr	tune

	move.l	#tune+6,$4da
wait:
	bsr	v_sync
	move.w	#$123,$ff8240
	bsr	clear_spec
	bsr	spec
	move.w	pic+2,$ff8240
	bsr	tst_key
	tst.l	d0
	beq.s	wait
	bsr	get_key

	jsr	endmus
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
clear_spec
	lea	spec_values,a0
	move.w	#80-1,d0
.cnt_down
	move.b	(a0)+,d1
	tst.b	d1
	beq.s	.next
	sub.b	#1,-1(a0)
	
.next	dbf	d0,.cnt_down

	move.l	spec_pos,a0
	sub.w	#50*160,a0
	moveq	#0,d1

	REPT	26
	move.w	d1,(a0)
	move.w	d1,8(a0)
	move.w	d1,16(a0)
	move.w	d1,24(a0)
	move.w	d1,32(a0)
	move.w	d1,40(a0)
	move.w	d1,48(a0)
	move.w	d1,56(a0)
	move.w	d1,64(a0)
	move.w	d1,72(a0)
	move.w	d1,80(a0)
	move.w	d1,88(a0)
	move.w	d1,96(a0)
	move.w	d1,104(a0)
	move.w	d1,112(a0)
	move.w	d1,120(a0)
	move.w	d1,128(a0)
	move.w	d1,136(a0)
	move.w	d1,144(a0)
	move.w	d1,152(a0)
	lea	160(a0),a0
	ENDR
	rts
	
************************************************

AFINE	equ	0
ACOURSE	equ	1	
BFINE	equ	2
BCOURSE	equ	3	
CFINE	equ	4
CCOURSE	equ	5	

COURCE_SHIFT	equ	3
FINE_SHIFT	equ	5

spec	lea	$ffff8800.w,a1

	move.b	#ACOURSE,(a1)		;A course tune
	move.b	(a1),d0
	and.w	#$ff,d0
	asl.w	#COURCE_SHIFT,d0
	lea	spec_values,a2
	move.w	d0,d1

	move.b	#AFINE,(a1)	;A fine tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsr.w	#FINE_SHIFT,d0
	add.w	d0,d1
	add.w	d1,a2
	move.b	#24,(a2)


******************
	move.b	#BCOURSE,(a1)		;B course tune
	move.b	(a1),d0
	and.w	#$ff,d0
	asl.w	#COURCE_SHIFT,d0
	lea	spec_values,a2
	move.w	d0,d1

	move.b	#BFINE,(a1)		;B fine tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsr.w	#FINE_SHIFT,d0
	add.w	d0,d1
	add.w	d1,a2
	move.b	#24,(a2)

******************
	move.b	#CCOURSE,(a1)		;C course tune
	move.b	(a1),d0
	and.w	#$ff,d0
	asl.w	#COURCE_SHIFT,d0
	lea	spec_values,a2
	move.w	d0,d1

	move.b	#CFINE,(a1)		;C fine tune
	move.b	(a1),d0
	and.w	#$ff,d0
	lsr.w	#FINE_SHIFT,d0
	add.w	d0,d1
bp	add.w	d1,a2
	move.b	#24,(a2)


******************** print speccy *******************
ps	move.l	spec_pos,a0
	sub.w	#160*25,a0
	add.w	#152,a0
	lea	spec_values,a2
	move.b	#20-1,d1
.loop	move.l	a0,a1

	move.b	(a2)+,d0
	beq.s	.nib2
	and.w	#$ff,d0
.loop1	move.b	#%00000111,1(a1)
	lea	-160(a1),a1
	dbf	d0,.loop1

.nib2	move.b	(a2)+,d0
	beq.s	.nib3
	and.w	#$ff,d0
	move.l	a0,a1
.loop2	or.b	#%01110000,1(a1)
	lea	-160(a1),a1
	dbf	d0,.loop2

.nib3	move.b	(a2)+,d0
	beq.s	.nib4
	and.w	#$ff,d0
	move.l	a0,a1
.loop3	or.b	#%00000111,(a1)
	lea	-160(a1),a1
	dbf	d0,.loop3

.nib4	move.b	(a2)+,d0
	beq.s	.nonib
	and.w	#$ff,d0
	move.l	a0,a1
.loop4	or.b	#%01110000,(a1)
	lea	-160(a1),a1
	dbf	d0,.loop4
.nonib
	sub.w	#8,a0
	dbf	d1,.loop
	rts





endmus	clr.l	$4da
	lea	$ffff8800,a0
	move.l	#$8080000,(a0)
	move.l	#$9090000,(a0)
	move.l	#$a0a0000,(a0)
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
spec_pos:	dc.l	0
pic:	incbin	info40.pi1
tune	incbin	loader.img
spec_values	dcb.b	68,0