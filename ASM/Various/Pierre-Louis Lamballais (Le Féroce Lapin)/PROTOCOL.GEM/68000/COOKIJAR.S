*--------------------------------------------------------------------------*
* Fichier "COOKIJAR.S"
* Routine appel‚e en mode superviseur avec Xbios(38).
* Etant donn‚ que dans le cas d'un tel appel il est quasiment
* impossible de passer des param‚tres, cette routine les
* r‚cupŠre dans COOKIE1, COOKIE2, COOKIE3
* COOKIE1   .L     nom du cookie … chercher 
* COOKIE2   .L     adresse de la boite … gateaux que nous
* proposons au cas ou l'actuelle serait pleine. (0 si nous
* ne voulons pas remplacer la boite).
* COOKIE3   .L     adresse … placer dans la boite, apr‚s le
* cookie1 s'il est trouv‚. 0 pour juste regarder !
* COOKIE4   .W  (0 ou 1)   Si nous trouvons COOKIE1: si COOKIE4 vaut 1,
* il faut imposer COOKIE3 dans le long mot suivant COOKIE1.
* COOKIE2  contient l'adresse de la boite … gateaux, 0 si ne
* l'a pas trouv‚ ou que sa cr‚ation est impossible.
* COOKIE3 contient le .L situ‚ apr‚s le COOKIE1 ou 0 si nous n'avons
* rien trouv‚.

COOKIE_JAR:
	MOVE.L	$5A0,A1	adresse syst‚me pour la boite
	CMP.L	#0,A1	il y a d‚ja une boite ?
	BNE.S	BOITE_OK	Oui
* Il n'y a pas de boite … gateaux, nous testons COOKIE2 pour
* savoir si nous devons en placer une.
	TST.L	COOKIE2
	BNE.S	.ICI
	BRA	END_COOKIE
* Il n'y a pas de boite, nous pla‡ons donc la notre. Par pr‚caution
* notre boite poss‚de 16 emplacements (contre 8 pour la boite
* d'origine des STE et TT)
.ICI	MOVE.L	COOKIE2,D0
	MOVE.L	D0,$5A0
	MOVE.L	D0,A1	pour la suite
* Notre boite est vide, devons-nous y mettre quelque chose ?
	TST.L	COOKIE3
	BEQ	END_COOKIE	non, donc bye bye
	BRA	FILL_COOKIE   oui donc remplissons
* Nous avons trouv‚ une boite … gateaux (adr. en A1)
* Suivant COOKIE1, nous devons chercher un  COOKIE ou non.
BOITE_OK	TST.L	COOKIE1	faut-il chercher un gateaux?		
	BEQ	END_COOKIE non, donc bye bye

* Bouclons pour chercher si le COOKIE1 est dans la boite...
	MOVEQ	#0,D7		init le compteur de gateaux
	MOVE.L	COOKIE1,D2		valeur … chercher...
MIAM	MOVE.L  	(A1)+,D0      	Prends un gateaux
        	MOVE.L  	(A1)+,A0  		puis un autre (gourmand!)
        	ADDQ.W    	#1,D7     		compte un couple
        	TST.L     	D0        		Emplacement vide?
        	BNE     	CMP_COOKIE		non, donc comparons...
* Nous avons trouv‚ un gateaux vide!!!!! C'est sans doute la fin
* de la liste.... devons nous essayer de d‚poser dans la boite
* notre COOKIE ou bien dire simplement qu'on a pas trouv‚ COOKIE1 ?
* Cela d‚pend de la valeur de COOKIE3!
* ATTENTION, une pr‚caution tr‚s importante!!! Il est tout a fait
* possible qu'un programme ait fabriqu‚ une boite, not‚ son
* emplacement en 5A0, puis soit parti! L'adresse de la boite
* est donc toujours en 5A0, mais … cette adresse il n'y a plus
* rien!!! On v‚rifie donc le nombre de slots, nombre qui doit
* ‚tre dans A0!
	CMP.L	#0,A0	il y a des slots?
	BNE	.ICI	oui, c'est ok...
* Cookie vide mais aussi nombre de slot nul, cela veut dire
* que l'adresse trouv‚e en 5A0 est mauvaise!
	CLR.L	$5A0
	BRA	COOKIE_JAR recommen‡ons tout haut!!!	
.ICI	TST.L	COOKIE3
	BEQ	END_COOKIE	rien … d‚poser, donc bye bye...
* Nous n'avons pas trouv‚ notre COOKIE1, nous allons donc le
* placer dans la boite, en le faisant suivre par COOKIE3.
* Mais y-a-t il encore de la place dans la boite ?
	MOVE.L	A0,D0	nombre d'emplacement
	CMP.L	D0,D7	compare aux couples lus
* NOTE: le couple vide est compt‚ comme 1. Si nous trouvons
* dans la boite mention de 8 slots, il n'y en a en fait
* que 7 pour les gateaux puisque le dernier (le huitiŠme)
* indique la fin!
	BEQ	BIG_BOITE il faut faire une boite + grande!	
* Reculons pour placer notre nom de cookie et l'adresse.
	SUBA.L	#8,A1
	MOVE.L	COOKIE1,(A1)+
	MOVE.L	COOKIE3,(A1)+
	MOVE.L	#0,(A1)+	indique fin de liste
	MOVE.L	D0,(A1)+	et nombre de slots
	BRA	END_COOKIE 
* La boite est d‚ja pleine! Nous allons donc
* cr‚er une nouvelle boite, plus grande, transvaser le
* contenu de l'ancienne dans la nouvelle, et y d‚poser
* notre gateaux, bien confortablement (pas au frais, les gateaux	
* n'aiment pas trop l'humidit‚).
* Nous avons pr‚vu une nouvelle boite avec 16 emplacements.
* Si l'ancienne contenait d‚ja au moins 16 couples, nous
* abandonnons, car nous n'aurons pas assez de place.
BIG_BOITE	CMP.L	#16,D0
	BHS	NO_BOX
	TST.L	COOKIE2	mettre une boite ?
	BEQ	NO_BOX
	MOVE.L	$5A0,A0	reprend d‚part de la boite
	MOVE.L	COOKIE2,A1 adr nouvelle boite
	MOVE.L	A1,$5A0	adr. syst‚me
* -2 pour D7 car nous allons travailler en DBF et en plus
* il ne faut pas recopier le slot vide.
	SUBQ.W	#2,D7
	TST.W	D7	pr‚caution...
	BPL	.HOP	c'est ok!
	MOVE.L	#0,COOKIE2 boite abim‚e!
	BRA	END_COOKIE	
.HOP	MOVE.L	(A0)+,(A1)+
	MOVE.L	(A0)+,(A1)+
	DBF	D7,.HOP
* La recopie ‚tant faites, pla‡ons COOKIE1 et COOKIE3
FILL_COOKIE
	MOVE.L	COOKIE1,(A1)+
	MOVE.L	COOKIE3,(A1)+
	MOVE.L	#0,(A1)+	le slot vide
	MOVE.L	#16,(A1)+	et le nombre total de slots
	BRA	END_COOKIE

NO_BOX	MOVE.L	#0,COOKIE3	 rat‚, impossible de mettre notre cookie...
	BRA	END_COOKIE

* Nous avons trouv‚ un cookie dans la boite!
* Est-ce celui que nous cherchons ?
CMP_COOKIE	CMP.L	D0,D2   c'est notre gateaux ?
	BNE	MIAM    non, bonne excuse pour en prendre d'autres...
* Nous avons trouv‚ le gateaux qui est indiqu‚ dans COOKIE1!
* Devons nous simplement noter l'adresse qui suit ou bien
* forcer cette adresse avec la valeur de COOKIE3 ?
* Cela d‚pend de la valeur de COOKIE4!
	TST.W	COOKIE4	juste prendre l'adresse ?
	BEQ	.LA	oui
* COOKIE4 valant 1, nous devons placer COOKIE3 dans la boite.
	SUBA.L	#4,A1	recule sur le bon endroit
	MOVE.L	COOKIE3,(A1)
	BRA	END_COOKIE	et bye bye...
.LA	MOVE.L	A0,COOKIE3 

END_COOKIE	MOVE.L	$5A0,COOKIE2	
	RTS
*--------------------------------------------------------------------------*
