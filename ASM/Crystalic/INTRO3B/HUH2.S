		move.w	#2,-(sp)
		trap	#14
		addq.l	#2,sp
		move.l	d0,screen

		CLR -(SP)
		MOVE.L #-1,-(SP)
		MOVE.L #-1,-(SP)
		MOVE #5,-(SP)
		TRAP #14			; ensure lowres
		LEA 12(SP),SP
		CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1				; supervisor mode
		ADDQ.L #6,SP
		LEA my_stack,SP

set_ints	MOVE #$2700,SR
		bsr flush
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
	        MOVE.B #$21,$FFFFFA07.W		; timer a and hbl
	        CLR.B $FFFFFA09.W		
        	MOVE.B #$21,$FFFFFA13.W		
		CLR.B $FFFFFA15.W
		CLR.B $FFFFFA19.W		; clear em out
		CLR.B $FFFFFA1B.W

	move.w	#2,-(sp)
	trap  	#14
	addq.l	#2,sp

cls2:
	movea.l	d0,a1
	move.l	#7999,d0
cls_loop2:
	move.l	#$ffffffff,(a1)+
	dbf	d0,cls_loop2

	move.w	#$0,farg
	move.l	#vrast,d0
	clr.b	d0
	move.l	d0,a4
	clr.l	d2
	move.l	#HBI,$120
	move.l	#VBI,$70

wait_key	
		Move.w	#37,-(sp)
		Trap	#14
		Addq.l	#2,sp

		CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
		BEQ restore

		BRA wait_key

restore		
		MOVE #$2700,SR
		LEA old_mfp,A0
		MOVEM.L (A0)+,D0-D7
		MOVEM.L D0-D7,$FFFF8240.W
		bsr flush
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
flush		rts

VBI:
	movem.l	d0-d7/a0-a7,-(sp)
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21
	bclr	#0,$fffa0f
	move.b	#8,$fffffa1b.w
	lea	HBI,a0
	move.l	a0,$120

	move.l	#RasterColors,RasterPtr
	clr.b	$3000
	CMP.B #$39,$FFFFFC02.W		; <SPACE> exits.
	BEQ restore
	movem.l	(sp)+,d0-d7/a0-a7
	rte

HBI:	
sync 	cmp.b	#160,$FF8209
	bls	sync
	move.b	$FF8209,d2
	jsr	(A4,D2)
	clr.l	d2
	move.l  a0,-(sp)
	clr.b	$fffffa1b.w
	move.b  #1,$fffffa21
	move.l	RasterPtr,a0
	move.w	(a0)+,farg
	move.l	a0,RasterPtr
	
	bclr	#0,$fffffa0f
	move.b	#8,$fffffa1b.w
	move.l	a0,RasterPtr
	lea	HBI2,a0
	move.l	a0,$120

	move.l  (sp)+,a0
	rte
HBI2:	
	move.w	#$777,$ff8240
	move.l  a0,-(sp)
	clr.b	$fffffa1b.w
	move.b  #200,$fffffa21
	move.l	RasterPtr,a0
	move.w	(a0)+,farg
	move.l	a0,RasterPtr

	bclr	#0,$fffffa0f
	move.b	#8,$fffffa1b.w
	move.l	a0,RasterPtr

	move.l  (sp)+,a0
	rte

vrast	
	nop	; 20 nopar
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop	; 20st h„r...
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.w	#$707,$ff825E
	move.w	#2,$FF8260
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	move.w	#0,$FF8260
;	move.w	#$777,$ff825E
	RTS
	
RasterPtr:	ds.l	1

RasterColors:
	dc.w	$000,$000,$002,$003,$004,$005,$006,$007,$117,$227,$337,$447,$557,$667,$777
	dc.w	$300,$500,$700,$500,$777,$777,$667,$557,$447,$337,$227,$117,$007,$006,$005,$004,$003,$002,$001,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000,$000,$010,$020,$030,$040,$050,$060,$070,$171,$272,$373,$474,$575,$676,$777
	dc.w	$676,$575,$474,$373,$272,$171,$070,$060,$050,$040,$030,$020,$010,$000,$000,$000,$000

log_base	DC.L screen
sc_x		DC.W 8
sc_x1		DC.W 0
vbl_timer	DC.W 0


		SECTION BSS

old_mfp		DS.L 30			; saved mfp vects etc
		DS.L 249
my_stack	DS.L 2			; our own stack..
farg		DS.W 1	
screen		DS.L 1

    	