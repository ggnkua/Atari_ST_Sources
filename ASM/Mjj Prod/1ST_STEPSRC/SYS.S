;=============================================================================
; DANCE DANCE DANCE !!
;  Tobe / MJJ PROD
;  DHS 10 years online compo
;-----------------------------------------------------------------------------
; SYS.S : system managment
;=============================================================================


;=============================================================================
				SECTION TEXT
;=============================================================================


;-----------------------------------------------------------------------------
; sys_detect : cookie based host detection (STE+)
;	arg : d0 (_MCH cookie value, $10000=STE, $30000=Falcon)
;	ret : d0 (1 if right host detected, 0 otherwise)
;-----------------------------------------------------------------------------

sys_detect:
	moveq		#0,				d1			; ret = 0
	move.l		$5A0.W,			d2			; cookie jar ptr
	beq.s		sys_detect_2				; no cookie jar
	movea.l		d2,				a0          ; first cookie ptr
sys_detect_0:
	move.l		(a0)+,			d2			; get cookie
	beq.s		sys_detect_2				; end of jar
	cmpi.l		#$5F4D4348,		d2			; check '_MCH'
	beq.s		sys_detect_1				; '_MCH' found
	addq.l		#4,				a0			; skip value
	bra.s		sys_detect_0				; next cookie
sys_detect_1:
	move.l		(a0)+,			d2			; get value
	cmp.l		d0,				d2			; check value
	bne.s		sys_detect_2				; wrong value
	moveq		#1,				d1			; STE : ret = 1
sys_detect_2:
	move.l		d1,				d0			; store result
	rts

;-----------------------------------------------------------------------------
; sys_backup : backup system
;-----------------------------------------------------------------------------

sys_backup:
	bsr			tos_vsync
	move.w		#$2700,			sr
	lea			$FFFF8200.W,	a0
	lea			sys_res,		a2
	move.w		$60(a0),		(a2)+		; store resolution
	move.w		$0A(a0),		(a2)+		; store frequency
	move.w		$0E(a0),		(a2)+		; store line width
	move.w		$64(a0),		(a2)+		; store screen shift
	move.w		$00(a0),		(a2)+		;
	move.w		$02(a0),		(a2)+		; store screen
	move.w		$0C(a0),		(a2)+		;
	lea			$FFFFFA00.W,	a1
	move.b		$07(a1),		(a2)+		; store mfp
	move.b		$0B(a1),		(a2)+
	move.b		$13(a1),		(a2)+
	move.b		$09(a1),		(a2)+
	move.b		$0D(a1),		(a2)+
	move.b		$15(a1),		(a2)+
	move.l		$70.W,			(a2)+		; store vbl
	move.w		$484.W,			(a2)+		; keyboard
	lea			$40(a0),		a0
	moveq		#7,				d0
sys_backup_0:
	move.l		(a0)+,			(a2)+		; store palette
	dbra		d0,sys_backup_0
	move.w		#$2300,			sr
	rts

;-----------------------------------------------------------------------------
; sys_setup : init system
;-----------------------------------------------------------------------------

sys_setup:
	lea			$FFFF8240.W,	a0			; setup pal
	lea			split_pal,		a1
	lea			ste_colors,		a2
	moveq		#15,			d0
	moveq		#15,			d3
sys_setup_0:
	move.w		(a0)+,			d1
	move.w		d1,				d2
	lsr.w		#8,				d2
	and.w		d3,				d2
	add.w		d2,				d2
	move.w		0(a2,d2.w),		(a1)+
	move.w		d1,				d2
	lsr.w		#4,				d2
	and.w		d3,				d2
	add.w		d2,				d2
	move.w		0(a2,d2.w),		(a1)+
	move.w		d1,				d2
	and.w		d3,				d2
	add.w		d2,				d2
	move.w		0(a2,d2.w),		(a1)+
	dbra		d0,sys_setup_0

	clr.b		$484.W						; keyboard
	bsr			tos_vsync
	move.w		#$2700,			sr
	lea			$FFFFFA00.W,	a0
	clr.b		$07(a0)						; disable mfp
	clr.b		$09(a0)
	lea			$FFFF8200.W,	a0
	move.b		#0,				$60(a0)		; low resolution
	move.b		#2,				$0A(a0)		; 50 hz frequency
	move.b		#64,			$0F(a0)		; line width
	clr.b		$65(a0)						; screen shift
	move.l		#sys_myvbl,		$70.W		; vbl
	move.w		#$2300,			sr
	IF dance_sid
		lea		sid_tvs,		a0			; setup sid
		lea		sid_tri,		a1
		bsr		sid_drv
		bsr		sid_drv+20					; effects off
		moveq	#64,			d0
.sid_skip:
		bsr		sid_drv+4
		dbra	d0,.sid_skip
	ELSE
		moveq	#1,				d0
		bsr		mus_drv						; setup mus
	ENDIF
	rts

;-----------------------------------------------------------------------------
; sys_restore : restore system
;-----------------------------------------------------------------------------

sys_restore:
	bsr			sys_vsync
	IF dance_sid
		bsr		sid_drv+8					; stop sid
	ELSE
		moveq	#0,				d0
		bsr		mus_drv+4					; stop mus
	ENDIF
	move.w		#$2700,			sr
	lea			$FFFF8200.W,	a0
	lea			sys_res,		a2
	move.w		(a2)+,			$60(a0)		; restore resolution
	move.w		(a2)+,			$0A(a0)		; restore frequency
	move.w		(a2)+,			$0E(a0)		; line width
	move.w		(a2)+,			$64(a0)
	move.w		(a2)+,			$00(a0)		;
	move.w		(a2)+,			$02(a0)		; restore screen
	move.w		(a2)+,			$0C(a0)		;
	lea			$FFFFFA00.W,	a1
	move.b		(a2)+,			$07(a1)		; restore mfp
	move.b		(a2)+,			$0B(a1)
	move.b		(a2)+,			$13(a1)
	move.b		(a2)+,			$09(a1)
	move.b		(a2)+,			$0D(a1)
	move.b		(a2)+,			$15(a1)
	move.l		(a2)+,			$70.W		; restore vbl
	move.w		(a2)+,			$484.W		; restore keyboard
	lea			$40(a0),		a0			; restore palette
	moveq		#7,				d0
sys_restore_0:
	move.l		(a2)+,			(a0)+
	dbra		d0,sys_restore_0
	move.w		#$2300,			sr
	rts

;-----------------------------------------------------------------------------
; sys_myvbl : new vbl
;-----------------------------------------------------------------------------

sys_myvbl:
	IF dance_sid
		bsr		sid_drv+4
	ELSE
		movem.l	d0-d7/a0-a6,	-(sp)
		bsr		mus_drv+8					; play mus
		movem.l	(sp)+,			d0-d7/a0-a6
	ENDIF
	not.w		sys_vblflag					; set flag
	rte

;-----------------------------------------------------------------------------
; sys_vsync : wait new vsync
;-----------------------------------------------------------------------------

sys_vsync:
	clr.w		sys_vblflag
sys_vsync_0:
	tst.w		sys_vblflag
	beq.s		sys_vsync_0
	rts

;-----------------------------------------------------------------------------
; tos_vsync : wait for xbios vsync
;-----------------------------------------------------------------------------

tos_vsync:
	move.w		#$25,			-(sp)
	trap		#14
	addq.l		#2,				sp
	rts


;=============================================================================
				SECTION BSS
;=============================================================================

sys_ok:			ds.w			1			; ste detected
sys_vblflag		ds.w			1			; demo vsync

sys_res:		ds.w			1			; screen resolution
sys_freq:		ds.w			1			; screen frequency
sys_linew:		ds.w			1			; screen line width
sys_shift:		ds.w			1			; screen shift
sys_scr:		ds.w			3			; screen ptr
sys_mfp:		ds.b			6			; mfp setup
sys_vbl:		ds.l			1			; system vbl ptr
sys_conterm:	ds.w			1			; keyboard conf
sys_pal:		ds.w			16			; system palette


;=============================================================================
;				END OF FILE
;=============================================================================

