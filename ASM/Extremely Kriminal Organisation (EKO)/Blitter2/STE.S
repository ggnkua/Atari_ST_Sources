; macro pour scrollhard(STE)
; 08/02/94
; ½Createur/EKO

; 0<=X<=15
offsetpixel:	macro x
	ifnc "\1","#0"
	move.b	\1,$ffff8265.w
	else
	clr.b	$ffff8265.w
	endc
	endm
; x en mot !
offsetligne:	macro x
	ifnc "\1","#0"
	move.b	\1,$ffff820f.w
	else
	clr.b	$ffff820f.w
	endc
	endm

; adr est un tampon contenant l'adr a afficher
; (pris en compte a la prochaine vbl)
adrecran:	macro adr
	move.b \1+1,$ffff8201.w
	move.b \1+2,$ffff8203.w
	move.b \1+3,$ffff820d.w
	endm

; adr est un tampon contenant l'adr a afficher
adrcompteur:	macro adr
	move.b \1+1,$ffff8205.w
	move.b \1+2,$ffff8207.w
	move.b \1+3,$ffff8209.w
	endm


; 10/03/92
; Macro blitter
; ½Createur/EKO


*long=x
*offsety=160-(long*offsetx)+offsetx

;lancement du blitter
startblit:	macro
	ifnc "\1",""
	move.b \1,$ffff8a3c.w
	else
	move.b #%11000000,$ffff8a3c.w
	endc
	endm

;lancement du blitter:avec les inters!
startblitinter:	macro
	move.b #%10000000,$ffff8a3c.w
	nop
.relance\@
	bset.b	#7,$ffff8a3c.w
	nop
	bne.s	.relance\@
	endm



;adr ->adr du masque	
demiteinte:	macro regadr
	ifnc "\1",""
	move.l (\1)+,$ffff8a00.w
	move.l (\1)+,$ffff8a04.w
	move.l (\1)+,$ffff8a08.w
	move.l (\1)+,$ffff8a0c.w
	move.l (\1)+,$ffff8a10.w
	move.l (\1)+,$ffff8a14.w
	move.l (\1)+,$ffff8a18.w
	move.l (\1)+,$ffff8a1c.w
	endc
	endm

demiteinte	equ	$ffff8a00

offsetxs:	macro x
	ifnc "\1","#0"
	move.w	\1,$ffff8a20.w
	else
	clr.w	$ffff82a20.w
	endc
	endm

offsetxd:	macro x
	ifnc "\1","#0"
	move.w	\1,$ffff8a2e.w
	else
	clr.w	$ffff8a2e.w
	endc
	endm

source: 	macro adr
	move.l \1,$ffff8a24.w
	endm

destination:	macro adr
	move.l \1,$ffff8a32.w
	endm

offsetys:	macro x
	ifnc "\1","#0"
	move.w	\1,$ffff8a22.w
	else
	clr.w	$ffff8a22.w
	endc
	endm

offsetyd:	macro x
	ifnc "\1","#0"
	move.w	\1,$ffff8a30.w
	else
	clr.w	$ffff8a30.w
	endc
	endm

longueur:	macro x
	ifnc "\1","#0"
	move.w	\1,$ffff8a36.w
	else
	clr.w	$ffff8a36.w
	endc
	endm

hauteur:	macro x
	ifnc "\1","#0"
	move.w	\1,$ffff8a38.w
	else
	clr.w	$ffff8a38.w
	endc
	endm

;x est compris entre 0 et 3:
;0=plein($ff)
;1=demi-teinte
;2=source
;3=source et demi-teinte
op:		macro x
	ifnc "\1","#0"
	move.b	\1,$ffff8a3a.w
	else
	clr.b	$ffff8a3a.w
	endc
	endm

;x est compris entre 0 et 15
;0=efface($0)
;3=transfert
;6=souce "en dessous" de la destination
;7=sprite
;15=pleins($ff) 
oplog:		macro x
	ifnc "\1","#0"
	move.b	\1,$ffff8a3b.w
	else
	clr.b	$ffff8a3b.w
	endc
	endm

nfsr	equ	%1000000
fxsr	equ	%10000000

skew:	macro x
	ifnc "\1","#0"
	move.b	\1,$ffff8a3d.w
	else
	clr.b	$ffff8a3d.w
	endc
	endm
* skew est lance par defaut en "non partage du bus de donnee"
* si on lui donne un autre aordre,il l'execute.

masque:		macro adr
	ifnc "\1",""
	move.l \1,$ffff8a28.w
	move.w \1+4,$ffff8a2c.w
	endc
	endm

mask1:		macro adr
	ifnc "\1","#0"
	move.w	\1,$ffff8a28.w
	else
	clr.w	$ffff8a28.w
	endc
	endm
mask2:		macro adr
	ifnc "\1","#0"
	move.w	\1,$ffff8a2a.w
	else
	clr.w	$ffff8a2a.w
	endc
	endm
mask3:		macro adr
	ifnc "\1","#0"
	move.w	\1,$ffff8a2c.w
	else
	clr.w	$ffff8a2c.w
	endc
	endm


* Ca sert saouvent.	
* debpixel:
; bout.
*	dc.w	%1111111111111111
*	dc.w	%0111111111111111
*	dc.w	%0011111111111111
*	dc.w	%0001111111111111
*	dc.w	%0000111111111111
*	dc.w	%0000011111111111
*	dc.w	%0000001111111111
*	dc.w	%0000000111111111
*	dc.w	%0000000011111111
*	dc.w	%0000000001111111
*	dc.w	%0000000000111111
*	dc.w	%0000000000011111
*	dc.w	%0000000000001111
*	dc.w	%0000000000000111
*	dc.w	%0000000000000011
*	dc.w	%0000000000000001
*	dc.w	0

*finpixel:
*	dc.w	0
*	dc.w	%1000000000000000
*	dc.w	%1100000000000000
*	dc.w	%1110000000000000
*	dc.w	%1111000000000000
*	dc.w	%1111100000000000
*	dc.w	%1111110000000000
*	dc.w	%1111111000000000
*	dc.w	%1111111100000000
*	dc.w	%1111111110000000
*	dc.w	%1111111111000000
*	dc.w	%1111111111100000
*	dc.w	%1111111111110000
*	dc.w	%1111111111111000
*	dc.w	%1111111111111100
*	dc.w	%1111111111111110
*	dc.w	%1111111111111111


