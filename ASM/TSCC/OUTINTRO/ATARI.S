; Atari System library, v1.1, ray//.tSCc. 2002-2007

BYTESPERSCL	=	160		; Physical screen resolution in bytes/scanlines
SCANLINES	=	200
PHYS_X		=	320
PHYS_Y		=	200
PHYS_BPP 	=	4

STACKLEN 	=	1024		; Stacklength in bytes


*********************************
*
*  d0.l *Block AllocSomeMem(d0.l size, d1.w mode)
*
* Try to allocate a fastram block
*
*********************************

STRAM		=	0
TTRAM		=	3

		text
AllocSomeMem:	movem.l d2-a6,-(sp)

		tst.l	d0		; Memavail requested?
		bmi.s	.avail

		addq.l	#4,d0		; Align blocksize by
		andi.b	#-4,d0		; 4 bytes otherwise


.avail: 	cmpi.w	#2,computer	; TT030 or Falcon030?
		blt.s	.malloc 	; no, then use malloc()

		move.w	d1,-(sp)
		move.l	d0,-(sp)
		move.w	#$0044,-(sp)	; mxalloc()
		trap	#1
		addq.l	#8,sp
		bra.s	.break

.malloc:	move.l	d0,-(sp)
		move.w	#$0048,-(sp)	; malloc()
		trap	#1
		addq.l	#6,sp

.break: 	movem.l (sp)+,d2-a6

		tst.l	d0		; Error?
		beq	AtariRestore

		clr.l	ErrMsg
		rts


*********************************
*
*  void FreeSomeMem(d0.l *Block)
*
* Release a previously reserved block
*
*********************************

FreeSomeMem:	movem.l d1-a6,-(sp)

		move.l	d0,-(sp)
		move.w	#$0049,-(sp)	; mfree()
		trap	#1
		addq.l	#6,sp

		movem.l (sp)+,d1-a6
		rts


*******************************
*
*  void FormAlert(a0.l *String)
*
* Create an AES alert box displaying the specified text
*
*******************************

FormAlert:	move.l	a0,addr_in

		move.l	#aes_params,d1
		move.w	#200,d0 	; Function number
		trap	#2		; aes trap

		rts




*********************************
*
*  void ClearBlock(a0.l *block, d0.l amount, d1.l pattern)
*
* Clear a block as fast as possible
*
*********************************

ClearBlock:	adda.l	d0,a0		; Point to end of block

		move.l	d0,d2		; amount%512
		andi.w	#511,d0
		lsr.l	#8,d2		; amount/512
		lsr.l	#1,d2
		swap	d0
		move.w	d2,d0

		subq.w	#1,d0
		bmi.s	.skipchunks

		move.l	d1,d2		; Spread pattern accross
		move.l	d1,d3		; available registers
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		movea.l d1,a1
		movea.l d1,a2
		movea.l d1,a3
		movea.l d1,a4
		movea.l d1,a5
		movea.l d1,a6

.chunks:				; Fill 512 byte chunks
	rept 9
		movem.l d1-d7/a1-a6,-(a0)
	endr
		movem.l d1-d7/a1-a4,-(a0)
		dbra	d0,.chunks

.skipchunks:	swap	d0		; Fill remaining longwords
		tst.w	d0
		beq.s	.skipalign

		moveq	#31,d2
		and.w	d0,d2
		neg.l	d2

		lsr.w	#5,d0

		add.l	d2,d2
		jmp	.entry(pc,d2.l)

.align:
	rept 32
		move.b	d1,-(a0)
	endr
.entry: 	dbra	d0,.align

.skipalign:	rts



*********************************
*
*  void MoveBlock(a0.l *source, a1.l *dest, d0.l amount)
*
* Copy a block as fast as possible
*
*********************************

MoveBlock:	move.l	d0,d1		; amount%512
		andi.w	#511,d0
		lsr.l	#8,d1		; amount/512
		lsr.l	#1,d1
		swap	d0
		move.w	d1,d0


		subq.w	#1,d0
		bmi	.skipchunks_mv
.chunks_mv:				; Blit 512 byte chunks
	rept 10
		movem.l (a0)+,d1-d7/a2-a6
		movem.l d1-d7/a2-a6,(a1)
		lea	12*4(a1),a1
	endr
		movem.l (a0)+,d1-d7/a2
		movem.l d1-d7/a2,(a1)
		lea	8*4(a1),a1
		dbra	d0,.chunks_mv

.skipchunks_mv: swap	d0		; Blit remaining longwords
		tst.w	d0
		beq.s	.skipalign_mv

		moveq	#31,d1
		and.w	d0,d1
		neg.l	d1

		lsr.w	#5,d0

		add.l	d1,d1
		jmp	.entry_mv(pc,d1.l)
.align_mv:
	rept 32
		move.b	(a0)+,(a1)+
	endr
.entry_mv:	dbra	d0,.align_mv

.skipalign_mv:	rts



*********************************
*
*  void d_lz77(a0.l *lz77data, a1.l *dest)
*
* Very! fast lz77 decompression routine
* 68000 version
*
*********************************

d_lz77: 	addq.l	#4,a0		; Skip original length
		bra.s	.loadtag

.literal:
	rept 8
		move.b	(a0)+,(a1)+	; Copy 8 bytes literal string
	endr

.loadtag:	move.b	(a0)+,d0	; Load compression TAG
		beq.s	.literal	; 8 bytes literal string?


		moveq	#8-1,d1 	; Process TAG per byte/string
.search:	add.b	d0,d0		; TAG <<= 1
		bcs.s	.compressed

		move.b	(a0)+,(a1)+	; Copy another literal byte
		dbra	d1,.search

		bra.s	.loadtag


.compressed:	moveq	#0,d2
		move.b	(a0)+,d2	; Load compression specifier
		beq.s	.break_lz	; End of stream, exit

		moveq	#$0f,d3 	; Mask out stringlength
		and.l	d2,d3

		lsl.w	#4,d2		; Compute string location
		move.b	(a0)+,d2
		movea.l a1,a2
		suba.l	d2,a2


		add.w	d3,d3		; Jump into unrolled string copy loop
		neg.w	d3
		jmp	.unroll_lz(pc,d3.w)

	rept 15
		move.b	(a2)+,(a1)+
	endr
.unroll_lz:	move.b	(a2)+,(a1)+
		move.b	(a2)+,(a1)+

		dbra	d1,.search

		bra.s	.loadtag

.break_lz:	rts


*********************************
*
*  void ISRSave(a0.l *char[54])
*
* Save ISR and MFP settings
*
*********************************

ISRSave:	movem.l d0-a6,-(sp)
		move.w	sr,-(sp)
		ori.w	#$0700,sr	; Disable all interrupts

		move.l	$00000070.w,(a0)+ ; ISR vectors
		move.l	$00000068.w,(a0)+
		move.l	$00000110.w,(a0)+
		move.l	$00000114.w,(a0)+
		move.l	$00000118.w,(a0)+
		move.l	$00000120.w,(a0)+
		move.l	$00000134.w,(a0)+

		lea	$fffffa00.w,a1	; MFP
		move.b	$0001(a1),(a0)+
		move.b	$0003(a1),(a0)+
		move.b	$0005(a1),(a0)+
		move.b	$0007(a1),(a0)+
		move.b	$0009(a1),(a0)+
		move.b	$000b(a1),(a0)+
		move.b	$000d(a1),(a0)+
		move.b	$000f(a1),(a0)+
		move.b	$0011(a1),(a0)+
		move.b	$0013(a1),(a0)+
		move.b	$0015(a1),(a0)+
		move.b	$0017(a1),(a0)+
		move.b	$0019(a1),(a0)+
		move.b	$001b(a1),(a0)+
		move.b	$001d(a1),(a0)+
		move.b	$001f(a1),(a0)+
		move.b	$0021(a1),(a0)+
		move.b	$0023(a1),(a0)+
		move.b	$0025(a1),(a0)+
		move.b	$00000484.w,(a0)+

		move.w	(sp)+,sr
		movem.l (sp)+,d0-a6
		rts


*********************************
*
*  void ISRRestore(a0.l *char[54])
*
* Restore ISR and MFP settings
*
*********************************

ISRRestore:	movem.l d0-a6,-(sp)
		move.w	sr,-(sp)
		ori.w	#$0700,sr	; Disable all interrupts

		clr.b	$fffffa1b.w	; Stop timer B
		move.l	(a0)+,$00000070.w ; ISR vectors
		move.l	(a0)+,$00000068.w
		move.l	(a0)+,$00000110.w
		move.l	(a0)+,$00000114.w
		move.l	(a0)+,$00000118.w
		move.l	(a0)+,$00000120.w
		move.l	(a0)+,$00000134.w

		lea.l	$fffffa00.w,a1	; MFP
		move.b	(a0)+,$0001(a1)
		move.b	(a0)+,$0003(a1)
		move.b	(a0)+,$0005(a1)
		move.b	(a0)+,$0007(a1)
		move.b	(a0)+,$0009(a1)
		move.b	(a0)+,$000b(a1)
		move.b	(a0)+,$000d(a1)
		move.b	(a0)+,$000f(a1)
		move.b	(a0)+,$0011(a1)
		move.b	(a0)+,$0013(a1)
		move.b	(a0)+,$0015(a1)
		move.b	(a0)+,$0017(a1)
		movea.l a0,a2
		clr.b	$0019(a1)
		clr.b	$001b(a1)
		clr.b	$001d(a1)
		addq.w	#3,a0
		move.b	(a0)+,d0	;$1f(a1)
		move.b	(a0)+,d0	;$21(a1)
		move.b	(a0)+,d0	;$23(a1)
		move.b	(a0)+,d0	;$25(a1)
		move.b	(a2)+,$0019(a1)
		move.b	(a2)+,$001b(a1)
		move.b	(a2)+,$001d(a1)
		move.b	(a0)+,$0484.w

		move.w	(sp)+,sr
		movem.l (sp)+,d0-a6
		rts


*********************************
*
*  void AtariInit()
*
* Determine machine type and initialise system
* accordingly
*
*********************************

AtariInit:	move.l	(sp)+,.ret	; Save return address

		movea.l 4(sp),a5
		move.l	$000c(a5),d0
		add.l	$0014(a5),d0
		add.l	$001c(a5),d0
		addi.l	#STACKLEN,d0

		move.l	a5,d1
		add.l	d0,d1		; End of program
		addq.l	#1,d1
		bclr.l	#0,d1
		movea.l d1,sp

		move.l	d0,-(sp)
		move.l	a5,-(sp)
		clr.w	-(sp)
		move.w	#$004a,-(sp)	; mshrink()
		trap	#1
		lea.l	12(sp),sp

		pea.l	PHYS_Y*BYTESPERSCL*3+256 ; Reserve 3 screen pages in ST-RAM
		move.w	#$0048,-(sp)	; malloc()
		trap	#1
		addq.l	#6,sp


		tst.l	d0		; Error?
		bne.s	.malloc_ok

		lea	.ScrBufferFail,a0 ; Print Errormessage and exit
		bsr.w	FormAlert
	
		clr.w	-(sp)
		trap	#1


.malloc_ok:	addi.l	#255,d0 	; Init screens
		clr.b	d0		; Align by 256 bytes

		lea.l	screen1(pc),a0
		lea.l	PHYS_Y*BYTESPERSCL.w,a1
		move.l	d0,(a0)+
		add.l	a1,d0
		move.l	d0,(a0)+
		add.l	a1,d0
		move.l	d0,(a0)+

		movea.l screen1(pc),a0	; Clear screens
		move.l	#PHYS_Y*BYTESPERSCL*3,d0
		moveq	#0,d1
		bsr.w	ClearBlock

		clr.l	-(sp)		; Super()
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,save_stack

		lea.l	MyStack,sp


; Determine machinetype via cookiejar

		move.l	#"_VDO",d1	; Cookie we are looking for
		move.l	$000005a0.w,d0	; Get address of cookie jar in d0
		beq.s	.init_nojar	; If zero, there's no jar.
		movea.l d0,a0		; Move the address of the jar to a0

.init_search:	tst.l	(a0)		; Is this jar entry the last one ?
		beq.s	.init_nofind	; Yes, the cookie was not found
		cmp.l	(a0),d1 	; Does this cookie match what we're looking for?
		beq.s	.init_foundit	; Yes, it does.
		addq.l	#8,a0		; Advance to the next jar entry
		bra.s	.init_search	; and start over

.init_nofind:	moveq	#-1,d0		; A negative (-1) means cookie not found
		bra.s	.init_cookieexit
.init_nojar:	moveq	#-2,d0		; A negative (-2) means there's no jar
		bra.s	.init_cookieexit
.init_foundit:	moveq	#0,d0		; A null in d0 means the cookie was found.

.init_cookieexit:
		tst.l	d0		; If not 0, assume ST
		bne.s	.init_st
		cmpi.l	#$00010000,4(a0) ; 1=STE
		beq.s	.init_ste
		cmpi.l	#$00020000,4(a0) ; 2=TT030
		beq.s	.init_tt
		cmpi.l	#$00030000,4(a0) ; 3=Falcon
		beq.s	.init_falc
		bra.s	.init_st	; If nothing else, assume ST

.init_ste:	move.w	#1,computer
		bra.s	.init_st

.init_tt:	move.w	#2,computer

.init_st:	move.l	$ffff8200.w,save_phy
		move.l	$ffff8260.w,save_res

		bsr.w	cycleScreens	; Update Physbase, eleminating junk before the resolution
					; switch
		clr.b	$ffff8260.w	; Set 320x200x4bpp (ST)

		bra	.init_video_done

.init_falc:	move.w	#3,computer

		lea	save_f030video,a0
		move.l	$ffff8200.w,(a0)+ ; vidhm
		move.w	$ffff820c.w,(a0)+ ; vidl
		move.l	$ffff8282.w,(a0)+ ; h-regs
		move.l	$ffff8286.w,(a0)+
		move.l	$ffff828a.w,(a0)+
		move.l	$ffff82a2.w,(a0)+ ; v-regs
		move.l	$ffff82a6.w,(a0)+
		move.l	$ffff82aa.w,(a0)+
		move.w	$ffff82c0.w,(a0)+ ; vco
		move.w	$ffff82c2.w,(a0)+ ; c_s
		move.l	$ffff820e.w,(a0)+ ; offset
		move.w	$ffff820a.w,(a0)+ ; sync
		move.b	$ffff8256.w,(a0)+ ; p_o
		clr.b	(a0)		; test of ST(E) or falcon mode
		cmpi.w	#$00b0,$ffff8282.w ; hht < $b0?
		sle.b	(a0)+		; Set flag
		move.w	$ffff8266.w,(a0)+ ;f_s
		move.w	$ffff8260.w,(a0)+ ;st_s

                bsr.w	cycleScreens	; Update Physbase

		move.w	#$0059,-(sp)	; Check monitortype (falcon)
		trap	#14		;
		addq.l	#2,sp		;
		cmp.w	#1,d0		; if 1 = RGB
		beq.s	.rgb60		;
		cmp.w	#3,d0		; if 3 = TV
		beq.s	.rgb60		; Otherwise assume VGA (ignore mono..)


.vga60: 	move.l	#$00170012,$ffff8282.w ; Falcon 60hz vga
		move.l	#$0001020e,$ffff8286.w
		move.l	#$000d0012,$ffff828a.w
		move.l	#$041903ff,$ffff82a2.w
		move.l	#$003f008d,$ffff82a6.w
		move.l	#$03ad0415,$ffff82aa.w
		move.w	#$0200,$ffff820a.w
		move.w	#$0186,$ffff82c0.w
		clr.w	$ffff8266.w
		clr.b	$ffff8260.w
		move.w	#$0005,$ffff82c2.w
		move.w	#$0050,$ffff8210.w



		bra.s	.init_video_done

.rgb60: 	move.l	#$003e0026,$ffff8282.w
		move.l	#$00150004,$ffff8286.w
		move.l	#$001d0035,$ffff828a.w
		move.l	#$020901db,$ffff82a2.w
		move.l	#$004b004b,$ffff82a6.w
		move.l	#$01db0203,$ffff82aa.w
		move.w	#$0200,$ffff820a.w
		move.w	#$0181,$ffff82c0.w
		clr.w	$ffff8266.w
		move.b	#$00,$ffff8260.w
		move.w	#$0000,$ffff82c2.w
		move.w	#$0050,$ffff8210.w
;>		move.b	$ffff820a.w,sys_sync
;>		bra.s	.skip_sync

.init_video_done:
		move.b	$ffff820a.w,sys_sync
		bclr.b	#1,$ffff820a.w	; Switch to NTSC mode

.skip_sync:	lea	$ffff8240.w,a0

		movem.l (a0),d0-d7	; Save palette
		movem.l d0-d7,save_pal

	rept 8
		clr.l	(a0)+		; Black palette
	endr


		lea.l	sys_vars,a0 ; Save ISR settings
		bsr.w	ISRSave

      		move.w	#$2700,sr

	ifnd	DEBUG
		lea.l	sys_errvec,a1 ; Patch in my error handlers
		lea.l	$00000008.w,a0
		move.l	(a0)+,(a1)+	; Bus Error
		move.l	(a0)+,(a1)+	; Address Error
		move.l	(a0)+,(a1)+	; Illegal Instruction Error

		move.l	#IlgInstErr,-(a0)
		move.l	#AddrErr,-(a0)
		move.l	#BusErr,-(a0)
	endc

;>		  moveq   #$12,d0	; Mouse position reporting off
;>		  bsr	  IO_SendIKBD

		move.l	#IdleVBL,$70.w	; Set up my ISRs
		move.l	#IdleHBL,$68.w

		move.l  #IO_CheckInput,$118.w
		move.l	#IdleA,$134.w
		move.l	#IdleB,$120.w
		move.l	#IdleC,$114.w
		move.l	#IdleD,$110.w

		lea.l	$fffffa00.w,a1
		move.b	#%00000001,$0007(a1) ; Enable timer b
		move.b	#%00000001,$0013(a1)
		move.b	#%01100000,$0009(a1) ; Enable IKBD IRQ and timer c
		move.b	#%01100000,$0015(a1)

		bclr.b	#3,$0017(a1)	; Hardware end of interrupt

		clr.b	$484.w		; Keyclick & repeat off

		move.w	#$2300,sr


		bsr.w	initSetPalette	; Init faded palette tables

		move.l	.ret(pc),-(sp)
		rts

.ret:		ds.l	1		; Return address

		data
.ScrBufferFail:	dc.b '[1][Malloc(): Failed to allocate|work screens.][ OK ]'
		even
.DmaBufferFail:	dc.b '[1][Malloc(): Failed to allocate|audio ringbuffers.][ OK ]'
		even



; Interrupt handlers

** temp
IO_CheckInput:	rte
*******

***********************************
*
*  void interrupt IdleC
*
* Increment _hz_200
*
***********************************

		text
IdleC:		addq.l	#1,$4ba.w	; _hz_200++
		rte


*******************************
*
*  void interrupt IdleFrcnt()
*
* Increment _VBL tick value
*
*******************************

VBLHookPtr:	dc.l	NULL		; Additional VBL routine #1
VBLHookPtr2:	dc.l	NULL		; and #2

VBLTailPtr:	dc.l	IdleA

IdleVBL:	move.l	d0,-(sp)

		move.l	VBLHookPtr(pc),d0	; Execture additional VBL routine #1?
		beq.s	.idle

		movem.l	d1-a6,-(sp)
                movea.l	d0,a0
		jsr	(a0)
                movem.l	(sp)+,d1-a6

.idle:		move.l	VBLHookPtr2(pc),d0	; Execture additional VBL routine #2?
		beq.s	.idle2

		movem.l	d1-a6,-(sp)
                movea.l	d0,a0
		jsr	(a0)
                movem.l	(sp)+,d1-a6

.idle2:		move.l	(sp)+,d0

		addq.l	#1,$466.w
;>		rte
;>		bra.w	demoTimerC ***
		move.l	VBLTailPtr(pc),-(sp)
		rts

IdleHBL:	rte
IdleA:		rte
IdleB:		rte
IdleD:		rte

*******************************
*
*  void interrupt splitPalVBL()
*  void interrupt splitPalHBL()
*
* Install VBL handler for split palette effects.
* "palObjPtr" is assumed to point to the current palette descriptor
*
*******************************

palObjPtr:	dc.l	NULL
curPalObjPtr:	dc.l	NULL

splitPalVBL:	movem.l	d0/a0/a6,-(sp)

		clr.b	$fffffa1b.w	; Stop HBL
		move.l	#IdleB,$120.w	; Install idle HBL handler

		move.l	palObjPtr(pc),d0	; palObjPtr != NULL?
		beq.s	.skip

		movea.l	d0,a6
		move.w	(a6)+,d0	; brightness
		movea.l	(a6)+,a0	; &palette
		bsr.w	setPalette

		move.w	(a6)+,d0	; Relative scanline position of next
		bmi.s	.skip		; Palette, if any

		move.l	a6,curPalObjPtr		; Keep track of palette object pointer
      		move.l	#splitPalHBL,$120.w	; Install palette HBL handler

		move.b	d0,$fffffa21.w	; Write to HBL counter register
		bset.b	#3,$fffffa1b.w	; Enable HBL event

.skip:		movem.l	(sp)+,d0/a0/a6

		move.l	d0,-(sp)

		move.l	VBLHookPtr(pc),d0	; Execture additional VBL routine #1?
		beq.s	.idle1

		movem.l	d1-a6,-(sp)
                movea.l	d0,a0
		jsr	(a0)
                movem.l	(sp)+,d1-a6

.idle1:         move.l	VBLHookPtr2(pc),d0	; Execture additional VBL routine #2?
		beq.s	.idle2

		movem.l	d1-a6,-(sp)
                movea.l	d0,a0
		jsr	(a0)
                movem.l	(sp)+,d1-a6

.idle2:		move.l	(sp)+,d0

		addq.l	#1,$466.w	; _VBL++
		;;rte

		move.l	VBLTailPtr(pc),-(sp)
		rts


splitPalHBL:	movem.l	d0/a0/a6,-(sp)

		clr.b	$fffffa1b.w	; Stop HBL
		move.l	#IdleB,$120.w	; Install idle HBL handler

		movea.l	curPalObjPtr(pc),a6
		move.w	(a6)+,d0	; brightness
		movea.l	(a6)+,a0	; &palette
		bsr.w	setPalette

		move.w	(a6)+,d0	; Relative scanline position of next
		bmi.s	.skip		; Palette, if any

		move.l	a6,curPalObjPtr		; Keep track of palette object pointer
      		move.l	#splitPalHBL,$120.w	; Install palette HBL handler

		move.b	d0,$fffffa21.w	; Write to HBL counter register
		bset.b	#3,$fffffa1b.w	; Enable HBL event

.skip:		movem.l	(sp)+,d0/a0/a6
		rte


*******************************
*
*  void installSplitPalette(a0.l * palObject)
*
* Install split palette from the given object.
*
*******************************

installSplitPalette:
;>		move.w	sr,-(sp)
;>		move.w	#$2700,sr

		move.l	a0,palObjPtr	; Install palette handler
		move.l	#splitPalVBL,$70.w

		bclr.b	#3,$fffffa03.w	; HBL at the end of each scanline
		bset.b	#0,$fffffa07.w	; Mask in HBL
		bset.b	#0,$fffffa13.w


;>		clr.b	$fffffa1b.w

;>		move	(sp)+,sr
		rts


*******************************
*
*  void uninstallSplitPalette()
*
* Uninstall split palette handler.
*
*******************************

uninstallSplitPalette:
;>		move.w	sr,-(sp)
;>		move.w	#$2700,sr

		clr.l	palObjPtr
		move.l	#IdleVBL,$70.w
		move.l	#IdleB,$120.w

       		clr.b	$fffffa1b.w

               	bclr.b	#0,$fffffa07.w	; Stop HBL
		bclr.b	#0,$fffffa13.w

;>		move.w	(sp)+,sr
		rts



*******************************
*
*  void AtariRestore()
*
* Restore system settings and exit to
* desktop
*
*******************************

AtariRestore:	move.b	sys_sync,$ffff820a.w

		lea.l	$ffff8240.w,a0	; Set palette to black

	rept 8
		clr.l	(a0)+
	endr

		move.w	#$2700,sr

	ifd	DEBUG
		lea.l	sys_errvec,a0
		lea.l	$8.w,a1

	rept 3
		move.l	(a0)+,(a1)+
	endr
	endc

;>		  moveq   #8,d0 	  ; Mouse on
;>		  bsr	  IO_SendIKBD
		move.w	#$2300,sr

		lea.l	sys_vars,a0
		bsr.w	ISRRestore



		cmpi.w	#3,computer
		beq.s	.falcrestore

.strestore:	move.l	save_phy,$ffff8200.w
		move.l	save_res,$ffff8260.w

		bra.s	.video_done

.falcrestore:	clr.w	$ffff8266.w	; Falcon-shift clear
		lea	save_f030video,a0
		move.l	(a0)+,$ffff8200.w ;videobase_address:h&m
		move.w	(a0)+,$ffff820c.w ;l
		move.l	(a0)+,$ffff8282.w ;h-regs
		move.l	(a0)+,$ffff8286.w ;
		move.l	(a0)+,$ffff828a.w ;
		move.l	(a0)+,$ffff82a2.w ;v-regs
		move.l	(a0)+,$ffff82a6.w ;
		move.l	(a0)+,$ffff82aa.w ;
		move.w	(a0)+,$ffff82c0.w ;vco
		move.w	(a0)+,$ffff82c2.w ;c_s
		move.l	(a0)+,$ffff820e.w ;offset
		move.w	(a0)+,$ffff820a.w ;sync
		move.b	(a0)+,$ffff8256.w ;p_o
		tst.b	(a0)+		;st(e) comptaible mode?
		bne.s	.falcok

		move.w	(a0),$ffff8266.w ;falcon-shift
		bra.s	.video_done

.falcok:	move.w	2(a0),$ffff8260.w ;st-shift
		lea	save_f030video,a0
		move.w	32(a0),$ffff82c2.w ;c_s
		move.l	34(a0),$ffff820e.w ;offset


.video_done:	movem.l save_pal,d0-d7	; Restore palette
		movem.l d0-d7,$ffff8240.w


		move.l	save_stack,-(sp) ; Return to user mode
		move.w	#32,-(sp)
		trap	#1
		addq.l	#6,sp


		move.l	ErrMsg,d0	; Did an error occur ?
		beq.s	.pterm		; no, then exit

		movea.l d0,a0
		bsr.w	FormAlert	; Otherwise display error-dialog

.pterm: 	clr.w	-(sp)		; Pterm()
		trap	#1

ErrMsg:		dc.l	NULL		; Pointer to possible error message


*******************************
*
*  void BusErr()
*  void AddrErr()
*  void IlgInstErr()
*
* Patched error handlers
*
*******************************

BusErr: 	move.l	#.BusErrMsg,ErrMsg

		move.l	10(sp),d0
		lea	.BusErrAdr+6,a0
		bra.s	ConvertErrAdr


               	data
.BusErrMsg:	dc.b '[1][Bus Error at|.text+0x'
.BusErrAdr:	dc.b '000000][ OK ]' ; Insert hex address here
		even

                text
AddrErr:	move.l	#.AddrErrMsg,ErrMsg

		move.l	10(sp),d0
		lea	.AddrErrAdr+6,a0
		bra.s	ConvertErrAdr

		data
.AddrErrMsg:	dc.b '[1][Address Error at|.text+0x'
.AddrErrAdr:	dc.b '000000][ OK ]'
		even

                text
IlgInstErr:	move.l	#.IlgInstErrMsg,ErrMsg

		move.l	2(sp),d0
		lea	.IlgInstErrAdr+6,a0
;>		bra.s	ConvertErrAdr

		data
.IlgInstErrMsg:	dc.b '[1][Illegal Instruction Error|at .text+0x'
.IlgInstErrAdr:	dc.b '000000][ OK ]'
		even

		text
ConvertErrAdr:	subi.l	#main,d0	; Convert offset of exception
; into hex string

		moveq	#6-1,d1 	; 6 digits
.convloop:	moveq	#$0f,d2
		and.l	d0,d2
		move.b	.bin2hex(pc,d2.l),-(a0)
		lsr.l	#4,d0		; Next digit
		dbra	d1,.convloop

		bra.w	AtariRestore

.bin2hex:	dc.b	'0123456789abcdef'


                data
computer:	dc.w	0 		; 0=st 1=ste 2=tt 3=falc

aes_params:	dc.l	control 	;  aes pointer structure
		dc.l	global_
		dc.l	int_in
		dc.l	int_out
		dc.l	addr_in
		dc.l	addr_out

control:	dc.w 52 		;    form_alert
		dc.w 1			;	control1-4
		dc.w 1
		dc.w 1
		dc.w 0


                bss
save_stack:	ds.l 1		; Space to save sytem settings
save_phy:	ds.l 1
save_res:	ds.l 1
save_pal:	ds.l 8
sys_errvec:	ds.l 3
save_f030video:	ds.b 46

sys_vars:	ds.b	54		; MFP+ISR
sys_sync:	ds.b	1
		even

global_:	ds.w	14 		; AES parameter block
int_in:		ds.w	16
int_out:	ds.w	7
addr_in:	ds.l	3
addr_out:	ds.l	1

		ds.b	STACKLEN	; Stackspace
MyStack:	ds.l	1


***********************************
*
*  void wVBL()
*
* Wait for next vertical blank event.
*
***********************************

		text
wVBL:		move.l	$466.w,d0	; Wait for VBL
.wvbl:		cmp.l	$466.w,d0
		nop
		beq.s	.wvbl
		rts


***********************************
*
*  long d0.l getTime()
*
* Return 200Hz tics passed since last call
*
***********************************

getTime:	move.l	$466.w,d0	;;$4ba.w,d0
		clr.l	$466.w		;;$4ba.w
		rts


; Misc. hardware routines

*********************************************
*
*  void cycleScreens()
*
* Cycle tripply buffers, unsynced to vertical
* retrace.
*
*********************************************

cycleScreens:	movem.l screen1(pc),d0-d2 ; Cycle screens
		exg.l	d1,d2
		exg.l	d0,d1
		movem.l d0-d2,screen1
		lsr.w	#8,d0
		move.l	d0,$ffff8200.w
		rts


screen1:	ds.l 1			; Physbase
screen2:	ds.l 1			; Logbase 1
screen3:	ds.l 1			; Logbase 2


*******************************************************
*
*  void initSetPalette()
*  void setPalette(a0.l * src444, d0.w brightness)
*
* Render the given 444rgb palette to the video hardware's
* color DAC.
*
*******************************************************

initSetPalette:	move.l	#fadeTable,d0	; Align table to 256 byte boundary
		clr.b	d0

		move.l	d0,fadeTablePtr

		movea.l	d0,a0		; Destination table
		lea.l	.faded_nibble(pc),a1

		moveq.l	#0,d3

		moveq.l	#(1<<PHYS_BPP)-1,d1	; Create 2 ^ PHYS_BPP faded color tables

.fade_loop:	moveq.l	#0,d0

.color_loop:	move.b	d0,d3
		moveq.l	#$f,d2
		and.b	d0,d2
		lsr.b	#4,d3

		add.b	d2,d2		; Convert from STE DAC format
		bclr.l	#4,d2
		beq.s	.null_hi
		addq.b	#1,d2

.null_hi:	add.b	d3,d3
		bclr.l	#4,d3
               	beq.s	.null_lo
         	addq.b	#1,d3

.null_lo:	move.b	(a1,d3.l),d3	; Recombine faded channels
		lsl.b	#4,d3
		or.b	(a1,d2.l),d3
		move.b	d3,(a0)+

		addq.b	#1,d0
		bcc.s	.color_loop

		addq.l	#1,a1
		dbra	d1,.fade_loop

		rts

.faded_nibble:	dc.b	$0,$0,$0,$0,$0,$0,$0	; Faded nibble table (STE palette DAC format)
                dc.b	$0,$0,$0,$0,$0,$0,$0,$0
		dc.b	$0,$8,$1,$9,$2,$a,$3,$b
		dc.b	$4,$c,$5,$d,$6,$e,$7,$f
		dc.b	$f


setPalette:     movem.l	d0-d1/a0-a3,-(sp)


		lea.l	$ffff8240.w,a1	; Hardware DAC registers

		ext.l	d0
		lsl.w	#8,d0
		add.l	fadeTablePtr(pc),d0
		lea.l	.short(pc),a3	; Space to combine high and low byte values
					; (faster than using shifts on the 68000)

	rept	(1<<PHYS_BPP)
		move.b	(a0)+,d0	; Retrieve high byte of DAC value (-R)
		move.l	d0,a2
		move.b	(a2),(a3)+
		move.b	(a0)+,d0	; Retrieve low byte of DAC value (GB)
		move.l	d0,a2
		move.b	(a2),(a3)+
		move.w	-(a3),(a1)+
	endr


		movem.l	(sp)+,d0-d1/a0-a3
		rts

.short:		dc.w	0

fadeTablePtr:	dc.l	0

		bss
		ds.b	256
fadeTable:	ds.b	(1<<PHYS_BPP)*256


*******************************************************
*
*  void convPalette(a0.l * src888, a1.l * dst444)
*
* Convert the given 888rgb palette array into a 444rgb
* STE compatible format.
*
*******************************************************

		text
convPalette:	moveq.l	#(1<<PHYS_BPP)-1,d0

.palloop:	move.b	(a0)+,d1	; Load r,g,b
		move.b	(a0)+,d2
		move.b	(a0)+,d3
		lsr.b	#4,d1		; Scale down
		lsr.b	#4,d2
		lsr.b	#4,d3

		lsr.b	#1,d1		; Convert to STE palette
		bcc.s	.r_cc		; bit order
		addq.b	#$08,d1

.r_cc:		lsr.b	#1,d2
		bcc.s	.g_cc
		addq.b	#$08,d2

.g_cc:		lsr.b	#1,d3
		bcc.s	.b_cc
		addq.w	#$08,d3
.b_cc:
		lsl.w	#8,d1		; Recombine channels
		or.b	d3,d1
		lsl.b	#4,d2
		or.b	d2,d1
		move.w	d1,(a1)+

		dbra	d0,.palloop
		rts


******************************************************
*  void clearScreens()
*
* Clear all three workscreens.
******************************************************

clearScreens:	moveq.l	#3-1,d1

.cls:   	move.w	d1,-(sp)
		movea.l	screen3(pc),a0
		lea.l	BYTESPERSCL*((PHYS_Y-LOGO_Y)/2)(a0),a0
		move.l	#BYTESPERSCL*LOGO_Y,d0
		moveq.l	#0,d1
		bsr.w	ClearBlock

		bsr.w	cycleScreens
		move.w	(sp)+,d1
		dbra	d1,.cls
        	rts
