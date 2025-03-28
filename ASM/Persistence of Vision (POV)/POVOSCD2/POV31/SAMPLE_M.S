* use cursor keys to move - SPACE to record position
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
	dc.w	$a00a		;hide mouse
	bsr	get_screen_base
	bsr	get_old_palette
	bsr	set_new_palette
	bsr	get_original_rez
	bsr	set_low_rez
	move.b	$484,old484
	and.b	#%11111110,$484

hide_cursor:
	pea	di_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp

	lea	pic+34,a0
	move.l	screen_base,a1
	move.w	#32000/4-1,d0
trans:	move.l	(a0)+,(a1)+
	dbf	d0,trans

	bsr	print_logo

	lea	buffer,a6
wait:
	bsr	v_sync
	bsr	tst_key
	tst.l	d0
	beq.s	wait
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	swap	d0

	cmp.b	#1,d0
	beq.s	exit

	cmp.b	#$39,d0
	beq	save_pos

	cmp.b	#$48,d0
	beq	up

	cmp.b	#$50,d0
	beq	down

	cmp.b	#$4d,d0
	beq	right

	cmp.b	#$4b,d0
	beq	left

	bra.s	wait

save_pos:
	move.b	ypos,d0
	move.b	xpos,d1
	move.b	shift,d2
	clr.b	d3
	move.b	d0,(a6)+
	move.b	d1,(a6)+
	move.b	d2,(a6)+
	move.b	d3,(a6)+
	bra.s	wait
exit:
	move.l	a6,eob

;now save
	bsr	f_create
	bsr	f_write
	bsr	f_close

show_cursor:
	pea	ei_mouse
	move.w	#$2-1,-(sp)
	move.w	#$19,-(sp)
	trap	#14
	addq.l	#8,sp

	move.b	old484,$484
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

up:	tst.b	ypos
 	bne.s	yvalidup
	bra	wait
yvalidup:
	move.b	ypos,d0
	sub.b	#1,d0
	move.b	d0,ypos

	bsr	return_under
	bsr	print_logo
	bra	wait

down:	cmp.b	#177,ypos
 	bne.s	yvaliddown
	bra	wait
yvaliddown:
	move.b	ypos,d0
	add.b	#1,d0
	move.b	d0,ypos

	bsr	return_under
	bsr	print_logo
	bra	wait

right:	cmp.b	#88,xpos	;words
 	ble.s	xvalidright
	bra	wait
xvalidright:
	cmp.b	#14,shift
	ble.s	altershift
	clr.b	shift
	move.b	xpos,d0
	add.b	#8,d0
	move.b	d0,xpos
	bra.s	doimg
altershift
	add.b	#1,shift
doimg
	bsr	return_under
	bsr	print_logo
	bra	wait

left:	cmp.b	#0,xpos
 	bge	xvalidleft
	bra	wait
xvalidleft:
	cmp.b	#0,shift
	bne.s	altershift2
	tst.b	xpos
	beq	wait
	move.b	#15,shift
	move.b	xpos,d0
	sub.b	#8,d0
	move.b	d0,xpos
	bra.s	doimg2
altershift2
	sub.b	#1,shift
doimg2
	bsr	return_under
	bsr	print_logo
	bra	wait

return_under:
;return old screen
	lea	pic+34,a0
	move.l	screen_base,a1
	add.w	store,a0
	add.w	store,a1
	REPT	22
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
	move.l	(a0)+,(a1)+
	add.w	#160-72,a0
	add.w	#160-72,a1
	ENDR
	rts

print_logo:
	move.b	ypos,d0
	and.l	#$ff,d0
	mulu	#160,d0
	move.l	screen_base,a1
	add.w	d0,a1
	move.w	d0,store
	move.b	xpos,d0
	and.l	#$ff,d0
	add.w	d0,a1
	add.w	d0,store

	lea	logo,a0
	move.b	shift,d0
	and.l	#$ff,d0
	mulu	#72*22,d0
	add.w	d0,a0

	REPT	22
	move.l	72*22*16(a0),d2
	move.l	(a0)+,d0
	move.l	(a1),d1
	and.l	d2,d1
	or.l	d1,d0
	move.l	d0,(a1)+

	move.l	72*22*16(a0),d2
	move.l	(a0)+,d0
	move.l	(a1),d1
	and.l	d2,d1
	or.l	d1,d0
	move.l	d0,(a1)+

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

	move.l	72*22*16(a0),d2
	move.l	(a0)+,d0
	move.l	(a1),d1
	and.l	d2,d1
	or.l	d1,d0
	move.l	d0,(a1)+

	move.l	72*22*16(a0),d2
	move.l	(a0)+,d0
	move.l	(a1),d1
	and.l	d2,d1
	or.l	d1,d0
	move.l	d0,(a1)+

	add.w	#160-72,a1
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


f_create:
	move.w	#0,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	add.l	#8,sp
	move.w	d0,handle
	rts

f_write:
	move.l	#buffer,-(sp)
	lea	buffer,a0
	move.l	eob,a1
	sub.l	a0,a1
	move.l	a1,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	rts

f_close:
	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
	rts

****************
* DATA SECTION *
****************
ei_mouse:	dc.b	$14,8
di_mouse:	dc.b	$12,$1a
eob:	dc.l	0
filename:	dc.b	"g:\pov31\path.bob",0
	even
handle:	dc.w	0
stack_save:	dc.l	0
screen_base	dc.l	0
original_rez:	dc.w	0
old_palette:	ds.w	16
old484:	dc.w	0
shift:	dc.b	0
xpos:	dc.b	0
ypos:	dc.b	177
store:	dc.w	0
pic:	incbin	"g:\pov31\pov31.pi1"
logo:	incbin	"g:\pov31\logo.dat"
	incbin	"g:\pov31\logo2.dat"
	incbin	g:\pov31\mask.dat
	incbin	g:\pov31\mask2.dat
buffer:	dc.l	0