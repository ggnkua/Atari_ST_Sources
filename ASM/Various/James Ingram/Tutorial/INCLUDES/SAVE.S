save_file:
* save file.
* name in a0
* address in a1
* length in d0

	pea	(a1)		; address
	move.l	d0,-(a7)	; length to save


* create file
	clr.w	-(a7)
	pea	(a0)
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7

	move.w	d0,d7

* save out data

	move.w	d0,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7

* close file
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts
	
