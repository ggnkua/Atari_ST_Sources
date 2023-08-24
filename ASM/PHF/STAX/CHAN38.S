; Channel 38 - Fried Bits Party Invitation Music

; By STAX (Tyan?)

; Hacked By Grazey/P.H.F. 

grazey	opt x+

******* POV DOWNLOAD DEVELOPMENT SWITCHES *********************************
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
	clr.l -(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	move.l	d0,stack
	endc

	bclr	#0,$484.w
	move.l	$70.w,old70

	lea	mfp,a0
	move.l	$134.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa19.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa1f.w,(a0)+

	move.b	#$40,$fffffa17.w
	move.b	#$21,$fffffa13.w
	move	#1,d0		;Tunes 0-3
	jsr	music
	jsr	music+4

	move.l	#vbl,$70.w

.lx	cmp.b	#$39,$fffffc02.w
	bne.s	.lx

	move.w	#$2700,sr
	move.l	old70,$70.w
	lea	mfp,a0
	move.l	$134.w,(a0)+
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa19.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa1f.w
	move.w	#$2300,sr


	move.l #$08080000,$ffff8800.w
	move.l #$09090000,$ffff8800.w
	move.l #$0a0a0000,$ffff8800.w


	ifeq	DOWNLOAD
	move.l	stack,-(sp)
	move.w	#$20,-(sp)
	trap	#1
	lea	6(sp),sp
	endc

	clr.w	-(sp)				
	trap	#1					

vbl	movem.l d0-a6,-(sp)			save registers
	jsr	music+4
	movem.l (sp)+,d0-a6			restore registers
	rte

stack	dc.l	0
old70	dc.l	0
mfp	ds.l	10
music	incbin 	chan38.mus
endmus	

	IFNE	DOWNLOAD
Code_End
Code_Length	equ	Code_End-Code_Start
	ENDC
