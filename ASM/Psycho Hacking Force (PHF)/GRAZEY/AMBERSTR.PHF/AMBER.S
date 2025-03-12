; Amberstar / Thalion

; Music By Mad Max From The Exceptions

; Hacked Using MonST By The Best GRaZey From The PHF Of Kingston Upon Hull

; Hacked December 1992

; Bar code also By Grz/PHF

; Credit me if ya use this zak! 

	opt	x-				;ha ha ripper
	clr.l	-(sp)			
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	bclr	#0,$484.w			;shhhh
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,col
	clr.w	$ffff8240.w

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
	move.l	#new110,$110.w

	lea	music,a0
	move.l	#music,offset

	move.l	#0,d0
	move.l	#1,d1
	jsr	driver
	jsr	bars

	lea	offs,a0
	
	move.l	#1,d0		;TUNE ?  0-16
	add.l	d0,d0
	add.l	d0,d0
	move.l	(a0,d0),a0
	add.l	offset,a0
	move.l	#1,d0
	move.l	#1,d1
	jsr	driver

	bset	#4,$fffffa09.w
	bset	#4,$fffffa0d.w
	bset	#4,$fffffa15.w
	bclr	#3,$fffffa17.w	;aei

	move.l	#new110,$110.w
	move.l	#vbl,$70.w

	and.b	#$f0,$fffffa1d.w
	and.b	#$f6,$fffffa25.w
	or.b	#$7,$fffffa1d.w

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

	movem.l	col,d0-d7
	movem.l	d0-d7,$ffff8240.w


	move.b	#$c0,$fffffa23.w		
	bset	#0,$484.w			
	move.w	(sp)+,sr			

	clr.w	-(sp)			;ta ta
	trap	#1

new110	move.w	#$2500,sr
	and.b	#$f0,$fffffa1d.w
	movem.l	d0-a6,-(sp)
	move.l	#1,d1
	jsr	driver+8		;duh
	movem.l	(sp)+,d0-a6
	ori.b	#7,$fffffa1d.w
	bclr	#4,$fffffa11.w
	rte

offs	dc.l	$0,$612,$bae,$1086,$16bc,$1c7c,$2428,$2a42,$31ea,$3ca0
	dc.l	$428c,$4710,$4b10,$50d2,$5dbe,$6354,$6906

vbl	jsr	bars+186		;Remove this line for no bars
	jsr	bars+298		;Remove this line for no bars
	rte

bars	incbin	"bars.bin"	
driver	incbin	"amber.drv"	
music	incbin	"amber.mus"
	even

section	bss
col	ds.l	8
store	ds.l	20
offset	ds.l	1

