	bra.w	start

	INCLUDE	FSCR2.I
	TEXT

start:	move.l	4(sp),a5			* mshrink
	move.l	$0c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	addi.l	#$1000,d0
	move.l	a5,d1
	add.l	d0,d1
	andi.b	#%11111110,d1			* even address
	move.l	d1,sp
	move.l	d0,-(sp)
 	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	lea	12(sp),sp

* mxalloc - Reserve stram ONLY for screens.
	clr.w	-(sp)				* ST-RAM only!
	move.l	#320*200*2*3+256,-(sp)		* size of screens..
	move.w	#$44,-(sp)			* Code $44: Mxalloc()
	trap	#1
	addq	#8,sp
	tst.l	d0				* Check if there is ST-RAM enough.
	bgt.s	.ramok
* Not enough ST-RAM free :(
	clr.w	-(sp)
	trap	#1

* Initialize screenaddresses..
.ramok:	lea	scr,a0
	move.l	#320*200*2,d1
	addq.l	#3,d0				* / long even
	andi.b	#%11111100,d0			* \ address..
	move.l	d0,(a0)+
	add.l	d1,d0
	move.l	d0,(a0)+
	add.l	d1,d0
	move.l	d0,(a0)+

; Set supervisormode and save old stackpointer..
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq	#6,sp
	move.l	#ustk,sp			* Install own stack..

* Save old screenaddress..
	move.w	#2,-(sp)
	trap	#14
	addq	#2,sp
	move.l	d0,oldscr

	move.l	$70.w,oldvbl
	move.l	#NEWVBL,$70.w
; Save falcon-pallette..
	bsr	SAVE_FALCPAL
* Save resolution..
	bsr	SAVE_FV


loop:	move.b	$FFFFFC02.w,keycode

	cmpi.b	#2,keycode
	bne.s	.next1
	bsr.w	changeTo1
.next1:	cmpi.b	#3,keycode
	bne.s	.next2
	bsr.w	changeTo2
.next2:

	cmpi.b	#$39,keycode
	bne	loop

	move.l	oldscr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$ffff8200.w
	move.b	d1,$ffff820d.w

	lea	save_fv,a0
	bsr	CHANGE_FVFAST
	bsr	RESTORE_FALCPAL

	move.l	oldvbl,$70.w

	clr.w	-(sp)
	trap	#1



changeTo1:
	lea	vga100_16bit_160_100,a0
	suba.l	a1,a1
	movea.l	scr,a2
	bra.w	Screen.registerUpdate

changeTo2:
	lea	vga100_8bit_320_200,a0
	lea	pal,a1
	movea.l	scr,a2
	bra.w	Screen.registerUpdate

; INPUT:
; a0: resolutionsetter routine (null: no change)
; a1: palette (null: no change)
; a2: screen
; OUTPUT:
; d0.w=0: done, -1: not done, still pending
Screen.registerUpdate:
	moveq	#-1,d0

; If the previous update is still pending, just return.
	tst.w	Screen.updateRequested
	bne.s	.end
	
	move.l	a0,Screen.resRout
	move.l	a1,Screen.palAdr
	move.l	a2,Screen.adr
	st	Screen.updateRequested
	clr.l	d0

.end:	rts

; This should be called by the vbl. Uses datastructures set by user to
; update screenbase, resolution and palette.
Screen.update:
	tst.w	Screen.updateRequested
	beq.s	.end

; Set resolution, if it's not a null.
	move.l	Screen.resRout,d0
	beq.s	.res_done
	movea.l	d0,a0
	jsr	(a0)
.res_done:

; Set screenbase.
	move.l	scr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	move.b	d1,$FFFF820D.w

; Set palette, if it's not a null.
	move.l	Screen.palAdr,d0
	beq.s	.pal_done
	movea.l	d0,a1
	lea	$FFFF9800.w,a0
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop
.pal_done:

	clr.l	Screen.resRout			; Indicate no new res anymore.
	clr.l	Screen.palAdr			; Indicate no pal anymore.

.end:	clr.w	Screen.updateRequested
	rts

******** INTERRUPT ROUTINE CODE ********

NEWVBL:	addq.l	#1,$0466.w
	movem.l	d0-a6,-(sp)
	bsr.w	Screen.update
	move.l	vbl_gfx(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
	rte

vbl_gfx:DC.L	rts

rts:	rts



	data

pal:	dc.l	$00000000
	dc.l	$FFFF00FF
	dc.l	$FF000000
	dc.l	$000000FF
	rept	252
	dc.l	0
	endr

	bss

Screen.updateRequested:
	ds.w	1
Screen.palAdr:
	ds.l	1
Screen.resRout:
	ds.l	1
Screen.adr:
	ds.l	1

oldscr:	ds.l	1
oldvbl:	ds.l	1
scr:	ds.l	3
keycode:ds.w	1

	ds.l	256
ustk:


