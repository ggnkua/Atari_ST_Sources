;-----------------------------------------------------------------------;
; 3d Space field using sprites(balls etc),				;
; Coded after seeing the Red sector Cebit'90 starfield demo!!!!		;
; (C) April 1991 Martin Griffiths. (Griff of The Inner Circle).		;
; This routine uses 'intelligent' sprite routines so that a minimum	;
; amount of masking is done and unused lines are NOT drawn to screen!	;
; Please NOTE this is not a lame perspective changing starfield!!!!	;
; Each Star(ball) is rotated about x,y,z and uses proper perspective	;
;-----------------------------------------------------------------------;

no_strs		EQU 58
spheight	EQU 16

letsgo		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; low res
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; super visor
		ADDQ.L #6,SP

		MOVE #$2700,SR
		LEA stack,SP
		LEA $FFFF8240.W,A0
		MOVEM.L (A0),D0-D7
		MOVEM.L D0-D7,old_cols
		REPT 8
		CLR.L (A0)+
		ENDR
		BSR Makeballrouts
		BSR Initscreens
		BSR Random_gen
		BSR set_ints
		MOVE.B #$12,$FFFFFC02.W
		MOVEM.L ballpal1(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$2300,SR

* This is the main program loop

Star_frame	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		NOT.W (A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
;		MOVE.W #$700,$FFFF8240.W
		MOVE vbl_timer(PC),D0
wait_vbl	CMP vbl_timer(PC),D0
		BEQ.S wait_vbl
;		MOVE.W #$000,$FFFF8240.W
		BSR clear_balls

		LEA angles(pc),a5
		ADDQ #4,(A5)
		ADDQ #4,2(A5)
		ADDQ #4,4(A5)
		BSR Matrix_make

		BSR Trans_balls
		BSR Plot_em

starsd		CMP.B #$39,$FFFFFC02.W
		bne Star_frame		

Exit		MOVE #$2700,SR
		BSR rest_ints
		MOVE.B #$8,$FFFFFC02.W
		MOVEM.L old_cols(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1			


; Rout to clear the balls/ stars whatever...

clear_balls	MOVE.L log_base(PC),A0
		LEA old_pos1(PC),A2	assume case 1
		TST switch
		BNE.S .case_1
.case_2		LEA old_pos2(PC),A2	no its case 2!
.case_1		MOVE.W (A2)+,D7
		SUBQ #1,D7
		BMI.S .out 
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
.starclear	MOVE.L A0,A1
		ADD.W (A2)+,A1
		MOVEM.L D0-D3,(A1)
		MOVEM.L D0-D3,160(A1)
		MOVEM.L D0-D3,320(A1)
		MOVEM.L D0-D3,480(A1)
		MOVEM.L D0-D3,640(A1)
		MOVEM.L D0-D3,800(A1)
		MOVEM.L D0-D3,960(A1)
		MOVEM.L D0-D3,1120(A1)
		MOVEM.L D0-D3,1280(A1)
		MOVEM.L D0-D3,1440(A1)
		MOVEM.L D0-D3,1600(A1)
		MOVEM.L D0-D3,1760(A1)
		MOVEM.L D0-D3,1920(A1)
		MOVEM.L D0-D3,2080(A1)
		MOVEM.L D0-D3,2240(A1)
		MOVEM.L D0-D3,2400(A1)
		DBF D7,.starclear
.out		RTS

; Calculate a translation matrix, from the angle data pointed by A5.
; D0-D7/A0-A3 smashed.

Matrix_make	LEA trig_tab,A0			sine table
		LEA 512(A0),A2			cosine table
		MOVEM.W (A5)+,D5-D7    	
		AND #$7FE,D5
		AND #$7FE,D6
		AND #$7FE,D7
		MOVE (A0,D5),D0			sin(xd)
		MOVE (A2,D5),D1			cos(xd)
		MOVE (A0,D6),D2			sin(yd)
		MOVE (A2,D6),D3			cos(yd)
		MOVE (A0,D7),D4			sin(zd)
		MOVE (A2,D7),D5			cos(zd)
		LEA M11+2(PC),A1
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
		MOVE D6,(A1)
* Matrix(2,1) siny*cosx+cosy*sinz*sinx 
		MOVE D2,D6
		MULS D1,D6			siny*cosx
		MOVE A3,D7			sinz*sinx
		MULS D3,D7			cosy*sinz*sinx			
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6			
		MOVE D6,M21-M11(A1)
* Matrix(3,1) -cosz*sinx
		MOVE D5,D6			cosz
		MULS D0,D6			cosz*sinx
		ADD.L D6,D6
		SWAP D6
		NEG D6				-cosz*sinx
		MOVE D6,M31-M11(A1)
* Matrix(1,2) -siny*cosz
		MOVE D2,D6			siny
		MULS D5,D6			siny*cosz
		ADD.L D6,D6
		SWAP D6
		NEG D6				-siny*cosz
		MOVE D6,M12-M11(A1)
* Matrix(2,2) cosy*cosz		
		MOVE D3,D6			cosy
		MULS D5,D6			cosy*cosz
		ADD.L D6,D6
		SWAP D6
		MOVE D6,M22-M11(A1)
* Matrix(3,2) sinz 
		MOVE D4,M32-M11(A1)
* Matrix(1,3) cosy*sinx+siny*sinz*cosx
		MOVE D3,D6			cosy
		MULS D0,D6			cosy*sinx
		MOVE A4,D7			sinz*cosx
		MULS D2,D7
		ADD.L D7,D6
		ADD.L D6,D6
		SWAP D6				siny*(sinz*cosx)
		MOVE D6,M13-M11(A1)
* Matrix(2,3) siny*sinx-cosy*sinz*cosx
		MULS D0,D2			siny*sinx
		MOVE A4,D7
		MULS D3,D7
		SUB.L D7,D2 
		ADD.L D2,D2
		SWAP D2
		MOVE D2,M23-M11(A1)
* Matrix(3,3) cosz*cosx
		MULS D1,D5 
		ADD.L D5,D5
		SWAP D5				cosz*cosx
		MOVE D5,M33-M11(A1)
		RTS				

; Rout to translate my lovely balls!!

Trans_balls	LEA stars(PC),A1		; co-ords
		LEA translated(PC),A4		; translated storage
		MOVE.W #160,A2			; x centre
		MOVE.W #100,A3			; y centre
		MOVEQ #no_strs-1,D7		; no. of stars
star_lp		MOVEM.W (A1)+,D0-D2		; get x,y,z
		SUB #10,D2			; move thru z
		CMP #-256,D2			; is object off z plane?
		BMI Star_off			; yes then reset it
cont		MOVE D2,-2(A1)			; otherwise store...
		MOVE D0,D3			
		MOVE D1,D4			; dup
		MOVE D2,D5
* Calculate x co-ordinate		
M11		MULS #0,D0			
M21		MULS #0,D4			; mat mult
M31		MULS #0,D5
		ADD.L D4,D0
		ADD.L D5,D0			; x
		MOVE D3,D6
		MOVE D1,D4
		MOVE D2,D5
* Calculate y co-ordinate		
M12		MULS #0,D3
M22		MULS #0,D1			; mat mult
M32		MULS #0,D5
		ADD.L D3,D1
		ADD.L D5,D1			; y
* Calculate z co-ordinate
M13		MULS #0,D6
M23		MULS #0,D4			; mat mult
M33		MULS #0,D2
		ADD.L D6,D2
		ADD.L D4,D2			; z
		ASR.L #8,D0						
		ASR.L #8,D1			
		SWAP D2
		ADD A2,D2			; z+160
		DIVS D2,D0			; x/z
		DIVS D2,D1			; y/z
		ADD A2,D0			; x+xcentre
		ADD A3,D1			; y+ycentre
		MOVE.W D0,(A4)+
		MOVE.W D1,(A4)+
		MOVE.W D2,(A4)+
		DBF D7,star_lp			
		RTS

Star_off	ADD #512,D2			; reset z
		BRA cont

; Plot the balls to the screen

Plot_em		LEA old_pos1+2(PC),A3		; assume case 1
		TST switch
		BNE.S .case_1
.case_2		LEA old_pos2+2(PC),A3		; no its case 2!
.case_1		LEA mul_160(PC),A1
		LEA translated(PC),A4		; translated co-ords
		LEA xlookup(PC),A5
		LEA ballzlookup(PC),A6		; z lookup(ball size)
		MOVE.L log_base(pc),d3
		MOVE.W #319-16,D4		; clip x
		MOVE.W #199-16,D5		; clip y
		PEA (A3)
		
plot_ball	MACRO
		MOVE.L D3,A2			; screen base in A2
		MOVEM.W (A4)+,D0-D2
		CMP D5,D1			; clip y
		BCC .noplot\@
		CMP D4,D0			; clip x
		BCC .noplot\@
		ADD D2,D2			; z*2
		ADD D0,D0
		ADD D0,D0			; x*4
		MOVE.L (A5,D0),D0
		ADD D1,D1			
		ADD.W (A1,D1),D0		; add screen line
		ADD.W D0,A2
		MOVE.W D0,(A3)+
		SWAP D0
		ADD.W (A6,D2),D0		; add z buf ptr.(sprite size) 
		LEA routs(PC),A0
		MOVE.L (A0,D0),A0
		JSR (A0)
.noplot\@
		ENDM

		REPT no_strs
		plot_ball
		ENDR
		MOVE.L (SP)+,A0
		SUB.L A0,A3
		MOVE.W A3,D0
		LSR #1,D0
		MOVE.W D0,-(A0)			; store no. of sprites
		RTS


; My little vbl interrupt.

my_vbl		ADDQ #1,vbl_timer
		RTE

; Initialisation and restore interrupt routs.

set_ints	move #$2700,sr
		lea old_stuff(pc),a0
		move.l $70.w,(a0)+
		lea my_vbl(pc),a1
		move.l a1,$70.w
		lea $fffffa00.w,a1
		movep.w 7(a1),d0
		move.w d0,(a0)+
		movep.w 13(a1),d0
		move.w d0,(a0)+
		moveq #0,d0
		movep.w d0,7(a1)
		movep.w d0,13(a1)
		move #$2300,sr
		bsr flush
		rts

rest_ints	move #$2700,sr
		lea old_stuff(pc),a0
		move.l (a0)+,$70.w
		lea $fffffa00.w,a1
		move.w (a0)+,d0
		movep.w d0,7(a1)
		move.w (a0)+,d0
		movep.w d0,13(a1)
		bsr flush
		move #$2300,sr
		rts

; Flush keyboard Buffer

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S .flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
.flok		RTS

old_stuff	ds.l 10
old_cols	ds.w 16

; Allocate space for screens and clear them...

Initscreens	lea log_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)+
		add.l #32000,d0
		move.l d0,(a1)+
		move.l log_base(pc),a0
		bsr clear_screen
		move.l phy_base(pc),a0
		bsr clear_screen
		move.l log_base(pc),d0
		lsr #8,d0
		move.l d0,$ffff8200.w
		rts

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #1999,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

; Rout to create the sprite routines(calls below rout)

Makeballrouts	LEA ball16,A0
		LEA shiftedball,A1
		LEA routs(PC),A6
		MOVEQ #7,D0
.lp		MOVE.L A0,Sprite_addr
		MOVEM.L D0/A0,-(SP)
		BSR Shift_sprite
		MOVEM.L (SP)+,D0/A0
		LEA 8*16(A0),A0
		DBF D0,.lp
		RTS

; Routine to shift a 4 plane sprite A1 -> to buffer for shifted sprite.
; Creates routine which is intelligently constructed.
; I reckon the code this now produces is about as optimum as possible!! 

Shift_sprite	MOVEA.L	Sprite_addr(PC),A2
		LEA data_buf(PC),A0
		MOVEQ #0,D0
		MOVEQ #spheight-1,D1
.moveto		MOVE.L (A2)+,(A0)+ 
		MOVE.L (A2)+,(A0)+ 
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		DBF D1,.moveto
		MOVEQ #15,D0
Spr_Shift_lp	MOVE.W D0,-(SP)
		LEA data_buf(PC),A2
		MOVE.L A1,(A6)+
		MOVEQ #spheight-1,D6
		CLR D0
init_mask	MOVEQ #1,D7
.lp		MOVEM.L	(A2)+,D1-D2
		MOVE.L D1,D3		
		OR.L D2,D3			; 1+3/2+4
		MOVE.W D3,D5
		SWAP D3
		OR.W D3,D5 			; d5 has mask
		BNE.S .tisdata			; if not 0 we have sprite data
		ADDQ #8,D0			; otherwise skip chunk
		BRA .nextline
.tisdata	TST D0				; we have sprite data
		BEQ.S .noskip 					
		CMP #8,D0
		BNE.S .notquicky
		MOVE.W daddq8(PC),(A1)+
		BRA.S .reset
.notquicky	MOVE.W dlea(PC),(A1)+		; so if need be advance 
		MOVE.W D0,(A1)+			; scr ptr from previous
.reset		CLR D0				; misses and reset
.noskip		NOT.W D5
		BNE.S .needsmask		; zero mask do with 'moves'
		MOVE.W dmove2(PC),(A1)+
		MOVE.L D1,(A1)+
		MOVE.W dmove2(PC),(A1)+
		MOVE.L D2,(A1)+
		BRA .nextline
; Needs to be masksed
.needsmask	MOVE.W dmove1(PC),(A1)+ ;MOVE.L #$12345678,D0
		MOVE.W D5,(A1)+
		MOVE.W D5,(A1)+

.planes12	TST.L D1
		BNE.S .yespl12
		MOVE.W dand2(PC),(A1)+  ;AND.L D0,(A2)+
		BRA.S .planes34
.yespl12	CMP.L #127,D1
		BPL.S .norm12
		CMP.L #-128,D1
		BMI.S .norm12
		AND #$00FF,D1
		OR #$7200,D1		;MOVEQ #XX,D1
		MOVE.W dand1(PC),(A1)+  ;AND.L D0,(A2)
		MOVE.W D1,(A1)+
		MOVE.W dor1(PC),(A1)+
		BRA.S .planes34
.norm12		MOVE.W dand1(PC),(A1)+  ;AND.L D0,(A2)
		MOVE.W dor(PC),(A1)+	;OR.L #$12345678,(A2)+
		MOVE.L D1,(A1)+

.planes34	TST.L D2
		BNE.S .yespl34
		MOVE.W dand2(PC),(A1)+  ;AND.L D0,(A2)+
		BRA.S .nextline
.yespl34	CMP.L #127,D2
		BPL.S .norm34
		CMP.L #-128,D2
		BMI.S .norm34
		AND #$00FF,D2
		OR #$7200,D2		;MOVEQ #XX,D1
		MOVE.W dand1(PC),(A1)+  ;AND.L D0,(A2)
		MOVE.W D2,(A1)+
		MOVE.W dor1(PC),(A1)+
		BRA.S .nextline
.norm34		MOVE.W dand1(PC),(A1)+  ;AND.L D0,(A2)
		MOVE.W dor(PC),(A1)+	;OR.L #$12345678,(A2)+
		MOVE.L D2,(A1)+

.nextline	DBF D7,.lp
		ADD #160-16,D0
		DBF D6,init_mask
		MOVE drts(PC),(A1)+

		LEA data_buf(PC),A0
		MOVEQ #spheight-1,D1
shiftit		REPT 4
		LSR (A0)+
		ROXR 6(A0)
		ENDR
		LEA 8(A0),A0
		DBF D1,shiftit
		MOVE.W (SP)+,D0
		DBF D0,Spr_Shift_lp
		RTS

dmove1		MOVE.L #$12345678,D0
dmove2		MOVE.L #$12345678,(A2)+
dand1		AND.L D0,(A2)
dand2		AND.L D0,(A2)+
dor		OR.L #$12345678,(A2)+
dor1		OR.L D1,(A2)+
dlea		LEA 4(A2),A2
daddq4		ADDQ.W #4,A2
daddq8		ADDQ.W #8,A2
drts		RTS

Sprite_addr	DC.L 0
data_buf	DS.B spheight*16

; Random number generator for initial ball positions...

Random_gen	LEA seed(PC),A2
		LEA stars(PC),A3
		MOVE #no_strs-1,D4
.f_rand_x	BSR Rand
		DIVU #400,D0
		SWAP D0
		SUB #200,D0
		MOVE D0,(A3)+
.f_rand_y	BSR Rand
		DIVU #300,D0
		SWAP D0
		SUB #150,D0
		MOVE D0,(A3)+
		BSR Rand
		AND #$1FF,D0
		SUB #$100,D0
		MOVE D0,(A3)+
		DBF D4,.f_rand_x
		RTS

Rand		MOVEQ #0,D0
		MOVE (A2),D0
		ROL #1,D0
		EOR #54341,D0
		SUBQ #1,D0		
		MOVE D0,(A2)
		RTS

seed		DC.W $5496
log_base 	DC.L 0
phy_base 	DC.L 0
switch		DS.W 1
vbl_timer	DS.W 1
angles		DS.W 3

ballpal1	dc.w	$000,$100,$200,$310,$420,$531,$642,$764
		dc.w	$700,$700,$700,$700,$700,$700,$700,$700

;
; Lookup tables for ball starfied e.g screen offsets and preshift offsets.
;

ballzlookup	DCB.W 32,0*64		; overflow...
		DCB.W 32,0*64
		DCB.W 32,1*64
		DCB.W 32,2*64
		DCB.W 32,3*64
		DCB.W 32,4*64
		DCB.W 32,5*64
		DCB.W 32,6*64
		DCB.W 32,7*64
		DCB.W 32,7*64		; overflow...

; X lookup (offset within preshift and screen plane ptr)

routs		DS.L 16*8
	
i		SET 0
xlookup		REPT 20
		DC.W 0*4,i
		DC.W 1*4,i
		DC.W 2*4,i
		DC.W 3*4,i
		DC.W 4*4,i
		DC.W 5*4,i
		DC.W 6*4,i
		DC.W 7*4,i
		DC.W 8*4,i
		DC.W 9*4,i
		DC.W 10*4,i
		DC.W 11*4,i
		DC.W 12*4,i
		DC.W 13*4,i
		DC.W 14*4,i
		DC.W 15*4,i
i		SET i+8
		ENDR

; Standard Tables...

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

; Y * 160 lookup table

i		set 0
mul_160		rept 200
		dc.w i
i		set i+160
		endr

ball16		incbin balls16.spr

		SECTION BSS
stars 		DS.W no_strs*3
old_pos1	DS.W no_strs+1
old_pos2	DS.W no_strs+1
translated	DS.W no_strs*3
		DS.L 199
stack		DS.L 2
screens		DS.B 256
		DS.B 32000
		DS.B 32000
		DS.B 256
shiftedball	
