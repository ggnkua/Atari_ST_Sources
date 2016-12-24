; This is the Second loader.
; It is loaded by the bootcode to a high location
; in memory,it's job is to stop the hackers!!!

; Encode the 2nd loader

Encode	LEA decoder(PC),A0
		MOVE #(512*10)/2-1,D0
		MOVE #$7FA0,D1
encode_lp	EOR.W D1,(A0)+		do encode
		ROR #1,D1
		DBF D0,encode_lp
write		MOVE #10,-(SP)		write 10 sectors
		MOVE #01,-(SP)		side 1
		CLR -(SP)			track 0
		MOVE #01,-(SP)		sector 1
		MOVE #00,-(SP)		boot device
		CLR.L -(SP)			filler
		PEA decoder(PC)		address to write
		MOVE #$09,-(SP)		_flopwr
		TRAP #14			xbios
		LEA 20(SP),SP		correct stack
		CLR -(SP)
		TRAP #1

**************************************************************************
**************************************************************************

; Second loader code starts here
; On entry is at address $7c000
; Jobs are:
; 1.Decode rest of loader(protection)
; 2.Load,decode,depack,and run Jose's intro to intro!
; 3.Load,decode,depack,install reset screen.
; 4.Load,decode,depack loader screen.
; 5.Set loader to load main menu.
; PC relative code for size and flexibility.

decoder
loader2	BRA start
		DC.B "FUUUCCCCCKKKKKK OFFFF!!!!!!"
		DC.B "DEMO CRACKERS, ARE LAME (OVERLANDERS TAKE NOTE!!)"
		DC.B "THE CURRENT BETTINGS ON WHO WILL CRACK THIS ARE:-"
		DC.B "1.EPSILON."
		DC.B "2.RUSS PAYNE.(HAS AN ADVANTAGE...)"
		DC.B "3.EMPIRE."
		DC.B "4.OVERLAMERS"
		DC.B "5.GRIFF(CONSIDERING HE IS WRITING THIS... UNLIKELY!)"
		EVEN		
start		MOVE #$2700,SR
		LEA $80000,SP
		BSR re_init
* Jose's intro:-Track 0,sector 2 and is 13 sectors long.
		BSR Dmaload
		LEA $10000,A0
		BSR decrunch
		LEA $10000,A0
		BSR Relocate
		JSR (a0)
introran	MOVE #$2700,SR
		LEA $80000,SP
		BSR re_init
		LEA load_addr(PC),A0
		MOVE.L #$500,(A0)+		; load address
		MOVE.W #$1,(A0)+			; track
		MOVE.W #$4,(A0)+			; sect no
		MOVE.W #$0,(A0)+			; side
		MOVE.W #21-1,(A0)+		; no of sectors
		BSR Dmaload
		MOVE #$2700,SR
		LEA $80000,SP
		MOVE.L #$500,$42A.W
		MOVE.L #$31415926,$426.W

; Reset installed - now load main intro

		LEA load_addr(PC),A0
		MOVE.L #$2f00,(A0)+		; load address
		MOVE.W #43,(A0)+			; track
		MOVE.W #8,(A0)+			; sect no
		MOVE.W #0,(A0)+			; side
		MOVE.W #51-1,(A0)+		; no of sectors
		BSR Dmaload
		LEA $2F00,A0
		BSR decrunch
		LEA $2F00,A0
		BSR Relocate
		JSR (A0)

; Now load main loader and set it to load main menu.

		MOVE #$2700,SR
		LEA $80000,SP
		BSR ourvects
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W
		CLR.B $FFFFFA0F.W
		CLR.B $FFFFFA11.W
		LEA $FFFF8240.W,A0
		REPT 8
		CLR.L (A0)+
		ENDR
		LEA load_addr(PC),A0
		MOVE.L #$2f00,(A0)+		; load address
		MOVE.W #72,(A0)+			; track
		MOVE.W #4,(A0)+			; sect no
		MOVE.W #0,(A0)+			; side
		MOVE.W #39-1,(A0)+		; no of sectors
		BSR Dmaload
		LEA $2F00,A0
		BSR decrunch
		LEA $2F00,A0
		BSR Relocate
		MOVE.W #116,$400.W
		CLR.W $402.W
		MOVEQ #0,D0
		JMP (A0)

RET		RTE		

* Turn off all shit...

re_init	CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W
		CLR.B $FFFFFA0F.W
		CLR.B $FFFFFA11.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		BSR ourvects
		MOVE.B #$8,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		MOVE.B #$9,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		MOVE.B #$A,$FFFF8800.W
		MOVE.B #0,$FFFF8802.W
		MOVE.B #7,$FFFF8800.W
		MOVE.B #-1,$FFFF8802.W
		LEA $FFFF8240.W,A0
		REPT 8
		CLR.L (A0)+
		ENDR
		LEA $7c000,A0
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVE.L D6,A1
		MOVE.L #($7b500/128)-1,D7
cl_lp		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,cl_lp
		LEA $100000,A0
		MOVE.L #($80000/128)-1,D7
cl1_lp	MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		MOVEM.L D0-D6/A1,-(A0)
		DBF D7,cl1_lp
		RTS

ourvects	LEA $8.W,A0
		LEA bombout(PC),A1
inst1_lp	MOVE.L A1,(A0)+
		CMP.L #$40,A0
		BNE.S inst1_lp
		LEA $60.W,A0
		LEA plainrte(PC),A1
inst2_lp	MOVE.L A1,(A0)+
		CMP.L #$200,A0
		BNE.S inst2_lp 
		RTS

plainrte	RTE

bombout	MOVE #$2700,SR
		MOVE.B #$7,$FFFF8800.W
		MOVE.B #-1,$FFFF8802.W
		MOVE #$700,$FFFF8240.W	
forever	BRA.S forever

* Relocator - A0 points to program to relocate

Relocate	MOVE.L 2(A0),D0
		ADD.L $6(A0),D0
		ADD.L $E(A0),D0
		LEA $1C(A0),A0
		MOVE.L A0,A1
		MOVE.L A0,A2
		MOVE.L A0,D1
		ADD.L D0,A1
		MOVE.L (A1)+,D0
		ADD.L D0,A2
		ADD.L D1,(A2)
		MOVEQ #0,D0
rel_lp	MOVE.B (A1),D0
		CLR.B (A1)+
		TST.B D0
		BEQ.S rel_done
		CMP.B #1,D0
		BEQ.S rel_1
		ADD.L D0,A2
		ADD.L D1,(A2)
		BRA.S rel_lp
rel_1		LEA $FE(A2),A2
		BRA.S rel_lp
rel_done	RTS

*************************************
* Fast DMA Load routine.            *
* By Griff December 1989.           *
* This loader doesnt use the WD1772 *
* read multiple sector command.     *
*************************************

sect_ptr	EQU 10

Dmaload	LEA $FFFF8606.W,A0
		LEA $FFFF8604.W,A1
		LEA $FFFFFA01.W,A2
		BSR seldrive
		BSR seektrack
		BSR read_sects
		RTS

* Select current drive/side
* d0 - 2 drive a
* d0 - 4 drive b

seldrive	MOVE $446.W,D0
		AND #1,D0
		ADDQ #1,D0
		ADD D0,D0
		OR side(PC),D0
		EOR.B #7,D0
select	MOVE.B #$E,$FFFF8800.W
		MOVE.B $FFFF8800.W,D1
		AND.B #$F8,D1
		OR.B D0,D1
		MOVE.B D1,$FFFF8802.W
		RTS

* Deselect current drive
* e.g turn motor off!

deselect	MOVE #$80,(A0)
		NOP
wait		BTST #7,(A1)
		BNE.S wait
		MOVEQ #7,D0
		BRA select

* Place read/write head on the
* track in 'track'.

seektrack	MOVE #$86,(A0)
		MOVE track(PC),D5
		BSR writefdc
		MOVE #$80,(A0)
		MOVEQ #16+4+3,D5
		BSR writefdc
		BSR fdcwait
		TST D5
		BNE seektrack
		RTS

* Read sectors into memory. 

read_sects	LEA load_addr(PC),A3
		MOVE sect_no(PC),D3
		MOVEQ #sect_ptr,D4
		MOVE no_sects(PC),D7
read_lp	MOVE.L (A3),D5
		MOVE.B D5,$FFFF860D.W
		LSR.L #8,D5
		MOVE.B D5,$FFFF860B.W
		LSR.W #8,D5
		MOVE.B D5,$FFFF8609.W


		MOVE #$90,(A0)
		MOVE #$190,(A0)
		MOVE #$90,(A0)
		MOVEq #$01,d5
		BSR writefdc
		MOVE #$84,(A0)
		MOVE D3,d5
		BSR writefdc
		MOVE #$80,(A0)
		MOVE #$88,d5
		BSR writefdc
		BSR fdcwait	
		TST D5
		BNE read_lp
		ADD.L #512,(A3)
		ADDQ #1,D3
		CMP D4,D3
		BGT.S step_in
		DBF D7,read_lp
		RTS
step_in	MOVE #$80,(A0)
		MOVE #64+16+8+4+3,d5
		BSR writefdc			; lets step in!!
		BSR fdcwait				; wait for it...
		TST D5
		BNE step_in				; an error??
		MOVEQ #1,D3
		DBF D7,read_lp
		RTS

* Wait for FDC
 	
fdcwait	MOVEQ #0,D5
		MOVE.L #$50000,D6
fdcwaitloop	BTST.B #5,(A2)
		BEQ.S wait_done
		SUBQ.L #1,D6
		BNE fdcwaitloop 
		MOVEQ #-1,D5
wait_done	RTS

* Write d5 to fdc

writefdc	MOVE.L D6,-(SP)
		MOVE.W SR,-(SP)
		BSR waitf
		MOVE D5,(A1)
		BSR waitf
		MOVE.W (SP)+,SR
		MOVE.L (SP)+,D6
		RTS

waitf		MOVEQ #32,D6
waitflp	DBF D6,waitflp
		RTS

;***************************************************************************
; Unpacking source for Pack-Ice Version 2.1
; a0: Pointer on packed Data

decrunch:	movem.l d0-a6,-(sp)
		addq.l #4,a0
		move.l (a0)+,d0
		lea -8(a0,d0.l),a5
		move.l (a0)+,(sp)
		lea 108(a0),a4
		movea.l a4,a6
		adda.l (sp),a6
		movea.l a6,a3
		movea.l a6,a1			; save 120 bytes
		lea ice2_21+120(pc),a2		; at the end of the
		moveq	#$77,d0			; unpacked data
ice2_00:	move.b -(a1),-(a2)
		dbra d0,ice2_00
		bsr ice2_0c
		bsr.s	ice2_08

ice2_04:	move.l (sp),d0			; move all data to
		lea -120(a4),a1			; 120 bytes lower
ice2_05:	move.b	(a4)+,(a1)+
		dbra	d0,ice2_05
		subi.l	#$010000,d0
		bpl.s	ice2_05
		moveq	#$77,d0			; restore saved data
		lea	ice2_21+120(pc),a2
ice2_06:	move.b	-(a2),-(a3)
		dbra	d0,ice2_06
ice2_07:	movem.l (sp)+,d0-a6
		rts
ice2_08:	bsr.s	ice2_10
		bcc.s	ice2_0b
		moveq	#0,d1
		bsr.s	ice2_10
		bcc.s	ice2_0a
		lea	ice2_1e(pc),a1
		moveq	#4,d3
ice2_09:	move.l	-(a1),d0
		bsr.s	ice2_13
		swap	d0
		cmp.w	d0,d1
		dbne	d3,ice2_09
		add.l	20(a1),d1
ice2_0a:	move.b	-(a5),-(a6)
		dbra	d1,ice2_0a
ice2_0b:	cmpa.l	a4,a6
		bgt.s	ice2_16
		rts
ice2_0c:	moveq	#3,d0
ice2_0d:	move.b	-(a5),d7
		ror.l	#8,d7
		dbra	d0,ice2_0d
		rts
ice2_0e:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_0f
		move.l	-(a5),d7
		addx.l	d7,d7
		bra.s	ice2_15
ice2_0f:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		bra.s	ice2_15
ice2_10:	add.l	d7,d7
		beq.s	ice2_11
		rts
ice2_11:	move.w	a5,d7
		btst	#0,d7
		bne.s	ice2_12
		move.l	-(a5),d7
		addx.l	d7,d7
		rts
ice2_12:	move.l	-5(a5),d7
		lsl.l	#8,d7
		move.b	-(a5),d7
		subq.l	#3,a5
		add.l	d7,d7
		bset	#0,d7
		rts
ice2_13:	moveq	#0,d1
ice2_14:	add.l	d7,d7
		beq.s	ice2_0e
ice2_15:	addx.w	d1,d1
		dbra	d0,ice2_14
		rts
ice2_16:	lea	ice2_1f(pc),a1
		moveq	#3,d2
ice2_17:	bsr.s	ice2_10
		dbcc	d2,ice2_17
		moveq	#0,d4
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bmi.s	ice2_18
		bsr.s	ice2_13
ice2_18:	move.b	6(a1,d2.w),d4
		add.w	d1,d4
		beq.s	ice2_1a
		lea	ice2_20(pc),a1
		moveq	#1,d2
ice2_19:	bsr.s	ice2_10
		dbcc	d2,ice2_19
		moveq	#0,d1
		move.b	1(a1,d2.w),d0
		ext.w	d0
		bsr.s	ice2_13
		add.w	d2,d2
		add.w	6(a1,d2.w),d1
		bra.s	ice2_1c
ice2_1a:	moveq	#0,d1
		moveq	#5,d0
		moveq	#0,d2
		bsr.s	ice2_10
		bcc.s	ice2_1b
		moveq	#8,d0
		moveq	#$40,d2
ice2_1b:	bsr.s	ice2_13
		add.w	d2,d1
ice2_1c:	lea	2(a6,d4.w),a1
		adda.w	d1,a1
		move.b	-(a1),-(a6)
ice2_1d:	move.b	-(a1),-(a6)
		dbra	d4,ice2_1d
		bra	ice2_08
		dc.b $7f,$ff,$00,$0e,$00,$ff,$00,$07
		dc.b $00,$07,$00,$02,$00,$03,$00,$01
		dc.b $00,$03,$00,$01
ice2_1e:	dc.b $00,$00,$01,$0d,$00,$00,$00,$0e
		dc.b $00,$00,$00,$07,$00,$00,$00,$04
		dc.b $00,$00,$00,$01
ice2_1f:	dc.b $09,$01,$00,$ff,$ff,$08,$04,$02
		dc.b $01,$00
ice2_20:	dc.b $0b,$04,$07,$00,$01,$20,$00,$00
		dc.b $00,$20
ice2_21:	ds.w 60			; free space (can be put in BSS)
		even
endreset

load_addr	DC.L $10000		address to load into
track		DC.W 0		start track
sect_no	DC.W 2		sector within start track
side		DC.W 0		side to load from
no_sects	DC.W 12-1 		no of sectors to load
		ds.w 100