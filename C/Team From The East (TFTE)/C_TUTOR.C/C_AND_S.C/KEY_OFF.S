;MARCHEW FOR T.F.T.E
;PROCEDURA WYLACZJACA SYGNAL KLAWISZA   

	.EXPORT key_off;    potrzebne dla C (to bedzie procedura)

;deklaracja supervisora
key_off:

	clr.l -(sp)				
	move.w #$20,-(sp)		
	trap #1					

;kasuje klawiature
	bclr #0,$484.w

;wyjscie Trapem
	clr.w -(sp)
	trap #1
	
	
