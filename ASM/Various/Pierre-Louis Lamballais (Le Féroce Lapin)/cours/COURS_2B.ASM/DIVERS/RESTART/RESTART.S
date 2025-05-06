
***********************************************
* reSTART! by Tom Hudson for START Magazine   *
*                                             *
* Copyright 1988 Antic Publishing Inc.        *
*			             *
* Restart system via Ctrl-Alt-Delete keypress *
* This program is a terminate-&-stay-resident *
* utility -- place in AUTO folder and it will *
* be installed at boot-up time.		  *
***********************************************

trap13	equ	$b4
memvalid equ	$420
conterm equ	$484
savptr	equ	$4a2
sysbase	equ	$4f2

begin:

* This is the code that installs reSTART *

	move.l	#trapin,-(sp)
	move.w	#38,-(sp)	;SUPER mode command
	trap	#14		;execute!
	addq.l	#6,sp

* Tell the world we're installed! *

	move.l	#inst_str,-(sp)	;Point to installation message
	move.w	#$09,-(sp)
	trap	#1		;print the message on the screen!
	addq.l	#6,sp

	clr.w	-(sp)		;termination code of 0
	move.l	#(end-begin+256),-(sp)	;Amount of RAM to keep resident
	move.w	#$31,-(sp)	;terminate, but stay resident!
	trap	#1

trapin:	move.l	trap13,oldtrap	;get old trap vector & save,
	move.l	#mytrap,trap13	;then substitute ours! 
	rts

* The actual trap-intercept code!			   *
* Looks for control-alternate-delete and resets the system *

mytrap:	clr.w	keyflag		;clear key flag	

* Set bit in conterm to return console key flags *
	ori.b	#8,conterm	;return console keys in keycode!
* Save misc registers in BIOS work area *
	movea.l	savptr,a1	;get BIOS save area address
	move.w	(sp)+,d0	;get old SR
	move.w	d0,-(a1)	;save in save area
	move.l	(sp)+,-(a1)	;save old PC
	move.l	sp,-(a1)	;save SSP
	move.l	a1,savptr	;save new BIOS save area ptr

* Now re-establish stack pointer *
	btst	#13,d0		;were we in user mode?
	bne	notuser		;no!
	move	usp,sp		;get user stack pointer

notuser:	cmpi.l	#$00020002,(sp)  opcode 2/device 2 (bconin/console)?
	bne	notbconin	;non ce n'est pas un appel … bconin

* Set key flag *
move.w	#1,keyflag	;flag on!  We will process returned value!

notbconin:	move.l	#retpoint,-(sp)	;Set up return info on
	move	sr,-(sp)	;stack, then...
	move.l	oldtrap,a0	;get old trap address
	jmp	(a0)		;and jump there!

retpoint:	tst.w	keyflag		;was it bconin?
	beq	nochek		;no!

* See if they hit Ctrl-Alt-Delete *

	CMP.L	#$0C53001F,D0	;Ctrl-Alt-Delete?
	BNE	NOCHEK		;No!

* It's the key!  Reset the system totally *

	clr.l	memvalid	;Force a real coldstart!  Reset button remains warm.
	move.l	sysbase,a0	;Find system base address 
	jmp	(a0)		;Jump to reset handler to do coldstart

* Normal return, restore some stuff and exit! *

nochek:	movea.l	savptr,a1	;get save area ptr
	move.l	(a1)+,sp	;restore stack pointer
	move.l	(a1)+,-(sp)	;restore return address
	move.w	(a1)+,-(sp)	;restore status register
	move.l	a1,savptr	;save new save area ptr
	rte			;and exit!

* Working data area *

keyflag: dc.w	0	;keypress process flag
oldtrap: dc.l	0	;old trap 13 vector

* Installation announcement string *

inst_str:
	dc.b	13,10
	dc.b	'*******************************',13,10
	dc.b	'*    ReSTART by Tom Hudson    *',13,10
	dc.b	'*   ',$BD,' 1988 Antic Publishing   *',13,10
	dc.b	'*    Version 1.0 installed!   *',13,10
	dc.b	'*******************************',13,10,10,0

end:
