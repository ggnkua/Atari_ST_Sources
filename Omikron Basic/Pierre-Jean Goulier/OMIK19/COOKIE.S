;
; Basic Omikron & Assembleur.
; Lecture d'un Cookie dans le Cookie-Jar.
; ½ Start Micro & PJG / 1994.
;
; Informations sur les Cookies :
; Cookies de machine :
;
;	CPU	: _CPU	00 (68000 : ST, STE, Mega STE)
;			10 (68010 : Rare)
;			20 (68020 : Rare)
;			30 (68030 : TT, Falcon)
;
;	Vid‚o	: _VDO  $00000000 (ST)
;			$00010000 (STE, scrolling hardware)
;			$00010001 (STBook)
;			$00020000 (TT)
;			$00030000 (Falcon)
;
;	Son	: _SND	0 (PSG Yamaha : tous modŠles)
;			1 (8 bits DMA : STE, TT, Falcon)
;			2 (16 bits Codec : Falcon)
;			3 (DSP : Falcon)
;			4 (Matrix : Falcon)
;
;	Machine	: _MCH	$00000000 (ST)
;			$00010000 (STE, Mega STE)
;			$00010001 (STBook)
;			$00020000 (TT)
;			$00030000 (Falcon)
;
;	Switches: _SWI	$00 (ST)
;			$BF (Falcon)
;			$FF (TT)
;
; Cookies exceptionnels :
;
;	_FRB	: Signale la pr‚sence de la Fast Ram (TT).
;	_FDC	: Signale la pr‚sence d'un lecteur HD.
;			$00000000 : Non (720 Ko)
;			$00010xxx : Haute Densit‚ (1.44 Mo)
;			$00020xxx : Extra Haute Densit‚ (2.88 Mo)
;			xxx : Origine du systŠme => "ATC" (AJAX)
;						    "DP1" (Dream Park)
;	_FPU	: Signale la pr‚sence du coprocesseur arithm‚tique.
;	_PWR	: Sur STBook, signale la pr‚sence d'un gestionnaire
;		  de consommation.
;	_NET	: Signale la pr‚sence d'un r‚seau.
;	MINT	: Signale la pr‚sence de MultiTOS.
;	NVDI	: Signale la pr‚sence de NVDI.
;	_SLM	: Signale la pr‚sence de DIABLO 630.
;	_AFM	: Signale la pr‚sence d'Audio Fun Machine.
;	_JPD	: Signale la pr‚sence du d‚codeur JPEG.



cookie	EQU	$5A0
	
	move.l	cookie,a6	; Le contenu du Jar => A6.
loop:	move.l	(a6)+,d1	; Cookie => D1.
	tst	d1		; Existe t'il ?
	beq.s	no		; Non, pas de cookie.
	cmp.l	d0,d1		; Sinon, est-ce le bon ?
	beq.s	good		; Oui...
	add.l	#4,a6		; Non, cookie suivant.
	bra	loop
good:	move.l	(a6),d0		; Oui, quel valeur du cookie ?
	bra	exit
no:	move.l	#-1,d0		; Pas de cookie
exit:	rts
	