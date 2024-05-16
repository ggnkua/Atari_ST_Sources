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
; ------------- VGA 8bit 60Hz ----------------------------------
; --------------------------------------------------------------
 
vga60_8bit_320_200:
	move.l	#$c6008D,$ffff8282.w
	move.l	#$15029a,$ffff8286.w
	move.l	#$7b0097,$ffff828a.w
	move.l	#$041903ad,$ffff82a2.w		;#$41903ff,$ffff82a2.w
	move.l	#$008d008D,$ffff82a6.w		;#$3f008D,$ffff82a6.w
	move.l	#$03aD0415,$ffff82aa.w		;#$3aD0415,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$10,$ffff8266.w
	move.w	#$5,$ffff82c2.w
	move.w	#$a0,$ffff8210.w
	rts

vga60_8bit_640_400:
	move.l	#$c6008D,$ffff8282.w
	move.l	#$1502ab,$ffff8286.w
	move.l	#$840097,$ffff828a.w
	move.l	#$41903ff,$ffff82a2.w
	move.l	#$3f008f,$ffff82a6.w
	move.l	#$3af0415,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$10,$ffff8266.w
	move.w	#$8,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- VGA 8bit 100Hz ---------------------------------
; --------------------------------------------------------------

vga100_8bit_320_200:
	move.l	#$c6008f,$ffff8282.w
	move.l	#$18029c,$ffff8286.w
	move.l	#$7D0098,$ffff828a.w
	move.l	#$02750215,$ffff82a2.w	;#$275025b,$ffff82a2.w
	move.l	#$00850085,$ffff82a6.w	;#$410085,$ffff82a6.w
	move.l	#$02150271,$ffff82aa.w	;#$2150271,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$10,$ffff8266.w
	move.w	#$4,$ffff82c2.w
	move.w	#$a0,$ffff8210.w
	rts

vga100_8bit_640_400:
	move.l	#$c6008f,$ffff8282.w
	move.l	#$1802aD,$ffff8286.w
	move.l	#$860098,$ffff828a.w
	move.l	#$274025b,$ffff82a2.w
	move.l	#$410084,$ffff82a6.w
	move.l	#$2140271,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$10,$ffff8266.w
	move.w	#$a,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- VGA 16bit 60Hz ---------------------------------
; --------------------------------------------------------------

vga60_16bit_160_200:
	move.l	#$620046,$ffff8282.w
	move.l	#$a024D,$ffff8286.w
	move.l	#$46004b,$ffff828a.w
	move.l	#$41903ff,$ffff82a2.w
	move.l	#$3f008D,$ffff82a6.w
	move.l	#$3aD0415,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$100,$ffff8266.w
	move.w	#$1,$ffff82c2.w
	move.w	#$a0,$ffff8210.w
	rts

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
; ------------- VGA 16bit 100Hz --------------------------------
; --------------------------------------------------------------

vga100_16bit_160_100:
	move.l	#$620047,$ffff8282.w
	move.l	#$c024e,$ffff8286.w
	move.l	#$47004c,$ffff828a.w
	move.l	#$275025b,$ffff82a2.w
	move.l	#$410085,$ffff82a6.w
	move.l	#$2150271,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$100,$ffff8266.w
	move.w	#$1,$ffff82c2.w
	move.w	#$a0,$ffff8210.w
	rts

vga100_16bit_320_100:
	move.l  #$c6008f,$ffff8282.w
	move.l  #$1802ae,$ffff8286.w
	move.l  #$8f0098,$ffff828a.w
	move.l  #$02750215,$ffff82a2.w	;#$275025b,$ffff82a2.w
	move.l  #$00850085,$ffff82a6.w	;#$410085,$ffff82a6.w
	move.l	#$02150271,$ffff82aa.w 	;#$2150271,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$100,$ffff8266.w
	move.w	#$5,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	rts

vga100_16bit_320_200:
	move.l	#$c6008f,$ffff8282.w
	move.l	#$1802ae,$ffff8286.w
	move.l	#$8f0098,$ffff828a.w
	move.l	#$02750215,$ffff82a2.w	;#$275025b,$ffff82a2.w
	move.l	#$00850085,$ffff82a6.w	;#$410085,$ffff82a6.w
	move.l	#$02150271,$ffff82aa.w	;#$2150271,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$186,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$100,$ffff8266.w
	move.w	#$4,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- RGB 8bit 50Hz ----------------------------------
; --------------------------------------------------------------

rgb50_8bit_320_200:
	move.l	#$c700a0,$ffff8282.w
	move.l	#$1f02ba,$ffff8286.w
	move.l	#$8900ab,$ffff828a.w
	move.l	#$2710265,$ffff82a2.w
	move.l	#$2f0081,$ffff82a6.w
	move.l	#$211026b,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$185,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$10,$ffff8266.w
	move.w	#$0,$ffff82c2.w
	move.w	#$a0,$ffff8210.w
	rts

rgb50_8bit_640_400:
	move.l	#$1900141,$ffff8282.w
	move.l	#$3e0005,$ffff8286.w
	move.l	#$1240156,$ffff828a.w
	move.l	#$2700265,$ffff82a2.w
	move.l	#$2f0080,$ffff82a6.w
	move.l	#$210026b,$ffff82aa.w
	move.w	#$200,$ffff820a.w
	move.w	#$185,$ffff82c0.w
	clr.w	$ffff8266.w
	move.w	#$10,$ffff8266.w
	move.w	#$6,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	rts

; --------------------------------------------------------------
; ------------- RGB 16bit 50Hz ---------------------------------
; --------------------------------------------------------------

rgb50_16bit_320_100:
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
	move.w	#$1,$ffff82c2.w
	move.w	#$140,$ffff8210.w
	rts

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
	move.b	$ffff8256.w,(a0)+		* p_o
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
	move.b	(a0)+,$ffff8256.w	34	* p_o
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

; INPUT:
; a1: palette
SET_FALCPAL:
	lea	$ffff9800.w,a0
	moveq	#128-1,d7
.loop:	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	dbra	d7,.loop
	rts

******** Screenclearers and copiers.

* Clears a 320*200 highcolor screen.
* INPUT:
* a0: screenaddress
CLEAR_320200TSCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#123-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*200*2,a0
.loop:
	REPT	20
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	dbra	d7,.loop
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6,-(a0)
	rts

* Clears a 320*100 highcolor screen.
* INPUT:
* a0: screenaddress
CLEAR_320100TSCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#100-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*100*2,a0
.loop:
	REPT	12
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d3,-(a0)
	dbra	d7,.loop
	rts

* Clears a 320*200 8bpp screen.
* INPUT:
* a0: screenaddress
CLEAR_3202008SCR:
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d1,d3
	move.l	d2,d4
	move.l	d3,d5
	move.l	d4,d6
	moveq	#100-1,d7
	move.l	d0,a1
	move.l	d1,a2
	move.l	d2,a3
	move.l	d3,a4
	move.l	d4,a5
	move.l	d5,a6
	adda.l	#320*100*2,a0
.loop:
	REPT	12
	movem.l	d0-d6/a1-a6,-(a0)
	ENDR
	movem.l	d0-d3,-(a0)
	dbra	d7,.loop
	rts

* Copies a 320*200 8bpp screen.
* INPUT:
* a0: destination
* a1: source
COPY_PIC3202008:
	moveq	#100-1,d7
.loop:	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,144(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,192(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,240(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,288(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,336(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,384(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,432(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,480(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,528(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,576(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,624(a0)
	lea	640(a0),a0
	dbra	d7,.loop
	rts

* Copies a 320*200 8bpp screen.
* INPUT:
* a0: destination
* a1: source
COPY_PIC32020016:
	move.w	#200-1,d7
.loop:	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,48(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,96(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,144(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,192(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,240(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,288(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,336(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,384(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,432(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,480(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,528(a0)
	movem.l	(a1)+,d0-d6/a2-a6
	movem.l	d0-d6/a2-a6,576(a0)
	movem.l	(a1)+,d0-d3
	movem.l	d0-d3,624(a0)
	lea	640(a0),a0
	dbra	d7,.loop
	rts

******** Highcolor pixeldoubling routines

* Doubles highcolor bitmap in vertical direction.
* (1*1) -> (1*2)
* INPUT:
* d0.w: width of buffer
* d1.w: height of buffer
* a0: destination buffer
* a1: source buffer
DOUBLE_BUFFERV:
	subq.w	#1,d1
	bmi.s	.end
	move.w	d0,d2
	ble.s	.end
	subq.w	#1,d2
	ext.l	d0
	add.l	d0,d0
	lea	(a0,d0.l),a2

.yloop:	move.w	d2,d7

.xloop:	move.w	(a1),(a0)+
	move.w	(a1)+,(a2)+
	dbra	d7,.xloop

	adda.l	d0,a0
	adda.l	d0,a2
	dbra	d1,.yloop

.end:	rts

* Doubles highcolor bitmap in horizontal direction.
* (1*1) -> (2*1)
* INPUT:
* d0.w: width of buffer
* d1.w: height of buffer
* a0: destination buffer
* a1: source buffer
DOUBLE_BUFFERH:
	subq.w	#1,d1
	bmi.s	.end
	move.w	d0,d2
	ble.s	.end
	subq.w	#1,d2

.yloop:	move.w	d2,d7

.xloop:	move.w	(a1),(a0)+
	move.w	(a1)+,(a0)+
	dbra	d7,.xloop

	dbra	d1,.yloop

.end:	rts

* Doubles highcolor bitmap in horizontal and vertical direction.
* (1*1) -> (2*2)
* INPUT:
* d0.w: width of buffer
* d1.w: height of buffer
* a0: destination buffer
* a1: source buffer
DOUBLE_BUFFERHV:
	subq.w	#1,d1
	bmi.s	.end
	move.w	d0,d2
	ble.s	.end
	subq.w	#1,d2
	ext.l	d0
	lsl.l	#2,d0
	lea	(a0,d0.l),a2

.yloop:	move.w	d2,d7

.xloop:	move.w	(a1)+,d0
	move.w	d0,(a0)+
	move.w	d0,(a0)+
	move.w	d0,(a2)+
	move.w	d0,(a2)+
	dbra	d7,.xloop

	adda.l	d0,a0
	adda.l	d0,a2
	dbra	d1,.yloop

.end:	rts

; Bitmap conversion routines..

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

; Converts an interleaved bitplane map to highcolor.
; INPUT:
; d0.w=width (in 16pixel planes!!)
; d1.w=height
; d2.w=#bitplanes
; a0: dst
; a1: src
; a2: pal (highcolor words, 2^#bitplanes entries)
Bitmap.convIBplToHC:
	subq.w	#1,d1
	bmi.s	.end
	move.w	d0,d7				; d7.w=width
	beq.s	.end
	subq.w	#1,d7
	subq.w	#1,d2
	movea.w	d2,a6				; a6=#bitplanes-1

.yloop:	move.w	d7,d0

.xloop:	moveq	#16-1,d6

.pixel_loop:
	move.l	a6,d5				; d5.w=#bitplanes-1
	lea	2(a1,d5.w*2),a3			; a3: next chunk
	clr.l	d3				; d3.b=pixel

.plane_loop:
	add.b	d3,d3				; d3.b=pixel=oldpixel<<1
	move.w	-(a3),d2
	lsr.w	d6,d2
	andi.b	#1,d2				; d2.w=masked bit
	or.b	d2,d3				; d3.b=pixel|masked bit
	dbf	d5,.plane_loop

	move.w	(a2,d3.l*2),(a0)+		; Store pixel.
	dbf	d6,.pixel_loop

	lea	2(a1,a6.l*2),a1			; a1: next chunk
	dbf	d0,.xloop

	dbf	d1,.yloop

.end:	rts

; INPUT:
; a0: dst truecolor palette (24b)
; a1: colorflow instruction table 
Pal.makeGradientTc:
	move.w	(a1)+,d7
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#1,d6
	lsl.w	d0,d6
	move.w	d7,d5
	mulu.w	d6,d5
	subq.w	#1,d6
	move.w	d6,d5
	subq.w	#1,d7

.biglop	move.l	(a1)+,d1
	move.l	(a1),d2
	moveq.l	#0,d3
	move.l	d3,d4
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
	move.l	a0,a6
.lop1	swap	d3
	move.w	d3,2(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop1
	move.w	d5,d6
	move.l	a6,a0
	moveq	#0,d3
	move.l	d3,d4
	swap	d1
	swap	d2
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
.lop2	swap	d3
	move.b	d3,1(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop2
	move.l	a6,a0
	move.w	d5,d6
	moveq.l	#0,d3
	move.l	d3,d4
	swap	d1
	swap	d2
	rol.l	#8,d1
	rol.l	#8,d2
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4
.lop3	swap	d3
	move.b	d3,(a0)
	addq.l	#4,a0
	swap	d3
	add.l	d4,d3
	dbra	d6,.lop3
	move.w	d5,d6
	dbra	d7,.biglop
	rts

; Generates a highcolor pallette from a (truecolor) flowtable.
; Note: doubles hc words
; INPUT:
; a0: dst highcolor buffer
; a1: instruction table 
Pal.makeGradient2Hc:
	move.l	a1,-(sp)
	move.l	a0,-(sp)
	bsr.s	Pal.makeGradientHc
	movea.l	(sp)+,a2
	movea.l	(sp)+,a1

	move.w	(a1)+,d7
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#1,d6
	lsl.w	d0,d6
	move.w	d7,d5
	mulu.w	d6,d5
	lea	(a2,d5.l*4),a2
	subq.w	#1,d5

; a0: src end, a2: dst end
.double_loop:
	move.w	-(a0),-(a2)
	move.w	(a0),-(a2)
	dbf	d5,.double_loop
	
	rts

; Generates a highcolor pallette from a (truecolor) flowtable.
; INPUT:
; a0: dst highcolor buffer
; a1: instruction table 
Pal.makeGradientHc:
	move.w	(a1)+,d7
	moveq	#0,d0
	move.w	(a1)+,d0
	moveq	#1,d6
	lsl.w	d0,d6
	move.w	d7,d5
	mulu.w	d6,d5
	subq.w	#1,d6
	movea.w	d6,a5
	subq.w	#1,d7

.loop:	move.l	(a1)+,d1
	move.l	(a1),d2
	move.l	d1,d3
	move.l	d2,d4
	lsr.l	#8,d3
	lsr.l	#8,d4
	clr.w	d3
	clr.w	d4
	sub.l	d3,d4
	asr.l	d0,d4
	move.l	a0,a6

.red_loop:
	swap	d3
	move.w	d3,d5
	lsl.w	#8,d5
	andi.w	#$f800,d5
	move.w	d5,(a0)+
	swap	d3
	add.l	d4,d3
	dbf	d6,.red_loop

	move.w	a5,d6
	move.l	a6,a0
	move.l	d1,d3
	move.l	d2,d4
	andi.l	#$00ff0000,d3
	andi.l	#$00ff0000,d4
	sub.l	d3,d4
	asr.l	d0,d4

.green_loop:
	swap	d3
	move.w	d3,d5
	lsl.w	#3,d5
	andi.w	#$07e0,d5
	or.w	d5,(a0)+
	swap	d3
	add.l	d4,d3
	dbf	d6,.green_loop

	move.l	a6,a0
	move.w	a5,d6
	moveq	#0,d3
	moveq	#0,d4
	move.b	d1,d3
	move.b	d2,d4
	swap	d3
	swap	d4
	sub.l	d3,d4
	asr.l	d0,d4

.blue_loop:
	swap	d3
	move.w	d3,d5
	lsr.w	#3,d5
	andi.w	#$001f,d5
	or.w	d5,(a0)+
	swap	d3
	add.l	d4,d3
	dbf	d6,.blue_loop

	move.w	a5,d6
	dbra	d7,.loop

	rts

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
