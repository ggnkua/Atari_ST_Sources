; STE Dial Sample Module - Example.

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
	dc.l	chartab-module
	dc.l	sampletab-module
	dc.l	dtext-module

	even

chartab:
	dc.b	'1234567890ABCDEH'
	dc.b	0

	even

sampletab:
	dc.l	t_1-module,t_1e-module
	dc.w	60,01
	dc.l	t_2-module,t_2e-module
	dc.w	60,01
	dc.l	t_3-module,t_3e-module
	dc.w	60,01
	dc.l	t_4-module,t_4e-module
	dc.w	60,01
	dc.l	t_5-module,t_5e-module
	dc.w	60,01
	dc.l	t_6-module,t_6e-module
	dc.w	60,01
	dc.l	t_7-module,t_7e-module
	dc.w	60,01
	dc.l	t_8-module,t_8e-module
	dc.w	60,01
	dc.l	t_9-module,t_9e-module
	dc.w	60,01
	dc.l	t_0-module,t_0e-module
	dc.w	60,01
	dc.l	t_a-module,t_ae-module
	dc.w	60,01
	dc.l	t_b-module,t_be-module
	dc.w	60,01
	dc.l	t_c-module,t_ce-module
	dc.w	60,01
	dc.l	t_d-module,t_de-module
	dc.w	60,01
	dc.l	t_e-module,t_ee-module
	dc.w	60,01
	dc.l	t_h-module,t_he-module
	dc.w	60,01
	dc.l	0,0
	dc.w	0
	even

t_1:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\1.ste
t_1e:
	even
t_2:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\2.ste
t_2e:
	even
t_3:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\3.ste
t_3e:
	even
t_4:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\4.ste
t_4e:
	even
t_5:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\5.ste
t_5e:
	even
t_6:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\6.ste
t_6e:
	even
t_7:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\7.ste
t_7e:
	even
t_8:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\8.ste
t_8e:
	even
t_9:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\9.ste
t_9e:
	even
t_0:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\0.ste
t_0e:
	even
t_a:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\a.ste
t_ae:
	even
t_b:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\b.ste
t_be:
	even
t_c:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\c.ste
t_ce:
	even
t_d:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\d.ste
t_de:
	even
t_e:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\e.ste
t_ee:
	even
t_h:	incbin	e:\source.s\ste_bb\ste_12_5\ccitt5r1\h.ste
t_he:
	even
dtext:	dc.b	'CCITT #5 -R1-'
	dc.b	0
	even
m_end:
handle:		dc.w	0
filename:	dc.b	'CCITT5R1.BB'
		dc.b	0
	even
	end