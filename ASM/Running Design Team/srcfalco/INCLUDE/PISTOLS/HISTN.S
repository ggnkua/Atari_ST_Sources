
;**************************************
;* 
;* include-file fuer
;* pistdata.s
;* 
;* (c) 1996 by tarzan boy of stax
;*
;**************************************


; datenfile fuer pistolentyp: histn


pistol_pfile	dc.b	"g:\running\tpi\histn.tpi",0
pistol_dfile	dc.b	"g:\running\data\histn.dat",0

pic_breite	dc.w	320		; bildbreite in pixel

anim_dat	dc.l	anim_dat_0	; zeiger auf die entsprechenden
		dc.l	anim_dat_1	; animationsdaten. wenn 0, dann
		dc.l	anim_dat_2	; fuer diese phase kein
		dc.l	anim_dat_3	; bild zur verfuegung.


; alle anim_dat_x-angabe in pixel


anim_dat_0	dc.w	0,63		; linke untere ecke (x,y)
		dc.w	70,64		; absolute breite und hoehe
		dc.w	166		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_1	dc.w	240,79+16	; ???		
		dc.w	70,64	
		dc.w	166
		dc.w	%11

anim_dat_2	dc.w	80,76	
		dc.w	79,77		
		dc.w	168
		dc.w	%11

anim_dat_3	dc.w	160,76		
		dc.w	75,77		
		dc.w	170
		dc.w	%11
