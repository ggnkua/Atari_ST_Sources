*** remove all CR/LF from a text file then sub 32 ****
*** to produce a data file with an offset of 0-58 ****

	move.l	sp,a5
	move.l	4(a5),a5	;get basepage
	move.l	12(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1c(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp		;okay that's it memory free & allocated

;remove all CR/LF - $0a,$0d
	lea	oldtext,a0
	lea	newtext,a1
	lea	oldtextend,a2
remove:	cmp.l	a0,a2
	beq.s	sub32
	move.b	(a0)+,d0
	cmp.b	#$a,d0
	bne.s	notlf
	bra.s	remove
notlf:	cmp.b	#$d,d0
	bne.s	not_cr
	bra.s	remove
not_cr:	move.b	d0,(a1)+
	bra.s	remove

sub32:	lea	newtext,a0
	sub.l	a0,a1
	move.l	a1,d0
	move.l	d0,length
;length of text in d0
reduce	move.b	(a0),d1
	sub.b	#32,d1
	move.b	d1,(a0)+
	sub.l	#1,d0
	bne.s	reduce
;now save
	move.w	#0,-(sp)
	pea	newfile
	move.w	#$3c,-(sp)
	trap	#1
	addq	#8,sp
	move.l	d0,d7
	pea	newtext
	move.l	length,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp

	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq	#4,sp

	bsr	get_key

	clr.w	-(sp)
	MOVE.W	#$4c,-(SP)	; RETURN TO GEM DESKTOP.
	TRAP	#1
ERR:	bra.s	ERR


*******************
* CUSTOM ROUTINES *
*******************



***********************
* SUBROUTINES SECTION *
***********************
v_sync:	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts

get_key:
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

****************
* DATA SECTION *
****************
newfile:	dc.b	"text.raw"
length:	dc.l	0
oldtext:	incbin	pov28.txt
oldtextend:
	SECTION BSS
newtext:	ds.b	10000
