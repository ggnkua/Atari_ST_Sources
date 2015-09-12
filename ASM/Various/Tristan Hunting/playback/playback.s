;SOURCE CODE FOR SAMPLED SOUND PLAYBACK ROUTINE
;PROGRAMMED USING DEVPAC ST
;BY TRISTAN HUNTING
;FOR ST FORMAT

smp_cmnd	MOVEM.L		A0-A3/D0-D4,-(SP)	save registers
		MOVE.W		#8,-(SP)
		MOVE.W		#27,-(SP)
		TRAP		#14
		ADDQ.L		#4,SP			enable timer b interrupt
		BSR		super			call supervisor mode
		MOVE.B		#0,$FFFA1B		stop timer b
		MOVE		#7,-(SP)
		CLR		-(SP)
		MOVE		#28,-(SP)
		TRAP		#14
		ADDQ.L		#6,SP			read sound chip port 7
		LEA		port7(PC),A0
		MOVE.B		D0,(A0)			save port 7
		AND.W		#192,D0
		ADD.W		#63,D0
		MOVE		#135,-(SP)
		MOVE		D0,-(SP)
		MOVE		#28,-(SP)
		TRAP		#14
		ADDQ.L		#6,SP			load new value to port 7
		MOVE.L		#$FF8800,A0				
		MOVE.L		#$FF8802,A1		sound chip address
		LEA		sup(PC),A2		data for setting up sound chip
		MOVE.L		#9,D0
slp		MOVE.B		(A2)+,(A0)
		MOVE.B		(A2)+,(A1)
		DBF		D0,slp			set up sound chip
		LEA		spa(PC),A0		address of interrupt routine variables
		LEA		vbls(PC),A1		address of basic variables
		MOVE.L		(A1)+,(A0)+		transfer address of sample data
		MOVE.L		(A1)+,(A0)+		transfer length of sample
		MOVE.L		(A1),D0			load coded sample rate
		MULU		#4,D0			multiply for position in data table
		LEA		sdt(PC),A2		load address of data table
		LEA		ntbint(PC),A3		load address of interrupt routine
		MOVE.L		A3,-(SP)		
		MOVE.W		0(A2,D0),-(SP)
		MOVE.W		2(A2,D0),-(SP)
		MOVE.W		#1,-(SP)
		MOVE.W		#31,-(SP)
		TRAP		#14
		ADD.L		#12,SP			start timer b
		BSR		usuper			exit supervisor mode
		MOVEM.L		(SP)+,A0-A3/D0-D4	load registers
		RTS					and exit...

spa		DS.L	2				interrupt routine variables
sup		DC.B	10,0,9,0,8,0,11,0,12,0		data for sound chip set up
sd		DC.B	10,0,9,0,8,0			data for sound chip shut down
port7		DC.L	0				port7

;TIMER B INTERRUPT

ntbint		MOVEM.L		A0-A2/D0-D2,-(SP)	save registers
		LEA.L		stable(PC),A1		address of data table
		LEA.L		spa(PC),A2		variables address
		SUBQ.L		#1,4(A2)
		BEQ		spexit			decrement and test counter
		MOVE.L		(A2),A0			sample address
		ADDQ.L		#1,(A2)			increment sample address
		CLR.L		d1
		CLR.L		d2			clear data registers
		MOVE.B		(A0),D1			read sample
		EORI.B		#128,D1			sign sample
		LSL		#1,D1			byte to word value
		MOVE.B		(A1,D1.W),D0		read data from sound table
		MOVE.B		$1(A1,D1.W),D1		data to voice C register
		MOVE		D0,D2
		LSR		#4,D2			put volume in lowest nibble
		ANDI		#$F,D0			mask voice b
		MOVE.B		#8,$FF8800		select voice a
		MOVE.B		D2,$FF8802		write volume
		MOVE.B		#9,$FF8800		select voice b
		MOVE.B		D1,$FF8802		write volume
		MOVE.B		#$A,$FF8800		select voice c
		MOVE.B		D0,$FF8802		write volume
		MOVEM.L		(SP)+,A0-A2/D0-D2	load registers
		BCLR		#0,$FFFA0F		acknowledge interrupt
		RTE					and exit...
spexit
		MOVE.L		#$FF8800,A0		
		MOVE.L		#$FF8802,A1		sound chip address for fast accsess
		LEA		sd(PC),A2		data for sound chip shut down 
		MOVE.L		#5,D0
selp		MOVE.B		(A2)+,(A0)
		MOVE.B		(A2)+,(A1)
		DBF		D0,selp			output data
		LEA		port7(PC),A2
		MOVE.B		#7,(A0)
		MOVE.B		(A2),(A1)		load port 7
		MOVEM.L		(SP)+,A0-A2/D0-D2	load registers	
		MOVE.B		#0,$FFFA1B		timer b	off
		BCLR		#0,$FFFA0F		acknowledge interrupt
		RTE					and exit
stable		DC.W 		$0000
		DC.W 		$0000
		DC.W 		$0001
		DC.W 		$0002
		DC.W 		$0003
		DC.W 		$0004
		DC.W 		$0004
		DC.W 		$0005
		DC.W 		$0005
		DC.W 		$0005
		DC.W 		$0006
		DC.W 		$0006
		DC.W 		$0006	
		DC.W 		$0006
		DC.W 		$0007
		DC.W 		$0007
		DC.W 		$0007
		DC.W 		$0007
		DC.W 		$0007
		DC.W 		$0008
		DC.W 		$0008
		DC.W 		$0008
		DC.W 		$0008
		DC.W 		$0008
		DC.W 		$0208
		DC.W 		$0308
		DC.W 		$0308
		DC.W 		$0408
		DC.W 		$0408
		DC.W 		$0009
		DC.W 		$0009
		DC.W 		$0009
		DC.W 		$0009
		DC.W 		$0209
		DC.W 		$0309
		DC.W 		$0309
		DC.W 		$0409
		DC.W 		$0409
		DC.W 		$0509
		DC.W 		$0509
		DC.W 		$0509
		DC.W 		$0509
		DC.W 		$0609
		DC.W 		$0609
		DC.W 		$0609
		DC.W 		$0609
		DC.W 		$000A
		DC.W 		$020A
		DC.W 		$030A
		DC.W 		$040A
		DC.W 		$040A
		DC.W 		$050A
		DC.W 		$050A
		DC.W 		$050A
		DC.W 		$060A
		DC.W 		$060A
		DC.W 		$060A
		DC.W 		$160A
		DC.W 		$160A
		DC.W 		$000B
		DC.W 		$000B
		DC.W 		$000B
		DC.W 		$010B
		DC.W 		$010B
		DC.W 		$020B
		DC.W 		$030B
		DC.W 		$030B
		DC.W 		$040B
		DC.W 		$0408	
		DC.W 		$050B
		DC.W 		$050B
		DC.W 		$060B
		DC.W 		$060B
		DC.W 		$060B
		DC.W 		$160B
		DC.W 		$070B
		DC.W 		$070B
		DC.W 		$070B
		DC.W 		$170B
		DC.W 		$170B
		DC.W 		$270B
		DC.W 		$080B
		DC.W 		$180B
		DC.W 		$280B
		DC.W 		$380B
		DC.W 		$380B
		DC.W 		$480B
		DC.W 		$480B
		DC.W 		$480B
		DC.W 		$000C
		DC.W 		$010C
		DC.W 		$020C
		DC.W 		$030C
		DC.W 		$030C
		DC.W 		$040C
		DC.W 		$040C
		DC.W 		$050C
		DC.W 		$250C
		DC.W 		$060C
		DC.W 		$060C
		DC.W 		$360C
		DC.W 		$070C
		DC.W 		$270C
		DC.W 		$370C
		DC.W 		$470C
		DC.W 		$470C
		DC.W 		$080C
		DC.W 		$280C
		DC.W 		$280C
		DC.W 		$380C
		DC.W 		$380C
		DC.W 		$480C
		DC.W 		$480C
		DC.W 		$580C
		DC.W 		$580C
		DC.W 		$090C
		DC.W 		$290C
		DC.W 		$390C
		DC.W 		$490C
		DC.W 		$490C
		DC.W 		$590C
		DC.W 		$590C
		DC.W 		$000D
		DC.W 		$010D
		DC.W 		$020D
		DC.W 		$030D
		DC.W 		$040D
		DC.W 		$040D
		DC.W 		$050D
		DC.W 		$050D
		DC.W 		$060D
		DC.W 		$060D
		DC.W 		$070D
		DC.W 		$070D
		DC.W 		$270D
		DC.W 		$270D
		DC.W 		$370D
		DC.W 		$370D
		DC.W 		$080D
		DC.W 		$080D
		DC.W 		$180D
		DC.W 		$280D
		DC.W 		$280D
		DC.W 		$380D
		DC.W 		$480D
		DC.W 		$090D
		DC.W 		$290D
		DC.W 		$390D
		DC.W 		$490D
		DC.W 		$590D
		DC.W 		$690D
		DC.W 		$0A0D
		DC.W 		$2A0D
		DC.W 		$3A0D
		DC.W 		$4A0D
		DC.W 		$5A0D
		DC.W 		$5A0D
		DC.W 		$6A0D
		DC.W 		$6A0D
		DC.W 		$7A0D
		DC.W 		$7A0D
		DC.W 		$0B0D
		DC.W 		$0B0D
		DC.W 		$3B0D
		DC.W 		$4B0D
		DC.W 		$4B0D
		DC.W 		$5B0D
		DC.W 		$5B0D
		DC.W 		$6B0D
		DC.W 		$6B0D
		DC.W 		$6B0D
		DC.W 		$7B0D
		DC.W 		$7B0D
		DC.W 		$7B0D
		DC.W 		$8B0D
		DC.W 		$8B0D
		DC.W 		$8B0D
		DC.W 		$8B0D
		DC.W 		$8B0D
		DC.W 		$000E
		DC.W 		$000E
		DC.W 		$010E
		DC.W 		$020E
		DC.W 		$030E
		DC.W 		$040E
		DC.W 		$040E
		DC.W 		$050E
		DC.W 		$050E
		DC.W 		$060E
		DC.W 		$060E
		DC.W 		$260E
		DC.W 		$070E
		DC.W 		$070E
		DC.W 		$270E
		DC.W 		$080E
		DC.W 		$080E
		DC.W 		$090E
		DC.W 		$490E
		DC.W 		$590E
		DC.W 		$690E
		DC.W 		$0A0E
		DC.W 		$0A0E
		DC.W 		$3A0E
		DC.W 		$3A0E
		DC.W 		$5A0E
		DC.W 		$5A0E
		DC.W 		$6A0E
		DC.W 		$6A0E
		DC.W 		$7A0E
		DC.W 		$7A0E
		DC.W 		$0B0E
		DC.W 		$4B0E
		DC.W 		$4B0E
		DC.W 		$5B0E
		DC.W 		$5B0E
		DC.W 		$6B0E
		DC.W 		$6B0E
		DC.W 		$7B0E
 		DC.W 		$7B0E
		DC.W 		$8B0E
		DC.W 		$8B0E
		DC.W 		$9B0E
		DC.W 		$9B0E
		DC.W 		$9B0E
		DC.W 		$9B0E
		DC.W 		$0C0E
		DC.W 		$0C0E
		DC.W 		$3C0E
		DC.W 		$7C0E
		DC.W 		$8C0E
		DC.W 		$8C0E
		DC.W 		$8C0E
		DC.W 		$8C0E
		DC.W 		$8C0E
		DC.W 		$9C0E
		DC.W 		$9C0E
		DC.W 		$9C0E
		DC.W 		$9C0E
		DC.W 		$9C0E
		DC.W 		$9C0E
		DC.W 		$9C0E
		DC.W 		$AC0E
		DC.W 		$AC0E
		DC.W 		$AC0E
		DC.W 		$AC0E
		DC.W 		$AC0E
		DC.W 		$AC0E
		DC.W 		$000F
		DC.W 		$060F
		DC.W 		$060F
		DC.W 		$070F
		DC.W 		$070F
		DC.W 		$070F
		DC.W 		$080F   
		DC.W 		$080F   
		DC.W 		$080F			data for sampled sounds			

super		CLR.L		-(SP)
		MOVE.W		#$20,-(SP)
		TRAP		#1
		ADD.L		#$6,SP			call supervisor
		LEA		stksve(PC),A0
		MOVE.L		D0,(A0)			save stack
		RTS					and exit...

usuper		LEA		stksve(PC),A0
		MOVE.L		(A0),D0
		MOVE.L		D0,-(SP)		load stack
		MOVE		#$20,-(SP)
		TRAP		#1
		ADDQ.L		#6,SP			back to user mode
		RTS		and exit...

sdt		DC.W		$E2,2,$E2,2,$76,2,$CA,1,$98,1
		DC.W		$79,1,$65,1,$56,1,$50,1,$45,1
		DC.W		$39,1,$36,1,$33,1,$30,1,$27,1
		DC.W		$21,1,$10,1		data table for sample rates(data,control(timer b registers)

stksve		DS.L		1			stack save

vbls		DS.L		4			variables
							;sample address,length,rate,space
