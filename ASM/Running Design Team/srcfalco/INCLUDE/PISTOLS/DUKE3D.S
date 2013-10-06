
;**************************************
;* 
;* include-file fuer
;* pistdata.s
;* 
;* (c) 1996 by tarzan boy
;*
;**************************************


; datenfile fuer pistolentyp: duke nukem 3d (ripped out)


pistol_pfile	dc.b	"g:\running\tpi\dukepist.tpi",0
pistol_dfile	dc.b	"g:\running\data\dukepist.dat",0

pic_breite	dc.w	320		; bildbreite in pixel

anim_dat	dc.l	anim_dat_0	; zeiger auf die entsprechenden
		dc.l	anim_dat_1	; animationsdaten. wenn 0, dann
		dc.l	anim_dat_0	; fuer diese phase kein
		dc.l	anim_dat_2	; bild zur verfuegung.


; alle anim_dat_x-angabe in pixel


anim_dat_0	dc.w	144,67		; linke untere ecke (x,y)
		dc.w	64,68		; absolute breite und hoehe
		dc.w	166		; screen_xoffi
		dc.w	%11		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_1	dc.w	208,86		
		dc.w	74,87		
		dc.w	156
		dc.w	%11

anim_dat_2	dc.w	0,125		
		dc.w	137,126		
		dc.w	183
		dc.w	%10
