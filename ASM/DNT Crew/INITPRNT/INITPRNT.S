;Petite initialisation de l'imprimante, destin‚e … ˆtre utilis‚e
;en tant que Tools avec Devpac.
;
;(C)odelame Nullos/DNT-Crew 1994.
;
	include	tos_030.s
	output	.tos

	section	text
	pea	hello(pc)
	Gemdos	Cconws
	lea	init(pc),a6
	moveq	#initsize-1,d6
send	moveq	#0,d0
	move.b	(a6)+,d6
	move.w	d6,-(sp)
	Gemdos	Cprnout
	dbf	d6,send
	Gemdos	Pterm

	section	data
hello	dc.b	$d,$a,"Imprimante en condens‚, caractŠres graphiques IBM, tabulation=11",$d,$a,0

init	dc.b	27,116,1,27,54	;Graphiques IBM
	dc.b	27,15		;Condens‚
	dc.b	27,101,0,11	;Tabulation 11
	dc.b	$d,$a		;Pof, ex‚cution!
initsize	equ	*-init
