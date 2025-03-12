; Grazey brings ya another 1 minute music hack, this time some

; Music by Donald Fakk Of S.O.T.E.

; Hacked Using MonST By The Best GRaZey From The PHF Of Kingston Upon Hull

; Bar code also By Grz/PHF

; Credit me if ya use this zak! 


	opt	x-				;ha ha ripper
	clr.l	-(sp)			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	bclr	#0,$484.w			;shhhh

	lea	store,a0		
	move.l	$70.w,(a0)+
	move.l	$110.w,(a0)+
	move.b	$fffffa01.w,(a0)+
	move.b	$fffffa03.w,(a0)+
	move.b	$fffffa05.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa0b.w,(a0)+
	move.b	$fffffa0d.w,(a0)+
	move.b	$fffffa0f.w,(a0)+
	move.b	$fffffa11.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	move.b	$fffffa1f.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	move.b	$fffffa23.w,(a0)+
	move.b	$fffffa25.w,(a0)+

	move.l	#2,d0
	jsr	driver
	move.l	#vbl,$70.w


grazey	cmp.b	#$39,$fffffc02.w
	bne.s	grazey

	move.w	sr,-(sp)			
	move.w	#$2700,sr		
	lea	store,a0		
	move.l	(a0)+,$70.w
	move.l	(a0)+,$110.w
	move.b	(a0)+,$fffffa01.w
	move.b	(a0)+,$fffffa03.w
	move.b	(a0)+,$fffffa05.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa0b.w
	move.b	(a0)+,$fffffa0d.w
	move.b	(a0)+,$fffffa0f.w
	move.b	(a0)+,$fffffa11.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1d.w
	move.b	(a0)+,$fffffa1f.w
	move.b	(a0)+,$fffffa21.w
	move.b	(a0)+,$fffffa23.w
	move.b	(a0)+,$fffffa25.w

	lea	$ffff8800.w,a0		;clr yammy
	move.l	#$0707ffff,(a0)
	move.l	#$08080000,(a0)
	move.l	#$09090000,(a0)
	move.l	#$0a0a0000,(a0)

	move.b	#$c0,$fffffa23.w		
	bset	#0,$484.w			
	move.w	(sp)+,sr			

	clr.w	-(sp)			;ta ta
	trap	#1

vbl	jsr	driver+4
	rte

driver	incbin	"sote.mus"	
	even

section	bss
store	ds.l	20

