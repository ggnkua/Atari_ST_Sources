* For POV 28 menu.
*
*** remove all CR/LF from a text file then sub 32 ****
*** to produce a data file with an offset of 0-58 ****

;
; IN:   POV28.TXT
; OUT:  TEXT.RAW
;

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

	clr.w	-(sp)
	TRAP	#1


****************
* DATA SECTION *
****************
newfile:	dc.b	"text.raw",0,0
		even
length:	dc.l	0
oldtext:	incbin	pov28.txt
oldtextend:
	SECTION BSS
newtext:	ds.b	10000
