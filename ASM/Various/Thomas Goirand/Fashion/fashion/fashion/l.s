		; conversion truecolor falcon de la palette
		XDEF	get_palette
		XDEF	tc_palette
		XDEF	_SYS_DAC
get_palette
		
		lea	_SYS_DAC,a0
		lea	tc_palette,a1
		move.l	#256,d0
.yop_pal
		move.b	1(a0),d1
		move.b	2(a0),d2
		move.b	3(a0),d3
		
		lsl.w	#8,d1
		and.w	#%1111100000000000,d1
		lsl.w	#8-5,d2
		and.w	#%0000011111100000,d2
		lsr.w	#3,d3
		and.w	#%0000000000011111,d3
		
		or.w	d3,d2
		or.w	d2,d1
		
		move.w	d1,(a1)+
		
		addq.l	#4,a0
		subq.l	#1,d0
		bne.s	.yop_pal

		rts

		data
_sys_palette	dc.l	_SYS_DAC
		dc.l	0
		dc.w	
_SYS_DAC	incbin	"netscape.dac"
tc_palette	ds.w	256
		text