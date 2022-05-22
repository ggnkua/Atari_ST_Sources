;-----------------------------------------------------------------------;
; 16*16 1 plane Buffer Scroller (This one has variable speeds 1,2,4etc) ;
; By Martin Griffiths May 1991. (alias Griff of the Inner Circle)....	;
;-----------------------------------------------------------------------;

		OPT O+,OW-

nolines		EQU 12
linewid		EQU 84
bufsize		EQU nolines*linewid

start		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; lowres
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; supervisor
		ADDQ.L #6,SP
		LEA stack,SP

letsgo		MOVE.L #$f8000,D0
		MOVE.L D0,log_base
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W
		BSR Init_ints
		MOVE.W #$700,$FFFF8240+2
		MOVE.W #$700,$FFFF8240+16
.wait		BTST.B #0,$FFFFFC00.W
		BEQ.S .wait
		CMP.B #$39,$FFFFFC02.W
		BNE.S .wait
		BSR Restore_ints
		CLR -(SP)
		TRAP #1

Init_ints	MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B $FFFFFA07.W,(A0)+
		MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
		MOVE.B $FFFFFA15.W,(A0)+
		MOVE.B $FFFFFA1B.W,(A0)+
		MOVE.B $FFFFFA21.W,(A0)+
		MOVE.L $70.W,(A0)+
		BCLR.B #3,$FFFFFA17.W
		CLR.B $FFFFFA07.W
		CLR.B $FFFFFA09.W
		CLR.B $FFFFFA13.W
		CLR.B $FFFFFA15.W
		MOVE.L #my_vbl,$70.W
		MOVE #$2300,SR
		RTS

Restore_ints	MOVE #$2700,SR
		LEA old_mfp,A0
		MOVE.B (A0)+,$FFFFFA07.W
		MOVE.B (A0)+,$FFFFFA09.W
		MOVE.B (A0)+,$FFFFFA13.W
		MOVE.B (A0)+,$FFFFFA15.W
		MOVE.B (A0)+,$FFFFFA1B.W
		MOVE.B (A0)+,$FFFFFA21.W
		MOVE.L (A0)+,$70.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		RTS

old_mfp		DS.L 3	

; The vbl...

my_vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVE #1600,D0
.wait		DBF D0,.wait
		NOT $FFFF8240.W
		BSR do_bufscroll
		NOT $FFFF8240.W
		MOVEM.L (SP)+,D0-D7/A0-A6
		ADDQ #1,vbl_timer
		RTE

; The Buffer Scrolling Routine...

do_bufscroll	LEA scr_point(PC),A1		; ->some variables
		MOVE.L (A1)+,A0			; curr text ptr
		MOVE (A1)+,D6			; pixel offset
		ADD scrlspeed(PC),D6		; pix offset+speed
		AND #15,D6			; next 16 pix?
		BNE.S .notnchar			; no then skip
		ADDQ.W #2,(A1)			; onto next chunk 
		CMP #linewid/2,(A1)		; in pix buffer.
		BNE.S .noreset			; reached end of buffer?		
		CLR (A1)			; if yes reset buffer position
.noreset	ADDQ.L #1,A0			; next letter...
		MOVE.W thischar+2(PC),thischar	; cycle characters.
		MOVEQ #0,D0
.fetchchar	MOVE.B (A0),D0	
		BNE.S .notwrap			; end of text?
		LEA text(PC),A0			; yes restart text
		MOVE.B (A0),D0
.notwrap	CMP.B #1,D0
		BNE.S .notsetspeed
		MOVE.B 1(A0),scrlspeed+1
		ADDQ.L #2,A0
		BRA.S .fetchchar
.notsetspeed	SUB.B #32,D0			; ascii normalise
		LSL #5,D0
		MOVE.W D0,thischar+2
.notnchar	MOVE D6,-(A1)			; otherwise restore
		MOVE.L A0,-(A1)
		LEA fontbuf+2(PC),A5     	; character addr    
		LEA (A5),A6
		ADDA.W thischar(PC),A5
		ADDA.W thischar+2(PC),A6
		MOVE.W scx(PC),D0
		MULU #bufsize,d0
		LEA scbuffer,A3
		ADD.L D0,A3
		ADD scrlpos(PC),A3
		MOVE.L A3,A1
		MOVE.W scrlspeed(PC),D4		; scroll speed
		SUBQ #1,D4
		MULU #14,D4			; *14(for jmp thru)
		LEA .jmpthru(PC),A4
		SUB.W D4,A4			; jmp address
		MOVEQ #nolines-1,D1
.updatebuflp	MOVE.W (A6)+,D3
		SWAP D3
		MOVE.W (A5)+,D3 
		ROL.L D6,D3
		MOVE.W D3,40(A3)		; update the buffers		
		MOVE.W D3,-2(A3)
		MOVE.L A3,A2
		JMP (A4)
		REPT 15				; e.g number of buffers
		LEA bufsize(A2),A2		; to update = speed!
		ROL.L #1,D3
		MOVE.W D3,(linewid/2)-2(A2)
		MOVE.W D3,-2(A2)
		ENDR
.jmpthru	LEA linewid(A3),A3
		DBF D1,.updatebuflp
copy_buf	MOVE.L log_base(PC),A2		; screen base
		LEA (128*160)+6(A2),A2
		MOVEQ #nolines-1,D1
.copybuflp	MOVE.W (a1)+,(A2)
		MOVE.W (a1)+,8(A2)
		MOVE.W (a1)+,16(A2)
		MOVE.W (a1)+,24(A2)
		MOVE.W (a1)+,32(A2)
		MOVE.W (a1)+,40(A2)
		MOVE.W (a1)+,48(A2)
		MOVE.W (a1)+,56(A2)		; copy to screen.
		MOVE.W (a1)+,64(A2)
		MOVE.W (a1)+,72(A2)
		MOVE.W (a1)+,80(A2)
		MOVE.W (a1)+,88(A2)
		MOVE.W (a1)+,96(A2)
		MOVE.W (a1)+,104(A2)
		MOVE.W (a1)+,112(A2) 
		MOVE.W (a1)+,120(A2) 
		MOVE.W (a1)+,128(A2)
		MOVE.W (a1)+,136(A2)
		MOVE.W (a1)+,144(A2)
		MOVE.W (a1)+,152(A2)
		LEA linewid-40(a1),a1		; next buf line
		LEA 160(A2),A2			; next scr line
		DBF D1,.copybuflp
		RTS

scr_point	DC.L text
scx		DC.W 0
scrlpos		DC.W 0
scrlspeed	DC.W 2
thischar	DS.W 2
text		DC.B " TESTING TESTING...... SHITTY FUCKING SCROLLINE....",1,4," FUCKING BASTARD ETC ETC........        ",1,2
		DC.B 0
		EVEN
log_base	DS.L 1
phy_base	DS.L 1
vbl_timer	DS.W 1
fontbuf		INCBIN solofont.DAT

		SECTION BSS
		DS.W 8
scbuffer	REPT 16
		DS.B bufsize
		ENDR
		DS.W 8

old_mfp		DS.L 4	
old_vbl		DS.L 1

		DS.L 149
stack		DS.L 1
