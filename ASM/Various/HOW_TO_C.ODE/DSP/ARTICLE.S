


******************************************************************************
*                                                                            *
*                   Communication entre DSP et 68030                         *  
*                  ----------------------------------                        *
*                                                                            *
* Article ecrit par No Way qui en ce moment fait un jeu ( excellent ) et qui *
* entre 2 tableaux a bien voulu faire  cet article  qui servira a toutes les *
* gens desirant utiliser le FALCON a 100%.Pour en revenir au jeu, il va etre *
* distribue en DECEMBRE et je conseille  a tout le monde de l' acheter  et a *
* personne de le deplomber... Sinon c' est a tout E.K.O que vous touchez  et *
* donc a MOI ....                                                            *
*                                                                            *
*  Remarque: C'est lui les 6000 points sur FALCON  , la demo qui a gagne  le *
* concours FALCON a la PLACE TO BE.Elle avait ete faite en seulement 2 jours *
* Meme chose pour la demo de  MJJ PROD avec l' excellent  JOKER , qui a bien *
* faillit gagner lui aussi.                                                  *
*                                                                            *
******************************************************************************





   Cet article a pour but d'expliquer une des methodes de transfert de donnees
entre la ram du DSP et celle du 68030. Il s'adresse a des personnes ayant deja
quelques notions d'assembleur, ainsi que quelques notions du DSP ( son organi-
-sation memoire, ses registres...).

Si vous debutez a peine, n'hesitez pas a me contacter en bal:
                              No way sur 3615 rtel (NDLR: 3614 rtel1)


Commencons par decrire le fonctionnement de l'host port(port parallele 8 bits)

    - Du cote 68030 l'host port est represente par 8 octets (se situant sur le 
falcon a partir de l adresse $ffffa200) :
	 

 -> 4 octets pour le controle et l'etat

	 octet 0 : interrupt control ICR
	 octet 1 : command vector CVR
	 octet 2 : interrupt status ISR 
	 octet 3 : interrupt vector IVR

 -> 4 octets pour les donnees
	
	 octet 4 : inutile mais bien utile !
	 octet 5 : poids fort de la donnee
	 octet 6 : poids 'moyen' de la donnee
	 octet 7 : poids faible de la donnee
	

(seul 3 octets sont necessaires car le mot (.w) elementaire DSP est de 24 bits
le quatrieme est utile car le 68030 est un 32 bits !)

  Pour realiser un transfert simple, nous avons uniquement besoin de connaitre
la signification des bits 0 et 1 du registre ISR  (  bits 0 et 1 de l' adresse 
$ffffa202  )

    ISR bit 0 (Receive data register full) : Ce bit est mis a 1 lorsque l'octet
de poids fort est recu du DSP,il est remis a 0 lorsque le 68030 a lu l'octet de
poids faible.

    ISR bit 1 (Transmit data register empty): Ce bit est mis a 1 lorsque le DSP
a recu l' octet de poids fort , et remis a 0 lorsque  68030 inscrit l' octet de
poids faible.


 Exemple:
----------

   Ci dessous,la routine  -> systeme Dsp_blkunpacked desassemble <-  qui permet
d' envoyer et  de recevoir a partir  d' un buffer source et d' un buffer desti-
-nation un certain nombre de longs mots au DSP.  Comme vous pouvez le constater
cette routine n'est d'une part pas optimise, et a le desavantage de n' etre pas
tres souple  ( Les donnees envoyees au DSP  sont transmises en rafale , UN seul
test est effectue AVANT la boucle d'envoi,ce qui suppose donc que le DSP va les
lire en connaissance de cause :  C' est a dire sans perdre trop de temps  entre
chaque lecture !   Il en est de meme pour la reception ... )
  
; Routine systeme Dsp_blkunpacked 
; (Opcode 98 Dsp_BlkUnpacked(data_in,size_in,data_out,size_out))
;                                             long *data_in
;                                             long size_in
;                                             long *data_out
;                                             long size_out
; en Assembleur:   
;                 move.l	#size_out,-(sp)
;		  pea		data_out
;		  move.l	#size_in,-(sp)
;		  pea		data_in
;		  move.w	#98,-(sp)
;		  trap		#14
;		  lea	        18(sp),sp


	MOVEA.L	4(A7),A0	; buffer d'envoi
	MOVE.L	8(A7),D0	; nombre de mots longs a envoyer
	MOVEA.L	$C(A7),A1	; buffer de reception
	MOVE.L	$10(A7),D1	; nombre de mots longs a recevoir

	TST.L	D0		; teste si il y a des donnees a envoyer
	BEQ	label1

	SUBQ.W	#1,D0
label2:	BTST	#1,$FFFFA202.W	
        ; attend que le port soit pres pour l'emission
	BEQ.S	label2 		; 

label3:	MOVE.L	(A0)+,$FFFFA204.W	; envoi en 'rafale'
	DBF	D0,label3

label1: TST.L	D1		; teste si il y a des donnees a recevoir
	BEQ	label4

	SUBQ.W	#1,D1
label5:	BTST	#0,$FFFFA202.W	; attend que la premiere donnee soit recue
	BEQ.S	label5

	; lis les autres donnees en provenance du Dsp.
label6:	MOVE.L	$FFFFA204.W,(A1)+	
	DBF	D1,label6

label4: RTS



        Du cote du Dsp , la demarche est identique. On utilisera 3 registres du
port B:

 Le PBC ( port B control register ) a l'adresse $ffe0 seul le bit 0 est utilise
si ce bit est positionne , le port B est configure en mode Host interface,sinon
il est en mode parallel I/O.

 Le HSR ( host status register ) a l ' adresse  $ffe9 . Le bit 0 indique si une
donnee est recue  du  68030.  Ce bit est remis  a zero des que le DSP  a lu  la
donnee.Le bit 1 indique si le registre d'emission est libre, ce bit est remis a
0 des que le dsp y inscrit une valeur.

 Et enfin le registre HTX, HRX registre d'emission et de reception,qui ce situe
a l'adresse $ffeb 


  Voici donc un exemple de programme qui recoit deux donnees du 030,un sinus et
un cosinus et qui fait la rotation correspondante, autour de l'axe  (zz') des 2
points dont les coordonnees se trouve a l'adresse $0 de la memoire X du DSP. 
      


NB_PTS:	equ	2

PBC:	equ	$ffe0
HSR:	equ	$ffe9
HTX:	equ	$ffeb

	org	p:$0
	jmp	start

	org	P:$40

start	
	move	#$ffff,m0	
	

wait_sinus
	movep	#1,X:PBC		;  
	jclr	#0,x:HSR,wait_sinus	; attend l'arrivee d'une donnee

	move	x:HTX,x1		; stock la donnee recue dans X1
					; dans notre cas le sinus
wait_cosinus
	movep	#1,X:PBC		;  
	jclr	#0,x:HSR,wait_cosinus	; attend l'arrivee du cosinus
	move	x:HTX,x0		; stock le cosinus dans X0



	move	#data,r0		; charge l'adresse du tableau
					; des coordonnees dans R0

	do	#NB_PTS,boucle		; boucle hardware qui executera
					; NB_PTS fois les 8 instructions
					; suivantes


	move	x:(r0)+,y0		; charge la coordonnee X
	move	x:(r0)+,y1		; charge la coordonnee Y


	mpy	y0,x1,a			; multiplication signee de y0 et x1
					; qui stocke le resultat dans A

	macr	-y1,x0,a		; multiplication signee 
					; additionne le resultat a A 
					; et arrondi le resultat final  

	mpy	y0,x0,b	
	macr	y1,x1,b	

send_x	jclr	#1,X:HSR,send_x		; attend que le registre d'envoi
					; de l'host soit vide.
	move	A1,X:HTX		; envoi de la coordonnee X

send_y	jclr	#1,X:HSR,send_y
	move	b1,X:HTX

boucle	

	jmp	start




	org	x:$0
data
	dc	10,10
	dc	20,20

	end


 Dans l'exemple precedent pour faciliter la comprehension le source n'a pas ete
optimise. En effet, on aurait pu utiliser , par exemple , les ' parallel move '
( Certaines instructions peuvent s' executer en paralelle avec une ou deux ins-
tructions MOVE)

Ce qui aurait donne le source suivant :
---------------------------------------

;
;start	
;	move	#$ffff,m0	
;	
;
;wait_sinus
;	movep	#1,X:PBC		  
;	jclr	#0,x:HSR,wait_sinus	
;
;	move	x:HTX,x1		
;					
;wait_cosinus
;	movep	#1,X:PBC		
;	jclr	#0,x:HSR,wait_cosinus	
;	move	x:HTX,x0		
;
;
;
;	move	#data,r0		
;	nop				
;	move	x:(r0)+,y0	
;	move	x:(r0)+,y1
;	
;	do	#NB_PTS,boucle
;
;	mpy	y0,x1,a
;	macr	-y1,x0,a	
;
;	mpy	y0,x0,b		x:(r0)+,y0
;	macr	y1,x1,b		x:(r0)+,y1
;
;send_x	jclr	#1,X:HSR,send_x
;	move	A1,X:HTX
;
;send_y	jclr	#1,X:HSR,send_y
;	move	b1,X:HTX
;
;boucle
;
;	jmp	start
;
;


    Voila pour ce qui est de la communication entre le 68030 et le DSP. Si vous
avez une autre technique ou alors autre chose sur le DSP(Optimisations etc ...)
vous pouvez ecrire a HOW TO CODE ou le marquer sur RTEL en *PATA 2.Je pense que
dans ce domaine tres sensible de la programmation sur FALCON, tout indicice est
precieux.

                --> signed:  No Way
