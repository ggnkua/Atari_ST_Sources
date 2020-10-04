;
; Xbios harddrive routines hook for SD card
;
; by Orion_ 05/2020
;

	section	text

	public	_HookupXbiosVectors
	public	_tos_bpb
	public	_sd_first_sector
	public	_SD_ReadData

	public	_WaitDemo

_HookupXbiosVectors:
	move.l	$4C2.w,d0	; _drvbits
	moveq	#2,d1		; start from drive C
.next_drive:
	btst.l	d1,d0		; test drive bit
	beq.s	.drive_available
	addq.b	#1,d1		; try next drive bit
	bra.s	.next_drive
.drive_available:
	move.w	d1,_sd_drive	; Save drive number
	bset.l	d1,d0		; Set new drive bit
	move.l	d0,$4C2.w	; _drvbits

	lea	$472.w,a0		; hdv_bpb
	lea	old_hdv_bpb+2,a1
	move.l	(a0),(a1)+		; set old vector in jmp adrs
	move.l	a1,(a0)+		; set new vector after the jmp

	lea	old_hdv_rw+2,a1
	move.l	(a0),(a1)+		; set old vector in jmp adrs
	move.l	a1,(a0)+		; set new vector after the jmp

	tst.l	(a0)+			; skip hdv_boot

	lea	old_hdv_mediach+2,a1
	move.l	(a0),(a1)+		; set old vector in jmp adrs
	move.l	a1,(a0)			; set new vector after the jmp

_WaitDemo:
	lea	$462.w,a0		; VBL counter
	move.l	(a0),d0
	addi.l	#200,d0			; wait ~4 seconds for the free demo version
.wait:	cmp.l	(a0),d0
	bne.s	.wait

	rts

;****************************************>

old_hdv_bpb:
	jmp	$CEDBCEDB
hdv_bpb:
	move.w	_sd_drive,d0
	cmp.w	4(a7),d0	; dev
	bne.s	old_hdv_bpb
	move.l	#_tos_bpb,d0
	rts

;****************************************>

old_hdv_rw:
	jmp	$CEDBCEDB
hdv_rw:				; LONG hdv_rw(WORD rw, UBYTE *buf, WORD count, WORD recno, WORD dev, LONG lrecno)
	move.w	_sd_drive,d0
	cmp.w	14(a7),d0	; dev
	bne.s	old_hdv_rw

	btst.b	#0,5(a7)	; test Read/Write bit (rw)
	bne.s	.out

	move.l	6(a7),a0	; buf
	move.w	10(a7),d1	; sector count
	subq.w	#1,d1		; dbra
	moveq	#0,d2
	move.w	12(a7),d2	; recno
	bpl.s	.ok
	move.l	16(a7),d2	; lrecno
.ok:
	add.l	_sd_first_sector,d2
.next:
	move.l	d2,d0
	addq.l	#1,d2		; next sector

	movem.l	d1-d2/a0,-(a7)
	bsr	_SD_ReadData
	movem.l	(a7)+,d1-d2/a0
	lea	512(a0),a0	; advance buffer of 1 sector size

	dbra	d1,.next

	moveq	#0,d0		; E_OK
	rts
.out:
	moveq	#-13,d0		; EWRPRO / write protect
	rts

;****************************************>

old_hdv_mediach:
	jmp	$CEDBCEDB
hdv_mediach:
	move.w	_sd_drive,d0
	cmp.w	4(a7),d0
	bne.s	old_hdv_mediach
	moveq	#0,d0		; MEDIANOCHANGE
	rts

;****************************************>

	section	data

_sd_drive:		dc.w	1
