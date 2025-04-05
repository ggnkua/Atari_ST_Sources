*****************************************
*       Speed-SWitcher MSTE  v1.1       *
*   by Daniel Eriksson of Delta Force.  *
*                                       *
*                 8 MHz                 *
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

* Run switching-routine in supervisor mode *
	pea	switch(pc)
	move.w	#38,-(sp)
	trap	#14			; Supexec (XBIOS)
	lea	6(sp),sp

* Write switching-text *
	pea	sw_text(pc)
	move.w	#9,-(sp)
	trap	#1			; Cconws (GEMDOS)
	lea	6(sp),sp

* Terminate *
	clr.w	-(sp)			; Pass a zero to parent-process
	move.w	#$4c,-(sp)
	trap	#1			; Pterm (GEMDOS)

* The switching routine *
switch:
	bclr.b	#0,$ffff8e21.w		; Disable cache-memory
	bclr.b	#1,$ffff8e21.w		; Set processor to 8 MHz
	rts

* Here's the DATA-segment *
	section	data
sw_text	dc.b	13,10,"Speed-SWitcher MSTE  v1.1  1992-02-11",13,10
	dc.b	"by Daniel Eriksson of Delta Force.",13,10
	dc.b	"Computer now switched to 8 MHz!",13,10
	dc.b	13,10,0

	END
