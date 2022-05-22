*
* This program will save the current screen mode as a Falcon Video file.
*

		include	releasem.s
		bra	main
		include	shrtones.s
		include	savefile.s
		include	gemmacro.i
		include	gem.s
		
filelength	equ	44
	
	
main		fsel_exinput #path,#filen,#title	; fileselector
		bsr	@super
		
		lea	buffer,a1
		move.l	#'FVDO',(a1)+	4 bytes header
		move.b	$ff8006,(a1)+	monitor type
		move.b	$ff820a,(a1)+	sync
		move.l	$ff820e,(a1)+	offset & vwrap
		move.w	$ff8266,(a1)+	spshift
		move.l	#$ff8282,a0	horizontal control registers
loop1		move	(a0)+,(a1)+
		cmp.l	#$ff8292,a0
		bne	loop1
		move.l	#$ff82a2,a0	vertical control registers
loop2		move	(a0)+,(a1)+
		cmp.l	#$ff82ae,a0
		bne	loop2
		move	$ff82c2,(a1)+	video control
		
		bsr	@user

		moveq	#0,d0
		move.b	path,d0
		sub.b	#'A',d0
		move	d0,-(sp)
		@gemdos	$e,4		set drive
		move.l	#path+150,a0
search		cmp.b	#'\',-(a0)
		bne	search
		move.b	#0,(a0)
		move.l	#path+2,-(sp)
		@gemdos	$3b,6		change dir
		move.l	#filen,a5
		move.l	#buffer,a6
		move.l	#filelength,d7
		bsr	@savefile	save it
		
		bra	@quit
	
	
path		dc.b	'C:\*.FV',0
		ds.b	150
title		dc.b	'Create a Falcon Video file',0

		include	aeslib.s
		section	bss
	
		even
buffer		ds.b	filelength
filen		ds.b	50

