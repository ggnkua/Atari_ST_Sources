;
; Basic Omikron & Assembleur.
; Retour du scan code … partir d'un INKEY$.
; ½ Start Micro & PJG / 1994.
;

	swap	d0	; Inversion du poids fort et du poids faible.
	and.l	#$ff,d0	; Annulation du poids fort.
	rts
	