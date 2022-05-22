* Play a sample under interrupt.

Sam_play	CLR.L -(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		LEA sup_stk(PC),A0
		MOVE.L D0,(A0)
		MOVE.B #2,$484		no keyclick
cl_sd_regs	MOVE #$8800,A0		soundchip addr
		MOVE #$8802,A1
		CLR.B D0
		MOVE.B #0,(A0)		reg 0
		MOVE.B D0,(A1)		clear it
		MOVE.B #1,(A0)		reg 1
		MOVE.B D0,(A1)		clear it
		MOVE.B #2,(A0)		
		MOVE.B D0,(A1)		etc
		MOVE.B #3,(A0)		
		MOVE.B D0,(A1)		etc
		MOVE.B #4,(A0)
		MOVE.B D0,(A1)
		MOVE.B #5,(A0)
		MOVE.B D0,(A1)
		MOVE.B #7,(A0)
		MOVE.B #-1,(A1)
		MOVE.B #8,(A0)
		MOVE.B D0,(A1)
		MOVE.B #9,(A0)
		MOVE.B D0,(A1)
		MOVE.B #10,(A0)
		MOVE.B D0,(A1)
init		MOVE.L #sam_strt,addr_cnt+2
		MOVE.L #sam_end,addr_tst+2
		MOVE Khz(PC),D0		
		SUBQ #3,D0	
		MOVE.L #do_samp,$134
		MOVE.B sd(PC,D0),D0
		MOVE.B D0,$FFFFFA1F.W	data
		MOVE.B #1,$FFFFFA19.W	control
		BCLR.B #3,$FFFFFA17.W	auto end
		BSET.B #5,$FFFFFA07.W	iera
		BSET.B #5,$FFFFFA13.W	imra
User		MOVE.L sup_stk(PC),-(SP)
		MOVE #$20,-(SP)
		TRAP #1
		ADDQ.L #6,SP
		CLR -(SP)
		TRAP #1

do_samp	MOVEM.L D6/D7/A6,-(SP)	
addr_cnt	LEA sam_strt,A6
addr_tst	CMP.L #$12345678,A6
		BGE.S dis_samp	
		CLR D7
		MOVE.B (A6)+,D7
		MOVE.L A6,addr_cnt+2
		LSL #3,D7
		MOVE.L snds(PC,D7),D6
		MOVE.W snds+4(PC,D7),D7
		MOVE #$8800,A6
		MOVEP.L D6,0(A6)
		MOVEP.W D7,0(A6)
		MOVEM.L (SP)+,D6/D7/A6
		RTE				
dis_samp	CLR.B $FFFFFA19.W 	 timer a - off
		MOVEM.L (SP)+,D6/D7/A6
		RTE				

sd		DC.B $CD,$9A,$7B,$66,$58
		DC.B $4D,$44,$3D,$38,$33
		DC.B $2F,$2C,$29,$26
		EVEN
snds		DC.W $80E,$90D,$A0C,$0
		DC.W $80F,$903,$A00,$0
		DC.W $80F,$903,$A00,$0
		DC.W $80F,$903,$A00,$0
		DC.W $80F,$903,$A00,$0
		DC.W $80F,$903,$A00,$0
		DC.W $80F,$903,$A00,$0
		DC.W $80E,$90D,$A0B,$0
		DC.W $80E,$90D,$A0B,$0
		DC.W $80E,$90D,$A0B,$0
		DC.W $80E,$90D,$A0B,$0
		DC.W $80E,$90D,$A0B,$0
		DC.W $80E,$90D,$A0B,$0
		DC.W $80E,$90D,$A0B,$0
		DC.W $80E,$90D,$A0A,$0
		DC.W $80E,$90D,$A0A,$0
		DC.W $80E,$90D,$A0A,$0
		DC.W $80E,$90D,$A0A,$0
		DC.W $80E,$90C,$A0C,$0
		DC.W $80E,$90D,$A00,$0
		DC.W $80D,$90D,$A0D,$0
		DC.W $80D,$90D,$A0D,$0
		DC.W $80D,$90D,$A0D,$0
		DC.W $80D,$90D,$A0D,$0
		DC.W $80D,$90D,$A0D,$0
		DC.W $80D,$90D,$A0D,$0
		DC.W $80E,$90C,$A0B,$0
		DC.W $80E,$90C,$A0B,$0
		DC.W $80E,$90C,$A0B,$0
		DC.W $80E,$90C,$A0B,$0
		DC.W $80E,$90C,$A0B,$0
		DC.W $80E,$90C,$A0B,$0
		DC.W $80E,$90C,$A0B,$0
		DC.W $80E,$90C,$A0B,$0
		DC.W $80E,$90C,$A0A,$0
		DC.W $80E,$90C,$A0A,$0
		DC.W $80E,$90C,$A0A,$0
		DC.W $80E,$90C,$A0A,$0
		DC.W $80D,$90D,$A0C,$0
		DC.W $80D,$90D,$A0C,$0
		DC.W $80E,$90C,$A09,$0
		DC.W $80E,$90C,$A09,$0
		DC.W $80E,$90C,$A05,$0
		DC.W $80E,$90C,$A00,$0
		DC.W $80E,$90C,$A00,$0
		DC.W $80E,$90B,$A0B,$0
		DC.W $80E,$90B,$A0B,$0
		DC.W $80E,$90B,$A0B,$0
		DC.W $80E,$90B,$A0B,$0
		DC.W $80E,$90B,$A0A,$0
		DC.W $80E,$90B,$A0A,$0
		DC.W $80E,$90B,$A0A,$0
		DC.W $80D,$90D,$A0B,$0
		DC.W $80D,$90D,$A0B,$0
		DC.W $80D,$90D,$A0B,$0
		DC.W $80E,$90B,$A09,$0
		DC.W $80E,$90B,$A09,$0
		DC.W $80E,$90B,$A09,$0
		DC.W $80D,$90C,$A0C,$0
		DC.W $80D,$90D,$A0A,$0
		DC.W $80E,$90B,$A07,$0
		DC.W $80E,$90B,$A00,$0
		DC.W $80E,$90B,$A00,$0
		DC.W $80D,$90D,$A09,$0
		DC.W $80D,$90D,$A09,$0
		DC.W $80E,$90A,$A09,$0
		DC.W $80D,$90D,$A08,$0
		DC.W $80D,$90D,$A07,$0
		DC.W $80D,$90D,$A04,$0
		DC.W $80D,$90D,$A00,$0
		DC.W $80E,$90A,$A04,$0
		DC.W $80E,$909,$A09,$0
		DC.W $80E,$909,$A09,$0
		DC.W $80D,$90C,$A0B,$0
		DC.W $80E,$909,$A08,$0
		DC.W $80E,$909,$A08,$0
		DC.W $80E,$909,$A07,$0
		DC.W $80E,$908,$A08,$0
		DC.W $80E,$909,$A01,$0
		DC.W $80C,$90C,$A0C,$0
		DC.W $80D,$90C,$A0A,$0
		DC.W $80E,$908,$A06,$0
		DC.W $80E,$907,$A07,$0
		DC.W $80E,$908,$A00,$0
		DC.W $80E,$907,$A05,$0
		DC.W $80E,$906,$A06,$0
		DC.W $80D,$90C,$A09,$0
		DC.W $80E,$905,$A05,$0
		DC.W $80E,$904,$A04,$0
		DC.W $80D,$90C,$A08,$0
		DC.W $80D,$90B,$A0B,$0
		DC.W $80E,$900,$A00,$0
		DC.W $80D,$90C,$A06,$0
		DC.W $80D,$90C,$A05,$0
		DC.W $80D,$90C,$A02,$0
		DC.W $80C,$90C,$A0B,$0
		DC.W $80C,$90C,$A0B,$0
		DC.W $80D,$90B,$A0A,$0
		DC.W $80D,$90B,$A0A,$0
		DC.W $80D,$90B,$A0A,$0
		DC.W $80D,$90B,$A0A,$0
		DC.W $80C,$90C,$A0A,$0
		DC.W $80C,$90C,$A0A,$0
		DC.W $80C,$90C,$A0A,$0
		DC.W $80D,$90B,$A09,$0
		DC.W $80D,$90B,$A09,$0
		DC.W $80D,$90A,$A0A,$0
		DC.W $80D,$90A,$A0A,$0
		DC.W $80D,$90A,$A0A,$0
		DC.W $80C,$90C,$A09,$0
		DC.W $80C,$90C,$A09,$0
		DC.W $80C,$90C,$A09,$0
		DC.W $80D,$90B,$A06,$0
		DC.W $80C,$90B,$A0B,$0
		DC.W $80C,$90C,$A08,$0
		DC.W $80D,$90B,$A00,$0
		DC.W $80D,$90B,$A00,$0
		DC.W $80C,$90C,$A07,$0
		DC.W $80C,$90C,$A06,$0
		DC.W $80C,$90C,$A05,$0
		DC.W $80C,$90C,$A03,$0
		DC.W $80C,$90C,$A01,$0
		DC.W $80C,$90B,$A0A,$0
		DC.W $80D,$90A,$A05,$0
		DC.W $80D,$90A,$A04,$0
		DC.W $80D,$90A,$A02,$0
		DC.W $80D,$909,$A08,$0
		DC.W $80D,$909,$A08,$0

		DC.W $80C,$90B,$A09,$0
		DC.W $80C,$90B,$A09,$0
		DC.W $80D,$908,$A08,$0
		DC.W $80B,$90B,$A0B,$0
		DC.W $80D,$909,$A05,$0
		DC.W $80C,$90B,$A08,$0
		DC.W $80D,$909,$A02,$0
		DC.W $80D,$908,$A06,$0
		DC.W $80C,$90B,$A07,$0
		DC.W $80D,$907,$A07,$0
		DC.W $80C,$90B,$A06,$0
		DC.W $80C,$90A,$A09,$0
		DC.W $80B,$90B,$A0A,$0
		DC.W $80C,$90B,$A02,$0
		DC.W $80C,$90B,$A00,$0
		DC.W $80C,$90A,$A08,$0
		DC.W $80D,$906,$A04,$0
		DC.W $80D,$905,$A05,$0
		DC.W $80D,$905,$A04,$0
		DC.W $80C,$909,$A09,$0
		DC.W $80D,$904,$A03,$0
		DC.W $80B,$90B,$A09,$0
		DC.W $80C,$90A,$A05,$0
		DC.W $80B,$90A,$A0A,$0
		DC.W $80C,$909,$A08,$0
		DC.W $80B,$90B,$A08,$0
		DC.W $80C,$90A,$A00,$0
		DC.W $80C,$90A,$A00,$0
		DC.W $80C,$909,$A07,$0
		DC.W $80B,$90B,$A07,$0
		DC.W $80C,$909,$A06,$0
		DC.W $80B,$90B,$A06,$0
		DC.W $80B,$90A,$A09,$0
		DC.W $80B,$90B,$A05,$0
		DC.W $80A,$90A,$A0A,$0
		DC.W $80B,$90B,$A02,$0
		DC.W $80B,$90A,$A08,$0
		DC.W $80C,$907,$A07,$0
		DC.W $80C,$908,$A04,$0
		DC.W $80C,$907,$A06,$0
		DC.W $80B,$909,$A09,$0
		DC.W $80C,$906,$A06,$0
		DC.W $80A,$90A,$A09,$0
		DC.W $80C,$907,$A03,$0
		DC.W $80B,$90A,$A05,$0
		DC.W $80B,$909,$A08,$0
		DC.W $80B,$90A,$A03,$0
		DC.W $80A,$90A,$A08,$0
		DC.W $80B,$90A,$A00,$0
		DC.W $80B,$909,$A07,$0
		DC.W $80B,$908,$A08,$0
		DC.W $80A,$90A,$A07,$0
		DC.W $80A,$909,$A09,$0
		DC.W $80C,$901,$A01,$0
		DC.W $80A,$90A,$A06,$0
		DC.W $80B,$908,$A07,$0
		DC.W $80A,$90A,$A05,$0
		DC.W $80A,$909,$A08,$0
		DC.W $80A,$90A,$A02,$0
		DC.W $80A,$90A,$A01,$0
		DC.W $80A,$90A,$A00,$0
		DC.W $809,$909,$A09,$0
		DC.W $80A,$908,$A08,$0
		DC.W $80B,$908,$A01,$0
		DC.W $80A,$909,$A06,$0
		DC.W $80B,$907,$A04,$0
		DC.W $80A,$909,$A05,$0
		DC.W $809,$909,$A08,$0
		DC.W $80A,$909,$A03,$0
		DC.W $80A,$908,$A06,$0
		DC.W $80A,$909,$A00,$0
		DC.W $809,$909,$A07,$0
		DC.W $809,$908,$A08,$0
		DC.W $80A,$908,$A04,$0
		DC.W $809,$909,$A06,$0
		DC.W $80A,$908,$A01,$0
		DC.W $809,$909,$A05,$0
		DC.W $809,$908,$A07,$0
		DC.W $808,$908,$A08,$0
		DC.W $809,$909,$A02,$0
		DC.W $809,$908,$A06,$0
		DC.W $809,$909,$A00,$0
		DC.W $809,$907,$A07,$0
		DC.W $808,$908,$A07,$0
		DC.W $809,$907,$A06,$0
		DC.W $809,$908,$A02,$0
		DC.W $808,$908,$A06,$0
		DC.W $809,$906,$A06,$0
		DC.W $808,$907,$A07,$0
		DC.W $808,$908,$A04,$0
		DC.W $808,$907,$A06,$0
		DC.W $808,$908,$A02,$0
		DC.W $807,$907,$A07,$0
		DC.W $808,$906,$A06,$0
		DC.W $808,$907,$A04,$0
		DC.W $807,$907,$A06,$0
		DC.W $808,$906,$A05,$0
		DC.W $808,$906,$A04,$0
		DC.W $807,$906,$A06,$0
		DC.W $807,$907,$A04,$0
		DC.W $808,$905,$A04,$0
		DC.W $806,$906,$A06,$0
		DC.W $807,$906,$A04,$0
		DC.W $807,$905,$A05,$0
		DC.W $806,$906,$A05,$0
		DC.W $806,$906,$A04,$0
		DC.W $806,$905,$A05,$0
		DC.W $806,$906,$A02,$0
		DC.W $806,$905,$A04,$0
		DC.W $805,$905,$A05,$0
		DC.W $806,$905,$A02,$0
		DC.W $805,$905,$A04,$0
		DC.W $805,$904,$A04,$0
		DC.W $805,$905,$A02,$0
		DC.W $804,$904,$A04,$0
		DC.W $804,$904,$A03,$0
		DC.W $804,$904,$A02,$0
		DC.W $804,$903,$A03,$0
		DC.W $803,$903,$A03,$0
		DC.W $803,$903,$A02,$0
		DC.W $803,$902,$A02,$0
		DC.W $802,$902,$A02,$0
		DC.W $802,$902,$A01,$0
		DC.W $801,$901,$A01,$0
		DC.W $802,$901,$A00,$0
		DC.W $801,$901,$A00,$0
		DC.W $801,$900,$A00,$0
		DC.W $800,$900,$A00,$0

sup_stk	DS.L 1
Khz		DC.W 10		
sam_strt	INCBIN "MOVEBODY.SPL"
sam_end
