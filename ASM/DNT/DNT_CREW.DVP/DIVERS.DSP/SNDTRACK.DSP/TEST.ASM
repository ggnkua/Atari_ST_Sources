;Exemple de programme … charger soit par le Xbios en conditions normales,
;soit pendant l'ex‚cution de la routine de soundtracker DSP...
;(C)oderight Nullos/DNT-Crew 1994

	nolist			;coupe le listing dans *.LST
	include	'ioequ.asm'	;
	include	'intequ.asm'	;
	himem	x:$3fff,y:$3fff,p:$7fff
	list			;R‚-active la sortie listing

Test	ident	1,0		;Test simple

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;; Macros pour acc‚der au port Host ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ReadHost	MACRO	dest
	jclr	#M_HRDF,x:<<M_HSR,*
	movep	x:<<M_HRX,dest
	ENDM

WritHost	MACRO	srce
	jclr	#M_HTDE,x:<<M_HSR,*
	movep	srce,x:<<M_HTX
	ENDM

	org	p:$0		;Comme tout programme DSP, commence en
	jsr	<Wouah		;P:$0000 et saute dans la suite.

	org	p:$40
Wouah	ReadHost	x0		;Lire les deux donn‚es envoy‚es par
	ReadHost	x1		;le 68030 … travers le port Host.
	WritHost	#$240671		;Lui ‚crire un peu n'importe quoi...
	mpy	x0,x1,a		;
	WritHost	a		;Et r‚pondre d'abord avec le produit
	move	x0,a		;
	andi	#$fe,ccr		;Puis ensuite par une division
	rep	#24		;non sign‚e, toute simple.
	div	x1,a		;
	WritHost	a0		;Et pof, communique le quotient.
	jmp	<*		;Attendre ind‚finiment.

	