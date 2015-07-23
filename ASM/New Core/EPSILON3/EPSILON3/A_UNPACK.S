; Epsilon III uppackningsrutin f”r animationer.
;----------------------------------------------
; Sist uppdaterad 1995-04-20 av The Gambler
;
;
;F030_REZ	EQU	%100110100	16bit 320*240 VGA
F030_REZ	EQU	%100110011	8bit 320*240 VGA
;F030_REZ	EQU	%010110010	4bit 320*200 VGA
FRAMESIZE	EQU	128000

	SECTION TEXT
	
start:	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,sp_usp

	move.w	#-1,-(sp)	Falcon rez?
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	tst.w	d0
	bmi.s	st_rez
	
	move.w	d0,falcon_rez	
	move.w	#3,old_rez
	move.w	#F030_REZ,-(sp)
	move.w	#3,-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	bra.s	calc_screen_mem
	
st_rez:	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,old_rez
	clr.w	-(sp)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
calc_screen_mem:
	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen
	move.l	#buf+512,d0
	clr.b	d0
	move.l	d0,buf_pek1
	add.l	#FRAMESIZE,d0
	move.l	d0,buf_pek2
	
main_loop:	
	move.l	buf_pek1,d0
	move.l	buf_pek2,buf_pek1
	move.l	d0,buf_pek2
	
	move.w	#-1,-(sp)
	move.l	buf_pek1,-(sp)
	move.l	buf_pek1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.l	buf_pek1,a0
	move.l	buf_pek2,a1
	jsr	unpack
	
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	
	cmpi.l	#anim_end,anim_pek
	blt.s	main_loop

	move.w	falcon_rez,-(sp)
	move.w	old_rez,-(sp)	
	move.l	screen,-(sp)
	move.l	screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	14(sp),sp
	
	move.l	sp_usp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
	


; Rutin f”r uppackning av animeringar
; packade med Epsilon III
; a0 -> destination
; a1 -> last frame
unpack:	move.l	anim_pek,a2
	
	move.l	a0,a3
unpack_loop:
	move.w	(a2)+,d0
	bmi.s	.end_of_frame
	beq.s	pal32
	cmpi.w	#1,d0
	beq.s	d_code
	cmpi.w	#2,d0
	beq.s	c_code
	cmpi.w	#3,d0
	beq.s	r1_code
	cmpi.w	#4,d0
	beq.s	r2_code
	cmpi.w	#5,d0
	beq.s	no_code
	cmpi.w	#6,d0
	beq.s	pal1024
	
.end_of_frame:
	move.l	a2,anim_pek
	rts

pal1024	lea	$ffff9800.w,a4
	move.w	#256-1,d0
.loop	move.l	(a2)+,(a4)+
	dbra	d0,.loop
	bra.s	unpack_loop
	
pal32:	movem.l	(a2)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bra.s	unpack_loop
	
no_code:move.l	(a2)+,d0
.loop	move.w	(a2)+,(a3)+
	dbra	d0,.loop
	bra.s	unpack_loop	
	
d_code:	move.l	(a2)+,d0
	adda.l	d0,a3
	bra.s	unpack_loop
	
c_code:	move.l	(a2)+,d0
	move.l	(a2)+,d1
.loop2	move.l	a2,a4
	move.l	d0,d2
.loop	move.w	(a4)+,(a3)+
	dbra	d2,.loop
	dbra	d1,.loop2
	move.l	a4,a2
	bra.s	unpack_loop

r1_code:move.l	a1,a4
	adda.l	(a2)+,a4
	move.l	(a2)+,d0
.loop	move.w	(a4)+,(a3)+
	dbra	d0,.loop
	bra	unpack_loop

r2_code:move.l	a0,a4
	add.l	(a2)+,a4
	move.l	(a2)+,d0
.loop	move.w	(a4)+,(a3)+
	dbra	d0,.loop
	bra	unpack_loop
	

	SECTION BSS
	EVEN

screen:	ds.l	1
sp_usp:	ds.l	1
falcon_rez:	ds.w	1
old_rez:	ds.w	1
buf:		ds.w	FRAMESIZE+512
buf_pek1:	ds.l	1
buf_pek2:	ds.l	1

	SECTION DATA
	EVEN
anim_pek:	dc.l	anim
anim:		INCBIN	F:\TST.ANM
anim_end:
	
	END
	