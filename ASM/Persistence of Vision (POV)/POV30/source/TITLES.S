
	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	12(a5),d0	;text segment
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
	move.b	#$12,$fffffc02.w
	dc.w	$a00a		;hide mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	move.l	screen_base,a0
	lea	pic+34,a1
	move.l	#32000/4-1,d0
sho_pic:	move.l	(a1)+,(a0)+
	dbf	d0,sho_pic
	bsr	ripple
wait:
	bsr	v_sync
	move.w	#$123,$ff8240
	bsr	restore
	bsr	ripple
	move.w	pic+2,$ff8240
	bsr	tst_key
	tst.l	d0
	beq.s	wait

	bsr	set_old_palette
	bsr	set_med_rez
	dc.w	$a009
	move.b	#8,$fffffc02.w
	bsr	set_user

	clr.w	-(sp)
	MOVE.W	#$4c,-(SP)
	TRAP	#1
ERR:	bra.s	ERR


*******************
* CUSTOM ROUTINES *
*******************
restore:
	move.w	ripple1_recover,d0
	bsr	do_recover
	move.w	ripple2_recover,d0
	bsr	do_recover
	move.w	ripple3_recover,d0
	bsr	do_recover
	move.w	ripple4_recover,d0
	bsr	do_recover
	move.w	ripple5_recover,d0
	bsr	do_recover
	rts

do_recover
	move.l	screen_base,a1
	add.w	d0,a1
	lea	pic+34,a0
	add.w	d0,a0
	move.w	#11-1,d1
.loop2	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	add.w	#160-72,a0
	add.w	#160-72,a1
	dbf	d1,.loop2
	rts


ripple:
	move.l	ripple1_pos,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_ripple1_reset
	lea	ripple1_table,a0
	move.l	a0,ripple1_pos
no_ripple1_reset
	move.w	(a0)+,d0	;word offset
	move.w	(a0)+,d1	;ripple number
	move.l	a0,ripple1_pos

	move.l	screen_base,a1
	add.w	#54*160,d0
	move.w	d0,ripple1_recover
	add.w	d0,a1

	and.w	#$ffff,d1
	mulu	#3960,d1
	lea	titles,a0
	add.l	d1,a0
	bsr	print_titles


*************** R I P P L E   2 *****************
	move.l	ripple2_pos,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_ripple2_reset
	lea	ripple2_table,a0
	move.l	a0,ripple2_pos
no_ripple2_reset
	move.w	(a0)+,d0	;word offset
	move.w	(a0)+,d1	;ripple number
	move.l	a0,ripple2_pos

	move.l	screen_base,a1
	add.w	#74*160,d0
	move.w	d0,ripple2_recover
	add.w	d0,a1

	and.w	#$ffff,d1
	mulu	#3960,d1
	lea	titles+792,a0
	add.l	d1,a0
	bsr	print_titles


**************** RIPPLE 3 ************
	move.l	ripple3_pos,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_ripple3_reset
	lea	ripple3_table,a0
	move.l	a0,ripple3_pos
no_ripple3_reset
	move.w	(a0)+,d0	;word offset
	move.w	(a0)+,d1	;ripple number
	move.l	a0,ripple3_pos

	move.l	screen_base,a1
	add.w	#94*160,d0
	move.w	d0,ripple3_recover
	add.w	d0,a1

	lea	titles+792+792,a0
	and.w	#$ffff,d1
	mulu	#3960,d1
	add.l	d1,a0
	bsr	print_titles


*********** RIPPLE 4 **********
	move.l	ripple4_pos,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_ripple4_reset
	lea	ripple4_table,a0
	move.l	a0,ripple4_pos
no_ripple4_reset
	move.w	(a0)+,d0	;word offset
	move.w	(a0)+,d1	;ripple number
	move.l	a0,ripple4_pos

	move.l	screen_base,a1
	add.w	#114*160,d0
	move.w	d0,ripple4_recover
	add.w	d0,a1

	lea	titles+792+792+792,a0
	and.w	#$ffff,d1
	mulu	#3960,d1
	add.l	d1,a0
	bsr	print_titles


*************ripple 5**********
	move.l	ripple5_pos,a0
	cmp.w	#$ffff,(a0)
	bne.s	no_ripple5_reset
	lea	ripple5_table,a0
	move.l	a0,ripple5_pos
no_ripple5_reset
	move.w	(a0)+,d0	;word offset
	move.w	(a0)+,d1	;ripple number
	move.l	a0,ripple5_pos

	move.l	screen_base,a1
	add.w	#134*160,d0
	move.w	d0,ripple5_recover
	add.w	d0,a1

	lea	titles+(792*4),a0
	and.w	#$ffff,d1
	mulu	#3960,d1
	add.l	d1,a0
	bsr	print_titles
	rts

print_titles:
				* from A0 to A1 *
	move.w	#11-1,d0
.loop	move.w	(a0),d1
	or.w	2(a0),d1
	or.w	4(a0),d1
	or.w	6(a0),d1
	not.w	d1

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

;mask on second to last word
	move.w	(a0),d1
	or.w	2(a0),d1
	or.w	4(a0),d1
	or.w	6(a0),d1
	not.w	d1

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

;mask on last word
	move.w	(a0),d1
	or.w	2(a0),d1
	or.w	4(a0),d1
	or.w	6(a0),d1
	not.w	d1

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	move.w	(a1),d2
	and.w	d1,d2
	or.w	(a0)+,d2
	move.w	d2,(a1)+

	add.w	#160-72,a1
	dbf	d0,.loop

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

pic:	incbin	pov30.pi1
titles:	incbin	titles.dat
ripple1_recover:	dc.w	0
ripple1_pos	dc.l	init_ripple1_table
init_ripple1_table
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,1
	dc.w	48,2
	dc.w	48,3
	dc.w	48,5
	dc.w	48,7
	dc.w	48,10
	dc.w	48,13
	dc.w	56,0
	dc.w	56,4

ripple1_table
	dc.w	56,9
	dc.w	56,14
	dc.w	64,3
	dc.w	64,8
	dc.w	64,12
	dc.w	72,0
	dc.w	72,3
	dc.w	72,6
	dc.w	72,8
	dc.w	72,10
	dc.w	72,11
	dc.w	72,12
	dc.w	72,13
	dc.w	72,12
	dc.w	72,11
	dc.w	72,10
	dc.w	72,8
	dc.w	72,6
	dc.w	72,3
	dc.w	72,0
	dc.w	64,12
	dc.w	64,8
	dc.w	64,3
	dc.w	56,14
	dc.w	56,9
	dc.w	56,4
	dc.w	48,15
	dc.w	48,10
	dc.w	48,5
	dc.w	48,0
	dc.w	40,11
	dc.w	40,6
	dc.w	40,1
	dc.w	32,12
	dc.w	32,8
	dc.w	32,4
	dc.w	32,1
	dc.w	24,15
	dc.w	24,12
	dc.w	24,10
	dc.w	24,8
	dc.w	24,6
	dc.w	24,5
	dc.w	24,4
	dc.w	24,3

	dc.w	24,4
	dc.w	24,5
	dc.w	24,6
	dc.w	24,8
	dc.w	24,10
	dc.w	24,12
	dc.w	24,15

	dc.w	32,1
	dc.w	32,4
	dc.w	32,8
	dc.w	32,12
	dc.w	40,1
	dc.w	40,6
	dc.w	40,11
	dc.w	48,0
	dc.w	48,5
	dc.w	48,10
	dc.w	48,15
	dc.w	56,4

	dc.w	$ffff
ripple2_recover:	dc.w	0
ripple2_pos:	dc.l	init_ripple2_table
init_ripple2_table
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,1
	dc.w	48,2
	dc.w	48,3
	dc.w	48,5
	dc.w	48,7
	dc.w	48,10
	dc.w	48,13
	dc.w	56,0
	dc.w	56,4

ripple2_table
	dc.w	56,9
	dc.w	56,14
	dc.w	64,3
	dc.w	64,8
	dc.w	64,12
	dc.w	72,0
	dc.w	72,3
	dc.w	72,6
	dc.w	72,8
	dc.w	72,10
	dc.w	72,11
	dc.w	72,12
	dc.w	72,13
	dc.w	72,12
	dc.w	72,11
	dc.w	72,10
	dc.w	72,8
	dc.w	72,6
	dc.w	72,3
	dc.w	72,0
	dc.w	64,12
	dc.w	64,8
	dc.w	64,3
	dc.w	56,14
	dc.w	56,9
	dc.w	56,4
	dc.w	48,15
	dc.w	48,10
	dc.w	48,5
	dc.w	48,0
	dc.w	40,11
	dc.w	40,6
	dc.w	40,1
	dc.w	32,12
	dc.w	32,8
	dc.w	32,4
	dc.w	32,1
	dc.w	24,15
	dc.w	24,12
	dc.w	24,10
	dc.w	24,8
	dc.w	24,6
	dc.w	24,5
	dc.w	24,4
	dc.w	24,3

	dc.w	24,4
	dc.w	24,5
	dc.w	24,6
	dc.w	24,8
	dc.w	24,10
	dc.w	24,12
	dc.w	24,15

	dc.w	32,1
	dc.w	32,4
	dc.w	32,8
	dc.w	32,12
	dc.w	40,1
	dc.w	40,6
	dc.w	40,11
	dc.w	48,0
	dc.w	48,5
	dc.w	48,10
	dc.w	48,15
	dc.w	56,4

	dc.w	$ffff

ripple3_recover:	dc.w	0
ripple3_pos:	dc.l	init_ripple3_table
init_ripple3_table
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,1
	dc.w	48,2
	dc.w	48,3
	dc.w	48,5
	dc.w	48,7
	dc.w	48,10
	dc.w	48,13
	dc.w	56,0
	dc.w	56,4

ripple3_table
	dc.w	56,9
	dc.w	56,14
	dc.w	64,3
	dc.w	64,8
	dc.w	64,12
	dc.w	72,0
	dc.w	72,3
	dc.w	72,6
	dc.w	72,8
	dc.w	72,10
	dc.w	72,11
	dc.w	72,12
	dc.w	72,13
	dc.w	72,12
	dc.w	72,11
	dc.w	72,10
	dc.w	72,8
	dc.w	72,6
	dc.w	72,3
	dc.w	72,0
	dc.w	64,12
	dc.w	64,8
	dc.w	64,3
	dc.w	56,14
	dc.w	56,9
	dc.w	56,4
	dc.w	48,15
	dc.w	48,10
	dc.w	48,5
	dc.w	48,0
	dc.w	40,11
	dc.w	40,6
	dc.w	40,1
	dc.w	32,12
	dc.w	32,8
	dc.w	32,4
	dc.w	32,1
	dc.w	24,15
	dc.w	24,12
	dc.w	24,10
	dc.w	24,8
	dc.w	24,6
	dc.w	24,5
	dc.w	24,4
	dc.w	24,3

	dc.w	24,4
	dc.w	24,5
	dc.w	24,6
	dc.w	24,8
	dc.w	24,10
	dc.w	24,12
	dc.w	24,15

	dc.w	32,1
	dc.w	32,4
	dc.w	32,8
	dc.w	32,12
	dc.w	40,1
	dc.w	40,6
	dc.w	40,11
	dc.w	48,0
	dc.w	48,5
	dc.w	48,10
	dc.w	48,15
	dc.w	56,4

	dc.w	$ffff

ripple4_recover:	dc.w	0
ripple4_pos:	dc.l	init_ripple4_table
init_ripple4_table
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,1
	dc.w	48,2
	dc.w	48,3
	dc.w	48,5
	dc.w	48,7
	dc.w	48,10
	dc.w	48,13
	dc.w	56,0
	dc.w	56,4

ripple4_table
	dc.w	56,9
	dc.w	56,14
	dc.w	64,3
	dc.w	64,8
	dc.w	64,12
	dc.w	72,0
	dc.w	72,3
	dc.w	72,6
	dc.w	72,8
	dc.w	72,10
	dc.w	72,11
	dc.w	72,12
	dc.w	72,13
	dc.w	72,12
	dc.w	72,11
	dc.w	72,10
	dc.w	72,8
	dc.w	72,6
	dc.w	72,3
	dc.w	72,0
	dc.w	64,12
	dc.w	64,8
	dc.w	64,3
	dc.w	56,14
	dc.w	56,9
	dc.w	56,4
	dc.w	48,15
	dc.w	48,10
	dc.w	48,5
	dc.w	48,0
	dc.w	40,11
	dc.w	40,6
	dc.w	40,1
	dc.w	32,12
	dc.w	32,8
	dc.w	32,4
	dc.w	32,1
	dc.w	24,15
	dc.w	24,12
	dc.w	24,10
	dc.w	24,8
	dc.w	24,6
	dc.w	24,5
	dc.w	24,4
	dc.w	24,3

	dc.w	24,4
	dc.w	24,5
	dc.w	24,6
	dc.w	24,8
	dc.w	24,10
	dc.w	24,12
	dc.w	24,15

	dc.w	32,1
	dc.w	32,4
	dc.w	32,8
	dc.w	32,12
	dc.w	40,1
	dc.w	40,6
	dc.w	40,11
	dc.w	48,0
	dc.w	48,5
	dc.w	48,10
	dc.w	48,15
	dc.w	56,4

	dc.w	$ffff

ripple5_recover:	dc.w	0
ripple5_pos:	dc.l	init_ripple5_table
init_ripple5_table
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,0
	dc.w	48,1
	dc.w	48,2
	dc.w	48,3
	dc.w	48,5
	dc.w	48,7
	dc.w	48,10
	dc.w	48,13
	dc.w	56,0
	dc.w	56,4

ripple5_table
	dc.w	56,9
	dc.w	56,14
	dc.w	64,3
	dc.w	64,8
	dc.w	64,12
	dc.w	72,0
	dc.w	72,3
	dc.w	72,6
	dc.w	72,8
	dc.w	72,10
	dc.w	72,11
	dc.w	72,12
	dc.w	72,13
	dc.w	72,12
	dc.w	72,11
	dc.w	72,10
	dc.w	72,8
	dc.w	72,6
	dc.w	72,3
	dc.w	72,0
	dc.w	64,12
	dc.w	64,8
	dc.w	64,3
	dc.w	56,14
	dc.w	56,9
	dc.w	56,4
	dc.w	48,15
	dc.w	48,10
	dc.w	48,5
	dc.w	48,0
	dc.w	40,11
	dc.w	40,6
	dc.w	40,1
	dc.w	32,12
	dc.w	32,8
	dc.w	32,4
	dc.w	32,1
	dc.w	24,15
	dc.w	24,12
	dc.w	24,10
	dc.w	24,8
	dc.w	24,6
	dc.w	24,5
	dc.w	24,4
	dc.w	24,3

	dc.w	24,4
	dc.w	24,5
	dc.w	24,6
	dc.w	24,8
	dc.w	24,10
	dc.w	24,12
	dc.w	24,15

	dc.w	32,1
	dc.w	32,4
	dc.w	32,8
	dc.w	32,12
	dc.w	40,1
	dc.w	40,6
	dc.w	40,11
	dc.w	48,0
	dc.w	48,5
	dc.w	48,10
	dc.w	48,15
	dc.w	56,4

	dc.w	$ffff
