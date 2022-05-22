; The ONRPLANEMANIATECHTRON2 Fullscreen
; by Electronic Images.
; Coding  : Martin Griffiths (Griff)   - All coding except 
;	    Jose Commins (The Phantom) - the Digisynth
; Graphix : Lawrence McDonald (Master)
; Music   : Nic Alderton (Count Zero)

; Approx Memory required when running: 430k
; Approx disk space(unpacked)        : 110k
; Approx disk space(packed)	     : 65k

		OPT O+,OW-

intro1		EQU 0
intro2		EQU 0
demo		EQU 0

screen1		EQU $E0000
screen2		EQU $F0000

		IFEQ demo
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		MOVE.L D0,gemoldsp
		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		CLR.B $FFFF8260.W
		ENDC


; No gem calls from here on.
		
Start		MOVE #$2700,SR
		MOVE.L SP,oldsp
		LEA stack,SP
		LEA $FFFF8240.W,A0
		MOVEM.L (A0),D0-D7
		MOVEM.L D0-D7,old_stuff
		MOVEQ #0,D1
		REPT 8
		MOVE.L D1,(A0)+
		ENDR
		MOVE.L #screen1,D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		BSR flush
		IFEQ intro2
		BSR clr_freemem
		JSR Genstars
		MOVEQ #1,D0
		JSR music
		ENDC
		LEA old_stuff+32,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA19.W,(A0)+
		MOVE.B $FFFFFA1D.W,(A0)+
		MOVE.B $FFFFFA1F.W,(A0)+
		MOVE.B $FFFFFA25.W,(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $B0.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.B #$20,$FFFFFA07.W
		CLR.B $FFFFFA09.W
		MOVE.B #$20,$FFFFFA13.W
		CLR.B $FFFFFA15.W
		BCLR.B #3,$FFFFFA17.W
		CLR.B $FFFFFA19.W
		CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W
		MOVE.L #phbl,$68.W
		IFEQ intro2
		MOVE.L #first_vbl,$70.W
		MOVE.L #stardemo,$134.W
		ENDC

		MOVE.L #switchmode,$B0.W
		BSR flush
		MOVE #$2300,SR
		STOP #$2300
; First vbl loop - while starfield is going
Dvbl_loop	
		IFEQ intro2
		BTST.B #0,$FFFFFC00.W
		BEQ.S Dvbl_loop
		CMP.B #$39+$80,$FFFFFC02.W
		BNE Dvbl_loop
		ENDC

		IFEQ intro1
secondbit	
		MOVE #$2700,SR
		MOVE.B #$8,$FFFF8800.W
		CLR.B $FFFF8802.W
		MOVE.B #$9,$FFFF8800.W
		CLR.B $FFFF8802.W
		MOVE.B #$A,$FFFF8800.W
		CLR.B $FFFF8802.W
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		BSR flush
		MOVE.L #firstmain_vbl,$70.W
		MOVE.L #maindemo,$134.W
		MOVE.L	#player,$110.w
		MOVE.L #screen1,log_base
		MOVE.L #screen1,phy_base
		BSR clr_freemem
		JSR Setupscroll
		JSR Inittune
		OR.B #%00010000,$fffffa09.w
		OR.B #%00010000,$fffffa15.w
		CLR.B $FFFFFA1D.W
		CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W
		MOVE #$2300,SR

;-----------------------------------------------------------------------;
;	         	   Main demo loop				;
;-----------------------------------------------------------------------;

vbl_loop	BTST.B #0,$FFFFFC00.W
		BEQ vbl_loop
		CMP.B #$39,$FFFFFC02.W
		BNE vbl_loop
		
		ENDC

; Restore old vectors, colours etc and exit
		
EXITDEMO	MOVE #$2700,SR
		LEA old_stuff,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$B0.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		BSR flush
		MOVE.B #$8,$FFFF8800.W
		CLR.B $FFFF8802.W
		MOVE.B #$9,$FFFF8800.W
		CLR.B $FFFF8802.W
		MOVE.B #$A,$FFFF8800.W
		CLR.B $FFFF8802.W
		MOVE #$2300,SR
		IFEQ demo
		MOVE.L gemoldsp(PC),-(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1
gemoldsp	DC.L 0
		ENDC
		MOVE.L oldsp(PC),SP
		RTS

oldsp		DC.L 0

; Toggle user/super mode - TRAP #12
 
switchmode	BCHG #13,(SP)
		RTE

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

		IFEQ intro1


; Plot the next row of big vertical scroller and copy back.

BigVertScroller	MOVE.L big_scrlpoint(PC),A0
		MOVE big_in(PC),D0
		ADDQ #4,D0
		CMP #128,D0
		BNE.S nwrap
		MOVEQ #0,D0
		ADDQ.W #1,A0
		MOVE.B (A0),D1
		BNE.S nwrap
		LEA bigtext(PC),A0
nwrap		MOVE D0,big_in
		MOVE.L A0,big_scrlpoint
		MOVEQ #0,D1
		MOVE.B (A0),D1
		SUB.B #32,D1
		LSL #7,D1
		ADD D0,D1
		LEA font32(PC),A0
		MOVEM.W (A0,D1),D0/D1
		LEA expandedbuf,A1
		REPT 16
		ADD D0,D0
		SCS (A1)+
		ENDR
		REPT 16
		ADD D1,D1
		SCS (A1)+
		ENDR
		RTS
font32		incbin D:\1PLANE.INC\c_chars.dat
big_scrlpoint	DC.L bigtext
big_in		DC.W 0
bigtext		DC.B "  HELLO THIS IS A FUCKING BIG SCROLLER SO THERE!!!!!",0
		EVEN

;-----------------------------------------------------------------------;
; 		 	Disting scroller rout.				;		
; This does the two disting scrollers at the bottom and top of screen.	;
; Please note: This is a 2 address reg+A7 version!! Sloooww....		;
;-----------------------------------------------------------------------;

nolines		EQU 31
linewid		EQU 128
bufsize		EQU nolines*linewid

; Shift dist upwards and place next dist value in table.

Dist_scrl13	TRAP #12
		LEA sd_dist_tab+(nolines*2)(pc),A0
		LEA -2(A0),A1
		REPT (nolines-1)/2
		MOVE.L -(a1),-(a0)
		ENDR
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
		NOT.W sd_finbarr
		BNE.S notwrap
		ADDQ.L #1,A0			after 32 pixs,next letter...
pos_ok		TST.B 1(A0)	
		BNE.S notwrap			end of text?
		LEA sd_text(PC),A0		yes restart text
notwrap		MOVE D2,sd_scx			otherwise restore
		MOVE.L A7,sd_which_buf
		MOVE.L A0,sd_scr_point
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.B (A0)+,D0
		MOVE.B (A0),D1			must be plotted
		LEA font32(PC),A0  		character addr    
		SUB.B #32,D0			normalise asci char
		LSL #7,D0              		*64 font offset
		ADDA.W D0,A0
		LEA 2(A0),A1
		TST.W sd_finbarr		last chunk of letter
		BEQ.S norm
		ADDQ.W #2,A0
		SUB.B #32,D1
		LSL #7,D1              		"
		LEA font32(PC),A1  		
		ADDA.W D1,A1
norm		ADD sd_scrlpos(PC),A7
		CMP #8,D2
		BGE shiftplus8
shiftless8
i		SET 0
j		SET 0
		REPT nolines
		MOVE.L (A1)+,D3
		MOVE.W j(A0),D3 
		ROL.L D2,D3
		MOVE.W D3,i+62(A7)
		MOVE.W D3,i-2(A7)
		ROL.L #1,D3
		MOVE.W D3,i+62+bufsize(A7)
		MOVE.W D3,i-2+bufsize(A7)
i		SET i+linewid
j		SET j+4
		ENDR
		BRA copy_buf
shiftplus8	NEG D2
		ADD #16,D2
i		SET 0
j		SET 0
		REPT nolines
		MOVE.L (A0)+,D3
		MOVE.W j(A1),D3 
		ROR.L D2,D3
		MOVE.W D3,i+62(A7)
		MOVE.W D3,i-2(A7)
		ROL.L #1,D3
		MOVE.W D3,i+62+bufsize(A7)
		MOVE.W D3,i-2+bufsize(A7)
i		SET i+linewid
j		SET j+4
		ENDR

copy_buf	LEA.L vertwaveptr(pc),a0
		MOVE.L (a0),sp
		SUBQ.L #2,sp
		CMP.L #vertwave,SP
		BNE.S notvwvewr
		LEA.L vertwaveend-76,SP
notvwvewr	MOVE.L SP,(a0)
		MOVE.W (SP),sd_dist_tab
		MOVE.L log_base(PC),A0	screen base
		MOVE.W sd_scx(PC),D1
		MOVE sd_scrlpos(PC),D2
		ADD D1,D1
		ADD D1,D1
		LEA sd_dist_tab(PC),SP
		LSL #5,D2
		ADD D2,D1
j		SET linewid*2
i		SET (9*160)+14-230
k		SET 2

		MOVEQ #0,D0
		REPT 2
		MOVE.L D0,i(A0)
		MOVE.L D0,i+16(A0)
		MOVE.L D0,i+32(A0)
		MOVE.L D0,i+48(A0)
		MOVE.L D0,i+64(A0)
		MOVE.L D0,i+80(A0)
		MOVE.L D0,i+96(A0)
		MOVE.L D0,i+112(A0) 
		MOVE.L D0,i+128(A0)
		MOVE.L D0,i+144(A0)
		MOVE.L D0,i+160(A0)
		MOVE.L D0,i+176(A0)
		MOVE.W D0,i+192(A0)
i		SET i+230
		ENDR

		REPT nolines-2
		MOVE.W (SP)+,D0
		ADD.W D1,D0
		MOVE.L sd_xtab-(sd_dist_tab+k)(SP,D0),A1
		LEA j(A1),A1
		MOVE.L (a1)+,i(A0)
		MOVE.L (a1)+,i+16(A0)
		MOVE.L (a1)+,i+32(A0)
		MOVE.L (a1)+,i+48(A0)
		MOVE.L (a1)+,i+64(A0)
		MOVE.L (a1)+,i+80(A0)
		MOVE.L (a1)+,i+96(A0)
		MOVE.L (a1)+,i+112(A0) 
		MOVE.L (a1)+,i+128(A0)
		MOVE.L (a1)+,i+144(A0)
		MOVE.L (a1)+,i+160(A0)
		MOVE.L (a1)+,i+176(A0)
		MOVE.W (a1)+,i+192(A0)
k		SET k+2
j		SET j+linewid
i		SET i+230
		ENDR 
		MOVEQ #0,D0
		MOVE.L D0,i(A0)
		MOVE.L D0,i+16(A0)
		MOVE.L D0,i+32(A0)
		MOVE.L D0,i+48(A0)
		MOVE.L D0,i+64(A0)
		MOVE.L D0,i+80(A0)
		MOVE.L D0,i+96(A0)
		MOVE.L D0,i+112(A0) 
		MOVE.L D0,i+128(A0)
		MOVE.L D0,i+144(A0)
		MOVE.L D0,i+160(A0)
		MOVE.L D0,i+176(A0)
		MOVE.W D0,i+192(A0)
		TRAP #12
		RTS

sd_scr_point	DC.L sd_text
sd_which_buf	DC.L sd_scbuffer
sd_scx		DC.W 0
sd_scrlpos	DC.W 0
sd_finbarr	DC.W 0
sd_text		dc.b " TESTING TESTING...... SHITTY FUCKING SCROLLINE.... FUCKING BASTARD ETC ETC........        "
		dc.b 0
		EVEN
vertwaveptr	DC.L vertwaveend-76
vertwave	INCBIN D:\1PLANE.INC\SCRLWAVE.DAT
vertwaveend	
sd_dist_ptr	DC.W 0
sd_dist_tab	DCB.W nolines,0
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

;-----------------------------------------------------------------------;
; 		 	8*8 scroller rout.				;		
; Please note: This is a 2 address reg+A7 version!! Sloooww....		;
;-----------------------------------------------------------------------;

nolines8	EQU 7
linewid8	EQU 256
bufsize8	EQU nolines8*linewid8

Plot_littlescroller:
		TRAP #12
		MOVEM.L .sd_scr_point(PC),A0/A7	;curr text ptr/curr pix buffer ptr
		MOVE .sd_scx(PC),D2		;pixel offset
		LEA bufsize8*2(A7),A7		;skip 2 buffers(2 pix step)	
		ADDQ #2,D2			;add 2(2 pixel step)
		CMP #16,D2			;end of chunk?
		BNE.S .pos_ok			;no then skip
		ADDQ.W #2,.sd_scrlpos		;onto next chunk 
		AND #127,.sd_scrlpos		
.nowrapscr	LEA scbuffer8,A7		;reset pixel chunk offset
		MOVEQ #0,D2			;+ pix position
		ADDQ.L #2,A0			;
.pos_ok		TST.B 1(A0)	
		BNE.S .notwrap			;end of text?
		LEA .sd_text(PC),A0		;yes restart text
.notwrap	MOVE D2,.sd_scx			;otherwise restore
		MOVEM.L A0/A7,.sd_scr_point
		MOVEQ #0,D0
		MOVEQ #0,D1
		MOVE.B (A0)+,D0
		MOVE.B (A0),D1
		LEA smllfont(PC),A0  		;character addr    
		LEA (A0),A1
		SUB.B #32,D0			;normalise asci char
		SUB.B #32,D1			
		LSL #3,D0              		;*8 font offset
		LSL #3,D1              		
		ADDA.W D0,A0
		ADDA.W D1,A1
		ADD .sd_scrlpos(PC),A7
i		SET 0
		REPT nolines8
		MOVEQ #0,D3
		MOVE.B (A0)+,D3
		LSL #8,D3 
		MOVE.B (A1)+,D3 
		ROL.L D2,D3
		MOVE.W D3,i-2(A7)
		MOVE.W D3,i+126(A7)
		SWAP D3
		OR.W D3,i-4(A7)
		OR.W D3,i+124(A7)
		SWAP D3
		ROL.L #1,D3
		MOVE.W D3,i-2+bufsize8(A7)
		MOVE.W D3,i+126+bufsize8(A7)
		SWAP D3
		OR.W D3,i-4+bufsize8(A7)
		OR.W D3,i+124+bufsize8(A7)
i		SET i+linewid8
		ENDR
		TRAP #12
.calcpos	MOVE dist_ang(PC),D0
		ADD dist_step(PC),D0
		AND #$3FE,D0
		MOVE D0,dist_ang
		MOVE dister(PC),D1
		ADD dist_step(PC),D1
		CMP maxi_dist(PC),D1
		BLE.S .notwang
 		SUB maxi_dist(PC),D1
.sel_wave	MOVE.L wave_ptr(PC),A1
		LEA dist_step(PC),A0
		MOVE (A1)+,(A0)+
		BPL.S .nrapwave 
		LEA wave_tab(PC),A1
		MOVE (A1)+,-2(A0)
.nrapwave	MOVE.L (A1)+,(A0)+
		MOVE.L A1,wave_ptr
.notwang	MOVE D1,dister
		LEA trig_tab(PC),A1		; ptr to sin table
		MOVE (A1,D0),D0			; sin(xd)
		MULS size(PC),D0		; *size (magnitude of wave)
		LSL.L #2,D0				
		SWAP D0				; normalise
		ADD #128,D0
		ADD .sd_scx(PC),D0
		MOVE.W D0,D1
		LEA scbuffer8,A0
		LSR #4,D0
		ADD D0,D0
		ADD .sd_scrlpos(PC),D0
		ADD D0,A0
		AND #15,D1
		MULU #bufsize8,D1
		ADD.L D1,A0
		MOVE.L log_base(PC),A1
		LEA (9*160)-(8*230)+10+(128*230)(A1),A1
		MOVE.L A0,ptr1
		MOVE.L A1,ptr2
		RTS

.sd_scr_point	DC.L .sd_text
.sd_which_buf	DC.L scbuffer8
.sd_scx		DC.W 0
.sd_scrlpos	DC.W 0
.sd_text	dc.b "  TESTING TESTING...... SHITTY FUCKING SCROLLINE.... FUCKING BASTARD ETC ETC........        "
		dc.b 0,0
		EVEN

scrollx		DC.W 0
ptr1		DC.L screen1
ptr2		DC.L screen1

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


		ENDC

; Clear all the free memory...

clr_freemem	LEA big_buf,A0
		LEA $100000,A1
		MOVEQ #0,D0
clr_lp		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		CMP.L A1,A0
		BLT.S clr_lp
		RTS

demo_pal	DC.W $000
		DC.W $070
		DC.W $007
		DC.W $070
		DC.W $700
		DC.W $070
		DC.W $700
		DC.W $070
		DC.W $070
		DC.W $007
		DC.W $070
		DC.W $700
		DC.W $070
		DC.W $700
		DC.W $070
		DC.W $000

log_base	DC.L screen1
phy_base	DC.L screen2

		IFEQ intro1

image_ptr	DC.L img
image_seqptr	DC.L img_seq
img_seq		
i		SET 0
		REPT 15
		DC.L i
i		SET i+2
		ENDR
		REPT 175
		DC.L i
i		SET i+80
		ENDR
		REPT 15
		DC.L i
i		SET i-2
		ENDR
		REPT 175
		DC.L i
i		SET i-80
		ENDR
		DC.L -1

dist_ang	DC.W 0
dist_step	DC.W 16
maxi_dist	DC.W 512
size		DC.W 0
dister		DC.W 0
wave_ptr	DC.L wave_tab
wave_tab	DC.W 6,2048,96
		DC.W 4,2048,64
		DC.W 16,4096,8
		DC.W 4,2048,128
		DC.W 16,4096,16
		DC.W 4,512,32
		DC.W -1

		ENDC

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

		ifeq intro2

;-----------------------------------------------------------------------;
;             - The little overscan intro to the demo -			;
; These routs are for the first section - the starfield with text.	;
; The text is 2 plane as is the starfield beneath it...			;
;-----------------------------------------------------------------------;

no_strs		EQU 324

first_vbl	MOVE.L #vbl,$70.W
		RTE

; The vbl for the little starfield demo.

vbl		CLR.B $FFFFFA19.W
		MOVE.B #100,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVEM.L curr_pal(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		LEA log_base(PC),A0
		MOVEM.L (A0)+,D0-D1
		MOVE.L D0,-(A0)
		MOVE.L D1,-(A0)
		LSR #8,D1
		MOVE.L D1,$FFFF8200.W
		BSR music+6			
		LEA old_strs1(PC),A1
		NOT switch
		BNE.S ccse2
		LEA old_strs2(PC),A1
ccse2		MOVE.L A1,which_old
		BSR Tseq
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE

f8timer		DC.W 0

old_strs1	REPT no_strs
		DC.L screen1
		ENDR
old_strs2	REPT no_strs
		DC.L screen2
		ENDR
which_old	DC.L old_strs1
switch		DC.W 0

;  Text Sequence stuff

Fade_in		EQU 0*4			; colour fade in
Fade_out	EQU 1*4			; colour fade out
Draw1		EQU 2*4			; draw 1 line of text pos y.
Delete1		EQU 3*4			; delete 1 line of text pos y.
Delay		EQU 4*4			; 50hz delay till next command.
Set_text	EQU 5*4			; set up text params
done		EQU 6*4			; finished for this frame
EndSeq		EQU 7*4			; restart sequence

Tseq		TST seq_delay
		BEQ.S .okletsgo
		SUBQ #1,seq_delay
		BNE.S done_tseq
.okletsgo	MOVE.L textseq_ptr(PC),A0
contseq		MOVE.W (A0)+,D0
		JMP text_commands(PC,D0)
donefornow	MOVE.L A0,textseq_ptr
done_tseq	RTS
text_commands	BRA.W Fadein		;fade in
		BRA.W Fadeout		;fade out
		BRA.W draw1linetext	;Draw 1 line
		BRA.W delete1line	;Delete 1line
		BRA.W StartDelay	;Delay
		BRA.W Setuptext		;Settext
		BRA.W donefornow	;done for this frame
		BRA.W Restartseq	;Endofsequence

; Fadein - Fuck it just realised it will be impossible to use this!!

Fadein		MOVE.L A0,-(SP)
		LEA curr_pal+8(PC),A0
		LEA firstdemopal+8(PC),A1
		MOVEQ #11,D4
.col_lp		MOVE (A0),D0	
		MOVE (A1)+,D1	
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S .R_done
		ADD #$100,D0
.R_done		MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S .G_done
		ADD #$010,D0
.G_done 	MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S .B_done
		ADDQ #$001,D0
.B_done		MOVE D0,(A0)+
		DBF D4,.col_lp
		MOVE.L (SP)+,A0
		BRA contseq			;and continue seq

; Fadeout

Fadeout		MOVE.L A0,-(SP)
		LEA curr_pal+8(PC),A0
		MOVEQ #11,D4
.col_lp		MOVE (A0),D0		curr value
		MOVE D0,D2
		AND #$700,D2
		TST D2		
		BMI.S .R_done
		SUB #$100,D0
.R_done		MOVE D0,D2
		AND #$070,D2
		TST D2
		BMI.S .G_done
		SUB #$010,D0
.G_done 	MOVE D0,D2
		AND #$007,D2
		TST D2
		BMI.S .B_done
		SUBQ #$001,D0
.B_done		MOVE D0,(A0)+
		DBF D4,.col_lp
		MOVE.L (SP)+,A0
		BRA contseq			;and continue seq
	
; Plot one line of text

draw1linetext	MOVE.W (A0)+,D0		; get y line from sequence
; D0 -> y offset in text to draw
		MOVE.L A0,-(SP)
		LEA screen1+164,A0
		LEA screen2+164,A1
		MOVEQ #0,D3
		MOVE.W D0,D3
		DIVU #9,D3
		MULU #230,D0
		ADD.L D0,A0		; first screen offset
		ADD.L D0,A1		; second "      "
		MOVE.L D3,D2
		MULU text8_width(PC),D3
		MOVE.L text8_ptr(PC),A6
		ADDA.W D3,A6		; point to start of text row
		SWAP D2
		LEA colourfnt(PC),A2
		ADD D2,D2		; *2 for font offset
		ADD D2,A2
		MOVE text8_width(PC),D2	;
		SUBQ #1,D2 
		MOVEQ #1,D1		; alternating add register
		MOVEQ #6,D3
.lp		MOVEQ #0,D0
		MOVE.B (A6)+,D0
		ADD D0,D0
		MOVE.W fontoffy(PC,D0),D0
		MOVE.W (A2,D0),D0
		MOVEP.W D0,(A0)
		MOVEP.W D0,(A1)
		ADDA.W D1,A0
		ADDA.W D1,A1
		EOR D3,D1
		DBF D2,.lp
		MOVE.L (SP)+,A0			;restore seq ptr
		BRA contseq			;and continue seq

fontoffy	DS.W 32
i		SET 0
		REPT 60
		DC.W i
i		SET i+18
		ENDR

; Delete one line

delete1line	MOVE (A0)+,D0
		MOVE.L A0,-(SP)
		MULU #230,D0
		LEA screen1+160,A0
		LEA screen2+160,A1
		ADD.L D0,A0
		ADD.L D0,A1
		MOVEQ #0,D0
i		SET 4
		REPT 28
		MOVE.L D0,i(A0)
		MOVE.L D0,i(A1)
i		SET i+8
		ENDR
		MOVE.L (SP)+,A0
		BRA contseq

StartDelay	MOVE.W (A0)+,seq_delay		;50hz delay
		BRA donefornow		

Setuptext	MOVE.W (A0)+,text8_width
		MOVE.L (A0)+,text8_ptr
		BRA contseq

Restartseq	LEA text_sequence(PC),A0	;restart sequence
		BRA donefornow


textseq_ptr	DC.L text_sequence
seq_delay	DC.W 0
text_sequence	REPT 7
		DC.W Fade_in,done
		ENDR
		DC.W Delay,150

; First page of text

		DC.W Set_text,52
		DC.L st8text1
i		SET 130
j		SET 131
		REPT 130
		DC.W Draw1,i,Draw1,j,done
i		SET i-1
j		SET j+1
		ENDR

		DC.W Delay,300

i		SET 1
j		SET (29*9)-1
		REPT 130
		DC.W Delete1,i,Delete1,j,done
i		SET i+2
j		SET j-2
		ENDR

; Second page of text

		DC.W Delay,50
		DC.W Set_text,52
		DC.L st8text2

i		SET 1
j		SET (29*9)-1
		REPT 130
		DC.W Draw1,i,Draw1,j,done
i		SET i+2
j		SET j-2
		ENDR

		DC.W Delay,300

i		SET 1
j		SET (29*9)-1
		REPT 130
		DC.W Delete1,i,Delete1,j,done
i		SET i+2
j		SET j-2
		ENDR


		DC.W EndSeq

text8_ptr	DC.L st8text1
text8_width	DC.W 52

st8text1
 DC.B "                                                    "
 DC.B "                  ELECTRONIC IMAGES                 "
 DC.B "                                                    "
 DC.B "                         OF                         "
 DC.B "                                                    "
 DC.B "                  THE INNER CIRCLE                  "
 DC.B "                                                    "
 DC.B "                VERY PROUDLY PRESENT                "
 DC.B "                                                    "
 DC.B "              THE SOMETHING FULLSCREEN              "
 DC.B "                                                    "
 DC.B "      CODED BY : GRIFF(NOW A MEMBER OF E.I!)        "
 DC.B "               : THE PHANTOM(THE DIGISYNTH ROUT)    "
 DC.B "      GRAPHIX  : MASTER(LAZY BASTARD!!!)            "
 DC.B "      MUSIC    : COUNT ZERO(WHO ELSE?!)             "
 DC.B "                                                    "
 DC.B "     THIS SCREEN WAS ORIGINALLY MADE FOR THE OVER-  "
 DC.B "     LANDERS 'EUROPEAN DEMOS'.BUT WE DIDN'T FINISH  "
 DC.B "     IT IN TIME. OUR DEEPEST APOLOGIES ARE SENT TO  "
 DC.B "     OVR, WE ARE TRUELY SORRY THAT WE MESSED YOU    "
 DC.B "     AROUND SO MUCH. BYE THE WAY WE THINK THAT THE  "
 DC.B "     EUROPEAN DEMOS ARE GREAT,BUT I WONDER WHY YOU  "
 DC.B "     CALL IT THE MEGASCROLLER DEMOS?!!!             "
 DC.B "     HEY ZIGGY YOUR SCREENS ARE EXCEPTIONALLY GOOD  "
 DC.B "     ESPECIALLY THE MEGA TRIDI SCREEN....           "
 DC.B "     THIS DEMO CONTAINS THE FASTEST EVER DIGISYNTH  "
 DC.B "     ON AN ST, USING ONLY 14 PERCENT CPU AT 8 KHZ.  " 
 DC.B "                                                    "
 DC.B "          PRESS SPACE AT ANY TIME TO SEE DEMO       "
 EVEN

st8text2
 DC.B "                                                    "
 DC.B "     HI TO :ALL OTHER MEMBERS OF THE INNER CIRCLE,  "
 DC.B "            PHALANX (YOUR DEMO IS F**KING GOOD!!!), "
 DC.B "            ULM, TCB, TEX, TLB, TLT, TSM, FF, TNT,  "
 DC.B "            CONSTELLATIONS, GHOST, OMEGA, TSM, FOF, "
 DC.B "            VECTOR, RIPPED OFF, BBC, DREAM WEAVERS, "
 DC.B "            POMPEY PIRATES, GFORCE, NEW ORDER, MCA, "
 DC.B "            EMPIRE, THE REPLICANTS, OVERLANDERS,    "
 DC.B "            THE MEDWAY BOYS, AUTOMATION, LAZER...   "
 DC.B "            AND TO ANY OTHER CREWS OUT THERE WHO    "
 DC.B "            WE HAVE FORGOTTEN THIS TIME.. SORRY!!   "
 DC.B "            NEARLY FORGOT,HI TO MIKE OF CARTERTON!  "
 DC.B "                                                    "
 DC.B "     IF YOU WISH TO CONTACT US THEN WRITE TO :-     "
 DC.B "                                                    "
 DC.B "                   GRIFF                            "
 DC.B "                    77 STRANRAER ROAD               "
 DC.B "                     PEMBROKE DOCK                  "
 DC.B "                      DYFED                         "
 DC.B "                       SA72 6RZ                     "
 DC.B "                        WALES                       "
 DC.B "                                                    "
 DC.B "     AS USUAL WE ARE NOT INTERESTED IN SWAPPING     "
 DC.B "     GAMES.. SO PLEASE DO NOT SEND LISTS OR DISKS.  "
 DC.B "     HOWEVER IF YOU ARE A FELLOW DEMOCODER OR JUST  "
 DC.B "     LEARNING 68000 AND NEED SOME HELP THEN DO NOT  "
 DC.B "     HESITATE TO CONTACT US.                        "
 DC.B "                                                    "
 DC.B "          PRESS SPACE AT ANY TIME TO SEE DEMO       "
 EVEN

colourfnt:	incbin D:\1PLANE.INC\8X9FONT2.DAT

stardemo	
		MOVE #$2100,SR
		STOP #$2100
		MOVE #$2700,SR
		MOVEM.L D0-D7/A0-A6,-(SP)
		CLR.B $FFFFFA19.W
		DCB.W 52,$4E71
		MOVE.B #0,$FFFF820A.W
		DCB.W 10,$4E71
		MOVEQ #0,D0
		MOVEQ #$3F,D1
		MOVE #$8209,A0
		MOVE.B #2,$FFFF820A.W
.syncloop	MOVE.B (A0),D0
		BEQ.S .syncloop
		SUB.B D0,D1
		LSL D1,D0
		MOVE.L log_base(PC),A0
		LEA 160(A0),A0
		LEA offsets(PC),A1
		MOVE.L which_old(PC),A5
		MOVE.L A5,A3
		DCB.W 42,$4E71
		LEA $FFFF820A.W,A6
		LEA $FFFF8260.W,A2
		MOVEQ #0,D0
		MOVEQ #2,D1
		MOVE #(no_strs/18)-1,D3
		MOVE #(no_strs/3)-1,D2
; Delete old stars - 18 per scanline (324 stars takes 18 scanlines)
.del_lp		MOVE.L (A3)+,A4
		MOVE.L D0,(A4)
		MOVE.L (A3)+,A4
		MOVE.B D1,(A2)
		MOVE.B D0,$FFFF8260.W
		MOVE.L D0,(A4)
		REPT 14
		MOVE.L (A3)+,A4
		MOVE.L D0,(A4)
		ENDR
		DCB.W 2,$4E71
		MOVE.B D0,(A6)
		MOVE.B D1,(A6)
		REPT 2
		MOVE.L (A3)+,A4
		MOVE.L D0,(A4)
		ENDR
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DBF D3,.del_lp
; Draw new stars - 3 per scanline! takes 108 scanlines (324 stars)!
stardraw_lp	DCB.W 7,$4E71
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
draw1		MOVE.L (A1),A2		
		MOVE.L (A2)+,D5		
		BLT.S .res
.cont		DCB.W 5,$4E71		
		BRA.S .restart
.res		MOVE.L no_strs*4(A1),A2	
		MOVE.L (A2)+,D5		
.restart	MOVE.L A0,A3		
		MOVE.L (A2)+,D4
		ADD.L D5,A3
		OR.L D4,(A3)
		MOVE.L A2,(A1)+		
		MOVE.L A3,(A5)+		
draw2		MOVE.L (A1),A2		
		MOVE.L (A2)+,D5		
		BLT.S .res
.cont		DCB.W 5,$4E71		
		BRA.S .restart
.res		MOVE.L no_strs*4(A1),A2	
		MOVE.L (A2)+,D5		
.restart	MOVE.L A0,A3		
		MOVE.L (A2)+,D4
		ADD.L D5,A3
		OR.L D4,(A3)
		MOVE.L A2,(A1)+		
		MOVE.L A3,(A5)+		
draw3		MOVE.L (A1),A2		
		MOVE.L (A2)+,D5		
		BLT.S .res
.cont		DCB.W 5,$4E71		
		BRA.S .restart
.res		MOVE.L no_strs*4(A1),A2	
		MOVE.L (A2)+,D5		
.restart	MOVE.L A0,A3		
		MOVE.L (A2)+,D4
		ADD.L D5,A3
		NOP
		MOVE.B D0,(A6)
		MOVE.B D1,(A6)
		OR.L D4,(A3)
		MOVE.L A2,(A1)+		
		MOVE.L A3,(A5)+		
		MOVE.B #2,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		NOP
		DBF D2,stardraw_lp
		MOVE #228-(no_strs/3)-(no_strs/18)-1,D2
.lp1		DCB.W 4,$4E71
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 89,$4E71	
		MOVE.B D0,(A6)
		MOVE.B D1,(A6)
		DCB.W 11,$4e71	
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 5,$4E71
		DBF D2,.lp1

.BOT_BORD	MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE.B D1,$FFFF820A.W
		DCB.W 85,$4E71	
 		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		DCB.W 11,$4e71	
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE #33,D2
		NOP
.blp		DCB.W 8,$4E71
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 89,$4E71	
		MOVE.B D0,(A6)
		MOVE.B D1,(A6)
		DCB.W 12,$4e71	
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DBF D2,.blp
		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE
firstdemopal	DC.W $000,$333,$555,$777,$021,$021,$021,$021
		DC.W $143,$143,$143,$143,$376,$376,$376,$376
curr_pal	DC.W $000,$333,$555,$777,$000,$000,$000,$000
		DC.W $000,$000,$000,$000,$000,$000,$000,$000

* This bit generates a big table of numbers which are co-ords
* for every star position. Memory wasting but quite fast. 

Genstars	LEA big_buf,A0
		LEA stars,A1		star co-ords
		LEA offsets(PC),A2
		LEA res_offsets(PC),A3
		MOVE #no_strs-1,D7
genstar_lp	MOVE.L A0,(A3)+			save reset offset
		MOVE.L A0,(A2)+			save curr offset
		MOVEM.W (A1)+,D4-D6		get x/y/z
		EXT.L D4			extend sign
		EXT.L D5
		ASL.L #8,D4
		ASL.L #8,D5
thisstar_lp	MOVE.L D4,D0 
		MOVE.L D5,D1
		MOVE.L D6,D2
		SUBQ #3,D6			z=z-3 (perspect)
		DIVS D2,D0			x/z(perspect)
		DIVS D2,D1			y/z(perspect)
		ADD #208,D0			add offsets
		ADD #135,D1			
		CMP #415,D0
		BHI.S Star_off
		CMP #263,D1
		BHI.S Star_off
		MOVE D0,D3
		MULU #230,D1
		LSR #1,D0
		AND.L #$0000FFF8,D0
		ADD.L D0,D1
		MOVE.L D1,(A0)+
		NOT D3
		AND #15,D3
		MOVEQ #0,D1
		BSET D3,D1
		ASR #6,D2
		TST D2
		BLE.S white
		CMP #1,D2
		BEQ.S white
		CMP #2,D2
		BEQ.S c2
c1		MOVE.W D1,(A0)+
		CLR.W (A0)+
		BRA thisstar_lp
white		MOVE.W D1,(A0)+
		MOVE.W D1,(A0)+
		BRA thisstar_lp
c2		MOVE.L D1,(A0)+
		BRA thisstar_lp
Star_off	MOVE.L #-1,(A0)+
		MOVE.L #-1,(A0)+
		DBF D7,genstar_lp
Randoffsets	LEA offsets(PC),A0
		LEA seed,A2
		MOVE #no_strs-2,D7
rands		MOVEM.L (A0),D0/D1
		SUB.L D0,D1
		LSR.L #3,D1			;subq #1,d1?
		MOVEQ #0,D2
		MOVE (A2),D2		
		ROL #1,D2			
		EOR #54321,D2
		SUBQ #1,D2		
		MOVE D2,(A2)	
		DIVU D1,D2						
		CLR.W D2
		SWAP D2
		LSL.L #3,D2
		ADD.L D2,D0
		MOVE.L D0,(A0)+
		DBF D7,rands			
		RTS

stars		INCBIN D:\1PLANE.INC\rand_324.xyz
seed		DC.W $9753
offsets		DS.L no_strs
res_offsets	DS.L no_strs
		ENDC
LINE_JMPS					;4*7*129
music		INCBIN D:\1PLANE.INC\IC_VECTR.CZI
		even

;----------------------------------------------------------------------;
	
		IFEQ intro1

; Main demo vbl and associated hbl routines. 

firstmain_vbl	CMP #3,vbl_timer
		BNE.S .fuckoff
		MOVE.L #main_vbl,$70.W
.fuckoff	ADDQ #1,vbl_timer
		RTE
vbl_timer	DC.W 0

main_vbl	CLR.B $FFFFFA19.W
		MOVE.B #100,$FFFFFA1F.W
		MOVE.B #4,$FFFFFA19.W
		JSR Seq
		RTE

maindemo	CLR.B $FFFFFA1D.W
		MOVE #$2100,SR				top border synchronisation
		STOP #$2100				by hbl
		MOVE #$2700,SR
		CLR.B $FFFFFA19.W
		DCB.W 30,$4E71
		BSR play2
		MOVE.B #0,$FFFF820A.W
		DCB.W 10,$4E71
		MOVEQ #0,D1
		MOVEQ #0,D2
		MOVE #$8209,A0
		MOVE.B #2,$FFFF820A.W
.syncloop	MOVE.B (A0),D1
		BEQ.S	.syncloop
		MOVEQ #10,D2
		SUB D1,D2
		LSL D2,D1
		MOVEQ	#28,d1
delayloop1	DBF D1,delayloop1
		MOVE #$8260,A1
HL1		JSR length_2
HL2		JSR length_2 
HL3		JSR length_2 
HL4		JSR length_2 
HL5		JSR length_2 
HL6		JSR length_2 
HL7		JSR length_2 
		DCB.W 16,$4E71	
		MOVEQ #0,D0
		MOVEQ #2,D1
		LEA demo_pal,A0
		LEA $FFFF8240.W,A1
		BSR play2
dopal		REPT 8
		MOVE.L (A0)+,(A1)+
		ENDR

		MOVE.L image_ptr,A0
		MOVE.L log_base,a1
		LEA (9*160)+(31*230)+8(a1),a1
		LEA 128*230(A1),A1

i		SET 6-(128*230)

		REPT 110
		MOVE.L (A0)+,i(A1)
		MOVE.L (A0)+,D5
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE.L D5,i+16(A1)
		MOVE.L (A0)+,i+32(A1)
		MOVE.L (A0)+,i+48(A1)
		MOVE.L (A0)+,i+64(A1)
		MOVE.L (A0)+,i+80(A1)
		MOVE.L (A0)+,i+96(A1)
		MOVE.L (A0)+,i+112(A1)
		MOVE.L (A0)+,i+128(A1)
		MOVE.L (A0)+,i+144(A1)
		MOVE.L (A0)+,i+160(A1)
		MOVE.L (A0)+,i+176(A1)
		MOVE.W (A0)+,i+192(A1)
		LEA 30(A0),A0 
		MOVE.L (A0)+,i+230(A1)
		MOVE.L (A0)+,i+230+16(A1)
		MOVE.L (A0)+,i+230+32(A1)
		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		MOVE.L (A0)+,i+230+48(A1)
		MOVE.W (A0)+,i+230+64(A1)
		MOVE.B #2,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE.W (A0)+,i+230+66(A1)
		MOVE.L (A0)+,i+230+80(A1)
		MOVE.B #2,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 9,$4E71
		MOVE.L (A0)+,i+230+96(A1)
		MOVE.L (A0)+,i+230+112(A1)
		MOVE.L (A0)+,i+230+128(A1)
		MOVE.L (A0)+,i+230+144(A1)
		MOVE.L (A0)+,i+230+160(A1)
		BSR play2
		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		MOVE.L (A0)+,i+230+176(A1)
		MOVE.W (A0)+,i+230+192(A1)
		MOVE.B #2,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		LEA 30(A0),A0 

i		SET i+460

		ENDR

.BOT_BORD	DCB.W 6,$4E71		
		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE.B D1,$FFFF820A.W
		DCB.W 85,$4E71	
 		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		MOVE.L ptr1,A0
		MOVE.L ptr2,A1
		MOVE.B #2,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 3,$4E71	

; Plot the little scroller to the screen.
; + the enlarged scroller...

plotword	MACRO
		MOVE.W (A0)+,D3
		MOVE.W D3,i+\1*8(A1)
		MOVE.W D3,j+\1*8(A1)
		ENDM

i		SET -128*230
j		SET 128*230
k		SET 2
l		SET (-128*230)+42
m		SET (128*230)+42

		REPT 7
		plotword 0
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 10,$4E71
		plotword 1
		plotword 2
		plotword 3
		MOVE.W (A0)+,D3
		MOVE.W D3,i+(4*8)(A1)
		BSR play2
		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		MOVE.W D3,j+(4*8)(A1)
		plotword 5
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE.W expandedbuf+k(PC),D4

		plotword 6
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		plotword 7
		plotword 8
		plotword 9
		plotword 10
		plotword 11
		plotword 12
		plotword 13
		plotword 14
		plotword 15
		plotword 16
		plotword 17
		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		plotword 18
		NOP
		MOVE.W (A0)+,D3
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE.W D3,i+(8*19)(A1)

		MOVE.W D3,j+(8*19)(A1)
		MOVE.W (A0)+,D3
		MOVE.W D3,i+(8*20)(A1)
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 9,$4E71
		MOVE.W D3,j+(8*20)(A1)
		plotword 21
		plotword 22
		plotword 23
		MOVE.W (A0)+,D3
		NOP
		BSR play2
		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		MOVE.W D3,i+(8*24)(A1)
		MOVE.W D3,j+(8*24)(A1)
		MOVE.W D4,l(A1)
		DCB.W 2,$4e71	
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE.W D4,m(A1)
		MOVE.W D4,l+230(A1)
		MOVE.W D4,m+230(A1)
		DCB.W 2,$4E71		
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE.W D4,l+460(A1)
		MOVE.W D4,m+460(A1)
		MOVE.W D4,l+690(A1)
		MOVE.W D4,m+690(A1)
		MOVE.W D4,l+920(A1)
		MOVE.W D4,m+920(A1)
		MOVE.W D4,l+1150(A1)
		MOVE.W D4,m+1150(A1)
		MOVE.W D4,l+1380(A1)
		MOVE.W D4,m+1380(A1)
		MOVE.W D4,l+1610(A1)
		MOVE.W D4,m+1610(A1)
		MOVE.W expandedbuf+k+2(PC),D4
		MOVE.W D4,l+8(A1)
		MOVE.W D4,m+8(A1)
		MOVE.W D4,l+238(A1)
		MOVE.W D4,m+238(A1)
		MOVE.W D4,l+468(A1)
		MOVE.W D4,m+468(A1)
		MOVE.W D4,l+698(A1)
		MOVE.W D4,m+698(A1)
		MOVE.W D4,l+928(A1)
		MOVE.W D4,m+928(A1)
		MOVE.W D4,l+1158(A1)
		MOVE.W D4,m+1158(A1)
		MOVE.W D4,l+1388(A1)
		MOVE.W D4,m+1388(A1)
		MOVE.W D4,l+1618(A1)
		MOVE.W D4,m+1618(A1)
		NOP
		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		DCB.W 11,$4e71	
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		LEA linewid8-50(a0),a0
		NOP
i		SET i+230
j		SET j+230
k		SET k+4
l		SET l+16
m		SET m+16
		ENDR
		DCB.W 5,$4E71
		MOVE #$8240,A0
		MOVEQ.L #0,D0
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		DCB.W 88-49-10,$4E71
		MOVE.B #78,$FFFFFA25.W
		MOVE.B #1,$FFFFFA1D.W
		BSR play2
		MOVE.B D0,$FFFF820A.W
		MOVE.B D1,$FFFF820A.W
		DCB.W 11,$4e71	
		MOVE.B D1,$FFFF8260.W
		MOVE.B D0,$FFFF8260.W
		MOVE #$2300,SR
		REPT 8
		MOVE.L D0,(A0)+
		ENDR


		MOVE.L log_base,D0
		ADD.L #8*230,D0
		CMP.L #screen1+(256*230),D0
		BNE.S .nores
		MOVE.L #screen1,D0
.nores		MOVE.L D0,D1
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		MOVE.L D1,log_base		
		CLR D0
		MOVE.B log_base+3,d0
		LEA LINE_JMPS,A0
		MULU #7*2,D0
		ADDA.W D0,A0
		LEA HL1+2(PC),A1
		MOVE.L (A0)+,(A1)
		MOVE.L (A0)+,6(A1)
		MOVE.L (A0)+,12(A1)
		MOVE.L (A0)+,18(A1)
		MOVE.L (A0)+,24(A1)
		MOVE.L (A0)+,30(A1)
		MOVE.L (A0)+,36(A1)
		MOVE.L image_seqptr,A0
		MOVE.L (A0)+,D0
		BGE.S notendimgseq
		LEA img_seq,A0
		MOVE.L (A0)+,D0
notendimgseq	ADD.L #img,D0
		MOVE.L D0,image_ptr
		MOVE.L A0,image_seqptr
		JSR Plot_littlescroller
		JSR BigVertScroller
		JSR Dist_scrl13
phbl		RTE
expandedbuf	DS.W 16

;--------------------------------------------------------------------------
; THE ACTUAL HARDWARE SCROLL ROUTS. 
; EACH ROUTS WILL GIVE A CERTAIN LINE LENGTH AND BY USING DIFFERENT
; COMBINATIONS OF THESE THE SCREEN CAN BE SCROLLED!!! 
;--------------------------------------------------------------------------

copytake	EQU 55

copycols	MACRO
		NOT D0
		TST D0
		BEQ.S playit\@
		DCB.W 53-5,$4E71
		BRA.S done\@
playit\@	BSR play2
		NOP
done\@		
		ENDM

; This table contains the various border removal combinations
; for adding 0 bytes,8 bytes,16 bytes etc etc....

ROUT_TAB	DC.L nothing     ;=0          0      
		DC.L length_2    ;=-2         1
		DC.L length24    ;=+24        2
		DC.L rightonly   ;=+44        3
		DC.L wholeline   ;=+70        4
		DC.L length26    ;=+26        5
		DC.L length_106  ;=-106!      6

ROUTS		DC.B 0,0,0,0,0,0,0
		DC.B 6,4,3,1,1,1,0
		DC.B 6,4,3,1,1,0,0
		DC.B 6,4,3,1,0,0,0
		DC.B 6,4,3,0,0,0,0
		DC.B 6,4,2,2,1,0,0
		DC.B 6,4,2,2,0,0,0
		DC.B 6,5,4,2,0,0,0
		DC.B 6,5,5,4,0,0,0
		DC.B 2,1,1,1,0,0,0
		DC.B 2,1,1,0,0,0,0
		DC.B 2,1,0,0,0,0,0
		DC.B 2,0,0,0,0,0,0
		DC.B 5,0,0,0,0,0,0
		DC.B 6,4,4,1,1,1,0
		DC.B 6,4,4,1,1,0,0
		DC.B 6,4,4,1,0,0,0
		DC.B 6,4,4,0,0,0,0
		DC.B 6,4,2,2,2,0,0
		DC.B 3,1,1,1,0,0,0
		DC.B 3,1,1,0,0,0,0
		DC.B 3,1,0,0,0,0,0
		DC.B 3,0,0,0,0,0,0
		DC.B 2,2,1,0,0,0,0
		DC.B 2,2,0,0,0,0,0
		DC.B 5,2,0,0,0,0,0
		DC.B 5,5,0,0,0,0,0
		DC.B 6,4,4,2,1,1,0
		DC.B 6,4,4,2,1,0,0
		DC.B 6,4,4,2,0,0,0
		DC.B 6,5,4,4,0,0,0
		DC.B 4,1,1,1,1,0,0
		DC.B 4,1,1,1,0,0,0
		DC.B 4,1,1,0,0,0,0
		DC.B 4,1,0,0,0,0,0
		DC.B 4,0,0,0,0,0,0
		DC.B 2,2,2,0,0,0,0
		DC.B 5,2,2,0,0,0,0
		DC.B 5,5,2,0,0,0,0
		DC.B 5,5,5,0,0,0,0
		DC.B 6,4,4,2,2,1,0
		DC.B 6,4,4,2,2,0,0
		DC.B 3,3,1,1,0,0,0
		DC.B 3,3,1,0,0,0,0
		DC.B 3,3,0,0,0,0,0
		DC.B 4,2,1,1,0,0,0
		DC.B 4,2,1,0,0,0,0
		DC.B 4,2,0,0,0,0,0
		DC.B 5,4,0,0,0,0,0
		DC.B 5,2,2,2,0,0,0
		DC.B 5,5,2,2,0,0,0
		DC.B 5,5,5,2,0,0,0
		DC.B 6,4,4,4,0,0,0
		DC.B 6,4,4,2,2,2,0
		DC.B 4,3,1,1,1,0,0
		DC.B 4,3,1,1,0,0,0
		DC.B 4,3,1,0,0,0,0
		DC.B 4,3,0,0,0,0,0
		DC.B 4,2,2,1,0,0,0
		DC.B 4,2,2,0,0,0,0
		DC.B 5,4,2,0,0,0,0
		DC.B 5,5,4,0,0,0,0
		DC.B 5,5,2,2,2,0,0
		DC.B 5,5,5,2,2,0,0
		DC.B 6,4,4,4,2,0,0
		DC.B 3,3,3,1,0,0,0
		DC.B 3,3,3,0,0,0,0
		DC.B 4,4,1,1,1,0,0
		DC.B 4,4,1,1,0,0,0
		DC.B 4,4,1,0,0,0,0
		DC.B 4,4,0,0,0,0,0
		DC.B 4,2,2,2,0,0,0
		DC.B 5,4,2,2,0,0,0
		DC.B 5,5,4,2,0,0,0
		DC.B 5,5,5,4,0,0,0
		DC.B 5,5,5,2,2,2,0
		DC.B 6,4,4,4,2,2,0
		DC.B 4,3,3,1,1,0,0
		DC.B 4,3,3,1,0,0,0
		DC.B 4,3,3,0,0,0,0
		DC.B 4,4,2,1,1,0,0
		DC.B 4,4,2,1,0,0,0
		DC.B 4,4,2,0,0,0,0
		DC.B 5,4,4,0,0,0,0
		DC.B 5,4,2,2,2,0,0
		DC.B 5,5,4,2,2,0,0
		DC.B 5,5,5,4,2,0,0
		DC.B 6,4,4,4,4,0,0
		DC.B 3,3,3,3,0,0,0
		DC.B 4,4,3,1,1,1,0
		DC.B 4,4,3,1,1,0,0
		DC.B 4,4,3,1,0,0,0
		DC.B 4,4,3,0,0,0,0
		DC.B 4,4,2,2,1,0,0
		DC.B 4,4,2,2,0,0,0
		DC.B 5,4,4,2,0,0,0
		DC.B 5,5,4,4,0,0,0
		DC.B 5,5,4,2,2,2,0
		DC.B 5,5,5,4,2,2,0
		DC.B 6,4,4,4,4,2,0
		DC.B 4,3,3,3,1,0,0
		DC.B 4,3,3,3,0,0,0
		DC.B 4,4,4,1,1,1,0
		DC.B 4,4,4,1,1,0,0
		DC.B 4,4,4,1,0,0,0
		DC.B 4,4,4,0,0,0,0
		DC.B 4,4,2,2,2,0,0
		DC.B 5,4,4,2,2,0,0
		DC.B 5,5,4,4,2,0,0
		DC.B 5,5,5,4,4,0,0
		DC.B 3,3,3,3,3,0,0
		DC.B 6,4,4,4,4,2,2
		DC.B 4,4,3,3,1,1,0
		DC.B 4,4,3,3,1,0,0
		DC.B 4,4,3,3,0,0,0
		DC.B 4,4,4,2,1,1,0
		DC.B 4,4,4,2,1,0,0
		DC.B 4,4,4,2,0,0,0
		DC.B 5,4,4,4,0,0,0
		DC.B 5,4,4,2,2,2,0
		DC.B 5,5,4,4,2,2,0
		DC.B 5,5,5,4,4,2,0
		DC.B 6,4,4,4,4,4,0
		DC.B 4,3,3,3,3,0,0
		DC.B 4,4,4,3,1,1,1
		DC.B 4,4,4,3,1,1,0
		DC.B 4,4,4,3,1,0,0
		DC.B 4,4,4,3,0,0,0

		even
			
* Overscan one whole screen line - works on STE.

wholeline	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 87-copytake,$4E71
		copycols
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 8,$4e71
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		RTS

* Right border only - works on STE!

rightonly	DCB.W	95-copytake,$4E71
		copycols
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 16,$4e71
		RTS

* Miss one word -2 bytes   - works on STE

length_2	DCB.W	94-copytake,$4E71
		copycols
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 17,$4e71
		RTS
   
* Do nothing              - works on STE!! 

nothing		DCB.W 95-copytake
		copycols
		DCB.W 119-95,$4E71
		RTS

* 24 bytes extra per line - works on STE

length24	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 86-copytake,$4E71
		copycols
		MOVE.B #0,$FFFF820A.W
		MOVE.B #2,$FFFF820A.W
		DCB.W 9,$4E71
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		RTS		

* +26 bytes  - works on ste although on ST's perhaps wobble may occur.

length26	MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		DCB.W 89-copytake,$4E71
		copycols
		DCB.W 14,$4E71
		MOVE.B #1,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		RTS		

* -106 bytes 

length_106	DCB.W 41,$4E71
		MOVE.B #2,$FFFF8260.W
		MOVE.B #0,$FFFF8260.W
		copycols
		DCB.W 70-copytake,$4e71
		RTS		

* SETUP HARDWARE SCROLL ROUTS

Setupscroll	LEA ROUTS(PC),A0
		LEA ROUT_TAB(PC),A1
		LEA LINE_JMPS,A2
		MOVEQ #127,D2	
.jlp		MOVEQ #6,D1
.ilp		CLR D0
		MOVE.B (A0)+,D0
		ADD D0,D0
		ADD D0,D0
		MOVE.L (A1,D0),(A2)+
		DBF D1,.ilp
		DBF D2,.jlp
		RTS

;-----------------------------------------------------------------------;

;-----------------------------------------------------------------------;
;			      * MR MUSIC * 				;
; Four Channel 8 bit sample player/sequencer programmed by :-		;
; Jose Commins of The Games Forge.(Concept,data format and sequencer)  	;
; Martin 'the length' Griffiths.(Convertor and optimisation)		;
; 7.9khz version! Using word samples					;
; This version leaves D0-D4 and A0-A1 free to play with.		;
;-----------------------------------------------------------------------;

; Initialise digi-synth.
	
Inittune:
	bsr	gentabs			; Generate note tables.
	bsr	find_tune
	bsr	find_samples
	lea	dur1(pc),a0
	bsr	initvoice
	lea	dur2(pc),a0
	bsr	initvoice
	lea	dur3(pc),a0
	bsr	initvoice
	lea	dur4(pc),a0
	bsr	initvoice
	bsr	set_up_sound		; Set up sound chip.
	lea	notetab-512,a2
	lea	offsamp(pc),a3
	move.l	a3,a4
	move.l	a3,a5
	move.l	a3,a6
	rts

; THIS IS THE SEQUENCER.

Seq:	movem.l d0-d3/a0-a1,-(sp)
	lea	dur1(pc),a0		; Play channel 1 song.
	lea	rmod1(pc),a1
	bsr	mr_music
	lea	dur2(pc),a0		; Play channel 2 song.
	lea	rmod2(pc),a1
	bsr	mr_music
	lea	dur3(pc),a0		; Play channel 3 song.
	lea	rmod3(pc),a1
	bsr	mr_music
	lea	dur4(pc),a0		; Play channel 4 song.
	lea	rmod4(pc),a1
	bsr	mr_music
	move.w	dur1+note(pc),d0
	move.w	dur2+note(pc),d1
	move.w	dur3+note(pc),d2
	move.w 	dur4+note(pc),d3
	sub.w	d0,d1			; Get offset from Ch1 note.
	sub.w	d0,d2
	sub.w	d0,d3
	move.w	#$2700,sr
	lea	notes,a2		; Reset note table.
	adda.w	d0,a2			; Add note for channel 1.
	move.w	d1,ch2add+2		; And modify offset.
	move.w	d2,ch3add+2
	move.w	d3,ch4add+2
	move #$2300,sr
	move.w	d1,ch2adda+2		; And modify offset.
	move.w	d2,ch3adda+2
	move.w	d3,ch4adda+2
	movem.l (sp)+,d0-d3/a0-a1
	rts
	
* MUSIC CONTROLLER (THIS CALLS ALL THE SUBROUTINES)

mr_music:
	move.w	(a1)+,loadit		; modify address reg stuff.
	move.w	(a1),loadit2
	move.w	(a1),loadit3
	sf	 new(a0)
	subq.w 	#1,(a0)			; Is duration on channel on?
	bne.s	no_new			; Nope... Keep on playing sample.
	move.l	sptr(a0),a1		; Yep... Get song pointer.
	move.w	(a1),d2			; Pattern command or end?
	bpl.s	noend			; No... Get command.
	cmpi.w	#-9999,d2		; End of song?
	bne	do_loop			; No, then it's a pattern loop.
	move.l	sptr+4(a0),a1		; Yes... Restore song pointer.
noend:	move.w	(a1)+,d2		; Get command word.
testlp	btst	#14,d2			; Loop on this channel?
	sne	loop(a0)		; set flag if bit is set
testsmp:btst	#0,d2			; NEW SAMPLE?
	bne	new_samp
testnte:btst	#1,d2			; NEW NOTE?
	bne	new_note
testsld:btst	#2,d2			; SLIDE?
	bne	slide_note
testrst:btst	#3,d2			; REST?
	bne	rest
endcmds	move.l	a1,sptr(a0)		; Store new song pointer.

; Slide test & slide.

no_new:	tst.b	slidin(a0)		; Are we sliding?
	beq.s	loop_test		; Nope... So skip.
	move.w	note(a0),d0		; Yes... Get current note.
	cmp.w	snote(a0),d0		; Is it = to destination note?
	beq.s	skipsl			; Yes... Stop sliding.
	subq.w	#1,scount(a0)		; No... Do slide rate...
	bne.s	loop_test
	move.w	slide(a0),scount(a0)
	cmp.w	snote(a0),d0		; Compare both notes.
	bgt.s	subit
	add.w	#512,note(a0)		; Source > dest, so slide up.
	bra.s	loop_test		; Continue sliding.
subit:	sub.w	#512,note(a0)		; Source < dest, so slide down.
	bra.s	loop_test		; Continue sliding.
skipsl:	sf	slidin(a0)		; Signal no slide.

; Loop test for sampled instruments.	

loop_test:
	tst.b	vcon(a0)
	beq.s	vcoff
	tst.b	new(a0)
	bne.s 	endltst
	move #$2700,sr
loadit	move.l a3,d1
	move.l	edaddr(a0),d0		; get sample's end addr
	cmp.l	d1,d0			; Is it over end?
	bgt.s	endltst			; Nope... No loop yet.
	tst.b	loop(a0)		; Loop sample?
	bne.s	loopit			; Yep... Loop test.
	sf	vcon(a0)		; If no loop, no play.
	sf	slidin(a0)		; No slide.
vcoff:	move	#-512,note(a0)
	move.l	#offsamp,d1
	bra	loadit2	
loopit:	sub.l	d0,d1
	add.l	lpaddr(a0),d1
; (fall through)	

loadit2:move.l 	d1,a3
endltst:move #$2300,sr
	rts

rmod1	move.l	a3,d1
	move.l	d1,a3
rmod2	move.l	a4,d1
	move.l	d1,a4
rmod3	move.l	a5,d1
	move.l	d1,a5
rmod4	move.l	a6,d1
	move.l	d1,a6

new_samp:
	move.w	(a1)+,d0		; Get sample number
	move.l	a1,d3
	lea	slist(pc),a1		; Get sample address table.
	lsl.w	#3,d0			; x 8 bytes per entry.
	adda.w	d0,a1			; Now A1 points to sample entries.
	move.l	samples(pc),d1		; Get samples start address.
	add.l	(a1)+,d1		; + offset = Sample address.
	move.l	d1,staddr(a0)
	moveq.l	#0,d0
	move.w	(a1)+,d0
	add.l 	d1,d0
	move.l	d0,edaddr(a0)		; Store end addr of sample
	moveq.l	#0,d0	
	move.w	(a1),d0	
	add.l 	d1,d0
	move.l	d0,lpaddr(a0)		; and loop addr of sample
	st	new(a0)			; Signal new sample.
	move.l	d3,a1
	bra	testnte

new_note:
	move.l	staddr(a0),d1
loadit3	move.l	d1,a3
	move.w	(a1)+,d0		; Yes... Get note.
	moveq	#9,d1
	lsl.w	d1,d0			; x 512 bytes for tables.
	move.w	d0,note(a0)		; Now new note.
	move.w	(a1)+,(a0)		; And new duration.
	st	vcon(a0)		; Enable playback.
	st	new(a0)			; Signal new sample.
	bra	testsld

slide_note:
	move.w	(a1)+,d0		; Slide to note...
	moveq	#9,d1
	lsl.w	d1,d0			; (X 512 for table)
	move.w	d0,snote(a0)
	move.w	(a1)+,d0		; Get slide delay value.
	move.w	d0,slide(a0)		; Put it in storage.
	move.w	d0,scount(a0)		; And in the counter.
	st	slidin(a0)		; Signal slide in progress.
	move.w	(a1)+,dur(a0)		; Get duration.
	bra	testrst

rest:	move.w	(a1)+,(a0)		; Get duration of rest.
	sf	vcon(a0)		; And don't play.
	bra	endcmds

do_loop:move.w	(a1)+,d0		; Get loop signal.
	move.b	(a1)+,d0		; Get loop value.
	move.b	(a1)+,d1		; Get loop counter.
	bne.s	keeplp			; Zero? No, more loops.
	move.b	d0,-1(a1)		; Restore loop counter.
	addq.w	#2,a1			; And go past loop address.
	tst.w	(a1)			; Is it a pattern command?
	bpl.s	moresng			; No, then play whatever.
	cmpi.w	#-9999,(a1)
	bne.s	do_loop
	move.l	sptr+4(a0),a1		; Yes... Restore song pointer.
moresng:bra	noend
keeplp:	subq.b	#1,d1			; Increase loop counter.
	move.b	d1,-1(a1)		; Store counter.
	sub.w	(a1),a1			; And loop back to address.
	bra	noend

; 12bit sample player - Through internal soundchip
					
player:	
play1	move.w	(a3),d7			;8
	add.w	(a4),d7			;8
	add.w	(a5),d7			;8
	add.w	(a6),d7			;8
	movem.l	sound_look(pc,d7),d6-d7 ;36
	movem.l d6-d7,$ffff8800.w	;36
ch4add:	adda.w	2(a2),a6		;16
ch3add:	adda.w	2(a2),a5		;16
ch2add:	adda.w	2(a2),a4		;16
	adda.w	(a2)+,a3		;12
	rte				;
					;---
					;162 cycles 
					;add 64 for rte + int req

play2	move.w	(a3),d7			;8
	add.w	(a4),d7			;8
	add.w	(a5),d7			;8
	add.w	(a6),d7			;8
	movem.l	sound_look(pc,d7),d6-d7 ;44
	movem.l d6-d7,$ffff8800.w	;44
ch4adda:adda.w	2(a2),a6		;16
ch3adda:adda.w	2(a2),a5		;16
ch2adda:adda.w	2(a2),a4		;16
	adda.w	(a2)+,a3		;12
	rts				;16+20(bsr)

sound_look:
	incbin D:\1PLANE.INC\2CHANMOV.TAB

;-------------------------------------------------------------------------;
;				SUBROUTINES				  ;
;-------------------------------------------------------------------------;

; ROUTINE FOR GENERATING 64 256 WORD NOTE TABLES. 

gentabs:lea	notes,a5
	lea	notetab(pc),a6		; Address of note table.
	moveq	#64-1,d3		; 64 notes.
nxtnote:move.l	(a6)+,d6		; Get note int and frac.
	moveq	#0,d5			; Clear D5.
	swap	d6			; Access to int part.
	move.w	d6,d4			; And into lower D5.
	clr.w	d6			; Get rid of D6 integer part.
	swap	d6			; Restore D6 mow only frac part.
	move.w	#256-1,d7		; 256 note skips. (20 to see!)
addem:	swap	d5			; Access to int.
	move.w	d4,d5			; Restore int.
	swap	d5			; And make upper D5 int.
	add.l	d6,d5			; Add frac & overflow =1 to D5.
	move.l 	d5,d2
	swap	d2
	add	d2,d2
	move.w	d2,(a5)+		; Store note skip value.
	dbra	d7,addem		; Do for 256 skips.
	dbra	d3,nxtnote		; Do for 64 notes.
	rts

; Initialise a voice pointed to by A0.

initvoice
	move.w	#2,dur(a0)
	move.w	#-512,note(a0)
	sf	loop(a0)
	sf	slidin(a0)
	sf	vcon(a0)
	sf	new(a0)
	lea.l	offsamp(pc),a1
	move.l	a1,staddr(a0)
	move.l	a1,edaddr(a0)
	move.l	a1,lpaddr(a0)
	rts

; FIND TUNE. (Needed every time a new tune is played).

find_tune:
	move.l	tuneptr(pc),a0		; Get tune pointer.
	lea	dur1(pc),a1		; Get song pointer for CH1.
	moveq	#3-1,d0			; Loop 3 times.
	move.l	a0,sptr(a1)		; Store the channel's tune addr.
	move.l	a0,sptr+4(a1)		; Twice for the player.
srchnt:	lea 	rsize(a1),a1
.srch	cmpi.w	#-9999,(a0)+		; Search for end of song.
	bne.s	.srch
	move.l	a0,sptr(a1)	
	move.l	a0,sptr+4(a1)
	dbra	d0,srchnt
	rts

; FIND SAMPLES

find_samples:
	move.l	samples(pc),a0		; Get voice set address.
findsmp:tst.w	(a0)			; See if negative.
	bpl.s	noends			; No...  Continue search.
	addq.w	#2,a0			; Yes...  Skip end value.
	move.l	a0,samples		; Store samples addresses.
	rts				; Return.
noends:	addq.w	#8,a0			; Skip to next instrument if any).
	bra.s	findsmp			; Continue search.

; SET UP SOUNDCHIP

set_up_sound:
	MOVE #$8800,A0
	MOVE.B #7,(A0)
	MOVE.B #$C0,D0
	AND.B	(A0),D0
	OR.B #$38,D0
	MOVE.B D0,2(A0)
	MOVE #$600,D0
.setup	MOVEP.W D0,(A0)
	SUB #$100,D0
	BPL.S .setup
	RTS

; 64 notes to generate tables...  Int and frac parts in word pairs.
; Generated using note formula in GFA Basic V3. Base freq: 440Hz.

notetab:dc.w	$0,$2AB7,$0,$2D41,$0,$2FF2,$0,$32CC
	dc.w	$0,$35D1,$0,$3904,$0,$3C68,$0,$4000
	dc.w	$0,$43CE,$0,$47D6,$0,$4C1C,$0,$50A2
	dc.w	$0,$556E,$0,$5A82,$0,$5FE4,$0,$6598
	dc.w	$0,$6BA2,$0,$7209,$0,$78D1,$0,$8000
	dc.w	$0,$879C,$0,$8FAD,$0,$9838,$0,$A145
	dc.w	$0,$AADC,$0,$B505,$0,$BFC9,$0,$CB30
	dc.w	$0,$D745,$0,$E412,$0,$F1A2,$1,$0
	dc.w	$1,$F39,$1,$1F5A,$1,$3070,$1,$428B
	dc.w	$1,$55B9,$1,$6A0B,$1,$7F92,$1,$9661
	dc.w	$1,$AE8B,$1,$C825,$1,$E345,$2,$1
	dc.w	$2,$1E73,$2,$3EB5,$2,$60E1,$2,$8516
	dc.w	$2,$AB72,$2,$D416,$2,$FF24,$3,$2CC2
	dc.w	$3,$5D16,$3,$904A,$3,$C68A,$4,$3
	dc.w	$4,$3CE7,$4,$7D6A,$4,$C1C3,$5,$A2D
	dc.w	$5,$56E4,$5,$A82C,$5,$FE49,$6,$5985

offsamp:dcb.w	1024,1024

; CHANNEL VARIABLES.	

tuneptr:dc.l	tune			; Address of tune.
samples:dc.l	slist			; Address of samples.

	rsreset
dur:	rs.w	1
note:	rs.w	1
loop:	rs.b	1
slidin:	rs.b	1
snote:	rs.w	1
scount:	rs.w	1
slide:	rs.w	1
staddr:	rs.l	1
edaddr:	rs.l	1
lpaddr:	rs.l	1
vcon:	rs.b	1
new:	rs.b	1
sptr:	rs.l	2
rsize	rs.b 	1

dur1:	ds.b	rsize
dur2:	ds.b	rsize
dur3:	ds.b	rsize
dur4:	ds.b	rsize

tune:		incbin D:\1PLANE.INC\FOIL.sng
slist:		incbin D:\1PLANE.INC\FOIL.eit
		even
img		incbin D:\1PLANE.INC\bigimage.dat
	
		ENDC

		SECTION BSS
old_stuff	DS.L 23
		DS.L 119
stack		DS.L 1
big_buf
		IFEQ intro1
; Note skip tables are written here.
		ds.w 256
notes:		ds.b 32768
		DS.W 2
sd_scbuffer	REPT 16
		DS.B bufsize
		ENDR
		DS.W 2

		DS.W 3
scbuffer8	REPT 16
		DS.B bufsize8
		ENDR
		DS.W 3

		ENDC
 
  