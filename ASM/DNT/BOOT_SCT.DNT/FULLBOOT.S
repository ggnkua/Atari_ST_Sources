;Nb:heu, j'ai utilis‚ les abr‚viations dont je me sers tout le temps
;dans mes sources mais elles ne sont pas forc‚ment claires..
;Donc OVD=Overscan Droite,cad le passage 60/50Hz , OVG=Overscan Gauche
;cad le passage 71/50Hz et STB veut dire stabilisateur (entre les deux !)
;
;                     (C)oderight NulloS//DNT 1992
;
	opt	o+
TEST	equ	1
	IFEQ	TEST
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	move.l	d0,2(sp)
	move.l	$432.w,-(sp)
	move.l	#buffer,$432.w
	bsr.s	START
	move.l	(sp)+,$432.w
	trap	#1
	clr.w	(sp)
	trap	#1
	ENDC

START
	IFNE	TEST
	tst.b	$44c.w
	beq.s	boot_ok
	rts
	ENDC
boot_ok	move.l	$432.w,a5
	move.w	#$0556,$ffff8242.w
	move.l	#$03340002,$ffff8244.w

	lea	sinus_tab+16(pc),a2	;
mak_sincos	lea	sinus+16*8*2(a5),a1	;
	movea.l	a1,a0		;
	moveq	#15,d7		;D‚compacter 16 octets
	moveq	#$57,d0		;valeur de d‚part
sin_bcl0	move.b	-(a2),d4		;premiers incr‚ments
	moveq	#7,d6		;8 bits/octets
sin_bcl1	add.b	d4,d4		;d'abord les n‚gatifs
	bcc.s	*+4		;on d‚cr‚mente selon les
	subq.w	#1,d0		;bits … 1
	move.w	d0,-(a1)		;stockage
	move.w	d0,(a0)+		;
	dbf	d6,sin_bcl1	;bit suivant
	dbf	d7,sin_bcl0	;on a donc sin pour ]0..PI[
	moveq	#-1,d7		;recopie 256 valeurs
sin_bcl2	move.w	(a1)+,(a0)		;pour obtenir la seconde moiti‚.
	neg.w	(a0)+		;ca donne sin pour ]0..2PI[
	subq.b	#1,d7		;une de plus
	bcc.s	sin_bcl2		;Retenue=passage de $00 … $FF 
				;En sortie,A0=cod_genere(a5)

	move.w	#273+1,d0		;nombre de lignes fullscreen
	move.w	#$2540,d2		;pour le logo:move.l d0,d(a2)
	move.w	#$3089,d4		;pour l'overscan bas:60Hz
	move.w	#$2480,d5		;pour le logo:move.l d0,(a2)
	moveq	#%11110111,d6	;masque pour changement de Dn
	move.l	#$32894e71,d7	;move.w a1,(a1)/nop
	movea.w	#$328d,a1		;move.w a5,(a1)
	moveq	#51,d1		;nombre de nops...
	bsr.s	gennop		;                  (51 nops)
	movea.l	#$308d3088,a2	;move.w a5/a0,(a0)
	move.l	a2,(a0)+		;OVD               (4  nops)
	moveq	#13-4,d1		;puis attendre 13 nops
	bsr.s	gennop		;hop!              (9 nops)
	move.l	#$50f88240,(a0)+	;Couleur0=blanc    (4  nops)
	bra.s	Cresson		;pose du stabilisateur...
gencod_bcl	moveq	#0,d3		;offset pour affichage logo
	move.w	d5,(a0)+		;1 move.l du logo  (3  nops)
	moveq	#2,d1		;
	bsr.s	genmov		;2 move.l du logo  (8  nops)
	move.l	#$32893088,(a0)+	;OVG               (4  nops)
	move.w	#$328D,(a0)+	;(suite)           (2  nops)
	moveq	#22,d1		;22 move.l logo    (88 nops)
	bsr.s	genmov		;
	move.w	d7,(a0)+		;nop               (1  nop!)
	move.l	a2,(a0)+		;OVD	        (4  nops)
	moveq	#2,d1		;2  move.l logo    (8  nops)
	bsr.s	genmov		;
	move.l	#$45EA00E6,(a0)+	;lea 230(a2),a2    (2  nops)
	move.w	d4,(a0)+		;overscan bas      (2  nops)
	move.w	d7,(a0)+		;nop	        (1  nop!)
	addq.b	#1,d2		;registre de donn‚e suivant
	addq.b	#1,d5		;idem pour le premier transfert
	and.b	d6,d2		;bits 0-2 pour D0...D7
	and.b	d6,d5		;pour les deux types de move
	eori.b	#4,d4		;$4=$9 XOR $D
Cresson	move.l	d7,(a0)+		;STB               (5  nops)
	move.w	a1,(a0)+		;
	subq.w	#1,d0		;ligne suivante
	bne.s	gencod_bcl		;(en sortie D0.L=0 !!)
	move.w	#$4e75,(a0)+	;sans oublier le RTS
	bra.s	install		;suite du boot...

genmov	addq.w	#8,d3		;suite du logo
	move.w	d2,(a0)+		;move.w D?,
	move.w	d3,(a0)+		;          d(a2)
	subq.w	#1,d1		;un move de plus
	bne.s	genmov		;encore...
	rts			;

gennop	move.w	d7,(a0)+		;un nop de synchro...
	subq.w	#1,d1		;
	bne.s	gennop		;
	rts			;
	

install	move.l	$ffff8200.w,-(sp)	;ancienne adresse ‚cran
	pea	256(a0)		;‚cran derriŠre le code
	move.l	(sp)+,d1		;g‚n‚r‚...
	clr.b	d1		;multiple de 256
	move.l	d1,ad_screen(a5)	;stocke r‚sultat
	movea.l	d1,a0		;conserve pour cls
	lsr.w	#8,d1		;
	move.w	#(230*273+204)/4-1,d2	;efface ‚cran
cls	move.l	d0,(a0)+		;plus rapide que clr.l (a0)+
	dbf	d2,cls		;
	move.l	d1,$ffff8200.w	;fixe affichage
	move.l	$70.w,-(sp)	;sauvegarde
	move.l	$fffffa06.w,-(sp)	;
	clr.l	$fffffa06.w	;explose le MFP..
	pea	dummy_vbl(pc)	;installe VBL pipot
	move.l	(sp)+,$70.w	;

end_vbl	movea.l	$432.w,a6		;adresses variables
	addq.w	#8,(a6)		;vitesse horizontale
	move.w	(a6)+,d0		;
	addq.w	#6,(a6)		;idem verticale
	move.w	(a6)+,d1		;
	andi.w	#$3fe,d0		;formatte pour sinus
	andi.w	#$3fe,d1		;
	move.w	sinus-4(a6,d0.w),d0	;
	andi.w	#$0f,d0		;seuls les bits bas...
	move.w	sinus-4(a6,d1.w),d1	;
	moveq	#7,d7		;boucle et...
	and.w	d7,d1		;entre 0 et 7 !! 
	lea	$ffff820a.w,a0	;pr‚pare registres
	lea	$ffff8260.w,a1	;
	lea	mini_logo(pc),a2	;gfx
decalx_bcl	move.l	(a2)+,d2		;premiŠre ligne
	ror.w	d0,d2		;d‚cale plan 0
	swap	d2		;puis le plan 1
	ror.w	d0,d2		;
	bsr.s	rotate_reg		;‚change les registres
	dbf	d7,decalx_bcl	;8 lignes et donc 8 registres
decaly_bcl	bsr.s	rotate_reg		;rotationne les lignes
	dbf	d1,decaly_bcl	;selon la donn‚e y
	move.l	ad_screen-4(a6),a2	;prˆt … afficher
	lea	204(a2),a2		;
	stop	#$2300		;attente VBL
	clr.w	$ffff8240.w	;4
full_start	move.w	#$595,d7		;2
	dbf	d7,*		;4290+1
	clr.b	(a0)		;;;;;;;;;;;;2
	moveq	#(18-3)*2,d7	;1
	lsr.l	d7,d1		;2+15
	move.w	a0,(a0)		;;;;;;;;;;;;2
	lsr.l	d7,d1		;2+15
	moveq	#30,d1		;1
	sub.b	$ffff8209.w,d1	;3
	lsr.l	d1,d1		;2+??

	move.l	a3,d7		;1
	move.l	a4,d0		;1 ~ installe le logo
	exg.l	a5,d1		;2 ~ D1 est nul=>A5=0
	jsr	cod_genere-4(a6)	;5        ==9
;Il y a 60 nops avant le premier OVD.Donc encore 51 nops ...
	moveq	#0,d0		;
	btst	d0,$fffffc00.w	;clavier bavard ?
	beq.s	end_vbl		;non
FlushKey	move.b	$fffffc02.w,d1	;si,‚coute le...
	btst	d0,$fffffc00.w	;encore des choses … dire ?
	bne.s	FlushKey		;oui !
	move.l	(sp)+,$fffffa06.w
	move.l	(sp)+,$70.w
	move.l	(sp)+,$ffff8200.w
	rts

dummy_vbl	rte

rotate_reg	exg.l	d2,d3		;rotation des registres.
	exg.l	d3,d4		;Le sh‚ma est le suivant:
	exg.l	d4,d5		;D2<-D3<-D4<-D5<-D6
	exg.l	d5,d6		;^                |
	exg.l	d6,a3		;A5<-A4-<A3<------+
	exg.l	a3,a4		;Sert notament pour le
	exg.l	a4,a5		;scrolling vertical
	rts





;incr‚ments de la sinusoide
;les 2 plans du logo sont invers‚s en ordre pour gagner 2 octets lors
;du d‚calage en ror.w
mini_logo
	dc.w	%0000000000000001,%0011111111111110
	dc.w	%0111100111111111,%0000000000000001
	dc.w	%0100110110000011,%1000000100000001
	dc.w	%0101010010110111,%1001000000100111
	dc.w	%0101010100110111,%1001010100100101
	dc.w	%0100100110110111,%1000000100100101
	dc.w	%0111111110011111,%1001101100100101
;	dc.w	%1111111111111111,%1111111111111111
;Les deux derniers plans … $FFFF sont pr‚sents dans les incr‚ments
;de sinus_tab
sinus_tab
	dc.b	$ff,$ff,$ff,$ff,$ff,$df,$ef,$bd
	dc.b	$db,$b5,$aa,$aa,$52,$44,$40,$80


	RSRESET
x_scroll	rs.w	1		;pour avancer dans sinus
y_scroll	rs.w	1		;non initialis‚s (inutile)
ad_screen	rs.l	1

sinus	rs.w	128*4		;1 Ko de sinus
cod_genere	rs.b	134+132*273	;taille du code g‚n‚r‚
dummy	rs.b	256		;256 octets tampon
screen	rs.b	273*230+204	;‚cran.
mem_size	rs.b	1
;Au total, … peu prŠs 99,5Ko pris en m‚moire (bigre !)

FIN
	
	IFEQ	TEST
	SECTION	BSS
buffer	ds.b	mem_size
	ENDC