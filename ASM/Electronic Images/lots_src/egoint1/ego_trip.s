;-----------------------------------------------------------------------;
;               Intro For The Ego-Trippers Compacting Group		;
;             Coded by Griff of Electronic Images. 22/07/1991		;
;-----------------------------------------------------------------------;
; It contains 10 khz NoiseTracker (full Volume variation on all chans.)	;
; + a single 32*32 Byte Bending/Disting Scroller in 4 planes....	;
;-----------------------------------------------------------------------;
; (I would not advise using a module over 120k since it may not work on
;   1/2 meg machines....)

; Hi Ian below is the Y coord of the bottom of your piccy...
; (e.g for a half screen piccy you would set it at about 100...)

baseline	equ 181		; Set for this 179 line piccy.

; Also if you wanna use a different font then cut out a 32*32 with fontsave
; and select 59 letters - You must select this amount or it will crash

; The key definitions are just down below somewhere!

player		equ $f9800	; $79800 - for 520st

__OUTPUT	equ 0
ASreplayIrqFrq	equ 64		; approx 10khz (timer speed)
tune		equ 96		; fine tune thingy

		SECTION TEXT

		OPT O+,OW-

Start		BRA letsgo

		DC.L 0
fileptr		DC.L 0
fileptrs	DC.L filename1
		DC.L filename2
		DC.L filename3
		DC.L filename4
		DC.L filename5

; The filenames - change this to the names of the program
; you wish to run when each key is pressed i.e filname1 for key 1 !!!

NOKEYS		EQU  5					number of keys

filename1	DC.B "A:\ROBO.JIM",0
		EVEN
filename2	DC.B "A:\SPIN.JIM",0
		EVEN
filename3	DC.B "A:\GENST2.PRG",0
		EVEN
filename4	DC.B "A:\GAME4.PRG",0
		EVEN
filename5	DC.B "A:\GAME5.PRG",0
		EVEN

letsgo		MOVE.L SP,A5			; save sp
		MOVE.L 4(A5),A5
		LEA stack,SP
		MOVE.L #$400,-(SP)		; length to reserve
		MOVE.L A5,-(SP)			; addr to reserve from
		MOVE.L #$4A0000,-(SP)		; memory shrink
		TRAP #1				; gemdos
		LEA 12(SP),SP			; correct stack
		MOVE #4,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		CMP #2,D0			; hires?
		BEQ exitme			; yes then fuckoff to desktop
		MOVE D0,oldres
		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; lowres
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; super
		ADDQ.L #6,SP
		MOVE.L D0,oldsp
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_stuff		; save palette
		MOVE #$777,D7			; fade down screen
.lp1		MOVEQ #2,D6
.lp		MOVE #37,-(SP)
		TRAP #14
		ADDQ.L #2,SP
		DBF D6,.lp
		MOVE.W D7,$FFFF8240.W
		SUB #$111,D7
		BPL.S .lp1
		MOVE #$8240,A0
		MOVEQ #0,D0
		REPT 8
		MOVE.L D0,(A0)+
		ENDR
		BSR ASreplayInstall		Start playing music
		MOVE #$2700,SR
		LEA $FFFFFA00.W,A1
		LEA old_stuff+32(PC),A0
		MOVE.B $07(A1),(A0)+
		MOVE.B $09(A1),(A0)+
		MOVE.B $13(A1),(A0)+
		MOVE.B $15(A1),(A0)+		; Save mfp registers 
		MOVE.B $19(A1),(A0)+		
		MOVE.B $1B(A1),(A0)+		
		MOVE.B $1D(A1),(A0)+
		MOVE.B $1F(A1),(A0)+
		MOVE.B $21(A1),(A0)+
		MOVE.B $25(A1),(A0)+
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $110.W,(A0)+
		MOVE.L $114.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
		MOVE.L $FFFF8200.W,(A0)+
		BSR Initscreens
		BSR Convfont
		move.l log_base(pc),a0
		BSR clear_screen
		MOVE.L log_base(pc),d0
		LSR #8,d0
		MOVE.L D0,$ffff8200.w
		BSR Copypic
		BSR flush
		MOVEQ #$12,D0
		BSR Write_ikbd
		MOVE.B #$21,$fffffa07.W
		MOVE.B #$10,$fffffa09.W
		MOVE.B #$21,$fffffa13.W
		MOVE.B #$10,$fffffa15.W
		CLR.B $fffffa1d.w
		MOVE.B #ASreplayIrqFrq,$fffffa25.w
		MOVE.B #1,$fffffa1d.w
		CLR.B $FFFFFA1B.W
		CLR.B $FFFFFA19.W
		MOVE.L #my_vbl,$70.W
		MOVE.L #player,$110.w
		MOVE.L #top_bordover,$134.w
		MOVE.L #piccy+2,pal_ptr
		BCLR.B #3,$fffffa17.W
		BSR flush
		CLR.B $FFFFFA0B.W
		CLR.B $FFFFFA0D.W
		MOVE #$2300,SR				; lets go!

vbwait		BTST.B #0,$FFFFFC00.W
		BEQ.S vbwait 
		MOVE.B $fffffc02.w,d0

; Here are the Key definations......

CHECKKEY1	CMP.B #1+1,d0
		BLT vbwait
		CMP.B #NOKEYS+1,d0
		BGT vbwait

; Restore gem then Chain the selected file.

		MOVE #$2700,SR
		AND #$FF,D0
		SUBQ #2,D0
		ADD D0,D0
		ADD D0,D0
		LEA fileptrs(PC),A6
		MOVE.L (A6,D0),fileptr
		LEA old_stuff(PC),A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA19.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA1D.W
		MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.B (A0)+,$FFFFFA25.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W
		MOVE.L (A0)+,$110.W
		MOVE.L (A0)+,$114.W
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		MOVE.L (A0)+,$FFFF8200.W
		MOVE.B #$C0,$FFFFFA23.W
		BSET.B #3,$FFFFFA17.W
		BSR flush
		MOVEQ #$8,D0
		BSR Write_ikbd
		MOVE #$2300,SR
		MOVE.W oldres(PC),-(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			lowres
		LEA 12(SP),SP
		MOVE.L oldsp(PC),-(SP)
		MOVE #$20,-(SP)
		TRAP #1				; super
		ADDQ.L #6,SP

		CLR.L Start
		PEA Start(PC)			;environment string...
		PEA Start(PC)
		MOVE.L fileptr(PC),-(SP)	;ptr to path + filename
		CLR -(SP)			;load'n'execute
		MOVE #$4B,-(SP)			;p_exec
		TRAP #1		
		LEA 16(SP),SP
exitme		CLR -(SP)
		TRAP #1

; Write D0 to IKBD

Write_ikbd	BTST.B #1,$FFFFFC00.W
		BEQ.S Write_ikbd
		MOVE.B D0,$FFFFFC02.W
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

oldsp		DC.L 0
old_stuff	DS.L 30
oldres		DS.W 1

; Init screens - screen allocation and clearing...

Initscreens	lea log_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)+
		rts

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #(44800/16)-1,d1
.cls		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		move.l d0,(a0)+
		dbf d1,.cls
		rts

; Copy Picture to logical screens.

Copypic		lea piccy+34,A0
		move.l log_base(pc),a1
		move #7999,d0
		moveq #0,d1
.lp		move.l (a0),(a1)+
		move.l d1,(a0)+
		dbf d0,.lp
		rts

; The vbl - calls sequencer and vbl filler

my_vbl		clr.b $fffffa19.w
		move.b #99,$fffffa1f.w
		move.b #4,$fffffa19.w
		move.l d0,-(sp)
		clr.b $fffffa1b.w
		move.b #baseline+1,$FFFFFA21.w
		move.b #8,$FFFFFA1B.w
		move.b #46,$FFFFFA21.w
		MOVE.L #palchange1,$120.w
		movem.l curr_pal(pc),D0-D7
		movem.l D0-D7,$FFFF8240.W		; set piccy pal
		tst.b scrlflag
		beq.s .nodoscrl
		bsr Dist_N_ByteBend
		bra.s .donescrl
.nodoscrl	move #5400,d0
.lp		dbf d0,.lp
.donescrl	bsr Fade_in				; fade in piccy
		bsr ASreplay
		bsr ASconvert
		bsr ASreplayDriver
		move.l (sp)+,d0
		rte

playtake	equ 36

play1		MACRO
		MOVE.L $110.W,A0
		PEA ret\@(PC)
		MOVE.W #$2700,-(SP)
		JMP (A0)
ret\@
		ENDM

top_bordover	PEA (A0)
		MOVE.L #phbl2,$68.W
		CLR.B $FFFFFA19.W
		CLR.B $FFFFFA1D.W
		MOVE #$2100,SR
		STOP #$2100
		MOVE.W #$2700,SR
		play1
		MOVE.B #ASreplayIrqFrq,$FFFFFA25.W
		MOVE.B #1,$FFFFFA1D.W
		DCB.W 86-9-playtake,$4E71
		MOVE.B #0,$FFFF820A.W
		DCB.W 18,$4E71
		MOVE.B #2,$FFFF820A.W
		MOVE.L (SP)+,A0
phbl2		RTE

palchange1	MOVE.W #$2500,SR
		PEA (A0)
		MOVE #$8240,A0
		MOVE.L #$00000011,(A0)+
		MOVE.L #$01220233,(A0)+
		MOVE.L #$01100221,(A0)+
		MOVE.L #$03320100,(A0)+
		MOVE.L #$02110322,(A0)+
		MOVE.L #$00100121,(A0)+
		MOVE.L #$02320444,(A0)+
		MOVE.L #$03330555,(A0)+
		MOVE.L #bot_bordover,$120.w
		MOVE.L (SP)+,A0
		RTE

bot_bordover	MOVE.W #$2500,SR
		MOVEM.L D2/A0,-(SP)
		MOVE #$8209,A0
		MOVE #128,D2
		CLR.B $FFFFFA1D.W
		CLR.B $FFFFFA1B.W
.syncb		CMP.B (A0),D2
		BEQ.S .syncb
		MOVE.B (A0),D2
		LEA noplist-128(PC),A0
		JMP (A0,D2) 
noplist		DCB.W 95-playtake,$4E71	
		play1
 		MOVE.B #0,$ffff820a.w
		dcb.w 8,$4e71
		MOVE.B #2,$ffff820a.w	
		MOVE.B #1,$FFFFFA1D.W
		MOVEM.L (SP)+,D2/A0
		RTE

; Fade in rout

Fade_in		TST fadeing
		BEQ fadedone
		SUBQ #1,fadeing1
		BNE nofade
		MOVE #4,fadeing1
		SUBQ #1,fadeing
		LEA curr_pal(PC),A0
		MOVE.L pal_ptr(PC),A2
		MOVEQ #15,D4
col_lp		MOVE (A0),D0		reg value
		MOVE (A2)+,D1		dest value
		MOVE D0,D2
		MOVE D1,D3
		AND #$700,D2
		AND #$700,D3
		CMP D2,D3		
		BLE.S R_done
		ADD #$100,D0
R_done		MOVE D0,D2
		MOVE D1,D3
		AND #$070,D2
		AND #$070,D3
		CMP D2,D3
		BLE.S G_done
		ADD #$010,D0
G_done 		MOVE D0,D2
		MOVE D1,D3
		AND #$007,D2
		AND #$007,D3
		CMP D2,D3
		BLE.S B_done
		ADDQ #$001,D0
B_done		MOVE D0,(A0)+
		DBF D4,col_lp
nofade		RTS

fadedone	ST scrlflag
		RTS

pal_ptr		DC.L 0
curr_pal	DS.W 16
fadeing		DC.W 7
fadeing1	DC.W 16
scrlflag	DC.W 0

log_base	DC.L 0
switch		DC.W 0

; Disting/ByteBending Rout.(32*32 in 4 plane takes 37% aaaargghh!)

no_lines	EQU 31
linewid		EQU 60*8
bufsize		EQU no_lines*linewid 
Scrlspeed	EQU 4

Dist_N_ByteBend	MOVE.L log_base(PC),A0	;screen base
		LEA baseline*160(A0),A0
		MOVEQ #0,D2
		MOVEQ #1,D1
.clearoldlp	MOVEQ #1,D0
.clearold	REPT 40			;delete top
		MOVEP.L D2,1280(A0)	;and bottom
		ENDR			;of old scroller
		LEA 160(A0),A0
		DBF D0,.clearold
		LEA (no_lines-4)*160(A0),A0
		DBF D1,.clearoldlp
.vdist		LEA vwaveptr,A0
		MOVE.W (A0),D0			;setup vertical
		ADDQ #2,D0			;wave (using SMC)
		AND #$FF,D0
		MOVE.W D0,(A0)+
		ADD.W D0,A0
		LEA .clearold(PC),A2
		LEA plot8(PC),A3
i		SET 0
j		SET 0
		REPT 5
		MOVEM.W (A0)+,D0-D7
		ADD #j,D0
		ADD #j+1,D1
		ADD #j+8,D2
		ADD #j+9,D3
		ADD #j+16,D4
		ADD #j+17,D5
		ADD #j+24,D6
		ADD #j+25,D7
		MOVE.W D0,i+2(A3)
		MOVE.W D0,j+2(A2)
		MOVE.W D1,i+6(A3)
		MOVE.W D1,j+6(A2)
		MOVE.W D2,i+10(A3)
		MOVE.W D2,j+10(A2)		
		MOVE.W D3,i+14(A3)
		MOVE.W D3,j+14(A2)	;(also setup for delete!)
		MOVE.W D4,i+18(A3)
		MOVE.W D4,j+18(A2)
		MOVE.W D5,i+22(A3)
		MOVE.W D5,j+22(A2)
		MOVE.W D6,i+26(A3)
		MOVE.W D6,j+26(A2)
		MOVE.W D7,i+30(A3)
		MOVE.W D7,j+30(A2)
i		SET i+36
j		SET j+32
		ENDR

.calc_dist	LEA dist_tab+2(PC),A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,-34(A0)
		MOVEM.L (A0)+,D0-D7		;shift up dist table
		MOVEM.L D0-D7,-34(A0)
		MOVE dist_ang(PC),D0
		ADD dist_step(PC),D0
		AND #$7FF,D0
.yep		MOVE D0,dist_ang
		MOVE dister(PC),D1
		ADD dist_step(PC),D1
		CMP maxi_dist(PC),D1
		BLE.S .notwang			;dist sequence
 		SUB maxi_dist(PC),D1
.sel_wave	MOVE.L wave_ptr(PC),A3
		LEA dist_step(PC),A2
		MOVE (A3)+,(A2)+
		BPL.S .nrapwave 
		LEA wave_tab(PC),A3
		MOVE (A3)+,-2(A2)
.nrapwave	MOVE.L (A3)+,(A2)+
		MOVE.L A3,wave_ptr
.notwang	MOVE D1,dister
		LEA trig_tab(PC),A3		;ptr to sin table
		MOVE (A3,D0),D0			;sin(xd)
		MULS size(PC),D0		;*size (magnitude of wave)
		ADD.L D0,D0
		SWAP D0				;normalise
		ADD #72,D0
		ADD D0,D0
		ADD D0,D0			;x4
		MOVE.W D0,dist_tab+60		;place in table

		LEA scr_point(PC),A2
		MOVEM.L (A2)+,A0/A4		;curr text ptr/curr pix buffer ptr
		MOVE (A2),D6			;pixel offset
		ADD.L #bufsize*Scrlspeed,A4	;skip buffers(speed pix step)	
		ADDQ #Scrlspeed,D6		;add (speed pixel step)
		CMP #8,D6
		BNE .t2
		LEA scbuffer,A4			;reset pixel chunk offset
		MOVE #4,littleadd
.t2		CMP #16,D6			;end of chunk?
		BNE.S .pos_ok			;no then skip
		ADDQ.W #8,scrlpos		;onto next chunk 
		CMP #linewid/2,scrlpos		;in pix buffer.
		BNE.S .nowrapscr		;reached end of buffer?		
		CLR scrlpos			;if yes reset buffer position
.nowrapscr	LEA scbuffer,A4			;reset pixel chunk offset
		MOVEQ #0,D6			;+ pix position
		MOVE.W D6,littleadd
		NOT inletswitch			;font is 32 wide
		BNE.S .pos_ok 			;so there are two chunks
		ADDQ.L #1,A0			;after 32 pixs,next letter...
.pos_ok		MOVEQ #0,D0
		TST.B 1(A0)	
		BNE.S .notwrap			;end of text?
		LEA text(PC),A0			;yes restart text
.notwrap	MOVE D6,(A2)			;otherwise restore
		MOVE.L A4,-(A2)
		MOVE.L A0,-(A2)
		MOVEQ #0,D0
		MOVE.B (A0)+,D0
		SUB.B #32,D0			;normalise asci char
		LSL #8,D0
		ADD D0,D0
		LEA fontbuf,A2     		;character addr    
		ADDA.W D0,A2
		LEA 256(A2),A3			;point to 2nd chunk
		TST inletswitch			;are we in 2nd chunk
		BEQ.S .norm 			;already?
		MOVE.L A3,A2
		MOVEQ #0,D0			;1st chunk of next char
		MOVE.B (A0),D0			;must be plotted
		SUB.B #32,D0
		LSL #8,D0
		ADD D0,D0
		LEA fontbuf,A3         
		ADDA.W D0,A3
.norm		ADD scrlpos(PC),A4
		ADD littleadd(PC),A4
		CMP #8,D6
		BLE .LESSTHAN8
.MORETHAN8	NEG D6
		ADD #16,D6
		REPT no_lines
		MOVEM.W (A2)+,D2-d5
		SWAP D2
		SWAP D3
		SWAP D4
		SWAP D5
		MOVE.W (A3)+,D2 
		MOVE.W (A3)+,D3 
		MOVE.W (A3)+,D4 
		MOVE.W (A3)+,D5 
		ROR.L D6,D2
		ROR.L D6,D3			;shift in (>8 shift)
		ROR.L D6,D4
		ROR.L D6,D5
		MOVE.B D2,(A4)+
		MOVE.B D3,(A4)+
		MOVE.B D4,(A4)+
		MOVE.B D5,(A4)+
		MOVE.L -(A4),(linewid/2)(A4)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize(A4),A4
		MOVE.B D2,(A4)+
		MOVE.B D3,(A4)+
		MOVE.B D4,(A4)+
		MOVE.B D5,(A4)+
		MOVE.L -(A4),(linewid/2)(A4)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize(A4),A4
		MOVE.B D2,(A4)+
		MOVE.B D3,(A4)+
		MOVE.B D4,(A4)+
		MOVE.B D5,(A4)+
		MOVE.L -(A4),(linewid/2)(A4)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize(A4),A4
		MOVE.B D2,(A4)+
		MOVE.B D3,(A4)+
		MOVE.B D4,(A4)+
		MOVE.B D5,(A4)+
		MOVE.L -(A4),(linewid/2)(A4)
		ADD.L #linewid-(bufsize*(Scrlspeed-1)),A4
		ENDR

		BRA .copy_buf

.LESSTHAN8
		REPT no_lines
		MOVEM.W (A3)+,D2-d5
		SWAP D2
		SWAP D3
		SWAP D4
		SWAP D5
		MOVE.W (A2)+,D2 
		MOVE.W (A2)+,D3 
		MOVE.W (A2)+,D4 
		MOVE.W (A2)+,D5 
		ROL.L D6,D2
		ROL.L D6,D3			;(shift in <=8)
		ROL.L D6,D4
		ROL.L D6,D5
		MOVE.B D2,(A4)+
		MOVE.B D3,(A4)+
		MOVE.B D4,(A4)+
		MOVE.B D5,(A4)+
		MOVE.L -(A4),(linewid/2)(A4)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize(A4),A4
		MOVE.B D2,(A4)+
		MOVE.B D3,(A4)+
		MOVE.B D4,(A4)+
		MOVE.B D5,(A4)+
		MOVE.L -(A4),(linewid/2)(A4)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize(A4),A4
		MOVE.B D2,(A4)+
		MOVE.B D3,(A4)+
		MOVE.B D4,(A4)+
		MOVE.B D5,(A4)+
		MOVE.L -(A4),(linewid/2)(A4)
		ROL.L #1,D2
		ROL.L #1,D3
		ROL.L #1,D4
		ROL.L #1,D5
		LEA bufsize(A4),A4
		MOVE.B D2,(A4)+
		MOVE.B D3,(A4)+
		MOVE.B D4,(A4)+
		MOVE.B D5,(A4)+
		MOVE.L -(A4),(linewid/2)(A4)
		ADD.L #linewid-(bufsize*(Scrlspeed-1)),A4
		ENDR

.copy_buf	LEA scbuffer,A0			;buffer base
		ADD scrlpos(PC),A0		;+ offset
		MOVE.L log_base(PC),A2		;screen base
		LEA baseline*160(A2),A2
		LEA dist_tab(PC),A3		;disty table
		LEA xtab(PC),A4			;x offset lookup
		MOVE.W scx(PC),D0
		ADD D0,D0
		ADD D0,D0
		ADD.W D0,A4			;+offset in table
		MOVEQ #no_lines-1,D7 
yline_lp	MOVE.W D7,A6
		MOVE.W (A3)+,D0
		LEA (A0),A5
		ADD.L (A4,D0),A5
		MOVEM.L (A5)+,D0-D7
plot8		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		MOVEM.L (A5)+,D0-D7
		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)			;blit one line
		MOVEP.L D6,(a2)			;(quickly!!)
		MOVEP.L D7,(a2)
		MOVEM.L (A5)+,D0-D7
		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		MOVEM.L (A5)+,D0-D7
		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		MOVEM.L (A5)+,D0-D7
		MOVEP.L D0,(a2)
		MOVEP.L D1,(a2)
		MOVEP.L D2,(a2)
		MOVEP.L D3,(a2)
		MOVEP.L D4,(a2)
		MOVEP.L D5,(a2)
		MOVEP.L D6,(a2)
		MOVEP.L D7,(a2)
		LEA 160(A2),A2
		LEA linewid(A0),A0
		MOVE.W A6,D7			;(and onto next...)
		DBF D7,yline_lp
		RTS

; Convert Font

Convfont	LEA fontbuf,A1
		MOVEQ #58,D1
charlp		MOVE.L log_base(PC),A0
		MOVE.L A1,A2
		MOVEQ #127,D0
copy1lp		MOVE.L (A2)+,(A0)+
		DBF D0,copy1lp
copy2		MOVE.L log_base(PC),A0
		MOVEQ #31,D0
copy2lp		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,248(A1)
		MOVE.L (A0)+,252(A1)
		DBF D0,copy2lp		
		LEA 256(A1),A1
		DBF D1,charlp
		RTS

i		SET 0
xtab		REPT 20
		DC.L i
		DC.L i+(bufsize*1)
		DC.L i+(bufsize*2)
		DC.L i+(bufsize*3)
		DC.L i+(bufsize*4)
		DC.L i+(bufsize*5)
		DC.L i+(bufsize*6)
		DC.L i+(bufsize*7)
i		SET i+4
		ENDR

littleadd	DC.W 0
scr_point	DC.L text
which_buf	DC.L scbuffer
scx		DC.W 0
scrlpos		DC.W 0
inletswitch	DC.W 0

; Yes Ian you type your scrolltext here!

text		dc.b "                  HELLO IAN, HERE IS THE FUCKING INTRO YOU WANTED...   MUCH BETTER THAN THE ONE JOSE DID!!! 0123456789!ABCDEFGHIJKLMNOPQRSTUVWXYZ   AND LOOP...           "
		dc.b 0
		EVEN

dist_ang	DC.W 0
dist_step	DC.W 8
maxi_dist	DC.W 1024
size		DC.W 0
dister		DC.W 0
wave_ptr	DC.L wave_tab
wave_tab	DC.W 8,1024,40
		DC.W 64,4096,8
		DC.W 64,4096,6
		DC.W 64,4096,8
		DC.W 64,8192,16
		DC.W 8,1024,16
		DC.W 8,1024,32
		DC.W 16,1024,32
		DC.W 16,1024,40
		DC.W -1

dist_tab	DCB.W no_lines+2,72


trig_tab	dc.w	$0000,$FF37,$FE6E,$FDA5,$FCDC,$FC13,$FB4A,$FA82 
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

vwaveptr	DS.W 1
testvwave	INCBIN awesome.inc\vwavesin.dat

; Audio Sculpture Replay Routine - Soundchip only with full voluming.
; This Version uses no registers at all!! Allows upto 19 Khz Replay!!!
; Re-coded from the Original source by Griff of Inner Circle in July 1991.

		opt o-
	
Amplitudes	ds.l 8
__sq_ptr	equ $3b8 $1d8
__ptrn_ptr	equ $43c $258
__DEF_SPEED	equ 6

__BUF_LEN	equ 2048	;2048 for internal sound at the moment...

pref_volume	dc.b 1
		even

* Interrupt generation

GenIrqFrq	st GenIrq_flg
		move.l #player,ASreplayIrqPtr
		jsr gen_frq
		jsr i_voltab
		sf GenIrq_flg
initsoundchip:	LEA $ffff8800.w,a0
		MOVE.B #7,(a0)		; turn on sound
		MOVE.B #$c0,d0
		AND.B (a0),d0
		OR.B #$38,d0
		MOVE.B d0,2(a0)
		MOVE.W #$0500,d0	;
.initslp	MOVEP.W d0,(a0)
		SUB.W #$0100,d0
		BPL.S .initslp
		rts

* Pointers to cmd strings used while generating the different IRQs
	
ASreplayIrqPtr	dc.l 0
ASreplayOutput	dc.w __OUTPUT

* The sequencer initialisation

ASreplayInit	move.l a_data_ptr(pc),a0
	add #__sq_ptr,a0
	move.b -2(a0),a_maxpart+1
	
	moveq #127,d0
	moveq #0,d1
.i1	move.l d1,d2
	subq #1,d0
	bmi.s .mend
.i2	move.b (a0)+,d1
	cmp.b d2,d1
	bgt.s .i1
	dbf d0,.i2
	
.mend	move.b d2,a_maxptrn
	addq.b #1,d2
	move.l a_data_ptr(pc),a0
	lea a_sample2(pc),a1
	moveq #10,d1
	lsl.l d1,d2
	add.l #__ptrn_ptr,d2
	add.l a0,d2
	move.l d2,d5
	moveq #30,d7
	moveq #0,d0
.i4	move.l d2,a2
	move.l a2,(a1)+
	moveq #0,d1
	move 42(a0),d1
	asl.l d1
	add.l d1,d2
	add #30,a0
	dbra d7,.i4 
	move.l d2,(a1)

.i5	lea a_sample2-4(pc),a6
	moveq #30,d7
	move.l a1,a0
	lea frequency_lst,a3
	move.l a3,a4
	move.l a0,a5
.i6	move.l (a0),a1
	move.l -(a0),a2
	moveq #31,d1
	moveq #0,d6
.i7	rept 8
	move.l d6,-(a3)
	endr
	dbra d1,.i7
	bra .incopy
	
.copy	move -(a1),-(a3)
.incopy	cmp.l a1,a2
	blt .copy
	clr.l (a3)

	move.l a3,-(a6)
 	subq #1,d7
	bpl .i6

	move.l #$80808080,d0
.i8b	eor.l d0,(a3)+
	cmp.l a4,a3
	blt .i8b
	move.l #$08000000,$ffff8888.w
	move.l #$09000000,$ffff8888.w
	move.l #$0a000000,$ffff8888.w
	clr.l a_partnrplay
	clr a_partnote
	move.l a_data_ptr(pc),a0
	move.b __sq_ptr-2(a0),a_maxpart+1
	move.b __sq_ptr-1(a0),e_crpres+1

a_rept_i	move.l a_data_ptr(pc),a0
	add #42,a0
	lea a_sample1(pc),a1
	lea a_repeat1(pc),a6
	moveq #30,d0
.l0	cmp #1,6(a0)
	beq.s .set80
	move.l (a1),a2		Start
	move.l a2,a5		
	add (a0),a2
	add (a0),a2
	move.l a2,d5		Real end
	add.l #1024,d5
	lea (a2),a3
	add 4(a0),a5		
	add 4(a0),a5
	move.l a5,d4		Repeat Start
	move.l a5,(a6)+
	bra .c2

.l2	move (a5)+,(a2)+
	cmp.l a3,a5
	blt .v0
.c2	move.l d4,a5
.v0	cmp.l d5,a2
	blt .l2	
	bra .c0

.set80	move.l (a1),a2
	add (a0),a2
	add (a0),a2
	move.l a2,(a6)+
	moveq #31,d1
	move.l #$80808080,d2
.l1	rept 8
	move.l d2,(a2)+
	endr
	dbra d1,.l1
.c0	lea 30(a0),a0
	lea 4(a1),a1
	dbra d0,.l0
	rts

* The sequencer routines...

ASreplay	addq #1,a_counter
	addq #1,a_arp_cnt
	addq #1,a_time
	move a_speed(pc),d0
	cmp a_counter(pc),d0
	bls a_seq
	
	tst a_delay_time
	bne a_plutt
	
	move a_speed(pc),d0
	lsr #1,d0
	cmp a_counter(pc),d0
	bne.s a_plutt
	
	tst.b a_break_flg
	beq.s .no_break
	
.xuxx	sf a_break_flg
	clr a_partnote
	bra.s .higher
	
.no_break	move a_nxt_partnote(pc),d0
	bmi.s .norm
	
	move d0,a_partnote
	move #-1,a_nxt_partnote
	bra.s .stop
	
.norm	add #16,a_partnote	Spara gammal adr o ny adr...
	and #$3f0,a_partnote
	bne.s .stop
	
.higher	addq #1,a_partnrplay+2
	move a_nxtpart(pc),d0
	bmi .no_posjmp
	
	move d0,a_partnrplay+2
	move #-1,a_nxtpart
	
.no_posjmp	move.l a_partnrplay(pc),d0
	cmp a_maxpart(pc),d0
	blt.s .stop
	
	move e_crpres(pc),a_partnrplay+2
	
.stop	move.l a_data_ptr(pc),a0
	lea __sq_ptr(a0),a1

a_plutt	lea audio0(pc),a5
	lea a_aud1temp(pc),a6
	moveq #3,d5
.l0	move #$fff,d0
	and r_command(a6),d0
	beq.s .c0
	moveq #15,d0
	and.b r_command(a6),d0
	add d0,d0
	lea a_chkcom_lst(pc),a0
	add (a0,d0),a0
	jsr (a0)
.c0	lea audio1-audio0(a5),a5
	lea a_aud2temp-a_aud1temp(a6),a6
	dbra d5,.l0
	rts

a_chkcom_lst	
za	set a_chkcom_lst
	dc a_arp-za,a_portup-za,a_portdown-za,a_myport-za,a_vib-za
	dc a_toneovol-za
	dc a_vibovol-za
	dc a_tremolo-za
	rept 2
	dc a_null-za
	endr
	dc a_volslide-za
	rept 3
	dc a_null-za
	endr
	dc a_b_parser-za,a_null-za
	dc a_set_speed-za
	
a_b_parser	move #$f0,d0
	moveq #15,d1
	move.b r_cmd_param(a6),d2
	and d2,d0
	lsr #3,d0
	and d2,d1
	lea .lst(pc),a1
	add (a1,d0),a1
	jmp (a1)
.lst	
za	set .lst
	rept 9
	dc a_null-za
	endr
	dc a_retrigg-za
	rept 2
	dc a_null-za
	endr
	dc a_notecut-za,a_notedelay-za,a_null-za,a_null-za

a_set_speed	tst.b r_cmd_param(a6)
	beq .nope
	move.b r_cmd_param(a6),a_arp_speed
.nope	rts

a_arp	move (a6),d0
	and #$3ff,d0
	beq.s .old
	clr a_arp_cnt
.old	moveq #0,d0
	move a_arp_cnt(pc),d0
	moveq #0,d1
	move.b a_arp_speed(pc),d1
	divu d1,d0
	and.l #$ffff,d0
	divu #3,d0
	swap d0
	tst.b d0
	beq.s .l2
	cmp.b #2,d0
	beq.s .l1
	moveq #0,d0
	move.b r_cmd_param(a6),d0
	lsr.b #4,d0
	bra.s .l3
.l1	moveq #15,d0
	and.b r_cmd_param(a6),d0
.l3	move r_period(a6),d1
	move.l period_to_note_ptr,a1
	moveq #0,d2
	move.b (a1,d1),d2
	add d0,d2
	add d2,d2
	move a_arpeggio(pc,d2),d2
	beq.s .l2
	move d2,AudPeriod(a5)
	move d2,AudPeriodSet(a5)
	rts
.l2	move r_period(a6),d2
	move d2,AudPeriod(a5)
	move d2,AudPeriodSet(a5)
	rts

	dc $358,$358
a_arpeggio	dc $0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc $023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc $0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc $00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc $008f,$0087,$007f,$0078,$0071,0
	dcb 16,0

a_setmyport	move (a6),d1		Fetch dest period
	and #$3ff,d1
	beq.s a_myport		No per=port
	move d1,r_destination(a6)	24(a6)=dest per
	move r_period(a6),d0	Curr per
	clr.b r_porta_dir(a6)		Clr dir
	cmp d0,d1		
	beq.s .clrport		Same per
	bge.s .rt
	move.b #1,r_porta_dir(a6)	Set dir
	rts
.clrport	clr r_destination(a6)	Clr port
.rt	rts

a_myport	move.b r_cmd_param(a6),d0		CHK for speed!
	beq.s a_myslide
	move.b d0,r_my_speed(a6)	23(a6)=speed
	clr.b r_cmd_param(a6)	No over-selection...
a_myslide	tst r_destination(a6)		destPeriod present?
	beq.s .rts
	moveq #0,d0
	move.b r_my_speed(a6),d0	Fetch speed!
	tst.b r_porta_dir(a6)	Select direction!
	bne.s .mysub
	add d0,r_period(a6)	Increment period!
	move r_destination(a6),d0	Fetch dest period
	cmp r_period(a6),d0	Target reached?
	bgt.s .myok
	move r_destination(a6),r_period(a6)	Set target...
	clr r_destination(a6)		No more portamento...
.myok	move r_period(a6),AudPeriod(a5)	Set period
	move r_period(a6),AudPeriodSet(a5)
	rts
	
.mysub	sub d0,r_period(a6)	Decrement period
	move r_destination(a6),d0		Fetch dest period
	cmp r_period(a6),d0	Target reached?
	blt.s .myok
	move r_destination(a6),r_period(a6)	Set target
	clr r_destination(a6)		No more port
	move r_period(a6),AudPeriod(a5)	Set period
	move r_period(a6),AudPeriodSet(a5)
.rts	rts


a_toneovol	bsr a_myslide
	bra a_voldown

a_vibovol	bsr a_viyy
	bra a_voldown
	
a_vib	move.b r_cmd_param(a6),d0
	beq.s a_viyy
	move.b d0,r_vib_dta(a6)
a_viyy	moveq #0,d1
	move.b r_vibrato(a6),d0
	beq .sine
	cmp.b #1,d0
	bne.s .pulse
	move.b r_vib_cnt(a6),d1
	bpl.s .set
	not.b d1
	bra.s .set
.pulse	not.b d1
	bra.s .set
.sine	moveq #$1f*4,d0
	and.b r_vib_cnt(a6),d0
	lsr #2,d0
	lea a_sin(pc),a1
	move.b (a1,d0),d1
.set	moveq #15,d0
	and.b r_vib_dta(a6),d0
	mulu d0,d1
	lsr #6,d1
	move r_period(a6),d0
	tst.b r_vib_cnt(a6)
	bmi.s .vibmin
	add d1,d0
	bra.s .vib2
.vibmin	sub d1,d0
.vib2	move d0,AudPeriod(a5)
	move d0,AudPeriodSet(a5)
	moveq #-16,d0
	and.b r_vib_dta(a6),d0
	lsr.b #2,d0
	add.b d0,r_vib_cnt(a6)
.vi	rts

a_tremolo	move.b r_cmd_param(a6),d0
	beq.s .old
	move.b d0,r_treold(a6)
.old	moveq #0,d1
	move.b r_tremolo(a6),d0
	beq.s .sine
	cmp.b #1,d0
	bne.s .pulse
	move.b r_trepos(a6),d1
	bpl.s .set
	not.b d1
	bra.s .set
.pulse	not.b d1
	bra.s .set
.sine	moveq #$1f*4,d0
	and.b r_trepos(a6),d0
	lsr #2,d0
	lea a_sin(pc),a1
	move.b (a1,d0),d1
.set	moveq #15,d0
	and.b r_treold(a6),d0
	mulu d0,d1
	lsr #6,d1
	move.b r_volume(a6),d0
	tst.b r_trepos(a6)
	bmi.s .vibmin
	add d1,d0
	bra.s .vib2
.vibmin	sub d1,d0
.vib2	bpl.s .ko0
	moveq #0,d0
	bra.s .go
.ko0	cmp #64,d0
	ble.s .go
	moveq #64,d0
.go	move.b d0,r_volume(a6)
	move.b d0,AudVolume(a5)
	moveq #-16,d0
	and.b r_treold(a6),d0
	lsr.b #2,d0
	add.b d0,r_trepos(a6)
.vi	rts
	
a_volslide	move.b r_cmd_param(a6),d0
	bne.s .nu
	move.b r_oldvolsld(a6),d0
.nu	move.b d0,r_oldvolsld(a6)
	and.b #$f0,d0
	beq.s a_voldown
	lsr.b #4,d0
	add.b d0,r_volume(a6)
	cmp.b #64,r_volume(a6)
	bmi.s a_vol3
	move.b #64,r_volume(a6)
	move.b r_volume(a6),AudVolume(a5)
a_null	rts

a_voldown	moveq #15,d0
	and.b r_cmd_param(a6),d0
	sub.b d0,r_volume(a6)
	bpl.s a_vol3
	clr.b r_volume(a6)
a_vol3	move.b r_volume(a6),AudVolume(a5)
	rts


a_fineportaup	move d1,d0
	bra.s a_portup_in
a_portup	moveq #0,d0
	move.b r_cmd_param(a6),d0
a_portup_in	beq.s .c0
	move.b d0,r_porta_speed(a6)
.c0	move.b r_porta_speed(a6),d0
	sub d0,r_period(a6)
	move r_period(a6),d0
	cmp #$71,d0
	bge.s .por2
	moveq #$71,d0
	and #$f000,r_command(a6)
.por2	move d0,AudPeriod(a5)
	move d0,r_period(a6)
	move d0,AudPeriodSet(a5)
	rts
	
a_fineportadown	move d1,d0
	bra.s a_portdown_in
a_portdown	moveq #0,d0
	move.b r_cmd_param(a6),d0
a_portdown_in	beq.s .c0
	move.b d0,r_porta_speed(a6)
.c0	move.b r_porta_speed(a6),d0
	add d0,r_period(a6)
	move r_period(a6),d0
	cmp #$358,d0
	ble.s .por3
	move #$358,d0
	clr.b r_porta_speed(a6)
	and #$f000,r_command(a6)
.por3	move d0,AudPeriod(a5)
	move d0,r_period(a6)
	move d0,AudPeriodSet(a5)
	rts
	
* The actual sequencer routine

a_seq	clr a_time
	tst a_delay_time
	beq.s .goforit
	
	subq #1,a_delay_time
	bra.s .x
	
.goforit	move.l a_data_ptr(pc),a0
	lea 12(a0),a3
	lea __sq_ptr(a0),a1
	move a_partnrplay+2(pc),d0
	moveq #0,d1
	move.b (a1,d0),d1
	
	lsl.l #8,d1
	lsl.l #2,d1
	lea __ptrn_ptr(a0),a0
	add a_partnote(pc),a0
	add.l d1,a0

	lea audio0(pc),a5
	lea a_aud1temp(pc),a6
	moveq #3,d5
.l0	bsr.s a_playit
.gah	lea audio1-audio0(a5),a5
	lea a_aud2temp-a_aud1temp(a6),a6
	lea 4(a0),a0
	dbra d5,.l0
	
.x	clr a_counter
	rts
   
* The real sequencer routine...
   
a_playit	move.l (a0),(a6)
	move #$ff0,d2
	and r_command(a6),d2
	cmp #$ed0,d2
	beq a_null
	
a_playshit	and #$f00,d2
	cmp #$300,d2
	beq .no_new_sample
	
	move.b r_command(a6),d2
	and #$f0,d2		Lownibble
	lsr #4,d2
	moveq #16,d0
	and.b (a6),d0
	or d0,d2
	beq.s .nosamplechange
	
	move.b d2,AudLastInstr(a5)
	move d2,AudInstr(a5)
	add d2,d2
	move d2,d0
	add d2,d2		d2=INSTR*4
	move d0,d1
	lsl #4,d0
	sub d1,d0
	lea a_repeats(pc),a1
	move.l (a1,d2),r_restart(a6)	RESTART
	lea a_samples(pc),a1
	move.l (a1,d2),d1
	move.l d1,r_start_ptr(a6)	START
	moveq #0,d2
	move (a3,d0),d2		LEN
	add.l d2,d2
	add.l d2,d1		START+LEN=
	move.l d1,r_end_ptr(a6)	END
	move.b 3(a3,d0),d0
	move.b d0,r_volume(a6)	Volume
	move.b d0,AudVolume(a5)
	
.nosamplechange	move (a6),d0		Period
	and #$3ff,d0
	beq.s .no_new_sample
	
	move d0,r_period(a6)
	move d0,AudPeriod(a5)	FRQ - Float
	move d0,AudPeriodSet(a5)	FRQ - Fix
	move d0,AudPeriodMidi(a5)	FRQ - Midi
	move.l r_start_ptr(a6),(a5)	START
	move.l r_end_ptr(a6),AudEnd(a5)	END
	move.l r_restart(a6),AudRestart(a5)
	
.no_new_sample	move r_command(a6),d0
	and #$fff,d0
	beq a_null
	
	lsr #7,d0
	and #$1e,d0
	lea a_com_lst(pc),a1
	add (a1,d0),a1
	jmp (a1)

a_com_lst	
za	set a_com_lst
	dc a_arp-za,a_portup-za,a_portdown-za,a_setmyport-za,a_vib-za
	dc a_toneovol-za
	dc a_vibovol-za
	dc a_tremolo-za
	dc a_phase2-za
	dc a_phase-za
	dc a_volslide-za,a_posjmp-za,a_setvol-za
	dc a_break-za,a_e_parser-za,a_setspeed-za
	
a_e_parser	move #$f0,d0
	moveq #15,d1
	move.b r_cmd_param(a6),d2
	and d2,d0
	lsr #3,d0
	and d2,d1
	lea .lst(pc),a1
	add (a1,d0),a1
	jmp (a1)
.lst	
za	set .lst
	dc a_filter-za,a_fineportaup-za,a_fineportadown-za
	dc a_setglissctrl-za,a_setvibratoctrl-za,a_setfinetune-za
	dc a_dbf-za,a_settremoloctrl-za,a_stoppus-za
	dc a_retrigg-za,a_volfineup-za,a_volfinedown-za
	dc a_notecut-za,a_notedelay-za,a_ptrndelay-za,a_funkit-za
	
a_setglissctrl	and #1,d1
	move.b d1,r_glissando(a6)
	rts

a_setvibratoctrl
	and #3,d1
	move.b d1,r_vibrato(a6)
	rts

a_setfinetune	move.b d1,r_finetune(a6)
	rts

a_settremoloctrl
	and #3,d1
	move.b d1,r_tremolo(a6)
	rts

a_retrigg	beq.s .fex		!
	moveq #0,d0
	move a_time(pc),d0
	beq.s .fex
	divu d1,d0
	swap d0
	tst d0
	bne.s .x
.fex	move.l r_start_ptr(a6),(a5)	START
	move.l r_end_ptr(a6),AudEnd(a5)	END
	move.l r_restart(a6),AudRestart(a5)
.x	rts

a_volfineup	beq.s .nu
	move.b d1,r_oldvolsld(a6)	!
.nu	move.b r_oldvolsld(a6),d1
	add.b d1,r_volume(a6)
	cmp.b #$40,r_volume(a6)
	bls.s .x
	move.b #$40,r_volume(a6)
.x	move.b r_volume(a6),AudVolume(a5)
	rts

a_volfinedown	beq.s .nu		!
	move.b d1,r_oldvolsld(a6)
.nu	move.b r_oldvolsld(a6),d1
	sub.b d1,r_volume(a6)
	bpl.s .x
	clr.b r_volume(a6)
.x	move.b r_volume(a6),AudVolume(a5)
	rts

a_notecut	beq.s .nu
	move.b d1,r_oldnotecut(a6)
.nu	move.b r_oldnotecut(a6),d1
	cmp a_time(pc),d1	!
	bne.s .x
	clr.b r_volume(a6)
	move.b r_volume(a6),AudVolume(a5)
.x	rts

a_notedelay	beq.s .nu
	move.b d1,r_oldnotedel(a6)
.nu	move.b r_oldnotedel(a6),d1
	cmp a_time(pc),d1
	bne.s .x
	and #$f000,r_command(a6)
	move.l a_data_ptr,a3
	lea 12(a3),a3
	bsr a_playshit
	clr.l (a6)
.x	rts

a_ptrndelay	beq.s .nu
	move.b d1,r_oldptrndel(a6)
.nu	move.b r_oldptrndel(a6),d1
	tst a_delay_time
	bne.s .x
	move d1,a_delay_time
.x	rts

a_funkit	rts

a_dbf	bne.s .running
	move a_partnote(pc),r_ptrnpos(a6)
	rts
.running	tst.b r_dbfcnt(a6)
	bne.s .noset
	move.b d1,r_dbfcnt(a6)
	bra.s .go
.noset	subq.b #1,r_dbfcnt(a6)
	beq.s .x
.go	move r_ptrnpos(a6),a_nxt_partnote
.x	rts
	
a_stoppus	cmp.b #$e,d1
	beq.s .stoppus
	move.b #$dd,a_fake_flg
	st a_break_flg
	rts
.stoppus	clr a_partnote
	move #31,a_counter
	
	addq #1,a_partnrplay+2
	move.l a_data_ptr,a0
	lea __sq_ptr(a0),a1

	rts

a_phase	moveq #0,d1
	move.b r_cmd_param(a6),d1
	beq.s .nostore
	
	move.b d1,r_phase(a6)
	
.nostore	move.b r_phase(a6),d1
	lsl.l #8,d1
	move.l r_end_ptr(a6),d0
	sub.l r_start_ptr(a6),d0
	cmp.l d1,d0
	blt.s .x
	
	tst.l (a5)
	beq .x
	add.l d1,r_start_ptr(a6)
	add.l d1,(a5)
.x	rts

a_phase2	moveq #0,d1
	move.b r_cmd_param(a6),d1
	beq.s .nu
	move.b d1,r_phase2(a6)
.nu	move.b r_phase2(a6),d1
	tst.l (a5)
	beq.s .x
	add.l d1,(a5)
	rts
.x	add.l d1,AudPtr(a5)
	rts
	
a_posjmp	move.b r_cmd_param(a6),d0
	and #$7f,d0
	move d0,a_nxtpart
	st a_break_flg
	sf a_fake_flg
	rts

a_setvol	move.b r_cmd_param(a6),d0
	beq.s .vol0
	cmp.b #64,d0
	ble.s .vol4
	moveq #64,d0
.vol4	move.b d0,r_volume(a6)
	move.b d0,r_cmd_param(a6)
	move.b d0,AudVolume(a5)
	rts
	
.vol0	tst.b pref_volume
	bne.s .uargh
	lea null,a1
	move.l a1,AudEnd(a5)
	move.l a1,AudRestart(a5)
	move.l a1,AudEndTmp(a5)
	move.l a1,AudRestartTmp(a5)
.uargh	move.b d0,r_volume(a6)
	move.b d0,AudVolume(a5)
	rts

a_setspeed	moveq #0,d0
	move.b r_cmd_param(a6),d0
	cmp #31,d0
	ble.s .ok0
	moveq #31,d0
.ok0	cmp #2,d0
	bhs.s .ok1
	moveq #2,d0
.ok1	move.b d0,r_cmd_param(a6)
	move d0,a_speed
	clr a_counter
	rts

a_break	st a_break_flg
	clr.b a_fake_flg
	rts

a_filter	move.b r_cmd_param(a6),r_filter(a6)
	rts

a_nxt_partnote	dc -1
a_delay_time	dc 0
a_arp_cnt	dc 0
a_arp_speed	dc.b 1
a_fake_flg	dc.b 0
a_sin	dc.b $00,$18,$31,$4a,$61,$78,$8d,$a1,$b4,$c5,$d4,$e0,$eb,$f4,$fa,$fd
	dc.b $ff,$fd,$fa,$f4,$eb,$e0,$d4,$c5,$b4,$a1,$8d,$78,$61,$4a,$31,$18
	
	rsreset
B„„„„„„„„„h	rs 1	0
r_command	rs.b 1	2
r_cmd_param	rs.b 1	3
r_start_ptr	rs.l 1	4
r_end_ptr	rs.l 1	8
r_restart	rs.l 1	12
r_period	rs 1	16
r_volume	rs 1	18
r_chn_switch	rs.b 1	20
r_filter	rs.b 1	21
r_porta_dir	rs.b 1	22
r_my_speed	rs.b 1	23
r_destination	rs 1	24
r_vib_dta	rs.b 1	26
r_vib_cnt	rs.b 1	27
r_porta_speed	rs.b 1	28
r_dbfcnt	rs.b 1	29
r_ptrnpos	rs 1	30
r_phase	rs.b 1	32
r_phase2	rs.b 1
r_oldvolsld	rs.b 1
r_oldnotecut	rs.b 1
r_oldnotedel	rs.b 1
r_oldptrndel	rs.b 1
r_finetune	rs.b 1
r_tremolo	rs.b 1
r_glissando	rs.b 1
r_vibrato	rs.b 1
r_treold	rs.b 1
r_trepos	rs.b 1

a_aud1temp	dc.l 0	0  Current cmd/note
	dc.l 0	4  Start
	dc.l null	8  End
	dc.l null	12 Restart
	dc 0	16 Period
	dc.b 0,0	18 Volym,0
	dc.b 1	20 Channel ON/OFF
	dc.b 0	21 Filter
	dc.b 0	22 #3
	dc.b 0	23 #3
	dc 0	24 #3
	dc.b 0	26 #4
	dc.b 0	27 #4
	dc.b 0	28 #1/#2
	dc.b 0
	dc 0
	ds.b 12
	
a_aud2temp	ds.l 2
	dc.l null,null
	ds 1
	ds.b 2
	ds.b 4
	ds 1
	ds.b 6
	ds.b 12
	
a_aud3temp	ds.l 2
	dc.l null,null
	ds 1
	ds.b 2
	ds.b 4
	ds 1
	ds.b 6
	ds.b 12
	
a_aud4temp	ds.l 2
	dc.l null,null
	ds 1
	ds.b 2
	ds.b 4
	ds 1
	ds.b 6
	ds.b 12
	
a_time	dc 0
a_speed	dc 0
a_partnrplay	dc.l 0
a_counter	dc 0
a_partnote	dc 0
a_samples	dc.l 0
a_sample1	ds.l 31
end_s_adr	dc.l frequency_lst
a_sample2	ds.l 32
a_repeats	dc.l 0
a_repeat1	ds.l 31
a_maxpart	dc 1
a_nxtpart	dc -1
a_break_flg	dc.b 0
a_maxptrn	dc.b 1
e_crpres	dc 0

	rsreset
AudStart	rs.l 1
AudPeriod	rs 1
AudVolume	rs 1
AudEnd	rs.l 1
AudRestart	rs.l 1
AudMute	rs.b 1
AudLastInstr	rs.b 1
AudEndTmp	rs.l 1
AudRestartTmp	rs.l 1
AudInstr	rs 1
AudPeriodSet	rs 1
AudPeriodMidi	rs 1
AudPeriod32	rs.l 1
AudVolumePtr	rs.l 1
AudPtr	rs 1
AudLoPtr	rs 1
AudPrecision	rs 1

audio0	dc.l null	0  start
	dc 0	4  period	SetPeriodFlagoPeriod f”r ASconvert
	dc 0	6  volume*256
	dc.l null	8  end
	dc.l null	12 restart
	dc.b 1	16 channel on/off
	dc.b 0	17 last instr
	dc.l null	18 endb
	dc.l null	22 restartb
	dc 0	26 instr
	dc 0	28 period	PeriodF”rFrekvensTabellsKrafs
	dc 0	30 period	PeriodF”rMidikravs
	dc.l 0	32 32-bit period
	dc.l 0	36 Volume Pointer
	dc 0	40 Current pointer for audio channel
	dc 0	42 Lower part of pointer for this voice
	dc 0	44 Precision for this channel
	
audio1	dc.l null
	ds 2
	dc.l null,null
	dc.b 1,0
	dc.l null,null
	dc 0,0,0
	ds.l 2
	ds 3
	
audio2	dc.l null
	ds 2
	dc.l null,null
	dc.b 1,0
	dc.l null,null
	dc 0,0,0
	ds.l 2
	ds 3
	
audio3	dc.l null
	ds 2
	dc.l null,null
	dc.b 1,0
	dc.l null,null
	dc 0,0,0
	ds.l 2
	ds 3

* Convert to data for replay buffer generation and interrupt!

ASconvert	lea audio0(pc),a0
	move.l a_frqtab_ptr,a1
	lea Amplitudes,a2
	
	moveq #3,d5
	
.l0	tst.b AudMute(a0)
	beq.s .c0
	
	moveq #0,d0
	move AudVolume(a0),d0
	add.l a_voltab_ptr(pc),d0
	move.l d0,AudVolumePtr(a0)
	
	move.l (a0),d0
	beq.s .c1
	clr.l (a0)
	move.l d0,AudPtr(a0)
	clr AudPrecision(a0)
	move.l AudEnd(a0),AudEndTmp(a0)
	move.l AudRestart(a0),AudRestartTmp(a0)
	
.c1	move AudPeriod(a0),d0
	beq.s .c0
	
	and #$3ff,d0
	add d0,d0
	add d0,d0
	move.l (a1,d0),AudPeriod32(a0)
	
.c0	move.l AudPtr(a0),a6
	move.b (a6),d2
	
	move.l AudPtr(a0),d1
	sub.l AudEndTmp(a0),d1	Sample End Passed?
	ble.s .c3
	
	move.l AudEndTmp(a0),d0	
	sub.l AudRestartTmp(a0),d0	A (EndSpl-ReptStart) = ReptLen!
	beq.s .c2		-> NoRepeat InstallNull
	
	divu d0,d1
	swap d1
	move.l AudRestartTmp(a0),a6
	add d1,a6
	cmp.l AudEndTmp(a0),a6
	bhi.s .c2
	move.l a6,AudPtr(a0)	B Mod A + ReptStart = New Reptstart
	bra.s .c3
	
.c2	move.l AudRestartTmp(a0),AudPtr(a0)
.c3	move.l AudPtr(a0),a3
	moveq #0,d0
	move.b (a3),d0
	tst.b pref_volume
	beq .noscaling
	move.l AudVolumePtr(a0),a5
	move.b (a5,d0),d0
.noscaling	tst.b d0
	bpl .ok
	not d0
.ok	and #$7f,d0
	move d0,(a2)+
	move AudPeriod(a0),(a2)+
	move.l a3,(a2)+
	lea audio1-audio0(a0),a0
	dbra d5,.l0
	rts

* Driver for the ring buffer in which the data is stored for the
* replay interrupt/audio dma read.

ASreplayDriver	
	move.l $110.w,a4
	sub.l #player,a4
	move.l a4,d2
	divu #12,d2
	add.l #ste_buf,d2
	cmp.l #end_ste_buf,d2
	bne.s .go
	move.l #ste_buf,d2
.go	move.l d2,d3
	sub.l ste_buf_ptr(pc),d3
	
	cmp.l #__BUF_LEN,d3
	blo .hit
	beq .wrap
	
	move.l ste_buf_ptr(pc),last_wrt

.wrap	move.l ste_buf_ptr(pc),d2

.hit	move.l d2,d4
	move.l last_wrt(pc),a0
	sub.l a0,d2
	bpl .onepartonly
	
	move.l d4,-(a7)
	
	move.l ste_buf_ptr(pc),d4
	add.l #__BUF_LEN,d4
	bsr ste_cnt
	
	move.l (a7)+,d4
	
	move.l ste_buf_ptr(pc),a0
.onepartonly	bsr ste_cnt
	move.l a0,last_wrt
.x	rts

* Volume control and floating frequency for interrupt driven sound!

ste_cnt	sub.l a0,d4
	lsr.w #1,d4
	subq #1,d4
	bmi .ok3
	movem.l d4/a0,-(a7)
w	set audio2-audio0
	lea audio0(pc),a3
	move.l AudPeriod32(a3),a1	; Voice 1
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	move.l w+AudPeriod32(a3),a2	; Voice 2
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6
	move.l a1,d5
	swap d5
	move.l d5,a1	
	move.l a2,d5
	swap d5
	move.l d5,a2
	swap d0
	swap d1
	moveq #0,d5
.l0	moveq #0,d6		4
	add.l a1,d0		8
	addx d6,d0
	add.l a2,d1		8
	addx d6,d1
	move.b (a5,d0),d2	16
	move.l d2,a3		4
	move.b (a3),d6		8
	move.b (a6,d1),d3	16
	move.l d3,a3		4
	move.b (a3),d5		8
	add d5,d6		4
	move d6,(a0)+		8
	dbra d4,.l0		12 / 116
	swap d0
	swap d1
	lea audio0(pc),a3
	add.l d0,AudLoPtr(a3)
	bcc.s .ok0
	addq #1,AudPtr(a3)
.ok0	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok1
	addq #1,w+AudPtr(a3)
.ok1	movem.l (a7)+,d4/a0
	lea audio1-audio0(a3),a3
	move.l AudPeriod32(a3),a1	; Voice 2
	move.l AudVolumePtr(a3),d2
	moveq #0,d0
	move AudPrecision(a3),d0
	move.l AudPtr(a3),a5
	move.l w+AudPeriod32(a3),a2	; Voice 3
	move.l w+AudVolumePtr(a3),d3
	moveq #0,d1
	move w+AudPrecision(a3),d1
	move.l w+AudPtr(a3),a6
	move.l a1,d5
	swap d5
	move.l d5,a1	
	move.l a2,d5
	swap d5
	move.l d5,a2
	swap d0
	swap d1

	move.l A0,D5
	sub.l #ste_buf,D5
	mulu #12,D5
	lea player+4,A4
	add.l D5,A4

	moveq #0,d5
.l1	moveq #0,d6		
	add.l a1,d0		
	addx d6,d0
 	add.l a2,d1		
	addx d6,d1
	move.b (a5,d0),d2	
	move.l d2,a3		
	move.b (a3),d6		
	move.b (a6,d1),d3	
	move.l d3,a3		
	move.b (a3),d5		
	add d5,d6		
	add (a0)+,d6		
	add.w D6,D6		
	move.w cliptab(PC,D6),d6
	move.w d6,(A4)		
	move.b d6,8(A4)		
	lea 24(a4),a4
	dbra d4,.l1		
	swap d0
	swap d1
	lea audio1(pc),a3
	add.l d0,AudLoPtr(a3)
	bcc.s .ok2
	addq #1,AudPtr(a3)
.ok2	add.l d1,w+AudLoPtr(a3)
	bcc.s .ok3
	addq #1,w+AudPtr(a3)
.ok3	rts
		
digi2	MACRO
	dc.b	(($\1>>8)&15),(($\1>>4)&15)
	dc.b	(($\2>>8)&15),(($\2>>4)&15)
	dc.b	(($\3>>8)&15),(($\3>>4)&15)
	dc.b	(($\4>>8)&15),(($\4>>4)&15)
	dc.b	(($\5>>8)&15),(($\5>>4)&15)
	dc.b	(($\6>>8)&15),(($\6>>4)&15)
	dc.b	(($\7>>8)&15),(($\7>>4)&15)
	dc.b	(($\8>>8)&15),(($\8>>4)&15)
	ENDM

cliptab	dcb.w	$180,0		* bottom clip area
conv2	digi2	000,000,200,300,400,500,510,600
	digi2	600,620,700,720,730,800,800,820
	digi2	830,900,910,920,930,940,950,951
	digi2	A00,A20,A30,A40,A50,A50,A52,A60
	digi2	A62,A70,A71,B00,B10,B30,B40,B40
	digi2	B50,B52,B60,B61,B70,B71,B72,B73
	digi2	B80,B81,B83,B84,B90,C00,C20,C30
	digi2	C40,C50,C51,C52,C60,C62,C70,C72
	digi2	C73,C80,C80,C82,C83,C90,C90,C92
	digi2	c93,c94,c95,c95,ca0,d00,d20,d30
	digi2	d40,d50,d50,d52,d60,d62,d70,d71
	digi2	d73,d74,d80,d82,d83,d90,d90,d92
	digi2	d93,d94,d95,d95,da0,da1,da3,da4
	digi2	da4,da5,da5,da6,da6,da7,da7,db0
	digi2	db1,db2,db3,db4,db5,db5,db6,e00
	digi2	e10,e30,e40,e41,e50,e52,e60,e61
	digi2	e70,e71,e73,e74,e80,e81,e83,e84
	digi2	e90,e92,e93,e94,e95,e95,ea0,ea1
	digi2	ea3,ea4,ea4,ea5,ea5,ea6,ea6,ea7
	digi2	ea7,ea7,eb0,eb2,eb3,eb4,eb5,eb5
	digi2	eb5,eb6,eb6,eb7,eb7,eb7,eb8,eb8
	digi2	eb8,eb8,eb9,ec0,ec1,ec3,ec4,ec4
	digi2	ec5,f00,f10,f30,f40,f41,f50,f52
	digi2	f60,f61,f70,f71,f73,f74,f80,f82
	digi2	f83,f84,f90,f92,f93,f94,f95,f95
	digi2	fa0,fa1,fa3,fa4,fa4,fa5,fa5,fa6
	digi2	fa6,fa7,fa7,fb0,fb0,fb2,fb3,fb4
	digi2	fb5,fb5,fb6,fb6,fb6,fb7,fb7,fb7
	digi2	fb8,fb8,fb8,fb8,fb9,fc0,fc1,fc3
	digi2	fc4,fc4,fc5,fc5,fc6,fc6,fc7,fc7
	digi2	fc7,fc7,fc8,fc8,fc8,fc8,fc9,fc9
	digi2	fc9,fc9,fc9,fc9,fca,fd0,fd1,fd3
	REPT	32			* top clip area
	digi2	fd3,fd3,fd3,fd3,fd3,fd3,fd3,fd3
	ENDR

MakePeriods	move.l period_to_note_ptr,a0
		add #$400,a0
		lea a_arpeggio,a1
		move #1023,d0
		moveq #0,d2
.l0		cmp (a1),d0
		bge .c0
		lea 2(a1),a1
		cmp #$23,d2
		beq .c0
		addq #1,d2
.c0		move.b d2,-(a0)
		dbra d0,.l0
		rts

* Generate frequency table

gen_frq	moveq #ASreplayIrqFrq,d5
	cmp #8,ASreplayOutput
	blt .noste
	moveq #49,d5
.noste	mulu #tune,d5
	move.l a_frqtab_ptr,a0
	addq #4,a0
	moveq #1,d0
.ml1	moveq #0,d2
	move d0,d2
	lsl.l #4,d2
	move.l d5,d3
	divu d2,d3
	move d3,(a0)+
	clr d3
	divu d2,d3
	move d3,(a0)+
	addq #1,d0
	cmp #1024,d0
	blt .ml1
	ifne __OUTPUT>8
	jsr GenFrequency
	endc
.x	rts

	
* Generate various tables for the replay routs

Gurkorna	move.l null_ptr,a0
		moveq #31,d0
		move.l #$80808080,d1
.l7		rept 8
		move.l d1,(a0)+
		endr
		dbra d0,.l7
		rts

* Initialize the 65*256 byte velocity conversion tables

i_voltab	move.l a_voltab_ptr(pc),a0
		moveq #0,d0
.l0		move.l d0,d1
		lsl.l #8,d1
		move #255,d2
		moveq #0,d3
		move #$80,d3
		move d0,d4
		lsr #1,d4
		sub d4,d3
.l1		move.b d3,(a0)+
		swap d3
		add.l d1,d3
		swap d3
		dbra d2,.l1
		addq #4,d0
		cmp #257,d0
		blt .l0
		rts

* The actual initialization of the replay routines

ASreplayInstall	lea a_voltab,a0
		add #255,a0
		move.l a0,d0
		and #$ff00,d0
		move.l d0,a_voltab_ptr
		lea end_s_adr(pc),a0
		move.l (a0),a1
		moveq #30,d0
.l0		sub #$400,a1
		move.l a1,-(a0)
		dbra d0,.l0
		ifne __OUTPUT>7
		move.l ste_buf_ptr,a0
		move #1023,d0
		ifne __OUTPUT>7
		move.l #$80808080,d1
		elseif
		move.l #$02000200,d1
		endc
.l1		move.l d1,(a0)+
		dbra d0,.l1
		endc
		bsr GenIrqFrq
		bsr Gurkorna
		bsr MakePeriods
		bsr i_voltab
		bsr makequickplay
		bsr ASreplayInit
		bsr gen_frq
	
a		set 0
		rept __BUF_LEN/1024	PreGenerateBuffer - The first buffer
		move.l ste_buf_ptr,a0	
		add #1024*a,a0
		move.l a0,d4
		add.l #1024,d4
		jsr ste_cnt
		move.l a0,last_wrt
		jsr ASconvert
a		set a+1
		endr
		move.l ste_buf_ptr,last_wrt

		move.l null_ptr,a0
		move.l a0,audio0
		move.l a0,audio1
		move.l a0,audio2
		move.l a0,audio3
		lea audio0,a1
		lea a_aud1temp,a2
		moveq #3,d0
.l2		move.l a0,(a1)
		move.l a0,AudStart(a1)
		move.l a0,AudRestart(a1)
		move.l a0,AudEnd(a1)
		move.l a0,AudRestartTmp(a1)
		move.l a0,AudEndTmp(a1)
		move.l a0,r_end_ptr(a2)
		move.l a0,r_restart(a2)
		lea audio1-audio0(a1),a1
		lea a_aud2temp-a_aud1temp(a2),a2
		dbra d0,.l2
		rts

; YM2149 Soundchip - Create the Quick play buffer.

makequickplay	lea player,a0
		move.l a0,a1
		movem.l playonesam(pc),d0-d5
		move #$400-2,d7
.make_lp	lea 24(a0),a0
		move.w a0,d4
		movem.l d0-d5,-24(a0)
		dbf d7,.make_lp
		move.w a1,d4
		movem.l d0-d5,(a0)
		rts

playonesam	move.l #$08000000,$ffff8800.w		; 8 bytes
		move.l #$09000000,$ffff8800.w		; 8 bytes
		move.w #2,$112.w			; 6 bytes
		rte					; 2 bytes

* Misc Params

GenIrq_flg	dc 0
ste_buf_ptr	dc.l ste_buf		;Pointer to the buffer which is in internal mode no more than 16384 bytes in front of the instruction reading it...
a_voltab_ptr	dc.l 0			;Pointer to the 256-byte boundary aligned volume tables

last_wrt	dc.l ste_buf		;Pointer to the last updated address in the circular output buffer
a_data_ptr	dc.l a_data		;Pointer to the bottom of the current module in memory
a_eof_ptr	dc.l a_eof		;Pointer to the top of the module
a_frqtab_ptr	dc.l a_frqtab
period_to_note_ptr
		dc.l period_to_note
null_ptr	dc.l null

		section data

; The Font is included here!
fontbuf		INCBIN awesome.inc\twstfn32.dat
		EVEN
; The Piccy is included here!
piccy		INCBIN awesome.inc\piccy.pi1
		EVEN
; The Module is included here!
a_data		INCBIN MODULES\ROCKIT.MOD
		EVEN
a_eof

__N_SAMPLES	equ 31

		section bss
	
		ds.l 256*__N_SAMPLES
frequency_lst	ds.l 38
ste_buf		ds.l __BUF_LEN/4
end_ste_buf	ds.w 32

		cnop 0,4

a_voltab	ds.w 128
		ds.l 4224
		ds.w 128
	
null		ds.w 512			1024	;Null sample where all pointers are while playing nothing
period_to_note	ds.l 256			1024	;Conversion table from Amiga period to Absolute note number
a_frqtab	ds.l 1024			4096	;Conversion table from Amiga Period to Audio Sculpture Fixed Point Interval

		DS.W 8
scbuffer	REPT 8
		DS.B bufsize			; scroll buffer
		ENDR
		DS.W 8

		DS.L 179
stack		DS.L 3				; stack space

screens		DS.B 256
		DS.B 44800			; screen space
