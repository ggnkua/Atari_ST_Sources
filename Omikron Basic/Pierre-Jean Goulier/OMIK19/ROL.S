;
; Basic Omikron & Assembleur
; Routine de rotation d'‚cran.
; ½ Start Micro & PJG / 1994.
;
	
	move	#2,-(sp)	; Adresse de l'‚cran (Phys).
	trap	#14
	addq.l	#2,sp
	move.l	d0,a5		; Phys => A5
	move.l	a5,a6		; et Phys => A6.
	move	#7999,d0	; 32000 octets = 8000 LW.
	move	#31,d1		; 32 bits pour un LW.
	
loop:	move.l	(a6),d2		; 32 rotations pour les 32000 octets !
	rol.l	d2
	move.l	d2,(a6)+
	dbra	d0,loop
	move	#7999,d0
	move.l	a5,a6
	dbra	d1,loop
	rts
