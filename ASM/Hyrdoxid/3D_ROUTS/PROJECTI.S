***************************
*ROUTINE DE PROJECTIONS 3D*
*          by  	    *
*   Cristalion/Hydroxid   *
***************************
;fait en 20 minutes !!!
;probleme si ze>128 mais pas grave car la rez ne permet pas un
;tel ze(sort de l'ecran a cause de la focale faible)

;-----------------------------
;routine de projection 3D
;1) calcul de Q=1-(ZE/FC)
;on multiplie q par 512 et on obtient:
;Q*512=512-4ZE pour FC=128 
;D0=Q    D1=ZE    D2=FC
;-----------------------------
	MOVE.W	#512,D3
	MOVEQ	#9,D0	;pour decalages/512
	MOVE.W	ZE,D1
	ASL.W	#2,D1	;4*ZE
	SUB.W	D1,D3	;512-4*ZE=Q*512
;-----------------------------
;2)calcul de X=XE/Q
;Q=D3    XE=D1  X=D1
;-----------------------------
	MOVE.W	XE,D1
	EXT.L	D1
	ASL.L	D0,D1	;XE*512
	DIVS	D3,D1	;XE*512/Q*512=X
	ADD.W	#192,D1	;CENTRE LES X
;-----------------------------
;3)calcul des Y=YE/Q
;Y=D2
;-----------------------------
	MOVE.W	YE,D2
	EXT.L	D2
	ASL.L	D0,D2	
	DIVS	D3,D2
	ADD.W	#120,D2

	SECTION	DATA
ZE	DC.W	10
XE	DC.W	-23
YE	DC.W	5
	END