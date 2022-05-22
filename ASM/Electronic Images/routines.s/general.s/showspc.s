; Spectrum .SPU Piccy shower.

letsgo		CLR -(SP)
		PEA -1.W
		PEA -1.W
		MOVE #5,-(SP)
		TRAP #14			; ensure lowres
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		LEA my_stack,SP
		BSR handle_spc
		BSR Copy_pic			; copy piccy to screeb

set_ints	MOVE #$2700,SR
		BSR flush			; flush IKBD
		MOVE.B #$12,$FFFFFC02.W		; kill mouse
		LEA old_mfp+32,A0
		MOVEM.L $FFFF8240.W,D0-D7
		MOVEM.L D0-D7,-32(A0)
		MOVE.B $FFFFFA07.W,(A0)+
	        MOVE.B $FFFFFA09.W,(A0)+
		MOVE.B $FFFFFA13.W,(A0)+
        	MOVE.B $FFFFFA15.W,(A0)+
	        MOVE.B $FFFFFA19.W,(A0)+	; save all vectors
        	MOVE.B $FFFFFA1F.W,(A0)+	; that we change
		MOVE.L $68.W,(A0)+
		MOVE.L $70.W,(A0)+
		MOVE.L $120.W,(A0)+
		MOVE.L $134.W,(A0)+
	        MOVE.B #0,$FFFFFA07.W		; timer a and hbl
	        CLR.B $FFFFFA09.W		
        	MOVE.B #0,$FFFFFA13.W		
		CLR.B $FFFFFA15.W
		MOVE.L #vbl,$70.W
		BCLR.B #3,$FFFFFA17.W		; soft end of interrupt
		MOVE #$2300,SR

; Little demo which scrolls the screen vertically to oblivion!
		
wait_key	BSR wait_vbl			; obvious!
		MOVE.L log_base(PC),D0
		LSR #8,D0
		MOVE.L D0,$FFFF8200.W		; upper 16 bits
		CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BNE.S wait_key

restore		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		BSR flush
		MOVE.B #$8,$FFFFFC02.W
		MOVE.B (A0)+,$FFFFFA07.W
	        MOVE.B (A0)+,$FFFFFA09.W
        	MOVE.B (A0)+,$FFFFFA13.W	; restore mfp
        	MOVE.B (A0)+,$FFFFFA15.W
	        MOVE.B (A0)+,$FFFFFA19.W
            	MOVE.B (A0)+,$FFFFFA1F.W
		MOVE.L (A0)+,$68.W
		MOVE.L (A0)+,$70.W		; and vects
		MOVE.L (A0)+,$120.W
		MOVE.L (A0)+,$134.W
		BSET.B #3,$FFFFFA17.W
		MOVE #$2300,SR
		CLR -(SP)			; see ya!
		TRAP #1

; Wait for one vbl
; (d0 destroyed)

wait_vbl	MOVE.W vbl_timer(PC),D0
.wait		CMP.W vbl_timer(PC),D0
		BEQ.S .wait
		RTS

vbl		MOVEM.L D0-D7/A0-A6,-(SP)
		MOVE #$8240,A0
		MOVEQ #0,D0
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+			; clear palette
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		MOVE.L D0,(A0)+
		LEA pal,A0
		MOVE #$8240,A1
		REPT 8
		MOVE.L (A0)+,(A1)+
		ENDR

		ADDQ #1,vbl_timer
		MOVEQ #0,D0
		MOVE #$8209,A0
waits		MOVE.B (A0),D0
		BEQ.S	waits
		MOVEQ #10,D1
		SUB.B D0,D1
		LSL.B D1,D0
		MOVEQ #34,D0
delay_lp	DBF D0,delay_lp
		NOP
		MOVE #$C4,D1
		LEA pal+32,A3
		MOVE #$8240,A4

dopal		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		NOP
		NOP
		DBF D1,dopal
		NOP
		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		MOVE.L (A3)+,(A2)+
		LEA (A4),A0
		LEA (A4),A1
		LEA (A4),A2
		LEA -$4A60(A3),A4
		NOP
		NOP
		NOP	 
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A0)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A3)+,(A1)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
		MOVE.L (A4)+,(A2)+
evbl:		MOVEM.L (SP)+,D0-D7/A0-A6
		RTE


; Copy the piccy to the screen.

Copy_pic	LEA pic(PC),A0
		MOVE.L log_base(PC),A1
		MOVE #1999,D1
cpy_lp1		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		MOVE.L (A0)+,(A1)+
		DBF D1,cpy_lp1 
		RTS

; Flush keyboard

flush		BTST.B #0,$FFFFFC00.W
		BEQ.S flok
		MOVE.B $FFFFFC02.W,D0
		BRA.S flush
flok		RTS

; SPC depacker

handle_spc:
	lea	spc(pc),a0
	move.l	a0,a1
	adda.l	#52000,a1
	move.l	a1,a2
	bsr	unpackspc

	move.l	a2,a0
	moveq	#4-1,d1
	moveq	#0,d2
dospc:	lea	spc(pc),a1
	lea	160(a1),a1
	adda.w	d2,a1
	move.w	#199-1,d0	; Number of lines -1.
	bsr	copy1plane
	addq.w	#2,d2
	dbra	d1,dospc
	lea	-6(a1),a1
	move.w	#1194-1,d0
copypln:move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d0,copypln
dont_moveit:
	rts


;
; SPC unpacker.
;
unpackspc:
	movem.l	(a0)+,d0-d2
	movem.l	d0-d2,spc_flag

itsspc:	move.l	a0,spc_addr

	move.w	#31840,d0

spc_next:
	moveq	#0,d1
	move.b	(a0)+,d1
	bpl.s	spc_norep

	ext.w	d1
	neg.w	d1
	addq.w	#1,d1	; (usually 2) -1 for DBRA
	move.w	d1,d2
	addq.w	#1,d2
	move.b	(a0)+,d3
spc_rep:move.b	d3,(a1)+
	dbra	d1,spc_rep
	sub.w	d2,d0
	ble.s	do_palette
	bra.s	spc_next

spc_norep:
	move.w	d1,d2
norep:	move.b	(a0)+,(a1)+
	dbra	d1,norep
	addq.w	#1,d2
	sub.w	d2,d0
	bgt.s	spc_next


do_palette:

	move.l	spc_addr(pc),a0
	add.l	spc_datalen(pc),a0

      MOVE.W  #$254,D7
      CLR.W   D0
L0043:MOVE.W  #$D,D6
      MOVE.W  (A0)+,D1
      LSR.W   #1,D1 
      MOVE.W  D0,(A1)+
L0044:LSR.W   #1,D1 
      BCC.S   L0045 
      MOVE.W  (A0)+,(A1)+ 
      DBF     D6,L0044
      BRA.S   L0046 
L0045:MOVE.W  D0,(A1)+
      DBF     D6,L0044
L0046:MOVE.W  D0,(A1)+
      DBF     D7,L0043
enduspc:
	rts	


spc_addr:
	ds.l	1
spc_flag:
	ds.w	1
spc_reserved:
	ds.w	1
spc_datalen:
	ds.l	1	
spc_collen:
	ds.l	1

	
copy1plane:
scoff	set	0
	rept	20
	move.w	(a0)+,scoff(a1)
scoff	set	scoff+8
	endr
	lea	160(a1),a1
	dbra	d0,copy1plane
	rts

log_base	DC.L $F0000
vbl_timer	DC.W 0

		SECTION DATA
spc
pic		INCBIN A:\1_2.SPC
pal		EQU pic+32000
		DS.B 100000

		SECTION BSS

old_mfp		DS.L 30			; saved mfp vects etc
		DS.L 249
my_stack	DS.L 2			; our own stack..

 