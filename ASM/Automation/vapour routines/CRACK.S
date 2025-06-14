	move.l	4(sp),a5		;address to basepage
	move.l	$0c(a5),d0		;length of text segment
	add.l	$14(a5),d0		;length of data segment
	add.l	$1c(a5),d0		;length of bss segment
	add.l	#$100,d0		;length of basepage
	add.l	#$1000,d0		;length of stackpointer
	move.l	a5,d1			;address to basepage
	add.l	d0,d1			;end of program
	and.l	#-2,d1			;make address even
	move.l	d1,sp			;new stackspace

	move.l	d0,-(sp)		;mshrink()
	move.l	a5,-(sp)		;
	move.w	d0,-(sp)		;
	move.w	#$4a,-(sp)		;
	trap	#1		;
	lea	12(sp),sp		;

	move.l	#text,-(sp)
	move.w	#9,-(sp)
	trap	#1
	add.l	#6,sp

	move.w	#1,-(sp)
	trap	#1
	add.l	#2,sp


	clr.l -(a7)			; $4b program file
	move.l #ct,-(a7)
	move.l #game1,-(a7)
	clr.w -(a7)
	move.w #$4b,-(a7)
	trap #1
	lea 14(a7),a7

quit_ld	move.w #$4c,-(a7)		; Back to Desktop
	trap #1

ct		dc.l 0

game1	dc.b "TEAM.BUG",0
	even


	pea text
	move.w #9,-(sp)
	trap #1
	addq.l #6,sp

text	dc.b	'SHW/D-BUG PRESENTS :',13,10,10
	dc.b	'TEAM - NEW SEASON EDITION',13,10
	dc.b	'=========================',13,10,10
	DC.B	'THIS GAME IS STE ONLY!',13,10,10
	DC.B	"THANKS TO ALEX TURNPENNY",13,10
	DC.B	"FOR THE ORIGINAL.",13,10,10

	DC.B	'PACKED AND MADE HARD-DRIVE',13,10
	DC.B	'INSTALLABLE BY SHW.',13,10,10
*	         0123456789012345678901234567890123456789	
	DC.B	"NOTES: DON'T CHANGE THE DRIVE WHEN",13,10
	DC.B	'SAVING! DATA WILL SAVE TO THE DIR',13,10
	DC.B	'WHERE THE GAME WAS STARTED!',13,10,10
	DC.B	"TO CHANGE A TEAM TO A HUMAN PLAYER",13,10
	DC.B	"CLICK THE DESIRED TEAM TWICE UNTIL",13,10
	DC.B	"IT CHANGES TO BLUE.",13,10
	DC.B	"KEYS: P=PAUSE, ESC=QUITS, R=REPLAY",13,10
	DC.B	"S=BRING ON SUB, O=OVERSCAN, C=POSITION",0
	even
