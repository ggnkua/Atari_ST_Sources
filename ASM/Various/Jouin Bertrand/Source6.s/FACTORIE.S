* routine recursive de calcul de factoriel
* par Golio Junior pour Falk'mag 6

	section TEXT

	move.l #10,d0

	bsr fact

			* retour systŠme
	move.w #0,-(sp)
	trap #1

* fonction qui calcul factoriel de maniŠre r‚cursive
* entr‚e : d0.l : factoriel … calculer
* sortie : d1.l : r‚sultat de la factoriel
fact
	tst.l d0		* factoriel de 0?
	bne fact_s1	* non alors on continue
	move.l #1,d1	* oui, alors c'est ‚gal … 1
	rts
fact_s1
	cmp.l #1,d0	* factoriel de 1?
	bne fact_s2	* non alors on continue
	move.l #1,d1	* oui, alors c'est ‚gal … 1
	rts
fact_s2
	move.l d0,-(sp)	* on calcul factoriel de d0-1
			* donc on sauve d0
	subq.l #1,d0	* d0=d0-1
	bsr fact		* calcul de la factoriel
			* d1 contient la factoriel de d0-1
	move.l (sp)+,d0	* r‚cup‚ration de d0
	mulu.l d0,d1	* calcul de factoriel d0
	rts