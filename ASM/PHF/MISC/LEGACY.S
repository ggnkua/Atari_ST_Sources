; Legacy Dentro Music By Jess Of OVR

; Hacked By Supernova/Cynix ( nice one )

; Rip from PE by Grz ( Very hard!! )

; This music is one of the best soundchip compositions I've heard for
; ages. Why weren't songs like this released in the late 80's/early 90's
; rather than now when the ST is dead! oh well thats life I suppose.

; I'm sure the last few bars of this song was used in Martin Galways'
; Ocean Loading Music version #2 ( As used in Matchday 2 ), didn't think
; we'd spot it Jess ?


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


;	clr.l -(sp)				
;	move.w	#$20,-(sp)			
;	trap	#1					
;	lea	6(sp),sp				
;	move.l	d0,stack

	move.w	#$2300,sr
	bclr	#0,$484.w				
	move.l	$70.w,old70

	move	#1,d0
	jsr	music

	move.l	#vbl,$70.w

	move.w	#7,-(sp)				
	trap	#1					
	lea	2(sp),sp				

	jsr	music+4

	move.l	old70,$70.w
	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w


	move.l	stack,-(sp)			
	move.w	#$20,-(sp)			
	trap	#1					
	lea	6(sp),sp  				

	clr.w	-(sp)				
	trap	#1					

vbl	movem.l d0-a6,-(sp)
	jsr	music+8
	movem.l (sp)+,d0-a6
	rte

stack	dc.l	0
old70	dc.l	0
music	incbin 	legacy.mus
endmus	

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
