beamb; System library v1.0, ray//.tSCc. 2004
; Constants

STACKLEN	=	$1000	; Stacklength in bytes

RGB		=	0		; Video hardware
VGA		=	1

NUMCOLORS	=	256	; # of colors (8bpp)


; Utilities

************************************************************
*  d0.l * malloc(d0.l amount, d1.w mode)
*
* Allocate a memory block. Returns NIL in case of an error.
* Doesn't perform any alignment.
************************************************************

STRAM	=	0		; RAM allocation modes
TTRAM	=	3

		section	text
malloc		move.w	d1,-(sp)

		move.l	d0,-(sp)
		move.w	#$44,-(sp)
		trap	#1
		addq.l	#8,sp

		tst.l	d0		; Failed?
		beq.w	restoreAtari
		rts


************************************************************
*  void mfree(d0.l *block)
*
* Release a previously allocated memory block.
************************************************************

mfree		move.l	d0,-(sp)
		move.w	#$49,-(sp)
		trap	#1
		addq.l	#6,sp
		rts
		

************************************************************
*  void ClearBlock(a0.l * block, d0.l amount, d1.l pattern)
*
* Fast blockfill routine. Assumes a word aligned destination
* block.
************************************************************

clearBlock	adda.l	d0,a0	; Point to end of block

		move.l	d0,d2	; amount mod 512
		andi.w	#511,d0
		lsr.l	#8,d2	; amount/512
		lsr.l	d2
		swap.w	d0
		move.w	d2,d0
		
		subq.w	#1,d0
		bmi.s	.skipchunks

		move.l	d1,d2	; Spread pattern accross
		move.l	d1,d3	; available registers
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		movea.l	d1,a1
		movea.l	d1,a2
		movea.l	d1,a3
		movea.l	d1,a4
		movea.l	d1,a5
		movea.l	d1,a6
		
.chunks				; Fill 512 byte chunks
	rept	9
		movem.l	d1-d7/a1-a6,-(a0)
	endr
		movem.l	d1-d7/a1-a4,-(a0)
		dbra	d0,.chunks
		
.skipchunks	swap.w	d0	; Fill remaining longwords
		tst.w	d0
		beq.s	.skipalign

		moveq.l	#31,d2
		and.w	d0,d2
		neg.l	d2
		
		lsr.w	#5,d0
		
		jmp	.entry(pc,d2.l*2)
		
.align	
	rept	32
		move.b	d1,-(a0)
	endr
.entry		dbra	d0,.align
		
.skipalign	rts

	ifeq	1
************************************************************
*  void moveBlock(a0.l * src, a1.l * dst, d0.l amount)
*
* Fast block move routine. Assumes word aligned source and
* destination addresses.
************************************************************

moveBlock	;>divu.w	#512,d0
		move.l	d0,d1	; amount mod 512
		andi.w	#511,d0
		lsr.l	#8,d1	; amount/512
		lsr.l	d1
		swap.w	d0
		move.w	d1,d0

		
		subq.w	#1,d0
		bmi.w	.skipchunks
.chunks				; Blit 512 byte chunks
	rept	10
		movem.l	(a0)+,d1-d7/a2-a6
		movem.l	d1-d7/a2-a6,(a1)
		lea.l	12*4(a1),a1
	endr
		movem.l	(a0)+,d1-d7/a2
		movem.l	d1-d7/a2,(a1)
		lea.l	8*4(a1),a1
		dbra	d0,.chunks
		
.skipchunks	swap.w	d0	; Blit remaining longwords
		tst.w	d0
		beq.s	.skipalign

		moveq.l	#31,d1
		and.w	d0,d1
		neg.l	d1
		
		lsr.w	#5,d0
		
		jmp	.entry(pc,d1.l*2)
.align	
	rept	32
		move.b	(a0)+,(a1)+
	endr
.entry		dbra	d0,.align

.skipalign	rts


***********************************************************
*  void dlz77(a0.l * lzsrc, a1.l * dest)
*
* Very fast lz77 decompression routine
***********************************************************

		move.l	(a0)+,(a1)+     ; Copy 8 bytes literal string
		move.l	(a0)+,(a1)+
         
dlz77		move.b	(a0)+,d0	; Load compression TAG
		beq.s	*-6		; 8 bytes literal string?


		moveq.l	#8-1,d1         ; Process TAG per byte/string
.search		add.b	d0,d0		; TAG <<= 1
		bcs.s	.compressed
		move.b  (a0)+,(a1)+     ; Copy another literal byte
		dbra	d1,.search

		bra.s	dlz77


.compressed	moveq.l	#0,d2
		move.b  (a0)+,d2        ; Load compression specifier
		beq.s	.break		; End of stream, exit

		moveq.l	#$0f,d3		; Mask out stringlength
		and.l	d2,d3

		lsl.w	#4,d2		; Compute string location
		move.b	(a0)+,d2
		movea.l	a1,a2
		suba.l	d2,a2


		neg.l	d3		; Jump into unrolled string copy loop
		jmp     .unroll(pc,d3.l*2)

	rept	15
		move.b	(a2)+,(a1)+
	endr
.unroll		move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+

		dbra	d1,.search

		bra.s	dlz77

.break		rts

	endc

; Interrupt related

************************************************************
*  void interrupt vblIsr()
*
* Default vertical blank interrupt routine, updates physical
* screen base. Can execute an optional vblHook routine
************************************************************
		section	text
vblHook		dc.l	NIL	; &HookRoutine

vblIsr		movem.l	d0-a6,-(sp)

		tas.b	baseUpdate	; Update screenbase?
		bne.s	.keep
		
		move.l	d0,-(sp)
		move.l	actScreen(pc),d0
		bsr.w	setBase
		move.l	(sp)+,d0
		
.keep		move.l	vblHook(pc),d0	; Execute vbl hook routine, if any
		beq.s	.break
		move.l	d0,a0
		jsr	(a0)
		
.break		movem.l	(sp)+,d0-a6

		addq.l	#1,$466.w	; __frcnt++
		rte


************************************************************
*  void wVbl()
*
* Wait till the next vertical blank event has occured.
************************************************************

wVbl		move.l	$466.w,d0
.vbl		cmp.l	$466.w,d0
		beq.s	.vbl
		rts


************************************************************
*  d0.l GetTime()
*
* Return number of 100Hz events occured since last call.
************************************************************

getTime		move.l	$04ba.w,d0
		clr.l	$04ba.w
		rts
		

************************************************************
*  void interrupt tidIsr()
*
* Default Timer D interrupt. Increment 100Hz event counter
************************************************************

tidIsr		addq.l	#1,$04ba.w
		rte

		
************************************************************
*  void interrupt ikbdIsr()
*
* Default ikbdIsr handler, recieve and process ikbd events.
************************************************************

ikbdIsr		move.w	#$2500,sr	; Permit lower priority IRQs

		move.w	d0,-(sp)
		move.b	$fffffc02.w,d0	; Read ACIA buffer
		bpl.s	.key

		cmpi.b	#$f7,d0		; Keypress?
		bls.s	.key
		cmpi.b	#$fb,d0
		bhi.s	.key

		move.b	d0,mouseBut	; Save the button state

		move.w	(sp)+,d0
		move.l	#.getDx,$118.w
		rte

.key		move.b	d0,scanCode
		move.w	(sp)+,d0
		rte


.getDx		move.w	d0,-(sp)
		move.b	$fffffc02.w,d0
		add.b	d0,mouseDx
		move.w	(sp)+,d0
		move.l	#.getDy,$118.w
		rte

.getDy		move.w	d0,-(sp)
		move.b	$fffffc02.w,d0
		add.b	d0,mouseDy
		move.w	(sp)+,d0
		move.l	#ikbdIsr,$118.w	; Reinstall driver
		rte

scanCode	ds.b	1
mouseBut	ds.b	1
mouseDx		ds.b	1	; Relative mouse position  8Bit mantissa
mouseDy		ds.b	1
		even


mouseY		dc.l	(YRES/2)<<8	; Absolute mouse position  24.8 fixed
mouseX		dc.l	(XRES/2)<<8


; System

************************************************************
*  void initAtari()
*
* Initialise the system and shut down system interrupts.
************************************************************

initAtari	movea.l	(sp)+,a3

		movea.l	$04(sp),a5	; Release unneeded memory
		move.l	$0c(a5),d0
		add.l	$14(a5),d0
		add.l	$1c(a5),d0
		add.l	#STACKLEN+$100,d0
		move.l	a5,d1
		add.l	d0,d1
		bclr.l	#0,d1		; Ensure even stack address
		move.l	d1,sp

		move.l	d0,-(sp)
		move.l	a5,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)	; MShrink()
		trap	#1
		lea.l	12(sp),sp


		clr.l	-(sp)
		move.w	#$20,-(sp)	; Super()
		trap	#1
		addq.l	#6,sp
		move.l	d0,sysUSP

		move.l	a3,-(sp)	; Restore return address

		move.l	$05a0.w,d0	; Check machine type via cookiejar
		beq.w	sysExit
		movea.l	d0,a0

.search		tst.l	(a0)
                beq.w	sysExit

                cmp.l	#"_VDO",(a0)	; "_VDO"?
                beq.s	.found

                addq.l	#8,a0
                bra.s	.search

.found          move.w	4(a0),d0	; Load "_MCH" cookie
		cmpi.b  #2,d0		; TT030?
                beq.w	.tt030
		cmpi.b	#3,d0		; F030?
		bne.w	sysExit


; Falcon 030 init

		lea.l	sysMachine,a0
		move.w	#F030,(a0)+

		move.b	$ffff8006.w,d0	; Check monitor type
		beq.w	sysExit		; Monochrome, exit
		
		;>move.w	#RGB,(a0)
		clr.w	(a0)		; Assume RGB
		
		lsr.b	d0		; VGA?
		bcs.s	.rgb
		;>move.w	#VGA,(a0)
		addq.w	#1,(a0)
		
.rgb		move.l	#FXRES*FYRES,physSize

		lea.l	$ffff9800.w,a0	; Save falcon palette
		lea.l	sysPalette,a1
		
		moveq.l	#NUMCOLORS/2-1,d0
.fpal		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d0,.fpal

		movem.l	$ffff8240.w,d0-d7; Save ST palette
		movem.l	d0-d7,(a1)

		lea.l	$ffff8200.w,a0	; Videl
		lea.l	sysVideo,a1
		move.l	(a0),(a1)+	; Phybase
		move.w	$0c(a0),(a1)+
		move.l	$82(a0),(a1)+
		move.l	$86(a0),(a1)+
		move.l	$8a(a0),(a1)+
		move.l	$a2(a0),(a1)+
		move.l	$a6(a0),(a1)+
		move.l	$aa(a0),(a1)+
		move.w	$c0(a0),(a1)+
		move.w	$c2(a0),(a1)+
		move.l	$0e(a0),(a1)+
		move.w	$0a(a0),(a1)+
		move.b	$56(a0),(a1)+
		clr.b	(a1)
		cmp.w	#$b0,$82(a0)
		sle.b	(a1)+
		move.w	$66(a0),(a1)+
		move.w	$60(a0),(a1)
		bra.s	.irqInit


; TT 030 init

.tt030		lea.l	sysMachine,a0
		;>move.w	#TT030,machine	; Save machine type
		clr.w	(a0)+
		;>move.w	#VGA,(a0)
		addq.w	#1,(a0)

		move.l	#TTXRES*TTYRES,physSize

		lea.l	$ffff8400.w,a0	; Save TT palette
		lea.l	sysPalette,a1
		
		moveq.l	#NUMCOLORS/2-1,d0
.tpal		move.l	(a0)+,(a1)+
		dbra	d0,.tpal
		
		movem.l	$ffff8240.w,d0-d7; Save ST palette
		movem.l	d0-d7,(a1)

		lea.l	$ffff8200.w,a0	; TT Shifter
		lea.l	sysVideo,a1
		
		move.l	(a0),(a1)+	; Phybase
		move.w	$0c(a0),(a1)+
		move.l	$60(a0),(a1)+	; ST/TT shiftmode
		
.irqInit	move.w	sr,-(sp)

		move.w	#$2700,sr	; Save irq vectors
		lea.l	sysSave,a0
		move.l	$0070.w,(a0)+
		move.l	$0068.w,(a0)+
		move.l	$0110.w,(a0)+
		move.l	$0114.w,(a0)+
		move.l	$0118.w,(a0)+
		move.l	$0120.w,(a0)+
		move.l	$0134.w,(a0)+

		lea.l	$fffffa00.w,a1	; Save mfp variables
		move.b	$07(a1),(a0)+
		move.b	$09(a1),(a0)+
		move.b	$11(a1),(a0)+
		move.b	$13(a1),(a0)+
		move.b	$15(a1),(a0)+
		move.b	$17(a1),(a0)+
		move.b	$1b(a1),(a0)+
		move.b	$21(a1),(a0)+
		move.b	$0484.w,(a0)
		
		move.b	#%1010000,$09(a1); Enable Timer D and
		move.b	#%1010000,$15(a1); ACIA IRQ
		
		clr.b	$07(a1)		; Turn any other IRQs off
		clr.b	$13(a1)
	
		bclr.b	#3,$17(a1)      ; Set hardware end of Interrupt
					; mode
		clr.b	$0484.w		; Turn off the keybell

		move.l	#vblIsr,$70.w	; New VBL irq
		move.l	#tidIsr,$110.w	; Timer D
		move.l	#ikbdIsr,$118.w	; IKBD IRQ

		ori.b	#%111,$1d(a1)	; Set TID to approx. 100Hz
		move.b	#123,$25(a1)

		moveq.l	#$12,d0		; Disable mouse
		bsr.w	sendCharIKBD
		moveq.l	#$8,d0		; Set relative mouse position
		bsr.w	sendCharIKBD	; reporting mode
		bsr.w	flushIKBD
	
		move.w	(sp)+,sr
	
		move.l	physSize(pc),d0	; Reserve 4 screen pages in ST Ram
		lsl.l	#2,d0		; * =4
		addi.l	#256,d0

		move.l	d0,-(sp)
		moveq.l	#STRAM,d1
		bsr.w	malloc

		move.l	d0,d1
		addi.l	#255,d1		; Byte align block
		clr.b	d1
	
		lea.l	actScreen(pc),a0; Save screen addresses

		moveq.l	#4-1,d2
.screens	move.l	d1,(a0)+
		add.l	physSize(pc),d1
		dbra	d2,.screens
		
		movea.l	d0,a0		; Clear 4 screens
		move.l	(sp)+,d0
		moveq.l	#0,d1
		bsr.w	clearBlock

		moveq.l	#2,d0
		bra.w	cycleScreens

		section	bss
savePal		ds.w	256


************************************************************
*  void restoreAtari()
*
* Restore the system to its initial state.
************************************************************
		section	text
restoreAtari	;>cmpi.w	#TT030,machine
		tst.w	sysMachine	; TT030?
		beq.w	.tt030


; Falcon 030 restore

		lea.l	sysVideo,a0	; Restore Videl
		lea.l	$ffff8200.w,a1
		clr.w   $66(a1)
		move.l	(a0)+,(a1)
		move.w	(a0)+,$0c(a1)
		move.l	(a0)+,$82(a1)
		move.l	(a0)+,$86(a1)
		move.l	(a0)+,$8a(a1)
		move.l	(a0)+,$a2(a1)
		move.l	(a0)+,$a6(a1)
		move.l	(a0)+,$aa(a1)
		move.w	(a0)+,$c0(a1)
		move.w	(a0)+,$c2(a1)
		move.l	(a0)+,$0e(a1)
		move.w	(a0)+,$0a(a1)
	        move.b  (a0)+,$56(a1)
	        tst.b   (a0)+ 
        	bne.s   .ok

	       	move.w  (a0),$66(a1)
	       	bra.s	.frestored
		
.ok		move.w  2(a0),$60(a1)

		lea.l	sysVideo+32,a0
		move.w	(a0),$c2(a1)
		move.l	2(a0),$0e(a1)
		
.frestored	lea.l	$ffff9800.w,a1	; Falcon palette
		lea.l	sysPalette,a0
		
		moveq.l	#128-1,d0
.pal		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		dbra	d0,.pal
		
		movem.l	(a0),d0-d7	; Restore ST palette
		movem.l	d0-d7,$ffff8240.w
		
		bra.s	.irqRestore


; TT030 restore

.tt030		lea.l	$ffff8400.w,a1	; TT palette
		lea.l	sysPalette,a0
		
		moveq.l	#NUMCOLORS/2-1,d0
.tpal		move.l	(a0)+,(a1)+
		dbra	d0,.tpal
		
		movem.l	(a0),d0-d7	; Restore ST palette
		movem.l	d0-d7,$ffff8240.w


		lea.l	$ffff8200.w,a1	; TT shifter
		lea.l	sysVideo,a0
		
		move.l	(a0)+,(a1)	; Phybase
		move.w	(a0)+,$0c(a1)
		move.l	(a0),$60(a1)	; ST/TT shiftmode
	

.irqRestore	move.w	sr,-(sp)
		move.w	#$2700,sr	; Restore IRQ vectors

		lea.l	sysSave,a0
		move.l	(a0)+,$0070.w
		move.l	(a0)+,$0068.w
		move.l	(a0)+,$0110.w
		move.l	(a0)+,$0114.w
		move.l	(a0)+,$0118.w
		move.l	(a0)+,$0120.w
		move.l	(a0)+,$0134.w

		lea.l	$fffffa00.w,a1	; Restore MFP variables
		move.b	(a0)+,$07(a1)
		move.b	(a0)+,$09(a1)
		move.b	(a0)+,$11(a1)
		move.b	(a0)+,$13(a1)
		move.b	(a0)+,$15(a1)
		move.b	(a0)+,$17(a1)
		move.b	(a0)+,$1b(a1)
		move.b	(a0)+,$21(a1)
		move.b	(a0),$484.w
	
		bsr.w	flushIKBD
		move.w	(sp)+,sr

sysExit		move.l	sysUSP(pc),-(sp)
		move.w	#$20,-(sp)	; Super()
		trap	#1
		addq.l	#6,sp

		clr.w	-(sp)		; Pterm()
		trap	#1

sysUSP		ds.l	1

		section	bss
sysSave		ds.b	38
sysPalette	ds.l	256+8
sysVideo	ds.b	46
sysMachine	ds.w	1
sysMonitor	ds.w	1		; Monitor type (RGB/VGA)


************************************************************
*  void flushIKBD()
*
* Flush the acia data buffer by reading all ikbd packets.
************************************************************
		section	text
flushIKBD	bra.s	.wait

.flush		tst.b	$fffffc02.w	; Read buffer
.wait		btst.b	#0,$fffffc00.w	; empty?
		bne.s	.flush
		rts


************************************************************
*  void sendCharIKBD(d0.b char)
*
* Send a command to the acia data buffer.
************************************************************

sendCharIKBD	btst.b	#1,$fffffc00.w	; Ready?
		beq.s	sendCharIKBD

		move.b	d0,$fffffc02.w	; Send char
		rts
		
************************************************************
*  void paintCursor()
*
* Compute mouse position and plot cursor accordingly
************************************************************

mState		=	mouseBut	; Unmasked mouse button state
mXinc		=	mouseDx		; Position increments
mYinc		=	mouseDy
mYfrac		=	mouseY		; Fractional cursor position
mXfrac		=	mouseX
mY		dc.w	YRES/2
mX		dc.w	XRES/2
mSpeed		=	520	; Cursor speed

paintCursor	move.b	mXinc(pc),d2; mX += mXinc*g_mSpeed
		ext.w	d2
		muls.w	#mSpeed,d2
		move.b	mYinc(pc),d3; mY += mYinc*g_mSpeed
		ext.w	d3
		muls.w	#mSpeed,d3
		
		lea.l	mYfrac(pc),a0
		movem.l	(a0)+,d0/d1	; Load mYfrac, mXfrac
		
		add.l	d3,d0		; Increment and clamp coordinates
		add.l	d2,d1
		
		move.l	#(XRES<<8)-1,d2
		cmp.l	d2,d1		; Leaves range?
		bcs.s	.x_range
		bmi.s	.reset_x
		
		move.l	d2,d1		; Clamp right
		bra.s	.x_range
.reset_x	moveq.l	#0,d1		; Clamp left
		
.x_range	move.l	#(YRES<<8)-1,d2
		cmp.l	d2,d0		; Leaves range?
		bcs.s	.y_range
		bmi.s	.reset_y
		
		move.l	d2,d0		; Clamp to bottom
		bra.s	.y_range
.reset_y	moveq.l	#0,d0		; Clamp to top		

.y_range	clr.w	mXinc	; Reset increments
		movem.l	d0/d1,-(a0)	; Save position

		movem.w	mY(pc),d5/d6	; Old mouse position
		
		asl.l	#8,d0		; Save new mouse position
		asr.l	#8,d1
		move.w	d1,d0		; Ypos<<16|Xpos
		move.l	d0,mY

		lea.l	.savePixels(pc),a5
		lea.l	.cursorOffsets(pc),a6
		movea.l	actScreen(pc),a1
	
		moveq.l	#4-1,d7
.restore	movea.l	a1,a0
		move.w	d6,d0
		move.w	d5,d1
		add.w	(a6)+,d0	; Add relative position
		add.w	(a6)+,d1
		move.b	(a5)+,d2	; Old color
		bsr.w	setPixel
		dbra	d7,.restore

		lea.l	.savePixels(pc),a5
		lea.l	.cursorOffsets(pc),a6
		movem.w	mY(pc),d5/d6

		moveq.l	#4-1,d7		; Draw 4 pixels forming the cursor

.drawcross	movea.l	a1,a0		; Save pixel to be overwritten
		move.w	d6,d0
		move.w	d5,d1
		add.w	(a6),d0
		add.w	2(a6),d1
		bsr.w	getPixel
		move.b	d2,(a5)+
		
		movea.l	a1,a0		; Overwrite pixel
		move.w	d6,d0
		move.w	d5,d1
		add.w	(a6)+,d0
		add.w	(a6)+,d1
		moveq.l	#50,d2
		bsr.w	setPixel
		
		dbra	d7,.drawcross
		rts
		
.cursorOffsets	dc.w	(PHYSX-XRES)/2,-1+(PHYSY-YRES)/2	; Relative x, y coordinates for the
		dc.w	(PHYSX-XRES)/2,+1+(PHYSY-YRES)/2	; "cursor cross"
		dc.w	-1+(PHYSX-XRES)/2,(PHYSY-YRES)/2
		dc.w	+1+(PHYSX-XRES)/2,(PHYSY-YRES)/2

.savePixels	ds.b	4