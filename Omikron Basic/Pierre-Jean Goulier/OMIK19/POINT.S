;
; Basic Omikron & Assembleur.
; Routine ‚mulant un POINT VDI.
; ½ Start Micro & PJG / 1994.
;

ptsin	EQU	12

	move	4(sp),d4	; Point X.
	move	6(sp),d5	; Point Y.
	DC.W	$A000		; Init Line A.
	move.l	ptsin(a0),a3	; Tableau PTSIN => A3.
	move	d4,(a3)		; X => PTSIN(0).
	move	d5,2(a3)	; Y => PTSIN(1).
	DC.W	$A002		; Get Pixel.
	move	#-1,d1		; D1 = Compteur VDI.
	lea	table(pc),a4	; Table correspondance => A4.
loop:	addq	#1,d1		; Lire la couleur VDI.
	cmp	(a4)+,d0
	bne.s	loop
	move	d1,d0
	rts
table:	DC.W	0,15,1,2,4,6,3,5,7,8,9,10,12,14,11,13
	
