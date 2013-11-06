MP2_ADDRESS	=	28
MP2_LENGTH	=	32
MP2_FREQUENCY	=	36
MP2_EXTERNAL	=	40
MP2_REPEAT	=	44
MP2_START	=	48
MP2_STOP	=	52

	text

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	move.l	#mp2song,mp2player+MP2_ADDRESS
	move.l	#mp2song_end-mp2song,mp2player+MP2_LENGTH
	move.l	#44100,mp2player+MP2_FREQUENCY
	move.l	#44100,mp2player+MP2_EXTERNAL
	move.l	#1,mp2player+MP2_REPEAT
	
	jsr	mp2player+MP2_START
	
dl
	pea	bufs
	move.w	#$8d,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#-1,-(sp)
	move.w	#$88,-(sp)
	trap	#14
	addq.l	#4,sp

	cmp.b	#$3b,$fffffc02.w
	bne.s	dl

	jsr	mp2player+MP2_STOP

	clr.w	-(sp)
	trap	#1

	data	
	
mp2player	incbin	mp2inc.bin

mp2song	incbin	f:\mp2\sound_of.mp2
mp2song_end

	bss
	
bufs	ds.l	4

	end
