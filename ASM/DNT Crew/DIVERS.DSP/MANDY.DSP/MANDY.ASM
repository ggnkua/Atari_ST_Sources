	NOLIST
	include	'ioequ.asm'
	LIST

mandy	ident	1,0	;Generateur Mandelbrot minimaliste

dsp	equ	0
	include	'mandy.inc'

ReadHost	MACRO	dest
	jclr	#M_HRDF,x:<<M_HSR,*
	movep	x:<<M_HRX,dest
	ENDM

WritHost	MACRO	srce
	jclr	#M_HTDE,x:<<M_HSR,*
	movep	srce,x:<<M_HTX
	ENDM

	COMMENT	%
Le DSP calcule en virgule fixe, avec 23 bits d‚cimaux [a.2^23] (->0.5=$400000 -1=$80000).
Donc il gŠre directement des nombres d‚cimaux entre -1 et 0.999 .Pour Mandy, comme
les coordonn‚es peuvent aller de -2 … 1.999 (au del…, la norme sera au moins 2,
donc divergence). Donc faut travailler avec le format DSP divis‚ par 2 (0.5=$200000
et -1=$C00000). Mais pour une multiplication, ca donnera [a.2^23]/2*[b.2^23]/2=[ab.2^23]/4
donc un r‚sultat trop petit.
Avec le scaling up, le transfert du r‚sultat en x0 ou y0 le remettra comme il faut. Mais
pour x1 (Xc) qu'il faut additionner au r‚sultat brut, il faut donc le tenir au format
DSP divis‚ par 4. y1 (Yc) doit ˆtre maintenu … /8 pour permettre de calculer (Xn*Yn+Yc/2)
r‚ajust‚ par le asl du milieu de boucle.
Si une des coordonn‚es r‚sultats est plus grande que [2.2^23]/4, alors le transfert en
x0 ou y0 sera plus grand que [2.2^23]/2=[1.2^23] => il y aura limitation, d‚tect‚ par
le sticky-bit L en fin de boucle. Faut effacer L un fois trouv‚.
Pour avancer en Xc, comme il faut obtenir x1 en /4, et qu'il y aura scaling up,
il faut travailler en /8, d'ou le addr #resol/8,a. Par contre pour y1, le calcul est
se fait en /8 d'o— le asr pour revenir dans ce format.
		%

	org	p:$0
;	jmp	<begin		;Code totalement bestial en pleine table
;				;de vecteurs DSP... ‡a gagne des octets,
;	org	p:$40		;pour le message en boot.. hihi!
			;Ne jamais faire ‡a dans un programme propre, bien s–r...

begin	ori	#%00001000,mr	;Scaling Up
	move	#starty/8,y1	;
	do	#resoly,fin_y	;
	  move	#startx/4,x1	;x1=Xc b=Yc
	  do	#resolx,fin_x	;
	    andi	#%10111111,ccr	;Vire le bit L-imiting
	    tfr	x1,b	y1,a	;On se paye un petit ajustement du /4
	    move	b,x0		;en chargeant X1 et Y1 (cf -\)
	    asl	a		;
	    do	#prof,fin_iter
		mac	x0,x0,b	a,y0	;Xc+Xn2         # y0=Yn
		jls	<stop		;-L-imiting sur Xn ou Yn ?
		macr	-y0,y0,b	y1,a	;Xc+Xn2-Yn2     # pr‚pare a=Yc en /8
		macr	x0,y0,a	b,x0	;  Xn*Yn+Yc/2   # x0=Xn+1
		asl	a	x1,b	;2*Xn*Yn+Yc     # pr‚pare b=Xc en /4
fin_iter	    clr	a		;Pas de divergence
	    jmp	<nextx		;
stop	    move	lc,a1		;Divergence, selon compteur
	    enddo			;
nextx	    WritHost	a1		;Balance la sauce
	    tfr	x1,b	#>size_x/resolx/8,a
	    addr	a,b		;Puisque l'incr‚ment sur Xc est le mˆme
	    tfr	y1,b	b,x1	;que sur Yc, on combine les 2 fins de
fin_x	  add	a,b		;boucle.
	  asr	b
	  move	b,y1		;
fin_y
;	jmp	<*	;On laisse le DSP partir dans les choux...
