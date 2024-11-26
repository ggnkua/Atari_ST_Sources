; a0 = pointer to filename
; a1 = pointer whereto
;

load_file	clr	-(sp)
	move.l	a0,-(sp)
	move	#$3d,-(sp)
	trap	#1
	move	d0,.handle
	
	move.l	a1,-(sp)
	pea	$7fffffff
	move	.handle,-(sp)
	move	#$3f,-(sp)
	trap	#1		;d0 = file length
	
	move	.handle,-(sp)
	move	#$3e,-(sp)
	trap	#1
	lea	24(sp),sp
	rts

.handle:	dc.w	0
