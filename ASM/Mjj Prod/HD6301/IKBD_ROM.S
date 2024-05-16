;=============================================================================
; IKBD_TST.S : Dump the 6301 ROM
;-----------------------------------------------------------------------------
;	TOBE/MJJPROD
;-----------------------------------------------------------------------------
; tab size = 4
;=============================================================================


;=============================================================================
				TEXT
;=============================================================================


;-----------------------------------------------------------------------------
main:
;-----------------------------------------------------------------------------

	clr.l		-(sp)							; supervisor
	move.w		#$20,-(sp)
	trap		#1
	addq.l		#6,sp

	clr.b		$FFFFFA07.W						; disable interrupts
	clr.b		$FFFFFA09.W

	move.l		#vbl,$70.W						; setup vbl

	;-------------------------------------------------------------------------

	lea			init_code,a0					; setup ikbd
	moveq		#init_code_size,d0

	lea			user_code,a1
	moveq		#user_code_size,d1

	bsr			ikbd_upload

	;-------------------------------------------------------------------------

	lea			$FFFFFC00.W,a0					; load ROM
	lea			$FFFFFC02.W,a1
	lea			rom_buffer,a2
	move.w		#$1000-1,d0						; 4096 bytes
.loop:
	btst		#0,(a0)							; wait for receive
	beq			.loop
	move.b		(a1),(a2)+
	dbra		d0,.loop
	
	;-------------------------------------------------------------------------

	move.w		attr,-(sp)						; create file
	pea			fname
	move.w		#$3C,-(sp)
	trap		#1
	addq.l		#8,sp
	move.w		d0,handle

	pea			rom_buffer						; write file
	move.l		#$1000,-(sp)
	move.w		handle,-(sp)
	move.w		#$40,-(sp)
	trap		#1
	lea			12(sp),sp

	move.w		handle,-(sp)					; close file
	move.w		#$3E,-(sp)
	trap		#1
	addq.l		#4,sp

	pea			msg								; print message
	move.w		#$9,-(sp)
	trap		#1
	addq.l		#6,sp
	
.end:											; infinite loop
	nop
	bra.s		.end


;-----------------------------------------------------------------------------
vbl:
;-----------------------------------------------------------------------------
	rte											; empty vbl :)


;=============================================================================
;				INCLUDE
;=============================================================================


	INCLUDE		"IKBD_UPL.S"					; reusable ikbd code uploader


;=============================================================================
				DATA
;=============================================================================


attr:
	dc.w	0

fname:
	dc.b	"A:\IKBD_ROM.BIN", 0
	EVEN

msg:
	dc.b	"ROM Dumped !", 0
	EVEN


;-----------------------------------------------------------------------------


init_code_size:		equ		1					; size of init code
user_code_size:		equ		21					; size of user code


;-----------------------------------------------------------------------------
init_code:
;-----------------------------------------------------------------------------
	; 6301 interrupts are disabled by the loader
	; SCI is already in the transmit/receive mode
	; no special init needed, just a nop
	dc.b	$01					;			nop


;-----------------------------------------------------------------------------
user_code:
;-----------------------------------------------------------------------------
	dc.b	$0					; overwrite the loader bra offset

								; load ROM start adress
	dc.b	$CE,$F0,$00			;			ldx		#$F000

								; load a byte from ROM
	dc.b	$A6,$00				;	Loop:	ldaa	X,#0

								; wait for transmit
	dc.b	$7B,$20,$11			;	Wait:	bit		#$20,$11
	dc.b	$27,$FB				;			beq		Wait (-5)

								; transmit byte
	dc.b	$97,$13				;			staa	$13

								; check end of ROM, then infinite loop
	dc.b	$8C,$FF,$FF			;	End:	cpx		#$FFFF
	dc.b	$27,$FB				;			beq		End   (-5)

								; next ROM byte
	dc.b	$08					;			inx
	dc.b	$20,$EF				;			bra		Loop  (-17)


;=============================================================================
				BSS
;=============================================================================


handle:
	ds.w	1

rom_buffer:
	ds.b	$1000


;=============================================================================
				END
;=============================================================================

