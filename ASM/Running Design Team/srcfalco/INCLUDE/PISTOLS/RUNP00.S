
;**************************************
;* 
;* include-file fuer
;* pistdata.s
;* 
;* (c) 1996 by tarzan boy
;*
;**************************************



pistol_pfile	dc.b	"g:\running\digitali.zed\fuss\runp00.tpi",0
pistol_dfile	dc.b	"g:\running\data\dukefoot.dat",0

pic_breite	dc.w	320		; bildbreite in pixel

anim_dat	dc.l	0
		dc.l	anim_dat_1	
		dc.l	anim_dat_0
		dc.l	0

; alle anim_dat_x-angaben in pixel


anim_dat_0	dc.w	0,89		; linke untere ecke (x,y)
		dc.w	123,90		; absolute breite und hoehe
		dc.w	140		; screen_xoffi
		dc.w	%00		; flags:
					;  bit 0: waffe schwankt in x-richtung
					;  bit 1: waffe schwankt in y-richtung

anim_dat_1	dc.w	128,108		
		dc.w	110,109		
		dc.w	140
		dc.w	%00





