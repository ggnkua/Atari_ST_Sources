**************************************
* Zen Republic¿ Boot Block Installer *
*             TEST COPY              *
*  Boot Block & Installer Code by:-  *
*          DRAVEN (19/4/94)          *
**************************************

PALETTE0	equ	$ffff8240

start
	clr.l	-(sp)		; set super mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,stack_save
	bsr	set_up		; branch to set up routine

main
	pea	screen_text(pc)	; main message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

get_key
	move.w	#7,-(sp)	; wait for key press
	trap	#1
	addq.l	#2,sp

	tst.w	d0		; scan d0 for correct key press
	beq.b	get_key		; not correct key

	cmp.b	#$1b,d0		; escape key = quit
	beq	exit

	cmp.b	#$0d,d0		; return key = install
	beq	do_boot

	bra.b	main		; return to start

do_boot
	pea	read_blk(pc)	; reading boot block message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

;first we read the old boot
	move.w	#1,-(sp)	; 1 sector to read
	clr.w	-(sp)		; side 0
	clr.w	-(sp)		; track 0
	move.w	#1,-(sp)	; start @ sector 1
	clr.w	-(sp)		; drive A
	clr.l	-(sp)		; not used
	pea	buffer		; read into here
	move.w	#8,-(sp)	; read boot sector
	trap	#14
	lea	20(sp),sp

	move.w	#150,d7		; delay for message
.loop	move.w	#$25,-(sp)	; wait for VBL
	trap	#14
	addq.l	#2,sp 
	dbf	d7,.loop

	lea	mycode,a0	; move my code into buffer
	lea	buffer+32,a1
	move.l	#mycodeend-mycode,d0
loop	move.b	(a0)+,(a1)+
	subq	#1,d0
	bne.s	loop

	move.b	skip,buffer
	move.b	skip+1,buffer+1
	move.b	skip+2,buffer+2

	move.w	#1,-(sp)	; now make it a boot sector
	move.w	#-1,-(sp)
	pea	-1
	pea	buffer
	move.w	#$12,-(sp)
	trap	#14
	lea	14(sp),sp
	bsr.b	write		; write boot block to disk
	bra	main		; branch to start

exit
	bsr	close_down	; quit routine
	clr.w	-(sp)
	trap	#1

write
	pea	write_blk(pc)	; writing boot block message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#1,-(sp)	; write new bootsector out
	clr.w	-(sp)
	clr.w	-(sp)
	move.w	#1,-(sp)
	clr.w	-(sp)
	clr.l	-(sp)
	pea	buffer
	move.w	#9,-(sp)
	trap	#14
	lea	20(sp),sp

	tst.w	d0		; test d0 for error in installing
	bmi.w	error		; 'disk write protected' etc.

	move.w	#150,d7		; delay for message
.loop	move.w	#$25,-(sp)	; wait for VBL
	trap	#14
	addq.l	#2,sp 
	dbf	d7,.loop

	rts

error
	pea	error_mess(pc)	; print error message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	move.w	#7,-(sp)	; wait for key
	trap	#1
	addq.l	#4,sp

	bra	main

***************
* Subroutines *
***************

*******************************
* Set up & shut down routines *
*******************************

set_up	
	bsr	kill_mouse
	bsr	get_res
	bsr	med_res
	bsr	save_palette
	bsr	set_palette
	rts

close_down
	bsr	restore_mouse
	bsr	set_org_res
	bsr	restore_palette
	rts

*********************************
* Routines to change resolution *
*********************************

get_res
	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	d0,org_res
	rts

set_org_res
	move.w	org_res,d0
	bra.s	set_res

set_low_res
	move.w	#0,d0
	bra.s	set_res
med_res	
	move.w	#1,d0	

set_res
	move.w	d0,-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

********************
* Palette routines *
********************

save_palette
	lea	PALETTE0,a0
	lea	old_pal,a1
	moveq	#4-1,d0
.loop
	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	rts

set_palette
	lea	new_pal,a0
	lea	PALETTE0,a1
	moveq	#4-1,d0
.loop
	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	rts

restore_palette
	lea	old_pal,a0
	lea	PALETTE0,a1
	moveq	#4-1,d0
.loop
	move.w	(a0)+,(a1)+
	dbf	d0,.loop
	rts

***********************************
* Disable & enable mouse routines *
***********************************

kill_mouse
	move.b	#$12,$fffffc02.w
	rts

restore_mouse
	move.b	#$08,$fffffc02.w
	rts

skip	bra.s	skip+32

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
	dc.b	27,'Y',12+32,13+32, "ZEN REPUBLIC¿"
	dc.b	0
	even

; virus free message

free
	dc.b	27,'c0',27,'b',15+32,27,'F'
	dc.b	27,'Y',15+32,09+32, "VIRUS FREE BOOT SECTOR"
	dc.b	0
	even

; possible virus found message

found							
	dc.b	27,'c0',27,'b',15+32,27,'F'
	dc.b	27,'Y',15+32,08+32, "> POSSIBLE VIRUS FOUND <"
	dc.b	27,'Y',17+32,03+32, "*-> SWITCH OFF ST(E) & RE-BOOT <-*"
	dc.b	0
	even

***************************************************************************
*
;;; END OF BOOTBLOCK CODE
*
***************************************************************************

mycodeend

screen_text
		;01234567890123456789012345678901234567890123456789012345678901234567890123456789
		dc.b	27,'E'
		dc.b	27,'f',1
		dc.b	27,'Y',32+03,32+((80-(line1end-line1))/2)
line1:
	dc.b	"ZEN REPUBLIC¿ BOOTBLOCK INSTALLER (Test Copy)"
line1end:
		dc.b	27,'Y',32+05,32+((80-(line2end-line2))/2)
line2:
	dc.b	"Bootblock Code and Installer Written by DRAVEN 19/4/94"
line2end:
		dc.b	27,'Y',32+12,32+((80-(line3end-line3))/2)
line3:
	dc.b	"************************"
line3end:
		dc.b	27,'Y',32+13,32+((80-(line4end-line4))/2)
line4:
	dc.b	"*                      *"
line4end:
		dc.b	27,'Y',32+14,32+((80-(line5end-line5))/2)
line5:
	dc.b	"* Return Key = Install *"
line5end:
		dc.b	27,'Y',32+15,32+((80-(line6end-line6))/2)
line6:
	dc.b	"* Escape Key = Quit    *"
line6end:
		dc.b	27,'Y',32+16,32+((80-(line7end-line7))/2)
line7:
	dc.b	"*                      *"
line7end:
		dc.b	27,'Y',32+17,32+((80-(line8end-line8))/2)
line8:
	dc.b	"************************"
line8end:
	dc.b	0

read_blk
	dc.b	27,'c0',27,'b',15+32,27,'E'
	dc.b	27,'Y',14+32,26+32, "** READING OLD BOOTSECTOR **"
	dc.b	0
	even

write_blk
	dc.b	27,'c0',27,'b',15+32,27,'E'
	dc.b	27,'Y',14+32,24+32, "** INSTALLING NEW BOOTSECTOR **"
	dc.b	0
	even

error_mess
	dc.b	27,'c0',27,'b',15+32,27,'E'
	dc.b	27,'Y',14+32,27+32, "** ERROR IN INSTALLING **"
	dc.b	0
	even

new_pal		dc.w	$000,$777

************************
      SECTION BSS
************************

org_res		ds.w	1
old_pal		ds.w	4
stack_save	ds.l	0

buffer	dcb.b	512,0