	SECTION	text

convertFormat
	displayDialog	#CONVERT,#16395,#.return

; set window title

	move.l	dialogTableAddress,a0
	move.w	dialogHandle(a0),d0
	rsrc_gaddr	#5,#CONVERTTITLE
	move.l	addrout,intin+4
	move.l	dialogTableAddress,a0
	wind_set	d0,#2


	rts

; the object that caused the return is in d0
.return
	cmpi.w	#CONVERTDONE,d0
	beq	.done

	jsr	selectObject

	cmpi.w	#_8TO16,d0
	beq	convert8To16

	cmpi.w	#_16TO8,d0
	beq	convert16To8

	cmpi.w	#STEREO2MONO,d0
	beq	convertStereoToMono

	cmpi.w	#MONO2STEREO,d0
	beq	convertMonoToStereo

	cmpi.w	#LEFT2LEFTRIGHT,d0
	beq	convertLeftToLeftRight

	cmpi.w	#RIGHT2LEFTRIGHT,d0
	beq	convertRightToLeftRight
.done
	rts