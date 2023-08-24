;Bonanza Brothers By Mark Wilson

;Hacked in 2min 35 seconds using Toxic MonST

;By Grazey from The P.H.F. Of East Yorkshire

;If you use this zak credit me or die........

;Not (G)ood (F)or (A)ssholes compat!

	opt	x+
	clr.l	-(sp)				
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,oldstk			
	bclr	#0,$484.w	

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	bsr	bars

	moveq	#0,d7			;Tunes 0-10
	bsr	music

	move.l	$70.w,oldint			
	move.l	#yoho,$70.w			

	move	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	move.l	oldint,$70.w			
	move.l	#$08080000,$ffff8800.w	
	move.l	#$09090000,$ffff8800.w
	move.l	#$0a0a0000,$ffff8800.w
	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w

	move.l	oldstk,-(sp)			
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				
	clr	-(sp)				
	trap	#1			

yoho	movem.l d0-a6,-(sp)			
	bsr	music+4
	bsr	bars+186
	bsr	bars+298
	movem.l (sp)+,d0-a6			
	move.l	oldint,-(sp)			
	rts					

bars	incbin bars.bin
music	incbin bonanza.mus
enmus

section bss
oldstk	ds.l	1
oldint	ds.l	1
oldcols	ds.w	16

