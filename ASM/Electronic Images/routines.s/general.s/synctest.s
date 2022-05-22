;-----------------------------------------------------------------------;
;                             Sync Test					;
;									;
;    (C) April 1991 Martin Griffiths. (Griff of The Inner Circle).	;
;									;
;-----------------------------------------------------------------------;

		OPT O+,OW-

letsgo		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; low res
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; super visor
		ADDQ.L #6,SP
		MOVE.L D0,old_stack
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,old_col
		MOVE.L $FFFF8200.W,savebase
		LEA stack,SP
		LEA $FFFF8240.W,A0
		REPT 8
		CLR.L (A0)+
		ENDR
		BSR Initscreens
		LEA synctext(PC),A0
		MOVE.B #0,txpos
		MOVE.B #3,typos
		BSR print
		BSR set_ints
		BSR wait_vbl
		BSR fadein_sync

* This is the main program loop

Star_frame	CMP.B #$39+$80,$FFFFFC02.W	; space to exit...
		BNE Star_frame		

Exit		BSR wait_vbl
		BSR fadeout_sync
		BSR rest_ints
		MOVEM.L old_col(PC),D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		MOVE.L savebase(PC),$FFFF8200.W
		MOVE.L old_stack(PC),-(SP)
		MOVE.W #$20,-(SP)
		TRAP #1	
		ADDQ.L #6,SP
		CLR -(SP)			; bye for now...
		TRAP #1			
old_col		DS.W 16
old_stack	DS.L 1
savebase	DS.L 1

; My little vbl interrupt.

my_vbl		MOVEM.L D0-A6,-(SP)
		MOVEM.W col1(PC),D3/D4
		MOVE.W D3,$FFFF8242.W
		LEA $FFFF8209.W,A0
		LEA $FFFF825E.W,A1
		MOVE.W D3,(A1)
.ok		MOVE.B (A0),D0
		BEQ.S .ok
		MOVEQ #$20,D1
		SUB.B D0,D1
		LSL.B D1,D0
		MOVEQ #80-1,D5
.lp		DCB.W 125,$4e71
		DBF D5,.lp

		MOVEQ #12-1,D5
.lp1		DCB.W 15,$4E71
		MOVE.W D4,(A1)
		MOVE.W D3,(A1)
		DCB.W 125-4-15,$4e71
		DBF D5,.lp1 
		MOVEM.L (SP)+,D0-A6
		ADDQ #1,vbl_timer
		RTE
phy_base	DC.L 0
vbl_timer	DC.W 0

wait_vbl	MOVE.W vbl_timer(PC),D0
.wait		CMP.W vbl_timer(PC),D0
		BEQ.S .wait
		RTS

col1		DC.W 0
col2		DC.W 0

; Fade in sync shit.

fadein_sync	BSR wait_vbl
		MOVEQ #0,D1
		MOVEQ #0,D2
.lp		MOVE.W D1,col1
		MOVE.W D2,col2
		BSR wait_vbl
		BSR wait_vbl
		BSR wait_vbl
		ADD.W #$111,D1
		ADD.W #$010,D2
		CMP.W #$080,D2
		BNE.S .lp
		RTS

; Fade out sync shit.

fadeout_sync	BSR wait_vbl
		MOVE #$777,D1
		MOVE #$070,D2
.lp		MOVE.W D1,col1
		MOVE.W D2,col2
		BSR wait_vbl
		BSR wait_vbl
		BSR wait_vbl
		SUB.W #$111,D1
		SUB.W #$010,D2
		BGE.S .lp
		RTS

; Initialisation and restore interrupt routs.

set_ints	move #$2700,sr
		lea old_stuff(pc),a0
		move.l $70.w,(a0)+
		lea my_vbl(pc),a1
		move.l a1,$70.w
		lea $fffffa00.w,a1
		movep.w 7(a1),d0
		move.w d0,(a0)+
		movep.w 13(a1),d0
		move.w d0,(a0)+
		moveq #0,d0
		movep.w d0,7(a1)
		movep.w d0,13(a1)
		move #$2300,sr
		rts

rest_ints	move #$2700,sr
		lea old_stuff(pc),a0
		move.l (a0)+,$70.w
		lea $fffffa00.w,a1
		move.w (a0)+,d0
		movep.w d0,7(a1)
		move.w (a0)+,d0
		movep.w d0,13(a1)
		move #$2300,sr
		rts

old_stuff	ds.l 6

; Allocate space for screens and clear them + make standard *160 table.

Initscreens	lea phy_base(pc),a1
		move.l #screens+256,d0
		clr.b d0
		move.l d0,(a1)
		lsr #8,d0
		move.l d0,$ffff8200.w
		move.l phy_base(pc),a0
		BSR clear_screen
		MOVE.L phy_base(pc),a0
		LEA 80*160(A0),A0
		MOVE.W #(12*160)/2-1,D0
		MOVE.W #%00000000000001000,D1
.lp1		MOVE.W D1,(A0)+
		DBF D0,.lp1
		RTS

; Clear screen ->A0

clear_screen	moveq #0,d0
		move #7999,d1
.cls		move.l d0,(a0)+
		dbf d1,.cls
		rts

; Print Rout -> Text address in A0...  Uses TXPOS and TYPOS (.B)
; 1 (in text) = Inverse text, else normal.
; 2 (in text) = Normal text.
; Returns with LASTPTR holding last address after 0 termination.

print:		movem.l	d0-d4/a0/a2-a3,-(sp)
		moveq	#0,d2
printline:
		move.b	(a0)+,d0
		bne.s	notend
		move.l	a0,lastptr
		movem.l	(sp)+,d0-d4/a0/a2-a3
		rts
notend:		cmpi.b	#1,d0
		bne.s	notinv
		moveq	#1,d2
		move.b	(a0)+,d0
notinv:		cmpi.b	#2,d0
		bne.s	notnorm
		moveq	#0,d2
		move.b	(a0)+,d0
notnorm:	cmpi.b	#$a,d0
		bne.s	notcr
		addq.b	#8,typos
		bra.s	printline
notcr:		cmpi.b	#$d,d0
		bne.s	notlf
		move.b	#0,txpos
		bra.s	printline
notlf:		tst.b	d2
		bne.s	inverse
		moveq   #0,D3
	        moveq   #0,D4
        	move.b  txpos(PC),D3
	        move.b  typos(PC),D4
		mulu #160,d4
	        movea.l phy_base(pc),A2		; Screen
        	adda.l d4,A2
	        lea     xtab(PC),a3
		add.w d3,d3        
        	add.w 0(a3,D3.w),a2
        	lea     font(PC),a3
	        moveq   #0,D3
	        move.b  D0,D3
        	sub.b   #32,D3
	        lsl.w   #3,D3
        	adda.w  D3,a3
        	move.b  (a3)+,(A2)
	        move.b  (a3)+,160(A2)
        	move.b  (a3)+,320(A2)
	        move.b  (a3)+,480(A2)
        	move.b  (a3)+,640(A2)
	        move.b  (a3)+,800(A2)
        	move.b  (a3)+,960(A2)
	        move.b  (a3),1120(A2)
		addq.b	#1,txpos
		bra	printline

inverse:	moveq   #0,D3
	        moveq   #0,D4
        	move.b  txpos(PC),D3
	        move.b  typos(PC),D4
		mulu #160,d4
	        movea.l phy_base(pc),A2		; Screeen
	        adda.l d4,A2
		add.w d3,d3        
		lea     xtab(PC),a3
        	add.w 0(a3,D3.w),a2
        	lea     font(PC),a3
	        moveq   #0,D3
        	move.b  D0,D3
	        sub.b   #32,D3
        	lsl.w   #3,D3
	        adda.w  D3,a3
        	move.b  (a3)+,(A2)
		not.b	(a2)
        	move.b  (a3)+,160(A2)
		not.b	160(a2)
	        move.b  (a3)+,320(A2)
		not.b	320(a2)
        	move.b  (a3)+,480(A2)
		not.b	480(a2)
        	move.b  (a3)+,640(A2)
		not.b	640(a2)
	        move.b  (a3)+,800(A2)
		not.b	800(a2)
	        move.b  (a3)+,960(A2)
		not.b	960(a2)
	        move.b  (a3),1120(A2)
		not.b	1120(a2)
		addq.b	#1,txpos
		bra	printline

font:   	dc.l	$00000000,$00000000,$00181818,$18001800,$00666666 
		dc.l	$00000000,$0066FF66,$66FF6600,$183E603C,$067C1800 
		dc.l	$00666C18,$30664600,$1C361C38,$6F663B00,$00181818 
		dc.l	$00000000,$000E1C18,$181C0E00,$00703818,$18387000 
		dc.l	$00663CFF,$3C660000,$0018187E,$18180000,$00000000 
		dc.l	$00181830,$0000007E,$00000000,$00000000,$00181800 
		dc.l	$00060C18,$30604000,$003C666E,$76663C00,$00183818 
		dc.l	$18187E00,$003C660C,$18307E00,$007E0C18,$0C663C00 
		dc.l	$000C1C3C,$6C7E0C00,$007E607C,$06663C00,$003C607C 
		dc.l	$66663C00,$007E060C,$18303000,$003C663C,$66663C00 
		dc.l	$003C663E,$060C3800,$00001818,$00181800,$00001818 
		dc.l	$00181830,$060C1830,$180C0600,$00007E00,$007E0000 
		dc.l	$6030180C,$18306000,$003C660C,$18001800,$003C666E 
		dc.l	$6E603E00,$00183C66,$667E6600,$007C667C,$66667C00 
		dc.l	$003C6660,$60663C00,$00786C66,$666C7800,$007E607C 
		dc.l	$60607E00,$007E607C,$60606000,$003E6060,$6E663E00 
		dc.l	$0066667E,$66666600,$007E1818,$18187E00,$00060606 
		dc.l	$06663C00,$00666C78,$786C6600,$00606060,$60607E00 
		dc.l	$0063777F,$6B636300,$0066767E,$7E6E6600,$003C6666 
		dc.l	$66663C00,$007C6666,$7C606000,$003C6666,$666C3600 
		dc.l	$007C6666,$7C6C6600,$003C603C,$06063C00,$007E1818 
		dc.l	$18181800,$00666666,$66667E00,$00666666,$663C1800 
		dc.l	$0063636B,$7F776300,$0066663C,$3C666600,$0066663C 
		dc.l	$18181800,$007E0C18,$30607E00,$001E1818,$18181E00 
		dc.l	$00406030,$180C0600,$00781818,$18187800,$00081C36 
		dc.l	$63000000,$00000000,$0000FF00,$00183C7E,$7E3C1800 
		dc.l	$00003C06,$3E663E00,$0060607C,$66667C00,$00003C60 
		dc.l	$60603C00,$0006063E,$66663E00,$00003C66,$7E603C00 
		dc.l	$000E183E,$18181800,$00003E66,$663E067C,$0060607C 
		dc.l	$66666600,$00180038,$18183C00,$00060006,$0606063C 
		dc.l	$0060606C,$786C6600,$00381818,$18183C00,$0000667F 
		dc.l	$7F6B6300,$00007C66,$66666600,$00003C66,$66663C00 
		dc.l	$00007C66,$667C6060,$00003E66,$663E0606,$00007C66 
		dc.l	$60606000,$00003E60,$3C067C00,$00187E18,$18180E00 
		dc.l	$00006666,$66663E00,$00006666,$663C1800,$0000636B 
		dc.l	$7F3E3600,$0000663C,$183C6600,$00006666,$663E0C78 
		dc.l	$00007E0C,$18307E00,$00183C7E,$7E183C00,$18181818 
		dc.l	$18181818,$007E787C,$6E660600,$08183878,$38180800 

xoff		set	0
xtab:   	rept	40
		dc.w	xoff,xoff+1
xoff		set	xoff+8
		endr

txpos:		ds.b 1
typos:		ds.b 1
lastptr:	ds.l 1

synctext	DC.B $a,$d,$a,$d,$a,$d
		DC.B "            Electronic Images",$a,$d,$a,$d
		DC.B "                Sync Test    ",$a,$d,$a,$d
		DC.B "----------------------------------------",$a,$d,$a,$d
		DC.B $a,$d,$a,$d,$a,$d,$a,$d
		DC.B "----------------------------------------",$a,$d,$a,$d
		DC.B "If the above middle vertical line is not",$a,$d
		DC.B "green, switch off your ST for 10 seconds",$a,$d
		DC.B "to kick your shifter chip into sync!!   ",$a,$d,$a,$d,$a,$d
		DC.B "       Press <SPACE> to continue.       ",$a,$d
		DC.B 0


		SECTION BSS
screens		DS.B 256
		DS.B 32000
		DS.L 149
stack		DS.L 1
