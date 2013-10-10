	xdef	rgb2sp,sp2rgb,rgb2st,st2rgb
	text
rgb2sp:			; xRGB
	rol.l	#8,d0	; RGBx
	rol.w	#8,d0	; RGxB

sp2rgb:			; RGxB
	ror.w	#8,d0	; RGBx
	ror.l	#8,d0	; xRGB

rgb2st:			; xxxx xxxx rrrR rrrr gggG gggg bbbB bbbb
	lsr.b	#5,d0	; xxxx xxxx rrrR rrrr gggG gggg 0000 0bbb (Xbit = B)
	ror.b	#3,d0	; xxxx xxxx rrrR rrrr gggG gggg bbb0 0000 (Xbit = B)
	roxr.b	#1,d0	; xxxx xxxx rrrR rrrr gggG gggg Bbbb 0000
	ror.l	#8,d0	; Bbbb 0000 xxxx xxxx rrrR rrrr gggG gggg
	lsr.b	#5,d0	; Bbbb 0000 xxxx xxxx rrrR rrrr 0000 0ggg (Xbit = G)
	ror.b	#3,d0	; Bbbb 0000 xxxx xxxx rrrR rrrr ggg0 0000 (Xbit = G)
	roxr.b	#1,d0	; Bbbb 0000 xxxx xxxx rrrR rrrr Gggg 0000
	ror.l	#8,d0	; Gggg 0000 Bbbb 0000 xxxx xxxx rrrR rrrr
	lsr.b	#5,d0	; Gggg 0000 Bbbb 0000 xxxx xxxx 0000 0rrr (Xbit = R)
	ror.b	#3,d0	; Gggg 0000 Bbbb 0000 xxxx xxxx rrr0 0000 (Xbit = R)
	roxr.b	#5,d0	; Gggg 0000 Bbbb 0000 xxxx xxxx 0000 Rrrr

	rol.l	#8,d0	; Bbbb 0000 xxxx xxxx 0000 Rrrr Gggg 0000
	lsr.w	#4,d0	; Bbbb 0000 xxxx xxxx 0000 0000 Rrrr Gggg
	rol.l	#4,d0	; 0000 xxxx xxxx 0000 0000 Rrrr Gggg Bbbb

st2rgb:			; 0000 0000 0000 0000 0000 Rrrr Gggg Bbbb
	moveq	#0,d0
	move.w	d1,d0
	lsl.w	#4,d0	; 0000 0000 0000 0000 Rrrr Gggg Bbbb 0000
	lsl.b	#1,d0	; 0000 0000 0000 0000 Rrrr Gggg bbb0 0000 (Xbit = B)
	rol.b	#3,d0	; 0000 0000 0000 0000 Rrrr Gggg 0000 0bbb (Xbit = B)
	roxl.b	#1,d0	; 0000 0000 0000 0000 Rrrr Gggg 0000 bbbB
	ror.l	#4,d0	; bbbB 0000 0000 0000 0000 Rrrr Gggg 0000
	lsl.b	#1,d0	; bbbB 0000 0000 0000 0000 Rrrr ggg0 0000 (Xbit = G)
	rol.b	#3,d0	; bbbB 0000 0000 0000 0000 Rrrr 0000 0ggg (Xbit = G)
	roxl.b	#5,d0	; bbbB 0000 0000 0000 0000 Rrrr gggG 0000
	ror.l	#8,d0	; gggG 0000 bbbB 0000 0000 0000 0000 Rrrr
	lsl.b	#5,d0	; gggG 0000 bbbB 0000 0000 0000 rrr0 0000 (Xbit = R)
	rol.b	#3,d0	; gggG 0000 bbbB 0000 0000 0000 0000 0rrr (Xbit = R)
	roxl.b	#5,d0	; gggG 0000 bbbB 0000 0000 0000 rrrR 0000
	swap	d0	; 0000 0000 rrrR 0000 gggG 0000 bbbB 0000
