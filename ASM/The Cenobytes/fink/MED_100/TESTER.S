***************************************************************************
* -THE FINK- RETURNS WITH MORE CODING FOR YOU LESSER MORTALS WHO CANN'T   *
* HACK .......								  *
***************************************************************************
* TESTER........ This code is the same as the main source for the menu    *
* which I ripped except I thought it would be interesting to see how many *
* scan lines each routine takes (how much processor time). The different  *
* colours in the boarder signify each routine....			  *
* Grey = Sprite								  *
* Red = Graphics equalizer						  *
* Green = Scroller							  *
* Blue = Music								  *
***************************************************************************
		MOVE.L	A7,A5 
		MOVE.L	4(A5),A5 
		MOVE.L	#$7FFF0,A7 
		MOVE.L	#$100,-(A7) 
		MOVE.L	A5,-(A7) 
		MOVE.W	#0,-(A7) 
		MOVE.W	#$4A,-(A7) 		; set data allocations
		TRAP	#1 
		ADDA.L	#$C,A7 
*---------------
		MOVE.W	#2,-(A7) 
		TRAP	#14 			; get screen address
		ADDQ.L	#2,A7 
		MOVE.L	D0,old_scr	
*---------------
		MOVE.W	#0,-(A7) 		; low res
		PEA	$70000 			; new scr addr
		PEA	$70000 
		MOVE.W	#5,-(A7) 
		TRAP	#14 
		ADDA.L	#$C,A7 
*---------------
		LEA	$60000,A0 
clear_scr	CLR.L	(A0)+ 
		CMPA.L	#$7FF00,A0 		; clear screen
		BLE	clear_scr
*---------------
		CLR.L	-(A7) 
		MOVE.W	#$20,-(A7) 		; supervisor
		TRAP	#1 
		ADDQ.L	#6,A7 
		MOVE.L	D0,old_ssp
*---------------
		MOVE.B	#2,$FF820A 		; 50 Hz
		MOVE.L	#reset_rout,$42A 	; new reset routine
		MOVE.L	#$31415926,$426		; make it vlaid
		MOVE.B	$FF820A,old_hz 		; save Hz
*---------------
		MOVE.W	#$12,-(A7)		; turn mouse off
		MOVE.W	#4,-(A7) 		
		MOVE.W	#3,-(A7) 
		TRAP	#13 
		ADDQ.L	#6,A7 
*---------------
		MOVE.L	$4.W,D0 		
		MOVE.L	D0,$502.W 		; stop screen dumps		
		MOVE.L	$70,old_vbl
		MOVE.L	$120,old_hbl
		ANDI.B	#$FC,$484		; turn off keyclick
*---------------
		BSR	set_mfp			; set up MFP, hbl, vbl etc
*---------------
*L6A3D2		LEA	$1EC4E,A0 
*L6A3D8		LEA	$496D6,A1 
*L6A3DE		MOVE.L	(A0)+,(A1)+ 
*L6A3E0		CMPA.L	#$24E7C,A0 
*L6A3E6		BLE	L6A3DE 

		move.w	#1,d0			******FINK*****
		jsr	music			******FINK*****

*		MOVE.W	#4,LBB26 		SAVE MUSIC NUMBER
*		MOVEQ	#4,D0 			MUSIC 4
*		JSR	$4D6EC 			RUN MUSIC

*L6A3FA		MOVE.L	#$4D80C,LB038 
		MOVE.L	#vbl,$70 		; new vbl
*---------------
		MOVE.W	#7999,D0 		; copy picy
		LEA	picy,A0 		
		LEA	$60000,A1 		
new_scr		MOVE.L	(A0)+,(A1)+ 
		DBF	D0,new_scr
*---------------
		MOVE.L	#$70000,L13FDC 		; fade in addr
		BSR	fink_fade		; do that funky fade..
*---------------
		MOVE.W	#1,m_bars 		; start music equalizer

*--------------- Create sprite masks & pre-shift sprite
		LEA	sprite_dat,A0		; holds sprite 
		LEA	mask_buff,A1 		; mask buffer
		LEA	sprite_buff,A2 		; sprite buffer
		MOVE.W	#31,D0 
mask_all	MOVE.W	#10,D1 
mask_1		MOVE.L	(A0),(A2)+ 
		MOVE.L	4(A0),(A2)+ 
		MOVE.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		NOT.W	D2 			; mask created
		MOVE.W	D2,(A1)+ 
		MOVE.W	D2,(A1)+ 		; so copy it
		DBF	D1,mask_1 

		LEA	$48(A0),A0		; next line 
		DBF	D0,mask_all 		; do all lines
*---------------
		BSR	shift_sprite		; shift sprite
*---------------
		LEA	sprite_dat,A0 		; sprite
		LEA	mask_2_buff,A1 		; new buffer pos for mask
		LEA	sprite_2_buff,A2 	; new buffer pos for sprite
		MOVE.W	#31,D0 
mask_all_2	MOVE.W	#10,D1 
mask_2		MOVE.L	(A0),(A2)+ 
		MOVE.L	4(A0),(A2)+ 
		MOVE.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		NOT.W	D2 
		MOVE.W	D2,(A1)+ 
		MOVE.W	D2,(A1)+ 
		DBF	D1,mask_2 

		LEA	$48(A0),A0 
		DBF	D0,mask_all_2 
*---------------
		BSR	shift_sprite		; shift sprite
*---------------
		LEA	sprite_dat,A0 		; sprite
		LEA	mask_3_buff,A1 		; new buffer pos for mask
		LEA	sprite_3_buff,A2 	; new buffer pos for sprite
		MOVE.W	#31,D0 
mask_all_3	MOVE.W	#10,D1 
mask_3		MOVE.L	(A0),(A2)+ 
		MOVE.L	4(A0),(A2)+ 
		MOVE.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		NOT.W	D2 
		MOVE.W	D2,(A1)+ 
		MOVE.W	D2,(A1)+ 
		DBF	D1,mask_3

		LEA	$48(A0),A0 
		DBF	D0,mask_all_3
*---------------
		BSR	shift_sprite		; shift sprite
*---------------
		LEA	sprite_dat,A0 		; sprite
		LEA	mask_4_buff,A1 		; new buffer pos for mask
		LEA	sprite_4_buff,A2 	; new buffer pos for sprite
		MOVE.W	#31,D0 
mask_all_4	MOVE.W	#10,D1 
mask_4		MOVE.L	(A0),(A2)+ 
		MOVE.L	4(A0),(A2)+ 
		MOVE.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		OR.W	(A0)+,D2 
		NOT.W	D2 
		MOVE.W	D2,(A1)+ 
		MOVE.W	D2,(A1)+ 
		DBF	D1,mask_4

		LEA	$48(A0),A0
		DBF	D0,mask_all_4
*---------------
		LEA	mask_addrs,A0 		; save mask buffer addrs
		MOVE.L	#mask_buff,(A0)+ 
		MOVE.L	#mask_2_buff,(A0)+ 
		MOVE.L	#mask_3_buff,(A0)+ 
		MOVE.L	#mask_4_buff,(A0)+ 

		LEA	sprite_addrs,A0		; save sprite buffer addrs
		MOVE.L	#sprite_buff,(A0)+ 
		MOVE.L	#sprite_2_buff,(A0)+ 
		MOVE.L	#sprite_3_buff,(A0)+ 
		MOVE.L	#sprite_4_buff,(A0)+ 

		MOVE.L	#$77E46,scr_addr	; scroller addr
		MOVE.W	#8,scr_count 		; buff counter
		MOVE.L	#text,text_p 		; set text pointer
		MOVE.W	#1,scroller		; start scroller 
		MOVE.W	#1,sprite 		; start sprite
*---------------
L6A730		MOVE.W	#$FF,-(A7) 		; main loop
		MOVE.W	#$6,-(A7) 
		TRAP	#1 
		ADDQ.L	#4,A7 
		TST.L	D0 
		BEQ	L6A730 
*---------------
check_0		CMP.B	#$30,D0			
		BNE	check_1
		MOVE.W	paly,D1 
		MOVE.W	#$777,paly
		MOVE.W	#3328,D0 
waity		NOP
		DBF	D0,waity 
		MOVE.W	D1,paly
		BCHG	#1,old_hz 
		BRA	L6A730 

check_1		CMP.B	#$31,D0 		
		BNE	check_2
		BSR	L6A9A0 
		PEA	$BB96 
		PEA	$BB9A 
		PEA	$16EEA 
		BRA	L6A992 			; load Super Off Road Racer

check_2		CMP.B	#$32,D0			
		BNE	check_3
		BSR	L6A9A0 
		PEA	$BB96 
		PEA	$BB9A 
		PEA	$16EF4 
		BRA	L6A992 			; load Cabal

check_3		CMP.B	#$33,D0 		
		BNE	check_4
		BSR	L6A9A0 
		PEA	$BB96 
		PEA	$BB9A 
		PEA	$16EFE 
		BRA	L6A992 			; load Pro Soccer 2190

check_4		CMP.B	#$34,D0			
		BNE	check_F1
		BSR	L6A9A0 
		BRA	L6AA56 
		PEA	$BB96 
		PEA	$BB9A 
		PEA	$16F08 
		BRA	L6A992 			; load Bodyshop

check_F1	SWAP	D0 
		CMP.B	#$3B,D0 
		BNE	check_F2
		CMPI.W	#0,$BB26 
		BEQ	L6A730 
		MOVE.W	#0,$BB26 
		MOVEQ	#0,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F2	CMP.B	#$3C,D0 
		BNE	check_F3
		CMPI.W	#1,$BB26 
		BEQ	L6A730 
		MOVE.W	#1,$BB26 
		MOVEQ	#1,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F3	CMP.B	#$3D,D0 
		BNE	check_F4
		CMPI.W	#2,$BB26 
		BEQ	L6A730 
		MOVE.W	#2,$BB26 
		MOVEQ	#2,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F4	CMP.B	#$3E,D0 
		BNE	check_F5
		CMPI.W	#3,$BB26 
		BEQ	L6A730 
		MOVE.W	#3,$BB26 
		MOVEQ	#3,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F5	CMP.B	#$3F,D0 
		BNE	check_F6
		CMPI.W	#4,$BB26 
		BEQ	L6A730 
		MOVE.W	#4,$BB26 
		MOVEQ	#4,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F6	CMP.B	#$40,D0 
		BNE	check_F7
		CMPI.W	#5,$BB26 
		BEQ	L6A730 
		MOVE.W	#5,$BB26 
		MOVEQ	#5,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F7	CMP.B	#$41,D0 
		BNE	check_F8
		CMPI.W	#6,$BB26 
		BEQ	L6A730 
		MOVE.W	#6,$BB26 
		MOVEQ	#6,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F8	CMP.B	#$42,D0 
		BNE	check_F9
		CMPI.W	#7,$BB26 
		BEQ	L6A730 
		MOVE.W	#7,$BB26 
		MOVEQ	#7,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F9	CMP.B	#$43,D0 
		BNE	check_F10
		CMPI.W	#8,$BB26 
		BEQ	L6A730 
		MOVE.W	#8,$BB26 
		MOVEQ	#8,D0 
		JSR	$4D6EC 
		BRA	L6A730 

check_F10	CMP.B	#$44,D0 
		BNE	L6A730 
		CMPI.W	#$B,$BB26 
		BEQ	L6A730 
		MOVE.W	#$B,$BB26 
		MOVEQ	#$B,D0 
		JSR	$4D6EC 
		BRA	L6A730 
*---------------
L6A992		CLR.W	-(A7) 
L6A994		MOVE.W	#$4B,-(A7) 
L6A998		TRAP	#$1 
L6A99A		ADDQ.L	#$6,A7 
L6A99C		BRA	L6AA56 
L6A9A0		MOVE.W	#$0,$BBB0 
L6A9A8		MOVE.W	#$0,$BBA0 
*---------------
		LEA	$70000,A0 		; clear screen
clear_scr2	CLR.L	(A0)+ 
		CMPA.L	#$7FF00,A0 
		BLT	clear_scr2
*---------------
		CLR.W	$FF8240 		; set pal
		MOVE.W	#$777,$FF8246 
*---------------
		MOVE.L	old_vbl,$70 
		BSR	restore_mfp 
*---------------
		MOVE.L	#$8080000,$FF8800 	; clear sound chip
		MOVE.L	#$9090000,$FF8800 
		MOVE.L	#$A0A0000,$FF8800 
*---------------
		MOVE.B	old_hz,$FF820A 
*---------------
		MOVE.W	#8,-(A7) 		; turn mouse on
		MOVE.W	#4,-(A7) 
		MOVE.W	#3,-(A7) 
		TRAP	#13 
		ADDQ.L	#6,A7 
*---------------
		ORI.B	#3,$484 		; keyclick on
		CLR.L	$426 
		CLR.L	$42A 
*---------------
		MOVE.W	#0,-(A7) 		; set old screen parameters
		MOVE.L	old_scr,-(A7) 
		MOVE.L	old_scr,-(A7) 
		MOVE.W	#5,-(A7) 
		TRAP	#14 
		ADDA.L	#$C,A7 
*---------------
		MOVE.L	old_ssp,-(A7) 		; user
		MOVE.W	#$20,-(A7) 
		TRAP	#1 
		ADDQ.L	#6,A7 
		RTS
*---------------
L6AA56		CLR.W	-(A7) 
L6AA58		TRAP	#$1 
L6AA5A		ADDQ.L	#$2,A7 
L6AA5C		RTS
***************************************************************************
* THE SCREEN FADE-IN ROUTINE (VERY TRICKY STUFF !!!)			  *
***************************************************************************
fink_fade	LEA	L13FE8,A0 		; buffer
		MOVE.W	#199,D1 		
		MOVE.W	#210,D0 
create_data	MOVE.W	D0,(A0) 
		CLR.W	2(A0) 
		CLR.L	4(A0) 
		ADDQ.W	#1,D0 
		LEA	8(A0),A0 
		DBF	D1,create_data

		MOVE.L	#-1,L13FE0	
		CLR.L	L13FE4 
L6AA90		LEA	L13FE8,A0 		; data buffer
		MOVEQ	#0,D0 
		CMPI.L	#199,L13FE0 		
		BGE	L6AAAC			
		ADDQ.L	#1,L13FE0		
L6AAAC		MOVE.L	D0,D1 
		LSL.L	#3,D1 
		TST.W	2(A0,D1.L) 
		BNE	L6AACA 
		TST.W	4(A0,D1.L) 
		BNE	L6AADC 
		MOVE.W	#$14,2(A0,D1.L) 
		BRA	L6AADC 
L6AACA		SUBQ.W	#1,2(A0,D1.L) 
		BNE	L6AADC 
		ADDQ.L	#1,L13FE4 
		NOT.W	4(A0,D1.L) 
L6AADC		ADDQ.L	#1,D0 
		CMP.L	L13FE0,D0 
		BLE	L6AAAC 
		MOVEQ	#0,D0 
L6AAEA		MOVE.L	D0,D1 
		LSL.L	#3,D1 
		TST.W	2(A0,D1.L) 
		BEQ	L6AB0A 
		MOVE.W	0(A0,D1.L),D2 
		MOVEQ	#0,D3 
		MOVE.W	D2,D3 
		SUB.W	2(A0,D1.L),D2 
		BSR	L6AB58 
		MOVE.W	D2,6(A0,D1.L) 
L6AB0A		ADDQ.L	#1,D0 
		CMP.L	L13FE0,D0 
		BLE	L6AAEA 
		BSR	L6AC2C 			; wait for vsync
		LEA	L13FE8,A0 
		MOVEQ	#0,D0 
L6AB22		MOVE.L	D0,D1 
		LSL.L	#3,D1 
		TST.W	2(A0,D1.L) 
		BEQ	L6AB3C 
		MOVE.W	0(A0,D1.L),D2 
		BSR	L6AB9E 
		MOVE.W	6(A0,D1.L),0(A0,D1.L) 
L6AB3C		ADDQ.L	#1,D0 
		CMP.L	L13FE0,D0 
		BLE	L6AB22 
		CMPI.L	#200,L13FE4 
		BNE	L6AA90 
		RTS

L6AB58		MOVEM.L	D0-D3/A0-A1,-(A7) 
L6AB5C		MOVE.L	L13FDC,A0 		; screen addr
L6AB62		MOVE.L	A0,A1 
L6AB64		MULU	#160,D3 		
L6AB68		ADDA.L	D3,A0 
L6AB6A		CMPA.L	#$78340,A0 
L6AB70		BLT	L6AB7A 
L6AB74		SUBA.L	#$18340,A0 
L6AB7A		MULU	#$A0,D2 
L6AB7E		ADDA.L	D2,A1 
L6AB80		CMPA.L	#$78340,A1 
L6AB86		BLT	L6AB90 
L6AB8A		SUBA.L	#$18340,A1 
L6AB90		MOVEQ	#$27,D0 
L6AB92		MOVE.L	(A0)+,(A1)+ 
L6AB94		DBF	D0,L6AB92 
L6AB98		MOVEM.L	(A7)+,D0-D3/A0-A1 
L6AB9C		RTS

L6AB9E		MOVEM.L	D0-D2/A1,-(A7) 
L6ABA2		MOVE.L	L13FDC,A1 		; screen addr
L6ABA8		MULU	#$A0,D2 		
L6ABAC		ADDA.L	D2,A1 	
L6ABAE		CMPA.L	#$78340,A1 
L6ABB4		BLT	L6ABBE 
L6ABB8		SUBA.L	#$18340,A1 
L6ABBE		MOVEQ	#$27,D0 
L6ABC0		CLR.L	(A1)+ 
L6ABC2		DBF	D0,L6ABC0 
L6ABC6		MOVEM.L	(A7)+,D0-D2/A1 
L6ABCA		RTS
*--------------- shifting the sprite
shift_sprite	MOVE.W	#3,D1 
shifty_4	MOVE.W	#31,D0 
		LEA	sprite_dat,A0 		; sprite
more_shifty	MOVE.W	#3,D2 
shift_all	ROXR	(A0) 
		ROXR	$8(A0) 
		ROXR	$10(A0) 
		ROXR	$18(A0) 
		ROXR	$20(A0) 
		ROXR	$28(A0) 
		ROXR	$30(A0) 
		ROXR	$38(A0) 
		ROXR	$40(A0) 
		ROXR	$48(A0) 
		ROXR	$50(A0) 
		LEA	$2(A0),A0 
		DBF	D2,shift_all 		; do all 4 bit-planes
		LEA	$98(A0),A0 		
		DBF	D0,more_shifty 		; do all lines
		DBF	D1,shifty_4 		; shift by 4 pixels
		RTS
*---------------
reset_rout	CLR.L	$426.W 			; if there was a virus in
		CLR.L	$42A.W 			; memory it's now one
		MOVE.L	$4.W,A0 		; dead mother fucker!!!
		JMP	(A0) 
*---------------
L6AC2C		CLR.W	LBB48 
keep_waiting	TST.W	LBB48 
		BEQ	keep_waiting		; wait for vsync
		RTS
***************************************************************************
* VBL ROUTINE         							  *
***************************************************************************
vbl		MOVE.W	#1,LBB48 		SET VBL FLAG
		MOVEM.L	D0-D7/A0-A6,-(A7) 
		MOVEM.L	paly,D0-D7 
		MOVEM.L	D0-D7,$FF8240 		; new pal
*---------------
		TST.W	sprite
		BEQ	L6AF0A 
*---------------
		MOVE.B	#0,$FFFFFA1B 		
		MOVE.B	#199,$FFFA21 		
		MOVE.L	#hbl_1,$120.W 		
		MOVE.B	#8,$FFFFFA1B 		

*--------------- The sprite movement routine
		MOVE.W	#$444,$FF8240		; GREY for the scan line count
		MOVE.L	old_pos,A1 		; old sprite pos
		MOVE.L	A1,A0 
		SUBA.L	#$70000,A0 
		ADDA.L	#picy,A0 
		MOVE.W	#7,D0 
clear_spr	MOVEM.L	(A0),D1-D7/A2-A6 	; copy over last sprite
		MOVEM.L	D1-D7/A2-A6,(A1) 	; the picture
		MOVEM.L	$30(A0),D1-D7/A2-A4 
		MOVEM.L	D1-D7/A2-A4,$30(A1) 
		MOVEM.L	$A0(A0),D1-D7/A2-A6 
		MOVEM.L	D1-D7/A2-A6,$A0(A1) 
		MOVEM.L	$D0(A0),D1-D7/A2-A4 
		MOVEM.L	D1-D7/A2-A4,$D0(A1) 
		MOVEM.L	$140(A0),D1-D7/A2-A6 
		MOVEM.L	D1-D7/A2-A6,$140(A1) 
		MOVEM.L	$170(A0),D1-D7/A2-A4 
		MOVEM.L	D1-D7/A2-A4,$170(A1) 
		MOVEM.L	$1E0(A0),D1-D7/A2-A6 
		MOVEM.L	D1-D7/A2-A6,$1E0(A1) 
		MOVEM.L	$210(A0),D1-D7/A2-A4 
		MOVEM.L	D1-D7/A2-A4,$210(A1) 
		LEA	640(A0),A0 
		LEA	640(A1),A1 
		DBF	D0,clear_spr 

*		ADDQ.W	#1,$BB3E 
*		MOVE.W	$BB3E,D0 
*		MOVE.W	#$7E,D1 
*		LEA	$BB34,A0 
*		MOVE.W	$BB3C,D2 
*		SUB.W	0(A0,D2.W),D1 
*		CMP.W	D1,D0 
*		BNE	L6AD4A 
*		ADDQ.W	#2,$BB3C 
*		CMPI.W	#8,$BB3C 
*		BNE	L6AD42 
*		CLR.W	$BB3C 
*L6AD42		CLR.W	D0 
*		MOVE.W	D0,$BB3E 
*L6AD4A		LEA	$B8E6,A0 
*		LEA	$BB2C,A1 
*		MOVE.W	$BB3C,D1 
*		ADD.W	0(A1,D1.W),D0 
*		MOVE.B	0(A0,D0.W),D0 
*		MOVE.W	$BB3C,D1 
*		MULU	#$14,D1 
*		ADD.B	D1,D0 
*		LEA	$70000,A0 		; screen addr
		lea	$76900,a0		******fink******
*		ANDI.L	#$FF,D0 		; d0 holds line no.
*		MULU	#160,D0 
*		ADDA.L	D0,A0 
		ADDA.L	line_pos,A0 		; add the line position
		MOVE.L	A0,old_pos 		; save spr pos
		LEA	mask_addrs,A0 
		LEA	sprite_addrs,A1 
		MOVE.L	spr_no,D0 		; holds sprite no.
		MOVE.L	0(A0,D0.L),A0		; get correct mask 
		MOVE.L	0(A1,D0.L),A1 		; get correct sprite
		MOVE.L	old_pos,A3 		; screen pos
		MOVE.W	#31,D1 

L6ADB2		rept	11
		MOVE.L	(A0)+,D2 		; get mask
		AND.L	D2,(A3) 		; copy it over picy

		and.l	d2,4(a3)		*****fink******

*		EXG	$4(A3),D2 		; copy it over picy
		MOVE.L	(A1)+,D2 		; get sprite
		OR.L	D2,(A3)+ 		; copy it over mask
		MOVE.L	(A1)+,D2 
		OR.L	D2,(A3)+ 		; copy it over mask
		endr

*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 

*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 

*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 

*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 

*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 

*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 

*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 

*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
	
*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
	
*		MOVE.L	(A0)+,D2 
*		AND.L	D2,(A3) 
*		EXG	$4(A3),D2 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 
*		MOVE.L	(A1)+,D2 
*		OR.L	D2,(A3)+ 

		LEA	$48(A3),A3 
		DBF	D1,L6ADB2 
*--------------- This bit works out how far across the line the
*--------------- sprite is, which direction, and which sprite to use
		TST.W	direction		; left=1, right=0 
		BNE	left 
		ADDQ.L	#4,spr_no
		BRA	check_no 

left		SUBQ.L	#4,spr_no 		; next sprite shift left
check_no	CMPI.L	#16,spr_no 		; has it gone past the last sprite
		BEQ	new_line_pos_r		; yep
		CMPI.L	#-4,spr_no 		; has it gone past the first sprite
		BEQ	new_line_pos_l		; yep
		BRA	L6AF0A 			; no, so do equ routine
*--------------- sprite moving right
new_line_pos_r	ADDQ.L	#8,line_pos		; move sprite right 
		CLR.L	spr_no 			; use first sprite
		CMPI.L	#80,line_pos		; has sprite hit right wall 
		BNE	L6AF0A 			; nar
		MOVE.W	#1,direction 		; yes, so change direction
		MOVE.L	#72,line_pos		; start pos of new direction
		MOVE.L	#12,spr_no 		; use last sprite
		BRA	L6AF0A 
*--------------- sprite moving left
new_line_pos_l	SUBQ.L	#8,line_pos 		; move sprite left
		MOVE.L	#12,spr_no 		; use last sprite
		TST.L	line_pos		; has sprite hit left wall
		BGE	L6AF0A 			; nar
		CLR.W	direction		; yes, so change direction
		CLR.L	line_pos		; new start pos of sprite
		CLR.L	spr_no 			; use first sprite
		move.w	#$500,$ff8240		; Red for the scan lines count
*---------------
L6AF0A		TST.W	m_bars
		BEQ	L6AFBA 
*--------------- music equalizer code for bottom boarder
		LEA	$FFFF8800.W,A0 
		LEA	$77D10,A1 		; screen addr (top of equ)

		LEA	$79110,A2 		; bottom of equ
		LEA	equ_buff,A3 		; equ buffer

		MOVE.B	#1,(A0) 
		MOVE.B	(A0),D0 
		ANDI.W	#7,D0 
		LSL.W	#2,D0 
		MOVE.B	#0,(A0) 
		MOVE.B	(A0),D1 
		ANDI.W	#3,D1 
		OR.W	D1,D0 
		MOVE.B	#8,(A0) 
		MOVE.B	(A0),D1 
		ANDI.W	#$F,D1 
		LSL.W	#1,D0 
		MOVE.W	D1,0(A3,D0.W) 

		MOVE.B	#3,(A0) 
		MOVE.B	(A0),D0 
		ANDI.W	#7,D0 
		LSL.W	#1,D0 
		MOVE.B	#2,(A0) 
		MOVE.B	(A0),D1 
		ANDI.W	#3,D1 
		OR.W	D1,D0 
		MOVE.B	#9,(A0) 
		MOVE.B	(A0),D1 
		ANDI.W	#$F,D1 
		LSL.W	#1,D0 
		MOVE.W	D1,0(A3,D0.W) 

		MOVE.B	#5,(A0) 
		MOVE.B	(A0),D0 
		ANDI.W	#7,D0 
		LSL.W	#2,D0 
		MOVE.B	#4,(A0) 
		MOVE.B	(A0),D1 
		ANDI.W	#3,D1 
		OR.W	D1,D0 
		MOVE.B	#$A,(A0) 
		MOVE.B	(A0),D1 
		ANDI.W	#$F,D1 
		LSL.W	#1,D0 
		MOVE.W	D1,0(A3,D0.W) 

		MOVE.W	#31,D0 
display_equ	BSR	L6B202 
		BSR	L6B230 
		DBF	D0,display_equ
		move.w	#$050,$ff8240		; GREEN for the scan line count
		EORI.W	#1,LBB28 
*--------------- Run scroller routine
L6AFBA		TST.W	scroller 
		BEQ	L6B036 
		CMPI.W	#8,scr_count
		BNE	just_scroll
		ADDQ.L	#1,text_p 		; next letter
		CLR.W	scr_count		; clear buff counter 
		MOVEQ	#0,D0 
		MOVE.L	text_p,A0 		; text pointer
		MOVE.B	(A0),D0 		; get letter
		CMP.B	#-1,D0 			; check for end of text
		BNE	no_reset
		MOVE.L	#text,text_p 		; reset pointer
		MOVE.W	#8,scr_count 		; set buff counter
		BRA	L6B036 

no_reset	SUBI.B	#$20,D0 
		LSL.W	#2,D0 
		LEA	font_table,A0 		; font table
		MOVE.L	0(A0,D0.W),A0 
		LEA	scr_buff,A1 		; buffer
		MOVE.W	#30,D0 
fill_buffer	MOVE.W	(A0),(A1)+ 
		MOVE.W	8(A0),(A1)+ 
		LEA	160(A0),A0 
		DBF	D0,fill_buffer

just_scroll	BSR	L6B08C 			; scroll text
		ADDQ.W	#1,scr_count 		; increase buff counter
		move.w	#$005,$ff8240		; BLUE for the scan line count
*---------------
L6B036	
		JSR	MUSIC+8			*****FINK******
*		JSR	$4D80C			; play music 
		EORI.W	#1,LBB2A 
		TST.W	LBB2A 
		BNE	slow_cycle
		CMPI.L	#84,col_count 		; check for end of cycle
		BNE	no_reset2 
		CLR.L	col_count		; reset cycle 
no_reset2	LEA	col_data,A0 
		ADDA.L	col_count,A0 
		ADDQ.L	#2,col_count		; shift up for next time 
		MOVEM.L	(A0),D0-D7 		; set up colours for cycle
		MOVEM.L	D0-D7,col_1
slow_cycle	MOVEM.L	(A7)+,D0-D7/A0-A6 
		MOVE.L	old_vbl,-(A7) 
		RTS
*--------------- end of vbl
*--------------- scroll text....
L6B08C		LEA	scr_buff,A0 		; buffer
		MOVE.L	scr_addr,A1 		; scroll addr
		MOVE.W	#30,D2 
scrolly		ROXL	$2(A0) 
		ROXL	(A0) 
		ROXL	$98(A1) 
		ROXL	$90(A1) 
		ROXL	$88(A1) 
		ROXL	$80(A1) 
		ROXL	$78(A1) 
		ROXL	$70(A1) 
		ROXL	$68(A1) 
		ROXL	$60(A1) 
		ROXL	$58(A1) 
		ROXL	$50(A1) 
		ROXL	$48(A1) 
		ROXL	$40(A1) 
		ROXL	$38(A1) 
		ROXL	$30(A1) 
		ROXL	$28(A1) 
		ROXL	$20(A1) 
		ROXL	$18(A1) 
		ROXL	$10(A1) 
		ROXL	$8(A1) 
		ROXL	$0(A1) 
		ROXL	$2(A0) 
		ROXL	(A0) 
		ROXL	$98(A1) 
		ROXL	$90(A1) 
		ROXL	$88(A1) 
		ROXL	$80(A1) 
		ROXL	$78(A1) 
		ROXL	$70(A1) 
		ROXL	$68(A1) 
		ROXL	$60(A1) 
		ROXL	$58(A1) 
		ROXL	$50(A1) 
		ROXL	$48(A1) 
		ROXL	$40(A1) 
		ROXL	$38(A1) 
		ROXL	$30(A1) 
		ROXL	$28(A1) 
		ROXL	$20(A1) 
		ROXL	$18(A1) 
		ROXL	$10(A1) 
		ROXL	$8(A1) 
		ROXL	$0(A1) 
		ROXL	$2(A0) 
		ROXL	(A0) 
		ROXL	$98(A1) 
		ROXL	$90(A1) 
		ROXL	$88(A1) 
		ROXL	$80(A1) 
		ROXL	$78(A1) 
		ROXL	$70(A1) 
		ROXL	$68(A1) 
		ROXL	$60(A1) 
		ROXL	$58(A1) 
		ROXL	$50(A1) 
		ROXL	$48(A1) 
		ROXL	$40(A1) 
		ROXL	$38(A1) 
		ROXL	$30(A1) 
		ROXL	$28(A1) 
		ROXL	$20(A1) 
		ROXL	$18(A1) 
		ROXL	$10(A1) 
		ROXL	$8(A1) 
		ROXL	$0(A1) 
		ROXL	$2(A0) 
		ROXL	(A0) 
		ROXL	$98(A1) 
		ROXL	$90(A1) 
		ROXL	$88(A1) 
		ROXL	$80(A1) 
		ROXL	$78(A1) 
		ROXL	$70(A1) 
		ROXL	$68(A1) 
		ROXL	$60(A1) 
		ROXL	$58(A1) 
		ROXL	$50(A1) 
		ROXL	$48(A1) 
		ROXL	$40(A1) 
		ROXL	$38(A1) 
		ROXL	$30(A1) 
		ROXL	$28(A1) 
		ROXL	$20(A1) 
		ROXL	$18(A1) 
		ROXL	$10(A1) 
		ROXL	$8(A1) 
		ROXL	$0(A1) 
		LEA	$4(A0),A0 
		LEA	$A0(A1),A1 
		DBF	D2,scrolly 
		RTS
*--------------- clear music equ
L6B202		MOVE.L	A1,A0 
		MOVE.W	D0,D1 
		LSL.W	#2,D1 
		BTST	#2,D1 
		BEQ	L6B212 
		SUBQ.W	#3,D1 
L6B212		ADDA.W	D1,A0 
		MOVE.W	#7,D1 
L6B218		CLR.B	(A0) 
		CLR.B	$A0(A0) 
		CLR.B	$140(A0) 
		CLR.B	$1E0(A0) 
		LEA	$280(A0),A0 
		DBF	D1,L6B218 
		RTS
*--------------- display music equ
L6B230		MOVE.W	D0,D1 
		MOVE.L	A2,A0 
		LSL.W	#1,D1 
		MOVE.W	0(A3,D1.W),D2 
		TST.W	LBB28 
		BNE	L6B250 
		TST.W	0(A3,D1.W) 
		BEQ	L6B250 
		SUBQ.W	#1,0(A3,D1.W) 
L6B250		LSL.W	#1,D1 
		BTST	#2,D1 
		BEQ	L6B25C 
		SUBQ.W	#3,D1 
L6B25C		ADDA.W	D1,A0 
L6B25E		MOVE.B	#$FF,(A0) 
		MOVE.B	#$FF,-160(A0) 
		LEA	-320(A0),A0 
		DBF	D2,L6B25E 
		RTS
*---------------
set_mfp		MOVE.B	$FFFFFA07,old_07 	; save MFP registers
		MOVE.B	$FFFFFA09,old_09 
		MOVE.B	$FFFFFA0F,old_0f
		MOVE.B	$FFFFFA11,old_11
		MOVE.B	$FFFFFA1B,old_1b
		ANDI.B	#$DF,$FFFA09 
		ANDI.B	#$FE,$FFFA07 
		MOVE.L	#null,$120 		; new hbl (does nout)
		ORI.B	#1,$FFFFFA07 
		ORI.B	#1,$FFFFFA13 
		RTS
*---------------
restore_mfp	MOVE.W	SR,-(A7) 
		MOVE.W	#$2700,SR 
		MOVE.B	old_07(PC),$FFFFFA07	
		MOVE.B	old_09(PC),$FFFFFA09 
		MOVE.B	old_0f(PC),$FFFFFA0F 
		MOVE.B	old_11(PC),$FFFFFA11 
		MOVE.B	old_1b(PC),$FFFFFA1B 
		MOVE.L	old_hbl,$120 		
		MOVE.W	(A7)+,SR 
		RTS
*---------------
null		RTE
***************************************************************************
* TIMER B ROUTINE	- GETS RID OF BOTTOM BOARDER			  *
***************************************************************************
hbl_1		CLR.B	$FFFFFA1B 		
		MOVEM.L	D0/A0,-(A7) 
		LEA	$FFFFFA21,A0 
		MOVE.B	#200,(A0) 		; wait for scan line 200
		MOVE.B	#8,$FFFFFA1B 
		MOVE.B	(A0),D0 
last		CMP.B	(A0),D0 
		BEQ	last			; wait for last scan line
		MOVE.B	#$FC,$FFFF820A 		; 60Hz
		MOVE.W	#2,D0 
nopy		NOP
		DBF	D0,nopy 		

		MOVE.B	#$FE,$FFFF820A 		; 50Hz
		MOVEM.L	(A7)+,D0/A0 
		MOVE.B	#0,$FFFFFA1B 		
		MOVE.B	#1,$FFFFFA21 		; wait 1 scan line
		MOVE.L	#hbl_2,$120.W 		
		MOVE.B	#8,$FFFFFA1B 		
		BCLR	#0,$FFFFFA0F 		
		RTE
*---------------
hbl_2		MOVE.B	#0,$FFFFFA1B 		
		MOVE.W	#$700,$FF8242 
		MOVE.W	col_1,$FF8250 
		MOVE.W	col_1,$FF8252 
		MOVE.W	col_1,$FF8254 
		MOVE.W	col_1,$FF8258 		
		MOVE.B	#2,$FFFFFA21 		
		MOVE.L	#hbl_3,$120.W 		
		MOVE.B	#8,$FFFFFA1B 		
		BCLR	#0,$FFFFFA0F 		
		RTE
*---------------
hbl_3		MOVE.B	#0,$FFFFFA1B 		
		MOVE.W	col_2,$FF8250 
		MOVE.W	col_2,$FF8252 
		MOVE.W	col_2,$FF8254 
		MOVE.W	col_2,$FF8258 		
		MOVE.L	#hbl_4,$120.W 		
		MOVE.B	#8,$FFFFFA1B		
		BCLR	#0,$FFFFFA0F 		
		RTE
*---------------
hbl_4		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	#$600,$FF8242 
		MOVE.W	col_3,$FF8250 
		MOVE.W	col_3,$FF8252 
		MOVE.W	col_3,$FF8254 
		MOVE.W	col_3,$FF8258		
		MOVE.L	#hbl_5,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_5		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	col_4,$FF8250 
		MOVE.W	col_4,$FF8252 
		MOVE.W	col_4,$FF8254 
		MOVE.W	col_4,$FF8258 		
		MOVE.L	#hbl_6,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_6		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	#$500,$FF8242 
		MOVE.W	col_5,$FF8250 
		MOVE.W	col_5,$FF8252 
		MOVE.W	col_5,$FF8254 
		MOVE.W	col_5,$FF8258		
		MOVE.L	#hbl_7,$120.W		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_7		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	col_6,$FF8250 
		MOVE.W	col_6,$FF8252 
		MOVE.W	col_6,$FF8254 
		MOVE.W	col_6,$FF8258 		
		MOVE.L	#hbl_8,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_8		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	#$70,$FF8242 
		MOVE.W	col_7,$FF8250 
		MOVE.W	col_7,$FF8252 
		MOVE.W	col_7,$FF8254 
		MOVE.W	col_7,$FF8258 		
		MOVE.L	#hbl_9,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_9		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	col_8,$FF8250 
		MOVE.W	col_8,$FF8252 
		MOVE.W	col_8,$FF8254 
		MOVE.W	col_8,$FF8258 		
		MOVE.L	#hbl_10,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_10		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	#$60,$FF8242 
		MOVE.W	col_9,$FF8250 
		MOVE.W	col_9,$FF8252 
		MOVE.W	col_9,$FF8254 
		MOVE.W	col_9,$FF8258 		
		MOVE.L	#hbl_11,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_11		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	col_10,$FF8250 
		MOVE.W	col_10,$FF8252 
		MOVE.W	col_10,$FF8254 
		MOVE.W	col_10,$FF8258 		
		MOVE.L	#hbl_12,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_12		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	#$50,$FF8242 
		MOVE.W	col_11,$FF8250 
		MOVE.W	col_11,$FF8252 
		MOVE.W	col_11,$FF8254 
		MOVE.W	col_11,$FF8258 		
		MOVE.L	#hbl_13,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_13		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	col_12,$FF8250 
		MOVE.W	col_12,$FF8252 
		MOVE.W	col_12,$FF8254 
		MOVE.W	col_12,$FF8258 		
		MOVE.L	#hbl_14,$120.W		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_14		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	#$40,$FF8242 
		MOVE.W	col_13,$FF8250 
		MOVE.W	col_13,$FF8252 
		MOVE.W	col_13,$FF8254 
		MOVE.W	col_13,$FF8258 	
		MOVE.L	#hbl_15,$120.W 
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_15		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	col_14,$FF8250 
		MOVE.W	col_14,$FF8252 
		MOVE.W	col_14,$FF8254 
		MOVE.W	col_14,$FF8258		
		MOVE.L	#hbl_16,$120.W 		
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_16		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	#$30,$FF8242 
		MOVE.W	col_15,$FF8250 
		MOVE.W	col_15,$FF8252 
		MOVE.W	col_15,$FF8254 
		MOVE.W	col_15,$FF8258 	
		MOVE.L	#hbl_17,$120.W 	
		MOVE.B	#8,$FFFFFA1B 
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------
hbl_17		MOVE.B	#0,$FFFFFA1B 
		MOVE.W	col_16,$FF8250 
		MOVE.W	col_16,$FF8252 
		MOVE.W	col_16,$FF8254 
		MOVE.W	col_16,$FF8258 		
		BCLR	#0,$FFFFFA0F 
		RTE
*---------------

L13FE0		DC.L	0
L13FE4		DC.L	0
L13FE8		DS.B	1600
LBB48		DC.W	0				VBL FLAG
old_scr		DC.L	0				
old_ssp		DC.L	0				
old_hz		DC.B	0				
old_vbl		DC.L	0				
old_hbl		DC.L	0				
LBB26		DC.W	0				MUSIC NUMBER
LB038		DC.L	0				??????
L13FDC		DC.L	0				SCREEN ADDRESS
old_07		DC.B	0				
old_09		DC.B	0				
old_0f		DC.B	0				
old_11		DC.B	0				
old_1b		DC.B	0
mask_addrs	ds.l	4
sprite_addrs	ds.l	4
spr_no		dc.l	0
direction	dc.w	0
line_pos	dc.l	0
old_pos		dc.l	$70000
LBB2A		dc.w	0
scr_addr	dc.l	0
scr_count	dc.w	0	
m_bars		dc.w	0	
LBB28		dc.w	0			; used in music bars
equ_buff	ds.w	32
scroller	dc.w	0
sprite		dc.w	0
scr_buff	ds.w	2*31
text_p		dc.l	0		
text		dc.b	" THE FINK RETURNS WITH PROBABLY ONE OF THE BEST HACKS "
		DC.B	" THAT I'VE DONE IN A WHILE    COS I'VE BEEN PRETTY"
		DC.B	" LAZY LATELY    ANYWAY, HELLOS TO ALL OTHER MEMBERS"
		DC.B	" OF THE CENOBYTES (THE WILLS, REESE, CRAZY CHRIS)"
		DC.B	"    AND A BIG HELLO TO THAT GIRL I SAW AT ALTON TOWERS"
		DC.B	" WHILE WAITING TO GO ON THE 'BEAST' ROLLERCOASTER"
		DC.B	"    COR BLIMEY,     NOT ARF     BY THE WAY WILLS, UNLIKE"
		DC.B	" YOU I DON'T USE TEXT EDITORS TO CHANGE THE TEXT"
		DC.B	"     WELL, WHATS BEEN HAPPENING LATELY WITH THE CENOBYTES"
		DC.B	" ?   CRAZY CHRIS HAS DONE SOD ALL    EXCEPT CODE ONE MENU"
		DC.B	" WHICH RUNS FAR TO SLOW BECAUSE HE WAS RUNNING EVERYTHING"
		DC.B	" UNDER THE VERTICAL BLANK      HE'S NEVER HEARD OF THE FLIP"
		DC.B	" SCREEN METHOD       REESE HAS DONE SOD ALL   I HAVE NOT"
		DC.B	" SEEN HIM FOR A WHILE BUT I KNOW HE HAS NOT DONE ANYTHING"
		DC.B	"   HOW ABOUT SOME ART REESE ?    HES ACTUALY OUR MAIN SOFTWARE"
		DC.B	" SUPPLIER (AND HE DOESNT SUPPLY VERY OFTEN !!!)     THE WILLS"
		DC.B	" HAS BEEN FIDDLING WITH VECTOR GRAPHICS (AT LEAST SOMEONE HAS"
		DC.B	" BEEN DOING SOMTHING !)    AS THE SUMMER HOLS COME TO AN END"
		DC.B	" AND WE GO BACK TO COLLEGE WE SHOULD GET SOME MORE STUFF DONE"
		DC.B	"       THIS MUSIC PLAYING WAS RIPPED BY ME (THE FINK) FROM"
		DC.B	" THE ULM (DARK SIDE OF THE SPOON DEMO)  WHICH HAPPENS TO BE"
		DC.B	" ONE OF THE BEST DEMOS I HAVE EVER SEEN ON THE ST AND IT WAS"
		DC.B	" NOT BEING USED ON THE DEMO (ANOTHER TRACK FROM THE SOURCE MUSIC"
		DC.B	" WAS) SO AS FAR AS I KNOW THIS IS THE FIRST TIME IT HAS EVER BEEN"
		DC.B	" HEARD ON A MENU         WOW      WRAP                  "
		DC.B	-1
		EVEN
col_count	dc.l	0
col_1		dc.w	0
col_2		dc.w	0
col_3		dc.w	0
col_4		dc.w	0
col_5		dc.w	0
col_6		dc.w	0
col_7		dc.w	0
col_8		dc.w	0
col_9		dc.w	0
col_10		dc.w	0
col_11		dc.w	0
col_12		dc.w	0
col_13		dc.w	0
col_14		dc.w	0
col_15		dc.w	0
col_16		dc.w	0

col_data	dc.w	$110,$220,$330,$440,$550,$660,$770,$771
		dc.w	$772,$773,$774,$775,$776,$777,$677,$577
		dc.w	$477,$377,$277,$177,$077,$067,$057,$047
		dc.w	$037,$027,$017,$007,$107,$207,$307,$407
		dc.w	$507,$607,$707,$606,$505,$404,$303,$202
		dc.w	$101,$110,$110,$220,$330,$440,$550,$660
		dc.w	$770,$771,$772,$773,$774,$775,$776,$777
		dc.w	$677,$577
font_table		
		dc.l	font+34+16+(160*128)		; space
		dc.l	font+34+112+(160*96)		; !
		dc.l	font+34				; "
		dc.l	font+34				; #
		dc.l	font+34				; $
		dc.l	font+34				; %
		dc.l	font+34				; &
		dc.l	font+34+32+(160*128)		; '
		dc.l	font+34+144+(160*96)		; (
		dc.l	font+34+(160*128)		; )
		dc.l	font+34				; *
		dc.l	font+34				; +
		dc.l	font+34+48+(160*128)		; ,
		dc.l	font+34				; -
		dc.l	font+34+128+(160*96)		; .
		dc.l	font+34				; /
		dc.l	font+34+96+(160*64)		; 0
		dc.l	font+34+112+(160*64)		; 1
		dc.l	font+34+128+(160*64)		; 2
		dc.l	font+34+144+(160*64)		; 3
		dc.l	font+34+(160*96)		; 4
		dc.l	font+34+16+(160*96)		; 5
		dc.l	font+34+32+(160*96)		; 6
		dc.l	font+34+48+(160*96)		; 7
		dc.l	font+34+64+(160*96)		; 8
		dc.l	font+34+80+(160*96)		; 9
		dc.l	font+34				; :
		dc.l	font+34				; ;
		dc.l	font+34				; <
		dc.l	font+34				; =
		dc.l	font+34				; >
		dc.l	font+34+96+(160*96)		; ?
		dc.l	font+34				; @
		dc.l	font+34				; A
		dc.l	font+34+16			; B
		dc.l	font+34+32			; C
		dc.l	font+34+48			; D
		dc.l	font+34+64			; E
		dc.l	font+34+80			; F
		dc.l	font+34+96			; G
		dc.l	font+34+112			; H
		dc.l	font+34+128			; I
		dc.l	font+34+144			; J
		dc.l	font+34+(160*32)		; K
		dc.l	font+34+16+(160*32)		; L
		dc.l	font+34+32+(160*32)		; M
		dc.l	font+34+48+(160*32)		; N
		dc.l	font+34+64+(160*32)		; O
		dc.l	font+34+80+(160*32)		; P
		dc.l	font+34+96+(160*32)		; Q
		dc.l	font+34+112+(160*32)		; R
		dc.l	font+34+128+(160*32)		; S
		dc.l	font+34+144+(160*32)		; T
		dc.l	font+34+(160*64)		; U
		dc.l	font+34+16+(160*64)		; V
		dc.l	font+34+32+(160*64)		; W
		dc.l	font+34+48+(160*64)		; X
		dc.l	font+34+64+(160*64)		; Y
		dc.l	font+34+80+(160*64)		; Z
		
		
PIC		INCBIN	'b:\MED_100\MED_100.PI1'
picy		EQU	PIC+34				
paly		EQU	PIC+2
FONT		INCBIN	B:\MED_100\FONT_10.PI1
MUSIC		INCBIN	b:\med_100\hide.MUS

sprite_dat	INCBIN	B:\MED_100\sprite.gfx
mask_buff	ds.b	1408
mask_2_buff	ds.b	1408
mask_3_buff	ds.b	1408
mask_4_buff	ds.b	1408
sprite_buff	ds.b	2816
sprite_2_buff	ds.b	2816
sprite_3_buff	ds.b	2816
sprite_4_buff	ds.b	2816