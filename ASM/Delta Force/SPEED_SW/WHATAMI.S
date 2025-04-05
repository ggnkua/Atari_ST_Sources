*****************************************
*       Speed-SWitcher MSTE  v1.1       *
*   by Daniel Eriksson of Delta Force.  *
*                                       *
*              What am I?               *
*                                       *
*       First edited:  1991-12-25       *
*       Last edited :  1992-02-11       *
*                                       *
*      This is a shareware program.     *
*     If you like it and use it then    *
* please contact me at any of the below *
*         mentioned addresses!          *
*     [only legal stuff of course!]     *
*                                       *
* Written and developed in Devpac v2.25 *
*****************************************


; The program is totally position independent (pc-relative).

* Run fetch_status-routine in supervisor mode *
	pea	fetch_status(pc)
	move.w	#38,-(sp)
	trap	#14			; Supexec (XBIOS)
	lea	6(sp),sp

* Write detect-text *
	pea	de_text(pc)
	move.w	#9,-(sp)
	trap	#1			; Cconws (GEMDOS)
	lea	6(sp),sp

* Write status-text *
	lea	status(pc),a0
	cmp.b	#3,(a0)			; Check for 16 MHz and cache ON
	bne.s	next1
	pea	t16_on(pc)
	bra.s	ready
next1:
	cmp.b	#2,(a0)			; Check for 16 MHz and cache OFF
	bne.s	next2
	pea	t16_of(pc)
	bra.s	ready
next2:
	cmp.b	#0,(a0)			; Check for 8 MHz (and cache OFF)
	bne.s	next3
	pea	t8(pc)
	bra.s	ready
next3:
	pea	strange(pc)
ready:
	move.w	#9,-(sp)
	trap	#1			; Cconws (GEMDOS)
	lea	6(sp),sp

* Terminate *
	clr.w	-(sp)			; Pass a zero to parent-process
	move.w	#$4c,-(sp)
	trap	#1			; Pterm (GEMDOS)

* The fetch_status-routine *
fetch_status:
	move.b	$ffff8e21.w,d0
	and.b	#3,d0
	lea	status(pc),a0
	move.b	d0,(a0)
	rts

* Here's the DATA-segment *
	section	data
status	ds.b	1
de_text	dc.b	13,10,"Speed-SWitcher MSTE  v1.1  1992-02-11",13,10
	dc.b	"by Daniel Eriksson of Delta Force.",13,10,0
t16_on	dc.b	"You are running at 16 MHz and cache ON!",13,10,13,10,0
t16_of	dc.b	"You are running at 16 MHz and cache OFF!",13,10,13,10,0
t8	dc.b	"You are running at 8 Mhz (and cache OFF)!",13,10,13,10,0
strange	dc.b	"Your computer is really STRANGE!",13,10,13,10,0

	END
