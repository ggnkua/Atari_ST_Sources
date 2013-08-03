

		org	$5000

		bsr		vSync

		lea		$ffff8240.w,a0

		move.w	(a0)+,d0
		moveq	#15-1,d1
iPal:	move.w	d0,(a0)+
		dbf		d1,iPal

		bsr		checkDMASound
		sne		(bDAC).w
	
		bsr		SetScreen
		bsr		PrintScreen

		move.l	#$00070080,$ffff8200.w
		
		bsr		vSync
	
		movem.l	Palette(pc),d0-d7
		movem.l	d0-d7,$ffff8240.w

.over:	tst.b	(bDAC).w			; if no DAC (STF?) then enter an infinite loop
		beq.s	.over

		lea		$5000.w,a0
		moveq	#1,d0			; load screen 1
		pea		(a0)
		jmp		$1000.w			; load the screen, then the RTS jump to the screen itself (run command)
	
Palette:
		dc.w	$005,$337,$227,$000,$117,$006,$004,$001
		dc.w	$777,$777,$777,$777,$777,$777,$777,$777
	
vSync:	move.w	$468.w,d0
.iLoop:	cmp.w	$468.w,d0
		beq.s	.iLoop
		rts

SetScreen:
			lea		$78000,a6
			moveq	#10-1,d2
.iLoop3:	moveq	#20-1,d1
.iLoop2:	movea.l	a6,a5
			lea		Motif(pc),a0
			moveq	#20-1,d0
.iLoop1:	move.l	(a0)+,(a5)+
			move.l	(a0)+,(a5)+
			lea		160-8(a5),a5
			dbf		d0,.iLoop1
			addq.w	#8,a6
			dbf		d1,.iLoop2
			lea		160*(20-1)(a6),a6
			dbf		d2,.iLoop3
			rts
	
PrintScreen:
			lea		$78000,a5
			lea		DaTexte(pc),a0

			tst.b	(bDAC).w
			bne.s	.lineLoop
			lea		DaTexteSTF(pc),a0

.lineLoop:	movea.l	a5,a6
			move.l	#$00070001,d7

.charLoop:	moveq	#0,d0
			move.b	(a0)+,d0
			beq		.over
			cmpi.b	#10,d0
			bne.s	.normal
			
			lea		160*8(a5),a5
			bra.s	.lineLoop
			
.normal:	subi.b	#' ',d0
			lsl.w	#3,d0
			lea		Font(pc),a1
			add.w	d0,a1
			move.b	(a1)+,6(a6)
			move.b	(a1)+,6+160*1(a6)
			move.b	(a1)+,6+160*2(a6)
			move.b	(a1)+,6+160*3(a6)
			move.b	(a1)+,6+160*4(a6)
			move.b	(a1)+,6+160*5(a6)
			move.b	(a1)+,6+160*6(a6)
			move.b	(a1)+,6+160*7(a6)
			add.w	d7,a6
			swap	d7
			bra		.charLoop
			
.over:		rts

checkDMASound:
			move.l	a7,a4
			move.l	$8.w,a5
			move.l	#.back,$8.w
			moveq	#0,d0
			move.b	d0,$ffff8901.w
			move.l	#$00120034,$ffff8902.w
			move.l	$ffff8902.w,d1
			andi.l	#$00ff00ff,d1
			cmpi.l	#$00120034,d1
			seq		d0
.back:		move.l	a5,$8.w
			move.l	a4,a7
			tst.b	d0
			rts



Motif:		
		dc.b	$00,$01,$00,$00,$00,$01,$00,$00
		dc.b	$00,$02,$80,$01,$00,$03,$00,$00
		dc.b	$00,$00,$C0,$03,$3f,$ff,$00,$00
		dc.b	$00,$00,$C0,$03,$3f,$ff,$00,$00
		dc.b	$00,$00,$C0,$03,$3f,$ff,$00,$00
		dc.b	$04,$00,$C7,$e3,$3b,$df,$00,$00
		dc.b	$07,$c0,$C4,$23,$3b,$df,$00,$00
		dc.b	$07,$c0,$C4,$23,$3b,$df,$00,$00
		dc.b	$07,$c0,$C4,$23,$3b,$df,$00,$00
		dc.b	$07,$c0,$C4,$23,$3b,$df,$00,$00
		dc.b	$07,$c0,$C4,$23,$3b,$df,$00,$00
		dc.b	$07,$c0,$C4,$23,$3b,$df,$00,$00
		dc.b	$07,$c0,$C4,$23,$3b,$df,$00,$00
		dc.b	$03,$c0,$C4,$23,$3f,$df,$00,$00
		dc.b	$00,$00,$C3,$e3,$3c,$1f,$00,$00
		dc.b	$00,$00,$C0,$03,$3f,$ff,$00,$00
		dc.b	$00,$00,$C0,$03,$3f,$ff,$00,$00
		dc.b	$00,$00,$C0,$03,$3f,$ff,$00,$00
		dc.b	$3f,$fc,$C0,$03,$3f,$ff,$00,$00
		dc.b	$7f,$fe,$80,$01,$7f,$ff,$00,$00

Font:	
		incbin	"fnt883.bin"
		even

bDAC:	dc.b	0
		
DaTexte:	
;		dc.b	'0123456789012345678901234567890123456789'
		dc.b	10
		dc.b	'   OXYGENE EVEN MORE PROUDLY PRESENTS',10
		dc.b	10
		dc.b	'           THE AMIGA DEMO II',10
		dc.b	'            (FINAL VERSION)',10
		dc.b	10
		dc.b	10
		
;		dc.b	'BETA VERSION: BUILD 17',10
;		dc.b	10
;		dc.b	10
;		dc.b	'FEATURES:',10
;		dc.b	'  -FALCON 16BITS SOUND VERSION',10
;		dc.B	'  -HD LOAD VERSION',10
;		dc.b	'  -FIX A RARE RANDOM CRASH',10
;		dc.b	'  -FIX (HOPE) SOME CRASH ON HD VERSION',10
;		dc.b	'  -LOOP 16MHZ MEGA STE WITH OVERSCAN!',10
;		dc.b	0
		
		dc.b	'READ SOME USEFUL HINTS ABOUT THIS DEMO:',10
		dc.b	10
		dc.b	'1. IT FEATURES 3 HOURS AND 6 MINUTES',10
		dc.b	'   OF GREAT AMIGA SOUND, USING A SINGLE',10
		dc.b	'   FLOPPY DISK',10
		dc.b	10
		dc.b	'2. THIS DEMO CAME 20 YEARS AFTER THE',10
		dc.b	'   GREAT AMIGA DEMO BY THE EXCEPTIONS',10
		dc.b	10
		dc.b	'3. THE PAULA EMULATOR USED HERE SHOULD',10
		dc.b	'   FEATURE THE BEST SOUND QUALITY YOU',10
		dc.b	'   EVER HEARD ON STE (WE HOPE SO!)',10
		dc.b	10
		dc.b	'4. THIS DEMO SHOULD RUN ON 520 STE,',10
		dc.b	'   MEGA STE, TT, FALCON AND CT60',10
		dc.b	10
		dc.b	10
		dc.b	'          ENJOY AMIGA SOUND!',10
		dc.b	0

DaTexteSTF:
;		dc.b	'0123456789012345678901234567890123456789'
		dc.b	10
		dc.b	'   OXYGENE EVEN MORE PROUDLY PRESENTS',10
		dc.b	10
		dc.b	'           THE AMIGA DEMO II',10
		dc.b	10
		dc.b	10
		dc.b	10
		dc.b	10
		dc.b	'SORRY BUT THIS DEMO REQUIRES DAC SOUND',10
		dc.b	'               HARDWARE.',10
		dc.b	10
		dc.b	10
		dc.b	'   THIS DEMO SHOULD RUN ON 520 STE,',10
		dc.b	'   MEGA STE, TT, FALCON AND CT60',10
		dc.b	10
		dc.b	10
		dc.b	'        FIND ANOTHER MACHINE :-(',10
		dc.b	0

		even
	