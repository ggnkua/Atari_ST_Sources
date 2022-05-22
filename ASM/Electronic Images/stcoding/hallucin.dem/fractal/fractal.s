;-----------------------------------------------------------------------;
;									;
;      Hallucinations "Fractal" part - fractal ferns/triangles...	;
; 	            by Martin Griffiths June 1992			;
;									;
;-----------------------------------------------------------------------;

		OPT C-,O+,OW-

demo		EQU 0

		IFEQ demo
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		ELSEIF
		ORG $10000
		ENDC

letsgo		MOVE.L SP,oldsp
		LEA my_stack,SP
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear pal
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		IFNE demo
		JSR $508
		ENDC

		BSR flush
		BSR Initscreens
		MOVE.W #$2700,SR
		LEA oldmfp(PC),A0
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA17.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		LEA vbl(PC),A0
		MOVE.L A0,$70.W
		MOVE.L #ltext_hbl,$120.W
		CLR.B $FFFFFA1B.W
		MOVE.B #1,$FFFFFA07.W
		MOVE.B #0,$fffffa09.W 
		MOVE.B #1,$FFFFFA13.W
		MOVE.B #0,$fffffa15.W 
		BCLR.B #3,$FFFFFA17.W
		MOVE #$2300,SR 

.obja1		SF.B dofrac
		BSR WaitVbl
		BSR Initscreens
		BSR WaitVbl
		ST.B dofrac
		MOVE.L #triang1,frac_ptr
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadein	
		MOVE #250,D7
		BSR Waitd7Vbls
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadeOut
		MOVEQ #16,D7
		BSR Waitd7Vbls

.obja2		SF.B dofrac
		BSR WaitVbl
		BSR Initscreens
		BSR WaitVbl
		ST.B dofrac
		MOVE.L #triang2,frac_ptr
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadein	
		MOVE #300,D7
		BSR Waitd7Vbls
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadeOut
		MOVEQ #30,D7
		BSR Waitd7Vbls

.obj1		SF.B dofrac
		BSR WaitVbl
		BSR Initscreens
		BSR WaitVbl
		ST.B dofrac
		MOVE.L #fracfern1,frac_ptr
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadein	
		MOVE #200,D7
		BSR Waitd7Vbls
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadeOut
		MOVEQ #16,D7
		BSR Waitd7Vbls

.obj2		SF.B dofrac
		BSR WaitVbl
		BSR Initscreens
		BSR WaitVbl
		ST.B dofrac
		MOVE.L #fracfern2,frac_ptr
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadein	
		MOVE #270,D7
		BSR Waitd7Vbls
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadeOut
		MOVEQ #16,D7
		BSR Waitd7Vbls

.obj3		SF.B dofrac
		BSR WaitVbl
		BSR Initscreens
		BSR WaitVbl
		ST.B dofrac
		MOVE.L #fracfern3,frac_ptr
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadein	
		MOVE #350,D7
		BSR Waitd7Vbls
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadeOut
		MOVEQ #16,D7
		BSR Waitd7Vbls


.obj4		SF.B dofrac
		BSR WaitVbl
		BSR Initscreens
		BSR WaitVbl
		ST.B dofrac
		MOVE.L #fracfern4,frac_ptr
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadein	
		MOVE #500,D7
		BSR Waitd7Vbls
		LEA currpal(PC),A0
		LEA pal(PC),A1
		BSR SetFadeOut
		MOVEQ #30,D7
		BSR Waitd7Vbls


.exit		MOVE #$2700,SR 
		LEA oldmfp(PC),A0
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA17.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.W #$2300,SR
		
		IFEQ demo
		MOVE.L #$00000666,$FFFF8240.W
		MOVE.L #$06660666,$FFFF8244.W
		CLR -(SP)
		TRAP #1
		ENDC
		MOVE.L oldsp(PC),SP
		RTS
oldsp		DS.L 1

oldmfp		DS.L 22

; Initialise screen.

Initscreens	LEA phy_base(PC),A1
	  	MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A1)
		BSR clearsc
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

clearsc		MOVE.L D0,A0
		MOVE.W #(32000/16)-1,D1
		MOVEQ #0,D2
.lp		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		DBF D1,.lp
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS


pal	  	dc.w $000,$020,$040,$040,$000,$000,$000,$000,$000
		dc.w $000,$000,$000,$000,$000,$000,$000,$000,$000

; Little old vbl..

vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVE.B #199,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		MOVE.L #ltext_hbl,$120.W
		MOVEM.L currpal(PC),D0-D7 
		MOVEM.L D0-D7,$FFFF8240.W
		IFNE demo
		JSR $504
		ENDC
		BSR littletext
		BSR NiceFadeIn
		BSR NiceFadeOut
		BSR Fractal_gen	
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer  	
		RTE 

vbl_timer	DC.W 0

WaitD7Vbls	
.wait_lp	BSR WaitVbl
		DBF D7,.wait_lp
		RTS

WaitVbl		MOVE.W vbl_timer(PC),D0
.wait		CMP.W vbl_timer(PC),D0
		BEQ.S .wait
		RTS

ltext_hbl	MOVEM.L A0/D7,-(SP)
		MOVE #$8209,A0
		MOVEQ #96,D7
.synca		CMP.B (A0),D7
		BEQ.S .synca
		MOVE.B (A0),D7
		JMP noplist1-96(PC,D7) 
noplist1	REPT 99
		NOP
		ENDR
		MOVE.B #0,$ffff820a.w
		REPT 8
		NOP
		ENDR
		MOVE.B #2,$ffff820a.w
		MOVE.W ltext_struc(PC),$FFFF8242.W
		CLR.B $FFFFFA1B.W
		MOVEM.L (SP)+,A0/D7
		RTE

; Little text rout.

base_offy	EQU 212*160

		RSRESET
plane1col	RS.W 1
text_tmr	RS.W 1
text_ptr	RS.L 1
tis_fade	RS.W 1
curr_x		RS.W 1
ltext_strucsize	RS.B 0

littletext	LEA ltext_struc(PC),A5
		TST.B tis_fade(A5)
		BEQ.S .notfade
		CMP.B #1,tis_fade(A5)
		BEQ.S .cse1
		CMP.B #2,tis_fade(A5)
		BEQ.S .cse2
		CMP.B #3,tis_fade(A5)
		BEQ.S .cse3

.cse1		ADD #$111,plane1col(A5)
		CMP #$777,plane1col(A5)
		BNE.S .nodone1
		MOVE.W #250,text_tmr(A5)
		MOVE.B #2,tis_fade(A5)	
.nodone1	RTS

.cse2		SUBQ #1,text_tmr(A5)
		BGE.S .nodone2
		MOVE.B #3,tis_fade(A5)
.nodone2	RTS

.cse3		SUB #$111,plane1col(A5)
		BNE.S .nodone3
		MOVE.B #0,tis_fade(A5)	
.nodone3	RTS

.notfade	MOVE.W curr_x(A5),D0
		LEA textofftab(PC),A3
		ADD.W D0,D0
		MOVE.W (A3,D0),D0
		MOVE.L phy_base(PC),A0	
		ADD.L #base_offy,A0
		ADD.W D0,A0
		LEA ltext(PC),A3
		ADD.L text_ptr(A5),A3
		CLR D0
		MOVE.B (A3)+,D0
		SUB.B #32,D0
		LSL #3,D0
		LEA font8(PC),A3
		ADD.W D0,A3
i		SET 0
		REPT 8
		MOVE.B (A3)+,i(A0)
i		SET i+160
		ENDR

		ADDQ.L #1,text_ptr(A5)
		ADDQ #1,curr_x(A5)
		CMP.W #40,curr_x(A5)
		BNE.S .nodoanything
		CLR.W curr_x(A5)
		MOVE.B #1,tis_fade(A5)
.nodoanything	RTS
font8		INCBIN ..\..\graphics\FONTS__8.RAW\MET_09.FN8
		EVEN

;		DC.B "0123456789012345678901234567890123456789"
ltext		DC.B "  A FRACTAL BREAK FROM THE 3D ROUTINES  "  
		DC.B "       'THE SPIERINSKI TRIANGLE'        "
		DC.B "   AND SOME FRACTALLY GENERATED FERNS   "
		DC.B "            WITH ZOOMING...             "
		DC.B "                                        "
		DC.B "    AND HERE ENDETH THE FRACTAL PART    "
		DC.B "                                        "
		DC.B "                                        "
		DC.B "                                        "
		DC.B 0
		EVEN

i		SET 0
textofftab
		REPT 20
		DC.W i
		DC.W i+1
i		SET i+8
		ENDR

ltext_struc	DC.W 0
		DC.W 0
		DS.B ltext_strucsize-4
		EVEN

;----------------------------------------------------------
; Fade routs.

currpal		DS.W 16
blank_pal	DS.W 16

; Set off a fade in
; A0 -> currpal A1 -> fade in palette

SetFadein	LEA fadein_vars(pc),a5
		MOVE.L #currpal,fadein_curptr(a5)
		MOVE.L A1,fadein_palptr(a5)
		MOVE.W #16,fadein_nocols(a5)
		MOVE.B #4,fadein_tim(a5)
		MOVE.B #4,fadein_spd(a5)
		ST.B fadeinflag(a5)
		RTS

; Set off a fade out

SetFadeout	LEA fadeout_vars(pc),a5
		MOVE.L #currpal,fadeout_curptr(a5)
		MOVE.W #16,fadeout_nocols(a5)
		MOVE.B #4,fadeout_tim(a5)
		MOVE.B #4,fadeout_spd(a5)
		ST.B fadeoutflag(a5)
		RTS

; Nice fade in routine. 
; ->Fade variables structure as below :-

		rsreset
fadein_curptr	rs.l 1			; current palette(from -> dest)
fadein_palptr	rs.l 1			; destination palette
fadein_nocols	rs.w 1			; no of colours in palette
fadein_tim	rs.b 1			; vbl count
fadein_spd	rs.b 1			; vbl fade delay speed
fadeinflag	rs.b 1			; fade flag(true if fading)
fadein_varsize	rs.b 1			; structure size

NiceFadein	LEA fadein_vars(pc),a5
		TST.B fadeinflag(a5)		; fading ?
		BEQ .nofadein	
		SUBQ.B #1,fadein_tim(a5) 	; vbl count-1
		BGT.S .nofadein
		MOVE.B fadein_spd(a5),fadein_tim(a5)    ; reset speed (vbl count)
.okstillfade	MOVE.L fadein_curptr(a5),a0 	; pal to fade FROM
		MOVE.L fadein_palptr(a5),a1	; ptr to pal to fade TO.
		MOVE.W fadein_nocols(a5),d7
		SUBQ #1,d7
		MOVE.L A0,A2
		MOVE.L A1,A3
		BSR.S dfadein
		MOVE.L A0,A2
		MOVE.L A1,A3
		MOVE.W fadein_nocols(a5),d0
		SUBQ #1,D0
.lp		MOVE.W (A2)+,D1
		MOVE.W (A3)+,D2
		ANDI.W #$777,D1
		ANDI.W #$777,D2
		CMP.W D1,D2
		BNE.S .nofadein
.ok		DBF D0,.lp
		SF.B fadeinflag(a5)		; yes signal fade done.
.nofadein	RTS

dfadein		MOVE.W	(A2),D0
		MOVE.W	(A3),D1
		ANDI.W	#7,D0
		ANDI.W	#7,D1
		CMP.W	D0,D1
		BEQ.S	L22CCE
		ADDI.W	#1,D0
		MOVE.W	(A2),D1
		ANDI.W	#$FFF8,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
		BRA.S	L22D0E
L22CCE		MOVE.W	(A2),D0
		MOVE.W	(A3),D1
		ANDI.W	#$700,D0
		ANDI.W	#$700,D1
		CMP.W	D0,D1
		BEQ.S	L22CEE
		ADDI.W	#$100,D0
		MOVE.W	(A2),D1
		ANDI.W	#$F8FF,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
		BRA.S	L22D0E
L22CEE		MOVE.W	(A2),D0
		MOVE.W	(A3),D1
		ANDI.W	#$70,D0
		ANDI.W	#$70,D1
		CMP.W	D0,D1
		BEQ	L22D0E
		ADDI.W	#$10,D0
		MOVE.W	(A2),D1
		ANDI.W	#$FF8F,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
L22D0E		ADDQ.L	#2,A2
		ADDQ.L	#2,A3
		DBF	D7,dfadein
		RTS

fadein_vars:	ds.b fadein_varsize
		even

; Nice fade OUT routine. 
; ->Fade variables structure as below :-

		rsreset
fadeout_curptr	rs.l 1			; current palette(from -> dest)
fadeout_nocols	rs.w 1			; no of colours in palette
fadeout_tim	rs.b 1			; vbl count
fadeout_spd	rs.b 1			; vbl fade delay speed
fadeoutflag	rs.b 1			; fade flag(true if fading)
fadeout_varsize	rs.b 1			; structure size

NiceFadeout	LEA fadeout_vars(pc),a5
		TST.B fadeoutflag(a5)		; fading ?
		BEQ .nofadeout	
		SUBQ.B #1,fadeout_tim(a5) 	; vbl count-1
		BGT.S .nofadeout
		MOVE.B fadeout_spd(a5),fadeout_tim(a5)    ; reset speed (vbl count)
.okstillfade	MOVE.L fadeout_curptr(a5),a0 	; pal to fade FROM
		MOVE.W fadeout_nocols(a5),d7
		SUBQ #1,D7
		MOVE.L A0,A2
	 	BSR.S dfadeout
		MOVE.L A0,A2
		MOVE.W fadeout_nocols(a5),d0
		SUBQ #1,D0
.lp		MOVE.W (A2)+,D1
		ANDI.W #$777,D1
		BNE.S .nofadeout
		DBF D0,.lp
		SF.B fadeoutflag(a5)		; yes signal fade done.
.nofadeout	RTS

dfadeout	MOVE.W	(A2),D0
		ANDI.W	#$70,D0
		BEQ.S	L22D50
		SUBI.W	#$10,D0
		MOVE.W	(A2),D1
		ANDI.W	#$FF8F,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
		BRA.S	L22D80
L22D50		MOVE.W	(A2),D0
		ANDI.W	#$700,D0
		BEQ.S	L22D68
		SUBI.W	#$100,D0
		MOVE.W	(A2),D1
		ANDI.W	#$F8FF,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
		BRA.S	L22D80
L22D68		MOVE.W	(A2),D0
		ANDI.W	#7,D0
		BEQ	L22D80
		SUBI.W	#1,D0
		MOVE.W	(A2),D1
		ANDI.W	#$FFF8,D1
		OR.W	D0,D1
		MOVE.W	D1,(A2)
L22D80		ADDQ.L	#2,A2
		DBF	D7,dfadeout
		RTS

fadeout_vars	DS.B fadeout_varsize	
		EVEN

;---------------------------------------------------------------

phy_base 	DS.L 1
dofrac		DS.W 1

;
; Generate Fractal (155 points) from 'frac_ptr'. This is 1 frames worth!
;

; Data Structure Format for fractal arrays.

		rsreset
xscle		rs.w 1			; x scale
yscle		rs.w 1			; y scale
xoff		rs.w 1			; x offset
yoff		rs.w 1			; y offset
fraca		rs.w 4
fracb		rs.w 4
fracc		rs.w 4			; constants for shape defination
fracd		rs.w 4
frace		rs.w 4
fracf		rs.w 4
fracp		rs.w 4			; weighted probabilities

Fractal_gen	tst.b dofrac
		beq nofrac
		move.l frac_ptr(pc),a3
		moveq #11,d3
		move #100,-(sp)

		lea.l mulu_160(pc),a2		; *160 table
		move.l phy_base(pc),a4		; screen base
		moveq.l #0,d4			; x%=0
		moveq.l #0,d5			; y%=0
		movem.w (a3),d0-d1/a0-a1
		lea xscale+2(pc),a5
		move.w d0,(a5)			; set up scaling
		move.w d1,yscale-xscale(a5)	; factors(SM code)
fracgen		lea (a3),a5
fracrand	move.l	fracrndseed(pc),d1
		add.l d1,d0
		mulu #$4731,d0
		add.l d6,d0			; psuedo random
		ror.l #1,d0			; number
		addi.l	#715136305,d0
		move.l	d0,fracrndseed		; in d0
		and.l #$7ff,d0			; pk%=int(rnd(512)
		cmp.w fracp(a5),d0
		ble.s .cont
.1		cmp.w fracp+2(a5),d0
		bgt.s .2
		addq #2,a5
		bra.s .cont			; choose array
.2		cmp.w fracp+4(a5),d0		; based on cum prob. 
		bgt.s .3
		addq #4,a5
		bra.s .cont
.3		addq #6,a5
.cont		move.w fraca(a5),d0		; a%(k)
		muls d4,d0			; a%(k)*x%
		move.w fracb(a5),d6		; b%(k)
		muls d5,d6			; b%(k)*y%
		add.l d0,d6
		asr.l d3,d6			
		add.w frace(a5),d6		; +e%(k)
		move.w fracc(a5),d7		; c%(k)
		muls d4,d7			; c%(k)*x%
		move.w fracd(a5),d0		; d%(k)
		muls d5,d0			; d%(k)*y%
		add.l d0,d7
		asr.l d3,d7			
		add.w fracf(a5),d7		; +f%(k)
		move.w d6,d4			; x%=nx% 	
		move.w d7,d5 			; y%=ny%
		move.w d4,d1			; x%
xscale		muls #7,d1			' x%*xscale
		asr.l d3,d1
		move.w d5,d2			; y%
yscale		muls #7,d2
		asr.l d3,d2	
		add a0,d1			; x+xoffset
		add a1,d2			; y+yoffset
.dofracplot	cmp #319,d1			; clip on x
		bcc .cont
		cmp #199,d2			; clip on y					
		bcc .cont
		move.w d1,d0
		lsr #1,d1
		and #$fff8,d1
		add d2,d2
		add (a2,d2),d1			; add screen line
		clr d2
		not d0
		and #15,d0
		bset d0,d2			; pixel mask
		move.w (a4,d1.w),d6
		not.w d6
		move.w d2,d7
		and.w d6,d7
		bne.s .ok
		addq #2,d1
.ok		or.w d2,(a4,d1.w)		; plot it!
.cont		subq #1,(sp)
		bne fracgen
		addq.l #2,sp
nofrac		rts		

fracrndseed 	dc.l $17935785
frac_ptr: 	dc.l fracfern1

; Fractal Objects - Ferns,'Sierpinski Triangle', tree

fracfern1	dc.w 25*1
		dc.w 16*1
		dc.w 160,20
.a		dc.w $0000/32
		dc.w $3333/32
		dc.w $ffffd999/32
		dc.w $d999/32
.b1		dc.w $0000
		dc.w $ffffbd70/32
		dc.w $47ae/32
		dc.w $0a3d/32
.c		dc.w $0000/32
		dc.w $3ae1/32
		dc.w $428f/32
		dc.w $fffff5c2/32
.d		dc.w $28f5/32
		dc.w $3851/32
		dc.w $3d70/32
		dc.w $d999/32
.e		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
.f		dc.w $0000/32
		dc.w $00019999/32
		dc.w $70a3/32
		dc.w $00019999/32
.p		dc.w $028f/32
		dc.w $147a/32
		dc.w $2665/32
		dc.w $fffe/32

fracfern2	dc.w 25*3/2
		dc.w 16*3/2
		dc.w 160,0
.a		dc.w $0000/32
		dc.w $3333/32
		dc.w $ffffd999/32
		dc.w $d999/32
.b1		dc.w $0000
		dc.w $ffffbd70/32
		dc.w $47ae/32
		dc.w $0a3d/32
.c		dc.w $0000/32
		dc.w $3ae1/32
		dc.w $428f/32
		dc.w $fffff5c2/32
.d		dc.w $28f5/32
		dc.w $3851/32
		dc.w $3d70/32
		dc.w $d999/32
.e		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
.f		dc.w $0000/32
		dc.w $00019999/32
		dc.w $70a3/32
		dc.w $00019999/32
.p		dc.w $028f/32
		dc.w $147a/32
		dc.w $2665/32
		dc.w $fffe/32

fracfern3	dc.w 25*2
		dc.w 16*2
		dc.w 160,0
.a		dc.w $0000/32
		dc.w $3333/32
		dc.w $ffffd999/32
		dc.w $d999/32
.b1		dc.w $0000	
		dc.w $ffffbd70/32
		dc.w $47ae/32
		dc.w $0a3d/32
.c		dc.w $0000/32
		dc.w $3ae1/32
		dc.w $428f/32
		dc.w $fffff5c2/32
.d		dc.w $28f5/32
		dc.w $3851/32
		dc.w $3d70/32
		dc.w $d999/32
.e		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
.f		dc.w $0000/32
		dc.w $00019999/32
		dc.w $70a3/32
		dc.w $00019999/32
.p		dc.w $028f/32
		dc.w $147a/32
		dc.w $2665/32
		dc.w $fffe/32

fracfern4	dc.w 25*3
		dc.w 16*3
		dc.w 160,-50
.a		dc.w $0000/32
		dc.w $3333/32
		dc.w $ffffd999/32
		dc.w $d999/32
.b1		dc.w $0000	
		dc.w $ffffbd70/32
		dc.w $47ae/32
		dc.w $0a3d/32
.c		dc.w $0000/32
		dc.w $3ae1/32
		dc.w $428f/32
		dc.w $fffff5c2/32
.d		dc.w $28f5/32
		dc.w $3851/32
		dc.w $3d70/32
		dc.w $d999/32
.e		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
		dc.w $0000/32
.f		dc.w $0000/32
		dc.w $00019999/32
		dc.w $70a3/32
		dc.w $00019999/32
.p		dc.w $028f/32
		dc.w $147a/32
		dc.w $2665/32
		dc.w $fffe/32

tree1		dc.w 370*2,265*2 
		dc.w 160,-50
.a		dc.w 0     ;0.00*2048
		dc.w 20    ;0.01*2048
		dc.w 860   ;0.42*2048
		dc.w 860   ;0.42*2048
.b1		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
		dc.w -860  ;-0.42*2048
		dc.w 860   ;0.42*2048
.c		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
		dc.w 860   ;0.42*2048
		dc.w -860  ;-0.42*2048
.d		dc.w 1024  ;0.50*2048
		dc.w 205   ;0.10*2048
		dc.w 860   ;0.42*2048
		dc.w 860   ;0.42*2048
.e		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
		dc.w 0     ;0.00*2048
.f		dc.w 0     ;0.00*2048
		dc.w 410   ;0.20*2048
		dc.w 410   ;0.20*2048
		dc.w 410   ;0.20*2048
.p		dc.w 103              ;0.05*2048
		dc.w 307+103          ;0.15*2048
		dc.w 819+307+103      ;0.40*2048
		dc.w 819+819+307+103  ;0.40*2048

triang1		dc.w 120,110
		dc.w 50,50
.a		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.b1		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
.c		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
.d		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.e		dc.w 0    ;0.00*2048
		dc.w 2048 ;1.00*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.f		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 1024  ;0.50*2048
		dc.w 0     ;0.00*2048
.p		dc.w 682   ;0.33*2048
		dc.w 682*2 ;0.33*2048
		dc.w (682*2)+683 ;0.34*2048
		dc.w 0     ;0.00*2048

triang2		dc.w 120*2,110*2
		dc.w -75,20
.a		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.b1		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
.c		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
.d		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.e		dc.w 0    ;0.00*2048
		dc.w 2048 ;1.00*2048
		dc.w 1024 ;0.50*2048
		dc.w 0    ;0.00*2048
.f		dc.w 0    ;0.00*2048
		dc.w 0    ;0.00*2048
		dc.w 1024  ;0.50*2048
		dc.w 0     ;0.00*2048
.p		dc.w 682   ;0.33*2048
		dc.w 682*2 ;0.33*2048
		dc.w (682*2)+683 ;0.34*2048
		dc.w 0     ;0.00*2048

i		set 0
mulu_160	rept 50
		dc.w i,i+160,i+320,i+480
i		set i+640
		endr
	
		SECTION BSS
		DS.L 199
my_stack	DS.L 3
screens		DS.B 256
		DS.B 47000
