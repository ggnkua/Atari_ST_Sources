
;**************************************
;* 
;* include-file fuer
;* pistdata.s
;* 
;* (c) 1996 by tarzan boy
;*
;**************************************


pistol_pfile	dc.b	"e:\running\tpi\flm.tpi",0
pistol_dfile	dc.b	"e:\running\data\weapons\flm.dat",0

pic_breite	dc.w	512		; bildbreite in pixel

anim_dat	dc.l	anim_dat_0	; zeiger auf die entsprechenden
		dc.l	anim_dat_1	; animationsdaten. wenn 0, dann
		dc.l	anim_dat_2	; fuer diese phase kein
		dc.l	anim_dat_3	; bild zur verfuegung.


; alle anim_dat_x-angabe in pixel


anim_dat_0	dc.w	0,69		; linke untere ecke (x,y)
		dc.w	76,70		; absolute breite und hoehe
		dc.w	150		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_1	dc.w	76,69		; linke untere ecke (x,y)
		dc.w	76,70		; absolute breite und hoehe
		dc.w	150		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_2	dc.w	152,69		; linke untere ecke (x,y)
		dc.w	76,70		; absolute breite und hoehe
		dc.w	150		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_3	dc.w	228,69		; linke untere ecke (x,y)
		dc.w	76,70		; absolute breite und hoehe
		dc.w	150		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

