; Falcon screenroutines:
;
; + resolutionswitchers
; + screenclearers
; + screencopiers
; + pallettesetters/savers
; + pixel/linedoublers

; VIDEO-modes available

; VGA (60 & 100Hz)  RGB (50)
; 320*200 8bit      320*200 8bit
; 640*400 8bit      640*400 8bit

; 160*100 16bit     320*100 16bit
; 160*200 16bit
; 320*100 16bit
; 320*200 16bit     320*200 16bit

; Notes:
; All RGB modes are all in "cinemascope" mode for overscan.

; --------------------------------------------------------------
; ------------- VGA 16bit 60Hz ---------------------------------
; --------------------------------------------------------------

vga60_16bit_320_200:
	move.l	#$c6008D,$ffff8282.w
	move.l	#$1502ac,$ffff8286.w
	move.l	#$8D0097,$ffff828a.w
	move.l	#$041903ad,$ffff82a2.w		;#$41903ff,$ffff82a2.w
	move.l	#$008d008d,$ffff82a6.w		;#$3f008D,$ffff82a6.w
	move.l	#$03aD0415,$ffff82aa.w		;#$3aD0415,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$100,$ffff8266.w
	move.w	#$5,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- RGB 16bit 50Hz ---------------------------------
; --------------------------------------------------------------

rgb50_16bit_320_200:
	move.l	#$c700a0,$ffff8282.w
	move.l	#$1f0003,$ffff8286.w
	move.l	#$9b00ab,$ffff828a.w
	move.l	#$2710265,$ffff82a2.w
	move.l	#$2f0081,$ffff82a6.w
	move.l	#$211026b,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$185,$ffff82c0.w
	clr.w	 $ffff8266.w
	move.w	#$100,$ffff8266.w
	move.w	#$0,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	rts


;******* Resolution saving and restoring routines

; Saves the current falcon resolution to an internal buffer.
SAVE_FV:
	lea	save_fv,a0
	move.l	$ffff8282.w,(a0)+		* h-regs
	move.l	$ffff8286.w,(a0)+		*
	move.l	$ffff828a.w,(a0)+		*
	move.l	$ffff82a2.w,(a0)+		* v-regs
	move.l	$ffff82a6.w,(a0)+		*
	move.l	$ffff82aa.w,(a0)+		*
	move.w	$ffff82c0.w,(a0)+		* vco
	move.w	$ffff82c2.w,(a0)+		* c_s
	move.l	$ffff820e.w,(a0)+		* offset
	move.w	$ffff820a.w,(a0)+		* sync
	move.b	$ffff8265.w,(a0)+		* p_o
	clr.b	(a0)				* test of st(e) or falcon mode
	cmp.w	#$b0,$ffff8282.w		* hht kleiner $b0?
	sle 	(a0)+				* flag setzen
	move.w	$ffff8266.w,(a0)+		* f_s
	move.w	$ffff8260.w,(a0)+		* st_s
	rts

* Changes screenresolution the fast way..
* Note: Takes one vbl, necessary to avoid monochrome sync errors.
* INPUT: a0: address of fv2-buffer
CHANGE_FVFAST:
	clr.w	$ffff8266.w			* falcon-shift clear
	move.l	(a0)+,$ffff8282.w	0	* h-regs
	move.l	(a0)+,$ffff8286.w	4	*
	move.l	(a0)+,$ffff828a.w 	8	*
	move.l	(a0)+,$ffff82a2.w	12	* v-regs
	move.l	(a0)+,$ffff82a6.w 	16	*
	move.l	(a0)+,$ffff82aa.w 	20	*
	move.w	(a0)+,$ffff82c0.w	24	* vco
	move.w	(a0)+,$ffff82c2.w	26	* c_s
	move.l	(a0)+,$ffff820e.w	28	* offset
	move.w	(a0)+,$ffff820a.w	32	* sync
	move.b	(a0)+,$ffff8265.w	34	* p_o
	tst.b	(a0)+			35	* st(e) compatible mode?
	bne.s	.ok			36
	move.w	$468.w,d0			* / wait for vbl
.wait468:					* | to avoid
	cmp.w	$468.w,d0			* | falcon monomode
	beq.s	.wait468			* \ syncerrors.
	move.w	(a0),$ffff8266.w	38	* falcon-shift
	bra.s	.video_restored
.ok:	move.w	2(a0),$ffff8260.w	40	* st-shift
	move.w	-10(a0),$ffff82c2.w		* c_s
	move.l	-8(a0),$ffff820e.w		* offset		
.video_restored:
	rts

******** Falcon bitplane mode palette routines

SAVE_FALCPAL:
	move.w	$468.w,d0
.waitvbl:
	cmp.w	$468.w,d0
	beq.s	.waitvbl
	lea	falcsave_pal,a0
	lea	$ffff9800.w,a1
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

RESTORE_FALCPAL:
	move.w	$468.w,d0
.waitvbl:
	cmp.w	$468.w,d0
	beq.s	.waitvbl
	lea	falcsave_pal,a1
	lea	$ffff9800.w,a0
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

	ifne	0

; INPUT:
; a1: palette
SET_FALCPAL:
	lea	$ffff9800.w,a0
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

	endc

******** Screenclearers and copiers.

; INPUT:
; d7.l=#pixels
; a0: dst hc pixels (%rrrrrggggggbbbbb)
; a1: src tc pixels ($rrggbb)
convertTc2Hc:
	subq.l	#1,d7
	bmi.s	.end
	swap	d7
	move.w	#$F800,d3
	move.w	#$07E0,d4

.outerloop:
	swap	d7

.innerloop:
	clr.l	d1
	move.b	(a1)+,d0
	move.b	(a1)+,d1
	move.b	(a1)+,d2
	lsl.w	#8,d0
	lsl.w	#3,d1
	lsr.b	#3,d2
	and.w	d3,d0
	and.w	d4,d1
	or.w	d1,d0
	or.b	d2,d0
	move.w	d0,(a0)+
	dbf	d7,.innerloop

	swap	d7
	dbf	d7,.outerloop

.end:	rts

; INPUT:
; a0: resolutionsetter routine (null: no change)
; a1: palette (null: no change)
; a2: screen
; OUTPUT:
; d0.w=0: done, -1: not done, still pending
Screen.requestUpdate:
	moveq	#-1,d0

; If the previous update is still pending, just return.
	tst.w	Screen.updateRequested
	bne.s	.end
	
	move.l	a0,Screen.resRout
	move.l	a1,Screen.palAdr
	move.l	a2,Screen.adr
	st	Screen.updateRequested
	clr.l	d0

.end:	rts

; This should be called by the vbl. Uses datastructures set by user to
; update screenbase, resolution and palette.
Screen.update:
	tst.w	Screen.updateRequested
	beq.s	.end

; Set resolution, if it's not a null.
	move.l	Screen.resRout,d0
	beq.s	.res_done
	movea.l	d0,a0
	jsr	(a0)
.res_done:

; Set screenbase.
	move.l	Screen.adr,d0
	move.l	d0,d1
	lsr.w	#8,d0
	move.l	d0,$FFFF8200.w
	move.b	d1,$FFFF820D.w

	IFNE	0
	IFNE	1
; testshit for videl hc fading, borderproblems, >0 end intensity...
; also doesn't work well in vga100 160x100.. urgh
	move.w	#0,$FFFF828A.w		; hde
	ELSE
;	move.w	#0,$FFFF8284.w
	clr.w	$FFFF8286.w			; todo: test hbe (0,1,2: inverse of gradient?)
;	move.w	$FFFF8288.w,$FFFF8284.w		; todo: test hbb
;	clr.w	$FFFF828A.w			; todo: test hde

;	move.w	#133+400,$FFFF82A4.w		; todo: test vbb
;	move.w	#133,$FFFF82A6.w		; vbe: start of gradient in halfscans
	move.w	#0,$FFFF82A6.w			; vbe: start of gradient in halfscans
;	move.w	#133+396,$FFFF82AA.w			; todo: test vde

	move.w	$04bc.w,d0
	lsr.w	#3,d0
;	Do_SinModulo	d0
;	Get_Sin	sine_tbl,d0,d0
;	asr.w	#8,d0
;	addi.b	#$80,d0
	clr.l	d1
	move.b	d0,d1
	lsl.w	#8,d1
	move.b	d0,d1
	swap	d1
	move.b	d0,d1
	move.l	d1,$FFFF9800.w
	ENDC
	ENDC

; Set palette, if it's not a null.
	move.l	Screen.palAdr,d0
	beq.s	.pal_done
	movea.l	d0,a1
	lea	$FFFF9800.w,a0
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbf	d7,.loop
.pal_done:

	clr.l	Screen.resRout			; Indicate no new res anymore.
	clr.l	Screen.palAdr			; Indicate no pal anymore.

.end:	clr.w	Screen.updateRequested
	rts


	BSS

Screen.updateRequested:
	ds.w	1
Screen.palAdr:
	ds.l	1
Screen.resRout:
	ds.l	1
Screen.adr:
	ds.l	1

save_fv:
	DS.W	24
falcsave_pal:
	DS.L	256
