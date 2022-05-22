loadreg		macro
		move.b	\1,$ffff8800.w
		move.b	\2,$ffff8802.w
		endm

eeek		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.b	#7,$ffff8800.w
		move.b	$ffff8800.w,d0
		and.b	#$f8,d0
		move.b	d0,$ffff8802.w

                MOVE #%1001100100011000,$FFFF8930.w	; dma output 25mhz clock,no handshake
                MOVE #%1000101101011110,$FFFF8932.w	; dsp out -> dac
		move.b  #1,$FFFF8934.w  	;
		move.b  #1,$FFFF8935.w  	;49.2khz
		move.b  #0,$FFFF8936.w  	;record 1 track.
                move.b  #1,$FFFF8937.w		;CODEC <- Multiplexor
                move.b  #3,$FFFF8938.w		;L+R <- Soundchip(NOT ADC!)
		lea	results,a6
		moveq	#15,d6
		
.main		loadreg	#8,D6
		loadreg	#0,#128
		loadreg	#1,#2
		BSET #7,$FFFF8901.w  		; select record register
                MOVE #64+3,$FFFF8920.w 		; 8 bit stereo,50khz,play 1 track,dac to track 1

		BSR Set_DMA
		MOVE #16,$FFFF8900.W	; DMA RECORD ON

		moveq	#100-1,d7
.lp		move.w	#37,-(sp)
		trap 	#14
		addq.l	#2,sp
		dbf	d7,.lp
		lea	buffer+2,a0
		moveq	#0,d0
		moveq	#0,d1
		move.w	#(65536/4)-1,d2
.lp2		move.w	(a0),d1
		add.l 	d1,d0
		addq.l	#4,a0
		dbf	d2,.lp2
		divu.l	#(65536/4),d0
		move.w	d0,(A6)+
		dbf	d6,.main
		loadreg #8,#0
		
		clr 	-(sp)
		trap 	#1


Set_DMA		MOVE.L #buffer,d0
		move.l	#65536+buffer,d1
		MOVE.B d0,$FFFF8907.W
		LSR.L #8,D0
		MOVE.B d0,$FFFF8905.W
		LSR.L #8,D0
		MOVE.B d0,$FFFF8903.W	
		MOVE.B d1,$FFFF8913.W
		LSR.L #8,D1
		MOVE.B d1,$FFFF8911.W
		LSR.L #8,D1
		MOVE.B d1,$FFFF890f.W
		RTS

		
		section bss
results		ds.w	16
buffer		DS.B	65536