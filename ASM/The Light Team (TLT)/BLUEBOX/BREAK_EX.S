; STE Break Sample Module - Example.
	
	opt	d+

	clr.w	-(sp)
	pea	filename
	move.w	#$3c,-(sp)
	trap	#1
	lea	8(sp),sp
	move.w	d0,handle

	pea	module
	move.l	#m_end-module,-(sp)
	move.w	handle,-(sp)
	move.w	#$40,-(sp)
	trap	#1
	lea	12(sp),sp

	move.w	handle,-(sp)
	move.w	#$3e,-(sp)
	trap	#1
	lea	4(sp),sp

	clr.w	-(sp)
	trap	#1

module:
	dc.w	128+1	; 12517 Hz STE Mono Samples.
	dc.w	250	; Delay 1
	dc.w	250	; Delay 2
	dc.l	sample1-module
	dc.l	s_end1-module
	dc.l	sample2-module
	dc.l	s_end2-module
	dc.l	btext-module

	even

sample1:	incbin	japan.clr
s_end1:
	even
sample2:	incbin	japan.xfr
s_end2:
	even
btext:		dc.b	'Japan'
		dc.b	0
	even
m_end:
filename:	dc.b	'JAPAN.BRE'
		dc.b	0
	even
handle:		dc.w	0
	end
