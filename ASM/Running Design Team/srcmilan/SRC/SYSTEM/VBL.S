

		text


; ---------------------------------------------------------
; berechnet den faktor zwischen vsync und 1000.
; muss immer dann ausgefuehrt werden, wenn die aufloesung
; neu gesetzt/gewechselt wird.
; x = 1000 / (vsync pro sekunde)
calcVblFactor
		fmove.w	#20,fp0
		fmove.x	fp0,vblFactorX

		rts



		data



		bss


vblTime		ds.w	1		; anzahl verstrichener vbls seit letztem bildaufbau
vblTime20	ds.w	1		; anzahl ... (relativ zu 50 vbls pro sekunde)
vblTime1000	ds.w	1		; anzahl ... (relativ zu 1000 vbls pro sekunde), entspricht msek.
vblFactorX	ds.b	12
