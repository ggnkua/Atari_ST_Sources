DEBUG2	equ 0

;
; routine de bases
;

; utilisation
;	lea rammovem,a0			; un buffer de 2294 octet
;	jsr prepclear32000		; a appeller un fois genere le code d'effacement de 32000 octet
;	

;  ***********************************************
prepclear32000		; a appeler qu'une fois
; a0 = ram de 571*4 movem repveté +4 dernier movem +4 lea +2 rts   2294 octet
; 14*4=56 32000/56 = 571  reste 24 octet


	move.l a0,d0
	move.l d0,clrauto1+2

	move.w #571-1,d0
	lea instruction,a1
	move.l (a1)+,d1
	move.l d1,(a0)+			; lea 32000(a0),a0
	move.l (a1)+,d1
.loop	move.l d1,(a0)+
	dbf d0,.loop
	move.l (a1)+,d1
	move.l d1,(a0)+
	move.w #$4e75,(a0)+
	rts
	


instruction
	lea 32000(a0),a0
	movem.l d0-d7/a1-a6,-(a0)
	movem.l d0-d5,-(a0)

clear32000:			; ne jamais appeler sans avoir au moins une fois appeler prepclear32000
; a0 = screen			; avec a0 = buffer de 2294 octets libre
	moveq #0,d0
	move.l d0,d1
	move.l d0,d2
	move.l d0,d3
	move.l d0,d4
	move.l d0,d5
	move.l d0,d6
	move.l d0,d7
	move.l d0,a1
	move.l d0,a2
	move.l d0,a3
	move.l d0,a4
	move.l d0,a5
	move.l d0,a6
clrauto1	jmp $00000000
instruction_movem

	movem.l d0,-(a0)

	dc.w %1100000000000000
	dc.w %1110000000000000
	dc.w %1111000000000000
	dc.w %1111100000000000
	dc.w %1111110000000000
	dc.w %1111111000000000
	dc.w %1111111100000000
	dc.w %1111111101000000
	dc.w %1111111101100000
	dc.w %1111111101110000

	dc.w %1111111101111000
	dc.w %1111111101111100
	dc.w %1111111101111110


;prepclear_arbitrary  ; efface un nombre x paire dans d0 element dans a0
;; a0 = ram ou le code sera genere
;
;	lea instruction,a1
;	move.w (a1),d2
;	move.w d2,(a0)+
;	move.w d0,(a0)+	   lea x(a0),a0
;
;	divu #14*4,d0
;	move.l d0,d1
;	swap d1			; d1 = reste de 14*4
;	lea instruction_movem,a2
;
;	tst.w d1
;	beq.s .zero
;	lsr #2,d1 		; d1/4 = nombre de registre
;	beq.s .word
;	move.w (a2)+,(a0)+
;  	subq #1,d1
 ; 	add.w d1,d1
 ; 	add.w d1,d1
 ;   move.w (a2,d1),(a0)+
;
;
;	
;   14*4 octet
;	movem.l d0-d7/a1-a6,-(a0)
;
;
;
;	move.l a0,d0
;	move.l d0,clrauto2+2
;
;	move.w #571-1,d0
;	lea instruction,a1
;	move.l (a1)+,d1
;	move.l d1,(a0)+			; lea 32000(a0),a0
;	move.l (a1)+,d1
;.loop	move.l d1,(a0)+
;	dbf d0,.loop
;	move.l (a1)+,d1
;	move.l d1,(a0)+
;	move.w #$4e75,(a0)+
;	rts


clear1024a0
	movem.l d0-d7/a1-a6,-(sp)
	moveq #0,d0
	move.l d0,d1
	move.l d0,d2
	move.L d0,d3
	move.l d0,d4
	move.l d0,d5
	move.l d0,d6
	move.l d0,d7
	move.l d0,a1
	move.l d0,a2
	move.l d0,a3
	move.l d0,a4
	move.l d0,a5
	move.l d0,a6
	lea 1024(a0),a0
	rept 18
	movem.l d0-d7/a1-a6,-(a0)
	endr
	movem.l d0-d3,-(a0)
	movem.l (sp)+,d0-d7/a1-a6
	rts


prepclearoneplan
; a0 = ram 2 moveq d0 + 2 rts +4000*4 move.w d0,dep(a0) = 16004 octet

	move.l a0,d0
	move.l d0,clearoneplan+2
	lea .instruction,a1
	move.w (a1)+,d1
	move.w d1,(a0)+
	move.w #3999,d0
.loop	move.l d1,(a0)+
	addq.w #8,d1
	dbf d0,.loop
	move.w #$4e75,(a0)+
	

.instruction
	moveq #0,d0
	move.w d0,$0000(a0)

clearoneplan:
; a0 = screen + 2*numero de plan de 0 a 3
	jmp $000000
mjj_sys_init:
	movem.l		d0-d7/a0-a6,-(sp)

	clr.l		-(sp)				; super mode
	move.w		#$20,-(sp)
	trap		#1
	addq.l		#6,sp
	move.l		d0,_mjj_stack

	move.w		#$2700,sr			; disable ints

	lea			_mjj_res,a1

	move.b		$FFFF8260.W,(a1)+	; store resolution
	move.b		$FFFF820A.W,(a1)+	; store frequency
	move.w		$FFFF820E.W,(a1)+	; store line width
	move.b		$FFFF8265.W,(a1)+	; store screen shift
	move.b		$44F.W,(a1)+		; store screen
	move.b		$450.W,(a1)+
	move.b		$451.W,(a1)+

	move.b		$FFFFFA07.W,(a1)+	; store mfp
	move.b		$FFFFFA13.W,(a1)+
	move.b		$FFFFFA09.W,(a1)+
	move.b		$FFFFFA15.W,(a1)+
	move.b		$FFFFFA17.W,(a1)+
	move.b		$FFFFFA19.W,(a1)+
	move.b		$FFFFFA1B.W,(a1)+
	move.b		$FFFFFA1D.W,(a1)+

	lea			$100.W,a0
	REPT 16
		move.l	(a0)+,(a1)+			; store mfp vectors
	ENDR

	move.l		$68.W,(a1)+			; store hbl
	move.l		$70.W,(a1)+			; store vbl
	move.w		$484.W,(a1)+		; store keyboard

	lea			$FFFF8240.W,a0		; store & clear palette
	move.w		(a0),d0
	REPT 16
		move.w	(a0),(a1)+
		IFEQ	DEBUG2
		move.w	d0,(a0)+
		ENDC
	ENDR

;	IFNE		FOR_MEGASTE
;	bsr			_megaste_init
;	ENDIF

;	IFNE		FOR_FALCON
;	bsr			_falcon_init
;	ENDIF

	IFEQ		DEBUG2
	clr.b		$FFFFFA07.W			; disable timers
	clr.b		$FFFFFA13.W
	clr.b		$FFFFFA09.W
	clr.b		$FFFFFA15.W
	ENDC

	IFEQ		DEBUG2
	move.b		#2,$FFFF820A.W		; 50hz
	clr.b		$FFFF8260.W			; low res
	ENDC

	move.l		#mjj_vbl,$70.W		; setup vbl

	move.w		#$2300,sr			; enable ints

	bsr			_disable_mouse		; bybye mouse
	bsr			_ikbd_flush			; flush keyboard

	movem.l		(sp)+,d0-d7/a0-a6
	rts

;-----------------------------------------------------------------------------
; mjj_sys_fini : restore sys
;-----------------------------------------------------------------------------

mjj_sys_fini:
	movem.l		d0-d7/a0-a6,-(sp)

	bsr			_ikbd_flush			; flush keyboard

	move.w		#$2700,sr			; disable ints

	lea			_mjj_res,a0

	move.b		(a0)+,$FFFF8260.W	; restore resolution
	move.b		(a0)+,$FFFF820A.W	; restore frequency
	move.w		(a0)+,$FFFF820E.W	; restore line width
	move.b		(a0)+,$FFFF8265.W	; restore screen shift
	move.b		(a0)+,$FFFF8201.W	;
	move.b		(a0)+,$FFFF8203.W	; restore screen
	move.b		(a0)+,$FFFF820D.W	;

	move.b		(a0)+,$FFFFFA07.W	; restore mfp
	move.b		(a0)+,$FFFFFA13.W
	move.b		(a0)+,$FFFFFA09.W
	move.b		(a0)+,$FFFFFA15.W
	move.b		(a0)+,$FFFFFA17.W
	move.b		(a0)+,$FFFFFA19.W
	move.b		(a0)+,$FFFFFA1B.W
	move.b		(a0)+,$FFFFFA1D.W

	lea			$100.W,a1
	REPT 16
		move.l	(a0)+,(a1)+			; restore mfp vectors
	ENDR

	move.l		(a0)+,$68.W			; restore hbl
	move.l		(a0)+,$70.W			; restore vbl
	move.w		(a0)+,$484.W		; restore keyboard

	lea			$FFFF8240.W,a1		; restore palette
	REPT 8
		move.l	(a0)+,(a1)+
	ENDR

	;IFNE		FOR_MEGASTE
	;bsr			_megaste_fini
	;ENDIF

	;IFNE		FOR_FALCON
	;bsr			_falcon_fini
	;ENDIF

	move.w		#$2300,sr			; enable ints

	bsr			_enable_mouse		; might be usefull

	move.l		_mjj_stack,-(sp)	; user mode
	move.w		#$20,-(sp)
	trap		#1
	addq.l		#6,sp

	movem.l		(sp)+,d0-d7/a0-a6
	rts

;-----------------------------------------------------------------------------
_disable_mouse:
;-----------------------------------------------------------------------------
	btst		#1,$FFFFFC00.W
	beq.s		_disable_mouse
	move.b		#$12,$FFFFFC02.W
	rts

;-----------------------------------------------------------------------------
_enable_mouse:
;-----------------------------------------------------------------------------
	btst		#1,$FFFFFC00.W
	beq.s		_enable_mouse
	move.b		#$8,$FFFFFC02.W
	rts

;-----------------------------------------------------------------------------
_ikbd_flush:
;-----------------------------------------------------------------------------
	bsr			waitvbl
	btst.b		#0,$FFFFFC00.W
	beq.s		.exit
	tst.b		$FFFFFC02.W
	bra.s		_ikbd_flush
.exit:
	rts

;	IFNE		FOR_MEGASTE
;-----------------------------------------------------------------------------
;
;_megaste_init:
;	cmpi.w		#MCH_MEGASTE,mjj_sysmch
;	bne.s		.no
;	move.b		$FFFF8E21.W,_mjj_mste
;	clr.b		$FFFF8E21.W
;.no:
;	rts
;
;_megaste_fini:
;	cmpi.w		#MCH_MEGASTE,mjj_sysmch
;	bne.s		.no
;	move.b		_mjj_mste,$FFFF8E21.W
;.no:
;	rts
;
;-----------------------------------------------------------------------------
;	ENDC

;	IFNE		FOR_FALCON
;-----------------------------------------------------------------------------
;
;_falcon_init:
;	cmpi.w		#MCH_FALCON30,mjj_sysmch
;	blt.s		.no
;	nop									; TODO
;.no:
;	rts
;
;_falcon_fini:
;	cmpi.w		#MCH_FALCON30,mjj_sysmch
;	blt.s		.no
;	nop									; TODO
;.no:
;	rts
;
;;-----------------------------------------------------------------------------
;	ENDIF

mjj_vbl:
;	jsr		_mjj_vbl_voidfn		; fn proc;
;	jsr		_mjj_vbl_voidfn		; zik proc
;	st		_mjj_vblflag

	addq.l #1,$466.w
	rte

;=============================================================================
				SECTION BSS
;=============================================================================


mjj_sysmch:		ds.w	1
_mjj_stack:		ds.l	1

_mjj_res:		ds.b	1			; screen resolution
_mjj_freq:		ds.b	1			; screen frequency
_mjj_linew:		ds.w	1			; screen line width
_mjj_shift:		ds.b	1			; screen shift
_mjj_scr:		ds.b	3			; screen ptr
_mjj_mfp:		ds.b	8			; mfp setup
_mjj_vec:		ds.l	16			; mfp vectors
_mjj_hbl:		ds.l	1			; system hbl
_mjj_vbl:		ds.l	1			; system vbl
_mjj_conterm:	ds.w	1			; keyboard conf
_mjj_pal:		ds.w	16			; system palette

_mjj_mste:		ds.w	1			; megaste cache & bus


;=============================================================================
;				END
;=============================================================================

rammovem	ds.b 2294
