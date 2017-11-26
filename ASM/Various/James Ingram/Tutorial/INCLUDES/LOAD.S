load_file:
* LOAD file.
* name in a0
* address in a1
* length in d0

	pea	(a1)		; address
	move.l	d0,-(a7)	; length to save


* open file
	clr.w	-(a7)
	pea	(a0)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7

	move.w	d0,d7

* load in data

	move.w	d0,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7

* close file
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts
	
