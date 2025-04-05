*********************************
*	Sound!!			*
*********************************
start:
	move.l	4(a7),a3		base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		text len
	add.l	$14(a3),d0		data len
	add.l	$1c(a3),d0		BSS len
	add.l	#$100,d0		basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			shrink memory
	lea	12(sp),sp



	move.l	#12000000+1,-(sp)	;thats 1 sample size
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bmi	exit
	addq.l	#1,d0
	and.w	#%1111111111111110,d0	;make it an even boundry
	move.l	d0,savemem



	move.w	#1,-(sp)
	move.l	#fname,-(sp)
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	move.w	d0,handle

	move.l	savemem,-(sp)
	move.l	#12000000,-(sp)
	move.w	handle,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.l	#12,sp
	move.l	d0,howlong

	move.w	handle,-(sp)	;close the file
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp

	move.w	#$80,-(sp)		;lock the sound system
	trap	#14
	addq.l	#2,sp
	tst.l	d0
	bmi	exit

	move.w	#1,-(sp)		;setmode 16bit Stereo
	move.w	#$84,-(sp)
	trap	#14
	addq.l	#4,sp


	move.w	#0,-(sp)	;rectracks
	move.w	#1,-(sp)	;playtracks
	move.w	#$85,-(sp)	;set tracks
	trap	#14
	addq.l	#6,sp


	move.w	#1,-(sp)	;disable handshaking
	move.w	#3,-(sp)	;prescale
	move.w	#0,-(sp)	;srclk internal 25.175Mhz
	move.w	#8,-(sp)	;dst dac
	move.w	#0,-(sp)	;src dma playback
	move.w	#$8b,-(sp)	;devconnect
	trap	#14
	add.l	#12,sp

	move.l	savemem,d0
	add.l	howlong,d0
	move.l	d0,-(sp)	;endaddress
	move.l	savemem,d0
	add.l	#128,d0	
	move.l	d0,-(sp)	;start address
	move.w	#0,-(sp)	;playback
	move.w	#$83,-(sp)	;setbuffer
	trap	#14
	add.l	#10,sp

	move.w	#%0000000000000011,-(sp)
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp


wait:
	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp

	

	move.w	#$81,-(sp)		;unlock the sound system
	trap	#14
	addq.l	#2,sp
	tst.l	d0


	move.l	savemem,-(sp)
	move.w	#$49,-(sp)		;dealloc
	trap	#1
	addq.l	#6,sp




exit:
	clr.w	(sp)
	trap	#1

howlong:	ds.l	1
savemem:	ds.l	1
handle:		ds.w	1
fname:		dc.b	'sample.trk',0
	even
		ds.l	1000
mystack:	ds.w	1	;stacks go backwards

