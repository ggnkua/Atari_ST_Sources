*	*	*	*	*	*	*	*	*	*

sing	move.l	4(a7),a3		; base page
	move.l	#mystack,a7
	move.l	$c(a3),d0		; text len
	add.l	$14(a3),d0		; data len
	add.l	$1c(a3),d0		; BSS len
	add.l	#$100,d0		; basepage
	move.l	d0,-(sp)
	move.l	a3,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1			; release memory
	add.l	#12,sp

	move.l	#210000,-(sp)		; malloc data area
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,song_ptr
	add.l	#10000,d0
	move.l	d0,vset_ptr

	pea	env_str			; execute singsong
	pea	cmd_str
	pea	prog_nm
	move.w	#3,-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	add.l	#14,sp
	add.l	#256,d0
	move.l	d0,prog_ptr

	lea	song_nm,a4		; load song
	move.l	song_ptr,a5
	move.l	#$10000,a6
	bsr	open

	lea	vset_nm,a4		; load voice set
	move.l	vset_ptr,a5
	move.l	#200000,a6
	bsr	open

	move.l	prog_ptr,a0		; play the song
	move.l	song_ptr,12(a0)
	move.l	vset_ptr,16(a0)
	jsr	(a0)

	clr.w	-(sp)			; program terminate
	move.w	#$4c,-(sp)
	trap	#1

*	*	*	*	*	*	*	*	*	*

open	clr.w	-(sp)			; load a file
	move.l	a4,-(sp)		; a4 -> filename
	move.w	#$3d,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.w	d0
	bmi	diskerr
	move.w	d0,-(sp)		; store file handle

read	move.l	a5,-(sp)		; read file to data area
	move.l	a6,-(sp)
	move.w	d0,-(sp)
	move.w	#$3f,-(sp)
	trap	#1
	add.w	#12,sp
	move.l	d0,d7			; store length

close	move.w	#$3e,-(sp)		; close file
	trap	#1			; handle already on stack
	addq.l	#4,sp
	move.l	d7,d0
	tst.l	d0			; d0=bytes loaded, -ve=err
diskerr	rts

*	*	*	*	*	*	*	*	*	*

prog_ptr:	dc.l	0
song_ptr:	dc.l	0
vset_ptr:	dc.l	0

prog_nm:	dc.b	'singsong.prg',0
song_nm:	dc.b	'a:\demo1.4v',0
vset_nm:	dc.b	'a:\voice.set',0
		even
env_str:	dc.b	0,0
cmd_str:	dc.b	0,0

*

	ds.l	100			stack space
mystack	ds.w	1			(stacks go backwards)

*	*	*	*	*	*	*	*	*	*
