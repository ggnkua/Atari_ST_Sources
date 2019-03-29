;*******************************************************************
;*                                                                 *
;* Published in the Ledgers Disk Magazine Volume 8                 *
;*                                           Release Date : 1/2/92 *
;*                                                                 *
;*******************************************************************

* musiq player for .MUS files!
* most tune inits are 0 or 1, else in brackets ....
* all ripping done by Tony -B-, so greet me or else !!!

	opt	d+

	pea	0.w
	move	#$20,-(sp)
	trap	#1
	addq	#6,sp

	moveq	#1,d0
	bsr	mus

scan	move	#37,-(sp)
	trap	#14
	addq	#2,sp

	bsr	mus+play
	
	cmp.b	#57,$fffffc02.w
	bne.s	scan
	
	lea	$ffff8800.w,a0
	move.l	#$8000000,(a0)
	move.l	#$9000000,(a0)
	move.l	#$a000000,(a0)
	
	pea	$4c0000
	trap	#1

mus	incbin	ninja_t.mus

play		=	$8

; play =$8
; newmax (1-9), ziggy, rings2, ninja_t
