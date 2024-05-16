************************************************
*                                              *
* << Virus are dead, Boot Module: >>           *
* ----------------------------------           *
*                                              *
* This file is the source of the :             *
* << Virus are dead ... >> boot module. It's   *
* only a very little bit enhanced version of   *
* the << Original boot >>. I give this source  *
* to give you a little idea to all persons who *
* want to code a boot modul and want a tiny    *
* example.                                     *
*                                              *
* << Code : GT Turbo (GT) >>                   *
*                                              *
*                                              *
*                        << C.V.S.D. 1995 >>   *
*                                              *
************************************************

	OPT	a+,d-

************************************************
*                                              *
************************************************

* This equivalence must be to another value than zero to test your
* boot. When you save your boot to include it in << ALYZEE >> never
* forget to set it a zero.

Boot_test	EQU	-1

************************************************
*                                              *
************************************************

	IFNE	Boot_test

	clr.l	-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq.w	#6,a7
	move.l	d0,-(a7)

	jsr	Boot(pc)	

	move.w	#7,-(a7)
	trap	#1
	addq.w	#2,a7
	
	move.w	#$20,-(a7)
	trap	#1
	addq.w	#6,a7

	clr.w	-(a7)
	trap	#1	
	
	ENDC


************************************************
*                                              *
* << The Boot Modul itself : >>                *
* -----------------------------                *
*                                              *
*                                              *
************************************************

	dc.b	"CVSD1995"
	dc.b	"ALYZEE44"

	dc.b	"<< Virus are ..., . GT Turbo. >>"	

	dc.w	%11111

	dc.w	3

	dc.w	9

	dc.w	First_line_txt-Boot+2
	
	dc.w	Scond_line_txt-Boot+2

	dc.w	Boot_end-Boot

Boot:	move.b	#$7,$484.w
	move.b	#$2,$ffff820a.w

	lea	Tos_ver+23(pc),a1
	move.l	$4f2.w,a0
	move.w	2(a0),d0
	move.w	d0,d1
	lsr.w	#8,d0
	add.b	#"0",d0
	move.b	d0,(a1)+
	move.b	#".",(a1)+
	add.b	#"0",d1
	move.b	d1,(a1)

	pea	GT_txt(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.w	#6,a7

	rts

GT_txt:	dc.b	27,"p"
	dc.b	"**********************************",13,10
	dc.b	"* << ALYZEE 4.4 : GT Turbo of >> *",13,10
	dc.b	"*       << C.V.S.D 1995 >>       *",13,10
Tos_ver:	dc.b	"*    << Tos  Version :     >>    *",13,10
	dc.b	"**********************************",13,10
	dc.b	"*                                *",13,10
First_line_txt:	dc.b	"*                                *",13,10
Scond_line_txt:	dc.b	"*                                *",13,10
	dc.b	"*                                *",13,10
	dc.b	"*  << Virus are all dead !!! >>  *",13,10
	dc.b	"**********************************",13,10
	dc.b	27,"q",0
	EVEN
Boot_end:

	