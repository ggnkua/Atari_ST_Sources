x	lea	crap(pc),a0
	lea	endc(pc),a1
.2	move.b	(a0),d0
	bmi.s	.1
	cmp.b	#$a,d0
	blt.s	.1
	sub.b	#' ',d0
.1	move.b	d0,(a0)+
	cmp.l	a0,a1
	bne.s	.2
	rts

crap	dc.b	$FB
	dc.b	'Este producto da calidad ha sido        '
	dc.b	'desarrollado los ultimos meses por      '
	dc.b	'nuestra compania de software que se     '
	dc.b	'llama desarrollos siniestros. Sera      '
	dc.b	'nuestra intencion de desarrollar        '
	dc.b	'otros productos para los ordenadores    '
	dc.b	'de Atari con un precio muy barato.      '
	dc.b	'                                        '
	dc.b	'Los derechos de matriculacion para      '
	dc.b	'este juego de centipede son 1000 pts.   '
	dc.b	'Su matriculacion para este producto     '
	dc.b	'garatizara el desarrollo de productos en'
	dc.b	'el futuro por desarollos siniestros.    '
	dc.b	'                                        '
	dc.b	'Tambien se dispone del ensamblador      '
	dc.b	'(68000) del programma.                  '
	dc.b	'                                        '
	dc.b	'Si vd quiere recibir el ensamlador      '
	dc.b	'los derechos de matriculacion son de    '
	dc.b	'2000 pts.                               '
	dc.b	'                                        '
	dc.b	'Toda la gente que han matriculado       '
	dc.b	'tendra la oportunidad de recibir        '
	dc.b	'nuestro proximo producto antes de la    ',-1
	dc.b	$FB
	dc.b	'distribucion general.                   '
	dc.b	'Dearrollos siniestros quieren           '
	dc.b	'desarrollar productos de interes a la   '
	dc.b	'gente que tienen los ordenadores de     '
	dc.b	'Atari. entonces mandennos sus ideas y   '
	dc.b	'quizas sera posible desarrolar el       '
	dc.b	'software.                               '
	dc.b	'                                        '
	dc.b	'postales internacionales a favor de     '
	dc.b	'desarrollos siniestros y envien a las   '
	dc.b	'envien a las direcciones siguientes ''   '
	dc.b	'                                        '
	dc.b	'Sinister Developments                   '
	dc.b	'16 (1f3) Downfield place                '
	dc.b	'Edinburgh                               '
	dc.b	'EH11 2EL                                '
	dc.b	'Scotland                                '
	dc.b	'Sinister Developments.                  '
	dc.b	'                                        '
	dc.b	'ÿ'
endc