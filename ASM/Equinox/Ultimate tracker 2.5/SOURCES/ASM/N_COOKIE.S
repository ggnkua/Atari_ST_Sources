; 
; Cookie Jar manager (C)1991 By TBC
;

	.export	get_cookie
	.export	add_cookie
	.export	remove_cookie
	
; ------------------------------------------------------------------
; get a cookie
; in : d0 = identifier
; out: a0 = pointer on cookie
; ------------------------------------------------------------------

	text

get_cookie:
	movem.l	d1-d7/a1-a6,-(a7)
	move.l	d0,param
	pea		rout_get(pc)
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	move.l	pt_cook,a0
	movem.l	(a7)+,d1-d7/a1-a6
	rts
	
rout_get:
	move.l	#0,pt_cook			; par d‚faut retourne NULL
	move.l	param,d0			; d0 = parametre
	move.l	$5a0.w,a0			; a0 = adresse jar
	cmp.l	#0,a0				; inexistante ?
	beq.b	fin_get				; oui -> sort
	
bcl_get:
	move.l	(a0),d1				; d1 = id cookie
	beq.b	fin_get				; = 0 (fini) -> sort
	cmp.l	d0,d1				; compare avec recherch‚
	beq.b	ok_cookie			; idem -> ok
	addq.l	#8,a0				; different passe au suivant
	bra.b	bcl_get				; et boucle
	
ok_cookie:
	move.l	a0,pt_cook			; sauve adresse

fin_get:
	rts							; retour

* ------------------------------------------------------------------------
* add un cookie
* in : a0 = pointer on cookie struct
* out: d0 = 0 = ok
*			   -1 = cookie already exists
*			   -2 = unable to create cookie
* ------------------------------------------------------------------------

add_cookie:
	movem.l	d1-d7/a1-a6,-(a7)
	move.l	a0,pt_cook
	pea		rout_add(pc)
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	move.w	rep,d0
	movem.l	(a7)+,d1-d7/a1-a6
	rts
	
rout_add:
	clr.w	d7				; nbe de cookies = 0
	move.w	#-2,rep			; par d‚faut = erreur
	move.l	pt_cook,a0		; a0 = pointeur cookie
	move.l	(a0),d0			; d0 = ident.
	move.l	$5a0.w,a0		; a0 = adresse jar
	cmp.l	#0,a0			; inexistant ?
	beq.b	fin_add			; oui -> sort

bcl_add:
	move.l	(a0),d1			; d1 = id cookie
	beq.b	fin_jar			; = 0 (fini) -> suite
	cmp.l	d1,d0			; = cookie a ajouter ?
	beq.b	deja_present	; oui -> sort
	addq.l	#8,a0			; passe au suivant
	addq.w	#1,d7			; nbe cookie + 1
	bra.b	bcl_add			; boucle

fin_jar:
	move.l	4(a0),d6		; d6 = nombre de slots dispos
	cmp.w	d7,d6			; slots tous occup‚s ?
	blt.b	fin_add			; oui -> sort
	move.l	pt_cook,a1		; a1 = adresse structure cookie
	move.l	(a1),(a0)+		; place l'id dans le jar
	move.l	4(a1),(a0)+		; place les infos
	clr.l	(a0)+			; efface cookie suivant (final)
	move.l	d6,(a0)			; nbe de slots
	clr.w	rep				; ok
fin_add:		
	rts						; fin

deja_present:
	move.w	#-1,rep			; d‚j… l… !
	rts
	
* ------------------------------------------------------------------------------
* remove a cookie
* in : d0 = identifier
* out: d0 = 0 : error 1 : ok
* ------------------------------------------------------------------------------

remove_cookie:
	movem.l	d1-d7/a0-a6,-(a7)
	move.l	d0,param
	pea		rem_cook(pc)
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	move.w	rep,d0
	movem.l	(a7)+,d1-d7/a0-a6
	rts	

rem_cook:
	move.w	#0,rep			; par d‚faut : erreur
	move.l	param,d0		; d0 = identificateur
	move.l	$5a0.w,a0		; a0 = adresse cookie jar
	cmp.l	#0,a0			; existant ?
	beq.b	fin_remove		; oui -> on sort
bc:
	move.l	(a0),d1			; d1 = identificateur cookie
	beq.b	fin_remove		; = 0 ? -> donc pas trouv‚ -> on sort
	cmp.l	d0,d1			; on compare avec l'id cherch‚
	beq.b	ok_rem			; identiques -> on enleve
	addq.l	#8,a0			; passe au cookie suivant
	bra.b	bc				; boucle
	
ok_rem:
	lea		8(a0),a1		; passe au cookie suivant
	move.l	(a1)+,d0		; d0 = identificateur cookie suivant
	beq.s	fin_rem			; si = 0 -> dernier cookie
	move.l	d0,(a0)+		; sinon recopie sur cookie a enlever
	move.l	(a1)+,(a0)+		; recopie contenu cookie
	bra.b	ok_rem			; boucle

fin_rem:
	move.l	d0,(a0)+		; recopie cookie final
	move.l	(a1),(a0)		; d1 = nombre max de cookies
	move.w	#1,rep			; retour TRUE
fin_remove:
	rts						; fin

	data

rep:		ds.w	1
pt_cook:	ds.l	1
param:		ds.l	1	