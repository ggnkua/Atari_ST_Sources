********************************************************
*           EXTRAIT DE LA BIBLIOTHEQUE TUBE GEM        *
*                  FICHIER "CHOICE.S"                  *
*              VERSION 2.00 (23 mars 1991)             *
********************************************************
CHOICE_TUBE:	
	MOVEM.L	D2-D7/A1-A6,-(SP)

	ADDA.L	#6,A0   pour sauter l'en-t‚te
	
	MOVE.L	A0,A6   sauve d‚but du tableau
	MOVE.L	A6,A5
	BSR	SOUFFLAGE   souffle dans le tuyau GEM
	RSRC_GADDR	#0,#TUBE	    cherche adresse formulaire
	MOVE.L	ADDR_OUT,A0    sauve l'adresse
	MOVE.L	A0,ADR_FORM    adr du formulaire
	FORM_CENTER   A0	centre le formulaire
	MOVEM.W	INT_OUT+2,D0-D3	r‚cup‚re les dimensions
	MOVEM.W	D0-D3,X_TUBE         et les sauve
	CLR.W	DIAL_TUBE	form_dial    non-ex‚cut‚
	BSR	HIDE_ALL       cache tous les boutons
	
	LEA	TAB_OKAPID,A0  tableau des apid par bouton
	MOVE.L	A0,PTN_OKAPID
	CLR.W	D5	init le compteur des APP_ID
	MOVE.W	#TUBE1,D7  premier bouton du formulaire
	CLR.W	MONO_FLAG	flag si je suis seul   
HOP	MOVE.W	(A5)+,D6    pr‚l‚ve AP_ID
	ADDQ.W	#1,D5	 et le compte
	CMP.W	#$FFFF,D6   fin du tableau ?
	BEQ.S	.HOP1	 oui
* Sommes-nous en train de d‚passer la fin du tableau ?
	CMP.W	-2(A6),D5	compare … nbr APP_ID autoris‚
	BLS.S	.ICI	encore bon, continuons
* Soit nous sommes sur le flag de fin, soit nous sommes en
* fin de tableau (d'apr‚s le nbr d'APP_ID autoris‚).
.HOP1	MOVE.L	A6,A5 	r‚-init
	CLR.W	D5	remet … 0 compteur d'APP_ID
	CMP.W	#TUBE1,D7  encore au d‚but ?
	BNE	GERE_FORMTUB  non -> g‚rer le formulaire
* Si MONO_FLAG vaut toujours 0, c'est qu'il n'y a pas de
* correspondant mais qu'en plus nous ne nous sommes pas trouv‚!
	TST.W	MONO_FLAG	
	BNE.S	HOP
* Suivant la valeur de JY_SUIS nous savons si nous
* sommes th‚oriquement dans la liste ou non...
	CMP.W	#$FFFF,JY_SUIS
	BEQ	NOBODY	je n'y suis pas...
	FORM_ALERT	#1,#ALERTE_TUB1   tableau endommag‚, bye bye
	BRA	NO_CHOICETUBE

* Nous avons lu un APP_ID qui n'est pas le flag de fin et nous
* ne sommes pas en bout de liste.
.ICI	CMP.W	APP_ID,D6   c'est le mien ?
	BNE.S	NOT_MINE
	CMP.W	#$FFFF,MONO_FLAG   je me suis d‚ja trouv‚ ?
	BNE.S	NO_ME
* Nous sommes seuls, nous pr‚venons l'utilisateur avec un message
* diff‚rent suivant que nous testions 300 ou 500 
NOBODY	MOVE.W	52(SP),D0	type de message … traiter
	CMP.W	#500,D0
	BEQ.S	.ICI_500
	FORM_ALERT	#1,#ALERTE_TUB2     je suis seul! (300)
	BRA 	NO_CHOICETUBE
.ICI_500	FORM_ALERT	#1,#ALERTE_TUB2BIS  je suis seul! (500)
	BRA 	NO_CHOICETUBE
* Nous notons que nous nous sommes trouv‚ dans la liste
NO_ME	MOVE.W	#$FFFF,MONO_FLAG
	BRA	HOP	et nous recommen‡ons
* Nous pouvons ‚crire … cet APP_ID
NOT_MINE	LEA	MESSAGEBUF,A0
	MOVE.W	52(SP),D0       	300 ou 500
	MOVE.W	D0,(A0)+   	es-tu compatible?
	MOVE.W	APP_ID,(A0)+  	mon ap_id
	MOVE.L	#0,(A0)+   	le reste	
	MOVE.L	#0,(A0)+		est mis
	MOVE.L	#0,(A0)+		… z‚ro
	APPL_WRITE  D6,#16,#MESSAGEBUF
* Attendons la r‚ponse...
NEXT_MULTI	EVNT_MULTI	#%110000,#1,#1,#1,#0,#0,#0,#0,#0,#0,#0,#0,#0,#0,#MESSAGEBUF,#500
	BTST	#4,D0      ‚v‚nement message ?
	BNE	.ICI2      oui donc lisons-le
	BTST	#5,D0      ‚v‚nement timer ?
	BNE	HOP        oui donc timer-out, passons au prochain			
	BRA	NEXT_MULTI rien de valable, attendons!
* Test de l'‚v‚nement message.
.ICI2	LEA	MESSAGEBUF,A0
	MOVE.W	52(SP),D0
	ADDQ.W	#1,D0      pour faire 301 ou 501
	CMP.W	(A0),D0    c'est une r‚ponse 'pas compatible'?
	BEQ	HOP    	oui donc passons … l'ap_id suivant
	ADDQ.W	#2,D0   	pour faire 303 ou 503
	CMP.W	(A0),D0   	c'est une r‚ponse 'je suis compatible'?
	BNE	NEXT_MULTI  non, recommencons l'attente,
* parce que cela peut-‚tre un message de redraw pour une de nos fen‚tre,
* mais ceci ne nous interesse pas pour le moment.
	CMP.W	2(A0),D6    c'est le bon correspondant ?
	BNE	HOP
	MOVE.L	6(A0),A4    d‚but des phrases identificatrices
	CLR.W	D4          donc identif. 0
	MOVE.W	#$EEEE,MONO_FLAG   il y a d'autres applications!
* Cherchons l'adresse du bouton  (r‚sultat en A0)
NEXT_BUTTON
	MOVE.L	ADR_FORM,A0
	OBJECT	A0,D7,A0,D0
	MOVE.W	#$15,8(A0)    selectable, exit et r_button
	MOVE.L	12(A0),A0     adr dest du texte
	MOVE.W	#31,D0	le descripteur est sur 32 octets
.LOOP	MOVE.B	(A4)+,(A0)+   met en place le descripteur
	DBF	D0,.LOOP
* Rangement dans le tableau l'APID et le num‚ro de descripteur
	MOVE.L	PTN_OKAPID,A0
	MOVE.W	D6,(A0)+      apid
	MOVE.W	D4,(A0)+      num‚ro du descripteur
	MOVE.L	A0,PTN_OKAPID
	ADDQ.W	#1,D4    descripteur suivant	
	CMP.W	#TUBE5,D7    c'‚tait le dernier bouton ?
	BEQ	GERE_FORMTUB
	ADDQ.W	#1,D7
* Je pr‚l‚ve le s‚parateur de phrase, en le sautant
	MOVE.W	(A4),D0 
	CMP.W	#$00FF,D0  c'‚tait la derniŠre phrase ?
	BEQ	HOP        oui donc on charge une nouvelle liste
	ADDA.L	#2,A4	Saut de separateur
	BRA	NEXT_BUTTON  non --> continue le remplissage
* Le formulaire est rempli, allons le g‚rer	
GERE_FORMTUB
* Nous testons une bascule pour faire un form_dial
* une seule fois.
	TST.W	DIAL_TUBE
	BNE.S	.NO_DIAL
	FORM_DIAL	#0,#0,#0,#0,#0,X_TUBE,Y_TUBE,W_TUBE,H_TUBE
	NOT.W	DIAL_TUBE
.NO_DIAL	MOVE.L	ADR_FORM,A3
	OBJC_DRAW	A3,#0,#10,X_TUBE,Y_TUBE,W_TUBE,H_TUBE
	MOVEQ	#0,D3
	FORM_DO	A3,D3
* La gestion est fini, avec quoi sommes-nous sortie ?
	MOVE.W	D0,D3 sauve r‚sultat
	OBJECT	A3,D3,A0,D0
	CMP.B	#26,7(A0)
	BNE.S	.NOTBUT
	BCLR	#0,11(A0)
.NOTBUT	CMP.W	#NEXTTUBE,D3   suite de la liste?
	BNE.S	NOT_NEXT     
* Nous avons une demande pour poursuivre la recherche.
	BSR	HIDE_ALL	re-cache les boutons (par d‚faut)
	LEA	TAB_OKAPID,A0  tableau des apid par bouton
	MOVE.L	A0,PTN_OKAPID
	MOVE.W	#TUBE1,D7   premier bouton du formulaire
	MOVE.W	(A4),D0    saute le s‚parateur 
	CMP.W	#$00FF,D0  c'‚tait la derniŠre phrase ?
	BEQ	HOP        oui donc on charge un nouvel AP_ID
	ADDA.L	#2,A4	Saut de separateur
	BRA	NEXT_BUTTON  non --> continue le remplissage

NOT_NEXT	MOVE.W	D3,D7   sauve le choix (plus sur que D3)	
	FORM_DIAL	#3,#0,#0,#0,#0,X_TUBE,Y_TUBE,W_TUBE,H_TUBE
	CMP.W	#ANNUTUBE,D7	bouton annuler ?
	BEQ.S	NO_CHOICETUBE	oui donc bye bye...

* Calculons quel bouton a ‚t‚ choisit pour piocher l'AP_ID
* et l'identificateur dans le tableau TAB_OKAPID.
	LEA	TAB_OKAPID,A0
	MOVE.W	#TUBE1,D0
	SUB.W	D0,D7     contient le choix bouton corrig‚
	LSL.W	#2,D7
	MOVE.W	0(A0,D7.W),D0	APP_ID choisit
	MOVE.W	2(A0,D7.W),D1	et l'identificateur
	BRA.S	END_CHOICE
* Rien de choisit ou rien de valable, nous l'indiquons
NO_CHOICETUBE
	MOVE.W	#$FFFF,D0	
	MOVE.W	#$FFFF,D1	
END_CHOICE  MOVEM.L	(SP)+,D2-D7/A1-A6
	RTS
*--------------------------------------------------------------------------*
* Par d‚faut, nous cachons tous les boutons du formulaire
HIDE_ALL	MOVEM.L	D0-D7/A0-A6,-(SP)
	MOVE.L	ADR_FORM,A6
	OBJECT	A6,#TUBE1,A0,D0
	MOVE.W	#$80,8(A0)	
	OBJECT	A6,#TUBE2,A0,D0
	MOVE.W	#$80,8(A0)	
	OBJECT	A6,#TUBE3,A0,D0
	MOVE.W	#$80,8(A0)	
	OBJECT	A6,#TUBE4,A0,D0
	MOVE.W	#$80,8(A0)	
	OBJECT	A6,#TUBE5,A0,D0
	MOVE.W	#$80,8(A0)	
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS
*--------------------------------------------------------------------------*
