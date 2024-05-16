;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; SCREEN.S : screen managment
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; calc_init : setup screens
;-----------------------------------------------------------------------------

scr_init:
	lea			scr_buf_1,		a0
	lea			64(a0),			a0
	move.l		a0,scr_front
	lea			scr_buf_2,		a0
	lea			64(a0),			a0
	move.l		a0,scr_back
	
	move.l		$44E.W,			a0
	move.w		#1999,			d0
scr_init_0:
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	clr.l		(a0)+
	dbra		d0,scr_init_0

	bsr.s		scr_clear
	bsr.s		scr_swap
	bsr.s		scr_clear
	bsr			scr_show
	rts

;-----------------------------------------------------------------------------
; scr_clear : clear back buffer
;-----------------------------------------------------------------------------

scr_clear:
	movem.l		d0-d1/a0,		-(sp)
	moveq		#2,				d0
	moveq		#-1,			d1
	lea			$FFFF8A20.W,	a0
	move.w		d0,				(a0)+		; source X increment
	move.w		d0,				(a0)+		; source Y increment
	move.l		scr_front,		(a0)+		; source address
	move.l		d1,				(a0)+		; mask 1 & 2
	move.w		d1,				(a0)+		; mask 3
	move.w		d0,				(a0)+		; destination X increment
	move.w		d0,				(a0)+		; destination Y increment
	move.l		scr_back,		(a0)+		; destination address
	move.l		#$900148,		(a0)+		; surface size
	move.w		#$0100,			(a0)+		; mode
	move.w		#$C000,			(a0)		; start
	nop
	movem.l		(sp)+,			d0-d1/a0
	rts

;-----------------------------------------------------------------------------
; scr_swap : swap buffers
;-----------------------------------------------------------------------------

scr_swap:
	movem.l		a0-a1,			-(sp)
	move.l		scr_back,		a0
	move.l		scr_front,		a1
	move.l		a0,scr_front
	move.l		a1,scr_back
	movem.l		(sp)+,			a0-a1
	rts

;-----------------------------------------------------------------------------
; scr_show : display front buffer
;-----------------------------------------------------------------------------

scr_show:
	movem.l		a0-a1,			-(sp)
	lea			$FFFF8200.W,	a0
	lea			scr_front,		a1
	move.b		$01(a1),		$01(a0)
	move.b		$02(a1),		$03(a0)
	move.b		$03(a1),		$0D(a0)
	movem.l		(sp)+,			a0-a1
	rts


;-----------------------------------------------------------------------------
; scr_black : black palette
;-----------------------------------------------------------------------------

scr_black:
	movem.l		d0/a0,			-(sp)
	lea			$FFFF8240.W,	a0
	moveq		#0,				d0
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	movem.l		(sp)+,			d0/a0
	rts

;-----------------------------------------------------------------------------
; scr_white : white palette
;-----------------------------------------------------------------------------

scr_white:
	movem.l		d0/a0,			-(sp)
	lea			$FFFF8240.W,	a0
	moveq		#-1,			d0
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	move.l		d0,				(a0)+
	movem.l		(sp)+,			d0/a0
	rts


;=============================================================================
				SECTION BSS
;=============================================================================


scr_front:		ds.l			1
scr_back:		ds.l			1

scr_dmz_1:		ds.b			18176
scr_top:		ds.b			36864
scr_buf_1:		ds.b			57600
scr_middle:		ds.b			36864
scr_buf_2:		ds.b			57600
scr_bottom:		ds.b			36864
scr_dmz_2:		ds.b			18176

;  128   320   128      = 576 pixels
; +---+-------+---+
; |   |       |   | 128 * 576 =  73728 pixels = 36864 bytes
; +---+-------+---+
; |   |       |   |
; |   |       |   | 200 * 576 = 115200 pixels = 57600 bytes
; +---+-------+---+
; |   |       |   | 128 * 576 =  73728 pixels = 36864 bytes
; +---+-------+---+
; |   |       |   |
; |   |       |   | 200 * 576 = 115200 pixels = 57600 bytes
; +---+-------+---+
; |   |       |   | 128 * 576 =  73728 pixels = 36864 bytes
; +---+-------+---+
;                              --------
;                               451584 pixels = 225792 bytes
;

;=============================================================================
;				END OF FILE
;=============================================================================

