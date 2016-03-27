; Read and/or Write sector!

rwabs	move	#0,-(sp)		;0,1,2=drive
	move	#10,-(sp)		;start logical sector
	move	#57,-(sp)		;amount to read/write
	pea	buffer(pc)
	move	#0,-(sp)		;0,1,2,3=read/write/read+ignore/
	move	#4,-(sp)		;write+ignore
	trap	#13
	lea	14(sp),sp


	even
buffer:
