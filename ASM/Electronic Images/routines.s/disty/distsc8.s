; 16*13 1 plane Disting scroller (C) Martin Griffiths Sept 1990.

		OPT O+,OW-

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

Start		MOVE #$2700,SR
		LEA stack,SP
		MOVE.L #$f8000,D0
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
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		BCLR.B #3,$FFFFFA17.W
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #my_vbl,$70.W
		MOVE.L #switch,$B0.W
		MOVE.W #$700,$FFFF8240+2
		MOVE.W #$700,$FFFF8240+16
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
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$B0.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)
		TRAP #1

log_base	DS.L 1
		DS.L 1
vbl_timer	DS.W 1
tempsp		DC.L 0

switch		BCHG #13,(SP)
		RTE
;-----------------------------------------------------------------------;
; 		 	Disting scroller rout.				;		
; Please note: This is a 2 address reg+A7 version!! Sloooww....		;
;-----------------------------------------------------------------------;

nolines		EQU 8
linewid		EQU 128
bufsize		EQU nolines*linewid

; Shift dist upwards and place next dist value in table.


my_vbl		MOVEM.L D0-D5/A0-A1,-(SP)
		MOVE #1600,D0
A		DBF D0,A

Dist_scrl13	TRAP #12
		MOVE.L sd_scr_point(PC),A0	curr text ptr
		MOVE.L sd_which_buf(PC),A7	curr pix buffer ptr
		MOVE sd_scx(PC),D2		pixel offset
		LEA bufsize*2(A7),A7		skip 2 buffers(2 pix step)	
		ADDQ #2,D2			add 2(2 pixel step)
		CMP #16,D2			end of chunk?
		BNE.S pos_ok			no then skip
		ADDQ.W #2,sd_scrlpos		onto next chunk 
		CMP #64,sd_scrlpos		in pix buffer.
		BNE.S nowrapscr			reached end of buffer?		
		CLR sd_scrlpos			if yes reset buffer position
nowrapscr	LEA sd_scbuffer,A7		reset pixel chunk offset
		MOVEQ #0,D2			+ pix position
		ADDQ.L #2,A0			after 32 pixs,next letter...
pos_ok		TST.B 1(A0)	
		BNE.S notwrap			end of text?
		LEA sd_text(PC),A0		yes restart text
notwrap		MOVE D2,sd_scx			otherwise restore
		MOVE.L A7,sd_which_buf
		MOVE.L A0,sd_scr_point
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.B (A0)+,D0
		MOVE.B (A0),D1
		LEA font32(PC),A0  		character addr    
		LEA (A0),A1
		SUB.B #32,D0			normalise asci char
		SUB.B #32,D1			
		LSL #3,D0              		*64 font offset
		LSL #3,D1              		
		ADDA.W D0,A0
		ADDA.W D1,A1
norm		ADD sd_scrlpos(PC),A7
i		SET 0
		REPT nolines
		MOVEQ #0,D3
		MOVE.B (A0)+,D3
		LSL #8,D3 
		MOVE.B (A1)+,D3 
		ROL.L D2,D3
		MOVE.W D3,i-2(A7)
		MOVE.W D3,i+62(A7)
		SWAP D3
		OR.W D3,i-4(A7)
		OR.W D3,i+60(A7)
		SWAP D3
		ROL.L #1,D3
		MOVE.W D3,i-2+bufsize(A7)
		MOVE.W D3,i+62+bufsize(A7)
		SWAP D3
		OR.W D3,i-4+bufsize(A7)
		OR.W D3,i+60+bufsize(A7)
i		SET i+linewid
		ENDR

copy_buf	MOVE.L log_base(PC),A0	screen base
		MOVE.L sd_which_buf(pc),A1
		ADD sd_scrlpos(PC),A1
i		SET 0
		REPT nolines
		MOVE.W (a1)+,i(A0)
		MOVE.W (a1)+,i+8(A0)
		MOVE.W (a1)+,i+16(A0)
		MOVE.W (a1)+,i+24(A0)
		MOVE.W (a1)+,i+32(A0)
		MOVE.W (a1)+,i+40(A0)
		MOVE.W (a1)+,i+48(A0)
		MOVE.W (a1)+,i+56(A0)
		MOVE.W (a1)+,i+64(A0)
		MOVE.W (a1)+,i+72(A0)
		MOVE.W (a1)+,i+80(A0)
		MOVE.W (a1)+,i+88(A0)
		MOVE.W (a1)+,i+96(A0)
		MOVE.W (a1)+,i+104(A0)
		MOVE.W (a1)+,i+112(A0)
		MOVE.W (a1)+,i+120(A0)
		MOVE.W (a1)+,i+128(A0)
		MOVE.W (a1)+,i+136(A0)
		MOVE.W (a1)+,i+144(A0)
		MOVE.W (a1)+,i+152(A0)
		LEA linewid-40(A1),A1
i		SET i+160
		ENDR 
		TRAP #12
		MOVEM.L (SP)+,D0-D5/A0-A1
		ADDQ #1,vbl_timer
		RTE

sd_scr_point	DC.L sd_text
sd_which_buf	DC.L sd_scbuffer
sd_scx		DC.W 0
sd_scrlpos	DC.W 0
sd_finbarr	DC.W 0
sd_text		dc.b "  TESTING TESTING...... SHITTY FUCKING SCROLLINE.... FUCKING BASTARD ETC ETC........        "
		dc.b 0,0
		EVEN
i		SET 0
sd_xtab		REPT 44
		DC.L sd_scbuffer+i
		DC.L sd_scbuffer+i+(bufsize*1)
		DC.L sd_scbuffer+i+(bufsize*2)
		DC.L sd_scbuffer+i+(bufsize*3)
		DC.L sd_scbuffer+i+(bufsize*4)
		DC.L sd_scbuffer+i+(bufsize*5)
		DC.L sd_scbuffer+i+(bufsize*6)
		DC.L sd_scbuffer+i+(bufsize*7)
		DC.L sd_scbuffer+i+(bufsize*8)
		DC.L sd_scbuffer+i+(bufsize*9)
		DC.L sd_scbuffer+i+(bufsize*10)
		DC.L sd_scbuffer+i+(bufsize*11)
		DC.L sd_scbuffer+i+(bufsize*12)
		DC.L sd_scbuffer+i+(bufsize*13)
		DC.L sd_scbuffer+i+(bufsize*14)
		DC.L sd_scbuffer+i+(bufsize*15)
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
font32		
smllfont	dc.l	$00000000,$00000000,$10101010,$10001000,$00240000 
		dc.l	$00000000,$24247E24,$7E242400,$107C907C,$127C1000 
		dc.l	$00440810,$20440000,$18241828,$45827D00,$00100000 
		dc.l	$00000000,$04081010,$10080400,$20100808,$08102000 
		dc.l	$004428FE,$28440000,$0010107C,$10100000,$00000000 
		dc.l	$00001020,$0000007C,$00000000,$00000000,$00001000 
		dc.l	$00020408,$10204000,$7C868A92,$A2C27C00,$10301010 
		dc.l	$10107C00,$7C82027C,$8080FE00,$7C82021C,$02827C00 
		dc.l	$0C142444,$84FE0400,$FC8080FC,$02827C00,$7C8280FC 
		dc.l	$82827C00,$FE820408,$10101000,$7C82827C,$82827C00 
		dc.l	$7C82827E,$02027C00,$00001000,$10000000,$00001000 
		dc.l	$10200000,$08102040,$20100800,$00007C00,$7C000000 
		dc.l	$20100804,$08102000,$7C82020C,$10001000,$7C829EA2 
		dc.l	$9C807E00,$7C8282FE,$82828200,$FC8282FC,$8282FC00 
		dc.l	$7C828080,$80827C00,$FC828282,$8282FC00,$FE8080F8 
		dc.l	$8080FE00,$FE8080F8,$80808000,$7E80808E,$82827C00 
		dc.l	$828282FE,$82828200,$7C101010,$10107C00,$02020202 
		dc.l	$02827C00,$828488F0,$88848200,$80808080,$8080FE00 
		dc.l	$82C6AA92,$82828200,$82C2A292,$8A868200,$7C828282 
		dc.l	$82827C00,$FC8282FC,$80808000,$7C828282,$8A847A00 
		dc.l	$FC8282FC,$88848200,$7C82807C,$02827C00,$FE101010 
		dc.l	$10101000,$82828282,$82827C00,$82828282,$44281000 
		dc.l	$82828292,$AAC68200,$82442810,$28448200,$82824428 
		dc.l	$10101000,$FE040810,$2040FE00,$1C101010,$10101C00 
		dc.l	$80402010,$08040200,$38080808,$08083800,$10284482 
		dc.l	$00000000,$00000000,$0000FE00,$00100000,$00000000 
		dc.l	$00007804,$7C847800,$8080F884,$8484F800,$00007880 
		dc.l	$80807800,$04047C84,$84847C00,$00007884,$F8807800 
		dc.l	$0C103810,$10101000,$00007884,$847C0478,$8080F884 
		dc.l	$84848400,$10003010,$10103800,$08000808,$08080830 
		dc.l	$808890E0,$90888400,$30101010,$10103800,$0000EC92 
		dc.l	$92828200,$0000F884,$84848400,$00007884,$84847800 
		dc.l	$0000F884,$8484F880,$00007C84,$84847C04,$0000F884 
		dc.l	$80808000,$00007880,$78047800,$10107C10,$10100C00 
		dc.l	$00008484,$84847C00,$00008282,$44281000,$00008282 
		dc.l	$82542800,$00008448,$30488400,$00008484,$847C0478 
		dc.l	$00007C08,$10207C00,$00000000,$00000000,$00000000 
		dc.l	$00000000,$00000000,$00000000,$00000000,$00000000 

		SECTION BSS
		DS.W 2
sd_scbuffer	REPT 16
		DS.B bufsize
		ENDR
		DS.W 2

old_mfp		DS.L 8
		DS.L 199
stack		DS.L 1
