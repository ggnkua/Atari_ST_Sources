; Risk's Lamebrain Demo

; Zaks By Danny O.

; Zak hacking by Grazey - Jan 1st 1994!

; Nice one Deano! (Exeter 0 Ull 1)
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




start	opt x-
	move.w	#$2300,sr
;	clr.l	-(sp)				
;	move	#$20,-(sp)			
;	trap	#1					
;	lea	6(sp),sp				
;	move.l	d0,stack+2
	bclr	#0,$484.w				

	move.w	#1,-(a7)
	pea	music+$93a(pc)
	jsr	music(pc)

.ll	cmp.b	#$39,$fffffc02.w
	bne	.ll
	lea	music+$7e8(pc),a1		
	jsr	music+$768(pc)

stack	move.l	#stack,-(sp)			
	move	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr	-(sp)				
	trap	#1					


oldcols	ds.w	16
hacked	dc.b	$ff,$ff
by 	dc.b	$ff
grazey	dc.b	0
in_1994	dc.b	0
	dc.b	0
music	incbin 	risk.drv
	incbin 	intro.mus
endmus	

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
