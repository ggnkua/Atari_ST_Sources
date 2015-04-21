;------------------------------------------------------------------------
; Le but de ce programme est, … partir d'une image XGA cr‚e … partir de
; FramoGen++, de ne garder pour chaque point non plus sa couleur, mais
; l'indice de cette couleur dans le d‚grad‚...
; Ainsi la taille de l'image s'en trouve divis‚e par 2...
;------------------------------------------------------------------------
; Pour cela il faut mettre plus bas (entre les 2 ;***** ) le nom de
; l'image source et celui de l'image destination...
;------------------------------------------------------------------------

	opt	x+
	
	lea	deg,a0
	clr.w	d0
loop:	move.w	(a0)+,d1
	move.b	d0,(table,d1.w)
	addq.w	#1,d0
	cmpi.w	#256,d0
	bne.s	loop

	lea	img1,a1
	lea	img2,a2
	lea	table,a3
	move.l	#640*320,d0
zou:
	move.w	(a1)+,d1
	move.b	(a3,d1.w),d1
	move.b	d1,(a2)+
	
	subq.l	#1,d0
	bne.s	zou
	
	include	h:\demos\earth\make.dat\fichiers.t
	save	nom,img2,#204800
	
	clr.w	(sp)
	trap	#1
	
deg:	incbin	h:\demos\earth\make.dat\degrade.rip

;*****
img1:	incbin	"source.xga"
nom:	dc.b	"dest.xga",0
;*****

	section bss
img2:	ds.b	640*320*2
table:	ds.b	65536