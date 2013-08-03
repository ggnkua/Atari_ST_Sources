;=============================================================================
; IKBD_TST.S : Test for IKBD_UPL.S
;-----------------------------------------------------------------------------
;	TOBE/MJJPROD
;-----------------------------------------------------------------------------
; tab size = 4
;=============================================================================


;-----------------------------------------------------------------------------
; - Generate colors with the 6301 and put them in the first palette register
;-----------------------------------------------------------------------------


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

	movea.l		$44E,a0							; clear screen
	move.w		#7999,d0
	moveq		#0,d1
.clr:
	move.l		d1,(a0)+
	dbra		d0,.clr

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

	lea			$FFFFFC02.W,a0					; draw colors
	lea			$FFFF8240.W,a1
	moveq		#0,d0
.loop:
	move.b		(a0),d0							; read ikbd byte
	move.w		d0,(a1)							; write palette register 0
	bra.s		.loop							; infinite loop


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


init_code_size:		equ		1					; size of init code
user_code_size:		equ		30					; size of user code


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

    							; load blue color
	dc.b	$86,$0F				;	Loop:	ldaa	#$0F
    							; wait for the transmit flag
	dc.b	$7B,$20,$11			;	Wait:	bit		#$20,$11
	dc.b	$27,$FB				;			beq		Wait (-5)
								; send byte
	dc.b	$97,$13				;			staa	$13

    							; load green color
	dc.b	$86,$F0				;			ldaa	#$F0
    							; wait for the transmit flag
	dc.b	$7B,$20,$11			;	Wait:	bit		#$20,$11
	dc.b	$27,$FB				;			beq		Wait (-5)
								; send byte
	dc.b	$97,$13				;			staa	$13

    							; load cyan color
	dc.b	$86,$FF				;			ldaa	#$FF
    							; wait for the transmit flag
	dc.b	$7B,$20,$11			;	Wait:	bit		#$20,$11
	dc.b	$27,$FB				;			beq		Wait (-5)
								; send byte
	dc.b	$97,$13				;			staa	$13

    							; infinite loop
	dc.b	$20,$E3				;			bra		Loop (-29)


;=============================================================================
				END
;=============================================================================

