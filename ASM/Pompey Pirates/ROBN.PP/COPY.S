dest	equ	$10000


;Relocator source for non-executable files.
;Don't forget to change destination addr
;at the top of this file
;don't forget to change file name at
;bottom of file


	clr.l	-(sp)
	move.w	#$20,-(sp)	;function supervisor
	trap	#1
	addq.w	#6,sp

;Text printer/trainer can be put in here
	dc.w	$a00a	;kill mouse

	clr.w	-(sp)
	pea	-1.w
	move.l	(sp),-(sp)
	move.w	#$05,-(sp)	;function set screen
	trap	#14
	lea	12(sp),sp

	clr.w	$ffff8240.w	;black background
	move.w	#$777,$ffff825e.w	;white text
	and.b	#$fe,$484.w	;kill key click


	pea	text(pc)
	move.w	#$09,-(sp)	;function printline
	trap	#1
	addq.w	#6,sp

wait	move.w	#7,-(sp)	;function waitkey
	trap	#1
	addq.w	#2,sp

	cmp.b	#$20,d0		;space ?
	bne.s	wait		;no


	lea	$80000,sp	;stack at top of halfmeg st
	move.w	#$2700,sr	;kill interupts for copydown


	lea	reloc(pc),a0
	lea	$200.w,a1	;unused space
	move.w	#dend-reloc-1,d7
loop	move.b	(a0)+,(a1)+
	dbra	d7,loop

	jmp	$200.w		;and relocate

reloc	lea	data,a0
	lea	dest,a1
	move.l	#end-data,d7	;file length
loop2	move.b	(a0)+,(a1)+
	subq.l	#1,d7
	bne.s	loop2

	jmp	dest		;run the sucker

dend	equ	*

text	dc.b	"HELLO",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"INSERT TEXT BETWEEN THESE QUOTES",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"",13,10
	dc.b	"PRESS SPACE TO CONTINUE",13,10,0


data	incbin	mydata.raw
end	equ	*