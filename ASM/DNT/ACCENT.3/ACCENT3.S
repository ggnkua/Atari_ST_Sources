*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*                               ACCENT 3                                  *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderigth NulloS\\DNT-Crew 06/1993*
	OUTPUT	.PRG

	SECTION	TEXT
depart	bra	start
XBRAbase	dc.b	"XBRA"
	dc.b	"ACC3"
ANC_TRAP	dc.l	0

patch0	equ	*+2
NEW_TRAP	lea	8(a7),a0		;Version 68030: 8 octets
	btst.b	#5,(a7)		;
	bne.s	supercall		;
	move.l	usp,a0		;

supercall	cmpi.w	#2,(a0)		;Appel Bconin ?
	bne.s	no_bconin		;
	cmpi.w	#2,2(a0)		;Clavier ?
	beq.s	bconin		;
	bra.s	jmp_old		;

no_bconin	cmpi.w	#1,(a0)+		;Bcostat ?
	bne.s	jmp_old		;
	cmpi.w	#2,(a0)		;Clavier ?
	bne.s	jmp_old		;
bcostat	lea	sauve_code(pc),a0	;Un caractŠre en suspens ?
	tst.l	(a0)		;
	beq.s	jmp_old		;non
	moveq.l	#-1,d0		;si, indique le
	rte			;

bconin	lea	sauve_code(pc),a1	;NOTRE Bconin
	move.l	(a1),d0		;Un caractŠre en attente ?
	beq.s	read_it		;
	clr.l	(a1)		;Donc on le vire: il est en D0
	rte			;maintenant (accentuation rat‚e)

bios_conin	move.l	a0,-(sp)		;Appel au bios, donc sauve ce
	move.l	d2,-(sp)		;qui le doit parmi D0-D2/A0-A2
	move.l	#$20002,-(sp)	;
patch1	move.w	#$b4,-(sp)		;Stackframe 030:offset trap #13
	pea	retour(pc)		;
	move.w	sr,-(sp)		;
jmp_old	movea.l	ANC_TRAP(pc),a0	;
	jmp	(a0)		;go!
retour	addq.l	#4,sp		;
	move.l	(sp)+,d2		;Reprend les registres.
	movea.l	(sp)+,a0		;
	rts			;

read_it	bsr.s	bios_conin		;Demande un caractŠre … Bconin
	move.l	d0,d2		;(le vrai). Conserve r‚sultat en
	lea	tab_circonflexe(pc),a0;D2
	cmpi.b	#"^",d0		;Selon l'accentuation demand‚e
	beq.s	traite		;
	lea	tab_trema(pc),a0	;
	cmpi.b	#"¹",d0		;
	beq.s	traite		;
	lea	tab_grave(pc),a0	;
	cmpi.b	#"`",d0		;
	beq.s	traite		;
	lea	tab_tilde(pc),a0	;
	cmpi.b	#"~",d0		;
	beq.s	traite		;
	rte			;Rien du tout: retour normal.

traite	bsr.s	bios_conin		;DeuxiŠme caractŠre, qu'il faut
	moveq	#0,d1		;accentuer si possible.
	move.b	(a0),d1		;Taille de la table des
	swap	d1		;lettres accentuables.
	move.b	(a0)+,d1		;
boucle	cmp.b	(a0)+,d0		;C'est celle-l… ?
	beq.s	find_it		;vi vi !
	dbf	d1,boucle		;
	cmp.b	d0,d2		;Double-accentuation=caractŠre
	beq.s	its_accent		;d'accentuation lui-mˆme.
	lea	sauve_code(pc),a1	;
	move.l	d0,(a1)		;Sinon ben stocke pour prochain
its_accent	move.l	d2,d0		;appel, afin de ne rien perdre.
	rte			;Et retourne D2=le premier.

find_it	moveq	#0,d0		;On a trouv‚ !
	swap	d1		;
	move.b	0(a0,d1.w),d0	;Donc renvoie l'‚quivalent
	rte			;(scan-code intact)

sauve_code	dc.l	0

tab_circonflexe
	dc.b	$05-1
	dc.b	'a','e','i','o','u'
	dc.b	$83,$88,$8c,$93,$96

tab_trema
	dc.b	$09-1
	dc.b	'a','e','i','A','o','O','U','u','y'
	dc.b	$84,$89,$8b,$8e,$94,$99,$9a,$81,$98

tab_grave
	dc.b	$06-1
	dc.b	'o','u','e','i','a','A'
	dc.b	$95,$97,$8a,$8d,$85,$b6

tab_tilde
	dc.b	$06-1
	dc.b	'n','N','a','o','A','O'
	dc.b	$a4,$a5,$b0,$b1,$b7,$b8
;--------------------------------------------------------
FinTSR	equ	*
	EVEN
start	clr.l	-(sp)		;superviseur
	move.w	#$20,-(sp)		;hop
	trap	#1		;
	move.l	d0,2(sp)		;direct appel Super suivant
	move.l	$5a0.w,d0		;Recherche du cookie _CPU
	movea.l	d0,a0		;
	beq.s	cpu_ok		;pas de jar->STF->68000
scanjar	move.l	(a0)+,d0		;
	addq.l	#4,a0		;<conserve CCR>
	beq.s	cpu_ok		;Pas trouv‚->STF
	cmpi.l	#"_CPU",d0		;Cookie _CPU ?
	bne.s	scanjar		;
trouv‚	move.l	-(a0),d0		;68000=000
	beq.s	cpu_ok		;
	cmpi.w	#030,d0		;68030=030
	bne.s	cpu_err		;
cpu_ok	tst.l	d0		;
	bne.s	no_patch		;
	subq.w	#2,patch0		;Si 68000, vire les sp‚cificit‚s
	move.l	#$4e714e71,patch1	;du code 030.
no_patch

	movea.l	$b4.w,a0		;cherche vecteur BIOS
cherche	cmpi.l	#"XBRA",-12(a0)	;XBRA chunck ?
	bne.s	mise_en_place	;non,on est pas l…
	cmpi.l	#"ACC3",-8(a0)	;c'est nous ?
	movea.l	-4(a0),a0		;prochain XBRA,conserve CCR
	bne.s	cherche		;c'etait pas nous
	lea	deja_la(pc),a6	;si,c'‚tait nous
	bra.s	cpu_err+4		;
cpu_err	lea	bad_cpu(pc),a6	;
	trap	#1		;Sortie en erreur...
	addq.l	#6,sp		;passe en user,r‚tablit pile
	pea	(a6)		;affiche
	move.w	#9,-(sp)		;vroom
	trap	#1		;hop
	move.w	#7,(sp)		;
	trap	#1		;Attente clavier.
	clr.w	(sp)		;maintenant,cassos
	trap	#1

mise_en_place
	move.l	$b4.w,ANC_TRAP	;ancienne vecteur du BIOS

	lea	XBRAbase(pc),a0	;Installe routines dans la
	lea	-128-4(a0),a1	;ligne de commande de notre
binst	move.b	(a0)+,(a1)+	;BasePage.Attention, surtout
	cmpa.l	#FinTSR,a0		;ne pas se servir de la DTA
	bne.s	binst		;(FSFIRST et autres) sinon la
				;ligne de commande est ‚cras‚e.

	move.l	#NEW_TRAP-132,$b4.w	;Nouveau vecteur.
	trap	#1		;repasse en user
	addq.l	#6,sp		;
	pea	en_place(pc)	;affiche une petite bienvenue
	move.w	#9,-(sp)		;
	trap	#1		;
	addq.l	#6,sp		;
	clr.w	-(sp)		;fill-byte
	pea	FinTSR-XBRAbase+128.w	;taille … conserver
	move.w	#$31,-(sp)		;PtermRes
	trap	#1		;go!


	SECTION	DATA
en_place	dc.b	13,10,27,"pAccent 3 is alive !",27,"q"
	dc.b	13,10,"(C)oderight NulloS\\DNT-Crew 06/1993"
	dc.b	13,10,"(C)redits:  F‚roce Lapin"
	dc.b	13,10,"            Megar\\BINARIS"
	dc.b	13,10,0
deja_la	dc.b	7,13,10,27,"pAccent 3 d‚j… r‚sident...",27,"q",13,10,0
bad_cpu	dc.b	7,13,10,27,"pAccent 3",27,"q fonctionne uniquement avec les"
	dc.b	13,10,"processeurs 68000 et 68030 !..",13,10,0

