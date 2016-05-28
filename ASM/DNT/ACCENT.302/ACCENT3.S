*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*                              ACCENT 3.2                                 *
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷(C)oderigth NulloS\\DNT-Crew 09/1993*
	OUTPUT	.PRG

	SECTION	TEXT
depart	bra.w	start
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

bios_conin	movem.l	d1/d2/a1,-(sp)	;Appel au bios, donc sauve ce
	move.l	#$20002,-(sp)	;qui doit l'ˆtre parmi D0-D2/A0-A2
patch1	move.w	#$b4,-(sp)		;Stackframe 030:offset trap #13
	pea	retour(pc)		;
	move.w	sr,-(sp)		;
jmp_old	movea.l	ANC_TRAP(pc),a0	;
	jmp	(a0)		;go!
retour	addq.l	#4,sp		;
	movem.l	(sp)+,d1/d2/a1	;Restauration complŠte.
	rts			;

read_it	bsr.s	bios_conin		;Demande un caractŠre … Bconin
	lea	tab_info(pc),a0	;
	lea	tab_accents(pc),a1	;
	moveq	#0,d1		;
	moveq	#0,d2		;
	move.b	(a0)+,d2		;Nombre de touches mortes
deadkey	move.b	(a0)+,d1		;
	cmp.b	(a0)+,d0		;Trouv‚ ?
	beq.s	traite		;
	add.w	d1,d1		;Non, avance dans la table
	adda.w	d1,a1		;des accents.
	dbf	d2,deadkey		;
	rte			;Rien du tout: retour normal.

traite	move.l	d0,d2		;Sauve le 1er caractŠre
	bsr.s	bios_conin		;DeuxiŠme caractŠre, qu'il faut
cherche	cmp.b	(a1)+,d0		;accentuer si possible.
	beq.s	accentuer		;
	addq.w	#1,a1		;
	subq.w	#1,d1		;
	bne.s	cherche		;
	cmp.b	d0,d2		;Double accentuation=caractŠre
	beq.s	doubl‚		;d'accentuation lui-mˆme.
	lea	sauve_code(pc),a0	;
	move.l	d0,(a0)		;Sinon ben stocke pour prochain
doubl‚	move.l	d2,d0		;appel, afin de ne rien perdre.
	rte			;Et retourne D2=le premier.

accentuer	moveq	#0,d0		;On a trouv‚ !
	move.b	(a1)+,d0		;Donc renvoie l'‚quivalent
	rte			;(scan-code inexistant)

sauve_code	dc.l	0

tab_info	dc.b	8-1		;8 touches mortes
	dc.b	5,'^'		;5 accentuations par circonflexe
	dc.b	9,'¹'		;9 ------------- --- tr‚ma
	dc.b	6,'`'		;6 ------------- --- grave
	dc.b	6,'~'		;6 ------------- --- tilde
	dc.b	2,'ø'		;2 ------------- --- rond
	dc.b	16,'|'		;  CaractŠres bizarro‹des
	dc.b	22,'#'		;  Alphabet h‚breux
	dc.b	13,'@'		;  Alphabet grec (en partie)

tab_accents
	dc.b	"aƒeˆiŒo“u–"	;"aeiou"     -> "ƒˆŒ“–"
	dc.b	"a„e‰i‹AŽo”O™Ušuy˜"	;"aeiAoOUuy" -> "„‰‹Ž”™š˜"
	dc.b	"o•u—eŠia…A¶"	;"oueiaA"    -> "•—Š…¶"
	dc.b	"n¤N¥a°o±A·O¸"	;"nNaoAO"    -> "¤¥°±·¸"
	dc.b	"a†A"		;"aA"        -> "†"
	dc.b	"o³O²c›Y?¨+ñ>ò<ó=ð*ßEîUï/ö~÷(ô)õ" ;Zarbi, vous avez dit zarbi ?
	dc.b	"aÂbÃcÄdÅeÆfÇgÈhÉiÊjËkÌlÍmÎnÏoÐpÑqÒrÓsÔtÕuÖv×" ;Vive l'h‚breux
	dc.b	"aàbáGâdëD0émæpãsåSätçFíOê" ;un bout de l'alphabet grec

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷*
FinTSR	equ	*
	EVEN
start	clr.l	-(sp)		;superviseur
	move.w	#$20,-(sp)		;hop
	trap	#1		;
	move.l	d0,2(sp)		;direct appel Super suivant
	move.l	$5a0.w,d0		;Recherche du cookie _CPU
	movea.l	d0,a0		;
	beq.s	cpu_68000		;pas de jar->STF->68000
scanjar	move.l	(a0)+,d0		;
	addq.l	#4,a0		;<conserve CCR>
	beq.s	cpu_68000		;Pas trouv‚->STF
	cmpi.l	#"_CPU",d0		;Cookie _CPU ?
	bne.s	scanjar		;
trouv‚	move.l	-(a0),d7		;68000=000
	beq.s	cpu_68000		;
	cmpi.w	#030,d7		;68030=030
	beq.s	cpu_68030		;

cpu_err	lea	bad_cpu(pc),a6	;
	trap	#1		;Sortie en erreur...
	pea	(a6)		;affiche
	move.w	#9,-(sp)		;vroom
	trap	#1		;hop
	move.w	#7,(sp)		;
	trap	#1		;Attente clavier.
	clr.w	(sp)		;maintenant,cassos
	trap	#1

cpu_68000	subq.w	#2,patch0		;Si 68000, vire les sp‚cificit‚s
	move.l	#$4e714e71,patch1	;du code 030.
cpu_68030	movea.l	$b4.w,a0		;cherche vecteur BIOS
looxbra	cmpi.l	#"XBRA",-12(a0)	;XBRA chunck ?
	bne.s	mise_en_place	;non,on est pas l…
	cmpi.l	#"ACC3",-8(a0)	;c'est nous ?
	movea.l	-4(a0),a0		;prochain XBRA,<conserve CCR>
	bne.s	looxbra		;c'etait pas nous
	lea	deja_la(pc),a6	;si,c'‚tait nous
	bra.s	cpu_err+4		;


mise_en_place
	lea	XBRAbase(pc),a0	;Installe routines dans la
	lea	-128-4(a0),a1	;ligne de commande de notre
binst	move.b	(a0)+,(a1)+	;BasePage.Attention, surtout
	cmpa.l	#FinTSR,a0		;ne pas se servir de la DTA
	bne.s	binst		;(FSFIRST et autres) sinon la
				;ligne de commande est ‚cras‚e.

	tst.w	d7		;68030 ?
	bne.s	.030		;
.000	move.l	$b4.w,ANC_TRAP-128-4	;Installation 68000.
	move.l	#NEW_TRAP-128-4,$b4.w	;
	bra.s	.fini		;
.030	lea	$b4.w,a0		;
	lea	ANC_TRAP-128-4(pc),a1	;Installation tout en
	move.l	#NEW_TRAP-128-4,d1	;douceur avec le 030.
.wait	cas2.l	d0:d2,d1:d0,(a0):(a1)	;
	bne.s	.wait		;

.fini	trap	#1		;repasse en user
	pea	en_place(pc)	;affiche une petite bienvenue
	move.w	#9,-(sp)		;
	trap	#1		;
	clr.w	(sp)		;fill-byte
	pea	FinTSR-XBRAbase+128.w	;taille … conserver
	move.w	#$31,-(sp)		;PtermRes
	trap	#1		;go!


	SECTION	DATA
en_place	dc.b	13,10,27,"pAccent 3.2 is alive !",27,"q"
	dc.b	13,10,"(C)oderight NulloS\\DNT-Crew 11/1993"
	dc.b	13,10,"(C)redits:  F‚roce Lapin"
	dc.b	13,10,"            Megar\\BINARIS"
	dc.b	13,10,0
deja_la	dc.b	7,13,10,27,"pAccent 3.2 d‚j… r‚sident...",27,"q",13,10,0
bad_cpu	dc.b	7,13,10,27,"pAccent 3.2",27,"q fonctionne uniquement avec les"
	dc.b	13,10,"processeurs 68000 et 68030 !..",13,10,0

