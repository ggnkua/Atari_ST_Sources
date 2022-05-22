* The Introscreen by Griff.
* with rotating starfield and
* quite a large 4 plane sprite.

		OPT O+,OW-

demo		EQU 0
no_strs	EQU 176

		IFEQ demo
		CLR -(SP)
		PEA $FFFFFFFF.W		
		PEA $FFFFFFFF.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 10(SP),SP
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		ENDC	

		MOVE #$2700,SR
		MOVE.L SP,oldsp
		LEA stack,SP
		MOVE #$8240,A0
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		CLR.L (A0)+
		LEA log_base(PC),A0
		MOVE.L #screens+256,D0
		CLR.B D0
		MOVE.L D0,(A0)+
		ADD.L #57600,D0
		MOVE.L D0,(A0)
		MOVE.L D0,A0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVE #3999,D0
		MOVEQ #0,D1
clfirst	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,clfirst
interrupts	LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVEQ #1,D0
		JSR music+28
		MOVE.L #first_vbl,$70.W
		MOVE.W #$700,$FFFF8242.W
		STOP #$2300

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
;               The 'fucking spinning' the logo					;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

; Do the pixel test


pointtest	LEA the,A0
		LEA thexs,A1				; xs'
		LEA 128*56(A1),A2				; ys'
		LEA 256*56(A1),A3				; zs'
		LEA 384*56(A1),A4				; colours'
		MOVE #-14,D1
theline	MOVE #-64,D0
		MOVEQ #7,D3
chunk_lp	MOVEM.W (A0)+,D4-D7
		REPT 16
		CLR D2
		ADD D7,D7
		ADDX D2,D2
		ADD D6,D6
		ADDX D2,D2
		ADD D5,D5
		ADDX D2,D2
		ADD D4,D4
		ADDX D2,D2
		MOVE.W D0,(A1)+			store x
		MOVE.W D1,(A2)+			store y
		MOVE.W #1,(A3)+			store z
		lsl #4,D2				16 bytes per routine.
		MOVE.W D2,(A4)+			store colour
		ADDQ #1,D0
		ENDR
		DBF D3,chunk_lp
		ADDQ #1,D1
		CMP #14,D1
		BNE theline
; Do the frames... translating 3584 points for 42 frames!!!!
		LEA frames,A6		
		LEA calc_trig,A1				; sin 
		LEA $200(A1),A0
		MOVE #42,-(SP)
fucking	MOVEQ #0,D1
		MOVEQ #0,D2				
		MOVEQ #0,D3				
		MOVEQ #0,D4				
		MOVEQ #0,D5				
		MOVEQ #0,D6				
		MOVE.L log_base(PC),a2
		MOVEQ #33,d7
clrthe_lp	MOVEM.L D1-D6,(a2)
		MOVEM.L D1-D6,24(a2)
		MOVEM.L D1-D4,48(a2)
		LEA 160(a2),a2
		dbf d7,clrthe_lp
		LEA thexs,A2				; xs'
		LEA 128*56(A2),A3				; ys'
		LEA 256*56(A2),A4				; zs'
		LEA 384*56(A2),A5				; colours'
		MOVE.W (A0),D0
		MOVE.W (A1),D1
		MOVEM.L A0-A1,-(sp)
		MOVE #3583,D7
translate	MOVE.W (A5)+,D5
		BEQ done1
		MOVE.W (A2)+,D2				; x(j)		
		MOVE.W (A3)+,D3				; y(j)
		MOVE.W (A4)+,D4				; z(j)
		MOVE.L D2,D5				; dup x(j)
		MOVE.L D4,D6				; dup z(j)
		MULS D0,D2					; x(j)*cos(y)
		MULS D1,D4					; z(j)*sin(y) 
		SUB.L D4,D2
		ADD.L D2,D2
		SWAP D2					; xnew!!!
		MULS D1,D5					; x(j)*sin(y)
		MULS D0,D6					; z(j)*cos(y)
		ADD.L D6,D5
		ADD.L D5,D5
		SWAP D5
; x - D2 y - D3  z - D5
		EXT.L D2
		EXT.L D3
		ASL.L #7,D2					; x*dist
		ASL.L #7,D3					; y*dist
		ADD #178,D5
		DIVS D5,D2
		DIVS D5,D3
		ADD #66,D2		
		ADD #16,D3		
		movem.w d2/d3,-(sp)
		bsr plot
		movem.w (sp)+,d2/d3
		addq #1,d2
		bsr plot
		DBF D7,translate
		BRA done1frame
done1		ADDQ.L #2,A2
		ADDQ.L #2,A3
		ADDQ.L #2,A4
		DBF D7,translate
done1frame	MOVE.L log_base(PC),A0
		MOVEQ #33,D7
cpyframelp	REPT 16
		MOVE.L (A0)+,(A6)+
		ENDR
		LEA 96(A0),A0    
		DBF D7,cpyframelp
		MOVEM.L (SP)+,A0-A1
		LEA 48(a0),a0
		LEA 48(a1),a1
		SUBQ #1,(sp)
		BNE fucking
		ADDQ.L #2,SP
		BRA shift_sprte

plot		add.w	d2,d2
		add.w	d2,d2				Long access.
		move.l xoff(pc,d2),d2
		add.w d3,d3
		add.w qmul(pc,d3),d2
		MOVE.L log_base(PC),a0		Get screen address (tee-hee!).
		adda.w d2,a0			Now add it to screenbase.
		swap d2
		move.w d2,d3			Get point data.
		not.w	d2				Inverse mask it.
		lea col0(pc),a1
		ADD.W -2(a5),a1			Get colour.
		JMP (a1)				Execute point routine.
i		set 0
qmul		rept 32
		dc.w i
i		set i+160
		endr
i		set 0	
xoff:		rept 20
		dc.w $8000,i
		dc.w $4000,i
		dc.w $2000,i
		dc.w $1000,i
		dc.w $0800,i
		dc.w $0400,i
		dc.w $0200,i
		dc.w $0100,i
		dc.w $0080,i
		dc.w $0040,i
		dc.w $0020,i
		dc.w $0010,i
		dc.w $0008,i
		dc.w $0004,i
		dc.w $0002,i
		dc.w $0001,i
i		set i+8
		endr
col0:		and.w	d2,(a0)+
		and.w	d2,(a0)+
		and.w	d2,(a0)+
		and.w	d2,(a0)
		rts
		ds.w 3
col1:		or.w	d3,(a0)+
		and.w	d2,(a0)+
		and.w	d2,(a0)+
		and.w	d2,(a0)
		rts
		ds.w 3
col2:		and.w	d2,(a0)+
		or.w	d3,(a0)+
		and.w	d2,(a0)+
		and.w	d2,(a0)
		rts
		ds.w 3
col3:		or.w	d3,(a0)+
		or.w	d3,(a0)+
		and.w	d2,(a0)+
		and.w	d2,(a0)
		rts
		ds.w 3
col4:		and.w	d2,(a0)+
		and.w	d2,(a0)+
		or.w	d3,(a0)+
		and.w	d2,(a0)
		rts
		ds.w 3
col5:		or.w	d3,(a0)+
		and.w	d2,(a0)+
		or.w	d3,(a0)+
		and.w	d2,(a0)
		rts
		ds.w 3
col6:		and.w	d2,(a0)+
		or.w	d3,(a0)+
		or.w	d3,(a0)+
		and.w	d2,(a0)
		rts
		ds.w 3
col7:		or.w	d3,(a0)+
		or.w	d3,(a0)+
		or.w	d3,(a0)+
		and.w	d2,(a0)
		rts
		ds.w 3
col8:		and.w	d2,(a0)+
		and.w	d2,(a0)+
		and.w	d2,(a0)+
		or.w	d3,(a0)
		rts
		ds.w 3
col9:		or.w	d3,(a0)+
		and.w	d2,(a0)+
		and.w	d2,(a0)+
		or.w	d3,(a0)
		rts
		ds.w 3
col10:	and.w	d2,(a0)+
		or.w	d3,(a0)+
		and.w	d2,(a0)+
		or.w	d3,(a0)
		rts
		ds.w 3
col11:	or.w	d3,(a0)+
		or.w	d3,(a0)+
		and.w	d2,(a0)+
		or.w	d3,(a0)
		rts
		ds.w 3
col12:	and.w	d2,(a0)+
		and.w	d2,(a0)+
		or.w	d3,(a0)+
		or.w	d3,(a0)
		rts
		ds.w 3
col13:	or.w	d3,(a0)+
		and.w	d2,(a0)+
		or.w	d3,(a0)+
		or.w	d3,(a0)
		rts
		ds.w 3
col14:	and.w	d2,(a0)+
		or.w	d3,(a0)+
		or.w	d3,(a0)+
		or.w	d3,(a0)
		rts
		ds.w 3
col15:	or.w	d3,(a0)+
		or.w	d3,(a0)+
		or.w	d3,(a0)+
		or.w	d3,(a0)
		rts

* Preshift le big sprite...

shift_sprte	LEA bigbuggers,A2
		MOVEQ #14,D7
		LEA bigbugger,A0
copyfrom	MOVE.L log_base(PC),A1
		MOVEQ #78,D2
copyfromlp	REPT 18
		MOVE.L (A0)+,(A1)+
		ENDR
		LEA 88(A1),A1
		DBF D2,copyfromlp
shift_lp	MOVE.L log_base(PC),A1
		MOVEQ #78,D2
shift1_lp	MOVEQ #3,D3
pl1_lp	LSR (A1)+
		ROXR 6(A1)
		ROXR 14(A1)
		ROXR 22(A1)
		ROXR 30(A1)
		ROXR 38(A1)
		ROXR 46(A1)
		ROXR 54(A1)
		ROXR 62(A1)
		ROXR 70(A1)
		DBF D3,pl1_lp
		LEA 152(A1),A1
		DBF D2,shift1_lp

copyto	MOVE.L log_base(PC),A1
		MOVEQ #78,D2
copytolp	REPT 18
		MOVE.L (A1)+,(A2)+
		ENDR
		LEA 88(A1),A1
		DBF D2,copytolp
		DBF D7,shift_lp

		
Pre_shift	LEA sprite_buf,A0
		LEA sprites,A2
		MOVEQ #5,D5
spr_lp	MOVEQ #0,D6
sh_lp		MOVE.L A2,A1
		MOVEQ #17,D7
li_lp		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #-1,D4
		MOVE (A1)+,D0
		MOVE (A1)+,D1
		MOVE (A1)+,D2
		MOVE (A1)+,D3
		MOVE D0,D4
		OR D1,D4
		OR D2,D4
		OR D3,D4
		NOT D4
		ROR.L D6,D0
		ROR.L D6,D1
		ROR.L D6,D2
		ROR.L D6,D3
		ROR.L D6,D4
		MOVE D4,(A0)+
		MOVE D4,(A0)+
		MOVE D0,(A0)+
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		MOVE D3,(A0)+
		SWAP D0
		SWAP D1
		SWAP D2
		SWAP D3
		SWAP D4
		MOVE D4,(A0)+
		MOVE D4,(A0)+
		MOVE D0,(A0)+
		MOVE D1,(A0)+
		MOVE D2,(A0)+
		MOVE D3,(A0)+
		DBF D7,li_lp	
		ADDQ #1,D6
		CMP #16,D6
		BNE.S sh_lp
		LEA 8*18(A2),A2
		DBF D5,spr_lp

* Generate times 160 table for screen y.

Gen160tab	LEA mulu_160(PC),A1
		SUB.L A0,A0
		MOVE #269,D0
gen160t_lp	MOVE.L A0,(A1)+
		LEA 160(A0),A0
		DBF D0,gen160t_lp
 
;-----------------------------------------------------------------------;
; This bit generates a big table of numbers which are co-ords		;
; for every star position.This means the star plotter is fuckin' fast	;	
;-----------------------------------------------------------------------;

Genstars	LEA stars(PC),A0
		MOVE #no_strs-1,D7
genoffy_lp	MOVEM.W (A0)+,D0-D2
		ASL.L #8,D0
		ASL.L #8,D1
		MOVE D0,-6(A0)
		MOVE D1,-4(A0)
		DBF D7,genoffy_lp
Main_gen	LEA big_buf,A0
		LEA stars(PC),A1		star co-ords
		LEA offsets(PC),A2
		LEA mulu_160(PC),A3
		MOVE.L A0,(A2)+
		MOVE #no_strs-1,D7
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
genstar_lp	MOVE (A1)+,D0		get x
		MOVE (A1)+,D1		get y
		MOVE (A1),D2		get z
		SUBQ #3,D2			z=z-4 (perspect)
		MOVE D2,(A1)
		SUBQ.L #4,A1
		EXT.L D0			extend sign
		EXT.L D1			ready for divide
		DIVS D2,D0			x/z(perspect)
		DIVS D2,D1			y/z(perspect)
		ADD #160,D0			add offsets
		ADD #130,D1			
		CMP #319,D0
		BHI.S Star_off
		CMP #266,D1
		BHI.S Star_off
		MOVE D0,D3
		ADD D1,D1
		ADD D1,D1
		MOVE.L (A3,D1),D1
		SUB.L #139*160,D1
		LSR #1,D0
		AND.B #$F8,D0
		ADD D0,D1
		SUBQ #2,D1
		MOVE.W D1,(A0)+
		NOT D3
		AND #15,D3
		MOVEQ #0,D1
		BSET D3,D1
		MOVE.W D1,(A0)+
		ASR #6,D2
		BLE.S white
		CMP #1,D2
		BNE.S notc1
white		BRA doneit
notc1		CMP #2,D2
		BNE.S notc2
		ADDQ #2,-4(A0)
		BRA doneit
notc2		ADDQ #4,-4(A0)
doneit	BRA genstar_lp

Star_off	MOVEQ #0,D1
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L A0,(A2)+
		ADDQ.L #6,A1
		DBF D7,genstar_lp

;-----------------------------------------------------------------------;
;	     		   Calc initial random offsets.				;
;-----------------------------------------------------------------------;

		LEA offsets(PC),A0
		LEA offsettab(PC),A1
		LEA seed(PC),A2
		MOVE #no_strs-1,D7
rands		MOVE.L (A0)+,D0
		MOVE.L (A0),D1
		SUB.L D0,D1
		ASR.L #2,D1
		SUBQ #1,D1
		MOVEQ #0,D2
		MOVE (A2),D2		
		ROL #1,D2			
		EOR #54321,D2
		SUBQ #1,D2		
		MOVE D2,(A2)	
		DIVU D1,D2						
		CLR D2
		SWAP D2
		ASL.L #2,D2
		ADD.L D2,D0
		MOVE.L D0,(A1)+
		DBF D7,rands			

CLS		MOVE.L log_base(PC),A0
		MOVEQ #0,D1
		MOVE #(46480+46480+256)/16-1,D0
cls_lp	MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp

moreints	MOVE.W #$2700,SR
		MOVE.B #$21,$FFFFFA07.W
		MOVE.B #$00,$FFFFFA09.W
		MOVE.B #$21,$FFFFFA13.W
		MOVE.B #$00,$FFFFFA15.W
		CLR.B $FFFFFA1B.W
		CLR.B $FFFFFA21.W
		CLR.B $FFFFFA19.W
		CLR.B $FFFFFA1F.W
		BCLR.B #3,$FFFFFA17.W
		MOVE.L #my_vbl,$70.W
		MOVE.L #remove_bot,$120.W
set_pal	MOVE #$8240,A0
		MOVE.L #$00000666,(A0)+
		MOVE.L #$04440333,(A0)+
		MOVE.L #$02220102,(A0)+
		MOVE.L #$02030304,(A0)+
		MOVE.L #$04050506,(A0)+
		MOVE.L #$02000300,(A0)+
		MOVE.L #$04000500,(A0)+
		MOVE.L #$06000111,(A0)+
		MOVE #$2300,SR

;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;
; 			 This is the main program loop!  				;
;-----------------------------------------------------------------------;
;-----------------------------------------------------------------------;

VBL_LP	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		LEA vbl_timer(PC),A0
		MOVE (A0),D0
wait_vbl	CMP (A0),D0
		BEQ.S wait_vbl

; Clear the 176 old stars.

clear_old	LEA old_pos1(PC),A0
		NOT switch
		BNE.S .case_2
.case_1	LEA old_pos2(PC),A0
.case_2	MOVEQ #0,D0
		REPT 29
		MOVEM.L (A0)+,A1-A6
		MOVE.L D0,(A1)
		MOVE.L D0,(A2)
		MOVE.L D0,(A3)
		MOVE.L D0,(A4)
		MOVE.L D0,(A5)
		MOVE.L D0,(A6)
		ENDR
		MOVEM.L (A0)+,A1-A2
		MOVE.L D0,(A1)
		MOVE.L D0,(A2)

; Clear the old 11 sprites

		LEA spoldoff1(pc),a6
		TST switch
		BNE.S spcl1
		LEA spoldoff2(pc),a6
spcl1		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEM.L (A6)+,A0-A5
		MOVEM.L D0-D3,(A0)
		MOVEM.L D0-D3,160(A0)
		MOVEM.L D0-D3,320(A0)
		MOVEM.L D0-D3,480(A0)
		MOVEM.L D0-D3,640(A0)
		MOVEM.L D0-D3,800(A0)
		MOVEM.L D0-D3,960(A0)
		MOVEM.L D0-D3,1120(A0)
		MOVEM.L D0-D3,1280(A0)
		MOVEM.L D0-D3,1440(A0)
		MOVEM.L D0-D3,1600(A0)
		MOVEM.L D0-D3,1760(A0)
		MOVEM.L D0-D3,1920(A0)
		MOVEM.L D0-D3,2080(A0)
		MOVEM.L D0-D3,2240(A0)
		MOVEM.L D0-D3,2400(A0)
		MOVEM.L D0-D3,2560(A0)
		MOVEM.L D0-D3,2720(A0)
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
		MOVEM.L D0-D3,2560(A1)
		MOVEM.L D0-D3,2720(A1)
		MOVEM.L D0-D3,(A2)
		MOVEM.L D0-D3,160(A2)
		MOVEM.L D0-D3,320(A2)
		MOVEM.L D0-D3,480(A2)
		MOVEM.L D0-D3,640(A2)
		MOVEM.L D0-D3,800(A2)
		MOVEM.L D0-D3,960(A2)
		MOVEM.L D0-D3,1120(A2)
		MOVEM.L D0-D3,1280(A2)
		MOVEM.L D0-D3,1440(A2)
		MOVEM.L D0-D3,1600(A2)
		MOVEM.L D0-D3,1760(A2)
		MOVEM.L D0-D3,1920(A2)
		MOVEM.L D0-D3,2080(A2)
		MOVEM.L D0-D3,2240(A2)
		MOVEM.L D0-D3,2400(A2)
		MOVEM.L D0-D3,2560(A2)
		MOVEM.L D0-D3,2720(A2)
		MOVEM.L D0-D3,(A3)
		MOVEM.L D0-D3,160(A3)
		MOVEM.L D0-D3,320(A3)
		MOVEM.L D0-D3,480(A3)
		MOVEM.L D0-D3,640(A3)
		MOVEM.L D0-D3,800(A3)
		MOVEM.L D0-D3,960(A3)
		MOVEM.L D0-D3,1120(A3)
		MOVEM.L D0-D3,1280(A3)
		MOVEM.L D0-D3,1440(A3)
		MOVEM.L D0-D3,1600(A3)
		MOVEM.L D0-D3,1760(A3)
		MOVEM.L D0-D3,1920(A3)
		MOVEM.L D0-D3,2080(A3)
		MOVEM.L D0-D3,2240(A3)
		MOVEM.L D0-D3,2400(A3)
		MOVEM.L D0-D3,2560(A3)
		MOVEM.L D0-D3,2720(A3)
		MOVEM.L D0-D3,(A4)
		MOVEM.L D0-D3,160(A4)
		MOVEM.L D0-D3,320(A4)
		MOVEM.L D0-D3,480(A4)
		MOVEM.L D0-D3,640(A4)
		MOVEM.L D0-D3,800(A4)
		MOVEM.L D0-D3,960(A4)
		MOVEM.L D0-D3,1120(A4)
		MOVEM.L D0-D3,1280(A4)
		MOVEM.L D0-D3,1440(A4)
		MOVEM.L D0-D3,1600(A4)
		MOVEM.L D0-D3,1760(A4)
		MOVEM.L D0-D3,1920(A4)
		MOVEM.L D0-D3,2080(A4)
		MOVEM.L D0-D3,2240(A4)
		MOVEM.L D0-D3,2400(A4)
		MOVEM.L D0-D3,2560(A4)
		MOVEM.L D0-D3,2720(A4)
		MOVEM.L D0-D3,(A5)
		MOVEM.L D0-D3,160(A5)
		MOVEM.L D0-D3,320(A5)
		MOVEM.L D0-D3,480(A5)
		MOVEM.L D0-D3,640(A5)
		MOVEM.L D0-D3,800(A5)
		MOVEM.L D0-D3,960(A5)
		MOVEM.L D0-D3,1120(A5)
		MOVEM.L D0-D3,1280(A5)
		MOVEM.L D0-D3,1440(A5)
		MOVEM.L D0-D3,1600(A5)
		MOVEM.L D0-D3,1760(A5)
		MOVEM.L D0-D3,1920(A5)
		MOVEM.L D0-D3,2080(A5)
		MOVEM.L D0-D3,2240(A5)
		MOVEM.L D0-D3,2400(A5)
		MOVEM.L D0-D3,2560(A5)
		MOVEM.L D0-D3,2720(A5)
		MOVEM.L (A6)+,A0-A4
		MOVEM.L D0-D3,(A0)
		MOVEM.L D0-D3,160(A0)
		MOVEM.L D0-D3,320(A0)
		MOVEM.L D0-D3,480(A0)
		MOVEM.L D0-D3,640(A0)
		MOVEM.L D0-D3,800(A0)
		MOVEM.L D0-D3,960(A0)
		MOVEM.L D0-D3,1120(A0)
		MOVEM.L D0-D3,1280(A0)
		MOVEM.L D0-D3,1440(A0)
		MOVEM.L D0-D3,1600(A0)
		MOVEM.L D0-D3,1760(A0)
		MOVEM.L D0-D3,1920(A0)
		MOVEM.L D0-D3,2080(A0)
		MOVEM.L D0-D3,2240(A0)
		MOVEM.L D0-D3,2400(A0)
		MOVEM.L D0-D3,2560(A0)
		MOVEM.L D0-D3,2720(A0)
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
		MOVEM.L D0-D3,2560(A1)
		MOVEM.L D0-D3,2720(A1)
		MOVEM.L D0-D3,(A2)
		MOVEM.L D0-D3,160(A2)
		MOVEM.L D0-D3,320(A2)
		MOVEM.L D0-D3,480(A2)
		MOVEM.L D0-D3,640(A2)
		MOVEM.L D0-D3,800(A2)
		MOVEM.L D0-D3,960(A2)
		MOVEM.L D0-D3,1120(A2)
		MOVEM.L D0-D3,1280(A2)
		MOVEM.L D0-D3,1440(A2)
		MOVEM.L D0-D3,1600(A2)
		MOVEM.L D0-D3,1760(A2)
		MOVEM.L D0-D3,1920(A2)
		MOVEM.L D0-D3,2080(A2)
		MOVEM.L D0-D3,2240(A2)
		MOVEM.L D0-D3,2400(A2)
		MOVEM.L D0-D3,2560(A2)
		MOVEM.L D0-D3,2720(A2)
		MOVEM.L D0-D3,(A3)
		MOVEM.L D0-D3,160(A3)
		MOVEM.L D0-D3,320(A3)
		MOVEM.L D0-D3,480(A3)
		MOVEM.L D0-D3,640(A3)
		MOVEM.L D0-D3,800(A3)
		MOVEM.L D0-D3,960(A3)
		MOVEM.L D0-D3,1120(A3)
		MOVEM.L D0-D3,1280(A3)
		MOVEM.L D0-D3,1440(A3)
		MOVEM.L D0-D3,1600(A3)
		MOVEM.L D0-D3,1760(A3)
		MOVEM.L D0-D3,1920(A3)
		MOVEM.L D0-D3,2080(A3)
		MOVEM.L D0-D3,2240(A3)
		MOVEM.L D0-D3,2400(A3)
		MOVEM.L D0-D3,2560(A3)
		MOVEM.L D0-D3,2720(A3)
		MOVEM.L D0-D3,(A4)
		MOVEM.L D0-D3,160(A4)
		MOVEM.L D0-D3,320(A4)
		MOVEM.L D0-D3,480(A4)
		MOVEM.L D0-D3,640(A4)
		MOVEM.L D0-D3,800(A4)
		MOVEM.L D0-D3,960(A4)
		MOVEM.L D0-D3,1120(A4)
		MOVEM.L D0-D3,1280(A4)
		MOVEM.L D0-D3,1440(A4)
		MOVEM.L D0-D3,1600(A4)
		MOVEM.L D0-D3,1760(A4)
		MOVEM.L D0-D3,1920(A4)
		MOVEM.L D0-D3,2080(A4)
		MOVEM.L D0-D3,2240(A4)
		MOVEM.L D0-D3,2400(A4)
		MOVEM.L D0-D3,2560(A4)
		MOVEM.L D0-D3,2720(A4)

; Put the rather large Inner
; circle onto the screen disting...

i		SET 0
j		SET 0
Putbiggy	MOVE.L log_base(PC),A6
		LEA (70*160)-32(A6),A6
		LEA disttab(PC),A5
		REPT 7
		MOVE.L (A5)+,A1
		LEA j+16(A6),A0
		ADD (A5)+,A0
		MOVEM.L i+16(A1),D0-D6/A2-A4
		MOVEM.L D0-D6/A2-A4,(A0)
i		SET i+72
j		SET j+160
		ENDR
		REPT 6
		MOVE.L (A5)+,A1
		LEA i+8(A1),A1
		LEA j+8(A6),A0
		ADD (A5)+,A0
		MOVEM.L (A1)+,D0-D7/A2-A4
		MOVEM.L D0-D7/A2-A4,(A0)  
		MOVEM.L (A1)+,D0-D2
		MOVEM.L D0-D2,44(A0)
i		SET i+72
j		SET j+160
		ENDR
		REPT 2
		MOVE.L (A5)+,A1
		LEA i(A1),A1
		LEA j(A6),A0
		ADD (A5)+,A0
		MOVEM.L (A1)+,D0-D7/A2-A4
		MOVEM.L D0-D7/A2-A4,(A0)  
		MOVEM.L (A1)+,D0-D6
		MOVEM.L D0-D6,44(A0)
i		SET i+72
j		SET j+160
		ENDR

		DCB.W 21,$4E71
		CLR.B $FFFF820A.W
		DCB.W 34,$4E71
		MOVE.B #2,$FFFF820A.W	

		REPT 7
		MOVE.L (A5)+,A1
		LEA i(A1),A1
		LEA j(A6),A0
		ADD (A5)+,A0
		MOVEM.L (A1)+,D0-D7/A2-A4
		MOVEM.L D0-D7/A2-A4,(A0)  
		MOVEM.L (A1)+,D0-D6
		MOVEM.L D0-D6,44(A0)
i		SET i+72
j		SET j+160
		ENDR

		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.L D0,A3
		MOVE.L D0,A4
		REPT 35
		MOVE.L (A5)+,A1
		LEA i(A1),A1
		LEA j-8(A6),A0
		ADD (A5)+,A0
		MOVEM.L (A1)+,D2-D7/A2
		MOVEM.L D0-D7/A2,(A0)  
		MOVEM.L (A1)+,D2-D7/A2
		MOVEM.L D2-D7/A2,36(A0)
		MOVEM.L (A1)+,D2-D5
		MOVEM.L D2-D5/A3-A4,64(A0) 
i		SET i+72
j		SET j+160
		ENDR
		REPT 9
		MOVE.L (A5)+,A1
		LEA i(A1),A1
		LEA j(A6),A0
		ADD (A5)+,A0
		MOVEM.L (A1)+,D0-D7/A2-A4
		MOVEM.L D0-D7/A2-A4,(A0)  
		MOVEM.L (A1)+,D0-D6
		MOVEM.L D0-D6,44(A0)
i		SET i+72
j		SET j+160
		ENDR
		REPT 7
		MOVE.L (A5)+,A1
		LEA i+8(A1),A1
		LEA j+8(A6),A0
		ADD (A5)+,A0
		MOVEM.L (A1)+,D0-D7/A2-A4
		MOVEM.L D0-D7/A2-A4,(A0)  
		MOVEM.L (A1)+,D0-D2
		MOVEM.L D0-D2,44(A0)
i		SET i+72
j		SET j+160
		ENDR
		REPT 6
		MOVE.L (A5)+,A1
		LEA j+16(A6),A0
		ADD (A5)+,A0
		MOVEM.L i+16(A1),D0-D6/A2-A4
		MOVEM.L D0-D6/A2-A4,(A0)
i		SET i+72
j		SET j+160
		ENDR

; Put the calculated wave in at
; the end of the table.....

calc_dist	LEA disttab+6(PC),A0
		REPT 8
		MOVEM.L (A0)+,D0-D7/A1-A6
		MOVEM.L D0-D7/A1-A6,-62(A0)
		ENDR
		MOVEM.L (A0)+,D0-D4
		MOVEM.L D0-D4,-26(A0)
		
CALC		LEA trig_tab(PC),A0
		LEA dist_ang(PC),A1
		LEA dister(PC),A3
		MOVE (A1),D0
		ADD dist_step(PC),D0
		AND #$3FF,D0
yep		MOVE D0,(A1)
		MOVE (A3),D1
		ADD dist_step(PC),D1
		CMP maxi_dist(PC),D1
		BLE.S notwang
 		SUB maxi_dist(PC),D1
sel_wave	LEA wave_ptr(PC),A4
		MOVE.L (A4),A1
		LEA dist_step(PC),A2
		MOVE (A1)+,(A2)+
		BPL.S nrapwave 
		LEA wave_tab(PC),A1
		MOVE (A1)+,-2(A2)
nrapwave	MOVE.L (A1)+,(A2)+
		MOVE (A1)+,(A2)+
		MOVE.L A1,(A4)
notwang	MOVE D1,(A3)
		ADDA.W D0,A0
		MOVE (A0),D0
		MULS size(PC),D0
		LSL.L #2,D0
		SWAP D0
		ADD offset(PC),D0
		LEA offtable(PC),A1
		ADD D0,D0
		MOVE D0,D2
		MOVE (A1,D0),D0
		AND #31,D2
		ADD D2,D2
		LEA bigmultab(PC),A0
		MOVE.L (A0,D2),A0
		LEA disttab+(78*6)(PC),A1
		MOVE.L A0,(A1)+
		MOVE.W D0,(A1)

;-----------------------------------------------------------------------;
;  			Put the decade demo logo on screen				;
;-----------------------------------------------------------------------;

putdecade	TST drawing
		BEq out
		MOVEQ #0,D1
		MOVE logo_y(PC),D1
		CMP #180,D1
		BEQ.S logoupped
		SUBQ #1,D1
logoupped	MOVE.W D1,logo_y
		MOVE.L log_base(PC),A1
		MOVE.W D1,D2
		ADD D1,D1
		ADD D1,D1
		ADD D2,D1
		LSL #5,D1
		ADD.L D1,A1
		LEA 16(A1),A1
		LEA decadelogo,A0
i		SET 0
		REPT 31
		MOVEM.L (A0)+,D0-D7/A2-A4
		MOVEM.L D0-D7/A2-A4,i(A1)
		MOVEM.L (A0)+,D0-D7/A2-A4
		MOVEM.L D0-D7/A2-A4,i+44(A1)
		MOVEM.L (A0)+,D0-D7/a2-a3
		MOVEM.L D0-D7/a2-a3,i+88(A1)
i		SET i+160
		ENDR
i		SET i+24
		REPT 28
		LEA 24(A0),A0
		MOVEM.L (A0)+,D0-D7/A2-A6
		MOVEM.L D0-D7/A2-A6,i(A1)
		MOVEM.L (A0)+,D0-D7/A2-A6
		MOVEM.L D0-D7/A2-A6,i+52(A1)
i		SET i+160
		ENDR
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
		MOVEQ #0,D6
		MOVEQ #0,D7
		REPT 2
		MOVEM.L D0-D7,i(A1)
		MOVEM.L D0-D7,i+32(A1)
		MOVEM.L D0-D7,i+64(A1)
		MOVEM.L D0-D7,i+96(A1)
i		SET i+160
		ENDR
out		CMP #120,vbl_timer
		BNE putthe
		MOVE #-1,drawing 

;------------------------------------------------------------------------;
;             Place the spinning 'THE' at the top of the screen		 ;
;------------------------------------------------------------------------;

putthe	MOVE.L frame_cnt,A0
		LEA 34*64(A0),A0
		CMP.L #frames+42*34*64,A0
		BNE.S okayframe
		LEA frames,A0
okayframe	MOVE.L A0,frame_cnt
		MOVE.L log_base(PC),A1
		LEA (7*160)+48(A1),A1
i		SET 0
		REPT 34
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,i(A1)
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,i+32(A1)
i		SET i+160
		ENDR

;------------------------------------------------------------------------;
;			 Now draw the inner circle sprites				 ;
;------------------------------------------------------------------------;

drawsprites	LEA sprite_ptrs(PC),A6
		LEA spptrsoffs(PC),A5
		LEA wave_base(PC),A2
		LEA spoldoff1(PC),A3
		MOVE.L log_base(PC),D6
		ADD.L #16000,D6
		MOVE #$1FFF,D4
		TST switch
		BNE.S spdraw
		LEA spoldoff2(PC),A3
spdraw	MOVEQ #10,D7
spdraw_lp	MOVE.L (A6)+,A0
		MOVE (A5),D2
		ADDQ #4,D2
		AND D4,D2
		MOVE D2,(A5)+ 
		MOVE.L (A2,D2),D0
		MOVE.L D6,A1
		ADD.W D0,A1
		MOVE.L A1,(A3)+
		SWAP D0
		ADD.W D0,A0
		REPT 18
		MOVEM.L (A1),D0-D3
		MOVE.L (A0)+,D5
		AND.L D5,D0
		AND.L D5,D1
		OR.L (A0)+,D0
		OR.L (A0)+,D1
		MOVE.L (A0)+,D5
		AND.L D5,D2
		AND.L D5,D3
		OR.L (A0)+,D2
		OR.L (A0)+,D3
		MOVEM.L D0-D3,(A1)
		LEA 160(A1),A1
		ENDR
		DBF D7,spdraw_lp
		

;------------------------------------------------------------------------;
;                    Plot the stars - from le table.				 ;
;------------------------------------------------------------------------;

plotstars	LEA old_pos1(PC),A5
		TST switch
		BNE.S .case_2
.case_1	LEA old_pos2(PC),A5
.case_2	MOVE.L log_base(PC),A6
		LEA 139*160(A6),A6
		LEA offsets(PC),A0
		LEA offsettab(PC),A1
star		macro
		MOVE.L (A1),A2			get curr star address
		MOVE.L A6,A4		
		ADDA.W (A2)+,A4			got screen address
		MOVE (A4)+,D2			get mask from		
		MOVE.L A4,(A5)+			store for clear
		MOVE.W (A2)+,D1			otherwise plot it!
		BNE.S starokay\@
		MOVE.L i(A0),A2
		BRA.S next_star\@
starokay\@	AND D1,D2				plot point?
		BNE.S next_star\@			no if something on screen
		OR.W D1,(A4)
next_star\@	MOVE.L A2,(A1)+			store new star address
		ENDM
i		set 0
		REPT 176
		star
i		set i+4
		ENDR
starsdone	JSR music+2+28
		BTST.B #0,$FFFFFC00.W
		BEQ VBL_LP
		MOVE.B $FFFFFC02.W,D0
		CMP.B #$39,D0
		BNE VBL_LP


; Exit... the intro (space was pressed!)

endintro
Exit		MOVE #$2700,SR
		MOVEQ #0,D0
		JSR music+28
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		IFEQ demo
		MOVE #$2300,SR
		MOVE #$777,$FFFF8240.W
		MOVE #$000,$FFFF8246.W
		CLR -(SP)
		TRAP #1			
		ENDC		
		MOVE.L oldsp(PC),SP
		RTS

oldsp		DC.L 0
drawing	dc.w 0
logo_y	dc.w 260

first_vbl	movem.l d0-d7/a0-a6,-(sp)
		subq #1,numbertimer
		bne notdisplay
copynum	move.w numbercnt(PC),d0
		mulu #178*12,d0
		lea numbers,a0
		adda.w d0,a0
		move.l log_base+4,a1
		lea 56+(11*160)(a1),a1
		move #177,d0
copynumb	move.w (a0)+,(a1)
		move.w (a0)+,8(a1)
		move.w (a0)+,16(a1)
		move.w (a0)+,24(a1)
		move.w (a0)+,32(a1)
		move.w (a0)+,40(a1)
		lea 160(a1),a1
		dbf d0,copynumb
		move #63,numbertimer
		subq #1,numbercnt
notdisplay	jsr music+2+28
		btst.b #0,$fffffc00.w
		beq outfirst
		move.b $fffffc02.w,d0
		cmp.b #$39,d0
		bne outfirst
		movem.l (sp)+,d0-d7/a0-a6
		pea endintro(pc) 
		move #$2300,-(Sp)
		rte
outfirst	movem.l (sp)+,d0-d7/a0-a6
		rte
numbercnt	dc.w 8
numbertimer	dc.w 1

my_vbl	CLR.B $FFFFFA19.W
		CLR.B $FFFFFA1B.W
		MOVE.B #228,$FFFFFA21.W
		MOVE.B #8,$FFFFFA1B.W
		ADDQ #1,vbl_timer
		RTE

remove_bot	MOVEM.L D0/A0,-(SP)
		MOVE #$8209,A0
.syncb	MOVE.B (A0),D0
		BEQ.S .syncb
		AND #$7E,D0
		JMP noplist(PC,D0)
noplist	DCB.W 105,$4E71
		MOVE.B #0,$FF820A
		DCB.W 12,$4E71
		MOVE.B #2,$FF820A
		MOVEM.L (SP)+,D0/A0
		RTE

wave_base	INCBIN INTRO.INC\SPWAVE.DAT

calc_trig	dc.w	$0000,$00C9,$0192,$025B,$0324,$03ED,$04B6,$057E 
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

trig_tab	rept 2
		dc.l	$0000019B,$032304BE,$064507DE,$09630AF9,$0C7C0E0E 
		dc.l	$0F8C111A,$1293141B,$158F1710,$187D19F7,$1B5C1CCE 
		dc.l	$1E2B1F93,$20E62244,$238E24E1,$261F2766,$289929D4 
		dc.l	$2AFA2C27,$2D412E5F,$2F6B307B,$31783279,$33673458 
		dc.l	$35363616,$36E437B3,$3871392E,$39DA3A85,$3B203BB9 
		dc.l	$3C413CC7,$3D3E3DB0,$3E143E73,$3EC43F0F,$3F4E3F85 
		dc.l	$3FB03FD3,$3FEB3FFA,$40003FFA,$3FEB3FD2,$3FB03F83 
		dc.l	$3F4E3F0C,$3EC43E6F,$3E143DAB,$3D3E3CC1,$3C413BB2 
		dc.l	$3B203A7E,$39DA3926,$387137AA,$36E4360C,$3536344D 
		dc.l	$3367326E,$3178306F,$2F6B2E53,$2D412C1A,$2AFA29C6 
		dc.l	$28992758,$261F24D2,$238E2235,$20E61F83,$1E2B1CBE 
		dc.l	$1B5C19E7,$187D1700,$158F140A,$12931109,$0F8C0DFC 
		dc.l	$0C7C0AE8,$096307CC,$064504AC,$03230189,$0000FE64 
		dc.l	$FCDCFB41,$F9BAF821,$F69CF506,$F383F1F1,$F073EEE5 
		dc.l	$ED6CEBE4,$EA70E8EF,$E782E608,$E4A3E331,$E1D4E06C 
		dc.l	$DF19DDBB,$DC71DB1E,$D9E0D899,$D766D62B,$D505D3D8 
		dc.l	$D2BED1A0,$D094CF84,$CE87CD86,$CC98CBA7,$CAC9C9E9 
		dc.l	$C91BC84C,$C78EC6D1,$C625C57A,$C4DFC446,$C3BEC338 
		dc.l	$C2C1C24F,$C1EBC18C,$C13BC0F0,$C0B1C07A,$C04FC02C 
		dc.l	$C014C005,$C000C005,$C014C02D,$C04FC07C,$C0B1C0F3 
		dc.l	$C13BC190,$C1EBC254,$C2C1C33E,$C3BEC44D,$C4DFC581 
		dc.l	$C625C6D9,$C78EC855,$C91BC9F3,$CAC9CBB2,$CC98CD91 
		dc.l	$CE87CF90,$D094D1AC,$D2BED3E5,$D505D639,$D766D8A7 
		dc.l	$D9E0DB2D,$DC71DDCA,$DF19E07C,$E1D4E341,$E4A3E618 
		dc.l	$E782E8FF,$EA70EBF5,$ED6CEEF6,$F073F203,$F383F517 
		dc.l	$F69CF833,$F9BAFB53,$FCDCFE76
		endr

dist_step	DC.W 4
maxi_dist	DC.W 512
offset	DC.W 0
size		DC.W 0
dister	DC.W 0
wave_ptr	DC.L wave_tab
wave_tab	DC.W 16,512,0,20
		DC.W 8,512,0,80
		DC.W 8,512,0,60
		DC.W 8,512+32,0,80
 		DC.W 6,512-32,20,20
		DC.W 4,128,20,20
		DC.W 8,384,0,40
		DC.W 8,512-128,0,80
 		DC.W 4,512+128,-40,40
		DC.W 64,4096,-40,4
		DC.W 8,512+128,-40,40
		DC.W 32,128+256,0,0
		DC.W 16,512,0,10
		DC.W 16,512,0,20
		DC.W 16,512,0,40
		DC.W 16,512,0,8
		DC.W 8,512,0,60
		DC.W 8,512,0,70
		DC.W 8,1024,0,80
		DC.W 32,1024,0,4
		DC.W 16,512,0,28
		DC.W 16,512,0,24
		DC.W 16,2048,0,4
		DC.W 16,1024,0,8
		DC.W 8,512,0,8
		DC.W 8,512,0,16
		DC.W 8,512,0,32
		DC.W 8,512,0,24
		DC.W 8,512,0,16
		DC.W 16,1024,0,32
		DC.W 8,512,0,24
		DC.W 16,512,0,8
		DC.W 32,2048,0,8
		DC.W -1

		DCB.W 16,0
		DCB.W 16,8	
		DCB.W 16,16	
		DCB.W 16,24	
		DCB.W 16,32	
		DCB.W 16,40	
		DCB.W 16,48	
		DCB.W 16,56	
		DCB.W 16,64	
		DCB.W 16,72	
offtable	DCB.W 16,80
		DCB.W 16,88
		DCB.W 16,96	
		DCB.W 16,104	
		DCB.W 16,112	
		DCB.W 16,120	
		DCB.W 16,128	
		DCB.W 16,136	
		DCB.W 16,144	
		DCB.W 16,152	
frame_cnt	DC.L frames
log_base 	DC.L 0
phy_base 	DC.L 0
switch	DC.W 0
seed		DC.W $9563
dist_ang	DC.W 0
sp1ptr	DC.W 0
vbl_timer	DS.W 1
old_mfp	DS.L 3
old_vbl	DC.L 0
old_ta	DC.L 0
old_tb	DC.L 0
stars		INCBIN INTRO.INC\INTRORN1
old_pos1	REPT 176
		DC.L screens
		ENDR
old_pos2	REPT 176
		DC.L screens
		ENDR
offsettab	DS.L no_strs+1
offsets	DS.L no_strs+1

disttab	REPT 80
		DC.L bigbugger
		DC.W 80
		ENDR
sprite_ptrs	DC.L sprite_buf+(16*18*24*2) 'E'
		DC.L sprite_buf+(16*18*24*3) 'L'
		DC.L sprite_buf+(16*18*24*1) 'C'
		DC.L sprite_buf+(16*18*24*5) 'R'
		DC.L sprite_buf+(16*18*24*0) 'I'
		DC.L sprite_buf+(16*18*24*1) 'C'
		DC.L sprite_buf+(16*18*24*5) 'R'
		DC.L sprite_buf+(16*18*24*2) 'E'
		DC.L sprite_buf+(16*18*24*4) 'N'
		DC.L sprite_buf+(16*18*24*4) 'N'
		DC.L sprite_buf+(16*18*24*0) 'I'
spptrsoffs	DC.W 00,16,32,48,64,80,112,128,144,160,176,192
		
* The sprites 'Inner Circle'....

sprites	incbin INTRO.INC\intsprtes.dat

spoldoff1	REPT 11
		DC.L screens
		ENDR
spoldoff2	REPT 11
		DC.L screens
		ENDR
bigmultab	DC.L bigbugger+(0*79*72)
		DC.L bigbugger+(1*79*72)
		DC.L bigbugger+(2*79*72)
		DC.L bigbugger+(3*79*72)
		DC.L bigbugger+(4*79*72)
		DC.L bigbugger+(5*79*72)
		DC.L bigbugger+(6*79*72)
		DC.L bigbugger+(7*79*72)
		DC.L bigbugger+(8*79*72)
		DC.L bigbugger+(9*79*72)
		DC.L bigbugger+(10*79*72)
		DC.L bigbugger+(11*79*72)
		DC.L bigbugger+(12*79*72)
		DC.L bigbugger+(13*79*72)
		DC.L bigbugger+(14*79*72)
		DC.L bigbugger+(15*79*72)

mulu_160	DS.L 270
music		INCBIN INTRO.INC\INTRO2.CZI
		EVEN
decadelogo	INCBIN INTRO.INC\DECADE.DAT
the		INCBIN INTRO.INC\THE.DAT
numbers	INCBIN INTRO.INC\numbs.dat
bigbugger	INCBIN INTRO.INC\IC_LOGO2.DAT
		SECTION BSS
thexs	
bigbuggers	DS.L 15*(79*18)
sprite_buf	DS.L 6*18*16*6
		DS.L 99
stack		DS.L 1			
screens	DS.B 256
		DS.B 57600
		DS.B 57600
frames	DS.B 64*42*34
big_buf

