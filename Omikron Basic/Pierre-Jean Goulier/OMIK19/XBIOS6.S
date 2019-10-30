;
; Basic Omikron & Assembleur
; Routine ‚mulant l'XBIOS 6.
; ½ Start Micro & PJG / 1994.
;
	move.l	4(sp),a6	; Adresse de la palette => A6.
	move	#0,d6		; D6 = Compteur des couleurs.
loop:	move	(a6)+,-(sp)	; Fixation des couleurs 1 … 1...
	move	d6,-(sp)
	move	#7,-(sp)	; avec l'XBIOS 7.
	trap	#14
	addq.l	#6,sp
	addq	#1,d6
	cmp	#16,d6
	bne.s	loop
	rts
	