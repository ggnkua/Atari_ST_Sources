;-----------------------------------------------------------------------;

;-----------------------------------------------------------------------;

; SetVideo() equates.

VERTFLAG	EQU $0100	; double-line on VGA, interlace on ST/TV ;
STMODES		EQU $0080	; ST compatible ;
OVERSCAN	EQU $0040	; Multiply X&Y rez by 1.2, ignored on VGA ;
PAL		EQU $0020	; PAL if set, else NTSC ;
VGA		EQU $0010	; VGA if set, else TV mode ;
COL80		EQU $0008	; 80 column if set, else 40 column ;
BPS16		EQU $0004
BPS8		EQU $0003
BPS4		EQU $0002
BPS2		EQU $0001
BPS1		EQU $0000

; Cache Control Register Equates (CACR)

ENABLE_CACHE		EQU 1   ; Enable instruction cache
FREEZE_CACHE		EQU 2   ; Freeze instruction cache
CLEAR_INST_CACHE_ENTRY	EQU 4   ; Clear instruction cache entry
CLEAR_INST_CACHE	EQU 8   ; Clear instruction cache
INST_BURST_ENABLE	EQU 16  ; Instruction burst enable
ENABLE_DATA_CACHE	EQU 256 ; Enable data cache
FREEZE_DATA_CACHE	EQU 512 ; Freeze data cache
CLEAR_DATA_CACHE_ENTRY	EQU 1024 ; Clear data cache entry
CLEAR_DATA_CACHE	EQU 2048 ; Clear data cache
DATA_BURST_ENABLE	EQU 4096 ; Instruction burst enable
WRITE_ALLOCATE		EQU 8192 ; Write allocate 

linewidth	equ 768

		OPT O+,OW-

demo		EQU 0

letsgo		MOVE.W #-1,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W D0,oldvideo
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		LEA my_stack,SP
		BSR Initscreens
		BSR load_dspprog	

		;lea	save_mfp,a0
		;move.b	$fffffa03.w,(a0)+
		;move.b	$fffffa13.w,(a0)+
		;move.b	$fffffa15.w,(a0)+
		;move.b	$fffffa17.w,(a0)+
		
		;Bset.B #7,$FFFFFA03.W	; at END of interrupt
		;MOVE.L #donetrans,$13C.W
		;Bset.B #7,$FFFFFA07.W
		;Bset.B #7,$FFFFFA13.W

		MOVE.W #STMODES+VGA+VERTFLAG+BPS4,-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		
.vbl_lp		
		BSR wait_vbl
		BSR dsp_mess
		CMP.B #$39+$80,$FFFFFC02.W
		BNE.S .vbl_lp

		;lea	save_mfp,a0
		;move.b	(a0)+,$fffffa03.w
		;move.b	(a0)+,$fffffa13.w
		;move.b	(a0)+,$fffffa15.w
		;move.b	(a0)+,$fffffa17.w

		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #$58,-(SP)
		TRAP #14
		ADDQ.L #4,SP
		MOVE.W oldvideo(PC),-(SP)
		MOVE.W #-1,-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 14(SP),SP
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

		CLR -(SP)
		TRAP #1

dsp_mess        move.l	#(8192),d1

		move.w  #%0001100111010101,$FFFF8930.w
                move.w  #%0101110110010011,$FFFF8932.w
		move.b  #$03,$FFFF8920.w ; play 4 track,dac to track 1
		move.b  #$43,$FFFF8921.w ; 16 bit stereo,
		move.b  #1,$FFFF8935.w  ;49.2khz
		move.b  #3,$ffff8936.w ; record 4 track
		
		move.b	#$80+19,$ffffa201.w
		move.l	#pic+34,a1
		move.w	d1,d0
.lpy		
.waith		BTST.B 	#1,$ffffa202.w
		BEQ.S 	.waith
		move.w	(a1)+,$ffffa206.w
		subq	#1,d0
		bne.s	.lpy

		move.w	#$2700,sr
                bset    #7,$FFFF8901.w  
		move.l log_base(pc),a1
		lea 	(a1,d1.l),a2
                jsr     set_dmaaddr
		move.b	#$80+20,$ffffa201.w
		sf donetransflag
		move.w	#16,$ffff8900.w
		move.w	#$2300,sr
		move.l	#100000,d0
lpt		subq.l	#1,d0
		bne.s	lpt
;		not.l	$ffff8240.w
;.wait1		tst.b donetransflag
;		beq.s .wait1
;		not.l	$ffff8240.w

		rts

donetrans	st donetransflag
		rte
donetransflag	DC.W 0
set_dmaaddr:    move.l  A1,D0
                move.b  D0,$FFFF8907.w
		lsr.l #8,d0
                move.b  D0,$FFFF8905.w ; set start of buffer
		lsr.l #8,d0
                move.b  D0,$FFFF8903.w
                move.l  A2,D0
                move.b  D0,$FFFF8913.w
		lsr.l #8,d0
                move.b  D0,$FFFF8911.w ; set end of buffer
		lsr.l #8,d0
                move.b  D0,$FFFF890f.w
                rts

anrte		RTE

save_mfp	dc.l 0
oldvideo	DC.W 0
oldbase		DC.L 0
oldsp		DS.L 1

; Initialise 3 screens.

Initscreens	LEA log_base(PC),A1
	  	MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)
		MOVE.B D0,$FFFF820D.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8203.W
		LSR.L #8,D0
		MOVE.B D0,$FFFF8201.W
		RTS


log_base	DC.L 0

wait_vbl	MOVE.l $466.W,D0
.waitvb		CMP.l $466.W,D0	
		BEQ.S .waitvb
		RTS

; Dsp loader

load_dspprog	MOVE.W #12,-(A7)	; ability
		MOVE.L #((DspProgEnd-DspProg)/3),-(A7)	; no. of dsp words
		PEA DspProg(PC)		; buf
		MOVE.W #$6E,-(A7)	; dsp_execboot
		TRAP #14
		LEA 12(A7),A7
		RTS

DspProg		incbin mess.bin
DspProgEnd
		EVEN

pic		incbin d:\coding.s\misc\messes\ic.pi1

		SECTION BSS

		
screens		DS.B 256
		DS.W 320*256
		DS.L 499
my_stack	DS.L 2
