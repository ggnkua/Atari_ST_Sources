
TEST		=	0

X_SIZE		=	640
Y_SIZE		=	480
LINE_SIZE	=	640
COLUMN_SIZE	=	16


		IFEQ	TEST
		INCLUDE	"F:\SOURCES\LIBS\STARTUP.S"
		ELSE
		clr.l	-(sp)
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		bsr	main
		nop
		illegal
		ENDC
		
		TEXT
		
main:		moveq	#1,d0
		moveq	#3,d1
		moveq	#3,d2
		bsr	set_screen
		bmi	exit

		bsr	init_rug
		bsr	init_modplay
		lea	object1,a0
		bsr	init_object
		bsr	set_logo
		move.l	#vbl_rout,$70.w
		
		move.w	#$0011,d0
		movec	d0,cacr

main_loop:	bsr	wvbl

		bsr	set_pal

;		move.w	#8000-1,d0
;del:		nop
;		dbra	d0,del

		cmp.b	#98,$fffffc02.w
		bne.s	.no_time
		move.l	#-1,$ffff9800.w
.no_time:	bsr	vbl_rug
		cmp.b	#98,$fffffc02.w
		bne.s	.no_time2
		clr.l	$ffff9800.w
.no_time2:
			
;		bsr	switch_screens
		
		cmp.b	#57,$fffffc02.w
		bne	main_loop
exit:		
		bsr	exit_modplay
		rts	

vbl_rout:	movem.l	d0-a6,-(sp)
		addq.l	#1,vbl_ctr
		bsr	switch_screens
		movem.l	(sp)+,d0-a6
		rte

set_screen:	
		IFEQ	TEST
		bsr	calc_mode
		bmi.s	.exit
		ENDC
		move.l	#rscreen1+4,d0
		move.l	#rscreen2+4,d1
		and.w	#$fffc,d0
		and.w	#$fffc,d1
		move.l	d0,screen1
		move.l	d1,screen2
		IFEQ 	TEST
		bsr	wvbl
		bsr	set_mode
		move.l	screen2,-(sp)
		move.b	1(sp),$ffff8201.w
		move.b	2(sp),$ffff8203.w
		move.b	3(sp),$ffff820d.w
		addq.l	#4,sp
		bsr	wvbl
		ENDC

		lea	$ffff9800.w,a0
		move.w	#255-1,d0
		clr.l	(a0)+
.s		move.l	#-1,(a0)+
		dbra	d0,.s
		
		moveq	#0,d0
.exit:		rts

switch_screens:	move.l	screen1,-(sp)
		move.l	screen2,screen1
		move.l	(sp),screen2
		IFEQ	TEST
		move.b	1(sp),$ffff8201.w
		move.b	2(sp),$ffff8203.w
		move.b	3(sp),$ffff820d.w
		ENDC
		addq.l	#4,sp
		rts
		
set_pal:	lea	current_pal,a0
		lea	$ffff9800.w,a1
		move.w	#256/4-1,d0
.set:		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		move.l	(a0)+,(a1)+		
		dbra	d0,.set
		rts
	
wvbl:		
		IFEQ	TEST
		move.l	vbl_ctr,d0
.ww:		cmp.l	vbl_ctr,d0
		beq.s	.ww
		ENDC
		
		rts

set_logo:	lea	logo+4*4,a0
		move.l	screen1,a1
		move.l	screen2,a2
		lea	6*2(a1),a1
		lea	6*2(a2),a2
		move.w	#480-1,d1
.loop2:		move.w	#40-1,d0
.loop:		move.l	(a0),(a1)
		move.l	(a0)+,(a2)
		lea	8*2(a1),a1
		lea	8*2(a2),a2
		dbra	d0,.loop
		dbra	d1,.loop2

		lea	current_pal+64*4,a0
		lea	logo+3*4,a1
		move.w	#3-1,d0
.set2:		move.l	-(a1),d1
		move.w	#64-1,d2
.set1:		move.l	d1,(a0)+
		dbra	d2,.set1
		dbra	d0,.set2
		rts

		INCLUDE	"f:\sources\elite.3\sources\rug.s"
		INCLUDE	"f:\sources\elite.3\sources\modplay.s"
		INCLUDE	"f:\sources\elite.3\sources\3d.s"

		DATA
		
logo:		incbin	"f:\sources\elite.3\graphics\elite.bin"
		
	
		BSS

current_pal:	ds.l	256
	
screen1:	ds.l	1
screen2:	ds.l	1

rscreen1:	ds.b	640*480	
rscreen2:	ds.b	640*480

		END		
		
		