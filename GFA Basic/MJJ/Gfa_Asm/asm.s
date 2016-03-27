*
; Appel GFA BASIC
; varfinal%=C:prgasm%(L:var1%,L:var2%)
; Note : a compiler sous Devpack 2.0
; Zorro 2 of MJJPROD
*

* DEBUT *

Debut
	
	;Je recupere mes coordonnees et je les assignes
	move.l	4(SP),D1	;var1%
	move.l	8(SP),D2	;var2%
	
Traitement
	
	;J'additionne var1% et var2%
	clr.l	D0
	move.l	D1,D0
	add.l	D2,D0		;resultat dans D0
	
Fin

	rts
		
* FIN *	
