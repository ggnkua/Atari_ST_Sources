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

crap	dc.b	$fb
	dc.b	'       I particolari di shareware       '
	dc.b	'                                        '
	dc.b	'Questo produtto la cui qualit>`         '
	dc.b	'ultima abbiamo svillupato durante gli   '
	dc.b	'ultimi pochi mesi. ` Nostra intenzione  '
	dc.b	'contunnare a scrwere altri produtti di  '
	dc.b	'ultima quali> per la serie di computer  '
	dc.b	'Atari per un presso ragionerule.        '
	dc.b	'Per rende2rvi un utente con la          '
	dc.b	'possibilit> di usave l''centipede        '
	dc.b	'dorrete pagare cinque sterline e cosi   '
	dc.b	'garantirete altri svillupi in futuro    '
	dc.b	'con sinister developments               '
	dc.b	'` anche disponabile l''elenco 68000      '
	dc.b	'assembler per questo programma.  Se     '
	dc.b	'vorreste ricevene il codice, il         '
	dc.b	'registrazione cio vi coster> duci       '
	dc.b	'sterline.                               '
	dc.b	'                                        '
	dc.b	'Tutti gli utenti registrati             '
	dc.b	'ricereranno il prossimo programma       '
	dc.b	'in anticipio. se arete bisogno          '
	dc.b	'di ulterrone informazioni o qualche     '
	dc.b	'suggerimento da darci, per favore       ',-1
	dc.b	$fb
	dc.b	'mettetevi in contatto con noi.          '
	dc.b	'Non si sa mai, potremmo decidere di     '
	dc.b	'prendene in considerazione la           '
	dc.b	'vostra idea.                            '
	dc.b	'                                        '
	dc.b	'Per favore rendete ogni, contante       '
	dc.b	'ordine postale,  ordine pagabile al     '
	dc.b	'sinister developments al sequente       '
	dc.b	'indirizzo.                              '
	dc.b	'                                        '
	dc.b	'16 (1f3) Downfield place                '
	dc.b	'Edinburgh                               '
	dc.b	'EH11 2EL                                '
	dc.b	'Scotland                                '
	dc.b	'Sinister Developments.                  ',-1
endc