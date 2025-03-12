mycode

***************************************************************************
*
;; START OF BOOTBLOCK CODE
*
***************************************************************************

	bra.b	bb_start		
	dc.b	"ZEN REPUBLIC¿ Virus Free Boot Sector "
	dc.b	189			;Copyright symbol
	dc.b	" DRAVEN '94 "
	dc.b	0
	even

bb_start
	move.w	#7,$ffff8240.w		; border = sky blue
	move.w	#-1,$ffff825e.w		; text = white

	pea	mess(pc)		; print 'ZEN REPUBLIC¿' 
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.l	$426.w,d0		; get reset vector
	cmp.l	#$31415926,d0		; has reset vector been enabled?
	beq	found_mess		; yes reset been changed

	movea.l	$42a.w,a0		; system reset bale out vector
	movea.l	a0,a4			; store for later
	lea	16(a0),a0		; get values above address start of reset code
	move.l	(a0)+,d0
	cmp.l	#$12123456,d0		; a check for known virus
	beq	found_mess
	
	adda.l	#$14,a4
	move.l	(a4),d0
	cmp.l	#$12123456,d0		; and another...
	beq	found_mess

	move.l	$472.w,d0		; get hard disc boot program block
	move.l	$4F2.w,d1		; base of RAM
	movea.l	d0,a0
	cmp.l	#$6072606A,(a0)		; check if any PROGRAM is stashed at bottom of RAM
	beq.b	free_mess		; this is to check to see if base of RAM
					; has been altered, if it has then it will
					; probably indicate a virus in memory

	cmp.l	d1,d0
	bls.b	found_mess		; possible virus found

free_mess
	pea	free(pc)		; virus not found
	move.w	#9,-(sp)		; print virus free message
	trap	#1
	addq.l	#6,sp

	bsr	sound_free		; call sound routine

	move.l	#$54120,d1		; delay
delay	subq.l	#1,d1
	bne.b	delay

**********************************************************
*
; This bit makes the screen go white after displaying 
; the virus free message (black text on white background)
; after the delay

	move.w	#-1,$ffff8240.l		; white
	move.w	#0,$ffff825e.l		; black

; Remove these instructions for the screen to stay blue with
; white text
*
**********************************************************

	rts

found_mess
	move.w	#$700,$ffff8240.w	; change background to red
	pea	found(pc)		; print virus found message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	bsr	sound_found		; call the sound routine
.loop	bra.s	.loop			; 

sound_free
	lea	$ffff8800.w,a4		; call sound
	move.w	#15,d0
	lea	sounds(pc),a0
.snd	move.b	d0,(a4) 
	move.b	(a0)+,2(a4) 
	dbf	d0,.snd

	move.w	#150,d7			; delay
.loop	move.w	#$25,-(sp)		; wait for VBL
	trap	#14
	addq.l	#2,sp 
	dbf	d7,.loop

	moveq	#$a,d0			; kill sound
.snd2	move.b	d0,(a4)
	clr.b	2(a4)
	dbf	d0,.snd2
	move.b	#7,(a4)
	move.b	#$FF,2(a4)
	rts

sound_found
	lea	$ffff8800.w,a4		; call sound
	move.w	#15,d0
	lea	sounds(pc),a0
.snd	move.b	d0,(a4) 
	move.b	(a0)+,2(a4) 
	dbf	d0,.snd

	move.w	#150,d7			; delay
.loop	move.w	#$25,-(sp)		; wait for VBL
	trap	#14
	addq.l	#2,sp
	dbf	d7,.loop
	rts				; note the kill sound code is
					; not used, hence the sound
					; loops

********************
* Initialised data *
********************

	SECTION	DATA

; here's the sound data

sounds	dc.b	$00,$27,$0A,$00,'v',$10,$10,$00
	dc.b	$F8,$08,$07,'w',$0E,$EE,$00,$00

; main boot sector message

mess
	dc.b	27,'c0',27,'b',15+32,27,'F'
	dc.b	27,'Y',09+32,13+32, "ZEN REPUBLIC¿"
	dc.b	0
	even

; virus free message

free
	dc.b	27,'c0',27,'b',15+32,27,'F'
	dc.b	27,'Y',12+32,09+32, "VIRUS FREE BOOT SECTOR"
	dc.b	0
	even

; possible virus found message

found							
	dc.b	27,'c0',27,'b',15+32,27,'F'
	dc.b	27,'Y',12+32,08+32, "> POSSIBLE VIRUS FOUND <"
	dc.b	27,'Y',14+32,03+32, "*-> SWITCH OFF ST(E) & RE-BOOT <-*"
	dc.b	0
	even

***************************************************************************
*
;;; END OF BOOTBLOCK CODE
*
***************************************************************************

mycodeend