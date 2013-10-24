***********************************
* DIR routine                     *
***********************************
	pea	message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

;get the current DTA
	move.w	#47,-(sp)
	trap	#1
	addq.l	#2,sp
	lea	olddta(pc),a0
	move.l	d0,(a0)

;set the dta
	pea	dta(pc)
	move.w	#26,-(sp)
	trap	#1
	addq.l	#6,sp

;read the first file in the directory
	move.w	#2,-(sp)
	move.l	#fname,-(sp)
	move.w	#78,-(sp)
	trap	#1
	addq.l	#8,sp
	bsr	print

;repeatedly read the next one until none left
loop	move.w	#79,-(sp)
	trap	#1
	addq.l	#2,sp
	tst.l	d0
	bne	exit
	bsr	print
	bra.s	loop

;restore original dta
exit:	move.l	dta(pc),-(sp)
	move.w	#26,-(sp)
	trap	#1
	addq.l	#6,sp

;wait for a key
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	clr.w	-(sp)
	trap	#1

; print filename in DTA
print:	lea	dta(pc),a6
	add.l	#30,a6
	lea	build,a2
	clr.l	d7
ploop:	move.b	(a6)+,d7	;get char
	beq	crlf		;0=end of name
	move.b	d7,(a2)+
	move.w	d7,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#4,sp
	bra.s	ploop
crlf:	move.w	#13,-(sp)
	move.w	#2,-(sp)
	trap	#1
	move.w	#10,-(sp)
	move.w	#2,-(sp)
	trap	#1
	addq.l	#8,sp
;now fix file so we can see
	move.w	#0,-(sp)
	move.w	#1,-(sp)
	pea	fix
	move.w	#$43,-(sp)
	trap	#1
	add.l	#10,sp
	lea	build,a3
	move.w	#12-1,d0
.loop:	clr.b	(a3)+
	dbf	d0,.loop
	rts

message	dc.b	27,'E'
	dc.b	"Hidden file finder",13,10,10
	dc.b	189," MAC SYS DATA 1991",13,10,10
	dc.b	"Finding files on drive  A:\",13,10,10
	dc.b	"Files found...",13,10,10,0
fix:	dc.b	"a:\"
build:	dcb.b	30,0
olddta:	dc.l	0
dta:	ds.b	46
fname	dc.b	"a:\*.*",0
	even
