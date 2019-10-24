; Sources de r‚solutions ‚tendues pour Falcon 030.
; (c)oderight 1995 Zerkman/Trisomic Development
; ne fonctionne que sur moniteur RGB ou sur TV UNIQUEMENT!
; d‚sol‚, je n'ai pas de VGA... Peut-ˆtre pour bient“t ?

; mode d'emploi:
;	lea	h_256_tc(pc),a0	;mode horizontal True Color 256 pixels ‚largi
;	lea	v_256(pc),a1	;mode vertical 256 lignes
;	bsr	install_reso	;installe le mode correspondant

vvrap	equ	$ffff820e
vwidth	equ	$ffff8210
spshift	equ	$ffff8266
hht	equ	$ffff8282
hbb	equ	$ffff8284
hbe	equ	$ffff8286
hdb	equ	$ffff8288
hde	equ	$ffff828a
hss	equ	$ffff828c
vft	equ	$ffff82a2
vbb	equ	$ffff82a4
vbe	equ	$ffff82a6
vdb	equ	$ffff82a8
vde	equ	$ffff82aa
vss	equ	$ffff82ac
rco	equ	$ffff82c0
vco	equ	$ffff82c2

	clr.l	-(sp)
	move	#32,-(sp)
	trap	#1		;passe en mode superviseur
	addq.l	#6,sp
	move.l	d0,-(sp)

; Sauvegarde de l'‚tat initial des registres:
	lea	save_regs(pc),a0
	move.w	vvrap.w,(a0)+
	move.w	vwidth.w,(a0)+
	move.w	spshift.w,(a0)+
	move.w	hht.w,(a0)+
	move.w	hbb.w,(a0)+
	move.w	hbe.w,(a0)+
	move.w	hdb.w,(a0)+
	move.w	hde.w,(a0)+
	move.w	hss.w,(a0)+
	move.w	vft.w,(a0)+
	move.w	vbb.w,(a0)+
	move.w	vbe.w,(a0)+
	move.w	vdb.w,(a0)+
	move.w	vde.w,(a0)+
	move.w	vss.w,(a0)+
	move.w	rco.w,(a0)+
	move.w	vco.w,(a0)+

	bsr	vsync

	lea	h_832_tc(pc),a0	;mode horizontal True Color 832 pixels
	lea	v_592i(pc),a1	;mode vertical 592 lignes entrelac‚es
	bsr	install_reso

	move	#7,-(sp)
	trap	#1		;attente de l'appui d'une touche
	addq.l	#2,sp

	bsr	vsync

; R‚tablissement de l'‚tat initial des registres:
	lea	save_regs(pc),a0
	move.w	(a0)+,vvrap.w
	move.w	(a0)+,vwidth.w
	move.w	(a0)+,spshift.w
	move.w	(a0)+,hht.w
	move.w	(a0)+,hbb.w
	move.w	(a0)+,hbe.w
	move.w	(a0)+,hdb.w
	move.w	(a0)+,hde.w
	move.w	(a0)+,hss.w
	move.w	(a0)+,vft.w
	move.w	(a0)+,vbb.w
	move.w	(a0)+,vbe.w
	move.w	(a0)+,vdb.w
	move.w	(a0)+,vde.w
	move.w	(a0)+,vss.w
	move.w	(a0)+,rco.w
	move.w	(a0)+,vco.w

	move	#32,-(sp)
	trap	#1		;passe en mode utilisateur
	addq.l	#6,sp

	clr	-(sp)
	trap	#1		;fin du programme


install_reso
	move.w	(a0)+,d0
	or	(a1)+,d0
	move.w	d0,vco		; D‚finitions horizontales, entrelacement, double ligne
	move	(a0)+,spshift	; Registre d‚finissant le nombre de couleurs
	move	(a0)+,d1
	btst	#1,d0		; Mode entrelac‚ ?
	beq.s	.pas_entrelace
	bset	#3,d1		; alors on trafique le bit 3 de RCO
.pas_entrelace
	move	d1,rco		; Bits de config vid‚o divers et vari‚s...
	move	(a0)+,vwidth	; Largeur de l'‚cran en mots
	movem.l	(a0)+,d0-d2
	movem.l	d0-d2,hht	; Les 6 registres de contr“le horizontaux
	movem.l	(a1)+,d0-d2
	movem.l	d0-d2,vft	; Les 6 registres de contr“le verticaux
	rts			; Et c'est fini !!!

vsync
	move	#37,-(sp)
	trap	#14		;synchro VBL
	addq.l	#2,sp
	rts

; Modes horizontaux
h_256_tc
	dc.w	$0,$100,$186,256
	dc.w	$c7,$7f,$48,$27,$7f,$b0
h_416_tc
	dc.w	$0,$100,$182,416
	dc.w	$ff,$ca,$27,$9,$ca,$d8
h_640_tc
	dc.w	$4,$100,$186,640
	dc.w	$18f,$141,$52,$21,$141,$160
h_832_tc
	dc.w	$4,$100,$182,832
	dc.w	$1ff,$1a3,$64,$33,$1a3,$1d0

h_256_256c
	dc.w	$0,$10,$186,128
	dc.w	$c7,$7f,$48,$15,$6d,$b0
h_416_256c
	dc.w	$0,$10,$181,208
	dc.w	$ff,$c9,$27,$2f6,$b7,$d8
h_640_256c
	dc.w	$4,$10,$186,320
	dc.w	$18f,$141,$52,$f,$12f,$160
h_832_256c
	dc.w	$4,$10,$182,416
	dc.w	$1ff,$1a3,$64,$21,$191,$1d0
h_1280_256c
	dc.w	$8,$10,$186,640
	dc.w	$18f,$13a,$4b,$19,$131,$160
h_1664_256c
	dc.w	$8,$10,$182,832
	dc.w	$1ff,$1a3,$64,$32,$19a,$1d0


h_256_16c
	dc.w	$0,$0,$186,64
	dc.w	$c7,$7f,$48,$5,$5d,$b0
h_416_16c
	dc.w	$0,$0,$182,104
	dc.w	$ff,$d1,$32,$2f0,$af,$e8
h_640_16c
	dc.w	$4,$0,$186,160
	dc.w	$18f,$141,$52,$390,$11f,$160
h_832_16c
	dc.w	$4,$0,$182,208
	dc.w	$1ff,$1a3,$64,$11,$181,$1d0
h_1280_16c
	dc.w	$8,$0,$186,320
	dc.w	$18f,$13a,$4b,$11,$129,$160
h_1664_16c
	dc.w	$8,$0,$182,416
	dc.w	$1ff,$1a3,$64,$2a,$192,$1d0

; Modes verticaux
v_240
	dc.w	$0
	dc.w	$271,$23b,$5b,$5b,$23b,$26b
v_256
	dc.w	$0
	dc.w	$271,$249,$49,$49,$249,$26b
v_296
	dc.w	$0
	dc.w	$27b,$26f,$21,$20,$270,$26f
v_496i
	dc.w	$2
	dc.w	$21E,$218,$24,$28,$218,$219
v_592i	
	dc.w	$2
	dc.w	$27A,$270,$22,$20,$270,$26F

	section	bss
save_regs
	ds.w	17