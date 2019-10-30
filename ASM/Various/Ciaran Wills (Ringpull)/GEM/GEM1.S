
* A simple demonstration program to make some AES calls
* Displays an alert box

* The GEM header...
	move.l	sp,a5
	lea	stack,sp	; Set up our own stack
	move.l	4(a5),a5
	move.l	12(a5),d0
	add.l	20(a5),d0
	add.l	28(a5),d0	; Work out memory required
	add.l	#256,d0		; Be on the safe side!
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr	-(sp)		; Dummy value
	move	#$4a,-(sp)	; GEMDOS #$4a: Mshrink
	trap	#1
	lea	12(sp),sp	; Fast way to add 12 to sp
* End of the GEM header

* appl_init call
	move.l	#appl_init,aespb
	bsr	aes

* form_alert call
	move.l	#form_alert,aespb
	move	#1,intin	; Default button (outlined)
	move.l	#alert_string	; Address of text string for box
	bsr	aes

* appl_exit call
	move.l	#appl_exit,aespb
	bsr	aes

* Now quit properly (Pterm)
	clr	-(sp)
	trap	#1

* The aes subroutine
aes:	movem.l	d0-a6,-(sp)
	move.l	#aespb,d1
	move.l	#$c8,d0
	trap	#2
	movem.l	(sp)+,d0-a6
	rts

	DATA
* Control arrays for AES calls
appl_init: DC.W 10,0,1,0,0
appl_exit: DC.W 19,0,1,0,0
form_alert: DC.W 52,1,1,1,0

alert_string: DC.B '[1][This is a sample GEM program!][ Wow! ]',0

aespb:	DC.L	contrl,global,intin,intout,addrin,addrout
vdipb:	DC.L	contrl,intin,ptsin,intout,ptsout
	BSS
contrl:	DS.W	128
global:	DS.W	16
intin:	DS.W	128
intout:	DS.W	128
addrin:	DS.W	128
addrout: DS.W	128
ptsin:	DS.W	128
ptsout:	DS.W	128
	DS.B	1024
stack:
