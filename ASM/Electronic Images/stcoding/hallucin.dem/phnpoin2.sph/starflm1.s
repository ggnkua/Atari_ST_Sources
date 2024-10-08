; Lots of STARS 3D Starfield!
; Rotation using multiplication table.
; By Martin Griffiths Dec 1992.

no_points	EQU 330
;no_points	EQU 590

demo		EQU 0				; 0=gem 1=from DMA disk
	
letsgo		
		IFEQ demo
		MOVE.W #4,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		MOVE.W D0,oldres
		MOVE.W #2,-(SP)
		TRAP #14		
		ADDQ.L #2,SP	
		MOVE.L D0,oldbase
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVE.B #0,$FFFF8E21.W

		ELSEIF

		ORG $10000
		MOVE.L SP,oldsp

		ENDC

		LEA stack,sp
		BSR MakeBigMatLook
		BSR Random_gen
		BSR makeperstab
		BSR Init_Crds
		IFNE demo
		JSR $508
		ENDC
		BSR Initscreens
		BSR set_ints
		BSR WaitVbl
		BSR WaitVbl
		MOVE.W #no_points,obj
.lp		BSR Swap_Screens
		MOVE.W #$100,$FFFF8240.W
		BSR WaitVbl
		BSR Clear_Old
		BSR Calc_N_Draw
		CMP.B #$39+$80,$FFFFFC02.W
		BNE.S .lp

		BSR rest_ints		

		IFEQ demo
		MOVE.B #$FF,$FFFF8E21.W
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		MOVE.L oldsp(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.W oldres(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.L oldbase(PC),-(SP)
		MOVE.W #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR -(SP)
		TRAP #1
oldbase		DS.L 1
oldres		DS.W 1

		ELSEIF

		MOVE.L oldsp(PC),SP
		RTS
		ENDC

saved7		DC.W 0

oldsp		DC.L 0

; General Routs...

; Initialisation interrupts.(saving old)

set_ints	MOVE #$2700,SR
		LEA old_stuff(pc),A0
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.B #1,$FFFFFA07.W	; enable hbl.
		MOVE.B #0,$FFFFFA09.W
		MOVE.B #1,$FFFFFA13.W
		MOVE.B #0,$FFFFFA15.W
		CLR.B $FFFFFA1B.W
		BCLR.B #3,$FFFFFA17.W
		LEA my_vbl(pc),A1
		MOVE.L A1,$70.w
		LEA SuperUser(PC),A1
		MOVE.L A1,$B0.W
		BSR flush
		MOVE.W #$2300,SR
		RTS

SuperUser	BCHG #13-8,(SP)
		RTE

; Restore old interrupts.

rest_ints	MOVE.W #$2700,sr
		LEA old_stuff(pc),a0
		MOVE.L (a0)+,$70.w
		MOVE.L (a0)+,$B0.w
		MOVE.L (a0)+,$120.w
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		BSR flush
		MOVE.W #$2300,sr
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

vbl_timer	DC.W 0
old_stuff	DS.L 15

log_base	DC.L 0
phy_base	DC.L 0
frame_switch	DC.W 0

; Wait for 1 vbl

WaitVbl		MOVE vbl_timer(PC),D0
.wait_vb	CMP vbl_timer(PC),D0
		BEQ.S .wait_vb
		RTS

; Swap LOG/PHYS screen ptrs and set the H/WARE reg.

Swap_Screens	LEA log_base(pc),A0
		MOVEM.L (A0)+,D0-D1
		NOT (A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Allocate memory for screens and clear them.

Initscreens	LEA log_base(PC),A1
		MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)+
		BSR cls
		ADD.L #42240,D0
		MOVE.L D0,(A1)+
		BSR cls
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Clear screen -> d0
		
cls		MOVE.L D0,A0
		MOVEQ #0,D2
		MOVE #(42240/16)-1,D1
.lp		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		DBF D1,.lp
		RTS

; Make the X1*X2 (.B) lookup table.

MakeBigMatLook	LEA bigtable,A0
		MOVE #-255,D0
		MOVE.W #512-1,D7
.lp1		MOVEQ #-127,D1
		MOVEQ #64-1,D6
.lp2		
		REPT 4
		MOVE.W D0,D2
		MULS D1,D2
		MOVE.W D2,(A0)+
		ADDQ #1,D1
		ENDR
		DBF D6,.lp2
		ADDQ #1,D0
		DBF D7,.lp1
		RTS

; Rout to generate initial Random star positions.

Random_gen	LEA XYZ_spCRDS(PC),A3
		MOVE #no_points-1,D7
f_rand_x	BSR Rand
		DIVU #510,D0
		SWAP D0
		SUB #255,D0
		ASL.W #7,D0
		MOVE D0,(A3)+
f_rand_y	BSR Rand
		DIVU #510,D0
		SWAP D0
		SUB #255,D0
		ASL.W #7,D0
		MOVE D0,(A3)+
f_rand_z	BSR Rand
		DIVU #510,D0
		SWAP D0
		SUB #255,D0
		ASL.W #7,D0
		MOVE D0,(A3)+
		DBF D7,f_rand_x
		RTS

; Random number generator. Returns with number in D0.
; This is a tad slooow... it takes about 650 cycles.

Rand		movem.l	d1-d2/d7,-(sp)
		move.l	rndseed(pc),d1
		move.l	#2147001325,d2
		bsr	mul		; 32 bit multiply
		add.l d6,d7
		move.l d7,d0
		addi.l	#715136305,d0
		move.l	d0,rndseed
		swap d0
		clr.w d0
		swap d0
		movem.l	(sp)+,d1-d2/d7
		rts

rndseed 	dc.l $446457456

; 32 bit multiply.  <540 cycles MAX.  Faster than the 'other' methods.
; Multiply D1 by D2; 64-bit result in D6 & D7.  D6 is MSL and D7 LSL.
; Returns with most significant in D6 and least significant in D7.

mul		move.l	d1,d3
		move.l	d2,d4
		swap	d3
		swap	d4
		move.w	d1,d7
		mulu	d2,d7
		move.w	d3,d6
		mulu	d4,d6
		mulu	d1,d4
		mulu	d2,d3
		add.l	d3,d4
		move.w	d4,d3
		swap	d3
		clr.w	d3
		clr.w	d4
		addx.w	d3,d4
		swap	d4
		add.l	d3,d7
		addx.l	d4,d6
		tst.l	d1
		bpl.s	lmul1
		sub.l	d2,d6
lmul1:		tst.l	d2
		bpl.s	lmul2
		sub.l	d1,d6
lmul2:		rts


; Convert X,Y,Z co-ords to addr' for matrix lookup.

Init_Crds	LEA XYZ_spCRDS(PC),A0
		LEA XYZ_spCRDSADDR(PC),A1
		LEA bigtable+(512*255)+256,A2	; big MAT lookup
		MOVE.W #no_points-1,D3
.lp		MOVEM.W (A0)+,D0-D2
		EXT.L D0
		EXT.L D1
		EXT.L D2
		ASL.L #2,D0
		ASL.L #2,D1
		ASL.L #2,D2
		ADD.L A2,D0
		ADD.L A2,D1
		ADD.L A2,D2
		MOVE.L D0,(A1)+
		MOVE.L D1,(A1)+
		MOVE.L D2,(A1)+
		DBF D3,.lp
		RTS

; Make the perspective table.

makeperstab	LEA perstab,A0
		MOVEQ #0,D0
		MOVE.L #70*(32768),D7
.smptlp		MOVE.W D0,D2
		EXT.L D2
		DIVU #1500,D2
		AND.W #$FFFE,D2
		CMP.W #6,D2
		BLE.S .ok
		MOVEQ #6,D2
.ok		MOVE.W D2,(A0)+
		MOVE.W D0,D1
		MOVE.L D7,D6
		ADD #71,D1
		DIVS D1,D6
		MOVE.W D6,(A0)+
		ADDQ #1,D0
		CMP #$4000,D0
		BNE.S .smptlp
		RTS

; Little old vbl.

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFFF8240.W
		IFNE demo
		JSR $504
		ENDC
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE
pal 		DC.L $00000777
		DC.L $05550555
		DC.L $03330333
		DC.L $03330333
		DC.L $01110111
		DC.L $01110111
		DC.L $01110111
		DC.L $01110111

; Clear those points!

Clear_Old	MOVEQ #0,D0
		TST frame_switch
		BNE Clear_Old2

Clear_Old1	MOVE.L log_base(PC),A0
saveold1	
		MOVE.B D0,2(A0)
		DS.L no_points

Clear_Old2	MOVE.L log_base(PC),A0
saveold2	
		MOVE.B D0,2(A0)
		DS.L no_points
		RTS

; Translate 'n' draw.

Calc_N_Draw	LEA rseqdata(PC),A3
		SUBQ #1,seq_timer(A3)
		BNE.S .nonew
		MOVE.L seq_ptr(A3),A1
		TST (A1)
		BPL.S .notendseq
		MOVE.L restart_ptr(A3),A1 
.notendseq	MOVE.W (A1)+,seq_timer(A3)
		MOVE.W (A1)+,addangx(A3)
		MOVE.W (A1)+,addangy(A3)
		MOVE.W (A1)+,addangz(A3)	; store new incs..
		MOVE.W (A1)+,.zspeed+2
		MOVE.L A1,seq_ptr(A3)
.nonew		LEA angles(pc),a5
		LEA trig_tab,A0			; sine table
		LEA 512(A0),A2			; cosine table
		MOVEM.W (A5),D5-D7    		; get current x,y,z ang	
		ADD addangx(A3),D5
		ADD addangy(A3),D6		; add increments
		ADD addangz(A3),D7
		AND #$7FE,D5
		AND #$7FE,D6
		AND #$7FE,D7
		MOVEM.W D5-D7,(A5)   	
		MOVE (A0,D5),D0			;sin(xd)
		MOVE (A2,D5),D1			;cos(xd)
		MOVE (A0,D6),D2			;sin(yd)
		MOVE (A2,D6),D3			;cos(yd)
		MOVE (A0,D7),D4			;sin(zd)
		MOVE (A2,D7),D5			;cos(zd)
		LEA smmat_tmp(PC),A1
* sinz*sinx(used twice) - A3
		MOVE D0,D6			sinx
		MULS D4,D6			sinz*sinx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A3
* sinz*cosx(used twice) - A4
		MOVE D1,D6			cosx
		MULS D4,D6			sinz*cosx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6			cosy
		MULS D1,D6			cosy*cosx
		MOVE A3,D7			sinz*sinx
		MULS D2,D7			siny*sinz*sinx					
		SUB.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)+
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6			siny*cosx
		MOVE A3,D7			sinz*sinx
		MULS D3,D7			cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)+
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			cosz
		MULS D0,D6			cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6				-cosz*sinx
		MOVE D6,(A1)+
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			siny
		MULS D5,D6			siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6				-siny*cosz
		MOVE D6,(A1)+
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			cosy
		MULS D5,D6			cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,(A1)+
* Matrix(3,2) sinz 
		MOVE D4,(A1)+
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			cosy
		MULS D0,D6			cosy*sinx
		MOVE A4,D7			sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6				siny*(sinz*cosx)
		MOVE D6,(A1)+
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,(A1)+
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5				cosz*cosx
		MOVE D5,(A1)+

.go_for_it	LEA smmat_tmp(PC),A5
		LEA .MO1_1+2(PC),A6
		MOVEM.W	(A5)+,D0-D2
		ASR.W #8,D0
		ADD.W D0,D0
		ASR.W #8,D1
		ADD.W D1,D1
		ASR.W #8,D2
		ADD.W D2,D2
		MOVE.W D0,.MO1_1-.MO1_1(A6)
		MOVE.W D1,.MO1_2-.MO1_1(A6)
		MOVE.W D2,.MO1_3-.MO1_1(A6)
		MOVEM.W	(A5)+,D0-D2
		ASR.W #8,D0
		ADD.W D0,D0
		ASR.W #8,D1
		ADD.W D1,D1
		ASR.W #8,D2
		ADD.W D2,D2
		MOVE.W D0,.MO1_4-.MO1_1(A6)
		MOVE.W D1,.MO1_5-.MO1_1(A6)
		MOVE.W D2,.MO1_6-.MO1_1(A6)
		MOVEM.W	(A5)+,D0-D2
		ASR.W #8,D0
		ADD.W D0,D0
		ASR.W #8,D1
		ADD.W D1,D1
		ASR.W #8,D2
		ADD.W D2,D2
		MOVE.W D0,.MO1_7-.MO1_1(A6)
		MOVE.W D1,.MO1_8-.MO1_1(A6)
		MOVE.W D2,.MO1_9-.MO1_1(A6)
		LEA obj(PC),A1
		MOVE (A1)+,D7
		SUBQ #1,D7
		BMI .doneplot

		TRAP #12

		MOVE.L log_base(PC),A6
		LEA saveold1(PC),A0
		TST.W frame_switch
		BEQ.S .cse2
		LEA saveold2(PC),A0
.cse2		MOVE.L (A0),D6
		MOVE.L #bigtable,D0
		MOVEQ #-4,D1
		LEA.L mul160,A5
		LEA.L perstab+($2000*4),A7
		
.trans_lp	MOVE.L	(A1)+,A2
		MOVE.L	(A1)+,A3
		MOVE.L	(A1),A4
.zspeed		LEA -512*3(A4),A4
		CMP.L D0,A4
		BGE.S .ok
		ADD.L #(512*512),A4
.ok		MOVE.L A4,(A1)+
.MO1_1		MOVE.W $C(A2),D5
.MO1_2		ADD.W -$4C(A3),D5
.MO1_3		ADD.W -$64(A4),D5
.MO1_4		MOVE.W -$75(A2),D3
.MO1_5		ADD.W $1C(A3),D3
.MO1_6		ADD.W -$27(A4),D3
.MO1_7		MOVE.W $2C(A2),D4
.MO1_8		ADD.W $60(A3),D4
.MO1_9		ADD.W -$44(A4),D4
		AND.W D1,D5
		MOVE.L (A7,D5),D5
		
		MULS d5,d3
		MULS d5,d4
		ADD.L D3,D3
		ADD.L D4,D4
		SWAP d3
		SWAP d4
		SWAP d5
		ADD.W #160,d3
		ADD.W #100,d4
		CMP.W #319,d3
		BCC.S .nop
		CMP.W #199,d4
		BCC.S .nop
.plot		ADD.W d4,d4
		CLR.W D6
		MOVE.B xoffs(PC,d3),d6
		ADD.W (a5,d4),d6
		ADD.W D5,D6
        	MOVE.L D6,(a0)+		;12
		BSET.B d3,(a6,d6.w)		;16
.nop		DBF D7,.trans_lp
		MOVE.W #$4E75,(A0)+
		TRAP #12
.doneplot	RTS

xoffs:
xoff            SET 153
		REPT 20
		DC.B xoff,xoff,xoff,xoff,xoff,xoff,xoff,xoff
xoff		SET xoff-1 		
		DC.B xoff,xoff,xoff,xoff,xoff,xoff,xoff,xoff
xoff		SET xoff-7 		
                ENDR
mul160		
i		set 0
		rept 50
		dc.w i,i+160,i+320,i+480
i		set i+640
		endr

; Sequence data for ball starfield
		
		RSRESET

seq_timer	RS.W 1
seq_ptr		RS.L 1
addangx		RS.W 1
addangy		RS.W 1
addangz		RS.W 1
restart_ptr	RS.L 1

rseqdata	DC.W 1
		DC.L rsequence 
		DC.W 0,0,0
		DC.L restart

rsequence	
restart		DC.W 400,0,0,0,-512*3
		DC.W 128,2,2,2,-512*3
		DC.W 128,4,4,2,-512*3
		DC.W 128,6,6,4,-512*3
		DC.W 128,4,6,4,-512*3
		DC.W 128,2,6,2,-512*3
		DC.W 128,4,4,4,-512*3
		DC.W 128,2,4,2,-512*3
		DC.W 128,2,4,0,-512*3
		DC.W -1

trig_tab	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 
		dc.w	$7FFF,$7FFE,$7FFC,$7FF9,$7FF5,$7FEF,$7FE8,$7FE0 
		dc.w	$7FD7,$7FCD,$7FC1,$7FB4,$7FA6,$7F96,$7F86,$7F74 
		dc.w	$7F61,$7F4C,$7F37,$7F20,$7F08,$7EEF,$7ED4,$7EB9 
		dc.w	$7E9C,$7E7E,$7E5E,$7E3E,$7E1C,$7DF9,$7DD5,$7DB0 
		dc.w	$7D89,$7D61,$7D38,$7D0E,$7CE2,$7CB6,$7C88,$7C59 
		dc.w	$7C29,$7BF7,$7BC4,$7B91,$7B5C,$7B25,$7AEE,$7AB5 
		dc.w	$7A7C,$7A41,$7A04,$79C7,$7989,$7949,$7908,$78C6 
		dc.w	$7883,$783F,$77F9,$77B3,$776B,$7722,$76D8,$768D 
		dc.w	$7640,$75F3,$75A4,$7554,$7503,$74B1,$745E,$740A 
		dc.w	$73B5,$735E,$7306,$72AE,$7254,$71F9,$719D,$7140 
		dc.w	$70E1,$7082,$7022,$6FC0,$6F5E,$6EFA,$6E95,$6E30 
		dc.w	$6DC9,$6D61,$6CF8,$6C8E,$6C23,$6BB7,$6B4A,$6ADB 
		dc.w	$6A6C,$69FC,$698B,$6919,$68A5,$6831,$67BC,$6745 
		dc.w	$66CE,$6656,$65DD,$6562,$64E7,$646B,$63EE,$6370 
		dc.w	$62F1,$6271,$61F0,$616E,$60EB,$6067,$5FE2,$5F5D 
		dc.w	$5ED6,$5E4F,$5DC6,$5D3D,$5CB3,$5C28,$5B9C,$5B0F 
		dc.w	$5A81,$59F3,$5963,$58D3,$5842,$57B0,$571D,$5689 
		dc.w	$55F4,$555F,$54C9,$5432,$539A,$5301,$5268,$51CE 
		dc.w	$5133,$5097,$4FFA,$4F5D,$4EBF,$4E20,$4D80,$4CE0 
		dc.w	$4C3F,$4B9D,$4AFA,$4A57,$49B3,$490E,$4869,$47C3 
		dc.w	$471C,$4674,$45CC,$4523,$447A,$43D0,$4325,$4279 
		dc.w	$41CD,$4120,$4073,$3FC5,$3F16,$3E67,$3DB7,$3D07 
		dc.w	$3C56,$3BA4,$3AF2,$3A3F,$398C,$38D8,$3824,$376F 
		dc.w	$36B9,$3603,$354D,$3496,$33DE,$3326,$326D,$31B4 
		dc.w	$30FB,$3041,$2F86,$2ECC,$2E10,$2D54,$2C98,$2BDB 
		dc.w	$2B1E,$2A61,$29A3,$28E5,$2826,$2767,$26A7,$25E7 
		dc.w	$2527,$2467,$23A6,$22E4,$2223,$2161,$209F,$1FDC 
		dc.w	$1F19,$1E56,$1D93,$1CCF,$1C0B,$1B46,$1A82,$19BD 
		dc.w	$18F8,$1833,$176D,$16A7,$15E1,$151B,$1455,$138E 
		dc.w	$12C7,$1200,$1139,$1072,$0FAB,$0EE3,$0E1B,$0D53 
		dc.w	$0C8B,$0BC3,$0AFB,$0A32,$096A,$08A1,$07D9,$0710 
		dc.w	$0647,$057E,$04B6,$03ED,$0324,$025B,$0192,$00C9 
		dc.w	$0000,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82 
		dc.w	$F9B9,$F8F0,$F827,$F75F,$F696,$F5CE,$F505,$F43D 
		dc.w	$F375,$F2AD,$F1E5,$F11D,$F055,$EF8E,$EEC7,$EE00 
		dc.w	$ED39,$EC72,$EBAB,$EAE5,$EA1F,$E959,$E893,$E7CD 
		dc.w	$E708,$E643,$E57E,$E4BA,$E3F5,$E331,$E26D,$E1AA 
		dc.w	$E0E7,$E024,$DF61,$DE9F,$DDDD,$DD1C,$DC5A,$DB99 
		dc.w	$DAD9,$DA19,$D959,$D899,$D7DA,$D71B,$D65D,$D59F 
		dc.w	$D4E2,$D425,$D368,$D2AC,$D1F0,$D134,$D07A,$CFBF 
		dc.w	$CF05,$CE4C,$CD93,$CCDA,$CC22,$CB6A,$CAB3,$C9FD 
		dc.w	$C947,$C891,$C7DC,$C728,$C674,$C5C1,$C50E,$C45C 
		dc.w	$C3AA,$C2F9,$C249,$C199,$C0EA,$C03B,$BF8D,$BEE0 
		dc.w	$BE33,$BD87,$BCDB,$BC30,$BB86,$BADD,$BA34,$B98C 
		dc.w	$B8E4,$B83D,$B797,$B6F2,$B64D,$B5A9,$B506,$B463 
		dc.w	$B3C1,$B320,$B280,$B1E0,$B141,$B0A3,$B006,$AF69 
		dc.w	$AECD,$AE32,$AD98,$ACFF,$AC66,$ABCE,$AB37,$AAA1 
		dc.w	$AA0C,$A977,$A8E3,$A850,$A7BE,$A72D,$A69D,$A60D 
		dc.w	$A57F,$A4F1,$A464,$A3D8,$A34D,$A2C3,$A23A,$A1B1 
		dc.w	$A12A,$A0A3,$A01E,$9F99,$9F15,$9E92,$9E10,$9D8F 
		dc.w	$9D0F,$9C90,$9C12,$9B95,$9B19,$9A9E,$9A23,$99AA 
		dc.w	$9932,$98BB,$9844,$97CF,$975B,$96E7,$9675,$9604 
		dc.w	$9594,$9525,$94B6,$9449,$93DD,$9372,$9308,$929F 
		dc.w	$9237,$91D0,$916B,$9106,$90A2,$9040,$8FDE,$8F7E 
		dc.w	$8F1F,$8EC0,$8E63,$8E07,$8DAC,$8D52,$8CFA,$8CA2 
		dc.w	$8C4B,$8BF6,$8BA2,$8B4F,$8AFD,$8AAC,$8A5C,$8A0D 
		dc.w	$89C0,$8973,$8928,$88DE,$8895,$884D,$8807,$87C1 
		dc.w	$877D,$873A,$86F8,$86B7,$8677,$8639,$85FC,$85BF 
		dc.w	$8584,$854B,$8512,$84DB,$84A4,$846F,$843C,$8409 
		dc.w	$83D7,$83A7,$8378,$834A,$831E,$82F2,$82C8,$829F 
		dc.w	$8277,$8250,$822B,$8207,$81E4,$81C2,$81A2,$8182 
		dc.w	$8164,$8147,$812C,$8111,$80F8,$80E0,$80C9,$80B4 
		dc.w	$809F,$808C,$807A,$806A,$805A,$804C,$803F,$8033 
		dc.w	$8029,$8020,$8018,$8011,$800B,$8007,$8004,$8002 
		dc.w	$8001,$8002,$8004,$8007,$800B,$8011,$8018,$8020 
		dc.w	$8029,$8033,$803F,$804C,$805A,$806A,$807A,$808C 
		dc.w	$809F,$80B4,$80C9,$80E0,$80F8,$8111,$812C,$8147 
		dc.w	$8164,$8182,$81A2,$81C2,$81E4,$8207,$822B,$8250 
		dc.w	$8277,$829F,$82C8,$82F2,$831E,$834A,$8378,$83A7 
		dc.w	$83D7,$8409,$843C,$846F,$84A4,$84DB,$8512,$854B 
		dc.w	$8584,$85BF,$85FC,$8639,$8677,$86B7,$86F8,$873A 
		dc.w	$877D,$87C1,$8807,$884D,$8895,$88DE,$8928,$8973 
		dc.w	$89C0,$8A0D,$8A5C,$8AAC,$8AFD,$8B4F,$8BA2,$8BF6 
		dc.w	$8C4B,$8CA2,$8CFA,$8D52,$8DAC,$8E07,$8E63,$8EC0 
		dc.w	$8F1F,$8F7E,$8FDE,$9040,$90A2,$9106,$916B,$91D0 
		dc.w	$9237,$929F,$9308,$9372,$93DD,$9449,$94B6,$9525 
		dc.w	$9594,$9604,$9675,$96E7,$975B,$97CF,$9844,$98BB 
		dc.w	$9932,$99AA,$9A23,$9A9E,$9B19,$9B95,$9C12,$9C90 
		dc.w	$9D0F,$9D8F,$9E10,$9E92,$9F15,$9F99,$A01E,$A0A3 
		dc.w	$A12A,$A1B1,$A23A,$A2C3,$A34D,$A3D8,$A464,$A4F1 
		dc.w	$A57F,$A60D,$A69D,$A72D,$A7BE,$A850,$A8E3,$A977 
		dc.w	$AA0C,$AAA1,$AB37,$ABCE,$AC66,$ACFF,$AD98,$AE32 
		dc.w	$AECD,$AF69,$B006,$B0A3,$B141,$B1E0,$B280,$B320 
		dc.w	$B3C1,$B463,$B506,$B5A9,$B64D,$B6F2,$B797,$B83D 
		dc.w	$B8E4,$B98C,$BA34,$BADD,$BB86,$BC30,$BCDB,$BD87 
		dc.w	$BE33,$BEE0,$BF8D,$C03B,$C0EA,$C199,$C249,$C2F9 
		dc.w	$C3AA,$C45C,$C50E,$C5C1,$C674,$C728,$C7DC,$C891 
		dc.w	$C947,$C9FD,$CAB3,$CB6A,$CC22,$CCDA,$CD93,$CE4C 
		dc.w	$CF05,$CFBF,$D07A,$D134,$D1F0,$D2AC,$D368,$D425 
		dc.w	$D4E2,$D59F,$D65D,$D71B,$D7DA,$D899,$D959,$DA19 
		dc.w	$DAD9,$DB99,$DC5A,$DD1C,$DDDD,$DE9F,$DF61,$E024 
		dc.w	$E0E7,$E1AA,$E26D,$E331,$E3F5,$E4BA,$E57E,$E643 
		dc.w	$E708,$E7CD,$E893,$E959,$EA1F,$EAE5,$EBAB,$EC72 
		dc.w	$ED39,$EE00,$EEC7,$EF8E,$F055,$F11D,$F1E5,$F2AD 
		dc.w	$F375,$F43D,$F505,$F5CE,$F696,$F75F,$F827,$F8F0 
		dc.w	$F9B9,$FA82,$FB4A,$FC13,$FCDC,$FDA5,$FE6E,$FF37 
		dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
		dc.w	$0647,$0710,$07D9,$08A1,$096A,$0A32,$0AFB,$0BC3 
		dc.w	$0C8B,$0D53,$0E1B,$0EE3,$0FAB,$1072,$1139,$1200 
		dc.w	$12C7,$138E,$1455,$151B,$15E1,$16A7,$176D,$1833 
		dc.w	$18F8,$19BD,$1A82,$1B46,$1C0B,$1CCF,$1D93,$1E56 
		dc.w	$1F19,$1FDC,$209F,$2161,$2223,$22E4,$23A6,$2467 
		dc.w	$2527,$25E7,$26A7,$2767,$2826,$28E5,$29A3,$2A61 
		dc.w	$2B1E,$2BDB,$2C98,$2D54,$2E10,$2ECC,$2F86,$3041 
		dc.w	$30FB,$31B4,$326D,$3326,$33DE,$3496,$354D,$3603 
		dc.w	$36B9,$376F,$3824,$38D8,$398C,$3A3F,$3AF2,$3BA4 
		dc.w	$3C56,$3D07,$3DB7,$3E67,$3F16,$3FC5,$4073,$4120 
		dc.w	$41CD,$4279,$4325,$43D0,$447A,$4523,$45CC,$4674 
		dc.w	$471C,$47C3,$4869,$490E,$49B3,$4A57,$4AFA,$4B9D 
		dc.w	$4C3F,$4CE0,$4D80,$4E20,$4EBF,$4F5D,$4FFA,$5097 
		dc.w	$5133,$51CE,$5268,$5301,$539A,$5432,$54C9,$555F 
		dc.w	$55F4,$5689,$571D,$57B0,$5842,$58D3,$5963,$59F3 
		dc.w	$5A81,$5B0F,$5B9C,$5C28,$5CB3,$5D3D,$5DC6,$5E4F 
		dc.w	$5ED6,$5F5D,$5FE2,$6067,$60EB,$616E,$61F0,$6271 
		dc.w	$62F1,$6370,$63EE,$646B,$64E7,$6562,$65DD,$6656 
		dc.w	$66CE,$6745,$67BC,$6831,$68A5,$6919,$698B,$69FC 
		dc.w	$6A6C,$6ADB,$6B4A,$6BB7,$6C23,$6C8E,$6CF8,$6D61 
		dc.w	$6DC9,$6E30,$6E95,$6EFA,$6F5E,$6FC0,$7022,$7082 
		dc.w	$70E1,$7140,$719D,$71F9,$7254,$72AE,$7306,$735E 
		dc.w	$73B5,$740A,$745E,$74B1,$7503,$7554,$75A4,$75F3 
		dc.w	$7640,$768D,$76D8,$7722,$776B,$77B3,$77F9,$783F 
		dc.w	$7883,$78C6,$7908,$7949,$7989,$79C7,$7A04,$7A41 
		dc.w	$7A7C,$7AB5,$7AEE,$7B25,$7B5C,$7B91,$7BC4,$7BF7 
		dc.w	$7C29,$7C59,$7C88,$7CB6,$7CE2,$7D0E,$7D38,$7D61 
		dc.w	$7D89,$7DB0,$7DD5,$7DF9,$7E1C,$7E3E,$7E5E,$7E7E 
		dc.w	$7E9C,$7EB9,$7ED4,$7EEF,$7F08,$7F20,$7F37,$7F4C 
		dc.w	$7F61,$7F74,$7F86,$7F96,$7FA6,$7FB4,$7FC1,$7FCD 
		dc.w	$7FD7,$7FE0,$7FE8,$7FEF,$7FF5,$7FF9,$7FFC,$7FFE 

angles		DC.W 512,0,0

		SECTION BSS
smmat_tmp	DS.W 9
XYZ_spCRDS	ds.w 3*no_points

obj		DS.W 1
XYZ_spCRDSADDR	DS.L no_points*3
perstab		DS.l $4000
		DS.L 1

bigtable	DS.B 512*512

screens		DS.B 256
		DS.B 42240
		DS.B 42240
		DS.L 349
stack		DS.L 2

