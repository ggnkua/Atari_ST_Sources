* Phoenix Bootsector v1.0 Source Code 3/10/91
* Coded (in about 230 bytes) by Agrajag for my Phoenix PD menu.

* Yes, it's pretty shit, but what do you expect for my first ever bootsector?

; Detects reset-resident routines- what a smartass I am!!!
; (No, only if the reset vector has been set.)

; It also puts #$1991 (The year, it was coded, dummy!) into $160, so you
; can check for that in your AUTO program to see it the boot has been
; changed, and put some code in to re-install it.

; See INSTALLP.S for details of how to install it.

	opt	o+,ow-		Optimisation on (ESSENTIAL this time!)

;	pea	colours		<<<< If you want to test it.
;	move	#38,-(sp)
;	trap	#14
;	addq.l	#6,sp
;	clr	-(sp)
; 	trap	#1
	
	opt	p+				HAS to be pc relative!

colours
	lea	$ff8240,a5
	move.l	#500,d5
.cols	move	#17,-(sp)
	trap	#14
	addq.l	#2,sp
	andi.l	#$777,d0
	move	d0,(a5)
	dbf	d5,.cols
message1
	move	#$1991,$160.w			Date-stamp it
	pea	text(pc)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp

resvector
	cmpi.l	#$31415926,$426			Reset-resident proggy?
	beq	reset_prog
	bra	error

reset_prog
	pea	text2(pc)
	move	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	move	#$700,(a5)
rr	move	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	swap	d0
	cmp.b	#$15,d0			Do you wish to clear the reset vector
	beq	clear_r
	bra	error

clear_r	clr.l	$426			Clear reset-vector
	move.l	4,$70			reset

error	
	move	#$777,(a5)
;	move	#7,-(sp)
;	trap	#1
;	addq.l	#2,sp
	rts

text	dc.b	27,'E',27,'Y',32,(32+10),'AGRAJAGGY SNAZZY BOOTY!',0
	ds.b	24

text2	dc.b	27,'Y',(32+11),(32+2),'THE RESET VECTOR HAS BEEN CHANGED!!!',27,'Y',(32+15),(32+12),'Clear it? (y/n)',0

bootend