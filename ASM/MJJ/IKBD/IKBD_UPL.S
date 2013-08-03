;=============================================================================
; IKBD_UPL.S : Upload & execute code in the keyboard processor
;-----------------------------------------------------------------------------
;	TOBE/MJJPROD : Original code by Belzebub/ST Connexion
;-----------------------------------------------------------------------------
; tab size = 4
;=============================================================================


;-----------------------------------------------------------------------------
; - The code is uploaded at $86 in the 6301 internal RAM and is executed
; - The first byte of the user code must contains the branch offset
;	to the main func ($00 is common)
;-----------------------------------------------------------------------------


;=============================================================================
				TEXT
;=============================================================================


;-----------------------------------------------------------------------------
ikbd_upload:
;-----------------------------------------------------------------------------
;	- a0 -> ptr to init code
;	- a1 -> ptr to user code
;	- d0 -> size of init code
;	- d1 -> size of user code
;-----------------------------------------------------------------------------

	movem.l		d2/a2-a3,-(sp)
	lea			$FFFFFC02.W,a3					; ACIA data register

	; set loader size in boot
	clr.w		d2
	move.b		ikbd_boot_loadersize,d2
	add.w		d0,d2
	addi.w		#ikbd_loader_presize+ikbd_loader_postsize,d2
	move.b		d2,ikbd_boot_loadersize

	; set user code size in loader
	move.b		ikbd_loader_usersize,d2
	add.w		d1,d2
	move.b		d2,ikbd_loader_usersize

	; upload boot sequence
	lea			ikbd_boot_code,a2
	moveq		#ikbd_boot_size-1,d2
.upload_boot:
	bsr.s		.ikbd_wait
	move.b		(a2)+,(a3)
	dbra		d2,.upload_boot

	; pause output
	bsr.s		.ikbd_wait
	move.b		#$13,(a3)						; $13 = pause output func

	; execute boot
	bsr.s		.ikbd_wait
	move.b		#$22,(a3)						; $22 = execute ram func
	bsr.s		.ikbd_wait
	clr.b		(a3)							; $00B1 = execution start
	bsr.s		.ikbd_wait
	move.b		#$B1,(a3)

	; upload loader post code
	lea			ikbd_loader_postcode,a2
	moveq		#ikbd_loader_postsize-1,d2
	bsr.s		.ikbd_upload

	; upload init code
	movea.l		a0,a2
	move.w		d0,d2
	subq		#1,d2
	bsr.s		.ikbd_upload

	; upload loader pre code
	lea			ikbd_loader_precode,a2
	moveq		#ikbd_loader_presize-1,d2
	bsr.s		.ikbd_upload

	; upload user code
	movea.l		a1,a2
	move.w		d1,d2
	subq		#1,d2
	bsr.s		.ikbd_upload

	movem.l		(sp)+,d2/a2-a3
	rts

;-----------------------------------------------------------------------------

.ikbd_upload:									; upload on ikbd stack
	bsr.s		.ikbd_wait						; a2 = ptr
	move.b		0(a2,d2.w),(a3)					; d2 = size
	dbra		d2,.ikbd_upload
	rts

.ikbd_wait:										; wait for ACIA
	btst		#1,$FFFFFC00.W					; [Tx data register flag]
	beq.s		.ikbd_wait
	rts


;=============================================================================
				DATA
;=============================================================================


ikbd_boot_size:			equ		15
ikbd_loader_presize:	equ		17
ikbd_loader_postsize:	equ		6


;-----------------------------------------------------------------------------
ikbd_boot_code:
;-----------------------------------------------------------------------------
;	- this code is loaded in a small free ram block at $B0
;	- the byte ($AF) is always = 0, and is used to create the
;	  stack ptr together with ($B0)
;	- the stack is then used to upload the loader and is set to
;	  (end boot + loader size - 1), so the first byte of the loader will
;	  overwrite the 'bra Ready' instruction offset to branch on itself
;-----------------------------------------------------------------------------
								; $20	= upload function code
								; $0080	= upload ptr
								; $0B	= upload size
	dc.b	$20,$00,$B0,$0B		; upload sequence

								; stack ptr low byte
								; hi byte in $AF = 0
ikbd_boot_loadersize:
	dc.b	$B9					; ($B0) = #$B9+size

								; turn off interrupts
	dc.b	$0F					; ($B1)			sei

								; set stack ($AF,$B0)
	dc.b	$9E,$AF				; ($B2)			lds		$AF

								; D is a 16 bits register
								; mapped to A & B 8 bits registers
								; so A = ($11) & B = ($12)
	dc.b	$DC,$11				; ($B4)	Ready:	ldd		$11

								; wait receive flag
	dc.b	$2A,$FC				; ($B6)			bpl		Ready

								; store B
	dc.b	$37					; ($B8)			pshb

								; loop until the loader code
								; overwrite the bra offset
	dc.b	$20,$F9				; ($B9)			bra		Ready


;-----------------------------------------------------------------------------
ikbd_loader_precode:
;-----------------------------------------------------------------------------
;	- this code is loaded by the boot
;	- it move the boot code at $80 and modify it to upload the user code
;	  and execute it
;	- the user code overwrite the loader/init code
;-----------------------------------------------------------------------------
								; overwrite the bra offset in the boot code
	dc.b	$00					; ($BA)			dc.b	$0

								; relocate the boot code
	dc.b	$DC,$B4				; ($BB)			ldd		$B4
	dc.b	$DD,$80				; ($BD)			std		$80
	dc.b	$DC,$B6				; ($BF)			ldd		$B6
	dc.b	$DD,$82				; ($C1)			std		$82
	dc.b	$DC,$B8				; ($C3)			ldd		$B8
	dc.b	$DD,$84				; ($C5)			std		$84

								; restore the boot bra offset
	dc.b	$86,$F9				; ($C7)			ldaa	#$F9
	dc.b	$97,$86				; ($C9)			staa	$86
	
	; -- init code will be inserted here by ikbd_upload --

;-----------------------------------------------------------------------------
ikbd_loader_postcode:
;-----------------------------------------------------------------------------
								; set stack ptr
	dc.b	$8E,$00				;				lds		#$85+size
ikbd_loader_usersize:
	dc.b	$85

								; start uploading user code
	dc.b	$7E,$00,$80			;				jmp		$80


;=============================================================================
;				END
;=============================================================================

