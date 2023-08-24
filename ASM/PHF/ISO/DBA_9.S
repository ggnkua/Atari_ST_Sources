; D.B.A. 9 Musics

; By Iso of Sentry

; Files torturously transferred by Grazey/P.H.F. 

; Well actually one of the files was hacked! (intro music) using
; good ole monst, have you played Alien Breed 2 on the A1200 - awesome...

; Multiple tunes , yonder the file............

grazey	opt x-

******* DOWNLOAD DEVELOPMENT SWITCHES *********************************
YES	equ	1
NO	equ	0
DOWNLOAD	equ	YES
	ifne	DOWNLOAD
	include	transmit.s
	org	$20000
Code_Start
Exec_Addr
	ENDC


	ifeq	DOWNLOAD
	clr.l	-(sp)				
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp				
	move.l	d0,stack+2
	endc

	bclr	#0,$484.w				
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,oldcols
	bsr	bars

	moveq	#1,d0
	jsr	music(pc)

	move.l	#music+2,$4d2.w
	move.l	#ull,$4da.w
	move	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	clr	d0
	jsr	music(pc)
	clr.l	$4d2.w
	clr.l	$4da.w
	movem.l	oldcols,d0-d7
	movem.l	d0-d7,$ffff8240.w

stack
	ifeq	DOWNLOAD
	move.l	#stack,-(sp)			
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				
	endc

	clr	-(sp)				
	trap	#1					

ull	jsr	bars+186
	jsr	bars+298
	rts

oldcols	ds.w	16
bars	incbin	a:\bars.bin
music	incbin 	dba9intr.mus
endmus	

;dba9intr.mus
;action.mus
;arf_arf.mus
;famildog.mus
;hiyaplac.mus
;horrrorr.mus
;patatkro.mus
;shoarma.mus
;sinking.mus

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
