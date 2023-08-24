; Oh No More Froggies! By Antichrist/Jedi

; Hacked in a scandalous 20! minutes

; By the best GRaZey/P.H.F. 

; If you use any of these zaks credit :Antichrist/Jedi and me for
; the hacking

; *Multiple tunes* see bottom of file

grazey	opt x-

	clr.l	-(sp)				
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack+2
	bclr	#0,$484.w				

	clr	d0
	bsr	music

.ll	bsr	music+8
	move	$468.w,d0
.ll1	cmp	$468.w,d0
	beq.s	.ll1
	cmp.b	#$39,$fffffc02.w
	bne.s	.ll

quit	bsr	music+4

stack	move.l	#stack,-(sp)			
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr	-(sp)				
	trap	#1					


oldcols	ds.w	16
music	incbin 	onmf1.mus
endmus	

; onmf1.mus	;Intro music then pauses and carries on with music #2
; onmf2.mus	;End Music


