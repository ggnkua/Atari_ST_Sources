*
* GORAUD.S
*
*	@goraud
*
*	Draw a goraud shaded polygon in true colour.
*	There's no clipping so don't draw too large polygons.
*
* In	a1.l=screenadr
*	a2.l=adr to colourtable
*	new_crds=following table: [x,y,i]*nbr_of_points
*	d6.w=nbr. of points
*	xres equ horizontal resolution
*	(destroys a lot)
*
*	The colourtable consists of 32 words, each a true colour value.
*	 word nr 0 is the darkest and word nr 31 the brightest. This is
*	 followed by 16 empty words.
*	Supplied colours: g_lightred, g_green, g_brown, g_white
*	new_crds is a table that consist of a pair of coordinates followed
*	 by a brightnes factor. The brightnes factor is a number between 0
*	 and #$7fff.
*
* ex.	 xres equ 384		overscaned lowres screen
*	 bsr @initgoraud	call once only
*
*	 move.l scradr,a1	screenaddress
*	 move.l #g_red,a2	I want a red poly
*	 moveq #4,d6		four points
*	 bsr @goraud		draw it
*
*	 new_crds dc.w 10,10,0		a dark point
*          	  dc.w 200,20,$7fff	a bright point
*		  dc.w 140,140,$7fff/2
*		  dc.w 25,50,$7fff/4
*	
*
*	@initgoraud
*	 This subroutine must be called once before using '@goraud'.
*



@goraud
		lea	offsets,a0
		move.l	a1,workscr2354
		move.l	a2,colouradr2354
		bsr	GDraw_Poly
		rts

		
colouradr2354	ds.l	1
offsets		dc.w	0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,100


;-----------------------------------------------------------------------;
;                 Gouraud Shaded Polygon Routine.			;
; A0 -> D6 coords (offsets into 'new_crds' in form X,Y,INTENSITY CONST) ;
;-----------------------------------------------------------------------;

GDraw_Poly	LEA trans_crds,A1 
		LEA new_crds,A6
		MOVE D6,D0
		ADD D6,D6
		ADD D0,D6
		ADD D6,D6		6*d6
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
		ADD.W D2,D2		
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
		ADD.W D4,D4			
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
		move.l	colouradr2354,a5
		MOVE.L workscr2354(PC),A6
		MULU #xres*2,D0 
		ADDA.L D0,A6 
		LEA x1s(PC),A1
		LEA x2s(PC),A2
		MOVEQ #16-6,D3
		MOVE.W #xres*2,D4
		MOVEQ #0,D5
Gdraw_lp    	MOVE.W (A1)+,D0		; x1
		MOVE.W (A2)+,D6		; x2
		MOVE.W (A1)+,D1	 	; Intensity 1
		MOVE.W (A2)+,D2		; Intensity 2
		EXT.L D1
		EXT.L D2
		LEA (A6,D0.W*2),A0
		SUB.W D0,D6 
		BLE DS2 
		SUB.L D1,D2 		
		EXT.L D6
		SWAP D2
		DIVS.L D6,D2
		ASR.L D3,d2
		ASL.L #6,D1
		SWAP D1
		SWAP D2
		MOVEQ #31,D0
		AND.W D6,D0
		LSR.W #5,D6
		MOVE D5,CCR
		JMP ([jmptab,D0.W*4])
Glp		
		REPT 32
		MOVE.W (A5,D1*2),(A0)+
		ADDX.L D2,D1
		ENDR
g_jmp		DBF D6,Glp
DS2      	ADD.W D4,A6
		DBF D7,Gdraw_lp

polydone	RTS 


i		SET 0
jmptab		
		REPT 32
		DC.L g_jmp+i
i		SET i-6
		ENDR 
		DS.W 16

; Create Multplication gradient table for poly edges

@initgoraud	LEA grad_table(PC),A0
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

trans_crds    	DS.W 200

workscr2354	ds.l	1


g_lightred
i		set	0
		rept	32
		dc.w	(31*32*64)+(i*64)+(i)
i		set	i+1
		endr
		ds.w	16

g_green
i		set	0
		rept	32
		dc.w	(1*32*64)+(i*64)+(1)
i		set	i+1
		endr
		ds.w	16

g_white
i		set	0
		rept	32
		dc.w	(i*32*64)+(i*64)+(i)
i		set	i+1
		endr
		ds.w	16

g_brown
i		set	0
		rept	32
		dc.w	(i*32*64)+((i/2)*64)+(2)
i		set	i+1
		endr
		ds.w	16
