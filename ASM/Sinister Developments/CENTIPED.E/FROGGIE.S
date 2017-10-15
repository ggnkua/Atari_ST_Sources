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
	dc.b	'        Les details du shareware        '
	dc.b	'                                        '
	dc.b	'Ce produit de qualite a ete developpe   '
	dc.b	'pendant ces derniers mois. Nous avons   '
	dc.b	'l''intention de poursuivre le            '
	dc.b	'developpement d''autres produits de      '
	dc.b	'qualite pour le ordinateurs Atari, a    '
	dc.b	'un prix raisonnable.                    '
	dc.b	'Les frais d''enregistrement pour         '
	dc.b	'Centipede sont de l''ordre de cinq       '
	dc.b	'livres sterling. En vous enregistrant   '
	dc.b	'pour ce produit, vous garantissez le    '
	dc.b	'developpement futur de logiciels par    '
	dc.b	'Sinister Developments                   '
	dc.b	'                                        '
	dc.b	'Le code de source complet en assembler  '
	dc.b	'68000 pour ce logiciel est egalement    '
	dc.b	'disponible. Si vous voulez le recevoir  '
	dc.b	'les frais d''enregistrement seront de    '
	dc.b	'l''ordre de dix livres sterling.         '
	dc.b	'Tous les utilisateurs enregistres       '
	dc.b	'recevront notre prochain developpment   '
	dc.b	'avant sa distribution generale.         '
	dc.b	'ÿû'
	dc.b	'Les suggestions sont toujours les       '
	dc.b	'bienvenues en vue de developpments      '
	dc.b	'futurs. Nous pourrions meme decider     '
	dc.b	'de mettre en oeuvre votre idee :        '
	dc.b	'veuillez adresser tout paiement         '
	dc.b	'(cheque, ordre de paiment, virement     '
	dc.b	'international) au nom de sinister       '
	dc.b	'developments a l''adresse suivante !     '
	dc.b	'                                        '
	dc.b	'16 (1f3) Downfield Place                '
	dc.b	'Edinburgh                               '
	dc.b	'Eh11 2El                                '
	dc.b	'Scotland                                '
	dc.b	'Sinister Developments.                  '
	dc.b	'ÿ'

endc