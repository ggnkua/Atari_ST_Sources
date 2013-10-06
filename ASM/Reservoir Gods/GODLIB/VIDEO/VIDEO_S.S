**************************************************************************************
*	VIDEO_S.S
*
*	video register manipulation FUNCTIONs
*
*	[c] 2000 Reservoir Gods
**************************************************************************************

**************************************************************************************
;	EXPORTS / IMPORTS
**************************************************************************************

	export	Video_SaveRegsST
	export	Video_RestoreRegsST
	export	Video_SaveRegsSTE
	export	Video_RestoreRegsSTE
	export	Video_SaveRegsTT
	export	Video_RestoreRegsTT
	export	Video_SaveRegsFalcon
	export	Video_RestoreRegsFalcon

	export	Video_UpdateRegsST
	export	Video_UpdateRegsSTE
	export	Video_UpdateRegsTT
	export	Video_UpdateRegsFalcon
	
	export	Video_GetPalST
	export	Video_SetPalST
	export	Video_GetPalTT
	export	Video_SetPalTT
	export	Video_GetPalFalcon
	export	Video_SetPalFalcon

	export	Video_XbiosSetScreen
	export	Video_XbiosFalconSetLow

	export	Video_SetFalconSTLowVGA
	export	Video_SetFalconSTLowRGBPAL_W
	export	Video_SetFalconSTLowRGBNTSC_W
	export	Video_SetFalconSTLowRGBPAL
	export	Video_SetFalconSTLowRGBNTSC

	import	gVideo


**************************************************************************************
;	STRUCTS
**************************************************************************************

	OFFSET

sVideo_pPhysic:				ds.l	1
sVideo_pPalST:				ds.l	1
sVideo_pPalTT:				ds.l	1
sVideo_pPalFalcon:			ds.l	1
sVideo_Width:				ds.w	1
sVideo_Height:				ds.w	1
sVideo_Mode:				ds.w	1
sVideo_ScrollX:				ds.w	1
sVideo_ScrollY:				ds.w	1
sVideo_NTSCflag:			ds.w	1
sVideo_ScanLineWords0:		ds.w	1
sVideo_ScanLineWords1:		ds.w	1
sVideo_UpdatePhysicFlag:	ds.b	1
sVideo_UpdatePalSTFlag:		ds.b	1
sVideo_UpdatePalTTFlag:		ds.b	1
sVideo_UpdatePalFalconFlag:	ds.b	1
sVideo_UpdateScrollFlag:	ds.b	1


	OFFSET

sVideoSaveRegsST_pPhysic:	ds.l	1
sVideoSaveRegsST_pLogic:	ds.l	1
sVideoSaveRegsST_Res:		ds.w	1
sVideoSaveRegsST_RegMode:	ds.b	1
sVideoSaveRegsST_RegSync:	ds.b	1


	OFFSET

sVideoSaveRegsSTE_pPhysic:		ds.l	1
sVideoSaveRegsSTE_pLogic:		ds.l	1
sVideoSaveRegsSTE_Res:			ds.w	1
sVideoSaveRegsSTE_RegMode:		ds.b	1
sVideoSaveRegsSTE_RegSync:		ds.b	1
sVideoSaveRegsSTE_RegLineWidth:	ds.b	1
sVideoSaveRegsSTE_RegScroll:	ds.b	1

	OFFSET

sVideoSaveRegsTT_pLogic:		ds.l	1
sVideoSaveRegsTT_pPhysic:		ds.l	1
sVideoSaveRegsTT_pPhysicLow:	ds.b	1
sVideoSaveRegsTT_ResST:			ds.b	1
sVideoSaveRegsTT_ResTT:			ds.w	1
sVideoSaveRegsTT_Sync:			ds.b	1
sVideoSaveRegsTT_LineWidth:		ds.b	1
sVideoSaveRegsTT_Scroll:		ds.b	1


	OFFSET

sVideoSaveState_Regs:			ds.l	32
sVideoSaveState_PalST:			ds.w	16
sVideoSaveState_PalFalcon:		ds.l	256


**************************************************************************************
	TEXT
**************************************************************************************

*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_SaveRegsST()
* ACTION:      saves st video register & xbios state
* CREATION:     24.03.00 PNK
*------------------------------------------------------------------------------------*

Video_SaveRegsST:
	movem.l	d0-d2/a0-a6,-(a7)							; save regs

	move.l	a0,a6										; apBuffer

	move.w	#4,-(a7)									; get mode
	trap	#14											; call XBIOS
	addq.l	#2,a7										; fix stack
	move.w	d0,sVideoSaveRegsST_Res(a6)					; save old res

	move.w	#2,-(a7)									; Physbase()
	trap	#14											; call XBIOS
	addq.l	#2,a7										; fix stack
	move.l	d0,sVideoSaveRegsST_pPhysic(a6)				; save old physic

	move.w	#3,-(a7)									; Logbase()
	trap	#14											; call XBIOS
	addq.l	#2,a7										; fix stack
	move.l	d0,sVideoSaveRegsST_pLogic(a6)				; save old logic

	move.b	$FFFF8260.w,sVideoSaveRegsST_RegMode(a6)	; save st video shifter
	move.b	$FFFF820A.w,sVideoSaveRegsST_RegSync(a6)	; save sync

	movem.l	(a7)+,d0-d2/a0-a6							; restore regs
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_RestoreRegsST()
* ACTION:      restores st video register & xbios state
* CREATION:     24.03.00 PNK
*------------------------------------------------------------------------------------*

Video_RestoreRegsST:
	movem.l	d0-d2/a0-a6,-(a7)							; save regs

	move.l	a0,a6										; apBuffer

	move.l	$466.w,d0
.wvbl:
	cmp.l	$466.w,d0
	beq.s	.wvbl

	move.l	sVideoSaveRegsST_pPhysic(a6),d0			; get address of physic
	move.l	d0,d1							; copy video address
	lsr.l	#8,d1							; video address mid
	move.l	d1,d2							; copy hi:mid
	lsr.l	#8,d2							; video address hi
	
	move.b	d2,$FFFF8201.w					; set video hi
	move.b	d1,$FFFF8203.w					; set video mid

	move.b	sVideoSaveRegsST_RegMode(a6),$FFFF8260.w	; save st video shifter
	move.b	sVideoSaveRegsST_RegSync(a6),$FFFF820A.w	; save sync

	move.l	$466.w,d0
.wvbl2:
	cmp.l	$466.w,d0
	beq.s	.wvbl2

	move.w	sVideoSaveRegsST_Res(a6),-(a7)				; old screen mode
	move.l	sVideoSaveRegsST_pPhysic(a6),-(a7)			; old phys
	move.l	sVideoSaveRegsST_pLogic(a6),-(a7)			; old log
	move.w	#5,-(a7)									; Setscreen()
	trap	#14
	lea		12(a7),a7									; fix stack


	movem.l	(a7)+,d0-d2/a0-a6							; restore regs
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_SaveRegsSTE()
* ACTION:      saves ste video register & xbios state
* CREATION:     24.03.00 PNK
*------------------------------------------------------------------------------------*

Video_SaveRegsSTE:
	movem.l	d0-d2/a0-a6,-(a7)	; save regs

	move.l	a0,a6				; apBuffer

	move.w	#4,-(a7)			; get mode
	trap	#14					; call XBIOS
	addq.l	#2,a7				; fix stack
	move.w	d0,sVideoSaveRegsSTE_Res(a6)					; save old res

	move.w	#2,-(a7)			; Physbase()
	trap	#14					; call XBIOS
	addq.l	#2,a7				; fix stack
	move.l	d0,sVideoSaveRegsSTE_pPhysic(a6)				; save old physic

	move.w	#3,-(a7)			; Logbase()
	trap	#14					; call XBIOS
	addq.l	#2,a7				; fix stack
	move.l	d0,sVideoSaveRegsSTE_pLogic(a6)					; save old logic

	move.b	$FFFF8260.w,sVideoSaveRegsSTE_RegMode(a6)		; save st video shifter
	move.b	$FFFF820A.w,sVideoSaveRegsSTE_RegSync(a6)		; save sync
	move.b	$FFFF820F.w,sVideoSaveRegsSTE_RegLineWidth(a6)	; save line width
	move.b	$FFFF8265.w,sVideoSaveRegsSTE_RegScroll(a6)		; save scroll

	movem.l	(a7)+,d0-d2/a0-a6	; restore regs
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_RestoreRegsSTE()
* ACTION:      restores ste video register & xbios state
* CREATION:     24.03.00 PNK
*------------------------------------------------------------------------------------*

Video_RestoreRegsSTE:
	movem.l	d0-d2/a0-a6,-(a7)								; save regs

	move.l	a0,a6											; apBuffer

	move.l	sVideoSaveRegsSTE_pPhysic(a6),d0				; get address of physic
	move.l	d0,d1											; copy video address
	lsr.l	#8,d1											; video address mid
	move.l	d1,d2											; copy hi:mid
	lsr.l	#8,d2											; video address hi
	
	move.b	d2,$FFFF8201.w									; set video hi
	move.b	d1,$FFFF8203.w									; set video mid
	move.b	d0,$FFFF820D.w									; set video lo
	move.b	d0,$FFFF8209.w									; set video lo

	move.b	sVideoSaveRegsSTE_RegMode(a6),$FFFF8260.w		; set st video shifter
	move.b	sVideoSaveRegsSTE_RegSync(a6),$FFFF820A.w		; set sync
	move.b	sVideoSaveRegsSTE_RegScroll(a6),$FFFF8265.w		; set scroll
	move.b	sVideoSaveRegsSTE_RegLineWidth(a6),$FFFF820F.w	; set line width


	move.l	$466.w,d0
.wvbl3:
	cmp.l	$466.w,d0
	beq.s	.wvbl3

	move.w	sVideoSaveRegsSTE_Res(a6),-(a7)					; old screen mode
	move.l	sVideoSaveRegsSTE_pPhysic(a6),-(a7)				; old phys
	move.l	sVideoSaveRegsSTE_pLogic(a6),-(a7)				; old log
	move.w	#5,-(a7)										; Setscreen()
	lea		12(a7),a7										; fix stack

	movem.l	(a7)+,d0-d2/a0-a6								; restore regs
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_SaveRegsTT()
* ACTION:      saves TT video register & xbios state
* CREATION:     24.03.00 PNK
*------------------------------------------------------------------------------------*

Video_SaveRegsTT:

	move.l	$FFFF8200.w,sVideoSaveRegsTT_pPhysic(a0)
	move.b	$FFFF820D.w,sVideoSaveRegsTT_pPhysicLow(a0)
	move.l	$0000044e.w,sVideoSaveRegsTT_pLogic(a0)
	move.b	$FFFF820A.w,sVideoSaveRegsTT_Sync(a0)
	move.b	$FFFF820F.w,sVideoSaveRegsTT_LineWidth(a0)
	move.b	$FFFF8260.w,sVideoSaveRegsTT_ResST(a0)
	move.w	$FFFF8262.w,sVideoSaveRegsTT_ResTT(a0)
	move.b	$FFFF8265.w,sVideoSaveRegsTT_Scroll(a0)

	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_RestoreRegsTT()
* ACTION:      restores TT video register & xbios state
* CREATION:    24.03.00 PNK
*------------------------------------------------------------------------------------*

Video_RestoreRegsTT:

    move.l  sVideoSaveRegsTT_pLogic(a0),$0000044E.w 
    move.l  sVideoSaveRegsTT_pPhysic(a0),$FFFF8200.w
    move.b  sVideoSaveRegsTT_pPhysicLow(a0),$FFFF820D.w
    move.b  sVideoSaveRegsTT_ResST(a0),$FFFF8260.w
    move.w  sVideoSaveRegsTT_ResTT(a0),$FFFF8262.w
	move.b	sVideoSaveRegsTT_Sync(a0),$FFFF820A.w
	move.b	sVideoSaveRegsTT_Scroll(a0),$FFFF8265.w
	move.b	sVideoSaveRegsTT_LineWidth(a0),$FFFF820F.w

	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_SaveRegsFalcon()
* ACTION:      saves falcon video register & xbios state
* CREATION:     24.03.00 PNK + Sage/Escape
*------------------------------------------------------------------------------------*

Video_SaveRegsFalcon:
	movem.l	d0-d2/a0-a6,-(a7)	; save regs

	move.l	a0,a6				; apBuffer

	move.w	#2,-(a7)			; Physbase()
	trap	#14					; call XBIOS
	addq.l	#2,a7				; fix stack
	move.l	d0,(a6)+			; save old physic

	move.w	#3,-(a7)			; Logbase()
	trap	#14					; call XBIOS
	addq.l	#2,a7				; fix stack
	move.l	d0,(a6)+			; save old logic

	move.w	#-1,-(a7)			; get xbios mode
	move.w	#$58,-(a7)			; Vsetmode()
	trap	#14					; call XBIOS
	addq.l	#4,a7				; fix stack
	move.w	d0,(a6)+			; save old xbios modecode

	move.l	$ffff8200.w,(a6)+	; 0 vidhm
	move.w	$ffff820c.w,(a6)+	; 4 vidl
	move.l	$ffff8282.w,(a6)+	; 6 h-regs
	move.l	$ffff8286.w,(a6)+	;10 
	move.l	$ffff828a.w,(a6)+	;14
	move.l	$ffff82a2.w,(a6)+	;18 v-regs
	move.l	$ffff82a6.w,(a6)+	;22
	move.l	$ffff82aa.w,(a6)+	;26
	move.w	$ffff82c0.w,(a6)+	;30 vco
	move.w	$ffff82c2.w,(a6)+	;32 c_s
	move.l	$ffff820e.w,(a6)+	;34 offset
	move.w	$ffff820a.w,(a6)+	;38 sync
	move.b  $ffff8256.w,(a6)+	;40 p_o
	clr.b   (a6)				;41 test of st(e) or falcon mode
	cmp.w   #$b0,$ffff8282.w	;   hht kleiner $b0?
	sle     (a6)+				;41 flag setzen
	move.w	$ffff8266.w,(a6)+	;42 f_s
	move.w	$ffff8260.w,(a6)+	;44 st_s

	movem.l	(a7)+,d0-d2/a0-a6	; restore regs
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_RestoreRegsFalcon()
* ACTION:      restore falcon video register & xbios state
* CREATION:     24.03.00 PNK
*------------------------------------------------------------------------------------*

Video_RestoreRegsFalcon:
	movem.l	d0-d2/a0-a6,-(a7)	; save regs

	move.l	a0,a6				; apBuffer

;	move.w	8(a6),-(a7)			; old res
;	move.w	#3,-(a7)			; use falcon modes
;	move.l	(a6)+,-(a7)			; old physic address
;	move.l	(a6)+,-(a7)			; old logic address
;	move.w	#5,-(a7)			; Setscreen()
;	trap	#14					; call XBIOS
;	lea		14(a7),a7			; fix stack
;
;	move.w	(a6)+,-(a7)			; old video mode
;	move.w	#$58,-(a7)			; Vsetmode()
;	trap	#14					; call XBIOS
;	addq.l	#4,a7				; fix stack


	lea	10(a0),a6
	move.w	$468.w,d0			; read vbl counter
.wvbl0:
	cmp.w	$468.w,d0			; on same frame?
	beq.s	.wvbl0				; wait for next fram

	clr.w   $ffff8266.w			; falcon-shift clear
	move.l	(a6)+,$ffff8200.w	; videobase_address:h&m
	move.w	(a6)+,$ffff820c.w	; l
	move.l	(a6)+,$ffff8282.w	; h-regs
	move.l	(a6)+,$ffff8286.w	;
	move.l	(a6)+,$ffff828a.w	;
	move.l	(a6)+,$ffff82a2.w	; v-regs
	move.l	(a6)+,$ffff82a6.w	;
	move.l	(a6)+,$ffff82aa.w	;
	move.w	(a6)+,$ffff82c0.w	; vco
	move.w	(a6)+,$ffff82c2.w	; c_s
	move.l	(a6)+,$ffff820e.w	; offset
	move.w	(a6)+,$ffff820a.w	; sync
	move.b  (a6)+,$ffff8256.w	; p_o

	tst.b   (a6)+   			; st(e) comptaible mode?
	bne.s   .ok

	move.w	$468.w,d0			; read vbl counter
.wvbl:
	cmp.w	$468.w,d0			; on same frame?
	beq.s	.wvbl				; wait for next fram

	move.w  (a6),$ffff8266.w	; falcon-shift
	bra.s	.video_restored

.ok:
	move.w  2(a6),$ffff8260.w	; st-shift
	move.w	-10(a6),$ffff82c2.w	; c_s
	move.l	-8(a6),$ffff820e.w	; offset		

.video_restored:
	movem.l	(a7)+,d0-d2/a0-a6	; restore regs
	rts	


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_GetPalST( U16 * apPal )
* ACTION:      copies ST palette to specified address
* CREATION:     10.04.99 PNK
*------------------------------------------------------------------------------------*

Video_GetPalST:
	move.l	a1,-(a7)		; save registers

	lea		$ffff8240.w,a1	; ST palette registers
	move.l	(a1)+,(a0)+		; cols 00-01
	move.l	(a1)+,(a0)+		; cols 02-03
	move.l	(a1)+,(a0)+		; cols 04-05
	move.l	(a1)+,(a0)+		; cols 06-07
	move.l	(a1)+,(a0)+		; cols 08-09
	move.l	(a1)+,(a0)+		; cols 10-11
	move.l	(a1)+,(a0)+		; cols 12-13
	move.l	(a1)+,(a0)+		; cols 14-15

	move.l	(a7)+,a1		; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_SetPalST( U16 * apPal )
* ACTION:      set ST palette
* CREATION:     10.04.99 PNK
*------------------------------------------------------------------------------------*

Video_SetPalST:
	move.l	a1,-(a7)		; save registers

	lea		$ffff8240.w,a1	; ST palette registers
	move.l	(a0)+,(a1)+		; cols 00-01
	move.l	(a0)+,(a1)+		; cols 02-03
	move.l	(a0)+,(a1)+		; cols 04-05
	move.l	(a0)+,(a1)+		; cols 06-07
	move.l	(a0)+,(a1)+		; cols 08-09
	move.l	(a0)+,(a1)+		; cols 10-11
	move.l	(a0)+,(a1)+		; cols 12-13
	move.l	(a0)+,(a1)+		; cols 14-15

	move.l	(a7)+,a1		; restore registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_GetPalTT( U16 * apPal )
* ACTION:      copies Falcon palette to specified address
* CREATION:     24.03.99 PNK
*------------------------------------------------------------------------------------*

Video_GetPalTT:
	movem.l	d0/a1,-(a7)		; save registers

	lea		$ffff8400.w,a1	; TT palette registers
	moveq	#(256/8)-1,d0	; loop count
.set:
	move.l	(a1)+,(a0)+		; set colour register i+0
	move.l	(a1)+,(a0)+		; set colour register i+1
	move.l	(a1)+,(a0)+		; set colour register i+2
	move.l	(a1)+,(a0)+		; set colour register i+3
	dbra	d0,.set			; loop for all registers

	movem.l	(a7)+,d0/a1		; save registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_SetPalTT( U16 * apPal )
* ACTION:      set TT palette
* CREATION:     24.03.99 PNK
*------------------------------------------------------------------------------------*

Video_SetPalTT:
	movem.l	d0/a1,-(a7)		; save registers

	lea		$ffff8400.w,a1	; TT palette registers
	moveq	#(256/8)-1,d0	; loop count
.set:
	move.l	(a0)+,(a1)+		; set colour register i+0
	move.l	(a0)+,(a1)+		; set colour register i+1
	move.l	(a0)+,(a1)+		; set colour register i+2
	move.l	(a0)+,(a1)+		; set colour register i+3
	dbra	d0,.set			; loop for all registers

	movem.l	(a7)+,d0/a1		; save registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_GetPalFalcon( U16 * apPal )
* ACTION:      copies Falcon palette to specified address
* CREATION:     10.04.99 PNK
*------------------------------------------------------------------------------------*

Video_GetPalFalcon:
	movem.l	d0/a1,-(a7)		; save registers

	lea		$ffff9800.w,a1	; Falcon palette registers
	moveq	#(256/4)-1,d0	; loop count
.set:
	move.l	(a1)+,(a0)+		; set colour register i+0
	move.l	(a1)+,(a0)+		; set colour register i+1
	move.l	(a1)+,(a0)+		; set colour register i+2
	move.l	(a1)+,(a0)+		; set colour register i+3
	dbra	d0,.set			; loop for all registers

	movem.l	(a7)+,d0/a1		; save registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_SetPalFalcon( U16 * apPal )
* ACTION:      set Falcon palette
* CREATION:     10.04.99 PNK
*------------------------------------------------------------------------------------*

Video_SetPalFalcon:
	movem.l	d0/a1,-(a7)		; save registers

	lea		$ffff9800.w,a1	; Falcon palette registers
	moveq	#(256/4)-1,d0	; loop count
.set:
	move.l	(a0)+,(a1)+		; set colour register i+0
	move.l	(a0)+,(a1)+		; set colour register i+1
	move.l	(a0)+,(a1)+		; set colour register i+2
	move.l	(a0)+,(a1)+		; set colour register i+3
	dbra	d0,.set			; loop for all registers

	movem.l	(a7)+,d0/a1		; save registers
	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_UpdateRegsST()
* ACTION:      sets physic & palette ( called from vbl )
* CREATION:     25.03.00 PNK
*------------------------------------------------------------------------------------*

Video_UpdateRegsST:

	lea		gVideo,a0						; address of video struct
	tas.b	sVideo_UpdatePhysicFlag(a0)		; new physic to set?
	bne.s	.no_physic						; no

	move.l	sVideo_pPhysic(a0),d0
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w					; get address of physic

.no_physic:

	tas.b	sVideo_UpdatePalSTFlag(a0)		; st palette to set?
	bne.s	.no_palst						; no

	movem.l	sVideo_pPalST(a0),a1			; get address of new st pal
	movem.l	(a1),d0-d7						; read palette
	movem.l	d0-d7,$FFFF8240.w				; set palette
.no_palst:

	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_UpdateRegsSTE()
* ACTION:      sets physic & palette ( called from vbl )
* CREATION:     25.03.00 PNK
*------------------------------------------------------------------------------------*

Video_UpdateRegsSTE:

	lea		gVideo,a0						; address of video struct
	tas.b	sVideo_UpdatePhysicFlag(a0)		; new physic to set?
	bne.s	.no_physic						; no

	move.l	sVideo_pPhysic(a0),d0			; get address of physic
	move.l	d0,d1							; copy video address
	lsr.l	#8,d1							; video address mid
	move.l	d1,d2							; copy hi:mid
	lsr.l	#8,d2							; video address hi
	
	move.b	d2,$FFFF8201.w					; set video hi
	move.b	d1,$FFFF8203.w					; set video mid
	move.b	d0,$FFFF820D.w					; set video lo

	move.b	d2,$FFFF8205.w					; set video hi
	move.b	d1,$FFFF8207.w					; set video mid
	move.b	d0,$FFFF8209.w					; set video lo
;	clr.b	sVideo_UpdatePhysicFlag(a0)		; new physic to set?

.no_physic:

	tas.b	sVideo_UpdateScrollFlag(a0)			; xscroll to set?
	bne.s	.no_scroll							; no

	move.b	sVideo_ScrollX(a0),d0					; check fine scroll pos
	beq.s	.scroll0								; special case on scroll of 0
	move.b	d0,$FFFF8265.w							; set scroll position
	move.b	sVideo_ScanLineWords0+1(a0),$FFFF820E.w	; set scanline length
	bra.s	.no_scroll								; finish update
.scroll0:	
	clr.b	$ffff8265.w								; set scroll 0
	move.b	sVideo_ScanLineWords1+1(a0),$FFFF820E.w	; set scanline length
.no_scroll:

	tas.b	sVideo_UpdatePalSTFlag(a0)		; st palette to set?
	bne.s	.no_palst						; no

	movem.l	sVideo_pPalST(a0),a1			; get address of new st pal
	movem.l	(a1),d0-d7						; read palette
	movem.l	d0-d7,$FFFF8240.w				; set palette
.no_palst:

	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_UpdateRegsTT()
* ACTION:      sets physic & palettes ( called from vbl )
* CREATION:     25.03.00 PNK
*------------------------------------------------------------------------------------*

Video_UpdateRegsTT:

	lea		gVideo,a0						; address of video struct
	tas.b	sVideo_UpdatePhysicFlag(a0)		; new physic to set?
	bne.s	.no_physic						; no

	move.l	sVideo_pPhysic(a0),d0			; get address of physic
	move.l	d0,d1							; copy video address
	lsr.l	#8,d1							; video address mid
	move.l	d1,d2							; copy hi:mid
	lsr.l	#8,d2							; video address hi
	
	move.b	d2,$FFFF8201.w					; set video hi
	move.b	d1,$FFFF8203.w					; set video mid
	move.b	d0,$FFFF820D.w					; set video lo

	move.b	d2,$FFFF8205.w					; set video hi
	move.b	d1,$FFFF8207.w					; set video mid
	move.b	d0,$FFFF8209.w					; set video lo

.no_physic:

	tas.b	sVideo_UpdateScrollFlag(a0)			; xscroll to set?
	bne.s	.no_scroll							; no

	move.b	sVideo_ScrollX(a0),d0					; check fine scroll pos
	beq.s	.scroll0								; special case on scroll of 0
	move.b	d0,$FFFF8265.w							; set scroll position
	move.b	sVideo_ScanLineWords0+1(a0),$FFFF820F.w	; set scanline length
	bra.s	.no_scroll								; finish update
.scroll0:	
	clr.b	$ffff8265.w								; set scroll 0
	move.b	sVideo_ScanLineWords1+1(a0),$FFFF820F.w	; set scanline length
.no_scroll:

	tas.b	sVideo_UpdatePalSTFlag(a0)		; st palette to set?
	bne.s	.no_palst						; no

	movem.l	sVideo_pPalST(a0),a1			; get address of new st pal
	movem.l	(a1),d0-d7						; read palette
	movem.l	d0-d7,$FFFF8240.w				; set palette
.no_palst:

	tas.b	sVideo_UpdatePalTTFlag(a0)		; st palette to set?
	bne		.no_paltt						; no

	movem.l	sVideo_pPalTT(a0),a1			; get address of new st pal
	movea.w	#$8240.w,a2						; start address of tt regs
	rept	16
	movem.l	(a1)+,d0-d7						; read palette
	movem.l	d0-d7,(a2)						; set palette
	lea		32(a2),a2						; next bank of registers
	endm
.no_paltt:

	rts


*------------------------------------------------------------------------------------*
* FUNCTION:    void Video_UpdateRegsFalcon()
* ACTION:      sets physic & palettes ( called from vbl )
* CREATION:     25.03.00 PNK
*------------------------------------------------------------------------------------*

Video_UpdateRegsFalcon:

	lea		gVideo,a0						; address of video struct
	tas.b	sVideo_UpdatePhysicFlag(a0)		; new physic to set?
	bne.s	.no_physic						; no

	move.l	sVideo_pPhysic(a0),d0			; get address of physic
	move.l	d0,d1							; copy video address
	lsr.l	#8,d1							; video address mid
	move.l	d1,d2							; copy hi:mid
	lsr.l	#8,d2							; video address hi
	
	move.b	d2,$FFFF8201.w					; set video hi
	move.b	d1,$FFFF8203.w					; set video mid
	move.b	d0,$FFFF820D.w					; set video lo

.no_physic:

	tas.b	sVideo_UpdateScrollFlag(a0)			; xscroll to set?
	bne.s	.no_scroll							; no

	move.b	sVideo_ScrollX(a0),d0					; check fine scroll pos
	beq.s	.scroll0								; special case on scroll of 0
	move.b	d0,$FFFF8265.w							; set scroll position
	move.w	sVideo_ScanLineWords0(a0),$FFFF820E.w	; set scanline length
	bra.s	.no_scroll								; finish update
.scroll0:	
	clr.b	$ffff8265.w								; set scroll 0
	move.w	sVideo_ScanLineWords1(a0),$FFFF820E.w	; set scanline length
.no_scroll:

	tas.b	sVideo_UpdatePalSTFlag(a0)		; st palette to set?
	bne.s	.no_palst						; no

	movem.l	sVideo_pPalST(a0),a1			; get address of new st pal
	movem.l	(a1),d0-d7						; read palette
	movem.l	d0-d7,$FFFF8240.w				; set palette
.no_palst:

	tas.b	sVideo_UpdatePalFalconFlag(a0)	; st palette to set?
	bne		.no_palfalcon					; no

	movem.l	sVideo_pPalFalcon(a0),a1		; get address of new st pal
	movea.w	#$9800.w,a2						; start address of tt regs
	moveq	#32-1,d7						; 32 sets of 32 bytes to set
.loop:
	movem.l	(a1)+,d0-d6/a3					; read palette
	movem.l	d0-d6/a3,(a2)					; set palette
	lea		32(a2),a2						; next bank of registers
	dbra	d7,.loop	

.no_palfalcon:

	rts


Video_XbiosSetScreen:
	movem.l	d0-a6,-(a7)
	
	move.w	d0,-(a7)
	move.l	#-1,-(a7)
	move.l	#-1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	lea		12(a7),a7

	movem.l	(a7)+,d0-a6

	rts


Video_XbiosFalconSetLow:
	rts	;hack
	movem.l	d0-a6,-(a7)

	move.w	#-1,-(a7)
	move.w	#5,-(a7)
	trap	#14
	addq.l	#4,a7

	andi	#$10+$20,d0
	ori		#$2,d0
	move.w	#$10+$80,d1
	and		d0,d1
	beq.s	.rgb
	or		#$100,d0
.rgb:

	move.w	d0,-(a7)
	move.w	#5,-(a7)
	trap	#14
	addq.l	#4,a7


	movem.l	(a7)+,d0-a6

	rts


Video_SetFalconSTLowVGA:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	move.l  #$170012,$ffff8282.w            ;falcon 60Hz 
    move.l  #$1020e,$ffff8286.w             ;
    move.l  #$d0012,$ffff828a.w             ;
    move.l  #$41903ff,$ffff82a2.w           ;
    move.l  #$3f008d,$ffff82a6.w            ;
    move.l  #$3ad0415,$ffff82aa.w           ;
    move.w  #$200,$ffff820a.w               ;
    move.w  #$186,$ffff82c0.w               ;
    clr.w   $ffff8266.w                     ;
    clr.b   $ffff8260.w                     ;
    move.w  #$5,$ffff82c2.w                 ;
    move.w  #$50,$ffff8210.w                ;
	move.w	(a7)+,sr
	rts

Video_SetFalconSTLowRGBPAL_W:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	move.l  #$300027,$ffff8282.w            ;falcon 50Hz 
    move.l  #$70229,$ffff8286.w             ;
    move.l  #$1e002a,$ffff828a.w            ;
    move.l  #$2710265,$ffff82a2.w           ;
    move.l  #$2f0081,$ffff82a6.w            ;
    move.l  #$211026b,$ffff82aa.w           ;
    move.w  #$200,$ffff820a.w               ;
    move.w  #$185,$ffff82c0.w               ;
    clr.w   $ffff8266.w                     ;
    clr.b   $ffff8260.w                     ;
    clr.w   $ffff82c2.w                     ;
    move.w  #$50,$ffff8210.w                ;
	move.w	(a7)+,sr
	rts


Video_SetFalconSTLowRGBNTSC_W:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	move.l	#$300027,$ffff8282.w
	move.l	#$70228,$ffff8286.w
	move.l	#$1d002a,$ffff828a.w
	move.l	#$20d0201,$ffff82a2.w
	move.l	#$170043,$ffff82a6.w
	move.l	#$1d30207,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$187,$ffff82c0.w
	clr.w	$ffff8266.w
	move.b	#$0,$ffff8260.w
	move.w	#$0,$ffff82c2.w
	move.w	#$50,$ffff8210.w
	move.w	(a7)+,sr
	rts

Video_SetFalconSTLowRGBPAL:
	move.w	sr,-(a7)
	move.w	#$2700,sr
    move.l   #$3e0033,$ffff8282.w
    move.l   #$a0005,$ffff8286.w
    move.l   #$1e0036,$ffff828a.w
    move.l   #$2710265,$ffff82a2.w
    move.l   #$2f0081,$ffff82a6.w
    move.l   #$211026b,$ffff82aa.w
    move.w   #$200,$ffff820a.w
    move.w   #$183,$ffff82c0.w
    clr.w    $ffff8266.w
    move.b   #$0,$ffff8260.w
    move.w   #$0,$ffff82c2.w
    move.w   #$50,$ffff8210.w
	move.w	(a7)+,sr
	rts

Video_SetFalconSTLowRGBNTSC:
	move.w	sr,-(a7)
	move.w	#$2700,sr
    move.l   #$3e0032,$ffff8282.w
    move.l   #$a0004,$ffff8286.w
    move.l   #$1d0036,$ffff828a.w
    move.l   #$20d0201,$ffff82a2.w
    move.l   #$170043,$ffff82a6.w
    move.l   #$1d30207,$ffff82aa.w
    move.w   #$200,$ffff820a.w
    move.w   #$183,$ffff82c0.w
    clr.w    $ffff8266.w
    move.b   #$0,$ffff8260.w
    move.w   #$0,$ffff82c2.w
    move.w   #$50,$ffff8210.w
	move.w	(a7)+,sr
	rts