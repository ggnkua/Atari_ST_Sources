; read/write/verify raw disk sector!


read_raw	move	#9,-(sp)		;amount= 0-9
	move	#0,-(sp)		;side
	move	#34,-(sp)		;track
	move	#3,-(sp)		;1st sector
	move	#0,-(sp)		;drive
	pea	0.w
	pea	buffer(pc)
	move	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	rts

write_raw	move	#3,-(sp)		;amout = 0-9
	move	#0,-(sp)		;side
	move	#7,-(sp)		;track
	move	#1,-(sp)		;start
	move	#0,-(sp)		;drive
	pea	0.w
	pea	buffer(pc)
	move	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	rts


verify_raw:
	move	#3,-(sp)		;amout = 0-9
	move	#0,-(sp)		;side
	move	#7,-(sp)		;track
	move	#1,-(sp)		;start
	move	#0,-(sp)		;drive
	pea	0.w
	pea	buffer(pc)
	move	#19,-(sp)
	trap	#14
	lea	20(sp),sp
	rts


	even
buffer:
