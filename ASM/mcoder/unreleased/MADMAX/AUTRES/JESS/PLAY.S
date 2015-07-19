*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*				*
*     PLAYER POUR MUSICS HOTLINE	!!!	*				
*				*
*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp

	moveq	#1,d0
	jsr	zik



main:	move.w	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	
	move.w	#2000,d0
stb	nop
	dbra	d0,stb
	
	move.w	#$555,$ffff8240	
	
	bsr 	zik+8
	
	move.w	#$000,$ffff8240
	
	cmp.b	#$39,$fffffc02.w
	bne.s	main



	clr.w	-(sp)
	trap	#1

	section	data

zik:	incbin	"m1.bin"
	incbin	"m2.bin"
	incbin	"m3.bin"
	end