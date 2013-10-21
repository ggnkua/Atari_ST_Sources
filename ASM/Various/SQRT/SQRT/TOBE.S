fast_sqrt: 
	moveq		#0,			d1		; g = 0
	move.l      #$8000,		d2		; b = $8000
	moveq		#15,		d3		; bshft = 15
fast_sqrt_0:
	move.l		d1,			d4		; temp = g
	add.l		d1,			d4		; temp = g<<1
	add.l		d2,			d4		; temp = (g<<1)+b
	lsl.l		d3,			d4		; temp = ((g<<1)+b)<<bshft
	subq.l		#1,			d3		; bshft--
	cmp.l		d0,			d4		; val >= temp ?
	bhi.s		fast_sqrt_1			;   no -> fast_sqrt_1
	add.l		d2,			d1		; g += b
	sub.l		d4,			d0		; val -= temp
fast_sqrt_1:
	lsr.l		#1,			d2		; b >>= 1, b!=0 ?
	bne.s		fast_sqrt_0			;   yes -> fast_sqrt_0
	move.l		d1,			d0		; return g
	rts

