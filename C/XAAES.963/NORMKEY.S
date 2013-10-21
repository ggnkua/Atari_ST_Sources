		.text
		.globl	normkey
module	normkey

       	move  	d3,-(a7)
       	move  	d0,d3
       	move  	d1,d0
       	and  	#255,d0			; 0xff
       	ext.L	d0
       	ext.L	d1
       	and.L	#65280,d1		; 0xff00
       	lsl.L	#8,d1
       	or.L	d1,d0
       	move  	d3,d2
       	and  	#255,d2			; 0xff
       	ext.L	d2
       	moveq	#24,d1			; 0x18
       	lsl.L	d1,d2
       	or.L	d2,d0
       	jsr 	nkc_tconv.L
       	and  	#-16385,d0		; 0xbfff
       	move  	d0,d1
       	and  	#768,d1			; 0x300
       	beq.B	L1
       	or  	#768,d0			; 0x300
L1:		and  	#-4097,d0		; 0xefff
       	move  	(a7)+,d3
       	rts	
