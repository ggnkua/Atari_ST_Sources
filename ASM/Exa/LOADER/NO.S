	jmp	start(pc)
	include macro&co.s
	include fal_rez2.s

start
	pea	$200000
	trap	#$01
	
	bsr	init_trap

	asave_video
	;asave_palette
	;asave_screen
	trap	#3
	vsync


	vsync
	arestore_video
	trap	#3
	


	clr.l	-(sp)
	trap	#1
