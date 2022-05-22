;----------------------------------------------------------------------
;
;	       		      'The Intro'
;
;        by Griff of Electronic Images. (The Inner Circle)
;
;----------------------------------------------------------------------

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

		ELSEIF

		ORG $10000
		MOVE.L SP,oldsp

		ENDC

		LEA stack,sp
		MOVE.W #$8240,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		BSR makegradtab
		BSR Initscreens
		BSR set_ints

presentingyou	BSR WaitVbl
		MOVE.L #my_vbl2,$70.w
		LEA presentpic+34,A0
		BSR copy_pic
		BSR WaitVbl
		LEA presentpic+2,A1
		BSR SetFadein	
		MOVE #130-1,D7
.mainvbl_loop	BSR WaitVbl
		DBF D7,.mainvbl_loop
		BSR SetFadeout	
		MOVEQ #66-1,D7
.lp2		BSR WaitVbl
		DBF D7,.lp2

anEIproduction	BSR WaitVbl
		BSR Initscreens
		LEA EIprod+34,A0
		BSR copy_pic
		BSR do_gouraud		

from		BSR WaitVbl
		LEA frompic+34,A0
		BSR copy_pic
		LEA frompic+2,A1
		BSR SetFadein	
		MOVE #130-1,D7
.mainvbl_loop	BSR WaitVbl
		DBF D7,.mainvbl_loop
		BSR SetFadeout	
		BSR WaitVbl
		MOVEQ #66-1,D7
.lp2		BSR WaitVbl
		DBF D7,.lp2

Innercircle	BSR WaitVbl
		BSR Initscreens
		LEA pic1+34,A0
		BSR copy_pic
		BSR WaitVbl
		MOVE.L #my_vbl,$70.w
		LEA pic1+2,A1
		BSR SetFadein	
		MOVE #250-1,D7
.mainvbl_loop	BSR WaitVbl
		DBF D7,.mainvbl_loop
		BSR SetFadeout	
		MOVEQ #66-1,D7
.lp2		BSR WaitVbl
		DBF D7,.lp2

hallucinations	BSR WaitVbl
		MOVE.L #my_vbl2,$70.w
		BSR WaitVbl
		LEA hallucin+34,A0
		BSR copy_pic
		LEA hallucin+2,A1
		BSR SetFadein	
		MOVE #150-1,D7
.mainvbl_loop	BSR WaitVbl
		DBF D7,.mainvbl_loop
		BSR SetFadeout	
		MOVEQ #66-1,D7
.lp2		BSR WaitVbl
		DBF D7,.lp2


		BSR rest_ints		

		IFEQ demo
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
		LEA my_vbl2(pc),A1
		MOVE.L A1,$70.w
		LEA anrte(PC),A0
		MOVE.L A0,$14.W
		LEA SuperUser(PC),A1
		MOVE.L A1,$B0.W
		BSR flush
		MOVE.W #$2300,SR
		RTS
SuperUser	BCHG #13-8,(SP)
anrte		RTE

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
		ADD.L #32000,D0
		MOVE.L D0,(A1)+
		BSR cls
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Clear screen -> d0
		
cls		MOVE.L D0,A0
		MOVEQ #0,D2
		MOVE #(32000/16)-1,D1
.lp		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		MOVE.L D2,(A0)+
		DBF D1,.lp
		RTS

; Copy first screen in animation to physical screen

copy_pic	MOVE.L log_base(PC),A1
		MOVE.L phy_base(PC),A2
		MOVE.W #3999,D0
.lp		MOVE.L (A0),(A1)+
		MOVE.L (A0)+,(A2)+
		MOVE.L (A0),(A1)+
		MOVE.L (A0)+,(A2)+
		DBF D0,.lp
		rts

; This is the actually delta rout...
; .DLT player -> A5 points to delta info data structure as below.
;	      -> A1 points to screen (or similar)

delta_speed	equ 5			; animation speed(vbls)

		RSRESET
dlt_delta_ptr	RS.L 1			; curr pointer to .DLT data

play_dlt:	move.l dlt_delta_ptr(A5),a0
		
.cont		move.w	(a0),d0			;number of deltas
		beq	.eos			;zero = end of seq
		addq.l #2,a0
		move.w	d0,d1
		asr.w	#3,d0			;/8
		and.w	#7,d1
		asl.w	#3,d1			;x8
		neg.w	d1
		jmp	.next(pc,d1.w)
.loop:		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
		move.w	(a0)+,d1
		move.l	(a0)+,d2
		eor.l	d2,0(a1,d1.w)
.next:		dbra	d0,.loop
		move.l a0,dlt_delta_ptr(A5)
.no_play	rts
.eos:		lea dlts,a0
		bra.s .cont

delta1		DC.L dlts

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
		MOVE.B #3,fadein_tim(a5)
		MOVE.B #3,fadein_spd(a5)
		ST.B fadeinflag(a5)
		RTS

; Set off a fade out

SetFadeout	LEA fadeout_vars(pc),a5
		MOVE.L #currpal,fadeout_curptr(a5)
		MOVE.W #16,fadeout_nocols(a5)
		MOVE.B #3,fadeout_tim(a5)
		MOVE.B #3,fadeout_spd(a5)
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

; Little old vbl.

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVEM.L currpal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		IFNE demo
		JSR $504
		ENDC
		BSR NiceFadein	
		BSR NiceFadeout	
		NOT.W slowdown
		BNE.S .missme
		LEA delta1(PC),A5
		MOVE.L phy_base(PC),A1
		BSR play_dlt
.missme		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE
slowdown	DC.W 0

; Little old vbl.

my_vbl2		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA1B.W
		MOVEM.L currpal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		IFNE demo
		JSR $504
		ENDC
		BSR NiceFadein	
		BSR NiceFadeout	
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE

hbl1		RTE
mul160
i		set 80
		rept 50
		dc.w i,i+160,i+320,i+480
i		set i+640
		endr


;-----------------------------------------------------------------------;
;									;
;   Fast Gouraud shading polygon routines,				;
; 				    by Martin Griffiths December 1991	;
;									;
; - Interpolation with "Moire" patterns - slower than solid colour	;
;   shading, but looks a lot better!					;
;									;
;-----------------------------------------------------------------------;


do_gouraud	LEA EIprod+2,A1
		BSR SetFadein	
		MOVEQ #120-1,D7
.lp		BSR do_gframe
		DBF D7,.lp	
		BSR SetFadeout	
		MOVEQ #32-1,D7
.lp1		BSR do_gframe
		DBF D7,.lp1
		RTS

do_gframe	MOVE.W D7,-(sp)
		CLR.W vbl_timer
.wait		BSR WaitVbl
		CMP.W #2,vbl_timer
		BNE.S .wait
		BSR SwapScreens
		BSR ClearIt
		BSR Matrix_make
		ADD.W #32,v_angles
		LEA gpyramid,a0
		BSR Draw_GObj	
		MOVE.W (SP)+,D7
		RTS

; Clear screen very quickly.

ClearIt		MOVE.L log_base(PC),A0
		LEA (73*160)+56(A0),A0
		moveq #0,d0
		moveq #0,d1
		moveq #0,d2
		moveq #0,d3
		moveq #0,d4
		moveq #0,d5
		moveq #0,d6
		moveq #0,d7
		move.l d7,a1		
		move.l d7,a2		
		move.l d7,a3		
		move.l d7,a4		
i		set 0
		rept 53
		movem.l d0-d7/a1-a4,i(a0)
i		set i+160
		endr
		rts

; Swap Screen ptrs and set hware reg.

SwapScreens    	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LEA $FFFF8201.W,A0
		LSR.L #8,D1 
		MOVEP.W D1,(A0) 
		RTS 

pal	  	DC.W  $000,$111,$222,$333,$444,$555,$666,$777
		DC.W  $000,$210,$320,$431,$532,$643,$764,$775

; Little old vbl..
;
;vbl		ADDQ #1,vbl_timer  	
;		RTE 

v_angles  	Dc.W 0,0,1024
x_offset	DC.L $0
y_offset	DC.L $0
z_offset	DC.L $2400000

; Calculate a translation matrix, from the angle data pointed by A5.
; D0-D7/A0-A3 smashed.

Matrix_make	LEA trig_tab,A0		;sine table
		LEA 512(A0),A2		;cosine table
		MOVEM.W v_angles(PC),D5-D7    	
		AND.W #$7FE,D5
		AND.W #$7FE,D6
		AND.W #$7FE,D7
		MOVE (A0,D5),D0		;sin(xd)
		MOVE (A2,D5),D1		;cos(xd)
		MOVE (A0,D6),D2		;sin(yd)
		MOVE (A2,D6),D3		;cos(yd)
		MOVE (A0,D7),D4		;sin(zd)
		MOVE (A2,D7),D5		;cos(zd)
		LEA M11+2(PC),A1
* sinz*sinx(used twice) - A3
		MOVE D0,D6		;sinx
		MULS D4,D6		;sinz*sinx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A3
* sinz*cosx(used twice) - A4
		MOVE D1,D6		;cosx
		MULS D4,D6		;sinz*cosx
		ADD.L D6,D6
		SWAP D6
		MOVE D6,A4
* Matrix(1,1) cosy*cosx-siny*sinz*sinx
		MOVE D3,D6		;cosy
		MULS D1,D6		;cosy*cosx
		MOVE A3,D7		;sinz*sinx
		MULS D2,D7		;siny*sinz*sinx					
		SUB.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,(A1)
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6		;siny*cosx
		MOVE A3,D7		;sinz*sinx
		MULS D3,D7		;cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,M21-M11(A1)
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6		;cosz
		MULS D0,D6		;cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6			;-cosz*sinx
		MOVE D6,M31-M11(A1)
* Matrix(1,2) -siny*cosz
		MOVE D2,D6		;siny
		MULS D5,D6		;siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6			;-siny*cosz
		MOVE D6,M12-M11(A1)
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6		;cosy
		MULS D5,D6		;cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,M22-M11(A1)
* Matrix(3,2) sinz 
		MOVE D4,M32-M11(A1)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6		;cosy
		MULS D0,D6		;cosy*sinx
		MOVE A4,D7		;sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			;siny*(sinz*cosx)
		MOVE D6,M13-M11(A1)
		MOVE D6,ML1-M11(A1)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2		;siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,M23-M11(A1)
		MOVE D2,ML2-M11(A1)
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5			;cosz*cosx
		MOVE D5,M33-M11(A1)
		MOVE D5,ML3-M11(A1)
		RTS				

; Draw Gouraud Shaded Object, D0-D7/A0-A6 smashed.

Draw_GObj	MOVE.W (A0)+,D7         ; verts-1
		LEA new_crds,A1
		MOVE #160,A3		; centre x
		MOVE #98,A4		; centre y
trans_lp	MOVEM.W (A0)+,D0-D2	; x,y,z
		MOVE D0,D3	
		MOVE D1,D4		; dup
		MOVE D2,D5
* Calculate x co-ordinate		
M11		MULS #0,D0			
M21		MULS #0,D4		; mat mult
M31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
* Calculate y co-ordinate		
M12		MULS #0,D3
M22		MULS #0,D1		; mat mult
M32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1
* Calculate z co-ordinate
M13		MULS #0,D6
M23		MULS #0,D4		; mat mult
M33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2
		ASR.L #8,D0
		ASR.L #8,D1
		ADD.L z_offset(PC),D2
		SWAP D2
		DIVS D2,D0		; x/z
		DIVS D2,D1		; y/z
		ADD A3,D0		; x scr centre
		ADD A4,D1		; y scr centre
		MOVE D0,(A1)+		; new x co-ord
		MOVE D1,(A1)+		; new y co-ord
		MOVEM.W (A0)+,D0-D2 	; fetch normal
ML1		MULS #0,D0
ML2		MULS #0,D1		; mat mult
ML3		MULS #0,D2
		ADD.L D1,D0 
		ADD.L D2,D0 
		ADD.L D0,D0 
		SWAP D0			; magnitude
		NEG.W D0
		BPL.S .ok
		CLR.W D0
.ok	   	MOVE.W D0,(A1)+		; store intensity
		DBF D7,trans_lp
; A0 -> 'no. of faces-1' in object data.
		MOVE.W (A0)+,D6
.draw_face_lp 	LEA new_crds,A6
		MOVEM.W (A0),D0-D2
		MOVEM.W 0(A6,D0.W),D4/D0
		MOVEM.W 0(A6,D2.W),D5/D2
		MOVE.L 0(A6,D1.W),D1 
		SUB.W D1,D4 
		SUB.W D1,D5 
		SWAP D1
		SUB.W D1,D0 
		SUB.W D1,D2 
		MULS D2,D4 
		MULS D0,D5 
		SUB.L D4,D5 
		BMI.S .is_seen
		ADD.W D6,D6 
		ADD.W D6,A0 
		MOVE.W (A0)+,D6
		BPL.S .draw_face_lp
		RTS 
.is_seen      	BSR GDraw_Poly
		MOVE.L USP,A0
		MOVE.W (A0)+,D6
		BPL.S .draw_face_lp
		RTS 

;-----------------------------------------------------------------------;
;                 Gouraud Shaded Polygon Routine.			;
; A0 -> D6 coords (offsets into 'new_crds' in form X,Y,INTENSITY CONST) ;
;-----------------------------------------------------------------------;

GDraw_Poly	LEA trans_crds,A1 
		LEA new_crds,A6
		MOVE D6,D0
		ADD D6,D6
		ADD D0,D6
		ADD D6,D6
		MOVE.L A1,A5
		ADDA.W D6,A5
		MOVE.L A5,A2
		ADDA.W D6,A2
Init_coords	SUBQ #2,D0
		MOVE.W (A0)+,D7
		MOVE.W 4(A6,D7),D5
		MOVE.L (A6,D7),D7
		MOVE D7,D2
		MOVE.L A5,A4
		MOVE.L D7,(A1)+		; dup first coord
		MOVE.W D5,(A1)+
		MOVE.L D7,(A2)+
		MOVE.W D5,(A2)+
		MOVE.L D7,(A5)+
		MOVE.W D5,(A5)+
.coord_lp	MOVE.W (A0)+,D3
		MOVE.W 4(A6,D3),D5
		MOVE.L (A6,D3),D3
		CMP D2,D3
		BGE.S .not_top
		MOVE D3,D2
		MOVE.L A5,A4
.not_top	CMP D3,D7
		BGE.S .not_bot
		MOVE D3,D7	
.not_bot	MOVE.L D3,(A1)+		; dup for rest
		MOVE.W D5,(A1)+
		MOVE.L D3,(A2)+
		MOVE.W D5,(A2)+
		MOVE.L D3,(A5)+
		MOVE.W D5,(A5)+
		DBF D0,.coord_lp
		MOVE.L A0,USP
		MOVE.L A4,A5
		SUB D2,D7		;d2 - lowest y  d7 - greatest y
		BEQ polydone
		MOVE D2,-(SP)
		MOVE D7,-(SP)

CALCS		LEA grad_table+640(PC),A0
; Calc x's down left side of poly
Do_left		LEA LEFTJMP(PC),A2
		LEA x1s(PC),A3
Left_lp 	SUBQ #6,A4
		MOVEM.W (A4),D1-D2		;x1,y1
		MOVEM.W 4(A4),D0/D3-D5		;I2,x2,y2,I1
		SUB D4,D2			;dy
		SUB D3,D1			;dx
		SUB D2,D7			;remaining lines-dy
		SUB D5,D0			;DI
		EXT.L D0
		DIVS D2,D0			
		ADD D2,D2
		MULS (A0,D2),D1
		ADD.L D1,D1
		MOVE.W D1,D4			; frac part
		SWAP D1				; whole part
		MOVE.W D2,D6
		ADD D2,D2
		ADD D2,D2
		ADD D6,D2			; *10
		NEG D2
		CLR.W D6
		JMP (A2,D2)
		REPT 200
		MOVE.W D3,(A3)+
		ADD.W D4,D6
		ADDX.W D1,D3
		MOVE.W D5,(A3)+
		ADD.W D0,D5
		ENDR
LEFTJMP		TST D7
		BGT Left_lp

; Calc x's down right side of poly

Do_right	MOVE.W (SP),D7
		LEA RIGHTJMP(PC),A2
		LEA x2s(PC),A3
Right_lp	MOVEM.W (A5)+,D1-D2/D5		;x1,y1,I2
		MOVEM.W (A5),D3-D4/D6		;x2,y2,I1
		SUB D2,D4			;dy
		SUB D1,D3			;dx
		SUB D4,D7			;remaining lines-dy
		SUB D5,D6			;DI
		EXT.L D6
		DIVS D4,D6			
		ADD D4,D4
		MULS (A0,D4),D3
		ADD.L D3,D3
		MOVE.W D3,D2			; frac part	
		SWAP D3				; whole part
		MOVE.W D4,D0
		ADD D4,D4
		ADD D4,D4
		ADD D0,D4			; *10
		NEG D4
		CLR.W D0
		JMP (A2,D4)
		REPT 200
		MOVE.W D1,(A3)+
		ADD.W D2,D0
		ADDX.W D3,D1
		MOVE.W D5,(A3)+
		ADD.W D6,D5
		ENDR
RIGHTJMP	TST D7
		BGT Right_lp

; Now draw on screen

.gofordraw 	MOVE (SP)+,D7		; DY
		MOVE (SP)+,D0		; MIN Y
		SUBQ #1,D7
		MOVE.L log_base(PC),A6
		MULU #$A0,D0 
		ADDA.W D0,A6 
		LEA x1s(PC),A1
		LEA x2s(PC),A2

Gdraw_lp    	MOVE.W (A1)+,D0		; x1
		MOVE.W (A2)+,D6		; x2
		MOVE.W (A1)+,D1	 	; Intensity 1
		MOVE.W (A2)+,D2		; Intensity 2
		SUB.W D0,D6 
		BLE.S DS2 
		EXT.L D1
		SUB.W D1,D2 		
		BMI DSD 
DSU		LSL.L #4,D1 
		MOVE.W D6,D3
		ADD D3,D3
		MULU (A0,D3),D2
		CMP.L #%00000111111111111111111111111111,D2
		BLO.S .ok
		MOVEQ #-1,D2
		BRA.S contdu
.ok		LSL.L #5,D2
		SWAP D2
contdu	     	MOVE.W D2,A5 
; Dithered hline rout.D0=start X D6=no of pixels.
DITHERUP:	MOVEQ #$F,D3
		AND.W D0,D3 
		SUB.W D3,D0 
		LSR.W #1,D0 
		MOVE.L A6,A4
		ADDA.W D0,A4
		MOVEQ #0,D2 
		BSET D3,D2 
		ADD.W D3,D3 
		MOVE.W MASKS(PC,D3.W),D3 
		MOVE.W #-$8000,D0
		MOVE.L D1,D4 
		SWAP D4
		ADD.W D4,D4 
		MOVE.W JMPTAB(PC,D4.W),D4
HERE     	JMP HERE(PC,D4.W) 
DS2      	LEA 160(A6),A6
		DBF D7,Gdraw_lp
polydone	RTS 

JMPTAB:  	DC.W DU01-HERE
		DC.W DU12-HERE
		DC.W DU23-HERE
		DC.W DU34-HERE
		DC.W DU45-HERE
		DC.W DU56-HERE
		DC.W DU67-HERE
		DC.W DU7-HERE
MASKS		DC.W $FFFF,$7FFF,$3FFF,$1FFF
		DC.W $0FFF,$07FF,$03FF,$01FF
		DC.W $00FF,$007F,$003F,$001F
		DC.W $000F,$0007,$0003,$0001
		DS.W 1 

DSD      	LSL.L #4,D1 
		MOVE.W D6,D3
		ADD D3,D3
		NEG D2
		MULU (A0,D3),D2
		CMP.L #%00000111111111111111111111111111,D2
		BLO.S .ok
		MOVEQ #-1,D2
		BRA.S .cont
.ok		LSL.L #5,D2
		SWAP D2
.cont		NEG.W D2
		BEQ contdu 
		MOVE.W D2,A5 
; Dithered hline rout D0=start X D6=no of pixels
DITHERDOWN   	MOVEQ #$F,D3
		AND.W D0,D3 
		SUB.W D3,D0 
		LSR.W #1,D0 
		MOVE.L A6,A4
		ADDA.W D0,A4
		MOVEQ #0,D2 
		BSET D3,D2 
		ADD.W D3,D3 
		MOVE.W MASKS(PC,D3.W),D3
		MOVE.W #-$8000,D0
		MOVE.L D1,D4 
		SWAP D4
		ADD.W D4,D4 
test		MOVE.W JMPTAB2(PC,D4.W),D4 
HERE2:    	JMP HERE2(PC,D4.W)

JMPTAB2:  	DC.W DD01-HERE2
		DC.W DD12-HERE2
		DC.W DD23-HERE2
		DC.W DD34-HERE2
		DC.W DD45-HERE2
		DC.W DD56-HERE2
		DC.W DD67-HERE2
		DC.W DD7-HERE2

; Create Multplication gradient table for poly edges

makegradtab	LEA grad_table(PC),A0
		MOVE #-320,D0
.lp1		MOVE.L #32768,D1
		DIVS D0,D1
		MOVE.W D1,(A0)+
		ADDQ #1,D0
		CMP #-1,D0
		BNE.S .lp1
		MOVE.W #-32768,(A0)+
		MOVE.W #0,(A0)+
		MOVE.W #32767,(A0)+
		MOVEQ #2,D0
.lp2		MOVE.L #32768,D1
		DIVS D0,D1
		MOVE.W D1,(A0)+
		ADDQ #1,D0
		CMP #321,D0
		BNE.S .lp2
		RTS		

grad_table	ds.w 642

x1s		DS.L 201
x2s		DS.L 201

DU01:     	ADD.W   D1,D0 
		ADDX.W  D2,D2 
		BCS.S   DU0AA 
		ADD.W   A5,D1 
		DBCS    D6,DU01 
		MOVEQ   #-1,D4
		MOVE.W  D2,D5 
DU0AB:    	ADD.W   D4,D4 
		ADDX.W  D5,D5 
		BCC.S   DU0AB 
		AND.W   D4,D3 
		AND.W   D3,D5 
		NOT.W   D3
		AND.W   D3,(A4) 
		OR.W    D5,(A4) 
		AND.W   D3,2(A4)
		AND.W   D3,4(A4)
		AND.W   D3,6(A4)
		MOVE.W  D4,D3 
		NOT.W   D3
		SUBQ.W  #1,D6 
		BPL.S   DU12
		BRA.W DS2 

DU0AA:    AND.W   D3,D2 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  AND.W   D3,(A4)+
  AND.W   D3,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCS    D6,DU0AC
  SUBQ.W  #1,D6 
  BPL     DU1AC 
  BRA.W DS2 

DU0AC:    MOVEQ   #0,D3 
DU0A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DU0B
  MOVE.W  D2,(A4)+
  MOVE.W  D3,(A4)+
  MOVE.L  D3,(A4)+
  MOVEQ   #1,D2 
DU0B:     ADD.W   A5,D1 
  DBCS    D6,DU0A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DU0C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DU0C
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D5,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  SUBQ.W  #1,D6 
  BPL.S   DU12
  BRA.W DS2 

DU12:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DU1AA 
  ADD.W   A5,D1 
  DBCS    D6,DU12 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DU1AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DU1AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,2(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DU23
  BRA.W DS2 
DU1AA:    AND.W   D3,D2 
  NOT.W   D3
  AND.W   D3,(A4)+
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  NOT.W   D2
  EOR.W   D3,D2 
  OR.W    D2,-4(A4) 
  AND.W   D3,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCS    D6,DU1AC
  SUBQ.W  #1,D6 
  BPL     DU2AC 
  BRA.W DS2 
DU1AC:    MOVEQ   #0,D3 
DU1A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DU1B
  MOVE.W  D2,D4 
  NOT.W   D4
  MOVE.W  D4,(A4)+
  MOVE.W  D2,(A4)+
  MOVE.L  D3,(A4)+
  MOVEQ   #1,D2 
DU1B:     ADD.W   A5,D1 
  DBCS    D6,DU1A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 

DU1C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DU1C
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,2(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DU23
  BRA.W DS2 

DU23:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DU2AA 
  ADD.W   A5,D1 
  DBCS    D6,DU23 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DU2AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DU2AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,2(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DU34
  BRA.W DS2 
DU2AA:    AND.W   D3,D2 
  MOVE.W  D3,D4 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  OR.W    D4,(A4)+
  AND.W   D3,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCS    D6,DU2AC
  SUBQ.W  #1,D6 
  BPL     DU3AC 
  BRA.W DS2 
DU2AC:    MOVEQ   #0,D3 
  MOVEQ   #-1,D4
DU2A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DU2B
  MOVE.W  D2,(A4)+
  MOVE.W  D4,(A4)+
  MOVE.L  D3,(A4)+
  MOVEQ   #1,D2 
DU2B:     ADD.W   A5,D1 
  DBCS    D6,DU2A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DU2C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DU2C
  OR.W    D3,2(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DU34
  BRA.W DS2 

DU34:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DU3AA 
  ADD.W   A5,D1 
  DBCS    D6,DU34 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DU3AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DU3AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,4(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  OR.W    D5,2(A4)
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DU45
  BRA.W DS2 
DU3AA:    AND.W   D3,D2 
  NOT.W   D3
  MOVE.W  D2,D4 
  NOT.W   D4
  EOR.W   D3,D4 
  AND.W   D3,(A4) 
  OR.W    D4,(A4)+
  AND.W   D3,(A4) 
  OR.W    D4,(A4)+
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCS    D6,DU3AC
  SUBQ.W  #1,D6 
  BPL     DU4AC 
  BRA.W DS2 
DU3AC:    MOVEQ   #0,D3 
DU3A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DU3B
  MOVE.W  D2,D4 
  NOT.W   D4
  MOVE.W  D4,(A4)+
  MOVE.W  D4,(A4)+
  MOVE.W  D2,(A4)+
  MOVE.W  D3,(A4)+
  MOVEQ   #1,D2 
DU3B:     ADD.W   A5,D1 
  DBCS    D6,DU3A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DU3C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DU3C
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,4(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  OR.W    D5,2(A4)
  SUBQ.W  #1,D6 
  BPL.S   DU45
  BRA.W DS2 

DU45:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DU4AA 
  ADD.W   A5,D1 
  DBCS    D6,DU45 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DU4AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DU4AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DU56
  BRA.W DS2 
DU4AA:    AND.W   D3,D2 
  MOVE.W  D3,D4 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  AND.W   D3,(A4)+
  OR.W    D4,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCS    D6,DU4AC
  SUBQ.W  #1,D6 
  BPL     DU5AC 
  BRA.W DS2 
DU4AC:    MOVEQ   #0,D3 
  MOVE.L  #-$10000,D4 
DU4A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DU4B
  MOVE.W  D2,(A4)+
  MOVE.W  D3,(A4)+
  MOVE.L  D4,(A4)+
  MOVEQ   #1,D2 
DU4B:     ADD.W   A5,D1 
  DBCS    D6,DU4A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DU4C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DU4C
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DU56
  BRA.W DS2 

DU56:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DU5AA 
  ADD.W   A5,D1 
  DBCS    D6,DU56 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DU5AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DU5AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,6(A4)
  OR.W    D5,2(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DU67
  BRA.W DS2 
DU5AA:    AND.W   D3,D2 
  MOVE.W  D3,D4 
  NOT.W   D3
  MOVE.W  D2,D5 
  NOT.W   D5
  EOR.W   D3,D5 
  AND.W   D3,(A4) 
  OR.W    D5,(A4)+
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  OR.W    D4,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCS    D6,DU5AC
  SUBQ.W  #1,D6 
  BPL     DU6AC 
  BRA.W DS2 
DU5AC:    MOVE.L  #-$10000,D3 
DU5A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DU5B
  MOVE.W  D2,D4 
  NOT.W   D4
  MOVE.W  D4,(A4)+
  MOVE.W  D2,(A4)+
  MOVE.L  D3,(A4)+
  MOVEQ   #1,D2 
DU5B:     ADD.W   A5,D1 
  DBCS    D6,DU5A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DU5C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DU5C
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,6(A4)
  OR.W    D5,2(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DU67
  BRA.W DS2 

DU67:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DU6AA 
  ADD.W   A5,D1 
  DBCS    D6,DU67 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DU6AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DU6AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,2(A4)
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DU7 
  BRA.W DS2 
DU6AA:    AND.W   D3,D2 
  MOVE.W  D3,D4 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  OR.W    D4,(A4)+
  OR.W    D4,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCS    D6,DU6AC
  SUBQ.W  #1,D6 
  BPL   DU7AC 
  BRA.W DS2 
DU6AC:    MOVEQ   #-1,D3
  MOVE.L  #-$10000,D4 
DU6A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DU6B
  MOVE.W  D2,(A4)+
  MOVE.W  D3,(A4)+
  MOVE.L  D4,(A4)+
  MOVEQ   #1,D2 
DU6B:     ADD.W   A5,D1 
  DBCS    D6,DU6A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DU6C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DU6C
  OR.W    D3,2(A4)
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DU7 
  BRA.W DS2 

DU7:      ADD.W   D2,D2 
  DBCS    D6,DU7
  BCS.S   DU7AA 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DU7AB:    ADD.W   D4,D4 
  ADD.W   D5,D5 
  BCC.S   DU7AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,(A4) 
  OR.W    D3,2(A4)
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,6(A4)
  MOVE.W  D4,D3 
  NOT.W   D3
  BRA.W DS2 
DU7AA:    OR.W    D3,(A4)+
  OR.W    D3,(A4)+
  OR.W    D3,(A4)+
  NOT.W   D3
  AND.W   D3,(A4)+
  DBF     D6,DU7AC
  BRA.W DS2 
DU7AC:    MOVEQ   #-1,D3
  MOVE.L  #-$10000,D4 
  BRA.S   DU7B
DU7A:     MOVE.L  D3,(A4)+
  MOVE.L  D4,(A4)+
DU7B:     SUBI.W  #$10,D6 
  BPL.S   DU7A
  ADD.W   D6,D6 
  MOVE.W  MASKS3(PC,D6.W),D3
  AND.W   D3,6(A4)
  NOT.W   D3
  OR.W    D3,(A4)+
  OR.W    D3,(A4)+
  OR.W    D3,(A4)+
  BRA.W DS2 

		DC.B $FF,$FF,'',$FF,'?',$FF,$1F,$FF
		DC.B $0F,$FF,$07,$FF,$03,$FF,$01,$FF
		DC.B $00,$FF,$00,'',$00,'?',$00,$1F
		DC.B $00,$0F,$00,$07,$00,$03,$00,$01
		DS.W 1 
MASKS3



DD7       	ADDX D2,D2
		BCS.S   DD7AA 
		ADD.W   A5,D1 
		DBCC    D6,DD7
		MOVEQ   #-1,D4
		MOVE.W  D2,D5 
DD7AB:    ADD.W   D4,D4 
  ADD.W   D5,D5 
  BCC.S   DD7AB 
  AND.W   D4,D3 
  OR.W    D3,(A4) 
  OR.W    D3,2(A4)
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,6(A4)
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DD67
  BRA.W DS2 
DD7AA:    OR.W    D3,(A4)+
  OR.W    D3,(A4)+
  OR.W    D3,(A4)+
  NOT.W   D3
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCC    D6,DD7AC
  SUBQ.W  #1,D6 
  BPL     DD6AC 
  BRA.W DS2 
DD7AC:    MOVEQ   #-1,D3
  MOVE.L  #-$10000,D4 
DD7A:     ADD.W   D2,D2 
  BCC.S   DD7B
  MOVE.L  D3,(A4)+
  MOVE.L  D4,(A4)+
  MOVEQ   #1,D2 
DD7B:     ADD.W   A5,D1 
  DBCC    D6,DD7A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DD7C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DD7C
  OR.W    D3,(A4) 
  OR.W    D3,2(A4)
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,6(A4)
  SUBQ.W  #1,D6 
  BPL.S   DD67
  BRA.W DS2 
DD67:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DD6AA 
  ADD.W   A5,D1 
  DBCC    D6,DD67 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DD6AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DD6AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,2(A4)
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DD56
  BRA.W DS2 
DD6AA:    AND.W   D3,D2 
  MOVE.W  D3,D4 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  OR.W    D4,(A4)+
  OR.W    D4,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCC    D6,DD6AC
  SUBQ.W  #1,D6 
  BPL     DD5AC 
  BRA.W DS2 
DD6AC:    MOVEQ   #-1,D3
  MOVE.L  #-$10000,D4 
DD6A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DD6B
  MOVE.W  D2,(A4)+
  MOVE.W  D3,(A4)+
  MOVE.L  D4,(A4)+
  MOVEQ   #1,D2 
DD6B:     ADD.W   A5,D1 
  DBCC    D6,DD6A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DD6C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DD6C
  OR.W    D3,2(A4)
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DD56
  BRA.W DS2 
DD56:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DD5AA 
  ADD.W   A5,D1 
  DBCC    D6,DD56 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DD5AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DD5AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,6(A4)
  OR.W    D5,2(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DD45
  BRA.W DS2 
DD5AA:    AND.W   D3,D2 
  MOVE.W  D3,D4 
  NOT.W   D3
  MOVE.W  D2,D5 
  NOT.W   D5
  EOR.W   D3,D5 
  AND.W   D3,(A4) 
  OR.W    D5,(A4)+
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  OR.W    D4,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCC    D6,DD5AC
  SUBQ.W  #1,D6 
  BPL     DD4AC 
  BRA.W DS2 
DD5AC:    MOVE.L  #-$10000,D3 
DD5A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DD5B
  MOVE.W  D2,D4 
  NOT.W   D4
  MOVE.W  D4,(A4)+
  MOVE.W  D2,(A4)+
  MOVE.L  D3,(A4)+
  MOVEQ   #1,D2 
DD5B:     ADD.W   A5,D1 
  DBCC    D6,DD5A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DD5C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DD5C
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,6(A4)
  OR.W    D5,2(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DD45
  BRA.W DS2 
DD45:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DD4AA 
  ADD.W   A5,D1 
  DBCC    D6,DD45 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DD4AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DD4AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DD34
  BRA.W DS2 
DD4AA:    AND.W   D3,D2 
  MOVE.W  D3,D4 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  AND.W   D3,(A4)+
  OR.W    D4,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCC    D6,DD4AC
  SUBQ.W  #1,D6 
  BPL     DD3AC 
  BRA.W DS2 
DD4AC:    MOVEQ   #0,D3 
  MOVE.L  #-$10000,D4 
DD4A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DD4B
  MOVE.W  D2,(A4)+
  MOVE.W  D3,(A4)+
  MOVE.L  D4,(A4)+
  MOVEQ   #1,D2 
DD4B:     ADD.W   A5,D1 
  DBCC    D6,DD4A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DD4C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DD4C
  OR.W    D3,4(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DD34
  BRA.W DS2 
DD34:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DD3AA 
  ADD.W   A5,D1 
  DBCC    D6,DD34 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DD3AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DD3AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,4(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  OR.W    D5,2(A4)
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DD23
  BRA.W DS2 
DD3AA:    AND.W   D3,D2 
  NOT.W   D3
  MOVE.W  D2,D4 
  NOT.W   D4
  EOR.W   D3,D4 
  AND.W   D3,(A4) 
  OR.W    D4,(A4)+
  AND.W   D3,(A4) 
  OR.W    D4,(A4)+
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCC    D6,DD3AC
  SUBQ.W  #1,D6 
  BPL     DD2AC 
  BRA.W DS2 
DD3AC:    MOVEQ   #0,D3 
DD3A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DD3B
  MOVE.W  D2,D4 
  NOT.W   D4
  MOVE.W  D4,(A4)+
  MOVE.W  D4,(A4)+
  MOVE.W  D2,(A4)+
  MOVE.W  D3,(A4)+
  MOVEQ   #1,D2 
DD3B:     ADD.W   A5,D1 
  DBCC    D6,DD3A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DD3C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DD3C
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,4(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  OR.W    D5,2(A4)
  SUBQ.W  #1,D6 
  BPL.S   DD23
  BRA.W DS2 
DD23:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DD2AA 
  ADD.W   A5,D1 
  DBCC    D6,DD23 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DD2AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DD2AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  OR.W    D3,2(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DD12
  BRA.W DS2 
DD2AA:    AND.W   D3,D2 
  MOVE.W  D3,D4 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  OR.W    D4,(A4)+
  AND.W   D3,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCC    D6,DD2AC
  SUBQ.W  #1,D6 
  BPL     DD1AC 
  BRA.W DS2 
DD2AC:    MOVEQ   #0,D3 
  MOVEQ   #-1,D4
DD2A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DD2B
  MOVE.W  D2,(A4)+
  MOVE.W  D4,(A4)+
  MOVE.L  D3,(A4)+
  MOVEQ   #1,D2 
DD2B:     ADD.W   A5,D1 
  DBCC    D6,DD2A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DD2C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DD2C
  OR.W    D3,2(A4)
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DD12
  BRA.W DS2 
DD12:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DD1AA 
  ADD.W   A5,D1 
  DBCC    D6,DD12 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DD1AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DD1AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,2(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  MOVE.W  D4,D3 
  NOT.W   D3
  SUBQ.W  #1,D6 
  BPL.S   DD01
  BRA.W DS2 
DD1AA:    AND.W   D3,D2 
  NOT.W   D3
  AND.W   D3,(A4)+
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  NOT.W   D2
  EOR.W   D3,D2 
  OR.W    D2,-4(A4) 
  AND.W   D3,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBCC    D6,DD1AC
  SUBQ.W  #1,D6 
  BPL     DD0AC 
  BRA.W DS2 
DD1AC:    MOVEQ   #0,D3 
DD1A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DD1B
  MOVE.W  D2,D4 
  NOT.W   D4
  MOVE.W  D4,(A4)+
  MOVE.W  D2,(A4)+
  MOVE.L  D3,(A4)+
  MOVEQ   #1,D2 
DD1B:     ADD.W   A5,D1 
  DBCC    D6,DD1A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DD1C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DD1C
  NOT.W   D3
  AND.W   D3,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  OR.W    D5,2(A4)
  NOT.W   D5
  EOR.W   D3,D5 
  OR.W    D5,(A4) 
  SUBQ.W  #1,D6 
  BPL.S   DD01
  BRA.W DS2 
DD01:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCS.S   DD0AA 
  ADD.W   A5,D1 
  DBCC    D6,DD01 
  MOVEQ   #-1,D4
  MOVE.W  D2,D5 
DD0AB:    ADD.W   D4,D4 
  ADDX.W  D5,D5 
  BCC.S   DD0AB 
  AND.W   D4,D3 
  AND.W   D3,D5 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D5,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  MOVE.W  D4,D3 
  NOT.W   D3
  BRA.W DS2 
DD0AA:    AND.W   D3,D2 
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D2,(A4)+
  AND.W   D3,(A4)+
  AND.W   D3,(A4)+
  AND.W   D3,(A4)+
  MOVEQ   #1,D2 
  ADD.W   A5,D1 
  DBF     D6,DD0AC
  BRA.W DS2 
DD0AC:    MOVEQ   #0,D3 
DD0A:     ADD.W   D1,D0 
  ADDX.W  D2,D2 
  BCC.S   DD0B
  MOVE.W  D2,(A4)+
  MOVE.W  D3,(A4)+
  MOVE.L  D3,(A4)+
  MOVEQ   #1,D2 
DD0B:     ADD.W   A5,D1 
  DBCC    D6,DD0A 
  MOVEQ   #-1,D3
  MOVE.W  D2,D5 
DD0C:     ADD.W   D3,D3 
  ADD.W   D5,D5 
  BCC.S   DD0C
  NOT.W   D3
  AND.W   D3,(A4) 
  OR.W    D5,(A4) 
  AND.W   D3,2(A4)
  AND.W   D3,4(A4)
  AND.W   D3,6(A4)
  BRA.W DS2 

trig_tab     	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
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

gpyramid	DC.W 5-1
		DC.W -100,-100,-100
		DC.W -19000,-16000,-19000
		DC.W 100,-100,-100
		DC.W 19000,-16000,-19000
		DC.W 100,-100,100
		DC.W 19000,-16000,19000
		DC.W -100,-100,100
		DC.W -19000,-16000,19000
		DC.W 0,100,0
		DC.W 0,29000,0
		DC.W 4,3*6,2*6,1*6,00*6
		DC.W 3,0*6,1*6,4*6
		DC.W 3,1*6,2*6,4*6
		DC.W 3,2*6,3*6,4*6
		DC.W 3,3*6,0*6,4*6
		DC.W -1

		SECTION DATA
presentpic	INCBIN PHN_INT.INC\PRESENT.PI1
EIprod		INCBIN PHN_INT.INC\EI_BIT.PI1
frompic		INCBIN PHN_INT.INC\FROM.PI1
pic1		INCBIN PHN_INT.INC\ICSEQ.PI1
dlts		INCBIN PHN_INT.INC\ICSEQ.DLT
hallucin	INCBIN PHN_INT.INC\BARB_PIC.PI1

		SECTION BSS
trans_crds    	DS.W 200
new_crds     	DS.W 200 

		DS.B 160*16
screens		DS.B 256
		DS.B 32000
		DS.B 32000
		DS.B 160*16
		DS.L 399
stack		DS.L 3

