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

crap 	dc.b	$fb
;		 0123456789012345678901234567890123456789
	dc.b	'         Auskunft _ber Shareware        '
	dc.b	'         =======================        '
	dc.b	'                                        '
	dc.b	'Dieses Qualit]tsprodukt ist w]hrend der '
	dc.b	'letzen paar Monaten entwickelt worden.  '
	dc.b	'Wir haben es vor, weitere               ' 
	dc.b	'Qualit]tsprodukte f_r die ATARI ST      '
  	dc.b	'Computerserie zu produzieren. Diese     '
	dc.b	'Produkte werden sehr preiswert sein.    '
	dc.b	'                                        '
	dc.b	'Die  Anmeldegeb_hr f_r Centipede ist    '
	dc.b	'F_nf Pfund Sterling. Wenn man f_r dieses'
	dc.b	'Produkt registriert, garantiert man die '
	dc.b	'Produktion der Software von Sinister    '
	dc.b	'Developements im Zukunft. Aller         '
	dc.b	'eingetragene Benutzer werden unser      '
	dc.b	'n]chstes Produkt bekommen, bevor es     '
	dc.b	'herausgebracht wird.                    '
	dc.b	'                                        '
	dc.b	'                                        '
	dc.b	'                                        '
	dc.b	'                                        '
	dc.b	'     -Dr_cken Sie bitte eine Taste-     ',-1
 	dc.b	$fb
	dc.b	'Der 68000 Assembler Sourcecode f_r      '
	dc.b	'dieses Programm steht auch zur          '
	dc.b	'Uerf_gung. Wenn Sie die Quelle bekommen '
	dc.b	'm^chten,sollten die uns die             '
	dc.b	'Anmeldegeb_hr von zehn Pfund Sterling   '
	dc.b	'schicken.                               '
	dc.b	'                                        '
	dc.b	'Vorschl]ge f_r zuk_nftige Produktionen  '
	dc.b	'bekommen wir auch gern. Vielleicht      '
	dc.b	'werden wir uns zwar entscheiden, Ihre   '
	dc.b	'Idee zu benutzen!                       '
	dc.b	'Bitte stellen Sie alle Schecks/Auslands-'
	dc.b	'weisunge auf Sinister Developments aus:-'
	dc.b	'                                        '
	dc.b	'16 (1f3) Downfield Place                '
	dc.b	'Edinburgh                               '
	dc.b	'EH11 2EL                                '
	dc.b	'Scotland                                '
	dc.b	'                                        '
	dc.b	'       Wir danken Ihnen f_r Ihren       '
	dc.b	'             Aufmerksamkeit.            ' 
	dc.b	'     -Dršcken Sie bitte eine Taste-     ',-1
endc      