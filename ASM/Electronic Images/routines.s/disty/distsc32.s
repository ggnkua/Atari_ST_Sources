; 32*32 1 plane Disting scroller
; This takes about 10% cpu time.
; (C) Martin Griffiths Sept 1990.

		OPT O+,OW-

linewid		EQU 104
bufsize		EQU 32*linewid

		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14
		LEA 12(SP),SP
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP

Start		MOVE #$2700,SR
		LEA stack,SP
		MOVE.L #screen1+256,D0
		CLR.B D0
		MOVE.L D0,log_base
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		BCLR.B #3,$FFFFFA17.W
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L $70.W,old_vbl
		MOVE.L #my_vbl,$70.W
		MOVE #$2300,SR
wait		BTST.B #0,$FFFFFC00.W
		BEQ wait
		CMP.B #$39,$FFFFFC02.W
		BNE wait
		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		BSET.B #3,$FFFFFA17.W
		MOVE.L old_vbl(PC),$70.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

log_base	DS.L 1
		DS.L 1
vbl_timer	DS.W 1

old_mfp		DS.L 5
old_vbl		DS.L 1


my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVE.W #$777,$FFFF8242.W
		MOVE.W #$777,$FFFF8250.W
		MOVE #1600,D0
A		DBF D0,A
		NOT $ffff8240.w
		BSR DistScroll1_32 
		NOT $ffff8240.w

		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE

; Shift dist upwards and place next dist value in table.

DistScroll1_32	LEA dist_tab+2(PC),A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,-34(A0)
		MOVEM.L (A0)+,D0-D7		; shift wave
		MOVEM.L D0-D7,-34(A0)
		LEA dist_ang(PC),A1
		MOVE (A1),D0
		ADD dist_step(PC),D0
		AND #$3FE,D0
.yep		MOVE D0,(A1)
		MOVE dister(PC),D1
		ADD dist_step(PC),D1
		CMP maxi_dist(PC),D1
		BLE.S .notwang
 		SUB maxi_dist(PC),D1
.sel_wave	MOVE.L wave_ptr(PC),A1
		LEA dist_step(PC),A2
		MOVE (A1)+,(A2)+
		BPL.S .nrapwave 
		LEA wave_tab(PC),A1
		MOVE (A1)+,-2(A2)
.nrapwave	MOVE.L (A1)+,(A2)+
		MOVE.L A1,wave_ptr
.notwang	MOVE D1,dister
		LEA trig_tab(PC),A1		;ptr to sin table
		MOVE (A1,D0),D0			;sin(xd)
		MULS size(PC),D0		;*size (magnitude of wave)
		LSL.L #2,D0				
		SWAP D0				normalise
		ADD #48,D0
		ADD D0,D0
		ADD D0,D0			;x4
		MOVE.W D0,dist_tab+62		;place in table

		LEA scr_point(PC),A1
		MOVE.L (A1)+,A0			;curr text ptr
		MOVE (A1)+,D6			;pixel offset
		ADDQ #2,D6			;add 2(2 pixel step)
		AND #15,D6			;end of chunk?
		BNE.S .posok			;no then skip
		ADDQ.W #2,(A1)			;onto next chunk 
		CMP #52,(A1)			;in pix buffer.
		BNE.S .nowrapscr		;reached end of buffer?		
		CLR (A1)			;if yes reset buffer position
.nowrapscr	NOT 2(A1)			;font is 32 wide(inlet switch)
		BNE.S .posok 			;so there are two chunks
		ADDQ.L #1,A0			;after 32 pixs,next letter...
.fetchnextlet	MOVEQ #0,D0
		MOVE.B (A0),D0	
		BNE.S .notwrap			;end of text?
		LEA text(PC),A0			;yes restart text
		BRA.S .fetchnextlet
.notwrap	MOVE.W curr2ndlet(PC),curr1stlet
		SUB.B #32,D0
		LSL #7,D0
		MOVE.W D0,curr2ndlet
.posok		MOVE D6,-(A1)			;otherwise restore
		MOVE.L A0,-(A1)			
		LEA fontbuf(PC),A5     		;character addr    
		ADDA.W curr1stlet(PC),A5
		LEA 2(A5),A6			;point to 2nd chunk
		TST inletswitch			;are we in 2nd chunk
		BEQ.S norm 			;already?
		ADDQ.W #2,A5			;if we are then the
		LEA fontbuf(PC),A6
		ADDA.W curr2ndlet(PC),A6
norm		LEA scbuffer-2,A3
		MOVE.W D6,D3
		MULU #bufsize,D3
		ADD.L D3,A3
		ADD scrlpos(PC),A3		;addr in buffer
		CMP #8,D6			;shift more than 8?
		BGE.S .morethan8		

.lessthan8	MOVEQ #32-1,D7
.addin_lp	MOVE.L (A6)+,D3
		MOVE.W (A5),D3 
		ROL.L D6,D3
		MOVE.W D3,52(A3)
		MOVE.W D3,(A3)
		ROL.L #1,D3			;add to buffer
		MOVE.W D3,52+bufsize(A3)	;shift <8
		MOVE.W D3,bufsize(A3)
		ADDQ.L #4,A5
		LEA linewid(A3),A3
		DBF D7,.addin_lp
		BRA.S .copy_buf

.morethan8	MOVEQ #32-1,D7
		NEG D6
		ADD #16,D6
.addin_lp2	MOVE.L (A5)+,D3
		MOVE.W (A6),D3 
		ROR.L D6,D3			;add to buffer
		MOVE.W D3,52(A3)		;shift >8 (so swap)
		MOVE.W D3,(A3)
		ROL.L #1,D3
		MOVE.W D3,52+bufsize(A3)
		MOVE.W D3,bufsize(A3)
		ADDQ.L #4,A6
		LEA linewid(A3),A3
		DBF D7,.addin_lp2

.copy_buf	MOVE.L log_base(PC),A2		;screen base

		LEA scbuffer(PC),A0
		ADD scrlpos(PC),A0
		LEA dist_tab(PC),A3
		LEA xtab(PC),A4
		MOVE scx(PC),D0
		ADD D0,D0
		ADD D0,D0
		ADD.W D0,A4
i		SET (128*160)+6
j		SET 0
		REPT 32
		MOVE.W (A3)+,D0
		LEA j(A0),A1
		ADD.L (A4,D0),A1		;buffer line addr
		MOVE.L (a1)+,i(A2)
		MOVE.L (a1)+,i+16(A2)
		MOVE.L (a1)+,i+32(A2)
		MOVE.L (a1)+,i+48(A2)		;blit line onto screen
		MOVE.L (a1)+,i+64(A2)
		MOVE.L (a1)+,i+80(A2)
		MOVE.L (a1)+,i+96(A2)
		MOVE.L (a1)+,i+112(A2) 
		MOVE.L (a1)+,i+128(A2)
		MOVE.L (a1)+,i+144(A2)
j		SET j+linewid
i		SET i+160
		ENDR
		RTS

scr_point	DC.L text
scx		DC.W 0
scrlpos		DC.W 0
inletswitch	DC.W 0
curr1stlet	DC.W 0
curr2ndlet	 DC.W 0

text		dc.b " TESTING TESTING...... SHITTY FUCKING SCROLLINE.... FUCKING BASTARD ETC ETC........        "
		dc.b 0
		EVEN
dist_ang	DC.W 0
dist_step	DC.W 4
maxi_dist	DC.W 512
size		DC.W 0
dister		DC.W 0
wave_ptr	DC.L wave_tab
wave_tab	DC.W 4,512,48
		DC.W 64,4096,1
		DC.W 32,4096,4
		DC.W 4,512,16
		DC.W 4,512,32
		DC.W -1

dist_tab	DCB.W 33,48

i		SET 0
xtab		REPT 10
		DC.L i
		DC.L i+(bufsize*1)
		DC.L i+(bufsize*2)
		DC.L i+(bufsize*3)
		DC.L i+(bufsize*4)
		DC.L i+(bufsize*5)
		DC.L i+(bufsize*6)
		DC.L i+(bufsize*7)
		DC.L i+(bufsize*8)
		DC.L i+(bufsize*9)
		DC.L i+(bufsize*10)
		DC.L i+(bufsize*11)
		DC.L i+(bufsize*12)
		DC.L i+(bufsize*13)
		DC.L i+(bufsize*14)
		DC.L i+(bufsize*15)
i		SET i+2
		ENDR

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

fontbuf		INCBIN c_chars.DAT

		SECTION BSS
		DS.W 2
scbuffer	REPT 16
		DS.B bufsize
		ENDR
		DS.W 2


		DS.L 149
stack		DS.L 1
screen1		DS.B 256
		DS.B 32000
