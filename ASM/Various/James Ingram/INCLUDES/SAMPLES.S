* Routines for dealing with samples

f_len	equ	26

load_unsign:
	bsr	load_a_sample

* d0 holds length... a6 holds address
	move.l	a6,a0
	move.l	d0,d1

.unsign:
	eor.b	#$80,(a0)+
	subq.l	#1,d1
	bne.s	.unsign
	rts


load_a_sample:
* enter with sample name in a0!

	clr.w	-(a7)
	pea	(a0)		; prepare for read

* don't read yet... check file length

	clr.w	-(a7)
	pea	(a0)		; prepare for search


	pea	dta
	move.w	#$1a,-(a7)
	trap	#1		; set dta address
	addq.l	#6,a7

	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7

	tst.w	d0
	beq.s	.found

.error:
	moveq	#-1,d0
	addq.l	#6,a7		; get rid of OPEN data!
	rts

.found:
* found the sample... reserve enough memory for it
	move.l	dta+f_len,d0	; get file length
	sub.l	#128,d0		; no file header!
	move.l	d0,.len

* make it a 256-byte boundary upwards!
* (for STe complex playing routines)
	add.l	#255,d0
	clr.b	d0

	move.l	d0,.len2


	move.l	d0,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7
	
	tst.l	d0
	bmi.s	.error
	beq.s	.error		; branch if memory error

* can do it!
	move.l	d0,a6		; keep address to load in at

* wipe the top of the memory area
	move.l	a6,a0
	add.l	.len2,a0
	move.w	#256-1,d0
.wipe:
	move.b	#$80,-(a0)
	dbra	d0,.wipe

	
	move.w	#$3d,-(a7)
	trap	#1		; open the file!
	addq.l	#8,a7
	move.w	d0,d6		; keep handle

* read first 128 bytes, to get them out of the way
	move.l	#128,d0
	bsr	read

* now read rest of file
	move.l	.len,d0
	bsr	read

* close the file
	move.w	d6,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	
	move.l	.len,d0
	move.l	.len2,d1
* returns address in a6 and length in d0
* length rounded up in d1
	rts

.mem_err:
* memory error!
	moveq	#-1,d0
	addq.l	#6,a7		; never OPEN!
	rts

.len	ds.l	1
.len2	ds.l	1

read:
* read d0 bytes to address in a6
	pea	(a6)
	move.l	d0,-(a7)
	move.w	d6,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	rts

dta	ds.b	44
