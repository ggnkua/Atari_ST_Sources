* An example how to make a gouraud-shaded cube using the routine
* shown in Falcon Lib 4.....
*
* I just added some 3D-code and stuff.....
*
*
* Deez // MIND Design
*
* Fredrik Egeberg
* Hasselgatan 22
* 614 33 S”derk”ping
* Tele: 0121-21325


vertflag	equ $0100	; double-line on vga, interlace on st/tv ;
stmodes		equ $0080	; st compatible (uses the ff8240 colour registers);
overscan	equ $0040	; multiply x&y rez by 1.2, ignored on vga ;
pal		equ $0020	; pal if set, else ntsc ;
vga		equ $0010	; vga if set, else tv mode ;
col80		equ $0008	; 80 column if set, else 40 column ;
bps16		equ $0004	; true colour mode
bps8		equ $0003	; 8 bitplanes ... etc.
bps4		equ $0002
bps2		equ $0001
bps1		equ $0000

	opt	o+,ow-
start	clr.l	-(sp)			* Enter Supervisor mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#2,sp
	move.l	d0,super
	move.b	#$12,$fffc02

* Set VGA, 320*240 TrueColor
* If you use a tv the just remove 'vga'

	move	#vga+vertflag+bps16,d7
	jsr	setvideo

	jsr	savevadr
	jsr	setvadr
	jsr	@initgoraud

main	jsr	spinit
	jsr	draw_polygon
	jsr	tst_scr
	jsr	waitvbl
	jsr	cls
	cmp.b	#1,$fffc02		* Somebody pressed <ESC>?
	bne	main			* If not so back to Main

restore	jsr	restorevideo
	move.b	#$8,$fffc02
	move.l	super,-(sp)		* Back into User mode
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)			* Quit program
	trap	#1

waitvbl	move.l	$466.w,d0
.vbl	cmp.l	$466.w,d0
	beq.s	.vbl
	rts

swap1	move.w	#-1,-(sp)		* Swap screens
	move.l	#logic,-(sp)
	move.l	#physic,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#physic,screen
	rts

swap2	move.w	#-1,-(sp)		* Swap screens
	move.l	#physic,-(sp)
	move.l	#logic,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	move.l	#logic,screen
	rts

tst_scr	move.l	#logic,d0
	cmp.l	screen,d0
	bne.s	swp_2
	jsr	swap1
	rts
swp_2	jsr	swap2
	rts

setvideo
	move	#37,-(sp)
	trap	#14
	addq.l	#2,sp
	move.w	#-1,-(sp)
	move.w	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
	move	d0,save4856
	move.w	d7,-(sp)
	move.w	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
	rts

restorevideo
	move.w	save4856,-(sp)
	move.w	#$58,-(sp)
	trap	#14
	addq.l	#4,sp
	rts
		
savevadr
	move	#2,-(sp)
	trap	#14
	addq.l	#2,sp
	move.l	d0,scradr7112
	rts

cls	move.l	screen,a0
	movem.l	d0-d7/a0-a6,-(sp)
	add.l	#130000,a0
	moveq.l	#0,d0
	move.l	d0,d1
	move.l	d1,d2
	move.l	d2,d3
	move.l	d3,d4
	move.l	d4,d5
	move.l	d5,d6
	move.l	d6,a1
	move.l	a1,a2
	move.l	a2,a3
	move.l	a3,a4
	move.l	a4,a5
	move.l	a5,a6
	moveq.w	#50-1,d7
cls_lp	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	movem.l	d0-d6/a1-a6,-(a0)
	dbra	d7,cls_lp
	movem.l	(sp)+,d0-d7/a0-a6
	rts

restorevadr
	move	#-1,-(sp)
	move.l	scradr7112,-(sp)
	move.l	scradr7112,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp		
	rts

setvadr	move	#-1,-(sp)
	move.l	#logic,-(sp)
	move.l	#logic,-(sp)
	move	#5,-(sp)
	trap	#14
	lea	12(sp),sp		
	rts

@goraud	lea.l	offsets,a0
	move.l	a1,workscr2354
	move.l	a2,colouradr2354
	bsr	GDraw_Poly
	rts

Draw_polygon
	move.l	#palette,color
	jsr	side1
	jsr	side2
	jsr	side3
	jsr	side4
	jsr	side5
	jsr	side6
	rts

side1	lea.l	new_crds,a0
	lea.l	z_tab,a1
	lea.l	newco,a3
	move.l	(a3),(a0)
	move.l	4(a3),6(a0)
	move.l	8(a3),12(a0)
	move.l	12(a3),18(a0)

	move.w	(a1),4(a0)
	move.w	2(a1),10(a0)
	move.w	4(a1),16(a0)
	move.w	6(a1),22(a0)
	move.l	screen,a1
	move.l	color,a2
	move.w	#4,d6
	jsr	@goraud
	rts

side2	lea.l	new_crds,a0
	lea.l	z_tab,a1
	lea.l	newco,a3
	move.l	4(a3),(a0)
	move.l	20(a3),6(a0)
	move.l	24(a3),12(a0)
	move.l	8(a3),18(a0)

	move.w	2(a1),4(a0)
	move.w	10(a1),10(a0)
	move.w	12(a1),16(a0)
	move.w	4(a1),22(a0)
	move.l	screen,a1
	move.l	color,a2
	move.w	#4,d6
	jsr	@goraud
	rts

side3	lea.l	new_crds,a0
	lea.l	z_tab,a1
	lea.l	newco,a3
	move.l	(a3),(a0)
	move.l	16(a3),6(a0)
	move.l	20(a3),12(a0)
	move.l	4(a3),18(a0)

	move.w	(a1),4(a0)
	move.w	8(a1),10(a0)
	move.w	10(a1),16(a0)
	move.w	2(a1),22(a0)
	move.l	screen,a1
	move.l	color,a2
	move.w	#4,d6
	jsr	@goraud

side4	lea.l	new_crds,a0
	lea.l	z_tab,a1
	lea.l	newco,a3
	move.l	8(a3),(a0)
	move.l	24(a3),6(a0)
	move.l	28(a3),12(a0)
	move.l	12(a3),18(a0)

	move.w	4(a1),4(a0)
	move.w	12(a1),10(a0)
	move.w	14(a1),16(a0)
	move.w	6(a1),22(a0)
	move.l	screen,a1
	move.l	color,a2
	move.w	#4,d6
	jsr	@goraud
	rts

side5	lea.l	new_crds,a0
	lea.l	z_tab,a1
	lea.l	newco,a3
	move.l	12(a3),(a0)
	move.l	28(a3),6(a0)
	move.l	16(a3),12(a0)
	move.l	(a3),18(a0)

	move.w	6(a1),4(a0)
	move.w	14(a1),10(a0)
	move.w	8(a1),16(a0)
	move.w	(a1),22(a0)
	move.l	screen,a1
	move.l	color,a2
	move.w	#4,d6
	jsr	@goraud
	rts

side6	lea.l	new_crds,a0
	lea.l	z_tab,a1
	lea.l	newco,a3
	move.l	28(a3),(a0)
	move.l	24(a3),6(a0)
	move.l	20(a3),12(a0)
	move.l	16(a3),18(a0)

	move.w	14(a1),4(a0)
	move.w	12(a1),10(a0)
	move.w	10(a1),16(a0)
	move.w	8(a1),22(a0)
	move.l	screen,a1
	move.l	color,a2
	move.w	#4,d6
	jsr	@goraud
	rts

spinit	lea.l	sintab,a0
	move.l	a0,a3
	move.l	a0,a4
	and.w	#$3ff,xang
	and.w	#$3ff,yang
	and.w	#$3ff,zang
	add.w	xang,a0
	add.w	yang,a3
	add.w	zang,a4
	lea.l	coords,a1
	lea.l	newco,a2
	lea.l	z_tab,a6
	move.w	#8-1,d5
	move.w	#14,d7
next	move.w	(a1)+,d0
	move.w	(a1)+,d1
	move.w	(a1)+,d2

rot_x	move.w	d1,d3			* copy y
	move.w	d2,d4			* copy z
	muls.w	256(a0),d1		* y.cos
	muls.w	(a0),d4			* z.sin
	sub.l	d4,d1			* y.cos - z.sin
	asr.l	d7,d1			* new y --> d1
	muls.w	(a0),d3			* y.sin
	muls.w	256(a0),d2		* z.cos
	add.l	d3,d2			* y.sin + z.cos
	asr.l	d7,d2			* new z --> d2

rot_y	move.w	d0,d3			* copy x 
	move.w	d2,d4			* copy z
	muls.w	256(a3),d0		* x.cos
	muls.w	(a3),d4			* z.sin
	add.l	d4,d0			* x.cos + y.sin
	asr.l	d7,d0			* new x --> d0
	muls.w	(a3),d3			* x.sin
	muls.w	256(a3),d2		* z.cos
	sub.l	d3,d2			* z.cos - x.sin
	asr.l	d7,d2			* new z --> d2

rot_z	move.w	d0,d3			* copy x
	move.w	d1,d4			* copy z
	muls.w	256(a4),d0		* x.cos
	muls.w	(a4),d4			* y.sin
	sub.l	d4,d0			* x.cos - y.sin
	asr.l	d7,d0			* new x --> d0
	muls.w	(a4),d3			* x.sin
	muls.w	256(a4),d1		* y.cos
	add.l	d3,d1			* x.sin + y.cos
	asr.l	d7,d1			* new y --> d1

per	move.w	#200,d3
	muls.w	d3,d0
	muls.w	d3,d1
	add.w	d2,d3
	add.w	#100,d3
	divs.w	d3,d0
	divs.w	d3,d1

	add.w	#160,d0			* Center Xpos
	add.w	#120,d1			* Center Ypos

	move.w	d0,(a2)+
	move.w	d1,(a2)+
	add.w	#140,d2
	muls.l	#155,d2
	move.w	d2,(a6)+

	dbra	d5,next
	add.w	#2*2,xang
	add.w	#2*5,yang
	add.w	#2*3,zang
	rts

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

CALCS		LEA grad_table+640,A0
; Calc x's down left side of poly
Do_left		LEA LEFTJMP,A2
		LEA x1s,A3
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
		LEA RIGHTJMP,A2
		LEA x2s,A3
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
		MOVE.L workscr2354,A6
		MULU #640,D0 
		ADDA.L D0,A6 
		LEA x1s,A1
		LEA x2s,A2
		MOVEQ #16-6,D3
		MOVE.W #640,D4
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

@initgoraud	LEA grad_table,A0
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

	section	data
super	dc.l	0
new_crds
	dc.w 10,10,0		a dark point
	dc.w 200,20,$7fff/1	a bright point
	dc.w 140,140,$7fff/1
	dc.w 25,50,0

palette
r	set	31
g	set	0
b	set	0
	rept	32
	dc.w	2048*r+64*g+b
r	set	r-1
g	set	g+1
b	set	b+0
	endr

g_lightred
i	set	31
	rept	32
	dc.w	(31*32*64)+(i*64)+(i)
i	set	i-1
	endr
	ds.w	16

g_green
i	set	31
	rept	32
	dc.w	(1*32*64)+(i*64)+(1)
i	set	i-1
	endr
	ds.w	16

g_white
i	set	31
	rept	32
	dc.w	(i*32*64)+(i*64)+(i)
i	set	i-1
	endr
	ds.w	16

g_brown
i	set	0
	rept	32
	dc.w	(i*32*64)+((i/2)*64)+(2)
i	set	i+1
	endr
	ds.w	16
offsets	dc.w	0,6,12,18,24,30,36,42,48,54,60,66,72,78,84,90,96,100
coords	dc.w	-64,-64,-64
	dc.w	64,-64,-64
	dc.w	64,64,-64
	dc.w	-64,64,-64
	dc.w	-64,-64,64
	dc.w	64,-64,64
	dc.w	64,64,64
	dc.w	-64,64,64
screen	dc.l	logic
zang	dc.w	0
xang	dc.w	0
yang	dc.w	0
color	dc.l	g_brown
sintab	dc.w	0,201,402,603,803,1004,1205,1405,1605
	dc.w	1805,2005,2204,2404,2602,2801,2998,3196,3393
	dc.w	3589,3785,3980,4175,4369,4563,4756,4948,5139
	dc.w	5329,5519,5708,5896,6083,6269,6455,6639,6822
	dc.w	7005,7186,7366,7545,7723,7900,8075,8249,8423
	dc.w	8594,8765,8934,9102,9268,9434,9597,9759,9920
	dc.w	10079,10237,10393,10548,10701,10853,11002,11150,11297
	dc.w	11442,11585,11726,11866,12003,12139,12273,12406,12536
	dc.w	12665,12791,12916,13038,13159,13278,13395,13510,13622
	dc.w	13733,13842,13948,14053,14155,14255,14353,14449,14543
	dc.w	14634,14723,14810,14895,14978,15058,15136,15212,15286
	dc.w	15357,15426,15492,15557,15618,15678,15735,15790,15842
	dc.w	15892,15940,15985,16028,16069,16107,16142,16175,16206
	dc.w	16234,16260,16284,16305,16323,16339,16353,16364,16372
	dc.w	16379,16382,16384,16382,16379,16372,16364,16353,16339
	dc.w	16323,16305,16284,16260,16234,16206,16175,16142,16107
	dc.w	16069,16028,15985,15940,15892,15842,15790,15735,15678
	dc.w	15618,15557,15492,15426,15357,15286,15212,15136,15058
	dc.w	14978,14895,14810,14723,14634,14543,14449,14353,14255
	dc.w	14155,14053,13948,13842,13733,13622,13510,13395,13278
	dc.w	13159,13038,12916,12791,12665,12536,12406,12273,12139
	dc.w	12003,11866,11726,11585,11442,11297,11150,11002,10853
	dc.w	10701,10548,10393,10237,10079,9920,9759,9597,9434
	dc.w	9268,9102,8934,8765,8594,8423,8249,8075,7900
	dc.w	7723,7545,7366,7186,7005,6822,6639,6455,6269
	dc.w	6083,5896,5708,5519,5329,5139,4948,4756,4563
	dc.w	4369,4175,3980,3785,3589,3393,3196,2998,2801
	dc.w	2602,2404,2204,2005,1805,1605,1405,1205,1004
	dc.w	803,603,402,201,0,-202,-403,-604,-804
	dc.w	-1005,-1206,-1406,-1606,-1806,-2006,-2205,-2405,-2603
	dc.w	-2802,-2999,-3197,-3394,-3590,-3786,-3981,-4176,-4370
	dc.w	-4564,-4757,-4949,-5140,-5330,-5520,-5709,-5897,-6084
	dc.w	-6270,-6456,-6640,-6823,-7006,-7187,-7367,-7546,-7724
	dc.w	-7901,-8076,-8250,-8424,-8595,-8766,-8935,-9103,-9269
	dc.w	-9435,-9598,-9760,-9921,-10080,-10238,-10394,-10549,-10702
	dc.w	-10854,-11003,-11151,-11298,-11443,-11586,-11727,-11867,-12004
	dc.w	-12140,-12274,-12407,-12537,-12666,-12792,-12917,-13039,-13160
	dc.w	-13279,-13396,-13511,-13623,-13734,-13843,-13949,-14054,-14156
	dc.w	-14256,-14354,-14450,-14544,-14635,-14724,-14811,-14896,-14979
	dc.w	-15059,-15137,-15213,-15287,-15358,-15427,-15493,-15558,-15619
	dc.w	-15679,-15736,-15791,-15843,-15893,-15941,-15986,-16029,-16070
	dc.w	-16108,-16143,-16176,-16207,-16235,-16261,-16285,-16306,-16324
	dc.w	-16340,-16354,-16365,-16373,-16380,-16383,-16384,-16383,-16380
	dc.w	-16373,-16365,-16354,-16340,-16324,-16306,-16285,-16261,-16235
	dc.w	-16207,-16176,-16143,-16108,-16070,-16029,-15986,-15941,-15893
	dc.w	-15843,-15791,-15736,-15679,-15619,-15558,-15493,-15427,-15358
	dc.w	-15287,-15213,-15137,-15059,-14979,-14896,-14811,-14724,-14635
	dc.w	-14544,-14450,-14354,-14256,-14156,-14054,-13949,-13843,-13734
	dc.w	-13623,-13511,-13396,-13279,-13160,-13039,-12917,-12792,-12666
	dc.w	-12537,-12407,-12274,-12140,-12004,-11867,-11727,-11586,-11443
	dc.w	-11298,-11151,-11003,-10854,-10702,-10549,-10394,-10238,-10080
	dc.w	-9921,-9760,-9598,-9435,-9269,-9103,-8935,-8766,-8595
	dc.w	-8424,-8250,-8076,-7901,-7724,-7546,-7367,-7187,-7006
	dc.w	-6823,-6640,-6456,-6270,-6084,-5897,-5709,-5520,-5330
	dc.w	-5140,-4949,-4757,-4564,-4370,-4176,-3981,-3786,-3590
	dc.w	-3394,-3197,-2999,-2802,-2603,-2405,-2205,-2006,-1806
	dc.w	-1606,-1406,-1206,-1005,-804,-604,-403,-202,0
	dc.w	201,402,603,803,1004,1205,1405,1605,1805
	dc.w	2005,2204,2404,2602,2801,2998,3196,3393,3589
	dc.w	3785,3980,4175,4369,4563,4756,4948,5139,5329
	dc.w	5519,5708,5896,6083,6269,6455,6639,6822,7005
	dc.w	7186,7366,7545,7723,7900,8075,8249,8423,8594
	dc.w	8765,8934,9102,9268,9434,9597,9759,9920,10079
	dc.w	10237,10393,10548,10701,10853,11002,11150,11297,11442
	dc.w	11585,11726,11866,12003,12139,12273,12406,12536,12665
	dc.w	12791,12916,13038,13159,13278,13395,13510,13622,13733
	dc.w	13842,13948,14053,14155,14255,14353,14449,14543,14634
	dc.w	14723,14810,14895,14978,15058,15136,15212,15286,15357
	dc.w	15426,15492,15557,15618,15678,15735,15790,15842,15892
	dc.w	15940,15985,16028,16069,16107,16142,16175,16206,16234
	dc.w	16260,16284,16305,16323,16339,16353,16364,16372,16379
	dc.w	16382,16384,0,0

	section	bss
logic	ds.l	38400
physic	ds.l	38400
save4856	ds.w	1
scradr7112	ds.l	1
grad_table	ds.w 642
x1s		DS.L 201
x2s		DS.L 201
trans_crds    	DS.W 200
workscr2354	ds.l	1
colouradr2354	ds.l	1
newco	ds.l	100
z_tab	ds.l	100
