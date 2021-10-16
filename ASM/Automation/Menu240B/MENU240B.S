start	move.l	4(a7),d0
		pea		$2000.w
		move.l	d0,-(a7)
		move.l	#$4a0000,-(a7)
		trap		#1
		add.w	#$c,a7
		lea		ints_on,a0
		bsr		supv
		lea		text,a0
		bsr		print
getkey	move.w	#7,-(a7)
		trap		#1
		addq.l	#2,a7
		cmp.w	#'0',d0
		bne		not_0
		lea		hertz,a0
		bsr		supv
		bra		getkey
not_0	cmp.w	#'1',d0
		bne		not_1
		lea		ints_off,a0
		bsr		supv
		lea		clr_scrn,a0
		bsr		print
		pea		dummy
		pea		dummy
		pea		file
		pea		$4b0000
		trap		#1
		add.w	#16,a7
		bra		end
not_1	cmp.w	#'2',d0
		bne		getkey
		lea		ints_off,a0
		bsr		supv
		lea		clr_scrn,a0
		bsr		print
end		clr.w	-(a7)
		trap 	#1

supv		move.l	a0,-(a7)
		move.w	#$26,-(a7)
		trap		#$e
		addq.l	#6,a7
		rts

print	move.l	a0,-(a7)
		move.w	#9,-(a7)
		trap		#1
		addq.l	#6,a7
		rts

hertz	bchg		#1,$ff820a
		rts

ints_on	move.l	$4ce,oldvbl
		move.l	#vbl,$4ce
		move.l	#mfp,$120
		move.b	#1,$fffa07
		bset		#0,$fffa13
		move.b	#1,$fffa21
		move.b	#8,$fffa1b
		move.b	#$40,$fffa09
		move.b	#$12,$fffc02
		clr.w	$ff825e
		bsr		music
		rts

ints_off	move.l	oldvbl,$4ce
		bclr		#0,$fffa13
		move.b	$fffa13,$fffa07
		move.b	#0,$fffa1b
		move.b	$fffa15,$fffa09
		move.b	#8,$fffc02
		clr.w	$ff8240
		move.b	#8,$ff8800
		clr.b	$ff8802
		move.b	#9,$ff8800
		clr.b	$ff8802
		move.b	#10,$ff8800
		clr.b	$ff8802
		move.w	#$777,$ff8246
		move.w	#$777,$ff825e
		rts

vbl		move.l	#cols,colpos
		bsr		music+$a8
		rts

mfp		move.l	a0,-(a7)
		move.l	colpos,a0
		move.w	(a0)+,$ffff8240.w
		move.l	a0,colpos
		move.l	(a7)+,a0
		bclr		#0,$ffffa0f
		rte

oldvbl	dc.l		0
dummy	dc.l		0
colpos	dc.l		cols
cols		dc.w		$111,$222,$333,$444,$555,$666,$777
		dcb.w	8,$777
		dc.w		$777,$666,$555,$444,$333,$222,$111,$0
		dcb.w	16,0
		dc.w		0,$100,$200,$300,$400,$500,$600,$700
		dcb.w	8,$700
		dc.w		$700,$600,$500,$400,$300,$200,$100,$0
		dcb.w	8,0
		dc.w		0,$110,$220,$330,$440,$550,$660,$770
		dcb.w	8,$770
		dc.w		$770,$660,$550,$440,$330,$220,$110,$0
		dcb.w	16,0
		dc.w		0,1,2,3,4,5,6,7
		dcb.w	64,7
		dc.w		7,6,5,4,3,2,1,0		
		dcb.w	9,0
music		incbin	'sapiens.mus'
clr_scrn	dc.b		27,'E',0
text		dc.b		27,'E',27,'f',10,13
		dc.b		'       Automation CD 240 - Part B',10,13,10,13,10,13,10,13,10,13
		dc.b		'1) Brick Busta',10,13,10,13,10,13,10,13
		dc.b		'2) Operation Thunderbolt Document',10,13,10,13,10,13,10,13,10,13
		dc.b		'Greetings to:',10,13
		dc.b		'The Medway Boys     The Carebears',10,13
		dc.b		'The Replicants      The Overlanders',10,13
		dc.b		'The Empire          The Big Four',10,13
		dc.b		'Derek M.D           Stan The Man',10,13
		dc.b		'New Order           Hal',10,13
		dc.b		'MCA                 Des of The Pompeys',10,13
		dc.b		'       and everybody else in Automation',0
file		dc.b		'bricky.bbc',0
