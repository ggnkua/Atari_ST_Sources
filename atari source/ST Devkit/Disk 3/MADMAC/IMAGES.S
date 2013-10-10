* images.s
	.globl	_images
	.globl	_masks


_images:
	dc.l	a_i2
	dc.l	a_i1
	dc.l	a_i0
	dc.l	0			; end of table

_masks:
	dc.l	a_m2
	dc.l	a_m1
	dc.l	a_m0
	dc.l	0			; end of table



a_i0:	dc.l	i0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
a_m0:	dc.l	m0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
a_i1:	dc.l	i1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
a_m1:	dc.l	m1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
a_i2:	dc.l	i2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
a_m2:	dc.l	m2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0



i0:
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff
	dc.w	$ffff,$ffff,$ffff,$ffff

m0:	dc.w	0,0,0,0,0,0,0,0
	dc.w	0,0,0,0,0,0,0,0

i1:
	.dc.w	$07E0,$07E0,$07E0,$0000,$1FF8,$1FF8,$1FF8,$0000
	.dc.w	$0FF0,$0FF0,$0FF0,$0000,$47E2,$47E2,$47E2,$0000
	.dc.w	$63C6,$63C6,$63C6,$0000,$F5AF,$F5AF,$F5AF,$0000
	.dc.w	$DA51,$DA51,$DA51,$0000,$9DB5,$9DB5,$9DB5,$0000
	.dc.w	$DDB5,$DDB5,$DDB5,$0000,$DA51,$DA51,$DA51,$0000
	.dc.w	$F5AF,$F5AF,$F5AF,$0000,$63C6,$63C6,$63C6,$0000
	.dc.w	$47E2,$47E2,$47E2,$0000,$0FF0,$0FF0,$0FF0,$0000
	.dc.w	$1FF8,$1FF8,$1FF8,$0000,$07E0,$07E0,$07E0,$0000

m1:
	.dc.w	$ffff-$07E0,$ffff-$1FF8,$ffff-$0FF0,$ffff-$47E2
	.dc.w	$ffff-$63C6,$ffff-$F5AF,$ffff-$DA51,$ffff-$9DB5
	.dc.w	$ffff-$DDB5,$ffff-$DA51,$ffff-$F5AF,$ffff-$63C6
	.dc.w	$ffff-$47E2,$ffff-$0FF0,$ffff-$1FF8,$ffff-$07E0

i2:
	.dc.w	$0000,$0000,$0000,$0000,$0180,$0000,$0000,$0000
	.dc.w	$0180,$0000,$0000,$0240,$0180,$0000,$0000,$0000
	.dc.w	$07E0,$0000,$0000,$0000,$1FF8,$1818,$1B18,$0000
	.dc.w	$2FF4,$2004,$2304,$0000,$4FD2,$4002,$4602,$0000
	.dc.w	$3FDC,$300C,$360C,$0000,$4FD2,$4002,$4602,$0000
	.dc.w	$4FB2,$4812,$4812,$0000,$1768,$1008,$1008,$0000
	.dc.w	$13C8,$1008,$1008,$0000,$1008,$1008,$1008,$0000
	.dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

m2:
	.dc.w	$ffff-$0000,$ffff-$0180,$ffff-$03C0,$ffff-$0180
	.dc.w	$ffff-$07E0,$ffff-$1FF8,$ffff-$2FF4,$ffff-$4FD2
	.dc.w	$ffff-$3FDC,$ffff-$4FD2,$ffff-$4FB2,$ffff-$1768
	.dc.w	$ffff-$13C8,$ffff-$1008,$ffff-$0000,$ffff-$0000
