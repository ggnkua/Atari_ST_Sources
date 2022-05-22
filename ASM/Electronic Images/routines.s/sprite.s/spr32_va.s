; 32*32 real-time shifting Sprite Rout. (with mouse movement to test it)
; by Martin Griffiths (C) 1991
; (4 32*32 sprites with clearing takes about 54% or 45% without)
; (notice also how much little variation there is in time taken!)

demo		EQU 0

		IFEQ demo
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; low res
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		ENDC

mans_start	MOVE #$2700,SR
		LEA stack(PC),SP
		MOVE.L log_base(PC),A0
		BSR cls
		MOVE.L phy_base(PC),A0
		BSR cls
		MOVEM.L pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE #$15,D0
		BSR write_ikbd
		MOVE #9,D0
		BSR write_ikbd
		MOVE #1,D0
		BSR write_ikbd
		MOVE #$3F,D0
		BSR write_ikbd
		MOVE #0,D0
		BSR write_ikbd
		MOVE #199,D0
		BSR write_ikbd
set_mouse	MOVEQ #$E,D0
		BSR write_ikbd
		MOVE #0,D0
		BSR write_ikbd
		MOVE #0,D0
		BSR write_ikbd
		MOVE #160,D0
		BSR write_ikbd
		MOVE #0,D0
		BSR write_ikbd
		MOVE #100,D0
		BSR write_ikbd
		BSR init_sprite
		MOVE.L $70.W,old_vbl
		MOVE.L $118.W,old_key
		MOVE.L #vbl,$70.W
		MOVE.L #key_rout,$118.W
		LEA old_mfp(PC),A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B #$00,$FFFFFA07.W
		MOVE.B #$40,$FFFFFA09.W
		MOVE.B #$00,$FFFFFA13.W
		MOVE.B #$40,$FFFFFA15.W
		MOVE #$D,D0
		BSR write_ikbd

		MOVE #$2300,SR
		BSR flush

; Main program vbl loop starts here.

vbl_lp		BSR Swap_Screens
		MOVE.W #$220,$FFFF8240.W
		BSR Wait_Vbl
		MOVE.W #$000,$FFFF8240.W
		BSR Clear_Old
		BSR Draw_Sprites

		CMP.B #$39,key
		BNE vbl_lp

restore		BSR flush
		MOVE #$2700,SR
		MOVEQ #$8,D0
		BSR write_ikbd
		LEA old_mfp(PC),A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.L old_vbl(PC),$70.W
		MOVE.L old_key(PC),$118.W
		MOVE.L #$07770000,$FFFF8240.W
		MOVE.L #$00000000,$FFFF8244.W
		MOVE.W #$2300,sr
		CLR -(SP)
		TRAP #1

; Clear Screen -> A0

cls		MOVE #1999,D0
		MOVEQ #0,D1
cls_lp		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		MOVE.L D1,(A0)+
		DBF D0,cls_lp
		RTS
	
; Swap those screens!

Swap_Screens	LEA log_base(PC),A0
		MOVE.L (A0)+,D0
		MOVE.L (A0)+,D1
		NOT.W (A0)
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		RTS

; Wait for 1 Vbl.

Wait_Vbl	MOVE vbl_timer(PC),D0
.wait_vbl	CMP vbl_timer(PC),D0
		BEQ.S .wait_vbl
		RTS

; Clear Old Sprites.

Clear_Old	LEA old_xys1(PC),A1
		TST switch
		BEQ.S clr_old
		LEA old_xys2(PC),A1
clr_old		MOVE.L log_base(PC),A0
		MOVEQ #8-1,D7
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVEQ #0,D3
		MOVEQ #0,D4
		MOVEQ #0,D5
clr_lp		MOVE.L A0,A2
		ADD (A1)+,A2
i		SET 0
		REPT 16
		MOVEM.L D0-D5,i(A2)
		MOVEM.L D0-D5,i+160(A2)
i		SET i+320
		ENDR
		DBF D7,clr_lp
		RTS

; Draw new Sprites
		
Draw_Sprites	LEA xymodbuf(PC),A5
		MOVEM.L $78+$28(A5),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C+$28(A5)
		MOVEM.L $78(A5),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$7C(A5)
		MOVEM.L $50(A5),D0-D7/A0-A2
		MOVEM.L D0-D7/A0-A2,$54(A5)
		MOVEM.L $28(A5),D0-D7/A0-A1
		MOVEM.L D0-D7/A0-A1,$2C(A5)
		MOVEM.L (A5),D0-D7/A0-A1
		MOVEM.L D0-D7/A0-A1,4(A5)
		MOVE mousex(PC),D0
		MOVE mousey(PC),D1
.which_clear	LEA old_xys1(PC),A6
		TST switch
		BEQ.S .cse2
		LEA old_xys2(PC),A6
.cse2		MOVE D0,(A5)
		MOVE D1,2(A5)
		BSR draw
		MOVE 24(A5),D0
		MOVE 26(A5),D1
		BSR draw
		MOVE 48(A5),D0
		MOVE 50(A5),D1
		BSR draw
		MOVE 72(A5),D0
		MOVE 74(A5),D1
		BSR draw
		MOVE 96(A5),D0
		MOVE 98(A5),D1
		BSR draw
		MOVE 120(A5),D0
		MOVE 122(A5),D1
		BSR draw
		MOVE 144(A5),D0
		MOVE 146(A5),D1
		BSR draw
		MOVE 168(A5),D0
		MOVE 170(A5),D1
		BSR draw
		RTS

; Draw 32*32 sprite - real time shift rout... (simple but very fast).
; (some re-ordering or fetching from screen instead might speed up?)

draw		
		LEA sprite1(PC),A0
		LEA mask1(PC),A1
		MOVE.L log_base(PC),A2	; screen base
		LSL #3,D0		; x*8
		ADD.W D1,D1		; y*2
		LEA xinfo_tab(PC),A3
		MOVEM.L (A3,D0),D5/A4
		LEA mul160_look(PC),A3	; *160 table
		ADD.W (A3,D1),D5	; add line offset to row offy
		MOVE D5,(A6)+		; save offset(for delete)
		ADDA D5,A2		; screen addr
		SWAP D5			; shift value
		CMP #8,D5
		BGT .morethan8
.lessthan8	MOVEQ #32-1,D6
.lpl8		LEA (A2),A3
		MOVE.L (A1)+,D0
		ROR.L D5,D0 
		MOVE.W A4,D1
		OR.W D0,D1
		EOR.W D1,D0
		NOT.W D0
		AND.W D0,(A2)+
		AND.W D0,(A2)+
		AND.W D0,(A2)+
		SWAP D0
		AND.L D0,(A2)+
		AND.W D0,(A2)+
		AND.W D0,(A2)+
		AND.W D0,(A2)+
		AND.W D1,(A2)+
		AND.W D1,(A2)+
		AND.W D1,(A2)+
		AND.W D1,(A2)+

		MOVEM.L (A0)+,D0-D3	; mask 'n' 4 planes data
		ROR.L D5,D0 
		ROR.L D5,D1 		; shift the 32 pixels
		ROR.L D5,D2 
		ROR.L D5,D3

		MOVE.L D0,D4
		MOVE.W D1,D4
		MOVE.L D2,D7
		MOVE.W D3,D7

		MOVE.W D0,D1
		SWAP D1
		MOVE.W D2,D3
		SWAP D3

		MOVE.L A4,D0
		MOVE.L A4,D2
		AND.L D1,D0
		AND.L D3,D2
 		OR.L D0,(A3)+		
 		OR.L D2,(A3)+		
 		OR.L D4,(A3)+
 		OR.L D7,(A3)+
		EOR.L D0,D1
		EOR.L D2,D3
 		OR.L D1,(A3)+		
 		OR.L D3,(A3)+
		LEA 160-24(A2),A2		; next row
		DBF D6,.lpl8
		RTS

.morethan8	NEG D5
		ADD #16,D5
		MOVEQ #32-1,D6
.lpm8		LEA (A2),A3
		MOVE.L (A1)+,D0
		SWAP D0
		ROL.L D5,D0 
		MOVE.W A4,D1
		OR.W D0,D1
		EOR.W D1,D0
		NOT.W D0
		AND.W D0,(A2)+
		AND.W D0,(A2)+
		AND.W D0,(A2)+
		SWAP D0
		AND.L D0,(A2)+
		AND.W D0,(A2)+
		AND.W D0,(A2)+
		AND.W D0,(A2)+
		AND.W D1,(A2)+
		AND.W D1,(A2)+
		AND.W D1,(A2)+
		AND.W D1,(A2)+

		MOVEM.L (A0)+,D0-D3	; mask 'n' 4 planes data
		SWAP D0
		SWAP D1
		SWAP D2
		SWAP D3
		ROL.L D5,D0 
		ROL.L D5,D1 		; shift the 32 pixels
		ROL.L D5,D2 
		ROL.L D5,D3

		MOVE.L D0,D4
		MOVE.W D1,D4
		MOVE.L D2,D7
		MOVE.W D3,D7

		MOVE.W D0,D1
		SWAP D1
		MOVE.W D2,D3
		SWAP D3

		MOVE.L A4,D0
		MOVE.L A4,D2
		AND.L D1,D0
		AND.L D3,D2
 		OR.L D0,(A3)+		
 		OR.L D2,(A3)+		
 		OR.L D4,(A3)+
 		OR.L D7,(A3)+
		EOR.L D0,D1
		EOR.L D2,D3
 		OR.L D1,(A3)+		
 		OR.L D3,(A3)+
		LEA 160-24(A2),A2		; next row
		DBF D6,.lpm8
		RTS

		RTS
i		SET 0
xinfo_tab	REPT 20
		DC.W 0,i
		DC.W %1111111111111111,%1111111111111111
		DC.W 1,i
		DC.W %0111111111111111,%0111111111111111
		DC.W 2,i
		DC.W %0011111111111111,%0011111111111111
		DC.W 3,i
		DC.W %0001111111111111,%0001111111111111
		DC.W 4,i
		DC.W %0000111111111111,%0000111111111111
		DC.W 5,i
		DC.W %0000011111111111,%0000011111111111
		DC.W 6,i
		DC.W %0000001111111111,%0000001111111111
		DC.W 7,i
		DC.W %0000000111111111,%0000000111111111
		DC.W 8,i
		DC.W %0000000011111111,%0000000011111111
		DC.W 9,i
		DC.W %0000000001111111,%0000000001111111
		DC.W 10,i
		DC.W %0000000000111111,%0000000000111111
		DC.W 11,i
		DC.W %0000000000011111,%0000000000011111
		DC.W 12,i
		DC.W %0000000000001111,%0000000000001111
		DC.W 13,i
		DC.W %0000000000000111,%0000000000000111
		DC.W 14,i
		DC.W %0000000000000011,%0000000000000011
		DC.W 15,i
		DC.W %0000000000000001,%0000000000000001
i		SET i+8
		ENDR

; Keyboard/Mouse handler interrupt routine...

key_rout	MOVE #$2500,SR
		MOVE D0,-(SP)
		MOVE.B $FFFFFC00.W,D0
		BTST #7,D0
		BEQ.S end
		BTST #0,D0
		BEQ.S end
key_read	MOVE.B $FFFFFC02.W,D0
		CMP.B #$F7,D0
		BEQ.S start_mouse
		MOVE.B D0,key
end		MOVE (SP)+,D0
endi		BCLR #6,$FFFFFA11.W
		RTE

start_mouse	MOVE.L #mouseb1,$118.W
		BRA.S end
mouseb1		MOVE.L #mouseb2,$118.W
		MOVE.B $FFFFFC02.W,mousex-1
		BRA.S endi
mouseb2		MOVE.L #mouseb3,$118.W
		MOVE.B $FFFFFC02.W,mousex
		BRA.S endi
mouseb3		MOVE.L #mouseb4,$118.W
		MOVE.B $FFFFFC02.W,mousex+1
		BRA.S endi
mouseb4		MOVE.L #mouseb5,$118.W
		MOVE.B $FFFFFC02.W,mousex+2
		BRA.S endi
mouseb5		MOVE.L #key_rout,$118.W
		MOVE.B $FFFFFC02.W,mousex+3
		BRA.S endi

*************************************

write_ikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S write_ikbd
		MOVE.B D0,$FFFFFC02.W
		RTS

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

; The vbl sends command to the ikbd to make it report the mouse xy.

vbl		MOVE D0,-(SP)
		ADDQ #1,vbl_timer
		MOVE #$D,D0
		BSR write_ikbd
		MOVE (SP)+,D0
		RTE

; Initialise the sprite data. (the sprite has 16 pixels extra each line)

init_sprite	LEA sprite(PC),A0
		LEA sprite1(PC),A1
		LEA mask1(PC),A2
		MOVEQ #31,D7
inilp		MOVEM.W (A0)+,D1-D4
		SWAP D1
		SWAP D2
		SWAP D3
		SWAP D4
		MOVE.W (A0)+,D1
		MOVE.W (A0)+,D2
		MOVE.W (A0)+,D3
		MOVE.W (A0)+,D4
		MOVE.L D1,D0
		OR.L D2,D0
		OR.L D3,D0
		OR.L D4,D0
		NOT.L D0
		SWAP D0
		MOVE.L D0,(A2)+
		SWAP D1
		SWAP D3
		MOVEM.L D1-D4,(A1)
		LEA 8(A0),A0		; skip last chunk
		LEA 16(A1),A1		; advance ptr.
		DBF D7,inilp 
		RTS

i		SET 0
mul160_look	REPT 50
		DC.W i,i+160,i+320,i+480
i		SET i+640
		ENDR


pal		dc.w	$0000,$0101,$0323,$0212,$0101,$0434,$0545,$0312 
		dc.w	$0423,$0534,$0201,$0656,$0767,$0756,$0645,$0745 

sprite		dc.l	$00060007,$00080000,$E000E000,$10000000,$00000000 
		dc.l	$00000000,$0007007D,$00020000,$F600FE00,$00000000 
		dc.l	$00000000,$00000000,$00F1010F,$00FC0000,$F780FF80 
		dc.l	$00000000,$00000000,$00000000,$027801F7,$03880070 
		dc.l	$75C0C5C0,$3A000000,$00000000,$00000000,$050E0379 
		dc.l	$06F60188,$6AA0AAE0,$55000000,$00000000,$00000000 
		dc.l	$0C470476,$0BB907CF,$A5C06640,$DBB08000,$00000000 
		dc.l	$00000000,$01061809,$0FFF07F0,$6C00EA00,$97F84000 
		dc.l	$00000000,$00000000,$33CF2971,$1FBE07C1,$F2787C78 
		dc.l	$8F84C000,$00000000,$00000000,$314F2871,$1FBE07C1 
		dc.l	$F278FC78,$8F84C000,$00000000,$00000000,$150B2D77 
		dc.l	$5AFD0783,$870078CA,$FF34800A,$00000000,$00000000 
		dc.l	$51AF6BBA,$1E5705EE,$A4546576,$9B8C0002,$00000000 
		dc.l	$00000000,$4CDC7BE3,$173408D8,$6B80EAB8,$15440002 
		dc.l	$00000000,$00000000,$45B13B4F,$F6700180,$BA02F5F2 
		dc.l	$0E03000C,$00000000,$00000000,$73C75F3F,$A5E80300 
		dc.l	$A602D9F7,$3E0A0005,$00000000,$00000000,$BF3CACF3 
		dc.l	$534F0600,$18D3E8FF,$F702000C,$00000000,$00000000 
		dc.l	$EFF4DA27,$37D90FE0,$0083FCCF,$E303003C,$00000000 
		dc.l	$00000000,$43C8BD3B,$66F50340,$30ABD2F9,$ED290016 
		dc.l	$00000000,$00000000,$70C697BF,$68710040,$612793FD 
		dc.l	$EC25001A,$00000000,$00000000,$8C07ED7E,$12B90000 
		dc.l	$E04611DF,$EE060039,$00000000,$00000000,$400F7EF4 
		dc.l	$81390002,$86E66EE7,$82E61919,$00000000,$00000000 
		dc.l	$45FE6601,$19FE0000,$05CED4FA,$04CA2B34,$00000000 
		dc.l	$00000000,$13F0500F,$2FF00001,$031440F2,$80107FEE 
		dc.l	$00000000,$00000000,$600077E8,$08130004,$020880EA 
		dc.l	$4008BFF6,$00000000,$00000000,$140038C8,$07370000 
		dc.l	$0FD4C014,$0014FFE8,$00000000,$00000000,$140038CB 
		dc.l	$07340003,$0FD4C014,$0014FFE8,$00000000,$00000000 
		dc.l	$108114FB,$0B01001E,$FF70C300,$C3003CF8,$00000000 
		dc.l	$00000000,$0071085B,$07B1000E,$E1909D80,$9D807E70 
		dc.l	$00000000,$00000000,$00BF009D,$075D0022,$E1A09D80 
		dc.l	$9D807E60,$00000000,$00000000,$006A0068,$03880017 
		dc.l	$51401200,$1200EFC0,$00000000,$00000000,$004501D0 
		dc.l	$000001AF,$FA807880,$78808700,$00000000,$00000000 
		dc.l	$00530070,$0050000F,$E6006600,$66009800,$00000000 
		dc.l	$00000000,$000E000E,$000E0001,$10001000,$1000E000 
		dc.l	$00000000,$00000000 

sprite1		DS.L 5*32
mask1		DS.L 32
old_vbl		DC.L 0
old_key		DC.L 0
old_mfp		DC.L 0
log_base	DC.L $2F0300		
phy_base	DC.L $2F8000		
switch		DC.W 0
vbl_timer	DC.W 0
old_xys1	DS.W 50
old_xys2	DS.W 50
key		DC.W 0
mousexy		DC.W 0
mousex		DC.W 160
mousey		DC.W 100  
xymodbuf	REPT 50
		DC.W 160,100,160,100
		ENDR
		SECTION BSS
		DS.L 199
stack		DS.L 2
				