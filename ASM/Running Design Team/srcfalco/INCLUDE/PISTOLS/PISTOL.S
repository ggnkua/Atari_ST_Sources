
;**************************************
;* 
;* include-file fuer
;* pistdata.s
;* 
;* (c) 1996 by tarzan boy
;*
;**************************************


; datenfile fuer pistolentyp: pistol (sharewarewaffe 2)


pistol_pfile	dc.b	"e:\running\tpi\pistol2.tpi",0
pistol_dfile	dc.b	"e:\running\data\weapons\pistol.dat",0

pic_breite	dc.w	320		; bildbreite in pixel

anim_dat	dc.l	anim_dat_0	; zeiger auf die entsprechenden
		dc.l	anim_dat_1	; animationsdaten. wenn 0, dann
		dc.l	anim_dat_2	; fuer diese phase kein
		dc.l	anim_dat_3	; bild zur verfuegung.


; alle anim_dat_x-angabe in pixel


anim_dat_0	dc.w	0,63		; linke untere ecke (x,y)
		dc.w	56,64		; absolute breite und hoehe
		dc.w	138		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_1	dc.w	56,63		; linke untere ecke (x,y)
		dc.w	60,64		; absolute breite und hoehe
		dc.w	138		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_2	dc.w	116,63		; linke untere ecke (x,y)
		dc.w	72,64		; absolute breite und hoehe
		dc.w	138		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_3	dc.w	188,63		; linke untere ecke (x,y)
		dc.w	74,64		; absolute breite und hoehe
		dc.w	137		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

