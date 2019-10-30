;
; Basic Omikron & Assembleur.
; D‚tecter GDOS en m‚moire.
; ½ Start Micro & PJG / 1994
;
	moveq	#0,d1		; D1 = 0
	move	#$fffe,d0	; D0 = $FFFE
	trap	#2		; On appelle l'AES.
	cmp	#$fffe,d0	; Si D0 a boug‚,
	sne	d1		; D1 = $FF sinon D1 = 0
	move.l	d1,d0		; D0 = D1.
	rts			; Retour
	