; Epsilon III uppackningsrutin f”r bilder.
;-----------------------------------------
; Sist uppdaterad 1994-08-23 av The Gambler
;
;
	SECTION TEXT
	
start:	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,sp_usp

	move.w	#-1,-(sp)
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp

	tst.w	d0
	bmi.s	.rez	
	
	move.w	d0,falcon_rez	
	move.w	#3,old_rez
	clr.w	falcon_flag
	bra.s	set_rez
	
.rez	move.w	#-1,falcon_flag

	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,old_rez

set_rez:			
	move.w	#0,-(sp)	;Žndra h„r f”r att visa
	pea	-1.w		;truecolor bilder!
	pea	-1.w
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp

	move.w	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen

main_loop:	
	move.l	screen,a0
	lea	data,a2
	jsr	unpack_pic
	
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	tst.w	falcon_flag
	bne.s	.nepp
	
	move.w	falcon_rez,-(sp)
.nepp	move.w	old_rez,-(sp)	
	move.l	screen,-(sp)
	move.l	screen,-(sp)
	move.w	#5,-(sp)
	trap	#14
	lea	12(sp),sp
	
	move.l	sp_usp,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1
	

; Rutin f”r uppackning av animeringar
; packade med Epsilon III
; a0 -> destination
; a2 -> data
unpack_pic:
	move.l	a0,a3
unpack_loop:
	move.w	(a2)+,d0
	bmi.s	.end_of_frame
	beq.s	pal32
	cmpi.w	#2,d0
	beq.s	c_code
	cmpi.w	#4,d0
	beq.s	r2_code
	cmpi.w	#5,d0
	beq.s	no_code
	
.end_of_frame:
	rts

pal32:	movem.l	(a2)+,d0-d7
	movem.l	d0-d7,$ffff8240.w
	bra.s	unpack_loop

no_code:move.l	(a2)+,d0
.loop	move.w	(a2)+,(a3)+
	dbra	d0,.loop
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

r2_code:move.l	a0,a4
	add.l	(a2)+,a4
	move.l	(a2)+,d0
.loop	move.w	(a4)+,(a3)+
	dbra	d0,.loop
	bra.s	unpack_loop
	

	SECTION BSS
	EVEN

screen:	ds.l	1
sp_usp:	ds.l	1
falcon_flag:	ds.w	1
falcon_rez:	ds.w	1
old_rez:	ds.w	1

	SECTION DATA
	EVEN

data:	INCBIN	F:\PIC.PAC
	
	END
	