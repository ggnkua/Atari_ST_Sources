; MAGI, Par AGOPIAN Mathias
; pour STMAG.
; Programme corrigeant 
; les modifications Hard du Falcon 030
;translation by Gunstick
;this is the stuff which goes into the bootsector
	include	MAKEBOOT.S

	section	TEXT

Prg	lea	$300000,a0
	cmp.l	#'MAGI',(a0)
	bne.s	.fin
	jmp	$c(a0)

.fin	lea	text(pc),a0
	bsr	print
	bsr	inkey
	move.w	d0,d7
	lea	cls(pc),a0
	bsr	print
	cmp.b	#'1',d7
	beq.s	.meg1
	move.b	#$8,$424.w
	move.b	#$8,$ff8001
	move.l	#$200000,$42e.w
	rts
.meg1	move.b	#$5,$424.w
	move.b	#$5,$ff8001
	move.l	#$100000,$42e.w
	rts
	
print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
	
inkey	move.w	#1,-(sp)	; Inkey
	trap	#1
	addq.l	#2,sp
	rts

text	dc.b	27,'E','Reconfigure memory',$a,$d
	dc.b	'to (1)MB or (2)MB : ',0
cls	dc.b	27,'E',0
	even
FinPrg

