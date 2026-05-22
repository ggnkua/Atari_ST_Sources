;
;
;A0 adresse de l'image compress‚ "*.MI1"
;A1 adresse de l'‚cran
;
 	move.l	4(sp),a0	;source
 	adda	#34,a0		;debut des pointeurs de donn‚es
	move.l 	8(sp),a1	;destination
	move	12(sp),d1
;	
	move.l	a0,a2
	add.l	#4000,a2	;+4000,d‚but des donn‚es a afficher
;
	clr.l  	d0
 	mulu 	#130,d1
 	add.w	#1869,d1
;
boucle:
 	move.w  (a0)+,d0	;pointeur sur les donn‚es a afficher

	move.l	0(a2,d0.l),(a1)+
	move.l	4(a2,d0.l),(a1)+
	move.l	8(a2,d0.l),(a1)+
	move.l	12(a2,d0.l),(a1)+
;
 	dbra 	d1,boucle 
 	rts
	end
 