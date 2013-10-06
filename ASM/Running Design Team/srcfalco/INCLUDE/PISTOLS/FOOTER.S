
;**************************************
;* 
;* include-file fuer
;* pistdata.s
;* 
;* (c) 1996 by tarzan boy of stax
;*
;**************************************


; datenfile fuer pistolentyp: duke nukem 3d foot (ripped out)


pistol_pfile	dc.b	"e:\running\tpi\footer3.tpi",0
pistol_dfile	dc.b	"e:\running\data\weapons\footer.dat",0

pic_breite	dc.w	320		; bildbreite in pixel

anim_dat	dc.l	anim_dat_1
		dc.l	anim_dat_1	
		dc.l	anim_dat_0
		dc.l	anim_dat_1

; alle anim_dat_x-angaben in pixel


anim_dat_0	dc.w	0,97		; linke untere ecke (x,y)
		dc.w	64,98		; absolute breite und hoehe
		dc.w	166		; screen_xoffi
		dc.w	%00		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_1	dc.w	64,47		
		dc.w	150,48		
		dc.w	156
		dc.w	%00





