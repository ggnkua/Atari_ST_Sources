; Epsilon III uppackningsrutin f”r animationer.
;----------------------------------------------
; Sist uppdaterad 1996-02-03 av The Gambler
;
;
;F030_REZ	EQU	%100110100	16bit 320*240 VGA
F030_REZ	EQU	%100110011	8bit 320*240 VGA
;F030_REZ	EQU	%010110010	4bit 320*200 VGA
FRAMESIZE	EQU	128000
SPEED		EQU	5

	SECTION TEXT
	
start:	pea	0.w
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,sp_usp

	move.w	#2,-(sp)	Phys_base
	trap	#14
	addq.l	#2,sp
	move.l	d0,old_screen

	move.w	#$59,-(sp)	What monitor?
	trap	#14
	addq.l	#2,sp
	
	cmpi.w	#2,d0		Not VGA?
	bne	get_out_of_here

	lea	$ffff9800.w,a0	Save pal
	lea	pal_buf,a1
	move.w	#255,d0
.loop	move.l	(a0)+,(a1)+
	dbra	d0,.loop
	
	move.w	#-1,-(sp)	What rez?
	move.w	#88,-(sp)
	trap	#14
	addq.l	#4,sp
	move.w	d0,falcon_rez	
	
	move.w	#F030_REZ,-(sp)	Set video mode!
	move.w	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
		
	move.l	#buf+512,d0
	clr.b	d0
	move.l	d0,buf_pek1
	add.l	#FRAMESIZE,d0
	move.l	d0,buf_pek2

	move.l	buf_pek1,a0
	move.l	buf_pek2,a1
	move.l	#FRAMESIZE/4-1,d0
	moveq.l	#0,d1
.clr_loop:
	move.l	d1,(a0)+
	move.l	d1,(a1)+
	dbra	d0,.clr_loop

	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	move	#$2700,sr
	move.l	$70.w,old_vbl
	move.l	$120.w,old_hbl
	move.b	$fffffa07.w,old_iera
	move.b	$fffffa09.w,old_ierb
	move.b	$fffffa1b.w,old_icra
	move.b	$fffffa13.w,old_imra
	move.l	#vbl,$70.w	;New VBI
	move.l	#hbl,$120.W	;New HBI
	move.b	#0,$fffffa1b.w	;Stop Timer B
	move.b	#1,$fffffa07.w	;Disable all MFB A IRQs except Timer B
	move.b	#1,$fffffa13.w	;Mask out all MFP A IRQs except Timer B
	move.b	#0,$fffffa09.w	;Disable all MFP B IRQs
	move	#$2300,sr	

	lea	$ffff9800.w,a0		Black out
	moveq	#0,d1
	move.w	#255,d0
.bloop	move.l	d1,(a0)+
	dbra	d0,.bloop
	
main_loop:	
	cmpi.w	#SPEED,vbl_counter
	blt.s	main_loop
	clr.w	vbl_counter
	
	bsr	toggle_screen
		
	move.l	buf_pek1,a0
	move.l	buf_pek2,a1
	move.l	anim_pek,a2
	jsr	unpack
	
	cmpi.l	#anim_end,anim_pek
	blt.s	main_loop

	move	#$2700,sr
	move.l	old_vbl,$70.w
	move.l	old_hbl,$120.w
	move.b	old_icra,$fffffa1b.w
	move.b	old_iera,$fffffa07.w
	move.b	old_ierb,$fffffa09.w
	move	#$2300,sr	

	move.w	falcon_rez,-(sp)	;Restore rez
	move.w	#3,-(sp)
	move.l	old_screen,-(sp)
	move.l	old_screen,-(sp)
	move.w  #5,-(sp)
	trap    #14
	lea	14(sp),sp

	lea	$ffff9800.w,a0		Restore pal
	lea	pal_buf,a1
	move.w	#255,d0
.loop	move.l	(a1)+,(a0)+
	dbra	d0,.loop

get_out_of_here:
	move.l	sp_usp,-(sp)		Usermode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1


vbl:	move.b	#0,$fffffa1b.w		;Stop timer B
	move.b	#150,$fffffa21.w	;Set Timer B trigger value
	move.b	#8,$fffffa1b.w		;Set timer B to count HBIs
	tst.w	hbl_flagga
	beq.s	.buggy_vbl
	addq.w	#1,vbl_counter
	clr.w	hbl_flagga
.buggy_vbl:
	rte
      
hbl:	move.w	#1,hbl_flagga
	move.b	#0,$fffffa1b.w		;Stop timer B
	bclr	#0,$fffffa0f.w		;clear in-service-bit
	rte
	
	
toggle_screen:
	move.w	#$2700,sr
	move.l	buf_pek1,d0
	move.l	buf_pek2,buf_pek1
	move.l	d0,buf_pek2
	move.b	buf_pek2+1,$ffff8201.w
	move.b	buf_pek2+2,$ffff8203.w
	move.b	buf_pek2+3,$ffff820d.w
	move.w	#$2300,sr
	rts


; Rutin f”r uppackning av animeringar
; packade med Epsilon III
; a0 -> destination
; a1 -> last frame
; a2 -> animation
unpack:	move.l	a0,a3
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
	beq	r2_code
	cmpi.w	#5,d0
	beq.s	no_code
	cmpi.w	#6,d0
	beq.s	pal1024
	
.end_of_frame:
	move.l	a2,anim_pek
	rts

pal1024	lea	$ffff9800.w,a4
	move.w	(a2)+,d0
	move.w	#255,d1
	sub.w	d0,d1
	lea	(a4,d0.w*4),a4
.loop	move.l	(a2)+,(a4)+
	dbra	d1,.loop
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
	bra	unpack_loop

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

old_screen:	ds.l	1
sp_usp:		ds.l	1
vbl_counter:	ds.w	1
hbl_flagga:	ds.w	1
old_vbl:	ds.l	1
old_hbl:	ds.l	1
old_icra:	ds.b	1
old_iera:	ds.b	1
old_ierb:	ds.b	1
old_imra:	ds.b	1
falcon_rez:	ds.w	1
buf_pek1:	ds.l	1
buf_pek2:	ds.l	1
pal_buf:	ds.l	256
buf:		ds.w	FRAMESIZE+512

	SECTION DATA
	EVEN
anim_pek:	dc.l	anim
anim:		INCBIN	F:\TST.FLI
anim_end:
	
	END
	