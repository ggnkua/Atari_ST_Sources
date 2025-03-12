*************** Grafix ripper (c) MSD of P.O.V. 1988-1991 ******

	clr.l	-(sp)		;Set super stack equal
	move.w	#32,-(sp)	; to user stack before call
	trap	#1
	addq.w	#6,sp		;correct stack
	move.l	d0,stksv	;save old supervisor stack value

	move.b	#$12,$fffffc02.w
	bsr	get_rez
	bsr	get_base
	bsr	set_low_rez

	bsr	get_pal
;Switch off keyclick.
	move.l	#$484,a0
	MOVE.B	(A0),D0
	MOVE.B	D0,ORG_KEY
	MOVE.B	#%11111110,(a0)

	lea	BUF_PAL,a2
	bsr	set_pal
	MOVE.W	#8,WIDTH
	MOVE.W	#152,CORRECTION

MOVEMENT:
	bsr	v_sync
;	move.w	#$123,$ffff8240.w
	bsr	print_img
;	clr.w	$ffff8240.w

;	Now wait for a sign from the user.
WAIT:	move.w	$FFFC02,D0	;data from keyboard

; GSX key codes are in lower byte of MSB ( bits 24-17 )
; ASCII key codes are in lower byte of LSB ( bits 0-7 )

	ANDI.W	#$FF00,D0	;MASK off all but GSX key codes.
	ASR.L	#8,D0	;Shift key values down into the LSB of
			;D0, then use CMP.B

	CMP.B	#01,D0	;ESC
	BEQ	EXIT

	cmpi.b	#$48,D0	; up curcor key
	beq	DOWN

	cmpi.b	#$4D,D0 	; right cursor key
	beq	SHIFTRIGHT

	cmpi.b	#$4B,D0	; left cursor key
	beq	SHIFTLEFT

	cmpi.b	#$50,D0	; down cursor key
	beq	UP

	cmpi.b	#$52,D0	;INSERT
	beq	THINNER

	cmpi.b	#$47,D0	;CLR/HOME
	beq	WIDER

	cmpi.b	#$3B,D0
	beq	set_pal_1

	cmpi.b	#$3C,D0
	beq	set_pal_2

	cmpi.b	#$3D,D0
	beq	set_pal_3

	cmpi.b	#$3E,D0
	beq	set_pal_4

	cmp.b	#$3f,d0		;F5 - set pal from 32 bytes before
	beq	set_before	;image...

;	CMPI.B	#68,D0	; F10
;	BEQ	F10

	JMP	WAIT    ;not any of the keys we want so get another

EXIT:
;transfer screen to FALSE for saving at later date
	move.l	POS,$200.w
	lea	FALSE,A1
	move.l	screen_base,A0
	move.w	#32000-1,D0
move:	move.b	(A0)+,(A1)+
	dbf	d0,move

	move.l	POS,d0
	move.l	#space,d1
	sub.l	d1,d0
	move.l	d0,$200.w

;save palette to buffer
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,BUF_PAL
	move.l	#$484,a0
	MOVE.B	ORG_KEY,D0
	MOVE.B	D0,(A0)

flush	btst.b	#0,$fffffC00.w	;flush keyboard
	beq.s	flush2
	move.b	$fffffC02.w,d0
	bra.s	flush
flush2

bp	pea	save_mess
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

get	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp

	cmp.b	#"Y",d0
	beq.s	save
	cmp.b	#"y",d0
	beq.s	save
	cmp.b	#"n",d0
	beq.s	return
	cmp.b	#"N",d0
	beq.s	return
	bra	get
return	
;Switch on keyclick.
	move.l	#$484,a0
	MOVE.B	ORG_KEY,D0
	MOVE.B	D0,(A0)

;	MOVE.W	org_rez,-(sp)	; Set Res.
	MOVE.W	#1,-(SP)
	MOVE.L	screen_base,D0
	MOVE.L	D0,-(SP)	; PHYSBASE
	MOVE.L	D0,-(SP)	; LOGBASE
	MOVE.W	#5,-(SP)
	TRAP	#14
	ADD.l	#12,SP

	lea	old_pal,A2
	bsr	set_pal

	move.b	#$8,$fffffc02.w

;set 68000 to user mode from supervisor
	move.l	stksv,-(sp)	;recover old supervisor stack
	move.w	#32,-(sp)
	trap	#1		;back to user
	addq.w	#6,sp		;correct stack
	MOVE.W	#0,-(SP)
	TRAP	#1
	rts


save	move.w	#0,-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	addq.l	#8,sp
	tst.l	d0
	bmi	err
	move.w	d0,d7
	pea	degas
	move.l	#32066,-(sp)
	move.w	d7,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	add.l	#12,sp
	tst.l	d0
	bmi	err
	move.w	d7,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	addq.l	#4,sp
err	bra	return
filename	dc.b	"picture.pi1",0
	even
save_mess
	dc.b	27,'E'
	dc.b	"Do you want to save picture? (Y/N) ",0
	even

****************** revised 26/12/90 **************
print_img:
	move.l	POS,a0		;position in memory
	move.l	screen_base,a1	;screen_base
	move.l	a1,a2
	move.w	#200-1,d1	;lines down
.loop1	move.w	WIDTH,d0	;bytes ACROSS
	sub.w	#1,d0		;correction for DBF
	lsr.w	#2,d0
.loop2	move.l	(a0)+,(a1)+	;move grafix
	dbf	d0,.loop2	;until width=0
	lea	160(a2),a2
	move.l	a2,a1
	dbf	d1,.loop1
	rts

***************************

UP:	move.l	POS,a0
	MOVE.W	CORRECTION,D4
	SUB.W	#160,D4
	SUB.w	D4,a0
	move.l	a0,POS
	bra	MOVEMENT

DOWN:	MOVE.L	POS,A0
	CMP.L	#space,A0	;stop display at start of graphics.
	BLE	MOVEMENT
	MOVE.W	CORRECTION,D4
	SUBI.W	#160,D4
	ADD.W	D4,A0
	MOVE.L	A0,POS
	bra	MOVEMENT
SHIFTLEFT:
	MOVE.L	POS,A0
	ADD.W	#2,A0
	MOVE.L	A0,POS
	bsr	pause
	JMP	MOVEMENT
SHIFTRIGHT:
	move.l	POS,A0
	cmp.l	#space,A0	;prevent user from going beyond file
	ble	MOVEMENT	;into machine code data.
	sub.w	#2,A0
	move.l	A0,POS
	bsr	pause
	jmp	MOVEMENT
WIDER:	MOVE.W	WIDTH,D0
	CMP.W	#160,D0
	BGE	TOO_WIDE
	ADDI.W	#4,D0
	MOVE.W	D0,WIDTH

	sub.w	#4,CORRECTION
TOO_WIDE:
	bsr	pause
	BRA	MOVEMENT
THINNER:
	MOVE.W	WIDTH,D0
	CMP.W	#4,D0
	BLE	TOO_THIN
	SUBI.W	#4,D0
	MOVE.W	D0,WIDTH
	add.w	#4,CORRECTION
TOO_THIN:
	BSR	CLS
	bsr	pause
	BRA	MOVEMENT
set_pal_1:
	lea	PALETTE_1,a2
	bsr	set_pal
	bra	MOVEMENT
set_pal_2:
	lea	PALETTE_2,a2
	bsr	set_pal
	bra	MOVEMENT
set_pal_3:
	lea	PALETTE_3,a2
	bsr	set_pal
	bra	MOVEMENT
set_pal_4:
	move.l	POS,A2
	bsr	set_pal
	bra	MOVEMENT
set_before
	move.l	POS,a2
	sub.w	#32,a2
	bsr	set_pal
	bra	MOVEMENT

************************** revised 14/9/91 **************
get_pal	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_pal
	rts

set_pal
;next palette held in A2 on entry
	lea	$ffff8240.w,a0
	movem.l	(a2),d0-d7
	movem.l	d0-d7,(a0)
	rts
***************************************************


pause:	
	MOVE.L	D0,-(sp)
	MOVE.W	#65000,D0
PAU:	NOP
	DBRA	D0,PAU
	MOVE.L	(sp)+,D0
	RTS

CLS:	MOVE.W	#8000,D0
	MOVE.L	screen_base,A0
CLS1:	CLR.L	(A0)+
	sub.W	#1,D0
	BNE.S	CLS1
	RTS

********************** Subroutines added 26/12/90 **********
set_low_rez
	clr.w	-(sp)
	move.l	screen_base,-(sp)
	move.l	screen_base,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	rts

get_rez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	D0,org_rez
	rts

get_base
	move.w	#3,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,screen_base	;Store screen address
	rts

v_sync	movem.l	d0-d3/a0-a3,-(sp)
	move.w	#$25,-(sp)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d0-d3/a0-a3
	rts



stksv:		dc.l	1
screen_base:	dc.l	0
org_rez:	dc.w	0	;Origional rez. store.
POS:		dc.l	space	;position on memory of NICKED grafic
ORG_KEY:	dc.w	1
WIDTH:		dc.W	1
CORRECTION:	dc.w	0

;	random palettes
PALETTE_1	DC.W	$0000,$0777,$0666,$0555,$0444,$0333,$0222,$0111
		dc.w	$0700,$0070,$0007,$0123,$0527,$0763,$0521,$0777
PALETTE_2	DC.W	$0000,$0777,$0010,$0020,$0030,$0052,$0111,$0222
		DC.W	$0333,$0444,$0555,$0666,$0400,$0630,$0740,$0750
PALETTE_3	DC.W	$0000,$0700,$0600,$0500,$0400,$0300,$0200,$0007
		DC.W	$0070,$0111,$0222,$0333,$0444,$0555,$0666,$0777
	even
old_pal		ds.w	16
space:		incbin	"l:extasia1.prg"
degas		dc.w	00
BUF_PAL:	ds.b	32
FALSE:		ds.b	32000
		ds.b	32
PICEND:
