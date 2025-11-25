;************************************************
;						*
;	EEPROM Write & Read Primitives		*
;						*
;************************************************
;
;	Hi-Score on-board-cartridge EEPROM primitives 
;	for use by Jaguar game cartridge developers.
;
;	128 bytes (accessable as 64 words) of non-volatile
;	memory are available on Jaguar game cartridges to
;	preserve Hi-scores or other game status.
;	Data is retained for up to 10 years, and a minimum
;       of 10,000 read/write cycles is assured, according to
;	product literature. 
;
;
;
;
;
;	 Programmer: Dave Staugas
;		     Atari, Sunnyvale
;		     [408] 745-8802
;
;	Last Update: 24-Sept-93
;
;
;   Equates needed that may already be defined in the JAGUAR.INC file..
;
JOY1		equ	$f14000		;this we'll use as our I/O base address
GPIO_0		equ	$f14800		;General purpose I/O #0
GPIO_1		equ	$f15000		;General purpose I/O #1
;
;   Equates derived from the above
;    to allow indirect with 16-bit displacement addressing
;
GPIO_0of	equ	GPIO_0-JOY1	;offset to GPIO_0 (when addr reg Ax -> JOY1) 
GPIO_1of	equ	GPIO_1-JOY1	;offset to GPIO_1 (when addr reg Ax -> JOY1) 
;
;   Commands specific to the National Semiconductor NM93C14
;
;  9-bit commands..
;		 876543210
eREAD	equ	%110000000		;read from EEPROM
eEWEN	equ	%100110000		;Erase/write Enable
eWRITE	equ	%101000000		;Write selected register
eEWDS	equ	%100000000		;Erase/Write disable (default)
;
;
;  DO (data out)	- is read on bit0 of JOY1
;  DI (data in) 	- is written on bit0 of GPIO_0
;  CS (chip select)	- is pulsed low by any access to GPIO_1
;
;
;*****************************************************************
;
;  Write a word to EEPROM
;
;  entry: d0.w = data to be written
;	  d1.w = least signifigant 6 bits specify write address (0-63)  
;
;   exit: all preserved
;
;
eewrite::
	Tst.w	Eeprom_Duff
	Bne	Eeprom_Duffed
	movem.l	a0/d0-d4,-(sp)
	lea	JOY1,a0		;set ptr to EEPROM i/o addresses
;
	tst.w	GPIO_1of(a0)	;strobe ChipSelect
;
	move.w	#eEWEN,d2	;erase/write enable command
	bsr	out9bits	;send it to EEPROM
;	
	tst.w	GPIO_1of(a0)	;strobe ChipSelect
;
	andi.w	#$3f,d1		;force write addr to be legit (0-63)
	ori.w	#eWRITE,d1	;form WRITE command
	move.w	d1,d2
	bsr	out9bits	;send it to EEPROM
;
	move.w	d0,d2		;get 16-bit data word to send
	bsr	out16bit	;  & send it
;
	tst.w	GPIO_1of(a0)	;strobe ChipSelect
;
	nop			;1 us required after CS for status valid
	nop
	move.w	#1,d2
	Moveq	#0,d4
	Move.w	#$ffff,-(sp)
wrwait:
	Subq.w	#1,(sp)
	Beq.s	.Exit_Lop	
	move.w	(a0),d3		;wait until write is complete
	and.w	d2,d3
	beq	wrwait	
	Bra	.No_Time_Out
;	
.Exit_Lop	
	Moveq	#-1,d4
.No_Time_Out
	Addq.l	#2,sp
	move.w	#eEWDS,d2	;get erase/write disable command
	bsr	out9bits	;send it
;
	tst.w	GPIO_1of(a0)	;strobe ChipSelect
;
	Tst.w	d4
	Sne	Eeprom_Duff
	movem.l	(sp)+,a0/d0-d4
Eeprom_Duffed
	rts			;we're done (returns negative if cannot write!)
;
;
;

Eeprom_Duff
	Dc.w	0


;******************************************************
;
;
;  Read a word from EEPROM
;
;  entry:  d1.w = least signifigant 6 bits specify read address (0-63)  
;
;   exit:  d0.w = data as read from EEPROM
;		  all other registers preserved
;
eeread::
	movem.l	a0/d1-d4,-(sp)
	lea	JOY1,a0		;set ptr to EEPROM i/o address
;
	tst.w	GPIO_1of(a0)	;strobe ChipSelect
;
	andi.w	#$3f,d1		;force legit read addr
	ori.w	#eREAD,d1
	move.w	d1,d2
	bsr	out9bits
;
	moveq	#0,d0
	moveq	#15,d3		;pick up 17 bits (1st is dummy)
inlp:	
	tst.w	GPIO_0of(a0)
	nop
	move.w	(a0),d1
	lsr.w	#1,d1
	addx.w	d0,d0
	nop
	nop
	nop
	nop
	nop
	nop
	dbra	d3,inlp
;
	movem.l	(sp)+,a0/d1-d4
	rts
;
;
;
;**************************************************************
;
;  Subordinate Routines needed by "eewrite"
;
;  Serial data sent to device is written to DI, bit0 of GPIO_0
;
; entry:
;  a0 -> JOY1
;  d2.w = 16-bit data word to write
;
; exit:
;  d2.w, d3.l destroyed
;
out16bit:
	rol.w	#1,d2		;align 1st serial data bit (bit15) to bit0
	moveq	#15,d3		;send 16 bits
	bra.s	out9lp
;
; entry:
;  a0 -> JOY1
;  d2.w = 9-bit command to write
;
out9bits:
	rol.w	#8,d2		;align 1st serial data bit (bit8) to bit0
	moveq	#8,d3		;send 9
out9lp:
	move.w	d2,GPIO_0of(a0)		;write next bit
	nop
	nop
	nop			;delay next write
	nop
	nop
	nop
	rol.w	#1,d2		;adjust bit0 for next datum
	dbra	d3,out9lp	;go for all 9 or all 16
	rts
;
;
